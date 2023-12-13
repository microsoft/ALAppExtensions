codeunit 148066 "VAT Exchange Rate CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Core] [VAT Date] [VAT Exchange Rate]
        isInitialized := false;
    end;

    var
        VATPeriodCZL: Record "VAT Period CZL";
        FromVATPostingSetup: Record "VAT Posting Setup";
        ToVATPostingSetup: Record "VAT Posting Setup";
        LibraryERM: Codeunit "Library - ERM";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryRandom: Codeunit "Library - Random";
        LibraryTaxCZL: Codeunit "Library - Tax CZL";
        PurchPost: Codeunit "Purch.-Post";
        SalesPost: Codeunit "Sales-Post";
        Assert: Codeunit Assert;
        PurchaseLineType: Enum "Purchase Line Type";
        isInitialized: Boolean;

    local procedure Initialize();
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"VAT Fields CZL");
        LibraryRandom.Init();
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"VAT Fields CZL");

        LibraryTaxCZL.SetUseVATDate(true);

        LibraryERM.CreateExchangeRate('EUR', WorkDate(), 25.00, 25.00);
        LibraryERM.CreateExchangeRate('EUR', CalcDate('<+1D>', WorkDate()), 25.50, 25.50);

        if not VATPeriodCZL.Get(WorkDate()) then begin
            VATPeriodCZL.Init();
            VATPeriodCZL."Starting Date" := WorkDate();
            VATPeriodCZL.Insert();
        end;

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"VAT Fields CZL");
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure ValidateVATCurrencyCodeInPurchaseHeader()
    var
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
    begin
        // [SCENARIO] Validate VAT Currency Code in Purchase Header
        Initialize();

        // [GIVEN] New Vendor has been created
        LibraryPurchase.CreateVendor(Vendor);

        // [GIVEN] New Purchase Invoice has been created
        LibraryPurchase.CreatePurchaseInvoiceForVendorNo(PurchaseHeader, Vendor."No.");
        PurchaseHeader.Validate("Posting Date", WorkDate());
        PurchaseHeader.Modify();

        // [WHEN] Currency Code is validated
        PurchaseHeader.Validate("Currency Code", 'EUR');

        // [THEN] VAT Currency Code will be Currency Code
        Assert.AreEqual(PurchaseHeader."Currency Code", PurchaseHeader."VAT Currency Code CZL", PurchaseHeader.FieldCaption("VAT Currency Code CZL"));

        // [THEN] VAT Currency Factor will be Currency Factor
        Assert.AreEqual(PurchaseHeader."Currency Factor", PurchaseHeader."VAT Currency Factor CZL", PurchaseHeader.FieldCaption("VAT Currency Factor CZL"));
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure VATCurrencyCodeInPostedPurchaseHeader()
    var
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        // [SCENARIO] VAT Currency Code in Posted Purchase Header
        Initialize();

        // [GIVEN] New Vendor has been created
        LibraryPurchase.CreateVendor(Vendor);

        // [GIVEN] New Purchase Invoice has been created
        LibraryPurchase.CreatePurchaseInvoiceForVendorNo(PurchaseHeader, Vendor."No.");
        PurchaseHeader.Validate("Posting Date", WorkDate());
#if not CLEAN22
#pragma warning disable AL0432
        PurchaseHeader.Validate("Original Doc. VAT Date CZL", PurchaseHeader."VAT Date CZL");
#pragma warning restore AL0432
#else
        PurchaseHeader.Validate("Original Doc. VAT Date CZL", PurchaseHeader."VAT Reporting Date");
