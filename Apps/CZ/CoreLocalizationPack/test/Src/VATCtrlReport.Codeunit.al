#pragma warning disable AA0210
codeunit 148064 "VAT Ctrl. Report CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Core] [VAT Ctrl. Report]
        isInitialized := false;
    end;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        LibraryTax: Codeunit "Library - Tax CZL";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        SimplifiedTaxDocumentLimit: Decimal;
        isInitialized: Boolean;
        SectionA1Tok: Label 'A1', Locked = true;
        SectionA2Tok: Label 'A2', Locked = true;
        SectionA4Tok: Label 'A4', Locked = true;
        SectionA5Tok: Label 'A5', Locked = true;
        SectionB1Tok: Label 'B1', Locked = true;
        SectionB2Tok: Label 'B2', Locked = true;
        SectionB3Tok: Label 'B3', Locked = true;
        UnexpectedCommodityCodeErr: Label 'Unexpected commodity code';
        UnexpectedSectionErr: Label 'Unexpected section';
        BaseAmountNotMatchErr: Label 'The base amount doesn''t match the sum of the base amounts from entries.';

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"VAT Ctrl. Report CZL");

        LibraryVariableStorage.Clear();
        LibrarySetupStorage.Restore();
        LibraryRandom.Init();

        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"VAT Ctrl. Report CZL");

        LibraryTax.SetUseVATDate(true);
        LibraryTax.SetVATControlReportInformation();
        LibraryTax.CreateDefaultVATControlReportSections(true);

        LibrarySetupStorage.Save(Database::"General Ledger Setup");
        LibrarySetupStorage.Save(Database::"Statutory Reporting Setup CZL");

        isInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"VAT Ctrl. Report CZL");
    end;

    [Test]
    [HandlerFunctions('MessageHandler,VATCtrlReportGetEntHandler')]
    procedure SuggestPurchaseDocumentToVATControlReportSectionB2()
    begin
        // [SCENARIO] The domestic purchase invoice over the limit is suggested to section B2 of vat control report.
        SuggestPurchaseDocumentToVATControlReportSection(SectionB2Tok);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,VATCtrlReportGetEntHandler')]
    procedure SuggestPurchaseDocumentToVATControlReportSectionB3()
    begin
        // [SCENARIO] The domestic purchase invoice below the limit is suggested to section B3 of vat control report.
        SuggestPurchaseDocumentToVATControlReportSection(SectionB3Tok);
    end;

    local procedure SuggestPurchaseDocumentToVATControlReportSection(SectionCode: Code[20])
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine1: Record "Purchase Line";
        PurchaseLine2: Record "Purchase Line";
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
        VATEntry: Record "VAT Entry";
        VATStatementName: Record "VAT Statement Name";
        PostedDocumentNo: Code[20];
    begin
        Initialize();

        // [GIVEN] The purchase invoice header with vat date in the last open vat period has been created
        PurchaseHeader := CreatePurchaseHeader(Enum::"Purchase Document Type"::Invoice);

        // [GIVEN] The two purchase invoice lines with amounts above/below limit has been created
        case SectionCode of
            SectionB2Tok:
                begin
                    PurchaseLine1 := CreatePurchaseLineAboveLimit(
                        PurchaseHeader, CreateVATPostingSetup(Enum::"Tax Calculation Type"::"Normal VAT", Enum::"VAT Rate CZL"::Base, 21));
                    PurchaseLine2 := CreatePurchaseLineAboveLimit(
                        PurchaseHeader, CreateVATPostingSetup(Enum::"Tax Calculation Type"::"Normal VAT", Enum::"VAT Rate CZL"::Base, 21));
                end;
            SectionB3Tok:
                begin
                    PurchaseLine1 := CreatePurchaseLineBelowLimit(
                        PurchaseHeader, CreateVATPostingSetup(Enum::"Tax Calculation Type"::"Normal VAT", Enum::"VAT Rate CZL"::Base, 21));
                    PurchaseLine2 := CreatePurchaseLineBelowLimit(
                        PurchaseHeader, CreateVATPostingSetup(Enum::"Tax Calculation Type"::"Normal VAT", Enum::"VAT Rate CZL"::Base, 21));
                end;
        end;

        // [GIVEN] The created purchase invoice has been posted
        PostedDocumentNo := PostPurchaseDocument(PurchaseHeader);

        // [GIVEN] The vat statement for section B2 has been created
        VATStatementName := CreateVATStatement();
        CreateVATStatementLine(VATStatementName, Enum::"General Posting Type"::Purchase,
            PurchaseLine1."VAT Bus. Posting Group", PurchaseLine1."VAT Prod. Posting Group", SectionB2Tok);
        CreateVATStatementLine(VATStatementName, Enum::"General Posting Type"::Purchase,
            PurchaseLine2."VAT Bus. Posting Group", PurchaseLine2."VAT Prod. Posting Group", SectionB2Tok);

        // [GIVEN] The vat control report for the last open vat period has been created
        VATCtrlReportHeaderCZL := CreateVATControlReport(
            Date2DMY(PurchaseHeader."Posting Date", 2), Date2DMY(PurchaseHeader."Posting Date", 3),
            VATStatementName."Statement Template Name", VATStatementName.Name);

        // [WHEN] Run suggest vat control report lines function
        SuggestVATControlReportLines(VATCtrlReportHeaderCZL);

        // [THEN] There will be only one vat control report line for the purchase invoice
        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", VATCtrlReportHeaderCZL."No.");
        VATCtrlReportLineCZL.SetRange("Document No.", PostedDocumentNo);
        Assert.RecordCount(VATCtrlReportLineCZL, 1);

        // [THEN] The section on the line will be B2/B3
        VATCtrlReportLineCZL.FindFirst();
        Assert.AreEqual(SectionCode, VATCtrlReportLineCZL."VAT Ctrl. Report Section Code", UnexpectedSectionErr);

        // [THEN] The amount on the line will equal the sum of the base amount from entries
        VATEntry.SetRange("Document No.", PostedDocumentNo);
        VATEntry.CalcSums(Base);
        Assert.AreEqual(VATEntry.Base, VATCtrlReportLineCZL.Base, BaseAmountNotMatchErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,VATCtrlReportGetEntHandler')]
    procedure SuggestPurchaseDocumentToVATControlReportSectionB1()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        TariffNumber: Record "Tariff Number";
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
        VATStatementName: Record "VAT Statement Name";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] The domestic purchase invoice with reverse charge is suggested to section B1 of vat control report.
        Initialize();

        // [GIVEN] The commodity lines have been created
        // [GIVEN] The tariff number has been created
        TariffNumber := CreateTariffNumber(CreateCommodity().Code, CreateCommodity(0).Code);

        // [GIVEN] The purchase invoice header with vat date in the last open vat period has been created
        PurchaseHeader := CreatePurchaseHeader(Enum::"Purchase Document Type"::Invoice);

        // [GIVEN] The purchase invoice line with amount above limit has been created
        PurchaseLine := CreatePurchaseLineAboveLimit(
            PurchaseHeader, CreateVATPostingSetup(Enum::"Tax Calculation Type"::"Reverse Charge VAT", Enum::"VAT Rate CZL"::Base, 21), TariffNumber."No.");

        // [GIVEN] The created purchase invoice has been posted
        PostedDocumentNo := PostPurchaseDocument(PurchaseHeader);

        // [GIVEN] The vat statement for section B1 has been created
        VATStatementName := CreateVATStatement();
        CreateVATStatementLine(VATStatementName, Enum::"General Posting Type"::Purchase,
            PurchaseLine."VAT Bus. Posting Group", PurchaseLine."VAT Prod. Posting Group", SectionB1Tok);

        // [GIVEN] The vat control report for the last open vat period has been created
        VATCtrlReportHeaderCZL := CreateVATControlReport(
            Date2DMY(PurchaseHeader."Posting Date", 2), Date2DMY(PurchaseHeader."Posting Date", 3),
            VATStatementName."Statement Template Name", VATStatementName.Name);

        // [WHEN] Run suggest vat control report lines function
        SuggestVATControlReportLines(VATCtrlReportHeaderCZL);

        // [THEN] There will be only one vat control report line for the purchase invoice
        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", VATCtrlReportHeaderCZL."No.");
        VATCtrlReportLineCZL.SetRange("Document No.", PostedDocumentNo);
        Assert.RecordCount(VATCtrlReportLineCZL, 1);

        // [THEN] The section on the line will be B1
        VATCtrlReportLineCZL.FindFirst();
        Assert.AreEqual(SectionB1Tok, VATCtrlReportLineCZL."VAT Ctrl. Report Section Code", UnexpectedSectionErr);
        Assert.AreEqual(TariffNumber."Statement Code CZL", VATCtrlReportLineCZL."Commodity Code", UnexpectedCommodityCodeErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,VATCtrlReportGetEntHandler')]
    procedure SuggestSalesDocumentToVATControlReportSectionA4()
    begin
        // [SCENARIO] The domestic sales invoice over the limit is suggested to section A4 of vat control report.
        SuggestSalesDocumentToVATControlReportSection(SectionA4Tok);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,VATCtrlReportGetEntHandler')]
    procedure SuggestSalesDocumentToVATControlReportSectionA5()
    begin
        // [SCENARIO] The domestic sales invoice below the limit is suggested to section A5 of vat control report.
        SuggestSalesDocumentToVATControlReportSection(SectionA5Tok);
    end;

    local procedure SuggestSalesDocumentToVATControlReportSection(SectionCode: Code[20])
    var
        SalesHeader: Record "Sales Header";
        SalesLine1: Record "Sales Line";
        SalesLine2: Record "Sales Line";
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
        VATEntry: Record "VAT Entry";
        VATStatementName: Record "VAT Statement Name";
        PostedDocumentNo: Code[20];
    begin
        Initialize();

        // [GIVEN] The sales invoice header with vat date in the last open vat period has been created
        SalesHeader := CreateSalesHeader(Enum::"Sales Document Type"::Invoice);

        // [GIVEN] The two sales invoice lines with amounts above/below limit has been created
        case SectionCode of
            SectionA4Tok:
                begin
                    SalesLine1 := CreatesalesLineAboveLimit(
                        SalesHeader, CreateVATPostingSetup(Enum::"Tax Calculation Type"::"Normal VAT", Enum::"VAT Rate CZL"::Base, 21));
                    SalesLine2 := CreatesalesLineAboveLimit(
                        SalesHeader, CreateVATPostingSetup(Enum::"Tax Calculation Type"::"Normal VAT", Enum::"VAT Rate CZL"::Base, 21));
                end;
            SectionA5Tok:
                begin
                    SalesLine1 := CreatesalesLineBelowLimit(
                        SalesHeader, CreateVATPostingSetup(Enum::"Tax Calculation Type"::"Normal VAT", Enum::"VAT Rate CZL"::Base, 21));
                    SalesLine2 := CreatesalesLineBelowLimit(
                        SalesHeader, CreateVATPostingSetup(Enum::"Tax Calculation Type"::"Normal VAT", Enum::"VAT Rate CZL"::Base, 21));
                end;
        end;

        // [GIVEN] The created sales invoice has been posted
        PostedDocumentNo := PostSalesDocument(SalesHeader);

        // [GIVEN] The vat statement for section B2 has been created
        VATStatementName := CreateVATStatement();
        CreateVATStatementLine(VATStatementName, Enum::"General Posting Type"::Sale,
            SalesLine1."VAT Bus. Posting Group", SalesLine1."VAT Prod. Posting Group", SectionA4Tok);
        CreateVATStatementLine(VATStatementName, Enum::"General Posting Type"::Sale,
            SalesLine2."VAT Bus. Posting Group", SalesLine2."VAT Prod. Posting Group", SectionA4Tok);

        // [GIVEN] The vat control report for the last open vat period has been created
        VATCtrlReportHeaderCZL := CreateVATControlReport(
#if not CLEAN22
#pragma warning disable AL0432
            Date2DMY(SalesHeader."VAT Date CZL", 2), Date2DMY(SalesHeader."VAT Date CZL", 3),
#pragma warning restore AL0432
#else
            Date2DMY(SalesHeader."VAT Reporting Date", 2), Date2DMY(SalesHeader."VAT Reporting Date", 3),
#endif
            VATStatementName."Statement Template Name", VATStatementName.Name);

        // [WHEN] Run suggest vat control report lines function
        SuggestVATControlReportLines(VATCtrlReportHeaderCZL);

        // [THEN] There will be only one vat control report line for the sales invoice
        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", VATCtrlReportHeaderCZL."No.");
        VATCtrlReportLineCZL.SetRange("Document No.", PostedDocumentNo);
        Assert.RecordCount(VATCtrlReportLineCZL, 1);

        // [THEN] The section on the line will be A4/A5
        VATCtrlReportLineCZL.FindFirst();
        Assert.AreEqual(SectionCode, VATCtrlReportLineCZL."VAT Ctrl. Report Section Code", UnexpectedSectionErr);

        // [THEN] The amount on the line will equal the sum of the base amount from entries
        VATEntry.SetRange("Document No.", PostedDocumentNo);
        VATEntry.CalcSums(Base);
        Assert.AreEqual(VATEntry.Base, VATCtrlReportLineCZL.Base, BaseAmountNotMatchErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,VATCtrlReportGetEntHandler')]
    procedure SuggestSalesDocumentToVATControlReportSectionA1()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TariffNumber: Record "Tariff Number";
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
        VATStatementName: Record "VAT Statement Name";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] The domestic sales invoice with reverse charge is suggested to section A1 of vat control report.
        Initialize();

        // [GIVEN] The commodity lines have been created
        // [GIVEN] The tariff number has been created
        TariffNumber := CreateTariffNumber(CreateCommodity().Code, CreateCommodity(0).Code);

        // [GIVEN] The sales invoice header with vat date in the last open vat period has been created
        SalesHeader := CreateSalesHeader(Enum::"Sales Document Type"::Invoice);

        // [GIVEN] The sales invoice line with amount above limit has been created
        SalesLine := CreateSalesLineAboveLimit(
            SalesHeader, CreateVATPostingSetup(Enum::"Tax Calculation Type"::"Reverse Charge VAT", Enum::"VAT Rate CZL"::Base, 21), TariffNumber."No.");

        // [GIVEN] The created sales invoice has been posted
        PostedDocumentNo := PostSalesDocument(SalesHeader);

        // [GIVEN] The vat statement for section A1 has been created
        VATStatementName := CreateVATStatement();
        CreateVATStatementLine(VATStatementName, Enum::"General Posting Type"::Sale,
            SalesLine."VAT Bus. Posting Group", SalesLine."VAT Prod. Posting Group", SectionA1Tok);

        // [GIVEN] The vat control report for the last open vat period has been created
        VATCtrlReportHeaderCZL := CreateVATControlReport(
#if not CLEAN22
#pragma warning disable AL0432
            Date2DMY(SalesHeader."VAT Date CZL", 2), Date2DMY(SalesHeader."VAT Date CZL", 3),
#pragma warning restore AL0432
#else
            Date2DMY(SalesHeader."VAT Reporting Date", 2), Date2DMY(SalesHeader."VAT Reporting Date", 3),
#endif
            VATStatementName."Statement Template Name", VATStatementName.Name);

        // [WHEN] Run suggest vat control report lines function
        SuggestVATControlReportLines(VATCtrlReportHeaderCZL);

        // [THEN] There will be only one vat control report line for the purchase invoice
        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", VATCtrlReportHeaderCZL."No.");
        VATCtrlReportLineCZL.SetRange("Document No.", PostedDocumentNo);
        Assert.RecordCount(VATCtrlReportLineCZL, 1);

        // [THEN] The section on the line will be B1
        VATCtrlReportLineCZL.FindFirst();
        Assert.AreEqual(SectionA1Tok, VATCtrlReportLineCZL."VAT Ctrl. Report Section Code", UnexpectedSectionErr);
        Assert.AreEqual(TariffNumber."Statement Code CZL", VATCtrlReportLineCZL."Commodity Code", UnexpectedCommodityCodeErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,VATCtrlReportGetEntHandler')]
    procedure SuggestPurchaseDocumentToVATControlReportSectionA2()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine1: Record "Purchase Line";
        PurchaseLine2: Record "Purchase Line";
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
        VATEntry: Record "VAT Entry";
        VATStatementName: Record "VAT Statement Name";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] The EU purchase invoice below the limit is suggested to section A2 of vat control report.
        Initialize();

        // [GIVEN] The purchase invoice header with vat date in the last open vat period has been created
        PurchaseHeader := CreatePurchaseHeader(Enum::"Purchase Document Type"::Invoice);

        // [GIVEN] The two purchase invoice lines with amounts above limit has been created
        PurchaseLine1 := CreatePurchaseLineAboveLimit(
            PurchaseHeader, CreateVATPostingSetup(Enum::"Tax Calculation Type"::"Reverse Charge VAT", Enum::"VAT Rate CZL"::Base, 21));
        PurchaseLine2 := CreatePurchaseLineAboveLimit(
            PurchaseHeader, CreateVATPostingSetup(Enum::"Tax Calculation Type"::"Reverse Charge VAT", Enum::"VAT Rate CZL"::Base, 21, true));

        // [GIVEN] The created purchase invoice has been posted
        PostedDocumentNo := PostPurchaseDocument(PurchaseHeader);

        // [GIVEN] The vat statement for section A2 has been created
        VATStatementName := CreateVATStatement();
        CreateVATStatementLine(VATStatementName, Enum::"General Posting Type"::Purchase,
            PurchaseLine1."VAT Bus. Posting Group", PurchaseLine1."VAT Prod. Posting Group", SectionA2Tok);
        CreateVATStatementLine(VATStatementName, Enum::"General Posting Type"::Purchase,
            PurchaseLine2."VAT Bus. Posting Group", PurchaseLine2."VAT Prod. Posting Group", SectionA2Tok);

        // [GIVEN] The vat control report for the last open vat period has been created
        VATCtrlReportHeaderCZL := CreateVATControlReport(
            Date2DMY(PurchaseHeader."Posting Date", 2), Date2DMY(PurchaseHeader."Posting Date", 3),
            VATStatementName."Statement Template Name", VATStatementName.Name);

        // [WHEN] Run suggest vat control report lines function
        SuggestVATControlReportLines(VATCtrlReportHeaderCZL);

        // [THEN] There will be only one vat control report line for the purchase invoice
        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", VATCtrlReportHeaderCZL."No.");
        VATCtrlReportLineCZL.SetRange("Document No.", PostedDocumentNo);
        Assert.RecordCount(VATCtrlReportLineCZL, 1);

        // [THEN] The section on the line will be A2
        VATCtrlReportLineCZL.FindFirst();
        Assert.AreEqual(SectionA2Tok, VATCtrlReportLineCZL."VAT Ctrl. Report Section Code", UnexpectedSectionErr);

        // [THEN] The amount on the line will equal the sum of the base amount from entries
        VATEntry.SetRange("Document No.", PostedDocumentNo);
        VATEntry.CalcSums(Base);
        Assert.AreEqual(VATEntry.Base, VATCtrlReportLineCZL.Base, BaseAmountNotMatchErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,VATCtrlReportGetEntHandler')]
    procedure SuggestPurchaseDocumentToVATControlReportByVATDate()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine1: Record "Purchase Line";
        PurchaseLine2: Record "Purchase Line";
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
        VATStatementName: Record "VAT Statement Name";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] The domestic purchase invoice with different vat date is not suggested to vat control report.
        Initialize();

        // [GIVEN] The purchase invoice header with vat date before last open vat period has been created
        PurchaseHeader := CreatePurchaseHeader(Enum::"Purchase Document Type"::Invoice);
#if not CLEAN22
#pragma warning disable AL0432
        PurchaseHeader.Validate("VAT Date CZL", CalcDate('<CM-1M>', PurchaseHeader."Posting Date"));
        PurchaseHeader.Validate("Original Doc. VAT Date CZL", PurchaseHeader."VAT Date CZL");
#pragma warning restore AL0432
#else
        PurchaseHeader.Validate("VAT Reporting Date", CalcDate('<CM-1M>', PurchaseHeader."Posting Date"));
        PurchaseHeader.Validate("Original Doc. VAT Date CZL", PurchaseHeader."VAT Reporting Date");
#endif
        PurchaseHeader.Modify();

        // [GIVEN] The two purchase invoice lines with amounts below limit has been created
        PurchaseLine1 := CreatePurchaseLineBelowLimit(
            PurchaseHeader, CreateVATPostingSetup(Enum::"Tax Calculation Type"::"Normal VAT", Enum::"VAT Rate CZL"::Base, 21));
        PurchaseLine2 := CreatePurchaseLineBelowLimit(
            PurchaseHeader, CreateVATPostingSetup(Enum::"Tax Calculation Type"::"Normal VAT", Enum::"VAT Rate CZL"::Base, 21));

        // [GIVEN] The created purchase invoice has been posted
        PostedDocumentNo := PostPurchaseDocument(PurchaseHeader);

        // [GIVEN] The vat statement for section B2 has been created
        VATStatementName := CreateVATStatement();
        CreateVATStatementLine(VATStatementName, Enum::"General Posting Type"::Purchase,
            PurchaseLine1."VAT Bus. Posting Group", PurchaseLine1."VAT Prod. Posting Group", SectionB2Tok);
        CreateVATStatementLine(VATStatementName, Enum::"General Posting Type"::Purchase,
            PurchaseLine2."VAT Bus. Posting Group", PurchaseLine2."VAT Prod. Posting Group", SectionB2Tok);

        // [GIVEN] The vat control report for the last open vat period has been created
        VATCtrlReportHeaderCZL := CreateVATControlReport(
            Date2DMY(PurchaseHeader."Posting Date", 2), Date2DMY(PurchaseHeader."Posting Date", 3),
            VATStatementName."Statement Template Name", VATStatementName.Name);

        // [WHEN] Run suggest vat control report lines function
        SuggestVATControlReportLines(VATCtrlReportHeaderCZL);

        // [THEN] There will be no vat control report line for the purchase invoice
        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", VATCtrlReportHeaderCZL."No.");
        VATCtrlReportLineCZL.SetRange("Document No.", PostedDocumentNo);
        Assert.RecordIsEmpty(VATCtrlReportLineCZL);
    end;


    [Test]
    [HandlerFunctions('MessageHandler,VATCtrlReportGetEntHandler')]
    procedure SuggestSalesDocumentToVATControlReportByVATDate()
    var
        SalesHeader: Record "Sales Header";
        SalesLine1: Record "Sales Line";
        SalesLine2: Record "Sales Line";
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
        VATStatementName: Record "VAT Statement Name";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] The domestic sales invoice with different vat date is not suggested to vat control report.
        Initialize();

        // [GIVEN] The sales invoice header with vat date before last open vat period has been created
        SalesHeader := CreateSalesHeader(Enum::"Sales Document Type"::Invoice);
