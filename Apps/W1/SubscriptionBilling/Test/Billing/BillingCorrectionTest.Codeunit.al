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
        BillingTemplate: Record "Billing Template";
        ServiceObject: Record "Service Object";
        CustomerContract: Record "Customer Contract";
        VendorContract: Record "Vendor Contract";
        BillingLine: Record "Billing Line";
        BillingLineArchive: Record "Billing Line Archive";
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        PurchaseHeader2: Record "Purchase Header";
        SalesHeader2: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PurchInvoiceHeader: Record "Purch. Inv. Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        PurchInvoiceLine: Record "Purch. Inv. Line";
        ContractTestLibrary: Codeunit "Contract Test Library";
        AssertThat: Codeunit Assert;
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
        CorrectPostedPurchInvoice: Codeunit "Correct Posted Purch. Invoice";
        CopyDocMgt: Codeunit "Copy Document Mgt.";
        BillingDateFormula: DateFormula;
        BillingToDateFormula: DateFormula;
        PostedDocumentNo: Code[20];
        BillingLineCount: Integer;
        IsInitialized: Boolean;

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
        AssertThat.RecordIsEmpty(BillingLine);

        BillingLine.SetRange("Document Type", Enum::"Rec. Billing Document Type"::"Credit Memo");
        AssertThat.AreEqual(BillingLineCount, BillingLine.Count, 'Only the billing lines for Credit Memo should exist');
        BillingLine.FindFirst();
        BillingLine.TestField("Document No.", SalesHeader."No.");
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
    [HandlerFunctions('CreateBillingDocsCustomerPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckBillingLinesCreatedForCreditMemo()
    begin
        Initialize();

        PostSalesInvoiceForContract();
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesHeader);
        BillingLineArchive.SetRange("Contract No.", SalesInvoiceLine."Contract No.");
        BillingLineArchive.SetRange("Contract Line No.", SalesInvoiceLine."Contract Line No.");
        if BillingLineArchive.FindSet() then
            repeat
                BillingLine.SetRange("Correction Document Type", BillingLineArchive."Document Type");
                BillingLine.SetRange("Correction Document No.", BillingLineArchive."Document No.");
                BillingLine.SetRange("Contract No.", BillingLineArchive."Contract No.");
                BillingLine.SetRange("Contract Line No.", BillingLineArchive."Contract Line No.");
                BillingLine.SetRange("Billing from", BillingLineArchive."Billing from");
                BillingLine.SetRange("Billing to", BillingLineArchive."Billing to");
                BillingLine.FindFirst();
                BillingLine.TestField("Correction Document Type", Enum::"Rec. Billing Document Type"::"Credit Memo");
                BillingLine.TestField("Correction Document No.", SalesHeader."No.");
            until BillingLineArchive.Next() = 0;
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
        AssertThat.AreEqual(BillingLineCount, BillingLine.Count, 'Only the billing lines for Credit Memo should exist');
        BillingLine.FindFirst();
        BillingLine.TestField("Document No.", PurchaseHeader."No.");
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
    [HandlerFunctions('CreateBillingDocsVendorPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckBillingLinesCreatedForPurchaseCreditMemo()
    begin
        Initialize();

        PostPurchaseInvoiceForContract();
        CorrectPostedPurchInvoice.CreateCreditMemoCopyDocument(PurchInvoiceHeader, PurchaseHeader);
        BillingLineArchive.SetRange("Contract No.", PurchInvoiceLine."Contract No.");
        BillingLineArchive.SetRange("Contract Line No.", PurchInvoiceLine."Contract Line No.");
        if BillingLineArchive.FindSet() then
            repeat
                BillingLine.SetRange("Correction Document Type", BillingLineArchive."Document Type");
                BillingLine.SetRange("Correction Document No.", BillingLineArchive."Document No.");
                BillingLine.SetRange("Contract No.", BillingLineArchive."Contract No.");
                BillingLine.SetRange("Contract Line No.", BillingLineArchive."Contract Line No.");
                BillingLine.SetRange("Billing from", BillingLineArchive."Billing from");
                BillingLine.SetRange("Billing to", BillingLineArchive."Billing to");
                BillingLine.FindFirst();
                BillingLine.TestField("Correction Document Type", Enum::"Rec. Billing Document Type"::"Credit Memo");
                BillingLine.TestField("Correction Document No.", SalesHeader."No.");
            until BillingLineArchive.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateBillingDocsCustomerPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestChangeServiceStartDateAfterCorrectionCustomerContract()
    var
        ServiceCommitment: Record "Service Commitment";
        LibraryRandom: Codeunit "Library - Random";
    begin
        Initialize();

        PostSalesInvoiceForContract();
        ServiceCommitment.Get(BillingLine."Service Commitment Entry No.");
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesHeader);        //Retrieve updated Service Commitment
        ServiceCommitment.Get(ServiceCommitment."Entry No.");
        ServiceCommitment.Validate("Service Start Date", LibraryRandom.RandDateFrom(ServiceCommitment."Service Start Date", 100));
    end;

    [Test]
    [HandlerFunctions('CreateBillingDocsVendorPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestChangeServiceStartDateAfterCorrectionVendorContract()
    var
        ServiceCommitment: Record "Service Commitment";
        LibraryRandom: Codeunit "Library - Random";
    begin
        Initialize();

        PostPurchaseInvoiceForContract();
        ServiceCommitment.Get(BillingLine."Service Commitment Entry No.");
        CorrectPostedPurchInvoice.CreateCreditMemoCopyDocument(PurchInvoiceHeader, PurchaseHeader);
        //Retrieve updated Service Commitment
        ServiceCommitment.Get(ServiceCommitment."Entry No.");
        ServiceCommitment.Validate("Service Start Date", LibraryRandom.RandDateFrom(ServiceCommitment."Service Start Date", 100));
    end;

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
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, '', true);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Vendor);
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange(Partner, BillingLine.Partner::Vendor);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);
        //Post Purchase Document
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
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, '', true);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange(Partner, BillingLine.Partner::Customer);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);
        //Post Sales Document
        BillingLineCount := BillingLine.Count;
        BillingLine.FindLast();
        SalesHeader.Get(SalesHeader."Document Type"::Invoice, BillingLine."Document No.");
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesInvoiceHeader.Get(PostedDocumentNo);
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

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
}