#endif
        PurchaseHeader.Validate("Currency Code", 'EUR');
        PurchaseHeader.Modify();

        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLineType::"G/L Account",
                                            LibraryERM.CreateGLAccountWithPurchSetup(), 1);
        PurchaseLine.Validate("Direct Unit Cost", 100);
        PurchaseLine.Modify(true);

        // [GIVEN] Purchase Invoice has been posted
        PurchPost.Run(PurchaseHeader);

        // [WHEN] Find last posted Purchase Invoice
        PurchInvHeader.SetRange("Buy-from Vendor No.", Vendor."No.");
        PurchInvHeader.FindLast();

        // [THEN] VAT Currency Code will be Currency Code
        Assert.AreEqual(PurchInvHeader."Currency Code", PurchInvHeader."VAT Currency Code CZL", PurchInvHeader.FieldCaption("VAT Currency Code CZL"));

        // [THEN] VAT Currency Factor will be Currency Factor
        Assert.AreEqual(PurchInvHeader."Currency Factor", PurchInvHeader."VAT Currency Factor CZL", PurchInvHeader.FieldCaption("VAT Currency Factor CZL"));
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure ValidateVATDateInPurchaseHeaderWithConfirmYes()
    var
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
    begin
        // [SCENARIO] Validate VAT Date in Purchase Header with confirm Yes
        Initialize();

        // [GIVEN] New Vendor has been created
        LibraryPurchase.CreateVendor(Vendor);

        // [GIVEN] New Purchase Invoice has been created
        LibraryPurchase.CreatePurchaseInvoiceForVendorNo(PurchaseHeader, Vendor."No.");
        PurchaseHeader.Validate("Posting Date", WorkDate());
        PurchaseHeader.Validate("Currency Code", 'EUR');
        PurchaseHeader.Modify();

        // [WHEN] VAT Date is validated
#if not CLEAN22
#pragma warning disable AL0432
        PurchaseHeader.Validate("VAT Date CZL", CalcDate('<+1D>', WorkDate()));
#pragma warning restore AL0432
#else
        PurchaseHeader.Validate("VAT Reporting Date", CalcDate('<+1D>', WorkDate()));
#endif

        // [THEN] VAT Date will not be Posting Date
#if not CLEAN22
#pragma warning disable AL0432
        Assert.AreNotEqual(PurchaseHeader."Posting Date", PurchaseHeader."VAT Date CZL", PurchaseHeader.FieldCaption("VAT Date CZL"));
#pragma warning restore AL0432
#else
        Assert.AreNotEqual(PurchaseHeader."Posting Date", PurchaseHeader."VAT Reporting Date", PurchaseHeader.FieldCaption("VAT Reporting Date"));
#endif

        // [THEN] VAT Currency Factor will not be Currency Factor
        Assert.AreNotEqual(PurchaseHeader."Currency Factor", PurchaseHeader."VAT Currency Factor CZL", PurchaseHeader.FieldCaption("VAT Currency Factor CZL"));
    end;

    [Test]
    [HandlerFunctions('ConfirmNoHandler')]
    procedure ValidateVATDateInPurchaseHeaderWithConfirmNo()
    var
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
    begin
        // [SCENARIO] Validate VAT Date in Purchase Header with confirm No
        Initialize();

        // [GIVEN] New Vendor has been created
        LibraryPurchase.CreateVendor(Vendor);

        // [GIVEN] New Purchase Invoice has been created
        LibraryPurchase.CreatePurchaseInvoiceForVendorNo(PurchaseHeader, Vendor."No.");
        PurchaseHeader.Validate("Posting Date", WorkDate());
        PurchaseHeader.Validate("Currency Code", 'EUR');
        PurchaseHeader.Modify();

        // [WHEN] VAT Date is validated
#if not CLEAN22
#pragma warning disable AL0432
        PurchaseHeader.Validate("VAT Date CZL", CalcDate('<+1D>', WorkDate()));
#pragma warning restore AL0432
#else
        PurchaseHeader.Validate("VAT Reporting Date", CalcDate('<+1D>', WorkDate()));
#endif

        // [THEN] VAT Date will not be Posting Date
#if not CLEAN22
#pragma warning disable AL0432
        Assert.AreNotEqual(PurchaseHeader."Posting Date", PurchaseHeader."VAT Date CZL", PurchaseHeader.FieldCaption("VAT Date CZL"));
#pragma warning restore AL0432
#else
        Assert.AreNotEqual(PurchaseHeader."Posting Date", PurchaseHeader."VAT Reporting Date", PurchaseHeader.FieldCaption("VAT Reporting Date"));