#if not CLEAN22
#pragma warning disable AL0432
        SalesHeader.Validate("VAT Date CZL", CalcDate('<CM-1M>', SalesHeader."Posting Date"));
        SalesHeader.Validate("Original Doc. VAT Date CZL", SalesHeader."VAT Date CZL");
#pragma warning restore AL0432
#else
        SalesHeader.Validate("VAT Reporting Date", CalcDate('<CM-1M>', SalesHeader."Posting Date"));
        SalesHeader.Validate("Original Doc. VAT Date CZL", SalesHeader."VAT Reporting Date");
#endif
        SalesHeader.Modify();

        // [GIVEN] The two sales invoice lines with amounts above limit has been created
        SalesLine1 := CreateSalesLineAboveLimit(
            SalesHeader, CreateVATPostingSetup(Enum::"Tax Calculation Type"::"Normal VAT", Enum::"VAT Rate CZL"::Base, 21));
        SalesLine2 := CreateSalesLineAboveLimit(
            SalesHeader, CreateVATPostingSetup(Enum::"Tax Calculation Type"::"Normal VAT", Enum::"VAT Rate CZL"::Base, 21));

        // [GIVEN] The created sales invoice has been posted
        PostedDocumentNo := PostSalesDocument(SalesHeader);

        // [GIVEN] The vat statement for section A4 has been created
        VATStatementName := CreateVATStatement();
        CreateVATStatementLine(VATStatementName, Enum::"General Posting Type"::Sale,
            SalesLine1."VAT Bus. Posting Group", SalesLine1."VAT Prod. Posting Group", SectionA4Tok);
        CreateVATStatementLine(VATStatementName, Enum::"General Posting Type"::Sale,
            SalesLine2."VAT Bus. Posting Group", SalesLine2."VAT Prod. Posting Group", SectionA4Tok);

        // [GIVEN] The vat control report for the last open vat period has been created
        VATCtrlReportHeaderCZL := CreateVATControlReport(
            Date2DMY(SalesHeader."Posting Date", 2), Date2DMY(SalesHeader."Posting Date", 3),
            VATStatementName."Statement Template Name", VATStatementName.Name);

        // [WHEN] Run suggest vat control report lines function
        SuggestVATControlReportLines(VATCtrlReportHeaderCZL);

        // [THEN] There will be no vat control report line for the sales invoice
        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", VATCtrlReportHeaderCZL."No.");
        VATCtrlReportLineCZL.SetRange("Document No.", PostedDocumentNo);
        Assert.RecordIsEmpty(VATCtrlReportLineCZL);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,VATCtrlReportGetEntHandler')]
    procedure SuggestSalesDocumentToVATControlReportWithIgnoreSimpleDocLimit()
    var
        SalesHeader: Record "Sales Header";
        SalesLine1: Record "Sales Line";
        SalesLine2: Record "Sales Line";
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
        VATEntry: Record "VAT Entry";
        VATStatementName: Record "VAT Statement Name";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] The domestic sales invoice below the limit with ignoring simple document limit.
        Initialize();

        // [GIVEN] The sales invoice header with vat date in the last open vat period has been created
        SalesHeader := CreateSalesHeader(Enum::"Sales Document Type"::Invoice);

        // [GIVEN] The two sales invoice lines with amounts below the limit has been created
        SalesLine1 := CreateSalesLineBelowLimit(
            SalesHeader, CreateVATPostingSetup(Enum::"Tax Calculation Type"::"Normal VAT", Enum::"VAT Rate CZL"::Base, 21));
        SalesLine2 := CreateSalesLineBelowLimit(
            SalesHeader, CreateVATPostingSetup(Enum::"Tax Calculation Type"::"Normal VAT", Enum::"VAT Rate CZL"::Base, 21));

        // [GIVEN] The created sales invoice has been posted
        PostedDocumentNo := PostSalesDocument(SalesHeader);

        // [GIVEN] The vat statement for section A4 has been created
        VATStatementName := CreateVATStatement();
        CreateVATStatementLine(VATStatementName, Enum::"General Posting Type"::Sale,
            SalesLine1."VAT Bus. Posting Group", SalesLine1."VAT Prod. Posting Group", SectionA4Tok, true);
        CreateVATStatementLine(VATStatementName, Enum::"General Posting Type"::Sale,
            SalesLine2."VAT Bus. Posting Group", SalesLine2."VAT Prod. Posting Group", SectionA4Tok, true);

        // [GIVEN] The vat control report for the last open vat period has been created
        VATCtrlReportHeaderCZL := CreateVATControlReport(
            Date2DMY(SalesHeader."Posting Date", 2), Date2DMY(SalesHeader."Posting Date", 3),
            VATStatementName."Statement Template Name", VATStatementName.Name);

        // [WHEN] Run suggest vat control report lines function
        SuggestVATControlReportLines(VATCtrlReportHeaderCZL);

        // [THEN] There will be only one vat control report line for the sales invoice
        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", VATCtrlReportHeaderCZL."No.");
        VATCtrlReportLineCZL.SetRange("Document No.", PostedDocumentNo);
        Assert.RecordCount(VATCtrlReportLineCZL, 1);

        // [THEN] The section on the line will be A4
        VATCtrlReportLineCZL.FindFirst();
        Assert.AreEqual(SectionA4Tok, VATCtrlReportLineCZL."VAT Ctrl. Report Section Code", UnexpectedSectionErr);

        // [THEN] The amount on the line will equal the sum of the base amount from entries
        VATEntry.SetRange("Document No.", PostedDocumentNo);
        VATEntry.CalcSums(Base);
        Assert.AreEqual(VATEntry.Base, VATCtrlReportLineCZL.Base, BaseAmountNotMatchErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,VATCtrlReportGetEntHandler')]
    procedure SuggestSalesDocumentToVATControlReportSectionA1WithTariffNoCombinations()
    var
        SalesHeader: Record "Sales Header";
        SalesLine1: Record "Sales Line";
        SalesLine2: Record "Sales Line";
        SalesLine3: Record "Sales Line";
        TariffNumber: Record "Tariff Number";
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
        VATStatementName: Record "VAT Statement Name";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] The domestic sales invoice with multi lines with reverse charge and tariff no. combinations is suggested to section A1 of vat control report.
        Initialize();

        // [GIVEN] The commodity lines have been created
        // [GIVEN] The tariff number has been created
        TariffNumber := CreateTariffNumber(CreateCommodity().Code, CreateCommodity(0).Code);

        // [GIVEN] The sales invoice header with vat date in the last open vat period has been created
        SalesHeader := CreateSalesHeader(Enum::"Sales Document Type"::Invoice);

        // [GIVEN] Three sales invoice lines with amount above limit have been created
        SalesLine1 := CreateSalesLineAboveLimit(
            SalesHeader, CreateVATPostingSetup(Enum::"Tax Calculation Type"::"Reverse Charge VAT", Enum::"VAT Rate CZL"::Base, 21), TariffNumber."No.");
        SalesLine2 := CreateSalesLineAboveLimit(
            SalesHeader, CreateVATPostingSetup(Enum::"Tax Calculation Type"::"Reverse Charge VAT", Enum::"VAT Rate CZL"::Base, 21), TariffNumber."No.");
        SalesLine3 := CreateSalesLineAboveLimit(
            SalesHeader, CreateVATPostingSetup(Enum::"Tax Calculation Type"::"Reverse Charge VAT", Enum::"VAT Rate CZL"::Base, 21));

        // [GIVEN] The created sales invoice has been posted
        PostedDocumentNo := PostSalesDocument(SalesHeader);

        // [GIVEN] The vat statement for section A1 has been created
        VATStatementName := CreateVATStatement();
        CreateVATStatementLine(VATStatementName, Enum::"General Posting Type"::Sale,
            SalesLine1."VAT Bus. Posting Group", SalesLine1."VAT Prod. Posting Group", SectionA1Tok);
        CreateVATStatementLine(VATStatementName, Enum::"General Posting Type"::Sale,
            SalesLine2."VAT Bus. Posting Group", SalesLine2."VAT Prod. Posting Group", SectionA1Tok);
        CreateVATStatementLine(VATStatementName, Enum::"General Posting Type"::Sale,
            SalesLine3."VAT Bus. Posting Group", SalesLine3."VAT Prod. Posting Group", SectionA1Tok);

        // [GIVEN] The vat control report for the last open vat period has been created
        VATCtrlReportHeaderCZL := CreateVATControlReport(
            Date2DMY(SalesHeader."Posting Date", 2), Date2DMY(SalesHeader."Posting Date", 3),
            VATStatementName."Statement Template Name", VATStatementName.Name);

        // [WHEN] Run suggest vat control report lines function
        SuggestVATControlReportLines(VATCtrlReportHeaderCZL);

        // [THEN] There will be two vat control report lines for the sales invoice
        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", VATCtrlReportHeaderCZL."No.");
        VATCtrlReportLineCZL.SetRange("Document No.", PostedDocumentNo);
        Assert.RecordCount(VATCtrlReportLineCZL, 2);

        // [THEN] The section on the first line will be A1 and commodity code will be filled
        VATCtrlReportLineCZL.FindSet();
        Assert.AreEqual(SectionA1Tok, VATCtrlReportLineCZL."VAT Ctrl. Report Section Code", UnexpectedSectionErr);
        Assert.AreEqual(TariffNumber."Statement Code CZL", VATCtrlReportLineCZL."Commodity Code", UnexpectedCommodityCodeErr);

        // [THEN] The amount on the first line will equal the sum of the base amount from the first two sales document lines
        Assert.AreEqual(-(SalesLine1."VAT Base Amount" + SalesLine2."VAT Base Amount"), VATCtrlReportLineCZL.Base, BaseAmountNotMatchErr);

        // [THEN] The section on the second line will be A1 and commodity code will be empty
        VATCtrlReportLineCZL.Next();
        Assert.AreEqual(SectionA1Tok, VATCtrlReportLineCZL."VAT Ctrl. Report Section Code", UnexpectedSectionErr);
        Assert.AreEqual('', VATCtrlReportLineCZL."Commodity Code", UnexpectedCommodityCodeErr);

        // [THEN] The amount on the second line will equal the sum of the base amount from the third sales document line
        Assert.AreEqual(-SalesLine3."VAT Base Amount", VATCtrlReportLineCZL.Base, BaseAmountNotMatchErr);
    end;

    local procedure CreateCommodity(LimitAmount: Decimal) CommodityCZL: Record "Commodity CZL"
    var
        CommoditySetupCZL: Record "Commodity Setup CZL";
    begin
        CommodityCZL := CreateCommodity();
        LibraryTax.CreateCommoditySetup(CommoditySetupCZL, CommodityCZL.Code, WorkDate(), 0D, LimitAmount);
    end;

    local procedure CreateCommodity() CommodityCZL: Record "Commodity CZL"
    begin
        LibraryTax.CreateCommodity(CommodityCZL);
    end;

    local procedure CreatePurchaseHeader(DocumentType: Enum "Purchase Document Type") PurchaseHeader: Record "Purchase Header"
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType,
          LibraryPurchase.CreateVendorWithVATBusPostingGroup(FindVATBusinessPostingGroup().Code));
        PurchaseHeader.Validate("Prices Including VAT", true);
        PurchaseHeader.Validate("Posting Date", LibraryTax.GetDateFromLastOpenVATPeriod());
