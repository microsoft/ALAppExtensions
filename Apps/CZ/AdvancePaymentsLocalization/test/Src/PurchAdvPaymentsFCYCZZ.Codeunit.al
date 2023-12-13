codeunit 148123 "Purch. Adv. Payments FCY CZZ"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Advance Payments] [Purchase] [Foreign Currency]
        isInitialized := false;
    end;

    var
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        GeneralLedgerSetup: Record "General Ledger Setup";
        Assert: Codeunit Assert;
        LibraryDialogHandler: Codeunit "Library - Dialog Handler";
        LibraryERM: Codeunit "Library - ERM";
        LibraryPurchAdvancesCZZ: Codeunit "Library - Purch. Advances CZZ";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        isInitialized: Boolean;
        CannotBeFoundErr: Label 'The field Advance Letter No. of table Gen. Journal Line contains a value (%1) that cannot be found in the related table (%2).', Comment = '%1 = advance letter no., %2 = table name';
        ExceededVATDifferenceErr: Label 'The VAT Differnce must not be more than %1.', Comment = '%1 = max VAT difference allowed';
        UnapplyAdvLetterQst: Label 'Unapply advance letter: %1\Continue?', Comment = '%1 = Advance Letters';
        CurrExchRateAdjustedMsg: Label 'One or more currency exchange rates have been adjusted.';

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
#if not CLEAN22
        ReplaceVATDateMgtCZL: Codeunit "Replace VAT Date Mgt. CZL";
#endif
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Purch. Adv. Payments FCY CZZ");
        LibraryRandom.Init();
        LibraryVariableStorage.Clear();
        LibraryDialogHandler.ClearVariableStorage();
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Purch. Adv. Payments FCY CZZ");

        GeneralLedgerSetup.Get();
#if not CLEAN22
        if not ReplaceVATDateMgtCZL.IsEnabled() then
            GeneralLedgerSetup."Use VAT Date CZL" := true
        else
