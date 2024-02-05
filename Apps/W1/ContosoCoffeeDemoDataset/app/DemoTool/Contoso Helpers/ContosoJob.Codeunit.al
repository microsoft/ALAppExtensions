codeunit 5186 "Contoso Job"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata Job = rim,
        tabledata "Job Task" = rim,
        tabledata "Job Planning Line" = rim,
        tabledata "Job Journal Template" = rim,
        tabledata "Job Journal Batch" = rim,
        tabledata "Job Journal Line" = rim,
        tabledata "Job Posting Group" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertJopPostingGroup(PostingGroupCode: Code[20]; Description: Text[100]; WIPCostsAcc: Code[20]; WIPAccruedCostsAcc: Code[20]; JobCostsAppliedAcc: Code[20]; JobCostsAdjAcc: Code[20]; WIPAccruedSalesAcc: Code[20]; WIPInvoicedSalesAcc: Code[20]; JobSalesAppliedAcc: Code[20]; JobSalesAdjAcc: Code[20]; RecognizedCostAcc: Code[20]; RecognizedSalesAcc: Code[20])
    var
        JobPostingGroup: Record "Job Posting Group";
        Exists: Boolean;
    begin
        if JobPostingGroup.Get(PostingGroupCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        JobPostingGroup.Validate("Code", PostingGroupCode);
        JobPostingGroup.Validate("Description", Description);
        JobPostingGroup.Validate("WIP Costs Account", WIPCostsAcc);
        JobPostingGroup.Validate("WIP Accrued Costs Account", WIPAccruedCostsAcc);
        JobPostingGroup.Validate("Job Costs Applied Account", JobCostsAppliedAcc);
        JobPostingGroup.Validate("Job Costs Adjustment Account", JobCostsAdjAcc);
        JobPostingGroup.Validate("WIP Accrued Sales Account", WIPAccruedSalesAcc);
        JobPostingGroup.Validate("WIP Invoiced Sales Account", WIPInvoicedSalesAcc);
        JobPostingGroup.Validate("Job Sales Applied Account", JobSalesAppliedAcc);
        JobPostingGroup.Validate("Job Sales Adjustment Account", JobSalesAdjAcc);
        JobPostingGroup.Validate("Recognized Costs Account", RecognizedCostAcc);
        JobPostingGroup.Validate("Recognized Sales Account", RecognizedSalesAcc);

        if Exists then
            JobPostingGroup.Modify(true)
        else
            JobPostingGroup.Insert(true);
    end;

    procedure InsertJob(JobNo: Code[20]; Description: Text[100]; CustomerNo: Code[20]; ExternalDocumentNo: Code[35])
    var
        Job: Record Job;
        Exists: Boolean;
    begin
        if Job.Get(JobNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Job.Validate("No.", JobNo);
        Job.Validate(Description, Description);
        Job.Validate("Bill-to Customer No.", CustomerNo);
        Job.Validate("External Document No.", ExternalDocumentNo);

        if Exists then
            Job.Modify(true)
        else
            Job.Insert(true);
    end;

    procedure InsertJobTask(JobNo: Code[20]; JobTaskNo: Code[20]; Description: Text[100]; JobTaskType: Enum "Job Task Type")
    var
        JobTask: Record "Job Task";
        Exists: Boolean;
    begin
        if JobTask.Get(JobNo, JobTaskNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        JobTask.Validate("Job No.", JobNo);
        JobTask.Validate("Job Task No.", JobTaskNo);
        JobTask.Validate(Description, Description);
        JobTask.Validate("Job Task Type", JobTaskType);

        if Exists then
            JobTask.Modify(true)
        else
            JobTask.Insert(true);
    end;

    procedure InsertJobPlanningLine(JobNo: Code[20]; JobTaskNo: Code[20]; LineType: Enum "Job Planning Line Line Type"; Type: Enum "Job Planning Line Type"; No: Code[20]; Quantity: Decimal; LineDescription: Text[100]; LocationCode: Code[10])
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        JobPlanningLine.Validate("Job No.", JobNo);
        JobPlanningLine.Validate("Job Task No.", JobTaskNo);
        JobPlanningLine."Line No." := GetNextJobPlanningLineNo(JobNo, JobTaskNo);
        JobPlanningLine.Validate("Line Type", LineType);
        JobPlanningLine.Validate(Type, Type);
        JobPlanningLine.Validate("No.", No);
        JobPlanningLine.Validate(Quantity, Quantity);
        JobPlanningLine.Validate("Location Code", LocationCode);
        JobPlanningLine.Validate(Description, LineDescription);
        JobPlanningLine.Insert(true);
    end;

    procedure InsertJobPlanningLine(JobNo: Code[20]; JobTaskNo: Code[20]; LineType: Enum "Job Planning Line Line Type"; LineDescription: Text[100])
    begin
        InsertJobPlanningLine(JobNo, JobTaskNo, LineType, Enum::"Job Planning Line Type"::Text, '', 0, LineDescription, '');
    end;

    procedure InsertJobJournalTemplate(TemplateName: Code[10]; Description: Text[80])
    var
        JobJournalTemplate: Record "Job Journal Template";
        Exists: Boolean;
    begin
        if JobJournalTemplate.Get(TemplateName) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        JobJournalTemplate.Validate(Name, TemplateName);
        JobJournalTemplate.Validate(Description, Description);

        if Exists then
            JobJournalTemplate.Modify(true)
        else
            JobJournalTemplate.Insert(true);
    end;

    procedure InsertJobJournalBatch(TemplateName: Code[10]; BatchName: Code[10]; Description: Text[100])
    var
        JobJournalBatch: Record "Job Journal Batch";
        Exists: Boolean;
    begin
        if JobJournalBatch.Get(TemplateName, BatchName) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        JobJournalBatch.Validate("Journal Template Name", TemplateName);
        JobJournalBatch.Validate(Name, BatchName);
        JobJournalBatch.Validate(Description, Description);

        if Exists then
            JobJournalBatch.Modify(true)
        else
            JobJournalBatch.Insert(true);
    end;

    procedure InsertJobJournalLine(TemplateName: Code[10]; BatchName: Code[10]; JobNo: Code[20]; JobTaskNo: Code[20]; JobLineType: Enum "Job Line Type"; JobJournalLineType: Enum "Job Journal Line Type";
                                                                                                                                       WhichNo: Code[20];
                                                                                                                                       Quantity: Decimal;
                                                                                                                                       LineDescription: Text[100])
    var
        JobJournalLine: Record "Job Journal Line";
    begin
        JobJournalLine.Init();
        JobJournalLine.Validate("Journal Template Name", TemplateName);
        JobJournalLine.Validate("Journal Batch Name", BatchName);
        JobJournalLine.Validate("Line No.", GetNextJobJournalLineNo(TemplateName, BatchName));
        JobJournalLine.Validate(Description, LineDescription);
        JobJournalLine.Validate("Job No.", JobNo);
        JobJournalLine.Validate("Job Task No.", JobTaskNo);
        JobJournalLine.Validate("Type", JobJournalLineType);
        JobJournalLine.Validate("No.", WhichNo);
        JobJournalLine.Validate("Quantity", Quantity);
        JobJournalLine.Validate("Line Type", JobJournalLine."Line Type"::Billable);
        JobJournalLine.Insert(true);
    end;

    local procedure GetNextJobJournalLineNo(TemplateName: Code[20]; BatchName: Code[20]): Integer
    var
        JobJournalLine: Record "Job Journal Line";
    begin
        JobJournalLine.SetRange("Journal Template Name", TemplateName);
        JobJournalLine.SetRange("Journal Batch Name", BatchName);
        JobJournalLine.SetCurrentKey("Line No."); // sort ascending

        if JobJournalLine.FindLast() then
            exit(JobJournalLine."Line No." + 10000)
        else
            exit(10000);
    end;

    local procedure GetNextJobPlanningLineNo(JobNo: Code[20]; JobTaskNo: Code[20]): Integer
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        JobPlanningLine.SetRange("Job No.", JobNo);
        JobPlanningLine.SetRange("Job Task No.", JobTaskNo);
        JobPlanningLine.SetCurrentKey("Line No.");

        if JobPlanningLine.FindLast() then
            exit(JobPlanningLine."Line No." + 10000)
        else
            exit(10000);
    end;
}