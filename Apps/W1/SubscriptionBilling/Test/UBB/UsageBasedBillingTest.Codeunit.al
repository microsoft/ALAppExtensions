namespace Microsoft.SubscriptionBilling;

using System.IO;
using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Setup;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Finance.Currency;

codeunit 148153 "Usage Based Billing Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

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
    procedure ExpectErrorIfGenericSettingIsNotLinkedToDataExchangeDefinition()
    begin
        Initialize();
        SetupUsageDataForProcessingToGenericImport();
        SetupDataExchangeDefinition();
        UsageDataImport."Processing Step" := Enum::"Processing Step"::"Create Imported Lines";
        UsageDataImport.Modify(false);
        asserterror Codeunit.Run(Codeunit::"Generic Usage Data Import", UsageDataImport);
    end;

    [Test]
    procedure TestCreateUsageDataGenericImport()
    begin
        //Create Setup Data and Import file
        Initialize();
        SetupUsageDataForProcessingToGenericImport();
        SetupDataExchangeDefinition();
        //Create Data Exchange definition for processing imported file and Creating Usage Data Generic Import
        UsageBasedBTestLibrary.ConnectDataExchDefinitionToUsageDataGenericSettings(DataExchDef.Code, GenericImportSettings);
        ProcessUsageDataImport(Enum::"Processing Step"::"Create Imported Lines");
        //Expect that Usage Data Generic Import is created
        Commit();
        UsageDataGenericImport.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        UsageDataGenericImport.FindFirst();
        UsageDataGenericImport.TestField("Processing Status", Enum::"Processing Status"::None);
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
        //Process Usage Data Generic Import
        CheckIfUsageDataSubscriptionIsCreated();
        CheckIfUsageDataCustomerIsCreated();
        CheckIfCustomerSupplierReferencesAreIsCreated();
        CheckIfSubscriptionSupplierReferencesAreIsCreated();
        CheckIfProductSupplierReferencesAreIsCreated();
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
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestProcessUsageDataBilling()
    begin
        Initialize();
        CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2));
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");
        //Test update service object and service commitment
        //TODO: Test prices update after 1. iteration of consultants testing
        //3 additional tests for different Usage Based Pricing option
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
        asserterror UsageDataBilling.FindFirst();
        Clear(UsageDataGenericImport);
        UsageDataGenericImport.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        asserterror UsageDataGenericImport.FindFirst();

        UsageDataImport.TestField("Processing Status", "Processing Status"::None);
        UsageDataImport.TestField("Processing Step", "Processing Step"::None);
    end;

    [Test]
    procedure ExpectErrorWhenDataExchangeDefinitionIsNotGenericImportForGenericImportSettings()
    var
        DataExchDefType: Enum "Data Exchange Definition Type";
        ListOfOrdinals: List of [Integer];
    begin
        //[GIVEN] Error for validating "Data Exchange Definition" for "Data Exchange Definition Type" different than "Generic Import"
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
            asserterror UsageDataBlob.FindFirst();

            UsageDataGenericImport.Reset();
            UsageDataGenericImport.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
            asserterror UsageDataGenericImport.FindFirst();

            FilterUsageDataBillingOnUsageDataImport(UsageDataImport."Entry No.");
            asserterror UsageDataBilling.FindFirst();
        until UsageDataImport.Next() = 0;
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
        TestIfReleatedUsageDataBillingIsUpdated("Service Partner"::Customer, "Usage Based Billing Doc. Type"::"Posted Invoice", SalesInvoiceHeader."No.", true, 0);
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
        TestIfReleatedUsageDataBillingIsUpdated("Service Partner"::Customer, Enum::"Usage Based Billing Doc. Type"::None, '', false, 0);
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
            TestIfReleatedUsageDataBillingIsUpdated("Service Partner"::Customer, Enum::"Usage Based Billing Doc. Type"::None, '', false, 0);
        until BillingLine.Next() = 0;
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
        Assert.RecordCount(UsageDataBilling, 2); //Expect additional usage data billing for credit memo

        UsageDataBilling.FilterOnDocumentTypeAndDocumentNo(Enum::"Usage Based Billing Doc. Type"::"Credit Memo", SalesCrMemoHeader."No.");
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
        Assert.RecordCount(UsageDataBilling, 3); //Expect additional usage data billing for credit memo and one withoud docoument type and document no

        UsageDataBilling.FilterOnDocumentTypeAndDocumentNo(Enum::"Usage Based Billing Doc. Type"::"Posted Credit Memo", CorrectedDocumentNo);
        UsageDataBilling.FindSet();

        UsageDataBilling.FilterOnDocumentTypeAndDocumentNo(Enum::"Usage Based Billing Doc. Type"::None, '');
        UsageDataBilling.FindSet();
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
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateCustomerBillingDocumentPageHandler,MessageHandler')]
    procedure TestCreateContractInvoiceForMultipleCustomerContracts()
    begin
        Initialize();
        for i := 1 to 2 do //create usage data for 3 different contracts
            CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2));

        //Process usage data and create customer contract invoices
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
        for i := 1 to 2 do //create usage data for 3 different contracts
            CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2));

        //Process usage data and create vendor contract invoices
        UsageDataImport.Reset();
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");
        UsageDataImport.Reset();
        UsageDataImport.CollectVendorContractsAndCreateInvoices(UsageDataImport);
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
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateVendorBillingDocumentPageHandler,MessageHandler')]
    procedure TestCreateVendorContractInvoiceFromUsageDataImport()
    begin
        Initialize();
        CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2));
        PostDocument := false;
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");
        UsageDataImport.TestField("Processing Status", "Processing Status"::Ok);
        UsageDataImport.CollectVendorContractsAndCreateInvoices(UsageDataImport);
        CheckIfPurchaseDocumentsHaveBeenCreated();
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
        TestIfReleatedUsageDataBillingIsUpdated("Service Partner"::Vendor, Enum::"Usage Based Billing Doc. Type"::"Posted Invoice", PurchaseInvoiceHeader."No.", true, 0);
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
        TestIfReleatedUsageDataBillingIsUpdated("Service Partner"::Vendor, Enum::"Usage Based Billing Doc. Type"::None, '', false, 0);
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
        TestIfReleatedUsageDataBillingIsUpdated("Service Partner"::Vendor, Enum::"Usage Based Billing Doc. Type"::None, '', false, 0);
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
        Assert.RecordCount(UsageDataBilling, 2); //Expect additional usage data billing for credit memo and one withoud docoument type and document no

        UsageDataBilling.FilterOnDocumentTypeAndDocumentNo(Enum::"Usage Based Billing Doc. Type"::"Credit Memo", SalesCrMemoHeader."No.");
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
        Assert.RecordCount(UsageDataBilling, 2); //Expect additional usage data billing for credit memo and one withoud docoument type and document no

        UsageDataBilling.FilterOnDocumentTypeAndDocumentNo(Enum::"Usage Based Billing Doc. Type"::"Credit Memo", PurchaseHeader."No.");
        UsageDataBilling.FindSet();
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
        Assert.RecordCount(UsageDataBilling, 3); //Expect additional usage data billing for credit memo and one withoud docoument type and document no

        UsageDataBilling.FilterOnDocumentTypeAndDocumentNo(Enum::"Usage Based Billing Doc. Type"::"Posted Credit Memo", CorrectedDocumentNo);
        UsageDataBilling.FindSet();

        UsageDataBilling.FilterOnDocumentTypeAndDocumentNo(Enum::"Usage Based Billing Doc. Type"::None, '');
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
        Assert.RecordCount(UsageDataBilling, 3); //Expect additional usage data billing for credit memo and one without document type and document no

        UsageDataBilling.FilterOnDocumentTypeAndDocumentNo(Enum::"Usage Based Billing Doc. Type"::"Posted Credit Memo", CorrectedDocumentNo);
        UsageDataBilling.FindSet();

        UsageDataBilling.FilterOnDocumentTypeAndDocumentNo(Enum::"Usage Based Billing Doc. Type"::None, '');
        UsageDataBilling.FindSet();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnDeleteCustomerContractLine()
    begin
        Initialize();
        CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2));
        UsageDataBilling.SetRange(Partner, "Service Partner"::Customer);
        UsageDataBilling.FindFirst();
        CustomerContractLine.Get(UsageDataBilling."Contract No.", UsageDataBilling."Contract Line No.");
        asserterror CustomerContractLine.Delete(true);
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

        SetupServiceObjectAndContracts(CalcDate('<-1D>', WorkDate())); //USage data generic import is create on workdate
        ProcessUsageDataImport(Enum::"Processing Step"::"Process Imported Lines");
        UsageDataGenericImport.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        UsageDataGenericImport.FindFirst();
        UsageDataGenericImport.TestField("Processing Status", Enum::"Processing Status"::Error);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnProcessUsageDataBillingWithZeroQuantity()
    begin
        Initialize();
        CreateUsageDataBilling("Usage Based Pricing"::"Usage Quantity", WorkDate(), WorkDate(), WorkDate(), WorkDate(), 0);
        ServiceObject."Quantity Decimal" := 0;
        ServiceObject.Modify(false);
        Codeunit.Run(Codeunit::"Process Usage Data Billing", UsageDataImport);
        UsageDataImport.TestField("Processing Status", "Processing Status"::Error);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateCustomerBillingDocumentPageHandler,MessageHandler')]
    procedure TestCreateUsageDataBillingDocumentsWhenBillingRequiredInBillingProposal()
    begin
        //Create recurring billing for simple customer contract
        //Set update required
        //Expect no error on create Usage data billing documents
        Initialize();
        CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2));
        PostDocument := false;
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");

        CreateBillingProposalForSimpleCustomerContract();
        ServiceCommitment.Get(BillingLine."Service Commitment Entry No.");
        ServiceCommitment.Validate("Discount %", LibraryRandom.RandDec(50, 2));
        ServiceCommitment.Modify(true);

        UsageDataImport.CollectCustomerContractsAndCreateInvoices(UsageDataImport);
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
        AssertThat.AreEqual(LastUsedNo, NoSeriesLine."Last No. Used", 'No Series changed after GetSalesPrice()');
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
        //Expect that month between BillingDate1 and BillingDate2 is skipped
        BillingLine.Reset();
        BillingLine.SetRange(Partner, "Service Partner"::Customer);
        BillingLine.SetRange("Service Start Date", CalcDate('<CM>', TestBillingDate));
        asserterror BillingLine.FindSet();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestPriceCalculationInUsageBasedBasedOnDay()
    var
        TempServiceCommitment: Record "Service Commitment" temporary;
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
        ContractTestLibrary.CreateServiceObject(ServiceObject, Item."No.");
        ServiceObject.InsertServiceCommitmentsFromStandardServCommPackages(WorkDate());
        ServiceObject."End-User Customer No." := Customer."No.";
        ServiceObject.Modify(false);
        CreateCustomerContractAndAssignServiceCommitments(TempServiceCommitment);
        CreateVendorContractAndAssignServiceCommitments(TempServiceCommitment);
        UsageBasedBTestLibrary.ConnectDataExchDefinitionToUsageDataGenericSettings(DataExchDef.Code, GenericImportSettings);

        ProcessUsageDataImport(Enum::"Processing Step"::"Create Imported Lines");
        ProcessUsageDataImport(Enum::"Processing Step"::"Process Imported Lines");

        UsageDataGenericImport.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        UsageDataGenericImport.FindFirst();
        PrepareServiceCommitmentAndUsageDataGenericImportForUsageBilling("Usage Based Pricing"::"Usage Quantity", '1D', '1D');
        Codeunit.Run(Codeunit::"Generic Usage Data Import", UsageDataImport);
        UsageDataImport.SetRecFilter();
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Create Usage Data Billing");
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");

        FilterUsageDataBillingOnUsageDataImport(UsageDataImport."Entry No.");
        UsageDataBilling.FindSet();
        UsageDataBilling.TestField("Unit Price", 1);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpecteErrorIfServiceCommitmentIsNotAssignedToContract()
    var
        TempServiceCommitment: Record "Service Commitment" temporary;
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
        ContractTestLibrary.CreateServiceObject(ServiceObject, Item."No.");
        ServiceObject.InsertServiceCommitmentsFromStandardServCommPackages(WorkDate());
        ServiceObject."End-User Customer No." := Customer."No.";
        ServiceObject.Modify(false);
        CreateCustomerContractAndAssignServiceCommitments(TempServiceCommitment);
        //TODO: Remove CreateVendorContractAndAssignServiceCommitments(TempServiceCommitment);
        UsageBasedBTestLibrary.ConnectDataExchDefinitionToUsageDataGenericSettings(DataExchDef.Code, GenericImportSettings);

        ProcessUsageDataImport(Enum::"Processing Step"::"Create Imported Lines");
        ProcessUsageDataImport(Enum::"Processing Step"::"Process Imported Lines");

        UsageDataGenericImport.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        UsageDataGenericImport.FindFirst();
        PrepareServiceCommitmentAndUsageDataGenericImportForUsageBilling("Usage Based Pricing"::"Usage Quantity", '1D', '1D');
        Codeunit.Run(Codeunit::"Generic Usage Data Import", UsageDataImport);
        UsageDataImport.SetRecFilter();
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Create Usage Data Billing");

        UsageDataImport.Get(UsageDataImport."Entry No.");
        UsageDataImport.TestField("Processing Status", Enum::"Processing Status"::Error);
    end;

    [Test]
    procedure TestProratedAmountForYearlyPrices()
    var
        EssDateTimeMgt: Codeunit "Date Time Management";
        BillingBasePeriod: DateFormula;
        BaseAmount: Decimal;
        ChargeStartDate: Date;
        ChargeEndDate: Date;
        ExpectedResult: Decimal;
        Result: Decimal;
        DaysInPeriod: Integer;
    begin
        BaseAmount := 100;
        Evaluate(BillingBasePeriod, '12M');
        ChargeStartDate := CalcDate('<-CY>', WorkDate());
        ChargeEndDate := CalcDate('<CY+1D>', ChargeStartDate);
        Result := EssDateTimeMgt.CalculateProRatedAmount(BaseAmount, ChargeStartDate, 000000T, ChargeEndDate, 000000T, BillingBasePeriod);
        ExpectedResult := BaseAmount;
        Assert.AreEqual(ExpectedResult, Result, 'Amount was not calculated properly');

        Evaluate(BillingBasePeriod, '1Y');
        Result := EssDateTimeMgt.CalculateProRatedAmount(BaseAmount, ChargeStartDate, 0T, ChargeEndDate, 0T, BillingBasePeriod);
        Assert.AreEqual(ExpectedResult, Result, 'Amount was not calculated properly');

        ChargeEndDate := CalcDate('<1D>', ChargeStartDate);
        Result := EssDateTimeMgt.CalculateProRatedAmount(BaseAmount, ChargeStartDate, 0T, ChargeEndDate, 0T, BillingBasePeriod);
        DaysInPeriod := ChargeEndDate - ChargeStartDate;
        ExpectedResult := DaysInPeriod * BaseAmount / (CalcDate('<12M>', ChargeStartDate) - ChargeStartDate); //Divide with Days in a year
        Assert.AreEqual(ExpectedResult, Result, 'Amount was not calculated properly');
    end;

    [Test]
    procedure TestProratedAmountForMonthlyPrices()
    var
        EssDateTimeMgt: Codeunit "Date Time Management";
        BillingBasePeriod: DateFormula;
        BaseAmount: Decimal;
        ChargeStartDate: Date;
        ChargeEndDate: Date;
        ExpectedResult: Decimal;
        Result: Decimal;
    begin
        BaseAmount := 100;
        Evaluate(BillingBasePeriod, '1M');
        ChargeStartDate := CalcDate('<-CY>', WorkDate());
        ChargeEndDate := CalcDate('<CY+1D>', ChargeStartDate);
        Result := EssDateTimeMgt.CalculateProRatedAmount(BaseAmount, ChargeStartDate, 0T, ChargeEndDate, 0T, BillingBasePeriod);
        ExpectedResult := BaseAmount * 12;
        Assert.AreEqual(Result, ExpectedResult, 'Amount was not calculated properly');

        ChargeStartDate := CalcDate('<15D>', ChargeStartDate);
        ChargeEndDate := CalcDate('<1M>', ChargeStartDate);
        Result := EssDateTimeMgt.CalculateProRatedAmount(BaseAmount, ChargeStartDate, 0T, ChargeEndDate, 0T, BillingBasePeriod);

        Assert.AreEqual(Result, BaseAmount, 'Amount was not calculated properly');
    end;

    [Test]
    procedure TestProratedAmountForDailyPrices()
    var
        EssDateTimeMgt: Codeunit "Date Time Management";
        BillingBasePeriod: DateFormula;
        BaseAmount: Decimal;
        ChargeStartDate: Date;
        ChargeEndDate: Date;
        ExpectedResult: Decimal;
        Result: Decimal;
    begin
        BaseAmount := 100;
        Evaluate(BillingBasePeriod, '1D');
        ChargeStartDate := CalcDate('<-CY>', WorkDate());
        ChargeEndDate := CalcDate('<1D>', ChargeStartDate);
        Result := EssDateTimeMgt.CalculateProRatedAmount(BaseAmount, ChargeStartDate, 0T, ChargeEndDate, 0T, BillingBasePeriod);
        ExpectedResult := BaseAmount;
        Assert.AreEqual(Result, ExpectedResult, 'Amount was not calculated properly');
    end;

    [Test]
    procedure TestProratedAmountForMonthlyPriceWithDailyUsageData()
    var
        ProcessUsageDataBilling: Codeunit "Process Usage Data Billing";
        BillingBasePeriod: DateFormula;
        BaseAmount: Decimal;
        ChargeStartDate: Date;
        ChargeEndDate: Date;
        ExpectedResult: Decimal;
        Result: Decimal;
        NoOfDaysInMonth1: Integer;
    begin
        BaseAmount := 100;
        Evaluate(BillingBasePeriod, '1M');
        ChargeStartDate := CalcDate('<-CY>', WorkDate());
        ChargeEndDate := CalcDate('<1D>', ChargeStartDate);
        Result := ProcessUsageDataBilling.CalculateAmount(BillingBasePeriod, BaseAmount, ChargeStartDate, 0T, ChargeEndDate, 0T);

        NoOfDaysInMonth1 := CalcDate('<CM>', ChargeEndDate) - CalcDate('<CM-1M+1D>', ChargeEndDate) + 1;
        ExpectedResult := BaseAmount * 1 / NoOfDaysInMonth1;

        Assert.AreEqual(Result, ExpectedResult, 'Amount was not calculated properly');
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
    [HandlerFunctions('MessageHandler,CreateCustomerBillingDocumentPageHandler')]
    procedure TestYearlyServiceCommitmentWithMonthlyUsageData()
    begin
        ClearAll();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        Item."Unit Price" := 2;
        Item."Unit Cost" := 1;
        Item.Modify(false);

        SetupServiceDataForProcessing(Enum::"Usage Based Pricing"::"Usage Quantity", "Calculation Base Type"::"Item Price", Enum::"Invoicing Via"::Contract,
                                       '1Y', '1Y', '1Y', "Service Partner"::Customer, 100, Item."No.");

        ProcessUsageDataWithSimpleGenericImport(WorkDate(), CalcDate('<CM>', WorkDate()), WorkDate(), CalcDate('<CM>', WorkDate()), 1);
        CreateContractInvoicesAndTestProcessedUsageData();
    end;

    [Test]
    [HandlerFunctions('MessageHandler,CreateCustomerBillingDocumentPageHandler')]
    procedure TestYearlyServiceCommitmentWithDailyUsageData()
    begin
        ClearAll();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        Item."Unit Price" := 2;
        Item."Unit Cost" := 1;
        Item.Modify(false);

        SetupServiceDataForProcessing(Enum::"Usage Based Pricing"::"Usage Quantity", "Calculation Base Type"::"Item Price", Enum::"Invoicing Via"::Contract,
                                       '1Y', '1Y', '1Y', "Service Partner"::Customer, 100, Item."No.");

        ProcessUsageDataWithSimpleGenericImport(WorkDate(), WorkDate(), WorkDate(), CalcDate('<CM>', WorkDate()), 1);
        CreateContractInvoicesAndTestProcessedUsageData();
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure TestSkipUsageBasedServiceCommitmentsWithoutUsageData()
    begin
        ClearAll();
        ContractTestLibrary.InitContractsApp();

        // [GIVEN]: Setup simple customer contract with service commitment marked as Usage based billing
        //Try to create a billing proposal with Billing To Date (crucial)
        ContractTestLibrary.CreateMultipleServiceObjectsWithItemSetup(Customer, ServiceObject, Item, 2);
        ContractTestLibrary.UpdateItemUnitCostAndPrice(Item, LibraryRandom.RandDec(1000, 2), LibraryRandom.RandDec(1000, 2), false);

        ContractTestLibrary.CreateServiceCommitmentTemplateSetup(ServiceCommitmentTemplate, '<12M>', Enum::"Invoicing Via"::Contract);
        ContractTestLibrary.CreateServiceCommPackageAndAssignItemToServiceCommitmentSetup(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine, Item, '<12M>');
        ServiceCommPackageLine."Usage Based Billing" := true;
        ServiceCommPackageLine.Modify();
        ContractTestLibrary.InsertServiceCommitmentFromServiceCommPackageSetup(ServiceCommitmentPackage, ServiceObject);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.");
        CustomerContract.SetRange("No.", CustomerContract."No.");
        CreateRecurringBillingTemplateSetupForCustomerContract('<2M-CM>', '<8M+CM>', CustomerContract.GetView());

        // [WHEN]: Creating a billing proposal
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);

        // [THEN]: No Billing Line should be created for Usage Based Service Commitments without usage data
        BillingLine.Reset();
        Assert.AreEqual(true, BillingLine.IsEmpty, 'No Billing Line should be created for Usage Based Service Commitments without usage data');
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure TestCreateContractInvoiceWithUsageBasedServiceCommitmentsWithUsageData()
    begin
        ClearAll();
        ContractTestLibrary.InitContractsApp();

        // [GIVEN]: Usage data billing for a contract
        CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2)); // MessageHandler, ExchangeRateSelectionModalPageHandler
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");

        // [WHEN]: Creating a billing proposal
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);

        // [THEN]: A Billing Line should be created for Usage Based Service Commitments with usage data
        BillingLine.Reset();
        Assert.AreEqual(false, BillingLine.IsEmpty, 'A new Billing Line should be created for Usage Based Service Commitments with usage data when creating an invoice from the contract');
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,CreateCustomerBillingDocumentPageHandler')]
    procedure TestCreateInvoicesForMoreThanOneContractPerImportViaUsageDataImports()
    var
        CustomerContract2: Record "Customer Contract";
        ServiceObject2: Record "Service Object";
        TestSubscribers: Codeunit "Usage Based B. Test Subscr.";
        QuantityOfServiceCommitments: Integer;
    begin
        ClearAll();
        ContractTestLibrary.InitContractsApp();
        // [GIVEN] Multiple Contracts with Usage based Service Commitments and Usage Data Billing
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");
        ContractTestLibrary.CreateCustomerContract(CustomerContract2, Customer."No.");
        UsageBasedBTestLibrary.CreateUsageDataImport(UsageDataImport, '');

        TestSubscribers.SetTestContext('TestCreateInvoicesForMoreThanOneContractPerImport');
        BindSubscription(TestSubscribers);
        ContractTestLibrary.AssignServiceObjectToCustomerContract(CustomerContract, ServiceObject, false); //ExchangeRateSelectionModalPageHandler,MessageHandler
        ContractTestLibrary.AssignServiceObjectToCustomerContract(CustomerContract2, ServiceObject2, false); //ExchangeRateSelectionModalPageHandler,MessageHandler
        UnbindSubscription(TestSubscribers);


        ServiceCommitment.SetFilter("Service Object No.", '%1|%2', ServiceObject."No.", ServiceObject2."No.");
        QuantityOfServiceCommitments := ServiceCommitment.Count();
        ServiceCommitment.FindSet();
        repeat
            CreateUsageDataBillingDummyDataFromServiceCommitment(UsageDataBilling, UsageDataImport."Entry No.", ServiceCommitment);
        until ServiceCommitment.Next() = 0;

        // [WHEN]: Creating a billing proposal via "Usage Data Imports" (CollectCustomerContractsAndCreateInvoices)
        UsageDataImport.CollectCustomerContractsAndCreateInvoices(UsageDataImport); //CreateCustomerBillingDocumentPageHandler

        // [THEN]: A Billing Line should be created for Usage Based Service Commitments with usage data
        BillingLine.Reset();
        Assert.AreEqual(QuantityOfServiceCommitments, BillingLine.Count(), 'A new Billing Line should be created for each Usage Based Service Commitment and Contract with usage data when creating an invoice via "Usage Data Imports"');
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestCreateInvoicesForMoreThanOneContractPerImportViaRecurringBilling()
    var
        CustomerContract2: Record "Customer Contract";
        ServiceObject2: Record "Service Object";
        TestSubscribers: Codeunit "Usage Based B. Test Subscr.";
        QuantityOfServiceCommitments: Integer;
    begin
        ClearAll();
        ContractTestLibrary.InitContractsApp();
        // [GIVEN] Multiple Contracts with Usage based Service Commitments and Usage Data Billing
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");
        ContractTestLibrary.CreateCustomerContract(CustomerContract2, Customer."No.");
        UsageBasedBTestLibrary.CreateUsageDataImport(UsageDataImport, '');

        TestSubscribers.SetTestContext('TestCreateInvoicesForMoreThanOneContractPerImport');
        BindSubscription(TestSubscribers);
        ContractTestLibrary.AssignServiceObjectToCustomerContract(CustomerContract, ServiceObject, false); //ExchangeRateSelectionModalPageHandler,MessageHandler
        ContractTestLibrary.AssignServiceObjectToCustomerContract(CustomerContract2, ServiceObject2, false); //ExchangeRateSelectionModalPageHandler,MessageHandler
        UnbindSubscription(TestSubscribers);

        ServiceCommitment.SetFilter("Service Object No.", '%1|%2', ServiceObject."No.", ServiceObject2."No.");
        QuantityOfServiceCommitments := ServiceCommitment.Count();
        ServiceCommitment.FindSet();
        repeat
            CreateUsageDataBillingDummyDataFromServiceCommitment(UsageDataBilling, UsageDataImport."Entry No.", ServiceCommitment);
        until ServiceCommitment.Next() = 0;

        // [WHEN]: Creating a billing proposal via Contract or "Recurring Billing"
        ContractTestLibrary.CreateRecurringBillingTemplate(BillingTemplate, '<CM>', '', '', Enum::"Service Partner"::Customer);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);

        // [THEN]: A new Billing Line should be created for each Usage Based Service Commitment and Contract with usage data when creating an invoice via "Usage Data Imports"
        BillingLine.Reset();
        Assert.AreEqual(QuantityOfServiceCommitments, BillingLine.Count(), 'A new Billing Line should be created for each Usage Based Service Commitment and Contract with usage data when creating an invoice via "Usage Data Imports"');
    end;


    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestProcessUsageDataBillingWithDiscount100()
    begin
        // [SCENARIO]: Setup simple customer contract with service commitment marked as Usage based billing
        // Add 100% discount in service commitment
        // Processing of Usage data should proceed without an error

        // [GIVEN]: Setup Usage based service commitment and assign it to customer; Add Discount of 100% to the service commitment
        Initialize();
        CreateUsageDataBilling("Usage Based Pricing"::"Fixed Quantity", LibraryRandom.RandDec(10, 2));
        ServiceCommitment.Validate("Discount Amount", ServiceCommitment."Service Amount");  //Rounding issue; Make sure that the Discount amount is equal to Service Amount
        ServiceCommitment.Modify(true);

        // [WHEN]: Expect no error to happen on processing usage data billing
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");

        // [THEN]: Test if Processing Status Ok is set in Usage Data Import
        UsageDataImport.TestField("Processing Status", "Processing Status"::Ok);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectNoInvoicesCreateIfUsageDataImportProcessingStatusIsError()
    begin
        // [SCENARIO]: When usage data is processed with an error
        // expect no invoices to be created

        // [GIVEN]: Create usage data which will for sure cause an error
        Initialize();
        CreateUsageDataBilling("Usage Based Pricing"::"Usage Quantity", WorkDate(), WorkDate(), WorkDate(), WorkDate(), 0);
        ServiceObject."Quantity Decimal" := 0; //Zero Quantity on Service Object will cause error
        ServiceObject.Modify(false);
        PostDocument := false;
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");

        // [WHEN]: Try to create customer contract invoices; Error should be caught and no usage data lines should be taken into contract invoice
        UsageDataImport.CollectCustomerContractsAndCreateInvoices(UsageDataImport);

        // [THEN]: Test if Processing Status Error is set in Usage Data Import and that no invoice has been created and assigned in Usage Data Billing
        UsageDataImport.Get(UsageDataImport."Entry No.");
        UsageDataImport.TestField("Processing Status", Enum::"Processing Status"::Error);
        FilterUsageDataBillingOnUsageDataImport(UsageDataImport."Entry No.", "Service Partner"::Customer, UsageDataBilling."Document Type"::Invoice);
        asserterror UsageDataBilling.FindSet();
    end;

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
        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Usage Based Billing Test");
    end;

    local procedure ResetAll()
    begin
        ClearAll();
        UsageBasedBTestLibrary.ResetUsageBasedRecords();
        BillingLine.Reset();
        BillingLine.DeleteAll(false);
    end;

    local procedure CheckIfSalesDocumentsHaveBeenCreated()
    begin
        BillingLine.FindSet();
        repeat
            BillingLine.TestField("Document Type", Enum::"Rec. Billing Document Type"::Invoice);
            BillingLine.TestField("Document No.");
            ServiceCommitment.Get(BillingLine."Service Commitment Entry No.");
            ServiceCommitment.TestField("Usage Based Billing");
            ServiceCommitment.TestField("Supplier Reference Entry No.");

            SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            SalesLine.SetFilter("Recurring Billing from", '>=%1', BillingLine."Billing from");
            SalesLine.SetFilter("Recurring Billing to", '<=%1', BillingLine."Billing to");
            Assert.AreEqual(1, SalesLine.Count, 'The Sales lines were not created properly.');
            TestIfReleatedUsageDataBillingIsUpdated("Service Partner"::Customer, UsageBasedDocTypeConv.ConvertSalesDocTypeToUsageBasedBillingDocType(SalesHeader."Document Type"), SalesHeader."No.", true, BillingLine."Entry No.");
        until BillingLine.Next() = 0;
    end;

    local procedure TestIfReleatedUsageDataBillingIsUpdated(ServicePartner: Enum "Service Partner"; UsageBasedBillingDocType: Enum "Usage Based Billing Doc. Type"; DocumentNo: Code[20]; TestNotEmptyDocLineNo: Boolean; BillingLineNo: Integer)
    begin
        FilterUsageDataBillingOnUsageDataImport(UsageDataImport."Entry No.", ServicePartner);
        UsageDataBilling.FindSet();
        repeat
            UsageDataBilling.TestField("Document Type", UsageBasedBillingDocType);
            UsageDataBilling.TestField("Document No.", DocumentNo);
            if BillingLineNo <> 0 then
                UsageDataBilling.TestField("Billing Line Entry No.", GetBillingEntryNo(BillingLine."Document Type", BillingLine.Partner, DocumentNo, UsageDataBilling."Contract No.",
                                                              UsageDataBilling."Contract Line No."));
            //Billing Line No. is always last line no. for Contract No. and Contract Line No.
            if TestNotEmptyDocLineNo then
                UsageDataBilling.TestField("Document Line No.")
            else
                UsageDataBilling.TestField("Document Line No.", 0);
        until UsageDataBilling.Next() = 0
    end;

    local procedure CheckIfPurchaseDocumentsHaveBeenCreated()
    begin
        if BillingLine.FindSet() then
            repeat
                BillingLine.TestField("Document Type", Enum::"Rec. Billing Document Type"::Invoice);
                BillingLine.TestField("Document No.");
                ServiceCommitment.Get(BillingLine."Service Commitment Entry No.");
                ServiceCommitment.TestField("Usage Based Billing");
                ServiceCommitment.TestField("Supplier Reference Entry No.");

                PurchaseHeader.Get(Enum::"Purchase Document Type"::Invoice, BillingLine."Document No.");
                PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
                PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
                PurchaseLine.SetFilter("Recurring Billing from", '>=%1', BillingLine."Billing from");
                PurchaseLine.SetFilter("Recurring Billing to", '<=%1', BillingLine."Billing to");
                Assert.AreEqual(1, PurchaseLine.Count, 'The Purchase lines were not created properly.');
                TestIfReleatedUsageDataBillingIsUpdated("Service Partner"::Vendor, UsageBasedDocTypeConv.ConvertPurchaseDocTypeToUsageBasedBillingDocType(PurchaseHeader."Document Type"), PurchaseHeader."No.", true, BillingLine."Entry No.");
            until BillingLine.Next() = 0;
    end;

    local procedure CreateUsageDataBillingDummyDataFromServiceCommitment(var NewUsageDataBilling: Record "Usage Data Billing"; UsageDataImportEntryNo: Integer; SourceServiceCommitment: Record "Service Commitment")
    begin
        SourceServiceCommitment.SetAutoCalcFields("Quantity Decimal");
        NewUsageDataBilling."Entry No." := 0;
        NewUsageDataBilling."Usage Data Import Entry No." := UsageDataImportEntryNo;
        NewUsageDataBilling.Partner := SourceServiceCommitment.Partner;
        NewUsageDataBilling."Service Object No." := SourceServiceCommitment."Service Object No.";
        NewUsageDataBilling."Service Commitment Entry No." := SourceServiceCommitment."Entry No.";
        NewUsageDataBilling."Contract No." := SourceServiceCommitment."Contract No.";
        NewUsageDataBilling."Contract Line No." := SourceServiceCommitment."Contract Line No.";
        NewUsageDataBilling.Quantity := SourceServiceCommitment."Quantity Decimal";
        NewUsageDataBilling."Charge Start Date" := WorkDate();
        NewUsageDataBilling."Charge End Date" := CalcDate('<CM>', WorkDate());
        NewUsageDataBilling.Insert(true);
    end;

    local procedure CreateRecurringBillingTemplateSetupForCustomerContract(DateFormula1Txt: Text; DateFormula2Txt: Text; FilterText: Text)
    begin
        ContractTestLibrary.CreateRecurringBillingTemplate(BillingTemplate, DateFormula1Txt, DateFormula2Txt, FilterText, Enum::"Service Partner"::Customer);
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

        BillingLine.FilterBillingLineOnContractLine(UsageDataBilling.Partner, UsageDataBilling."Contract No.", UsageDataBilling."Contract Line No.");
        BillingLine.CalcSums("Service Amount");
        Assert.AreEqual(Round(BillingLine."Service Amount", Currency."Unit-Amount Rounding Precision"), ExpectedInvoiceAmount, 'Billing lines where not created properly');
    end;

    procedure SetupUsageDataForProcessingToGenericImport()
    begin
        SetupUsageDataForProcessingToGenericImport(WorkDate(), WorkDate(), WorkDate(), WorkDate(), LibraryRandom.RandDec(10, 2));
    end;

    procedure SetupUsageDataForProcessingToGenericImport(BillingPeriodStartingDate: Date; BillingPeriodEndingDate: Date; SubscriptionStartingDate: Date; SubscriptionEndingDate: Date; Quantity: Decimal)
    begin
        SetupUsageDataForProcessingToGenericImport(BillingPeriodStartingDate, BillingPeriodEndingDate, SubscriptionStartingDate, SubscriptionEndingDate, Quantity, true);
    end;

    procedure SetupUsageDataForProcessingToGenericImport(BillingPeriodStartingDate: Date; BillingPeriodEndingDate: Date; SubscriptionStartingDate: Date; SubscriptionEndingDate: Date; Quantity: Decimal; UnitPriceFromImport: Boolean)
    begin
        UsageBasedBTestLibrary.CreateUsageDataSupplier(UsageDataSupplier, Enum::"Usage Data Supplier Type"::Generic, UnitPriceFromImport, Enum::"Vendor Invoice Per"::Import);
        UsageBasedBTestLibrary.CreateGenericImportSettings(GenericImportSettings, UsageDataSupplier."No.", true, true);
        UsageBasedBTestLibrary.CreateUsageDataImport(UsageDataImport, UsageDataSupplier."No.");
        RRef.GetTable(UsageDataGenericImport);
        UsageDataBlob.InsertFromUsageDataImport(UsageDataImport);
        UsageBasedBTestLibrary.CreateUsageDataCSVFileBasedOnRecordAndImportToUsageDataBlob(UsageDataBlob, RRef, ServiceObject."No.", ServiceCommitment."Entry No.", BillingPeriodStartingDate, BillingPeriodEndingDate,
                                                                                    SubscriptionStartingDate, SubscriptionEndingDate, Quantity);
    end;

    local procedure SetupDataExchangeDefinition()
    begin
        UsageBasedBTestLibrary.CreateDataExchDefinition(DataExchDef, FileType::"Variable Text", Enum::"Data Exchange Definition Type"::"Generic Import", FileEncoding::"UTF-8", ColumnSeparator::Semicolon, '', 1);
        UsageBasedBTestLibrary.CreateDataExchDefinitionLine(DataExchLineDef, DataExchDef.Code, RRef);
        UsageBasedBTestLibrary.CreateDataExchColumnDefinition(DataExchColumnDef, DataExchDef.Code, DataExchLineDef.Code, RRef);
        UsageBasedBTestLibrary.CreateDataExchangeMapping(DataExchMapping, DataExchDef.Code, DataExchLineDef.Code, RRef);
        UsageBasedBTestLibrary.CreateDataExchangeFieldMapping(DataExchFieldMapping, DataExchDef.Code, DataExchLineDef.Code, RRef);
    end;

    local procedure CheckIfUsageDataSubscriptionIsCreated()
    begin
        UsageDataSubscription.SetRange("Supplier No.", UsageDataImport."Supplier No.");
        UsageDataSubscription.SetRange("Supplier Reference", UsageDataGenericImport."Subscription ID");
        UsageDataSubscription.FindFirst();
        UsageDataSubscription.TestField("Customer ID", UsageDataGenericImport."Customer ID");
        UsageDataSubscription.TestField("Product ID", UsageDataGenericImport."Product ID");
        UsageDataSubscription.TestField("Product Name", UsageDataGenericImport."Product Name");
        UsageDataSubscription.TestField("Unit Type", UsageDataGenericImport.Unit);
        UsageDataSubscription.TestField(Quantity, UsageDataGenericImport.Quantity);
        UsageDataSubscription.TestField("Start Date", UsageDataGenericImport."Subscription Start Date");
        UsageDataSubscription.TestField("End Date", UsageDataGenericImport."Subscription End Date");
    end;

    local procedure CheckIfUsageDataCustomerIsCreated()
    begin
        UsageDataCustomer.SetRange("Supplier No.", UsageDataImport."Supplier No.");
        UsageDataCustomer.SetRange("Supplier Reference", UsageDataGenericImport."Customer ID");
        UsageDataCustomer.FindFirst();
    end;

    local procedure CheckIfCustomerSupplierReferencesAreIsCreated()
    begin
        UsageDataSupplierReference.FilterUsageDataSupplierReference(UsageDataImport."Supplier No.", UsageDataGenericImport."Customer ID", Enum::"Usage Data Reference Type"::Customer);
        UsageDataSupplierReference.FindFirst();
    end;

    local procedure CheckIfSubscriptionSupplierReferencesAreIsCreated()
    begin
        UsageDataSupplierReference.FilterUsageDataSupplierReference(UsageDataImport."Supplier No.", UsageDataGenericImport."Subscription ID", Enum::"Usage Data Reference Type"::Subscription);
        UsageDataSupplierReference.FindFirst();
    end;

    local procedure CheckIfProductSupplierReferencesAreIsCreated()
    begin
        UsageDataSupplierReference.FilterUsageDataSupplierReference(UsageDataImport."Supplier No.", UsageDataGenericImport."Product ID", Enum::"Usage Data Reference Type"::Product);
        UsageDataSupplierReference.FindFirst();
    end;

    local procedure PrepareServiceCommitmentAndUsageDataGenericImportForUsageBilling(UsageBasedPricing: Enum "Usage Based Pricing")
    begin
        PrepareServiceCommitmentAndUsageDataGenericImportForUsageBilling(UsageBasedPricing, '', '');
    end;

    local procedure PrepareServiceCommitmentAndUsageDataGenericImportForUsageBilling(UsageBasedPricing: Enum "Usage Based Pricing"; BillingBasePeriod: Text; BillingRhythm: Text)
    begin
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindSet();
        repeat
            ServiceCommitment."Usage Based Billing" := true;
            ServiceCommitment."Usage Based Pricing" := UsageBasedPricing;
            if BillingBasePeriod <> '' then
                Evaluate(ServiceCommitment."Billing Base Period", BillingBasePeriod);
            if BillingRhythm <> '' then
                Evaluate(ServiceCommitment."Billing Rhythm", BillingRhythm);
            UsageDataSupplierReference.FilterUsageDataSupplierReference(UsageDataImport."Supplier No.", UsageDataGenericImport."Subscription ID", Enum::"Usage Data Reference Type"::Subscription);
            if UsageDataSupplierReference.FindFirst() then
                ServiceCommitment."Supplier Reference Entry No." := UsageDataSupplierReference."Entry No.";
            ServiceCommitment.Modify(false);
            UsageDataGenericImport."Service Object No." := ServiceObject."No.";
            UsageDataGenericImport.Modify(false);
        until ServiceCommitment.Next() = 0;
    end;

    local procedure TestUsageDataBilling()
    begin
        UsageDataBilling.TestField("Usage Data Import Entry No.", UsageDataGenericImport."Usage Data Import Entry No.");
        UsageDataBilling.TestField("Service Object No.", UsageDataGenericImport."Service Object No.");
        UsageDataBilling.TestField("Charge Start Date", UsageDataGenericImport."Billing Period Start Date");
        UsageDataBilling.TestField("Charge Start Time", 000000T);
        UsageDataBilling.TestField("Charge End Date", CalcDate('<+1D>', UsageDataGenericImport."Billing Period End Date"));
        UsageDataBilling.TestField("Charge End Time", 000000T);
        UsageDataBilling.TestField("Unit Cost", UsageDataGenericImport.Cost);
        UsageDataBilling.TestField(Quantity, UsageDataGenericImport.Quantity);
        UsageDataBilling.TestField("Cost Amount", UsageDataGenericImport."Cost Amount");
        UsageDataBilling.TestField(Amount, 0);
        UsageDataBilling.TestField("Unit Price", 0);
        UsageDataBilling.TestField("Currency Code", UsageDataGenericImport.Currency);
        UsageDataBilling.TestField("Service Object No.", ServiceCommitment."Service Object No.");
        UsageDataBilling.TestField(Partner, ServiceCommitment.Partner);
        UsageDataBilling.TestField("Contract No.", ServiceCommitment."Contract No.");
        UsageDataBilling.TestField("Contract Line No.", ServiceCommitment."Contract Line No.");
        UsageDataBilling.TestField("Service Object No.", ServiceCommitment."Service Object No.");
        UsageDataBilling.TestField("Service Commitment Entry No.", ServiceCommitment."Entry No.");
        UsageDataBilling.TestField("Usage Base Pricing", ServiceCommitment."Usage Based Pricing");
        UsageDataBilling.TestField("Pricing Unit Cost Surcharge %", ServiceCommitment."Pricing Unit Cost Surcharge %");
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

        //Error is expected because Usage data subscription is created in this step - linking with service commitment is second step
        //Therefore Processing needs to be performed twice - refer to AB2070
        UsageDataGenericImport.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        UsageDataGenericImport.FindFirst();
        PrepareServiceCommitmentAndUsageDataGenericImportForUsageBilling(UsageBasedPricing);
        Codeunit.Run(Codeunit::"Generic Usage Data Import", UsageDataImport);
        UsageDataImport.SetRecFilter();
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Create Usage Data Billing");
    end;

    local procedure SetupServiceObjectAndContracts(ServiceAndCalculationStartDate: Date)
    var
        TempServiceCommitment: Record "Service Commitment" temporary;
    begin
        ContractTestLibrary.CreateCustomer(Customer);
        CreateServiceObjectWithServiceCommitments(Customer."No.", ServiceAndCalculationStartDate);
        CreateCustomerContractAndAssignServiceCommitments(TempServiceCommitment);
        CreateVendorContractAndAssignServiceCommitments(TempServiceCommitment);
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

    local procedure CreateServiceObjectWithServiceCommitments(CustomerNo: Code[20]; ServiceAndCalculationStartDate: Date)
    begin
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        Item."Unit Price" := LibraryRandom.RandDec(1000, 2);
        Item."Unit Cost" := LibraryRandom.RandDec(1000, 2);
        Item.Modify(false);
        SetupItemWithMultipleServiceCommitmentPackages();
        ContractTestLibrary.CreateServiceObject(ServiceObject, Item."No.");
        ServiceObject.InsertServiceCommitmentsFromStandardServCommPackages(ServiceAndCalculationStartDate);
        ServiceObject."End-User Customer No." := CustomerNo;
        ServiceObject.Modify(false);
    end;

    local procedure CreateCustomerContractAndAssignServiceCommitments(var TempServiceCommitment: Record "Service Commitment" temporary)
    begin
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");
        ContractTestLibrary.FillTempServiceCommitment(TempServiceCommitment, ServiceObject, CustomerContract);
        CustomerContract.CreateCustomerContractLinesFromServiceCommitments(TempServiceCommitment);
        CustomerContractLine.SetRange("Contract No.", CustomerContract."No.");
        CustomerContractLine.FindLast();
        ContractTestLibrary.SetGeneralPostingSetup(Customer."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group", false, Enum::"Service Partner"::Customer);
    end;

    local procedure CreateVendorContractAndAssignServiceCommitments(var TempServiceCommitment: Record "Service Commitment" temporary)
    begin
        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContract(VendorContract, Vendor."No.");
        ContractTestLibrary.FillTempServiceCommitmentForVendor(TempServiceCommitment, ServiceObject, VendorContract);
        VendorContract.CreateVendorContractLinesFromServiceCommitments(TempServiceCommitment);
        VendorContractLine.SetRange("Contract No.", VendorContract."No.");
        VendorContractLine.FindLast();
        ContractTestLibrary.SetGeneralPostingSetup(Vendor."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group", false, Enum::"Service Partner"::Vendor);
    end;

    local procedure CreateBillingProposalForSimpleCustomerContract()
    begin
        ContractTestLibrary.InitContractsApp();
        SetupServiceObjectAndContracts(WorkDate());
        CustomerContract.SetRange("No.", CustomerContract."No.");
        ContractTestLibrary.CreateRecurringBillingTemplate(BillingTemplate, '<2M-CM>', '<8M+CM>', CustomerContract.GetView(), Enum::"Service Partner"::Customer);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
        BillingLine.Reset();
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.FindLast();
    end;

    procedure SetupItemWithMultipleServiceCommitmentPackages()
    begin
        //Billing rhytm should be the same as in Usage data billing which is in the "Usage Based B. Test Library" set to 1D always (WorkDate()) Ref: CreateOutStreamData
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        Evaluate(ServiceCommitmentTemplate."Billing Base Period", '1M');
        ServiceCommitmentTemplate."Calculation Base %" := LibraryRandom.RandDec(100, 2);
        ServiceCommitmentTemplate."Invoicing via" := Enum::"Invoicing Via"::Contract;
        ServiceCommitmentTemplate."Calculation Base Type" := "Calculation Base Type"::"Item Price";
        ServiceCommitmentTemplate.Modify(false);
        //Standard Service Comm. Package with two Service Comm. Package Lines
        //1. for Customer
        //2. for Vendor
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

        //Additional Service Commitment Package
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ServiceCommPackageLine.Partner := Enum::"Service Partner"::Customer;
        Evaluate(ServiceCommPackageLine."Extension Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Notice Period", '<1M>');
        Evaluate(ServiceCommPackageLine."Initial Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Billing Rhythm", '<1M>');
        ServiceCommPackageLine.Modify(false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);
    end;

    local procedure GetBillingEntryNo(BillingDocumentType: Enum "Rec. Billing Document Type"; ServiceParner: Enum "Service Partner";
                                                              DocumentNo: Code[20];
                                                              ContractNo: Code[20];
                                                              ContractLineNo: Integer): Integer
    begin
        BillingLine.FilterBillingLineOnContractLine(ServiceParner, ContractNo, ContractLineNo);
        BillingLine.SetRange("Document Type", BillingDocumentType);
        BillingLine.SetRange("Document No.", DocumentNo);
        if BillingLine.FindLast() then
            exit(BillingLine."Entry No.")
        else
            exit(0);
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

    local procedure ProcessUsageDataImport(ProcessingStep: Enum "Processing Step")
    begin
        UsageDataImport."Processing Step" := ProcessingStep;
        UsageDataImport.Modify(false);
        Codeunit.Run(Codeunit::"Generic Usage Data Import", UsageDataImport);
    end;

    local procedure SetupServiceDataForProcessing(UsageBasedPricing: Enum "Usage Based Pricing"; CalculationBaseType: Enum "Calculation Base Type";
                                                                         InvoicingVia: Enum "Invoicing Via";
                                                                         BillingBasePeriod: Text;
                                                                         BillingRhythm: Text;
                                                                         ExtensionTerm: Text;
                                                                         ServicePartner: Enum "Service Partner";
                                                                         CalculationBase: Decimal;
                                                                         ItemNo: Code[20])
    var
        TempServiceCommitment: Record "Service Commitment" temporary;
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
        ContractTestLibrary.CreateServiceObject(ServiceObject, ItemNo);
        ServiceObject.InsertServiceCommitmentsFromStandardServCommPackages(WorkDate());
        ServiceObject."End-User Customer No." := Customer."No.";
        ServiceObject.Modify(false);
        CreateCustomerContractAndAssignServiceCommitments(TempServiceCommitment);
    end;

    local procedure ProcessUsageDataWithSimpleGenericImport(BillingPeriodStartDate: Date; BillingPeriodEndDate: Date; SubscriptionStartDate: Date; SubscriptionEndDate: Date; Quantity: Integer)
    begin
        UsageBasedBTestLibrary.CreateUsageDataSupplier(UsageDataSupplier, Enum::"Usage Data Supplier Type"::Generic, false, Enum::"Vendor Invoice Per"::Import);
        UsageBasedBTestLibrary.CreateGenericImportSettings(GenericImportSettings, UsageDataSupplier."No.", true, true);
        UsageBasedBTestLibrary.CreateUsageDataImport(UsageDataImport, UsageDataSupplier."No.");
        UsageBasedBTestLibrary.CreateSimpleUsageDataGenericImport(UsageDataGenericImport, UsageDataImport."Entry No.", ServiceObject."No.", Customer."No.", Item."Unit Cost", BillingPeriodStartDate, BillingPeriodEndDate, SubscriptionStartDate, SubscriptionEndDate, Quantity);
        ProcessUsageDataImport(Enum::"Processing Step"::"Process Imported Lines");
        UsageDataGenericImport.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        UsageDataGenericImport.FindFirst();
        PrepareServiceCommitmentAndUsageDataGenericImportForUsageBilling("Usage Based Pricing"::"Usage Quantity");
        Codeunit.Run(Codeunit::"Generic Usage Data Import", UsageDataImport);

        UsageDataImport.SetRecFilter();
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Create Usage Data Billing");
        UsageDataImport.ProcessUsageDataImport(UsageDataImport, Enum::"Processing Step"::"Process Usage Data Billing");
    end;

    local procedure CheckIfServiceCommitmentRemains()
    begin
        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", UsageDataBilling."Service Object No.");
        ServiceCommitment.SetRange("Entry No.", UsageDataBilling."Service Commitment Entry No.");
        ServiceCommitment.FindSet();
        repeat
            if ServiceCommitment.Partner = "Service Partner"::Customer then
                ServiceCommitment.TestField(Price, Item."Unit Price")
            else
                ServiceCommitment.TestField(Price, Item."Unit Cost");
        until ServiceCommitment.Next() = 0;
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

    var
        UsageDataSupplier: Record "Usage Data Supplier";
        GenericImportSettings: Record "Generic Import Settings";
        UsageDataImport: Record "Usage Data Import";
        UsageDataBlob: Record "Usage Data Blob";
        UsageDataGenericImport: Record "Usage Data Generic Import";
        DataExchDef: Record "Data Exch. Def";
        DataExchColumnDef: Record "Data Exch. Column Def";
        DataExchLineDef: Record "Data Exch. Line Def";
        DataExchMapping: Record "Data Exch. Mapping";
        DataExchFieldMapping: Record "Data Exch. Field Mapping";
        UsageDataSubscription: Record "Usage Data Subscription";
        UsageDataCustomer: Record "Usage Data Customer";
        UsageDataSupplierReference: Record "Usage Data Supplier Reference";
        ServiceObject: Record "Service Object";
        Item: Record Item;
        ServiceCommitment: Record "Service Commitment";
        UsageDataBilling: Record "Usage Data Billing";
        CustomerContract: Record "Customer Contract";
        Customer: Record Customer;
        CustomerContractLine: Record "Customer Contract Line";
        BillingLine: Record "Billing Line";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Header";
        SalesSetup: Record "Sales & Receivables Setup";
        ServiceCommitmentTemplate: Record "Service Commitment Template";
        ServiceCommitmentPackage: Record "Service Commitment Package";
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        ItemServCommitmentPackage: Record "Item Serv. Commitment Package";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VendorContract: Record "Vendor Contract";
        VendorContractLine: Record "Vendor Contract Line";
        PurchSetup: Record "Purchases & Payables Setup";
        Vendor: Record Vendor;
        Currency: Record Currency;
        SalesLine: Record "Sales Line";
        BillingTemplate: Record "Billing Template";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryPurchase: Codeunit "Library - Purchase";
        UsageBasedBTestLibrary: Codeunit "Usage Based B. Test Library";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        CorrectPostedPurchaseInvoice: Codeunit "Correct Posted Purch. Invoice";
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
        AssertThat: Codeunit Assert;
        LibrarySales: Codeunit "Library - Sales";
        ContractTestLibrary: Codeunit "Contract Test Library";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit Assert;
        UsageBasedDocTypeConv: Codeunit "Usage Based Doc. Type Conv.";
        RRef: RecordRef;
        FileType: Option Xml,"Variable Text","Fixed Text",Json;
        FileEncoding: Option "MS-DOS","UTF-8","UTF-16",WINDOWS;
        ColumnSeparator: Option " ",Tab,Semicolon,Comma,Space,Custom;
        PostDocument: Boolean;
        IsInitialized: Boolean;
        CorrectedDocumentNo: Code[20];
        i: Integer;
        j: Integer;
}