#endif

        // [THEN] VAT Currency Factor will be Currency Factor
        Assert.AreEqual(PurchaseHeader."Currency Factor", PurchaseHeader."VAT Currency Factor CZL", PurchaseHeader.FieldCaption("VAT Currency Factor CZL"));
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure VATCurrencyFactorInPostedPurchaseHeader()
    var
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        // [SCENARIO] VAT Currency Code in Posted Purchase Header
        Initialize();

        // [GIVEN] New Vendor has been created
        LibraryPurchase.CreateVendor(Vendor);

        // [GIVEN] New Purchase Invoice has been created
        LibraryPurchase.CreatePurchaseInvoiceForVendorNo(PurchaseHeader, Vendor."No.");
        PurchaseHeader.Validate("Posting Date", WorkDate());
#if not CLEAN22
#pragma warning disable AL0432
        PurchaseHeader.Validate("Original Doc. VAT Date CZL", PurchaseHeader."VAT Date CZL");
#pragma warning restore AL0432
#else
        PurchaseHeader.Validate("Original Doc. VAT Date CZL", PurchaseHeader."VAT Reporting Date");
#endif
        PurchaseHeader.Validate("Currency Code", 'EUR');
        PurchaseHeader.Modify();

        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLineType::"G/L Account",
                                            LibraryERM.CreateGLAccountWithPurchSetup(), 1);
        PurchaseLine.Validate("Direct Unit Cost", 100);
        PurchaseLine.Modify(true);

        // [GIVEN] VAT Date has been validated
#if not CLEAN22
#pragma warning disable AL0432
        PurchaseHeader.Validate("VAT Date CZL", CalcDate('<+1D>', WorkDate()));
#pragma warning restore AL0432
#else
        PurchaseHeader.Validate("VAT Reporting Date", CalcDate('<+1D>', WorkDate()));
#endif

        // [GIVEN] Purchase Invoice has been posted
        PurchPost.Run(PurchaseHeader);

        // [WHEN] Find last posted Purchase Invoice
        PurchInvHeader.SetRange("Buy-from Vendor No.", Vendor."No.");
        PurchInvHeader.FindLast();

        // [THEN] VAT Date will not be Posting Date
#if not CLEAN22
#pragma warning disable AL0432
        Assert.AreNotEqual(PurchInvHeader."Posting Date", PurchInvHeader."VAT Date CZL", PurchInvHeader.FieldCaption("VAT Date CZL"));
#pragma warning restore AL0432
#else
        Assert.AreNotEqual(PurchInvHeader."Posting Date", PurchInvHeader."VAT Reporting Date", PurchInvHeader.FieldCaption("VAT Reporting Date"));
#endif

        // [THEN] VAT Currency Factor will not be Currency Factor
        Assert.AreNotEqual(PurchInvHeader."Currency Factor", PurchInvHeader."VAT Currency Factor CZL", PurchInvHeader.FieldCaption("VAT Currency Factor CZL"));
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure ValidateVATCurrencyFactorInSalesHeader()
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GeneralPostingType: Enum "General Posting Type";
    begin
        // [SCENARIO] Validate VAT Currency Code in Sales Header
        Initialize();

        // [GIVEN] New Customer has been created
        LibrarySales.CreateCustomer(Customer);

        // [GIVEN] New Sales Invoice has been created
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        SalesHeader.Validate("Posting Date", WorkDate());
#if not CLEAN22
#pragma warning disable AL0432
        SalesHeader.Validate("Original Doc. VAT Date CZL", SalesHeader."VAT Date CZL");
#pragma warning restore AL0432
#else
        SalesHeader.Validate("Original Doc. VAT Date CZL", SalesHeader."VAT Reporting Date");
#endif
        SalesHeader.Validate("Currency Code", 'EUR');
        SalesHeader.Modify();

        // [GIVEN] New Sales Invoice Line has been created
#pragma warning disable AA0210
        VATPostingSetup.SetRange("VAT Calculation Type", VATPostingSetup."VAT Calculation Type"::"Normal VAT");
#pragma warning restore AA0210
        VATPostingSetup.FindLast();
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::"G/L Account",
                                    LibraryERM.CreateGLAccountWithVATPostingSetup(VATPostingSetup, GeneralPostingType::Purchase), 1);
        SalesLine.Validate("Unit Price", 100);
        SalesLine.Modify(true);

        // [WHEN] VAT Date has been validated
#if not CLEAN22
#pragma warning disable AL0432
        SalesHeader.Validate("VAT Date CZL", CalcDate('<+1D>', WorkDate()));
#pragma warning restore AL0432
#else
        SalesHeader.Validate("VAT Reporting Date", CalcDate('<+1D>', WorkDate()));
