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
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        GeneralLedgerSetup: Record "General Ledger Setup";
        Assert: Codeunit Assert;
        LibraryCashDeskCZP: Codeunit "Library - Cash Desk CZP";
        LibraryCashDocumentCZP: Codeunit "Library - Cash Document CZP";
        LibraryDialogHandler: Codeunit "Library - Dialog Handler";
        LibraryERM: Codeunit "Library - ERM";
        LibraryJournals: Codeunit "Library - Journals";
        LibraryPurchAdvancesCZZ: Codeunit "Library - Purch. Advances CZZ";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        isInitialized: Boolean;
        AppliedToAdvanceLetterErr: Label 'The entry is applied to advance letter and cannot be used to applying or unapplying.';
        ApplyAdvanceLetterQst: Label 'Apply Advance Letter?';
        LaterAdvancePaymentQst: Label 'The linked advance letter %1 is paid after %2. If you continue, the advance letter won''t be deducted.\\Do you want to continue?', Comment = '%1 = advance letter no., %2 = posting date';
        OpenAdvanceLetterQst: Label 'Do you want to open created Advance Letter?';
        NoApplicationEntryErr: Label 'Vendor Ledger Entry No. %1 does not have an application entry.', Comment = '%1 = advance letter no.';
        UnapplyAdvLetterQst: Label 'Unapply advance letter: %1\Continue?', Comment = '%1 = Advance Letters';
        UsageNoPossibleQst: Label 'Usage all applicated advances is not possible.\Continue?';
        PostCashDocumentQst: Label 'Do you want to post Cash Document Header %1?', Comment = '%1 = Cash Document No.';

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Purchase Advance Payments CZZ");
        LibraryRandom.Init();
        LibraryVariableStorage.Clear();
        LibraryDialogHandler.ClearVariableStorage();
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
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ, '');

        // [THEN] Purchase advance letter will be created
        PurchAdvLetterLineCZZ.SetRange("Document No.", PurchAdvLetterHeaderCZZ."No.");
        Assert.RecordIsNotEmpty(PurchAdvLetterLineCZZ);
    end;

    [Test]
    [HandlerFunctions('CreatePurchAdvLetterHandler,ConfirmHandler')]
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
        SetExpectedConfirm(OpenAdvanceLetterQst, false);
        CreatePurchAdvLetterFromOrderWithAdvancePer(PurchaseHeader, AdvanceLetterTemplateCZZ.Code, 100, false, PurchAdvLetterHeaderCZZ);

        // [THEN] Purchase advance letter will be created
        PurchAdvLetterLineCZZ.SetRange("Document No.", PurchAdvLetterHeaderCZZ."No.");
        Assert.RecordIsNotEmpty(PurchAdvLetterLineCZZ);
    end;

    [Test]
    [HandlerFunctions('CreatePurchAdvLetterHandler,ConfirmHandler')]
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
        SetExpectedConfirm(OpenAdvanceLetterQst, false);
        CreatePurchAdvLetterFromOrderWithAdvancePer(PurchaseHeader, AdvanceLetterTemplateCZZ.Code, 100, false, PurchAdvLetterHeaderCZZ);

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
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter bas been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);
        AmountInclVAT := PurchAdvLetterLineCZZ."Amount Including VAT";

        // [WHEN] Post purchase advance payment
        AmountInclVATLCY := CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, AmountInclVAT);

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
    [HandlerFunctions('CreatePurchAdvLetterHandler,ConfirmHandler')]
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
        SetExpectedConfirm(OpenAdvanceLetterQst, false);
        CreatePurchAdvLetterFromOrderWithAdvancePer(PurchaseHeader, AdvanceLetterTemplateCZZ.Code, 100, false, PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance has been paid
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [WHEN] Post purchase order
        PostedDocNo := PostPurchaseDocument(PurchaseHeader);

        // [THEN] Purchaseance advance letter status will be Closed
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
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ, Currency.Code);
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);
        AmountInclVAT := PurchAdvLetterLineCZZ."Amount Including VAT";

        // [WHEN] Post purchase advance payment with different exchange rate
        AmountInclVATLCY := CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, AmountInclVAT, 0.9, 0D);

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

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure LinkPurchAdvLetterToInvoice()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        VATEntry: Record "VAT Entry";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Create purchase advance letter and link to invoice
        Initialize();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase invoice has been created
        // [GIVEN] Purchase invoice line has been created
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
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure LinkPurchAdvLetterToInvoiceWithOlderDate()
    var
        AdvanceLetterApplication: Record "Advance Letter Application CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        TempAdvanceLetterApplication: Record "Advance Letter Application CZZ" temporary;
    begin
        // [SCENARIO] Create purchase advance letter and link to invoice with older date
        Initialize();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Payment VAT has been posted
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Payment);
        PurchAdvLetterEntryCZZ.FindFirst();
        PostPurchAdvancePaymentVAT(PurchAdvLetterEntryCZZ);

        // [GIVEN] Purchase invoice has been created
        // [GIVEN] Purchase invoice line has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Posting Date" - 1,
            PurchAdvLetterLineCZZ."VAT Bus. Posting Group", PurchAdvLetterLineCZZ."VAT Prod. Posting Group", '', 0,
            true, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [WHEN] Get list of advance letter available for linking
        AdvanceLetterApplication.GetPossiblePurchAdvance(
            Enum::"Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice", PurchaseHeader."No.", PurchaseHeader."Pay-to Vendor No.",
            PurchaseHeader."Posting Date", PurchaseHeader."Currency Code", TempAdvanceLetterApplication);

        // [THEN] Purchase advance letter won't be available for linking
        TempAdvanceLetterApplication.SetRange("Advance Letter Type", Enum::"Advance Letter Type CZZ"::Purchase);
        TempAdvanceLetterApplication.SetRange("Advance Letter No.", PurchAdvLetterHeaderCZZ."No.");
        Assert.RecordIsEmpty(TempAdvanceLetterApplication);
    end;

    [Test]
    procedure AdditionalLinkPurchAdvLetterToPayment()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
    begin
        // [SCENARIO] Additional link purchase advance letter to payment
        Initialize();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Payment has been posted
        CreateAndPostPayment(PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterLineCZZ."Amount Including VAT");

        // [WHEN] Link advance letter to payment
        VendorLedgerEntry.FindLast(); // entry of payment
        LibraryPurchAdvancesCZZ.LinkPurchAdvancePayment(PurchAdvLetterHeaderCZZ, VendorLedgerEntry);

        // [THEN] Purchase advance letter will be paid
        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterHeaderCZZ.TestField(Status, PurchAdvLetterHeaderCZZ.Status::"To Use");

        // [THEN] Purchase advance letter entries will be created. One of the type "Payment" and the other of the "VAT Payment".
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.FindLast();
        Assert.AreEqual(PurchAdvLetterEntryCZZ."Entry Type"::Payment, PurchAdvLetterEntryCZZ."Entry Type", 'The purchase advance letter entry must be of type "Payment".');
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure UnlinkPurchAdvLetterFromPayment()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PurchAdvLetterEntryCZZ1: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
    begin
        // [SCENARIO] Unlink purchase advance letter from payment
        Initialize();

        // [GIVEN] Purchase advance letter has been created
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

        // [THEN] Purchase advance letter entries will be create. One of the type "Payment" and the other of the "VAT Payment".
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
    procedure AdditionalLinkPurchaseAdvLetterToInvoice()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchaseLine: Record "Purchase Line";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Create purchase advance letter and additionally link to invoice
        Initialize();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase invoice has been created
        // [GIVEN] Purchase invoice line has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Posting Date",
            PurchAdvLetterLineCZZ."VAT Bus. Posting Group", PurchAdvLetterLineCZZ."VAT Prod. Posting Group", '', 0,
            true, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Purchase invoice has been posted
        PostedDocumentNo := PostPurchaseDocument(PurchaseHeader);

        // [WHEN] Link advance letter to posted purchase invoice
        PurchInvHeader.Get(PostedDocumentNo);
        SetExpectedConfirm(ApplyAdvanceLetterQst, true);
        LibraryPurchAdvancesCZZ.ApplyPurchAdvanceLetter(PurchAdvLetterHeaderCZZ, PurchInvHeader);

        // [THEN] Purchase advance letter entries for posted purchase invoice are created
        PurchAdvLetterEntryCZZ.SetRange("Document No.", PurchInvHeader."No.");
        PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Usage);
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Usage");
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler,ConfirmHandler')]
    procedure AdditionalUnlinkPurchAdvLetterFromPostedInvoice()
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchaseLine: Record "Purchase Line";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Create purchase advance letter, link to invoice, post the invoice and unlink the purchase advance letter
        Initialize();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase invoice has been created
        // [GIVEN] Purchase invoice line has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Posting Date",
            PurchAdvLetterLineCZZ."VAT Bus. Posting Group", PurchAdvLetterLineCZZ."VAT Prod. Posting Group", '', 0,
            true, PurchAdvLetterLineCZZ."Amount Including VAT");

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
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure ManualPaymentVATUsageInPurchaseAdvanceLetter()
    var
        PurchAdvLetterEntryCZZ1: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        // [SCENARIO] Manual payment VAT usage in purchase advance letter
        Initialize();

        // [GIVEN] Purchase advance letter without automatic post VAT usage has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);
        PurchAdvLetterHeaderCZZ."Automatic Post VAT Usage" := false;
        PurchAdvLetterHeaderCZZ.Modify();

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase invoice has been created
        // [GIVEN] Purchase invoice line has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Posting Date",
            PurchAdvLetterLineCZZ."VAT Bus. Posting Group", PurchAdvLetterLineCZZ."VAT Prod. Posting Group", '', 0,
            true, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Whole advance letter has been linked to purchase invoice
        LibraryPurchAdvancesCZZ.LinkPurchAdvanceLetterToDocument(
            PurchAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice", PurchaseHeader."No.",
            PurchAdvLetterLineCZZ."Amount Including VAT", PurchAdvLetterLineCZZ."Amount Including VAT (LCY)");

        // [GIVEN] Purchase invoice has been posted
        PostPurchaseDocument(PurchaseHeader);

        // [WHEN] Post advance payment usage VAT from advance letter entry of "Usage" type
        PurchAdvLetterEntryCZZ1.Reset();
        PurchAdvLetterEntryCZZ1.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ1.SetRange("Entry Type", PurchAdvLetterEntryCZZ1."Entry Type"::Usage);
        PurchAdvLetterEntryCZZ1.FindFirst();
        PostPurchAdvancePaymentUsageVAT(PurchAdvLetterEntryCZZ1);

        // [THEN] Purchase advance letter entry of "VAT Usage" type will be created
        PurchAdvLetterEntryCZZ2.Reset();
        PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ2.SetRange("Entry Type", PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Usage");
        PurchAdvLetterEntryCZZ2.FindFirst();
        Assert.AreEqual(PurchAdvLetterEntryCZZ1."Posting Date", PurchAdvLetterEntryCZZ2."Posting Date", 'The entry must have the same posting date as related entry.');
        Assert.AreEqual(PurchAdvLetterEntryCZZ1.Amount, PurchAdvLetterEntryCZZ2.Amount, 'The entry must have the same amount as related entry.');

        // [THEN] Purchase advance letter will be closed
        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterHeaderCZZ.TestField(Status, PurchAdvLetterHeaderCZZ.Status::Closed);
    end;

    [Test]
    procedure ClosePurchaseAdvanceLetterWithoutVATPayment()
    var
        PurchAdvLetterEntryCZZ1: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
    begin
        // [SCENARIO] It must be possible to close the purchase advance letter without VAT payment
        Initialize();

        // [GIVEN] Purchase advance letter without automatic post VAT usage has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);
        PurchAdvLetterHeaderCZZ."Automatic Post VAT Usage" := false;
        PurchAdvLetterHeaderCZZ.Modify();

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [WHEN] Close advance letter
        LibraryPurchAdvancesCZZ.ClosePurchAdvanceLetter(PurchAdvLetterHeaderCZZ);

        // [THEN] Purchase advance letter entry of "Close" type will be created
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
    procedure LinkPurchAdvanceLetterWithReverseChargeToInvoice()
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VATEntry: Record "VAT Entry";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Link purchase advance letter with reverse charge to invoice
        Initialize();

        // [GIVEN] Posting of VAT documents for reverse charge has been enabled
        SetPostVATDocForReverseCharge(true);

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with reverse charge has been created
        CreatePurchAdvLetterWithReverseCharge(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase invoice has been created
        // [GIVEN] Purchase invoice line has been created
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

        // [THEN] VAT entries of purchase invoice and advance letter will exist
        VATEntry.Reset();
        VATEntry.SetRange("Document No.", PostedDocumentNo);
        VATEntry.SetRange("Posting Date", PurchaseHeader."Posting Date");
        Assert.RecordIsNotEmpty(VATEntry);

        // [THEN] Sum of base and VAT amounts in VAT entries will be zero
        VATEntry.CalcSums(Base, Amount);
        Assert.AreEqual(0, VATEntry.Base, 'The sum of base amount in VAT Entries must be zero.');
        Assert.AreEqual(0, VATEntry.Amount, 'The sum of VAT amount in VAT Entries must be zero.');

        // [THEN] Sum of base and VAT amounts in advance letter entries will be zero
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.CalcSums("VAT Base Amount", "VAT Amount");
        Assert.AreEqual(0, PurchAdvLetterEntryCZZ."VAT Base Amount", 'The sum of base amount in advance letter entries must be zero.');
        Assert.AreEqual(0, PurchAdvLetterEntryCZZ."VAT Amount", 'The sum of VAT amount in VAT advance letter must be zero.');

        // [THEN] Purchase advance letter will be closed
        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterHeaderCZZ.TestField(Status, PurchAdvLetterHeaderCZZ.Status::Closed);

        SetPostVATDocForReverseCharge(false);
    end;

    [Test]
    procedure MultipleAdvancePayment()
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        FirstPaymentAmount: Decimal;
        SecondPaymentAmount: Decimal;
    begin
        // [SCENARIO] The payment of the purchase advance letter can be split into several payments
        Initialize();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been partially paid
        FirstPaymentAmount := Round(PurchAdvLetterLineCZZ."Amount Including VAT" / 2);
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, FirstPaymentAmount);

        // [WHEN] Purchase advance letter has been paid in full by the general journal
        SecondPaymentAmount := PurchAdvLetterLineCZZ."Amount Including VAT" - FirstPaymentAmount;
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, SecondPaymentAmount);

        // [THEN] Sum of amounts of advance letter entries with type Init and Payment will be zero
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetFilter("Entry Type", '%1|%2', PurchAdvLetterEntryCZZ."Entry Type"::"Initial Entry", PurchAdvLetterEntryCZZ."Entry Type"::Payment);
        PurchAdvLetterEntryCZZ.CalcSums(Amount);
        Assert.AreEqual(0, PurchAdvLetterEntryCZZ.Amount, 'The sum of amount in advance letter entries must be zero.');
    end;

    [Test]
    procedure MultipleAdvancePaymentWithTimeShift()
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        FirstPaymentAmount: Decimal;
        SecondPaymentAmount: Decimal;
    begin
        // [SCENARIO] Only advance payments paid up to the posting date of purchase invoice can be assigned to the invoice
        Initialize();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been partially paid
        FirstPaymentAmount := Round(PurchAdvLetterLineCZZ."Amount Including VAT" / 2);
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, FirstPaymentAmount);

        // [GIVEN] Purchase advance letter has been paid in full a month later
        SecondPaymentAmount := PurchAdvLetterLineCZZ."Amount Including VAT" - FirstPaymentAmount;
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, SecondPaymentAmount, 0, CalcDate('<+1M>', PurchAdvLetterHeaderCZZ."Posting Date"));

        // [GIVEN] Purchase invoice has been created
        // [GIVEN] Purchase invoice line has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Posting Date",
            PurchAdvLetterLineCZZ."VAT Bus. Posting Group", PurchAdvLetterLineCZZ."VAT Prod. Posting Group", '', 0,
            true, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [WHEN] Get possible purchase advance to link
        AdvanceLetterApplicationCZZ.GetPossiblePurchAdvance(
            Enum::"Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice", PurchaseHeader."No.", PurchaseHeader."Pay-to Vendor No.",
            PurchaseHeader."Posting Date", PurchaseHeader."Currency Code", AdvanceLetterApplicationCZZ);

        // [THEN] Only first payment amount is possible to use for link
        AdvanceLetterApplicationCZZ.Get(
            Enum::"Advance Letter Type CZZ"::Purchase, PurchAdvLetterHeaderCZZ."No.",
            Enum::"Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice", PurchaseHeader."No.");
        Assert.AreEqual(FirstPaymentAmount, AdvanceLetterApplicationCZZ.Amount, 'Only first payment amount can be used.');
    end;

    [Test]
    procedure LinkMultipleAdvanceLettersToOneInvoice()
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ1: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ1: Record "Purch. Adv. Letter Line CZZ";
        PurchAdvLetterHeaderCZZ2: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ2: Record "Purch. Adv. Letter Line CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine1: Record "Purchase Line";
        PurchaseLine2: Record "Purchase Line";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Multiple advance letters can be linked to a one purchase invoice
        Initialize();

        // [GIVEN] First purchase advance letter has been created
        // [GIVEN] First purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ1, PurchAdvLetterLineCZZ1);

        // [GIVEN] First purchase advance letter has been released
        LibraryPurchAdvancesCZZ.ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ1);

        // [GIVEN] First purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ1, PurchAdvLetterLineCZZ1."Amount Including VAT");

        // [GIVEN] Second purchase advance letter has been created
        // [GIVEN] Second purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetterWithVendor(PurchAdvLetterHeaderCZZ2, PurchAdvLetterLineCZZ2, PurchAdvLetterHeaderCZZ1."Pay-to Vendor No.");

        // [GIVEN] Second Purch advance letter has been released
        LibraryPurchAdvancesCZZ.ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ2);

        // [GIVEN] Second Purch advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ2, PurchAdvLetterLineCZZ2."Amount Including VAT");

        // [GIVEN] Purchase invoice has been created
        // [GIVEN] First purchase invoice line has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine1, PurchAdvLetterHeaderCZZ1."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ1."Posting Date",
            PurchAdvLetterLineCZZ1."VAT Bus. Posting Group", PurchAdvLetterLineCZZ1."VAT Prod. Posting Group", '', 0,
            true, PurchAdvLetterLineCZZ1."Amount Including VAT");

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

        // [THEN] The first advance letter will be used by invoice
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ1."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Usage);
        PurchAdvLetterEntryCZZ.SetRange("Document No.", PostedDocumentNo);
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        // [THEN] The second advance letter will be used by invoice
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ2."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Usage);
        PurchAdvLetterEntryCZZ.SetRange("Document No.", PostedDocumentNo);
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);
    end;

    [Test]
    procedure CancelApplicationOfVendorLedgerEntryForAdvancePayment()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        LastVendLedgerEntryNo: Integer;
    begin
        // [SCENARIO] Cancellation of application of vendor ledger entry for advance payment must fail
        Initialize();

        VendorLedgerEntry.FindLast();
        LastVendLedgerEntryNo := VendorLedgerEntry."Entry No.";

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        LibraryPurchAdvancesCZZ.ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");
        Commit();

        // [WHEN] Unapply all vendor ledger entries created by advance payment
        UnApplyVendLedgerEntries(LastVendLedgerEntryNo, true);

        // [THEN] The three vendor ledger entries will be created
        VerifyVendLedgerEntryCount(LastVendLedgerEntryNo, 3);

        // [THEN] The error will occurs when attempting to unapply vendor ledger entries
        VerifyErrors();
    end;

    [Test]
    procedure CancelApplicationOfVendorLedgerEntryForClosedAdvanceLetter()
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        LastVendLedgerEntryNo: Integer;
    begin
        // [SCENARIO] Cancellation of application of vendor ledger entry for closed advance letter must fail
        Initialize();

        LastVendLedgerEntryNo := GetLastVendLedgerEntryNo();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        LibraryPurchAdvancesCZZ.ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Purchase advance letter has been closed
        LibraryPurchAdvancesCZZ.ClosePurchAdvanceLetter(PurchAdvLetterHeaderCZZ);
        Commit();

        // [WHEN] Unapply all vendor ledger entries created by advance payment
        UnApplyVendLedgerEntries(LastVendLedgerEntryNo, true);

        // [THEN] The five vendor ledger entries will be created
        VerifyVendLedgerEntryCount(LastVendLedgerEntryNo, 5);

        // [THEN] The error will occurs when attempting to unapply vendor ledger entries
        VerifyErrors();
    end;

    [Test]
    procedure CancelApplicationOfVendorLedgerEntryForUnappliedPaymentFromAdvanceLetter()
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        LastVendLedgerEntryNo: Integer;
    begin
        // [SCENARIO] Cancellation of application of vendor ledger entry for an unapplied payment from advance letter must fail
        Initialize();

        LastVendLedgerEntryNo := GetLastVendLedgerEntryNo();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        LibraryPurchAdvancesCZZ.ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Purchase advance payment has been unlinked
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", Enum::"Advance Letter Entry Type CZZ"::Payment);
        PurchAdvLetterEntryCZZ.FindFirst();
        LibraryPurchAdvancesCZZ.UnlinkPurchAdvancePayment(PurchAdvLetterEntryCZZ);
        Commit();

        // [WHEN] Unapply all vendor ledger entries created by advance payment
        UnApplyVendLedgerEntries(LastVendLedgerEntryNo, true);

        // [THEN] The five vendor ledger entries will be created
        VerifyVendLedgerEntryCount(LastVendLedgerEntryNo, 5);

        // [THEN] The error will occurs when attempting to unapply vendor ledger entries
        VerifyErrors();
    end;

    [Test]
    procedure CancelApplicationOfVendorLedgerEntryForReappliedPaymentToAdvanceLetter()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        LastVendLedgerEntryNo: Integer;
    begin
        // [SCENARIO] Cancellation of application of vendor ledger entry for a reapplied payment to advance letter must fail
        Initialize();

        LastVendLedgerEntryNo := GetLastVendLedgerEntryNo();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        LibraryPurchAdvancesCZZ.ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Purchase advance payment has been unlinked
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", Enum::"Advance Letter Entry Type CZZ"::Payment);
        PurchAdvLetterEntryCZZ.FindFirst();
        LibraryPurchAdvancesCZZ.UnlinkPurchAdvancePayment(PurchAdvLetterEntryCZZ);

        // [GIVEN] Purchase advance payment has been relinked to advance letter
        VendorLedgerEntry.Reset();
        VendorLedgerEntry.SetFilter("Entry No.", '>%1', LastVendLedgerEntryNo);
        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Payment);
        VendorLedgerEntry.SetRange(Open, true);
        VendorLedgerEntry.FindLast();
        LibraryPurchAdvancesCZZ.LinkPurchAdvancePayment(PurchAdvLetterHeaderCZZ, VendorLedgerEntry);
        Commit();

        // [WHEN] Unapply all vendor ledger entries created by advance payment
        UnApplyVendLedgerEntries(LastVendLedgerEntryNo, true);

        // [THEN] The seven vendor ledger entries will be created
        VerifyVendLedgerEntryCount(LastVendLedgerEntryNo, 7);

        // [THEN] The error will occurs when attempting to unapply vendor ledger entries
        VerifyErrors();
    end;

    [Test]
    procedure CancelApplicationOfVendorLedgerEntryForLinkedAdvanceLetterToInvoice()
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LastVendLedgerEntryNo: Integer;
    begin
        // [SCENARIO] Cancellation of application of vendor ledger entry for a linked advance letter to invoice must fail
        Initialize();

        LastVendLedgerEntryNo := GetLastVendLedgerEntryNo();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        LibraryPurchAdvancesCZZ.ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Purchase invoice has been created
        // [GIVEN] Purchase invoice line has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Posting Date",
            PurchAdvLetterLineCZZ."VAT Bus. Posting Group", PurchAdvLetterLineCZZ."VAT Prod. Posting Group", '', 0,
            true, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Whole advance letter has been linked to Purch invoice
        LibraryPurchAdvancesCZZ.LinkPurchAdvanceLetterToDocument(
            PurchAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice", PurchaseHeader."No.",
            PurchAdvLetterLineCZZ."Amount Including VAT", PurchAdvLetterLineCZZ."Amount Including VAT (LCY)");

        // [GIVEN] Purchase invoice has been posted
        PostPurchaseDocument(PurchaseHeader);
        Commit();

        // [WHEN] Unapply all vendor ledger entries created by advance payment
        UnApplyVendLedgerEntries(LastVendLedgerEntryNo, true);

        // [THEN] The seven vendor ledger entries will be created
        VerifyVendLedgerEntryCount(LastVendLedgerEntryNo, 6);

        // [THEN] The error will occurs when attempting to unapply vendor ledger entries
        VerifyErrors();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure CancelApplicationOfVendLedgerEntryForUnlinkedAdvanceLetterFromInvoice()
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchInvHeader: Record "Purch. Inv. Header";
        PostedDocumentNo: Code[20];
        LastVendLedgerEntryNo: Integer;
    begin
        // [SCENARIO] Cancellation of application of vendor ledger entry for an unlinked advance letter to invoice must fail
        Initialize();

        LastVendLedgerEntryNo := GetLastVendLedgerEntryNo();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        LibraryPurchAdvancesCZZ.ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Purchase invoice has been created
        // [GIVEN] Purchase invoice line has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Posting Date",
            PurchAdvLetterLineCZZ."VAT Bus. Posting Group", PurchAdvLetterLineCZZ."VAT Prod. Posting Group", '', 0,
            true, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Whole advance letter has been linked to purchase invoice
        LibraryPurchAdvancesCZZ.LinkPurchAdvanceLetterToDocument(
            PurchAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Purchase invoice", PurchaseHeader."No.",
            PurchAdvLetterLineCZZ."Amount Including VAT", PurchAdvLetterLineCZZ."Amount Including VAT (LCY)");

        // [GIVEN] Purchase invoice has been posted
        PostedDocumentNo := PostPurchaseDocument(PurchaseHeader);

        // [GIVEN] Unlink purchase advance letter from posted purchase invoice
        PurchInvHeader.Get(PostedDocumentNo);
        SetExpectedConfirm(StrSubstNo(UnapplyAdvLetterQst, PurchAdvLetterHeaderCZZ."No."), true);
        LibraryPurchAdvancesCZZ.UnapplyAdvanceLetter(PurchInvHeader);
        Commit();

        // [WHEN] Unapply all vendor ledger entries created by advance payment
        UnApplyVendLedgerEntries(LastVendLedgerEntryNo, true);

        // [THEN] The seven vendor ledger entries will be created
        VerifyVendLedgerEntryCount(LastVendLedgerEntryNo, 8);

        // [THEN] The error will occurs when attempting to unapply vendor ledger entries
        VerifyErrors();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure CancelApplicationOfVendLedgerEntryForRelinkedAdvanceLetterToInvoice()
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchInvHeader: Record "Purch. Inv. Header";
        PostedDocumentNo: Code[20];
        LastVendLedgerEntryNo: Integer;
    begin
        // [SCENARIO] Cancellation of application of vendor ledger entry for a relinked advance letter to invoice must fail
        Initialize();

        LastVendLedgerEntryNo := GetLastVendLedgerEntryNo();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ);

        // [GIVEN] Purchase advance letter has been released
        LibraryPurchAdvancesCZZ.ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Purchase invoice has been created
        // [GIVEN] Purchase invoice line has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Posting Date",
            PurchAdvLetterLineCZZ."VAT Bus. Posting Group", PurchAdvLetterLineCZZ."VAT Prod. Posting Group", '', 0,
            true, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Whole advance letter has been linked to purchase invoice
        LibraryPurchAdvancesCZZ.LinkPurchAdvanceLetterToDocument(
            PurchAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice", PurchaseHeader."No.",
            PurchAdvLetterLineCZZ."Amount Including VAT", PurchAdvLetterLineCZZ."Amount Including VAT (LCY)");

        // [GIVEN] Purchase invoice has been posted
        PostedDocumentNo := PostPurchaseDocument(PurchaseHeader);

        // [GIVEN] Unlink purchase advance letter from posted purchase invoice
        PurchInvHeader.Get(PostedDocumentNo);
        SetExpectedConfirm(StrSubstNo(UnapplyAdvLetterQst, PurchAdvLetterHeaderCZZ."No."), true);
        LibraryPurchAdvancesCZZ.UnapplyAdvanceLetter(PurchInvHeader);

        // [GIVEN] Link advance letter to posted purchase invoice
        SetExpectedConfirm(ApplyAdvanceLetterQst, true);
        LibraryPurchAdvancesCZZ.ApplyPurchAdvanceLetter(PurchAdvLetterHeaderCZZ, PurchInvHeader);
        Commit();

        // [WHEN] Unapply all vendor ledger entries created by advance payment
        UnApplyVendLedgerEntries(LastVendLedgerEntryNo, true);

        // [THEN] The seven vendor ledger entries will be created
        VerifyVendLedgerEntryCount(LastVendLedgerEntryNo, 10);

        // [THEN] The error will occurs when attempting to unapply vendor ledger entries
        VerifyErrors();
    end;

    [Test]
    [HandlerFunctions('CreatePurchAdvLetterHandler,ConfirmHandler')]
    procedure CreatePurchAdvanceLetterFromOrderFor100Per()
    begin
        // [SCENARIO] Create purchase advance letter from order for 100% of amount
        // [GIVEN] Purchase order has been created
        // [GIVEN] Purchase order line has been created
        // [GIVEN] Purchase advance letter for 100% has been created from order
        // [WHEN] Release purchase advance letter
        // [THEN] Purchase advance letter will be created for 100% of order amount
        // [THEN] Purchase advance letter will be linked with purchase order
        CreatePurchAdvanceLetterFromOrderForAdvancePer(100);
    end;

    [Test]
    [HandlerFunctions('CreatePurchAdvLetterHandler,ConfirmHandler')]
    procedure CreatePurchAdvanceLetterFromOrderFor80Per()
    begin
        // [SCENARIO] Create purchase advance letter from order for 80% of amount
        // [GIVEN] Purchase order has been created
        // [GIVEN] Purchase order line has been created
        // [GIVEN] Purchase advance letter for 80% has been created from order
        // [WHEN] Release purchase advance letter
        // [THEN] Purchase advance letter will be created for 80% of order amount
        // [THEN] Purchase advance letter will be linked with purchase order
        CreatePurchAdvanceLetterFromOrderForAdvancePer(80);
    end;

    procedure CreatePurchAdvanceLetterFromOrderForAdvancePer(AdvancePer: Decimal)
    var
        Currency: Record Currency;
        TempAdvanceLetterApplication: Record "Advance Letter Application CZZ" temporary;
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        AdvanceAmount: Decimal;
    begin
        Initialize();

        LibraryPurchAdvancesCZZ.CreatePurchOrder(PurchaseHeader, PurchaseLine);
        PurchaseHeader.CalcFields("Amount Including VAT");

        SetExpectedConfirm(OpenAdvanceLetterQst, false);
        CreatePurchAdvLetterFromOrderWithAdvancePer(PurchaseHeader, AdvanceLetterTemplateCZZ.Code, AdvancePer, false, PurchAdvLetterHeaderCZZ);
        Currency.InitRoundingPrecision();
        AdvanceAmount := Round(PurchaseHeader."Amount Including VAT" * (AdvancePer / 100), Currency."Amount Rounding Precision");

        LibraryPurchAdvancesCZZ.ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        PurchAdvLetterHeaderCZZ.TestField("Amount Including VAT", AdvanceAmount);
        PurchAdvLetterHeaderCZZ.TestField(Status, PurchAdvLetterHeaderCZZ.Status::"To Pay");

        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"Initial Entry");
        PurchAdvLetterEntryCZZ.SetRange(Amount, -AdvanceAmount);
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        TempAdvanceLetterApplication.GetAssignedAdvance(Enum::"Adv. Letter Usage Doc.Type CZZ"::"Purchase Order", PurchaseHeader."No.", TempAdvanceLetterApplication);
        TempAdvanceLetterApplication.SetRange("Advance Letter Type", Enum::"Advance Letter Type CZZ"::Purchase);
        TempAdvanceLetterApplication.SetRange("Advance Letter No.", PurchAdvLetterHeaderCZZ."No.");
        TempAdvanceLetterApplication.SetRange(Amount, AdvanceAmount);
        Assert.RecordIsNotEmpty(TempAdvanceLetterApplication);
    end;

    [Test]
    [HandlerFunctions('CreatePurchAdvLetterHandler,ConfirmHandler')]
    procedure CreatePurchAdvanceLetterFromOrderForAdvanceAmount()
    var
        Currency: Record Currency;
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        AdvanceAmount: Decimal;
    begin
        // [SCENARIO] Create purchase advance letter from order for specified advance amount
        Initialize();

        // [GIVEN] Purchase order has been created
        // [GIVEN] Purchase order line has been created
        LibraryPurchAdvancesCZZ.CreatePurchOrder(PurchaseHeader, PurchaseLine);
        PurchaseHeader.CalcFields("Amount Including VAT");

        // [GIVEN] Purchase advance letter for specified amount has been created from order
        Currency.InitRoundingPrecision();
        AdvanceAmount := Round(PurchaseHeader."Amount Including VAT" * (LibraryRandom.RandIntInRange(1, 99) / 100), Currency."Amount Rounding Precision");
        SetExpectedConfirm(OpenAdvanceLetterQst, false);
        CreatePurchAdvLetterFromOrderWithAdvanceAmount(PurchaseHeader, AdvanceLetterTemplateCZZ.Code, AdvanceAmount, false, PurchAdvLetterHeaderCZZ);

        // [WHEN] Release purchase advance letter
        LibraryPurchAdvancesCZZ.ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [THEN] Purchase advance letter will be created for specified amount of order
        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        PurchAdvLetterHeaderCZZ.TestField("Amount Including VAT", AdvanceAmount);
        PurchAdvLetterHeaderCZZ.TestField(Status, PurchAdvLetterHeaderCZZ.Status::"To Pay");

        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"Initial Entry");
        PurchAdvLetterEntryCZZ.SetRange(Amount, -AdvanceAmount);
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);
    end;

    [Test]
    [HandlerFunctions('CreatePurchAdvLetterHandler,ConfirmHandler')]
    procedure CreatePurchAdvanceLetterFromOrderByLines()
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine1: Record "Purchase Line";
        PurchaseLine2: Record "Purchase Line";
        PurchaseLine3: Record "Purchase Line";
    begin
        // [SCENARIO] Create purchase advance letter from order by lines
        Initialize();

        // [GIVEN] Purchase order has been created
        // [GIVEN] First purchase order line has been created
        LibraryPurchAdvancesCZZ.CreatePurchOrder(PurchaseHeader, PurchaseLine1);

        // [GIVEN] Second purchase order line has been created
        LibraryPurchase.CreatePurchaseLine(
          PurchaseLine2, PurchaseHeader, PurchaseLine2.Type::"G/L Account", PurchaseLine1."No.", 1);
        PurchaseLine2.Validate("Direct Unit Cost", LibraryRandom.RandDec(1000, 2));
        PurchaseLine2.Modify(true);

        // [GIVEN] Third purchase order line has been created
        LibraryPurchase.CreatePurchaseLine(
          PurchaseLine3, PurchaseHeader, PurchaseLine3.Type::"G/L Account", PurchaseLine1."No.", 1);
        PurchaseLine3.Validate("Direct Unit Cost", LibraryRandom.RandDec(1000, 2));
        PurchaseLine3.Modify(true);

        // [WHEN] Create purchase advance letter from order and suggest by lines
        SetExpectedConfirm(OpenAdvanceLetterQst, false);
        CreatePurchAdvLetterFromOrderWithAdvancePer(PurchaseHeader, AdvanceLetterTemplateCZZ.Code, 100, true, PurchAdvLetterHeaderCZZ);

        // [THEN] Purchase advance letter will have the same lines as purchase order
        PurchAdvLetterLineCZZ.SetRange("Document No.", PurchAdvLetterHeaderCZZ."No.");
        Assert.RecordCount(PurchAdvLetterLineCZZ, 3);

        // [THEN] Separate purchase advance line will be created for each line from purchase order
        PurchAdvLetterLineCZZ.SetRange("Line No.", PurchaseLine1."Line No.");
        PurchAdvLetterLineCZZ.SetRange("Amount Including VAT", PurchaseLine1."Amount Including VAT");
        Assert.RecordIsNotEmpty(PurchAdvLetterLineCZZ);

        PurchAdvLetterLineCZZ.SetRange("Line No.", PurchaseLine2."Line No.");
        PurchAdvLetterLineCZZ.SetRange("Amount Including VAT", PurchaseLine2."Amount Including VAT");
        Assert.RecordIsNotEmpty(PurchAdvLetterLineCZZ);

        PurchAdvLetterLineCZZ.SetRange("Line No.", PurchaseLine3."Line No.");
        PurchAdvLetterLineCZZ.SetRange("Amount Including VAT", PurchaseLine3."Amount Including VAT");
        Assert.RecordIsNotEmpty(PurchAdvLetterLineCZZ);
    end;

    [Test]
    procedure LinkUnpaidAdvanceLetterToPurchOrder()
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        TempAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ" temporary;
    begin
        // [SCENARIO] Link unpaid purchase advance letter to purchase order
        Initialize();

        // [GIVEN] Purchase order has been created
        // [GIVEN] Purchase order line has been created
        LibraryPurchAdvancesCZZ.CreatePurchOrder(PurchaseHeader, PurchaseLine);

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetterWithVendor(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ, PurchaseHeader."Pay-to Vendor No.");

        // [GIVEN] Purchase advance letter has been released
        LibraryPurchAdvancesCZZ.ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [WHEN] Get list of advance letter available for linking
        TempAdvanceLetterApplicationCZZ.GetPossiblePurchAdvance(
            Enum::"Adv. Letter Usage Doc.Type CZZ"::"Purchase Order", PurchaseHeader."No.", PurchaseHeader."Pay-to Vendor No.",
            PurchaseHeader."Posting Date", PurchaseHeader."Currency Code", TempAdvanceLetterApplicationCZZ);

        // [THEN] Purchase advance letter won't be available for linking
        TempAdvanceLetterApplicationCZZ.SetRange("Advance Letter Type", Enum::"Advance Letter Type CZZ"::Purchase);
        TempAdvanceLetterApplicationCZZ.SetRange("Advance Letter No.", PurchAdvLetterHeaderCZZ."No.");
        Assert.RecordIsEmpty(TempAdvanceLetterApplicationCZZ);
    end;

    [Test]
    procedure LinkPaidAdvanceLetterToPurchOrder()
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        TempAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ" temporary;
    begin
        // [SCENARIO] Link paid purchase advance letter to purchase order
        Initialize();

        // [GIVEN] Purchase order has been created
        // [GIVEN] Purchase order line has been created
        LibraryPurchAdvancesCZZ.CreatePurchOrder(PurchaseHeader, PurchaseLine);

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetterWithVendor(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ, PurchaseHeader."Pay-to Vendor No.");

        // [GIVEN] Purchase advance letter has been released
        LibraryPurchAdvancesCZZ.ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [WHEN] Get list of advance letter available for linking
        TempAdvanceLetterApplicationCZZ.GetPossiblePurchAdvance(
            Enum::"Adv. Letter Usage Doc.Type CZZ"::"Purchase Order", PurchaseHeader."No.", PurchaseHeader."Pay-to Vendor No.",
            PurchaseHeader."Posting Date", PurchaseHeader."Currency Code", TempAdvanceLetterApplicationCZZ);

        // [THEN] Purchase advance letter will be available for linking
        TempAdvanceLetterApplicationCZZ.SetRange("Advance Letter Type", Enum::"Advance Letter Type CZZ"::Purchase);
        TempAdvanceLetterApplicationCZZ.SetRange("Advance Letter No.", PurchAdvLetterHeaderCZZ."No.");
        Assert.RecordIsNotEmpty(TempAdvanceLetterApplicationCZZ);
    end;

    [Test]
    [HandlerFunctions('CreatePurchAdvLetterHandler,ConfirmHandler')]
    procedure CloseLinkedAdvanceLetterWithPurchOrder()
    var
        TempAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ" temporary;
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        // [SCENARIO] Close linked purchase advance letter with purchase order
        Initialize();

        // [GIVEN] Purchase order has been created
        // [GIVEN] Purchase order line has been created
        LibraryPurchAdvancesCZZ.CreatePurchOrder(PurchaseHeader, PurchaseLine);

        // [GIVEN] Purchase advance letter for 100% has been created from order
        SetExpectedConfirm(OpenAdvanceLetterQst, false);
        CreatePurchAdvLetterFromOrderWithAdvancePer(PurchaseHeader, AdvanceLetterTemplateCZZ.Code, 100, false, PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been released
        LibraryPurchAdvancesCZZ.ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [WHEN] Close purchase advance letter
        LibraryPurchAdvancesCZZ.ClosePurchAdvanceLetter(PurchAdvLetterHeaderCZZ);

        // [THEN] Purchase advance letter won't be linked with purchase order
        TempAdvanceLetterApplicationCZZ.GetAssignedAdvance(
            Enum::"Adv. Letter Usage Doc.Type CZZ"::"Purchase Order", PurchaseHeader."No.", TempAdvanceLetterApplicationCZZ);
        TempAdvanceLetterApplicationCZZ.Reset();
        Assert.RecordIsEmpty(TempAdvanceLetterApplicationCZZ);
    end;

    [Test]
    [HandlerFunctions('CreatePurchAdvLetterHandler,ConfirmHandler')]
    procedure AdvancePaymentByCashDesk()
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        // [SCENARIO] Advance payment by cash desk
        Initialize();

        // [GIVEN] Purchase order has been created
        // [GIVEN] Purchase order line has been created
        LibraryPurchAdvancesCZZ.CreatePurchOrder(PurchaseHeader, PurchaseLine);

        // [GIVEN] Purchase advance letter for 100% has been created from order
        SetExpectedConfirm(OpenAdvanceLetterQst, false);
        CreatePurchAdvLetterFromOrderWithAdvancePer(PurchaseHeader, AdvanceLetterTemplateCZZ.Code, 100, false, PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been released
        LibraryPurchAdvancesCZZ.ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Cash document has been created
        CreateCashDocument(CashDocumentHeaderCZP, CashDocumentLineCZP,
            Enum::"Cash Document Type CZP"::Withdrawal, PurchAdvLetterHeaderCZZ);

        // [WHEN] Post cash document
        SetExpectedConfirm(StrSubstNo(PostCashDocumentQst, CashDocumentHeaderCZP."No."), true);
        PostCashDocument(CashDocumentHeaderCZP);

        // [THEN] Purchase advance letter will be paid in full by cash document
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Payment);
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        // [THEN] Purchase advance letter will be to use
        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterHeaderCZZ.TestField(Status, PurchAdvLetterHeaderCZZ.Status::"To Use");
    end;

    [Test]
    [HandlerFunctions('CreatePurchAdvLetterHandler,ConfirmHandler,ModalVATDocumentHandler')]
    procedure PurchInvoiceWithAdvanceLetterPostedFromPurchOrder()
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VATEntry: Record "VAT Entry";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Purchase invoice with advance letter posted from purchase order
        Initialize();

        // [GIVEN] Purchase order has been created
        // [GIVEN] Purchase order line has been created
        LibraryPurchAdvancesCZZ.CreatePurchOrder(PurchaseHeader, PurchaseLine);

        // [GIVEN] Purchase advance letter for 100% has been created from order
        SetExpectedConfirm(OpenAdvanceLetterQst, false);
        CreatePurchAdvLetterFromOrderWithAdvancePer(PurchaseHeader, AdvanceLetterTemplateCZZ.Code, 100, false, PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been released
        LibraryPurchAdvancesCZZ.ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Cash document has been created
        CreateCashDocument(CashDocumentHeaderCZP, CashDocumentLineCZP,
            Enum::"Cash Document Type CZP"::Withdrawal, PurchAdvLetterHeaderCZZ);

        // [GIVEN] Cash document has been posted
        SetExpectedConfirm(StrSubstNo(PostCashDocumentQst, CashDocumentHeaderCZP."No."), true);
        PostCashDocument(CashDocumentHeaderCZP);

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [WHEN] Post purchase order
        PostedDocumentNo := PostPurchaseDocument(PurchaseHeader);

        // [THEN] VAT entries of purchase invoice and advance letter will exist
        VATEntry.Reset();
        VATEntry.SetRange("Document No.", PostedDocumentNo);
        VATEntry.SetRange("Posting Date", PurchaseHeader."Posting Date");
        Assert.RecordIsNotEmpty(VATEntry);

        // [THEN] Sum of base and VAT amounts in VAT entries will be zero
        VATEntry.CalcSums(Base, Amount);
        Assert.AreEqual(0, VATEntry.Base, 'The sum of base amount in VAT Entries must be zero.');
        Assert.AreEqual(0, VATEntry.Amount, 'The sum of VAT amount in VAT Entries must be zero.');

        // [THEN] Purchase advance letter will exist
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        // [THEN] Sum of base and VAT amounts in advance letter entries will be zero
        PurchAdvLetterEntryCZZ.CalcSums("VAT Base Amount", "VAT Amount");
        Assert.AreEqual(0, PurchAdvLetterEntryCZZ."VAT Base Amount", 'The sum of base amount in advance letter entries must be zero.');
        Assert.AreEqual(0, PurchAdvLetterEntryCZZ."VAT Amount", 'The sum of VAT amount in VAT advance letter must be zero.');

        // [THEN] Purchase advance letter will be closed
        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterHeaderCZZ.TestField(Status, PurchAdvLetterHeaderCZZ.Status::Closed);
    end;

    [Test]
    [HandlerFunctions('CreatePurchAdvLetterHandler,ConfirmHandler,ModalVATDocumentHandler')]
    procedure AdvancePaymentWithLaterDateThanOrderDate()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        TempAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ" temporary;
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Advance payment with later date than order date
        Initialize();

        // [GIVEN] Purchase order has been created
        // [GIVEN] Purchase order line has been created
        LibraryPurchAdvancesCZZ.CreatePurchOrder(PurchaseHeader, PurchaseLine);

        // [GIVEN] Purchase advance letter for 100% has been created from order
        SetExpectedConfirm(OpenAdvanceLetterQst, false);
        CreatePurchAdvLetterFromOrderWithAdvancePer(PurchaseHeader, AdvanceLetterTemplateCZZ.Code, 100, false, PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been released
        LibraryPurchAdvancesCZZ.ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT", 0, WorkDate() + 1);

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [WHEN] Post purchase order
        SetExpectedConfirm(StrSubstNo(LaterAdvancePaymentQst, PurchAdvLetterHeaderCZZ."No.", PurchaseHeader."Posting Date"), true);
        PostedDocumentNo := PostPurchaseDocument(PurchaseHeader);

        // [THEN] Vendor ledger entry created by invoice will be unapplied
        VendorLedgerEntry.SetRange("Document No.", PostedDocumentNo);
        VendorLedgerEntry.FindLast();
        VendorLedgerEntry.CalcFields("Remaining Amount");
        Assert.AreNotEqual(0, VendorLedgerEntry."Remaining Amount", 'The remaining amount in vendor ledger entry must be not zero.');

        // [THEN] Purchase advance lettere won't be deducted
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Usage);
        Assert.RecordIsEmpty(PurchAdvLetterEntryCZZ);

        TempAdvanceLetterApplicationCZZ.GetAssignedAdvance(Enum::"Adv. Letter Usage Doc.Type CZZ"::"Purchase Order", PurchaseHeader."No.", TempAdvanceLetterApplicationCZZ);
        Assert.RecordIsEmpty(TempAdvanceLetterApplicationCZZ);

        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterHeaderCZZ.TestField(Status, PurchAdvLetterHeaderCZZ.Status::"To Use");
    end;

    [Test]
    [HandlerFunctions('CreatePurchAdvLetterHandler,ConfirmHandler')]
    procedure NoticeToUnpaidPurchAdvanceLetter()
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        // [SCENARIO] Notice to unpaid purchase advance letter
        Initialize();

        // [GIVEN] Purchase order has been created
        // [GIVEN] Purchase order line has been created
        LibraryPurchAdvancesCZZ.CreatePurchOrder(PurchaseHeader, PurchaseLine);

        // [GIVEN] Purchase advance letter for 100% has been created from order
        SetExpectedConfirm(OpenAdvanceLetterQst, false);
        CreatePurchAdvLetterFromOrderWithAdvancePer(PurchaseHeader, AdvanceLetterTemplateCZZ.Code, 100, false, PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been released
        LibraryPurchAdvancesCZZ.ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [WHEN] Post purchase order
        SetExpectedConfirm(StrSubstNo(UsageNoPossibleQst), true);
        PostPurchaseDocument(PurchaseHeader);

        // [THEN] Confirm handler will be called
    end;

    [Test]
    [HandlerFunctions('CreatePurchAdvLetterHandler,ConfirmHandler,ModalVATDocumentHandler')]
    procedure DeductAdvanceLetterByQuantityToInvoice()
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchaseLine: Record "Purchase Line";
        VATEntry: Record "VAT Entry";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Deduct advance letter by quantity to invoice
        Initialize();

        // [GIVEN] Purchase order has been created
        // [GIVEN] Purchase order line has been created
        LibraryPurchAdvancesCZZ.CreatePurchOrder(PurchaseHeader, PurchaseLine);

        // [GIVEN] Purchase advance letter for 100% has been created from order
        SetExpectedConfirm(OpenAdvanceLetterQst, false);
        CreatePurchAdvLetterFromOrderWithAdvancePer(PurchaseHeader, AdvanceLetterTemplateCZZ.Code, 100, false, PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been released
        LibraryPurchAdvancesCZZ.ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] "Qty. to Invoice" and "Qty. to Ship" fields in purchase order line have been modified to 1
        PurchaseLine.Validate("Qty. to Invoice", 1);
        PurchaseLine.Validate("Qty. to Receive", 1);
        PurchaseLine.Modify(true);

        // [WHEN] Post Purch order
        PostedDocumentNo := PostPurchaseDocument(PurchaseHeader);

        // [THEN] VAT entries of Purch invoice and advance letter will exist
        VATEntry.Reset();
        VATEntry.SetRange("Document No.", PostedDocumentNo);
        VATEntry.SetRange("Posting Date", PurchaseHeader."Posting Date");
        Assert.RecordIsNotEmpty(VATEntry);

        // [THEN] Sum of base and VAT amounts in VAT entries will be zero
        VATEntry.CalcSums(Base, Amount);
        Assert.AreEqual(0, VATEntry.Base, 'The sum of base amount in VAT Entries must be zero.');
        Assert.AreEqual(0, VATEntry.Amount, 'The sum of VAT amount in VAT Entries must be zero.');

        // [THEN] Purchase advance letter entry with usage will exist
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Document No.", PostedDocumentNo);
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Usage);
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        PurchInvHeader.Get(PostedDocumentNo);
        PurchInvHeader.CalcFields("Amount Including VAT");
        PurchAdvLetterEntryCZZ.FindFirst();
        PurchAdvLetterEntryCZZ.TestField(Amount, -PurchInvHeader."Amount Including VAT");

        // [THEN] Purchase advance letter will be to use
        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterHeaderCZZ.TestField(Status, PurchAdvLetterHeaderCZZ.Status::"To Use");
    end;

    [Test]
    [HandlerFunctions('CreatePurchAdvLetterHandler,ConfirmHandler,ModalVATDocumentHandler')]
    procedure NegativeLineInPurchOrder()
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine1: Record "Purchase Line";
        PurchaseLine2: Record "Purchase Line";
        VATEntry: Record "VAT Entry";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Negative line in purchase order
        Initialize();

        // [GIVEN] Purchase order has been created
        // [GIVEN] Purchase order line has been created
        LibraryPurchAdvancesCZZ.CreatePurchOrder(PurchaseHeader, PurchaseLine1);

        // [GIVEN] Second purchase order line has been created
        LibraryPurchase.CreatePurchaseLine(
          PurchaseLine2, PurchaseHeader, PurchaseLine2.Type::"G/L Account", PurchaseLine1."No.", -1);
        PurchaseLine2.Validate("Direct Unit Cost", PurchaseLine1."Direct Unit Cost" / 2);
        PurchaseLine2.Modify(true);

        // [GIVEN] Purchase advance letter for 100% has been created from order
        SetExpectedConfirm(OpenAdvanceLetterQst, false);
        CreatePurchAdvLetterFromOrderWithAdvancePer(PurchaseHeader, AdvanceLetterTemplateCZZ.Code, 100, false, PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been released
        LibraryPurchAdvancesCZZ.ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [WHEN] Post purchase order
        PostedDocumentNo := PostPurchaseDocument(PurchaseHeader);

        // [THEN] VAT entries of purchase invoice and advance letter will exist
        VATEntry.Reset();
        VATEntry.SetRange("Document No.", PostedDocumentNo);
        VATEntry.SetRange("Posting Date", PurchaseHeader."Posting Date");
        Assert.RecordIsNotEmpty(VATEntry);

        // [THEN] Sum of base and VAT amounts in VAT entries will be zero
        VATEntry.CalcSums(Base, Amount);
        Assert.AreNearlyEqual(0, VATEntry.Base, 0.1, 'The sum of base amount in VAT Entries must be zero.');
        Assert.AreNearlyEqual(0, VATEntry.Amount, 0.1, 'The sum of VAT amount in VAT Entries must be zero.');

        // [THEN] Purchase advance letter will exist
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ);

        // [THEN] Sum of base and VAT amounts in advance letter entries will be zero
        PurchAdvLetterEntryCZZ.CalcSums("VAT Base Amount", "VAT Amount");
        Assert.AreEqual(0, PurchAdvLetterEntryCZZ."VAT Base Amount", 'The sum of base amount in advance letter entries must be zero.');
        Assert.AreEqual(0, PurchAdvLetterEntryCZZ."VAT Amount", 'The sum of VAT amount in VAT advance letter must be zero.');

        // [THEN] Purchase advance letter will be closed
        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterHeaderCZZ.TestField(Status, PurchAdvLetterHeaderCZZ.Status::Closed);
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure VATPaymentToPurchAdvLetterWithTwoVATRates()
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ1: Record "Purch. Adv. Letter Line CZZ";
        PurchAdvLetterLineCZZ2: Record "Purch. Adv. Letter Line CZZ";
        PurchAdvLetterEntryCZZ1: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        // [SCENARIO] VAT payment to purchase advance letter with two VAT rates
        Initialize();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ1);

        // [GIVEN] Second purchase advance letter line with normal VAT has been created
        FindNextVATPostingSetup(VATPostingSetup);
        LibraryPurchAdvancesCZZ.CreatePurchAdvLetterLine(
            PurchAdvLetterLineCZZ2, PurchAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ."Amount Including VAT");

        // [WHEN] Post purchase advance payment VAT
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [THEN] Two purchase advance letter entries of "VAT Payment" type will exist
        PurchAdvLetterEntryCZZ1.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ1.SetRange("Entry Type", PurchAdvLetterEntryCZZ1."Entry Type"::"VAT Payment");
        Assert.RecordCount(PurchAdvLetterEntryCZZ1, 2);

        // [THEN] Sum of amounts in purchase advance letter entries will be the same as in entry with "Payment" type
        PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ2.SetRange("Entry Type", PurchAdvLetterEntryCZZ2."Entry Type"::Payment);
        PurchAdvLetterEntryCZZ2.FindLast();
        PurchAdvLetterEntryCZZ1.CalcSums(Amount);
        Assert.AreEqual(PurchAdvLetterEntryCZZ1.Amount, PurchAdvLetterEntryCZZ2.Amount, 'The sum of amounts in purchase advance letter entries must be the same as in entry with "Payment" type.');
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure UnlinkAdvancePaymentFromPurchAdvLetterWithTwoLines()
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ1: Record "Purch. Adv. Letter Line CZZ";
        PurchAdvLetterLineCZZ2: Record "Purch. Adv. Letter Line CZZ";
        PurchAdvLetterEntryCZZ1: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        // [SCENARIO] Unlink advance payment from purchase advance letter with two lines
        Initialize();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ1);

        // [GIVEN] Second purchase advance letter line with normal VAT has been created
        FindNextVATPostingSetup(VATPostingSetup);
        LibraryPurchAdvancesCZZ.CreatePurchAdvLetterLine(
            PurchAdvLetterLineCZZ2, PurchAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ."Amount Including VAT");

        // [GIVEN] Purchase advance payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [WHEN] Unlink advance letter from payment
        FindLastPaymentAdvanceLetterEntry(PurchAdvLetterHeaderCZZ."No.", PurchAdvLetterEntryCZZ1);
        LibraryPurchAdvancesCZZ.UnlinkPurchAdvancePayment(PurchAdvLetterEntryCZZ1);

        // [THEN] Purchase advance letter entries of "Payment" and "VAT Payment" type with opposite sign will exist
        PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ2.Find('+');
        Assert.AreEqual(PurchAdvLetterEntryCZZ2."Entry Type"::Payment, PurchAdvLetterEntryCZZ2."Entry Type", 'The purchase advance letter entry must be of type "Payment".');
        Assert.AreEqual(-PurchAdvLetterEntryCZZ1.Amount, PurchAdvLetterEntryCZZ2.Amount, 'The amount must have the opposite sign.');
        Assert.AreEqual(PurchAdvLetterEntryCZZ1."Entry No.", PurchAdvLetterEntryCZZ2."Related Entry", 'The entry must be related to entry of "Payment" type');

        PurchAdvLetterEntryCZZ2.Next(-1);
        Assert.AreEqual(PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Payment", PurchAdvLetterEntryCZZ2."Entry Type", 'The purchase advance letter entry must be of type "VAT Payment".');
        Assert.AreEqual(-PurchAdvLetterLineCZZ2."Amount Including VAT", PurchAdvLetterEntryCZZ2.Amount, 'The amount must have the opposite sign.');

        PurchAdvLetterEntryCZZ2.Next(-1);
        Assert.AreEqual(PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Payment", PurchAdvLetterEntryCZZ2."Entry Type", 'The purchase advance letter entry must be of type "VAT Payment".');
        Assert.AreEqual(-PurchAdvLetterLineCZZ1."Amount Including VAT", PurchAdvLetterEntryCZZ2.Amount, 'The amount must have the opposite sign.');

        PurchAdvLetterEntryCZZ2.SetFilter("Entry Type", '%1|%2',
            PurchAdvLetterEntryCZZ2."Entry Type"::Payment, PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
        PurchAdvLetterEntryCZZ2.CalcSums(Amount);
        Assert.AreEqual(0, PurchAdvLetterEntryCZZ2.Amount, 'The sum of amounts in purchase advance letter entries must be zero.');

        // [THEN] Purchase advance letter status will be "To Pay"
        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterHeaderCZZ.TestField(Status, PurchAdvLetterHeaderCZZ.Status::"To Pay");
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure CreatePurchAdvLetterWithTwoLinesAndLinkToInvoice()
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ1: Record "Purch. Adv. Letter Line CZZ";
        PurchAdvLetterLineCZZ2: Record "Purch. Adv. Letter Line CZZ";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VATEntry: Record "VAT Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Create purchase advance letter with two lines and link to invoice with line which is the same as first line in advance letter
        Initialize();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ1);

        // [GIVEN] Second purchase advance letter line with normal VAT has been created
        FindNextVATPostingSetup(VATPostingSetup);
        LibraryPurchAdvancesCZZ.CreatePurchAdvLetterLine(
            PurchAdvLetterLineCZZ2, PurchAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ."Amount Including VAT");

        // [GIVEN] Purchase advance payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase invoice has been created
        // [GIVEN] Purchase invoice line has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Posting Date",
            PurchAdvLetterLineCZZ1."VAT Bus. Posting Group", PurchAdvLetterLineCZZ1."VAT Prod. Posting Group", '', 0,
            true, PurchAdvLetterLineCZZ1."Amount Including VAT");

        // [GIVEN] Whole advance letter has been linked to purchase invoice
        LibraryPurchAdvancesCZZ.LinkPurchAdvanceLetterToDocument(
            PurchAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice", PurchaseHeader."No.",
            PurchAdvLetterLineCZZ1."Amount Including VAT", PurchAdvLetterLineCZZ1."Amount Including VAT (LCY)");

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

        // [THEN] Only one purchase advance letter entry of "VAT Usage" type will exist
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Usage");
        Assert.RecordCount(PurchAdvLetterEntryCZZ, 1);

        // [THEN] Sum of amounts in purchase advance letter entries of "VAT payment" and "VAT usage" type will be zero
        PurchAdvLetterEntryCZZ.FindFirst();
        PurchAdvLetterEntryCZZ.SetRange("VAT Bus. Posting Group", PurchAdvLetterEntryCZZ."VAT Bus. Posting Group");
        PurchAdvLetterEntryCZZ.SetRange("VAT Prod. Posting Group", PurchAdvLetterEntryCZZ."VAT Prod. Posting Group");
        PurchAdvLetterEntryCZZ.SetFilter("Entry Type", '%1|%2',
            PurchAdvLetterEntryCZZ."Entry Type"::"VAT Usage", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        PurchAdvLetterEntryCZZ.CalcSums(Amount);
        Assert.AreEqual(0, PurchAdvLetterEntryCZZ.Amount, 'The sum of amounts in purchase advance letter entries must be zero.');
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure CreatePurchAdvLetterWithTwoLinesAndLinkToInvoice2()
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ1: Record "Purch. Adv. Letter Line CZZ";
        PurchAdvLetterLineCZZ2: Record "Purch. Adv. Letter Line CZZ";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VATEntry: Record "VAT Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Create purchase advance letter with two lines and link to invoice with line which is the same as second line in advance letter
        Initialize();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ1);

        // [GIVEN] Second purchase advance letter line with normal VAT has been created
        FindNextVATPostingSetup(VATPostingSetup);
        LibraryPurchAdvancesCZZ.CreatePurchAdvLetterLine(
            PurchAdvLetterLineCZZ2, PurchAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ."Amount Including VAT");

        // [GIVEN] Purchase advance payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase invoice has been created
        // [GIVEN] Purchase invoice line has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Posting Date",
            PurchAdvLetterLineCZZ2."VAT Bus. Posting Group", PurchAdvLetterLineCZZ2."VAT Prod. Posting Group", '', 0,
            true, PurchAdvLetterLineCZZ2."Amount Including VAT");

        // [GIVEN] Whole advance letter has been linked to purchase invoice
        LibraryPurchAdvancesCZZ.LinkPurchAdvanceLetterToDocument(
            PurchAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice", PurchaseHeader."No.",
            PurchAdvLetterLineCZZ2."Amount Including VAT", PurchAdvLetterLineCZZ2."Amount Including VAT (LCY)");

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

        // [THEN] Only one purchase advance letter entry of "VAT Usage" type will exist
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Usage");
        Assert.RecordCount(PurchAdvLetterEntryCZZ, 1);

        // [THEN] Sum of amounts in purchase advance letter entries of "VAT payment" and "VAT usage" type will be zero
        PurchAdvLetterEntryCZZ.FindFirst();
        PurchAdvLetterEntryCZZ.SetRange("VAT Bus. Posting Group", PurchAdvLetterEntryCZZ."VAT Bus. Posting Group");
        PurchAdvLetterEntryCZZ.SetRange("VAT Prod. Posting Group", PurchAdvLetterEntryCZZ."VAT Prod. Posting Group");
        PurchAdvLetterEntryCZZ.SetFilter("Entry Type", '%1|%2',
            PurchAdvLetterEntryCZZ."Entry Type"::"VAT Usage", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        PurchAdvLetterEntryCZZ.CalcSums(Amount);
        Assert.AreEqual(0, PurchAdvLetterEntryCZZ.Amount, 'The sum of amounts in purchase advance letter entries must be zero.');
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure VATPaymentToPurchAdvLetterWithTwoVATRatesPartiallyPaid()
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ1: Record "Purch. Adv. Letter Line CZZ";
        PurchAdvLetterLineCZZ2: Record "Purch. Adv. Letter Line CZZ";
        PurchAdvLetterEntryCZZ1: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        // [SCENARIO] VAT payment to purchase advance letter with two VAT rates partially paid
        Initialize();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ1);

        // [GIVEN] Second purchase advance letter line with normal VAT has been created
        FindNextVATPostingSetup(VATPostingSetup);
        LibraryPurchAdvancesCZZ.CreatePurchAdvLetterLine(
            PurchAdvLetterLineCZZ2, PurchAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been half paid by the general journal
        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ,
            Round(PurchAdvLetterLineCZZ1."Amount Including VAT" / 2) +
            Round(PurchAdvLetterLineCZZ2."Amount Including VAT" / 2));

        // [WHEN] Post purchase advance payment VAT
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [THEN] Two purchase advance letter entries of "VAT Payment" type will exist
        PurchAdvLetterEntryCZZ1.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ1.SetRange("Entry Type", PurchAdvLetterEntryCZZ1."Entry Type"::"VAT Payment");
        Assert.RecordCount(PurchAdvLetterEntryCZZ1, 2);

        // [THEN] Sum of amounts in purchase advance letter entries will be the same as in entry with "Payment" type
        PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ2.SetRange("Entry Type", PurchAdvLetterEntryCZZ2."Entry Type"::Payment);
        PurchAdvLetterEntryCZZ2.FindLast();
        PurchAdvLetterEntryCZZ1.CalcSums(Amount);
        Assert.AreEqual(PurchAdvLetterEntryCZZ1.Amount, PurchAdvLetterEntryCZZ2.Amount, 'The sum of amounts in purchase advance letter entries must be the same as in entry with "Payment" type.');
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure CreatePurchAdvLetterWithTwoLinesAndLinkToInvoiceWithLowerAmount()
    var
        GLAccount: Record "G/L Account";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ1: Record "Purch. Adv. Letter Line CZZ";
        PurchAdvLetterLineCZZ2: Record "Purch. Adv. Letter Line CZZ";
        PurchAdvLetterEntryCZZ1: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine1: Record "Purchase Line";
        PurchaseLine2: Record "Purchase Line";
        VATEntry: Record "VAT Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Create purchase advance letter with two lines and link to invoice with amount lower than advance letter
        Initialize();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ1);

        // [GIVEN] Second purchase advance letter line with normal VAT has been created
        FindNextVATPostingSetup(VATPostingSetup);
        LibraryPurchAdvancesCZZ.CreatePurchAdvLetterLine(
            PurchAdvLetterLineCZZ2, PurchAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ."Amount Including VAT");

        // [GIVEN] Purchase advance payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase invoice has been created
        // [GIVEN] First purchase invoice line with amount lower than first line of advance letter has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine1, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Posting Date",
            PurchAdvLetterLineCZZ1."VAT Bus. Posting Group", PurchAdvLetterLineCZZ1."VAT Prod. Posting Group", '', 0,
            true, PurchAdvLetterLineCZZ1."Amount Including VAT" - 1);

        // [GIVEN] Second purchase invoice line with amount lower than second line of advance letter has been created
        LibraryPurchAdvancesCZZ.CreateGLAccount(GLAccount);
        GLAccount.Validate("VAT Bus. Posting Group", PurchAdvLetterLineCZZ2."VAT Bus. Posting Group");
        GLAccount.Validate("VAT Prod. Posting Group", PurchAdvLetterLineCZZ2."VAT Prod. Posting Group");
        GLAccount.Modify(true);
        LibraryPurchase.CreatePurchaseLine(PurchaseLine2, PurchaseHeader, PurchaseLine2.Type::"G/L Account", GLAccount."No.", 1);
        PurchaseLine2.Validate("Direct Unit Cost", PurchAdvLetterLineCZZ2."Amount Including VAT" - 1);
        PurchaseLine2.Modify(true);

        // [GIVEN] Whole advance letter has been linked to purchase invoice
        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT", "Amount Including VAT (LCY)");
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

        // [THEN] One purchase advance letter entry of "Usage" type will exist
        PurchAdvLetterEntryCZZ1.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ1.SetRange("Entry Type", PurchAdvLetterEntryCZZ1."Entry Type"::Usage);
        Assert.RecordCount(PurchAdvLetterEntryCZZ1, 1);

        // [THEN] Two purchase advance letter entries of "VAT Usage" type will exist
        PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ2.SetRange("Entry Type", PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Usage");
        Assert.RecordCount(PurchAdvLetterEntryCZZ2, 2);

        // [THEN] Sum of amounts in purchase advance letter entries of "VAT Usage" type will be the same as in Usage type of entry
        PurchAdvLetterEntryCZZ1.FindFirst();
        PurchAdvLetterEntryCZZ2.CalcSums(Amount);
        Assert.AreEqual(PurchAdvLetterEntryCZZ1.Amount, PurchAdvLetterEntryCZZ2.Amount, 'The sum of amounts in purchase advance letter entries must be the same as in entry with "Usage" type.');
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure CreatePurchAdvLetterWithTwoDiffVATRatesAndLinkToInvoiceWithOneVATRate()
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ1: Record "Purch. Adv. Letter Line CZZ";
        PurchAdvLetterLineCZZ2: Record "Purch. Adv. Letter Line CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VATEntry: Record "VAT Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        PostedDocumentNo: Code[20];
        VATEntryCount: Integer;
    begin
        // [SCENARIO] Create purchase advance letter with two lines with different VAT rates and link to invoice with
        //            with line which is the same as first line in advance letter and one VAT rate
        Initialize();

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ1);

        // [GIVEN] Second purchase advance letter line with reverse charge has been created
        LibraryPurchAdvancesCZZ.FindVATPostingSetupEU(VATPostingSetup);
        LibraryPurchAdvancesCZZ.CreatePurchAdvLetterLine(
            PurchAdvLetterLineCZZ2, PurchAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ."Amount Including VAT");

        // [GIVEN] Purchase advance payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase invoice has been created
        // [GIVEN] Purchase invoice line by first line of advance letter has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Posting Date",
            PurchAdvLetterLineCZZ1."VAT Bus. Posting Group", PurchAdvLetterLineCZZ1."VAT Prod. Posting Group", '', 0,
            true, PurchAdvLetterLineCZZ1."Amount Including VAT");

        // [GIVEN] Whole advance letter has been linked to purchase invoice
        LibraryPurchAdvancesCZZ.LinkPurchAdvanceLetterToDocument(
            PurchAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice", PurchaseHeader."No.",
            PurchAdvLetterLineCZZ1."Amount Including VAT", PurchAdvLetterLineCZZ1."Amount Including VAT (LCY)");

        // [WHEN] Post purchase invoice
        PostedDocumentNo := PostPurchaseDocument(PurchaseHeader);

        // [THEN] VAT entries of purchase invoice will exist
        VATEntry.Reset();
        VATEntry.SetRange("VAT Bus. Posting Group", PurchAdvLetterLineCZZ1."VAT Bus. Posting Group");
        VATEntry.SetRange("VAT Prod. Posting Group", PurchAdvLetterLineCZZ1."VAT Prod. Posting Group");
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

        // [THEN] All VAT entries will have the same VAT posting group
        VATEntryCount := VATEntry.Count();
        VATEntry.FindFirst();
        VATEntry.SetRange("VAT Bus. Posting Group", VATEntry."VAT Bus. Posting Group");
        VATEntry.SetRange("VAT Prod. Posting Group", VATEntry."VAT Prod. Posting Group");
        Assert.RecordCount(VATEntry, VATEntryCount);
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure CreatePurchAdvLetterWithTwoDiffVATRatesAndLinkToInvoiceWithOneVATRate2()
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ1: Record "Purch. Adv. Letter Line CZZ";
        PurchAdvLetterLineCZZ2: Record "Purch. Adv. Letter Line CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VATEntry: Record "VAT Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        PostedDocumentNo: Code[20];
        VATEntryCount: Integer;
    begin
        // [SCENARIO] Create purchase advance letter with two lines with different VAT rates and link to invoice with line which is the same as second line in advance letter and one VAT rate
        Initialize();

        // [GIVEN] Posting of VAT documents for reverse charge has been enabled
        SetPostVATDocForReverseCharge(true);

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ1);

        // [GIVEN] Second purchase advance letter line with reverse charge has been created
        LibraryPurchAdvancesCZZ.FindVATPostingSetupEU(VATPostingSetup);
        LibraryPurchAdvancesCZZ.CreatePurchAdvLetterLine(
            PurchAdvLetterLineCZZ2, PurchAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ."Amount Including VAT");

        // [GIVEN] Purchase advance payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase invoice has been created
        // [GIVEN] Purchase invoice line by first line of advance letter has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Posting Date",
            PurchAdvLetterLineCZZ2."VAT Bus. Posting Group", PurchAdvLetterLineCZZ2."VAT Prod. Posting Group", '', 0,
            true, PurchAdvLetterLineCZZ2."Amount Including VAT");

        // [GIVEN] Whole advance letter has been linked to purchase invoice
        LibraryPurchAdvancesCZZ.LinkPurchAdvanceLetterToDocument(
            PurchAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice", PurchaseHeader."No.",
            PurchAdvLetterLineCZZ2."Amount Including VAT", PurchAdvLetterLineCZZ2."Amount Including VAT (LCY)");

        // [WHEN] Post purchase invoice
        PostedDocumentNo := PostPurchaseDocument(PurchaseHeader);

        // [THEN] VAT entries of purchase invoice will exist
        VATEntry.Reset();
        VATEntry.SetRange("VAT Bus. Posting Group", PurchAdvLetterLineCZZ2."VAT Bus. Posting Group");
        VATEntry.SetRange("VAT Prod. Posting Group", PurchAdvLetterLineCZZ2."VAT Prod. Posting Group");
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

        // [THEN] All VAT entries will have the same VAT posting group
        VATEntryCount := VATEntry.Count();
        VATEntry.FindFirst();
        VATEntry.SetRange("VAT Bus. Posting Group", VATEntry."VAT Bus. Posting Group");
        VATEntry.SetRange("VAT Prod. Posting Group", VATEntry."VAT Prod. Posting Group");
        Assert.RecordCount(VATEntry, VATEntryCount);

        SetPostVATDocForReverseCharge(false);
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure CreatePurchAdvLetterWithTwoDiffVATRatesAndLinkToInvoiceWithOneVATRate3()
    var
        PurchAdvLetterEntryCZZ1: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ1: Record "Purch. Adv. Letter Line CZZ";
        PurchAdvLetterLineCZZ2: Record "Purch. Adv. Letter Line CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        // [SCENARIO] Create purchase advance letter with two lines with different VAT rates and link to invoice with line which has the higher amount as first line in advance letter and one VAT rate
        Initialize();

        // [GIVEN] Posting of VAT documents for reverse charge has been enabled
        SetPostVATDocForReverseCharge(true);

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ1);

        // [GIVEN] Second purchase advance letter line with reverse charge has been created
        LibraryPurchAdvancesCZZ.FindVATPostingSetupEU(VATPostingSetup);
        LibraryPurchAdvancesCZZ.CreatePurchAdvLetterLine(
            PurchAdvLetterLineCZZ2, PurchAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT", "Amount Including VAT (LCY)");
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ."Amount Including VAT");

        // [GIVEN] Purchase advance payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase invoice has been created
        // [GIVEN] Purchase invoice line with amount higher than first line of advance letter has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Posting Date",
            PurchAdvLetterLineCZZ1."VAT Bus. Posting Group", PurchAdvLetterLineCZZ1."VAT Prod. Posting Group", '', 0,
            true, PurchAdvLetterLineCZZ1."Amount Including VAT" + 1);

        // [GIVEN] Whole advance letter has been linked to purchase invoice
        LibraryPurchAdvancesCZZ.LinkPurchAdvanceLetterToDocument(
            PurchAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice", PurchaseHeader."No.",
            PurchAdvLetterHeaderCZZ."Amount Including VAT", PurchAdvLetterHeaderCZZ."Amount Including VAT (LCY)");

        // [WHEN] Post purchase invoice
        PostPurchaseDocument(PurchaseHeader);

        // [THEN] Amount in purchase advance letter entry of "VAT Payment" type will be the sames as in entry with "VAT Usage" type of the same VAT posting group as in first line of advance letter
        PurchAdvLetterEntryCZZ1.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ1.SetRange("VAT Bus. Posting Group", PurchAdvLetterLineCZZ1."VAT Bus. Posting Group");
        PurchAdvLetterEntryCZZ1.SetRange("VAT Prod. Posting Group", PurchAdvLetterLineCZZ1."VAT Prod. Posting Group");
        PurchAdvLetterEntryCZZ1.SetRange("Entry Type", PurchAdvLetterEntryCZZ1."Entry Type"::"VAT Payment");
        PurchAdvLetterEntryCZZ1.FindFirst();

        PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        purchAdvLetterEntryCZZ2.SetRange("VAT Bus. Posting Group", PurchaseLine."VAT Bus. Posting Group");
        purchAdvLetterEntryCZZ2.SetRange("VAT Prod. Posting Group", PurchaseLine."VAT Prod. Posting Group");
        purchAdvLetterEntryCZZ2.SetRange("Entry Type", purchAdvLetterEntryCZZ2."Entry Type"::"VAT Usage");
        PurchAdvLetterEntryCZZ2.FindFirst();
        Assert.AreEqual(PurchAdvLetterEntryCZZ1.Amount, -PurchAdvLetterEntryCZZ2.Amount, 'The amount in purchase advance letter entry of "VAT Payment" type must be the same as in entry with "VAT Usage" type.');

        // [THEN] Purchase advance letter entry of "VAT Usage" type with the same VAT posting group as in second line of advance letter will exist
        PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        purchAdvLetterEntryCZZ2.SetRange("VAT Bus. Posting Group", PurchAdvLetterLineCZZ2."VAT Bus. Posting Group");
        purchAdvLetterEntryCZZ2.SetRange("VAT Prod. Posting Group", PurchAdvLetterLineCZZ2."VAT Prod. Posting Group");
        purchAdvLetterEntryCZZ2.SetRange("Entry Type", purchAdvLetterEntryCZZ2."Entry Type"::"VAT Usage");
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ2);

        SetPostVATDocForReverseCharge(false);
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure CreatePurchAdvLetterWithTwoDiffVATRatesAndLinkToInvoiceWithOneVATRate4()
    var
        PurchAdvLetterEntryCZZ1: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ1: Record "Purch. Adv. Letter Line CZZ";
        PurchAdvLetterLineCZZ2: Record "Purch. Adv. Letter Line CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        // [SCENARIO] Create purchase advance letter with two lines with different VAT rates and link to invoice with line which has the higher amount as second line in advance letter and one VAT rate
        Initialize();

        // [GIVEN] Posting of VAT documents for reverse charge has been enabled
        SetPostVATDocForReverseCharge(true);

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ1);

        // [GIVEN] Second purchase advance letter line with reverse charge has been created
        LibraryPurchAdvancesCZZ.FindVATPostingSetupEU(VATPostingSetup);
        LibraryPurchAdvancesCZZ.CreatePurchAdvLetterLine(
            PurchAdvLetterLineCZZ2, PurchAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT", "Amount Including VAT (LCY)");
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ."Amount Including VAT");

        // [GIVEN] Purchase advance payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase invoice has been created
        // [GIVEN] Purchase invoice line with amount higher than second line of advance letter has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Posting Date",
            PurchAdvLetterLineCZZ2."VAT Bus. Posting Group", PurchAdvLetterLineCZZ2."VAT Prod. Posting Group", '', 0,
            true, PurchAdvLetterLineCZZ2."Amount Including VAT" + 1);

        // [GIVEN] Whole advance letter has been linked to purchase invoice
        LibraryPurchAdvancesCZZ.LinkPurchAdvanceLetterToDocument(
            PurchAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice", PurchaseHeader."No.",
            PurchAdvLetterHeaderCZZ."Amount Including VAT", PurchAdvLetterHeaderCZZ."Amount Including VAT (LCY)");

        // [WHEN] Post purchase invoice
        PostPurchaseDocument(PurchaseHeader);

        // [THEN] Amount in purchase advance letter entry of "VAT Payment" type will be the same as in entry with "VAT Usage" type of the same VAT posting group as in second line of advance letter
        PurchAdvLetterEntryCZZ1.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ1.SetRange("VAT Bus. Posting Group", PurchAdvLetterLineCZZ2."VAT Bus. Posting Group");
        PurchAdvLetterEntryCZZ1.SetRange("VAT Prod. Posting Group", PurchAdvLetterLineCZZ2."VAT Prod. Posting Group");
        PurchAdvLetterEntryCZZ1.SetRange("Entry Type", PurchAdvLetterEntryCZZ1."Entry Type"::"VAT Payment");
        PurchAdvLetterEntryCZZ1.FindFirst();

        PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        purchAdvLetterEntryCZZ2.SetRange("VAT Bus. Posting Group", PurchaseLine."VAT Bus. Posting Group");
        purchAdvLetterEntryCZZ2.SetRange("VAT Prod. Posting Group", PurchaseLine."VAT Prod. Posting Group");
        purchAdvLetterEntryCZZ2.SetRange("Entry Type", purchAdvLetterEntryCZZ2."Entry Type"::"VAT Usage");
        PurchAdvLetterEntryCZZ2.FindFirst();
        Assert.AreEqual(PurchAdvLetterEntryCZZ1.Amount, -PurchAdvLetterEntryCZZ2.Amount, 'The amount in purchase advance letter entry of "VAT Payment" type must be the same as in entry with "VAT Usage" type.');

        // [THEN] Purchase advance letter entry of "VAT Usage" type with the same VAT posting group as in first line of advance letter will exist
        PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        purchAdvLetterEntryCZZ2.SetRange("VAT Bus. Posting Group", PurchAdvLetterLineCZZ1."VAT Bus. Posting Group");
        purchAdvLetterEntryCZZ2.SetRange("VAT Prod. Posting Group", PurchAdvLetterLineCZZ1."VAT Prod. Posting Group");
        purchAdvLetterEntryCZZ2.SetRange("Entry Type", purchAdvLetterEntryCZZ2."Entry Type"::"VAT Usage");
        Assert.RecordIsNotEmpty(PurchAdvLetterEntryCZZ2);

        SetPostVATDocForReverseCharge(false);
    end;

    [Test]
    [HandlerFunctions('ModalVATDocumentHandler')]
    procedure CreatePurchAdvLetterWithTwoDiffVATRatesAndLinkToInvoice()
    var
        GLAccount: Record "G/L Account";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ1: Record "Purch. Adv. Letter Line CZZ";
        PurchAdvLetterLineCZZ2: Record "Purch. Adv. Letter Line CZZ";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine1: Record "Purchase Line";
        PurchaseLine2: Record "Purchase Line";
        VATEntry: Record "VAT Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Create purchase advance letter with two lines with different VAT rates and link to invoice with two lines which have the lower amounts as lines in advance letter
        Initialize();

        // [GIVEN] Posting of VAT documents for reverse charge has been enabled
        SetPostVATDocForReverseCharge(true);

        // [GIVEN] Purchase advance letter has been created
        // [GIVEN] Purchase advance letter line with normal VAT has been created
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ1);

        // [GIVEN] Second purchase advance letter line with reverse charge has been created
        LibraryPurchAdvancesCZZ.FindVATPostingSetupEU(VATPostingSetup);
        LibraryPurchAdvancesCZZ.CreatePurchAdvLetterLine(
            PurchAdvLetterLineCZZ2, PurchAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Purchase advance letter has been released
        ReleasePurchAdvLetter(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase advance letter has been paid in full by the general journal
        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT", "Amount Including VAT (LCY)");
        CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ."Amount Including VAT");

        // [GIVEN] Purchase advance payment VAT has been posted
        PostPurchAdvancePaymentVAT(PurchAdvLetterHeaderCZZ);

        // [GIVEN] Purchase invoice has been created
        // [GIVEN] First purchase invoice line with amount lower than first line of advance letter has been created
        LibraryPurchAdvancesCZZ.CreatePurchInvoice(
            PurchaseHeader, PurchaseLine1, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."Posting Date",
            PurchAdvLetterLineCZZ1."VAT Bus. Posting Group", PurchAdvLetterLineCZZ1."VAT Prod. Posting Group", '', 0,
            true, PurchAdvLetterLineCZZ1."Amount Including VAT" - 1);

        // [GIVEN] Second purchase invoice line with amount lower than second line of advance letter has been created
        LibraryPurchAdvancesCZZ.CreateGLAccount(GLAccount);
        GLAccount.Validate("VAT Bus. Posting Group", PurchAdvLetterLineCZZ2."VAT Bus. Posting Group");
        GLAccount.Validate("VAT Prod. Posting Group", PurchAdvLetterLineCZZ2."VAT Prod. Posting Group");
        GLAccount.Modify(true);
        LibraryPurchase.CreatePurchaseLine(PurchaseLine2, PurchaseHeader, PurchaseLine2.Type::"G/L Account", GLAccount."No.", 1);
        PurchaseLine2.Validate("Direct Unit Cost", PurchAdvLetterLineCZZ2."Amount Including VAT" - 1);
        PurchaseLine2.Modify(true);

        // [GIVEN] Whole advance letter has been linked to purchase invoice
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

        // [THEN] Sum of base and VAT amount in VAT entries with the same VAT posting group as in first line of advance letter will be zero
        VATEntry.SetRange("VAT Bus. Posting Group", PurchAdvLetterLineCZZ1."VAT Bus. Posting Group");
        VATEntry.SetRange("VAT Prod. Posting Group", PurchAdvLetterLineCZZ1."VAT Prod. Posting Group");
        VATEntry.CalcSums(Base, Amount);
        Assert.AreEqual(0, VATEntry.Base, 'The sum of base amount in VAT Entries must be zero.');
        Assert.AreEqual(0, VATEntry.Amount, 'The sum of VAT amount in VAT Entries must be zero.');

        // [THEN] Sum of base and VAT amount in VAT entries with the same VAT posting group as in second line of advance letter will be zero
        VATEntry.SetRange("VAT Bus. Posting Group", PurchAdvLetterLineCZZ2."VAT Bus. Posting Group");
        VATEntry.SetRange("VAT Prod. Posting Group", PurchAdvLetterLineCZZ2."VAT Prod. Posting Group");
        VATEntry.CalcSums(Base, Amount);
        Assert.AreEqual(0, VATEntry.Base, 'The sum of base amount in VAT Entries must be zero.');
        Assert.AreEqual(0, VATEntry.Amount, 'The sum of VAT amount in VAT Entries must be zero.');

        SetPostVATDocForReverseCharge(false);
    end;

    local procedure CreatePurchAdvLetterBase(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ"; VendorNo: Code[20]; CurrencyCode: Code[10]; VATPostingSetup: Record "VAT Posting Setup")
    var
        Vendor: Record Vendor;
    begin
        if VendorNo = '' then begin
            LibraryPurchAdvancesCZZ.CreateVendor(Vendor);
            Vendor.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
            Vendor.Modify(true);
            VendorNo := Vendor."No.";
        end;

        LibraryPurchAdvancesCZZ.CreatePurchAdvLetterHeader(PurchAdvLetterHeaderCZZ, AdvanceLetterTemplateCZZ.Code, VendorNo, CurrencyCode);
        LibraryPurchAdvancesCZZ.CreatePurchAdvLetterLine(PurchAdvLetterLineCZZ, PurchAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));
    end;

    local procedure CreatePurchAdvLetter(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ"; CurrencyCode: Code[10])
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        LibraryPurchAdvancesCZZ.FindVATPostingSetup(VATPostingSetup);
        CreatePurchAdvLetterBase(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ, '', CurrencyCode, VATPostingSetup);
    end;

    local procedure CreatePurchAdvLetter(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ")
    begin
        CreatePurchAdvLetter(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ, '');
    end;

    local procedure CreatePurchAdvLetterWithVendor(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ"; VendorNo: Code[20])
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        LibraryPurchAdvancesCZZ.FindVATPostingSetup(VATPostingSetup);
        CreatePurchAdvLetterBase(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ, VendorNo, '', VATPostingSetup);
    end;

    local procedure CreatePurchAdvLetterWithReverseCharge(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ")
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        LibraryPurchAdvancesCZZ.FindVATPostingSetupEU(VATPostingSetup);
        CreatePurchAdvLetterBase(PurchAdvLetterHeaderCZZ, PurchAdvLetterLineCZZ, '', '', VATPostingSetup);
    end;

    local procedure CreatePurchAdvLetterFromOrderWithAdvanceAmount(var PurchaseHeader: Record "Purchase Header"; AdvanceLetterCode: Code[20]; AdvanceAmount: Decimal; SuggestByLine: Boolean; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
        CreatePurchAdvLetterFromOrder(PurchaseHeader, AdvanceLetterCode, 0, AdvanceAmount, SuggestByLine, PurchAdvLetterHeaderCZZ);
    end;

    local procedure CreatePurchAdvLetterFromOrderWithAdvancePer(var PurchaseHeader: Record "Purchase Header"; AdvanceLetterCode: Code[20]; AdvancePer: Decimal; SuggestByLine: Boolean; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
        CreatePurchAdvLetterFromOrder(PurchaseHeader, AdvanceLetterCode, AdvancePer, 0, SuggestByLine, PurchAdvLetterHeaderCZZ);
    end;

    local procedure CreatePurchAdvLetterFromOrder(var PurchaseHeader: Record "Purchase Header"; AdvanceLetterCode: Code[20]; AdvancePer: Decimal; AdvanceAmount: Decimal; SuggestByLine: Boolean; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
    begin
        Commit();
        LibraryVariableStorage.Enqueue(AdvanceLetterCode);
        LibraryVariableStorage.Enqueue(AdvancePer);
        LibraryVariableStorage.Enqueue(AdvanceAmount);
        LibraryVariableStorage.Enqueue(SuggestByLine);
        LibraryPurchAdvancesCZZ.CreatePurchAdvanceLetterFromOrder(PurchaseHeader);

        AdvanceLetterApplicationCZZ.SetRange("Advance Letter Type", AdvanceLetterApplicationCZZ."Advance Letter Type"::Purchase);
        AdvanceLetterApplicationCZZ.SetRange("Document Type", AdvanceLetterApplicationCZZ."Document Type"::"Purchase Order");
        AdvanceLetterApplicationCZZ.SetRange("Document No.", PurchaseHeader."No.");
        AdvanceLetterApplicationCZZ.FindFirst();
        PurchAdvLetterHeaderCZZ.Get(AdvanceLetterApplicationCZZ."Advance Letter No.");
    end;

    local procedure CreateAndPostPaymentPurchAdvLetter(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; Amount: Decimal; ExchangeRate: Decimal; PostingDate: Date): Decimal
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        LibraryPurchAdvancesCZZ.CreatePurchAdvancePayment(GenJournalLine, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", Amount, PurchAdvLetterHeaderCZZ."Currency Code", PurchAdvLetterHeaderCZZ."No.", ExchangeRate, PostingDate);
        PostGenJournalLine(GenJournalLine);
        exit(GenJournalLine."Amount (LCY)");
    end;

    local procedure CreateAndPostPaymentPurchAdvLetter(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; Amount: Decimal): Decimal
    begin
        exit(CreateAndPostPaymentPurchAdvLetter(PurchAdvLetterHeaderCZZ, Amount, 0, 0D));
    end;

    local procedure CreateAndPostPayment(VendorNo: Code[20]; Amount: Decimal)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        LibraryJournals.CreateGenJournalLineWithBatch(
            GenJournalLine, GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::Vendor, VendorNo, Amount);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateCashDocument(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var CashDocumentLineCZP: Record "Cash Document Line CZP"; CashDocType: Enum "Cash Document Type CZP"; PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    var
        CashDeskCZP: Record "Cash Desk CZP";
        CashDeskUserCZP: Record "Cash Desk User CZP";
    begin
        LibraryCashDeskCZP.CreateCashDeskCZP(CashDeskCZP);
        LibraryCashDeskCZP.SetupCashDeskCZP(CashDeskCZP, false);
        LibraryCashDeskCZP.CreateCashDeskUserCZP(CashDeskUserCZP, CashDeskCZP."No.", true, true, true);
        LibraryCashDocumentCZP.CreateCashDocumentHeaderCZP(CashDocumentHeaderCZP, CashDocType, CashDeskCZP."No.");
        LibraryCashDocumentCZP.CreateCashDocumentLineCZP(CashDocumentLineCZP, CashDocumentHeaderCZP,
            Enum::"Cash Document Account Type CZP"::Vendor, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", 0);
        CashDocumentLineCZP.Validate("Advance Letter No. CZZ", PurchAdvLetterHeaderCZZ."No.");
        CashDocumentLineCZP.Modify();
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

    local procedure PostPurchAdvancePaymentUsageVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    begin
        LibraryVariableStorage.Enqueue(WorkDate()); // original document vat date
        LibraryVariableStorage.Enqueue(PurchAdvLetterEntryCZZ."Document No."); // external document no.
        LibraryPurchAdvancesCZZ.PostPurchAdvancePaymentUsageVAT(PurchAdvLetterEntryCZZ);
    end;

    local procedure GetLastVendLedgerEntryNo(): Integer
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry.FindLast();
        exit(VendorLedgerEntry."Entry No.");
    end;

    local procedure UnApplyVendLedgerEntries(FromEntryNo: Integer; IsErrorExpected: Boolean)
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry.SetFilter("Entry No.", '>%1', FromEntryNo);
        if VendorLedgerEntry.FindSet() then
            repeat
                if not IsErrorExpected then
                    LibraryPurchAdvancesCZZ.UnApplyVendLedgEntry(VendorLedgerEntry."Entry No.")
                else begin
                    asserterror LibraryPurchAdvancesCZZ.UnApplyVendLedgEntry(VendorLedgerEntry."Entry No.");
                    LibraryVariableStorage.Enqueue(VendorLedgerEntry);
                    LibraryVariableStorage.Enqueue(GetLastErrorText());
                end;
            until VendorLedgerEntry.Next() = 0;
    end;

    local procedure VerifyVendLedgerEntryCount(FromEntryNo: Integer; ExpectedCount: Integer)
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry.SetFilter("Entry No.", '>%1', FromEntryNo);
        Assert.RecordCount(VendorLedgerEntry, ExpectedCount);
    end;

    local procedure VerifyErrors()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        Variant: Variant;
        ErrorText: Text;
        i: Integer;
    begin
        for i := 1 to LibraryVariableStorage.Length() / 2 do begin
            LibraryVariableStorage.Dequeue(Variant);
            VendorLedgerEntry := Variant;
            LibraryVariableStorage.Dequeue(Variant);
            ErrorText := Variant;
            if VendorLedgerEntry.Open then
                Assert.AreEqual(StrSubstNo(NoApplicationEntryErr, VendorLedgerEntry."Entry No."), ErrorText, 'Unexpected error occur.')
            else
                Assert.AreEqual(AppliedToAdvanceLetterErr, ErrorText, 'Unexpected error occur.');
        end;
    end;

    local procedure PostCashDocument(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
        LibraryCashDocumentCZP.PostCashDocumentCZP(CashDocumentHeaderCZP);
    end;

    local procedure SetPostVATDocForReverseCharge(Value: Boolean)
    begin
        AdvanceLetterTemplateCZZ."Post VAT Doc. for Rev. Charge" := Value;
        AdvanceLetterTemplateCZZ.Modify();
    end;

    local procedure FindNextVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup")
    begin
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        if VATPostingSetup.Next() = 0 then
            LibraryERM.CreateVATPostingSetupWithAccounts(
                VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT", LibraryRandom.RandDecInDecimalRange(10, 25, 0));
        LibraryPurchAdvancesCZZ.AddAdvLetterAccounsToVATPostingSetup(VATPostingSetup);
    end;

    local procedure SetExpectedConfirm(Question: Text; Reply: Boolean)
    begin
        LibraryDialogHandler.SetExpectedConfirm(Question, Reply);
    end;

    [ModalPageHandler]
    procedure ModalVATDocumentHandler(var VATDocument: TestPage "VAT Document CZZ")
    begin
        VATDocument.OriginalDocumentVATDate.SetValue(LibraryVariableStorage.DequeueDate());
        VATDocument.ExternalDocumentNo.SetValue(LibraryVariableStorage.DequeueText());
        VATDocument.OK().Invoke();
    end;

    [RequestPageHandler]
    procedure CreatePurchAdvLetterHandler(var CreatePurchAdvLetterCZZ: TestRequestPage "Create Purch. Adv. Letter CZZ")
    var
        DecimalValue: Decimal;
    begin
        CreatePurchAdvLetterCZZ.AdvLetterCode.SetValue(LibraryVariableStorage.DequeueText());
        CreatePurchAdvLetterCZZ.AdvPer.SetValue := 100;
        DecimalValue := LibraryVariableStorage.DequeueDecimal();
        if DecimalValue <> 0 then
            CreatePurchAdvLetterCZZ.AdvPer.SetValue(DecimalValue);
        DecimalValue := LibraryVariableStorage.DequeueDecimal();
        if DecimalValue <> 0 then
            CreatePurchAdvLetterCZZ.AdvAmount.SetValue(DecimalValue);
        CreatePurchAdvLetterCZZ.SuggByLine.SetValue(LibraryVariableStorage.DequeueBoolean());
        CreatePurchAdvLetterCZZ.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        LibraryDialogHandler.HandleConfirm(Question, Reply);
    end;
}
