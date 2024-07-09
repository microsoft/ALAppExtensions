codeunit 148129 "Sales Adv. Pmt.Rev.Charge CZZ"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Advance Payments] [Sales] [Feverse Charge]
        isInitialized := false;
    end;

    var
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        GeneralLedgerSetup: Record "General Ledger Setup";
        Assert: Codeunit Assert;
        LibraryDialogHandler: Codeunit "Library - Dialog Handler";
        LibrarySalesAdvancesCZZ: Codeunit "Library - Sales Advances CZZ";
        LibrarySales: Codeunit "Library - Sales";
        LibraryRandom: Codeunit "Library - Random";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        isInitialized: Boolean;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Sales Adv. Pmt.Rev.Charge CZZ");
        LibraryRandom.Init();
        LibraryVariableStorage.Clear();
        LibraryDialogHandler.ClearVariableStorage();
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Sales Adv. Pmt.Rev.Charge CZZ");

        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."VAT Reporting Date Usage" := GeneralLedgerSetup."VAT Reporting Date Usage"::Enabled;
        GeneralLedgerSetup."Def. Orig. Doc. VAT Date CZL" := GeneralLedgerSetup."Def. Orig. Doc. VAT Date CZL"::"VAT Date";
        GeneralLedgerSetup."Max. VAT Difference Allowed" := 0.5;
        GeneralLedgerSetup.Modify();

        LibrarySalesAdvancesCZZ.CreateSalesAdvanceLetterTemplate(AdvanceLetterTemplateCZZ);
        AdvanceLetterTemplateCZZ."Post VAT Doc. for Rev. Charge" := false;
        AdvanceLetterTemplateCZZ.Modify();

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Sales Adv. Pmt.Rev.Charge CZZ");
    end;

    [Test]
    procedure SalesAdvLetterWithReverseCharge()
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
    begin
        // [SCENARIO] VAT document of sales advance letter with reverse charge
        Initialize();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with reverse charge has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [WHEN] Pay sales advance letter in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

        // [THEN] Sales advance letter entry of "VAT Payment" type will be created
        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ);

        // [THEN] VAT entry won't be created for the sales advance letter entry with reverse charge
        SalesAdvLetterEntryCZZ.FindFirst();
        Assert.AreEqual(0, SalesAdvLetterEntryCZZ."VAT Entry No.", 'VAT entry mustn''t be created.');

        // [THEN] Created sales advance letter entry will be marked as auxiliary
        Assert.AreEqual(true, SalesAdvLetterEntryCZZ."Auxiliary Entry", 'Auxiliary entry must be true.');

        // [THEN] The document no. will be equal to the advance letter no.
        Assert.AreEqual(SalesAdvLetterHeaderCZZ."No.", SalesAdvLetterEntryCZZ."Document No.", 'Document No. must be equal to advance letter no.');
    end;

    [Test]
    procedure LinkSalesAdvLetterWithReverseChargeToInvoice()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        VATEntry: Record "VAT Entry";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Link sales advance letter with reverse charge to sales invoice
        Initialize();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with reverse charge has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Sales invoice has been created
        // [GIVEN] Sales invoice line with reverse charge has been created
        LibrarySalesAdvancesCZZ.CreateSalesInvoice(
            SalesHeader, SalesLine, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", SalesAdvLetterHeaderCZZ."Posting Date",
            SalesAdvLetterLineCZZ."VAT Bus. Posting Group", SalesAdvLetterLineCZZ."VAT Prod. Posting Group", '', 0,
            true, SalesAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Whole advance letter has been linked to sales invoice
        LibrarySalesAdvancesCZZ.LinkSalesAdvanceLetterToDocument(
            SalesAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Sales Invoice", SalesHeader."No.",
            SalesAdvLetterLineCZZ."Amount Including VAT", SalesAdvLetterLineCZZ."Amount Including VAT (LCY)");

        // [WHEN] Post sales invoice
        PostedDocumentNo := PostSalesDocument(SalesHeader);

        // [THEN] VAT entries of sales invoice will exist
        VATEntry.Reset();
        VATEntry.SetRange("Document No.", PostedDocumentNo);
        VATEntry.SetRange("Posting Date", SalesHeader."Posting Date");
        VATEntry.SetRange("Advance Letter No. CZZ", '');
        Assert.RecordIsNotEmpty(VATEntry);

        // [THEN] VAT entries of advance letter won't be exist
        VATEntry.SetRange("Advance Letter No. CZZ", SalesAdvLetterHeaderCZZ."No.");
        Assert.RecordIsEmpty(VATEntry);

        // [THEN] Sales advance letter entry of "Usage" type will be created
        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.CalcSums("VAT Base Amount", "VAT Base Amount (LCY)");
        Assert.AreNearlyEqual(0, SalesAdvLetterEntryCZZ."VAT Base Amount", 1, 'The sum of VAT base amount must be zero.');
        Assert.AreNearlyEqual(0, SalesAdvLetterEntryCZZ."VAT Base Amount (LCY)", 1, 'The sum of VAT base amount (LCY) must be zero.');

        // [THEN] Sales advance letter will be closed
        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterHeaderCZZ.TestField(Status, SalesAdvLetterHeaderCZZ.Status::Closed);
    end;

    [Test]
    procedure SalesAdvLetterWithNormalVAT()
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        // [SCENARIO] VAT document of sales advance letter with normal VAT
        Initialize();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        LibrarySalesAdvancesCZZ.FindVATPostingSetup(VATPostingSetup);
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ, VATPostingSetup);

        // [GIVEN] Sales advance letter has been released
        ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [WHEN] Pay sales advance letter in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

        // [THEN] Sales advance letter entry of "VAT Payment" type will be created
        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ);

        // [THEN] Created sales advance letter entry will have VAT amounts
        SalesAdvLetterEntryCZZ.FindFirst();
        Assert.AreNotEqual(0, SalesAdvLetterEntryCZZ."VAT Amount", 'VAT amount mustn''t be zero.');
        Assert.AreNotEqual(0, SalesAdvLetterEntryCZZ."VAT Amount (LCY)", 'VAT amount (LCY) mustn''t be zero.');
        Assert.AreNotEqual(0, SalesAdvLetterEntryCZZ."VAT Base Amount", 'VAT base amount mustn''t be zero.');
        Assert.AreNotEqual(0, SalesAdvLetterEntryCZZ."VAT Base Amount (LCY)", 'VAT base amount (LCY) mustn''t be zero.');
        Assert.AreNotEqual(0, SalesAdvLetterEntryCZZ."VAT Entry No.", 'VAT entry must be created.');

        // [THEN] Created sales advance letter entry won't be marked as auxiliary
        Assert.AreEqual(false, SalesAdvLetterEntryCZZ."Auxiliary Entry", 'Auxiliary entry must be false.');

        // [THEN] The document no. won't be equal to the advance letter no.
        Assert.AreNotEqual(SalesAdvLetterHeaderCZZ."No.", SalesAdvLetterEntryCZZ."Document No.", 'Document No. mustn''t be equal to advance letter no.');
    end;

    [Test]
    procedure SalesAdvLetterWithNormalVATAndReverseCharge()
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        // [SCENARIO] VAT document of sales advance letter with normal VAT and reverse charge
        Initialize();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with reverse charge has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter line with normal VAT has been created
        LibrarySalesAdvancesCZZ.FindVATPostingSetup(VATPostingSetup);
        LibrarySalesAdvancesCZZ.CreateSalesAdvLetterLine(
            SalesAdvLetterLineCZZ, SalesAdvLetterHeaderCZZ,
            VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Sales advance letter has been released
        ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [WHEN] Pay sales advance letter in full by the general journal
        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterHeaderCZZ."Amount Including VAT");

        // [THEN] Sales advance letter entry of "VAT Payment" type with normal VAT will be created
        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        SalesAdvLetterEntryCZZ.SetRange("VAT Calculation Type", SalesAdvLetterEntryCZZ."VAT Calculation Type"::"Normal VAT");
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ);

        // [THEN] Created sales advance letter entry with normal VAT will have VAT amounts
        SalesAdvLetterEntryCZZ.FindFirst();
        Assert.AreNotEqual(0, SalesAdvLetterEntryCZZ."VAT Amount", 'VAT amount mustn''t be zero.');
        Assert.AreNotEqual(0, SalesAdvLetterEntryCZZ."VAT Amount (LCY)", 'VAT amount (LCY) mustn''t be zero.');
        Assert.AreNotEqual(0, SalesAdvLetterEntryCZZ."VAT Base Amount", 'VAT base amount mustn''t be zero.');
        Assert.AreNotEqual(0, SalesAdvLetterEntryCZZ."VAT Base Amount (LCY)", 'VAT base amount (LCY) mustn''t be zero.');
        Assert.AreNotEqual(0, SalesAdvLetterEntryCZZ."VAT Entry No.", 'VAT entry must be created.');

        // [THEN] Sales advance letter entry with normal VAT won't be marked as auxiliary
        Assert.AreEqual(false, SalesAdvLetterEntryCZZ."Auxiliary Entry", 'Auxiliary entry must be false.');

        // [THEN] The document no. won't be equal to the advance letter no.
        Assert.AreNotEqual(SalesAdvLetterHeaderCZZ."No.", SalesAdvLetterEntryCZZ."Document No.", 'Document No. mustn''t be equal to advance letter no.');

        // [THEN] Sales advance letter entry of "VAT Payment" type with reverse charge will be created
        SalesAdvLetterEntryCZZ.SetRange("VAT Calculation Type", SalesAdvLetterEntryCZZ."VAT Calculation Type"::"Reverse Charge VAT");
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ);

        // [THEN] VAT entry won't be created for the sales advance letter entry with reverse charge
        SalesAdvLetterEntryCZZ.FindFirst();
        Assert.AreEqual(0, SalesAdvLetterEntryCZZ."VAT Entry No.", 'VAT entry mustn''t be created.');

        // [THEN] Sales advance letter entry with reverse charge will be marked as auxiliary
        Assert.AreEqual(true, SalesAdvLetterEntryCZZ."Auxiliary Entry", 'Auxiliary entry must be true.');

        // [THEN] The document no. won't be equal to the advance letter no.
        Assert.AreNotEqual(SalesAdvLetterHeaderCZZ."No.", SalesAdvLetterEntryCZZ."Document No.", 'Document No. mustn''t be equal to advance letter no.');
    end;

    [Test]
    procedure SalesAdvLetterWithNormalVATAndReverseChargePartiallyPaid()
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
        PaymentAmount: Decimal;
        VATPaymentAmount: Decimal;
    begin
        // [SCENARIO] VAT document of sales advance letter with normal VAT and reverse charge is partially paid                                                                                                                                                                                                                                                                                                                                                                                   
        Initialize();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with reverse charge has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter line with normal VAT has been created
        LibrarySalesAdvancesCZZ.FindVATPostingSetup(VATPostingSetup);
        LibrarySalesAdvancesCZZ.CreateSalesAdvLetterLine(
            SalesAdvLetterLineCZZ, SalesAdvLetterHeaderCZZ,
            VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Sales advance letter has been released
        ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [WHEN] Pay sales advance letter in half by the general journal
        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterHeaderCZZ."Amount Including VAT" / 2);

        // [THEN] Sales advance letter entry of "VAT Payment" type with normal VAT will be created
        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        SalesAdvLetterEntryCZZ.SetRange("VAT Calculation Type", SalesAdvLetterEntryCZZ."VAT Calculation Type"::"Normal VAT");
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ);

        // [THEN] Created sales advance letter entry with normal VAT will have VAT amounts
        SalesAdvLetterEntryCZZ.FindFirst();
        VATPaymentAmount := SalesAdvLetterEntryCZZ."Amount";
        Assert.AreNotEqual(0, SalesAdvLetterEntryCZZ."VAT Amount", 'VAT amount mustn''t be zero.');
        Assert.AreNotEqual(0, SalesAdvLetterEntryCZZ."VAT Amount (LCY)", 'VAT amount (LCY) mustn''t be zero.');
        Assert.AreNotEqual(0, SalesAdvLetterEntryCZZ."VAT Base Amount", 'VAT base amount mustn''t be zero.');
        Assert.AreNotEqual(0, SalesAdvLetterEntryCZZ."VAT Base Amount (LCY)", 'VAT base amount (LCY) mustn''t be zero.');
        Assert.AreNotEqual(0, SalesAdvLetterEntryCZZ."VAT Entry No.", 'VAT entry must be created.');

        // [THEN] Created sales advance letter entry with normal VAT won't be marked as auxiliary
        Assert.AreEqual(false, SalesAdvLetterEntryCZZ."Auxiliary Entry", 'Auxiliary entry must be false.');

        // [THEN] The document no. won't be equal to the advance letter no.
        Assert.AreNotEqual(SalesAdvLetterHeaderCZZ."No.", SalesAdvLetterEntryCZZ."Document No.", 'Document No. mustn''t be equal to advance letter no.');

        // [THEN] Sales advance letter entry of "VAT Payment" type with reverse charge will be created
        SalesAdvLetterEntryCZZ.SetRange("VAT Calculation Type", SalesAdvLetterEntryCZZ."VAT Calculation Type"::"Reverse Charge VAT");
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ);

        // [THEN] VAT entry won't be created for the sales advance letter entry with reverse charge
        SalesAdvLetterEntryCZZ.FindFirst();
        VATPaymentAmount += SalesAdvLetterEntryCZZ."Amount";
        Assert.AreEqual(0, SalesAdvLetterEntryCZZ."VAT Entry No.", 'VAT entry mustn''t be created.');

        // [THEN] Created sales advance letter entry with reverse charge will be marked as auxiliary
        Assert.AreEqual(true, SalesAdvLetterEntryCZZ."Auxiliary Entry", 'Auxiliary entry must be true.');

        // [THEN] The document no. won't be equal to the advance letter no.
        Assert.AreNotEqual(SalesAdvLetterHeaderCZZ."No.", SalesAdvLetterEntryCZZ."Document No.", 'Document No. mustn''t be equal to advance letter no.');

        // [THEN] The sum of payment amount must be equal to the sum of VAT payment amount
        SalesAdvLetterEntryCZZ.Reset();
        FindLastPaymentAdvanceLetterEntry(SalesAdvLetterHeaderCZZ."No.", SalesAdvLetterEntryCZZ);
        PaymentAmount := SalesAdvLetterEntryCZZ."Amount";
        Assert.AreEqual(PaymentAmount, VATPaymentAmount, 'The sum of payment amount must be equal to the sum of VAT payment amount.');
    end;

    [Test]
    procedure LinkSalesAdvLetterWithNormalVATAndReverseChargeToInvoice1()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ1: Record "Sales Adv. Letter Line CZZ";
        SalesAdvLetterLineCZZ2: Record "Sales Adv. Letter Line CZZ";
        VATEntry: Record "VAT Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Link sales advance letter with normal VAT and reverse charge to sales invoice with normal VAT
        Initialize();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with reverse charge has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ1);

        // [GIVEN] Sales advance letter line with normal VAT has been created
        LibrarySalesAdvancesCZZ.FindVATPostingSetup(VATPostingSetup); // normal VAT
        LibrarySalesAdvancesCZZ.CreateSalesAdvLetterLine(
            SalesAdvLetterLineCZZ2, SalesAdvLetterHeaderCZZ,
            VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Sales advance letter has been released
        ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterHeaderCZZ."Amount Including VAT");

        // [GIVEN] Sales invoice has been created
        // [GIVEN] Sales invoice line with normal VAT has been created
        LibrarySalesAdvancesCZZ.CreateSalesInvoice(
            SalesHeader, SalesLine, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", SalesAdvLetterHeaderCZZ."Posting Date",
            SalesAdvLetterLineCZZ2."VAT Bus. Posting Group", SalesAdvLetterLineCZZ2."VAT Prod. Posting Group", '', 0,
            true, SalesAdvLetterLineCZZ2."Amount Including VAT");

        // [GIVEN] Second line with normal VAT has been linked to sales invoice
        LibrarySalesAdvancesCZZ.LinkSalesAdvanceLetterToDocument(
            SalesAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Sales Invoice", SalesHeader."No.",
            SalesAdvLetterHeaderCZZ."Amount Including VAT", SalesAdvLetterHeaderCZZ."Amount Including VAT (LCY)");

        // [WHEN] Post sales invoice
        PostedDocumentNo := PostSalesDocument(SalesHeader);

        // [THEN] VAT entries of sales invoice will exist
        VATEntry.Reset();
        VATEntry.SetRange("Document No.", PostedDocumentNo);
        VATEntry.SetRange("Posting Date", SalesHeader."Posting Date");
        VATEntry.SetRange("Advance Letter No. CZZ", '');
        Assert.RecordIsNotEmpty(VATEntry);

        // [THEN] VAT entries of advance letter will exist
        VATEntry.SetRange("Advance Letter No. CZZ", SalesAdvLetterHeaderCZZ."No.");
        Assert.RecordIsNotEmpty(VATEntry);

        // [THEN] Sum of base and VAT amounts in VAT entries will be zero
        VATEntry.SetRange("Advance Letter No. CZZ");
        VATEntry.CalcSums(Base, Amount);
        Assert.AreEqual(0, VATEntry.Base, 'The sum of base amount in VAT Entries must be zero.');
        Assert.AreEqual(0, VATEntry.Amount, 'The sum of VAT amount in VAT Entries must be zero.');

        // [THEN] VAT entries will have the same VAT calculation type
        VATEntry.SetFilter("VAT Calculation Type", '<>%1', SalesAdvLetterLineCZZ2."VAT Calculation Type");
        Assert.RecordIsEmpty(VATEntry);
    end;

    [Test]
    procedure LinkSalesAdvLetterWithNormalVATAndReverseChargeToInvoice2()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ1: Record "Sales Adv. Letter Line CZZ";
        SalesAdvLetterLineCZZ2: Record "Sales Adv. Letter Line CZZ";
        VATEntry: Record "VAT Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Link sales advance letter with normal VAT and reverse charge to sales invoice with reverse charge
        Initialize();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with reverse charge has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ1);

        // [GIVEN] Sales advance letter line with normal VAT has been created
        LibrarySalesAdvancesCZZ.FindVATPostingSetup(VATPostingSetup);
        LibrarySalesAdvancesCZZ.CreateSalesAdvLetterLine(
            SalesAdvLetterLineCZZ2, SalesAdvLetterHeaderCZZ,
            VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Sales advance letter has been released
        ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterHeaderCZZ."Amount Including VAT");

        // [GIVEN] Sales invoice has been created
        // [GIVEN] Sales invoice line with reverse charge has been created
        LibrarySalesAdvancesCZZ.CreateSalesInvoice(
            SalesHeader, SalesLine, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", SalesAdvLetterHeaderCZZ."Posting Date",
            SalesAdvLetterLineCZZ1."VAT Bus. Posting Group", SalesAdvLetterLineCZZ1."VAT Prod. Posting Group", '', 0,
            true, SalesAdvLetterLineCZZ1."Amount Including VAT");

        // [GIVEN] First line with reverse charge has been linked to sales invoice
        LibrarySalesAdvancesCZZ.LinkSalesAdvanceLetterToDocument(
            SalesAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Sales Invoice", SalesHeader."No.",
            SalesAdvLetterHeaderCZZ."Amount Including VAT", SalesAdvLetterHeaderCZZ."Amount Including VAT (LCY)");

        // [WHEN] Post sales invoice
        PostedDocumentNo := PostSalesDocument(SalesHeader);

        // [THEN] VAT entries of sales invoice will exist
        VATEntry.Reset();
        VATEntry.SetRange("Document No.", PostedDocumentNo);
        VATEntry.SetRange("Posting Date", SalesHeader."Posting Date");
        VATEntry.SetRange("Advance Letter No. CZZ", '');
        Assert.RecordIsNotEmpty(VATEntry);

        // [THEN] VAT entries of advance letter won't exist
        VATEntry.SetRange("Advance Letter No. CZZ", SalesAdvLetterHeaderCZZ."No.");
        Assert.RecordIsEmpty(VATEntry);

        // [THEN] Sum of base and VAT amounts in VAT entries won't be zero
        VATEntry.SetRange("Advance Letter No. CZZ");
        VATEntry.CalcSums(Base, Amount);
        Assert.AreNotEqual(0, VATEntry.Base, 'The sum of base amount in VAT Entries mustn''t be zero.');

        // [THEN] Sales advance letter entry of "VAT Usage" type with reverse charge will be created
        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Usage");
        SalesAdvLetterEntryCZZ.SetRange("VAT Calculation Type", SalesAdvLetterEntryCZZ."VAT Calculation Type"::"Reverse Charge VAT");
        SalesAdvLetterEntryCZZ.SetRange("Auxiliary Entry", true);
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ);

        // [THEN] Sales advance letter entry of "VAT Usage" type with normal VAT won't be created
        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Usage");
        SalesAdvLetterEntryCZZ.SetRange("VAT Calculation Type", SalesAdvLetterEntryCZZ."VAT Calculation Type"::"Normal VAT");
        Assert.RecordIsEmpty(SalesAdvLetterEntryCZZ);
    end;

    [Test]
    procedure LinkSalesAdvLetterWithNormalVATAndReverseChargeToInvoice3()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ1: Record "Sales Adv. Letter Line CZZ";
        SalesAdvLetterLineCZZ2: Record "Sales Adv. Letter Line CZZ";
        VATEntry: Record "VAT Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        PostedDocumentNo: Code[20];
        VATPaymentAmount, VATPaymentAmountLCY : Decimal;
    begin
        // [SCENARIO] Link sales advance letter with normal VAT and reverse charge to sales invoice with normal VAT and higher amount than the advance letter
        Initialize();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with reverse charge has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ1);

        // [GIVEN] Sales advance letter line with normal VAT has been created
        LibrarySalesAdvancesCZZ.FindVATPostingSetup(VATPostingSetup);
        LibrarySalesAdvancesCZZ.CreateSalesAdvLetterLine(
            SalesAdvLetterLineCZZ2, SalesAdvLetterHeaderCZZ,
            VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Sales advance letter has been released
        ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterHeaderCZZ."Amount Including VAT");

        // [GIVEN] Sales invoice has been created
        // [GIVEN] Sales invoice line with normal VAT has been created
        LibrarySalesAdvancesCZZ.CreateSalesInvoice(
            SalesHeader, SalesLine, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", SalesAdvLetterHeaderCZZ."Posting Date",
            SalesAdvLetterLineCZZ2."VAT Bus. Posting Group", SalesAdvLetterLineCZZ2."VAT Prod. Posting Group", '', 0,
            true, SalesAdvLetterLineCZZ2."Amount Including VAT" + (SalesAdvLetterLineCZZ1."Amount Including VAT" / 2));

        // [GIVEN] First line with normal VAT has been linked to sales invoice
        LibrarySalesAdvancesCZZ.LinkSalesAdvanceLetterToDocument(
            SalesAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Sales Invoice", SalesHeader."No.",
            SalesAdvLetterHeaderCZZ."Amount Including VAT", SalesAdvLetterHeaderCZZ."Amount Including VAT (LCY)");

        // [WHEN] Post sales invoice
        PostedDocumentNo := PostSalesDocument(SalesHeader);

        // [THEN] Sales advance letter entry of "VAT Usage" type will have amount equal to the amount of "VAT Payment" entry
        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        SalesAdvLetterEntryCZZ.SetRange("VAT Calculation Type", SalesAdvLetterLineCZZ2."VAT Calculation Type");
        SalesAdvLetterEntryCZZ.CalcSums(Amount, "Amount (LCY)");
        VATPaymentAmount := SalesAdvLetterEntryCZZ.Amount;
        VATPaymentAmountLCY := SalesAdvLetterEntryCZZ."Amount (LCY)";

        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Usage");
        SalesAdvLetterEntryCZZ.SetRange("VAT Calculation Type", SalesAdvLetterLineCZZ2."VAT Calculation Type");
        SalesAdvLetterEntryCZZ.FindFirst();
        Assert.AreEqual(VATPaymentAmount, -SalesAdvLetterEntryCZZ.Amount, 'The amount of VAT Payment entry must be equal to the amount of VAT Usage entry.');
        Assert.AreEqual(VATPaymentAmountLCY, -SalesAdvLetterEntryCZZ."Amount (LCY)", 'The amount (LCY) of VAT Payment entry must be equal to the amount (LCY) of VAT Usage entry.');

        // [THEN] Sum of base and VAT amounts in VAT entries won't be zero
        VATEntry.Reset();
        VATEntry.SetRange("Document No.", PostedDocumentNo);
        VATEntry.SetRange("Posting Date", SalesHeader."Posting Date");
        VATEntry.CalcSums(Base, Amount);
        Assert.AreNotEqual(0, VATEntry.Base, 'The sum of base amount in VAT Entries mustn''t be zero.');
        Assert.AreNotEqual(0, VATEntry.Amount, 'The sum of VAT amount in VAT Entries mustn''t be zero.');
    end;

    [Test]
    procedure LinkSalesAdvLetterWithNormalVATAndReverseChargeToInvoice4()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ1: Record "Sales Adv. Letter Line CZZ";
        SalesAdvLetterLineCZZ2: Record "Sales Adv. Letter Line CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        // [SCENARIO] Link sales advance letter with normal VAT and reverse charge to sales invoice with reverse charge and higher amount than the advance letter
        Initialize();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with reverse charge has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ1);

        // [GIVEN] Sales advance letter line with normal VAT has been created
        LibrarySalesAdvancesCZZ.FindVATPostingSetup(VATPostingSetup);
        LibrarySalesAdvancesCZZ.CreateSalesAdvLetterLine(
            SalesAdvLetterLineCZZ2, SalesAdvLetterHeaderCZZ,
            VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Sales advance letter has been released
        ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterHeaderCZZ."Amount Including VAT");

        // [GIVEN] Sales invoice has been created
        // [GIVEN] Sales invoice line with reverse charge has been created
        LibrarySalesAdvancesCZZ.CreateSalesInvoice(
            SalesHeader, SalesLine, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", SalesAdvLetterHeaderCZZ."Posting Date",
            SalesAdvLetterLineCZZ1."VAT Bus. Posting Group", SalesAdvLetterLineCZZ1."VAT Prod. Posting Group", '', 0,
            true, SalesAdvLetterLineCZZ1."Amount Including VAT" + Round(SalesAdvLetterLineCZZ2."Amount Including VAT" / 2));

        // [GIVEN] First line with reverse charge has been linked to sales invoice
        LibrarySalesAdvancesCZZ.LinkSalesAdvanceLetterToDocument(
            SalesAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Sales Invoice", SalesHeader."No.",
            SalesAdvLetterHeaderCZZ."Amount Including VAT", SalesAdvLetterHeaderCZZ."Amount Including VAT (LCY)");

        // [WHEN] Post sales invoice
        PostSalesDocument(SalesHeader);

        // [THEN] Sales advance letter entry of "VAT Usage" type will have amount equal to part of the amount of "VAT Payment" entry with normal VAT
        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Usage");
        SalesAdvLetterEntryCZZ.SetRange("VAT Calculation Type", SalesAdvLetterLineCZZ2."VAT Calculation Type");
        SalesAdvLetterEntryCZZ.FindFirst();
        Assert.AreEqual(Round(SalesAdvLetterLineCZZ2."Amount Including VAT" / 2), SalesAdvLetterEntryCZZ.Amount, 'The amount of VAT Payment entry must be equal to the amount of VAT Usage entry.');

        // [THEN] Sales advance letter entry of "VAT Usage" type will have amount equal to the amount of "VAT Payment" entry with reverse charge
        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Usage");
        SalesAdvLetterEntryCZZ.SetRange("VAT Calculation Type", SalesAdvLetterLineCZZ1."VAT Calculation Type");
        SalesAdvLetterEntryCZZ.SetRange("Auxiliary Entry", true);
        SalesAdvLetterEntryCZZ.SetRange("VAT Entry No.", 0);
        SalesAdvLetterEntryCZZ.FindFirst();
        Assert.AreEqual(SalesAdvLetterLineCZZ1."Amount Including VAT", SalesAdvLetterEntryCZZ.Amount, 'The amount of VAT Payment entry must be equal to the amount of VAT Usage entry.');
    end;

    [Test]
    procedure LinkSalesAdvLetterWithNormalVATAndReverseChargeToInvoice5()
    var
        GLAccount: Record "G/L Account";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ1: Record "Sales Adv. Letter Line CZZ";
        SalesAdvLetterLineCZZ2: Record "Sales Adv. Letter Line CZZ";
        VATEntry: Record "VAT Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Link sales advance letter with normal VAT and reverse charge to sales invoice with normal VAT and reverse charge and lower amount than the advance letter
        Initialize();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with reverse charge has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ1);

        // [GIVEN] Sales advance letter line with normal VAT has been created
        LibrarySalesAdvancesCZZ.FindVATPostingSetup(VATPostingSetup);
        LibrarySalesAdvancesCZZ.CreateSalesAdvLetterLine(
            SalesAdvLetterLineCZZ2, SalesAdvLetterHeaderCZZ,
            VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Sales advance letter has been released
        ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterHeaderCZZ."Amount Including VAT");

        // [GIVEN] Sales invoice has been created
        // [GIVEN] First sales invoice line with reverse charge has been created
        LibrarySalesAdvancesCZZ.CreateSalesInvoice(
            SalesHeader, SalesLine, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", SalesAdvLetterHeaderCZZ."Posting Date",
            SalesAdvLetterLineCZZ1."VAT Bus. Posting Group", SalesAdvLetterLineCZZ1."VAT Prod. Posting Group", '', 0,
            true, SalesAdvLetterLineCZZ1."Amount Including VAT" / 2);

        // [GIVEN] Second sales invoice line with normal VAT has been created
        LibrarySalesAdvancesCZZ.CreateGLAccount(GLAccount);
        GLAccount.Validate("VAT Bus. Posting Group", SalesAdvLetterLineCZZ2."VAT Bus. Posting Group");
        GLAccount.Validate("VAT Prod. Posting Group", SalesAdvLetterLineCZZ2."VAT Prod. Posting Group");
        GLAccount.Modify(true);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::"G/L Account", GLAccount."No.", 1);
        SalesLine.Validate("Unit Price", SalesAdvLetterLineCZZ2."Amount Including VAT" / 2);
        SalesLine.Modify(true);

        // [GIVEN] First line with reverse charge has been linked to sales invoice
        LibrarySalesAdvancesCZZ.LinkSalesAdvanceLetterToDocument(
            SalesAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Sales Invoice", SalesHeader."No.",
            SalesAdvLetterHeaderCZZ."Amount Including VAT", SalesAdvLetterHeaderCZZ."Amount Including VAT (LCY)");

        // [WHEN] Post sales invoice
        PostedDocumentNo := PostSalesDocument(SalesHeader);

        // [THEN] Sum of base and VAT amounts in VAT entries of invoice won't be zero
        VATEntry.Reset();
        VATEntry.SetRange("Document No.", PostedDocumentNo);
        VATEntry.SetRange("Posting Date", SalesHeader."Posting Date");
        VATEntry.CalcSums(Base, Amount);
        Assert.AreNotEqual(0, VATEntry.Base, 'The sum of base amount in VAT Entries mustn''t be zero.');

        // [THEN] Sum of base and VAT amounts in VAT entries with reverse charge VAT won't be zero
        VATEntry.SetRange("VAT Calculation Type", SalesAdvLetterLineCZZ1."VAT Calculation Type"::"Reverse Charge VAT");
        VATEntry.CalcSums(Base, Amount);
        Assert.AreNotEqual(0, VATEntry.Base, 'The sum of base amount in VAT Entries mustn''t be zero.');

        // [THEN] Sum of base and VAT amounts in VAT entries with normal VAT will be zero
        VATEntry.SetRange("VAT Calculation Type", SalesAdvLetterLineCZZ1."VAT Calculation Type"::"Normal VAT");
        VATEntry.CalcSums(Base, Amount);
        Assert.AreEqual(0, VATEntry.Base, 'The sum of base amount in VAT Entries must be zero.');
        Assert.AreEqual(0, VATEntry.Amount, 'The sum of VAT amount in VAT Entries must be zero.');
    end;

    local procedure CreateSalesAdvLetter(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; VATPostingSetup: Record "VAT Posting Setup"; VendorNo: Code[20])
    var
        Customer: Record Customer;
    begin
        if VendorNo = '' then begin
            LibrarySalesAdvancesCZZ.CreateCustomer(Customer);
            Customer.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
            Customer.Modify(true);
            VendorNo := Customer."No.";
        end;

        LibrarySalesAdvancesCZZ.CreateSalesAdvLetterHeader(SalesAdvLetterHeaderCZZ, AdvanceLetterTemplateCZZ.Code, VendorNo, '');
        LibrarySalesAdvancesCZZ.CreateSalesAdvLetterLine(SalesAdvLetterLineCZZ, SalesAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));
    end;

    local procedure CreateSalesAdvLetter(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; VATPostingSetup: Record "VAT Posting Setup")
    begin
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ, VATPostingSetup, '');
    end;

    local procedure CreateSalesAdvLetter(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ")
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        LibrarySalesAdvancesCZZ.FindVATPostingSetupEU(VATPostingSetup);
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ, VATPostingSetup, '');
    end;

    local procedure CreateAndPostPaymentSalesAdvLetter(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; Amount: Decimal; ExchangeRate: Decimal; PostingDate: Date)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        LibrarySalesAdvancesCZZ.CreateSalesAdvancePayment(
            GenJournalLine, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", Amount, SalesAdvLetterHeaderCZZ."Currency Code",
            SalesAdvLetterHeaderCZZ."No.", ExchangeRate, PostingDate);
        LibrarySalesAdvancesCZZ.PostSalesAdvancePayment(GenJournalLine);
    end;

    local procedure CreateAndPostPaymentSalesAdvLetter(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; Amount: Decimal)
    begin
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, Amount, 0, 0D);
    end;

    local procedure ReleaseSalesAdvLetter(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);
    end;

    local procedure PostSalesDocument(var SalesHeader: Record "Sales Header"): Code[20]
    begin
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure FindLastPaymentAdvanceLetterEntry(AdvanceLetterNo: Code[20]; var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    begin
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", AdvanceLetterNo);
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Payment);
        SalesAdvLetterEntryCZZ.FindLast();
    end;
}
