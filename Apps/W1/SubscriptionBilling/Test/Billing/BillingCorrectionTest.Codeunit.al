namespace Microsoft.SubscriptionBilling;

using Microsoft.Utilities;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;

codeunit 139686 "Billing Correction Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    var
        BillingLine: Record "Billing Line";
        BillingLineArchive: Record "Billing Line Archive";
        BillingTemplate: Record "Billing Template";
        CustomerContract: Record "Customer Subscription Contract";
        PurchInvoiceHeader: Record "Purch. Inv. Header";
        PurchInvoiceLine: Record "Purch. Inv. Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseHeader2: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
        SalesHeader2: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        ServiceObject: Record "Subscription Header";
        VendorContract: Record "Vendor Subscription Contract";
        Assert: Codeunit Assert;
        ContractTestLibrary: Codeunit "Contract Test Library";
        CopyDocMgt: Codeunit "Copy Document Mgt.";
        CorrectPostedPurchInvoice: Codeunit "Correct Posted Purch. Invoice";
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryUtility: Codeunit "Library - Utility";
        BillingDateFormula: DateFormula;
        BillingToDateFormula: DateFormula;
        IsInitialized: Boolean;
        PostedDocumentNo: Code[20];
        BillingLineCount: Integer;

    #region Tests

    [Test]
    [HandlerFunctions('CreateBillingDocsCustomerPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckBillingLinesCreatedForCreditMemo()
    begin
        Initialize();

        PostSalesInvoiceForContract();
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesHeader);
        BillingLineArchive.SetRange("Subscription Contract No.", SalesInvoiceLine."Subscription Contract No.");
        BillingLineArchive.SetRange("Subscription Contract Line No.", SalesInvoiceLine."Subscription Contract Line No.");
        if BillingLineArchive.FindSet() then
            repeat
                BillingLine.SetRange("Correction Document Type", BillingLineArchive."Document Type");
                BillingLine.SetRange("Correction Document No.", BillingLineArchive."Document No.");
                BillingLine.SetRange("Subscription Contract No.", BillingLineArchive."Subscription Contract No.");
                BillingLine.SetRange("Subscription Contract Line No.", BillingLineArchive."Subscription Contract Line No.");
                BillingLine.SetRange("Billing from", BillingLineArchive."Billing from");
                BillingLine.SetRange("Billing to", BillingLineArchive."Billing to");
                BillingLine.FindFirst();
                BillingLine.TestField("Correction Document Type", Enum::"Rec. Billing Document Type"::"Credit Memo");
                BillingLine.TestField("Correction Document No.", SalesHeader."No.");
            until BillingLineArchive.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateBillingDocsVendorPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckBillingLinesCreatedForPurchaseCreditMemo()
    begin
        Initialize();

        PostPurchaseInvoiceForContract();
        CorrectPostedPurchInvoice.CreateCreditMemoCopyDocument(PurchInvoiceHeader, PurchaseHeader);
        BillingLineArchive.SetRange("Subscription Contract No.", PurchInvoiceLine."Subscription Contract No.");
        BillingLineArchive.SetRange("Subscription Contract Line No.", PurchInvoiceLine."Subscription Contract Line No.");
        if BillingLineArchive.FindSet() then
            repeat
                BillingLine.SetRange("Correction Document Type", BillingLineArchive."Document Type");
                BillingLine.SetRange("Correction Document No.", BillingLineArchive."Document No.");
                BillingLine.SetRange("Subscription Contract No.", BillingLineArchive."Subscription Contract No.");
                BillingLine.SetRange("Subscription Contract Line No.", BillingLineArchive."Subscription Contract Line No.");
                BillingLine.SetRange("Billing from", BillingLineArchive."Billing from");
                BillingLine.SetRange("Billing to", BillingLineArchive."Billing to");
                BillingLine.FindFirst();
                BillingLine.TestField("Correction Document Type", Enum::"Rec. Billing Document Type"::"Credit Memo");
                BillingLine.TestField("Correction Document No.", SalesHeader."No.");
            until BillingLineArchive.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateBillingDocsCustomerPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorWhenCopyingPostedContractInvoice()
    var
        i: Integer;
    begin
        Initialize();

        for i := 0 to 5 do begin
            PostSalesInvoiceForContract();
            SalesHeader2."Document Type" := Enum::"Sales Document Type".FromInteger(i);
            CopyDocMgt.SetProperties(true, false, false, true, true, true, false);
            if SalesHeader2."Document Type" = SalesHeader2."Document Type"::"Credit Memo" then
                CopyDocMgt.CopySalesDoc(Enum::"Sales Document Type From"::"Posted Invoice", SalesInvoiceHeader."No.", SalesHeader2)
            else
                asserterror CopyDocMgt.CopySalesDoc(Enum::"Sales Document Type From"::"Posted Invoice", SalesInvoiceHeader."No.", SalesHeader2);
        end;
    end;

    [Test]
    [HandlerFunctions('CreateBillingDocsVendorPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorWhenCopyingPostedVendorContractInvoice()
    var
        i: Integer;
    begin
        Initialize();

        for i := 0 to 5 do begin
            PostPurchaseInvoiceForContract();
            PurchaseHeader2."Document Type" := Enum::"Purchase Document Type".FromInteger(i);
            CopyDocMgt.SetProperties(true, false, false, true, true, true, false);
            if PurchaseHeader2."Document Type" = PurchaseHeader2."Document Type"::"Credit Memo" then
                CopyDocMgt.CopyPurchDoc(Enum::"Purchase Document Type From"::"Posted Invoice", PurchInvoiceHeader."No.", PurchaseHeader2)
            else
                asserterror CopyDocMgt.CopyPurchDoc(Enum::"Purchase Document Type From"::"Posted Invoice", PurchInvoiceHeader."No.", PurchaseHeader2);
        end;
    end;

    [Test]
    [HandlerFunctions('CreateBillingDocsCustomerPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorWhenNewerInvoiceExist()
    begin
        Initialize();

        PostSalesInvoiceForContract();
        Evaluate(BillingDateFormula, '<9M-CM>');
        Evaluate(BillingToDateFormula, '<12M+CM>');
        BillingTemplate."Billing Date Formula" := BillingDateFormula;
        BillingTemplate."Billing to Date Formula" := BillingToDateFormula;
        BillingTemplate.Modify(false);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
        asserterror CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesHeader);
    end;

    [Test]
    [HandlerFunctions('CreateBillingDocsVendorPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorWhenNewerPurchaseInvoiceExist()
    begin
        Initialize();

        PostPurchaseInvoiceForContract();
        Evaluate(BillingDateFormula, '<9M-CM>');
        Evaluate(BillingToDateFormula, '<12M+CM>');
        BillingTemplate."Billing Date Formula" := BillingDateFormula;
        BillingTemplate."Billing to Date Formula" := BillingToDateFormula;
        BillingTemplate.Modify(false);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Vendor);
        asserterror CorrectPostedPurchInvoice.CreateCreditMemoCopyDocument(PurchInvoiceHeader, PurchaseHeader);
    end;

    [Test]
    [HandlerFunctions('CreateBillingDocsVendorPageHandler,PurchaseCreditMemosPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorWhenRelatedPurchaseLineExist()
    begin
        Initialize();

        PostPurchaseInvoiceForContract();
        CorrectPostedPurchInvoice.CreateCreditMemoCopyDocument(PurchInvoiceHeader, PurchaseHeader);
        Commit(); // retain data after asserterror
        asserterror CorrectPostedPurchInvoice.CreateCreditMemoCopyDocument(PurchInvoiceHeader, PurchaseHeader2);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Vendor);
        Assert.AreEqual(BillingLineCount, BillingLine.Count, 'Only the billing lines for Credit Memo should exist');
        BillingLine.FindFirst();
        BillingLine.TestField("Document No.", PurchaseHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CreateBillingDocsCustomerPageHandler,SalesCreditMemosPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure ExpectErrorWhenRelatedSalesLineExist()
    begin
        Initialize();

        PostSalesInvoiceForContract();
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesHeader);
        Commit(); // retain data after asserterror
        asserterror CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesHeader2);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
        BillingLine.Reset();
        BillingLine.SetRange("Document Type", Enum::"Rec. Billing Document Type"::Invoice);
        Assert.RecordIsEmpty(BillingLine);

        BillingLine.SetRange("Document Type", Enum::"Rec. Billing Document Type"::"Credit Memo");
        Assert.AreEqual(BillingLineCount, BillingLine.Count, 'Only the billing lines for Credit Memo should exist');
        BillingLine.FindFirst();
        BillingLine.TestField("Document No.", SalesHeader."No.");
    end;

    [Test]
    [HandlerFunctions('CreateBillingDocsCustomerPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestChangeServiceStartDateAfterCorrectionCustomerContract()
    var
        ServiceCommitment: Record "Subscription Line";
        LibraryRandom: Codeunit "Library - Random";
    begin
        Initialize();

        PostSalesInvoiceForContract();
        ServiceCommitment.Get(BillingLine."Subscription Line Entry No.");
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesHeader); // Retrieve updated Subscription Line
        ServiceCommitment.Get(ServiceCommitment."Entry No.");
        ServiceCommitment.Validate("Subscription Line Start Date", LibraryRandom.RandDateFrom(ServiceCommitment."Subscription Line Start Date", 100));
    end;

    [Test]
    [HandlerFunctions('CreateBillingDocsVendorPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestChangeServiceStartDateAfterCorrectionVendorContract()
    var
        ServiceCommitment: Record "Subscription Line";
        LibraryRandom: Codeunit "Library - Random";
    begin
        Initialize();

        PostPurchaseInvoiceForContract();
        ServiceCommitment.Get(BillingLine."Subscription Line Entry No.");
        CorrectPostedPurchInvoice.CreateCreditMemoCopyDocument(PurchInvoiceHeader, PurchaseHeader);
        // Retrieve updated Subscription Line
        ServiceCommitment.Get(ServiceCommitment."Entry No.");
        ServiceCommitment.Validate("Subscription Line Start Date", LibraryRandom.RandDateFrom(ServiceCommitment."Subscription Line Start Date", 100));
    end;

    #endregion Tests

    #region Procedures

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Billing Correction Test");
        ClearAll();

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Billing Correction Test");
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        LibraryERMCountryData.UpdateSalesReceivablesSetup();
        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Billing Correction Test");
    end;

    local procedure PostPurchaseInvoiceForContract()
    begin
        ClearAll();
        BillingTemplate.DeleteAll(false);
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, '', true);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Vendor);
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange(Partner, BillingLine.Partner::Vendor);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);
        // Post Purchase Document
        BillingLineCount := BillingLine.Count;
        BillingLine.FindFirst();
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Invoice, BillingLine."Document No.");
        PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateGUID());
        PurchaseHeader.Modify(false);
        PostedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        PurchInvoiceHeader.Get(PostedDocumentNo);
    end;

    local procedure PostSalesInvoiceForContract()
    begin
        ClearAll();
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, '', true);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange(Partner, BillingLine.Partner::Customer);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);
        // Post Sales Document
        BillingLineCount := BillingLine.Count;
        BillingLine.FindLast();
        SalesHeader.Get(SalesHeader."Document Type"::Invoice, BillingLine."Document No.");
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesInvoiceHeader.Get(PostedDocumentNo);
    end;

    #endregion Procedures

    #region Handlers

    [ModalPageHandler]
    procedure CreateBillingDocsCustomerPageHandler(var CreateBillingDocsCustomerPage: TestPage "Create Customer Billing Docs")
    begin
        CreateBillingDocsCustomerPage.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CreateBillingDocsVendorPageHandler(var CreateBillingDocsVendorPage: TestPage "Create Vendor Billing Docs")
    begin
        CreateBillingDocsVendorPage.OK().Invoke();
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

    [PageHandler]
    procedure PurchaseCreditMemosPageHandler(var PurchaseCreditMemosPage: TestPage "Purchase Credit Memos")
    begin
        PurchaseCreditMemosPage.OK().Invoke();
    end;

    [PageHandler]
    procedure PurchaseCrMemoPageHandler(var PurchaseCreditMemoPage: TestPage "Purchase Credit Memo")
    begin
        PurchaseCreditMemoPage.OK().Invoke();
    end;

    [PageHandler]
    procedure SalesCreditMemosPageHandler(var SalesCreditMemosPage: TestPage "Sales Credit Memos")
    begin
        SalesCreditMemosPage.OK().Invoke();
    end;

    [PageHandler]
    procedure SalesCrMemoPageHandler(var SalesCreditMemoPage: TestPage "Sales Credit Memo")
    begin
        SalesCreditMemoPage.OK().Invoke();
    end;

    #endregion Handlers
}
