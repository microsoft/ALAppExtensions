#if not CLEAN22
codeunit 134153 "Test Intrastat"
{
    Subtype = Test;
    TestPermissions = Disabled;
    ObsoleteState = Pending;
#pragma warning disable AS0072
    ObsoleteTag = '22.0';
#pragma warning restore AS0072
    ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';

    trigger OnRun()
    begin
        // [FEATURE] [Intrastat]
    end;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        IsInitialized: Boolean;

    [Test]
    [HandlerFunctions('GetItemLedgerEntriesRequestPageHandler,IntratstatJnlFormReqPageHandler')]
    [Scope('OnPrem')]
    procedure TestIntrastatFormReport()
    var
        SalesHeader: Record "Sales Header";
        Item: Record Item;
        IntrastatJnlBatch: Record "Intrastat Jnl. Batch";
        IntrastatJnlLine: Record "Intrastat Jnl. Line";
    begin
        Initialize();

        // Setup
        CreateIntrastatJournalTemplateAndBatch(IntrastatJnlBatch, WorkDate());
        CreateItemWithTariffNo(Item);
        CreateAndPostSalesDoc(
          SalesHeader."Document Type"::Order, CreateForeignCustomerNo(), Item."No.", LibraryRandom.RandDec(10, 2));

        Commit();
        RunGetItemLedgerEntriesToCreateJnlLines(IntrastatJnlBatch);
        SetMandatoryFieldsOnJnlLines(IntrastatJnlLine, IntrastatJnlBatch, FindOrCreateIntrastatTransportMethod(), FindOrCreateIntrastatTransactionType());
        Commit();

        // Exercise
        RunIntrastatJournalForm(IntrastatJnlLine.Type::Shipment);

        // Verify
        IntrastatJnlLine.SetFilter("Tariff No.", Item."Tariff No.");
        IntrastatJnlLine.FindFirst();
        IntrastatJnlLine.TestField("Transaction Type");
        IntrastatJnlLine.TestField("Transport Method");
        LibraryReportDataset.LoadDataSetFile();
        Assert.IsTrue(LibraryReportDataset.RowCount() > 0, 'Empty Dataset');
        LibraryReportDataset.MoveToRow(LibraryReportDataset.FindRow('TariffNo_IntraJnlLine', Item."Tariff No.") + 1);
        LibraryReportDataset.AssertCurrentRowValueEquals('TransacType_IntraJnlLine', IntrastatJnlLine."Transaction Type");
        LibraryReportDataset.AssertCurrentRowValueEquals('TransportMet_IntraJnlLine', IntrastatJnlLine."Transport Method");
    end;

    [Test]
    [HandlerFunctions('GetItemLedgerEntriesRequestPageHandler')]
    [Scope('OnPrem')]
    procedure IntrastatAmountIsUnitPriceAfterSalesOrder()
    var
        IntrastatJnlBatch: Record "Intrastat Jnl. Batch";
        SalesHeader: Record "Sales Header";
        Item: Record Item;
    begin
        // [SCENARIO 362690] Intrastat Journal Line Amount = Item."Unit Price" after Sales Order posting with Quantity = 1
        // [FEATURE] [Sales] [Order]
        Initialize();
        CreateIntrastatJournalTemplateAndBatch(IntrastatJnlBatch, WorkDate());

        // [GIVEN] Item with "Unit Price" = "X"
        CreateItemWithTariffNo(Item);

        // [GIVEN] Create Post Sales Order with Quantity = 1
        CreateAndPostSalesDoc(SalesHeader."Document Type"::Order, CreateForeignCustomerNo(), Item."No.", 1);

        // [WHEN] Run Intrastat "Get Item Ledger Entries" report
        RunGetItemLedgerEntriesToCreateJnlLines(IntrastatJnlBatch);

        // [THEN] Intrastat Journal Line Amount = "X"
        VerifyIntrastatJnlLine(IntrastatJnlBatch, Item."No.", 1, Round(Item."Unit Price", 1));
    end;

    [Test]
    [HandlerFunctions('GetItemLedgerEntriesRequestPageHandler')]
    [Scope('OnPrem')]
    procedure IntrastatAmountIsUnitPriceAfterSalesReturnOrder()
    var
        IntrastatJnlBatch: Record "Intrastat Jnl. Batch";
        SalesHeader: Record "Sales Header";
        Item: Record Item;
    begin
        // [SCENARIO 362690] Intrastat Journal Line Amount = Item."Unit Price" after Sales Return Order posting with Quantity = 1
        // [FEATURE] [Sales] [Return Order]
        Initialize();
        CreateIntrastatJournalTemplateAndBatch(IntrastatJnlBatch, WorkDate());

        // [GIVEN] Item with "Unit Price" = "X"
        CreateItemWithTariffNo(Item);

        // [GIVEN] Create Post Sales Return Order with Quantity = 1
        CreateAndPostSalesDoc(SalesHeader."Document Type"::"Return Order", CreateForeignCustomerNo(), Item."No.", 1);

        // [WHEN] Run Intrastat "Get Item Ledger Entries" report
        RunGetItemLedgerEntriesToCreateJnlLines(IntrastatJnlBatch);

        // [THEN] Intrastat Journal Line Amount = "X"
        VerifyIntrastatJnlLine(IntrastatJnlBatch, Item."No.", 1, Round(Item."Unit Price", 1));
    end;

    [Test]
    [HandlerFunctions('GetItemLedgerEntriesRequestPageHandler')]
    [Scope('OnPrem')]
    procedure IntrastatAmountIsUnitCostAfterPurchaseOrder()
    var
        IntrastatJnlBatch: Record "Intrastat Jnl. Batch";
        PurchaseHeader: Record "Purchase Header";
        Item: Record Item;
    begin
        // [SCENARIO 362690] Intrastat Journal Line Amount = Item."Last Direct Cost" after Purchase Order posting with Quantity = 1
        // [FEATURE] [Purchase] [Order]
        Initialize();
        CreateIntrastatJournalTemplateAndBatch(IntrastatJnlBatch, WorkDate());

        // [GIVEN] Item with "Last Direct Cost" = "X"
        CreateItemWithTariffNo(Item);

        // [GIVEN] Create Post Purchase Order with Quantity = 1
        CreateAndPostPurchDoc(PurchaseHeader."Document Type"::Order, CreateForeignVendorNo(), Item."No.", 1);

        // [WHEN] Run Intrastat "Get Item Ledger Entries" report
        RunGetItemLedgerEntriesToCreateJnlLines(IntrastatJnlBatch);

        // [THEN] Intrastat Journal Line Amount = "X"
        VerifyIntrastatJnlLine(IntrastatJnlBatch, Item."No.", 1, Round(Item."Last Direct Cost", 1));
    end;

    [Test]
    [HandlerFunctions('GetItemLedgerEntriesRequestPageHandler')]
    [Scope('OnPrem')]
    procedure IntrastatAmountIsUnitCostAfterPurchaseReturnOrder()
    var
        IntrastatJnlBatch: Record "Intrastat Jnl. Batch";
        PurchaseHeader: Record "Purchase Header";
        Item: Record Item;
    begin
        // [SCENARIO 362690] Intrastat Journal Line Amount = Item."Last Direct Cost" after Purchase Return Order posting with Quantity = 1
        // [FEATURE] [Purchase] [Return Order]
        Initialize();
        CreateIntrastatJournalTemplateAndBatch(IntrastatJnlBatch, WorkDate());

        // [GIVEN] Item with "Last Direct Cost" = "X"
        CreateItemWithTariffNo(Item);

        // [GIVEN] Create Post Purchase Return Order with Quantity = 1
        CreateAndPostPurchDoc(PurchaseHeader."Document Type"::Order, CreateForeignVendorNo(), Item."No.", 1);

        // [WHEN] Run Intrastat "Get Item Ledger Entries" report
        RunGetItemLedgerEntriesToCreateJnlLines(IntrastatJnlBatch);

        // [THEN] Intrastat Journal Line Amount = "X"
        VerifyIntrastatJnlLine(IntrastatJnlBatch, Item."No.", 1, Round(Item."Last Direct Cost", 1));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure IntrastatJournalStatisticalValueEditable()
    var
        IntrastatJournal: TestPage "Intrastat Journal";
    begin
        // [FEATURE] [UI] [UT]
        // [SCENARIO 331036] Statistical Value is editable on Intrastat Journal page
        Initialize();
        RunIntrastatJournal(IntrastatJournal);
        Assert.IsTrue(IntrastatJournal."Statistical Value".Editable(), '');
    end;

    local procedure Initialize()
    var
        IntrastatJnlTemplate: Record "Intrastat Jnl. Template";
    begin
        LibraryVariableStorage.Clear();
        LibraryReportDataset.Reset();
        IntrastatJnlTemplate.DeleteAll(true);

        if IsInitialized then
            exit;

        LibraryERMCountryData.UpdateGeneralLedgerSetup();
        LibraryERMCountryData.UpdateGeneralPostingSetup();
        SetIntrastatCodeOnCountryRegion();
        SetTariffNoOnItems();

        IsInitialized := true;
        Commit();
    end;

    local procedure CreateIntrastatJournalTemplateAndBatch(var IntrastatJnlBatch: Record "Intrastat Jnl. Batch"; PostingDate: Date)
    var
        IntrastatJnlTemplate: Record "Intrastat Jnl. Template";
    begin
        LibraryERM.CreateIntrastatJnlTemplate(IntrastatJnlTemplate);
        LibraryERM.CreateIntrastatJnlBatch(IntrastatJnlBatch, IntrastatJnlTemplate.Name);
        IntrastatJnlBatch.Validate("Statistics Period", Format(PostingDate, 0, '<Year,2><Month,2>'));
        IntrastatJnlBatch.Modify(true);
    end;

    local procedure CreateAndPostSalesDoc(DocumentType: Enum "Sales Document Type"; CustomerNo: Code[20]; ItemNo: Code[20]; Quantity: Decimal)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, ItemNo, Quantity);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
    end;

    local procedure CreateAndPostPurchDoc(DocumentType: Enum "Purchase Document Type"; VendorNo: Code[20]; ItemNo: Code[20]; Quantity: Decimal)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, VendorNo);
        PurchaseHeader.Validate("Vendor Invoice No.", PurchaseHeader."No.");
        PurchaseHeader.Validate("Vendor Cr. Memo No.", PurchaseHeader."No.");
        PurchaseHeader.Modify();

        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, ItemNo, Quantity);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
    end;

    local procedure CreateForeignCustomerNo(): Code[20]
    var
        Customer: Record Customer;
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Country/Region Code", FindCountryRegionCode());
        Customer.Modify(true);
        exit(Customer."No.");
    end;

    local procedure CreateForeignVendorNo(): Code[20]
    var
        Vendor: Record Vendor;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("Country/Region Code", FindCountryRegionCode());
        Vendor.Modify(true);
        exit(Vendor."No.");
    end;

    local procedure CreateItemWithTariffNo(var Item: Record Item)
    begin
        LibraryInventory.CreateItem(Item);
        with Item do begin
            Validate("Tariff No.", LibraryUtility.CreateCodeRecord(DATABASE::"Tariff Number"));
            Validate("Unit Cost", LibraryRandom.RandDecInRange(100, 200, 2));
            Validate("Unit Price", LibraryRandom.RandDecInRange(100, 200, 2));
            Validate("Last Direct Cost", LibraryRandom.RandDecInRange(100, 200, 2));
            Modify(true);
        end;
    end;

    local procedure RunIntrastatJournal(var IntrastatJournal: TestPage "Intrastat Journal")
    begin
        IntrastatJournal.OpenEdit();
    end;

    local procedure RunGetItemLedgerEntriesToCreateJnlLines(IntrastatJnlBatch: Record "Intrastat Jnl. Batch")
    var
        IntrastatJournal: TestPage "Intrastat Journal";
    begin
        RunIntrastatJournal(IntrastatJournal);
        LibraryVariableStorage.AssertEmpty();
        LibraryVariableStorage.Enqueue(CalcDate('<-CM>', WorkDate()));
        LibraryVariableStorage.Enqueue(CalcDate('<CM>', WorkDate()));
        IntrastatJournal.GetEntries.Invoke();
        VerifyIntrastatJnlLinesExist(IntrastatJnlBatch);
        IntrastatJournal.Close();
    end;

    local procedure RunIntrastatJournalForm(Type: Option)
    var
        IntrastatJournal: TestPage "Intrastat Journal";
    begin
        RunIntrastatJournal(IntrastatJournal);
        LibraryVariableStorage.AssertEmpty();
        LibraryVariableStorage.Enqueue(Type);
        IntrastatJournal.Form.Invoke();
    end;

    local procedure SetMandatoryFieldsOnJnlLines(var IntrastatJnlLine: Record "Intrastat Jnl. Line"; IntrastatJnlBatch: Record "Intrastat Jnl. Batch"; TransportMethod: Code[10]; TransactionType: Code[10])
    begin
        IntrastatJnlLine.SetRange("Journal Template Name", IntrastatJnlBatch."Journal Template Name");
        IntrastatJnlLine.SetRange("Journal Batch Name", IntrastatJnlBatch.Name);
        IntrastatJnlLine.FindSet();
        repeat
            IntrastatJnlLine.Validate("Transport Method", TransportMethod);
            IntrastatJnlLine.Validate("Transaction Type", TransactionType);
            IntrastatJnlLine.Validate("Net Weight", LibraryRandom.RandDecInRange(1, 10, 2));
            IntrastatJnlLine.Modify(true);
        until IntrastatJnlLine.Next() = 0;
    end;

    local procedure VerifyIntrastatJnlLinesExist(var IntrastatJnlBatch: Record "Intrastat Jnl. Batch")
    var
        IntrastatJnlLine: Record "Intrastat Jnl. Line";
    begin
        IntrastatJnlLine.SetRange("Journal Template Name", IntrastatJnlBatch."Journal Template Name");
        IntrastatJnlLine.SetRange("Journal Batch Name", IntrastatJnlBatch.Name);
        Assert.IsFalse(IntrastatJnlLine.IsEmpty, 'No Intrastat Journal Lines exist');
    end;

    local procedure FindOrCreateIntrastatTransactionType(): Code[10]
    begin
        exit(LibraryUtility.FindOrCreateCodeRecord(DATABASE::"Transaction Type"));
    end;

    local procedure FindOrCreateIntrastatTransportMethod(): Code[10]
    begin
        exit(LibraryUtility.FindOrCreateCodeRecord(DATABASE::"Transport Method"));
    end;

    local procedure FindCountryRegionCode(): Code[10]
    var
        CompanyInfo: Record "Company Information";
        CountryRegion: Record "Country/Region";
    begin
        CompanyInfo.Get();
        with CountryRegion do begin
            SetFilter(Code, '<>%1', CompanyInfo."Country/Region Code");
            SetFilter("Intrastat Code", '<>%1', '');
            FindFirst();
            exit(Code);
        end;
    end;

    local procedure SetIntrastatCodeOnCountryRegion()
    var
        CountryRegion: Record "Country/Region";
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CountryRegion.Get(CompanyInformation."Country/Region Code");
        CountryRegion.Validate("Intrastat Code", CountryRegion.Code);
        CountryRegion.Modify(true);
    end;

    local procedure SetTariffNoOnItems()
    var
        Item: Record Item;
        TariffNumber: Record "Tariff Number";
    begin
        TariffNumber.FindFirst();
        Item.SetRange("Tariff No.", '');
        if not Item.IsEmpty() then
            Item.ModifyAll("Tariff No.", TariffNumber."No.");
    end;

    local procedure VerifyIntrastatJnlLine(IntrastatJnlBatch: Record "Intrastat Jnl. Batch"; ItemNo: Code[20]; ExpectedQty: Decimal; ExpectedAmount: Decimal)
    var
        IntrastatJnlLine: Record "Intrastat Jnl. Line";
    begin
        with IntrastatJnlLine do begin
            SetRange("Journal Template Name", IntrastatJnlBatch."Journal Template Name");
            SetRange("Journal Batch Name", IntrastatJnlBatch.Name);
            SetRange("Item No.", ItemNo);
            FindFirst();
            Assert.AreEqual(ExpectedQty, Quantity, FieldCaption(Quantity));
            Assert.AreEqual(ExpectedAmount, Amount, FieldCaption(Amount));
        end;
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure GetItemLedgerEntriesRequestPageHandler(var GetItemLedgerEntriesReqPage: TestRequestPage "Get Item Ledger Entries")
    var
        StartDate: Variant;
        EndDate: Variant;
    begin
        LibraryVariableStorage.Dequeue(StartDate);
        LibraryVariableStorage.Dequeue(EndDate);
        GetItemLedgerEntriesReqPage.StartingDate.SetValue(StartDate);
        GetItemLedgerEntriesReqPage.EndingDate.SetValue(EndDate);
        GetItemLedgerEntriesReqPage.IndirectCostPctReq.SetValue(0);
        GetItemLedgerEntriesReqPage.OK().Invoke();
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure IntratstatJnlFormReqPageHandler(var IntrastatFormReqPage: TestRequestPage "Intrastat - Form")
    var
        Type: Variant;
    begin
        LibraryVariableStorage.Dequeue(Type);
        IntrastatFormReqPage."Intrastat Jnl. Line".SetFilter(Type, Format(Type));
        IntrastatFormReqPage.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;
}
#endif