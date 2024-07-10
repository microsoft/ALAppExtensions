codeunit 148127 "Purch. Adv. Pmt.Rev.Charge CZZ"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Advance Payments] [Purchase] [Feverse Charge]
        isInitialized := false;
    end;

    var
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        GeneralLedgerSetup: Record "General Ledger Setup";
        Assert: Codeunit Assert;
        LibraryDialogHandler: Codeunit "Library - Dialog Handler";
        LibraryPurchAdvancesCZZ: Codeunit "Library - Purch. Advances CZZ";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        isInitialized: Boolean;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Purch. Adv. Pmt.Rev.Charge CZZ");
        LibraryRandom.Init();
        LibraryVariableStorage.Clear();
        LibraryDialogHandler.ClearVariableStorage();
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Purch. Adv. Pmt.Rev.Charge CZZ");

        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."VAT Reporting Date Usage" := GeneralLedgerSetup."VAT Reporting Date Usage"::Enabled;
        GeneralLedgerSetup."Def. Orig. Doc. VAT Date CZL" := GeneralLedgerSetup."Def. Orig. Doc. VAT Date CZL"::"VAT Date";
        GeneralLedgerSetup."Max. VAT Difference Allowed" := 0.5;
        GeneralLedgerSetup.Modify();

        LibraryPurchAdvancesCZZ.CreatePurchAdvanceLetterTemplate(AdvanceLetterTemplateCZZ);
        AdvanceLetterTemplateCZZ."Post VAT Doc. for Rev. Charge" := false;
        AdvanceLetterTemplateCZZ.Modify();

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Purch. Adv. Pmt.Rev.Charge CZZ");
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure PurchAdvLetterWithReverseCharge()
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
    begin
        // [SCENARIO] VAT document of purchase advance letter with reverse charge
        Initialize();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with reverse charge has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [WHEN] Post payment VAT
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [THEN] Purchase advance letter entry of "VAT Payment" type will be created
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        // [THEN] VAT entry won't be created for the purchase advance letter entry with reverse charge
        PurchAdvLetterEntryCZZ.FindFirst();
        Assert.AreEqual(0, PurchAdvLetterEntryCZZ."VAT Entry No.", 'VAT entry mustn''t be created.');

        // [THEN] Created purchase advance letter entry will be marked as auxiliary
        Assert.AreEqual(true, PurchAdvLetterEntryCZZ."Auxiliary Entry", 'Auxiliary entry must be true.');

        // [THEN] The document no. will be equal to the advance letter no.
        Assert.AreEqual(PurchAdvLetterHeaderCZZ."No.", PurchAdvLetterEntryCZZ."Document No.", 'Document No. must be equal to advance letter no.');
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure LinkPurchAdvLetterWithReverseChargeToInvoice()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        VATEntry: Record "VAT Entry";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Link purchase advance letter with reverse charge to purchase invoice
        Initialize();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with reverse charge has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase invoice has been created
        // [GIVEN] Purchase invoice line with reverse charge has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Posting Date",
            PurchAdvLetterLineCZZ."VAT Bus. Posting Group", PurchAdvLetterLineCZZ."VAT Prod. Posting Group", '', 0,
            true, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Whole advance letter has been linked to purchase invoice
        LibraryPurchAdvancesCZZ.LinkPurchAdvanceLetterToDocument(
            PurchAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice", PurchaseHeader."No.",
            PurchAdvLetterLineCZZ."Amount Including VAT", PurchAdvLetterLineCZZ."Amount Including VAT (LCY)");

        // [WHEN] Post purchase invoice
        PostedDocumentNo := PostPurchaseDocument(PurchaseHeader);

        // [THEN] VAT entries of purchase invoice will exist
        VATEntry.Reset();
        VATEntry.SetRange("Document No.", PostedDocumentNo);
        VATEntry.SetRange("Posting Date", PurchaseHeader."Posting Date");
        VATEntry.SetRange("Advance Letter No. CZZ", '');
        Assert.RecordIsNotEmpty(VATEntry);

        // [THEN] VAT entries of advance letter won't be exist
        VATEntry.SetRange("Advance Letter No. CZZ", PurchAdvLetterHeaderCZZ."No.");
        Assert.RecordIsEmpty(VATEntry);

        // [THEN] Purchase advance letter entry of "Usage" type will be created
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.CalcSums("VAT Base Amount", "VAT Base Amount (LCY)");
        Assert.AreNearlyEqual(0, PurchAdvLetterEntryCZZ."VAT Base Amount", 1, 'The sum of VAT base amount must be zero.');
        Assert.AreNearlyEqual(0, PurchAdvLetterEntryCZZ."VAT Base Amount (LCY)", 1, 'The sum of VAT base amount (LCY) must be zero.');

        // [THEN] Purchase advance letter will be closed
        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterHeaderCZZ.TestField(Status, PurchAdvLetterHeaderCZZ.Status::Closed);
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure PurchAdvLetterWithNormalVAT()
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        // [SCENARIO] VAT document of purchase advance letter with normal VAT
        Initialize();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        LibraryPurchAdvancesCZZ.FindVATPostingSetup(VATPostingSetup);
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ, VATPostingSetup);

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [WHEN] Post payment VAT
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [THEN] Purchase advance letter entry of "VAT Payment" type will be created
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        // [THEN] Created purchase advance letter entry will have VAT amounts
        PurchAdvLetterEntryCZZ.FindFirst();
        Assert.AreNotEqual(0, PurchAdvLetterEntryCZZ."VAT Amount", 'VAT amount mustn''t be zero.');
        Assert.AreNotEqual(0, PurchAdvLetterEntryCZZ."VAT Amount (LCY)", 'VAT amount (LCY) mustn''t be zero.');
        Assert.AreNotEqual(0, PurchAdvLetterEntryCZZ."VAT Base Amount", 'VAT base amount mustn''t be zero.');
        Assert.AreNotEqual(0, PurchAdvLetterEntryCZZ."VAT Base Amount (LCY)", 'VAT base amount (LCY) mustn''t be zero.');
        Assert.AreNotEqual(0, PurchAdvLetterEntryCZZ."VAT Entry No.", 'VAT entry must be created.');

        // [THEN] Created purchase advance letter entry won't be marked as auxiliary
        Assert.AreEqual(false, PurchAdvLetterEntryCZZ."Auxiliary Entry", 'Auxiliary entry must be false.');

        // [THEN] The document no. won't be equal to the advance letter no.
        Assert.AreNotEqual(PurchAdvLetterHeaderCZZ."No.", PurchAdvLetterEntryCZZ."Document No.", 'Document No. mustn''t be equal to advance letter no.');
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure PurchAdvLetterWithNormalVATAndReverseCharge()
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        // [SCENARIO] VAT document of purchase advance letter with normal VAT and reverse charge
        Initialize();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with reverse charge has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter line with normal VAT has been created
        LibraryPurchAdvancesCZZ.FindVATPostingSetup(VATPostingSetup);
        LibraryPurchAdvancesCZZ.CreatePurchAdvLetterLine(
            PurchAdvLetterLineCZZ, PurchAdvLetterHeaderCZZ,
            VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ."Amount Including VAT");

        // [WHEN] Post payment VAT
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [THEN] Purchase advance letter entry of "VAT Payment" type with normal VAT will be created
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        PurchAdvLetterEntryCZZ.SetRange("VAT Calculation Type", PurchAdvLetterEntryCZZ."VAT Calculation Type"::"Normal VAT");
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        // [THEN] Created purchase advance letter entry with normal VAT will have VAT amounts
        PurchAdvLetterEntryCZZ.FindFirst();
        Assert.AreNotEqual(0, PurchAdvLetterEntryCZZ."VAT Amount", 'VAT amount mustn''t be zero.');
        Assert.AreNotEqual(0, PurchAdvLetterEntryCZZ."VAT Amount (LCY)", 'VAT amount (LCY) mustn''t be zero.');
        Assert.AreNotEqual(0, PurchAdvLetterEntryCZZ."VAT Base Amount", 'VAT base amount mustn''t be zero.');
        Assert.AreNotEqual(0, PurchAdvLetterEntryCZZ."VAT Base Amount (LCY)", 'VAT base amount (LCY) mustn''t be zero.');
        Assert.AreNotEqual(0, PurchAdvLetterEntryCZZ."VAT Entry No.", 'VAT entry must be created.');

        // [THEN] Purchase advance letter entry with normal VAT won't be marked as auxiliary
        Assert.AreEqual(false, PurchAdvLetterEntryCZZ."Auxiliary Entry", 'Auxiliary entry must be false.');

        // [THEN] The document no. won't be equal to the advance letter no.
        Assert.AreNotEqual(PurchAdvLetterHeaderCZZ."No.", PurchAdvLetterEntryCZZ."Document No.", 'Document No. mustn''t be equal to advance letter no.');

        // [THEN] Purchase advance letter entry of "VAT Payment" type with reverse charge will be created
        PurchAdvLetterEntryCZZ.SetRange("VAT Calculation Type", PurchAdvLetterEntryCZZ."VAT Calculation Type"::"Reverse Charge VAT");
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        // [THEN] VAT entry won't be created for the purchase advance letter entry with reverse charge
        PurchAdvLetterEntryCZZ.FindFirst();
        Assert.AreEqual(0, PurchAdvLetterEntryCZZ."VAT Entry No.", 'VAT entry mustn''t be created.');

        // [THEN] Purchase advance letter entry with reverse charge will be marked as auxiliary
        Assert.AreEqual(true, PurchAdvLetterEntryCZZ."Auxiliary Entry", 'Auxiliary entry must be true.');

        // [THEN] The document no. won't be equal to the advance letter no.
        Assert.AreNotEqual(PurchAdvLetterHeaderCZZ."No.", PurchAdvLetterEntryCZZ."Document No.", 'Document No. mustn''t be equal to advance letter no.');
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure PurchAdvLetterWithNormalVATAndReverseChargePartiallyPaid()
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
        PaymentAmount: Decimal;
        VATPaymentAmount: Decimal;
    begin
        // [SCENARIO] VAT document of purchase advance letter with normal VAT and reverse charge is partially paid                                                                                                                                                                                                                                                                                                                                                                                   
        Initialize();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with reverse charge has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter line with normal VAT has been created
        LibraryPurchAdvancesCZZ.FindVATPostingSetup(VATPostingSetup);
        LibraryPurchAdvancesCZZ.CreatePurchAdvLetterLine(
            PurchAdvLetterLineCZZ, PurchAdvLetterHeaderCZZ,
            VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in half by the general journal
        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ."Amount Including VAT" / 2);

        // [WHEN] Post payment VAT
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [THEN] Purchase advance letter entry of "VAT Payment" type with normal VAT will be created
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        PurchAdvLetterEntryCZZ.SetRange("VAT Calculation Type", PurchAdvLetterEntryCZZ."VAT Calculation Type"::"Normal VAT");
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        // [THEN] Created purchase advance letter entry with normal VAT will have VAT amounts
        PurchAdvLetterEntryCZZ.FindFirst();
        VATPaymentAmount := PurchAdvLetterEntryCZZ."Amount";
        Assert.AreNotEqual(0, PurchAdvLetterEntryCZZ."VAT Amount", 'VAT amount mustn''t be zero.');
        Assert.AreNotEqual(0, PurchAdvLetterEntryCZZ."VAT Amount (LCY)", 'VAT amount (LCY) mustn''t be zero.');
        Assert.AreNotEqual(0, PurchAdvLetterEntryCZZ."VAT Base Amount", 'VAT base amount mustn''t be zero.');
        Assert.AreNotEqual(0, PurchAdvLetterEntryCZZ."VAT Base Amount (LCY)", 'VAT base amount (LCY) mustn''t be zero.');
        Assert.AreNotEqual(0, PurchAdvLetterEntryCZZ."VAT Entry No.", 'VAT entry must be created.');

        // [THEN] Created purchase advance letter entry with normal VAT won't be marked as auxiliary
        Assert.AreEqual(false, PurchAdvLetterEntryCZZ."Auxiliary Entry", 'Auxiliary entry must be false.');

        // [THEN] The document no. won't be equal to the advance letter no.
        Assert.AreNotEqual(PurchAdvLetterHeaderCZZ."No.", PurchAdvLetterEntryCZZ."Document No.", 'Document No. mustn''t be equal to advance letter no.');

        // [THEN] Purchase advance letter entry of "VAT Payment" type with reverse charge will be created
        PurchAdvLetterEntryCZZ.SetRange("VAT Calculation Type", PurchAdvLetterEntryCZZ."VAT Calculation Type"::"Reverse Charge VAT");
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        // [THEN] VAT entry won't be created for the purchase advance letter entry with reverse charge
        PurchAdvLetterEntryCZZ.FindFirst();
        VATPaymentAmount += PurchAdvLetterEntryCZZ."Amount";
        Assert.AreEqual(0, PurchAdvLetterEntryCZZ."VAT Entry No.", 'VAT entry mustn''t be created.');

        // [THEN] Created purchase advance letter entry with reverse charge will be marked as auxiliary
        Assert.AreEqual(true, PurchAdvLetterEntryCZZ."Auxiliary Entry", 'Auxiliary entry must be true.');

        // [THEN] The document no. won't be equal to the advance letter no.
        Assert.AreNotEqual(PurchAdvLetterHeaderCZZ."No.", PurchAdvLetterEntryCZZ."Document No.", 'Document No. mustn''t be equal to advance letter no.');

        // [THEN] The sum of payment amount must be equal to the sum of VAT payment amount
        PurchAdvLetterEntryCZZ.Reset();
        FindLastPaymentAdvanceLetterEntry(PurchAdvLetterHeaderCZZ."No.", PurchAdvLetterEntryCZZ);
        PaymentAmount := PurchAdvLetterEntryCZZ."Amount";
        Assert.AreEqual(PaymentAmount, VATPaymentAmount, 'The sum of payment amount must be equal to the sum of VAT payment amount.');
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure LinkPurchAdvLetterWithNormalVATAndReverseChargeToInvoice1()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ1: Record "Purch. Adv. Letter Line CZZ";
        PurchAdvLetterLineCZZ2: Record "Purch. Adv. Letter Line CZZ";
        VATEntry: Record "VAT Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Link purchase advance letter with normal VAT and reverse charge to purchase invoice with normal VAT
        Initialize();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with reverse charge has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ1);

        // [GIVEN] Purchase advance letter line with normal VAT has been created
        LibraryPurchAdvancesCZZ.FindVATPostingSetup(VATPostingSetup); // normal VAT
        LibraryPurchAdvancesCZZ.CreatePurchAdvLetterLine(
            PurchAdvLetterLineCZZ2, PurchAdvLetterHeaderCZZ,
            VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ."Amount Including VAT");

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase invoice has been created
        // [GIVEN] Purchase invoice line with normal VAT has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Posting Date",
            PurchAdvLetterLineCZZ2."VAT Bus. Posting Group", PurchAdvLetterLineCZZ2."VAT Prod. Posting Group", '', 0,
            true, PurchAdvLetterLineCZZ2."Amount Including VAT");

        // [GIVEN] Second line with normal VAT has been linked to purchase invoice
        LibraryPurchAdvancesCZZ.LinkPurchAdvanceLetterToDocument(
            PurchAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice", PurchaseHeader."No.",
            PurchAdvLetterHeaderCZZ."Amount Including VAT", PurchAdvLetterHeaderCZZ."Amount Including VAT (LCY)");

        // [WHEN] Post purchase invoice
        PostedDocumentNo := PostPurchaseDocument(PurchaseHeader);

        // [THEN] VAT entries of purchase invoice will exist
        VATEntry.Reset();
        VATEntry.SetRange("Document No.", PostedDocumentNo);
        VATEntry.SetRange("Posting Date", PurchaseHeader."Posting Date");
        VATEntry.SetRange("Advance Letter No. CZZ", '');
        Assert.RecordIsNotEmpty(VATEntry);

        // [THEN] VAT entries of advance letter will exist
        VATEntry.SetRange("Advance Letter No. CZZ", PurchAdvLetterHeaderCZZ."No.");
        Assert.RecordIsNotEmpty(VATEntry);

        // [THEN] Sum of base and VAT amounts in VAT entries will be zero
        VATEntry.SetRange("Advance Letter No. CZZ");
        VATEntry.CalcSums(Base, Amount);
        Assert.AreEqual(0, VATEntry.Base, 'The sum of base amount in VAT Entries must be zero.');
        Assert.AreEqual(0, VATEntry.Amount, 'The sum of VAT amount in VAT Entries must be zero.');

        // [THEN] VAT entries will have the same VAT calculation type
        VATEntry.SetFilter("VAT Calculation Type", '<>%1', PurchAdvLetterLineCZZ2."VAT Calculation Type");
        Assert.RecordIsEmpty(VATEntry);
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure LinkPurchAdvLetterWithNormalVATAndReverseChargeToInvoice2()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ1: Record "Purch. Adv. Letter Line CZZ";
        PurchAdvLetterLineCZZ2: Record "Purch. Adv. Letter Line CZZ";
        VATEntry: Record "VAT Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Link purchase advance letter with normal VAT and reverse charge to purchase invoice with reverse charge
        Initialize();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with reverse charge has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ1);

        // [GIVEN] Purchase advance letter line with normal VAT has been created
        LibraryPurchAdvancesCZZ.FindVATPostingSetup(VATPostingSetup);
        LibraryPurchAdvancesCZZ.CreatePurchAdvLetterLine(
            PurchAdvLetterLineCZZ2, PurchAdvLetterHeaderCZZ,
            VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ."Amount Including VAT");

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase invoice has been created
        // [GIVEN] Purchase invoice line with reverse charge has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Posting Date",
            PurchAdvLetterLineCZZ1."VAT Bus. Posting Group", PurchAdvLetterLineCZZ1."VAT Prod. Posting Group", '', 0,
            true, PurchAdvLetterLineCZZ1."Amount Including VAT");

        // [GIVEN] First line with reverse charge has been linked to purchase invoice
        LibraryPurchAdvancesCZZ.LinkPurchAdvanceLetterToDocument(
            PurchAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice", PurchaseHeader."No.",
            PurchAdvLetterHeaderCZZ."Amount Including VAT", PurchAdvLetterHeaderCZZ."Amount Including VAT (LCY)");

        // [WHEN] Post purchase invoice
        PostedDocumentNo := PostPurchaseDocument(PurchaseHeader);

        // [THEN] VAT entries of purchase invoice will exist
        VATEntry.Reset();
        VATEntry.SetRange("Document No.", PostedDocumentNo);
        VATEntry.SetRange("Posting Date", PurchaseHeader."Posting Date");
        VATEntry.SetRange("Advance Letter No. CZZ", '');
        Assert.RecordIsNotEmpty(VATEntry);

        // [THEN] VAT entries of advance letter won't exist
        VATEntry.SetRange("Advance Letter No. CZZ", PurchAdvLetterHeaderCZZ."No.");
        Assert.RecordIsEmpty(VATEntry);

        // [THEN] Sum of base and VAT amounts in VAT entries won't be zero
        VATEntry.SetRange("Advance Letter No. CZZ");
        VATEntry.CalcSums(Base, Amount);
        Assert.AreNotEqual(0, VATEntry.Base, 'The sum of base amount in VAT Entries mustn''t be zero.');
        Assert.AreNotEqual(0, VATEntry.Amount, 'The sum of VAT amount in VAT Entries mustn''t be zero.');

        // [THEN] Purchase advance letter entry of "VAT Usage" type with reverse charge will be created
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Usage");
        PurchAdvLetterEntryCZZ.SetRange("VAT Calculation Type", PurchAdvLetterEntryCZZ."VAT Calculation Type"::"Reverse Charge VAT");
        PurchAdvLetterEntryCZZ.SetRange("Auxiliary Entry", true);
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        // [THEN] Purchase advance letter entry of "VAT Usage" type with normal VAT won't be created
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Usage");
        PurchAdvLetterEntryCZZ.SetRange("VAT Calculation Type", PurchAdvLetterEntryCZZ."VAT Calculation Type"::"Normal VAT");
        Assert.RecordIsEmpty(PurchAdvLetterEntryCZZ);
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure LinkPurchAdvLetterWithNormalVATAndReverseChargeToInvoice3()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ1: Record "Purch. Adv. Letter Line CZZ";
        PurchAdvLetterLineCZZ2: Record "Purch. Adv. Letter Line CZZ";
        VATEntry: Record "VAT Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        PostedDocumentNo: Code[20];
        VATPaymentAmount, VATPaymentAmountLCY : Decimal;
    begin
        // [SCENARIO] Link purchase advance letter with normal VAT and reverse charge to purchase invoice with normal VAT and higher amount than the advance letter
        Initialize();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with reverse charge has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ1);

        // [GIVEN] Purchase advance letter line with normal VAT has been created
        LibraryPurchAdvancesCZZ.FindVATPostingSetup(VATPostingSetup);
        LibraryPurchAdvancesCZZ.CreatePurchAdvLetterLine(
            PurchAdvLetterLineCZZ2, PurchAdvLetterHeaderCZZ,
            VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ."Amount Including VAT");

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase invoice has been created
        // [GIVEN] Purchase invoice line with normal VAT has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Posting Date",
            PurchAdvLetterLineCZZ2."VAT Bus. Posting Group", PurchAdvLetterLineCZZ2."VAT Prod. Posting Group", '', 0,
            true, PurchAdvLetterLineCZZ2."Amount Including VAT" + (PurchAdvLetterLineCZZ1."Amount Including VAT" / 2));

        // [GIVEN] First line with normal VAT has been linked to purchase invoice
        LibraryPurchAdvancesCZZ.LinkPurchAdvanceLetterToDocument(
            PurchAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice", PurchaseHeader."No.",
            PurchAdvLetterHeaderCZZ."Amount Including VAT", PurchAdvLetterHeaderCZZ."Amount Including VAT (LCY)");

        // [WHEN] Post purchase invoice
        PostedDocumentNo := PostPurchaseDocument(PurchaseHeader);

        // [THEN] Purchase advance letter entry of "VAT Usage" type will have amount equal to the amount of "VAT Payment" entry
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        PurchAdvLetterEntryCZZ.SetRange("VAT Calculation Type", PurchAdvLetterLineCZZ2."VAT Calculation Type");
        PurchAdvLetterEntryCZZ.CalcSums(Amount, "Amount (LCY)");
        VATPaymentAmount := PurchAdvLetterEntryCZZ.Amount;
        VATPaymentAmountLCY := PurchAdvLetterEntryCZZ."Amount (LCY)";

        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Usage");
        PurchAdvLetterEntryCZZ.SetRange("VAT Calculation Type", PurchAdvLetterLineCZZ2."VAT Calculation Type");
        PurchAdvLetterEntryCZZ.FindFirst();
        Assert.AreEqual(VATPaymentAmount, -PurchAdvLetterEntryCZZ.Amount, 'The amount of VAT Payment entry must be equal to the amount of VAT Usage entry.');
        Assert.AreEqual(VATPaymentAmountLCY, -PurchAdvLetterEntryCZZ."Amount (LCY)", 'The amount (LCY) of VAT Payment entry must be equal to the amount (LCY) of VAT Usage entry.');

        // [THEN] Sum of base and VAT amounts in VAT entries won't be zero
        VATEntry.Reset();
        VATEntry.SetRange("Document No.", PostedDocumentNo);
        VATEntry.SetRange("Posting Date", PurchaseHeader."Posting Date");
        VATEntry.CalcSums(Base, Amount);
        Assert.AreNotEqual(0, VATEntry.Base, 'The sum of base amount in VAT Entries mustn''t be zero.');
        Assert.AreNotEqual(0, VATEntry.Amount, 'The sum of VAT amount in VAT Entries mustn''t be zero.');
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure LinkPurchAdvLetterWithNormalVATAndReverseChargeToInvoice4()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ1: Record "Purch. Adv. Letter Line CZZ";
        PurchAdvLetterLineCZZ2: Record "Purch. Adv. Letter Line CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        // [SCENARIO] Link purchase advance letter with normal VAT and reverse charge to purchase invoice with reverse charge and higher amount than the advance letter
        Initialize();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with reverse charge has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ1);

        // [GIVEN] Purchase advance letter line with normal VAT has been created
        LibraryPurchAdvancesCZZ.FindVATPostingSetup(VATPostingSetup);
        LibraryPurchAdvancesCZZ.CreatePurchAdvLetterLine(
            PurchAdvLetterLineCZZ2, PurchAdvLetterHeaderCZZ,
            VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ."Amount Including VAT");

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase invoice has been created
        // [GIVEN] Purchase invoice line with reverse charge has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Posting Date",
            PurchAdvLetterLineCZZ1."VAT Bus. Posting Group", PurchAdvLetterLineCZZ1."VAT Prod. Posting Group", '', 0,
            true, PurchAdvLetterLineCZZ1."Amount Including VAT" + Round(PurchAdvLetterLineCZZ2."Amount Including VAT" / 2));

        // [GIVEN] First line with reverse charge has been linked to purchase invoice
        LibraryPurchAdvancesCZZ.LinkPurchAdvanceLetterToDocument(
            PurchAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice", PurchaseHeader."No.",
            PurchAdvLetterHeaderCZZ."Amount Including VAT", PurchAdvLetterHeaderCZZ."Amount Including VAT (LCY)");

        // [WHEN] Post purchase invoice
        PostPurchaseDocument(PurchaseHeader);

        // [THEN] Purchase advance letter entry of "VAT Usage" type will have amount equal to part of the amount of "VAT Payment" entry with normal VAT
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Usage");
        PurchAdvLetterEntryCZZ.SetRange("VAT Calculation Type", PurchAdvLetterLineCZZ2."VAT Calculation Type");
        PurchAdvLetterEntryCZZ.FindFirst();
        Assert.AreEqual(Round(PurchAdvLetterLineCZZ2."Amount Including VAT" / 2), -PurchAdvLetterEntryCZZ.Amount, 'The amount of VAT Payment entry must be equal to the amount of VAT Usage entry.');

        // [THEN] Purchase advance letter entry of "VAT Usage" type will have amount equal to the amount of "VAT Payment" entry with reverse charge
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Usage");
        PurchAdvLetterEntryCZZ.SetRange("VAT Calculation Type", PurchAdvLetterLineCZZ1."VAT Calculation Type");
        PurchAdvLetterEntryCZZ.SetRange("Auxiliary Entry", true);
        PurchAdvLetterEntryCZZ.SetRange("VAT Entry No.", 0);
        PurchAdvLetterEntryCZZ.FindFirst();
        Assert.AreEqual(PurchAdvLetterLineCZZ1."Amount Including VAT", -PurchAdvLetterEntryCZZ.Amount, 'The amount of VAT Payment entry must be equal to the amount of VAT Usage entry.');
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure LinkPurchAdvLetterWithNormalVATAndReverseChargeToInvoice5()
    var
        GLAccount: Record "G/L Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ1: Record "Purch. Adv. Letter Line CZZ";
        PurchAdvLetterLineCZZ2: Record "Purch. Adv. Letter Line CZZ";
        VATEntry: Record "VAT Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Link purchase advance letter with normal VAT and reverse charge to purchase invoice with normal VAT and reverse charge and lower amount than the advance letter
        Initialize();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with reverse charge has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ1);

        // [GIVEN] Purchase advance letter line with normal VAT has been created
        LibraryPurchAdvancesCZZ.FindVATPostingSetup(VATPostingSetup);
        LibraryPurchAdvancesCZZ.CreatePurchAdvLetterLine(
            PurchAdvLetterLineCZZ2, PurchAdvLetterHeaderCZZ,
            VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ."Amount Including VAT");

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase invoice has been created
        // [GIVEN] First purchase invoice line with reverse charge has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Posting Date",
            PurchAdvLetterLineCZZ1."VAT Bus. Posting Group", PurchAdvLetterLineCZZ1."VAT Prod. Posting Group", '', 0,
            true, PurchAdvLetterLineCZZ1."Amount Including VAT" / 2);

        // [GIVEN] Second purchase invoice line with normal VAT has been created
        LibraryPurchAdvancesCZZ.CreateGLAccount(GLAccount);
        GLAccount.Validate("VAT Bus. Posting Group", PurchAdvLetterLineCZZ2."VAT Bus. Posting Group");
        GLAccount.Validate("VAT Prod. Posting Group", PurchAdvLetterLineCZZ2."VAT Prod. Posting Group");
        GLAccount.Modify(true);

        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", GLAccount."No.", 1);
        PurchaseLine.Validate("Direct Unit Cost", PurchAdvLetterLineCZZ2."Amount Including VAT" / 2);
        PurchaseLine.Modify(true);

        // [GIVEN] First line with reverse charge has been linked to purchase invoice
        LibraryPurchAdvancesCZZ.LinkPurchAdvanceLetterToDocument(
            PurchAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice", PurchaseHeader."No.",
            PurchAdvLetterHeaderCZZ."Amount Including VAT", PurchAdvLetterHeaderCZZ."Amount Including VAT (LCY)");

        // [WHEN] Post purchase invoice
        PostedDocumentNo := PostPurchaseDocument(PurchaseHeader);

        // [THEN] Sum of base and VAT amounts in VAT entries of invoice won't be zero
        VATEntry.Reset();
        VATEntry.SetRange("Document No.", PostedDocumentNo);
        VATEntry.SetRange("Posting Date", PurchaseHeader."Posting Date");
        VATEntry.CalcSums(Base, Amount);
        Assert.AreNotEqual(0, VATEntry.Base, 'The sum of base amount in VAT Entries mustn''t be zero.');
        Assert.AreNotEqual(0, VATEntry.Amount, 'The sum of VAT amount in VAT Entries mustn''t be zero.');

        // [THEN] Sum of base and VAT amounts in VAT entries with reverse charge VAT won't be zero
        VATEntry.SetRange("VAT Calculation Type", PurchAdvLetterLineCZZ1."VAT Calculation Type"::"Reverse Charge VAT");
        VATEntry.CalcSums(Base, Amount);
        Assert.AreNotEqual(0, VATEntry.Base, 'The sum of base amount in VAT Entries mustn''t be zero.');
        Assert.AreNotEqual(0, VATEntry.Amount, 'The sum of VAT amount in VAT Entries mustn''t be zero.');

        // [THEN] Sum of base and VAT amounts in VAT entries with normal VAT will be zero
        VATEntry.SetRange("VAT Calculation Type", PurchAdvLetterLineCZZ1."VAT Calculation Type"::"Normal VAT");
        VATEntry.CalcSums(Base, Amount);
        Assert.AreEqual(0, VATEntry.Base, 'The sum of base amount in VAT Entries must be zero.');
        Assert.AreEqual(0, VATEntry.Amount, 'The sum of VAT amount in VAT Entries must be zero.');
    end;

    local procedure CreatePurchAdvLetter(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ"; VATPostingSetup: Record "VAT Posting Setup"; VendorNo: Code[20])
    var
        Vendor: Record Vendor;
    begin
        if VendorNo = '' then begin
            LibraryPurchAdvancesCZZ.CreateVendor(Vendor);
            Vendor.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
            Vendor.Modify(true);
            VendorNo := Vendor."No.";
        end;

        LibraryPurchAdvancesCZZ.CreatePurchAdvLetterHeader(PurchAdvLetterHeaderCZZ, AdvanceLetterTemplateCZZ.Code, VendorNo, '');
        LibraryPurchAdvancesCZZ.CreatePurchAdvLetterLine(PurchAdvLetterLineCZZ, PurchAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));
    end;

    local procedure CreatePurchAdvLetter(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ"; VATPostingSetup: Record "VAT Posting Setup")
    begin
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ, VATPostingSetup, '');
    end;

    local procedure CreatePurchAdvLetter(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ")
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        LibraryPurchAdvancesCZZ.FindVATPostingSetupEU(VATPostingSetup);
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ, VATPostingSetup, '');
    end;

    local procedure CreateAndPostPaymentPurchAdvLetter(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; Amount: Decimal; ExchangeRate: Decimal; PostingDate: Date)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        LibraryPurchAdvancesCZZ.CreatePurchAdvancePayment(
            GenJournalLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", Amount, PurchAdvLetterHeaderCZZ."Currency Code",
            PurchAdvLetterHeaderCZZ."No.", ExchangeRate, PostingDate);
        LibraryPurchAdvancesCZZ.PostPurchAdvancePayment(GenJournalLine);
    end;

    local procedure CreateAndPostPaymentPurchAdvLetter(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; Amount: Decimal)
    begin
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, Amount, 0, 0D);
    end;

    local procedure ReleasePurchAdvLetter(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
        LibraryPurchAdvancesCZZ.ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);
    end;

    local procedure PostPurchaseDocument(var PurchaseHeader: Record "Purchase Header"): Code[20]
    begin
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;

    local procedure FindLastPaymentAdvanceLetterEntry(AdvanceLetterNo: Code[20]; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    begin
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", AdvanceLetterNo);
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Payment);
        PurchAdvLetterEntryCZZ.FindLast();
    end;

    local procedure PostPurchAdvancePaymentVAT(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ");
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
    begin
        FindLastPaymentAdvanceLetterEntry(PurchAdvLetterHeaderCZZ."No.", PurchAdvLetterEntryCZZ);
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