#if not CLEAN22
#pragma warning disable AL0432
        PurchaseHeader.Validate("VAT Date CZL", PurchaseHeader."Posting Date");
        PurchaseHeader."Original Doc. VAT Date CZL" := PurchaseHeader."VAT Date CZL";
#pragma warning restore AL0432
#else
        PurchaseHeader.Validate("VAT Reporting Date", PurchaseHeader."Posting Date");
        PurchaseHeader."Original Doc. VAT Date CZL" := PurchaseHeader."VAT Reporting Date";
#endif
        PurchaseHeader.Modify();
    end;

    local procedure CreatePurchaseLine(PurchaseHeader: Record "Purchase Header"; VATPostingSetup: Record "VAT Posting Setup"; Amount: Decimal) PurchaseLine: Record "Purchase Line"
    begin
        PurchaseLine := CreatePurchaseLine(PurchaseHeader, VATPostingSetup, Amount, '');
    end;

    local procedure CreatePurchaseLine(PurchaseHeader: Record "Purchase Header"; VATPostingSetup: Record "VAT Posting Setup"; Amount: Decimal; TariffNo: Code[20]) PurchaseLine: Record "Purchase Line"
    begin
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account",
          LibraryERM.CreateGLAccountWithVATPostingSetup(VATPostingSetup, Enum::"General Posting Type"::Purchase), 1);
        PurchaseLine.Validate("Direct Unit Cost", Amount);
        if TariffNo <> '' then
            PurchaseLine.Validate("Tariff No. CZL", TariffNo);
        PurchaseLine.Modify(true);
    end;

    local procedure CreatePurchaseLineAboveLimit(PurchaseHeader: Record "Purchase Header"; VATPostingSetup: Record "VAT Posting Setup"): Record "Purchase Line";
    begin
        exit(CreatePurchaseLine(PurchaseHeader, VATPostingSetup, GetRandAmountAboveLimit()));
    end;

    local procedure CreatePurchaseLineAboveLimit(PurchaseHeader: Record "Purchase Header"; VATPostingSetup: Record "VAT Posting Setup"; TariffNo: Code[20]): Record "Purchase Line";
    begin
        exit(CreatePurchaseLine(PurchaseHeader, VATPostingSetup, GetRandAmountAboveLimit(), TariffNo));
    end;

    local procedure CreatePurchaseLineBelowLimit(PurchaseHeader: Record "Purchase Header"; VATPostingSetup: Record "VAT Posting Setup"): Record "Purchase Line";
    begin
        exit(CreatePurchaseLine(PurchaseHeader, VATPostingSetup, GetRandAmountBelowLimit()));
    end;

    local procedure CreateSalesHeader(DocumentType: Enum "Sales Document Type") SalesHeader: Record "Sales Header"
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType,
          LibrarySales.CreateCustomerWithVATBusPostingGroup(FindVATBusinessPostingGroup().Code));
        SalesHeader.Validate("Prices Including VAT", true);
        SalesHeader.Validate("Posting Date", LibraryTax.GetDateFromLastOpenVATPeriod());