#endif
        GeneralLedgerSetup."VAT Reporting Date Usage" := GeneralLedgerSetup."VAT Reporting Date Usage"::Enabled;
        GeneralLedgerSetup."Def. Orig. Doc. VAT Date CZL" := GeneralLedgerSetup."Def. Orig. Doc. VAT Date CZL"::"VAT Date";
        GeneralLedgerSetup."Max. VAT Difference Allowed" := 0.5;
        GeneralLedgerSetup.Modify();

        LibraryPurchAdvancesCZZ.CreatePurchAdvanceLetterTemplate(AdvanceLetterTemplateCZZ);
        UpdateCurrency();

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Purch. Adv. Payments FCY CZZ");
    end;

    [Test]
    procedure PurchAdvLetterInFCYPaidInLCY()
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // [SCENARIO] Create purchase advance letter in foreign currency and paid in local currency
        Initialize();

        // [GIVEN] Purchase advance letter in foreign currency has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [WHEN] Create payment journal
        asserterror LibraryPurchAdvancesCZZ.CreatePurchAdvancePayment(
            GenJournalLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterLineCZZ."Amount Including VAT", '',
            PurchAdvLetterHeaderCZZ."No.", 0, 0D);

        // [THEN] The error will occur
        Assert.ExpectedError(StrSubstNo(CannotBeFoundErr, PurchAdvLetterHeaderCZZ."No.", PurchAdvLetterHeaderCZZ.TableCaption()));
    end;

    [Test]
    procedure PurchAdvLetterInFCYPaidInFCY()
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
    begin
        // [SCENARIO] Create purchase advance letter in foreign currency and paid in foreign currency
        Initialize();

        // [GIVEN] Purchase advance letter in foreign currency has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [WHEN] Create and post payment advance letter
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [THEN] Purchase advance letter will be changed to status = "To Use"
        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterHeaderCZZ.TestField(Status, PurchAdvLetterHeaderCZZ.Status::"To Use");

        // [THEN] Purchase advance letter entry with entry type = Payment will be exist
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Payment);
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure LinkPurchAdvLetterInFCYToInvoiceInLCY()
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        TempAdvanceLetterApplication: Record "Advance Letter Application CZZ" temporary;
    begin
        // [SCENARIO] Create purchase advance letter in foreign currency and link to invoice in local currency
        Initialize();

        // [GIVEN] Purchase advance letter in foreign currency has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase invoice in local currency has been created
        // [GIVEN] Purchase invoice line has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Posting Date",
            PurchAdvLetterLineCZZ."VAT Bus. Posting Group", PurchAdvLetterLineCZZ."VAT Prod. Posting Group", '', 0,
            true, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [WHEN] Get list of advance letter available for linking
        AdvanceLetterApplicationCZZ.GetPossiblePurchAdvance(
            Enum::"Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice", PurchaseHeader."No.", PurchaseHeader."Pay-to Vendor No.",
            PurchaseHeader."Posting Date", PurchaseHeader."Currency Code", TempAdvanceLetterApplication);

        // [THEN] Purchase advance letter won't be available for linking
        TempAdvanceLetterApplication.SetRange("Advance Letter Type", Enum::"Advance Letter Type CZZ"::Purchase);
        TempAdvanceLetterApplication.SetRange("Advance Letter No.", PurchAdvLetterHeaderCZZ."No.");
        Assert.RecordIsEmpty(TempAdvanceLetterApplication);
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure LinkPurchAdvLetterInFCYToInvoiceInFCY()
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VATEntry: Record "VAT Entry";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Create purchase advance letter in foreign currency and link to invoice in foreign currency
        Initialize();

        // [GIVEN] Purchase advance letter in foreign currency has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase invoice in foreign currency has been created
        // [GIVEN] Purchase invoice line has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Posting Date",
            PurchAdvLetterLineCZZ."VAT Bus. Posting Group", PurchAdvLetterLineCZZ."VAT Prod. Posting Group", PurchAdvLetterHeaderCZZ."Currency Code", 0,
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

        // [THEN] VAT entries of advance letter will exist
        VATEntry.SetRange("Advance Letter No. CZZ", PurchAdvLetterHeaderCZZ."No.");
        Assert.RecordIsNotEmpty(VATEntry);

        // [THEN] Sum of base and VAT amounts in VAT entries will be zero
        VATEntry.SetRange("Advance Letter No. CZZ");
        VATEntry.CalcSums(Base, Amount);
        Assert.AreEqual(0, VATEntry.Base, 'The sum of base amount in VAT Entries must be zero.');
        Assert.AreEqual(0, VATEntry.Amount, 'The sum of VAT amount in VAT Entries must be zero.');

        // [THEN] Purchase advance letter will be closed
        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterHeaderCZZ.TestField(Status, PurchAdvLetterHeaderCZZ.Status::Closed);
    end;

    [Test]
    procedure ClosePurchAdvLetterInFCYWithoutPaymentVAT()
    var
        PurchAdvLetterEntryCZZ1: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        ClosingDate: Date;
    begin
        // [SCENARIO] Purchase advance letter in foreign currency without payment VAT can be closed
        Initialize();

        // [GIVEN] Purchase advance letter in foreign currency has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [WHEN] Close advance letter
        ClosingDate := WorkDate() + 1;
        LibraryPurchAdvancesCZZ.ClosePurchAdvanceLetter(
            PurchAdvLetterHeaderCZZ, ClosingDate, ClosingDate, ClosingDate, 0, PurchAdvLetterHeaderCZZ."No.");

        // [THEN] Purchase advance letter entry of "Close" type will be created and will have the same amount as entry of "Payment" type with opposite sign
        PurchAdvLetterEntryCZZ1.Reset();
        PurchAdvLetterEntryCZZ1.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ1.SetRange("Entry Type", PurchAdvLetterEntryCZZ1."Entry Type"::Payment);
        PurchAdvLetterEntryCZZ1.FindFirst();

        PurchAdvLetterEntryCZZ2.Reset();
        PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ2.SetRange("Entry Type", PurchAdvLetterEntryCZZ2."Entry Type"::Close);
        PurchAdvLetterEntryCZZ2.FindFirst();
        Assert.AreEqual(PurchAdvLetterEntryCZZ1."Entry No.", PurchAdvLetterEntryCZZ2."Related Entry", 'The entry must be related to entry of "Payment" type');
        Assert.AreEqual(-PurchAdvLetterEntryCZZ1.Amount, PurchAdvLetterEntryCZZ2.Amount, 'The entry must have the opposite amount as related entry.');
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure ClosePurchAdvLetterInFCYWithPaymentVAT()
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        ClosingDate: Date;
    begin
        // [SCENARIO] Purchase advance letter in foreign currency with payment VAT can be closed
        Initialize();

        // [GIVEN] Purchase advance letter in foreign currency has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [WHEN] Close advance letter
        ClosingDate := WorkDate() + 1;
        LibraryPurchAdvancesCZZ.ClosePurchAdvanceLetter(
            PurchAdvLetterHeaderCZZ, ClosingDate, ClosingDate, ClosingDate, 0, PurchAdvLetterHeaderCZZ."No.");

        // [THEN] Purchase advance letter entry of "Close" type will be created
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Close);
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        // [THEN] Purchase advance letter entry of "VAT Close" type will be created
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Close");
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        // [THEN] Purchase advance letter entry of "VAT Rate" type will be created
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Rate");
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        // [THEN] The sum of amounts of purchase advance letter entries will be zero
        PurchAdvLetterEntryCZZ.SetFilter("Entry Type", '<>%1', PurchAdvLetterEntryCZZ."Entry Type"::"Initial Entry");
        PurchAdvLetterEntryCZZ.CalcSums("Amount (LCY)");
        Assert.AreEqual(0, PurchAdvLetterEntryCZZ."Amount (LCY)", 'The sum of amounts must be zero.');
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure LinkPurchAdvLetterInFCYToInvoiceWithDiffCurrExchRate()
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VATEntry: Record "VAT Entry";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Create purchase advance letter in foreign currency and link to invoice with different currency exchange rate
        Initialize();

        // [GIVEN] Purchase advance letter in foreign currency has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase invoice in foreign currency has been created
        // [GIVEN] Purchase invoice line has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Posting Date" + 1,
            PurchAdvLetterLineCZZ."VAT Bus. Posting Group", PurchAdvLetterLineCZZ."VAT Prod. Posting Group", PurchAdvLetterHeaderCZZ."Currency Code", 0,
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

        // [THEN] VAT entries of advance letter will exist
        VATEntry.SetRange("Advance Letter No. CZZ", PurchAdvLetterHeaderCZZ."No.");
        Assert.RecordIsNotEmpty(VATEntry);

        // [THEN] Sum of base and VAT amounts in VAT entries will be zero
        VATEntry.SetRange("Advance Letter No. CZZ");
        VATEntry.CalcSums(Base, Amount);
        Assert.AreNearlyEqual(0, VATEntry.Base, 1, 'The sum of base amount in VAT entries must be zero.');
        Assert.AreNearlyEqual(0, VATEntry.Amount, 1, 'The sum of amount in VAT entries must be zero.');

        // [THEN] Purchase advance letter entry of "Usage" type will be created
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Usage);
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        // [THEN] Purchase advance letter entry of "VAT Usage" type will be created
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Usage");
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        // [THEN] Purchase advance letter entry of "VAT Rate" type will be created
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Rate");
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        // [THEN] Purchase advance letter will be closed
        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterHeaderCZZ.TestField(Status, PurchAdvLetterHeaderCZZ.Status::Closed);
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure LinkPurchAdvLetterInFCYToInvoiceWithDiffVATCurrExchRate()
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VATEntry: Record "VAT Entry";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Create purchase advance letter in foreign currency and link to invoice with different VAT currency exchange rate
        Initialize();

        // [GIVEN] Purchase advance letter in foreign currency has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase invoice in foreign currency has been created
        // [GIVEN] Purchase invoice line has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.",
            PurchAdvLetterHeaderCZZ."Posting Date" + 2, PurchAdvLetterHeaderCZZ."Posting Date" + 1,
            PurchAdvLetterLineCZZ."VAT Bus. Posting Group", PurchAdvLetterLineCZZ."VAT Prod. Posting Group",
            PurchAdvLetterHeaderCZZ."Currency Code", 0, true, PurchAdvLetterLineCZZ."Amount Including VAT");

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

        // [THEN] VAT entries of advance letter will exist
        VATEntry.SetRange("Advance Letter No. CZZ", PurchAdvLetterHeaderCZZ."No.");
        Assert.RecordIsNotEmpty(VATEntry);

        // [THEN] Sum of base and VAT amounts in VAT entries will be zero
        VATEntry.SetRange("Advance Letter No. CZZ");
        VATEntry.CalcSums(Base, Amount);
        Assert.AreNearlyEqual(0, VATEntry.Base, 1, 'The sum of base amount in VAT entries must be zero.');
        Assert.AreNearlyEqual(0, VATEntry.Amount, 1, 'The sum of amount in VAT entries must be zero.');

        // [THEN] Purchase advance letter entry of "Usage" type will be created
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Usage);
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        // [THEN] Purchase advance letter entry of "VAT Usage" type will be created
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Usage");
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        // [THEN] Purchase advance letter entry of "VAT Rate" type will be created
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Rate");
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        // [THEN] Purchase advance letter will be closed
        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterHeaderCZZ.TestField(Status, PurchAdvLetterHeaderCZZ.Status::Closed);
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentExceededVATCorrFCYHandler')]
    procedure VATCorrectionFCYOnPurchaseAdvancePaymentVATExceeded()
    var
        Currency: Record Currency;
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
    begin
        // [SCENARIO] Correction of the VAT amount on the payment VAT for the purchase advance in foreign currency with an exceeded VAT difference
        Initialize();
        FindForeignCurrency(Currency);

        // [GIVEN] Purchase advance letter in foreign currency has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [WHEN] Set VAT correction with an exceeded VAT difference on payment VAT
        FindLastPaymentAdvanceLetterEntry(PurchAdvLetterHeaderCZZ."No.", PurchAdvLetterEntryCZZ);
        LibraryVariableStorage.Enqueue(WorkDate()); // original document vat date
        LibraryVariableStorage.Enqueue(PurchAdvLetterEntryCZZ."Document No."); // external document no.
        LibraryVariableStorage.Enqueue(PurchAdvLetterLineCZZ."VAT Amount" + (Currency."Max. VAT Difference Allowed" * 2)); // VAT correction more than allowed
        LibraryPurchAdvancesCZZ.PostPurchAdvancePaymentVAT(PurchAdvLetterEntryCZZ);

        // [THEN] Error occurs
        Assert.ExpectedError(StrSubstNo(ExceededVATDifferenceErr, Currency."Max. VAT Difference Allowed"));
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentVATCorrFCYHandler')]
    procedure VATCorrectionFCYOnPurchaseAdvancePaymentVAT()
    var
        Currency: Record Currency;
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        CorrectedVATAmount: Decimal;
    begin
        // [SCENARIO] Correction of the VAT amount on the payment VAT for the purchase advance in foreign currency within VAT difference
        Initialize();
        FindForeignCurrency(Currency);

        // [GIVEN] Purchase advance letter in foreign currency has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [WHEN] Set VAT correction within VAT difference on payment VAT
        // CorrectedVATAmount := Round(PurchAdvLetterLineCZZ."VAT Amount",
        //     Currency."Amount Rounding Precision", Currency.VATRoundingDirection()) +
        //     GeneralLedgerSetup."Max. VAT Difference Allowed";
        CorrectedVATAmount := PurchAdvLetterLineCZZ."VAT Amount" + Currency."Max. VAT Difference Allowed";
        FindLastPaymentAdvanceLetterEntry(PurchAdvLetterHeaderCZZ."No.", PurchAdvLetterEntryCZZ);
        LibraryVariableStorage.Enqueue(WorkDate()); // original document vat date
        LibraryVariableStorage.Enqueue(PurchAdvLetterEntryCZZ."Document No."); // external document no.
        LibraryVariableStorage.Enqueue(CorrectedVATAmount); // VAT correction
        LibraryPurchAdvancesCZZ.PostPurchAdvancePaymentVAT(PurchAdvLetterEntryCZZ);

        // [THEN] Purchase advance letter entry of "VAT Payment" type will be created
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        // [THEN] VAT amount of the purchase advance letter entry will be equal to corrected VAT amount
        PurchAdvLetterEntryCZZ.FindFirst();
        Assert.AreEqual(
            CorrectedVATAmount,
            PurchAdvLetterEntryCZZ."VAT Amount", 'VAT amount must be equal to corrected VAT amount.');
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentVATCorrLCYHandler')]
    procedure VATCorrectionLCYOnPurchaseAdvancePaymentVAT()
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        CorrectedVATAmount: Decimal;
    begin
        // [SCENARIO] Correction of the VAT amount (LCY) on the payment VAT for the purchase advance in foreign currency within VAT difference
        Initialize();

        // [GIVEN] Purchase advance letter in foreign currency has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [WHEN] Set VAT correction within VAT difference on payment VAT
        CorrectedVATAmount := PurchAdvLetterLineCZZ."VAT Amount (LCY)" + GeneralLedgerSetup."Max. VAT Difference Allowed";
        FindLastPaymentAdvanceLetterEntry(PurchAdvLetterHeaderCZZ."No.", PurchAdvLetterEntryCZZ);
        LibraryVariableStorage.Enqueue(WorkDate()); // original document vat date
        LibraryVariableStorage.Enqueue(PurchAdvLetterEntryCZZ."Document No."); // external document no.
        LibraryVariableStorage.Enqueue(CorrectedVATAmount); // VAT correction
        LibraryPurchAdvancesCZZ.PostPurchAdvancePaymentVAT(PurchAdvLetterEntryCZZ);

        // [THEN] Purchase advance letter entry of "VAT Payment" type will be created
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        // [THEN] VAT amount (LCY) of the purchase advance letter entry will be equal to corrected VAT amount
        PurchAdvLetterEntryCZZ.FindFirst();
        Assert.AreEqual(
            CorrectedVATAmount,
            PurchAdvLetterEntryCZZ."VAT Amount (LCY)", 'VAT amount (LCY) must be equal to corrected VAT amount.');
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure ClosePurchAdvLetterInFCYPartiallyDeducted()
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ClosingDate: Date;
    begin
        // [SCENARIO] Close purchase advance letter in foreign currency and partially deducted by purchase invoice
        Initialize();

        // [GIVEN] Purchase advance letter in foreign currency has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase invoice in foreign currency and different exchange rate as advance letter has been created
        // [GIVEN] Purchase invoice line with a lower amount than advance letter line has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Posting Date" + 1,
            PurchAdvLetterLineCZZ."VAT Bus. Posting Group", PurchAdvLetterLineCZZ."VAT Prod. Posting Group",
            PurchAdvLetterHeaderCZZ."Currency Code", 0, true, PurchAdvLetterLineCZZ."Amount Including VAT" / 2);

        // [GIVEN] Whole advance letter has been linked to purchase invoice
        LibraryPurchAdvancesCZZ.LinkPurchAdvanceLetterToDocument(
            PurchAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice", PurchaseHeader."No.",
            PurchAdvLetterLineCZZ."Amount Including VAT", PurchAdvLetterLineCZZ."Amount Including VAT (LCY)");

        // [GIVEN] Purchase invoice has been posted
        PostPurchaseDocument(PurchaseHeader);

        // [WHEN] Close purchase advance letter
        ClosingDate := WorkDate() + 1;
        LibraryPurchAdvancesCZZ.ClosePurchAdvanceLetter(PurchAdvLetterHeaderCZZ, ClosingDate, ClosingDate, ClosingDate, 0, PurchAdvLetterHeaderCZZ."No.");

        // [THEN] Purchase advance letter entry of "Close" type will be created
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Close);
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        // [THEN] Purchase advance letter entry of "VAT Close" type will be created
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Close");
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        // [THEN] Purchase advance letter entry of "VAT Rate" type will be created
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Rate");
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        // [THEN] The sum of amounts of purchase advance letter entries will be zero
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetFilter("Entry Type", '<>%1', PurchAdvLetterEntryCZZ."Entry Type"::"Initial Entry");
        PurchAdvLetterEntryCZZ.CalcSums("Amount (LCY)");
        Assert.AreEqual(0, PurchAdvLetterEntryCZZ."Amount (LCY)", 'The sum of amounts must be zero.');
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure MultipleAdvancePaymentInFCY()
    var
        Currency: Record Currency;
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VATEntry: Record "VAT Entry";
        PostedDocumentNo: Code[20];
        FirstPaymentAmount: Decimal;
        SecondPaymentAmount: Decimal;
        ThirdPaymentAmount: Decimal;
    begin
        // [SCENARIO] The payment of the purchase advance letter in foreign currency can be split into several payments
        Initialize();
        FindForeignCurrency(Currency);

        // [GIVEN] Purchase advance letter in foreign currency has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been partially paid
        FirstPaymentAmount := Round(PurchAdvLetterLineCZZ."Amount Including VAT" / 3,
            Currency."Amount Rounding Precision", Currency.VATRoundingDirection());
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, FirstPaymentAmount);

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been partially paid
        SecondPaymentAmount := FirstPaymentAmount;
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, SecondPaymentAmount);

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been partially paid
        ThirdPaymentAmount := PurchAdvLetterLineCZZ."Amount Including VAT" - FirstPaymentAmount - SecondPaymentAmount;
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, ThirdPaymentAmount, 0, PurchAdvLetterHeaderCZZ."Posting Date" + 1);

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase invoice in foreign currency and different exchange rate as advance letter has been created
        // [GIVEN] Purchase invoice line has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Posting Date" + 5,
            PurchAdvLetterLineCZZ."VAT Bus. Posting Group", PurchAdvLetterLineCZZ."VAT Prod. Posting Group",
            PurchAdvLetterHeaderCZZ."Currency Code", 0, true, PurchAdvLetterLineCZZ."Amount Including VAT");

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

        // [THEN] VAT entries of advance letter will exist
        VATEntry.SetRange("Advance Letter No. CZZ", PurchAdvLetterHeaderCZZ."No.");
        Assert.RecordIsNotEmpty(VATEntry);

        // [THEN] Sum of base and VAT amounts of VAT entries will be zero
        VATEntry.SetRange("Advance Letter No. CZZ");
        VATEntry.CalcSums(Base, Amount);
        Assert.AreNearlyEqual(0, VATEntry.Base, 1, 'The sum of base amount in VAT entries must be zero.');
        Assert.AreNearlyEqual(0, VATEntry.Amount, 1, 'The sum of amount in VAT entries must be zero.');

        // [THEN] Three purchase advance letter entry of "VAT Payment" type will be created
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        Assert.RecordCount(PurchAdvLetterEntryCZZ, 3);

        // [THEN] Three purchase advance letter entry of "VAT Usage" type will be created
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Usage");
        Assert.RecordCount(PurchAdvLetterEntryCZZ, 3);

        // [THEN] Three purchase advance letter entry of "VAT Rate" type will be created
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Rate");
        Assert.RecordCount(PurchAdvLetterEntryCZZ, 3);

        // [THEN] Sum of VAT base and VAT amount of purchase advance letter entries will be zero
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.CalcSums("VAT Base Amount", "VAT Amount");
        Assert.AreEqual(0, PurchAdvLetterEntryCZZ."VAT Base Amount", 'The sum of VAT base amount in purchase adv. letter entries must be zero.');
        Assert.AreEqual(0, PurchAdvLetterEntryCZZ."VAT Amount", 'The sum of VAT amount in purchase adv. letter entries must be zero.');

        // [THEN] Purchase advance letter will be closed
        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterHeaderCZZ.TestField(Status, PurchAdvLetterHeaderCZZ.Status::Closed);
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure LinkMultipleAdvanceLettersInFCYToOneInvoice()
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ1: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterHeaderCZZ2: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ1: Record "Purch. Adv. Letter Line CZZ";
        PurchAdvLetterLineCZZ2: Record "Purch. Adv. Letter Line CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine1: Record "Purchase Line";
        PurchaseLine2: Record "Purchase Line";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Multiple advance letters in foreign currency can be linked to a one purchase invoice
        Initialize();

        // [GIVEN] First purchase advance letter in foreign currency has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ1, PurchAdvLetterLineCZZ1);

        // [GIVEN] First purchase advance letter has been released
        LibraryPurchAdvancesCZZ.ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ1);

        // [GIVEN] First purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ1, PurchAdvLetterLineCZZ1."Amount Including VAT");

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ1);

        // [GIVEN] Second purchase advance letter in foreign currency has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ2, PurchAdvLetterLineCZZ2, PurchAdvLetterHeaderCZZ1."Pay-to Vendor No.");

        // [GIVEN] Second purchase advance letter has been released
        LibraryPurchAdvancesCZZ.ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ2);

        // [GIVEN] Second purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ2, PurchAdvLetterLineCZZ2."Amount Including VAT");

        // [GIVEN] Second purchase VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ2);

        // [GIVEN] Purchase invoice in foreign currency and different exchange rate as advance letters has been created
        // [GIVEN] First purchase invoice line has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine1, PurchAdvLetterHeaderCZZ1."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ1."Posting Date" + 5,
            PurchAdvLetterLineCZZ1."VAT Bus. Posting Group", PurchAdvLetterLineCZZ1."VAT Prod. Posting Group",
            PurchAdvLetterHeaderCZZ1."Currency Code", 0, true, PurchAdvLetterLineCZZ1."Amount Including VAT");

        // [GIVEN] Second purchase invoice line has been created
        LibraryPurchase.CreatePurchaseLine(PurchaseLine2, PurchaseHeader, PurchaseLine2.Type::"G/L Account", PurchaseLine1."No.", 1);
        PurchaseLine2.Validate("Direct Unit Cost", PurchAdvLetterLineCZZ2."Amount Including VAT");
        PurchaseLine2.Modify(true);

        // [GIVEN] Whole first advance letter has been linked to purchase invoice
        LibraryPurchAdvancesCZZ.LinkPurchAdvanceLetterToDocument(
            PurchAdvLetterHeaderCZZ1, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice", PurchaseHeader."No.",
            PurchAdvLetterLineCZZ1."Amount Including VAT", PurchAdvLetterLineCZZ1."Amount Including VAT (LCY)");

        // [GIVEN] Whole second advance letter has been linked to purchase invoice
        LibraryPurchAdvancesCZZ.LinkPurchAdvanceLetterToDocument(
            PurchAdvLetterHeaderCZZ2, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice", PurchaseHeader."No.",
            PurchAdvLetterLineCZZ2."Amount Including VAT", PurchAdvLetterLineCZZ2."Amount Including VAT (LCY)");

        // [WHEN] Post purchase invoice
        PostedDocumentNo := PostPurchaseDocument(PurchaseHeader);

        // [THEN] Purchase advance letter entry of Usage type for the first purchase advance letter will be created
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ1."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Usage);
        PurchAdvLetterEntryCZZ.SetRange("Document No.", PostedDocumentNo);
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        // [THEN] Purchase advance letter entry of Usage type for the second purchase advance letter will be created
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ2."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Usage);
        PurchAdvLetterEntryCZZ.SetRange("Document No.", PostedDocumentNo);
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure UnlinkPurchAdvLetterInFCYFromPayment()
    var
        PurchAdvLetterEntryCZZ1: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        // [SCENARIO] Unlink purchase advance letter in foreign currency from payment
        Initialize();

        // [GIVEN] Purchase advance letter in foreign currency has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [WHEN] Unlink advance letter from payment
        FindLastPaymentAdvanceLetterEntry(PurchAdvLetterHeaderCZZ."No.", PurchAdvLetterEntryCZZ1);
        LibraryPurchAdvancesCZZ.UnlinkPurchAdvancePayment(PurchAdvLetterEntryCZZ1);

        // [THEN] Purchase advance letter entries will be created. One of the type "Payment" and the other of the "VAT Payment".
        PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ2.Find('+');
        Assert.AreEqual(PurchAdvLetterEntryCZZ2."Entry Type"::Payment, PurchAdvLetterEntryCZZ2."Entry Type", 'The purchase advance letter entry must be of type "Payment".');
        Assert.AreEqual(-PurchAdvLetterEntryCZZ1.Amount, PurchAdvLetterEntryCZZ2.Amount, 'The amount must have the opposite sign.');
        Assert.AreEqual(PurchAdvLetterEntryCZZ1."Entry No.", PurchAdvLetterEntryCZZ2."Related Entry", 'The entry must be related to entry of "Payment" type');

        PurchAdvLetterEntryCZZ2.Next(-1);
        Assert.AreEqual(PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Payment", PurchAdvLetterEntryCZZ2."Entry Type", 'The purchase advance letter entry must be of type "VAT Payment".');
        Assert.AreEqual(-PurchAdvLetterEntryCZZ1.Amount, PurchAdvLetterEntryCZZ2.Amount, 'The amount must have the opposite sign.');
        Assert.AreEqual(PurchAdvLetterEntryCZZ1."Entry No.", PurchAdvLetterEntryCZZ2."Related Entry", 'The entry must be related to entry of "Payment" type');

        // [THEN] Last opened vendor ledger entry won't be related to advance letter. The "Advance Letter No." field will be empty.
        VendorLedgerEntry.SetRange(Open, true);
        VendorLedgerEntry.FindLast();
        Assert.AreEqual('', VendorLedgerEntry."Advance Letter No. CZZ", 'The advance letter no. must be empty.');
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler,ConfirmHandler')]
    procedure UnlinkPurchAdvLetterInFCYFromPostedInvoice()
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchInvHeader: Record "Purch. Inv. Header";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Unlink purchase advance letter in foreign currency from posted invoice
        Initialize();

        // [GIVEN] Purchase advance letter in foreign currency has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase invoice in foreign currency has been created
        // [GIVEN] Purchase invoice line has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Posting Date",
            PurchAdvLetterLineCZZ."VAT Bus. Posting Group", PurchAdvLetterLineCZZ."VAT Prod. Posting Group",
            PurchAdvLetterHeaderCZZ."Currency Code", 0, true, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Whole advance letter has been linked to purchase invoice
        LibraryPurchAdvancesCZZ.LinkPurchAdvanceLetterToDocument(
            PurchAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice", PurchaseHeader."No.",
            PurchAdvLetterLineCZZ."Amount Including VAT", PurchAdvLetterLineCZZ."Amount Including VAT (LCY)");

        // [GIVEN] Purchase invoice has been posted
        PostedDocumentNo := PostPurchaseDocument(PurchaseHeader);

        // [WHEN] Unlink purchase advance letter from posted purchase invoice
        PurchInvHeader.Get(PostedDocumentNo);
        SetExpectedConfirm(StrSubstNo(UnapplyAdvLetterQst, PurchAdvLetterHeaderCZZ."No."), true);
        LibraryPurchAdvancesCZZ.UnapplyAdvanceLetter(PurchInvHeader);

        // [THEN] Purchase advance letter will be changed to status = "To Use"
        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterHeaderCZZ.TestField(Status, PurchAdvLetterHeaderCZZ.Status::"To Use");

        // [THEN] Sum amounts of purchase advance letter entries for posted purchase invoice must be zero
        PurchAdvLetterEntryCZZ.SetRange("Document No.", PurchInvHeader."No.");
        PurchAdvLetterEntryCZZ.CalcSums(Amount, "Amount (LCY)", "VAT Base Amount", "VAT Base Amount (LCY)", "VAT Amount", "VAT Amount (LCY)");
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);
        Assert.AreEqual(0, PurchAdvLetterEntryCZZ.Amount, 'The Amount must be zero.');
        Assert.AreEqual(0, PurchAdvLetterEntryCZZ."Amount (LCY)", 'The Amount LCY must be zero.');
        Assert.AreEqual(0, PurchAdvLetterEntryCZZ."VAT Base Amount", 'The VAT Base Amount must be zero.');
        Assert.AreEqual(0, PurchAdvLetterEntryCZZ."VAT Base Amount (LCY)", 'The VAT Base Amount LCY must be zero.');
        Assert.AreEqual(0, PurchAdvLetterEntryCZZ."VAT Amount", 'The VAT Amount must be zero.');
        Assert.AreEqual(0, PurchAdvLetterEntryCZZ."VAT Amount (LCY)", 'The VAT Amount LCY must be zero.');
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler,RequestPageAdjustExchangeRatesHandler,MessageHandler')]
    procedure AdjustCurrExchRateWithoutAffectedPaymentPurchAdvLetterInFCY()
    var
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        EntryCount: Integer;
    begin
        // [SCENARIO] Adjust currency exchange rate without affected payment purchase advance letter in foreign currency
        Initialize();

        // [GIVEN] Purchase advance letter in foreign currency has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Count of purchase advance letter entry has been saved
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        EntryCount := PurchAdvLetterEntryCZZ.Count();

        // [WHEN] Run adjust exchange rate
        Commit();
        SetExpectedMessage(CurrExchRateAdjustedMsg);
        RunAdjustExchangeRates(
            PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Currency Code",
            CalcDate('<-CY>', WorkDate()), CalcDate('<CY>', WorkDate()), CalcDate('<CY>', WorkDate()),
            PurchAdvLetterHeaderCZZ."No.", false, true, false, true, false);

        // [THEN] Detailed vendor ledger entry with of "Unrealized Gain" or "Unrealized Loss" type will be created
        VendorLedgerEntry.Reset();
        VendorLedgerEntry.SetRange("Vendor No.", PurchAdvLetterHeaderCZZ."Pay-to Vendor No.");
        VendorLedgerEntry.FindLast();
        DetailedVendorLedgEntry.SetCurrentKey("Vendor Ledger Entry No.");
        DetailedVendorLedgEntry.SetRange("Vendor Ledger Entry No.", VendorLedgerEntry."Entry No.");
        DetailedVendorLedgEntry.SetFilter("Entry Type", '%1|%2',
            DetailedVendorLedgEntry."Entry Type"::"Unrealized Gain",
            DetailedVendorLedgEntry."Entry Type"::"Unrealized Loss");
        Assert.RecordIsNotEmpty(DetailedVendorLedgEntry);

        // [THEN] Count of the purchase advance letter entries is the same as before adjust running
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        Assert.RecordCount(PurchAdvLetterEntryCZZ, EntryCount);
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler,RequestPageAdjustExchangeRatesHandler,MessageHandler,RequestPageAdjustAdvExchRatesHandler')]
    procedure AdjustCurrExchRateWithAffectedPaymentPurchAdvLetterInFCY()
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        AdjustedDate: Date;
    begin
        // [SCENARIO] Adjust currency exchange rate with affected payment purchase advance letter in foreign currency
        Initialize();

        // [GIVEN] Purchase advance letter in foreign currency has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Adjust exchange rate has been ran
        Commit();
        SetExpectedMessage(CurrExchRateAdjustedMsg);
        RunAdjustExchangeRates(
            PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Currency Code",
            CalcDate('<-CY>', WorkDate()), CalcDate('<CY>', WorkDate()), CalcDate('<CY>', WorkDate()),
            PurchAdvLetterHeaderCZZ."No.", false, true, false, true, false);

        // [WHEN] Run adjust adv. exch. rates
        Commit();
        AdjustedDate := CalcDate('<CY>', WorkDate());
        RunAdjustAdvExchRates(
            PurchAdvLetterHeaderCZZ."No.", AdjustedDate, PurchAdvLetterHeaderCZZ."No.", false, true);

        // [THEN] Purchase advance letter entries of type "VAT Adjustment" will be created
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Adjustment");
        PurchAdvLetterEntryCZZ.SetRange("Posting Date", AdjustedDate);
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);
    end;

    local procedure UpdateCurrency()
    var
        Currency: Record Currency;
    begin
        FindForeignCurrency(Currency);
        Currency.Validate("Invoice Rounding Precision", 0.01);
        Currency.Validate("Max. VAT Difference Allowed", 0.5);
        Currency.Modify();

        LibraryERM.CreateExchangeRate(Currency.Code, WorkDate(), 1 / 25, 1 / 25);
        LibraryERM.CreateExchangeRate(Currency.Code, WorkDate() + 1, 1 / 25.5, 1 / 25.5);
        LibraryERM.CreateExchangeRate(Currency.Code, WorkDate() + 2, 1 / 26.2, 1 / 26.2);
        LibraryERM.CreateExchangeRate(Currency.Code, CalcDate('<CY>', WorkDate()), 1 / 27, 1 / 27);
    end;

    local procedure CreatePurchAdvLetter(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ"; VendorNo: Code[20])
    var
        Currency: Record Currency;
        VATPostingSetup: Record "VAT Posting Setup";
        Vendor: Record Vendor;
    begin
        LibraryPurchAdvancesCZZ.FindVATPostingSetup(VATPostingSetup);

        if VendorNo = '' then begin
            LibraryPurchAdvancesCZZ.CreateVendor(Vendor);
            Vendor.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
            Vendor.Modify(true);
            VendorNo := Vendor."No.";
        end;

        FindForeignCurrency(Currency);
        LibraryPurchAdvancesCZZ.CreatePurchAdvLetterHeader(PurchAdvLetterHeaderCZZ, AdvanceLetterTemplateCZZ.Code, VendorNo, Currency.Code);
        LibraryPurchAdvancesCZZ.CreatePurchAdvLetterLine(PurchAdvLetterLineCZZ, PurchAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));
    end;

    local procedure CreatePurchAdvLetter(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ")
    begin
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ, '');
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

    local procedure FindForeignCurrency(var Currency: Record Currency)
    begin
        Currency.SetFilter(Code, '<>%1', GeneralLedgerSetup."LCY Code");
        LibraryERM.FindCurrency(Currency);
    end;

    local procedure ReleasePurchAdvLetter(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
        LibraryPurchAdvancesCZZ.ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);
    end;

    local procedure PostGenJournalLine(var GenJournalLine: Record "Gen. Journal Line")
    begin
        Codeunit.Run(Codeunit::"Gen. Jnl.-Post Line", GenJournalLine);
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

    local procedure RunAdjustExchangeRates(VendorNo: Code[20]; CurrencyCode: Code[10]; StartDate: Date; EndDate: Date; PostingDate: Date; DocumentNo: Code[20]; AdjCust: Boolean; AdjVend: Boolean; AdjBank: Boolean; Post: Boolean; SkipAdvancePayments: Boolean)
    var
        Currency: Record Currency;
        XmlParameters: Text;
    begin
        LibraryVariableStorage.Enqueue(StartDate);
        LibraryVariableStorage.Enqueue(EndDate);
        LibraryVariableStorage.Enqueue(PostingDate);
        LibraryVariableStorage.Enqueue(DocumentNo);
        LibraryVariableStorage.Enqueue(AdjCust);
        LibraryVariableStorage.Enqueue(AdjVend);
        LibraryVariableStorage.Enqueue(AdjBank);
        LibraryVariableStorage.Enqueue(Post);
        LibraryVariableStorage.Enqueue(SkipAdvancePayments);
        LibraryVariableStorage.Enqueue(VendorNo);

        Currency.SetRange(Code, CurrencyCode);
        XmlParameters := Report.RunRequestPage(Report::"Adjust Exchange Rates CZL");
        LibraryReportDataset.RunReportAndLoad(Report::"Adjust Exchange Rates CZL", Currency, XmlParameters);
    end;

    local procedure RunAdjustAdvExchRates(PurchAdvLetterNo: Code[20]; AdjustToDate: Date; DocumentNo: Code[20]; AdjCust: Boolean; AdjVend: Boolean)
    begin
        LibraryVariableStorage.Enqueue(AdjustToDate);
        LibraryVariableStorage.Enqueue(DocumentNo);
        LibraryVariableStorage.Enqueue(AdjCust);
        LibraryVariableStorage.Enqueue(AdjVend);
        LibraryVariableStorage.Enqueue(PurchAdvLetterNo);
        Report.RunModal(Report::"Adjust Adv. Exch. Rates CZZ", true, false);
    end;

    local procedure SetExpectedConfirm(Question: Text; Reply: Boolean)
    begin
        LibraryDialogHandler.SetExpectedConfirm(Question, Reply);
    end;

    local procedure SetExpectedMessage(Message: Text)
    begin
        LibraryDialogHandler.SetExpectedMessage(Message);
    end;

    [RequestPageHandler]
    procedure RequestPageAdjustExchangeRatesHandler(var AdjustExchangeRatesCZL: TestRequestPage "Adjust Exchange Rates CZL")
    var
        FieldVariant: Variant;
    begin
        LibraryVariableStorage.Dequeue(FieldVariant);
        AdjustExchangeRatesCZL.StartingDate.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        AdjustExchangeRatesCZL.EndingDate.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        AdjustExchangeRatesCZL.PostingDateField.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        AdjustExchangeRatesCZL.DocumentNo.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        AdjustExchangeRatesCZL.AdjCustField.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        AdjustExchangeRatesCZL.AdjVendField.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        AdjustExchangeRatesCZL.AdjBankField.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        AdjustExchangeRatesCZL.PostField.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        AdjustExchangeRatesCZL.SkipAdvancePaymentsField.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        AdjustExchangeRatesCZL.Vendor.SetFilter("No.", FieldVariant);
        AdjustExchangeRatesCZL.OK().Invoke();
    end;

    [RequestPageHandler]
    procedure RequestPageAdjustAdvExchRatesHandler(var AdjustAdvExchRatesCZZ: TestRequestPage "Adjust Adv. Exch. Rates CZZ")
    var
        FieldVariant: Variant;
    begin
        LibraryVariableStorage.Dequeue(FieldVariant);
        AdjustAdvExchRatesCZZ.AdjustToDateField.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        AdjustAdvExchRatesCZZ.DocumentNoField.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        AdjustAdvExchRatesCZZ.AdjustCustomerField.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        AdjustAdvExchRatesCZZ.AdjustVendorField.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        AdjustAdvExchRatesCZZ."Purch. Adv. Letter Header CZZ".SetFilter("No.", FieldVariant);
        AdjustAdvExchRatesCZZ.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ModalVATDocumentHandler(var VATDocument: TestPage "VAT Document CZZ")
    begin
        VATDocument.OriginalDocumentVATDate.SetValue(LibraryVariableStorage.DequeueDate());
        VATDocument.ExternalDocumentNo.SetValue(LibraryVariableStorage.DequeueText());
        VATDocument.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ModalVATDocumentExceededVATCorrFCYHandler(var VATDocument: TestPage "VAT Document CZZ")
    begin
        VATDocument.OriginalDocumentVATDate.SetValue(LibraryVariableStorage.DequeueDate());
        VATDocument.ExternalDocumentNo.SetValue(LibraryVariableStorage.DequeueText());
        asserterror VATDocument.Lines."VAT Amount".SetValue(LibraryVariableStorage.DequeueDecimal());
        VATDocument.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ModalVATDocumentVATCorrFCYHandler(var VATDocument: TestPage "VAT Document CZZ")
    begin
        VATDocument.OriginalDocumentVATDate.SetValue(LibraryVariableStorage.DequeueDate());
        VATDocument.ExternalDocumentNo.SetValue(LibraryVariableStorage.DequeueText());
        VATDocument.Lines."VAT Amount".SetValue(LibraryVariableStorage.DequeueDecimal());
        VATDocument.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ModalVATDocumentVATCorrLCYHandler(var VATDocument: TestPage "VAT Document CZZ")
    begin
        VATDocument.OriginalDocumentVATDate.SetValue(LibraryVariableStorage.DequeueDate());
        VATDocument.ExternalDocumentNo.SetValue(LibraryVariableStorage.DequeueText());
        VATDocument.Lines."VAT Amount (ACY)".SetValue(LibraryVariableStorage.DequeueDecimal());
        VATDocument.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        LibraryDialogHandler.HandleConfirm(Question, Reply);
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
        LibraryDialogHandler.HandleMessage(Message);
    end;
}