#endif

        // [THEN] VAT Date will not be Posting Date
#if not CLEAN22
#pragma warning disable AL0432
        Assert.AreNotEqual(SalesHeader."Posting Date", SalesHeader."VAT Date CZL", SalesHeader.FieldCaption("VAT Date CZL"));
#pragma warning restore AL0432
#else
        Assert.AreNotEqual(SalesHeader."Posting Date", SalesHeader."VAT Reporting Date", SalesHeader.FieldCaption("VAT Reporting Date"));
#endif

        // [THEN] VAT Currency Factor will not be Currency Factor
        Assert.AreNotEqual(SalesHeader."Currency Factor", SalesHeader."VAT Currency Factor CZL", SalesHeader.FieldCaption("VAT Currency Factor CZL"));
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure VATCurrencyFactorInPostedSalesHeaderNormal()
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        VATEntry: Record "VAT Entry";
        GeneralPostingType: Enum "General Posting Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] If Currency Factor and VAT Currency factor are different, VAT calculation can be Normal
        Initialize();

        // [GIVEN] New Customer has been created
        LibrarySales.CreateCustomer(Customer);

        // [GIVEN] New Sales Invoice has been created
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        SalesHeader.Validate("Posting Date", WorkDate());
#if not CLEAN22
#pragma warning disable AL0432
        SalesHeader.Validate("Original Doc. VAT Date CZL", SalesHeader."VAT Date CZL");
#pragma warning restore AL0432
#else
        SalesHeader.Validate("Original Doc. VAT Date CZL", SalesHeader."VAT Reporting Date");
#endif
        SalesHeader.Validate("Currency Code", 'EUR');
        SalesHeader.Modify();

        // [GIVEN] New Sales Invoice Line has been created
#pragma warning disable AA0210
        VATPostingSetup.SetRange("VAT Bus. Posting Group", Customer."VAT Bus. Posting Group");
        VATPostingSetup.SetRange("VAT Calculation Type", VATPostingSetup."VAT Calculation Type"::"Normal VAT");
#pragma warning restore AA0210
        VATPostingSetup.FindLast();
        VATPostingSetup."Sales VAT Curr. Exch. Acc CZL" := LibraryERM.CreateGLAccountNoWithDirectPosting();
        VATPostingSetup.Modify();
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::"G/L Account",
                                    LibraryERM.CreateGLAccountWithVATPostingSetup(VATPostingSetup, GeneralPostingType::Sale), 1);
        SalesLine.Validate("Unit Price", 100);
        SalesLine.Modify(true);

        // [GIVEN] VAT Date has been validated
#if not CLEAN22
#pragma warning disable AL0432
        SalesHeader.Validate("VAT Date CZL", CalcDate('<+1D>', WorkDate()));
#pragma warning restore AL0432
#else
        SalesHeader.Validate("VAT Reporting Date", CalcDate('<+1D>', WorkDate()));
#endif

        // [WHEN] Post Sales Invoice
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] VAT Entry will be created
        VATEntry.setrange("Document No.", PostedDocumentNo);
        VATEntry.SetRange("Posting Date", SalesHeader."Posting Date");
        Assert.RecordCount(VATEntry, 3);
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure VATCurrencyFactorInPostedSalesHeaderReverseCharge()
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        GeneralPostingType: Enum "General Posting Type";
    begin
        // [SCENARIO] If Currency Factor and VAT Currency factor are different, VAT calculation must be Reverse Charge
        Initialize();

        // [GIVEN] New Customer has been created
        LibrarySales.CreateCustomer(Customer);

        // [GIVEN] New Sales Invoice has been created
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        SalesHeader.Validate("Posting Date", WorkDate());
#if not CLEAN22
#pragma warning disable AL0432
        SalesHeader.Validate("Original Doc. VAT Date CZL", SalesHeader."VAT Date CZL");
#pragma warning restore AL0432
#else
        SalesHeader.Validate("Original Doc. VAT Date CZL", SalesHeader."VAT Reporting Date");
#endif
        SalesHeader.Validate("Currency Code", 'EUR');
        SalesHeader.Modify();

        // [GIVEN] New Sales Invoice Line has been created
