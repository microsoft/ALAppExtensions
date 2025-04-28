namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Item.Attribute;
using Microsoft.Pricing.Asset;
using Microsoft.Pricing.PriceList;
using Microsoft.Pricing.Source;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using System.Globalization;
using System.TestLibraries.Utilities;

codeunit 139687 "Recurring Billing Docs Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    var
        BillingLine: Record "Billing Line";
        BillingTemplate: Record "Billing Template";
        BillingTemplate2: Record "Billing Template";
        CustomerContract: Record "Customer Subscription Contract";
        CustomerContract2: Record "Customer Subscription Contract";
        CustomerContract3: Record "Customer Subscription Contract";
        CustomerContract4: Record "Customer Subscription Contract";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseInvoiceHeader: Record "Purch. Inv. Header";
        PurchaseLine: Record "Purchase Line";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesLine: Record "Sales Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
        ServiceObject2: Record "Subscription Header";
        ServiceObject3: Record "Subscription Header";
        ServiceObject4: Record "Subscription Header";
        TempSalesInvoiceHeader: Record "Sales Invoice Header" temporary;
        VendorContract: Record "Vendor Subscription Contract";
        VendorContractLine: Record "Vend. Sub. Contract Line";
        Assert: Codeunit Assert;
        BillingProposal: Codeunit "Billing Proposal";
        ContractsGeneralMgt: Codeunit "Sub. Contracts General Mgt.";
        ContractTestLibrary: Codeunit "Contract Test Library";
        LibraryERM: Codeunit "Library - ERM";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPriceCalculation: Codeunit "Library - Price Calculation";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        IsInitialized: Boolean;
        NoContractLinesFoundErr: Label 'No contract lines were found that can be billed with the specified parameters.';

    #region Tests

    [Test]
    [HandlerFunctions('MessageHandler,GetVendorContractLinesPageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure AssignVendorContractLinesToExistingPurchaseInvoiceLine()
    var
        Item: Record Item;
        Vendor: Record Vendor;
    begin
        // [SCENARIO] Test if Vendor Subscription Contract line can be assigned to purchase invoice line
        Initialize();

        // [GIVEN] Setup Subscription with Subscription Line and assign it to Vendor Subscription Contract
        // [GIVEN] Create Purchase Invoice with Purchase Invoice Line
        ContractTestLibrary.DeleteAllContractRecords();
        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, Vendor."No.");
        GetVendorContractServiceCommitment(VendorContract."No.");
        ServiceCommitment."Billing Rhythm" := ServiceCommitment."Billing Base Period";
        ServiceCommitment.Modify(false);
        LibraryPurchase.CreatePurchaseInvoiceForVendorNo(PurchaseHeader, Vendor."No.");
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, "Purchase Line Type"::Item, Item."No.", 1);
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDec(100, 2));
        PurchaseLine.Modify(false);
        // [WHEN] Invoke Get Vendor Subscription Contract Lines
        PurchaseLine.AssignVendorContractLine();
        // Commit()); // retain changes

        // [THEN] Test if Purchase header is marked as Recurring billing
        PurchaseHeader.Get(PurchaseHeader."Document Type", PurchaseHeader."No.");
        PurchaseHeader.TestField("Recurring Billing", true);

        // [THEN] Test if billing lines exist
        BillingLine.Reset();
        BillingLine.FilterBillingLineOnDocumentLine(BillingLine.GetBillingDocumentTypeFromPurchaseDocumentType(PurchaseLine."Document Type"), PurchaseLine."Document No.", PurchaseLine."Line No.");
        Assert.RecordIsNotEmpty(BillingLine);
        BillingLine.CalcSums(Amount);
        Assert.AreEqual(PurchaseLine."Line Amount", BillingLine.Amount, 'Service amount was not taken from purchase line');

        // [THEN] If Purchase Line is deleted, billing lines are deleted as well
        PurchaseLine.Get(PurchaseLine."Document Type", PurchaseLine."Document No.", PurchaseLine."Line No.");
        PurchaseLine.Delete(true);
        BillingLine.Reset();
        BillingLine.FilterBillingLineOnDocumentLine(BillingLine.GetBillingDocumentTypeFromPurchaseDocumentType(PurchaseLine."Document Type"), PurchaseLine."Document No.", PurchaseLine."Line No.");
        Assert.RecordIsEmpty(BillingLine);
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckBatchDeleteAllContractDocuments()
    begin
        Initialize();
        LibrarySetupStorage.Save(Database::"Subscription Contract Setup");

        // [SCENARIO] multiple Sales- and Purchase-Contract Documents can be batch-deleted by using the function from the recurring billing page
        InitAndCreateBillingDocument(Enum::"Service Partner"::Customer);
        InitAndCreateBillingDocument(Enum::"Service Partner"::Customer);
        InitAndCreateBillingDocument(Enum::"Service Partner"::Vendor);
        InitAndCreateBillingDocument(Enum::"Service Partner"::Vendor);

        BillingProposal.DeleteBillingDocuments(1, false); // Selection: 1 = "All Documents"

        Assert.AreEqual(0, GetNumberOfContractDocumentsSales(Enum::"Sales Document Type"::Invoice), 'Failed to delete all Sales Contract Invoices');
        Assert.AreEqual(0, GetNumberOfContractDocumentsSales(Enum::"Sales Document Type"::"Credit Memo"), 'Failed to delete all Sales Contract Credit Memos');
        Assert.AreEqual(0, GetNumberOfContractDocumentsPurchase(Enum::"Purchase Document Type"::Invoice), 'Failed to delete all Purchase Contract Invoices');
        Assert.AreEqual(0, GetNumberOfContractDocumentsPurchase(Enum::"Purchase Document Type"::"Credit Memo"), 'Failed to delete all Purchase Contract Credit Memos');
    end;

    [Test]
    procedure CheckBatchDeleteSelectedContractDocuments()
    begin
        Initialize();

        // [SCENARIO] multiple Sales- and Purchase-Contract Invoices can be batch-deleted depending on the selected document type
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
    [HandlerFunctions('CreateCustomerBillingDocsBillToCustomerPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckContractNamesAreTransferredToSalesDocumentOnBillingPerBillToContractOptionsOn()
    var
        FieldValueNotExpectedTxt: Label '"%1" should be present (once) as a description-line', Locked = true;
    begin
        Initialize();

        // [SCENARIO] Names are transferred as Description Lines in Sales Document (Create per bill-to (see PageHandler), both options on)
        LibrarySetupStorage.Save(Database::"Subscription Contract Setup");
        PrepareCustomerContractWithNames();

        CustomerContract."Contractor Name in coll. Inv." := true;
        CustomerContract."Recipient Name in coll. Inv." := true;
        CustomerContract.Modify(false);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);

        Assert.AreEqual(1, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Sell-to Customer Name"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Sell-to Customer Name")));
        Assert.AreEqual(1, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Sell-to Customer Name 2"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Sell-to Customer Name 2")));
        Assert.AreEqual(1, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Ship-to Name"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Ship-to Name")));
        Assert.AreEqual(1, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Ship-to Name 2"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Ship-to Name 2")));
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckContractSalesInvoiceDescriptions()
    var
        ItemAttribute: Record "Item Attribute";
        ItemAttribute2: Record "Item Attribute";
        ItemAttributeValue: Record "Item Attribute Value";
        ItemAttributeValue2: Record "Item Attribute Value";
        ParentSalesLine: Record "Sales Line";
        SalesLine2: Record "Sales Line";
        ServiceContractSetup: Record "Subscription Contract Setup";
        CustomerNo: Code[20];
    begin
        Initialize();

        // [SCENARIO] Sales Invoice Line Description and attached lines are created according to setup
        BillingLine.Reset();
        if not BillingLine.IsEmpty() then
            BillingLine.DeleteAll(false);

        LibrarySetupStorage.Save(Database::"Subscription Contract Setup");
        ServiceContractSetup.Get();
        ServiceContractSetup."Contract Invoice Description" := Enum::"Contract Invoice Text Type"::"Service Commitment";
        ServiceContractSetup."Contract Invoice Add. Line 1" := Enum::"Contract Invoice Text Type"::"Billing Period";
        ServiceContractSetup."Contract Invoice Add. Line 2" := Enum::"Contract Invoice Text Type"::"Service Object";
        ServiceContractSetup."Contract Invoice Add. Line 3" := Enum::"Contract Invoice Text Type"::"Serial No.";
        ServiceContractSetup."Contract Invoice Add. Line 4" := Enum::"Contract Invoice Text Type"::"Customer Reference";
        ServiceContractSetup."Contract Invoice Add. Line 5" := Enum::"Contract Invoice Text Type"::"Primary attribute";
        ServiceContractSetup.Modify(false);

        CustomerNo := '';
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, CustomerNo);
        ServiceObject."Customer Reference" := CopyStr(LibraryRandom.RandText(MaxStrLen(ServiceObject."Customer Reference")), 1, MaxStrLen(ServiceObject."Customer Reference"));
        ServiceObject."Serial No." := CopyStr(LibraryRandom.RandText(MaxStrLen(ServiceObject."Serial No.")), 1, MaxStrLen(ServiceObject."Serial No."));
        ServiceObject.Modify(false);

        ContractTestLibrary.CreateItemAttributeMappedToServiceObject(ServiceObject."No.", ItemAttribute, ItemAttributeValue, false);
        ContractTestLibrary.CreateItemAttributeMappedToServiceObject(ServiceObject."No.", ItemAttribute2, ItemAttributeValue2, true);

        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);

        CreateBillingDocuments(false);

        BillingLine.Reset();
        BillingLine.FindFirst();
        BillingLine.TestField("Document Type", BillingLine."Document Type"::Invoice);

        SalesLine.Reset();
        FilterSalesLineOnDocumentLine(BillingLine.GetSalesDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");
        Assert.AreEqual(1, SalesLine.Count, 'The Sales lines were not created properly.');
        SalesLine.FindFirst();
        SalesLine.TestField(Description, BillingLine."Subscription Line Description");
        SalesLine.TestField("Description 2", '');

        SalesLine2.Reset();
        SalesLine2.SetRange("Document Type", SalesLine."Document Type");
        SalesLine2.SetRange("Document No.", SalesLine."Document No.");
        SalesLine2.SetRange("Attached to Line No.", SalesLine."Line No.");
        Assert.AreEqual(5, SalesLine2.Count, 'Setup-failure: expected five attached Lines.');
        SalesLine2.FindSet();
        // 1st line: Service Period
        Assert.IsSubstring(SalesLine2.Description, 'Subscription period');
        ParentSalesLine.Get(SalesLine2."Document Type", SalesLine2."Document No.", SalesLine2."Attached to Line No.");
        SalesLine2.Next();
        // 2nd line: Subscription Description
        Assert.AreEqual(SalesLine2.Description, ServiceObject.Description, 'Description does not match expected value');
        ParentSalesLine.Get(SalesLine2."Document Type", SalesLine2."Document No.", SalesLine2."Attached to Line No.");
        SalesLine2.Next();
        // 3rd line: Serial No.
        Assert.IsSubstring(SalesLine2.Description, ServiceObject."Serial No.");
        ParentSalesLine.Get(SalesLine2."Document Type", SalesLine2."Document No.", SalesLine2."Attached to Line No.");
        SalesLine2.Next();
        // 4th line: Customer Reference
        Assert.IsSubstring(SalesLine2.Description, ServiceObject."Customer Reference");
        ParentSalesLine.Get(SalesLine2."Document Type", SalesLine2."Document No.", SalesLine2."Attached to Line No.");
        SalesLine2.Next();
        // 5th line: Primary Attribute
        Assert.IsSubstring(ServiceObject.GetPrimaryAttributeValue(), SalesLine2.Description);
        ParentSalesLine.Get(SalesLine2."Document Type", SalesLine2."Document No.", SalesLine2."Attached to Line No.");
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckContractTypeIsTranslated()
    var
        ContractType: Record "Subscription Contract Type";
        Customer: Record Customer;
        FieldTranslation: Record "Field Translation";
        LanguageMgt: Codeunit Language;
    begin
        Initialize();

        ContractTestLibrary.CreateContractType(ContractType);
        ContractTestLibrary.CreateTranslationForField(FieldTranslation, ContractType, ContractType.FieldNo(Description), LanguageMgt.GetLanguageCode(GlobalLanguage));

        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, '');
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
        Assert.AreEqual(0, SalesLine.Count, 'Untranslated Contract Type Description found');
        SalesLine.SetRange(Description, FieldTranslation.Translation);
        Assert.AreEqual(1, SalesLine.Count, 'Translated Contract Type Description not found');
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsBillToCustomerPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckContractZeroNamesAreTransferredToSalesDocumentOnBillingPerBillToContractOptionsOff()
    var
        FieldValueNotExpectedTxt: Label '"%1" should not be present as a description-line', Locked = true;
    begin
        Initialize();

        // [SCENARIO] Names are NOT transferred as Description Lines in Sales Document (Create per bill-to (see PageHandler), both options off)
        LibrarySetupStorage.Save(Database::"Subscription Contract Setup");
        PrepareCustomerContractWithNames();

        CustomerContract."Contractor Name in coll. Inv." := false;
        CustomerContract."Recipient Name in coll. Inv." := false;
        CustomerContract.Modify(false);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);

        Assert.AreEqual(0, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Sell-to Customer Name"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Sell-to Customer Name")));
        Assert.AreEqual(0, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Sell-to Customer Name 2"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Sell-to Customer Name 2")));
        Assert.AreEqual(0, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Ship-to Name"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Ship-to Name")));
        Assert.AreEqual(0, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Ship-to Name 2"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Ship-to Name 2")));
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckContractZeroNamesAreTransferredToSalesDocumentOnBillingPerContractOptionsOff()
    var
        FieldValueNotExpectedTxt: Label '"%1" should not be present as a description-line', Locked = true;
    begin
        Initialize();

        // [SCENARIO] Names are NOT transferred as Description Lines in Sales Document (Create per Contract (see PageHandler), both options off)
        LibrarySetupStorage.Save(Database::"Subscription Contract Setup");
        PrepareCustomerContractWithNames();

        CustomerContract."Contractor Name in coll. Inv." := false;
        CustomerContract."Recipient Name in coll. Inv." := false;
        CustomerContract.Modify(false);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);

        Assert.AreEqual(0, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Sell-to Customer Name"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Sell-to Customer Name")));
        Assert.AreEqual(0, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Sell-to Customer Name 2"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Sell-to Customer Name 2")));
        Assert.AreEqual(0, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Ship-to Name"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Ship-to Name")));
        Assert.AreEqual(0, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Ship-to Name 2"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Ship-to Name 2")));
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckContractZeroNamesAreTransferredToSalesDocumentOnBillingPerContractOptionsOn()
    var
        FieldValueNotExpectedTxt: Label '"%1" should not be present as a description-line', Locked = true;
    begin
        Initialize();

        // [SCENARIO] Names are NOT transferred as Description Lines in Sales Document (Create per Contract (see PageHandler), both options on)
        LibrarySetupStorage.Save(Database::"Subscription Contract Setup");
        PrepareCustomerContractWithNames();

        CustomerContract."Contractor Name in coll. Inv." := true;
        CustomerContract."Recipient Name in coll. Inv." := true;
        CustomerContract.Modify(false);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);

        Assert.AreEqual(0, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Sell-to Customer Name"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Sell-to Customer Name")));
        Assert.AreEqual(0, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Sell-to Customer Name 2"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Sell-to Customer Name 2")));
        Assert.AreEqual(0, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Ship-to Name"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Ship-to Name")));
        Assert.AreEqual(0, GetNoOfSalesInvoiceLineWithDescription(CustomerContract."Ship-to Name 2"), StrSubstNo(FieldValueNotExpectedTxt, CustomerContract.FieldCaption("Ship-to Name 2")));
    end;

    [Test]
    [HandlerFunctions('CheckDialogConfirmHandler,ExchangeRateSelectionModalPageHandler,CreateAndPostCustomerBillingDocsContractPageHandler,MessageHandler')]
    procedure CheckCustomerBillingProposalCanBeCreatedForSalesCrMemoExists()
    var
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
        SalesCrMemoExistsMsg: Label 'There is a sales credit memo that needs to be posted before an invoice can be created. Do you want to open the credit memo?', Locked = true;
    begin
        Initialize();

        // Check if correct dialog opens
        // Credit Memo exists
        LibrarySetupStorage.Save(Database::"Subscription Contract Setup");
        InitAndCreateBillingDocument("Service Partner"::Customer);
        // DialogMsg := SalesCrMemoExistsMsg;
        LibraryVariableStorage.Enqueue(SalesCrMemoExistsMsg);
        GetPostedSalesDocumentsFromContract(CustomerContract);
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesHeader);
        BillingProposal.CreateBillingProposalFromContract(CustomerContract."No.", CustomerContract.GetFilter("Billing Rhythm Filter"), "Service Partner"::Customer);
    end;

    [Test]
    [HandlerFunctions('CheckDialogConfirmHandler,ExchangeRateSelectionModalPageHandler,CreateCustomerBillingDocsContractPageHandler,MessageHandler')]
    procedure CheckCustomerBillingProposalCanBeCreatedForSalesInvoiceExists()
    var
        UnpostedSalesInvExistsMsg: Label 'Billing line with unposted Sales Invoice exists. New invoices cannot be created until the current invoice is posted. Do you want to open the invoice?';
    begin
        Initialize();

        // Check if correct dialog opens
        // Unposted invoice exists
        LibrarySetupStorage.Save(Database::"Subscription Contract Setup");
        InitAndCreateBillingDocument("Service Partner"::Customer);
        // DialogMsg := UnpostedSalesInvExistsMsg;
        LibraryVariableStorage.Enqueue(UnpostedSalesInvExistsMsg);
        BillingProposal.CreateBillingProposalFromContract(CustomerContract."No.", CustomerContract.GetFilter("Billing Rhythm Filter"), "Service Partner"::Customer);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckIfBillingLinesAreDeletedOnCreateCustomerInvoiceWithError()
    var
        Customer: Record Customer;
    begin
        Initialize();

        ContractTestLibrary.DeleteAllContractRecords();
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, Customer."No.");
        Customer."Customer Posting Group" := '';
        Customer.Modify(false);
        asserterror CustomerContract.CreateBillingProposal();

        // Check if Billing lines for Customer Subscription Contract are empty
        BillingLine.Reset();
        BillingLine.SetRange("Billing Template Code", '');
        BillingLine.SetRange("Subscription Contract No.", CustomerContract."No.");
        asserterror BillingLine.FindSet();
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsPayToVendorPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckMultipleContractsPurchaseInvoiceHeaderPostingDescription()
    var
        PostedDocumentNo: Code[20];
    begin
        Initialize();

        InitAndCreateBillingDocumentsForMultipleVendorContracts();
        BillingLine.FindLast();
        PurchaseHeader.Get(Enum::"Purchase Document Type"::Invoice, BillingLine."Document No.");
        PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateGUID());
        PurchaseHeader.Modify(false);
        PostedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        PurchaseInvoiceHeader.Get(PostedDocumentNo);
        Assert.IsSubstring(PurchaseInvoiceHeader."Posting Description", 'Multiple Vendor Subscription Contract');
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsBillToCustomerPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckMultipleContractsSalesInvoiceHeaderPostingDescription()
    begin
        Initialize();

        InitAndCreateBillingDocumentsForMultipleCustomerContracts();
        BillingLine.FindLast();
        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
        SalesHeader.TestField("Posting Description", 'Multiple Customer Subscription Contracts');
        PostAndGetSalesInvoiceHeaderFromRecurringBilling();
        SalesInvoiceHeader.TestField("Posting Description", 'Multiple Customer Subscription Contracts');
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckPurchInvoiceHeaderPostingDescription()
    var
        PostedDocumentNo: Code[20];
    begin
        Initialize();
        LibrarySetupStorage.Save(Database::"Subscription Contract Setup");
        InitAndCreateBillingDocument(Enum::"Service Partner"::Vendor);
        BillingLine.FindLast();
        PurchaseHeader.Get(Enum::"Purchase Document Type"::Invoice, BillingLine."Document No.");
        PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateGUID());
        PurchaseHeader.Modify(false);
        PostedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        PurchaseInvoiceHeader.Get(PostedDocumentNo);
        Assert.IsSubstring(PurchaseInvoiceHeader."Posting Description", 'Vendor Subscription Contract ' + BillingLine."Subscription Contract No.");
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsTestOpenPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckRequestPageSelectionConfirmedForCustomer()
    begin
        Initialize();
        LibrarySetupStorage.Save(Database::"Subscription Contract Setup");
        InitAndCreateBillingDocument(Enum::"Service Partner"::Customer);
        // The Request Page has been cancelled, therefore no Sales Document should have been created
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
        LibrarySetupStorage.Save(Database::"Subscription Contract Setup");
        InitAndCreateBillingDocument(Enum::"Service Partner"::Vendor);
        // The Request Page has been cancelled, therefore no Purchase Document should have been created
        if BillingLine.FindSet() then
            repeat
                BillingLine.TestField("Document Type", Enum::"Rec. Billing Document Type"::None);
                BillingLine.TestField("Document No.", '');
            until BillingLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckSingleContractSalesInvoiceHeaderPostingDescription()
    begin
        Initialize();
        LibrarySetupStorage.Save(Database::"Subscription Contract Setup");
        InitAndCreateBillingDocument(Enum::"Service Partner"::Customer);
        BillingLine.FindLast();
        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
        SalesHeader.TestField("Posting Description", 'Customer Subscription Contract ' + BillingLine."Subscription Contract No.");
        PostAndGetSalesInvoiceHeaderFromRecurringBilling();
        SalesInvoiceHeader.TestField("Posting Description", 'Customer Subscription Contract ' + BillingLine."Subscription Contract No.");
    end;

    [Test]
    [HandlerFunctions('CheckDialogConfirmHandler,ExchangeRateSelectionModalPageHandler,CreateVendorBillingDocsTestOpenPageHandler,MessageHandler')]
    procedure CheckVendorBillingProposalCanBeCreatedForPurchaseCrMemoExists()
    var
        BillingLineArchive: Record "Billing Line Archive";
        CorrectPostedPurchaseInvoice: Codeunit "Correct Posted Purch. Invoice";
        PurchCrMemoExistsMsg: Label 'There is a purchase credit memo that needs to be posted before an invoice can be created. Do you want to open the credit memo?', Locked = true;
    begin
        Initialize();

        // Check if correct dialog opens
        // Credit Memo exists
        PostPurchaseInvoice();
        LibraryVariableStorage.Enqueue(PurchCrMemoExistsMsg);
        // DialogMsg := PurchCrMemoExistsMsg;
        ContractTestLibrary.FilterBillingLineArchiveOnContractLine(BillingLineArchive, VendorContract."No.", 0, Enum::"Service Partner"::Vendor);
        BillingLineArchive.FindFirst();
        PurchaseInvoiceHeader.Get(BillingLineArchive."Document No.");
        CorrectPostedPurchaseInvoice.CreateCreditMemoCopyDocument(PurchaseInvoiceHeader, PurchaseHeader);
        BillingProposal.CreateBillingProposalFromContract(VendorContract."No.", VendorContract.GetFilter("Billing Rhythm Filter"), "Service Partner"::Vendor);
    end;

    [Test]
    [HandlerFunctions('CheckDialogConfirmHandler,ExchangeRateSelectionModalPageHandler,CreateVendorBillingDocsTestOpenPageHandler,MessageHandler')]
    procedure CheckVendorBillingProposalCanBeCreatedForPurchaseInvoiceExists()
    var
        UnpostedPurchaseInvExistsMsg: Label 'Billing line with unposted Purchase Invoice exists. New invoices cannot be created until the current invoice is posted. Do you want to open the invoice?';
    begin
        Initialize();

        // Check if correct dialog opens
        // Unposted invoice exists
        LibrarySetupStorage.Save(Database::"Subscription Contract Setup");
        InitAndCreateBillingDocument("Service Partner"::Vendor);
        // DialogMsg := UnpostedPurchaseInvExistsMsg;
        LibraryVariableStorage.Enqueue(UnpostedPurchaseInvExistsMsg);
        BillingProposal.CreateBillingProposalFromContract(VendorContract."No.", VendorContract.GetFilter("Billing Rhythm Filter"), "Service Partner"::Vendor);
    end;

    [Test]
    [HandlerFunctions('CreateAndPostCustomerBillingDocsBillToCustomerPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CreateAndPostSalesDocumentsPerBillToCustomer()
    var
        DocumentsCount: Integer;
    begin
        Initialize();

        // Contract1, Sell-to Customer1, Bill-to Customer1
        // Contract2, Sell-to Customer2, Bill-to Customer2
        // Contract3, Sell-to Customer2, Bill-to Customer1
        // Contract4, Sell-to Customer3, Bill-to Customer1
        InitAndCreateBillingDocumentsForMultipleCustomerContracts();
        DocumentsCount := CheckIfPostedSalesDocumentsHaveBeenCreated();
        Assert.AreEqual(2, DocumentsCount, 'Posted Sales Documents were not created correctly');
    end;

    [Test]
    [HandlerFunctions('CreateAndPostCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CreateAndPostSalesDocumentsPerContract()
    var
        DocumentsCount: Integer;
    begin
        Initialize();

        // Contract1, Sell-to Customer1, Bill-to Customer1
        // Contract2, Sell-to Customer2, Bill-to Customer2
        // Contract3, Sell-to Customer2, Bill-to Customer1
        // Contract4, Sell-to Customer3, Bill-to Customer1
        InitAndCreateBillingDocumentsForMultipleCustomerContracts();
        DocumentsCount := CheckIfPostedSalesDocumentsHaveBeenCreated();
        Assert.AreEqual(4, DocumentsCount, 'Posted Sales Documents were not created correctly');
    end;

    [Test]
    [HandlerFunctions('CreateAndPostCustomerBillingDocsSellToCustomerPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CreateAndPostSalesDocumentsPerSellToCustomer()
    var
        DocumentsCount: Integer;
    begin
        Initialize();

        // Contract1, Sell-to Customer1, Bill-to Customer1
        // Contract2, Sell-to Customer2, Bill-to Customer2
        // Contract3, Sell-to Customer2, Bill-to Customer1
        // Contract4, Sell-to Customer3, Bill-to Customer1
        InitAndCreateBillingDocumentsForMultipleCustomerContracts();
        DocumentsCount := CheckIfPostedSalesDocumentsHaveBeenCreated();
        Assert.AreEqual(3, DocumentsCount, 'Posted Sales Documents were not created correctly');
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler')]
    procedure CreatePurchaseDocumentsForContractWithGLAccount()
    var
        Vendor: Record Vendor;
        DocumentsCount: Integer;
    begin
        // [SCENARIO] Create a Purchase Document for Contract containing one G/L Account line and check document

        // [GIVEN] A Vendor Subscription Contract has been with G/L Account Line
        ClearAll();
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContract(VendorContract, Vendor."No.");
        ContractTestLibrary.InsertVendorContractGLAccountLine(VendorContract, VendorContractLine);

        // [WHEN] A Purchase document has been created from a Contract
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Vendor);
        CreateBillingDocuments();

        // [THEN] The Purchase Document has been created and contains the GL Account Line
        DocumentsCount := CheckIfPurchaseDocumentsHaveBeenCreated();
        Assert.AreEqual(1, DocumentsCount, 'Purchase Document was not created correctly');
        BillingLine.FindLast();
        FilterPurchaseLineOnDocumentLine(BillingLine.GetPurchaseDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");
        PurchaseLine.FindSet();
        PurchaseLine.TestField("No.", VendorContractLine."No.");
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsBuyFromVendorPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CreatePurchaseDocumentsPerBuyFromVendor()
    var
        DocumentsCount: Integer;
    begin
        Initialize();

        // Contract1, Buy-from Vendor1, Pay-to Vendor1
        // Contract2, Buy-from Vendor2, Pay-to Vendor2
        // Contract3, Buy-from Vendor2, Pay-to Vendor1
        // Contract4, Buy-from Vendor3, Pay-to Vendor1
        InitAndCreateBillingDocumentsForMultipleVendorContracts();
        DocumentsCount := CheckIfPurchaseDocumentsHaveBeenCreated();
        Assert.AreEqual(3, DocumentsCount, 'Purchase Documents were not created correctly');
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CreatePurchaseDocumentsPerContract()
    var
        DocumentsCount: Integer;
    begin
        Initialize();

        // Contract1, Buy-from Vendor1, Pay-to Vendor1
        // Contract2, Buy-from Vendor2, Pay-to Vendor2
        // Contract3, Buy-from Vendor2, Bill-to Vendor1
        // Contract4, Buy-from Vendor3, Bill-to Vendor1
        InitAndCreateBillingDocumentsForMultipleVendorContracts();
        DocumentsCount := CheckIfPurchaseDocumentsHaveBeenCreated();
        Assert.AreEqual(4, DocumentsCount, 'Purchase Documents were not created correctly');
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CreatePurchaseDocumentsPerCurrencyCode()
    var
        Vendor2: Record Vendor;
        VendorContract2: Record "Vendor Subscription Contract";
        VendorContract3: Record "Vendor Subscription Contract";
        DocumentsCount: Integer;
    begin
        Initialize();

        ContractTestLibrary.CreateVendor(Vendor2);
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract2, ServiceObject2, Vendor2."No.");
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract3, ServiceObject3, Vendor2."No.");
        VendorContract3.SetHideValidationDialog(true);
        VendorContract3.Validate("Currency Code", LibraryERM.CreateCurrencyWithRandomExchRates());
        VendorContract3.Modify(false);
        VendorContract2.SetHideValidationDialog(true);
        VendorContract2.Validate("Currency Code", LibraryERM.CreateCurrencyWithRandomExchRates());
        VendorContract2.Modify(false);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Vendor);
        CreateBillingDocuments();
        DocumentsCount := CheckIfPurchaseDocumentsHaveBeenCreated();
        Assert.AreEqual(2, DocumentsCount, 'Purchase Documents were not created correctly');
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsPayToVendorPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CreatePurchaseDocumentsPerPayToVendor()
    var
        DocumentsCount: Integer;
    begin
        Initialize();

        // Contract1, Buy-from Vendor1, Pay-to Vendor1
        // Contract2, Buy-from Vendor2, Pay-to Vendor2
        // Contract3, Buy-from Vendor2, Pay-to Vendor1
        // Contract4, Buy-from Vendor3, Pay-to Vendor1
        InitAndCreateBillingDocumentsForMultipleVendorContracts();
        DocumentsCount := CheckIfPurchaseDocumentsHaveBeenCreated();
        Assert.AreEqual(2, DocumentsCount, 'Purchase Documents were not created correctly');
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler')]
    procedure CreateSalesDocumentForContractAndCheckSorting()
    var
        Customer: Record Customer;
        Item: Record Item;
        LineSortingInSalesDocErr: Label 'Line Sorting in a sales document is wrong.', Locked = true;
        LastContractLineNo: Integer;
    begin
        Initialize();

        // ServiceObject
        // ServiceObject2
        // load ServiceObject2 in Contract
        // load ServiceObject1 in Contract
        // expect the same sorting in sales invoice
        LibrarySales.CreateCustomer(Customer);
        ContractTestLibrary.CreateServiceObjectForItemWithServiceCommitments(ServiceObject, Enum::"Invoicing Via"::Contract, false, Item, 1, 0);
        ServiceObject.SetHideValidationDialog(true);
        ServiceObject.Validate("End-User Customer No.", Customer."No.");
        ServiceObject.Modify(false);
        ContractTestLibrary.CreateServiceObjectForItemWithServiceCommitments(ServiceObject2, Enum::"Invoicing Via"::Contract, false, Item, 1, 0);
        ServiceObject2.SetHideValidationDialog(true);
        ServiceObject2.Validate("End-User Customer No.", Customer."No.");
        ServiceObject2.Modify(false);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject2, Customer."No.");
        ContractTestLibrary.AssignServiceObjectForItemToCustomerContract(CustomerContract, ServiceObject, false);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
        CreateBillingDocuments();
        BillingLine.FindLast();
        FilterSalesLineOnDocumentLine(BillingLine.GetSalesDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");
        SalesLine.FindSet();
        LastContractLineNo := 0;
        repeat
            BillingLine.FilterBillingLineOnDocumentLine(BillingLine.GetBillingDocumentTypeFromSalesDocumentType(SalesLine."Document Type"), SalesLine."Document No.", SalesLine."Line No.");
            BillingLine.FindFirst();
            if LastContractLineNo > BillingLine."Subscription Contract Line No." then
                Error(LineSortingInSalesDocErr);
            LastContractLineNo := BillingLine."Subscription Contract Line No.";
        until SalesLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler')]
    procedure CreateSalesDocumentsForContractWithGLAccount()
    var
        Customer: Record Customer;
        DocumentsCount: Integer;
    begin
        // [SCENARIO] Create a Sales Document for Contract containing one G/L Account line and check document

        // [GIVEN] A Customer Subscription Contract has been with G/L Account Line
        ClearAll();
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");
        ContractTestLibrary.InsertCustomerContractGLAccountLine(CustomerContract, CustomerContractLine);

        // [WHEN] A sales document has been created from a Contract
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
        CreateBillingDocuments();

        // [THEN] The Sales Document has been created and contains the GL Account Line
        DocumentsCount := CheckIfSalesDocumentsHaveBeenCreated();
        Assert.AreEqual(1, DocumentsCount, 'Sales Document was not created correctly');
        BillingLine.FindLast();
        FilterSalesLineOnDocumentLine(BillingLine.GetSalesDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");
        SalesLine.FindSet();
        SalesLine.TestField("No.", CustomerContractLine."No.");
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsBillToCustomerPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CreateSalesDocumentsPerBillToCustomer()
    var
        DocumentsCount: Integer;
    begin
        Initialize();

        // Contract1, Sell-to Customer1, Bill-to Customer1
        // Contract2, Sell-to Customer2, Bill-to Customer2
        // Contract3, Sell-to Customer2, Bill-to Customer1
        // Contract4, Sell-to Customer3, Bill-to Customer1
        InitAndCreateBillingDocumentsForMultipleCustomerContracts();
        DocumentsCount := CheckIfSalesDocumentsHaveBeenCreated();
        Assert.AreEqual(2, DocumentsCount, 'Sales Documents were not created correctly');
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CreateSalesDocumentsPerContract()
    var
        DocumentsCount: Integer;
    begin
        Initialize();

        // Contract1, Sell-to Customer1, Bill-to Customer1
        // Contract2, Sell-to Customer2, Bill-to Customer2
        // Contract3, Sell-to Customer2, Bill-to Customer1
        // Contract4, Sell-to Customer3, Bill-to Customer1
        InitAndCreateBillingDocumentsForMultipleCustomerContracts();
        DocumentsCount := CheckIfSalesDocumentsHaveBeenCreated();
        Assert.AreEqual(4, DocumentsCount, 'Sales Documents were not created correctly');
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CreateSalesDocumentsPerCurrencyCode()
    var
        Customer2: Record Customer;
        DocumentsCount: Integer;
    begin
        Initialize();

        ContractTestLibrary.CreateCustomer(Customer2);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract2, ServiceObject2, Customer2."No.");
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract3, ServiceObject3, Customer2."No.");
        CustomerContract3.SetHideValidationDialog(true);
        CustomerContract3.Validate("Currency Code", LibraryERM.CreateCurrencyWithRandomExchRates());
        CustomerContract3.Modify(false);
        CustomerContract2.SetHideValidationDialog(true);
        CustomerContract2.Validate("Currency Code", LibraryERM.CreateCurrencyWithRandomExchRates());
        CustomerContract2.Modify(false);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
        CreateBillingDocuments();
        DocumentsCount := CheckIfSalesDocumentsHaveBeenCreated();
        Assert.AreEqual(2, DocumentsCount, 'Sales Documents were not created correctly');
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsSellToCustomerPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CreateSalesDocumentsPerSellToCustomer()
    var
        DocumentsCount: Integer;
    begin
        Initialize();

        // Contract1, Sell-to Customer1, Bill-to Customer1
        // Contract2, Sell-to Customer2, Bill-to Customer2
        // Contract3, Sell-to Customer2, Bill-to Customer1
        // Contract4, Sell-to Customer3, Bill-to Customer1
        InitAndCreateBillingDocumentsForMultipleCustomerContracts();
        DocumentsCount := CheckIfSalesDocumentsHaveBeenCreated();
        Assert.AreEqual(3, DocumentsCount, 'Sales Documents were not created correctly');
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure DeletePurchaseDocument()
    begin
        Initialize();
        LibrarySetupStorage.Save(Database::"Subscription Contract Setup");
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
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure DeletePurchaseLine()
    begin
        Initialize();
        LibrarySetupStorage.Save(Database::"Subscription Contract Setup");
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
    procedure DeleteSalesDocument()
    begin
        Initialize();
        LibrarySetupStorage.Save(Database::"Subscription Contract Setup");
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
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure DeleteSalesLine()
    begin
        Initialize();
        LibrarySetupStorage.Save(Database::"Subscription Contract Setup");
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
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectBillingLinesCheckErrorsForCustomer()
    begin
        Initialize();

        SetupBasicBillingProposal(Enum::"Service Partner"::Customer);
        BillingLine.SetFilter("Billing Template Code", '%1|%2', BillingTemplate.Code, BillingTemplate2.Code);
        BillingLine.SetRange(Partner, BillingLine.Partner::Customer);
        BillingLine.FindFirst();
        ServiceCommitment.Get(BillingLine."Subscription Line Entry No.");
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
        ServiceCommitment.Get(BillingLine."Subscription Line Entry No.");
        ServiceCommitment.Modify(true);
        asserterror Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);
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
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorBillingLinesForAllVendorContractLinesExist()
    begin
        Initialize();

        SetupBasicBillingProposal("Service Partner"::Vendor);
        asserterror BillingProposal.CreateBillingProposalFromContract(VendorContract."No.", VendorContract.GetFilter("Billing Rhythm Filter"), "Service Partner"::Vendor);
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorChangeBillingToDateWhenDocNoExists()
    begin
        Initialize();

        InitAndCreateBillingDocumentsForMultipleVendorContracts();
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange("Subscription Header No.", ServiceObject."No.");
        BillingLine.FindFirst();
        asserterror BillingProposal.UpdateBillingToDate(BillingLine, CalcDate('<+3D>', BillingLine."Billing to"));
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,CreateBillingDocumentPageHandler')]
    procedure ExpectErrorOnCreateSinglePurchaseDocumentOnPreviousBillingDate()
    var
        NextBillingToDate: Date;
    begin
        Initialize();

        ContractTestLibrary.DeleteAllContractRecords();
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, '', false);
        GetVendorContractServiceCommitment(VendorContract."No.");
        NextBillingToDate := CalcDate('<-1Y>', ServiceCommitment."Next Billing Date");
        LibraryVariableStorage.Enqueue(NextBillingToDate);
        BillingProposal.CreateBillingProposalFromContract(VendorContract."No.", VendorContract.GetFilter("Billing Rhythm Filter"), "Service Partner"::Vendor);
        Assert.ExpectedError(NoContractLinesFoundErr);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateBillingDocumentPageHandler,MessageHandler')]
    procedure ExpectErrorOnCreateSingleSalesDocumentOnPreviousBillingDate()
    var
        NextBillingToDate: Date;
    begin
        Initialize();

        ContractTestLibrary.DeleteAllContractRecords();
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, '', false);
        GetCustomerContractServiceCommitment(CustomerContract."No.");
        NextBillingToDate := CalcDate('<-1Y>', ServiceCommitment."Next Billing Date");
        LibraryVariableStorage.Enqueue(NextBillingToDate);
        BillingProposal.CreateBillingProposalFromContract(CustomerContract."No.", CustomerContract.GetFilter("Billing Rhythm Filter"), "Service Partner"::Customer);
        Assert.ExpectedError(NoContractLinesFoundErr);
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnModifyPurchaseHeader()
    var
        CorrectPostedPurchaseInvoice: Codeunit "Correct Posted Purch. Invoice";
        FieldsList: List of [Integer];
        PostedDocumentNo: Code[20];
    begin
        Initialize();
        LibrarySetupStorage.Save(Database::"Subscription Contract Setup");
        InitAndCreateBillingDocument(Enum::"Service Partner"::Vendor);
        BillingLine.FindLast();
        PurchaseHeader.Get(Enum::"Purchase Document Type"::Invoice, BillingLine."Document No.");

        PopulateListOfFieldsForHeaders(false, FieldsList);
        TestRecordFieldsChanges(PurchaseHeader, FieldsList);

        PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateGUID());
        PurchaseHeader.Modify(false);
        PostedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        PurchaseInvoiceHeader.Get(PostedDocumentNo);
        CorrectPostedPurchaseInvoice.CreateCreditMemoCopyDocument(PurchaseInvoiceHeader, PurchaseHeader); // check if its necessary to test Cr Memo

        TestRecordFieldsChanges(PurchaseHeader, FieldsList);
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnModifyPurchaseLine()
    var
        CorrectPostedPurchaseInvoice: Codeunit "Correct Posted Purch. Invoice";
        PurchaseCrMemoSubForm: TestPage "Purch. Cr. Memo Subform";
        PurchaseInvoiceSubForm: TestPage "Purch. Invoice Subform";
        FieldsList: List of [Integer];
        PostedDocumentNo: Code[20];
    begin
        Initialize();
        LibrarySetupStorage.Save(Database::"Subscription Contract Setup");
        InitAndCreateBillingDocument(Enum::"Service Partner"::Vendor);
        Commit(); // persist Invoice until the end of the test
        BillingLine.FindLast();
        PurchaseHeader.Get(Enum::"Purchase Document Type"::Invoice, BillingLine."Document No.");
        FilterPurchaseLineOnDocumentLine(BillingLine.GetPurchaseDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");
        PurchaseLine.FindFirst();

        PurchaseInvoiceSubForm.OpenEdit();
        PurchaseInvoiceSubForm.GoToRecord(PurchaseLine);
        asserterror PurchaseInvoiceSubForm."Invoice Disc. Pct.".SetValue(LibraryRandom.RandInt(10));
        asserterror PurchaseInvoiceSubForm.InvoiceDiscountAmount.SetValue(LibraryRandom.RandInt(10));
        PurchaseInvoiceSubForm.Close();

        PopulateListOfFieldsForLines(FieldsList);
        TestRecordFieldsChanges(PurchaseLine, FieldsList);

        PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateGUID());
        PurchaseHeader.Modify(false);
        PostedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        PurchaseInvoiceHeader.Get(PostedDocumentNo);
        CorrectPostedPurchaseInvoice.CreateCreditMemoCopyDocument(PurchaseInvoiceHeader, PurchaseHeader); // check if its necessary to test Cr Memo
        Commit(); // persist Credit Memo until the end of the test
        BillingLine.FindLast(); // Fetch new BillingLine created for Cr Memo
        FilterPurchaseLineOnDocumentLine(BillingLine.GetPurchaseDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");
        PurchaseLine.FindFirst();

        PurchaseCrMemoSubForm.OpenEdit();
        PurchaseCrMemoSubForm.GoToRecord(PurchaseLine);
        asserterror PurchaseCrMemoSubForm."Invoice Disc. Pct.".SetValue(LibraryRandom.RandInt(10));
        asserterror PurchaseCrMemoSubForm."Invoice Discount Amount".SetValue(LibraryRandom.RandInt(10));
        PurchaseCrMemoSubForm.Close();

        TestRecordFieldsChanges(PurchaseLine, FieldsList);
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnModifySalesHeader()
    var
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
        FieldsList: List of [Integer];
        PostedDocumentNo: Code[20];
    begin
        Initialize();
        LibrarySetupStorage.Save(Database::"Subscription Contract Setup");
        InitAndCreateBillingDocument(Enum::"Service Partner"::Customer);
        BillingLine.FindLast();
        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");

        PopulateListOfFieldsForHeaders(true, FieldsList);
        TestRecordFieldsChanges(SalesHeader, FieldsList);

        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesInvoiceHeader.Get(PostedDocumentNo);
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesHeader); // check if its necessary to test Cr Memo

        TestRecordFieldsChanges(SalesHeader, FieldsList);
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnModifySalesLine()
    var
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
        SalesCrMemoSubForm: TestPage "Sales Cr. Memo Subform";
        SalesInvoiceSubForm: TestPage "Sales Invoice Subform";
        FieldsList: List of [Integer];
        PostedDocumentNo: Code[20];
    begin
        Initialize();
        LibrarySetupStorage.Save(Database::"Subscription Contract Setup");
        InitAndCreateBillingDocument(Enum::"Service Partner"::Customer);
        Commit(); // persist Invoice until the end of the test
        BillingLine.FindLast();
        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
        FilterSalesLineOnDocumentLine(BillingLine.GetSalesDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");
        SalesLine.FindFirst();

        PopulateListOfFieldsForLines(FieldsList);
        TestRecordFieldsChanges(SalesLine, FieldsList);

        SalesInvoiceSubForm.OpenEdit();
        SalesInvoiceSubForm.GoToRecord(SalesLine);
        asserterror SalesInvoiceSubForm."Invoice Disc. Pct.".SetValue(LibraryRandom.RandInt(10));
        asserterror SalesInvoiceSubForm."Invoice Discount Amount".SetValue(LibraryRandom.RandInt(10));
        SalesInvoiceSubForm.Close();

        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesInvoiceHeader.Get(PostedDocumentNo);
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesHeader); // check if its necessary to test Cr Memo
        Commit(); // persist Credit Memo until the end of the test
        BillingLine.FindLast(); // Fetch new BillingLine created for Cr Memo
        FilterSalesLineOnDocumentLine(BillingLine.GetSalesDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");
        SalesLine.FindFirst();
        SalesCrMemoSubForm.OpenEdit();
        SalesCrMemoSubForm.GoToRecord(SalesLine);
        asserterror SalesCrMemoSubForm."Invoice Disc. Pct.".SetValue(LibraryRandom.RandInt(10));
        asserterror SalesCrMemoSubForm."Invoice Discount Amount".SetValue(LibraryRandom.RandInt(10));
        SalesCrMemoSubForm.Close();

        TestRecordFieldsChanges(SalesLine, FieldsList);
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnServiceObjectDescriptionChangeWhenUnpostedDocumentsExistCustomer()
    begin
        Initialize();
        LibrarySetupStorage.Save(Database::"Subscription Contract Setup");
        InitAndCreateBillingDocument("Service Partner"::Customer);
        CheckIfSalesDocumentsHaveBeenCreated();
        asserterror ServiceObject.Validate(Description, LibraryRandom.RandText(MaxStrLen(ServiceObject.Description)));
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnServiceObjectDescriptionChangeWhenUnpostedDocumentsExistVendor()
    begin
        Initialize();
        LibrarySetupStorage.Save(Database::"Subscription Contract Setup");
        InitAndCreateBillingDocument("Service Partner"::Vendor);
        CheckIfPurchaseDocumentsHaveBeenCreated();
        asserterror ServiceObject.Validate(Description, LibraryRandom.RandText(MaxStrLen(ServiceObject.Description)));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes,MessageHandler,CreateCustomerBillingDocsModalPageHandler')]
    procedure ExpectVariantCodeFromServiceObjectWhenCreateInvoiceFromCustomerContract()
    var
        Customer: Record Customer;
        Item: Record Item;
        ItemVariant: Record "Item Variant";
    begin
        // [SCENARIO] When create Invoice from Customer Subscription Contract, Variant Code from Subscription is transferred to Sales Line if exist
        Initialize();

        // [GIVEN] Create: Subscription Item with Variant, Subscription with Subscription Line, Customer Subscription Contract with Lines and Billing Proposal
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        LibraryInventory.CreateVariant(ItemVariant, Item);
        LibrarySales.CreateCustomer(Customer);
        ContractTestLibrary.CreateServiceObjectForItemWithServiceCommitments(ServiceObject, Enum::"Invoicing Via"::Contract, false, Item, 1, 0);
        ServiceObject."Variant Code" := ItemVariant.Code;
        ServiceObject.Validate("End-User Customer No.", Customer."No.");
        ServiceObject.Modify(false);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, Customer."No.", false);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);

        // [WHEN] Create Invoice from Customer Subscription Contract
        CreateBillingDocuments();
        BillingLine.FindLast();
        FilterSalesLineOnDocumentLine(BillingLine.GetSalesDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");
        SalesLine.FindSet();
        SalesLine.FindFirst();

        // [THEN] Variant Code from Subscription is transferred to Sales Line
        Assert.AreEqual(ServiceObject."Variant Code", SalesLine."Variant Code", 'Variant Code from Service Object should be transferred to Sales Line if exist');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes,ExchangeRateSelectionModalPageHandler,MessageHandler,CreateVendorBillingDocsModalPageHandler')]
    procedure ExpectVariantCodeFromServiceObjectWhenCreateInvoiceFromVendorContract()
    var
        Customer: Record Customer;
        Item: Record Item;
        ItemVariant: Record "Item Variant";
    begin
        // [SCENARIO] When create Invoice from Vendor Subscription Contract, Variant Code from Subscription is transferred to Purchase Line if exist
        Initialize();

        // [GIVEN] Create: Subscription Item with Variant, Subscription with Subscription Line, Vendor Subscription Contract with Lines and Billing Proposal
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        LibraryInventory.CreateVariant(ItemVariant, Item);
        LibrarySales.CreateCustomer(Customer);
        ContractTestLibrary.CreateServiceObjectForItemWithServiceCommitments(ServiceObject, Enum::"Invoicing Via"::Contract, false, Item, 0, 1);
        ServiceObject."Variant Code" := ItemVariant.Code;
        ServiceObject.Validate("End-User Customer No.", Customer."No.");
        ServiceObject.Modify(false);
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, '', false);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Vendor);

        // [WHEN] Create Invoice from Vendor Subscription Contract
        CreateBillingDocuments();
        BillingLine.FindLast();
        FilterPurchaseLineOnDocumentLine(BillingLine.GetSalesDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");
        PurchaseLine.FindSet();
        PurchaseLine.FindFirst();

        // [THEN] Variant Code from Subscription is transferred to Purchase Line
        Assert.AreEqual(ServiceObject."Variant Code", PurchaseLine."Variant Code", 'Variant Code from Service Object should be transferred to Purchase Line if exist');
    end;

    [Test]
    [HandlerFunctions('MessageHandler,GetVendorContractLinesPageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure GetVendorContractLinesInPurchaseInvoices()
    var
        Item: Record Item;
        Vendor: Record Vendor;
    begin
        // [SCENARIO] Test if Vendor Subscription Contract line can be fetched to purchase invoice and test if invoice can be posted

        // [GIVEN] Setup Subscription with Subscription Line and assign it to Vendor Subscription Contract
        ContractTestLibrary.DeleteAllContractRecords();
        Clear(ServiceObject);
        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateServiceObjectForItemWithServiceCommitments(ServiceObject, "Invoicing Via"::Contract, false, Item, 0, 1);
        ContractTestLibrary.CreateVendorContract(VendorContract, Vendor."No.");
        ContractTestLibrary.AssignServiceObjectForItemToVendorContract(VendorContract, ServiceObject, false);
        LibraryPurchase.CreatePurchaseInvoiceForVendorNo(PurchaseHeader, Vendor."No.");

        // [WHEN] Invoke Get Vendor Subscription Contract Lines
        PurchaseHeader.RunGetVendorContractLines();
        // Commit()); // retain changes

        // [THEN] Test if purchase line is created with Item No. from Subscription
        GetVendorContractServiceCommitment(VendorContract."No.");
        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        PurchaseLine.SetRange("No.", ServiceCommitment."Invoicing Item No.");
        Assert.RecordIsNotEmpty(PurchaseLine);

        // [THEN] Test if Purchase header is marked as Recurring billing
        PurchaseHeader.Get(PurchaseHeader."Document Type", PurchaseHeader."No.");
        PurchaseHeader.TestField("Recurring Billing", true);

        // [THEN] Test if billing lines exist
        PurchaseLine.FindFirst();
        BillingLine.Reset();
        BillingLine.FilterBillingLineOnDocumentLine(BillingLine.GetBillingDocumentTypeFromPurchaseDocumentType(PurchaseLine."Document Type"), PurchaseLine."Document No.", PurchaseLine."Line No.");
        Assert.RecordIsNotEmpty(BillingLine);

        // [THEN] If Purchase Line is deleted, billing lines are deleted as well
        PurchaseLine.Delete(true);
        BillingLine.Reset();
        BillingLine.FilterBillingLineOnDocumentLine(BillingLine.GetBillingDocumentTypeFromPurchaseDocumentType(PurchaseLine."Document Type"), PurchaseLine."Document No.", PurchaseLine."Line No.");
        Assert.RecordIsEmpty(BillingLine);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,GetVendorContractLinesProducesCorrectAmountsDuringSelectionPageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure GetVendorContractLinesProducesCorrectAmountsDuringSelection()
    var
        Item: Record Item;
        Vendor: Record Vendor;
    begin
        // [SCENARIO:] Test if selection in the "Get Vendor Subscription Contract Lines" page is updating amounts correctly during Assignment
        Initialize();

        // [GIVEN] Setup Subscription with Subscription Line and assign it to Vendor Subscription Contract
        // [GIVEN] Create Purchase Invoice with Purchase Invoice Line
        ContractTestLibrary.DeleteAllContractRecords();
        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, Vendor."No.");
        GetVendorContractServiceCommitment(VendorContract."No.");
        ServiceCommitment."Billing Rhythm" := ServiceCommitment."Billing Base Period";
        ServiceCommitment.Modify(false);
        LibraryPurchase.CreatePurchaseInvoiceForVendorNo(PurchaseHeader, Vendor."No.");
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, "Purchase Line Type"::Item, Item."No.", 1);
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDec(100, 2));
        PurchaseLine.Modify(false);
        // [WHEN] Invoke Get Vendor Subscription Contract Lines
        PurchaseHeader.RunGetVendorContractLines(); // Testing is done in the modal page handler
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure PostPurchaseInvoice()
    var
        PostedDocumentNo: Code[20];
    begin
        Initialize();
        LibrarySetupStorage.Save(Database::"Subscription Contract Setup");
        InitAndCreateBillingDocument(Enum::"Service Partner"::Vendor);
        BillingLine.FindLast();
        PurchaseHeader.Get(Enum::"Purchase Document Type"::Invoice, BillingLine."Document No.");
        PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateGUID());
        PurchaseHeader.Modify(false);
        PostedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        PurchaseInvoiceHeader.Get(PostedDocumentNo);
        BillingLine.Reset();
        BillingLine.SetRange("Subscription Contract No.", VendorContract."No.");
        asserterror BillingLine.FindFirst();
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure PostSalesInvoice()
    var
        PostedDocumentNo: Code[20];
    begin
        Initialize();
        LibrarySetupStorage.Save(Database::"Subscription Contract Setup");
        InitAndCreateBillingDocument(Enum::"Service Partner"::Customer);
        BillingLine.FindLast();
        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesInvoiceHeader.Get(PostedDocumentNo);
        BillingLine.Reset();
        BillingLine.SetRange("Subscription Contract No.", CustomerContract."No.");
        asserterror BillingLine.FindFirst();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,CreateBillingDocumentPageHandler')]
    procedure TestBillingLineOnCreateSinglePurchaseDocument()
    var
        NextBillingToDate: Date;
    begin
        Initialize();

        ContractTestLibrary.DeleteAllContractRecords();
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, '', false);
        GetVendorContractServiceCommitment(VendorContract."No.");
        NextBillingToDate := ServiceCommitment."Next Billing Date";
        LibraryVariableStorage.Enqueue(NextBillingToDate);
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
    procedure TestBillingLineOnCreateSingleSalesDocument()
    var
        NextBillingToDate: Date;
    begin
        Initialize();

        ContractTestLibrary.DeleteAllContractRecords();
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, '', false);
        GetCustomerContractServiceCommitment(CustomerContract."No.");
        NextBillingToDate := ServiceCommitment."Next Billing Date";
        LibraryVariableStorage.Enqueue(NextBillingToDate);
        BillingProposal.CreateBillingProposalFromContract(CustomerContract."No.", CustomerContract.GetFilter("Billing Rhythm Filter"), "Service Partner"::Customer);
        BillingLine.FindLast();
        BillingLine.TestField("Document Type", "Rec. Billing Document Type"::Invoice);
        BillingLine.TestField("Document No.");
        BillingLine.TestField("Billing Template Code", '');
        BillingLine.TestField("Billing to", NextBillingToDate);
        BillingLine.TestField("User ID", UserId);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestBillingLinesAreDeletedForCreditMemos()
    var
        Item: Record Item;
        ServiceCommPackageLine: Record "Subscription Package Line";
        NegativeCalcBaseAmtErr: Label 'Setup-Failure: negative "Calculation Base Amount" expected for Subscription Line.', Locked = true;
    begin
        Initialize();

        // [SCENARIO] When a Credit Memo (created directly from a Contract) is deleted, all linked Billing Lines should also be deleted
        Clear(SalesHeader);
        Clear(CustomerContract);

        ServiceCommPackageLine.Reset();
        if not ServiceCommPackageLine.IsEmpty() then
            ServiceCommPackageLine.DeleteAll(false);
        ContractTestLibrary.CreateItemForServiceObjectWithServiceCommitments(Item);
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
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();
        if ServiceCommitment."Calculation Base Amount" >= 0 then
            Error(NegativeCalcBaseAmtErr);

        BillingProposal.CreateBillingProposalForContract(
            Enum::"Service Partner"::Customer,
            CustomerContract."No.",
            '',
            '',
            CalcDate('<2M-CM>', WorkDate()),
            CalcDate('<2M-CM>', WorkDate()));
        if not BillingProposal.CreateBillingDocument(
            Enum::"Service Partner"::Customer,
            CustomerContract."No.",
            CalcDate('<2M-CM>', WorkDate()),
            CalcDate('<2M-CM>', WorkDate()),
            false,
            false)
        then
            Error(GetLastErrorText());

        CustomerContract.TestField("No.");
        BillingLine.Reset();
        BillingLine.SetRange("Subscription Contract No.", CustomerContract."No.");
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
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler')]
    procedure TestBillingLinesWithCreditMemoDocumentType()
    var
        Item: Record Item;
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceCommitmentTemplate: Record "Sub. Package Line Template";
        ServiceCommPackageLine: Record "Subscription Package Line";
        WrongSignErr: Label 'Unit Price and Line Amount in Credit memo have wrong sign', Locked = true;
        InitialNextBillingDate: Date;
        PreviousNextBillingDate: Date;
    begin
        Initialize();

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
        BillingLine.SetRange("Subscription Contract No.", CustomerContract."No.");
        BillingLine.FindSet();
        repeat
            BillingLine.TestField("Document Type", BillingLine."Document Type"::"Credit Memo");
        until BillingLine.Next() = 0;
        CustomerContractLine.Get(BillingLine."Subscription Contract No.", BillingLine."Subscription Contract Line No."); // Save Customer Subscription Contract Line

        FilterSalesLineOnDocumentLine(BillingLine.GetSalesDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");
        SalesLine.SetRange(Type, "Sales Line Type"::Item);
        SalesLine.FindSet();
        if SalesLine."Line Amount" < 0 then
            Error(WrongSignErr);
        CustomerContractLine.GetServiceCommitment(ServiceCommitment);
        PreviousNextBillingDate := ServiceCommitment."Next Billing Date";

        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        SalesHeader.Delete(true);
        CustomerContractLine.GetServiceCommitment(ServiceCommitment);
        Assert.AreEqual(ServiceCommitment."Next Billing Date", PreviousNextBillingDate, 'Next billing date was updated when Sales Document is deleted');

        BillingLine.FindLast();
        repeat
            BillingLine.Delete(true);
        until BillingLine.Next(-1) = 0;
        CustomerContractLine.GetServiceCommitment(ServiceCommitment);
        Assert.AreEqual(ServiceCommitment."Next Billing Date", InitialNextBillingDate, 'Next billing date was not updated when billing line is deleted');
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler')]
    procedure TestBillingLinesWithInvoiceDocumentType()
    var
        Item: Record Item;
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceCommitmentTemplate: Record "Sub. Package Line Template";
        ServiceCommPackageLine: Record "Subscription Package Line";
    begin
        Initialize();

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
        BillingLine.SetRange("Subscription Contract No.", CustomerContract."No.");
        BillingLine.FindSet();
        repeat
            BillingLine.TestField("Document Type", BillingLine."Document Type"::Invoice);
        until BillingLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateBillingDocumentPageHandler,MessageHandler')]
    procedure TestCustomerContractSalesInvoicePricesTakenFromServiceCommitment()
    var
        Item: Record Item;
        PriceListHeader: Record "Price List Header";
        PriceListLine: Record "Price List Line";
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceCommitmentTemplate: Record "Sub. Package Line Template";
        ServiceCommPackageLine: Record "Subscription Package Line";
        PriceListManagement: Codeunit "Price List Management";
        NextBillingToDate: Date;
    begin
        // [SCENARIO] Test if Prices in Sales Invoice (created from Customer Subscription Contract) are taken from Subscription Lines
        Initialize();

        // [GIVEN]
        // Setup Subscription Item with sales price
        // Create Subscription from the Sales order
        // Assign the Subscription Line to the Customer Subscription Contract (at this point Subscription Line has prices taken from the sales order)
        ContractTestLibrary.DeleteAllContractRecords();

        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate, '<1M>', 100, "Invoicing Via"::Contract, "Calculation Base Type"::"Document Price", false);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '<1M>', 100, '', "Service Partner"::Customer, Item."No.", "Invoicing Via"::Contract, "Calculation Base Type"::"Document Price", '', '<1M>', false);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage.Code);

        LibraryPriceCalculation.CreatePriceHeader(PriceListHeader, "Price Type"::Sale, "Price Source Type"::"All Customers", '');
        LibraryPriceCalculation.CreatePriceListLine(PriceListLine, PriceListHeader.Code, PriceListHeader."Price Type", PriceListHeader."Source Type", PriceListHeader."Parent Source No.", PriceListHeader."Source No.", Enum::"Price Amount Type"::Any, Enum::"Price Asset Type"::Item, Item."No.");
        PriceListManagement.ActivateDraftLines(PriceListHeader);

        LibrarySales.CreateSalesDocumentWithItem(SalesHeader, SalesLine, Enum::"Sales Document Type"::Order, '', Item."No.", LibraryRandom.RandDecInRange(1, 8, 0), '', CalcDate('<-CM>', WorkDate()));
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        ServiceObject.FindLast();
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, SalesHeader."Sell-to Customer No.", false);
        GetCustomerContractServiceCommitment(CustomerContract."No.");

        // [WHEN]
        // Create purchase invoice directly from the Vendor Subscription Contract
        NextBillingToDate := CalcDate('<CM>', ServiceCommitment."Next Billing Date"); // Take the whole month for more accurate comparison
        LibraryVariableStorage.Enqueue(NextBillingToDate);
        BillingProposal.CreateBillingProposalFromContract(CustomerContract."No.", CustomerContract.GetFilter("Billing Rhythm Filter"), "Service Partner"::Customer);
        BillingLine.FindLast();
        // [THEN]
        // Expect that Discount from the price list is not applied in the sales line
        // Expect that the Line amount is set from the Subscription Line and not the price list
        FilterSalesLineOnDocumentLine(BillingLine.GetSalesDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");
        SalesLine.SetRange("Line Amount", ServiceCommitment.Amount);
        SalesLine.SetRange("Line Discount %", ServiceCommitment."Discount %");
        Assert.RecordIsNotEmpty(SalesLine);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,CreateBillingDocumentPageHandler')]
    procedure TestDeleteSinglePurchaseDocument()
    var
        NextBillingToDate: Date;
    begin
        Initialize();

        ContractTestLibrary.DeleteAllContractRecords();
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, '', false);
        GetVendorContractServiceCommitment(VendorContract."No.");
        NextBillingToDate := ServiceCommitment."Next Billing Date";
        LibraryVariableStorage.Enqueue(NextBillingToDate);
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
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,CreateBillingDocumentPageHandler')]
    procedure TestDeleteSingleSalesDocument()
    var
        NextBillingToDate: Date;
    begin
        Initialize();

        ContractTestLibrary.DeleteAllContractRecords();
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, '', false);
        GetCustomerContractServiceCommitment(CustomerContract."No.");
        NextBillingToDate := ServiceCommitment."Next Billing Date";
        LibraryVariableStorage.Enqueue(NextBillingToDate);
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
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,CreateVendorBillingDocsContractPageHandler,BillingLinesArchivePageHandler')]
    procedure TestOpenBillingLinesArchiveFromPurchaseCreditMemo()
    var
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        CorrectPostedPurchaseInvoice: Codeunit "Correct Posted Purch. Invoice";
        ExpectedNoOfArchivedLines: Integer;
        PostedDocumentNo: Code[20];
    begin
        Initialize();

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
        PurchCrMemoLine.SetFilter("Subscription Contract No.", '<>%1', '');
        PurchCrMemoLine.SetFilter("Subscription Contract Line No.", '<>%1', 0);
        PurchCrMemoLine.FindFirst();
        ExpectedNoOfArchivedLines := CountBillingArchiveLinesOnDocument(Enum::"Rec. Billing Document Type"::"Credit Memo", PostedDocumentNo, "Service Partner"::Vendor, PurchCrMemoLine."Subscription Contract No.", PurchCrMemoLine."Subscription Contract Line No.");
        LibraryVariableStorage.Enqueue(ExpectedNoOfArchivedLines);
        ContractsGeneralMgt.ShowArchivedBillingLines(PurchCrMemoLine."Subscription Contract No.", PurchCrMemoLine."Subscription Contract Line No.", "Service Partner"::Vendor, Enum::"Rec. Billing Document Type"::"Credit Memo", PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,CreateVendorBillingDocsContractPageHandler,BillingLinesArchivePageHandler')]
    procedure TestOpenBillingLinesArchiveFromPurchaseInvoice()
    var
        PurchInvLine: Record "Purch. Inv. Line";
        ExpectedNoOfArchivedLines: Integer;
        PostedDocumentNo: Code[20];
    begin
        Initialize();

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
        PurchInvLine.SetFilter("Subscription Contract No.", '<>%1', '');
        PurchInvLine.SetFilter("Subscription Contract Line No.", '<>%1', 0);
        PurchInvLine.FindFirst();
        ExpectedNoOfArchivedLines := CountBillingArchiveLinesOnDocument(Enum::"Rec. Billing Document Type"::Invoice, PostedDocumentNo, "Service Partner"::Vendor, PurchInvLine."Subscription Contract No.", PurchInvLine."Subscription Contract Line No.");
        LibraryVariableStorage.Enqueue(ExpectedNoOfArchivedLines);
        ContractsGeneralMgt.ShowArchivedBillingLines(PurchInvLine."Subscription Contract No.", PurchInvLine."Subscription Contract Line No.", "Service Partner"::Vendor, Enum::"Rec. Billing Document Type"::Invoice, PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,CreateCustomerBillingDocsContractPageHandler,BillingLinesArchivePageHandler')]
    procedure TestOpenBillingLinesArchiveFromSalesCreditMemo()
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
        ExpectedNoOfArchivedLines: Integer;
        PostedDocumentNo: Code[20];
    begin
        Initialize();

        InitAndCreateBillingDocumentsForMultipleCustomerContracts();
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
        SalesCrMemoLine.SetFilter("Subscription Contract No.", '<>%1', '');
        SalesCrMemoLine.SetFilter("Subscription Contract Line No.", '<>%1', 0);
        SalesCrMemoLine.FindFirst();
        ExpectedNoOfArchivedLines := CountBillingArchiveLinesOnDocument(Enum::"Rec. Billing Document Type"::"Credit Memo", PostedDocumentNo, "Service Partner"::Customer, SalesCrMemoLine."Subscription Contract No.", SalesCrMemoLine."Subscription Contract Line No.");
        LibraryVariableStorage.Enqueue(ExpectedNoOfArchivedLines);
        ContractsGeneralMgt.ShowArchivedBillingLines(SalesCrMemoLine."Subscription Contract No.", SalesCrMemoLine."Subscription Contract Line No.", "Service Partner"::Customer, "Rec. Billing Document Type"::"Credit Memo", PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,CreateCustomerBillingDocsContractPageHandler,BillingLinesArchivePageHandler')]
    procedure TestOpenBillingLinesArchiveFromSalesInvoice()
    var
        SalesInvLine: Record "Sales Invoice Line";
        ExpectedNoOfArchivedLines: Integer;
        PostedDocumentNo: Code[20];
    begin
        Initialize();

        InitAndCreateBillingDocumentsForMultipleCustomerContracts();
        BillingLine.Reset();
        BillingLine.FindSet();
        repeat
            SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
            PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true)
        until BillingLine.Next() = 0;
        SalesInvLine.SetRange("Document No.", PostedDocumentNo);
        SalesInvLine.SetFilter("Subscription Contract No.", '<>%1', '');
        SalesInvLine.SetFilter("Subscription Contract Line No.", '<>%1', 0);
        SalesInvLine.FindFirst();
        ExpectedNoOfArchivedLines := CountBillingArchiveLinesOnDocument(Enum::"Rec. Billing Document Type"::Invoice, PostedDocumentNo, "Service Partner"::Customer, SalesInvLine."Subscription Contract No.", SalesInvLine."Subscription Contract Line No.");
        LibraryVariableStorage.Enqueue(ExpectedNoOfArchivedLines);
        ContractsGeneralMgt.ShowArchivedBillingLines(SalesInvLine."Subscription Contract No.", SalesInvLine."Subscription Contract Line No.", "Service Partner"::Customer, Enum::"Rec. Billing Document Type"::Invoice, PostedDocumentNo);
    end;

    [Test]
    procedure TestPostingPurchaseInvoiceFromGeneralJournal()
    var
        GeneralJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalTemplate: Record "Gen. Journal Template";
        GLAccount: Record "G/L Account";
        Vendor: Record Vendor;
    begin
        Initialize();

        // Expect that posting of simple general journal is not affected with Recurring billing field in Vendor Ledger Entries
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
        Customer: Record Customer;
        GeneralJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalTemplate: Record "Gen. Journal Template";
        GLAccount: Record "G/L Account";
    begin
        Initialize();

        // Expect that posting of simple general journal is not affected with Recurring billing field in Customer Ledger Entries
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
    procedure TestRecurringBillingInCustLedgerEntries()
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        PostedDocumentNo: Code[20];
    begin
        Initialize();
        LibrarySetupStorage.Save(Database::"Subscription Contract Setup");
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
        PostedDocumentNo: Code[20];
    begin
        Initialize();
        LibrarySetupStorage.Save(Database::"Subscription Contract Setup");
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
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,ConfirmHandlerYes,MessageHandler,CreateCustomerBillingDocsContractPageHandler,BillingLinesArchivePageHandler')]
    procedure TestShowBillingLineArchiveFromRecreatedCustomerContractLine()
    var
        ExpectedNoOfArchivedLines: Integer;
        LineNo: Integer;
    begin
        Initialize();

        InitAndCreateBillingDocumentsForMultipleCustomerContracts();
        BillingLine.Reset();
        BillingLine.FindSet();
        repeat
            SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
            LibrarySales.PostSalesDocument(SalesHeader, true, true)
        until BillingLine.Next() = 0;

        CustomerContractLine.SetRange("Subscription Contract No.", CustomerContract."No.");
        CustomerContractLine.SetRange("Contract Line Type", Enum::"Contract Line Type"::Item);
        CustomerContractLine.FindFirst();
        ExpectedNoOfArchivedLines := CountBillingArchiveLinesOnServiceCommitment(CustomerContractLine."Subscription Line Entry No.");
        LibraryVariableStorage.Enqueue(ExpectedNoOfArchivedLines);
        ContractsGeneralMgt.ShowArchivedBillingLinesForServiceCommitment(CustomerContractLine."Subscription Line Entry No.");

        CustomerContractLine.GetServiceCommitment(ServiceCommitment);
        // Force Close Subscription Line
        ServiceCommitment."Subscription Line End Date" := CalcDate('<-1D>', Today());
        ServiceCommitment."Next Billing Date" := CalcDate('<+1D>', ServiceCommitment."Subscription Line End Date");
        ServiceCommitment.Modify(false);
        ServiceObject.UpdateServicesDates();

        // Delete Customer Subscription Contract line
        // create a new line with same line no
        LineNo := CustomerContractLine."Line No.";
        CustomerContractLine.Get(CustomerContractLine."Subscription Contract No.", CustomerContractLine."Line No.");
        CustomerContractLine.Delete(true);
        CustomerContractLine.Init();
        CustomerContractLine."Subscription Contract No." := CustomerContract."No.";
        CustomerContractLine."Line No." := LineNo;
        CustomerContractLine."Contract Line Type" := Enum::"Contract Line Type"::Comment;
        CustomerContractLine.Insert(false);

        LibraryVariableStorage.Clear();
        ExpectedNoOfArchivedLines := 0;
        LibraryVariableStorage.Enqueue(ExpectedNoOfArchivedLines);
        ContractsGeneralMgt.ShowArchivedBillingLinesForServiceCommitment(CustomerContractLine."Subscription Line Entry No.");
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,ConfirmHandlerYes,MessageHandler,CreateVendorBillingDocsContractPageHandler,BillingLinesArchivePageHandler')]
    procedure TestShowBillingLineArchiveFromRecreatedVendorContractLine()
    var
        ExpectedNoOfArchivedLines: Integer;
        LineNo: Integer;
    begin
        Initialize();

        InitAndCreateBillingDocumentsForMultipleVendorContracts();
        BillingLine.Reset();
        BillingLine.FindSet();
        repeat
            PurchaseHeader.Get(Enum::"Purchase Document Type"::Invoice, BillingLine."Document No.");
            PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateGUID());
            PurchaseHeader.Modify(false);
            LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        until BillingLine.Next() = 0;

        VendorContractLine.SetRange("Subscription Contract No.", VendorContract."No.");
        VendorContractLine.SetRange("Contract Line Type", Enum::"Contract Line Type"::Item);
        VendorContractLine.FindFirst();
        ExpectedNoOfArchivedLines := CountBillingArchiveLinesOnServiceCommitment(VendorContractLine."Subscription Line Entry No.");
        LibraryVariableStorage.Enqueue(ExpectedNoOfArchivedLines);
        ContractsGeneralMgt.ShowArchivedBillingLinesForServiceCommitment(VendorContractLine."Subscription Line Entry No.");

        VendorContractLine.GetServiceCommitment(ServiceCommitment);
        // Force Close Subscription Line
        ServiceCommitment."Subscription Line End Date" := CalcDate('<-1D>', Today());
        ServiceCommitment."Next Billing Date" := CalcDate('<+1D>', ServiceCommitment."Subscription Line End Date");
        ServiceCommitment.Modify(false);
        ServiceObject.UpdateServicesDates();

        // Delete Vendor Subscription Contract line
        // create a new line with same line no
        LineNo := VendorContractLine."Line No.";
        VendorContractLine.Get(VendorContractLine."Subscription Contract No.", VendorContractLine."Line No.");
        VendorContractLine.Delete(true);
        VendorContractLine.Init();
        VendorContractLine."Subscription Contract No." := CustomerContract."No.";
        VendorContractLine."Line No." := LineNo;
        VendorContractLine."Contract Line Type" := Enum::"Contract Line Type"::Comment;
        VendorContractLine.Insert(false);

        LibraryVariableStorage.Clear();
        ExpectedNoOfArchivedLines := 0;
        LibraryVariableStorage.Enqueue(ExpectedNoOfArchivedLines);
        ContractsGeneralMgt.ShowArchivedBillingLinesForServiceCommitment(VendorContractLine."Subscription Line Entry No.");
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,CreateCustomerBillingDocsContractPageHandler,BillingLinesArchivePageHandler')]
    procedure TestShowBillingLineArchiveFromServiceCommitment()
    var
        BillingLineArchive: Record "Billing Line Archive";
        ExpectedNoOfArchivedLines: Integer;
    begin
        Initialize();

        InitAndCreateBillingDocumentsForMultipleCustomerContracts();
        BillingLine.Reset();
        BillingLine.FindSet();
        repeat
            SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
            LibrarySales.PostSalesDocument(SalesHeader, true, true)
        until BillingLine.Next() = 0;

        CustomerContractLine.SetRange("Subscription Contract No.", CustomerContract."No.");
        CustomerContractLine.SetRange("Contract Line Type", Enum::"Contract Line Type"::Item);
        CustomerContractLine.FindFirst();
        ExpectedNoOfArchivedLines := CountBillingArchiveLinesOnServiceCommitment(CustomerContractLine."Subscription Line Entry No.");
        LibraryVariableStorage.Enqueue(ExpectedNoOfArchivedLines);
        ContractsGeneralMgt.ShowArchivedBillingLinesForServiceCommitment(CustomerContractLine."Subscription Line Entry No.");

        CustomerContractLine.GetServiceCommitment(ServiceCommitment);
        // Force Close Subscription Line
        ServiceCommitment."Subscription Line End Date" := CalcDate('<-1D>', Today());
        ServiceCommitment."Next Billing Date" := CalcDate('<+1D>', ServiceCommitment."Subscription Line End Date");
        ServiceCommitment.Modify(false);
        ServiceObject.UpdateServicesDates();
        ServiceCommitment.Delete(true);

        BillingLineArchive.FilterBillingLineArchiveOnServiceCommitment(CustomerContractLine."Subscription Line Entry No.");
        Assert.RecordIsEmpty(BillingLineArchive);
    end;

    [Test]
    [HandlerFunctions('CreateBillingDocumentPageHandler,MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure TestVendorContractPurchaseInvoicePricesTakenFromServiceCommitment()
    var
        Item: Record Item;
        PriceListHeader: Record "Price List Header";
        PriceListLine: Record "Price List Line";
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceCommitmentTemplate: Record "Sub. Package Line Template";
        ServiceCommPackageLine: Record "Subscription Package Line";
        PriceListManagement: Codeunit "Price List Management";
        NextBillingToDate: Date;
    begin
        // [SCENARIO] Test if Prices in Purchase Invoice (created from Vendor Subscription Contract) are taken from Subscription Lines
        Initialize();

        // [GIVEN]
        // Setup Subscription Item with purchase price
        // Create Subscription from the Sales order
        // Assign the Subscription Line to the Vendor Subscription Contract (at this point Subscription Line has prices taken from the sales order)

        ContractTestLibrary.DeleteAllContractRecords();

        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate, '<1M>', 100, "Invoicing Via"::Contract, "Calculation Base Type"::"Document Price", false);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '<1M>', 100, '', "Service Partner"::Vendor, Item."No.", "Invoicing Via"::Contract, "Calculation Base Type"::"Document Price", '', '<1M>', false);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage.Code);

        LibraryPriceCalculation.CreatePriceHeader(PriceListHeader, "Price Type"::Purchase, "Price Source Type"::"All Vendors", '');
        LibraryPriceCalculation.CreatePriceListLine(PriceListLine, PriceListHeader.Code, PriceListHeader."Price Type", PriceListHeader."Source Type", PriceListHeader."Parent Source No.", PriceListHeader."Source No.", Enum::"Price Amount Type"::Any, Enum::"Price Asset Type"::Item, Item."No.");
        PriceListManagement.ActivateDraftLines(PriceListHeader);

        LibrarySales.CreateSalesDocumentWithItem(SalesHeader, SalesLine, Enum::"Sales Document Type"::Order, '', Item."No.", LibraryRandom.RandDecInRange(1, 8, 0), '', CalcDate('<-CM>', WorkDate()));
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        ServiceObject.FindLast();
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, '', false);
        GetVendorContractServiceCommitment(VendorContract."No.");

        // [WHEN]
        // Create purchase invoice directly from the Vendor Subscription Contract
        NextBillingToDate := CalcDate('<CM>', ServiceCommitment."Next Billing Date"); // Take the whole month for more accurate comparison
        LibraryVariableStorage.Enqueue(NextBillingToDate);
        BillingProposal.CreateBillingProposalFromContract(VendorContract."No.", VendorContract.GetFilter("Billing Rhythm Filter"), "Service Partner"::Vendor);

        // [THEN]
        // Expect that Discount from the price list is not applied in the purchase line
        // Expect that the Line amount is set from the Subscription Line and not the price list
        BillingLine.FindLast();
        FilterPurchaseLineOnDocumentLine(BillingLine.GetPurchaseDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");
        PurchaseLine.FindFirst();
        Assert.AreEqual(PurchaseLine."Line Amount", ServiceCommitment.Amount, 'Purchase Line Line Amount does not match Service Commitment Service Amount.');
        Assert.AreEqual(PurchaseLine."Line Discount %", ServiceCommitment."Discount %", 'Purchase Line Discount % does not match Service Commitment Discount %.');
    end;

    [Test]
    procedure UT_ExpectErrorWhenItemUnitOfMeasureDoesNotExist()
    var
        Item: Record Item;
        MockServiceObject: Record "Subscription Header";
        UnitOfMeasure: Record "Unit of Measure";
        CreateBillingDocumentsCodeunit: Codeunit "Create Billing Documents";
        ItemUOMDoesNotExistErr: Label 'The Unit of Measure of the Subscription (%1) contains a value (%2) that cannot be found in the Item Unit of Measure of the corresponding Invoicing Item (%3).', Locked = true;
    begin
        // [GIVEN] Create Subscription Item with Unit of Measure
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        // [WHEN] Create Subscription with different Unit of Measure
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        MockServiceObject.Init();
        MockServiceObject."No." := LibraryUtility.GenerateGUID();
        MockServiceObject."Unit of Measure" := UnitOfMeasure.Code;

        // [THEN] Throw error if Item Unit of Measure for Invoicing Item No. does not exist
        asserterror CreateBillingDocumentsCodeunit.ErrorIfItemUnitOfMeasureCodeDoesNotExist(Item."No.", MockServiceObject);
        Assert.ExpectedError(StrSubstNo(ItemUOMDoesNotExistErr, MockServiceObject."No.", MockServiceObject."Unit of Measure", Item."No."));
    end;

    #endregion Tests

    #region Procedures

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Recurring Billing Docs Test");
        ContractTestLibrary.InitContractsApp();

        LibrarySetupStorage.Restore();
        Clear(LibrarySetupStorage);
        LibraryVariableStorage.AssertEmpty();
        Clear(LibraryVariableStorage);

        ClearAll();

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Recurring Billing Docs Test");
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        LibraryERMCountryData.UpdateSalesReceivablesSetup();
        LibraryERMCountryData.UpdateGeneralLedgerSetup();
        LibraryERMCountryData.UpdateJournalTemplMandatory(false);
        ContractTestLibrary.InitSourceCodeSetup();
        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Recurring Billing Docs Test");
    end;

    local procedure CheckIfPostedSalesDocumentsHaveBeenCreated() DocumentCount: Integer
    begin
        TempSalesInvoiceHeader.Reset();
        TempSalesInvoiceHeader.DeleteAll(false);
        DocumentCount += GetPostedSalesDocumentsFromContract(CustomerContract);
        DocumentCount += GetPostedSalesDocumentsFromContract(CustomerContract2);
        DocumentCount += GetPostedSalesDocumentsFromContract(CustomerContract3);
        DocumentCount += GetPostedSalesDocumentsFromContract(CustomerContract4);
    end;

    local procedure CheckIfPurchaseDocumentsHaveBeenCreated() DocumentCount: Integer
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
                Assert.AreEqual(1, PurchaseLine.Count, 'The Purchase lines were not created properly.');
                PurchaseLine.FindFirst();
                PurchaseLine.TestField(Description, BillingLine."Subscription Line Description");
                BillingLine.CalcFields("Subscription Description");
                PurchaseLine.TestField("Description 2", BillingLine."Subscription Description");
                if not TempPurchaseHeader.Get(PurchaseHeader."Document Type", PurchaseHeader."No.") then begin
                    TempPurchaseHeader.TransferFields(PurchaseHeader);
                    TempPurchaseHeader.Insert(false);
                    DocumentCount += 1;
                end;
            until BillingLine.Next() = 0;
    end;

    local procedure CheckIfSalesDocumentsHaveBeenCreated() DocumentsCount: Integer
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
                Assert.AreEqual(1, SalesLine.Count, 'The Sales lines were not created properly.');
                SalesLine.FindFirst();
                BillingLine.CalcFields("Subscription Description");
                SalesLine.TestField(Description, BillingLine."Subscription Description");
                SalesLine.TestField("Description 2", '');
                if not TempSalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.") then begin
                    TempSalesHeader.TransferFields(SalesHeader);
                    TempSalesHeader.Insert(false);
                    DocumentsCount += 1;
                end;
            until BillingLine.Next() = 0;
    end;

    local procedure CountBillingArchiveLinesOnDocument(DocumentType: Enum "Rec. Billing Document Type"; DocumentNo: Code[20]; ServicePartner: Enum "Service Partner"; ContractNo: Code[20]; ContractLineNo: Integer): Integer
    var
        BillingArchiveLine: Record "Billing Line Archive";
    begin
        BillingArchiveLine.FilterBillingLineArchiveOnContractLine(ServicePartner, ContractNo, ContractLineNo);
        BillingArchiveLine.FilterBillingLineArchiveOnDocument(DocumentType, DocumentNo);
        exit(BillingArchiveLine.Count());
    end;

    local procedure CountBillingArchiveLinesOnServiceCommitment(ServiceCommitmentEntryNo: Integer): Integer
    var
        BillingArchiveLine: Record "Billing Line Archive";
    begin
        BillingArchiveLine.FilterBillingLineArchiveOnServiceCommitment(ServiceCommitmentEntryNo);
        exit(BillingArchiveLine.Count());
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

        Assert.AreEqual(NoOfSalesInvoices, GetNumberOfContractDocumentsSales(Enum::"Sales Document Type"::Invoice), 'Unexpected No. of Sales Invoices after batch-deletion');
        Assert.AreEqual(NoOfSalesCrMemos, GetNumberOfContractDocumentsSales(Enum::"Sales Document Type"::"Credit Memo"), 'Unexpected No. of Sales Credit Memos after batch-deletion');
        Assert.AreEqual(NoOfPurchaseInvoices, GetNumberOfContractDocumentsPurchase(Enum::"Purchase Document Type"::Invoice), 'Unexpected No. of Purchase Invoices after batch-deletion');
        Assert.AreEqual(NoOfPurchaseCrMemos, GetNumberOfContractDocumentsPurchase(Enum::"Purchase Document Type"::"Credit Memo"), 'Unexpected No. of Purchase Credit Memos after batch-deletion');
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

    local procedure CreateCustomerContractAndAssignServiceObjects(ItemNo: Code[20])
    var
        TempServiceCommitment: Record "Subscription Line" temporary;
    begin
        ContractTestLibrary.CreateCustomerContract(CustomerContract, SalesHeader."Sell-to Customer No.");
        ServiceObject.Reset();
        ServiceObject.FilterOnItemNo(ItemNo);
        ServiceObject.FindSet();
        repeat
            ContractTestLibrary.FillTempServiceCommitment(TempServiceCommitment, ServiceObject, CustomerContract);
            CustomerContract.CreateCustomerContractLinesFromServiceCommitments(TempServiceCommitment);
        until ServiceObject.Next() = 0;
        CustomerContractLine.SetRange("Subscription Contract No.", CustomerContract."No.");
        CustomerContractLine.FindSet();
        repeat
            CustomerContractLine.GetServiceCommitment(ServiceCommitment);
            ServiceCommitment.Validate("Subscription Line Start Date", CalcDate('<2M-CM>', WorkDate()));
            ServiceCommitment.Modify(false);
        until CustomerContractLine.Next() = 0;
    end;

    local procedure CreateDummyContractDocumentsPurchase()
    var
        PurchaseDocumentType: Enum "Purchase Document Type";
        i: Integer;
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

    local procedure CreateDummyContractDocumentsSales()
    var
        SalesDocumentType: Enum "Sales Document Type";
        i: Integer;
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

    local procedure FilterPurchaseLineOnDocumentLine(PurchaseDocumentType: Enum "Purchase Document Type"; DocumentNo: Code[20]; LineNo: Integer)
    begin
        PurchaseLine.SetRange("Document Type", PurchaseDocumentType);
        PurchaseLine.SetRange("Document No.", DocumentNo);
        PurchaseLine.SetRange("Line No.", LineNo);
    end;

    local procedure FilterSalesLineOnDocumentLine(SalesDocumentType: Enum "Sales Document Type"; DocumentNo: Code[20]; LineNo: Integer)
    begin
        SalesLine.SetRange("Document Type", SalesDocumentType);
        SalesLine.SetRange("Document No.", DocumentNo);
        SalesLine.SetRange("Line No.", LineNo);
    end;

    local procedure GetCustomerContractServiceCommitment(ContractNo: Code[20])
    begin
        CustomerContractLine.SetRange("Subscription Contract No.", ContractNo);
        CustomerContractLine.FindFirst();
        CustomerContractLine.GetServiceCommitment(ServiceCommitment);
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

    local procedure GetNumberOfContractDocumentsPurchase(DocumentType: Enum "Purchase Document Type"): Integer
    begin
        PurchaseHeader.Reset();
        PurchaseHeader.SetRange("Document Type", DocumentType);
        PurchaseHeader.SetRange("Recurring Billing", true);
        exit(PurchaseHeader.Count());
    end;

    local procedure GetNumberOfContractDocumentsSales(DocumentType: Enum "Sales Document Type"): Integer
    begin
        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", DocumentType);
        SalesHeader.SetRange("Recurring Billing", true);
        exit(SalesHeader.Count());
    end;

    local procedure GetPostedSalesDocumentsFromContract(SourceCustomerContract: Record "Customer Subscription Contract") DocumentsCount: Integer
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

    local procedure GetVendorContractServiceCommitment(ContractNo: Code[20])
    begin
        VendorContractLine.SetRange("Subscription Contract No.", ContractNo);
        VendorContractLine.FindFirst();
        ServiceCommitment.Get(VendorContractLine."Subscription Line Entry No.")
    end;

    local procedure InitAndCreateBillingDocument(ServicePartner: Enum "Service Partner")
    begin
        SetupBasicBillingProposal(ServicePartner);
        CreateBillingDocuments();
    end;

    local procedure InitAndCreateBillingDocumentsForMultipleCustomerContracts()
    var
        Customer2: Record Customer;
        Customer3: Record Customer;
    begin
        // Contract1, Sell-to Customer1, Bill-to Customer1
        // Contract2, Sell-to Customer2, Bill-to Customer2
        // Contract3, Sell-to Customer2, Bill-to Customer1
        // Contract4, Sell-to Customer3, Bill-to Customer1
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, '');
        ContractTestLibrary.CreateCustomer(Customer2);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract2, ServiceObject2, Customer2."No.");
        CustomerContract2.Validate("Currency Code", CustomerContract."Currency Code");
        CustomerContract2.Modify(false);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract3, ServiceObject3, Customer2."No.");
        CustomerContract3.SetHideValidationDialog(true);
        CustomerContract3.Validate("Bill-to Customer No.", CustomerContract."Bill-to Customer No.");
        CustomerContract3.Validate("Currency Code", CustomerContract."Currency Code");
        CustomerContract3.Modify(false);
        ContractTestLibrary.CreateCustomer(Customer3);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract4, ServiceObject4, Customer3."No.");
        CustomerContract4.SetHideValidationDialog(true);
        CustomerContract4.Validate("Bill-to Customer No.", CustomerContract."Bill-to Customer No.");
        CustomerContract4.Validate("Currency Code", CustomerContract."Currency Code");
        CustomerContract4.Modify(false);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
        CreateBillingDocuments();
    end;

    local procedure InitAndCreateBillingDocumentsForMultipleVendorContracts()
    var
        Vendor2: Record Vendor;
        Vendor3: Record Vendor;
        VendorContract2: Record "Vendor Subscription Contract";
        VendorContract3: Record "Vendor Subscription Contract";
        VendorContract4: Record "Vendor Subscription Contract";
    begin
        // Contract1, Sell-to Customer1, Bill-to Customer1
        // Contract2, Sell-to Customer2, Bill-to Customer2
        // Contract3, Sell-to Customer2, Bill-to Customer1
        // Contract4, Sell-to Customer3, Bill-to Customer1
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, '');
        ContractTestLibrary.CreateVendor(Vendor2);
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract2, ServiceObject2, Vendor2."No.");
        VendorContract2.Validate("Currency Code", VendorContract."Currency Code");
        VendorContract2.Modify(false);
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract3, ServiceObject3, Vendor2."No.");
        VendorContract3.SetHideValidationDialog(true);
        VendorContract3.Validate("Currency Code", VendorContract."Currency Code");
        VendorContract3.Validate("Pay-to Vendor No.", VendorContract."Buy-from Vendor No.");
        VendorContract3.Modify(false);
        ContractTestLibrary.CreateVendor(Vendor3);
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract4, ServiceObject4, Vendor3."No.");
        VendorContract4.SetHideValidationDialog(true);
        VendorContract4.Validate("Pay-to Vendor No.", VendorContract."Buy-from Vendor No.");
        VendorContract4.Validate("Currency Code", VendorContract."Currency Code");
        VendorContract4.Modify(false);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Vendor);
        CreateBillingDocuments();
    end;

    local procedure InitServiceContractSetup()
    var
        ServiceContractSetup: Record "Subscription Contract Setup";
    begin
        ServiceContractSetup.Get();
        ServiceContractSetup."Primary Key" := ServiceContractSetup."Primary Key";
        ServiceContractSetup.ContractTextsCreateDefaults();
        ServiceContractSetup.Modify(false);
    end;

    local procedure PopulateListOfFieldsForHeaders(CalledFromSales: Boolean; var FieldsList: List of [Integer])
    begin
        Clear(FieldsList);
        FieldsList.Add(2);    // Sell-to Customer No.   // Buy-from Vendor No. (Buy-from Vendor No.)
        FieldsList.Add(4);    // Bill-to Customer No.   // Pay-to Vendor No. (Pay-to Vendor No.)
        FieldsList.Add(5);    // Bill-to Name   // Pay-to Name (Pay-to Name)
        FieldsList.Add(6);    // Bill-to Name 2   // Pay-to Name 2 (Pay-to Name 2)
        FieldsList.Add(7);    // Bill-to Address (Bill-to Address)   // Pay-to Address (Pay-to Address)
        FieldsList.Add(8);    // Bill-to Address 2 (Bill-to Address 2)   // Pay-to Address 2 (Pay-to Address 2)
        FieldsList.Add(9);    // Bill-to City (Bill-to City)   // Pay-to City (Pay-to City)
        FieldsList.Add(10);   // Bill-to Contact (Bill-to Contact)   // Pay-to Contact (Pay-to Contact)
        FieldsList.Add(12);   // Ship-to Code (Ship-to Code)   // Ship-to Code (Ship-to Code)
        FieldsList.Add(13);   // Ship-to Name (Ship-to Name)   // Ship-to Name (Ship-to Name)
        FieldsList.Add(14);   // Ship-to Name 2 (Ship-to Name 2)   // Ship-to Name 2 (Ship-to Name 2)
        FieldsList.Add(15);   // Ship-to Address (Ship-to Address)   // Ship-to Address (Ship-to Address)
        FieldsList.Add(16);   // Ship-to Address 2 (Ship-to Address 2)   // Ship-to Address 2 (Ship-to Address 2)
        FieldsList.Add(17);   // Ship-to City (Ship-to City)   // Ship-to City (Ship-to City)
        FieldsList.Add(18);   // Ship-to Contact (Ship-to Contact)   // Ship-to Contact (Ship-to Contact)
        FieldsList.Add(29);   // Shortcut Dimension 1 Code (Shortcut Dimension 1 Code)   // Shortcut Dimension 1 Code (Shortcut Dimension 1 Code)
        FieldsList.Add(30);   // Shortcut Dimension 2 Code (Shortcut Dimension 2 Code)   // Shortcut Dimension 2 Code (Shortcut Dimension 2 Code)
        FieldsList.Add(32);   // Currency Code (Currency Code)   // Currency Code (Currency Code)
        FieldsList.Add(35);   // Prices Including VAT (Prices Including VAT)   // Prices Including VAT (Prices Including VAT)
        FieldsList.Add(76);   // Transaction Type (Transaction Type)   // Transaction Type (Transaction Type)
        FieldsList.Add(77);   // Transport Method (Transport Method)   // Transport Method (Transport Method)
        FieldsList.Add(79);   // Sell-to Customer Name (Sell-to Customer Name)   // Buy-from Vendor Name (Buy-from Vendor Name)
        FieldsList.Add(80);   // Sell-to Customer Name 2 (Sell-to Customer Name 2)   // Buy-from Vendor Name 2 (Buy-from Vendor Name 2)
        FieldsList.Add(81);   // Sell-to Address (Sell-to Address)   // Buy-from Address (Buy-from Address)
        FieldsList.Add(82);   // Sell-to Address 2 (Sell-to Address 2)   // Buy-from Address 2 (Buy-from Address 2)
        FieldsList.Add(83);   // Sell-to City (Sell-to City)   // Buy-from City (Buy-from City)
        FieldsList.Add(84);   // Sell-to Contact (Sell-to Contact)   // Buy-from Contact (Buy-from Contact)
        FieldsList.Add(85);   // Bill-to Post Code (Bill-to Post Code)   // Pay-to Post Code (Pay-to Post Code)
        FieldsList.Add(86);   // Bill-to County (Bill-to County)   // Pay-to County (Pay-to County)
        FieldsList.Add(87);   // Bill-to Country/Region Code (Bill-to Country/Region Code)   // Pay-to Country/Region Code (Pay-to Country/Region Code)
        FieldsList.Add(88);   // Sell-to Post Code (Sell-to Post Code)   // Buy-from Post Code (Buy-from Post Code)
        FieldsList.Add(89);   // Sell-to County (Sell-to County)   // Buy-from County (Buy-from County)
        FieldsList.Add(90);   // Sell-to Country/Region Code (Sell-to Country/Region Code)   // Buy-from Country/Region Code (Buy-from Country/Region Code)
        FieldsList.Add(91);   // Ship-to Post Code (Ship-to Post Code)   // Ship-to Post Code (Ship-to Post Code)
        FieldsList.Add(92);   // Ship-to County (Ship-to County)   // Ship-to County (Ship-to County)
        FieldsList.Add(93);   // Ship-to Country/Region Code (Ship-to Country/Region Code)   // Ship-to Country/Region Code (Ship-to Country/Region Code)
        FieldsList.Add(116);  // VAT Bus. Posting Group (VAT Bus. Posting Group)   // VAT Bus. Posting Group (VAT Bus. Posting Group)
        FieldsList.Add(480);  // Dimension Set ID (Dimension Set ID)   // Dimension Set ID (Dimension Set ID)
        FieldsList.Add(5052); // Sell-to Contact No. (Sell-to Contact No.)   // Buy-from Contact No. (Buy-from Contact No.)
        FieldsList.Add(5053); // Bill-to Contact No. (Bill-to Contact No.)   // Pay-to Contact No. (Pay-to Contact No.)
        if CalledFromSales then begin
            FieldsList.Add(75);   // EU 3-Party Trade (EU 3-Party Trade)   // No field in Purchase Header
            FieldsList.Add(5056); // Sell-to Customer Templ. Code (Sell-to Customer Templ. Code)   // No field in Purchase Header
            FieldsList.Add(5057); // Bill-to Customer Templ. Code (Bill-to Customer Templ. Code)   // No field in Purchase Header
        end;
    end;

    local procedure PopulateListOfFieldsForLines(var FieldsList: List of [Integer])
    begin
        Clear(FieldsList);
        FieldsList.Add(5);    // Type
        FieldsList.Add(6);    // No.
        FieldsList.Add(15);   // Quantity
        FieldsList.Add(22);   // Unit Price/Cost
        FieldsList.Add(27);   // Line Discount %
        FieldsList.Add(28);   // Line Discount Amount
        FieldsList.Add(29);   // Amount
        FieldsList.Add(30);   // Amount including VAT
        FieldsList.Add(40);   // Dim1
        FieldsList.Add(41);   // Dim2
        FieldsList.Add(480);  // Dimension Set ID
        FieldsList.Add(8053); // Recurring Billing from
        FieldsList.Add(8054); // Recurring Billing to
    end;

    local procedure PostAndGetSalesInvoiceHeaderFromRecurringBilling()
    var
        PostedDocumentNo: Code[20];
    begin
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesInvoiceHeader.Get(PostedDocumentNo);
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

    local procedure SetupBasicBillingProposal(ServicePartner: Enum "Service Partner")
    begin
        Clear(CustomerContract);
        Clear(VendorContract);
        Clear(ServiceObject);
        Clear(BillingTemplate);
        Clear(BillingTemplate2);

        case ServicePartner of
            Enum::"Service Partner"::Customer:
                ContractTestLibrary.CreateCustomerContractAndCreateContractLinesAndBillingProposal(CustomerContract, ServiceObject, '', BillingTemplate);
            Enum::"Service Partner"::Vendor:
                ContractTestLibrary.CreateVendorContractAndCreateContractLinesAndBillingProposal(VendorContract, ServiceObject, '', BillingTemplate);
        end;
        ContractTestLibrary.CreateDefaultRecurringBillingTemplateForServicePartner(BillingTemplate2, ServicePartner);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate2, ServicePartner);
    end;

    local procedure TestRecordFieldsChanges(RecVariant: Variant; var FieldsList: List of [Integer])
    var
        DocChangeMgt: Codeunit "Document Change Management";
        RRef: RecordRef;
        FRef: FieldRef;
        FieldNo: Integer;
    begin
        RRef.GetTable(RecVariant);
        foreach FieldNo in FieldsList do begin
            FRef := RRef.Field(FieldNo);
            UpdateFieldRefValue(FRef);
            asserterror DocChangeMgt.PreventChangeOnDocumentHeaderOrLine(FRef, FieldNo);
        end;
    end;

    local procedure UpdateFieldRefValue(var FRef: FieldRef)
    var
        ValueDecimal: Decimal;
        ValueInteger: Integer;
        ValueCode: Text[10];
    begin
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
    end;

    #endregion Procedures

    #region Handlers

    [PageHandler]
    procedure BillingLinesArchivePageHandler(var BillingLinesArchive: TestPage "Archived Billing Lines")
    var
        ExpectedNoOfArchivedLines: Integer;
        NoOfRecords: Integer;
    begin
        ExpectedNoOfArchivedLines := LibraryVariableStorage.DequeueInteger();
        if BillingLinesArchive.First() then
            repeat
                NoOfRecords += 1;
            until not BillingLinesArchive.Next();
        Assert.AreEqual(NoOfRecords, ExpectedNoOfArchivedLines, 'Page Billing Lines Archive is not filtered properly.');
        BillingLinesArchive.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CancelCreateVendorBillingDocsTestOpenPageHandler(var CreateVendorBillingDocs: TestPage "Create Vendor Billing Docs")
    var
        PageDocumentDate: Date;
        PagePostingDate: Date;
    begin
        Evaluate(PagePostingDate, CreateVendorBillingDocs.PostingDate.Value);
        Evaluate(PageDocumentDate, CreateVendorBillingDocs.DocumentDate.Value);
        Assert.AreEqual(WorkDate(), PagePostingDate, 'Posting Date is not initialized correctly.');
        Assert.AreEqual(WorkDate(), PageDocumentDate, 'Document Date is not initialized correctly.');
        CreateVendorBillingDocs.Cancel().Invoke();
    end;

    [ConfirmHandler]
    procedure CheckDialogConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    var
        UnexpectedDialogTextErr: Label 'Unexpected confirm dialog text.', Locked = true;
        DialogMsg: Text;
    begin
        DialogMsg := LibraryVariableStorage.DequeueText();
        if Question <> DialogMsg then
            Error(UnexpectedDialogTextErr);
        Reply := false;
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerYes(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [ModalPageHandler]
    procedure CreateAndPostCustomerBillingDocsBillToCustomerPageHandler(var CreateCustomerBillingDocs: TestPage "Create Customer Billing Docs")
    begin
        CreateCustomerBillingDocs.PostDocuments.SetValue(true);
        CreateCustomerBillingDocs.GroupingType.SetValue(Enum::"Customer Rec. Billing Grouping"::"Bill-to Customer No.");
        CreateCustomerBillingDocs.OK().Invoke();
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
    procedure CreateBillingDocumentPageHandler(var CreateBillingDocument: TestPage "Create Billing Document")
    var
        NextBillingToDate: Date;
    begin
        NextBillingToDate := LibraryVariableStorage.DequeueDate();
        CreateBillingDocument.BillingDate.SetValue(NextBillingToDate);
        CreateBillingDocument.BillingTo.SetValue(NextBillingToDate);
        CreateBillingDocument.OpenDocument.SetValue(false);
        CreateBillingDocument.PostDocument.SetValue(false);
        CreateBillingDocument.OK().Invoke()
    end;

    [ModalPageHandler]
    procedure CreateCustomerBillingDocsBillToCustomerPageHandler(var CreateCustomerBillingDocs: TestPage "Create Customer Billing Docs")
    begin
        CreateCustomerBillingDocs.GroupingType.SetValue(Enum::"Customer Rec. Billing Grouping"::"Bill-to Customer No.");
        CreateCustomerBillingDocs.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CreateCustomerBillingDocsContractPageHandler(var CreateCustomerBillingDocs: TestPage "Create Customer Billing Docs")
    begin
        CreateCustomerBillingDocs.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CreateCustomerBillingDocsModalPageHandler(var CreateCustomerBillingDocsPage: TestPage "Create Customer Billing Docs")
    begin
        CreateCustomerBillingDocsPage.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CreateCustomerBillingDocsSellToCustomerPageHandler(var CreateCustomerBillingDocs: TestPage "Create Customer Billing Docs")
    begin
        CreateCustomerBillingDocs.GroupingType.SetValue(Enum::"Customer Rec. Billing Grouping"::"Sell-to Customer No.");
        CreateCustomerBillingDocs.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CreateCustomerBillingDocsTestOpenPageHandler(var CreateCustomerBillingDocs: TestPage "Create Customer Billing Docs")
    var
        PageDocumentDate: Date;
        PagePostingDate: Date;
    begin
        Evaluate(PagePostingDate, CreateCustomerBillingDocs.PostingDate.Value);
        Evaluate(PageDocumentDate, CreateCustomerBillingDocs.DocumentDate.Value);
        Assert.AreEqual(WorkDate(), PagePostingDate, 'Posting Date is not initialized correctly.');
        Assert.AreEqual(WorkDate(), PageDocumentDate, 'Document Date is not initialized correctly.');
        CreateCustomerBillingDocs.Cancel().Invoke();
    end;

    [ModalPageHandler]
    procedure CreateVendorBillingDocsBuyFromVendorPageHandler(var CreateVendorBillingDocs: TestPage "Create Vendor Billing Docs")
    begin
        CreateVendorBillingDocs.GroupingType.SetValue(Enum::"Vendor Rec. Billing Grouping"::"Buy-from Vendor No.");
        CreateVendorBillingDocs.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CreateVendorBillingDocsContractPageHandler(var CreateVendorBillingDocs: TestPage "Create Vendor Billing Docs")
    begin
        CreateVendorBillingDocs.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CreateVendorBillingDocsModalPageHandler(var CreateVendorBillingDocsPage: TestPage "Create Vendor Billing Docs")
    begin
        CreateVendorBillingDocsPage.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CreateVendorBillingDocsPayToVendorPageHandler(var CreateVendorBillingDocs: TestPage "Create Vendor Billing Docs")
    begin
        CreateVendorBillingDocs.GroupingType.SetValue(Enum::"Vendor Rec. Billing Grouping"::"Pay-to Vendor No.");
        CreateVendorBillingDocs.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CreateVendorBillingDocsTestOpenPageHandler(var CreateVendorBillingDocs: TestPage "Create Vendor Billing Docs")
    begin
        CreateVendorBillingDocs.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ExchangeRateSelectionModalPageHandler(var ExchangeRateSelectionPage: TestPage "Exchange Rate Selection")
    begin
        ExchangeRateSelectionPage.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure GetVendorContractLinesPageHandler(var GetVendorContractLines: TestPage "Get Vendor Contract Lines")
    begin
        GetVendorContractLines.Expand(true);
        GetVendorContractLines.Next(); // Skip Grouping line
        GetVendorContractLines.Selected.SetValue(true);
        GetVendorContractLines.OK().Invoke()
    end;

    [ModalPageHandler]
    procedure GetVendorContractLinesProducesCorrectAmountsDuringSelectionPageHandler(var GetVendorContractLines: TestPage "Get Vendor Contract Lines")
    var
        Selected: Boolean;
        CalculationBaseAmount: Decimal;
        CalculationBasePercentage: Decimal;
        Price: Decimal;
        ServiceAmount: Decimal;
    begin
        GetVendorContractLines.Expand(true);
        GetVendorContractLines.Next(); // Skip Grouping line
        // [WHEN] Change the value of Vendor Invoice Amount on the page
        GetVendorContractLines."Vendor Invoice Amount".SetValue(LibraryRandom.RandDecInDecimalRange(0, 100, 2)); // Change value of Vendor Invoice Amount

        // [THEN] Test if Selected is set to true
        Evaluate(Selected, GetVendorContractLines.Selected.Value());
        Assert.IsTrue(Selected, 'Service commitment is not selected when Vendor Invoice Amount is changed');

        // [THEN] Test if Subscription Line data is recalculated on the page
        Evaluate(CalculationBasePercentage, GetVendorContractLines."Calculation Base %".Value);
        Evaluate(CalculationBaseAmount, GetVendorContractLines."Calculation Base Amount".Value);
        Evaluate(ServiceAmount, GetVendorContractLines."Service Amount".Value);
        Evaluate(Price, GetVendorContractLines.Price.Value);
        Assert.AreNotEqual(ServiceCommitment."Calculation Base %", CalculationBasePercentage, 'Service commitment was not calculated on the page');
        Assert.AreNotEqual(ServiceCommitment."Calculation Base Amount", CalculationBaseAmount, 'Service commitment was not calculated on the page');
        Assert.AreNotEqual(ServiceCommitment.Amount, ServiceAmount, 'Service commitment was not calculated on the page');
        Assert.AreNotEqual(ServiceCommitment.Price, Price, 'Service commitment was not calculated on the page');

        // [WHEN] Deselect Subscription Line
        GetVendorContractLines.Selected.SetValue(false);
        // [THEN] Test if Subscription Line data is recalculated on the page
        Evaluate(CalculationBasePercentage, GetVendorContractLines."Calculation Base %".Value);
        Evaluate(CalculationBaseAmount, GetVendorContractLines."Calculation Base Amount".Value);
        Evaluate(ServiceAmount, GetVendorContractLines."Service Amount".Value);
        Evaluate(Price, GetVendorContractLines.Price.Value);
        Assert.AreEqual(ServiceCommitment."Calculation Base %", CalculationBasePercentage, 'Service commitment was not reset on the page');
        Assert.AreEqual(ServiceCommitment."Calculation Base Amount", CalculationBaseAmount, 'Service commitment was not reset on the page');
        Assert.AreEqual(ServiceCommitment.Amount, ServiceAmount, 'Service commitment was not reset on the page');
        Assert.AreEqual(ServiceCommitment.Price, Price, 'Service commitment was not reset on the page');
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    #endregion Handlers
}
