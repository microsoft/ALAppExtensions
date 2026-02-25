/// <summary>
/// Provides utility functions for creating and managing timesheets in test scenarios, including time sheet lines and resource time sheets.
/// </summary>
codeunit 131904 "Library - Time Sheet"
{
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
    end;

    var
        ResourcesSetup: Record "Resources Setup";
        TempTimeSheetLine: Record "Time Sheet Line" temporary;
        Assert: Codeunit Assert;
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";
        LibraryResource: Codeunit "Library - Resource";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryAssembly: Codeunit "Library - Assembly";
        TimeSheetApprovalMgt: Codeunit "Time Sheet Approval Management";
        Initialized: Boolean;
        NoSeriesCode: Label 'TS';
        TimeSheetFieldValueErr: Label 'Time Sheet field %1 value is incorrect.';

    procedure Initialize()
    var
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
    begin
        if Initialized then
            exit;

        if not ResourcesSetup.Get() then begin
            ResourcesSetup.Init();
            ResourcesSetup.Insert();
        end;

        if ResourcesSetup."Time Sheet Nos." = '' then begin
            ResourcesSetup.Validate("Time Sheet Nos.", GetTimeSheetNoSeries());
            ResourcesSetup.Modify();
        end;

        Initialized := true;
        LibraryERMCountryData.CreateVATData();

        Commit();
    end;

    procedure CheckAssemblyTimeSheetLine(TimeSheetHeader: Record "Time Sheet Header"; AssemblyHeaderNo: Code[20]; AssemblyLineNo: Integer; AssemblyLineQuantity: Decimal)
    var
        TimeSheetLine: Record "Time Sheet Line";
    begin
        TimeSheetLine.SetRange("Time Sheet No.", TimeSheetHeader."No.");
        TimeSheetLine.SetRange("Assembly Order No.", AssemblyHeaderNo);
        TimeSheetLine.SetRange("Assembly Order Line No.", AssemblyLineNo);
        TimeSheetLine.FindLast();
        TimeSheetLine.CalcFields("Total Quantity");

        Assert.AreEqual(AssemblyLineQuantity, TimeSheetLine."Total Quantity",
          StrSubstNo(TimeSheetFieldValueErr, TimeSheetLine.FieldCaption("Total Quantity")));
        Assert.IsTrue(TimeSheetLine.Chargeable, StrSubstNo(TimeSheetFieldValueErr, TimeSheetLine.FieldCaption(Chargeable)));
        Assert.AreEqual(TimeSheetLine.Status::Approved, TimeSheetLine.Status,
          StrSubstNo(TimeSheetFieldValueErr, TimeSheetLine.FieldCaption(Status)));
        Assert.IsTrue(TimeSheetLine.Posted, StrSubstNo(TimeSheetFieldValueErr, TimeSheetLine.FieldCaption(Posted)));
    end;

#if not CLEAN27
    [Obsolete('Moved to codeunit Library Service', '27.0')]
    procedure CheckServiceTimeSheetLine(TimeSheetHeader: Record "Time Sheet Header"; ServiceHeaderNo: Code[20]; ServiceLineNo: Integer; ServiceLineQuantity: Decimal; Chargeable: Boolean)
    var
        LibraryService: Codeunit "Library - Service";
    begin
        LibraryService.CheckServiceTimeSheetLine(TimeSheetHeader, ServiceHeaderNo, ServiceLineNo, ServiceLineQuantity, Chargeable);
    end;
#endif

    procedure CreateJobJournalLine(var JobJournalLine: Record "Job Journal Line"; JournalTemplateName: Code[10]; JournalBatchName: Code[10])
    var
        RecRef: RecordRef;
    begin
        JobJournalLine.Init();
        JobJournalLine.Validate("Journal Template Name", JournalTemplateName);
        JobJournalLine.Validate("Journal Batch Name", JournalBatchName);
        RecRef.GetTable(JobJournalLine);
        JobJournalLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, JobJournalLine.FieldNo("Line No.")));
        JobJournalLine.Insert(true);
    end;

    procedure CreateJobPlanningLine(var JobPlanningLine: Record "Job Planning Line"; JobNo: Code[20]; JobTaskNo: Code[20]; ResourceNo: Code[20]; PlanningDate: Date)
    var
        LineNo: Integer;
    begin
        JobPlanningLine.SetRange("Job No.", JobNo);
        JobPlanningLine.SetRange("Job Task No.", JobTaskNo);
        if JobPlanningLine.FindLast() then;
        LineNo := JobPlanningLine."Line No." + 10000;

        JobPlanningLine.Init();
        JobPlanningLine."Job No." := JobNo;
        JobPlanningLine."Job Task No." := JobTaskNo;
        JobPlanningLine."Line No." := LineNo;
        JobPlanningLine.Type := JobPlanningLine.Type::Resource;
        JobPlanningLine."No." := ResourceNo;
        JobPlanningLine."Planning Date" := PlanningDate;
        JobPlanningLine.Insert();
    end;

    procedure CreateTimeSheet(var TimeSheetHeader: Record "Time Sheet Header"; UseCurrentUserID: Boolean)
    var
        UserSetup: Record "User Setup";
        Resource: Record Resource;
        AccountingPeriod: Record "Accounting Period";
        Date: Record Date;
        CreateTimeSheets: Report "Create Time Sheets";
    begin
        // function creates user setup, time sheet resource and time sheet header

        // create user setup
        CreateUserSetup(UserSetup, UseCurrentUserID);

        // resource - person
        CreateTimeSheetResource(Resource);
        Resource.Validate("Time Sheet Owner User ID", UserSetup."User ID");
        Resource.Validate("Time Sheet Approver User ID", UserId);
        Resource.Modify();

        // find first open accounting period
        GetAccountingPeriod(AccountingPeriod);

        // find first DOW after accounting period starting date
        Date.SetRange("Period Type", Date."Period Type"::Date);
        Date.SetFilter("Period Start", '%1..', AccountingPeriod."Starting Date");
        Date.SetRange("Period No.", ResourcesSetup."Time Sheet First Weekday" + 1);
        Date.FindFirst();

        WorkDate := Date."Period Start";

        // create time sheet
        CreateTimeSheets.InitParameters(Date."Period Start", 1, Resource."No.", false, true);
        CreateTimeSheets.UseRequestPage(false);
        CreateTimeSheets.Run();

        // find created time sheet
        TimeSheetHeader.SetRange("Resource No.", Resource."No.");
        TimeSheetHeader.FindFirst();
    end;

    procedure CreateTimeSheetLine(TimeSheetHeader: Record "Time Sheet Header"; var TimeSheetLine: Record "Time Sheet Line"; Type: Enum "Time Sheet Line Type"; JobNo: Code[20]; JobTaskNo: Code[20]; ServiceOrderNo: Code[20]; CauseOfAbsenceCode: Code[10])
    var
        LineNo: Integer;
    begin
        LineNo := TimeSheetHeader.GetLastLineNo() + 10000;

        TimeSheetLine.Init();
        TimeSheetLine."Time Sheet No." := TimeSheetHeader."No.";
        TimeSheetLine."Line No." := LineNo;
        TimeSheetLine.Type := Type;
        case Type of
            Type::Job:
                begin
                    TimeSheetLine.Validate("Job No.", JobNo);
                    TimeSheetLine.Validate("Job Task No.", JobTaskNo);
                end;
            Type::Service:
                TimeSheetLine.Validate("Service Order No.", ServiceOrderNo);
            Type::Absence:
                TimeSheetLine.Validate("Cause of Absence Code", CauseOfAbsenceCode);
        end;
        TimeSheetLine.Insert(true);
    end;

    procedure CreateTimeSheetDetail(TimeSheetLine: Record "Time Sheet Line"; Date: Date; Quantity: Decimal)
    var
        TimeSheetDetail: Record "Time Sheet Detail";
    begin
        TimeSheetDetail.Init();
        TimeSheetDetail."Time Sheet No." := TimeSheetLine."Time Sheet No.";
        TimeSheetDetail."Time Sheet Line No." := TimeSheetLine."Line No.";
        TimeSheetDetail.Date := Date;
        TimeSheetDetail.CopyFromTimeSheetLine(TimeSheetLine);
        TimeSheetDetail.Quantity := Quantity;
        TimeSheetDetail.Insert();
    end;

    procedure CreateTimeSheetResource(var Resource: Record Resource)
    var
        ResourceUnitOfMeasure: Record "Resource Unit of Measure";
        HumanResourceUnitOfMeasure: Record "Human Resource Unit of Measure";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        LibraryResource.CreateResource(Resource, VATPostingSetup."VAT Bus. Posting Group");
        // take base unit of measure from table 5220 to be allowed register employee absence
        FindHRUnitOfMeasure(HumanResourceUnitOfMeasure);
        if not ResourceUnitOfMeasure.Get(Resource."No.", HumanResourceUnitOfMeasure.Code) then
            LibraryResource.CreateResourceUnitOfMeasure(
              ResourceUnitOfMeasure, Resource."No.", HumanResourceUnitOfMeasure.Code, 1);
        Resource.Validate("Base Unit of Measure", HumanResourceUnitOfMeasure.Code);
        Resource."Use Time Sheet" := true;
        Resource.Modify();
    end;

