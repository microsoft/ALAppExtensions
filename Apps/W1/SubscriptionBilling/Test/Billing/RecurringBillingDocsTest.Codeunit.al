namespace Microsoft.SubscriptionBilling;

using System.Globalization;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Item.Attribute;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Pricing.Source;
using Microsoft.Pricing.Asset;
using Microsoft.Pricing.PriceList;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Account;

codeunit 139687 "Recurring Billing Docs Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    var
        BillingTemplate: Record "Billing Template";
        BillingTemplate2: Record "Billing Template";
        ServiceObject: Record "Service Object";
        ServiceObject2: Record "Service Object";
        ServiceObject3: Record "Service Object";
        ServiceObject4: Record "Service Object";
        CustomerContract: Record "Customer Contract";
        CustomerContract2: Record "Customer Contract";
        CustomerContract3: Record "Customer Contract";
        CustomerContract4: Record "Customer Contract";
        VendorContract: Record "Vendor Contract";
        VendorContract2: Record "Vendor Contract";
        VendorContract3: Record "Vendor Contract";
        VendorContract4: Record "Vendor Contract";
        CustomerContractLine: Record "Customer Contract Line";
        BillingLine: Record "Billing Line";
        ServiceCommitment: Record "Service Commitment";
        Customer2: Record Customer;
        Customer3: Record Customer;
        Vendor2: Record Vendor;
        Vendor3: Record Vendor;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesLine2: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempSalesInvoiceHeader: Record "Sales Invoice Header" temporary;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchaseInvoiceHeader: Record "Purch. Inv. Header";
        VendorContractLine: Record "Vendor Contract Line";
        ContractTestLibrary: Codeunit "Contract Test Library";
        AssertThat: Codeunit Assert;
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        BillingProposal: Codeunit "Billing Proposal";
        DocChangeMgt: Codeunit "Document Change Management";
        LibraryRandom: Codeunit "Library - Random";
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
        CorrectPostedPurchaseInvoice: Codeunit "Correct Posted Purch. Invoice";
        ContractsGeneralMgt: Codeunit "Contracts General Mgt.";
        LibraryPriceCalculation: Codeunit "Library - Price Calculation";
        PriceListManagement: Codeunit "Price List Management";
        RRef: RecordRef;
        FRef: FieldRef;
        UnpostedSalesInvExistsMsg: Label 'Billing line with unposted Sales Invoice exists. New invoices cannot be created until the current invoice is posted. Do you want to open the invoice?';
        SalesCrMemoExistsMsg: Label 'There is a sales credit memo that needs to be posted before an invoice can be created. Do you want to open the credit memo?';
        NoContractLinesFoundErr: Label 'No contract lines were found that can be billed with the specified parameters.';
        PurchCrMemoExistsMsg: Label 'There is a purchase credit memo that needs to be posted before an invoice can be created. Do you want to open the credit memo?';
        PostedDocumentNo: Code[20];
        DocumentsCount: Integer;
        PurchaseDocumentCount: Integer;
        i: Integer;
        ExpectedNoOfArchivedLines: Integer;
        FieldsArray: array[100] of Integer;
        EmptyArray: Boolean;
        NextBillingToDate: Date;
        DialogMsg: Text;
        IsInitialized: Boolean;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectBillingLinesCheckErrorsForCustomer()
    begin
        Initialize();

        SetupBasicBillingProposal(Enum::"Service Partner"::Customer);
        BillingLine.SetFilter("Billing Template Code", '%1|%2', BillingTemplate.Code, BillingTemplate2.Code);
        BillingLine.SetRange(Partner, BillingLine.Partner::Customer);
        BillingLine.FindFirst();
        ServiceCommitment.Get(BillingLine."Service Commitment Entry No.");
        ServiceCommitment.Modify(true);
        asserterror Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectBillingLinesCheckErrorsForVendor()
    begin
        Initialize();

        SetupBasicBillingProposal(Enum::"Service Partner"::Vendor);
        BillingLine.SetFilter("Billing Template Code", '%1|%2', BillingTemplate.Code, BillingTemplate2.Code);
        BillingLine.SetRange(Partner, BillingLine.Partner::Vendor);
        BillingLine.FindFirst();
        ServiceCommitment.Get(BillingLine."Service Commitment Entry No.");
        ServiceCommitment.Modify(true);
        asserterror Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsTestOpenPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckRequestPageSelectionConfirmedForCustomer()
    begin
        Initialize();

        InitAndCreateBillingDocument(Enum::"Service Partner"::Customer);
        //The Request Page has been cancelled, therefore no Sales Document should have been created
        if BillingLine.FindSet() then
            repeat
                BillingLine.TestField("Document Type", Enum::"Rec. Billing Document Type"::None);
                BillingLine.TestField("Document No.", '');
            until BillingLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CancelCreateVendorBillingDocsTestOpenPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckRequestPageSelectionConfirmedForVendor()
    begin
        Initialize();

        InitAndCreateBillingDocument(Enum::"Service Partner"::Vendor);
        //The Request Page has been cancelled, therefore no Purchase Document should have been created
        if BillingLine.FindSet() then
            repeat
                BillingLine.TestField("Document Type", Enum::"Rec. Billing Document Type"::None);
                BillingLine.TestField("Document No.", '');
            until BillingLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CreateSalesDocumentsPerContract()
    begin
        Initialize();

        //Contract1, Sell-to Customer1, Bill-to Customer1
        //Contract2, Sell-to Customer2, Bill-to Customer2
        //Contract3, Sell-to Customer2, Bill-to Customer1
        //Contract4, Sell-to Customer3, Bill-to Customer1
        InitAndCreateBillingDocumentsForMultipleContracts();
        CheckIfSalesDocumentsHaveBeenCreated();
        AssertThat.AreEqual(4, DocumentsCount, 'Sales Documents were not created correctly');
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler')]
    procedure CreateSalesDocumentForContractAndCheckSorting()
    var
        Customer: Record Customer;
        Item: Record Item;
        LastContractLineNo: Integer;
    begin
        Initialize();

        //ServiceObject
        //ServiceObject2
        //load ServiceObject2 in Contract
        //load ServiceObject1 in Contract
        //expect the same sorting in sales invoice
        LibrarySales.CreateCustomer(Customer);
        ContractTestLibrary.CreateServiceObjectWithItemAndWithServiceCommitment(ServiceObject, Enum::"Invoicing Via"::Contract, false, Item, 1, 0);
        ServiceObject.SetHideValidationDialog(true);
        ServiceObject.Validate("End-User Customer No.", Customer."No.");
        ServiceObject.Modify(false);
        ContractTestLibrary.CreateServiceObjectWithItemAndWithServiceCommitment(ServiceObject2, Enum::"Invoicing Via"::Contract, false, Item, 1, 0);
        ServiceObject2.SetHideValidationDialog(true);
        ServiceObject2.Validate("End-User Customer No.", Customer."No.");
        ServiceObject2.Modify(false);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject2, Customer."No.");
        ContractTestLibrary.AssignServiceObjectToCustomerContract(CustomerContract, ServiceObject, false);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
        CreateBillingDocuments();
        BillingLine.FindLast();
        FilterSalesLineOnDocumentLine(BillingLine.GetSalesDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");
        SalesLine.FindSet();
        LastContractLineNo := 0;
        repeat
            BillingLine.FilterBillingLineOnDocumentLine(BillingLine.GetBillingDocumentTypeFromSalesDocumentType(SalesLine."Document Type"), SalesLine."Document No.", SalesLine."Line No.");
            BillingLine.FindFirst();
            if LastContractLineNo > BillingLine."Contract Line No." then
                Error('Line Sorting in a sales document is wrong.');
            LastContractLineNo := BillingLine."Contract Line No.";
        until SalesLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckSingleContractSalesInvoiceHeaderPostingDescription()
    begin
        Initialize();

        InitAndCreateBillingDocument(Enum::"Service Partner"::Customer);
        BillingLine.FindLast();
        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
        SalesHeader.TestField("Posting Description", 'Customer Contract ' + BillingLine."Contract No.");
        PostAndGetSalesInvoiceHeaderFromRecurringBilling();
        SalesInvoiceHeader.TestField("Posting Description", 'Customer Contract ' + BillingLine."Contract No.");
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsBillToCustomerPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckMultipleContractsSalesInvoiceHeaderPostingDescription()
    begin
        Initialize();

        InitAndCreateBillingDocumentsForMultipleContracts();
        BillingLine.FindLast();
        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
        SalesHeader.TestField("Posting Description", 'Multiple Customer Contracts');
        PostAndGetSalesInvoiceHeaderFromRecurringBilling();
        SalesInvoiceHeader.TestField("Posting Description", 'Multiple Customer Contracts');
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsSellToCustomerPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CreateSalesDocumentsPerSellToCustomer()
    begin
        Initialize();

        //Contract1, Sell-to Customer1, Bill-to Customer1
        //Contract2, Sell-to Customer2, Bill-to Customer2
        //Contract3, Sell-to Customer2, Bill-to Customer1
        //Contract4, Sell-to Customer3, Bill-to Customer1
        InitAndCreateBillingDocumentsForMultipleContracts();
        CheckIfSalesDocumentsHaveBeenCreated();
        AssertThat.AreEqual(3, DocumentsCount, 'Sales Documents were not created correctly');
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsBillToCustomerPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CreateSalesDocumentsPerBillToCustomer()
    begin
        Initialize();

        //Contract1, Sell-to Customer1, Bill-to Customer1
        //Contract2, Sell-to Customer2, Bill-to Customer2
        //Contract3, Sell-to Customer2, Bill-to Customer1
        //Contract4, Sell-to Customer3, Bill-to Customer1
        InitAndCreateBillingDocumentsForMultipleContracts();
        CheckIfSalesDocumentsHaveBeenCreated();
        AssertThat.AreEqual(2, DocumentsCount, 'Sales Documents were not created correctly');
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CreatePurchaseDocumentsPerContract()
    begin
        Initialize();

        //Contract1, Buy-from Vendor1, Pay-to Vendor1
        //Contract2, Buy-from Vendor2, Pay-to Vendor2
        //Contract3, Buy-from Vendor2, Bill-to Vendor1
        //Contract4, Buy-from Vendor3, Bill-to Vendor1
        InitAndCreateBillingDocumentsForMultipleVendorContracts();
        CheckIfPurchaseDocumentsHaveBeenCreated();
        AssertThat.AreEqual(4, PurchaseDocumentCount, 'Purchase Documents were not created correctly');
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckPurchInvoiceHeaderPostingDescription()
    begin
        Initialize();

        InitAndCreateBillingDocument(Enum::"Service Partner"::Vendor);
        BillingLine.FindLast();
        PurchaseHeader.Get(Enum::"Purchase Document Type"::Invoice, BillingLine."Document No.");
        PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateGUID());
        PurchaseHeader.Modify(false);
        PostedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        PurchaseInvoiceHeader.Get(PostedDocumentNo);
        AssertThat.IsSubstring(PurchaseInvoiceHeader."Posting Description", 'Vendor Contract ' + BillingLine."Contract No.");
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsPayToVendorPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckMultipleContractsPurchaseInvoiceHeaderPostingDescription()
    begin
        Initialize();

        InitAndCreateBillingDocumentsForMultipleVendorContracts();
        BillingLine.FindLast();
        PurchaseHeader.Get(Enum::"Purchase Document Type"::Invoice, BillingLine."Document No.");
        PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateGUID());
        PurchaseHeader.Modify(false);
        PostedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        PurchaseInvoiceHeader.Get(PostedDocumentNo);
        AssertThat.IsSubstring(PurchaseInvoiceHeader."Posting Description", 'Multiple Vendor Contract');
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsBuyFromVendorPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CreatePurchaseDocumentsPerBuyFromVendor()
    begin
        Initialize();

        //Contract1, Buy-from Vendor1, Pay-to Vendor1
        //Contract2, Buy-from Vendor2, Pay-to Vendor2
        //Contract3, Buy-from Vendor2, Pay-to Vendor1
        //Contract4, Buy-from Vendor3, Pay-to Vendor1
        InitAndCreateBillingDocumentsForMultipleVendorContracts();
        CheckIfPurchaseDocumentsHaveBeenCreated();
        AssertThat.AreEqual(3, PurchaseDocumentCount, 'Purchase Documents were not created correctly');
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsPayToVendorPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CreatePurchaseDocumentsPerPayToVendor()
    begin
        Initialize();

        //Contract1, Buy-from Vendor1, Pay-to Vendor1
        //Contract2, Buy-from Vendor2, Pay-to Vendor2
        //Contract3, Buy-from Vendor2, Pay-to Vendor1
        //Contract4, Buy-from Vendor3, Pay-to Vendor1
        InitAndCreateBillingDocumentsForMultipleVendorContracts();
        CheckIfPurchaseDocumentsHaveBeenCreated();
        AssertThat.AreEqual(2, PurchaseDocumentCount, 'Purchase Documents were not created correctly');
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure PostSalesInvoice()
    begin
        Initialize();

        InitAndCreateBillingDocument(Enum::"Service Partner"::Customer);
        BillingLine.FindLast();
        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesInvoiceHeader.Get(PostedDocumentNo);
        BillingLine.Reset();
        BillingLine.SetRange("Contract No.", CustomerContract."No.");
        asserterror BillingLine.FindFirst();
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure PostPurchaseInvoice()
    begin
        Initialize();

        InitAndCreateBillingDocument(Enum::"Service Partner"::Vendor);
        BillingLine.FindLast();
        PurchaseHeader.Get(Enum::"Purchase Document Type"::Invoice, BillingLine."Document No.");
        PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateGUID());
        PurchaseHeader.Modify(false);
        PostedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        PurchaseInvoiceHeader.Get(PostedDocumentNo);
        BillingLine.Reset();
        BillingLine.SetRange("Contract No.", VendorContract."No.");
        asserterror BillingLine.FindFirst();
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure DeleteSalesDocument()
    begin
        Initialize();

        InitAndCreateBillingDocument(Enum::"Service Partner"::Customer);
        BillingLine.FindLast();
        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
        SalesHeader.Delete(true);
        BillingLine.Reset();
        BillingLine.SetRange("Document Type", Enum::"Rec. Billing Document Type"::Invoice);
        BillingLine.SetRange("Document No.", SalesHeader."No.");
        asserterror BillingLine.FindFirst();
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure DeletePurchaseDocument()
    begin
        Initialize();

        InitAndCreateBillingDocument(Enum::"Service Partner"::Vendor);
        BillingLine.FindLast();
        PurchaseHeader.Get(Enum::"Purchase Document Type"::Invoice, BillingLine."Document No.");
        PurchaseHeader.Delete(true);
        BillingLine.Reset();
        BillingLine.SetRange("Document Type", Enum::"Rec. Billing Document Type"::Invoice);
        BillingLine.SetRange("Document No.", PurchaseHeader."No.");
        asserterror BillingLine.FindFirst();
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure DeleteSalesLine()
    begin
        Initialize();

        InitAndCreateBillingDocument(Enum::"Service Partner"::Customer);
        BillingLine.FindLast();
        FilterSalesLineOnDocumentLine(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.", BillingLine."Document Line No.");
        SalesLine.FindFirst();
        SalesLine.Delete(true);
        BillingLine.Reset();
        BillingLine.SetRange("Document Type", Enum::"Rec. Billing Document Type"::Invoice);
        BillingLine.SetRange("Document No.", SalesLine."Document No.");
        asserterror BillingLine.FindFirst();
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure DeletePurchaseLine()
    begin
        Initialize();

        InitAndCreateBillingDocument(Enum::"Service Partner"::Vendor);
        BillingLine.FindLast();
        FilterPurchaseLineOnDocumentLine(BillingLine.GetPurchaseDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");
        PurchaseLine.FindFirst();
        PurchaseLine.Delete(true);
        BillingLine.Reset();
        BillingLine.SetRange("Document Type", Enum::"Rec. Billing Document Type"::Invoice);
        BillingLine.SetRange("Document No.", PurchaseLine."Document No.");
        asserterror BillingLine.FindFirst();
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CreateSalesDocumentsPerCurrencyCode()
    begin
        Initialize();

        ClearAll();
        ContractTestLibrary.CreateCustomer(Customer2);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract2, ServiceObject2, Customer2."No.");
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract3, ServiceObject3, Customer2."No.");
        CustomerContract3.SetHideValidationDialog(true);
        CustomerContract3.Validate("Currency Code", LibraryERM.CreateCurrencyWithRandomExchRates());
        CustomerContract3.Modify(false);
        CustomerContract2.SetHideValidationDialog(true);
        CustomerContract2.Validate("Currency Code", LibraryERM.CreateCurrencyWithRandomExchRates());
        CustomerContract2.Modify(false);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
        CreateBillingDocuments();
        CheckIfSalesDocumentsHaveBeenCreated();
        AssertThat.AreEqual(2, DocumentsCount, 'Sales Documents were not created correctly');
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CreatePurchaseDocumentsPerCurrencyCode()
    begin
        Initialize();

        ClearAll();
        ContractTestLibrary.CreateVendor(Vendor2);
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract2, ServiceObject2, Vendor2."No.");
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract3, ServiceObject3, Vendor2."No.");
        VendorContract3.SetHideValidationDialog(true);
        VendorContract3.Validate("Currency Code", LibraryERM.CreateCurrencyWithRandomExchRates());
        VendorContract3.Modify(false);
        VendorContract2.SetHideValidationDialog(true);
        VendorContract2.Validate("Currency Code", LibraryERM.CreateCurrencyWithRandomExchRates());
        VendorContract2.Modify(false);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Vendor);
        CreateBillingDocuments();
        CheckIfPurchaseDocumentsHaveBeenCreated();
        AssertThat.AreEqual(2, PurchaseDocumentCount, 'Purchase Documents were not created correctly');
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorChangeBillingToDateWhenDocNoExists()
    begin
        Initialize();

        InitAndCreateBillingDocumentsForMultipleVendorContracts();
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange("Service Object No.", ServiceObject."No.");
        BillingLine.FindFirst();
        asserterror BillingProposal.UpdateBillingToDate(BillingLine, CalcDate('<+3D>', BillingLine."Billing to"));
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnModifySalesHeader()
    begin
        Initialize();

        InitAndCreateBillingDocument(Enum::"Service Partner"::Customer);
        BillingLine.FindLast();
        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
        RRef.GetTable(SalesHeader);
        PopulateArrayOfFieldsForHeaders(true);
        TestDocumentFields(true);

        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesInvoiceHeader.Get(PostedDocumentNo);
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesHeader); //check if its neccessary to test Cr Memo
        RRef.GetTable(SalesHeader);
        TestDocumentFields(true);
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnModifySalesLine()
    var
        SalesInvoiceSubForm: TestPage "Sales Invoice Subform";
        SalesCrMemoSubForm: TestPage "Sales Cr. Memo Subform";
    begin
        Initialize();

        InitAndCreateBillingDocument(Enum::"Service Partner"::Customer);
        BillingLine.FindLast();
        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
        FilterSalesLineOnDocumentLine(BillingLine.GetSalesDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");
        SalesLine.FindFirst();
        RRef.GetTable(SalesLine);
        PopulateArrayOfFieldsForLines();
        TestDocumentFields(true);
        SalesInvoiceSubForm.OpenEdit();
        SalesInvoiceSubForm.GoToRecord(SalesLine);
        asserterror SalesInvoiceSubForm."Invoice Disc. Pct.".SetValue(LibraryRandom.RandInt(10));
        asserterror SalesInvoiceSubForm."Invoice Discount Amount".SetValue(LibraryRandom.RandInt(10));
        SalesInvoiceSubForm.Close();

        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesInvoiceHeader.Get(PostedDocumentNo);
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesHeader); //check if its neccessary to test Cr Memo
        BillingLine.FindLast(); //Retrieve Cr Memo Billing Line
        FilterSalesLineOnDocumentLine(BillingLine.GetSalesDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");
        SalesLine.FindFirst();
        SalesCrMemoSubForm.OpenEdit();
        SalesCrMemoSubForm.GoToRecord(SalesLine);
        asserterror SalesCrMemoSubForm."Invoice Disc. Pct.".SetValue(LibraryRandom.RandInt(10));
        asserterror SalesCrMemoSubForm."Invoice Discount Amount".SetValue(LibraryRandom.RandInt(10));
        SalesCrMemoSubForm.Close();
        RRef.GetTable(SalesLine);
        TestDocumentFields(true);
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnModifyPurchaseHeader()
    begin
        Initialize();

        EmptyArray := false;
        InitAndCreateBillingDocument(Enum::"Service Partner"::Vendor);
        BillingLine.FindLast();
        PurchaseHeader.Get(Enum::"Purchase Document Type"::Invoice, BillingLine."Document No.");
        RRef.GetTable(PurchaseHeader);
        PopulateArrayOfFieldsForHeaders(false);
        TestDocumentFields(false);

        PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateGUID());
        PurchaseHeader.Modify(false);
        PostedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        PurchaseInvoiceHeader.Get(PostedDocumentNo);
        CorrectPostedPurchaseInvoice.CreateCreditMemoCopyDocument(PurchaseInvoiceHeader, PurchaseHeader); //check if its neccessary to test Cr Memo
        RRef.GetTable(PurchaseHeader);
        TestDocumentFields(false);
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnModifyPurchaseLine()
    var
        PurchaseInvoiceSubForm: TestPage "Purch. Invoice Subform";
        PurchaseCrMemoSubForm: TestPage "Purch. Cr. Memo Subform";
    begin
        Initialize();

        InitAndCreateBillingDocument(Enum::"Service Partner"::Vendor);
        BillingLine.FindLast();
        PurchaseHeader.Get(Enum::"Purchase Document Type"::Invoice, BillingLine."Document No.");
        FilterPurchaseLineOnDocumentLine(BillingLine.GetPurchaseDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");
        PurchaseLine.FindFirst();

        PurchaseInvoiceSubForm.OpenEdit();
        PurchaseInvoiceSubForm.GoToRecord(PurchaseLine);
        asserterror PurchaseInvoiceSubForm."Invoice Disc. Pct.".SetValue(LibraryRandom.RandInt(10));
        asserterror PurchaseInvoiceSubForm.InvoiceDiscountAmount.SetValue(LibraryRandom.RandInt(10));
        PurchaseInvoiceSubForm.Close();
        RRef.GetTable(PurchaseLine);
        PopulateArrayOfFieldsForLines();
        TestDocumentFields(true);

        PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateGUID());
        PurchaseHeader.Modify(false);
        PostedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        PurchaseInvoiceHeader.Get(PostedDocumentNo);
        CorrectPostedPurchaseInvoice.CreateCreditMemoCopyDocument(PurchaseInvoiceHeader, PurchaseHeader); //check if its neccessary to test Cr Memo
        BillingLine.FindLast(); //Fetch new BillingLine created for Cr Memo
        FilterPurchaseLineOnDocumentLine(BillingLine.GetPurchaseDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");
        PurchaseLine.FindFirst();

        PurchaseCrMemoSubForm.OpenEdit();
        PurchaseCrMemoSubForm.GoToRecord(PurchaseLine);
        asserterror PurchaseCrMemoSubForm."Invoice Disc. Pct.".SetValue(LibraryRandom.RandInt(10));
        asserterror PurchaseCrMemoSubForm."Invoice Discount Amount".SetValue(LibraryRandom.RandInt(10));
        PurchaseCrMemoSubForm.Close();
        RRef.GetTable(PurchaseLine);
        TestDocumentFields(true);
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckContractTypeIsTranslated()
    var
        Customer: Record Customer;
        ContractType: Record "Contract Type";
        FieldTranslation: Record "Field Translation";
        LanguageMgt: Codeunit Language;
    begin
        Initialize();

        ClearAll();
        ContractTestLibrary.CreateContractType(ContractType);
        ContractTestLibrary.CreateTranslationForField(FieldTranslation, ContractType, ContractType.FieldNo(Description), LanguageMgt.GetLanguageCode(GlobalLanguage));

        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, '');
        CustomerContract.Validate("Contract Type", ContractType.Code);
        CustomerContract.Modify(true);
        Customer.Get(CustomerContract."Bill-to Customer No.");
        Customer.Validate("Language Code", FieldTranslation."Language Code");
        Customer.Modify(false);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
        CreateBillingDocuments();

        BillingLine.Reset();
        BillingLine.FindFirst();
        BillingLine.TestField("Document No.");
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", BillingLine.GetSalesDocumentTypeFromBillingDocumentType());
        SalesLine.SetRange("Document No.", BillingLine."Document No.");
        SalesLine.SetRange(Description, ContractType.Description);
        AssertThat.AreEqual(0, SalesLine.Count, 'Untranslated Contract Type Description found');
        SalesLine.SetRange(Description, FieldTranslation.Translation);
        AssertThat.AreEqual(1, SalesLine.Count, 'Translated Contract Type Description not found');
    end;

    [Test]
    [HandlerFunctions('CreateAndPostCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CreateAndPostSalesDocumentsPerContract()
    begin
        Initialize();

        //Contract1, Sell-to Customer1, Bill-to Customer1
        //Contract2, Sell-to Customer2, Bill-to Customer2
        //Contract3, Sell-to Customer2, Bill-to Customer1
        //Contract4, Sell-to Customer3, Bill-to Customer1
        InitAndCreateBillingDocumentsForMultipleContracts();
        CheckIfPostedSalesDocumentsHaveBeenCreated();
        AssertThat.AreEqual(4, DocumentsCount, 'Posted Sales Documents were not created correctly');
    end;

    [Test]
    [HandlerFunctions('CreateAndPostCustomerBillingDocsSellToCustomerPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CreateAndPostSalesDocumentsPerSellToCustomer()
    begin
        Initialize();

        //Contract1, Sell-to Customer1, Bill-to Customer1
        //Contract2, Sell-to Customer2, Bill-to Customer2
        //Contract3, Sell-to Customer2, Bill-to Customer1
        //Contract4, Sell-to Customer3, Bill-to Customer1
        InitAndCreateBillingDocumentsForMultipleContracts();
        CheckIfPostedSalesDocumentsHaveBeenCreated();
        AssertThat.AreEqual(3, DocumentsCount, 'Posted Sales Documents were not created correctly');
    end;

    [Test]
    [HandlerFunctions('CreateAndPostCustomerBillingDocsBillToCustomerPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CreateAndPostSalesDocumentsPerBillToCustomer()
    begin
        Initialize();

        //Contract1, Sell-to Customer1, Bill-to Customer1
        //Contract2, Sell-to Customer2, Bill-to Customer2
        //Contract3, Sell-to Customer2, Bill-to Customer1
        //Contract4, Sell-to Customer3, Bill-to Customer1
        InitAndCreateBillingDocumentsForMultipleContracts();
        CheckIfPostedSalesDocumentsHaveBeenCreated();
        AssertThat.AreEqual(2, DocumentsCount, 'Posted Sales Documents were not created correctly');
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorBillingLinesForAllCustomerContractLinesExist()
    begin
        Initialize();

        SetupBasicBillingProposal("Service Partner"::Customer);
        asserterror BillingProposal.CreateBillingProposalFromContract(CustomerContract."No.", CustomerContract.GetFilter("Billing Rhythm Filter"), "Service Partner"::Customer);
    end;

    [Test]
    [HandlerFunctions('DialogHandler,ExchangeRateSelectionModalPageHandler,CreateCustomerBillingDocsContractPageHandler,MessageHandler')]
    procedure CheckCustomerBillingProposalCanBeCreatedForSalesInvoiceExists()
    begin
        Initialize();

        //Check if correct dialog opens       
        //Unposted invoice exists
        InitAndCreateBillingDocument("Service Partner"::Customer);
        DialogMsg := UnpostedSalesInvExistsMsg;
        BillingProposal.CreateBillingProposalFromContract(CustomerContract."No.", CustomerContract.GetFilter("Billing Rhythm Filter"), "Service Partner"::Customer);
    end;

    [Test]
    [HandlerFunctions('DialogHandler,ExchangeRateSelectionModalPageHandler,CreateAndPostCustomerBillingDocsContractPageHandler,MessageHandler')]
    procedure CheckCustomerBillingProposalCanBeCreatedForSalesCrMemoExists()
    begin
        Initialize();

        //Check if correct dialog opens       
        //Credit Memo exists
        InitAndCreateBillingDocument("Service Partner"::Customer);
        DialogMsg := SalesCrMemoExistsMsg;
        GetPostedSalesDocumentsFromContract(CustomerContract);
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesHeader);
        BillingProposal.CreateBillingProposalFromContract(CustomerContract."No.", CustomerContract.GetFilter("Billing Rhythm Filter"), "Service Partner"::Customer);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateBillingDocumentPageHandler,MessageHandler')]
    procedure ExpectErrorOnCreateSingleSalesDocumentOnPreviousBillingDate()
    begin
        Initialize();

        ClearAll();
        ContractTestLibrary.ResetContractRecords();
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, '', false);
        GetCustomerContractServiceCommitment(CustomerContract."No.");
        NextBillingToDate := CalcDate('<-1Y>', ServiceCommitment."Next Billing Date");
        BillingProposal.CreateBillingProposalFromContract(CustomerContract."No.", CustomerContract.GetFilter("Billing Rhythm Filter"), "Service Partner"::Customer);
        AssertThat.ExpectedError(NoContractLinesFoundErr);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,CreateBillingDocumentPageHandler')]
    procedure TestBillingLineOnCreateSingleSalesDocument()
    begin
        Initialize();

        ClearAll();
        ContractTestLibrary.ResetContractRecords();
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, '', false);
        GetCustomerContractServiceCommitment(CustomerContract."No.");
        NextBillingToDate := ServiceCommitment."Next Billing Date";
        BillingProposal.CreateBillingProposalFromContract(CustomerContract."No.", CustomerContract.GetFilter("Billing Rhythm Filter"), "Service Partner"::Customer);
        BillingLine.FindLast();
        BillingLine.TestField("Document Type", "Rec. Billing Document Type"::Invoice);
        BillingLine.TestField("Document No.");
        BillingLine.TestField("Billing Template Code", '');
        BillingLine.TestField("Billing to", NextBillingToDate);
        BillingLine.TestField("User ID", UserId);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,CreateBillingDocumentPageHandler')]
    procedure TestDeleteSingleSalesDocument()
    begin
        Initialize();

        ClearAll();
        ContractTestLibrary.ResetContractRecords();
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, '', false);
        GetCustomerContractServiceCommitment(CustomerContract."No.");
        NextBillingToDate := ServiceCommitment."Next Billing Date";
        BillingProposal.CreateBillingProposalFromContract(CustomerContract."No.", CustomerContract.GetFilter("Billing Rhythm Filter"), "Service Partner"::Customer);
        BillingLine.Reset();
        BillingLine.SetRange("Billing Template Code", '');
        BillingLine.FindLast();
        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
        SalesHeader.Delete(true);
        BillingLine.Reset();
        BillingLine.SetRange("Billing Template Code", '');
        asserterror BillingLine.FindLast();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorBillingLinesForAllVendorContractLinesExist()
    begin
        Initialize();

        SetupBasicBillingProposal("Service Partner"::Vendor);
        asserterror BillingProposal.CreateBillingProposalFromContract(VendorContract."No.", VendorContract.GetFilter("Billing Rhythm Filter"), "Service Partner"::Vendor);
    end;

    [Test]
    [HandlerFunctions('DialogHandler,ExchangeRateSelectionModalPageHandler,CreateVendorBillingDocsTestOpenPageHandler,MessageHandler')]
    procedure CheckVendorBillingProposalCanBeCreatedForPurchaseInvoiceExists()
    var
        UnpostedPurchaseInvExistsMsg: Label 'Billing line with unposted Purchase Invoice exists. New invoices cannot be created until the current invoice is posted. Do you want to open the invoice?';
    begin
        Initialize();

        //Check if correct dialog opens       
        //Unposted invoice exists
        InitAndCreateBillingDocument("Service Partner"::Vendor);
        DialogMsg := UnpostedPurchaseInvExistsMsg;
        BillingProposal.CreateBillingProposalFromContract(VendorContract."No.", VendorContract.GetFilter("Billing Rhythm Filter"), "Service Partner"::Vendor);
    end;

    [Test]
    [HandlerFunctions('DialogHandler,ExchangeRateSelectionModalPageHandler,CreateVendorBillingDocsTestOpenPageHandler,MessageHandler')]
    procedure CheckVendorBillingProposalCanBeCreatedForPurchaseCrMemoExists()
    var
        BillingLineArchive: Record "Billing Line Archive";
    begin
        Initialize();

        //Check if correct dialog opens       
        //Credit Memo exists
        PostPurchaseInvoice();
        DialogMsg := PurchCrMemoExistsMsg;
        ContractTestLibrary.FilterBillingLineArchiveOnContractLine(BillingLineArchive, VendorContract."No.", 0, Enum::"Service Partner"::Vendor);
        BillingLineArchive.FindFirst();
        PurchaseInvoiceHeader.Get(BillingLineArchive."Document No.");
        CorrectPostedPurchaseInvoice.CreateCreditMemoCopyDocument(PurchaseInvoiceHeader, PurchaseHeader);
        BillingProposal.CreateBillingProposalFromContract(VendorContract."No.", VendorContract.GetFilter("Billing Rhythm Filter"), "Service Partner"::Vendor);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,CreateBillingDocumentPageHandler')]
    procedure ExpectErrorOnCreateSinglePurchaseDocumentOnPreviousBillingDate()
    begin
        Initialize();

        ClearAll();
        ContractTestLibrary.ResetContractRecords();
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, '', false);
        GetVendorContractServiceCommitment(VendorContract."No.");
        NextBillingToDate := CalcDate('<-1Y>', ServiceCommitment."Next Billing Date");
        BillingProposal.CreateBillingProposalFromContract(VendorContract."No.", VendorContract.GetFilter("Billing Rhythm Filter"), "Service Partner"::Vendor);
        AssertThat.ExpectedError(NoContractLinesFoundErr);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,CreateBillingDocumentPageHandler')]
    procedure TestBillingLineOnCreateSinglePurchaseDocument()
    begin
        Initialize();

        ClearAll();
        ContractTestLibrary.ResetContractRecords();
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, '', false);
        GetVendorContractServiceCommitment(VendorContract."No.");
        NextBillingToDate := ServiceCommitment."Next Billing Date";
        BillingProposal.CreateBillingProposalFromContract(VendorContract."No.", VendorContract.GetFilter("Billing Rhythm Filter"), "Service Partner"::Vendor);
        BillingLine.FindLast();
        BillingLine.TestField("Document Type", "Rec. Billing Document Type"::Invoice);
        BillingLine.TestField("Document No.");
        BillingLine.TestField("Billing Template Code", '');
        BillingLine.TestField("Billing to", NextBillingToDate);
        BillingLine.TestField("User ID", UserId);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,CreateBillingDocumentPageHandler')]
    procedure TestDeleteSinglePurchaseDocument()
    begin
        Initialize();

        ClearAll();
        ContractTestLibrary.ResetContractRecords();
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, '', false);
        GetVendorContractServiceCommitment(VendorContract."No.");
        NextBillingToDate := ServiceCommitment."Next Billing Date";
        BillingProposal.CreateBillingProposalFromContract(VendorContract."No.", VendorContract.GetFilter("Billing Rhythm Filter"), "Service Partner"::Vendor);
        BillingLine.Reset();
        BillingLine.SetRange("Billing Template Code", '');
        BillingLine.FindLast();
        PurchaseHeader.Get(Enum::"Purchase Document Type"::Invoice, BillingLine."Document No.");
        PurchaseHeader.Delete(true);
        BillingLine.Reset();
        BillingLine.SetRange("Billing Template Code", '');
        asserterror BillingLine.FindLast();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,CreateVendorBillingDocsContractPageHandler,BillingLinesArchivePageHandler')]
    procedure TestOpenBillingLinesArchiveFromPurchaseInvoice()
    var
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        Initialize();

        ContractTestLibrary.InitContractsApp();
        InitAndCreateBillingDocumentsForMultipleVendorContracts();
        BillingLine.Reset();
        BillingLine.FindSet();
        repeat
            PurchaseHeader.Get(Enum::"Purchase Document Type"::Invoice, BillingLine."Document No.");
            PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateGUID());
            PurchaseHeader.Modify(false);
            PostedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true)
        until BillingLine.Next() = 0;
        PurchInvLine.SetRange("Document No.", PostedDocumentNo);
        PurchInvLine.SetFilter("Contract No.", '<>%1', '');
        PurchInvLine.SetFilter("Contract Line No.", '<>%1', 0);
        PurchInvLine.FindFirst();
        ExpectedNoOfArchivedLines := CountBillingArchiveLinesOnDocument(Enum::"Rec. Billing Document Type"::Invoice, PostedDocumentNo, "Service Partner"::Vendor, PurchInvLine."Contract No.", PurchInvLine."Contract Line No.");
        ContractsGeneralMgt.ShowArchivedBillingLines(PurchInvLine."Contract No.", PurchInvLine."Contract Line No.", "Service Partner"::Vendor, Enum::"Rec. Billing Document Type"::Invoice, PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,CreateVendorBillingDocsContractPageHandler,BillingLinesArchivePageHandler')]
    procedure TestOpenBillingLinesArchiveFromPurchaseCreditMemo()
    var
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
    begin
        Initialize();

        ContractTestLibrary.InitContractsApp();
        InitAndCreateBillingDocumentsForMultipleVendorContracts();
        BillingLine.Reset();
        BillingLine.FindSet();
        repeat
            PurchaseHeader.Get(Enum::"Purchase Document Type"::Invoice, BillingLine."Document No.");
            PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateGUID());
            PurchaseHeader.Modify(false);
            PostedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
            PurchaseInvoiceHeader.Get(PostedDocumentNo);
            CorrectPostedPurchaseInvoice.CreateCreditMemoCopyDocument(PurchaseInvoiceHeader, PurchaseHeader);
            PurchaseHeader.Validate("Vendor Cr. Memo No.", LibraryUtility.GenerateGUID());
            PurchaseHeader.Modify(false);
            PostedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        until BillingLine.Next() = 0;
        PurchCrMemoLine.SetRange("Document No.", PostedDocumentNo);
        PurchCrMemoLine.SetFilter("Contract No.", '<>%1', '');
        PurchCrMemoLine.SetFilter("Contract Line No.", '<>%1', 0);
        PurchCrMemoLine.FindFirst();
        ExpectedNoOfArchivedLines := CountBillingArchiveLinesOnDocument(Enum::"Rec. Billing Document Type"::"Credit Memo", PostedDocumentNo, "Service Partner"::Vendor, PurchCrMemoLine."Contract No.", PurchCrMemoLine."Contract Line No.");
        ContractsGeneralMgt.ShowArchivedBillingLines(PurchCrMemoLine."Contract No.", PurchCrMemoLine."Contract Line No.", "Service Partner"::Vendor, Enum::"Rec. Billing Document Type"::"Credit Memo", PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,CreateCustomerBillingDocsContractPageHandler,BillingLinesArchivePageHandler')]
    procedure TestOpenBillingLinesArchiveFromSalesInvoice()
    var
        SalesInvLine: Record "Sales Invoice Line";
    begin
        Initialize();

        ContractTestLibrary.InitContractsApp();
        InitAndCreateBillingDocumentsForMultipleContracts();
        BillingLine.Reset();
        BillingLine.FindSet();
        repeat
            SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
            PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true)
        until BillingLine.Next() = 0;
        SalesInvLine.SetRange("Document No.", PostedDocumentNo);
        SalesInvLine.SetFilter("Contract No.", '<>%1', '');
        SalesInvLine.SetFilter("Contract Line No.", '<>%1', 0);
        SalesInvLine.FindFirst();
        ExpectedNoOfArchivedLines := CountBillingArchiveLinesOnDocument(Enum::"Rec. Billing Document Type"::Invoice, PostedDocumentNo, "Service Partner"::Customer, SalesInvLine."Contract No.", SalesInvLine."Contract Line No.");
        ContractsGeneralMgt.ShowArchivedBillingLines(SalesInvLine."Contract No.", SalesInvLine."Contract Line No.", "Service Partner"::Customer, Enum::"Rec. Billing Document Type"::Invoice, PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,CreateCustomerBillingDocsContractPageHandler,BillingLinesArchivePageHandler')]
    procedure TestOpenBillingLinesArchiveFromSalesCreditMemo()
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        Initialize();

        ContractTestLibrary.InitContractsApp();
        InitAndCreateBillingDocumentsForMultipleContracts();
        BillingLine.Reset();
        BillingLine.FindSet();
        repeat
            SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
            PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
            SalesInvoiceHeader.Get(PostedDocumentNo);
            CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesHeader);
            PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        until BillingLine.Next() = 0;
        SalesCrMemoLine.SetRange("Document No.", PostedDocumentNo);
        SalesCrMemoLine.SetFilter("Contract No.", '<>%1', '');
        SalesCrMemoLine.SetFilter("Contract Line No.", '<>%1', 0);
        SalesCrMemoLine.FindFirst();
        ExpectedNoOfArchivedLines := CountBillingArchiveLinesOnDocument(Enum::"Rec. Billing Document Type"::"Credit Memo", PostedDocumentNo, "Service Partner"::Customer, SalesCrMemoLine."Contract No.", SalesCrMemoLine."Contract Line No.");
        ContractsGeneralMgt.ShowArchivedBillingLines(SalesCrMemoLine."Contract No.", SalesCrMemoLine."Contract Line No.", "Service Partner"::Customer, "Rec. Billing Document Type"::"Credit Memo", PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnServiceObjectDescriptionChangeWhenUnpostedDocumentsExistCustomer()
    begin
        Initialize();

        InitAndCreateBillingDocument("Service Partner"::Customer);
        CheckIfSalesDocumentsHaveBeenCreated();
        asserterror ServiceObject.Validate(Description, LibraryRandom.RandText(MaxStrLen(ServiceObject.Description)));
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnServiceObjectDescriptionChangeWhenUnpostedDocumentsExistVendor()
    begin
        Initialize();

        InitAndCreateBillingDocument("Service Partner"::Vendor);
        CheckIfPurchaseDocumentsHaveBeenCreated();
        asserterror ServiceObject.Validate(Description, LibraryRandom.RandText(MaxStrLen(ServiceObject.Description)));
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestRecurringBillingInCustLedgerEntries()
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        Initialize();

        InitAndCreateBillingDocument(Enum::"Service Partner"::Customer);
        BillingLine.FindLast();
        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        CustLedgEntry.SetRange("Document Type", CustLedgEntry."Document Type"::Invoice);
        CustLedgEntry.SetRange("Document No.", PostedDocumentNo);
        CustLedgEntry.FindSet();
        CustLedgEntry.TestField("Recurring Billing", true);
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestRecurringBillingInVendorLedgerEntries()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        Initialize();

        InitAndCreateBillingDocument(Enum::"Service Partner"::Vendor);
        BillingLine.FindLast();
        PurchaseHeader.Get(Enum::"Purchase Document Type"::Invoice, BillingLine."Document No.");
        PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateGUID());
        PurchaseHeader.Modify(false);
        PostedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice);
        VendorLedgerEntry.SetRange("Document No.", PostedDocumentNo);
        VendorLedgerEntry.FindSet();
        VendorLedgerEntry.TestField("Recurring Billing", true);
    end;

    [Test]
    procedure TestPostingPurchaseInvoiceFromGeneralJournal()
    var
        GeneralJournalLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        Vendor: Record Vendor;
        GLAccount: Record "G/L Account";
    begin
        Initialize();

        //Expect that posting of simple general journal is not affected with Recurring billing field in Vendor Ledger Entries
        //Ref. IC230221) Posting of Recurring General Journal fails
        LibraryPurchase.CreateVendor(Vendor);
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryERM.CreateGeneralJnlLine(GeneralJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name, Enum::"Gen. Journal Document Type"::Invoice,
                                        Enum::"Gen. Journal Account Type"::Vendor, Vendor."No.", -100);
        LibraryERM.CreateGLAccount(GLAccount);
        GeneralJournalLine."Bal. Account Type" := GeneralJournalLine."Bal. Account Type"::"G/L Account";
        GeneralJournalLine."Bal. Account No." := GLAccount."No.";
        GeneralJournalLine.Modify(false);
        LibraryERM.PostGeneralJnlLine(GeneralJournalLine);
    end;

    [Test]
    procedure TestPostingSalesInvoiceFromGeneralJournal()
    var
        GeneralJournalLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        Customer: Record Customer;
        GLAccount: Record "G/L Account";
    begin
        Initialize();

        //Expect that posting of simple general journal is not affected with Recurring billing field in Customer Ledger Entries
        //Ref. IC230221) Posting of Recurring General Journal fails
        LibrarySales.CreateCustomer(Customer);
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryERM.CreateGeneralJnlLine(GeneralJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name, Enum::"Gen. Journal Document Type"::Invoice,
                                        Enum::"Gen. Journal Account Type"::Customer, Customer."No.", 100);
        LibraryERM.CreateGLAccount(GLAccount);
        GeneralJournalLine."Bal. Account Type" := GeneralJournalLine."Bal. Account Type"::"G/L Account";
        GeneralJournalLine."Bal. Account No." := GLAccount."No.";
        GeneralJournalLine.Modify(false);
        LibraryERM.PostGeneralJnlLine(GeneralJournalLine);
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckContractSalesInvoiceDescriptions()
    var
        ServiceContractSetup: Record "Service Contract Setup";
        ItemAttribute: Record "Item Attribute";
        ItemAttribute2: Record "Item Attribute";
        ItemAttributeValue: Record "Item Attribute Value";
        ItemAttributeValue2: Record "Item Attribute Value";
        ParentSalesLine: Record "Sales Line";
        CustomerNo: Code[20];
    begin
        Initialize();

        // Test: Sales Invoice Line Description and attached lines are created according to setup
        ClearAll();
        BillingLine.Reset();
        if not BillingLine.IsEmpty() then
            BillingLine.DeleteAll(false);

        ServiceContractSetup.Get();
        ServiceContractSetup."Contract Invoice Description" := Enum::"Contract Invoice Text Type"::"Service Commitment";
        ServiceContractSetup."Contract Invoice Add. Line 1" := Enum::"Contract Invoice Text Type"::"Billing Period";
        ServiceContractSetup."Contract Invoice Add. Line 2" := Enum::"Contract Invoice Text Type"::"Service Object";
        ServiceContractSetup."Contract Invoice Add. Line 3" := Enum::"Contract Invoice Text Type"::"Serial No.";
        ServiceContractSetup."Contract Invoice Add. Line 4" := Enum::"Contract Invoice Text Type"::"Customer Reference";
        ServiceContractSetup."Contract Invoice Add. Line 5" := Enum::"Contract Invoice Text Type"::"Primary attribute";
        ServiceContractSetup.Modify(false);

        CustomerNo := '';
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, CustomerNo);
        ServiceObject."Customer Reference" := CopyStr(LibraryRandom.RandText(MaxStrLen(ServiceObject."Customer Reference")), 1, MaxStrLen(ServiceObject."Customer Reference"));
        ServiceObject."Serial No." := CopyStr(LibraryRandom.RandText(MaxStrLen(ServiceObject."Serial No.")), 1, MaxStrLen(ServiceObject."Serial No."));
        ServiceObject.Modify(false);

        ContractTestLibrary.CreateServiceObjectAttributeMappedToServiceObject(ServiceObject."No.", ItemAttribute, ItemAttributeValue, false);
        ContractTestLibrary.CreateServiceObjectAttributeMappedToServiceObject(ServiceObject."No.", ItemAttribute2, ItemAttributeValue2, true);

        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);

        CreateBillingDocuments(false);

        BillingLine.Reset();
        BillingLine.FindFirst();
        BillingLine.TestField("Document Type", BillingLine."Document Type"::Invoice);

        SalesLine.Reset();
        FilterSalesLineOnDocumentLine(BillingLine.GetSalesDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");
        AssertThat.AreEqual(1, SalesLine.Count, 'The Sales lines were not created properly.');
        SalesLine.FindFirst();
        SalesLine.TestField(Description, BillingLine."Service Commitment Description");
        SalesLine.TestField("Description 2", '');

        SalesLine2.Reset();
        SalesLine2.SetRange("Document Type", SalesLine."Document Type");
        SalesLine2.SetRange("Document No.", SalesLine."Document No.");
        SalesLine2.SetRange("Attached to Line No.", SalesLine."Line No.");
        AssertThat.AreEqual(5, SalesLine2.Count, 'Setup-failure: expected five attached Lines.');
        SalesLine2.FindSet();
        // 1st line: Service Period
        AssertThat.IsSubstring(SalesLine2.Description, 'Service period');
        ParentSalesLine.Get(SalesLine2."Document Type", SalesLine2."Document No.", SalesLine2."Attached to Line No.");
        SalesLine2.Next();
        // 2nd line: Service Object Description
        AssertThat.AreEqual(SalesLine2.Description, ServiceObject.Description, 'Description does not match expected value');
        ParentSalesLine.Get(SalesLine2."Document Type", SalesLine2."Document No.", SalesLine2."Attached to Line No.");
        SalesLine2.Next();
        // 3rd line: Serial No.
        AssertThat.IsSubstring(SalesLine2.Description, ServiceObject."Serial No.");
        ParentSalesLine.Get(SalesLine2."Document Type", SalesLine2."Document No.", SalesLine2."Attached to Line No.");
        SalesLine2.Next();
        // 4th line: Customer Reference
        AssertThat.IsSubstring(SalesLine2.Description, ServiceObject."Customer Reference");
        ParentSalesLine.Get(SalesLine2."Document Type", SalesLine2."Document No.", SalesLine2."Attached to Line No.");
        SalesLine2.Next();
        // 5th line: Primary Attribute
        AssertThat.IsSubstring(ServiceObject.GetPrimaryAttributeValue(), SalesLine2.Description);
        ParentSalesLine.Get(SalesLine2."Document Type", SalesLine2."Document No.", SalesLine2."Attached to Line No.");
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckContractZeroNamesAreTransferredToSalesDocumentOnBillingPerContractOptionsOff()
    var
        FieldValueNotExpectedTxt: Label '"%1" should not be present as a description-line', Locked = true;
    begin
        Initialize();

        // Test: Names are NOT transferred as Description Lines in Sales Document (Create per Contract (see PageHandler), both options off)
        ClearAll();
        PrepareCustomerContractWithNames();

        CustomerContract."Contractor Name in coll. Inv." := false;
        CustomerContract."Recipient Name in coll. Inv." := false;
        CustomerContract.Modify(false);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);

        AssertThat.AreEqual(0, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Sell-to Customer Name"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Sell-to Customer Name")));
        AssertThat.AreEqual(0, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Sell-to Customer Name 2"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Sell-to Customer Name 2")));
        AssertThat.AreEqual(0, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Ship-to Name"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Ship-to Name")));
        AssertThat.AreEqual(0, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Ship-to Name 2"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Ship-to Name 2")));
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsBillToCustomerPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckContractZeroNamesAreTransferredToSalesDocumentOnBillingPerBillToContractOptionsOff()
    var
        FieldValueNotExpectedTxt: Label '"%1" should not be present as a description-line', Locked = true;
    begin
        Initialize();

        // Test: Names are NOT transferred as Description Lines in Sales Document (Create per bill-to (see PageHandler), both options off)
        ClearAll();
        PrepareCustomerContractWithNames();

        CustomerContract."Contractor Name in coll. Inv." := false;
        CustomerContract."Recipient Name in coll. Inv." := false;
        CustomerContract.Modify(false);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);

        AssertThat.AreEqual(0, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Sell-to Customer Name"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Sell-to Customer Name")));
        AssertThat.AreEqual(0, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Sell-to Customer Name 2"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Sell-to Customer Name 2")));
        AssertThat.AreEqual(0, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Ship-to Name"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Ship-to Name")));
        AssertThat.AreEqual(0, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Ship-to Name 2"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Ship-to Name 2")));
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckContractZeroNamesAreTransferredToSalesDocumentOnBillingPerContractOptionsOn()
    var
        FieldValueNotExpectedTxt: Label '"%1" should not be present as a description-line', Locked = true;
    begin
        Initialize();

        // Test: Names are NOT transferred as Description Lines in Sales Document (Create per Contract (see PageHandler), both options on)
        ClearAll();
        PrepareCustomerContractWithNames();

        CustomerContract."Contractor Name in coll. Inv." := true;
        CustomerContract."Recipient Name in coll. Inv." := true;
        CustomerContract.Modify(false);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);

        AssertThat.AreEqual(0, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Sell-to Customer Name"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Sell-to Customer Name")));
        AssertThat.AreEqual(0, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Sell-to Customer Name 2"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Sell-to Customer Name 2")));
        AssertThat.AreEqual(0, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Ship-to Name"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Ship-to Name")));
        AssertThat.AreEqual(0, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Ship-to Name 2"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Ship-to Name 2")));
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsBillToCustomerPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckContractNamesAreTransferredToSalesDocumentOnBillingPerBillToContractOptionsOn()
    var
        FieldValueNotExpectedTxt: Label '"%1" should be present (once) as a description-line', Locked = true;
    begin
        Initialize();

        // Test: Names are transferred as Description Lines in Sales Document (Create per bill-to (see PageHandler), both options on)
        ClearAll();
        PrepareCustomerContractWithNames();

        CustomerContract."Contractor Name in coll. Inv." := true;
        CustomerContract."Recipient Name in coll. Inv." := true;
        CustomerContract.Modify(false);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);

        AssertThat.AreEqual(1, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Sell-to Customer Name"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Sell-to Customer Name")));
        AssertThat.AreEqual(1, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Sell-to Customer Name 2"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Sell-to Customer Name 2")));
        AssertThat.AreEqual(1, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Ship-to Name"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Ship-to Name")));
        AssertThat.AreEqual(1, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Ship-to Name 2"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Ship-to Name 2")));
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckIfBillingLinesAreDeletedOnCreateCustomerInvoiceWithError()
    var
        Customer: Record Customer;
    begin
        Initialize();

        ClearAll();
        ContractTestLibrary.ResetContractRecords();
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.");
        Customer."Customer Posting Group" := '';
        Customer.Modify(false);
        asserterror CustomerContract.CreateBillingProposal();

        //Check if Billing lines for customer contract are empty
        BillingLine.Reset();
        BillingLine.SetRange("Billing Template Code", '');
        BillingLine.SetRange("Contract No.", CustomerContract."No.");
        asserterror BillingLine.FindSet();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,CreateCustomerBillingDocsContractPageHandler,BillingLinesArchivePageHandler')]
    procedure TestShowBillingLineArchiveFromServiceCommitment()
    var
        BillingLineArchive: Record "Billing Line Archive";
    begin
        Initialize();

        ContractTestLibrary.InitContractsApp();
        InitAndCreateBillingDocumentsForMultipleContracts();
        BillingLine.Reset();
        BillingLine.FindSet();
        repeat
            SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
            LibrarySales.PostSalesDocument(SalesHeader, true, true)
        until BillingLine.Next() = 0;

        CustomerContractLine.SetRange("Contract No.", CustomerContract."No.");
        CustomerContractLine.SetRange("Contract Line Type", Enum::"Contract Line Type"::"Service Commitment");
        CustomerContractLine.FindFirst();
        ExpectedNoOfArchivedLines := CountBillingArchiveLinesOnServiceCommitment(CustomerContractLine."Service Commitment Entry No.");
        ContractsGeneralMgt.ShowArchivedBillingLinesForServiceCommitment(CustomerContractLine."Service Commitment Entry No.");

        CustomerContractLine.GetServiceCommitment(ServiceCommitment);
        //Force Close service commitment
        ServiceCommitment."Service End Date" := CalcDate('<-1D>', Today());
        ServiceCommitment."Next Billing Date" := CalcDate('<+1D>', ServiceCommitment."Service End Date");
        ServiceCommitment.Modify(false);
        ServiceObject.UpdateServicesDates();
        ServiceCommitment.Delete(true);

        BillingLineArchive.FilterBillingLineArchiveOnServiceCommitment(CustomerContractLine."Service Commitment Entry No.");
        AssertThat.RecordIsEmpty(BillingLineArchive);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,ConfirmHandler,MessageHandler,CreateCustomerBillingDocsContractPageHandler,BillingLinesArchivePageHandler')]
    procedure TestShowBillingLineArchiveFromRecreatedCustomerContractLine()
    var
        LineNo: Integer;
    begin
        Initialize();

        ContractTestLibrary.InitContractsApp();
        InitAndCreateBillingDocumentsForMultipleContracts();
        BillingLine.Reset();
        BillingLine.FindSet();
        repeat
            SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
            LibrarySales.PostSalesDocument(SalesHeader, true, true)
        until BillingLine.Next() = 0;

        CustomerContractLine.SetRange("Contract No.", CustomerContract."No.");
        CustomerContractLine.SetRange("Contract Line Type", Enum::"Contract Line Type"::"Service Commitment");
        CustomerContractLine.FindFirst();
        ExpectedNoOfArchivedLines := CountBillingArchiveLinesOnServiceCommitment(CustomerContractLine."Service Commitment Entry No.");
        ContractsGeneralMgt.ShowArchivedBillingLinesForServiceCommitment(CustomerContractLine."Service Commitment Entry No.");

        CustomerContractLine.GetServiceCommitment(ServiceCommitment);
        //Force Close service commitment
        ServiceCommitment."Service End Date" := CalcDate('<-1D>', Today());
        ServiceCommitment."Next Billing Date" := CalcDate('<+1D>', ServiceCommitment."Service End Date");
        ServiceCommitment.Modify(false);
        ServiceObject.UpdateServicesDates();

        //Delete customer contract line
        //create a new line with same line no
        LineNo := CustomerContractLine."Line No.";
        CustomerContractLine.Get(CustomerContractLine."Contract No.", CustomerContractLine."Line No.");
        CustomerContractLine.Delete(true);
        CustomerContractLine.Init();
        CustomerContractLine."Contract No." := CustomerContract."No.";
        CustomerContractLine."Line No." := LineNo;
        CustomerContractLine."Contract Line Type" := Enum::"Contract Line Type"::Comment;
        CustomerContractLine.Insert(false);

        ExpectedNoOfArchivedLines := 0;
        ContractsGeneralMgt.ShowArchivedBillingLinesForServiceCommitment(CustomerContractLine."Service Commitment Entry No.");
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,ConfirmHandler,MessageHandler,CreateVendorBillingDocsContractPageHandler,BillingLinesArchivePageHandler')]
    procedure TestShowBillingLineArchiveFromRecreatedVendorContractLine()
    var
        LineNo: Integer;
    begin
        Initialize();

        ContractTestLibrary.InitContractsApp();
        InitAndCreateBillingDocumentsForMultipleVendorContracts();
        BillingLine.Reset();
        BillingLine.FindSet();
        repeat
            PurchaseHeader.Get(Enum::"Purchase Document Type"::Invoice, BillingLine."Document No.");
            PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateGUID());
            PurchaseHeader.Modify(false);
            LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        until BillingLine.Next() = 0;

        VendorContractLine.SetRange("Contract No.", VendorContract."No.");
        VendorContractLine.SetRange("Contract Line Type", Enum::"Contract Line Type"::"Service Commitment");
        VendorContractLine.FindFirst();
        ExpectedNoOfArchivedLines := CountBillingArchiveLinesOnServiceCommitment(VendorContractLine."Service Commitment Entry No.");
        ContractsGeneralMgt.ShowArchivedBillingLinesForServiceCommitment(VendorContractLine."Service Commitment Entry No.");

        VendorContractLine.GetServiceCommitment(ServiceCommitment);
        //Force Close service commitment
        ServiceCommitment."Service End Date" := CalcDate('<-1D>', Today());
        ServiceCommitment."Next Billing Date" := CalcDate('<+1D>', ServiceCommitment."Service End Date");
        ServiceCommitment.Modify(false);
        ServiceObject.UpdateServicesDates();

        //Delete vendor contract line
        //create a new line with same line no
        LineNo := VendorContractLine."Line No.";
        VendorContractLine.Get(VendorContractLine."Contract No.", VendorContractLine."Line No.");
        VendorContractLine.Delete(true);
        VendorContractLine.Init();
        VendorContractLine."Contract No." := CustomerContract."No.";
        VendorContractLine."Line No." := LineNo;
        VendorContractLine."Contract Line Type" := Enum::"Contract Line Type"::Comment;
        VendorContractLine.Insert(false);

        ExpectedNoOfArchivedLines := 0;
        ContractsGeneralMgt.ShowArchivedBillingLinesForServiceCommitment(VendorContractLine."Service Commitment Entry No.");
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler')]
    procedure TestBillingLinesWithInvoiceDocumentType()
    var
        Item: Record Item;
        ServiceCommitmentTemplate: Record "Service Commitment Template";
        ServiceCommitmentPackage: Record "Service Commitment Package";
        ServiceCommPackageLine: Record "Service Comm. Package Line";
    begin
        Initialize();

        ClearAll();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ServiceCommitmentTemplate."Invoicing Item No." := Item."No.";
        ServiceCommitmentTemplate."Calculation Base %" := LibraryRandom.RandDecInRange(0, 100, 2);
        Evaluate(ServiceCommitmentTemplate."Billing Base Period", '<12M>');
        ServiceCommitmentTemplate.Modify(false);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ServiceCommPackageLine."Calculation Base Type" := ServiceCommPackageLine."Calculation Base Type"::"Document Price";
        ContractTestLibrary.InitServiceCommitmentPackageLineFields(ServiceCommPackageLine);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code, true);

        CreateAndPostSimpleSalesDocument(Item."No.");
        CreateCustomerContractAndAssignServiceObjects(Item."No.");
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer, WorkDate());
        CreateBillingDocuments();

        BillingLine.Reset();
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange(Partner, BillingLine.Partner::Customer);
        BillingLine.SetRange("Contract No.", CustomerContract."No.");
        BillingLine.FindSet();
        repeat
            BillingLine.TestField("Document Type", BillingLine."Document Type"::Invoice);
        until BillingLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler')]
    procedure TestBillingLinesWithCreditMemoDocumentType()
    var
        Item: Record Item;
        ServiceCommitmentTemplate: Record "Service Commitment Template";
        ServiceCommitmentPackage: Record "Service Commitment Package";
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        PreviousNextBillingDate: Date;
        InitialNextBillingDate: Date;
    begin
        Initialize();

        ClearAll();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ServiceCommitmentTemplate."Invoicing Item No." := Item."No.";
        ServiceCommitmentTemplate."Calculation Base %" := LibraryRandom.RandDecInRange(0, 100, 2);
        Evaluate(ServiceCommitmentTemplate."Billing Base Period", '<12M>');
        ServiceCommitmentTemplate.Modify(false);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ServiceCommPackageLine."Calculation Base Type" := ServiceCommPackageLine."Calculation Base Type"::"Document Price";
        ContractTestLibrary.InitServiceCommitmentPackageLineFields(ServiceCommPackageLine);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code, true);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", 1);
        SalesLine.Validate("Unit Price", -50);
        SalesLine.Modify(false);
        LibrarySales.PostSalesDocument(SalesHeader, true, false);
        CreateCustomerContractAndAssignServiceObjects(Item."No.");
        InitialNextBillingDate := ServiceCommitment."Next Billing Date";

        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer, WorkDate());
        CreateBillingDocuments();

        BillingLine.Reset();
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange(Partner, BillingLine.Partner::Customer);
        BillingLine.SetRange("Contract No.", CustomerContract."No.");
        BillingLine.FindSet();
        repeat
            BillingLine.TestField("Document Type", BillingLine."Document Type"::"Credit Memo");
        until BillingLine.Next() = 0;
        CustomerContractLine.Get(BillingLine."Contract No.", BillingLine."Contract Line No."); //Save Customer Contract Line

        FilterSalesLineOnDocumentLine(BillingLine.GetSalesDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");
        SalesLine.SetRange(Type, "Sales Line Type"::Item);
        SalesLine.FindSet();
        if SalesLine."Line Amount" < 0 then
            Error('Unit Price and Line Amount in Credit memo have wrong sign');
        CustomerContractLine.GetServiceCommitment(ServiceCommitment);
        PreviousNextBillingDate := ServiceCommitment."Next Billing Date";

        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        SalesHeader.Delete(true);
        CustomerContractLine.GetServiceCommitment(ServiceCommitment);
        AssertThat.AreEqual(ServiceCommitment."Next Billing Date", PreviousNextBillingDate, 'Next billing date was updated when Sales Document is deleted');

        BillingLine.FindLast();
        repeat
            BillingLine.Delete(true);
        until BillingLine.Next(-1) = 0;
        CustomerContractLine.GetServiceCommitment(ServiceCommitment);
        AssertThat.AreEqual(ServiceCommitment."Next Billing Date", InitialNextBillingDate, 'Next billing date was not updated when billing line is deleted');
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestBillingLinesAreDeletedForCreditMemos()
    var
        Item: Record Item;
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        Assert: Codeunit Assert;
    begin
        Initialize();

        // Test: When a Credit Memo (created directly from a Contract) is deleted, all linked Billing Lines should also be deleted
        Clear(SalesHeader);
        Clear(CustomerContract);

        ServiceCommPackageLine.Reset();
        if not ServiceCommPackageLine.IsEmpty() then
            ServiceCommPackageLine.DeleteAll(false);
        ContractTestLibrary.CreateServiceObjectItemWithServiceCommitments(Item);
        ServiceCommPackageLine.FindFirst();
        ServiceCommPackageLine.Validate("Calculation Base Type", ServiceCommPackageLine."Calculation Base Type"::"Document Price");
        ServiceCommPackageLine."Invoicing Item No." := Item."No.";
        ServiceCommPackageLine.Validate("Calculation Base %", 100);
        ServiceCommPackageLine.Modify(true);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", 1);
        SalesLine.Validate("Unit Price", -1200);
        SalesLine.Modify(true);
        LibrarySales.PostSalesDocument(SalesHeader, true, false);
        CreateCustomerContractAndAssignServiceObjects(Item."No.");

        CustomerContract.TestField("No.");
        ServiceObject.TestField("No.");
        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();
        if ServiceCommitment."Calculation Base Amount" >= 0 then
            Error('Setup-Failure: negative "Calculation Base Amount" expected for Service Commitment.');

        BillingProposal.CreateBillingProposalForContract(
            Enum::"Service Partner"::Customer,
            CustomerContract."No.",
            '',
            '',
            CalcDate('<+CY>', WorkDate()),
            CalcDate('<+CY>', WorkDate()));
        if not BillingProposal.CreateBillingDocument(
            Enum::"Service Partner"::Customer,
            CustomerContract."No.",
            CalcDate('<+CY>', WorkDate()),
            CalcDate('<+CY>', WorkDate()),
            false,
            false)
        then
            Error(GetLastErrorText());

        CustomerContract.TestField("No.");
        BillingLine.Reset();
        BillingLine.SetRange("Contract No.", CustomerContract."No.");
        Assert.AreEqual(1, BillingLine.Count, 'Setup-failure, creating billing document: expected one billing line');
        BillingLine.SetLoadFields("Document Type", "Document No.", "Billing Template Code");
        BillingLine.FindFirst();
        Assert.AreEqual(BillingLine."Document Type"::"Credit Memo", BillingLine."Document Type", 'Setup-failure, creating billing document: expected a credit memo to be created');
        BillingLine.TestField("Document No.");
        BillingLine.TestField("Billing Template Code", '');
        SalesHeader.Get(SalesHeader."Document Type"::"Credit Memo", BillingLine."Document No.");
        SalesHeader.Delete(true);
        Assert.AreEqual(0, BillingLine.Count, 'Zero remaining billing lines expected after deleting the credit memo.');
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckBatchDeleteAllContractDocuments()
    begin
        Initialize();

        // Test: multiple Sales- and Purchase-Contract Documents can be batch-deleted by using the function from the recurring billing page
        InitAndCreateBillingDocument(Enum::"Service Partner"::Customer);
        InitAndCreateBillingDocument(Enum::"Service Partner"::Customer);
        InitAndCreateBillingDocument(Enum::"Service Partner"::Vendor);
        InitAndCreateBillingDocument(Enum::"Service Partner"::Vendor);

        BillingProposal.DeleteBillingDocuments(1, false); // Selection: 1 = "All Documents"

        AssertThat.AreEqual(0, GetNumberOfContractDocumentsSales(Enum::"Sales Document Type"::Invoice), 'Failed to delete all Sales Contract Invoices');
        AssertThat.AreEqual(0, GetNumberOfContractDocumentsSales(Enum::"Sales Document Type"::"Credit Memo"), 'Failed to delete all Sales Contract Credit Memos');
        AssertThat.AreEqual(0, GetNumberOfContractDocumentsPurchase(Enum::"Purchase Document Type"::Invoice), 'Failed to delete all Purchase Contract Invoices');
        AssertThat.AreEqual(0, GetNumberOfContractDocumentsPurchase(Enum::"Purchase Document Type"::"Credit Memo"), 'Failed to delete all Purchase Contract Credit Memos');
    end;

    [Test]
    procedure CheckBatchDeleteSelectedContractDocuments()
    begin
        Initialize();

        // Test: multiple Sales- and Purchase-Contract Invoices can be batch-deleted depending on the selected document type
        // Selection: 2 = "All Sales Invoices"
        CreateAndDeleteDummyContractDocuments(2, 0, 2, 2, 2);
        // Selection: 3 = "All Sales Credit Memos"
        CreateAndDeleteDummyContractDocuments(3, 2, 0, 2, 2);
        // Selection: 4 = "All Purchase Invoices"
        CreateAndDeleteDummyContractDocuments(4, 2, 2, 0, 2);
        // Selection: 5 = "All Purchase Credit Memos"
        CreateAndDeleteDummyContractDocuments(5, 2, 2, 2, 0);
    end;

    [Test]
    [HandlerFunctions('CreateBillingDocumentPageHandler,MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure TestVendorContractPurchaseInvoicePricesTakenFromServiceCommitment()
    var
        Item: Record Item;
        ServiceCommitmentTemplate: Record "Service Commitment Template";
        ServiceCommitmentPackage: Record "Service Commitment Package";
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        PriceListHeader: Record "Price List Header";
        PriceListLine: Record "Price List Line";
    begin
        //[SCENARIO]: Test if Prices in Purchase Invoice (created from Vendor Contract) are taken from service commitments
        Initialize();

        //[GIVEN]:
        //Setup service commitment item with purchase price 
        //Create service object from the Sales order
        //Assign the service commitment to the vendor contract (at this point service commitment has prices taken from the sales order)
        ClearAll();
        ContractTestLibrary.ResetContractRecords();

        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate, '<1M>', 100, "Invoicing Via"::Contract, "Calculation Base Type"::"Document Price");
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '<1M>', 100, '', "Service Partner"::Vendor, Item."No.", "Invoicing Via"::Contract, "Calculation Base Type"::"Document Price", '', '<1M>', false);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage.Code);

        LibraryPriceCalculation.CreatePriceHeader(PriceListHeader, "Price Type"::Purchase, "Price Source Type"::"All Vendors", '');
        LibraryPriceCalculation.CreatePriceListLine(PriceListLine, PriceListHeader.Code, PriceListHeader."Price Type", PriceListHeader."Source Type", PriceListHeader."Parent Source No.", PriceListHeader."Source No.", Enum::"Price Amount Type"::Any, Enum::"Price Asset Type"::Item, Item."No.");
        PriceListManagement.ActivateDraftLines(PriceListHeader);

        LibrarySales.CreateSalesDocumentWithItem(SalesHeader, SalesLine, Enum::"Sales Document Type"::Order, '', Item."No.", LibraryRandom.RandDecInRange(1, 8, 0), '', CalcDate('<-CM>', WorkDate()));
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        ServiceObject.FindLast();
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, '', false);
        GetVendorContractServiceCommitment(VendorContract."No.");

        //[WHEN]:
        //Create purchase invoice directly from the vendor contract
        NextBillingToDate := CalcDate('<CM>', ServiceCommitment."Next Billing Date"); //Take the whole month for more accurate comparison
        BillingProposal.CreateBillingProposalFromContract(VendorContract."No.", VendorContract.GetFilter("Billing Rhythm Filter"), "Service Partner"::Vendor);

        //[THEN]:
        //Expect that Discount from the price list is not applied in the purchase line
        //Expect that the Line amount is set from the service commitment and not the price list
        BillingLine.FindLast();
        FilterPurchaseLineOnDocumentLine(BillingLine.GetPurchaseDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");
        PurchaseLine.SetRange("Line Amount", ServiceCommitment."Service Amount");
        PurchaseLine.SetRange("Line Discount %", ServiceCommitment."Discount %");
        AssertThat.RecordIsNotEmpty(PurchaseLine);
    end;

    [Test]
    [HandlerFunctions('CreateBillingDocumentPageHandler,MessageHandler')]
    procedure TestCustomerContractSalesInvoicePricesTakenFromServiceCommitment()
    var
        Item: Record Item;
        ServiceCommitmentTemplate: Record "Service Commitment Template";
        ServiceCommitmentPackage: Record "Service Commitment Package";
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        PriceListHeader: Record "Price List Header";
        PriceListLine: Record "Price List Line";
    begin
        //[SCENARIO]: Test if Prices in Sales Invoice (created from Customer Contract) are taken from service commitments
        Initialize();

        //[GIVEN]:
        //Setup service commitment item with sales price 
        //Create service object from the Sales order
        //Assign the service commitment to the customer contract (at this point service commitment has prices taken from the sales order)
        ClearAll();
        ContractTestLibrary.ResetContractRecords();

        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate, '<1M>', 100, "Invoicing Via"::Contract, "Calculation Base Type"::"Document Price");
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '<1M>', 100, '', "Service Partner"::Customer, Item."No.", "Invoicing Via"::Contract, "Calculation Base Type"::"Document Price", '', '<1M>', false);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage.Code);

        LibraryPriceCalculation.CreatePriceHeader(PriceListHeader, "Price Type"::Sale, "Price Source Type"::"All Customers", '');
        LibraryPriceCalculation.CreatePriceListLine(PriceListLine, PriceListHeader.Code, PriceListHeader."Price Type", PriceListHeader."Source Type", PriceListHeader."Parent Source No.", PriceListHeader."Source No.", Enum::"Price Amount Type"::Any, Enum::"Price Asset Type"::Item, Item."No.");
        PriceListManagement.ActivateDraftLines(PriceListHeader);

        LibrarySales.CreateSalesDocumentWithItem(SalesHeader, SalesLine, Enum::"Sales Document Type"::Order, '', Item."No.", LibraryRandom.RandDecInRange(1, 8, 0), '', CalcDate('<-CM>', WorkDate()));
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        ServiceObject.FindLast();
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, SalesHeader."Sell-to Customer No.", false);
        GetCustomerContractServiceCommitment(CustomerContract."No.");

        //[WHEN]:
        //Create purchase invoice directly from the vendor contract
        NextBillingToDate := CalcDate('<CM>', ServiceCommitment."Next Billing Date"); //Take the whole month for more accurate comparison
        BillingProposal.CreateBillingProposalFromContract(CustomerContract."No.", CustomerContract.GetFilter("Billing Rhythm Filter"), "Service Partner"::Customer);
        BillingLine.FindLast();
        //[THEN]:
        //Expect that Discount from the price list is not applied in the sales line
        //Expect that the Line amount is set from the service commitment and not the price list
        FilterSalesLineOnDocumentLine(BillingLine.GetSalesDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");
        SalesLine.SetRange("Line Amount", ServiceCommitment."Service Amount");
        SalesLine.SetRange("Line Discount %", ServiceCommitment."Discount %");
        AssertThat.RecordIsNotEmpty(SalesLine);
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Recurring Billing Docs Test");

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Recurring Billing Docs Test");
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        LibraryERMCountryData.UpdateSalesReceivablesSetup();
        LibraryERMCountryData.UpdateGeneralLedgerSetup();
        LibraryERMCountryData.UpdateJournalTemplMandatory(false);
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Recurring Billing Docs Test");
    end;

    local procedure FilterSalesLineOnDocumentLine(SalesDocumentType: Enum "Sales Document Type"; DocumentNo: Code[20]; LineNo: Integer)
    begin
        SalesLine.SetRange("Document Type", SalesDocumentType);
        SalesLine.SetRange("Document No.", DocumentNo);
        SalesLine.SetRange("Line No.", LineNo);
    end;

    local procedure FilterPurchaseLineOnDocumentLine(PurchaseDocumentType: Enum "Purchase Document Type"; DocumentNo: Code[20]; LineNo: Integer)
    begin
        PurchaseLine.SetRange("Document Type", PurchaseDocumentType);
        PurchaseLine.SetRange("Document No.", DocumentNo);
        PurchaseLine.SetRange("Line No.", LineNo);
    end;

    local procedure InitServiceContractSetup()
    var
        ServiceContractSetup: Record "Service Contract Setup";
    begin
        ServiceContractSetup.Get();
        ServiceContractSetup.ContractTextsCreateDefaults();
        ServiceContractSetup.Modify(false);
    end;

    local procedure SetupBasicBillingProposal(ServicePartner: Enum "Service Partner")
    begin
        ClearAll();
        case ServicePartner of
            Enum::"Service Partner"::Customer:
                ContractTestLibrary.CreateCustomerContractAndCreateContractLinesAndBillingProposal(CustomerContract, ServiceObject, '', BillingTemplate);
            Enum::"Service Partner"::Vendor:
                ContractTestLibrary.CreateVendorContractAndCreateContractLinesAndBillingProposal(VendorContract, ServiceObject, '', BillingTemplate);
        end;
        ContractTestLibrary.CreateDefaultRecurringBillingTemplateForServicePartner(BillingTemplate2, ServicePartner);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate2, ServicePartner);
    end;

    local procedure InitAndCreateBillingDocument(ServicePartner: Enum "Service Partner")
    begin
        SetupBasicBillingProposal(ServicePartner);
        CreateBillingDocuments();
    end;

    local procedure CreateBillingDocuments()
    begin
        CreateBillingDocuments(true);
    end;

    local procedure CreateBillingDocuments(InitializeTextSetup: Boolean)
    begin
        if InitializeTextSetup then begin
            InitServiceContractSetup();
            // Commit before asserterror to keep data
            Commit();
        end;
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange(Partner, BillingTemplate.Partner);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);
        Commit(); // retain data after asserterror
    end;

    local procedure InitAndCreateBillingDocumentsForMultipleContracts()
    begin
        //Contract1, Sell-to Customer1, Bill-to Customer1
        //Contract2, Sell-to Customer2, Bill-to Customer2
        //Contract3, Sell-to Customer2, Bill-to Customer1
        //Contract4, Sell-to Customer3, Bill-to Customer1
        ClearAll();
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, '');
        ContractTestLibrary.CreateCustomer(Customer2);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract2, ServiceObject2, Customer2."No.");
        CustomerContract2.Validate("Currency Code", CustomerContract."Currency Code");
        CustomerContract2.Modify(false);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract3, ServiceObject3, Customer2."No.");
        CustomerContract3.SetHideValidationDialog(true);
        CustomerContract3.Validate("Bill-to Customer No.", CustomerContract."Bill-to Customer No.");
        CustomerContract3.Validate("Currency Code", CustomerContract."Currency Code");
        CustomerContract3.Modify(false);
        ContractTestLibrary.CreateCustomer(Customer3);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract4, ServiceObject4, Customer3."No.");
        CustomerContract4.SetHideValidationDialog(true);
        CustomerContract4.Validate("Bill-to Customer No.", CustomerContract."Bill-to Customer No.");
        CustomerContract4.Validate("Currency Code", CustomerContract."Currency Code");
        CustomerContract4.Modify(false);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
        CreateBillingDocuments();
    end;

    local procedure InitAndCreateBillingDocumentsForMultipleVendorContracts()
    begin
        //Contract1, Sell-to Customer1, Bill-to Customer1
        //Contract2, Sell-to Customer2, Bill-to Customer2
        //Contract3, Sell-to Customer2, Bill-to Customer1
        //Contract4, Sell-to Customer3, Bill-to Customer1
        ClearAll();
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, '');
        ContractTestLibrary.CreateVendor(Vendor2);
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract2, ServiceObject2, Vendor2."No.");
        VendorContract2.Validate("Currency Code", VendorContract."Currency Code");
        VendorContract2.Modify(false);
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract3, ServiceObject3, Vendor2."No.");
        VendorContract3.SetHideValidationDialog(true);
        VendorContract3.Validate("Currency Code", VendorContract."Currency Code");
        VendorContract3.Validate("Pay-to Vendor No.", VendorContract."Buy-from Vendor No.");
        VendorContract3.Modify(false);
        ContractTestLibrary.CreateVendor(Vendor3);
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract4, ServiceObject4, Vendor3."No.");
        VendorContract4.SetHideValidationDialog(true);
        VendorContract4.Validate("Pay-to Vendor No.", VendorContract."Buy-from Vendor No.");
        VendorContract4.Validate("Currency Code", VendorContract."Currency Code");
        VendorContract4.Modify(false);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Vendor);
        CreateBillingDocuments();
    end;

    local procedure CheckIfSalesDocumentsHaveBeenCreated()
    var
        TempSalesHeader: Record "Sales Header" temporary;
    begin
        if BillingLine.FindSet() then
            repeat
                BillingLine.TestField("Document Type", Enum::"Rec. Billing Document Type"::Invoice);
                BillingLine.TestField("Document No.");
                SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
                SalesHeader.TestField("Assigned User ID", UserId());
                FilterSalesLineOnDocumentLine(SalesHeader."Document Type", SalesHeader."No.", BillingLine."Document Line No.");
                AssertThat.AreEqual(1, SalesLine.Count, 'The Sales lines were not created properly.');
                SalesLine.FindFirst();
                BillingLine.CalcFields("Service Object Description");
                SalesLine.TestField(Description, BillingLine."Service Object Description");
                SalesLine.TestField("Description 2", '');
                if not TempSalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.") then begin
                    TempSalesHeader.TransferFields(SalesHeader);
                    TempSalesHeader.Insert(false);
                    DocumentsCount += 1;
                end;
            until BillingLine.Next() = 0;
    end;

    local procedure CheckIfPurchaseDocumentsHaveBeenCreated()
    var
        TempPurchaseHeader: Record "Purchase Header" temporary;
    begin
        if BillingLine.FindSet() then
            repeat
                BillingLine.TestField("Document Type", Enum::"Rec. Billing Document Type"::Invoice);
                BillingLine.TestField("Document No.");
                PurchaseHeader.Get(Enum::"Purchase Document Type"::Invoice, BillingLine."Document No.");
                PurchaseHeader.TestField("Assigned User ID", UserId());
                FilterPurchaseLineOnDocumentLine(PurchaseHeader."Document Type", BillingLine."Document No.", BillingLine."Document Line No.");
                AssertThat.AreEqual(1, PurchaseLine.Count, 'The Purchase lines were not created properly.');
                PurchaseLine.FindFirst();
                PurchaseLine.TestField(Description, BillingLine."Service Commitment Description");
                BillingLine.CalcFields("Service Object Description");
                PurchaseLine.TestField("Description 2", BillingLine."Service Object Description");
                if not TempPurchaseHeader.Get(PurchaseHeader."Document Type", PurchaseHeader."No.") then begin
                    TempPurchaseHeader.TransferFields(PurchaseHeader);
                    TempPurchaseHeader.Insert(false);
                    PurchaseDocumentCount += 1;
                end;
            until BillingLine.Next() = 0;
    end;

    local procedure TestDocumentFields(CalledFromSales: Boolean)
    var
        ValueCode: Text[10];
        ValueInteger: Integer;
        ValueDecimal: Decimal;
    begin
        i := 1;
        repeat
            FRef := RRef.Field(FieldsArray[i]);

            case FRef.Type() of
                FieldType::Decimal:
                    begin
                        ValueDecimal := FRef.Value;
                        FRef.Value(ValueDecimal + 1);
                    end;
                FieldType::Integer, FieldType::Option:
                    begin
                        ValueInteger := FRef.Value;
                        FRef.Value(ValueInteger + 1);
                    end;
                FieldType::Code, FieldType::Text:
                    begin
                        ValueCode := CopyStr(LibraryRandom.RandText(10), 1, 10);
                        FRef.Value(ValueCode);
                    end;
                FieldType::Date:
                    FRef.Value(CalcDate('<1D>', FRef.Value));
                FieldType::Boolean:
                    FRef.Value(not FRef.Value);
            end;

            asserterror DocChangeMgt.PreventChangeOnDocumentHeaderOrLine(RRef, FieldsArray[i]);
            i += 1;
            if ((i in [20, 40, 43]) and not CalledFromSales) then //skip ID that's not in Purchase Hdr but exists in Sales Hdr
                i += 1;
            if FieldsArray[i] = 0 then
                EmptyArray := true;
        until EmptyArray = true;
    end;

    local procedure PopulateArrayOfFieldsForHeaders(CalledFromSales: Boolean)
    begin
        FieldsArray[1] := 2;  //Sell-to Customer No.   //Buy-from Vendor No. (Buy-from Vendor No.)
        FieldsArray[2] := 4;  //Bill-to Customer No.   //Pay-to Vendor No. (Pay-to Vendor No.)
        FieldsArray[3] := 5;  //Bill-to Name   //Pay-to Name (Pay-to Name)
        FieldsArray[4] := 6;  //Bill-to Name 2   //Pay-to Name 2 (Pay-to Name 2)
        FieldsArray[5] := 7;  //Bill-to Address (Bill-to Address)   //Pay-to Address (Pay-to Address)
        FieldsArray[6] := 8;  //Bill-to Address 2 (Bill-to Address 2)   //Pay-to Address 2 (Pay-to Address 2)
        FieldsArray[7] := 9;  //Bill-to City (Bill-to City)   //Pay-to City (Pay-to City)
        FieldsArray[8] := 10;  //Bill-to Contact (Bill-to Contact)   //Pay-to Contact (Pay-to Contact)
        FieldsArray[9] := 12;  //Ship-to Code (Ship-to Code)   //Ship-to Code (Ship-to Code)
        FieldsArray[10] := 13;  //Ship-to Name (Ship-to Name)   //Ship-to Name (Ship-to Name)
        FieldsArray[11] := 14;  //Ship-to Name 2 (Ship-to Name 2)   //Ship-to Name 2 (Ship-to Name 2)
        FieldsArray[12] := 15;  //Ship-to Address (Ship-to Address)   //Ship-to Address (Ship-to Address)
        FieldsArray[13] := 16;  //Ship-to Address 2 (Ship-to Address 2)   //Ship-to Address 2 (Ship-to Address 2)
        FieldsArray[14] := 17;  //Ship-to City (Ship-to City)   //Ship-to City (Ship-to City)
        FieldsArray[15] := 18;  //Ship-to Contact (Ship-to Contact)   //Ship-to Contact (Ship-to Contact)
        FieldsArray[16] := 29;  //Shortcut Dimension 1 Code (Shortcut Dimension 1 Code)   //Shortcut Dimension 1 Code (Shortcut Dimension 1 Code)
        FieldsArray[17] := 30;  //Shortcut Dimension 2 Code (Shortcut Dimension 2 Code)   //Shortcut Dimension 2 Code (Shortcut Dimension 2 Code)
        FieldsArray[18] := 32;  //Currency Code (Currency Code)   //Currency Code (Currency Code)
        FieldsArray[19] := 35;  //Prices Including VAT (Prices Including VAT)   //Prices Including VAT (Prices Including VAT)
        FieldsArray[21] := 76;  //Transaction Type (Transaction Type)   //Transaction Type (Transaction Type)
        FieldsArray[22] := 77;  //Transport Method (Transport Method)   //Transport Method (Transport Method)
        FieldsArray[23] := 79;  //Sell-to Customer Name (Sell-to Customer Name)   //Buy-from Vendor Name (Buy-from Vendor Name)
        FieldsArray[24] := 80;  //Sell-to Customer Name 2 (Sell-to Customer Name 2)   //Buy-from Vendor Name 2 (Buy-from Vendor Name 2)
        FieldsArray[25] := 81;  //Sell-to Address (Sell-to Address)   //Buy-from Address (Buy-from Address)
        FieldsArray[26] := 82;  //Sell-to Address 2 (Sell-to Address 2)   //Buy-from Address 2 (Buy-from Address 2)
        FieldsArray[27] := 83;  //Sell-to City (Sell-to City)   //Buy-from City (Buy-from City)
        FieldsArray[28] := 84;  //Sell-to Contact (Sell-to Contact)   //Buy-from Contact (Buy-from Contact)
        FieldsArray[29] := 85;  //Bill-to Post Code (Bill-to Post Code)   //Pay-to Post Code (Pay-to Post Code)
        FieldsArray[30] := 86;  //Bill-to County (Bill-to County)   //Pay-to County (Pay-to County)
        FieldsArray[31] := 87;  //Bill-to Country/Region Code (Bill-to Country/Region Code)   //Pay-to Country/Region Code (Pay-to Country/Region Code)
        FieldsArray[32] := 88;  //Sell-to Post Code (Sell-to Post Code)   //Buy-from Post Code (Buy-from Post Code)
        FieldsArray[33] := 89;  //Sell-to County (Sell-to County)   //Buy-from County (Buy-from County)
        FieldsArray[34] := 90;  //Sell-to Country/Region Code (Sell-to Country/Region Code)   //Buy-from Country/Region Code (Buy-from Country/Region Code)
        FieldsArray[35] := 91;  //Ship-to Post Code (Ship-to Post Code)   //Ship-to Post Code (Ship-to Post Code)
        FieldsArray[36] := 92;  //Ship-to County (Ship-to County)   //Ship-to County (Ship-to County)
        FieldsArray[37] := 93;  //Ship-to Country/Region Code (Ship-to Country/Region Code)   //Ship-to Country/Region Code (Ship-to Country/Region Code)
        FieldsArray[38] := 116;  //VAT Bus. Posting Group (VAT Bus. Posting Group)   //VAT Bus. Posting Group (VAT Bus. Posting Group)
        FieldsArray[39] := 480;  //Dimension Set ID (Dimension Set ID)   //Dimension Set ID (Dimension Set ID)
        FieldsArray[41] := 5052;  //Sell-to Contact No. (Sell-to Contact No.)   //Buy-from Contact No. (Buy-from Contact No.)
        FieldsArray[42] := 5053;  //Bill-to Contact No. (Bill-to Contact No.)   //Pay-to Contact No. (Pay-to Contact No.)
        if CalledFromSales then begin
            FieldsArray[20] := 75;  //EU 3-Party Trade (EU 3-Party Trade)   //No field in Purchase Header
            FieldsArray[43] := 5057;  //Bill-to Customer Templ. Code (Bill-to Customer Templ. Code)   //No field in Purchase Header
            FieldsArray[40] := 5056;  //Sell-to Customer Templ. Code (Sell-to Customer Templ. Code)   //No field in Purchase Header
        end;
    end;

    local procedure PopulateArrayOfFieldsForLines()
    begin
        FieldsArray[1] := 5;  //Type
        FieldsArray[2] := 6;  //No.
        FieldsArray[3] := 15;   //Quantity
        FieldsArray[4] := 22;  //Unit Price/Cost
        FieldsArray[5] := 27;  //Line Discount %
        FieldsArray[6] := 28;  //Line Discount Amount
        FieldsArray[7] := 29;  //Amount
        FieldsArray[8] := 30;  //Amount including VAT
        FieldsArray[9] := 40;  //Dim 1
        FieldsArray[10] := 41;  // Dim2
        FieldsArray[11] := 480;  // Dimension Set ID
        FieldsArray[12] := 8053;  //Recurring Billing from
        FieldsArray[13] := 8054;  //Recurring Billing to
    end;

    local procedure PostAndGetSalesInvoiceHeaderFromRecurringBilling()
    begin
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesInvoiceHeader.Get(PostedDocumentNo);
    end;

    local procedure CheckIfPostedSalesDocumentsHaveBeenCreated()
    begin
        TempSalesInvoiceHeader.Reset();
        TempSalesInvoiceHeader.DeleteAll(false);
        GetPostedSalesDocumentsFromContract(CustomerContract);
        GetPostedSalesDocumentsFromContract(CustomerContract2);
        GetPostedSalesDocumentsFromContract(CustomerContract3);
        GetPostedSalesDocumentsFromContract(CustomerContract4);
    end;

    local procedure GetPostedSalesDocumentsFromContract(SourceCustomerContract: Record "Customer Contract")
    var
        BillingLineArchive: Record "Billing Line Archive";
    begin
        ContractTestLibrary.FilterBillingLineArchiveOnContractLine(BillingLineArchive, SourceCustomerContract."No.", 0, Enum::"Service Partner"::Customer);
        if BillingLineArchive.FindSet() then
            repeat
                BillingLineArchive.TestField("Document Type", BillingLineArchive."Document Type"::Invoice);
                BillingLineArchive.TestField("Document No.");
                SalesInvoiceHeader.Get(BillingLineArchive."Document No.");
                if not TempSalesInvoiceHeader.Get(BillingLineArchive."Document No.") then begin
                    TempSalesInvoiceHeader := SalesInvoiceHeader;
                    TempSalesInvoiceHeader.Insert(false);
                    DocumentsCount += 1;
                end;
            until BillingLineArchive.Next() = 0;
    end;

    local procedure GetCustomerContractServiceCommitment(ContractNo: Code[20])
    begin
        CustomerContractLine.SetRange("Contract No.", ContractNo);
        CustomerContractLine.FindFirst();
        CustomerContractLine.GetServiceCommitment(ServiceCommitment);
    end;

    local procedure GetVendorContractServiceCommitment(ContractNo: Code[20])
    begin
        VendorContractLine.SetRange("Contract No.", ContractNo);
        VendorContractLine.FindFirst();
        ServiceCommitment.Get(VendorContractLine."Service Commitment Entry No.")
    end;

    local procedure CountBillingArchiveLinesOnDocument(DocumentType: Enum "Rec. Billing Document Type"; DocumentNo: Code[20]; ServicePartner: Enum "Service Partner"; ContractNo: Code[20]; ContractLineNo: Integer): Integer
    var
        BillingArchiveLine: Record "Billing Line Archive";
    begin
        BillingArchiveLine.FilterBillingLineArchiveOnContractLine(ServicePartner, ContractNo, ContractLineNo);
        BillingArchiveLine.FilterBillingLineArchiveOnDocument(DocumentType, DocumentNo);
        exit(BillingArchiveLine.Count());
    end;

    local procedure PrepareCustomerContractWithNames()
    begin
        SetupBasicBillingProposal(Enum::"Service Partner"::Customer);
        InitServiceContractSetup();

        CustomerContract."Sell-to Customer Name" := CopyStr(LibraryRandom.RandText(MaxStrLen(CustomerContract."Sell-to Customer Name")), 1, MaxStrLen(CustomerContract."Sell-to Customer Name"));
        CustomerContract."Sell-to Customer Name 2" := CopyStr(LibraryRandom.RandText(MaxStrLen(CustomerContract."Sell-to Customer Name 2")), 1, MaxStrLen(CustomerContract."Sell-to Customer Name 2"));
        CustomerContract."Ship-to Name" := CopyStr(LibraryRandom.RandText(MaxStrLen(CustomerContract."Ship-to Name")), 1, MaxStrLen(CustomerContract."Ship-to Name"));
        CustomerContract."Ship-to Name 2" := CopyStr(LibraryRandom.RandText(MaxStrLen(CustomerContract."Ship-to Name 2")), 1, MaxStrLen(CustomerContract."Ship-to Name 2"));
        CustomerContract.Modify(false);
    end;

    local procedure GetNoOfSalesInvoiceLineWithDescription(ExpectedDescriptionText: Text[100]): Integer
    begin
        BillingLine.Reset();
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange(Partner, BillingTemplate.Partner);
        BillingLine.FindLast();

        SalesLine.Reset();
        SalesLine.SetRange("Document Type", BillingLine.GetSalesDocumentTypeFromBillingDocumentType());
        SalesLine.SetRange("Document No.", BillingLine."Document No.");
        SalesLine.SetRange(Description, ExpectedDescriptionText);
        exit(SalesLine.Count());
    end;

    local procedure CreateAndPostSimpleSalesDocument(ItemNo: Code[20])
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, ItemNo, 1);
        SalesLine.Validate("Unit Price", -50);
        SalesLine.Modify(false);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, ItemNo, 1);
        SalesLine.Validate("Unit Price", 100);
        SalesLine.Modify(false);
        LibrarySales.PostSalesDocument(SalesHeader, true, false);
    end;

    local procedure CreateCustomerContractAndAssignServiceObjects(ItemNo: Code[20])
    var
        TempServiceCommitment: Record "Service Commitment" temporary;
    begin
        ContractTestLibrary.CreateCustomerContract(CustomerContract, SalesHeader."Sell-to Customer No.");
        ServiceObject.Reset();
        ServiceObject.SetRange("Item No.", ItemNo);
        ServiceObject.FindSet();
        repeat
            ContractTestLibrary.FillTempServiceCommitment(TempServiceCommitment, ServiceObject, CustomerContract);
            CustomerContract.CreateCustomerContractLinesFromServiceCommitments(TempServiceCommitment);
        until ServiceObject.Next() = 0;
        CustomerContractLine.SetRange("Contract No.", CustomerContract."No.");
        CustomerContractLine.FindSet();
        repeat
            CustomerContractLine.GetServiceCommitment(ServiceCommitment);
            ServiceCommitment.Validate("Service Start Date", CalcDate('<2M-CM>', WorkDate()));
            ServiceCommitment.Modify(false);
        until CustomerContractLine.Next() = 0;
    end;

    local procedure CreateAndDeleteDummyContractDocuments(Selection: Integer; NoOfSalesInvoices: Integer; NoOfSalesCrMemos: Integer; NoOfPurchaseInvoices: Integer; NoOfPurchaseCrMemos: Integer)
    begin
        SalesHeader.Reset();
        SalesHeader.SetFilter("Document Type", '%1|%2', SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::"Credit Memo");
        if not SalesHeader.IsEmpty() then
            SalesHeader.ModifyAll("Recurring Billing", false, false);
        PurchaseHeader.Reset();
        PurchaseHeader.SetFilter("Document Type", '%1|%2', PurchaseHeader."Document Type"::Invoice, PurchaseHeader."Document Type"::"Credit Memo");
        if not PurchaseHeader.IsEmpty() then
            PurchaseHeader.ModifyAll("Recurring Billing", false, false);

        CreateDummyContractDocumentsSales();
        CreateDummyContractDocumentsPurchase();
        BillingProposal.DeleteBillingDocuments(Selection, false);

        AssertThat.AreEqual(NoOfSalesInvoices, GetNumberOfContractDocumentsSales(Enum::"Sales Document Type"::Invoice), 'Unexpected No. of Sales Invoices after batch-deletion');
        AssertThat.AreEqual(NoOfSalesCrMemos, GetNumberOfContractDocumentsSales(Enum::"Sales Document Type"::"Credit Memo"), 'Unexpected No. of Sales Credit Memos after batch-deletion');
        AssertThat.AreEqual(NoOfPurchaseInvoices, GetNumberOfContractDocumentsPurchase(Enum::"Purchase Document Type"::Invoice), 'Unexpected No. of Purchase Invoices after batch-deletion');
        AssertThat.AreEqual(NoOfPurchaseCrMemos, GetNumberOfContractDocumentsPurchase(Enum::"Purchase Document Type"::"Credit Memo"), 'Unexpected No. of Purchase Credit Memos after batch-deletion');
    end;

    local procedure GetNumberOfContractDocumentsSales(DocumentType: Enum "Sales Document Type"): Integer
    begin
        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", DocumentType);
        SalesHeader.SetRange("Recurring Billing", true);
        exit(SalesHeader.Count());
    end;

    local procedure GetNumberOfContractDocumentsPurchase(DocumentType: Enum "Purchase Document Type"): Integer
    begin
        PurchaseHeader.Reset();
        PurchaseHeader.SetRange("Document Type", DocumentType);
        PurchaseHeader.SetRange("Recurring Billing", true);
        exit(PurchaseHeader.Count());
    end;

    local procedure CreateDummyContractDocumentsSales()
    var
        SalesDocumentType: Enum "Sales Document Type";
    begin
        for SalesDocumentType := SalesDocumentType::Invoice to SalesDocumentType::"Credit Memo" do
            for i := 1 to 2 do begin
                Clear(SalesHeader);
                SalesHeader."No." := '';
                SalesHeader."Document Type" := SalesDocumentType;
                SalesHeader."Recurring Billing" := true;
                SalesHeader.Insert(true);
            end;
    end;

    local procedure CreateDummyContractDocumentsPurchase()
    var
        PurchaseDocumentType: Enum "Purchase Document Type";
    begin
        for PurchaseDocumentType := PurchaseDocumentType::Invoice to PurchaseDocumentType::"Credit Memo" do
            for i := 1 to 2 do begin
                Clear(PurchaseHeader);
                PurchaseHeader."No." := '';
                PurchaseHeader."Document Type" := PurchaseDocumentType;
                PurchaseHeader."Recurring Billing" := true;
                PurchaseHeader.Insert(true);
            end;
    end;

    local procedure CountBillingArchiveLinesOnServiceCommitment(ServiceCommitmentEntryNo: Integer): Integer
    var
        BillingArchiveLine: Record "Billing Line Archive";
    begin
        BillingArchiveLine.FilterBillingLineArchiveOnServiceCommitment(ServiceCommitmentEntryNo);
        exit(BillingArchiveLine.Count());
    end;

    [ConfirmHandler]
    procedure DialogHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        if not (Question = DialogMsg) then
            Error('No Dialog Question found!');
        Reply := false;
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    [ModalPageHandler]
    procedure CreateCustomerBillingDocsTestOpenPageHandler(var CreateCustomerBillingDocs: TestPage "Create Customer Billing Docs")
    var
        PagePostingDate: Date;
        PageDocumentDate: Date;
    begin
        Evaluate(PagePostingDate, CreateCustomerBillingDocs.PostingDate.Value);
        Evaluate(PageDocumentDate, CreateCustomerBillingDocs.DocumentDate.Value);
        AssertThat.AreEqual(WorkDate(), PagePostingDate, 'Posting Date is not initialized correctly.');
        AssertThat.AreEqual(WorkDate(), PageDocumentDate, 'Document Date is not initialized correctly.');
        CreateCustomerBillingDocs.Cancel().Invoke();
    end;

    [ModalPageHandler]
    procedure CreateCustomerBillingDocsContractPageHandler(var CreateCustomerBillingDocs: TestPage "Create Customer Billing Docs")
    begin
        CreateCustomerBillingDocs.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CreateCustomerBillingDocsSellToCustomerPageHandler(var CreateCustomerBillingDocs: TestPage "Create Customer Billing Docs")
    begin
        CreateCustomerBillingDocs.GroupingType.SetValue(Enum::"Customer Rec. Billing Grouping"::"Sell-to Customer No.");
        CreateCustomerBillingDocs.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CreateCustomerBillingDocsBillToCustomerPageHandler(var CreateCustomerBillingDocs: TestPage "Create Customer Billing Docs")
    begin
        CreateCustomerBillingDocs.GroupingType.SetValue(Enum::"Customer Rec. Billing Grouping"::"Bill-to Customer No.");
        CreateCustomerBillingDocs.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CancelCreateVendorBillingDocsTestOpenPageHandler(var CreateVendorBillingDocs: TestPage "Create Vendor Billing Docs")
    var
        PagePostingDate: Date;
        PageDocumentDate: Date;
    begin
        Evaluate(PagePostingDate, CreateVendorBillingDocs.PostingDate.Value);
        Evaluate(PageDocumentDate, CreateVendorBillingDocs.DocumentDate.Value);
        AssertThat.AreEqual(WorkDate(), PagePostingDate, 'Posting Date is not initialized correctly.');
        AssertThat.AreEqual(WorkDate(), PageDocumentDate, 'Document Date is not initialized correctly.');
        CreateVendorBillingDocs.Cancel().Invoke();
    end;

    [ModalPageHandler]
    procedure CreateVendorBillingDocsContractPageHandler(var CreateVendorBillingDocs: TestPage "Create Vendor Billing Docs")
    begin
        CreateVendorBillingDocs.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CreateVendorBillingDocsPayToVendorPageHandler(var CreateVendorBillingDocs: TestPage "Create Vendor Billing Docs")
    begin
        CreateVendorBillingDocs.GroupingType.SetValue(Enum::"Vendor Rec. Billing Grouping"::"Pay-to Vendor No.");
        CreateVendorBillingDocs.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CreateVendorBillingDocsBuyFromVendorPageHandler(var CreateVendorBillingDocs: TestPage "Create Vendor Billing Docs")
    begin
        CreateVendorBillingDocs.GroupingType.SetValue(Enum::"Vendor Rec. Billing Grouping"::"Buy-From Vendor No.");
        CreateVendorBillingDocs.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ExchangeRateSelectionModalPageHandler(var ExchangeRateSelectionPage: TestPage "Exchange Rate Selection")
    begin
        ExchangeRateSelectionPage.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CreateAndPostCustomerBillingDocsContractPageHandler(var CreateCustomerBillingDocs: TestPage "Create Customer Billing Docs")
    begin
        CreateCustomerBillingDocs.PostDocuments.SetValue(true);
        CreateCustomerBillingDocs.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CreateAndPostCustomerBillingDocsSellToCustomerPageHandler(var CreateCustomerBillingDocs: TestPage "Create Customer Billing Docs")
    begin
        CreateCustomerBillingDocs.PostDocuments.SetValue(true);
        CreateCustomerBillingDocs.GroupingType.SetValue(Enum::"Customer Rec. Billing Grouping"::"Sell-to Customer No.");
        CreateCustomerBillingDocs.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CreateAndPostCustomerBillingDocsBillToCustomerPageHandler(var CreateCustomerBillingDocs: TestPage "Create Customer Billing Docs")
    begin
        CreateCustomerBillingDocs.PostDocuments.SetValue(true);
        CreateCustomerBillingDocs.GroupingType.SetValue(Enum::"Customer Rec. Billing Grouping"::"Bill-to Customer No.");
        CreateCustomerBillingDocs.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CreateVendorBillingDocsTestOpenPageHandler(var CreateVendorBillingDocs: TestPage "Create Vendor Billing Docs")
    begin
        CreateVendorBillingDocs.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CreateBillingDocumentPageHandler(var CreateBillingDocument: TestPage "Create Billing Document")
    begin
        CreateBillingDocument.BillingDate.SetValue(NextBillingToDate);
        CreateBillingDocument.BillingTo.SetValue(NextBillingToDate);
        CreateBillingDocument.OpenDocument.SetValue(false);
        CreateBillingDocument.PostDocument.SetValue(false);
        CreateBillingDocument.OK().Invoke()
    end;

    [PageHandler]
    procedure BillingLinesArchivePageHandler(var BillingLinesArchive: TestPage "Archived Billing Lines")
    var
        NoOfRecords: Integer;
    begin
        if BillingLinesArchive.First() then
            repeat
                NoOfRecords += 1;
            until not BillingLinesArchive.Next();
        AssertThat.AreEqual(NoOfRecords, ExpectedNoOfArchivedLines, 'Page Billing Lines Archive is not filtered properly.');
        BillingLinesArchive.OK().Invoke();
    end;
}