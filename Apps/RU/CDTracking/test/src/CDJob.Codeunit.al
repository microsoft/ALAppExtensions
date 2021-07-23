codeunit 147109 "CD Job"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        LibraryRandom: Codeunit "Library - Random";
        LibraryCDTracking: Codeunit "Library - CD Tracking";
        LibraryItemTracking: Codeunit "Library - Item Tracking";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryJob: Codeunit "Library - Job";
        IsInitialized: Boolean;

    [Test]
    [HandlerFunctions('ItemTrackingLinesPageHandler')]
    [Scope('OnPrem')]
    procedure CDNoAssignedToJobPlanningLineFromJobLedgEntryAfterPurchOrderWithTrackingAndStrictLinkToJob()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        JobPlanningLine: Record "Job Planning Line";
        JobLedgerEntry: Record "Job Ledger Entry";
        InvNo: Code[20];
    begin
        // [FEATURE] [Item Tracking] [CD No.]
        // [SCENARIO 382364] "Package No." in Job Planning Line is equal the same field from Job Ledger Entry after posting Purchase Order with Item Tracking and "Job Planning Line No." defined

        Initialize();

        // [GIVEN] Job with Planning Line - "Usage Link" and Item "X" with Tracking by "Package No."
        CreateJobWithPlanningUsageLinkAndSpecificItem(JobPlanningLine, CreateItemWithCDNoTracking());

        // [GIVEN] Purchase Order with Item "X", Job ("Job Planning Line No." is defined to make strict link to Job)
        LibraryPurchase.CreatePurchaseOrderWithLocation(PurchaseHeader, LibraryPurchase.CreateVendorNo(), '');
        LibraryPurchase.CreatePurchaseLineWithUnitCost(
          PurchaseLine, PurchaseHeader, JobPlanningLine."No.", LibraryRandom.RandInt(100), LibraryRandom.RandDec(100, 2));
        UpdatePurchaseLineWithJob(PurchaseLine, JobPlanningLine);

        LibraryVariableStorage.Enqueue(PurchaseLine.Quantity);
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        AssignItemTrackingLinesOnPurchaseOrder(PurchaseHeader);

        // [WHEN] Post Purchase Order
        InvNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] The value of "Package No." in Job Ledger Entry is assigned
        FindJobLedgerEntry(JobLedgerEntry, InvNo, JobPlanningLine."No.");
        JobLedgerEntry.TestField("Package No.");

        // [THEN] The value of "Package No." in Job Planning Line is equal value in Job Ledger Entry
        JobPlanningLine.Find();
        JobPlanningLine.TestField("Package No.", JobLedgerEntry."Package No.");
    end;

    local procedure Initialize()
    var
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
    begin
        if IsInitialized then
            exit;

        LibraryERMCountryData.CreateVATData();
        LibraryERMCountryData.CreateGeneralPostingSetupData();
        LibraryERMCountryData.UpdateGeneralPostingSetup();
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        IsInitialized := true;
    end;

    local procedure CreateJobWithPlanningUsageLinkAndSpecificItem(var JobPlanningLine: Record "Job Planning Line"; ItemNo: Code[20])
    var
        JobTask: Record "Job Task";
    begin
        CreateJobWithJobTask(JobTask);

        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Budget.AsInteger(), JobPlanningLine.Type::Item, JobTask, JobPlanningLine);
        JobPlanningLine.Validate("No.", ItemNo);
        JobPlanningLine.Validate(Quantity, LibraryRandom.RandInt(100));
        JobPlanningLine.Validate("Usage Link", true);
        JobPlanningLine.Modify(true);
    end;

    local procedure CreateJobWithJobTask(var JobTask: Record "Job Task")
    var
        Job: Record Job;
    begin
        LibraryJob.CreateJob(Job);
        Job.Validate("Bill-to Customer No.", LibrarySales.CreateCustomerNo());
        Job.Modify(true);
        LibraryJob.CreateJobTask(Job, JobTask);
    end;

    local procedure CreateItemWithCDNoTracking(): Code[20]
    var
        CDLocationSetup: Record "CD Location Setup";
        ItemTrackingCode: Record "Item Tracking Code";
        Item: Record Item;
        CDNumberHeader: Record "CD Number Header";
        PackageNoInformation: Record "Package No. Information";
        CDNo: Code[20];
    begin
        LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, false, false, true);
        LibraryCDTracking.CreateCDTracking(CDLocationSetup, ItemTrackingCode.Code, '');
        LibraryItemTracking.CreateItemWithItemTrackingCode(Item, ItemTrackingCode);
        LibraryCDTracking.CreateCDNumberHeaderWithCountryRegion(CDNumberHeader);
        CDNo := LibraryUtility.GenerateGUID();
        LibraryVariableStorage.Enqueue(CDNo);
        LibraryItemTracking.CreatePackageNoInformation(PackageNoInformation, Item."No.", CDNo);
        PackageNoInformation."CD Header Number" := CDNumberHeader."No.";
        PackageNoInformation.Modify();
        exit(Item."No.");
    end;

    local procedure UpdatePurchaseLineWithJob(var PurchaseLine: Record "Purchase Line"; JobPlanningLine: Record "Job Planning Line")
    begin
        PurchaseLine.Validate("Job No.", JobPlanningLine."Job No.");
        PurchaseLine.Validate("Job Task No.", JobPlanningLine."Job Task No.");
        PurchaseLine.Validate("Job Line Type", PurchaseLine."Job Line Type"::Budget);
        PurchaseLine.Validate("Job Planning Line No.", JobPlanningLine."Line No.");
        PurchaseLine.Modify(true);
    end;

    local procedure AssignItemTrackingLinesOnPurchaseOrder(var PurchaseHeader: Record "Purchase Header")
    var
        PurchaseOrder: TestPage "Purchase Order";
    begin
        PurchaseOrder.OpenView();
        PurchaseOrder.FILTER.SetFilter("No.", PurchaseHeader."No.");
        PurchaseOrder.PurchLines."Item Tracking Lines".Invoke();
        PurchaseHeader.Get(PurchaseHeader."Document Type", PurchaseHeader."No.");
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ItemTrackingLinesPageHandler(var ItemTrackingLines: TestPage "Item Tracking Lines")
    begin
        ItemTrackingLines."Package No.".SetValue(LibraryVariableStorage.DequeueText());
        ItemTrackingLines."Quantity (Base)".SetValue(LibraryVariableStorage.DequeueDecimal());
        ItemTrackingLines.OK().Invoke();
    end;

    local procedure FindJobLedgerEntry(var JobLedgerEntry: Record "Job Ledger Entry"; DocumentNo: Code[20]; No: Code[20])
    begin
        JobLedgerEntry.SetRange("Document No.", DocumentNo);
        JobLedgerEntry.SetRange("No.", No);
        JobLedgerEntry.FindFirst();
    end;
}

