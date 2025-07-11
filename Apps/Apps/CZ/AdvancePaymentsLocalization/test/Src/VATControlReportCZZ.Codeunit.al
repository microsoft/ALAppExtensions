codeunit 148122 "VAT Control Report CZZ"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Advance Payments] [Sales] [Purchase] [VAT Control Report]
        isInitialized := false;
    end;

    var
        SalesAdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        PurchAdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryPurchAdvancesCZZ: Codeunit "Library - Purch. Advances CZZ";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        LibrarySalesAdvancesCZZ: Codeunit "Library - Sales Advances CZZ";
        LibraryTax: Codeunit "Library - Tax CZL";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        isInitialized: Boolean;
        SectionA4Tok: Label 'A4', Locked = true;
        SectionB2Tok: Label 'B2', Locked = true;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"VAT Control Report CZZ");
        LibraryRandom.Init();
        LibraryVariableStorage.Clear();
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"VAT Control Report CZZ");

        LibrarySalesAdvancesCZZ.CreateSalesAdvanceLetterTemplate(SalesAdvanceLetterTemplateCZZ);
        LibraryPurchAdvancesCZZ.CreatePurchAdvanceLetterTemplate(PurchAdvanceLetterTemplateCZZ);

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"VAT Control Report CZZ");
    end;

    [Test]
    procedure SalesAdvanceVATPaymentInVATControlReport()
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
        VATStatementName: Record "VAT Statement Name";
    begin
        // [SCENARIO] Sales advance VAT payment has to be part of the VAT control report
        Initialize();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetterBase(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ, '');

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT", 0);

        // [GIVEN] VAT statement has been created
        VATStatementName := CreateVATStatement();
        CreateVATStatementLine(VATStatementName, Enum::"General Posting Type"::Sale,
            SalesAdvLetterLineCZZ."VAT Bus. Posting Group", SalesAdvLetterLineCZZ."VAT Prod. Posting Group", SectionA4Tok);

        // [GIVEN] The vat control report has been created 
        VATCtrlReportHeaderCZL := CreateVATControlReport(
            Date2DMY(SalesAdvLetterHeaderCZZ."Posting Date", 2), Date2DMY(SalesAdvLetterHeaderCZZ."Posting Date", 3),
            VATStatementName."Statement Template Name", VATStatementName.Name);

        // [WHEN] Suggest VAT control report lines
        SuggestVATControlReportLines(VATCtrlReportHeaderCZL);

        // [THEN] The VAT payment document will be suggested in VAT control report line
        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        SalesAdvLetterEntryCZZ.FindFirst();

        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", VATCtrlReportHeaderCZL."No.");
        VATCtrlReportLineCZL.SetRange("Document No.", SalesAdvLetterEntryCZZ."Document No.");
        VATCtrlReportLineCZL.FindFirst();
        Assert.IsFalse(VATCtrlReportLineCZL.IsEmpty(), 'The VAT control report line for VAT payment must exist.');
        Assert.AreEqual(SalesAdvLetterEntryCZZ."VAT Base Amount", VATCtrlReportLineCZL.Base, 'The base must be the same as in sales advance letter entry.');
        Assert.AreEqual(SalesAdvLetterEntryCZZ."VAT Amount", VATCtrlReportLineCZL.Amount, 'The VAT amount must be the same as in sales advance letter entry');
    end;

    [Test]
    procedure SalesAdvanceVATPaymentLinkedToInvoiceInVATControlReport()
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
        VATStatementName: Record "VAT Statement Name";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Sales advance VAT payment linked to invoice has to be part of the VAT control report
        Initialize();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetterBase(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ, '');

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT", 0);

        // [GIVEN] Sales invoice has been created
        // [GIVEN] Sales invoice line has been created
        LibrarySalesAdvancesCZZ.CreateSalesInvoice(
            SalesHeader, SalesLine, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", SalesAdvLetterHeaderCZZ."Posting Date",
            SalesAdvLetterLineCZZ."VAT Bus. Posting Group", SalesAdvLetterLineCZZ."VAT Prod. Posting Group", '', 0,
            true, SalesAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Whole advance letter has been linked to sales invoice
        LibrarySalesAdvancesCZZ.LinkSalesAdvanceLetterToDocument(
            SalesAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Sales Invoice", SalesHeader."No.",
            SalesAdvLetterLineCZZ."Amount Including VAT", SalesAdvLetterLineCZZ."Amount Including VAT (LCY)");

        // [GIVEN] Sales invoice has been posted
        PostedDocumentNo := PostSalesDocument(SalesHeader);

        // [GIVEN] VAT statement has been created
        VATStatementName := CreateVATStatement();
        CreateVATStatementLine(VATStatementName, Enum::"General Posting Type"::Sale,
            SalesAdvLetterLineCZZ."VAT Bus. Posting Group", SalesAdvLetterLineCZZ."VAT Prod. Posting Group", SectionA4Tok);

        // [GIVEN] The vat control report has been created 
        VATCtrlReportHeaderCZL := CreateVATControlReport(
            Date2DMY(SalesAdvLetterHeaderCZZ."Posting Date", 2), Date2DMY(SalesAdvLetterHeaderCZZ."Posting Date", 3),
            VATStatementName."Statement Template Name", VATStatementName.Name);

        // [WHEN] Suggest VAT control report lines
        SuggestVATControlReportLines(VATCtrlReportHeaderCZL);

        // [THEN] The VAT payment document will be suggested in VAT control report line
        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        SalesAdvLetterEntryCZZ.FindFirst();

        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", VATCtrlReportHeaderCZL."No.");
        VATCtrlReportLineCZL.SetRange("Document No.", SalesAdvLetterEntryCZZ."Document No.");
        VATCtrlReportLineCZL.FindFirst();
        Assert.IsFalse(VATCtrlReportLineCZL.IsEmpty(), 'The VAT control report line for VAT payment must exist.');
        Assert.AreEqual(SalesAdvLetterEntryCZZ."VAT Base Amount", VATCtrlReportLineCZL.Base, 'The base must be the same as in sales advance letter entry.');
        Assert.AreEqual(SalesAdvLetterEntryCZZ."VAT Amount", VATCtrlReportLineCZL.Amount, 'The VAT amount must be the same as in sales advance letter entry');

        // [THEN] The posted invoice won't be suggested in VAT control report line
        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", VATCtrlReportHeaderCZL."No.");
        VATCtrlReportLineCZL.SetRange("Document No.", PostedDocumentNo);
        Assert.IsTrue(VATCtrlReportLineCZL.IsEmpty(), 'The posted invoice can not be suggested to VAT control report.');
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure PurchAdvanceVATPaymentInVATControlReport()
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
        VATStatementName: Record "VAT Statement Name";
    begin
        // [SCENARIO] Purchase advance VAT payment has to be part of the VAT control report
        Initialize();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetterBase(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ, '');

        // [GIVEN] Purchase advance letter has been released
        LibraryPurchAdvancesCZZ.ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT", 0);

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] VAT statement has been created
        VATStatementName := CreateVATStatement();
        CreateVATStatementLine(VATStatementName, Enum::"General Posting Type"::Purchase,
            PurchAdvLetterLineCZZ."VAT Bus. Posting Group", PurchAdvLetterLineCZZ."VAT Prod. Posting Group", SectionB2Tok);

        // [GIVEN] The vat control report has been created 
        VATCtrlReportHeaderCZL := CreateVATControlReport(
            Date2DMY(PurchAdvLetterHeaderCZZ."Posting Date", 2), Date2DMY(PurchAdvLetterHeaderCZZ."Posting Date", 3),
            VATStatementName."Statement Template Name", VATStatementName.Name);

        // [WHEN] Suggest VAT control report lines
        SuggestVATControlReportLines(VATCtrlReportHeaderCZL);

        // [THEN] The VAT payment document will be suggested in VAT control report line
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        PurchAdvLetterEntryCZZ.FindFirst();

        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", VATCtrlReportHeaderCZL."No.");
        VATCtrlReportLineCZL.SetRange("Document No.", PurchAdvLetterEntryCZZ."Document No.");
        VATCtrlReportLineCZL.FindFirst();
        Assert.IsFalse(VATCtrlReportLineCZL.IsEmpty(), 'The VAT control report line for VAT payment must exist.');
        Assert.AreEqual(PurchAdvLetterEntryCZZ."VAT Base Amount", VATCtrlReportLineCZL.Base, 'The base must be the same as in purchase advance letter entry.');
        Assert.AreEqual(PurchAdvLetterEntryCZZ."VAT Amount", VATCtrlReportLineCZL.Amount, 'The VAT amount must be the same as in purchase advance letter entry');
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure PurchAdvanceVATPaymentLinkedToInvoiceInVATControlReport()
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
        VATStatementName: Record "VAT Statement Name";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Purchase advance VAT payment linked to invoice has to be part of the VAT control report
        Initialize();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetterBase(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ, '');

        // [GIVEN] Purchase advance letter has been released
        LibraryPurchAdvancesCZZ.ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT", 0);

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase invoice has been created
        // [GIVEN] Purchase invoice line has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchHeader, PurchLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Posting Date",
            PurchAdvLetterLineCZZ."VAT Bus. Posting Group", PurchAdvLetterLineCZZ."VAT Prod. Posting Group", '', 0,
            true, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Whole advance letter has been linked to purchase invoice
        LibraryPurchAdvancesCZZ.LinkPurchAdvanceLetterToDocument(
            PurchAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice", PurchHeader."No.",
            PurchAdvLetterLineCZZ."Amount Including VAT", PurchAdvLetterLineCZZ."Amount Including VAT (LCY)");

        // [GIVEN] Purchase invoice has been posted
        PostedDocumentNo := PostPurchDocument(PurchHeader);

        // [GIVEN] VAT statement has been created
        VATStatementName := CreateVATStatement();
        CreateVATStatementLine(VATStatementName, Enum::"General Posting Type"::Purchase,
            PurchAdvLetterLineCZZ."VAT Bus. Posting Group", PurchAdvLetterLineCZZ."VAT Prod. Posting Group", SectionB2Tok);

        // [GIVEN] The vat control report has been created 
        VATCtrlReportHeaderCZL := CreateVATControlReport(
            Date2DMY(PurchAdvLetterHeaderCZZ."Posting Date", 2), Date2DMY(PurchAdvLetterHeaderCZZ."Posting Date", 3),
            VATStatementName."Statement Template Name", VATStatementName.Name);

        // [WHEN] Suggest VAT control report lines
        SuggestVATControlReportLines(VATCtrlReportHeaderCZL);

        // [THEN] The VAT payment document will be suggested in VAT control report line
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        PurchAdvLetterEntryCZZ.FindFirst();

        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", VATCtrlReportHeaderCZL."No.");
        VATCtrlReportLineCZL.SetRange("Document No.", PurchAdvLetterEntryCZZ."Document No.");
        VATCtrlReportLineCZL.FindFirst();
        Assert.IsFalse(VATCtrlReportLineCZL.IsEmpty(), 'The VAT control report line for VAT payment must exist.');
        Assert.AreEqual(PurchAdvLetterEntryCZZ."VAT Base Amount", VATCtrlReportLineCZL.Base, 'The base must be the same as in purchase advance letter entry.');
        Assert.AreEqual(PurchAdvLetterEntryCZZ."VAT Amount", VATCtrlReportLineCZL.Amount, 'The VAT amount must be the same as in purchase advance letter entry');

        // [THEN] The posted invoice won't be suggested in VAT control report line
        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", VATCtrlReportHeaderCZL."No.");
        VATCtrlReportLineCZL.SetRange("Document No.", PostedDocumentNo);
        Assert.IsTrue(VATCtrlReportLineCZL.IsEmpty(), 'The posted invoice can not be suggested to VAT control report.');
    end;

    local procedure CreateSalesAdvLetterBase(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; CurrencyCode: Code[10])
    var
        VATPostingSetup: Record "VAT Posting Setup";
        Customer: Record Customer;
    begin
        LibrarySalesAdvancesCZZ.FindVATPostingSetup(VATPostingSetup);
        LibrarySalesAdvancesCZZ.CreateCustomer(Customer);
        Customer.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        Customer.Modify(true);

        LibrarySalesAdvancesCZZ.CreateSalesAdvLetterHeader(SalesAdvLetterHeaderCZZ, SalesAdvanceLetterTemplateCZZ.Code, Customer."No.", CurrencyCode);
        LibrarySalesAdvancesCZZ.CreateSalesAdvLetterLine(SalesAdvLetterLineCZZ, SalesAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));
    end;

    local procedure CreatePurchAdvLetterBase(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ"; CurrencyCode: Code[10])
    var
        VATPostingSetup: Record "VAT Posting Setup";
        Vendor: Record Vendor;
    begin
        LibraryPurchAdvancesCZZ.FindVATPostingSetup(VATPostingSetup);
        LibraryPurchAdvancesCZZ.CreateVendor(Vendor);
        Vendor.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        Vendor.Modify(true);

        LibraryPurchAdvancesCZZ.CreatePurchAdvLetterHeader(PurchAdvLetterHeaderCZZ, PurchAdvanceLetterTemplateCZZ.Code, Vendor."No.", CurrencyCode);
        LibraryPurchAdvancesCZZ.CreatePurchAdvLetterLine(PurchAdvLetterLineCZZ, PurchAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));
    end;

    local procedure CreateAndPostPaymentSalesAdvLetter(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; Amount: Decimal; ExchangeRate: Decimal)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        LibrarySalesAdvancesCZZ.CreateSalesAdvancePayment(GenJournalLine, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", Amount, SalesAdvLetterHeaderCZZ."Currency Code", SalesAdvLetterHeaderCZZ."No.", ExchangeRate);
        LibrarySalesAdvancesCZZ.PostSalesAdvancePayment(GenJournalLine);
    end;

    local procedure CreateAndPostPaymentPurchAdvLetter(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; Amount: Decimal; ExchangeRate: Decimal)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        LibraryPurchAdvancesCZZ.CreatePurchAdvancePayment(GenJournalLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", Amount, PurchAdvLetterHeaderCZZ."Currency Code", PurchAdvLetterHeaderCZZ."No.", ExchangeRate);
        LibraryPurchAdvancesCZZ.PostPurchAdvancePayment(GenJournalLine);
    end;

    local procedure PostSalesDocument(var SalesHeader: Record "Sales Header"): Code[20]
    begin
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure PostPurchDocument(var PurchHeader: Record "Purchase Header"): Code[20]
    begin
        exit(LibraryPurchase.PostPurchaseDocument(PurchHeader, true, true));
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

    local procedure CreateVATControlReport(PeriodNo: Integer; Year: Integer; VATStatementTemplateName: Code[10]; VATStatementName: Code[10]) VATCtrlReportHeader: Record "VAT Ctrl. Report Header CZL"
    begin
        LibraryTax.CreateVATControlReportWithPeriod(VATCtrlReportHeader, PeriodNo, Year);
        VATCtrlReportHeader.Validate("VAT Statement Template Name", VATStatementTemplateName);
        VATCtrlReportHeader.Validate("VAT Statement Name", VATStatementName);
        VATCtrlReportHeader.Modify(true);
    end;

    local procedure SuggestVATControlReportLines(var VATCtrlReportHeader: Record "VAT Ctrl. Report Header CZL")
    var
        VATCtrlReportMgtCZL: Codeunit "VAT Ctrl. Report Mgt. CZL";
    begin
        VATCtrlReportMgtCZL.GetVATCtrlReportLines(VATCtrlReportHeader, VATCtrlReportHeader."Start Date", VATCtrlReportHeader."End Date",
            VATCtrlReportHeader."VAT Statement Template Name", VATCtrlReportHeader."VAT Statement Name", 0, false, false);
    end;

    local procedure FindPaymentAdvanceLetterEntry(AdvanceLetterNo: Code[20]; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    begin
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", AdvanceLetterNo);
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Payment);
        PurchAdvLetterEntryCZZ.FindFirst();
    end;

    local procedure PostPurchAdvancePaymentVAT(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ");
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
    begin
        FindPaymentAdvanceLetterEntry(PurchAdvLetterHeaderCZZ."No.", PurchAdvLetterEntryCZZ);
        PostPurchAdvancePaymentVAT(PurchAdvLetterEntryCZZ);
    end;

    local procedure PostPurchAdvancePaymentVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ");
    begin
        LibraryVariableStorage.Enqueue(WorkDate()); // original document vat date
        LibraryVariableStorage.Enqueue(PurchAdvLetterEntryCZZ."Document No."); // external document no.
        LibraryPurchAdvancesCZZ.PostPurchAdvancePaymentVAT(PurchAdvLetterEntryCZZ);
    end;

    [ModalPageHandler]
    procedure ModalVATDocumentHandler(var VATDocument: TestPage "VAT Document CZZ")
    begin
        VATDocument.OriginalDocumentVATDate.SetValue(LibraryVariableStorage.DequeueDate());
        VATDocument.ExternalDocumentNo.SetValue(LibraryVariableStorage.DequeueText());
        VATDocument.OK().Invoke();
    end;
}