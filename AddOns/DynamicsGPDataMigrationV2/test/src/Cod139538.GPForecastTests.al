codeunit 139538 "GP Forecasting Tests"
{
    // [FEATURE] [GP Forecasting]

    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        MSSalesForecastSetup: Record "MS - Sales Forecast Setup";
        Assert: Codeunit Assert;
        CashFlowForecastHandler: Codeunit "Cash Flow Forecast Handler";
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        MSSalesForecastHandler: Codeunit "Sales Forecast Handler";
        LibraryInventory: Codeunit "Library - Inventory";
        LibrarySales: Codeunit "Library - Sales";
        MockServiceURITxt: Label 'https://localhost:8080/services.azureml.net/workspaces/2eaccaaec84c47c7a1f8f01ec0a6eea7', Locked = true;
        MockServiceKeyTxt: Label 'TestKey', Locked = true;
        XPAYABLESTxt: label 'PAYABLES', Locked = true;
        XRECEIVABLESTxt: label 'RECEIVABLES', Locked = true;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPOnPrepareCashFlowData()
    var
        TempTimeSeriesBuffer: Record "Time Series Buffer";
    begin
        // [SCENARIO] Normal prediction of item with GP history
        LibraryLowerPermissions.SetOutsideO365Scope();

        CreateCashFlowSetup();
        CashFlowForecastHandler.Initialize();

        // [GIVEN] 6 historical periods
        CreateCashFlowTestData(WorkDate(), true, false);

        // [THEN] Forecast is prepared 
        LibraryLowerPermissions.SetAccountReceivables();
        Assert.IsTrue(CashFlowForecastHandler.PrepareForecast(TempTimeSeriesBuffer), 'Forecast failed');

        // [THEN] There are Forecast entries including 6 for payables and 6 for receivables coming from GP history tables
        TempTimeSeriesBuffer.Reset();
        TempTimeSeriesBuffer.SETRANGE("Group ID", XPAYABLESTxt);
        TempTimeSeriesBuffer.FindSet();
        Assert.RecordCount(TempTimeSeriesBuffer, 6);
        TempTimeSeriesBuffer.Reset();
        TempTimeSeriesBuffer.SETRANGE("Group ID", XRECEIVABLESTxt);
        TempTimeSeriesBuffer.FindSet();
        Assert.RecordCount(TempTimeSeriesBuffer, 6);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPCashFlowDataValues()
    var
        TempTimeSeriesBuffer: Record "Time Series Buffer";
    begin
        // [SCENARIO] normal forecast records set from GP history tables
        LibraryLowerPermissions.SetOutsideO365Scope();

        CreateCashFlowSetup();
        CashFlowForecastHandler.Initialize();

        // [GIVEN] 6 historical periods with some duplicate document numbers in GP history tables
        CreateCashFlowTestData(WorkDate(), true, false);

        // [GIVEN] Forecast is prepared 
        LibraryLowerPermissions.SetAccountReceivables();
        Assert.IsTrue(CashFlowForecastHandler.PrepareForecast(TempTimeSeriesBuffer), 'Forecast failed');

        // [THEN] the value for receivables period 6 should be 180
        TempTimeSeriesBuffer.Reset();
        TempTimeSeriesBuffer.SetFilter("Group ID", XRECEIVABLESTxt);
        TempTimeSeriesBuffer.SetFilter("Period No.", '6');
        TempTimeSeriesBuffer.FindSet();
        Assert.AreEqual(180, TempTimeSeriesBuffer.Value, 'Invalid Amount for period 6 receivables.');

        // [THEN] the value for payables period 6 should be 120
        TempTimeSeriesBuffer.Reset();
        TempTimeSeriesBuffer.SetFilter("Group ID", XPAYABLESTxt);
        TempTimeSeriesBuffer.SetFilter("Period No.", '6');
        TempTimeSeriesBuffer.FindSet();
        Assert.AreEqual(120, TempTimeSeriesBuffer.Value, 'Invalid Amount for period 6 payables.');

        // [THEN] the value for receivables period 1 should be 20
        TempTimeSeriesBuffer.Reset();
        TempTimeSeriesBuffer.SetFilter("Group ID", XRECEIVABLESTxt);
        TempTimeSeriesBuffer.SetFilter("Period No.", '1');
        TempTimeSeriesBuffer.FindSet();
        Assert.AreEqual(20, TempTimeSeriesBuffer.Value, 'Invalid Amount for period 1 receivables.');

        // [THEN] the value for receivables period 2 should be 40
        TempTimeSeriesBuffer.Reset();
        TempTimeSeriesBuffer.SetFilter("Group ID", XRECEIVABLESTxt);
        TempTimeSeriesBuffer.SetFilter("Period No.", '2');
        TempTimeSeriesBuffer.FindSet();
        Assert.AreEqual(40, TempTimeSeriesBuffer.Value, 'Invalid Amount for period 2 receivables.');

        // [THEN] the value for payables period 1 should be 10
        TempTimeSeriesBuffer.Reset();
        TempTimeSeriesBuffer.SetFilter("Group ID", XPAYABLESTxt);
        TempTimeSeriesBuffer.SetFilter("Period No.", '1');
        TempTimeSeriesBuffer.FindSet();
        Assert.AreEqual(10, TempTimeSeriesBuffer.Value, 'Invalid Amount for period 1 payables.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPCashFlowDataValuesWithCreditMemos()
    var
        TempTimeSeriesBuffer: Record "Time Series Buffer";
    begin
        // [SCENARIO] normal forecast records set from GP history tables
        LibraryLowerPermissions.SetOutsideO365Scope();

        CreateCashFlowSetup();
        CashFlowForecastHandler.Initialize();

        // [GIVEN] 6 historical periods with some duplicate document numbers in GP history tables and some credit memos
        CreateCashFlowTestData(WorkDate(), true, true);

        // [GIVEN] Forecast is prepared 
        LibraryLowerPermissions.SetAccountReceivables();
        Assert.IsTrue(CashFlowForecastHandler.PrepareForecast(TempTimeSeriesBuffer), 'Forecast failed');

        // [THEN] the value for receivables period 3 should be 30
        TempTimeSeriesBuffer.Reset();
        TempTimeSeriesBuffer.SetFilter("Group ID", XRECEIVABLESTxt);
        TempTimeSeriesBuffer.SetFilter("Period No.", '3');
        TempTimeSeriesBuffer.FindSet();
        Assert.AreEqual(30, TempTimeSeriesBuffer.Value, 'Invalid Amount for period 3 receivables.');

        // [THEN] the value for payables period 3 should be 30
        TempTimeSeriesBuffer.Reset();
        TempTimeSeriesBuffer.SetFilter("Group ID", XPAYABLESTxt);
        TempTimeSeriesBuffer.SetFilter("Period No.", '3');
        TempTimeSeriesBuffer.FindSet();
        Assert.AreEqual(30, TempTimeSeriesBuffer.Value, 'Invalid Amount for period 3 payables.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPOnPrepareSandIHistoryData()
    var
        MSSalesForecast: Record "MS - Sales Forecast";
        Item: Record Item;
        MSSalesForecastParameter: Record "MS - Sales Forecast Parameter";
        TimeSeriesManagement: Codeunit "Time Series Management";
    begin
        // [SCENARIO] Normal prediction of item with history
        SI_Initialize();
        LibraryLowerPermissions.SetOutsideO365Scope();

        // [Given] Sales history for an Item with six historic entries
        CreateSITestData(Item, WorkDate(), true, 6);
        LibraryLowerPermissions.SetAccountReceivables();

        // [Given] The Api Uri key has been set and the horizon is 12 periods
        SetupSI();
        // [When] Item sales is being forecast for the given item
        Assert.IsTrue(MSSalesForecastHandler.PrepareForecast(MSSalesForecastParameter, Item."No.", TimeSeriesManagement), 'Forecast failed');

        // [THEN] There are 6 Forecast entries 6 for an item
        MSSalesForecast.SETRANGE("Item No.", Item."No.");
        Assert.RecordCount(MSSalesForecast, 6);
    end;

    local procedure CreateCashFlowSetup()
    var
        CashFlowSetup: Record "Cash Flow Setup";
    begin
        CashFlowSetup.Get();
        CashFlowSetup.SaveUserDefinedAPIKey('dummykey');
        CashFlowSetup.Validate("API URL", 'https://ussouthcentral.services.azureml.net');
        CashFlowSetup.Validate("Period Type", CashFlowSetup."Period Type"::Year);
        CashFlowSetup.Validate("Historical Periods", 18);
        CashFlowSetup.Validate("Azure AI Enabled", true);
        CashFlowSetup.Validate("Taxable Period", CashFlowSetup."Taxable Period"::Monthly);
        CashFlowSetup.Modify(true);
    end;

    local procedure CreateCashFlowTestData(Date: Date; Cleanup: Boolean; CreateCreditMemos: Boolean)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        GP_SOPTrxHist: Record GP_SOPTrxHist;
        GP_RMOpen: Record GP_RMOpen;
        GP_RMHist: Record GP_RMHist;
    begin
        if CleanUp then begin
            CustLedgerEntry.DeleteAll();
            VendorLedgerEntry.DeleteAll();
            GP_SOPTrxHist.DeleteAll();
            GP_RMOpen.DeleteAll();
            GP_RMHist.DeleteAll();
        end;

        CreateCustomerLedgerEntry(CalcDate('<-6Y+1D>', Date));
        CreateCustomerLedgerEntry(CalcDate('<-5Y+1D>', Date));
        CreateCustomerLedgerEntry(CalcDate('<-4Y+1D>', Date));
        CreateCustomerLedgerEntry(CalcDate('<-3Y+1D>', Date));
        CreateCustomerLedgerEntry(CalcDate('<-2Y+1D>', Date));
        CreateCustomerLedgerEntry(CalcDate('<-1Y+1D>', Date));

        CreateVendorLedgerEntry(CalcDate('<-6Y+1D>', Date));
        CreateVendorLedgerEntry(CalcDate('<-5Y+1D>', Date));
        CreateVendorLedgerEntry(CalcDate('<-4Y+1D>', Date));
        CreateVendorLedgerEntry(CalcDate('<-3Y+1D>', Date));
        CreateVendorLedgerEntry(CalcDate('<-2Y+1D>', Date));
        CreateVendorLedgerEntry(CalcDate('<-1Y+1D>', Date));

        // SALES
        CreateRMOpenEntry(CalcDate('<-6Y+1D>', Date), 10, 10, false);
        CreateRMOpenEntry(CalcDate('<-5Y+1D>', Date), 20, 20, false);
        CreateRMOpenEntry(CalcDate('<-4Y+1D>', Date), 30, 30, false);
        CreateRMOpenEntry(CalcDate('<-3Y+1D>', Date), 40, 40, false);
        CreateRMOpenEntry(CalcDate('<-2Y+1D>', Date), 50, 50, false);
        CreateRMOpenEntry(CalcDate('<-1Y+1D>', Date), 60, 60, false);

        CreateRMTrxHistEntry(CalcDate('<-6Y+1D>', Date), 10, 10, false);
        CreateRMTrxHistEntry(CalcDate('<-5Y+1D>', Date), 80, 20, false);
        CreateRMTrxHistEntry(CalcDate('<-4Y+1D>', Date), 90, 30, false);
        CreateRMTrxHistEntry(CalcDate('<-3Y+1D>', Date), 100, 40, false);
        CreateRMTrxHistEntry(CalcDate('<-2Y+1D>', Date), 110, 50, false);
        CreateRMTrxHistEntry(CalcDate('<-1Y+1D>', Date), 120, 60, false);

        CreateSOPTrxHistEntry(CalcDate('<-6Y+1D>', Date), 130, 10);
        CreateSOPTrxHistEntry(CalcDate('<-5Y+1D>', Date), 20, 20);
        CreateSOPTrxHistEntry(CalcDate('<-4Y+1D>', Date), 150, 30);
        CreateSOPTrxHistEntry(CalcDate('<-3Y+1D>', Date), 160, 40);
        CreateSOPTrxHistEntry(CalcDate('<-2Y+1D>', Date), 170, 50);
        CreateSOPTrxHistEntry(CalcDate('<-1Y+1D>', Date), 180, 60);

        //PURCHASING
        CreatePMHistEntry(CalcDate('<-6Y+1D>', Date), 190, 10, false);
        CreatePMHistEntry(CalcDate('<-5Y+1D>', Date), 200, 20, false);
        CreatePMHistEntry(CalcDate('<-4Y+1D>', Date), 210, 30, false);
        CreatePMHistEntry(CalcDate('<-3Y+1D>', Date), 220, 40, false);
        CreatePMHistEntry(CalcDate('<-2Y+1D>', Date), 230, 50, false);
        CreatePMHistEntry(CalcDate('<-1Y+1D>', Date), 240, 60, false);

        CreatePOP_PO_HistEntry(CalcDate('<-6Y+1D>', Date), 190, 10);
        CreatePOP_PO_HistEntry(CalcDate('<-5Y+1D>', Date), 260, 20);
        CreatePOP_PO_HistEntry(CalcDate('<-4Y+1D>', Date), 270, 30);
        CreatePOP_PO_HistEntry(CalcDate('<-3Y+1D>', Date), 280, 40);
        CreatePOP_PO_HistEntry(CalcDate('<-2Y+1D>', Date), 290, 50);
        CreatePOP_PO_HistEntry(CalcDate('<-1Y+1D>', Date), 300, 60);

        if CreateCreditMemos then begin
            CreateRMOpenEntry(CalcDate('<-4Y+1D>', Date), 35, 30, true);
            CreateRMTrxHistEntry(CalcDate('<-4Y+1D>', Date), 95, 30, true);
            CreatePMHistEntry(CalcDate('<-4Y+1D>', Date), 215, 30, true);
        end;

        CreateCustomer();
        CreateVendor();
    end;

    local procedure CreateCustomerLedgerEntry(DueDate: Date)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        EntryNo: Integer;
    begin
        if CustLedgerEntry.FindLast() then;
        EntryNo := CustLedgerEntry."Entry No." + 1;
        CustLedgerEntry.Init();
        CustLedgerEntry.Open := true;
        CustLedgerEntry."Document Type" := CustLedgerEntry."Document Type"::Invoice;
        CustLedgerEntry."Due Date" := DueDate;
        CustLedgerEntry."Entry No." := EntryNo;
        CustLedgerEntry.Insert();
    end;

    local procedure CreateVendorLedgerEntry(DueDate: Date)
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        EntryNo: Integer;
    begin
        if VendorLedgerEntry.FindLast() then;
        EntryNo := VendorLedgerEntry."Entry No." + 1;
        VendorLedgerEntry.Init();
        VendorLedgerEntry.Open := true;
        VendorLedgerEntry."Document Type" := VendorLedgerEntry."Document Type"::Invoice;
        VendorLedgerEntry."Due Date" := DueDate;
        VendorLedgerEntry."Entry No." := EntryNo;
        VendorLedgerEntry.Insert();
    end;

    local procedure CreateSOPTrxHistEntry(DueDate: Date; SOPNumber: Integer; DocAmount: Decimal)
    var
        GP_SOPTrxHist: Record GP_SOPTrxHist;
    begin
        GP_SOPTrxHist.Init();
        GP_SOPTrxHist.SOPNUMBE := Format(SOPNumber);
        GP_SOPTrxHist.SOPTYPE := GP_SOPTrxHist.SOPTYPE::Invoice;
        GP_SOPTrxHist.DUEDATE := CreateDateTime(DueDate, 0T);
        GP_SOPTrxHist.DOCAMNT := DocAmount;
        GP_SOPTrxHist.Insert();
    end;

    local procedure CreateRMTrxHistEntry(DueDate: Date; DocNumber: Integer; DocAmount: Decimal; CreateAsCreditMemo: Boolean)
    var
        GP_RMHist: Record GP_RMHist;
    begin
        GP_RMHist.Init();
        GP_RMHist.DOCNUMBR := Format(DocNumber);
        if CreateAsCreditMemo then
            GP_RMHist.RMDTYPAL := GP_RMHist.RMDTYPAL::"Credit Memos"
        else
            GP_RMHist.RMDTYPAL := GP_RMHist.RMDTYPAL::"Sales/Invoices";
        GP_RMHist.DUEDATE := CreateDateTime(DueDate, 0T);
        GP_RMHist.CUSTNMBR := '1';
        GP_RMHist.SLSAMNT := DocAmount;
        GP_RMHist.Insert();
    end;

    local procedure CreateRMOpenEntry(DueDate: Date; DocNumber: Integer; DocAmount: Decimal; CreateAsCreditMemo: Boolean)
    var
        GP_RMOpen: Record GP_RMOpen;
    begin
        GP_RMOpen.Init();
        GP_RMOpen.DOCNUMBR := Format(DocNumber);
        if CreateAsCreditMemo then
            GP_RMOpen.RMDTYPAL := GP_RMOpen.RMDTYPAL::"Credit Memos"
        else
            GP_RMOpen.RMDTYPAL := GP_RMOpen.RMDTYPAL::"Sales/Invoices";
        GP_RMOpen.DUEDATE := CreateDateTime(DueDate, 0T);
        GP_RMOpen.CUSTNMBR := '1';
        GP_RMOpen.SLSAMNT := DocAmount;
        GP_RMOpen.Insert();
    end;

    local procedure CreatePOP_PO_HistEntry(DueDate: Date; PONumber: Integer; DocAmount: Decimal)
    var
        GP_POP_POHist: Record GP_POP_POHist;
    begin
        GP_POP_POHist.Init();
        GP_POP_POHist.PONUMBER := Format(PONumber);
        GP_POP_POHist.POTYPE := GP_POP_POHist.POTYPE::Standard;
        GP_POP_POHist.DUEDATE := CreateDateTime(DueDate, 0T);
        GP_POP_POHist.CUSTNMBR := '1';
        GP_POP_POHist.SUBTOTAL := DocAmount;
        GP_POP_POHist.Insert();
    end;


    local procedure CreatePMHistEntry(DueDate: Date; PONumber: Integer; DocAmount: Decimal; CreateAsCreditMemo: Boolean)
    var
        GP_PMHist: Record GP_PMHist;
    begin
        GP_PMHist.Init();
        GP_PMHist.VCHRNMBR := Format(PONumber);
        GP_PMHist.DOCNUMBR := GP_PMHist.VCHRNMBR;
        if CreateAsCreditMemo then
            GP_PMHist.DOCTYPE := GP_PMHist.DOCTYPE::"Credit Memo"
        else
            GP_PMHist.DOCTYPE := GP_PMHist.DOCTYPE::Invoice;
        GP_PMHist.DUEDATE := CreateDateTime(DueDate, 0T);
        GP_PMHist.VENDORID := '1';
        GP_PMHist.DOCAMNT := DocAmount;
        GP_PMHist.Insert();
    end;

    local procedure CreateCustomer()
    var
        Customer: Record Customer;
        CustomerNumber: Code[20];
    begin
        Customer.DeleteAll();
        Evaluate(CustomerNumber, '1');
        Customer.Init();
        Customer."No." := CustomerNumber;
        Customer.Insert();
    end;

    local procedure CreateVendor()
    var
        Vendor: Record Vendor;
        VendorNumber: Code[20];
    begin
        Vendor.DeleteAll();
        Evaluate(Vendor."No.", '1');
        Vendor.Init();
        Vendor."No." := VendorNumber;
        Vendor.Insert();
    end;

    local procedure SI_Initialize();
    var
        MSSalesForecast: Record "MS - Sales Forecast";
        MSSalesForecastParameter: Record "MS - Sales Forecast Parameter";
        JobQueueEntry: Record "Job Queue Entry";
        LibraryPermissions: Codeunit "Library - Permissions";
        LibraryNotificationMgt: Codeunit "Library - Notification Mgt.";
    begin
        LibraryPermissions.SetTestabilitySoftwareAsAService(true);
        LibraryNotificationMgt.DisableAllNotifications(); // do not get polluted by Image analysis notifications

        MSSalesForecastSetup.DeleteAll();
        MSSalesForecast.DeleteAll();
        MSSalesForecastParameter.DeleteAll();

        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Sales Forecast Update");
        JobQueueEntry.DeleteAll();
    end;

    local procedure CreateSITestData(var Item: Record Item; Date: Date; Cleanup: Boolean; NumberOfEntries: Integer)
    var
        GP_IVTrxAmountsHist: Record GP_IVTrxAmountsHist;
        Customer: Record Customer;

    begin
        if CleanUp then
            GP_IVTrxAmountsHist.DeleteAll();

        LibraryInventory.CreateItem(Item);
        LibrarySales.CreateCustomer(Customer);
        CreateLedgerEntriesBeforeWorkdate(Item, Customer, NumberOfEntries, false);
    end;

    procedure CreateLedgerEntriesBeforeWorkdate(var Item: Record Item; var Customer: Record Customer; NumberOfEntries: Integer; PeriodTypeDay: Boolean);
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        PostingDate: Date;
        EntryNo: Integer;
        LastEntryNo: Integer;
        QtyToIncrease: Decimal;
    begin
        PostingDate := CalcDate('<-1D>', WorkDate());
        QtyToIncrease := 5;

        ItemLedgerEntry.FindLast();
        LastEntryNo := ItemLedgerEntry."Entry No.";
        CLEAR(ItemLedgerEntry);

        // Increasing, linear sales
        for EntryNo := 1 to NumberOfEntries do begin
            ItemLedgerEntry.Init();
            ItemLedgerEntry."Entry No." := LastEntryNo + EntryNo;
            ItemLedgerEntry."Item No." := Item."No.";
            ItemLedgerEntry."Entry Type" := ItemLedgerEntry."Entry Type"::Sale;
            ItemLedgerEntry."Posting Date" := PostingDate;
            ItemLedgerEntry.Quantity := -(NumberOfEntries * QtyToIncrease - (EntryNo - 1) * QtyToIncrease);
            ItemLedgerEntry."Source Type" := ItemLedgerEntry."Source Type"::Customer;
            ItemLedgerEntry."Source No." := Customer."No.";
            ItemLedgerEntry.Insert();

            CreateGPIVTrxEntry(PostingDate, Item, Customer);

            if PeriodTypeDay then
                PostingDate := CalcDate('<-1D>', PostingDate)
            else
                PostingDate := CalcDate('<-1M>', PostingDate);
        end;
    end;

    local procedure CreateGPIVTrxEntry(DueDate: Date; Item: Record Item; Customer: Record Customer)
    var
        GP_IVTrxAmountsHist: Record GP_IVTrxAmountsHist;
        LibraryRandom: Codeunit "Library - Random";
        DocNumber: integer;
        ItemQuantity: Decimal;
    begin
        LibraryRandom.Init();
        ItemQuantity := LibraryRandom.RandDec(10, 3);
        DocNumber := 0;
        if GP_IVTrxAmountsHist.FindLast() then
            Evaluate(DocNumber, GP_IVTrxAmountsHist.DOCNUMBR);
        DocNumber := DocNumber + 100;
        GP_IVTrxAmountsHist.Init();
        GP_IVTrxAmountsHist.DOCTYPE := GP_IVTrxAmountsHist.DOCTYPE::Sale;
        GP_IVTrxAmountsHist.DOCNUMBR := Format(DocNumber);
        GP_IVTrxAmountsHist.DOCDATE := CREATEDATETIME(DueDate, 0T);
        GP_IVTrxAmountsHist.TRXQTY := ItemQuantity;
        GP_IVTrxAmountsHist.LNSEQNBR := 10;
        GP_IVTrxAmountsHist.ITEMNMBR := Item."No.";
        GP_IVTrxAmountsHist.CUSTNMBR := Customer."No.";
        GP_IVTrxAmountsHist.Insert();
    end;

    procedure SetupSI();
    begin
        MSSalesForecastSetup.GetSingleInstance();
        MSSalesForecastSetup.Validate("API URI", MockServiceURITxt);
        MSSalesForecastSetup.SetUserDefinedAPIKey(MockServiceKeyTxt);
        MSSalesForecastSetup.Modify(true);
    end;

}