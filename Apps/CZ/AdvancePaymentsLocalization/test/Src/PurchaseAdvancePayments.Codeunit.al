codeunit 148108 "Purchase Advance Payments CZZ"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Advance Payments] [Purchase]
        isInitialized := false;
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        Assert: Codeunit Assert;
        LibraryRandom: Codeunit "Library - Random";
        LibraryPurchAdvancesCZZ: Codeunit "Library - Purch. Advances CZZ";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryERM: Codeunit "Library - ERM";
        isInitialized: Boolean;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Purchase Advance Payments CZZ");
        LibraryRandom.Init();
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Purchase Advance Payments CZZ");

        GeneralLedgerSetup.Get();
        UpdatePurchaseSetup();
        LibraryPurchAdvancesCZZ.CreatePurchAdvanceLetterTemplate(AdvanceLetterTemplateCZZ);

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Purchase Advance Payments CZZ");
    end;

    [Test]
    procedure CreatePurchAdvLetter()
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
    begin
        // [SCENARIO] Test if the system allows to create a new Purchase Advance Letter
        Initialize();

        // [WHEN] Create purchase advance letter
        CreatePurchAdvLetterBase(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ, '');

        // [THEN] Purchase advance letter will be created
        PurchAdvLetterLineCZZ.SetRange("Document No.", PurchAdvLetterHeaderCZZ."No.");
        Assert.IsFalse(PurchAdvLetterLineCZZ.IsEmpty(), 'Advance Letter was not created.');
    end;

    [Test]
    [HandlerFunctions('CreatePurchAdvLetterHandler,OpenAdvanceLetterHandler')]
    procedure CreatePurchAdvLetterFromPurchOrder()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
    begin
        // [SCENARIO] Test if the system allows to create a new Purchase Advance Letter from Purchase order
        Initialize();

        // [GIVEN] Purchase order has been created
        LibraryPurchAdvancesCZZ.CreatePurchOrder(PurchaseHeader, PurchaseLine);

        // [WHEN] Create purchase advance letter from purchase order
        CreatePurchAdvLetterFromPurchDoc(PurchAdvLetterHeaderCZZ, PurchaseHeader);

        // [THEN] Purchase advance letter will be created
        PurchAdvLetterLineCZZ.SetRange("Document No.", PurchAdvLetterHeaderCZZ."No.");
        Assert.IsFalse(PurchAdvLetterLineCZZ.IsEmpty(), 'Advance Letter was not created.');
    end;

    [Test]
    [HandlerFunctions('CreatePurchAdvLetterHandler,OpenAdvanceLetterHandler')]
    procedure ReleasePurchAdvLetter()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
    begin
        // [SCENARIO] Test the release of Purchase Advance Letter
        Initialize();

        // [GIVEN] Purchase advance letter from purchase order has been created
        LibraryPurchAdvancesCZZ.CreatePurchOrder(PurchaseHeader, PurchaseLine);
        CreatePurchAdvLetterFromPurchDoc(PurchAdvLetterHeaderCZZ, PurchaseHeader);

        // [WHEN] Release purchase advance
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [THEN] Purchase advance letter ststus will be To Pay
        PurchAdvLetterHeaderCZZ.TestField(Status, PurchAdvLetterHeaderCZZ.Status::"To Pay");
    end;

    [Test]
    procedure PaymentPurchAdvLetter()
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        AmountInclVAT, AmountInclVATLCY : Decimal;
    begin
        // [SCENARIO] Test the payment of Purchase Advance Letter
        Initialize();

        // [GIVEN] Purchase advance letter bas been created
        CreatePurchAdvLetterBase(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ, '');

        // [GIVEN] Purchase advance letter bas been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);
        AmountInclVAT := PurchAdvLetterLineCZZ."Amount Including VAT";

        // [WHEN] Post purchase advance payment
        AmountInclVATLCY := PostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, AmountInclVAT, 0);

        // [THEN] Purchase advance letter status will be To Use
        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterHeaderCZZ.TestField(Status, PurchAdvLetterHeaderCZZ.Status::"To Use");

        // [THEN] Purchase advance letter entry Payment will be created
        PurchAdvLetterEntryCZZ.SetCurrentKey("Purch. Adv. Letter No.");
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Payment);
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        // [THEN] Purchase advance letter entry Payment entry has correct amounts
        PurchAdvLetterEntryCZZ.FindFirst();
        Assert.AreEqual(PurchAdvLetterEntryCZZ.Amount, AmountInclVAT, 'Wrong payment entry Amount.');
        Assert.AreEqual(PurchAdvLetterEntryCZZ."Amount (LCY)", AmountInclVATLCY, 'Wrong payment entry Amount (LCY).');
    end;

    [Test]
    [HandlerFunctions('CreatePurchAdvLetterHandler,OpenAdvanceLetterHandler')]
    procedure PostPurchOrderWithPurchAdvLetter()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchInvHeader: Record "Purch. Inv. Header";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PostedDocNo: Code[20];
    begin
        // [SCENARIO] Test the posting of Purchase Order from which Purchase Advance Letter was created
        Initialize();

        // [GIVEN] Purchase advance letter from purchase order has been created
        LibraryPurchAdvancesCZZ.CreatePurchOrder(PurchaseHeader, PurchaseLine);
        CreatePurchAdvLetterFromPurchDoc(PurchAdvLetterHeaderCZZ, PurchaseHeader);

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance has been paid
        PostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT", 0);

        // [WHEN] Post purchase order
        PostedDocNo := PostPurchaseDocument(PurchaseHeader);

        // [THEN] Purchance advance letter status will be Closed
        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterHeaderCZZ.TestField(Status, PurchAdvLetterHeaderCZZ.Status::Closed);

        // [THEN] Purchase Advance letter entry type Usage will be created
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Usage);
        PurchAdvLetterEntryCZZ.FindFirst();
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        // [THEN] Purchase invoice will be non zero amount
        PurchInvHeader.Get(PostedDocNo);
        PurchInvHeader.CalcFields(Amount, "Amount Including VAT");
        PurchInvHeader.TestField(Amount, PurchaseLine.Amount);
        PurchInvHeader.TestField("Amount Including VAT", PurchaseLine."Amount Including VAT");

        // [THEN] Vedor ledger entry will be closed
        VendorLedgerEntry.SetRange("Vendor No.", PurchaseHeader."Pay-to Vendor No.");
        VendorLedgerEntry.SetRange("Document No.", PostedDocNo);
        VendorLedgerEntry.FindLast();
        VendorLedgerEntry.TestField(Open, false);
    end;

    [Test]
    procedure PaymentPurchAdvLetterWithForeignCurrency()
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        Currency: Record Currency;
        AmountInclVAT, AmountInclVATLCY : Decimal;
    begin
        // [SCENARIO] Test creation Purchase Advance Letter with foreign currency, changing exchange rate and posting payment
        Initialize();

        // [GIVEN] Foreign currency has been created
        FindForeignCurrency(Currency);

        // [GIVEN] Purchases advance letter with foreign currency has been crrated and released
        CreatePurchAdvLetterBase(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ, Currency.Code);
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);
        AmountInclVAT := PurchAdvLetterLineCZZ."Amount Including VAT";

        // [WHEN] Post purchase advance payment with different exchange rate
        AmountInclVATLCY := PostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, AmountInclVAT, 0.9);

        // [THEN] Purchase advance letter status will be To Use
        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterHeaderCZZ.TestField(Status, PurchAdvLetterHeaderCZZ.Status::"To Use");

        // [THEN] Purchase advance letter entry Payment has correct amounts
        PurchAdvLetterEntryCZZ.SetCurrentKey("Purch. Adv. Letter No.");
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Payment);
        PurchAdvLetterEntryCZZ.FindFirst();
        Assert.AreEqual(PurchAdvLetterEntryCZZ.Amount, AmountInclVAT, 'Wrong payment entry Amount.');
        Assert.AreEqual(PurchAdvLetterEntryCZZ."Amount (LCY)", AmountInclVATLCY, 'Wrong payment entry Amount (LCY).');
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

        LibraryPurchAdvancesCZZ.CreatePurchAdvLetterHeader(PurchAdvLetterHeaderCZZ, AdvanceLetterTemplateCZZ.Code, Vendor."No.", CurrencyCode);
        LibraryPurchAdvancesCZZ.CreatePurchAdvLetterLine(PurchAdvLetterLineCZZ, PurchAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));
    end;

    local procedure CreatePurchAdvLetterFromPurchDoc(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchaseHeader: Record "Purchase Header")
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        CreatePurchAdvLetterCZZ: Report "Create Purch. Adv. Letter CZZ";
    begin
        Commit();
        CreatePurchAdvLetterCZZ.SetPurchHeader(PurchaseHeader);
        CreatePurchAdvLetterCZZ.Run();

        AdvanceLetterApplicationCZZ.SetRange("Advance Letter Type", AdvanceLetterApplicationCZZ."Advance Letter Type"::Purchase);
        AdvanceLetterApplicationCZZ.SetRange("Document Type", AdvanceLetterApplicationCZZ."Document Type"::"Purchase Order");
        AdvanceLetterApplicationCZZ.SetRange("Document No.", PurchaseHeader."No.");
        AdvanceLetterApplicationCZZ.FindFirst();
        PurchAdvLetterHeaderCZZ.Get(AdvanceLetterApplicationCZZ."Advance Letter No.");
    end;

    local procedure PostPaymentPurchAdvLetter(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; Amount: Decimal; ExchangeRate: Decimal): Decimal
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        LibraryPurchAdvancesCZZ.CreatePurchAdvancePayment(GenJournalLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", Amount, PurchAdvLetterHeaderCZZ."Currency Code", PurchAdvLetterHeaderCZZ."No.", ExchangeRate);
        PostGenJournalLine(GenJournalLine);
        exit(GenJournalLine."Amount (LCY)");
    end;

    local procedure FindForeignCurrency(var Currency: Record Currency)
    begin
        Currency.SetFilter(Code, '<>%1', GeneralLedgerSetup."LCY Code");
        LibraryERM.FindCurrency(Currency);
    end;

    local procedure UpdatePurchaseSetup()
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Allow VAT Difference", true);
        PurchasesPayablesSetup.Modify(true);
    end;

    local procedure ReleasePurchAdvLetter(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
        Codeunit.Run(Codeunit::"Rel. Purch.Adv.Letter Doc. CZZ", PurchAdvLetterHeaderCZZ);
    end;

    local procedure PostGenJournalLine(var GenJournalLine: Record "Gen. Journal Line")
    begin
        Codeunit.Run(Codeunit::"Gen. Jnl.-Post Line", GenJournalLine);
    end;

    local procedure PostPurchaseDocument(var PurchaseHeader: Record "Purchase Header"): Code[20]
    begin
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;

    [RequestPageHandler]
    procedure CreatePurchAdvLetterHandler(var CreatePurchAdvLetterCZZ: TestRequestPage "Create Purch. Adv. Letter CZZ")
    begin
        CreatePurchAdvLetterCZZ.AdvLetterCode.SetValue := AdvanceLetterTemplateCZZ.Code;
        CreatePurchAdvLetterCZZ.AdvPer.SetValue := 100;
        CreatePurchAdvLetterCZZ.SuggByLine.SetValue := false;
        CreatePurchAdvLetterCZZ.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure OpenAdvanceLetterHandler(Question: Text; var Reply: Boolean)
    var
        OpenAdvanceLetterQst: Label 'Do you want to open created Advance Letter?';
    begin
        if Question = OpenAdvanceLetterQst then
            Reply := false;
    end;
}
