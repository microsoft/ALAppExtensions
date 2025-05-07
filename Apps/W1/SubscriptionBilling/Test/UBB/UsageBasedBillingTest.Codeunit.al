namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.Currency;
using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Item.Catalog;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Setup;
using System.IO;
using System.TestLibraries.Utilities;

codeunit 148153 "Usage Based Billing Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    var
        BillingLine: Record "Billing Line";
        BillingTemplate: Record "Billing Template";
        Currency: Record Currency;
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
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchSetup: Record "Purchases & Payables Setup";
        SalesSetup: Record "Sales & Receivables Setup";
        SalesCrMemoHeader: Record "Sales Header";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesLine: Record "Sales Line";
        ServiceCommPackageLine: Record "Subscription Package Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceCommitmentTemplate: Record "Sub. Package Line Template";
        ServiceObject: Record "Subscription Header";
        UsageDataBilling: Record "Usage Data Billing";
        UsageDataBlob: Record "Usage Data Blob";
        UsageDataCustomer: Record "Usage Data Supp. Customer";
        UsageDataGenericImport: Record "Usage Data Generic Import";
        UsageDataImport: Record "Usage Data Import";
        UsageDataSubscription: Record "Usage Data Supp. Subscription";
        UsageDataSupplier: Record "Usage Data Supplier";
        UsageDataSupplierReference: Record "Usage Data Supplier Reference";
        Vendor: Record Vendor;
        VendorContract: Record "Vendor Subscription Contract";
        VendorContractLine: Record "Vend. Sub. Contract Line";
        Assert: Codeunit Assert;
        ContractTestLibrary: Codeunit "Contract Test Library";
        CorrectPostedPurchaseInvoice: Codeunit "Correct Posted Purch. Invoice";
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryItemReference: Codeunit "Library - Item Reference";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        UsageBasedBTestLibrary: Codeunit "Usage Based B. Test Library";
        UsageBasedDocTypeConverter: Codeunit "Usage Based Doc. Type Conv.";
        RRef: RecordRef;
        IsInitialized: Boolean;
        PostDocument: Boolean;
        CorrectedDocumentNo: Code[20];
        i: Integer;
        j: Integer;
        ColumnSeparator: Option " ",Tab,Semicolon,Comma,Space,Custom;
        FileEncoding: Option "MS-DOS","UTF-8","UTF-16",WINDOWS;
        FileType: Option Xml,"Variable Text","Fixed Text",Json;

    #region Tests

    [Test]
    [HandlerFunctions('MessageHandler,CreateCustomerBillingDocumentPageHandler')]
    procedure ApplyServiceCommitmentDiscountInContractInvoice()
    var
        DiscountPct: Decimal;
    begin
        // [SCENARIO] Check that discount from Subscription Line is applied in the invoice and usage data is updated accordingly

        // [GIVEN] Create Subscription Item
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        Item."Unit Price" := LibraryRandom.RandDec(1000, 2);
        Item."Unit Cost" := LibraryRandom.RandDec(1000, 2);
        Item.Modify(false);

        // [GIVEN] Setup Subscription with Subscription Lines and usage quantity
        SetupServiceDataForProcessing(Enum::"Usage Based Pricing"::"Usage Quantity", "Calculation Base Type"::"Item Price", Enum::"Invoicing Via"::Contract,
                                       '1Y', '1Y', '1Y', "Service Partner"::Customer, 100, Item."No.");

        // [GIVEN] Add discount to Subscription Line
        DiscountPct := LibraryRandom.RandDec(99, 2);
        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.FindSet();
        repeat
            ServiceCommitment.Validate("Discount %", DiscountPct);
            ServiceCommitment.Modify(false);
        until ServiceCommitment.Next() = 0;

        // [WHEN] Create and process simple usage data
        ProcessUsageDataWithSimpleGenericImport(WorkDate(), WorkDate(), WorkDate(), CalcDate('<CM>', WorkDate()), 1);

        // [WHEN] Create contract invoice from usage data - discount should be applied
        UsageDataImport.CollectCustomerContractsAndCreateInvoices(UsageDataImport);

        // [THEN] Expect that discount is not applied in the Usage data, but in the invoice
        FilterUsageDataBillingOnUsageDataImport(UsageDataImport."Entry No.", "Service Partner"::Customer);
        UsageDataBilling.FindFirst();

        BillingLine.FilterBillingLineOnContractLine(UsageDataBilling.Partner, UsageDataBilling."Subscription Contract No.", UsageDataBilling."Subscription Contract Line No.");
        BillingLine.FindSet();
        repeat
            BillingLine.TestField("Discount %", DiscountPct);
        until BillingLine.Next() = 0;

        // [THEN] Test that prices Subscription Line is not updated
        CheckIfServiceCommitmentRemains();
    end;

    [Test]
    procedure ExistForContractLineDependsOnUsageDataForContractLine()
    var
        CustomerContractLine1: Record "Cust. Sub. Contract Line";
        UsageDataBilling1: Record "Usage Data Billing";
        UsageDataExist: Boolean;
    begin
        // [SCENARIO] Action Usage Data should be disabled if there is no Usage Data for Contract Line and should be enabled if there is Usage Data for Contract Line

        // [GIVEN] Create Customer Subscription Contract with line
        ResetAll();
        UsageBasedBTestLibrary.MockCustomerContractLine(CustomerContractLine1);

        // [WHEN] Contract line is selected
        UsageDataExist := UsageDataBilling1.ExistForContractLine("Service Partner"::Customer, CustomerContractLine1."Subscription Contract No.", CustomerContractLine1."Line No.");

        // [THEN] Action Usage Data should be disabled
        Assert.IsFalse(UsageDataExist, 'Usage Data Action should be disabled');

        // [WHEN] Usage Data is created and Contract line is selected
        UsageBasedBTestLibrary.MockCustomerContractLine(CustomerContractLine1);
        UsageBasedBTestLibrary.MockUsageDataBillingForContractLine(UsageDataBilling1, "Service Partner"::Customer, CustomerContractLine1."Subscription Contract No.", CustomerContractLine1."Line No.");
        UsageDataExist := UsageDataBilling1.ExistForContractLine("Service Partner"::Customer, CustomerContractLine1."Subscription Contract No.", CustomerContractLine1."Line No.");

        // [THEN] Action Usage Data should be enabled
        Assert.IsTrue(UsageDataExist, 'Usage Data Action should be enabled');
    end;

    [Test]
    procedure ExistForDocumentsDependsOnUsageDataForDocument()
    var
        Item1: Record Item;
        SalesHeader1: Record "Sales Header";
        SalesLine1: Record "Sales Line";
        UsageDataBilling1: Record "Usage Data Billing";
        UsageDataExist: Boolean;
    begin
        // [SCENARIO] Action Usage Data should be disabled if there is no Usage Data for Document line and should be enabled if there is Usage Data for Document Line

        // [GIVEN] Create Sales Invoice
        ResetAll();
        LibraryInventory.CreateNonInventoryTypeItem(Item1);
        LibrarySales.CreateSalesHeader(SalesHeader1, SalesHeader1."Document Type"::Invoice, '');
        LibrarySales.CreateSalesLine(SalesLine1, SalesHeader1, SalesLine1.Type::Item, Item1."No.", LibraryRandom.RandInt(100));

        // [WHEN] Sales line is selected
        UsageDataExist := UsageDataBilling1.ExistForSalesDocuments(SalesLine1."Document Type", SalesLine1."Document No.", SalesLine1."Line No.");

        // [THEN] Action Usage Data should be disabled
        Assert.IsFalse(UsageDataExist, 'Usage Data Action should be disabled');

        // [WHEN] Usage Data is created and Sales line is selected
        UsageBasedBTestLibrary.MockUsageDataBillingForDocuments(UsageDataBilling1, SalesLine1."Document Type", SalesLine1."Document No.", SalesLine1."Line No.");
        UsageDataExist := UsageDataBilling1.ExistForSalesDocuments(SalesLine1."Document Type", SalesLine1."Document No.", SalesLine1."Line No.");

        // [THEN] Action Usage Data should be enabled
        Assert.IsTrue(UsageDataExist, 'Usage Data Action should be enabled');
    end;

    [Test]
    procedure ExistForRecurringBillingDependsOnBillingUsageData()
    var
        BillingLine1: Record "Billing Line";
        UsageDataBilling1: Record "Usage Data Billing";
        UsageDataExist: Boolean;
    begin
        // [SCENARIO] Action Usage Data should be disabled if there is no Usage Data for Billing Line and should be enabled if there is Usage Data for Billing Line

        // [GIVEN] Create Billing Line
        ResetAll();
        UsageBasedBTestLibrary.MockBillingLine(BillingLine1);

        // [WHEN] Billing line is selected
        UsageDataExist := UsageDataBilling1.ExistForRecurringBilling(BillingLine1."Subscription Header No.", BillingLine1."Subscription Line Entry No.", BillingLine1."Document Type", BillingLine1."Document No.");

        // [THEN] Action Usage Data should be disabled
        Assert.IsFalse(UsageDataExist, 'Usage Data Action should be disabled');

        // [WHEN] Usage Data is created and Billing line is selected
        UsageBasedBTestLibrary.MockBillingLineWithServObjectNo(BillingLine1);
        UsageBasedBTestLibrary.CreateSalesInvoiceAndAssignToBillingLine(BillingLine1);
        UsageBasedBTestLibrary.MockUsageDataForBillingLine(UsageDataBilling1, BillingLine1);
        UsageDataExist := UsageDataBilling1.ExistForRecurringBilling(BillingLine1."Subscription Header No.", BillingLine1."Subscription Line Entry No.", BillingLine1."Document Type", BillingLine1."Document No.");

        // [THEN] Action Usage Data should be enabled
        Assert.IsTrue(UsageDataExist, 'Usage Data Action should be enabled');
    end;

    [Test]
    procedure ExistForServiceCommitmentsDependsOnServiceCommitmentUsageData()
    var
        ServiceCommitment1: Record "Subscription Line";
        UsageDataBilling1: Record "Usage Data Billing";
        UsageDataExist: Boolean;
    begin
        // [SCENARIO] Action Usage Data should be disabled if there is no Usage Data for Subscription Line Line and should be enabled if there is Usage Data for Subscription Line Line

        // [GIVEN] Create Subscription Line
        ResetAll();
        UsageBasedBTestLibrary.MockServiceCommitmentLine(ServiceCommitment1);

        // [WHEN] Subscription Line line is selected
        UsageDataExist := UsageDataBilling1.ExistForServiceCommitments(ServiceCommitment1.Partner, ServiceCommitment1."Subscription Header No.", ServiceCommitment1."Entry No.");

        // [THEN] Action Usage Data should be disabled
        Assert.IsFalse(UsageDataExist, 'Usage Data Action should be disabled');

        // [WHEN] Usage data is created and Subscription Line line is selected
        UsageBasedBTestLibrary.MockUsageDataBillingForServiceCommitmentLine(UsageDataBilling1, ServiceCommitment1.Partner, ServiceCommitment1."Subscription Header No.", ServiceCommitment1."Entry No.");
        UsageDataExist := UsageDataBilling1.ExistForServiceCommitments(ServiceCommitment1.Partner, ServiceCommitment1."Subscription Header No.", ServiceCommitment1."Entry No.");

        // [THEN] Action Usage Data should be enabled
        Assert.IsTrue(UsageDataExist, 'Usage Data Action should be enabled');
    end;

    [Test]
    procedure ExpectErrorIfGenericSettingIsNotLinkedToDataExchangeDefinition()
    begin
        Initialize();
        SetupUsageDataForProcessingToGenericImport();
        SetupDataExchangeDefinition();
        UsageDataImport."Processing Step" := Enum::"Processing Step"::"Create Imported Lines";
        UsageDataImport.Modify(false);
        asserterror Codeunit.Run(Codeunit::"Import And Process Usage Data", UsageDataImport);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorIfServiceCommitmentIsNotAssignedToContract()
    begin
        Initialize();
        SetupUsageDataForProcessingToGenericImport(WorkDate(), WorkDate(), WorkDate(), WorkDate(), 1, false);
        SetupDataExchangeDefinition();
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        Item."Unit Price" := 1;
        Item."Unit Cost" := 1;
        Item.Modify(false);
        SetupItemWithMultipleServiceCommitmentPackages();
        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, Item."No.");
        ServiceObject.InsertServiceCommitmentsFromStandardServCommPackages(WorkDate());
        ServiceObject."End-User Customer No." := Customer."No.";
        ServiceObject.Modify(false);
        CreateCustomerContractAndAssignServiceCommitments();
        UsageBasedBTestLibrary.ConnectDataExchDefinitionToUsageDataGenericSettings(DataExchDef.Code, GenericImportSettings);

        ProcessUsageDataImport(Enum::"Processing Step"::"Create Imported Lines");
        ProcessUsageDataImport(Enum::"Processing Step"::"Process Imported Lines");

        UsageDataGenericImport.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        UsageDataGenericImport.FindFirst();
        PrepareServiceCommitmentAndUsageDataGenericImportForUsageBilling("Usage Based Pricing"::"Usage Quantity", '1D', '1D');
        Codeunit.Run(Codeunit::"Import And Process Usage Data", UsageDataImport);
        UsageDataImport.SetRecFilter();
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Create Usage Data Billing");

        UsageDataImport.Get(UsageDataImport."Entry No.");
        UsageDataImport.TestField("Processing Status", Enum::"Processing Status"::Error);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnDeleteCustomerContractLine()
    begin
        Initialize();
        CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2));
        UsageDataBilling.SetRange(Partner, "Service Partner"::Customer);
        UsageDataBilling.FindFirst();
        CustomerContractLine.Get(UsageDataBilling."Subscription Contract No.", UsageDataBilling."Subscription Contract Line No.");
        asserterror CustomerContractLine.Delete(true);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateCustomerBillingDocumentPageHandler,MessageHandler')]
    procedure ExpectErrorOnDeleteUsageDataImportIfDocumentIsCreated()
    begin
        Initialize();
        CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2));
        PostDocument := true;
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");
        UsageDataImport.TestField("Processing Status", "Processing Status"::Ok);
        UsageDataImport.CollectCustomerContractsAndCreateInvoices(UsageDataImport);
        asserterror UsageDataImport.Delete(true);
        asserterror UsageDataImport.DeleteUsageDataBillingLines();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnProcessUsageDataBillingWithZeroQuantity()
    begin
        Initialize();
        CreateUsageDataBilling("Usage Based Pricing"::"Usage Quantity", WorkDate(), WorkDate(), WorkDate(), WorkDate(), 0);
        ServiceObject.Quantity := 0;
        ServiceObject.Modify(false);
        Codeunit.Run(Codeunit::"Process Usage Data Billing", UsageDataImport);
        UsageDataImport.TestField("Processing Status", "Processing Status"::Error);
    end;

    [Test]
    procedure ExpectErrorWhenDataExchangeDefinitionIsNotGenericImportForGenericImportSettings()
    var
        DataExchDefType: Enum "Data Exchange Definition Type";
        ListOfOrdinals: List of [Integer];
    begin
        // [GIVEN] Error for validating "Data Exchange Definition" for "Data Exchange Definition Type" different than "Generic Import"
        Initialize();
        UsageBasedBTestLibrary.CreateUsageDataSupplier(UsageDataSupplier, Enum::"Usage Data Supplier Type"::Generic, true, Enum::"Vendor Invoice Per"::Import);
        UsageBasedBTestLibrary.CreateGenericImportSettings(GenericImportSettings, UsageDataSupplier."No.", true, true);

        ListOfOrdinals := "Data Exchange Definition Type".Ordinals();
        foreach i in ListOfOrdinals do begin
            DataExchDefType := "Data Exchange Definition Type".FromInteger(i);
            UsageBasedBTestLibrary.CreateDataExchDefinition(DataExchDef, FileType::"Variable Text", DataExchDefType, FileEncoding::"UTF-8", ColumnSeparator::Semicolon, '', 1);
            if DataExchDefType = "Data Exchange Definition Type"::"Generic Import" then
                GenericImportSettings.Validate("Data Exchange Definition", DataExchDef.Code)
            else
                asserterror GenericImportSettings.Validate("Data Exchange Definition", DataExchDef.Code);
        end;
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorWhenServiceCommitmentStartDateIsNotValid()
    begin
        Initialize();
        SetupUsageDataForProcessingToGenericImport();
        SetupDataExchangeDefinition();
        UsageBasedBTestLibrary.ConnectDataExchDefinitionToUsageDataGenericSettings(DataExchDef.Code, GenericImportSettings);
        ProcessUsageDataImport(Enum::"Processing Step"::"Create Imported Lines");

        UsageDataGenericImport.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        UsageDataGenericImport.FindFirst();

        SetupServiceObjectAndContracts(CalcDate('<-1D>', WorkDate())); // USage data generic import is create on workdate
        ProcessUsageDataImport(Enum::"Processing Step"::"Process Imported Lines");
        UsageDataGenericImport.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        UsageDataGenericImport.FindFirst();
        UsageDataGenericImport.TestField("Processing Status", Enum::"Processing Status"::Error);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectNoInvoicesCreateIfUsageDataImportProcessingStatusIsError()
    begin
        // [SCENARIO] When usage data is processed with an error
        // expect no invoices to be created

        // [GIVEN] Create usage data which will for sure cause an error
        Initialize();
        CreateUsageDataBilling("Usage Based Pricing"::"Usage Quantity", WorkDate(), WorkDate(), WorkDate(), WorkDate(), 0);
        ServiceObject.Quantity := 0; // Zero Quantity on Subscription will cause error
        ServiceObject.Modify(false);
        PostDocument := false;
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");

        // [WHEN] Try to create Customer Subscription Contract invoices; Error should be caught and no usage data lines should be taken into contract invoice
        UsageDataImport.CollectCustomerContractsAndCreateInvoices(UsageDataImport);

        // [THEN] Test if Processing Status Error is set in Usage Data Import and that no invoice has been created and assigned in Usage Data Billing
        UsageDataImport.Get(UsageDataImport."Entry No.");
        UsageDataImport.TestField("Processing Status", Enum::"Processing Status"::Error);
        FilterUsageDataBillingOnUsageDataImport(UsageDataImport."Entry No.", "Service Partner"::Customer, UsageDataBilling."Document Type"::Invoice);
        Assert.RecordIsEmpty(UsageDataBilling);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateCustomerBillingDocumentPageHandler,MessageHandler')]
    procedure TestCreateContractInvoiceForMultipleCustomerContracts()
    begin
        Initialize();
        for i := 1 to 2 do // create usage data for 3 different contracts
            CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2));

        // Process usage data and create Customer Subscription Contract invoices
        UsageDataImport.Reset();
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");
        UsageDataImport.Reset();
        UsageDataImport.CollectCustomerContractsAndCreateInvoices(UsageDataImport);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateVendorBillingDocumentPageHandler,MessageHandler')]
    procedure TestCreateContractInvoiceForMultipleVendorContracts()
    begin
        Initialize();
        for i := 1 to 2 do // create usage data for 3 different contracts
            CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2));

        // Process usage data and create Vendor Subscription Contract invoices
        UsageDataImport.Reset();
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");
        UsageDataImport.Reset();
        UsageDataImport.CollectVendorContractsAndCreateInvoices(UsageDataImport);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateCustomerBillingDocumentPageHandler,MessageHandler')]
    procedure TestCreateContractInvoiceFromUsageDataImport()
    begin
        Initialize();
        CreateUsageDataBilling("Usage Based Pricing"::"Usage Quantity", LibraryRandom.RandDec(10, 2));
        PostDocument := false;
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");
        UsageDataImport.TestField("Processing Status", "Processing Status"::Ok);
        UsageDataImport.CollectCustomerContractsAndCreateInvoices(UsageDataImport);
        CheckIfSalesDocumentsHaveBeenCreated();
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure TestCreateContractInvoiceWithUsageBasedServiceCommitmentsWithUsageData()
    begin
        ClearAll();
        ContractTestLibrary.InitContractsApp();

        // [GIVEN] Usage data billing for a contract
        CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2)); // MessageHandler, ExchangeRateSelectionModalPageHandler
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");

        // [WHEN] Creating a billing proposal
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);

        // [THEN] A Billing Line should be created for Usage Based Subscription Lines with usage data
        BillingLine.Reset();
        Assert.AreEqual(false, BillingLine.IsEmpty, 'A new Billing Line should be created for Usage Based Service Commitments with usage data when creating an invoice from the contract');
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateCustomerBillingDocumentPageHandler,MessageHandler')]
    procedure TestCreateCustomerContractInvoiceFromUsageDataImport()
    begin
        Initialize();
        CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2));
        PostDocument := false;
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");
        UsageDataImport.TestField("Processing Status", "Processing Status"::Ok);
        UsageDataImport.CollectCustomerContractsAndCreateInvoices(UsageDataImport);
        CheckIfSalesDocumentsHaveBeenCreated();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestCreateInvoicesForMoreThanOneContractPerImportViaRecurringBilling()
    var
        CustomerContract2: Record "Customer Subscription Contract";
        ServiceObject2: Record "Subscription Header";
        TestSubscribers: Codeunit "Usage Based B. Test Subscr.";
        QuantityOfServiceCommitments: Integer;
    begin
        ClearAll();
        ContractTestLibrary.InitContractsApp();
        // [GIVEN] Multiple Contracts with Usage based Subscription Lines and Usage Data Billing
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");
        ContractTestLibrary.CreateCustomerContract(CustomerContract2, Customer."No.");
        UsageBasedBTestLibrary.CreateUsageDataImport(UsageDataImport, '');

        TestSubscribers.SetTestContext('TestCreateInvoicesForMoreThanOneContractPerImport');
        BindSubscription(TestSubscribers);
        ContractTestLibrary.AssignServiceObjectForItemToCustomerContract(CustomerContract, ServiceObject, false); // ExchangeRateSelectionModalPageHandler,MessageHandler
        ContractTestLibrary.AssignServiceObjectForItemToCustomerContract(CustomerContract2, ServiceObject2, false); // ExchangeRateSelectionModalPageHandler,MessageHandler
        UnbindSubscription(TestSubscribers);

        ServiceCommitment.SetFilter("Subscription Header No.", '%1|%2', ServiceObject."No.", ServiceObject2."No.");
        QuantityOfServiceCommitments := ServiceCommitment.Count();
        ServiceCommitment.FindSet();
        repeat
            CreateUsageDataBillingDummyDataFromServiceCommitment(UsageDataBilling, UsageDataImport."Entry No.", ServiceCommitment);
        until ServiceCommitment.Next() = 0;

        // [WHEN] Creating a billing proposal via Contract or "Recurring Billing"
        ContractTestLibrary.CreateRecurringBillingTemplate(BillingTemplate, '<CM>', '', '', Enum::"Service Partner"::Customer);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);

        // [THEN] A new Billing Line should be created for each Usage Based Subscription Line and Contract with usage data when creating an invoice via "Usage Data Imports"
        BillingLine.Reset();
        Assert.AreEqual(QuantityOfServiceCommitments, BillingLine.Count(), 'A new Billing Line should be created for each Usage Based Service Commitment and Contract with usage data when creating an invoice via "Usage Data Imports"');
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,CreateCustomerBillingDocumentPageHandler')]
    procedure TestCreateInvoicesForMoreThanOneContractPerImportViaUsageDataImports()
    var
        CustomerContract2: Record "Customer Subscription Contract";
        ServiceObject2: Record "Subscription Header";
        TestSubscribers: Codeunit "Usage Based B. Test Subscr.";
        QuantityOfServiceCommitments: Integer;
    begin
        ClearAll();
        ContractTestLibrary.InitContractsApp();
        // [GIVEN] Multiple Contracts with Usage based Subscription Lines and Usage Data Billing
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");
        ContractTestLibrary.CreateCustomerContract(CustomerContract2, Customer."No.");
        UsageBasedBTestLibrary.CreateUsageDataImport(UsageDataImport, '');

        TestSubscribers.SetTestContext('TestCreateInvoicesForMoreThanOneContractPerImport');
        BindSubscription(TestSubscribers);
        ContractTestLibrary.AssignServiceObjectForItemToCustomerContract(CustomerContract, ServiceObject, false); // ExchangeRateSelectionModalPageHandler,MessageHandler
        ContractTestLibrary.AssignServiceObjectForItemToCustomerContract(CustomerContract2, ServiceObject2, false); // ExchangeRateSelectionModalPageHandler,MessageHandler
        UnbindSubscription(TestSubscribers);

        ServiceCommitment.SetFilter("Subscription Header No.", '%1|%2', ServiceObject."No.", ServiceObject2."No.");
        QuantityOfServiceCommitments := ServiceCommitment.Count();
        ServiceCommitment.FindSet();
        repeat
            CreateUsageDataBillingDummyDataFromServiceCommitment(UsageDataBilling, UsageDataImport."Entry No.", ServiceCommitment);
        until ServiceCommitment.Next() = 0;

        // [WHEN] Creating a billing proposal via "Usage Data Imports" (CollectCustomerContractsAndCreateInvoices)
        UsageDataImport.CollectCustomerContractsAndCreateInvoices(UsageDataImport); // CreateCustomerBillingDocumentPageHandler

        // [THEN] A Billing Line should be created for Usage Based Subscription Lines with usage data
        BillingLine.Reset();
        Assert.AreEqual(QuantityOfServiceCommitments, BillingLine.Count(), 'A new Billing Line should be created for each Usage Based Service Commitment and Contract with usage data when creating an invoice via "Usage Data Imports"');
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestCreateUsageDataBilling()
    begin
        Initialize();
        CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2));
        UsageDataImport.FindLast();
        UsageDataImport.TestField("Processing Status", "Processing Status"::Ok);
        UsageDataBilling.FindLast();
        TestUsageDataBilling();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateCustomerBillingDocumentPageHandler,MessageHandler')]
    procedure TestCreateUsageDataBillingDocumentsWhenBillingRequiredInBillingProposal()
    begin
        // Create recurring billing for simple Customer Subscription Contract
        // Set update required
        // Expect no error on create Usage data billing documents
        Initialize();
        CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2));
        PostDocument := false;
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");

        CreateBillingProposalForSimpleCustomerContract();
        ServiceCommitment.Get(BillingLine."Subscription Line Entry No.");
        ServiceCommitment.Validate("Discount %", LibraryRandom.RandDec(50, 2));
        ServiceCommitment.Modify(true);

        UsageDataImport.CollectCustomerContractsAndCreateInvoices(UsageDataImport);
    end;

    [Test]
    procedure TestCreateUsageDataGenericImport()
    begin
        // Create Setup Data and Import file
        Initialize();
        SetupUsageDataForProcessingToGenericImport();
        SetupDataExchangeDefinition();
        // Create Data Exchange definition for processing imported file and Creating Usage Data Generic Import
        UsageBasedBTestLibrary.ConnectDataExchDefinitionToUsageDataGenericSettings(DataExchDef.Code, GenericImportSettings);
        ProcessUsageDataImport(Enum::"Processing Step"::"Create Imported Lines");
        // Expect that Usage Data Generic Import is created
        Commit();
        UsageDataGenericImport.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        UsageDataGenericImport.FindFirst();
        UsageDataGenericImport.TestField("Processing Status", Enum::"Processing Status"::None);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateVendorBillingDocumentPageHandler,MessageHandler')]
    procedure TestCreateVendorContractInvoiceFromUsageDataImport()
    begin
        Initialize();
        CreateUsageDataBilling("Usage Based Pricing"::"Usage Quantity", LibraryRandom.RandDec(10, 2));
        PostDocument := false;
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");
        UsageDataImport.TestField("Processing Status", "Processing Status"::Ok);
        UsageDataImport.CollectVendorContractsAndCreateInvoices(UsageDataImport);
        CheckIfPurchaseDocumentsHaveBeenCreated();
    end;

    [Test]
    [HandlerFunctions('MessageHandler,CreateCustomerBillingDocumentPageHandler')]
    procedure TestDailyServiceCommitmentWithDailyUsageData()
    begin
        ClearAll();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        Item."Unit Price" := 2;
        Item."Unit Cost" := 1;
        Item.Modify(false);

        SetupServiceDataForProcessing(Enum::"Usage Based Pricing"::"Usage Quantity", "Calculation Base Type"::"Item Price", Enum::"Invoicing Via"::Contract,
                                       '1D', '1D', '1Y', "Service Partner"::Customer, 100, Item."No.");

        ProcessUsageDataWithSimpleGenericImport(WorkDate(), WorkDate(), WorkDate(), CalcDate('<CM>', WorkDate()), 1);
        CreateContractInvoicesAndTestProcessedUsageData();
    end;

    [Test]
    [HandlerFunctions('MessageHandler,CreateCustomerBillingDocumentPageHandler')]
    procedure TestDailyServiceCommitmentWithMonthlyUsageData()
    begin
        ClearAll();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        Item."Unit Price" := 2;
        Item."Unit Cost" := 1;
        Item.Modify(false);

        SetupServiceDataForProcessing(Enum::"Usage Based Pricing"::"Usage Quantity", "Calculation Base Type"::"Item Price", Enum::"Invoicing Via"::Contract,
                                       '1D', '1D', '1Y', "Service Partner"::Customer, 100, Item."No.");

        ProcessUsageDataWithSimpleGenericImport(WorkDate(), CalcDate('<CM>', WorkDate()), WorkDate(), CalcDate('<CM>', WorkDate()), 1);
        CreateContractInvoicesAndTestProcessedUsageData();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestDeleteUsageDataBilling()
    begin
        Initialize();
        CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2));
        UsageDataImport.DeleteUsageDataBillingLines();
        Commit(); // retain data after asserterror

        FilterUsageDataBillingOnUsageDataImport(UsageDataImport."Entry No.");
        Assert.RecordIsEmpty(UsageDataBilling);
        Clear(UsageDataGenericImport);
        UsageDataGenericImport.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        Assert.RecordIsEmpty(UsageDataGenericImport);

        UsageDataImport.TestField("Processing Status", "Processing Status"::None);
        UsageDataImport.TestField("Processing Step", "Processing Step"::None);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestIfLastUsedNoRemainsInSalesOrderNos()
    var
        NoSeriesLine: Record "No. Series Line";
        LastUsedNo: Code[20];
    begin
        Initialize();
        SalesSetup.Get();
        NoSeriesLine.SetRange("Series Code", SalesSetup."Order Nos.");
        NoSeriesLine.FindLast();
        LastUsedNo := NoSeriesLine."Last No. Used";

        Currency.InitRoundingPrecision();
        CreateUsageDataBilling("Usage Based Pricing"::"Usage Quantity", LibraryRandom.RandDec(10, 2));
        UsageDataSupplier."Unit Price from Import" := false;
        UsageDataSupplier.Modify(false);
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");

        NoSeriesLine.SetRange("Series Code", SalesSetup."Order Nos.");
        NoSeriesLine.FindLast();
        Assert.AreEqual(LastUsedNo, NoSeriesLine."Last No. Used", 'No Series changed after GetSalesPrice()');
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestIfRelatedDataIsDeletedOnDeleteUsageDataImport()
    begin
        Initialize();
        j := LibraryRandom.RandIntInRange(2, 10);
        for i := 1 to j do
            CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2));

        UsageDataImport.Reset();
        UsageDataImport.FindSet();
        repeat
            UsageDataImport.Delete(true);
            // Commit before asserterror to keep data
            Commit();

            UsageDataBlob.Reset();
            UsageDataBlob.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
            Assert.RecordIsEmpty(UsageDataBlob);

            UsageDataGenericImport.Reset();
            UsageDataGenericImport.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
            Assert.RecordIsEmpty(UsageDataGenericImport);

            FilterUsageDataBillingOnUsageDataImport(UsageDataImport."Entry No.");
            Assert.RecordIsEmpty(UsageDataBilling);
        until UsageDataImport.Next() = 0;
    end;

    [Test]
    procedure TestImportFileToUsageDataBlob()
    begin
        Initialize();
        SetupUsageDataForProcessingToGenericImport();
        UsageDataBlob.TestField("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        UsageDataBlob.TestField("Import Status", Enum::"Processing Status"::Ok);
        UsageDataBlob.TestField(Data);
        UsageDataBlob.TestField("Data Hash Value");
    end;

    [Test]
    [HandlerFunctions('MessageHandler,CreateCustomerBillingDocumentPageHandler')]
    procedure TestMonthlyServiceCommitmentWithDailyUsageData()
    begin
        ClearAll();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        Item."Unit Price" := 2;
        Item."Unit Cost" := 1;
        Item.Modify(false);

        SetupServiceDataForProcessing(Enum::"Usage Based Pricing"::"Usage Quantity", "Calculation Base Type"::"Item Price", Enum::"Invoicing Via"::Contract,
                                       '1M', '1M', '1Y', "Service Partner"::Customer, 100, Item."No.");

        ProcessUsageDataWithSimpleGenericImport(WorkDate(), WorkDate(), WorkDate(), CalcDate('<CM>', WorkDate()), 1);
        CreateContractInvoicesAndTestProcessedUsageData();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateCustomerBillingDocumentPageHandler,MessageHandler')]
    procedure TestOnlyProcessDataWithinBillingPeriod()
    var
        BillingDate1: Date;
        BillingDate2: Date;
        TestBillingDate: Date;
    begin
        Initialize();
        BillingDate1 := WorkDate();
        TestBillingDate := CalcDate('<1M>', WorkDate());
        BillingDate2 := CalcDate('<2M>', WorkDate());
        CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", BillingDate1, CalcDate('<CM>', BillingDate1), BillingDate1, CalcDate('<CM>', BillingDate1), LibraryRandom.RandDec(10, 2));
        PostDocument := true;
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");
        UsageDataImport.CollectCustomerContractsAndCreateInvoices(UsageDataImport);

        CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", BillingDate2, CalcDate('<CM>', BillingDate2), BillingDate2, CalcDate('<CM>', BillingDate2), LibraryRandom.RandDec(10, 2));
        PostDocument := false;
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");
        UsageDataImport.CollectCustomerContractsAndCreateInvoices(UsageDataImport);
        // Expect that month between BillingDate1 and BillingDate2 is skipped
        BillingLine.Reset();
        BillingLine.SetRange(Partner, "Service Partner"::Customer);
        BillingLine.SetRange("Subscription Line Start Date", CalcDate('<CM>', TestBillingDate));
        Assert.RecordIsEmpty(BillingLine);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestPriceCalculationInUsageBasedBasedOnDay()
    var
        ProcessUsageDataBilling: Codeunit "Process Usage Data Billing";
        RoundingPrecision: Decimal;
    begin
        Initialize();
        SetupUsageDataForProcessingToGenericImport(WorkDate(), WorkDate(), WorkDate(), WorkDate(), 1, false);
        SetupDataExchangeDefinition();
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        Item."Unit Price" := 1;
        Item."Unit Cost" := 1;
        Item.Modify(false);
        SetupItemWithMultipleServiceCommitmentPackages();
        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, Item."No.");
        ServiceObject.InsertServiceCommitmentsFromStandardServCommPackages(WorkDate());
        ServiceObject."End-User Customer No." := Customer."No.";
        ServiceObject.Modify(false);
        CreateCustomerContractAndAssignServiceCommitments();
        CreateVendorContractAndAssignServiceCommitments();
        UsageBasedBTestLibrary.ConnectDataExchDefinitionToUsageDataGenericSettings(DataExchDef.Code, GenericImportSettings);

        ProcessUsageDataImport(Enum::"Processing Step"::"Create Imported Lines");
        ProcessUsageDataImport(Enum::"Processing Step"::"Process Imported Lines");

        UsageDataGenericImport.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        UsageDataGenericImport.FindFirst();
        PrepareServiceCommitmentAndUsageDataGenericImportForUsageBilling("Usage Based Pricing"::"Usage Quantity", '1D', '1D');
        Codeunit.Run(Codeunit::"Import And Process Usage Data", UsageDataImport);
        UsageDataImport.SetRecFilter();
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Create Usage Data Billing");
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");

        FilterUsageDataBillingOnUsageDataImport(UsageDataImport."Entry No.");
        UsageDataBilling.FindSet();
        ProcessUsageDataBilling.SetRoundingPrecision(RoundingPrecision, UsageDataBilling."Unit Price", Currency);
        Assert.AreEqual(Round(ServiceCommitment.Price, RoundingPrecision), UsageDataBilling."Unit Price", 'Amount was not calculated properly in Usage data.');
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestProcessUsageDataBilling()
    begin
        Initialize();
        CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2));
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");
        // Test update Subscription and Subscription Line
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestProcessUsageDataBillingWithDiscount100()
    begin
        // [SCENARIO] Setup simple Customer Subscription Contract with Subscription Line marked as Usage based billing
        // Add 100% discount in Subscription Line
        // Processing of Usage data should proceed without an error

        // [GIVEN]: Setup Usage based Subscription Line and assign it to customer; Add Discount of 100% to the Subscription Lines
        Initialize();
        CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2));

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.FindSet();
        repeat
            ServiceCommitment.Validate("Discount %", 100);
            ServiceCommitment.Modify(true);
        until ServiceCommitment.Next() = 0;

        // [WHEN] Expect no error to happen on processing usage data billing
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");

        // [THEN] Test if Processing Status Ok is set in Usage Data Import
        UsageDataImport.TestField("Processing Status", "Processing Status"::Ok);
    end;

    [Test]
    procedure TestProcessUsageDataBillingWithFixedQuantityAndPartialPeriods()
    var
        ProcessUsageDataBilling: Codeunit "Process Usage Data Billing";
        CalculatedAmount: Decimal;
        ExpectedResult: Decimal;
        RoundingPrecision: Decimal;
    begin
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        Item."Unit Price" := LibraryRandom.RandDec(100, 2);
        Item."Unit Cost" := LibraryRandom.RandDec(100, 2);
        Item.Modify(false);

        SetupServiceDataForProcessing(Enum::"Usage Based Pricing"::"Fixed Quantity", "Calculation Base Type"::"Item Price", Enum::"Invoicing Via"::Contract,
                                       '1M', '1M', '1M', "Service Partner"::Customer, 100, Item."No.");

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.SetRange(Partner, "Service Partner"::Customer);
        ServiceCommitment.FindFirst();

        ServiceCommitment.Validate("Subscription Line Start Date", CalcDate('<-CM>', WorkDate()));
        ServiceCommitment.Modify(false);
        ExpectedResult := ServiceCommitment.UnitPriceForPeriod(CalcDate('<-CM>', WorkDate()), WorkDate()) * ServiceObject.Quantity;

        ProcessUsageDataWithSimpleGenericImport(CalcDate('<-CM>', WorkDate()), WorkDate(), CalcDate('<-CM>', WorkDate()), WorkDate(), ServiceObject.Quantity, "Usage Based Pricing"::"Fixed Quantity");

        FilterUsageDataBillingOnUsageDataImport(UsageDataImport."Entry No.", "Service Partner"::Customer);
        UsageDataBilling.CalcSums(Amount);
        CalculatedAmount := UsageDataBilling.Amount;
        UsageDataBilling.FindFirst();

        ProcessUsageDataBilling.SetRoundingPrecision(RoundingPrecision, CalculatedAmount, Currency);
        Assert.AreEqual(Round(ExpectedResult, RoundingPrecision), CalculatedAmount, 'Amount was not calculated properly in Usage data.');
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestProcessUsageDataGenericImport()
    begin
        Initialize();
        SetupUsageDataForProcessingToGenericImport();
        SetupDataExchangeDefinition();
        UsageBasedBTestLibrary.ConnectDataExchDefinitionToUsageDataGenericSettings(DataExchDef.Code, GenericImportSettings);
        ProcessUsageDataImport(Enum::"Processing Step"::"Create Imported Lines");
        UsageDataGenericImport.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        UsageDataGenericImport.FindFirst();

        SetupServiceObjectAndContracts(WorkDate());
        ProcessUsageDataImport(Enum::"Processing Step"::"Process Imported Lines");
        // Process Usage Data Generic Import
        CheckIfUsageDataSubscriptionIsCreated();
        CheckIfUsageDataCustomerIsCreated();
        CheckIfCustomerSupplierReferencesAreIsCreated();
        CheckIfSubscriptionSupplierReferencesAreIsCreated();
        CheckIfProductSupplierReferencesAreIsCreated();
    end;

    [Test]
    procedure TestProratedAmountForDailyPrices()
    var
        BillingBasePeriod: DateFormula;
        ChargeEndDate: Date;
        ChargeStartDate: Date;
        BaseAmount: Decimal;
        ExpectedResult: Decimal;
        Result: Decimal;
    begin
        BaseAmount := 100;
        Evaluate(BillingBasePeriod, '1D');
        ChargeStartDate := CalcDate('<-CY>', WorkDate());
        ChargeEndDate := ChargeStartDate;
        MockServiceCommitment(ServiceCommitment, BillingBasePeriod, BillingBasePeriod, BaseAmount);
        Result := ServiceCommitment.UnitPriceForPeriod(ChargeStartDate, ChargeEndDate);

        ExpectedResult := BaseAmount;
        Assert.AreEqual(Result, ExpectedResult, 'Amount was not calculated properly');
    end;

    [Test]
    procedure TestProratedAmountForMonthlyPrices()
    var
        BillingBasePeriod: DateFormula;
        ChargeEndDate: Date;
        ChargeStartDate: Date;
        BaseAmount: Decimal;
        ExpectedResult: Decimal;
        Result: Decimal;
    begin
        BaseAmount := 100;
        Evaluate(BillingBasePeriod, '1M');
        ChargeStartDate := CalcDate('<-CY>', WorkDate());
        ChargeEndDate := CalcDate('<CY>', ChargeStartDate);
        MockServiceCommitment(ServiceCommitment, BillingBasePeriod, BillingBasePeriod, BaseAmount);
        Result := ServiceCommitment.UnitPriceForPeriod(ChargeStartDate, ChargeEndDate);

        ExpectedResult := BaseAmount * 12;
        Assert.AreEqual(Result, ExpectedResult, 'Amount was not calculated properly');

        ChargeStartDate := CalcDate('<15D>', ChargeStartDate);
        ChargeEndDate := CalcDate('<1M>', ChargeStartDate);
        MockServiceCommitment(ServiceCommitment, BillingBasePeriod, BillingBasePeriod, BaseAmount);
        Result := ServiceCommitment.UnitPriceForPeriod(ChargeStartDate, ChargeEndDate - 1);

        Assert.AreEqual(Result, BaseAmount, 'Amount was not calculated properly');
    end;

    [Test]
    procedure TestProratedAmountForMonthlyPriceWithDailyUsageData()
    var
        BillingBasePeriod: DateFormula;
        ChargeEndDate: Date;
        ChargeStartDate: Date;
        BaseAmount: Decimal;
        ExpectedResult: Decimal;
        Result: Decimal;
        NoOfDaysInMonth1: Integer;
    begin
        BaseAmount := 100;
        Evaluate(BillingBasePeriod, '1M');
        ChargeStartDate := CalcDate('<-CY>', WorkDate());
        ChargeEndDate := ChargeStartDate;
        MockServiceCommitment(ServiceCommitment, BillingBasePeriod, BillingBasePeriod, BaseAmount);
        Result := ServiceCommitment.UnitPriceForPeriod(ChargeStartDate, ChargeEndDate);

        NoOfDaysInMonth1 := CalcDate('<CM>', ChargeEndDate) - ChargeStartDate + 1;
        ExpectedResult := BaseAmount * 1 / NoOfDaysInMonth1;

        Assert.AreEqual(Result, ExpectedResult, 'Amount was not calculated properly');
    end;

    [Test]
    procedure TestProratedAmountForYearlyPrices()
    var
        BillingBasePeriod: DateFormula;
        ChargeEndDate: Date;
        ChargeStartDate: Date;
        BaseAmount: Decimal;
        ExpectedResult: Decimal;
        Result: Decimal;
    begin
        BaseAmount := 100;
        Evaluate(BillingBasePeriod, '12M');
        ChargeStartDate := CalcDate('<-CY>', WorkDate());
        ChargeEndDate := CalcDate('<CY>', ChargeStartDate);
        MockServiceCommitment(ServiceCommitment, BillingBasePeriod, BillingBasePeriod, BaseAmount);
        Result := ServiceCommitment.UnitPriceForPeriod(ChargeStartDate, ChargeEndDate);

        ExpectedResult := BaseAmount;
        Assert.AreEqual(ExpectedResult, Result, 'Amount was not calculated properly');

        Evaluate(BillingBasePeriod, '1Y');
        MockServiceCommitment(ServiceCommitment, BillingBasePeriod, BillingBasePeriod, BaseAmount);
        Result := ServiceCommitment.UnitPriceForPeriod(ChargeStartDate, ChargeEndDate);
        Assert.AreEqual(ExpectedResult, Result, 'Amount was not calculated properly');

        BaseAmount := ChargeEndDate - ChargeStartDate + 1; // Set the Amount to number of days
        ChargeEndDate := ChargeStartDate;
        MockServiceCommitment(ServiceCommitment, BillingBasePeriod, BillingBasePeriod, BaseAmount);
        Result := ServiceCommitment.UnitPriceForPeriod(ChargeStartDate, ChargeEndDate);
        Assert.AreEqual(1, Result, 'Amount was not calculated properly');
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure TestSkipUsageBasedServiceCommitmentsWithoutUsageData()
    begin
        ClearAll();
        ContractTestLibrary.InitContractsApp();

        // [GIVEN] Setup simple Customer Subscription Contract with Subscription Line marked as Usage based billing
        // Try to create a billing proposal with Billing To Date (crucial)
        ContractTestLibrary.CreateMultipleServiceObjectsWithItemSetup(Customer, ServiceObject, Item, 2);
        ContractTestLibrary.UpdateItemUnitCostAndPrice(Item, LibraryRandom.RandDec(1000, 2), LibraryRandom.RandDec(1000, 2), false);

        ContractTestLibrary.CreateServiceCommitmentTemplateSetup(ServiceCommitmentTemplate, '<12M>', Enum::"Invoicing Via"::Contract);
        ContractTestLibrary.CreateServiceCommPackageAndAssignItemToServiceCommitmentSetup(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine, Item, '<12M>');
        ServiceCommPackageLine."Usage Based Billing" := true;
        ServiceCommPackageLine.Modify(false);
        ContractTestLibrary.InsertServiceCommitmentFromServiceCommPackageSetup(ServiceCommitmentPackage, ServiceObject);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, Customer."No.");
        CustomerContract.SetRange("No.", CustomerContract."No.");
        CreateRecurringBillingTemplateSetupForCustomerContract('<2M-CM>', '<8M+CM>', CustomerContract.GetView());

        // [WHEN] Creating a billing proposal
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);

        // [THEN] No Billing Line should be created for Usage Based Subscription Lines without usage data
        BillingLine.Reset();
        Assert.AreEqual(true, BillingLine.IsEmpty, 'No Billing Line should be created for Usage Based Service Commitments without usage data');
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateVendorBillingDocumentPageHandler,MessageHandler')]
    procedure TestUpdateUsageBasedAfterDeletePurchaseHeader()
    begin
        Initialize();
        CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2));
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");
        UsageDataImport.TestField("Processing Status", "Processing Status"::Ok);
        UsageDataImport.CollectVendorContractsAndCreateInvoices(UsageDataImport);
        FilterUsageDataBillingOnUsageDataImport(UsageDataImport."Entry No.");
        UsageDataBilling.MarkPurchaseHeaderFromUsageDataBilling(UsageDataBilling, PurchaseHeader);
        PurchaseHeader.FindSet();
        PurchaseHeader.Delete(true);
        TestIfRelatedUsageDataBillingIsUpdated("Service Partner"::Vendor, Enum::"Usage Based Billing Doc. Type"::None, '', false, 0);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateVendorBillingDocumentPageHandler,MessageHandler')]
    procedure TestUpdateUsageBasedAfterDeletePurchInvHeader()
    var
        PurchaseInvoiceHeader: Record "Purch. Inv. Header";
    begin
        Initialize();
        PurchaseInvoiceHeader.DeleteAll(false);

        CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2));
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");
        UsageDataImport.TestField("Processing Status", "Processing Status"::Ok);
        UsageDataImport.CollectVendorContractsAndCreateInvoices(UsageDataImport);
        PostPurchaseDocuments();

        PurchaseInvoiceHeader.FindLast();
        PurchaseInvoiceHeader."No. Printed" := 1;
        PurchaseInvoiceHeader.Modify(false);

        PurchSetup.Get();
        PurchSetup."Allow Document Deletion Before" := CalcDate('<1D>', WorkDate());
        PurchSetup.Modify(false);

        PurchaseInvoiceHeader.Delete(true);
        TestIfRelatedUsageDataBillingIsUpdated("Service Partner"::Vendor, Enum::"Usage Based Billing Doc. Type"::None, '', false, 0);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateCustomerBillingDocumentPageHandler,MessageHandler')]
    procedure TestUpdateUsageBasedAfterDeleteSalesHeader()
    begin
        Initialize();
        CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2));
        PostDocument := false;
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");
        UsageDataImport.TestField("Processing Status", "Processing Status"::Ok);
        UsageDataImport.CollectCustomerContractsAndCreateInvoices(UsageDataImport);
        BillingLine.FindSet();
        repeat
            SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
            SalesHeader.Delete(true);
            TestIfRelatedUsageDataBillingIsUpdated("Service Partner"::Customer, Enum::"Usage Based Billing Doc. Type"::None, '', false, 0);
        until BillingLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateCustomerBillingDocumentPageHandler,MessageHandler')]
    procedure TestUpdateUsageBasedAfterDeleteSalesInvoiceHeader()
    begin
        Initialize();
        SalesInvoiceHeader.DeleteAll(false);
        CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2));
        PostDocument := true;
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");
        UsageDataImport.TestField("Processing Status", "Processing Status"::Ok);
        UsageDataImport.CollectCustomerContractsAndCreateInvoices(UsageDataImport);
        SalesInvoiceHeader.FindLast();
        SalesInvoiceHeader."No. Printed" := 1;
        SalesInvoiceHeader.Modify(false);

        SalesSetup.Get();
        SalesSetup."Allow Document Deletion Before" := CalcDate('<1D>', WorkDate());
        SalesSetup.Modify(false);
        SalesInvoiceHeader.Delete(true);
        TestIfRelatedUsageDataBillingIsUpdated("Service Partner"::Customer, Enum::"Usage Based Billing Doc. Type"::None, '', false, 0);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateCustomerBillingDocumentPageHandler,MessageHandler')]
    procedure TestUpdateUsageBasedAfterInsertCreditMemo()
    begin
        Initialize();
        CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2));
        PostDocument := true;
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");
        UsageDataImport.TestField("Processing Status", "Processing Status"::Ok);
        UsageDataImport.CollectCustomerContractsAndCreateInvoices(UsageDataImport);
        FilterUsageDataBillingOnUsageDataImport(UsageDataImport."Entry No.", "Service Partner"::Customer, UsageDataBilling."Document Type"::"Posted Invoice");
        UsageDataBilling.FindSet();
        SalesInvoiceHeader.Get(UsageDataBilling."Document No.");
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesCrMemoHeader);

        FilterUsageDataBillingOnUsageDataImport(UsageDataImport."Entry No.", "Service Partner"::Customer);
        Assert.RecordCount(UsageDataBilling, 2); // Expect additional usage data billing for credit memo

        UsageDataBilling.FilterOnDocumentTypeAndDocumentNo(Enum::"Service Partner"::Customer, Enum::"Usage Based Billing Doc. Type"::"Credit Memo", SalesCrMemoHeader."No.");
        UsageDataBilling.FindSet();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateVendorBillingDocumentPageHandler,MessageHandler')]
    procedure TestUpdateUsageBasedAfterInsertPurchaseCreditMemo()
    var
        PurchaseInvoiceHeader: Record "Purch. Inv. Header";
    begin
        Initialize();
        PurchaseInvoiceHeader.DeleteAll(false);

        CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2));
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");
        UsageDataImport.TestField("Processing Status", "Processing Status"::Ok);
        UsageDataImport.CollectVendorContractsAndCreateInvoices(UsageDataImport);
        PostPurchaseDocuments();
        PurchaseInvoiceHeader.FindLast();
        CorrectPostedPurchaseInvoice.CreateCreditMemoCopyDocument(PurchaseInvoiceHeader, PurchaseHeader);

        FilterUsageDataBillingOnUsageDataImport(UsageDataImport."Entry No.", "Service Partner"::Vendor);
        Assert.RecordCount(UsageDataBilling, 2); // Expect additional usage data billing for credit memo and one without document type and document no

        UsageDataBilling.FilterOnDocumentTypeAndDocumentNo(Enum::"Service Partner"::Vendor, Enum::"Usage Based Billing Doc. Type"::"Credit Memo", PurchaseHeader."No.");
        UsageDataBilling.FindSet();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateCustomerBillingDocumentPageHandler,MessageHandler')]
    procedure TestUpdateUsageBasedAfterInsertSalesCreditMemo()
    begin
        Initialize();
        CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2));
        PostDocument := true;
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");
        UsageDataImport.TestField("Processing Status", "Processing Status"::Ok);
        UsageDataImport.CollectCustomerContractsAndCreateInvoices(UsageDataImport);

        FilterUsageDataBillingOnUsageDataImport(UsageDataImport."Entry No.", "Service Partner"::Customer, UsageDataBilling."Document Type"::"Posted Invoice");
        UsageDataBilling.FindSet();
        SalesInvoiceHeader.Get(UsageDataBilling."Document No.");
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesCrMemoHeader);

        FilterUsageDataBillingOnUsageDataImport(UsageDataImport."Entry No.", "Service Partner"::Customer);
        Assert.RecordCount(UsageDataBilling, 2); // Expect additional usage data billing for credit memo and one without document type and document no

        UsageDataBilling.FilterOnDocumentTypeAndDocumentNo(Enum::"Service Partner"::Customer, Enum::"Usage Based Billing Doc. Type"::"Credit Memo", SalesCrMemoHeader."No.");
        UsageDataBilling.FindSet();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateCustomerBillingDocumentPageHandler,MessageHandler')]
    procedure TestUpdateUsageBasedAfterPostCreditMemo()
    begin
        Initialize();
        CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2));
        PostDocument := true;
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");
        UsageDataImport.TestField("Processing Status", "Processing Status"::Ok);
        UsageDataImport.CollectCustomerContractsAndCreateInvoices(UsageDataImport);
        FilterUsageDataBillingOnUsageDataImport(UsageDataImport."Entry No.", "Service Partner"::Customer, UsageDataBilling."Document Type"::"Posted Invoice");
        UsageDataBilling.FindSet();

        SalesInvoiceHeader.Get(UsageDataBilling."Document No.");
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesCrMemoHeader);
        CorrectedDocumentNo := LibrarySales.PostSalesDocument(SalesCrMemoHeader, true, true);

        FilterUsageDataBillingOnUsageDataImport(UsageDataImport."Entry No.", "Service Partner"::Customer);
        Assert.RecordCount(UsageDataBilling, 3); // Expect additional usage data billing for credit memo and one without document type and document no

        UsageDataBilling.FilterOnDocumentTypeAndDocumentNo(Enum::"Service Partner"::Customer, Enum::"Usage Based Billing Doc. Type"::"Posted Credit Memo", CorrectedDocumentNo);
        UsageDataBilling.FindSet();

        UsageDataBilling.FilterOnDocumentTypeAndDocumentNo(Enum::"Service Partner"::Customer, Enum::"Usage Based Billing Doc. Type"::None, '');
        UsageDataBilling.FindSet();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateVendorBillingDocumentPageHandler,MessageHandler')]
    procedure TestUpdateUsageBasedAfterPostPurchaseCreditMemo()
    var
        PurchaseInvoiceHeader: Record "Purch. Inv. Header";
    begin
        Initialize();
        PurchaseInvoiceHeader.DeleteAll(false);

        CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2));
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");
        UsageDataImport.TestField("Processing Status", "Processing Status"::Ok);
        UsageDataImport.CollectVendorContractsAndCreateInvoices(UsageDataImport);
        PostPurchaseDocuments();
        PurchaseInvoiceHeader.FindLast();
        CorrectPostedPurchaseInvoice.CreateCreditMemoCopyDocument(PurchaseInvoiceHeader, PurchaseHeader);
        PurchaseHeader."Vendor Cr. Memo No." := LibraryUtility.GenerateGUID();
        PurchaseHeader.Modify(false);
        CorrectedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        FilterUsageDataBillingOnUsageDataImport(UsageDataImport."Entry No.", "Service Partner"::Vendor);
        Assert.RecordCount(UsageDataBilling, 3); // Expect additional usage data billing for credit memo and one without document type and document no

        UsageDataBilling.FilterOnDocumentTypeAndDocumentNo(Enum::"Service Partner"::Vendor, Enum::"Usage Based Billing Doc. Type"::"Posted Credit Memo", CorrectedDocumentNo);
        UsageDataBilling.FindSet();

        UsageDataBilling.FilterOnDocumentTypeAndDocumentNo(Enum::"Service Partner"::Vendor, Enum::"Usage Based Billing Doc. Type"::None, '');
        UsageDataBilling.FindSet();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateVendorBillingDocumentPageHandler,MessageHandler')]
    procedure TestUpdateUsageBasedAfterPostPurchaseHeader()
    var
        PurchaseInvoiceHeader: Record "Purch. Inv. Header";
    begin
        Initialize();
        PurchaseInvoiceHeader.DeleteAll(false);
        CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2));
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");
        UsageDataImport.TestField("Processing Status", "Processing Status"::Ok);
        UsageDataImport.CollectVendorContractsAndCreateInvoices(UsageDataImport);

        PostPurchaseDocuments();
        PurchaseInvoiceHeader.FindLast();
        TestIfRelatedUsageDataBillingIsUpdated("Service Partner"::Vendor, Enum::"Usage Based Billing Doc. Type"::"Posted Invoice", PurchaseInvoiceHeader."No.", true, 0);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateCustomerBillingDocumentPageHandler,MessageHandler')]
    procedure TestUpdateUsageBasedAfterPostSalesCreditMemo()
    begin
        Initialize();
        CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2));
        PostDocument := true;
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");
        UsageDataImport.TestField("Processing Status", "Processing Status"::Ok);
        UsageDataImport.CollectCustomerContractsAndCreateInvoices(UsageDataImport);
        FilterUsageDataBillingOnUsageDataImport(UsageDataImport."Entry No.", "Service Partner"::Customer, UsageDataBilling."Document Type"::"Posted Invoice");
        UsageDataBilling.FindSet();

        SalesInvoiceHeader.Get(UsageDataBilling."Document No.");
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesCrMemoHeader);
        CorrectedDocumentNo := LibrarySales.PostSalesDocument(SalesCrMemoHeader, true, true);

        FilterUsageDataBillingOnUsageDataImport(UsageDataImport."Entry No.", "Service Partner"::Customer);
        Assert.RecordCount(UsageDataBilling, 3); // Expect additional usage data billing for credit memo and one without document type and document no

        UsageDataBilling.FilterOnDocumentTypeAndDocumentNo(Enum::"Service Partner"::Customer, Enum::"Usage Based Billing Doc. Type"::"Posted Credit Memo", CorrectedDocumentNo);
        UsageDataBilling.FindSet();

        UsageDataBilling.FilterOnDocumentTypeAndDocumentNo(Enum::"Service Partner"::Customer, Enum::"Usage Based Billing Doc. Type"::None, '');
        UsageDataBilling.FindSet();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateCustomerBillingDocumentPageHandler,MessageHandler')]
    procedure TestUpdateUsageBasedAfterPostSalesHeader()
    begin
        Initialize();
        SalesInvoiceHeader.DeleteAll(false);
        CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2));
        PostDocument := true;
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");
        UsageDataImport.TestField("Processing Status", "Processing Status"::Ok);
        UsageDataImport.CollectCustomerContractsAndCreateInvoices(UsageDataImport);
        SalesInvoiceHeader.FindLast();
        TestIfRelatedUsageDataBillingIsUpdated("Service Partner"::Customer, "Usage Based Billing Doc. Type"::"Posted Invoice", SalesInvoiceHeader."No.", true, 0);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,CreateCustomerBillingDocumentPageHandler')]
    procedure TestYearlyServiceCommitmentWithDailyUsageData()
    var
        UsageDataBilling2: Record "Usage Data Billing";
    begin
        ClearAll();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        //In order to avoid rounding issues, set the Unit price to number of days in the period; This way Daily price will always be 1
        Item."Unit Price" := CalcDate('<1Y>', WorkDate()) - WorkDate();
        Item."Unit Cost" := 1;
        Item.Modify(false);

        SetupServiceDataForProcessing(Enum::"Usage Based Pricing"::"Usage Quantity", "Calculation Base Type"::"Item Price", Enum::"Invoicing Via"::Contract,
                                       '1Y', '1Y', '1Y', "Service Partner"::Customer, 100, Item."No.");

        ProcessUsageDataWithSimpleGenericImport(WorkDate(), WorkDate(), WorkDate(), WorkDate(), 1);
        UsageDataBilling2.Reset();
        UsageDataBilling2.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        UsageDataBilling2.SetRange(Partner, "Service Partner"::Customer);
        if UsageDataBilling2.FindSet() then
            repeat
                UsageDataBilling2.TestField("Unit Price", UsageDataBilling2."Charged Period (Days)");
            until UsageDataBilling2.Next() = 0;
        CreateContractInvoicesAndTestProcessedUsageData();
    end;

    [Test]
    [HandlerFunctions('MessageHandler,CreateCustomerBillingDocumentPageHandler')]
    procedure TestYearlyServiceCommitmentWithMonthlyUsageData()
    var
        UsageDataBilling2: Record "Usage Data Billing";
    begin
        ClearAll();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        //In order to avoid rounding issues, set the Unit price to number of days in the period; This way Daily price will always be 1
        Item."Unit Price" := CalcDate('<1Y>', WorkDate()) - WorkDate();
        Item."Unit Cost" := 1;
        Item.Modify(false);

        SetupServiceDataForProcessing(Enum::"Usage Based Pricing"::"Usage Quantity", "Calculation Base Type"::"Item Price", Enum::"Invoicing Via"::Contract,
                                       '1Y', '1Y', '1Y', "Service Partner"::Customer, 100, Item."No.");

        ProcessUsageDataWithSimpleGenericImport(WorkDate(), CalcDate('<CM>', WorkDate()), WorkDate(), CalcDate('<CM>', WorkDate()), 1);
        UsageDataBilling2.Reset();
        UsageDataBilling2.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        UsageDataBilling2.SetRange(Partner, "Service Partner"::Customer);
        if UsageDataBilling2.FindSet() then
            repeat
                UsageDataBilling2.TestField("Unit Price", UsageDataBilling2."Charged Period (Days)");
            until UsageDataBilling2.Next() = 0;
        CreateContractInvoicesAndTestProcessedUsageData();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure UpdatingServiceObjectAvailabilityDuringProcessing()
    var
        ItemReference: Record "Item Reference";
    begin
        // [SCENARIO]: The Subscription Availability should be properly updated after processing imported lines
        // When there is no available Subscription to be connected to the imported line status should be "Not Available"
        // When there is available Subscription to be connected to the imported line status should be "Available"
        // When a Subscription is connected to the imported line status should be "Connected"

        // [GIVEN]: Setup Generic Connector and import lines from a file
        Initialize();
        SetupUsageDataForProcessingToGenericImport();
        ContractTestLibrary.CreateVendor(Vendor);
        UsageDataSupplier.Validate("Vendor No.", Vendor."No.");
        UsageDataSupplier.Modify(false);
        SetupDataExchangeDefinition();
        UsageBasedBTestLibrary.ConnectDataExchDefinitionToUsageDataGenericSettings(DataExchDef.Code, GenericImportSettings);
        SetupServiceObjectAndContracts(WorkDate());
        ProcessUsageDataImport(Enum::"Processing Step"::"Create Imported Lines");

        // [WHEN]: process imported lines
        ProcessUsageDataImport(Enum::"Processing Step"::"Process Imported Lines");

        // [THEN]: Test if Subscription Availability is set to "Not Available"
        ValidateUsageDataGenericImportAvailability(UsageDataImport."Entry No.", "Service Object Availability"::"Not Available", '');

        // [WHEN]: insert an item reference to a usage data supplier reference
        UsageDataSubscription.FindForSupplierReference(UsageDataImport."Supplier No.", UsageDataGenericImport."Supp. Subscription ID");
        UsageDataSupplierReference.FindSupplierReference(UsageDataImport."Supplier No.", UsageDataSubscription."Product ID", Enum::"Usage Data Reference Type"::Product);
        LibraryItemReference.CreateItemReference(ItemReference, Item."No.", "Item Reference Type"::Vendor, UsageDataSupplier."Vendor No.");
        ItemReference."Supplier Ref. Entry No." := UsageDataSupplierReference."Entry No.";
        ItemReference.Modify(false);
        ProcessUsageDataImport(Enum::"Processing Step"::"Process Imported Lines");

        // [THEN]: Test if Subscription Availability is set to "Available"
        ValidateUsageDataGenericImportAvailability(UsageDataImport."Entry No.", "Service Object Availability"::Available, '');

        // [WHEN]: insert an subscription reference is set for Subscription Line
        UsageDataSupplierReference.FindSupplierReference(UsageDataImport."Supplier No.", UsageDataGenericImport."Supp. Subscription ID", Enum::"Usage Data Reference Type"::Subscription);
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Vendor);
        ServiceCommitment.FindFirst();
        ServiceCommitment."Supplier Reference Entry No." := UsageDataSupplierReference."Entry No.";
        ServiceCommitment.Modify(false);
        ProcessUsageDataImport(Enum::"Processing Step"::"Process Imported Lines");

        // [THEN]: Test if Subscription Availability is set to "Connected"
        ValidateUsageDataGenericImportAvailability(UsageDataImport."Entry No.", "Service Object Availability"::Connected, ServiceObject."No.");
    end;

    [Test]
    procedure UT_ValidateBillingLineNoRelation()
    var
        BillingLines: array[4] of Record "Billing Line";
        BillingLinesArchive: array[4] of Record "Billing Line Archive";
        UsageDataBillings: array[4, 2] of Record "Usage Data Billing";
    begin
        // [SCENARIO] Validate Billing Line No. table relation in Usage Data Billings

        // [GIVEN] Create Billing Lines and Billing Lines Archive, Create Usage Data from Billing Lines and Billing Lines Archive
        ResetAll();
        MockBillingLine(BillingLines[1], "Service Partner"::Customer, "Rec. Billing Document Type"::Invoice);
        MockBillingLine(BillingLines[2], "Service Partner"::Customer, "Rec. Billing Document Type"::"Credit Memo");
        MockBillingLine(BillingLines[3], "Service Partner"::Vendor, "Rec. Billing Document Type"::Invoice);
        MockBillingLine(BillingLines[4], "Service Partner"::Vendor, "Rec. Billing Document Type"::"Credit Memo");
        MockBillingLineArchive(BillingLinesArchive[1], "Service Partner"::Customer, "Rec. Billing Document Type"::Invoice);
        MockBillingLineArchive(BillingLinesArchive[2], "Service Partner"::Customer, "Rec. Billing Document Type"::"Credit Memo");
        MockBillingLineArchive(BillingLinesArchive[3], "Service Partner"::Vendor, "Rec. Billing Document Type"::Invoice);
        MockBillingLineArchive(BillingLinesArchive[4], "Service Partner"::Vendor, "Rec. Billing Document Type"::"Credit Memo");

        for i := 1 to ArrayLen(BillingLines) do begin
            MockUsageData(UsageDataBillings[i, 1], BillingLines[i].Partner, ConvertDocumentType(BillingLines[i]."Document Type"), BillingLines[i]."Document No.");

            if i mod 2 = 1 then
                MockUsageData(UsageDataBillings[i, 2], BillingLinesArchive[i].Partner, "Usage Based Billing Doc. Type"::"Posted Invoice", BillingLinesArchive[i]."Document No.")
            else
                MockUsageData(UsageDataBillings[i, 2], BillingLinesArchive[i].Partner, "Usage Based Billing Doc. Type"::"Posted Credit Memo", BillingLinesArchive[i]."Document No.");
        end;

        // [WHEN] Validate Billing Line No. in Usage Data Billings
        for i := 1 to ArrayLen(BillingLines) do begin
            UsageDataBillings[i, 1].Validate("Billing Line Entry No.", BillingLines[i]."Entry No.");
            UsageDataBillings[i, 2].Validate("Billing Line Entry No.", BillingLinesArchive[i]."Entry No.");
        end;

        // [THEN] Billing Line No. has been validated
        for i := 1 to ArrayLen(BillingLines) do begin
            Assert.AreEqual(BillingLines[i]."Entry No.", UsageDataBillings[i, 1]."Billing Line Entry No.", 'Billig Line No. has not been validated');
            Assert.AreEqual(BillingLinesArchive[i]."Entry No.", UsageDataBillings[i, 2]."Billing Line Entry No.", 'Billig Line No. has not been validated');
        end;
    end;

    [Test]
    [HandlerFunctions('UsageDataBillingsModalPageHandler')]
    procedure VerifyFilteringOfUsageDataBilling()
    var
        BillingLines: array[2] of Record "Billing Line";
        UsageDataBillings: array[2] of Record "Usage Data Billing";
    begin
        // [SCENARIO] Verify filtering of Usage Data Billings when a Document No. is either assigned or not to the lines

        // [GIVEN] Create 2 Billing Lines and Usage Data Billings
        ResetAll();
        UsageBasedBTestLibrary.MockBillingLineWithServObjectNo(BillingLines[1]);
        UsageBasedBTestLibrary.MockBillingLine(BillingLines[2]);
        BillingLines[2]."Subscription Header No." := BillingLines[1]."Subscription Header No.";
        BillingLines[2]."Subscription Line Entry No." := BillingLines[1]."Subscription Line Entry No.";
        UsageBasedBTestLibrary.CreateSalesInvoiceAndAssignToBillingLine(BillingLines[1]);
        UsageBasedBTestLibrary.MockUsageDataForBillingLine(UsageDataBillings[1], BillingLines[1]);
        UsageBasedBTestLibrary.MockUsageDataForBillingLine(UsageDataBillings[2], BillingLines[2]);

        // [WHEN] Billing line with assigned Document No. is selected
        UsageDataBillings[1].ShowForRecurringBilling(BillingLines[1]."Subscription Header No.", BillingLines[1]."Subscription Line Entry No.", BillingLines[1]."Document Type", BillingLines[1]."Document No."); // UsageDataBillingsModalPageHandler

        // [THEN] Usage Data Billing is filtered and only one record is visible
        Assert.IsTrue(LibraryVariableStorage.DequeueBoolean(), 'Usage Data Billing is not found, but should be.');
        Assert.IsFalse(LibraryVariableStorage.DequeueBoolean(), 'Usage Data Billing is found, but should not be');

        // [WHEN] Billing line without Document No. is selected
        UsageDataBillings[2].ShowForRecurringBilling(BillingLines[2]."Subscription Header No.", BillingLines[2]."Subscription Line Entry No.", BillingLines[2]."Document Type", BillingLines[2]."Document No."); // UsageDataBillingsModalPageHandler

        // [THEN] Usage Data Billing is filtered and only one record is visible
        Assert.IsTrue(LibraryVariableStorage.DequeueBoolean(), 'Usage Data Billing is not found, but should be.');
        Assert.IsFalse(LibraryVariableStorage.DequeueBoolean(), 'Usage Data Billing is found, but should not be');
    end;

    [Test]
    [HandlerFunctions('MessageHandler,CreateCustomerBillingDocumentPageHandler')]
    procedure TestUsageDataImportWithMultipleUsageDataGenericImports()
    var
        UBBTestLibrary: Codeunit "Usage Based B. Test Library";
        BillingPeriodStartDate: Date;
        SubscriptionStartDate: Date;
        SubscriptionID: Text;
        ExpectedAmount: Decimal;
    begin
        // [SCENARIO] Verify that usage data import with multiple usage data generic imports creates correct billing and invoices

        // [GIVEN] Initialize the contracts and usage-based billing applications
        ContractTestLibrary.InitContractsApp();

        // [GIVEN] Create a Subscription Item
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        Item."Unit Price" := LibraryRandom.RandDec(1000, 2);
        Item."Unit Cost" := LibraryRandom.RandDec(1000, 2);
        Item.Modify(false);

        // [GIVEN] Setup Subscription with Subscription Lines and usage quantity
        SetupServiceDataForProcessing(Enum::"Usage Based Pricing"::"Usage Quantity", Enum::"Calculation Base Type"::"Item Price", Enum::"Invoicing Via"::Contract,
                                       '1M', '1M', '1M', "Service Partner"::Customer, 100, Item."No.");

        // [WHEN] Create and process simple usage data
        UBBTestLibrary.CreateUsageDataSupplier(UsageDataSupplier, Enum::"Usage Data Supplier Type"::Generic, false, Enum::"Vendor Invoice Per"::Import);
        UBBTestLibrary.CreateGenericImportSettings(GenericImportSettings, UsageDataSupplier."No.", true, true);
        UBBTestLibrary.CreateUsageDataImport(UsageDataImport, UsageDataSupplier."No.");
        BillingPeriodStartDate := CalcDate('<-CM>', WorkDate());
        SubscriptionStartDate := CalcDate('<-CM>', WorkDate());
        SubscriptionID := LibraryRandom.RandText(80);
        for i := 1 to LibraryRandom.RandInt(10) do begin
            UBBTestLibrary.CreateSimpleUsageDataGenericImport(UsageDataGenericImport, UsageDataImport."Entry No.", ServiceObject."No.", Customer."No.", Item."Unit Cost",
             BillingPeriodStartDate, CalcDate('<CM>', BillingPeriodStartDate), SubscriptionStartDate, CalcDate('<CM>', SubscriptionStartDate), LibraryRandom.RandInt(10));

            UsageDataGenericImport."Supp. Subscription ID" := SubscriptionID;
            UsageDataGenericImport.Modify();
            BillingPeriodStartDate := CalcDate('<1M>', BillingPeriodStartDate);
            SubscriptionStartDate := CalcDate('<1M>', SubscriptionStartDate);
        end;
        ProcessUsageDataImport(Enum::"Processing Step"::"Process Imported Lines");

        // [WHEN] Prepare Subscription Line and usage data generic import for usage billing
        UsageDataGenericImport.Reset();
        UsageDataGenericImport.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        UsageDataGenericImport.FindFirst();
        repeat
            PrepareServiceCommitmentAndUsageDataGenericImportForUsageBilling(Enum::"Usage Based Pricing"::"Usage Quantity", '1M', '1M', Calcdate('<-CM>', WorkDate()));
        until UsageDataGenericImport.Next() = 0;
        Codeunit.Run(Codeunit::"Import And Process Usage Data", UsageDataImport);

        // [WHEN] Process usage data import to create and process usage data billing
        UsageDataImport.SetRecFilter();
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Create Usage Data Billing");
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");

        // [WHEN] Create contract invoice from usage data
        UsageDataImport.CollectCustomerContractsAndCreateInvoices(UsageDataImport);

        // [THEN] Verify that Line Amount in the Invoice equals the sum of all Usage Billing Data Amounts
        UsageDataBilling.Reset();
        UsageDataBilling.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        UsageDataBilling.SetRange(Partner, "Service Partner"::Customer);
        UsageDataBilling.CalcSums(Amount);
        ExpectedAmount := UsageDataBilling.Amount;
        UsageDataBilling.FindLast();

        SalesLine.SetRange("Document Type", "Sales Document Type"::Invoice);
        SalesLine.SetRange("Document No.", UsageDataBilling."Document No.");
        SalesLine.SetRange("Line No.", UsageDataBilling."Document Line No.");
        SalesLine.FindFirst();
        Assert.AreEqual(ExpectedAmount, SalesLine.Amount, 'Line Amount in the Invoice should be equal to the sum of all Usage Billing Data Amounts');
        Assert.AreEqual(UsageDataBilling.Quantity, SalesLine.Quantity, 'Quantity in the Invoice should be equal to the Quantity of Last Usage Billing Data');

        // [THEN] Verify that each Billing line corresponds to each Usage Data Billing
        BillingLine.Reset();
        BillingLine.SetRange("Document No.", UsageDataBilling."Document No.");
        BillingLine.FindFirst();
        repeat
            UsageDataBilling.SetRange("Document No.", BillingLine."Document No.");
            UsageDataBilling.SetRange("Charge Start Date", BillingLine."Billing from");
            UsageDataBilling.SetRange("Charge End Date", BillingLine."Billing to");
            UsageDataBilling.FindFirst();
            Assert.AreEqual(BillingLine.Amount, UsageDataBilling.Amount, 'Billing Line Amount should be equal to Usage Data Billing Amount');
            Assert.AreEqual(BillingLine."Service Object Quantity", UsageDataBilling.Quantity, 'Billing Line Quantity should be equal to Usage Data Billing Quantity');
        until BillingLine.Next() = 0;
    end;
    #endregion Tests

    #region Procedures

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Usage Based Billing Test");
        ResetAll();

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Usage Based Billing Test");
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        LibraryERMCountryData.UpdateSalesReceivablesSetup();
        LibraryERMCountryData.UpdateGeneralLedgerSetup();
        LibraryERMCountryData.UpdateJournalTemplMandatory(false);
        ContractTestLibrary.InitSourceCodeSetup();
        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Usage Based Billing Test");
    end;

    local procedure ResetAll()
    begin
        ClearAll();
        UsageBasedBTestLibrary.DeleteAllUsageBasedRecords();
        BillingLine.Reset();
        BillingLine.DeleteAll(false);
    end;

    local procedure CheckIfCustomerSupplierReferencesAreIsCreated()
    begin
        UsageDataSupplierReference.FilterUsageDataSupplierReference(UsageDataImport."Supplier No.", UsageDataGenericImport."Customer ID", Enum::"Usage Data Reference Type"::Customer);
        UsageDataSupplierReference.FindFirst();
    end;

    local procedure CheckIfProductSupplierReferencesAreIsCreated()
    begin
        UsageDataSupplierReference.FilterUsageDataSupplierReference(UsageDataImport."Supplier No.", UsageDataGenericImport."Product ID", Enum::"Usage Data Reference Type"::Product);
        UsageDataSupplierReference.FindFirst();
    end;

    local procedure CheckIfPurchaseDocumentsHaveBeenCreated()
    begin
        if BillingLine.FindSet() then
            repeat
                BillingLine.TestField("Document Type", Enum::"Rec. Billing Document Type"::Invoice);
                BillingLine.TestField("Document No.");
                ServiceCommitment.Get(BillingLine."Subscription Line Entry No.");
                ServiceCommitment.TestField("Usage Based Billing");
                ServiceCommitment.TestField("Supplier Reference Entry No.");

                PurchaseHeader.Get(Enum::"Purchase Document Type"::Invoice, BillingLine."Document No.");
                PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
                PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
                PurchaseLine.SetFilter("Recurring Billing from", '>=%1', BillingLine."Billing from");
                PurchaseLine.SetFilter("Recurring Billing to", '<=%1', BillingLine."Billing to");
                Assert.RecordCount(PurchaseLine, 1);
                TestIfRelatedUsageDataBillingIsUpdated("Service Partner"::Vendor, UsageBasedDocTypeConverter.ConvertPurchaseDocTypeToUsageBasedBillingDocType(PurchaseHeader."Document Type"), PurchaseHeader."No.", true, BillingLine."Entry No.");
                PurchaseLine.FindFirst();
                TestIfInvoicesMatchesUsageData("Service Partner"::Vendor, PurchaseLine."Line Amount", PurchaseLine."Document No.");
            until BillingLine.Next() = 0;
    end;

    local procedure CheckIfSalesDocumentsHaveBeenCreated()
    begin
        BillingLine.FindSet();
        repeat
            BillingLine.TestField("Document Type", Enum::"Rec. Billing Document Type"::Invoice);
            BillingLine.TestField("Document No.");
            ServiceCommitment.Get(BillingLine."Subscription Line Entry No.");
            ServiceCommitment.TestField("Usage Based Billing");
            ServiceCommitment.TestField("Supplier Reference Entry No.");

            SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            SalesLine.SetFilter("Recurring Billing from", '>=%1', BillingLine."Billing from");
            SalesLine.SetFilter("Recurring Billing to", '<=%1', BillingLine."Billing to");
            Assert.RecordCount(SalesLine, 1);
            TestIfRelatedUsageDataBillingIsUpdated("Service Partner"::Customer, UsageBasedDocTypeConverter.ConvertSalesDocTypeToUsageBasedBillingDocType(SalesHeader."Document Type"), SalesHeader."No.", true, BillingLine."Entry No.");
            SalesLine.FindFirst();
            TestIfInvoicesMatchesUsageData("Service Partner"::Customer, SalesLine."Line Amount", SalesLine."Document No.");
        until BillingLine.Next() = 0;
    end;

    local procedure TestIfInvoicesMatchesUsageData(ServicePartner: Enum "Service Partner"; InvoiceAmount: Decimal; DocumentNo: Code[20])
    begin
        UsageDataBilling.Reset();
        UsageDataBilling.FilterOnDocumentTypeAndDocumentNo(ServicePartner, Enum::"Usage Based Billing Doc. Type"::"Invoice", DocumentNo);
        UsageDataBilling.CalcSums(Amount, "Cost Amount");
        case ServicePartner of
            ServicePartner::Customer:
                Assert.AreEqual(UsageDataBilling.Amount, InvoiceAmount, 'The Sales Invoice lines were not created properly.');
            ServicePartner::Vendor:
                Assert.AreEqual(UsageDataBilling."Cost Amount", InvoiceAmount, 'The Purchase Invoice lines were not created properly.');
        end;
    end;

    local procedure CheckIfServiceCommitmentRemains()
    begin
        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Subscription Header No.", UsageDataBilling."Subscription Header No.");
        ServiceCommitment.SetRange("Entry No.", UsageDataBilling."Subscription Line Entry No.");
        ServiceCommitment.FindSet();
        repeat
            if ServiceCommitment.Partner = "Service Partner"::Customer then
                ServiceCommitment.TestField(Price, Item."Unit Price")
            else
                ServiceCommitment.TestField(Price, Item."Unit Cost");
        until ServiceCommitment.Next() = 0;
    end;

    local procedure CheckIfSubscriptionSupplierReferencesAreIsCreated()
    begin
        UsageDataSupplierReference.FilterUsageDataSupplierReference(UsageDataImport."Supplier No.", UsageDataGenericImport."Supp. Subscription ID", Enum::"Usage Data Reference Type"::Subscription);
        UsageDataSupplierReference.FindFirst();
    end;

    local procedure CheckIfUsageDataCustomerIsCreated()
    begin
        UsageDataCustomer.SetRange("Supplier No.", UsageDataImport."Supplier No.");
        UsageDataCustomer.SetRange("Supplier Reference", UsageDataGenericImport."Customer ID");
        UsageDataCustomer.FindFirst();
    end;

    local procedure CheckIfUsageDataSubscriptionIsCreated()
    begin
        UsageDataSubscription.FindForSupplierReference(UsageDataImport."Supplier No.", UsageDataGenericImport."Supp. Subscription ID");
        UsageDataSubscription.TestField("Customer ID", UsageDataGenericImport."Customer ID");
        UsageDataSubscription.TestField("Product ID", UsageDataGenericImport."Product ID");
        UsageDataSubscription.TestField("Product Name", UsageDataGenericImport."Product Name");
        UsageDataSubscription.TestField("Unit Type", UsageDataGenericImport.Unit);
        UsageDataSubscription.TestField(Quantity, UsageDataGenericImport.Quantity);
        UsageDataSubscription.TestField("Start Date", UsageDataGenericImport."Supp. Subscription Start Date");
        UsageDataSubscription.TestField("End Date", UsageDataGenericImport."Supp. Subscription End Date");
    end;

    local procedure ConvertDocumentType(DocumentType: Enum "Rec. Billing Document Type"): Enum "Usage Based Billing Doc. Type"
    begin
        UsageBasedDocTypeConverter.ConvertRecurringBillingDocTypeToUsageBasedBillingDocType(DocumentType);
    end;

    local procedure CreateBillingProposalForSimpleCustomerContract()
    begin
        ContractTestLibrary.InitContractsApp();
        CustomerContract.SetRange("No.", CustomerContract."No.");
        ContractTestLibrary.CreateRecurringBillingTemplate(BillingTemplate, '<2M-CM>', '<8M+CM>', CustomerContract.GetView(), Enum::"Service Partner"::Customer);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
        BillingLine.Reset();
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.FindLast();
    end;

    local procedure CreateContractInvoicesAndTestProcessedUsageData()
    var
        ExpectedInvoiceAmount: Decimal;
    begin
        FilterUsageDataBillingOnUsageDataImport(UsageDataImport."Entry No.", "Service Partner"::Customer);
        UsageDataBilling.CalcSums(Amount);
        ExpectedInvoiceAmount := UsageDataBilling.Amount;
        UsageDataImport.CollectCustomerContractsAndCreateInvoices(UsageDataImport);

        Currency.InitRoundingPrecision();
        UsageDataBilling.FindFirst();

        CheckIfServiceCommitmentRemains();

        BillingLine.FilterBillingLineOnContractLine(UsageDataBilling.Partner, UsageDataBilling."Subscription Contract No.", UsageDataBilling."Subscription Contract Line No.");
        BillingLine.CalcSums(Amount);
        Assert.AreEqual(Round(BillingLine.Amount, Currency."Unit-Amount Rounding Precision"), ExpectedInvoiceAmount, 'Billing lines where not created properly');
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

    local procedure CreateRecurringBillingTemplateSetupForCustomerContract(DateFormula1Txt: Text; DateFormula2Txt: Text; FilterText: Text)
    begin
        ContractTestLibrary.CreateRecurringBillingTemplate(BillingTemplate, DateFormula1Txt, DateFormula2Txt, FilterText, Enum::"Service Partner"::Customer);
    end;

    local procedure CreateServiceObjectWithServiceCommitments(CustomerNo: Code[20]; ServiceAndCalculationStartDate: Date)
    begin
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        Item."Unit Price" := LibraryRandom.RandDec(1000, 2);
        Item."Unit Cost" := LibraryRandom.RandDec(1000, 2);
        Item.Modify(false);
        SetupItemWithMultipleServiceCommitmentPackages();
        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, Item."No.");
        ServiceObject.InsertServiceCommitmentsFromStandardServCommPackages(ServiceAndCalculationStartDate);
        ServiceObject."End-User Customer No." := CustomerNo;
        ServiceObject.Modify(false);
    end;

    local procedure CreateUsageDataBilling(UsageBasedPricing: Enum "Usage Based Pricing"; Quantity: Decimal)
    begin
        CreateUsageDataBilling(UsageBasedPricing, WorkDate(), CalcDate('<CM>', WorkDate()), WorkDate(), CalcDate('<CM>', WorkDate()), Quantity);
    end;

    local procedure CreateUsageDataBilling(UsageBasedPricing: Enum "Usage Based Pricing"; BillingPeriodStartingDate: Date; BillingPeriodEndingDate: Date; SubscriptionStartingDate: Date; SubscriptionEndingDate: Date; Quantity: Decimal)
    begin
        SetupUsageDataForProcessingToGenericImport(BillingPeriodStartingDate, BillingPeriodEndingDate, SubscriptionStartingDate, SubscriptionEndingDate, Quantity);
        SetupDataExchangeDefinition();
        SetupServiceObjectAndContracts(SubscriptionStartingDate);
        UsageBasedBTestLibrary.ConnectDataExchDefinitionToUsageDataGenericSettings(DataExchDef.Code, GenericImportSettings);
        ProcessUsageDataImport(Enum::"Processing Step"::"Create Imported Lines");
        ProcessUsageDataImport(Enum::"Processing Step"::"Process Imported Lines");

        // Error is expected because Usage data subscription is created in this step - linking with Subscription Line is second step
        // Therefore Processing needs to be performed twice - refer to AB2070
        UsageDataGenericImport.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        UsageDataGenericImport.FindFirst();
        PrepareServiceCommitmentAndUsageDataGenericImportForUsageBilling(UsageBasedPricing);
        Codeunit.Run(Codeunit::"Import And Process Usage Data", UsageDataImport);
        UsageDataImport.SetRecFilter();
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Create Usage Data Billing");
    end;

    local procedure CreateUsageDataBillingDummyDataFromServiceCommitment(var NewUsageDataBilling: Record "Usage Data Billing"; UsageDataImportEntryNo: Integer; SourceServiceCommitment: Record "Subscription Line")
    begin
        SourceServiceCommitment.SetAutoCalcFields(Quantity);
        NewUsageDataBilling."Entry No." := 0;
        NewUsageDataBilling."Usage Data Import Entry No." := UsageDataImportEntryNo;
        NewUsageDataBilling.Partner := SourceServiceCommitment.Partner;
        NewUsageDataBilling."Subscription Header No." := SourceServiceCommitment."Subscription Header No.";
        NewUsageDataBilling."Subscription Line Entry No." := SourceServiceCommitment."Entry No.";
        NewUsageDataBilling."Subscription Contract No." := SourceServiceCommitment."Subscription Contract No.";
        NewUsageDataBilling."Subscription Contract Line No." := SourceServiceCommitment."Subscription Contract Line No.";
        NewUsageDataBilling.Quantity := SourceServiceCommitment.Quantity;
        NewUsageDataBilling."Charge Start Date" := WorkDate();
        NewUsageDataBilling."Charge End Date" := CalcDate('<CM>', WorkDate());
        NewUsageDataBilling.Insert(true);
    end;

    local procedure CreateVendorContractAndAssignServiceCommitments()
    var
        TempServiceCommitment: Record "Subscription Line" temporary;
    begin
        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContract(VendorContract, Vendor."No.");
        ContractTestLibrary.FillTempServiceCommitmentForVendor(TempServiceCommitment, ServiceObject, VendorContract);
        VendorContract.CreateVendorContractLinesFromServiceCommitments(TempServiceCommitment);
        VendorContractLine.SetRange("Subscription Contract No.", VendorContract."No.");
        VendorContractLine.FindLast();
        ContractTestLibrary.SetGeneralPostingSetup(Vendor."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group", false, Enum::"Service Partner"::Vendor);
    end;

    local procedure FilterUsageDataBillingOnUsageDataImport(UsageDataImportEntryNo: Integer)
    begin
        UsageDataBilling.Reset();
        UsageDataBilling.SetRange("Usage Data Import Entry No.", UsageDataImportEntryNo);
    end;

    local procedure FilterUsageDataBillingOnUsageDataImport(UsageDataImportEntryNo: Integer; ServicePartner: Enum "Service Partner")
    begin
        FilterUsageDataBillingOnUsageDataImport(UsageDataImportEntryNo);
        UsageDataBilling.SetRange(Partner, ServicePartner);
    end;

    local procedure FilterUsageDataBillingOnUsageDataImport(UsageDataImportEntryNo: Integer; ServicePartner: Enum "Service Partner"; UsageBasedBillingDocType: Enum "Usage Based Billing Doc. Type")
    begin
        FilterUsageDataBillingOnUsageDataImport(UsageDataImportEntryNo, ServicePartner);
        UsageDataBilling.SetRange("Document Type", UsageBasedBillingDocType);
    end;

    local procedure GetBillingEntryNo(BillingDocumentType: Enum "Rec. Billing Document Type"; ServicePartner: Enum "Service Partner"; DocumentNo: Code[20]; ContractNo: Code[20]; ContractLineNo: Integer): Integer
    begin
        BillingLine.FilterBillingLineOnContractLine(ServicePartner, ContractNo, ContractLineNo);
        BillingLine.SetRange("Document Type", BillingDocumentType);
        BillingLine.SetRange("Document No.", DocumentNo);
        if BillingLine.FindLast() then
            exit(BillingLine."Entry No.")
        else
            exit(0);
    end;

    local procedure MockBillingLine(var NewBillingLine: Record "Billing Line"; Partner: Enum "Service Partner"; DocumentType: Enum "Rec. Billing Document Type")
    begin
        NewBillingLine.Init();
        NewBillingLine."User ID" := CopyStr(UserId(), 1, MaxStrLen(NewBillingLine."User ID"));
        NewBillingLine."Entry No." := 0;
        NewBillingLine.Partner := Partner;
        NewBillingLine."Document Type" := DocumentType;
        NewBillingLine."Document No." := CopyStr(LibraryRandom.RandText(MaxStrLen(Item.Description)), 1, 20);
        NewBillingLine.Insert(false);
    end;

    local procedure MockBillingLineArchive(var NewBillingLineArchive: Record "Billing Line Archive"; Partner: Enum "Service Partner"; DocumentType: Enum "Rec. Billing Document Type")
    begin
        NewBillingLineArchive.Init();
        NewBillingLineArchive.Partner := Partner;
        NewBillingLineArchive."Document Type" := DocumentType;
        NewBillingLineArchive."Document No." := CopyStr(LibraryRandom.RandText(MaxStrLen(Item.Description)), 1, 20);
        NewBillingLineArchive.Insert(false);
    end;

    local procedure MockUsageData(var NewUsageDataBilling: Record "Usage Data Billing"; Partner: Enum "Service Partner"; DocumentType: Enum "Usage Based Billing Doc. Type"; DocumentNo: Code[20])
    begin
        NewUsageDataBilling.Init();
        NewUsageDataBilling.Partner := Partner;
        NewUsageDataBilling."Document Type" := DocumentType;
        NewUsageDataBilling."Document No." := DocumentNo;
        NewUsageDataBilling.Insert(false);
    end;

    local procedure PostPurchaseDocuments()
    begin
        FilterUsageDataBillingOnUsageDataImport(UsageDataImport."Entry No.");
        UsageDataBilling.MarkPurchaseHeaderFromUsageDataBilling(UsageDataBilling, PurchaseHeader);
        PurchaseHeader.FindSet();
        repeat
            PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateGUID());
            PurchaseHeader.Modify(false);
            LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        until PurchaseHeader.Next() = 0;
    end;

    local procedure PrepareServiceCommitmentAndUsageDataGenericImportForUsageBilling(UsageBasedPricing: Enum "Usage Based Pricing")
    begin
        PrepareServiceCommitmentAndUsageDataGenericImportForUsageBilling(UsageBasedPricing, '', '');
    end;

    local procedure PrepareServiceCommitmentAndUsageDataGenericImportForUsageBilling(UsageBasedPricing: Enum "Usage Based Pricing"; BillingBasePeriod: Text;
                                                                                                                BillingRhythm: Text)
    begin
        PrepareServiceCommitmentAndUsageDataGenericImportForUsageBilling(UsageBasedPricing, BillingBasePeriod, BillingRhythm, 0D);

    end;

    local procedure PrepareServiceCommitmentAndUsageDataGenericImportForUsageBilling(UsageBasedPricing: Enum "Usage Based Pricing"; BillingBasePeriod: Text;
                                                                                                            BillingRhythm: Text; ServiceStartDate: Date)
    begin
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.FindSet();
        repeat
            ServiceCommitment."Usage Based Pricing" := UsageBasedPricing;
            if ServiceStartDate <> 0D then
                ServiceCommitment."Subscription Line Start Date" := CalcDate('<-CM>', WorkDate());
            if BillingBasePeriod <> '' then
                Evaluate(ServiceCommitment."Billing Base Period", BillingBasePeriod);
            if BillingRhythm <> '' then
                Evaluate(ServiceCommitment."Billing Rhythm", BillingRhythm);
            UsageDataSupplierReference.FilterUsageDataSupplierReference(UsageDataImport."Supplier No.", UsageDataGenericImport."Supp. Subscription ID", Enum::"Usage Data Reference Type"::Subscription);
            if UsageDataSupplierReference.FindFirst() then
                ServiceCommitment."Supplier Reference Entry No." := UsageDataSupplierReference."Entry No.";
            ServiceCommitment.Modify(false);
            UsageDataGenericImport."Subscription Header No." := ServiceObject."No.";
            UsageDataGenericImport.Modify(false);
        until ServiceCommitment.Next() = 0;
    end;

    local procedure ProcessUsageDataImport(ProcessingStep: Enum "Processing Step")
    begin
        UsageDataImport."Processing Step" := ProcessingStep;
        UsageDataImport.Modify(false);
        Codeunit.Run(Codeunit::"Import And Process Usage Data", UsageDataImport);
    end;

    local procedure ProcessUsageDataWithSimpleGenericImport(BillingPeriodStartDate: Date; BillingPeriodEndDate: Date; SubscriptionStartDate: Date; SubscriptionEndDate: Date; Quantity: Decimal)
    begin
        ProcessUsageDataWithSimpleGenericImport(BillingPeriodStartDate, BillingPeriodEndDate, SubscriptionStartDate, SubscriptionEndDate, Quantity, "Usage Based Pricing"::"Usage Quantity");
    end;

    local procedure ProcessUsageDataWithSimpleGenericImport(BillingPeriodStartDate: Date; BillingPeriodEndDate: Date; SubscriptionStartDate: Date; SubscriptionEndDate: Date; Quantity: Decimal; UsageBasedPricing: Enum "Usage Based Pricing")
    begin
        UsageBasedBTestLibrary.CreateUsageDataSupplier(UsageDataSupplier, Enum::"Usage Data Supplier Type"::Generic, false, Enum::"Vendor Invoice Per"::Import);
        UsageBasedBTestLibrary.CreateGenericImportSettings(GenericImportSettings, UsageDataSupplier."No.", true, true);
        UsageBasedBTestLibrary.CreateUsageDataImport(UsageDataImport, UsageDataSupplier."No.");
        UsageBasedBTestLibrary.CreateSimpleUsageDataGenericImport(UsageDataGenericImport, UsageDataImport."Entry No.", ServiceObject."No.", Customer."No.", Item."Unit Cost", BillingPeriodStartDate, BillingPeriodEndDate, SubscriptionStartDate, SubscriptionEndDate, Quantity);
        ProcessUsageDataImport(Enum::"Processing Step"::"Process Imported Lines");
        UsageDataGenericImport.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        UsageDataGenericImport.FindFirst();
        PrepareServiceCommitmentAndUsageDataGenericImportForUsageBilling(UsageBasedPricing);
        Codeunit.Run(Codeunit::"Import And Process Usage Data", UsageDataImport);

        UsageDataImport.SetRecFilter();
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Create Usage Data Billing");
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");
    end;

    local procedure SetupDataExchangeDefinition()
    begin
        UsageBasedBTestLibrary.CreateDataExchDefinition(DataExchDef, FileType::"Variable Text", Enum::"Data Exchange Definition Type"::"Generic Import", FileEncoding::"UTF-8", ColumnSeparator::Semicolon, '', 1);
        UsageBasedBTestLibrary.CreateDataExchDefinitionLine(DataExchLineDef, DataExchDef.Code, RRef);
        UsageBasedBTestLibrary.CreateDataExchColumnDefinition(DataExchColumnDef, DataExchDef.Code, DataExchLineDef.Code, RRef);
        UsageBasedBTestLibrary.CreateDataExchangeMapping(DataExchMapping, DataExchDef.Code, DataExchLineDef.Code, RRef);
        UsageBasedBTestLibrary.CreateDataExchangeFieldMapping(DataExchFieldMapping, DataExchDef.Code, DataExchLineDef.Code, RRef);
    end;

    local procedure SetupItemWithMultipleServiceCommitmentPackages()
    begin
        // Billing rhythm should be the same as in Usage data billing which is in the "Usage Based B. Test Library" set to 1D always (WorkDate()) Ref: CreateOutStreamData
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        Evaluate(ServiceCommitmentTemplate."Billing Base Period", '1M');
        ServiceCommitmentTemplate."Calculation Base %" := LibraryRandom.RandDec(100, 2);
        ServiceCommitmentTemplate."Invoicing via" := Enum::"Invoicing Via"::Contract;
        ServiceCommitmentTemplate."Calculation Base Type" := "Calculation Base Type"::"Item Price";
        ServiceCommitmentTemplate."Usage Based Billing" := true;
        ServiceCommitmentTemplate.Modify(false);
        // Standard Subscription Package with two Subscription Package Lines
        // 1. for Customer
        // 2. for Vendor
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ServiceCommPackageLine.Partner := Enum::"Service Partner"::Customer;
        Evaluate(ServiceCommPackageLine."Extension Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Notice Period", '<1M>');
        Evaluate(ServiceCommPackageLine."Initial Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Billing Rhythm", '<1M>');
        ServiceCommPackageLine.Modify(false);

        ContractTestLibrary.CreateServiceCommitmentPackageLine(ServiceCommitmentPackage.Code, ServiceCommitmentTemplate.Code, ServiceCommPackageLine);
        ServiceCommPackageLine.Partner := Enum::"Service Partner"::Vendor;
        Evaluate(ServiceCommPackageLine."Extension Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Notice Period", '<1M>');
        Evaluate(ServiceCommPackageLine."Initial Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Billing Rhythm", '<1M>');
        ServiceCommPackageLine.Modify(false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);
        ItemServCommitmentPackage.Get(Item."No.", ServiceCommitmentPackage.Code);
        ItemServCommitmentPackage.Standard := true;
        ItemServCommitmentPackage.Modify(false);

        // Additional Subscription Package
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ServiceCommPackageLine.Partner := Enum::"Service Partner"::Customer;
        Evaluate(ServiceCommPackageLine."Extension Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Notice Period", '<1M>');
        Evaluate(ServiceCommPackageLine."Initial Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Billing Rhythm", '<1M>');
        ServiceCommPackageLine.Modify(false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);
    end;

    local procedure SetupServiceDataForProcessing(UsageBasedPricing: Enum "Usage Based Pricing"; CalculationBaseType: Enum "Calculation Base Type";
                                                                         InvoicingVia: Enum "Invoicing Via";
                                                                         BillingBasePeriod: Text;
                                                                         BillingRhythm: Text;
                                                                         ExtensionTerm: Text;
                                                                         ServicePartner: Enum "Service Partner";
                                                                         CalculationBase: Decimal;
                                                                         ItemNo: Code[20])
    begin
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ServiceCommitmentTemplate."Usage Based Billing" := true;
        ServiceCommitmentTemplate."Usage Based Pricing" := UsageBasedPricing;
        Evaluate(ServiceCommitmentTemplate."Billing Base Period", '1M');
        ServiceCommitmentTemplate."Calculation Base %" := LibraryRandom.RandDec(100, 2);
        ServiceCommitmentTemplate."Invoicing via" := InvoicingVia;
        ServiceCommitmentTemplate."Calculation Base Type" := CalculationBaseType;
        ServiceCommitmentTemplate.Modify(false);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, BillingBasePeriod, CalculationBase, BillingRhythm, ExtensionTerm, ServicePartner, '');
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);
        ItemServCommitmentPackage.Get(ItemNo, ServiceCommitmentPackage.Code);
        ItemServCommitmentPackage.Standard := true;
        ItemServCommitmentPackage.Modify(false);

        LibrarySales.CreateCustomer(Customer);
        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, ItemNo);
        ServiceObject.InsertServiceCommitmentsFromStandardServCommPackages(WorkDate());
        ServiceObject."End-User Customer No." := Customer."No.";
        ServiceObject.Modify(false);
        CreateCustomerContractAndAssignServiceCommitments();
    end;

    local procedure SetupServiceObjectAndContracts(ServiceAndCalculationStartDate: Date)
    begin
        ContractTestLibrary.CreateCustomer(Customer);
        CreateServiceObjectWithServiceCommitments(Customer."No.", ServiceAndCalculationStartDate);
        CreateCustomerContractAndAssignServiceCommitments();
        CreateVendorContractAndAssignServiceCommitments();
    end;

    local procedure SetupUsageDataForProcessingToGenericImport()
    begin
        SetupUsageDataForProcessingToGenericImport(WorkDate(), WorkDate(), WorkDate(), WorkDate(), LibraryRandom.RandDec(10, 2));
    end;

    local procedure SetupUsageDataForProcessingToGenericImport(BillingPeriodStartingDate: Date; BillingPeriodEndingDate: Date; SubscriptionStartingDate: Date; SubscriptionEndingDate: Date; Quantity: Decimal)
    begin
        SetupUsageDataForProcessingToGenericImport(BillingPeriodStartingDate, BillingPeriodEndingDate, SubscriptionStartingDate, SubscriptionEndingDate, Quantity, true);
    end;

    local procedure SetupUsageDataForProcessingToGenericImport(BillingPeriodStartingDate: Date; BillingPeriodEndingDate: Date; SubscriptionStartingDate: Date; SubscriptionEndingDate: Date; Quantity: Decimal; UnitPriceFromImport: Boolean)
    begin
        UsageBasedBTestLibrary.CreateUsageDataSupplier(UsageDataSupplier, Enum::"Usage Data Supplier Type"::Generic, UnitPriceFromImport, Enum::"Vendor Invoice Per"::Import);
        UsageBasedBTestLibrary.CreateGenericImportSettings(GenericImportSettings, UsageDataSupplier."No.", true, true);
        UsageBasedBTestLibrary.CreateUsageDataImport(UsageDataImport, UsageDataSupplier."No.");
        RRef.GetTable(UsageDataGenericImport);
        UsageDataBlob.InsertFromUsageDataImport(UsageDataImport);
        UsageBasedBTestLibrary.CreateUsageDataCSVFileBasedOnRecordAndImportToUsageDataBlob(
                    UsageDataBlob,
                    RRef,
                    CopyStr(LibraryRandom.RandText(80), 1, 80),
                    CopyStr(LibraryRandom.RandText(80), 1, 80),
                    ServiceObject."No.",
                    ServiceCommitment."Entry No.",
                    BillingPeriodStartingDate,
                    BillingPeriodEndingDate,
                    SubscriptionStartingDate,
                    SubscriptionEndingDate,
                    Quantity);
    end;

    local procedure TestIfRelatedUsageDataBillingIsUpdated(ServicePartner: Enum "Service Partner"; UsageBasedBillingDocType: Enum "Usage Based Billing Doc. Type"; DocumentNo: Code[20]; TestNotEmptyDocLineNo: Boolean; BillingLineNo: Integer)
    begin
        FilterUsageDataBillingOnUsageDataImport(UsageDataImport."Entry No.", ServicePartner);
        UsageDataBilling.FindSet();
        repeat
            UsageDataBilling.TestField("Document Type", UsageBasedBillingDocType);
            UsageDataBilling.TestField("Document No.", DocumentNo);
            if BillingLineNo <> 0 then
                UsageDataBilling.TestField("Billing Line Entry No.", GetBillingEntryNo(BillingLine."Document Type", BillingLine.Partner, DocumentNo, UsageDataBilling."Subscription Contract No.",
                                                              UsageDataBilling."Subscription Contract Line No."));
            // Billing Line No. is always last line no. for Contract No. and Contract Line No.
            if TestNotEmptyDocLineNo then
                UsageDataBilling.TestField("Document Line No.")
            else
                UsageDataBilling.TestField("Document Line No.", 0);
        until UsageDataBilling.Next() = 0
    end;

    local procedure TestUsageDataBilling()
    begin
        UsageDataBilling.TestField("Usage Data Import Entry No.", UsageDataGenericImport."Usage Data Import Entry No.");
        UsageDataBilling.TestField("Subscription Header No.", UsageDataGenericImport."Subscription Header No.");
        UsageDataBilling.TestField("Charge Start Date", UsageDataGenericImport."Billing Period Start Date");
        UsageDataBilling.TestField("Charge End Date", UsageDataGenericImport."Billing Period End Date");
        UsageDataBilling.TestField("Unit Cost", UsageDataGenericImport.Cost);
        UsageDataBilling.TestField(Quantity, UsageDataGenericImport.Quantity);
        UsageDataBilling.TestField("Cost Amount", UsageDataGenericImport."Cost Amount");
        UsageDataBilling.TestField(Amount, 0);
        UsageDataBilling.TestField("Unit Price", 0);
        UsageDataBilling.TestField("Currency Code", UsageDataGenericImport.Currency);
        UsageDataBilling.TestField("Subscription Header No.", ServiceCommitment."Subscription Header No.");
        UsageDataBilling.TestField(Partner, ServiceCommitment.Partner);
        UsageDataBilling.TestField("Subscription Contract No.", ServiceCommitment."Subscription Contract No.");
        UsageDataBilling.TestField("Subscription Contract Line No.", ServiceCommitment."Subscription Contract Line No.");
        UsageDataBilling.TestField("Subscription Header No.", ServiceCommitment."Subscription Header No.");
        UsageDataBilling.TestField("Subscription Line Entry No.", ServiceCommitment."Entry No.");
        UsageDataBilling.TestField("Usage Base Pricing", ServiceCommitment."Usage Based Pricing");
        UsageDataBilling.TestField("Pricing Unit Cost Surcharge %", ServiceCommitment."Pricing Unit Cost Surcharge %");
    end;

    local procedure ValidateUsageDataGenericImportAvailability(UsageDataImportEntryNo: Integer; ExpectedServiceObjectAvailability: Enum "Service Object Availability"; ExpectedServiceObjectNo: Code[20])
    begin
        UsageDataGenericImport.SetRange("Usage Data Import Entry No.", UsageDataImportEntryNo);
        UsageDataGenericImport.FindFirst();
        Assert.AreEqual(ExpectedServiceObjectAvailability, UsageDataGenericImport."Service Object Availability", 'Service Object Availability is not set to expected value in Usage Data Generic Import.');
        Assert.AreEqual(ExpectedServiceObjectNo, UsageDataGenericImport."Subscription Header No.", 'Service Object No. is not set to expected value in Usage Data Generic Import.');
    end;

    local procedure MockServiceCommitment(var ServiceCommitment: Record "Subscription Line"; BillingBasePeriod: DateFormula; BillingRhythm: DateFormula; Price: Decimal)
    begin
        ServiceCommitment.Init();
        ServiceCommitment."Billing Base Period" := BillingBasePeriod;
        ServiceCommitment."Billing Rhythm" := BillingRhythm;
        ServiceCommitment.Price := Price;
    end;
    #endregion Procedures

    #region Handlers

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
    procedure UsageDataBillingsModalPageHandler(var UsageDataBillings: TestPage "Usage Data Billings")
    begin
        LibraryVariableStorage.Enqueue(UsageDataBillings.First());
        LibraryVariableStorage.Enqueue(UsageDataBillings.Next());
    end;

    #endregion Handlers
}
