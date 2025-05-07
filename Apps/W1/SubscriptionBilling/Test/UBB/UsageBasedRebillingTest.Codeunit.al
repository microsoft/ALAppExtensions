namespace Microsoft.SubscriptionBilling;
using System.IO;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.History;
codeunit 139694 "Usage Based Rebilling Test"
{
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure UsageDataBillingMetadataIsCreatedAndDeletedWithUsageBasedBilling()
    var
        UsageDataBillingMetadata: Record "Usage Data Billing Metadata";
        UsageDataImport: Record "Usage Data Import";
    begin
        // [SCENARIO] ???
        // [GIVEN] Set up the initial state
        ResetAll();
        Initialize(); // Initialize necessary data and configurations
        SetupServiceObjectAndContracts(SubscriptionStartingDate);
        CreateInitialImport(UsageDataImport); // Create initial usage data import record

        // [WHEN] Process the usage data import -> Create Usage Data Billing
        ProcessData(UsageDataImport, "Processing Step"::"Create Usage Data Billing");

        UsageDataImport.TestField("Processing Status", "Processing Status"::Ok);
        UsageDataBilling.FindLast();

        // [THEN] Check if metadata is created
        TestUsageDataBillingMetadataForRebilling(UsageDataBillingMetadata, UsageDataBilling, false);

        // [WHEN] Delete Usage Data billing
        Assert.IsFalse(UsageDataBilling.IsInvoiced(), 'Should not be invoiced');
        UsageDataBilling.Delete(true);

        // [THEN] Metadata should be deleted as well
        UsageDataBillingMetadata.Reset();
        UsageDataBillingMetadata.SetRange("Usage Data Billing Entry No.", UsageDataBilling."Entry No.");
        Assert.RecordIsEmpty(UsageDataBillingMetadata);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateCustomerBillingDocumentPageHandler,MessageHandler')]
    procedure UsageDataBillingMetadataIsCreatedButNotDeletedWithInvoicedUsageBasedBilling()
    var
        UsageDataBillingMetadata: Record "Usage Data Billing Metadata";
        UsageDataImport: Record "Usage Data Import";
    begin
        // [SCENARIO] ???
        // [GIVEN] Set up the initial state
        ResetAll();
        Initialize(); // Initialize necessary data and configurations
        SetupServiceObjectAndContracts(SubscriptionStartingDate);
        CreateInitialImport(UsageDataImport); // Create initial usage data import record

        // [GIVEN] Process Usage Data Import
        ProcessData(UsageDataImport, "Processing Step"::"Process Usage Data Billing");

        UsageDataBilling.SetRange(Partner, "Service Partner"::Customer);
        UsageDataBilling.FindLast();

        // [GIVEN] Create customer invoices; Don't post the document
        PostDocument := false;
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");
        UsageDataImport.TestField("Processing Status", "Processing Status"::Ok);
        UsageDataImport.CollectCustomerContractsAndCreateInvoices(UsageDataImport);

        // [THEN] Check that metadata exists after deleting the UsageDataBilling
        UsageDataBilling.Find();
        UsageDataBilling.Delete(true);
        UsageDataBillingMetadata.SetRange("Usage Data Billing Entry No.", UsageDataBilling."Entry No.");
        Assert.IsTrue(UsageDataBilling.IsInvoiced(), 'Should be invoiced');
        Assert.IsFalse(UsageDataBillingMetadata.IsEmpty, 'Metadata does still exist');
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure RebillingIsSet()
    var
        UsageDataBillingMetadata: Record "Usage Data Billing Metadata";
        InitialUsageDataImport: Record "Usage Data Import";
        RebillingUsageDataImport: Record "Usage Data Import";
    begin
        // [SCENARIO] ???
        // [GIVEN] Set up the initial state
        ResetAll(); // Reset all data to ensure a clean state
        Initialize(); // Initialize necessary data and configurations
        SetupServiceObjectAndContracts(SubscriptionStartingDate);
        CreateInitialImport(InitialUsageDataImport); // Create initial usage data import record

        // [WHEN] Process the initial usage data import
        ProcessData(InitialUsageDataImport, "Processing Step"::"Create Usage Data Billing"); // Process the data to create usage data billing
        TestUsageDataForRebilling(UsageDataBilling, InitialUsageDataImport."Entry No.", false);
        TestUsageDataBillingMetadataForRebilling(UsageDataBillingMetadata, UsageDataBilling, false);

        // [GIVEN] Close the initial import and mark it as invoiced
        InitialUsageDataImport.SetStatus("Processing Status"::Closed);
        UsageDataBillingMetadata.Invoiced := true;
        UsageDataBillingMetadata.Modify();

        // [WHEN] Create and process the rebilling import
        CreateRebillingImport(RebillingUsageDataImport); // Create rebilling usage data import record
        ProcessData(RebillingUsageDataImport, "Processing Step"::"Create Usage Data Billing"); // Process the data to create usage data billing
        TestUsageDataForRebilling(UsageDataBilling, RebillingUsageDataImport."Entry No.", true);

        // [THEN] Assert the expected outcomes for rebilling metadata
        TestUsageDataBillingMetadataForRebilling(UsageDataBillingMetadata, UsageDataBilling, true);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateCustomerBillingDocumentPageHandler,MessageHandler')]
    procedure ServiceCommitmentNextBillingDateIsSetToRebillingDate()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        ServiceCommitment: Record "Subscription Line";
        UsageDataGenericImport: Record "Usage Data Generic Import";
        InitialUsageDataImport: Record "Usage Data Import";
        RebillingUsageDataImport: Record "Usage Data Import";
    begin
        // [SCENARIO] ???
        // [GIVEN] Set up the initial state
        ResetAll(); // Reset all data to ensure a clean state
        Initialize(); // Initialize necessary data and configurations
        SetupServiceObjectAndContracts(SubscriptionStartingDate);

        // [GIVEN] Setup and post first billing
        PostDocument := true;
        CreateInitialImport(InitialUsageDataImport); // Create initial usage data import record
        ProcessData(InitialUsageDataImport, "Processing Step"::"Process Usage Data Billing"); // Process the data to create usage data billing

        // [THEN] Verify setup
        UsageDataGenericImport.SetCurrentKey("Billing Period Start Date");
        UsageDataGenericImport.SetRange("Usage Data Import Entry No.", InitialUsageDataImport."Entry No.");
        Assert.AreEqual(1, UsageDataGenericImport.Count(), 'Expected one line to be imported in the first import, but found a different count.');
        UsageDataGenericImport.FindFirst(); // initial import
        TestAndCompareBillingPeriodStartAndEndDate(CalcDate('<-CY>', WorkDate()), CalcDate('<CY>', WorkDate())
                                                    , UsageDataGenericImport."Billing Period Start Date", UsageDataGenericImport."Billing Period End Date");

        // [WHEN] Post the rebilling usage data import
        RebillingUsageDataImport.CollectCustomerContractsAndCreateInvoices(InitialUsageDataImport);

        // [THEN] Check invoice and usage data billing line
        SalesInvoiceHeader.SetRange("Sell-to Customer No.", Customer."No.");
        SalesInvoiceHeader.FindFirst();
        SalesInvoiceHeader.TestField("Recurring Billing", true);
        UsageDataBilling.Reset();
        UsageDataBilling.FilterOnDocumentTypeAndDocumentNo("Service Partner"::Customer, UsageDataBilling."Document Type"::"Posted Invoice", SalesInvoiceHeader."No.");
        Assert.AreEqual(1, UsageDataBilling.Count(), 'Expected one usage data billing to be invoiced, but found a different count.');
        UsageDataBilling.FindFirst();

        // [THEN] Check Subscription Line
        ServiceCommitment.Get(UsageDataBilling."Subscription Line Entry No.");
        Assert.AreEqual(CalcDate('<CY+1D>', WorkDate()), ServiceCommitment."Next Billing Date", 'Expected Next Billing Date to be the day after the end of the year, but it was different.');

        // [GIVEN] Setup and prepare follow-up billing
        PostDocument := false;
        CreateRebillingImportWithFollowupLine(RebillingUsageDataImport); // Create rebilling usage data import record with follow-up line
        ProcessData(RebillingUsageDataImport, "Processing Step"::"Process Usage Data Billing"); // Process the data to create usage data billing

        // [THEN] Verify setup
        UsageDataGenericImport.SetRange("Usage Data Import Entry No.", RebillingUsageDataImport."Entry No.");
        Assert.AreEqual(2, UsageDataGenericImport.Count(), 'Expected two lines to be imported in rebilling and follow-up import, but found a different count.');
        UsageDataGenericImport.FindFirst(); // rebilling of initial import
        TestAndCompareBillingPeriodStartAndEndDate(WorkDate(), CalcDate('<CY>', WorkDate())
                                            , UsageDataGenericImport."Billing Period Start Date", UsageDataGenericImport."Billing Period End Date");
        UsageDataGenericImport.Next(); // follow-up billing of next year
        TestAndCompareBillingPeriodStartAndEndDate(CalcDate('<CY+1D>', WorkDate()), CalcDate('<CY+1Y>', WorkDate())
                                    , UsageDataGenericImport."Billing Period Start Date", UsageDataGenericImport."Billing Period End Date");

        // [THEN] Check Subscription Line
        ServiceCommitment.Find();
        Assert.AreEqual(WorkDate(), ServiceCommitment."Next Billing Date", 'Expected Service Commitment Next Billing Date to be reset to the rebilling date, but it was different.');

        // [WHEN] Create sales invoice
        RebillingUsageDataImport.CollectCustomerContractsAndCreateInvoices(RebillingUsageDataImport);

        // [THEN] Check usage data billing line
        UsageDataBilling.Reset();
        UsageDataBilling.SetCurrentKey("Charge Start Date");
        UsageDataBilling.SetRange("Usage Data Import Entry No.", RebillingUsageDataImport."Entry No.");
        UsageDataBilling.SetRange(Partner, "Service Partner"::Customer);
        UsageDataBilling.FindFirst();
        TestAndCompareBillingPeriodStartAndEndDate(WorkDate(), CalcDate('<CY>', WorkDate())
                            , UsageDataBilling."Charge Start Date", UsageDataBilling."Charge End Date");
        Assert.AreEqual(2, UsageDataBilling.Count(), 'Expected two usage data billing lines to be created, but found a different count.');

        UsageDataBilling.FindFirst();
        // [THEN] Check Subscription Line
        ServiceCommitment.Get(UsageDataBilling."Subscription Line Entry No.");
        Assert.AreEqual(CalcDate('<CY+1Y+1D>', WorkDate()), ServiceCommitment."Next Billing Date", 'Expected Next Billing Date to be the day after the end of the year, but it was different.');
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateCustomerBillingDocumentPageHandler,MessageHandler')]
    procedure OneBillingLineIsCreatedForEveryRebillingUsageDataLine()
    var
        BillingLine: Record "Billing Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        ServiceCommitment: Record "Subscription Line";
        UsageDataGenericImport: Record "Usage Data Generic Import";
        InitialUsageDataImport: Record "Usage Data Import";
        RebillingUsageDataImport: Record "Usage Data Import";
        BillingFromDate: Date;
        BillingToDate: Date;
    begin
        // [SCENARIO] ???
        // [GIVEN] Set up the initial state
        ResetAll(); // Reset all data to ensure a clean state
        Initialize(); // Initialize necessary data and configurations
        SetupServiceObjectAndContracts(SubscriptionStartingDate);

        // [GIVEN] Setup and post first billing
        PostDocument := true;
        CreateInitialImport(InitialUsageDataImport); // Create initial usage data import record
        ProcessData(InitialUsageDataImport, "Processing Step"::"Process Usage Data Billing"); // Process the data to create usage data billing

        // [THEN] Verify setup
        UsageDataGenericImport.SetCurrentKey("Billing Period Start Date");
        UsageDataGenericImport.SetRange("Usage Data Import Entry No.", InitialUsageDataImport."Entry No.");
        Assert.AreEqual(1, UsageDataGenericImport.Count(), 'Expected one line to be imported in the first import, but found a different count.');
        UsageDataGenericImport.FindFirst(); // initial import
        TestAndCompareBillingPeriodStartAndEndDate(CalcDate('<-CY>', WorkDate()), CalcDate('<CY>', WorkDate())
            , UsageDataGenericImport."Billing Period Start Date", UsageDataGenericImport."Billing Period End Date");
        // [WHEN] Post the rebilling usage data import
        RebillingUsageDataImport.CollectCustomerContractsAndCreateInvoices(RebillingUsageDataImport);

        // [THEN] Check invoice and usage data billing line
        SalesInvoiceHeader.SetRange("Sell-to Customer No.", Customer."No.");
        SalesInvoiceHeader.FindFirst();
        SalesInvoiceHeader.TestField("Recurring Billing", true);
        UsageDataBilling.FilterOnDocumentTypeAndDocumentNo("Service Partner"::Customer, UsageDataBilling."Document Type"::"Posted Invoice", SalesInvoiceHeader."No.");
        Assert.AreEqual(1, UsageDataBilling.Count(), 'Expected one usage data billing to be invoiced, but found a different count.');
        UsageDataBilling.FindFirst();

        // [THEN] Check Subscription Line
        ServiceCommitment.Get(UsageDataBilling."Subscription Line Entry No.");
        Assert.AreEqual(CalcDate('<CY+1D>', WorkDate()), ServiceCommitment."Next Billing Date", 'Expected Next Billing Date to be the day after the end of the year, but it was different.');

        // [GIVEN] Setup and prepare follow-up billing
        PostDocument := false;
        CreateRebillingImportWithFollowupLine(RebillingUsageDataImport); // Create rebilling usage data import record with follow-up line
        ProcessData(RebillingUsageDataImport, "Processing Step"::"Process Usage Data Billing"); // Process the data to create usage data billing

        // [THEN] Verify setup
        UsageDataGenericImport.SetRange("Usage Data Import Entry No.", RebillingUsageDataImport."Entry No.");
        Assert.AreEqual(2, UsageDataGenericImport.Count(), 'Expected two lines to be imported in rebilling and follow-up import, but found a different count.');
        UsageDataGenericImport.FindFirst(); // rebilling of initial import
        TestAndCompareBillingPeriodStartAndEndDate(WorkDate(), CalcDate('<CY>', WorkDate())
                        , UsageDataGenericImport."Billing Period Start Date", UsageDataGenericImport."Billing Period End Date");
        UsageDataGenericImport.Next(); // follow-up billing of next year
        TestAndCompareBillingPeriodStartAndEndDate(CalcDate('<CY+1D>', WorkDate()), CalcDate('<CY+1Y>', WorkDate())
                        , UsageDataGenericImport."Billing Period Start Date", UsageDataGenericImport."Billing Period End Date");

        // [WHEN] Create sales invoice
        RebillingUsageDataImport.CollectCustomerContractsAndCreateInvoices(RebillingUsageDataImport);

        // [THEN] Check usage data billing line
        UsageDataBilling.Reset();
        UsageDataBilling.SetRange("Usage Data Import Entry No.", RebillingUsageDataImport."Entry No.");
        UsageDataBilling.SetRange(Partner, "Service Partner"::Customer);
        Assert.AreEqual(2, UsageDataBilling.Count(), 'Expected two usage data billing lines to be created, but found a different count.');
        UsageDataBilling.FindFirst();

        // [THEN] Check Subscription Line
        ServiceCommitment.Get(UsageDataBilling."Subscription Line Entry No.");
        Assert.AreEqual(CalcDate('<CY+1Y+1D>', WorkDate()), ServiceCommitment."Next Billing Date", 'Expected Next Billing Date to be the day after the end of the year, but it was different.');

        BillingLine.SetCurrentKey("Billing from");
        BillingLine.SetRange("Subscription Header No.", ServiceObject."No.");
        BillingLine.FindFirst();
        BillingFromDate := UsageDataBilling."Charge Start Date";
        BillingToDate := CalcDate('<CY>', WorkDate());
        TestAndCompareBillingPeriodStartAndEndDate(BillingFromDate, BillingToDate
                    , BillingLine."Billing from", BillingLine."Billing to");
        Assert.AreEqual(2, BillingLine.Count(), 'Expected two billing lines to be created, but found a different count.');
    end;

    local procedure Initialize()
    begin
        if Initialized then
            exit;

        SubscriptionStartingDate := CalcDate('<-CY>', WorkDate());
        SubscriptionEndingDate := CalcDate('<CY>', WorkDate());

        UBBTestLibrary.CreateUsageDataSupplier(UsageDataSupplier, Enum::"Usage Data Supplier Type"::Generic, true, Enum::"Vendor Invoice Per"::Import);
        UBBTestLibrary.CreateGenericImportSettings(GenericImportSettings, UsageDataSupplier."No.", true, true);

        SetupDataExchangeDefinition();
        UBBTestLibrary.ConnectDataExchDefinitionToUsageDataGenericSettings(DataExchDef.Code, GenericImportSettings);
        SetupUsageDataCustomerAndSubscription();

        Initialized := true;
    end;

    local procedure CreateInitialImport(var UsageDataImport: Record "Usage Data Import")
    var
        UsageDataGenericImport: Record "Usage Data Generic Import";
        BillingPeriodEndingDate: Date;
        BillingPeriodStartingDate: Date;
    begin
        BillingPeriodStartingDate := CalcDate('<-CY>', WorkDate());
        BillingPeriodEndingDate := CalcDate('<CY>', WorkDate());

        UBBTestLibrary.CreateUsageDataImport(UsageDataImport, UsageDataSupplier."No.");
        RRef.GetTable(UsageDataGenericImport);
        UsageDataBlob.InsertFromUsageDataImport(UsageDataImport);
        UBBTestLibrary.CreateUsageDataCSVFileBasedOnRecordAndImportToUsageDataBlob(
            UsageDataBlob,
            RRef,
            GetCustomerId(),
            GetSubscriptionId(),
            ServiceObject."No.",
            ServiceCommitmentGlobal."Entry No.",
            BillingPeriodStartingDate,
            BillingPeriodEndingDate,
            SubscriptionStartingDate,
            SubscriptionEndingDate,
            10);
    end;

    local procedure CreateRebillingImport(var UsageDataImport: Record "Usage Data Import")
    var
        UsageDataGenericImport: Record "Usage Data Generic Import";
        BillingPeriodEndingDate: Date;
        BillingPeriodStartingDate: Date;
    begin
        BillingPeriodStartingDate := WorkDate();
        BillingPeriodEndingDate := CalcDate('<CY>', WorkDate());

        UBBTestLibrary.CreateUsageDataImport(UsageDataImport, UsageDataSupplier."No.");
        RRef.GetTable(UsageDataGenericImport);
        UsageDataBlob.InsertFromUsageDataImport(UsageDataImport);
        UBBTestLibrary.CreateUsageDataCSVFileBasedOnRecordAndImportToUsageDataBlob(
            UsageDataBlob,
            RRef,
            GetCustomerId(),
            GetSubscriptionId(),
            ServiceObject."No.",
            ServiceCommitmentGlobal."Entry No.",
            BillingPeriodStartingDate,
            BillingPeriodEndingDate,
            SubscriptionStartingDate,
            SubscriptionEndingDate,
            10);
    end;

    local procedure CreateRebillingImportWithFollowupLine(var UsageDataImport: Record "Usage Data Import")
    var
        UsageDataGenericImport: Record "Usage Data Generic Import";
        BillingPeriodEndingDate: Date;
        BillingPeriodStartingDate: Date;
        FieldCount: Integer;
        OutStr: OutStream;
    begin
        UBBTestLibrary.CreateUsageDataImport(UsageDataImport, UsageDataSupplier."No.");
        RRef.GetTable(UsageDataGenericImport);
        UsageDataBlob.InsertFromUsageDataImport(UsageDataImport);

        UsageDataBlob.Data.CreateOutStream(OutStr, TextEncoding::UTF8);
        FieldCount := RRef.FieldCount();
        UBBTestLibrary.CreateOutStreamHeaders(UsageDataBlob, OutStr, RRef, FieldCount);

        BillingPeriodStartingDate := WorkDate();
        BillingPeriodEndingDate := CalcDate('<CY>', WorkDate());
        UBBTestLibrary.CreateOutStreamData(
            UsageDataBlob,
            OutStr,
            RRef,
            FieldCount,
            GetCustomerId(),
            GetSubscriptionId(),
            ServiceObject."No.",
            ServiceCommitmentGlobal."Entry No.",
            BillingPeriodStartingDate,
            BillingPeriodEndingDate,
            SubscriptionStartingDate,
            SubscriptionEndingDate,
            10);

        BillingPeriodStartingDate := CalcDate('<CY+1D>', WorkDate());
        BillingPeriodEndingDate := CalcDate('<CY+1Y>', WorkDate());
        UBBTestLibrary.CreateOutStreamData(
            UsageDataBlob,
            OutStr,
            RRef,
            FieldCount,
            GetCustomerId(),
            GetSubscriptionId(),
            ServiceObject."No.",
            ServiceCommitmentGlobal."Entry No.",
            BillingPeriodStartingDate,
            BillingPeriodEndingDate,
            SubscriptionStartingDate,
            SubscriptionEndingDate,
            10);

        UsageDataBlob.ComputeHashValue();
        UsageDataBlob."Import Status" := Enum::"Processing Status"::Ok;
        UsageDataBlob.Modify(false);
    end;

    local procedure SetupDataExchangeDefinition()
    var
        UsageDataGenericImport: Record "Usage Data Generic Import";
        UsageDataGenericImportRRef: RecordRef;
    begin
        UsageDataGenericImportRRef.GetTable(UsageDataGenericImport);
        UBBTestLibrary.CreateDataExchDefinition(DataExchDef, FileType::"Variable Text", Enum::"Data Exchange Definition Type"::"Generic Import", FileEncoding::"UTF-8", ColumnSeparator::Semicolon, '', 1);
        UBBTestLibrary.CreateDataExchDefinitionLine(DataExchLineDef, DataExchDef.Code, UsageDataGenericImportRRef);
        UBBTestLibrary.CreateDataExchColumnDefinition(DataExchColumnDef, DataExchDef.Code, DataExchLineDef.Code, UsageDataGenericImportRRef);
        UBBTestLibrary.CreateDataExchangeMapping(DataExchMapping, DataExchDef.Code, DataExchLineDef.Code, UsageDataGenericImportRRef);
        UBBTestLibrary.CreateDataExchangeFieldMapping(DataExchFieldMapping, DataExchDef.Code, DataExchLineDef.Code, UsageDataGenericImportRRef);
    end;

    local procedure SetupServiceObjectAndContracts(ServiceAndCalculationStartDate: Date)
    begin
        ContractTestLibrary.CreateCustomer(Customer);
        CreateServiceObjectWithServiceCommitments(Customer."No.", ServiceAndCalculationStartDate);
        CreateCustomerContractAndAssignServiceCommitments();
        CreateVendorContractAndAssignServiceCommitments();
    end;

    local procedure SetupUsageDataCustomerAndSubscription()
    var
        UsageDataGenericImport: Record "Usage Data Generic Import";
        GenericUsageDataImport: Codeunit "Import And Process Usage Data";
    begin
        UsageDataGenericImport."Customer ID" := GetCustomerId();
        UsageDataGenericImport."Supp. Subscription ID" := GetSubscriptionId();
        GenericUsageDataImport.CreateUsageDataCustomer(UsageDataGenericImport."Customer ID", UsageDataSupplierReference, UsageDataSupplier."No.");
        GenericUsageDataImport.CreateUsageDataSubscription(UsageDataGenericImport."Supp. Subscription ID", UsageDataGenericImport."Customer ID",
                                    UsageDataGenericImport."Product ID", UsageDataGenericImport."Product Name", UsageDataGenericImport."Unit",
                                    UsageDataGenericImport.Quantity, UsageDataGenericImport."Supp. Subscription Start Date", UsageDataGenericImport."Supp. Subscription End Date",
                                    UsageDataSupplierReference, UsageDataSupplier."No.");
    end;

    local procedure ResetAll()
    var
        BillingLine: Record "Billing Line";
    begin
        ClearAll();
        BillingLine.DeleteAll(false);
    end;

    local procedure CreateServiceObjectWithServiceCommitments(CustomerNo: Code[20]; ServiceAndCalculationStartDate: Date)
    begin
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        ContractTestLibrary.UpdateItemUnitCostAndPrice(Item, LibraryRandom.RandDec(1000, 2), LibraryRandom.RandDec(1000, 2), false);

        SetupItemWithMultipleServiceCommitmentPackages();
        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, Item."No.");
        ServiceObject.InsertServiceCommitmentsFromStandardServCommPackages(ServiceAndCalculationStartDate);

        ServiceObject."End-User Customer No." := CustomerNo;
        ServiceObject.Modify(false);

        // Update Subscription Lines
        ServiceCommitmentGlobal.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitmentGlobal.FindSet();
        repeat
            ServiceCommitmentGlobal."Usage Based Billing" := true;
            ServiceCommitmentGlobal."Usage Based Pricing" := "Usage Based Pricing"::"Usage Quantity";
            ServiceCommitmentGlobal.Validate("Subscription Line Start Date", ServiceAndCalculationStartDate);

            UsageDataSupplierReference.FilterUsageDataSupplierReference(UsageDataSupplier."No.", GetSubscriptionId(), Enum::"Usage Data Reference Type"::Subscription);
            if UsageDataSupplierReference.FindFirst() then
                ServiceCommitmentGlobal."Supplier Reference Entry No." := UsageDataSupplierReference."Entry No.";
            ServiceCommitmentGlobal.Modify(false);
        until ServiceCommitmentGlobal.Next() = 0;
    end;

    local procedure CreateCustomerContractAndAssignServiceCommitments()
    var
        TempServiceCommitment: Record "Subscription Line" temporary;
    begin
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");
        ContractTestLibrary.FillTempServiceCommitment(TempServiceCommitment, ServiceObject, CustomerContract);
        CustomerContract.CreateCustomerContractLinesFromServiceCommitments(TempServiceCommitment);
        CustomerContractLine.SetRange("Subscription Contract No.", CustomerContract."No.");
        CustomerContractLine.FindLast();
        ContractTestLibrary.SetGeneralPostingSetup(Customer."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group", false, Enum::"Service Partner"::Customer);
    end;

    local procedure CreateVendorContractAndAssignServiceCommitments()
    var
        TempServiceCommitment: Record "Subscription Line" temporary;
    begin
        ContractTestLibrary.CreateVendorInLCY(Vendor);
        ContractTestLibrary.CreateVendorContract(VendorContract, Vendor."No.");
        ContractTestLibrary.FillTempServiceCommitmentForVendor(TempServiceCommitment, ServiceObject, VendorContract);
        VendorContract.CreateVendorContractLinesFromServiceCommitments(TempServiceCommitment);
        VendorContractLine.SetRange("Subscription Contract No.", VendorContract."No.");
        VendorContractLine.FindLast();
        ContractTestLibrary.SetGeneralPostingSetup(Vendor."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group", false, Enum::"Service Partner"::Vendor);
    end;

    [ModalPageHandler]
    procedure ExchangeRateSelectionModalPageHandler(var ExchangeRateSelectionPage: TestPage "Exchange Rate Selection")
    begin
        ExchangeRateSelectionPage.OK().Invoke();
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    [ModalPageHandler]
    procedure CreateCustomerBillingDocumentPageHandler(var CreateCustomerBillingDocument: TestPage "Create Usage B. Cust. B. Docs")
    begin
        CreateCustomerBillingDocument.BillingDate.SetValue(WorkDate());
        CreateCustomerBillingDocument.PostDocument.SetValue(PostDocument);
        CreateCustomerBillingDocument.OK().Invoke()
    end;

    [ModalPageHandler]
    procedure CreateVendorBillingDocumentPageHandler(var CreateVendorBillingDocument: TestPage "Create Usage B. Vend. B. Docs")
    begin
        CreateVendorBillingDocument.BillingDate.SetValue(WorkDate());
        CreateVendorBillingDocument.OK().Invoke()
    end;

    procedure SetupItemWithMultipleServiceCommitmentPackages()
    begin
        //Billing rhythm should be the same as in Usage data billing which is in the UBB Library set to 1D always (WorkDate()) Ref: CreateOutStreamData
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        Evaluate(ServiceCommitmentTemplate."Billing Base Period", '1Y');
        ServiceCommitmentTemplate."Calculation Base %" := LibraryRandom.RandDec(100, 2);
        ServiceCommitmentTemplate."Invoicing via" := Enum::"Invoicing Via"::Contract;
        ServiceCommitmentTemplate."Calculation Base Type" := "Calculation Base Type"::"Item Price";
        ServiceCommitmentTemplate.Modify(false);
        //Standard Subscription Package with two Subscription Package Lines
        //1. for Customer
        //2. for Vendor
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ServiceCommPackageLine.Partner := Enum::"Service Partner"::Customer;
        Evaluate(ServiceCommPackageLine."Extension Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Notice Period", '<1M>');
        Evaluate(ServiceCommPackageLine."Initial Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Billing Rhythm", '<1Y>');
        ServiceCommPackageLine.Modify(false);

        ContractTestLibrary.CreateServiceCommitmentPackageLine(ServiceCommitmentPackage.Code, ServiceCommitmentTemplate.Code, ServiceCommPackageLine);
        ServiceCommPackageLine.Partner := Enum::"Service Partner"::Vendor;
        Evaluate(ServiceCommPackageLine."Extension Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Notice Period", '<1M>');
        Evaluate(ServiceCommPackageLine."Initial Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Billing Rhythm", '<1Y>');
        ServiceCommPackageLine.Modify(false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);
        ItemServCommitmentPackage.Get(Item."No.", ServiceCommitmentPackage.Code);
        ItemServCommitmentPackage.Standard := true;
        ItemServCommitmentPackage.Modify(false);

        //Additional Subscription Package
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ServiceCommPackageLine.Partner := Enum::"Service Partner"::Customer;
        Evaluate(ServiceCommPackageLine."Extension Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Notice Period", '<1M>');
        Evaluate(ServiceCommPackageLine."Initial Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Billing Rhythm", '<1Y>');
        ServiceCommPackageLine.Modify(false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);
    end;

    local procedure GetCustomerId(): Text[80]
    begin
        exit(PrefixLbl + 'CUST_000001');
    end;

    local procedure GetSubscriptionId(): Text[80]
    begin
        exit(PrefixLbl + 'SUB_000001');
    end;

    local procedure ProcessData(var UsageDataImportToProcess: Record "Usage Data Import"; UpToProcessingStep: Enum "Processing Step")
    begin
        UsageDataImportToProcess.SetRange("Entry No.", UsageDataImportToProcess."Entry No.");
        if UpToProcessingStep.AsInteger() >= "Processing Step"::"Create Imported Lines".AsInteger() then
            UsageDataImportToProcess.ProcessUsageDataImport(UsageDataImportToProcess, "Processing Step"::"Create Imported Lines");
        if UpToProcessingStep.AsInteger() >= "Processing Step"::"Process Imported Lines".AsInteger() then
            UsageDataImportToProcess.ProcessUsageDataImport(UsageDataImportToProcess, "Processing Step"::"Process Imported Lines");
        if UpToProcessingStep.AsInteger() >= "Processing Step"::"Create Usage Data Billing".AsInteger() then
            UsageDataImportToProcess.ProcessUsageDataImport(UsageDataImportToProcess, "Processing Step"::"Create Usage Data Billing");
        if UpToProcessingStep.AsInteger() >= "Processing Step"::"Process Usage Data Billing".AsInteger() then
            UsageDataImportToProcess.ProcessUsageDataImport(UsageDataImportToProcess, "Processing Step"::"Process Usage Data Billing");
    end;

    local procedure TestUsageDataBillingMetadataForRebilling(var UsageDataBillingMetadata: Record "Usage Data Billing Metadata"; UsageDataBilling: Record "Usage Data Billing"; TestTrue: Boolean)
    begin
        UsageDataBillingMetadata.SetRange("Usage Data Billing Entry No.", UsageDataBilling."Entry No.");
        UsageDataBillingMetadata.FindFirst(); // Find the first matching metadata record
        if not TestTrue then
            Assert.IsFalse(UsageDataBillingMetadata.Rebilling, 'Expected UsageDataBillingMetadata.Rebilling to be false for initial import, but it was true.') // Verify that the rebilling flag is false
        else
            Assert.IsTrue(UsageDataBillingMetadata.Rebilling, 'Expected UsageDataBillingMetadata.Rebilling to be true for rebilling import, but it was false.'); // Verify that the rebilling flag is true
    end;

    local procedure TestUsageDataForRebilling(var UsageDataBilling: Record "Usage Data Billing"; UsageDataImportEntryNo: Integer; TestTrue: Boolean)
    begin
        UsageDataBilling.SetRange("Usage Data Import Entry No.", UsageDataImportEntryNo);
        UsageDataBilling.FindLast();
        if not TestTrue then
            Assert.IsFalse(UsageDataBilling.Rebilling, 'Expected initial import to not be rebilling, but it was.'); // Verify that the initial import is not rebilling
    end;

    local procedure TestAndCompareBillingPeriodStartAndEndDate(ExpectedBillingPeriodStartDate: Date; ExpectedBillingPeriodEndDate: Date; BillingPeriodStartDate: Date; BillingPeriodEndDate: Date)
    begin
        Assert.AreEqual(ExpectedBillingPeriodStartDate, BillingPeriodStartDate, 'Billing Period Start Date does not match the expected value.');
        Assert.AreEqual(ExpectedBillingPeriodEndDate, BillingPeriodEndDate, 'Billing Period End Date does not match the expected value.');
    end;

    var
        Customer: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        DataExchColumnDef: Record "Data Exch. Column Def";
        DataExchDef: Record "Data Exch. Def";
        DataExchFieldMapping: Record "Data Exch. Field Mapping";
        DataExchLineDef: Record "Data Exch. Line Def";
        DataExchMapping: Record "Data Exch. Mapping";
        GenericImportSettings: Record "Generic Import Settings";
        Item: Record Item;
        ItemServCommitmentPackage: Record "Item Subscription Package";
        ServiceCommPackageLine: Record "Subscription Package Line";
        ServiceCommitmentGlobal: Record "Subscription Line";
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceCommitmentTemplate: Record "Sub. Package Line Template";
        ServiceObject: Record "Subscription Header";
        UsageDataBilling: Record "Usage Data Billing";
        UsageDataBlob: Record "Usage Data Blob";
        UsageDataSupplier: Record "Usage Data Supplier";
        UsageDataSupplierReference: Record "Usage Data Supplier Reference";
        Vendor: Record Vendor;
        VendorContract: Record "Vendor Subscription Contract";
        VendorContractLine: Record "Vend. Sub. Contract Line";
        Assert: Codeunit Assert;
        ContractTestLibrary: Codeunit "Contract Test Library";
        LibraryRandom: Codeunit "Library - Random";
        UBBTestLibrary: Codeunit "Usage Based B. Test Library";
        RRef: RecordRef;
        Initialized: Boolean;
        PostDocument: Boolean;
        SubscriptionEndingDate: Date;
        SubscriptionStartingDate: Date;
        PrefixLbl: Label 'ZZZ', Locked = true;
        ColumnSeparator: Option " ",Tab,Semicolon,Comma,Space,Custom;
        FileEncoding: Option "MS-DOS","UTF-8","UTF-16",WINDOWS;
        FileType: Option Xml,"Variable Text","Fixed Text",Json;
}