#if not CLEAN27
    [Obsolete('Moved to codeunit Library Service', '27.0')]
    procedure CreateServiceOrder(var ServiceHeader: Record "Service Header"; PostingDate: Date)
    var
        LibraryService: Codeunit "Library - Service";
    begin
        LibraryService.CreateServiceOrder(ServiceHeader, PostingDate);
    end;
#endif

    procedure CreateUserSetup(var UserSetup: Record "User Setup"; CurrUserID: Boolean)
    begin
        UserSetup.Init();
        if CurrUserID then begin
            UserSetup."User ID" := CopyStr(UserId(), 1, MaxStrLen(UserSetup."User ID"));
            UserSetup."Time Sheet Admin." := true;
        end else
            UserSetup."User ID" :=
              CopyStr(
                LibraryUtility.GenerateRandomCode(UserSetup.FieldNo("User ID"), DATABASE::"User Setup"), 1, MaxStrLen(UserSetup."User ID"));
        if UserSetup.Insert() then;
    end;

    procedure CreateWorkType(var WorkType: Record "Work Type"; ResourceBUOM: Code[10])
    begin
        WorkType.Init();
        WorkType.Validate(Code, CopyStr(Format(CreateGuid()), 1, MaxStrLen(WorkType.Code)));
        WorkType.Insert(true);
        WorkType.Validate(Description, 'test work type');
        WorkType.Validate("Unit of Measure Code", ResourceBUOM);
        WorkType.Modify();
    end;

    procedure CreateHRUnitOfMeasure(var HumanResourceUnitOfMeasure: Record "Human Resource Unit of Measure"; QtyPerUnitOfMeasure: Decimal)
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        HumanResourceUnitOfMeasure.Init();
        HumanResourceUnitOfMeasure.Validate(Code, UnitOfMeasure.Code);
        HumanResourceUnitOfMeasure.Validate("Qty. per Unit of Measure", QtyPerUnitOfMeasure);
        HumanResourceUnitOfMeasure.Insert(true);
    end;

    procedure CreateCauseOfAbsence(var CauseOfAbsence: Record "Cause of Absence")
    var
        HumanResourceUnitOfMeasure: Record "Human Resource Unit of Measure";
    begin
        CreateHRUnitOfMeasure(HumanResourceUnitOfMeasure, 1);

        CauseOfAbsence.Init();
        CauseOfAbsence.Validate(Code, LibraryUtility.GenerateGUID());
        CauseOfAbsence.Validate(Description, LibraryUtility.GenerateGUID());
        CauseOfAbsence.Validate("Unit of Measure Code", HumanResourceUnitOfMeasure.Code);
        CauseOfAbsence.Insert(true);
    end;

    procedure FindCauseOfAbsence(var CauseOfAbsence: Record "Cause of Absence")
    var
        HumanResourceUnitOfMeasure: Record "Human Resource Unit of Measure";
    begin
        CauseOfAbsence.FindFirst();
        if CauseOfAbsence."Unit of Measure Code" = '' then begin
            HumanResourceUnitOfMeasure.FindFirst();
            CauseOfAbsence.Validate("Unit of Measure Code", HumanResourceUnitOfMeasure.Code);
            CauseOfAbsence.Modify(true);
        end;
    end;

    procedure FindHRUnitOfMeasure(var HumanResourceUnitOfMeasure: Record "Human Resource Unit of Measure")
    begin
        HumanResourceUnitOfMeasure.FindFirst();
    end;

    procedure FindJobJournalBatch(var JobJournalBatch: Record "Job Journal Batch"; JournalTemplateName: Code[10])
    begin
        JobJournalBatch.SetRange("Journal Template Name", JournalTemplateName);
        JobJournalBatch.FindFirst();
    end;

    procedure FindJobJournalTemplate(var JobJournalTemplate: Record "Job Journal Template")
    begin
        JobJournalTemplate.FindFirst();
    end;

    procedure FindJob(var Job: Record Job)
    begin
        Job.SetFilter("Person Responsible", '<>''''');
        Job.SetFilter(Status, '<>%1', Job.Status::Completed);
        Job.FindFirst();
    end;

    procedure FindJobTask(JobNo: Code[20]; var JobTask: Record "Job Task")
    begin
        JobTask.SetRange("Job No.", JobNo);
        JobTask.SetRange("Job Task Type", JobTask."Job Task Type"::Posting);
        JobTask.FindFirst();
    end;

    procedure GetAccountingPeriod(var AccountingPeriod: Record "Accounting Period")
    var
        StartingDate: Date;
    begin
        // find first open accounting period
        AccountingPeriod.SetRange(Closed, false);
        if not AccountingPeriod.FindFirst() then begin
            // if accounting period is not found then create new one
            AccountingPeriod.Reset();
            if AccountingPeriod.FindLast() then
                StartingDate := CalcDate('<+1M>', AccountingPeriod."Starting Date")
            else
                StartingDate := CalcDate('<CM>', Today);
            AccountingPeriod.Init();
            AccountingPeriod."Starting Date" := StartingDate;
            AccountingPeriod.Insert();
        end;
    end;

    procedure GetRandomDecimal(): Decimal
    begin
        exit(LibraryRandom.RandInt(9999) / 100);
    end;

    procedure GetTimeSheetNoSeries(): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if not NoSeries.Get(NoSeriesCode) then begin
            LibraryUtility.CreateNoSeries(NoSeries, true, false, false);
            NoSeries.Rename(NoSeriesCode);
            LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, '', '')
        end;

        exit(NoSeries.Code)
    end;

    [Scope('OnPrem')]
    procedure GetTimeSheetLineBuffer(var TimeSheetLine: Record "Time Sheet Line")
    begin
        if TempTimeSheetLine.FindSet() then
            repeat
                TimeSheetLine := TempTimeSheetLine;
                TimeSheetLine.Insert();
            until TempTimeSheetLine.Next() = 0;
    end;

    procedure InitAssemblyBackwayScenario(var TimeSheetHeader: Record "Time Sheet Header"; var AssemblyHeader: Record "Assembly Header"; var AssemblyLine: Record "Assembly Line"; TimeSheetExists: Boolean)
    var
        Location: Record Location;
        UserSetup: Record "User Setup";
        Resource: Record Resource;
        Item: array[2] of Record Item;
        BOMComponent: Record "BOM Component";
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
        GeneralPostingSetup: Record "General Posting Setup";
        ItemCount: Integer;
        Date: Date;
    begin
        if TimeSheetExists then begin
            // create time sheet
            CreateTimeSheet(TimeSheetHeader, false);
            Resource.Get(TimeSheetHeader."Resource No.");
            Date := TimeSheetHeader."Starting Date";
        end else begin
            // set up without tine sheet; create resource
            Date := WorkDate();
            CreateUserSetup(UserSetup, false);
            CreateTimeSheetResource(Resource);
            Resource.Validate("Time Sheet Owner User ID", UserSetup."User ID");
            Resource.Validate("Time Sheet Approver User ID", UserId);
        end;

        LibraryERM.FindGeneralPostingSetupInvtFull(GeneralPostingSetup);
        Resource.Validate("Gen. Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group");
        Resource.Modify();

        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location);

        // get items on the location (pos.adjmt.)
        LibraryInventory.SelectItemJournalTemplateName(ItemJournalTemplate, ItemJournalTemplate.Type::Item);
        LibraryInventory.SelectItemJournalBatchName(ItemJournalBatch, ItemJournalTemplate.Type, ItemJournalTemplate.Name);
        LibraryInventory.ClearItemJournal(ItemJournalTemplate, ItemJournalBatch);

        for ItemCount := 1 to 2 do begin
            LibraryInventory.CreateItem(Item[ItemCount]);
            LibraryInventory.CreateItemJournalLine(ItemJournalLine, ItemJournalBatch."Journal Template Name", ItemJournalBatch.Name,
              ItemJournalLine."Entry Type"::"Positive Adjmt.", Item[ItemCount]."No.", 10);
            ItemJournalLine.Validate("Location Code", Location.Code);
            ItemJournalLine.Modify();
        end;

        LibraryInventory.PostItemJournalLine(ItemJournalBatch."Journal Template Name", ItemJournalBatch.Name);

        // create complicated item
        LibraryInventory.CreateBOMComponent(BOMComponent, Item[1]."No.", BOMComponent.Type::Item, Item[2]."No.", 2, '');

        // create assembly order with lines
        LibraryAssembly.CreateAssemblyHeader(AssemblyHeader, CalcDate('<+7D>', Date), Item[1]."No.", Location.Code, 2, '');
        AssemblyHeader.Validate("Posting Date", CalcDate('<+3D>', Date));
        AssemblyHeader.Modify();
        LibraryAssembly.CreateAssemblyLine(
          AssemblyHeader, AssemblyLine, "BOM Component Type"::Resource, Resource."No.", Resource."Base Unit of Measure", 8, 8, 'Working resource');
    end;

#if not CLEAN27
    [Obsolete('Moved to codeunit Library Service', '27.0')]
    procedure InitBackwayScenario(var TimeSheetHeader: Record "Time Sheet Header"; var ServiceHeader: Record "Service Header"; var ServiceLine: Record "Service Line")
    var
        LibraryService: Codeunit "Library - Service";
    begin
        LibraryService.InitBackwayScenario(TimeSheetHeader, ServiceHeader, ServiceLine);
    end;
#endif

    procedure InitJobScenario(var TimeSheetHeader: Record "Time Sheet Header"; var TimeSheetLine: Record "Time Sheet Line")
    var
        Resource: Record Resource;
        Job: Record Job;
        JobTask: Record "Job Task";
    begin
        // create time sheet
        CreateTimeSheet(TimeSheetHeader, false);

        // create time sheet line with type Job
        // find job and task
        FindJob(Job);
        FindJobTask(Job."No.", JobTask);
        // job's responsible person (resource) must have Owner ID filled in
        Resource.Get(Job."Person Responsible");
        Resource."Time Sheet Owner User ID" := CopyStr(UserId(), 1, MaxStrLen(Resource."Time Sheet Owner User ID"));
        Resource.Modify();
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, TimeSheetLine.Type::Job, Job."No.",
          JobTask."Job Task No.", '', '');

        // set quantity for line
        CreateTimeSheetDetail(TimeSheetLine, TimeSheetHeader."Starting Date", GetRandomDecimal());
        // submit and approve line
        TimeSheetApprovalMgt.Submit(TimeSheetLine);
        TimeSheetApprovalMgt.Approve(TimeSheetLine);
    end;

    procedure InitResourceScenario(var TimeSheetHeader: Record "Time Sheet Header"; var TimeSheetLine: Record "Time Sheet Line"; UseCurrentUserID: Boolean)
    begin
        // create time sheet
        CreateTimeSheet(TimeSheetHeader, UseCurrentUserID);

        // create time sheet lines with type Resource
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, TimeSheetLine.Type::Resource, '', '', '', '');
        TimeSheetLine.Description := TimeSheetHeader."Resource No.";
        TimeSheetLine.Modify();

        // set quantity for line
        CreateTimeSheetDetail(TimeSheetLine, TimeSheetHeader."Starting Date", GetRandomDecimal());
        // submit and approve line
        TimeSheetApprovalMgt.Submit(TimeSheetLine);
        TimeSheetApprovalMgt.Approve(TimeSheetLine);
    end;

    procedure InitScenarioWTForJob(var TimeSheetHeader: Record "Time Sheet Header")
    var
        TimeSheetLine: array[2] of Record "Time Sheet Line";
        Resource: Record Resource;
        Job: Record Job;
        JobTask: Record "Job Task";
        WorkType: Record "Work Type";
        RowCount: Integer;
    begin
        // create time sheet
        CreateTimeSheet(TimeSheetHeader, false);

        for RowCount := 1 to 2 do begin
            // create time sheet line with type Job
            // find job and task
            FindJob(Job);
            FindJobTask(Job."No.", JobTask);
            // job's responsible person (resource) must have Owner ID filled in
            Resource.Get(Job."Person Responsible");
            Resource."Time Sheet Owner User ID" := CopyStr(UserId(), 1, MaxStrLen(Resource."Time Sheet Owner User ID"));
            Resource.Modify();
            CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine[RowCount], TimeSheetLine[RowCount].Type::Job, Job."No.",
              JobTask."Job Task No.", '', '');
            // change work type
            if RowCount = 2 then begin
                // create work type
                Resource.Get(TimeSheetHeader."Resource No.");
                CreateWorkType(WorkType, Resource."Base Unit of Measure");
                TimeSheetLine[RowCount].Validate(Chargeable, false);
                TimeSheetLine[RowCount].Validate("Work Type Code", WorkType.Code);
            end;
            TimeSheetLine[RowCount].Modify();
            CreateTimeSheetDetail(TimeSheetLine[RowCount], TimeSheetHeader."Starting Date", GetRandomDecimal());
            CreateTimeSheetDetail(TimeSheetLine[RowCount], TimeSheetHeader."Starting Date" + 1, GetRandomDecimal());
            TimeSheetApprovalMgt.Submit(TimeSheetLine[RowCount]);
        end;
    end;

#if not CLEAN27
    [Obsolete('Moved to codeunit Library Service', '27.0')]
    procedure InitScenarioWTForServiceOrder(var TimeSheetHeader: Record "Time Sheet Header"; var ServiceHeader: Record "Service Header")
    var
        LibraryService: Codeunit "Library - Service";
    begin
        LibraryService.InitScenarioWTForServiceOrder(TimeSheetHeader, ServiceHeader);
    end;
#endif

#if not CLEAN27
    [Obsolete('Moved to codeunit Library Service', '27.0')]
    procedure InitServiceScenario(var TimeSheetHeader: Record "Time Sheet Header"; var TimeSheetLine: Record "Time Sheet Line"; var ServiceHeader: Record "Service Header")
    var
        LibraryService: Codeunit "Library - Service";
    begin
        LibraryService.InitServiceScenario(TimeSheetHeader, TimeSheetLine, ServiceHeader);
    end;
#endif

    procedure SubmitTimeSheetLine(var TimeSheetLine: Record "Time Sheet Line")
    begin
        TimeSheetApprovalMgt.Submit(TimeSheetLine);
    end;

    procedure SubmitAndApproveTimeSheetLine(var TimeSheetLine: Record "Time Sheet Line")
    begin
        TimeSheetApprovalMgt.Submit(TimeSheetLine);
        TimeSheetApprovalMgt.Approve(TimeSheetLine);
    end;

    procedure RunSuggestJobJnlLinesReportForResourceInPeriod(JobJournalLine: Record "Job Journal Line"; ResourceNo: Code[20]; StartingDate: Date; EndingDate: Date)
    var
        SuggestJobJnlLines: Report "Suggest Job Jnl. Lines";
    begin
        Commit();
        Clear(SuggestJobJnlLines);
        SuggestJobJnlLines.InitParameters(JobJournalLine, ResourceNo, '', '', StartingDate, EndingDate);
        SuggestJobJnlLines.Run();
    end;

    procedure RunCreateTimeSheetsReport(StartDate: Date; NewNoOfPeriods: Integer; ResourceNo: Code[20])
    var
        CreateTimeSheets: Report "Create Time Sheets";
    begin
        Clear(CreateTimeSheets);
        CreateTimeSheets.InitParameters(StartDate, NewNoOfPeriods, ResourceNo, false, true);
        CreateTimeSheets.UseRequestPage(false);
        CreateTimeSheets.Run();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Manager Time Sheet", 'OnAfterProcess', '', false, false)]
    local procedure OnAfterProcessManagerTimeSheet(var TimeSheetLine: Record "Time Sheet Line"; "Action": Option "Approve Selected","Approve All","Reopen Selected","Reopen All","Reject Selected","Reject All")
    var
        TimeSheetMgt: Codeunit "Time Sheet Management";
    begin
        TimeSheetMgt.CopyFilteredTimeSheetLinesToBuffer(TimeSheetLine, TempTimeSheetLine);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Manager Time Sheet by Job", 'OnAfterProcess', '', false, false)]
    local procedure OnAfterProcessManagerTimeSheetByJob(var TimeSheetLine: Record "Time Sheet Line"; "Action": Option "Approve Selected","Approve All","Reopen Selected","Reopen All","Reject Selected","Reject All")
    var
        TimeSheetMgt: Codeunit "Time Sheet Management";
    begin
        TimeSheetMgt.CopyFilteredTimeSheetLinesToBuffer(TimeSheetLine, TempTimeSheetLine);
    end;
}

