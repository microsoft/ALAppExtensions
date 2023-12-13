codeunit 148124 "Sales Adv. Payments FCY CZZ"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Advance Payments] [Sales] [Foreign Currency]
        isInitialized := false;
    end;

    var
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        GeneralLedgerSetup: Record "General Ledger Setup";
        Assert: Codeunit Assert;
        LibraryDialogHandler: Codeunit "Library - Dialog Handler";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySalesAdvancesCZZ: Codeunit "Library - Sales Advances CZZ";
        LibrarySales: Codeunit "Library - Sales";
        LibraryRandom: Codeunit "Library - Random";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        isInitialized: Boolean;
        CannotBeFoundErr: Label 'The field Advance Letter No. of table Gen. Journal Line contains a value (%1) that cannot be found in the related table (%2).', Comment = '%1 = advance letter no., %2 = table name';
        UnapplyAdvLetterQst: Label 'Unapply advance letter: %1\Continue?', Comment = '%1 = Advance Letters';
        CurrExchRateAdjustedMsg: Label 'One or more currency exchange rates have been adjusted.';

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
#if not CLEAN22
        ReplaceVATDateMgtCZL: Codeunit "Replace VAT Date Mgt. CZL";
#endif
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Sales Adv. Payments FCY CZZ");
        LibraryRandom.Init();
        LibraryVariableStorage.Clear();
        LibraryDialogHandler.ClearVariableStorage();
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Sales Adv. Payments FCY CZZ");

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

        LibrarySalesAdvancesCZZ.CreateSalesAdvanceLetterTemplate(AdvanceLetterTemplateCZZ);
        UpdateCurrency();

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Sales Adv. Payments FCY CZZ");
    end;

    [Test]
    procedure SalesAdvLetterInFCYPaidInLCY()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // [SCENARIO] Create sales advance letter in foreign currency and paid in local currency
        Initialize();

        // [GIVEN] Sales advance letter in foreign currency has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [WHEN] Create payment journal
        asserterror LibrarySalesAdvancesCZZ.CreateSalesAdvancePayment(
            GenJournalLine, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", SalesAdvLetterLineCZZ."Amount Including VAT", '',
            SalesAdvLetterHeaderCZZ."No.", 0);

        // [THEN] The error will occur
        Assert.ExpectedError(StrSubstNo(CannotBeFoundErr, SalesAdvLetterHeaderCZZ."No.", SalesAdvLetterHeaderCZZ.TableCaption()));
    end;

    [Test]
    procedure SalesAdvLetterInFCYPaidInFCY()
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
    begin
        // [SCENARIO] Create sales advance letter in foreign currency and paid in foreign currency
        Initialize();

        // [GIVEN] Sales advance letter in foreign currency has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [WHEN] Create and post payment advance letter
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

        // [THEN] Sales advance letter will be changed to status = "To Use"
        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterHeaderCZZ.TestField(Status, SalesAdvLetterHeaderCZZ.Status::"To Use");

        // [THEN] Sales advance letter entry with entry type = Payment will be exist
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Payment);
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ);
    end;

    [Test]
    procedure LinkSalesAdvLetterInFCYToInvoiceInLCY()
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TempAdvanceLetterApplication: Record "Advance Letter Application CZZ" temporary;
    begin
        // [SCENARIO] Create sales advance letter in foreign currency and link to invoice in local currency
        Initialize();

        // [GIVEN] Sales advance letter in foreign currency has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Sales invoice in local currency has been created
        // [GIVEN] Sales invoice line has been created
        LibrarySalesAdvancesCZZ.CreateSalesInvoice(
            SalesHeader, SalesLine, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", SalesAdvLetterHeaderCZZ."Posting Date",
            SalesAdvLetterLineCZZ."VAT Bus. Posting Group", SalesAdvLetterLineCZZ."VAT Prod. Posting Group", '', 0,
            true, SalesAdvLetterLineCZZ."Amount Including VAT");

        // [WHEN] Get list of advance letter available for linking
        AdvanceLetterApplicationCZZ.GetPossibleSalesAdvance(
            Enum::"Adv. Letter Usage Doc.Type CZZ"::"Sales Invoice", SalesHeader."No.", SalesHeader."Bill-to Customer No.",
            SalesHeader."Posting Date", SalesHeader."Currency Code", TempAdvanceLetterApplication);

        // [THEN] Sales advance letter won't be available for linking
        TempAdvanceLetterApplication.SetRange("Advance Letter Type", Enum::"Advance Letter Type CZZ"::Sales);
        TempAdvanceLetterApplication.SetRange("Advance Letter No.", SalesAdvLetterHeaderCZZ."No.");
        Assert.RecordIsEmpty(TempAdvanceLetterApplication);
    end;

    [Test]
    procedure LinkSalesAdvLetterInFCYToInvoiceInFCY()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        VATEntry: Record "VAT Entry";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Create sales advance letter in foreign currency and link to invoice in foreign currency
        Initialize();

        // [GIVEN] Sales advance letter in foreign currency has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Sales invoice in foreign currency has been created
        // [GIVEN] Sales invoice line has been created
        LibrarySalesAdvancesCZZ.CreateSalesInvoice(
            SalesHeader, SalesLine, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", SalesAdvLetterHeaderCZZ."Posting Date",
            SalesAdvLetterLineCZZ."VAT Bus. Posting Group", SalesAdvLetterLineCZZ."VAT Prod. Posting Group",
            SalesAdvLetterHeaderCZZ."Currency Code", 0, true, SalesAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Whole advance letter has been linked to Sales invoice
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

        // [THEN] VAT entries of advance letter will exist
        VATEntry.SetRange("Advance Letter No. CZZ", SalesAdvLetterHeaderCZZ."No.");
        Assert.RecordIsNotEmpty(VATEntry);

        // [THEN] Sum of base and VAT amounts in VAT entries will be zero
        VATEntry.SetRange("Advance Letter No. CZZ");
        VATEntry.CalcSums(Base, Amount);
        Assert.AreEqual(0, VATEntry.Base, 'The sum of base amount in VAT Entries must be zero.');
        Assert.AreEqual(0, VATEntry.Amount, 'The sum of VAT amount in VAT Entries must be zero.');

        // [THEN] Sales advance letter will be closed
        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterHeaderCZZ.TestField(Status, SalesAdvLetterHeaderCZZ.Status::Closed);
    end;

    [Test]
    procedure CloseSalesAdvLetterInFCYWithoutPaymentVAT()
    var
        SalesAdvLetterEntryCZZ1: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        ClosingDate: Date;
    begin
        // [SCENARIO] Sales advance letter in foreign currency without payment VAT can be closed
        Initialize();

        // [GIVEN] Sales advance letter in foreign currency without automatic post VAT document has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);
        SalesAdvLetterHeaderCZZ."Automatic Post VAT Document" := false;
        SalesAdvLetterHeaderCZZ.Modify();

        // [GIVEN] Sales advance letter has been released
        ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

        // [WHEN] Close advance letter
        ClosingDate := WorkDate() + 1;
        LibrarySalesAdvancesCZZ.CloseSalesAdvanceLetter(
            SalesAdvLetterHeaderCZZ, ClosingDate, ClosingDate, 0);

        // [THEN] Sales advance letter entry of "Close" type will be created and will have the same amount as entry of "Payment" type with opposite sign
        SalesAdvLetterEntryCZZ1.Reset();
        SalesAdvLetterEntryCZZ1.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ1.SetRange("Entry Type", SalesAdvLetterEntryCZZ1."Entry Type"::Payment);
        SalesAdvLetterEntryCZZ1.FindFirst();

        SalesAdvLetterEntryCZZ2.Reset();
        SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ2.SetRange("Entry Type", SalesAdvLetterEntryCZZ2."Entry Type"::Close);
        SalesAdvLetterEntryCZZ2.FindFirst();
        Assert.AreEqual(SalesAdvLetterEntryCZZ1."Entry No.", SalesAdvLetterEntryCZZ2."Related Entry", 'The entry must be related to entry of "Payment" type');
        Assert.AreEqual(-SalesAdvLetterEntryCZZ1.Amount, SalesAdvLetterEntryCZZ2.Amount, 'The entry must have the opposite amount as related entry.');
    end;

    [Test]
    procedure CloseSalesAdvLetterInFCYWithPaymentVAT()
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        ClosingDate: Date;
    begin
        // [SCENARIO] Sales advance letter in foreign currency with payment VAT can be closed
        Initialize();

        // [GIVEN] Sales advance letter in foreign currency has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

        // [WHEN] Close advance letter
        ClosingDate := WorkDate() + 1;
        LibrarySalesAdvancesCZZ.CloseSalesAdvanceLetter(
            SalesAdvLetterHeaderCZZ, ClosingDate, ClosingDate, 0);

        // [THEN] Sales advance letter entry of "Close" type will be created
        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Close);
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ);

        // [THEN] Sales advance letter entry of "VAT Close" type will be created
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Close");
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ);

        // [THEN] Sales advance letter entry of "VAT Rate" type will be created
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Rate");
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ);

        // [THEN] The sum of amounts of sales advance letter entries will be zero
        SalesAdvLetterEntryCZZ.SetFilter("Entry Type", '<>%1', SalesAdvLetterEntryCZZ."Entry Type"::"Initial Entry");
        SalesAdvLetterEntryCZZ.CalcSums("Amount (LCY)");
        Assert.AreEqual(0, SalesAdvLetterEntryCZZ."Amount (LCY)", 'The sum of amounts must be zero.');
    end;

    [Test]
    procedure LinkSalesAdvLetterInFCYToInvoiceWithDiffCurrExchRate()
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        VATEntry: Record "VAT Entry";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Create sales advance letter in foreign currency and link to invoice with different currency exchange rate
        Initialize();

        // [GIVEN] Sales advance letter in foreign currency has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Sales invoice in foreign currency has been created
        // [GIVEN] Sales invoice line has been created
        LibrarySalesAdvancesCZZ.CreateSalesInvoice(
            SalesHeader, SalesLine, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", SalesAdvLetterHeaderCZZ."Posting Date" + 1,
            SalesAdvLetterLineCZZ."VAT Bus. Posting Group", SalesAdvLetterLineCZZ."VAT Prod. Posting Group", SalesAdvLetterHeaderCZZ."Currency Code", 0,
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

        // [THEN] VAT entries of advance letter will exist
        VATEntry.SetRange("Advance Letter No. CZZ", SalesAdvLetterHeaderCZZ."No.");
        Assert.RecordIsNotEmpty(VATEntry);

        // [THEN] Sum of base and VAT amounts in VAT entries will be zero
        VATEntry.SetRange("Advance Letter No. CZZ");
        VATEntry.CalcSums(Base, Amount);
        Assert.AreNearlyEqual(0, VATEntry.Base, 1, 'The sum of base amount in VAT entries must be zero.');
        Assert.AreNearlyEqual(0, VATEntry.Amount, 1, 'The sum of amount in VAT entries must be zero.');

        // [THEN] Sales advance letter entry of "Usage" type will be created
        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Document No.", PostedDocumentNo);
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Usage);
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ);

        // [THEN] Sales advance letter entry of "VAT Usage" type will be created
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Usage");
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ);

        // [THEN] Sales advance letter entry of "VAT Rate" type will be created
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Rate");
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ);

        // [THEN] Sales advance letter will be closed
        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterHeaderCZZ.TestField(Status, SalesAdvLetterHeaderCZZ.Status::Closed);
    end;

    [Test]
    procedure CloseSalesAdvLetterInFCYPartiallyDeducted()
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ClosingDate: Date;
    begin
        // [SCENARIO] Close sales advance letter in foreign currency and partially deducted by sales invoice
        Initialize();

        // [GIVEN] Sales advance letter in foreign currency has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Sales invoice in foreign currency and different exchange rate as advance letter has been created
        // [GIVEN] Sales invoice line with a lower amount than advance letter line has been created
        LibrarySalesAdvancesCZZ.CreateSalesInvoice(
            SalesHeader, SalesLine, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", SalesAdvLetterHeaderCZZ."Posting Date" + 1,
            SalesAdvLetterLineCZZ."VAT Bus. Posting Group", SalesAdvLetterLineCZZ."VAT Prod. Posting Group",
            SalesAdvLetterHeaderCZZ."Currency Code", 0, true, SalesAdvLetterLineCZZ."Amount Including VAT" / 2);

        // [GIVEN] Whole advance letter has been linked to sales invoice
        LibrarySalesAdvancesCZZ.LinkSalesAdvanceLetterToDocument(
            SalesAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Sales Invoice", SalesHeader."No.",
            SalesAdvLetterLineCZZ."Amount Including VAT", SalesAdvLetterLineCZZ."Amount Including VAT (LCY)");

        // [GIVEN] Sales invoice has been posted
        PostSalesDocument(SalesHeader);

        // [WHEN] Close sales advance letter
        ClosingDate := WorkDate() + 1;
        LibrarySalesAdvancesCZZ.CloseSalesAdvanceLetter(SalesAdvLetterHeaderCZZ, ClosingDate, ClosingDate, 0);

        // [THEN] Sales advance letter entry of "Close" type will be created
        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Close);
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ);

        // [THEN] Sales advance letter entry of "VAT Close" type will be created
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Close");
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ);

        // [THEN] Sales advance letter entry of "VAT Rate" type will be created
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Rate");
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ);

        // [THEN] The sum of amounts of sales advance letter entries will be zero
        SalesAdvLetterEntryCZZ.SetFilter("Entry Type", '<>%1', SalesAdvLetterEntryCZZ."Entry Type"::"Initial Entry");
        SalesAdvLetterEntryCZZ.CalcSums("Amount (LCY)");
        Assert.AreEqual(0, SalesAdvLetterEntryCZZ."Amount (LCY)", 'The sum of amounts must be zero.');
    end;

    [Test]
    procedure MultipleAdvancePaymentInFCY()
    var
        Currency: Record Currency;
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        VATEntry: Record "VAT Entry";
        PostedDocumentNo: Code[20];
        FirstPaymentAmount: Decimal;
        SecondPaymentAmount: Decimal;
        ThirdPaymentAmount: Decimal;
    begin
        // [SCENARIO] The payment of the sales advance letter in foreign currency can be split into several payments
        Initialize();
        FindForeignCurrency(Currency);

        // [GIVEN] Sales advance letter in foreign currency has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been partially paid
        FirstPaymentAmount := Round(SalesAdvLetterLineCZZ."Amount Including VAT" / 3,
            Currency."Amount Rounding Precision", Currency.VATRoundingDirection());
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -FirstPaymentAmount);

        // [GIVEN] Sales advance letter has been partially paid
        SecondPaymentAmount := FirstPaymentAmount;
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SecondPaymentAmount);

        // [GIVEN] Sales advance letter has been partially paid
        ThirdPaymentAmount := SalesAdvLetterLineCZZ."Amount Including VAT" - FirstPaymentAmount - SecondPaymentAmount;
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -ThirdPaymentAmount, 0, SalesAdvLetterHeaderCZZ."Posting Date" + 1);

        // [GIVEN] Sales invoice in foreign currency and different exchange rate as advance letter has been created
        // [GIVEN] Sales invoice line has been created
        LibrarySalesAdvancesCZZ.CreateSalesInvoice(
            SalesHeader, SalesLine, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", SalesAdvLetterHeaderCZZ."Posting Date" + 5,
            SalesAdvLetterLineCZZ."VAT Bus. Posting Group", SalesAdvLetterLineCZZ."VAT Prod. Posting Group",
            SalesAdvLetterHeaderCZZ."Currency Code", 0, true, SalesAdvLetterLineCZZ."Amount Including VAT");

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

        // [THEN] VAT entries of advance letter will exist
        VATEntry.SetRange("Advance Letter No. CZZ", SalesAdvLetterHeaderCZZ."No.");
        Assert.RecordIsNotEmpty(VATEntry);

        // [THEN] Sum of base and VAT amounts of VAT entries will be zero
        VATEntry.SetRange("Advance Letter No. CZZ");
        VATEntry.CalcSums(Base, Amount);
        Assert.AreNearlyEqual(0, VATEntry.Base, 1, 'The sum of base amount in VAT entries must be zero.');
        Assert.AreNearlyEqual(0, VATEntry.Amount, 1, 'The sum of amount in VAT entries must be zero.');

        // [THEN] Three sales advance letter entry of "VAT Payment" type will be created
        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        Assert.RecordCount(SalesAdvLetterEntryCZZ, 3);

        // [THEN] Three sales advance letter entry of "VAT Usage" type will be created
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Usage");
        Assert.RecordCount(SalesAdvLetterEntryCZZ, 3);

        // [THEN] Three sales advance letter entry of "VAT Rate" type will be created
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Rate");
        Assert.RecordCount(SalesAdvLetterEntryCZZ, 3);

        // [THEN] Sum of VAT base and VAT amount of sales advance letter entries will be zero
        SalesAdvLetterEntryCZZ.SetFilter("Entry Type", '<>%1', SalesAdvLetterEntryCZZ."Entry Type"::"Initial Entry");
        SalesAdvLetterEntryCZZ.CalcSums("VAT Base Amount", "VAT Amount");
        Assert.AreEqual(0, SalesAdvLetterEntryCZZ."VAT Base Amount", 'The sum of VAT base amount in sales adv. letter entries must be zero.');
        Assert.AreEqual(0, SalesAdvLetterEntryCZZ."VAT Amount", 'The sum of VAT amount in sales adv. letter entries must be zero.');

        // [THEN] Sales advance letter will be closed
        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterHeaderCZZ.TestField(Status, SalesAdvLetterHeaderCZZ.Status::Closed);
    end;

    [Test]
    procedure LinkMultipleAdvanceLettersInFCYToOneInvoice()
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ1: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterHeaderCZZ2: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ1: Record "Sales Adv. Letter Line CZZ";
        SalesAdvLetterLineCZZ2: Record "Sales Adv. Letter Line CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine1: Record "Sales Line";
        SalesLine2: Record "Sales Line";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Multiple advance letters in foreign currency can be linked to a one sales invoice
        Initialize();

        // [GIVEN] First sales advance letter in foreign currency has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ1, SalesAdvLetterLineCZZ1);

        // [GIVEN] First sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ1);

        // [GIVEN] First sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ1, -SalesAdvLetterLineCZZ1."Amount Including VAT");

        // [GIVEN] Second sales advance letter in foreign currency has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ2, SalesAdvLetterLineCZZ2, SalesAdvLetterHeaderCZZ1."Bill-to Customer No.");

        // [GIVEN] Second sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ2);

        // [GIVEN] Second sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ2, -SalesAdvLetterLineCZZ2."Amount Including VAT");

        // [GIVEN] Sales invoice in foreign currency and different exchange rate as advance letters has been created
        // [GIVEN] First sales invoice line has been created
        LibrarySalesAdvancesCZZ.CreateSalesInvoice(
            SalesHeader, SalesLine1, SalesAdvLetterHeaderCZZ1."Bill-to Customer No.", SalesAdvLetterHeaderCZZ1."Posting Date" + 5,
            SalesAdvLetterLineCZZ1."VAT Bus. Posting Group", SalesAdvLetterLineCZZ1."VAT Prod. Posting Group",
            SalesAdvLetterHeaderCZZ1."Currency Code", 0, true, SalesAdvLetterLineCZZ1."Amount Including VAT");

        // [GIVEN] Second sales invoice line has been created
        LibrarySales.CreateSalesLine(SalesLine2, SalesHeader, SalesLine2.Type::"G/L Account", SalesLine1."No.", 1);
        SalesLine2.Validate("Unit Price", SalesAdvLetterLineCZZ2."Amount Including VAT");
        SalesLine2.Modify(true);

        // [GIVEN] Whole first advance letter has been linked to sales invoice
        LibrarySalesAdvancesCZZ.LinkSalesAdvanceLetterToDocument(
            SalesAdvLetterHeaderCZZ1, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Sales Invoice", SalesHeader."No.",
            SalesAdvLetterLineCZZ1."Amount Including VAT", SalesAdvLetterLineCZZ1."Amount Including VAT (LCY)");

        // [GIVEN] Whole second advance letter has been linked to sales invoice
        LibrarySalesAdvancesCZZ.LinkSalesAdvanceLetterToDocument(
            SalesAdvLetterHeaderCZZ2, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Sales Invoice", SalesHeader."No.",
            SalesAdvLetterLineCZZ2."Amount Including VAT", SalesAdvLetterLineCZZ2."Amount Including VAT (LCY)");

        // [WHEN] Post sales invoice
        PostedDocumentNo := PostSalesDocument(SalesHeader);

        // [THEN] Sales advance letter entry of Usage type for the first sales advance letter will be created
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ1."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Usage);
        SalesAdvLetterEntryCZZ.SetRange("Document No.", PostedDocumentNo);
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ);

        // [THEN] Sales advance letter entry of Usage type for the second sales advance letter will be created
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ2."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Usage);
        SalesAdvLetterEntryCZZ.SetRange("Document No.", PostedDocumentNo);
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ);
    end;

    [Test]
    procedure UnlinkSalesAdvLetterInFCYFromPayment()
    var
        SalesAdvLetterEntryCZZ1: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        // [SCENARIO] Unlink sales advance letter in foreign currency from payment
        Initialize();

        // [GIVEN] Sales advance letter in foreign currency has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

        // [WHEN] Unlink advance letter from payment
        FindLastPaymentAdvanceLetterEntry(SalesAdvLetterHeaderCZZ."No.", SalesAdvLetterEntryCZZ1);
        LibrarySalesAdvancesCZZ.UnlinkSalesAdvancePayment(SalesAdvLetterEntryCZZ1);

        // [THEN] Sales advance letter entries will be created. One of the type "Payment" and the other of the type "VAT Payment".
        SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ2.Find('+');
        Assert.AreEqual(SalesAdvLetterEntryCZZ2."Entry Type"::Payment, SalesAdvLetterEntryCZZ2."Entry Type", 'The sales advance letter entry must be of type "Payment".');
        Assert.AreEqual(-SalesAdvLetterEntryCZZ1.Amount, SalesAdvLetterEntryCZZ2.Amount, 'The amount must have the opposite sign.');
        Assert.AreEqual(SalesAdvLetterEntryCZZ1."Entry No.", SalesAdvLetterEntryCZZ2."Related Entry", 'The entry must be related to entry of "Payment" type');

        SalesAdvLetterEntryCZZ2.Next(-1);
        Assert.AreEqual(SalesAdvLetterEntryCZZ2."Entry Type"::"VAT Payment", SalesAdvLetterEntryCZZ2."Entry Type", 'The sales advance letter entry must be of type "VAT Payment".');
        Assert.AreEqual(-SalesAdvLetterEntryCZZ1.Amount, SalesAdvLetterEntryCZZ2.Amount, 'The amount must have the opposite sign.');
        Assert.AreEqual(SalesAdvLetterEntryCZZ1."Entry No.", SalesAdvLetterEntryCZZ2."Related Entry", 'The entry must be related to entry of "Payment" type');

        // [THEN] Last opened customer ledger entry won't be related to advance letter. The "Advance Letter No." field will be empty.
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.FindLast();
        Assert.AreEqual('', CustLedgerEntry."Advance Letter No. CZZ", 'The advance letter no. must be empty.');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure UnlinkSalesAdvLetterInFCYFromPostedInvoice()
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Unlink sales advance letter in foreign currency from posted invoice
        Initialize();

        // [GIVEN] Sales advance letter in foreign currency has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Sales invoice in foreign currency has been created
        // [GIVEN] Sales invoice line has been created
        LibrarySalesAdvancesCZZ.CreateSalesInvoice(
            SalesHeader, SalesLine, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", SalesAdvLetterHeaderCZZ."Posting Date",
            SalesAdvLetterLineCZZ."VAT Bus. Posting Group", SalesAdvLetterLineCZZ."VAT Prod. Posting Group",
            SalesAdvLetterHeaderCZZ."Currency Code", 0, true, SalesAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Whole advance letter has been linked to sales invoice
        LibrarySalesAdvancesCZZ.LinkSalesAdvanceLetterToDocument(
            SalesAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Sales Invoice", SalesHeader."No.",
            SalesAdvLetterLineCZZ."Amount Including VAT", SalesAdvLetterLineCZZ."Amount Including VAT (LCY)");

        // [GIVEN] Sales invoice has been posted
        PostedDocumentNo := PostSalesDocument(SalesHeader);

        // [WHEN] Unlink sales advance letter from posted sales invoice
        SalesInvoiceHeader.Get(PostedDocumentNo);
        SetExpectedConfirm(StrSubstNo(UnapplyAdvLetterQst, SalesAdvLetterHeaderCZZ."No."), true);
        LibrarySalesAdvancesCZZ.UnapplyAdvanceLetter(SalesInvoiceHeader);

        // [THEN] Sales advance letter will be changed to status = "To Use"
        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterHeaderCZZ.TestField(Status, SalesAdvLetterHeaderCZZ.Status::"To Use");

        // [THEN] Sum amounts of sales advance letter entries for posted sales invoice must be zero
        SalesAdvLetterEntryCZZ.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesAdvLetterEntryCZZ.CalcSums(Amount, "Amount (LCY)", "VAT Base Amount", "VAT Base Amount (LCY)", "VAT Amount", "VAT Amount (LCY)");
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ);
        Assert.AreEqual(0, SalesAdvLetterEntryCZZ.Amount, 'The Amount must be zero.');
        Assert.AreEqual(0, SalesAdvLetterEntryCZZ."Amount (LCY)", 'The Amount LCY must be zero.');
        Assert.AreEqual(0, SalesAdvLetterEntryCZZ."VAT Base Amount", 'The VAT Base Amount must be zero.');
        Assert.AreEqual(0, SalesAdvLetterEntryCZZ."VAT Base Amount (LCY)", 'The VAT Base Amount LCY must be zero.');
        Assert.AreEqual(0, SalesAdvLetterEntryCZZ."VAT Amount", 'The VAT Amount must be zero.');
        Assert.AreEqual(0, SalesAdvLetterEntryCZZ."VAT Amount (LCY)", 'The VAT Amount LCY must be zero.');
    end;

    [Test]
    [HandlerFunctions('RequestPageAdjustExchangeRatesHandler,MessageHandler')]
    procedure AdjustCurrExchRateWithoutAffectedPaymentSalesAdvLetterInFCY()
    var
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        EntryCount: Integer;
    begin
        // [SCENARIO] Adjust currency exchange rate without affected payment sales advance letter in foreign currency
        Initialize();

        // [GIVEN] Sales advance letter in foreign currency has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Count of sales advance letter entry has been saved
        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        EntryCount := SalesAdvLetterEntryCZZ.Count();

        // [WHEN] Run adjust exchange rate
        Commit();
        SetExpectedMessage(CurrExchRateAdjustedMsg);
        RunAdjustExchangeRates(
            SalesAdvLetterHeaderCZZ."Bill-to Customer No.", SalesAdvLetterHeaderCZZ."Currency Code",
            CalcDate('<-CY>', WorkDate()), CalcDate('<CY>', WorkDate()), CalcDate('<CY>', WorkDate()),
            SalesAdvLetterHeaderCZZ."No.", true, false, false, true, false);

        // [THEN] Detailed customer ledger entry with of "Unrealized Gain" or "Unrealized Loss" type will be created
        CustLedgerEntry.Reset();
        CustLedgerEntry.SetRange("Customer No.", SalesAdvLetterHeaderCZZ."Bill-to Customer No.");
        CustLedgerEntry.FindLast();
        DetailedCustLedgEntry.SetCurrentKey("Cust. Ledger Entry No.");
        DetailedCustLedgEntry.SetRange("Cust. Ledger Entry No.", CustLedgerEntry."Entry No.");
        DetailedCustLedgEntry.SetFilter("Entry Type", '%1|%2',
            DetailedCustLedgEntry."Entry Type"::"Unrealized Gain",
            DetailedCustLedgEntry."Entry Type"::"Unrealized Loss");
        Assert.RecordIsNotEmpty(DetailedCustLedgEntry);

        // [THEN] Count of the sales advance letter entries is the same as before adjust running
        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        Assert.RecordCount(SalesAdvLetterEntryCZZ, EntryCount);
    end;

    [Test]
    [HandlerFunctions('RequestPageAdjustExchangeRatesHandler,MessageHandler,RequestPageAdjustAdvExchRatesHandler')]
    procedure AdjustCurrExchRateWithAffectedPaymentSalesAdvLetterInFCY()
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        AdjustedDate: Date;
    begin
        // [SCENARIO] Adjust currency exchange rate with affected payment sales advance letter in foreign currency
        Initialize();

        // [GIVEN] Sales advance letter in foreign currency has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Adjust exchange rate has been ran
        Commit();
        SetExpectedMessage(CurrExchRateAdjustedMsg);
        RunAdjustExchangeRates(
            SalesAdvLetterHeaderCZZ."Bill-to Customer No.", SalesAdvLetterHeaderCZZ."Currency Code",
            CalcDate('<-CY>', WorkDate()), CalcDate('<CY>', WorkDate()), CalcDate('<CY>', WorkDate()),
            SalesAdvLetterHeaderCZZ."No.", true, false, false, true, false);

        // [WHEN] Run adjust adv. exch. rates
        Commit();
        AdjustedDate := CalcDate('<CY>', WorkDate());
        RunAdjustAdvExchRates(
            SalesAdvLetterHeaderCZZ."No.", AdjustedDate, SalesAdvLetterHeaderCZZ."No.", true, false);

        // [THEN] Sales advance letter entries of type "VAT Adjustment" will be created
        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Adjustment");
        SalesAdvLetterEntryCZZ.SetRange("Posting Date", AdjustedDate);
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ);
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

    local procedure CreateSalesAdvLetter(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; CustomerNo: Code[20])
    var
        Currency: Record Currency;
        VATPostingSetup: Record "VAT Posting Setup";
        Customer: Record Customer;
    begin
        LibrarySalesAdvancesCZZ.FindVATPostingSetup(VATPostingSetup);

        if CustomerNo = '' then begin
            LibrarySalesAdvancesCZZ.CreateCustomer(Customer);
            Customer.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
            Customer.Modify(true);
            CustomerNo := Customer."No.";
        end;

        FindForeignCurrency(Currency);
        LibrarySalesAdvancesCZZ.CreateSalesAdvLetterHeader(SalesAdvLetterHeaderCZZ, AdvanceLetterTemplateCZZ.Code, CustomerNo, Currency.Code);
        LibrarySalesAdvancesCZZ.CreateSalesAdvLetterLine(SalesAdvLetterLineCZZ, SalesAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));
    end;

    local procedure CreateSalesAdvLetter(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ")
    begin
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ, '');
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

    local procedure FindForeignCurrency(var Currency: Record Currency)
    begin
        Currency.SetFilter(Code, '<>%1', GeneralLedgerSetup."LCY Code");
        LibraryERM.FindCurrency(Currency);
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

    local procedure RunAdjustExchangeRates(CustomerNo: Code[20]; CurrencyCode: Code[10]; StartDate: Date; EndDate: Date; PostingDate: Date; DocumentNo: Code[20]; AdjCust: Boolean; AdjVend: Boolean; AdjBank: Boolean; Post: Boolean; SkipAdvancePayments: Boolean)
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
        LibraryVariableStorage.Enqueue(CustomerNo);

        Currency.SetRange(Code, CurrencyCode);
        XmlParameters := Report.RunRequestPage(Report::"Adjust Exchange Rates CZL");
        LibraryReportDataset.RunReportAndLoad(Report::"Adjust Exchange Rates CZL", Currency, XmlParameters);
    end;

    local procedure RunAdjustAdvExchRates(SalesAdvLetterNo: Code[20]; AdjustToDate: Date; DocumentNo: Code[20]; AdjCust: Boolean; AdjVend: Boolean)
    begin
        LibraryVariableStorage.Enqueue(AdjustToDate);
        LibraryVariableStorage.Enqueue(DocumentNo);
        LibraryVariableStorage.Enqueue(AdjCust);
        LibraryVariableStorage.Enqueue(AdjVend);
        LibraryVariableStorage.Enqueue(SalesAdvLetterNo);
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
        AdjustExchangeRatesCZL.Customer.SetFilter("No.", FieldVariant);
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
        AdjustAdvExchRatesCZZ."Sales Adv. Letter Header CZZ".SetFilter("No.", FieldVariant);
        AdjustAdvExchRatesCZZ.OK().Invoke();
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