#if not CLEAN22
#pragma warning disable AL0432
        SalesHeader.Validate("VAT Date CZL", SalesHeader."Posting Date");
        SalesHeader."Original Doc. VAT Date CZL" := SalesHeader."VAT Date CZL";
#pragma warning restore AL0432
#else
        SalesHeader.Validate("VAT Reporting Date", SalesHeader."Posting Date");
        SalesHeader."Original Doc. VAT Date CZL" := SalesHeader."VAT Reporting Date";
#endif
        SalesHeader.Modify();
    end;

    local procedure CreateSalesLine(SalesHeader: Record "Sales Header"; VATPostingSetup: Record "VAT Posting Setup"; Amount: Decimal) SalesLine: Record "Sales Line"
    begin
        SalesLine := CreateSalesLine(SalesHeader, VATPostingSetup, Amount, '');
    end;

    local procedure CreateSalesLine(SalesHeader: Record "Sales Header"; VATPostingSetup: Record "VAT Posting Setup"; Amount: Decimal; TariffNo: Code[20]) SalesLine: Record "Sales Line"
    begin
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::"G/L Account",
          LibraryERM.CreateGLAccountWithVATPostingSetup(VATPostingSetup, Enum::"General Posting Type"::Sale), 1);
        SalesLine.Validate("Unit Price", Amount);
        if TariffNo <> '' then
            SalesLine.Validate("Tariff No. CZL", TariffNo);
        SalesLine.Modify(true);
    end;

    local procedure CreateSalesLineAboveLimit(SalesHeader: Record "Sales Header"; VATPostingSetup: Record "VAT Posting Setup"): Record "Sales Line";
    begin
        exit(CreateSalesLine(SalesHeader, VATPostingSetup, GetRandAmountAboveLimit()));
    end;

    local procedure CreateSalesLineAboveLimit(SalesHeader: Record "Sales Header"; VATPostingSetup: Record "VAT Posting Setup"; TariffNo: Code[20]): Record "Sales Line";
    begin
        exit(CreateSalesLine(SalesHeader, VATPostingSetup, GetRandAmountAboveLimit(), TariffNo));
    end;

    local procedure CreateSalesLineBelowLimit(SalesHeader: Record "Sales Header"; VATPostingSetup: Record "VAT Posting Setup"): Record "Sales Line";
    begin
        exit(CreateSalesLine(SalesHeader, VATPostingSetup, GetRandAmountBelowLimit()));
    end;

    local procedure CreateTariffNumber(StatementCode: Code[10]; StatementLimitCode: Code[10]) TariffNumber: Record "Tariff Number"
    begin
        LibraryTax.CreateTariffNumber(TariffNumber);
        TariffNumber.Validate("Statement Code CZL", StatementCode);
        TariffNumber.Validate("Statement Limit Code CZL", StatementLimitCode);
        TariffNumber.Validate("Allow Empty UoM Code CZL", true);
        TariffNumber.Modify(true);
    end;

    local procedure CreateVATControlReport(PeriodNo: Integer; Year: Integer; VATStatementTemplateName: Code[10]; VATStatementName: Code[10]) VATCtrlReportHeader: Record "VAT Ctrl. Report Header CZL"
    begin
        LibraryTax.CreateVATControlReportWithPeriod(VATCtrlReportHeader, PeriodNo, Year);
        VATCtrlReportHeader.Validate("VAT Statement Template Name", VATStatementTemplateName);
        VATCtrlReportHeader.Validate("VAT Statement Name", VATStatementName);
        VATCtrlReportHeader.Modify(true);
    end;

    local procedure CreateVATPostingSetup(VATCalculationType: Enum "Tax Calculation Type"; VATRate: Enum "VAT Rate CZL"; VATPct: Decimal; EUService: Boolean) VATPostingSetup: Record "VAT Posting Setup"
    var
        VATProductPostingGroup: Record "VAT Product Posting Group";
    begin
        LibraryERM.CreateVATProductPostingGroup(VATProductPostingGroup);
        LibraryERM.CreateVATPostingSetup(VATPostingSetup, FindVATBusinessPostingGroup().Code, VATProductPostingGroup.Code);
        VATPostingSetup.Validate("VAT Calculation Type", VATCalculationType);
        VATPostingSetup.Validate("VAT Identifier", VATProductPostingGroup.Code);
        VATPostingSetup.Validate("VAT %", VATPct);
        VATPostingSetup.Validate("VAT Rate CZL", VATRate);
        VATPostingSetup.Validate("EU Service", EUService);
        VATPostingSetup.Validate("Sales VAT Account", LibraryERM.CreateGLAccountNo());
        VATPostingSetup.Validate("Purchase VAT Account", LibraryERM.CreateGLAccountNo());
        VATPostingSetup.Validate("Reverse Chrg. VAT Acc.", LibraryERM.CreateGLAccountNo());
        VATPostingSetup.Modify();
    end;

    local procedure CreateVATPostingSetup(VATCalculationType: Enum "Tax Calculation Type"; VATRate: Enum "VAT Rate CZL"; VATPct: Decimal) VATPostingSetup: Record "VAT Posting Setup"
    begin
        VATPostingSetup := CreateVATPostingSetup(VATCalculationType, VATRate, VATPct, false);
    end;

    local procedure CreateVATStatement() VATStatementName: Record "VAT Statement Name"
    begin
        LibraryERM.CreateVATStatementNameWithTemplate(VATStatementName);
    end;

    local procedure CreateVATStatementLine(VATStatementName: Record "VAT Statement Name"; GenPostingType: Enum "General Posting Type"; VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20]; SectionCode: Code[20]) VATStatementLine: Record "VAT Statement Line"
    begin
        VATStatementLine := CreateVATStatementLine(VATStatementName, GenPostingType, VATBusPostingGroup, VATProdPostingGroup, SectionCode, false);
    end;

    local procedure CreateVATStatementLine(VATStatementName: Record "VAT Statement Name"; GenPostingType: Enum "General Posting Type"; VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20]; SectionCode: Code[20]; IgnoreSimpleDocLimit: Boolean) VATStatementLine: Record "VAT Statement Line"
    begin
        LibraryERM.CreateVATStatementLine(
          VATStatementLine, VATStatementName."Statement Template Name", VATStatementName.Name);
        VATStatementLine.Validate(Type, Enum::"VAT Statement Line Type"::"VAT Entry Totaling");
        VATStatementLine.Validate("Gen. Posting Type", GenPostingType);
        VATStatementLine.Validate("Amount Type", Enum::"VAT Statement Line Amount Type"::Base);
        VATStatementLine.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        VATStatementLine.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        VATStatementLine.Validate("VAT Ctrl. Report Section CZL", SectionCode);
        VATStatementLine.Validate("Ignore Simpl. Doc. Limit CZL", IgnoreSimpleDocLimit);
        VATStatementLine.Modify();
    end;

    local procedure FindVATBusinessPostingGroup() VATBusinessPostingGroup: Record "VAT Business Posting Group"
    begin
        LibraryERM.FindVATBusinessPostingGroup(VATBusinessPostingGroup);
    end;

    local procedure GetRandAmountBelowLimit(): Decimal
    begin
        exit(LibraryRandom.RandDecInDecimalRange(1, (GetSimplifiedTaxDocumentLimit() - 1) / 2, 2));
    end;

    local procedure GetRandAmountAboveLimit(): Decimal
    begin
        exit(LibraryRandom.RandDecInDecimalRange(GetSimplifiedTaxDocumentLimit(), GetSimplifiedTaxDocumentLimit() * 2, 2));
    end;

    local procedure GetSimplifiedTaxDocumentLimit(): Decimal
    begin
        if SimplifiedTaxDocumentLimit = 0 then
            SimplifiedTaxDocumentLimit := LibraryTax.GetSimplifiedTaxDocumentLimit();
        exit(SimplifiedTaxDocumentLimit);
    end;

    local procedure PostPurchaseDocument(var PurchaseHeader: Record "Purchase Header"): Code[20]
    begin
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;

    local procedure PostSalesDocument(var SalesHeader: Record "Sales Header"): Code[20]
    begin
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure SuggestVATControlReportLines(var VATCtrlReportHeader: Record "VAT Ctrl. Report Header CZL")
    begin
        LibraryVariableStorage.Enqueue(VATCtrlReportHeader."Start Date");
        LibraryVariableStorage.Enqueue(VATCtrlReportHeader."End Date");
        LibraryVariableStorage.Enqueue(VATCtrlReportHeader."VAT Statement Template Name");
        LibraryVariableStorage.Enqueue(VATCtrlReportHeader."VAT Statement Name");
        LibraryVariableStorage.Enqueue(0); // Add
        Commit();
        LibraryTax.SuggestVATControlReportLines(VATCtrlReportHeader);
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
        // Message Handler
    end;

    [RequestPageHandler]
    procedure VATCtrlReportGetEntHandler(var VATCtrlReportGetEntCZL: TestRequestPage "VAT Ctrl. Report Get Ent. CZL")
    var
        VariantValue: Variant;
    begin
        LibraryVariableStorage.Dequeue(VariantValue);
        VATCtrlReportGetEntCZL.StartingDate.AssertEquals(VariantValue);
        LibraryVariableStorage.Dequeue(VariantValue);
        VATCtrlReportGetEntCZL.EndingDate.AssertEquals(VariantValue);
        LibraryVariableStorage.Dequeue(VariantValue);
        VATCtrlReportGetEntCZL.VATStatementTemplateCZL.AssertEquals(VariantValue);
        LibraryVariableStorage.Dequeue(VariantValue);
        VATCtrlReportGetEntCZL.VATStatementNameCZL.AssertEquals(VariantValue);
        LibraryVariableStorage.Dequeue(VariantValue);
        VATCtrlReportGetEntCZL.ProcessEntryTypeCZL.SetValue(VariantValue);
        VATCtrlReportGetEntCZL.OK().Invoke();
    end;
}