#pragma warning disable AA0210
        VATPostingSetup.SetRange("VAT Bus. Posting Group", Customer."VAT Bus. Posting Group");
        VATPostingSetup.SetRange("VAT Calculation Type", VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT");
#pragma warning restore AA0210
        VATPostingSetup.FindLast();
        VATPostingSetup."Sales VAT Curr. Exch. Acc CZL" := LibraryERM.CreateGLAccountNoWithDirectPosting();
        VATPostingSetup.Modify();
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::"G/L Account",
                                    LibraryERM.CreateGLAccountWithVATPostingSetup(VATPostingSetup, GeneralPostingType::Sale), 1);
        SalesLine.Validate("Unit Price", 100);
        SalesLine.Modify(true);

        // [GIVEN] VAT Date has been validated
#if not CLEAN22
#pragma warning disable AL0432
        SalesHeader.Validate("VAT Date CZL", CalcDate('<+1D>', WorkDate()));
#pragma warning restore AL0432
#else
        SalesHeader.Validate("VAT Reporting Date", CalcDate('<+1D>', WorkDate()));
#endif

        // [WHEN] Post Sales Invoice
        SalesPost.Run(SalesHeader);

        // [THEN] One Sales Invoice will be posted
        SalesInvoiceHeader.SetRange("Sell-to Customer No.", Customer."No.");
        Assert.AreEqual(1, SalesInvoiceHeader.Count(), 'One posted sales invoice was expected for this customer.');
    end;

    [Test]
    [HandlerFunctions('HandleCopyVATPostingSetupReport,ConfirmYesHandler')]
    procedure CopyVATCurrExchAccountsWithCopyVATPostingSetup()
    var
        VATPostingSetupPage: TestPage "VAT Posting Setup";
    begin
        // [SCENARIO] Copy VAT Currency Exchange Accounts with Copy - VATPostingSetup
        Initialize();

        // [GIVEN] New source VAT Posting Setup has been created
        LibraryERM.CreateVATPostingSetupWithAccounts(FromVATPostingSetup, FromVATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT", 1);
        FromVATPostingSetup.Validate("Sales VAT Curr. Exch. Acc CZL", LibraryERM.CreateGLAccountNo());
        FromVATPostingSetup.Validate("Purch. VAT Curr. Exch. Acc CZL", LibraryERM.CreateGLAccountNo());
        FromVATPostingSetup.Modify();

        // [GIVEN] New target VAT Posting Setup has been created
        LibraryERM.CreateVATPostingSetupWithAccounts(ToVATPostingSetup, ToVATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT", 1);

        // [GIVEN] Page VAT Posting Setup has been opened and source setup has been selected
        VATPostingSetupPage.OpenView();
        VATPostingSetupPage.GoToRecord(ToVATPostingSetup);

        // [WHEN] Run Copy... to target setup
        Commit();
        VATPostingSetupPage.Copy.Invoke();

        // [THEN] Target VAT posting setup will have VAT Currency Exchange Accounts
        ToVATPostingSetup.Find();
        ToVATPostingSetup.Testfield("Sales VAT Curr. Exch. Acc CZL", FromVATPostingSetup."Sales VAT Curr. Exch. Acc CZL");
        ToVATPostingSetup.Testfield("Purch. VAT Curr. Exch. Acc CZL", FromVATPostingSetup."Purch. VAT Curr. Exch. Acc CZL");
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [ConfirmHandler]
    procedure ConfirmNoHandler(Question: Text; var Reply: Boolean)
    begin
        if StrPos(Question, 'Currency Code') > 0 then
            Reply := true
        else
            Reply := false;
    end;

    [RequestPageHandler]
    procedure HandleCopyVATPostingSetupReport(var CopyVATPostingSetup: TestRequestPage "Copy - VAT Posting Setup")
    begin
        CopyVATPostingSetup.VATBusPostingGroup.SetValue(FromVATPostingSetup."VAT Bus. Posting Group");
        CopyVATPostingSetup.VATProdPostingGroup.SetValue(FromVATPostingSetup."VAT Prod. Posting Group");
        CopyVATPostingSetup.Copy.SetValue(0);
        CopyVATPostingSetup.SalesAccounts.SetValue(true);
        CopyVATPostingSetup.PurchaseAccounts.SetValue(true);
        CopyVATPostingSetup.OK().Invoke();
    end;
}
