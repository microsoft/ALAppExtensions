codeunit 148109 "Sales Advance Payments CZZ"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Advance Payments] [Sales]
        isInitialized := false;
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        Assert: Codeunit Assert;
        LibraryCashDeskCZP: Codeunit "Library - Cash Desk CZP";
        LibraryCashDocumentCZP: Codeunit "Library - Cash Document CZP";
        LibraryDialogHandler: Codeunit "Library - Dialog Handler";
        LibraryJournals: Codeunit "Library - Journals";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySalesAdvancesCZZ: Codeunit "Library - Sales Advances CZZ";
        LibrarySales: Codeunit "Library - Sales";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        isInitialized: Boolean;
        AppliedToAdvanceLetterErr: Label 'The entry is applied to advance letter and cannot be used to applying or unapplying.';
        ApplyAdvanceLetterQst: Label 'Apply Advance Letter?';
        LaterAdvancePaymentQst: Label 'The linked advance letter %1 is paid after %2. If you continue, the advance letter won''t be deducted.\\Do you want to continue?', Comment = '%1 = advance letter no., %2 = posting date';
        OpenAdvanceLetterQst: Label 'Do you want to open created Advance Letter?';
        NoApplicationEntryErr: Label 'Cust. Ledger Entry No. %1 does not have an application entry.', Comment = '%1 = advance letter no.';
        UnapplyAdvLetterQst: Label 'Unapply advance letter: %1\Continue?', Comment = '%1 = Advance Letters';
        UsageNoPossibleQst: Label 'Usage all applicated advances is not possible.\Continue?';
        PostCashDocumentQst: Label 'Do you want to post Cash Document Header %1?', Comment = '%1 = Cash Document No.';

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Sales Advance Payments CZZ");
        LibraryRandom.Init();
        LibraryVariableStorage.Clear();
        LibraryDialogHandler.ClearVariableStorage();
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Sales Advance Payments CZZ");

        GeneralLedgerSetup.Get();
        LibrarySalesAdvancesCZZ.CreateSalesAdvanceLetterTemplate(AdvanceLetterTemplateCZZ);

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Sales Advance Payments CZZ");
    end;

    [Test]
    procedure CreateSalesAdvLetter()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
    begin
        // [SCENARIO] Test if the system allows to create a new Sales Advance Letter
        Initialize();

        // [WHEN] Create sales advance letter
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [THEN] Sales advance letter will be created
        SalesAdvLetterLineCZZ.SetRange("Document No.", SalesAdvLetterHeaderCZZ."No.");
        Assert.RecordIsNotEmpty(SalesAdvLetterLineCZZ);
    end;

    [Test]
    [HandlerFunctions('CreateSalesAdvLetterHandler,ConfirmHandler')]
    procedure CreateSalesAdvLetterFromSalesOrder()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
    begin
        // [SCENARIO] Test if the system allows to create a new Sales Advance Letter from Sales order
        Initialize();

        // [GIVEN] Sales order has been created
        LibrarySalesAdvancesCZZ.CreateSalesOrder(SalesHeader, SalesLine);

        // [WHEN] Create sales advance letter from sales order
        SetExpectedConfirm(OpenAdvanceLetterQst, false);
        CreateSalesAdvLetterFromOrderWithAdvancePer(SalesHeader, AdvanceLetterTemplateCZZ.Code, 100, false, SalesAdvLetterHeaderCZZ);

        // [THEN] Sales advance letter will be created
        SalesAdvLetterLineCZZ.SetRange("Document No.", SalesAdvLetterHeaderCZZ."No.");
        Assert.RecordIsNotEmpty(salesAdvLetterLineCZZ);
    end;

    [Test]
    [HandlerFunctions('CreateSalesAdvLetterHandler,ConfirmHandler')]
    procedure ReleaseSalesAdvLetter()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
    begin
        // [SCENARIO] Test the release of Sales Advance Letter
        Initialize();

        // [GIVEN] Sales advance letter from sales order has been created
        LibrarySalesAdvancesCZZ.CreateSalesOrder(SalesHeader, SalesLine);
        SetExpectedConfirm(OpenAdvanceLetterQst, false);
        CreateSalesAdvLetterFromOrderWithAdvancePer(SalesHeader, AdvanceLetterTemplateCZZ.Code, 100, false, SalesAdvLetterHeaderCZZ);

        // [WHEN] Release sales advance
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [THEN] Sales advance letter ststus will be To Pay
        SalesAdvLetterHeaderCZZ.TestField(Status, SalesAdvLetterHeaderCZZ.Status::"To Pay");
    end;

    [Test]
    procedure PaymentSalesAdvLetter()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        AmountInclVAT, AmountInclVATLCY : Decimal;
    begin
        // [SCENARIO] Test the payment of Sales Advance Letter
        Initialize();

        // [GIVEN] Sales advance letter has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);
        AmountInclVAT := -SalesAdvLetterLineCZZ."Amount Including VAT";

        // [WHEN] Post sales advance payment
        AmountInclVATLCY := CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, AmountInclVAT);

        // [THEN] Sales advance letter status will be To Use
        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterHeaderCZZ.TestField(Status, SalesAdvLetterHeaderCZZ.Status::"To Use");

        // [THEN] Sales advance letter entry Payment will be created
        SalesAdvLetterEntryCZZ.SetCurrentKey("Sales Adv. Letter No.");
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Payment);
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ);

        // [THEN] Sales advance letter entry Payment has correct amounts
        SalesAdvLetterEntryCZZ.FindFirst();
        Assert.AreEqual(SalesAdvLetterEntryCZZ.Amount, AmountInclVAT, 'Wrong payment entry Amount.');
        Assert.AreEqual(SalesAdvLetterEntryCZZ."Amount (LCY)", AmountInclVATLCY, 'Wrong payment entry Amount (LCY).');
    end;

    [Test]
    [HandlerFunctions('CreateSalesAdvLetterHandler,ConfirmHandler')]
    procedure PostSalesOrderWithSalesAdvLetter()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        SalesAdvLetterEntry: Record "Sales Adv. Letter Entry CZZ";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        PostedDocNo: Code[20];
    begin
        // [SCENARIO] Test the posting of Sales Order from which Sales Advance Letter was created
        Initialize();

        // [GIVEN] Sales advance letter from sales order has been created
        LibrarySalesAdvancesCZZ.CreateSalesOrder(SalesHeader, SalesLine);
        SetExpectedConfirm(OpenAdvanceLetterQst, false);
        CreateSalesAdvLetterFromOrderWithAdvancePer(SalesHeader, AdvanceLetterTemplateCZZ.Code, 100, false, SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance has been paid
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

        // [WHEN] Post sales order
        PostedDocNo := PostSalesDocument(SalesHeader);

        // [THEN] Sales advance letter status will be Closed
        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterHeaderCZZ.TestField(Status, SalesAdvLetterHeaderCZZ.Status::Closed);

        // [THEN] Sales Advance letter entry type Usage will be created
        SalesAdvLetterEntry.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntry.SetRange("Entry Type", SalesAdvLetterEntry."Entry Type"::Usage);
        SalesAdvLetterEntry.FindFirst();
        Assert.RecordIsNotEmpty(SalesAdvLetterEntry);

        // [THEN] Sales invoice will be non zero amount
        SalesInvoiceHeader.Get(PostedDocNo);
        SalesInvoiceHeader.CalcFields(Amount, "Amount Including VAT");
        SalesInvoiceHeader.TestField(Amount, SalesLine.Amount);
        SalesInvoiceHeader.TestField("Amount Including VAT", SalesLine."Amount Including VAT");

        // [THEN] Customer ledger entry will be closed
        CustLedgerEntry.SetRange("Customer No.", SalesHeader."Bill-to Customer No.");
        CustLedgerEntry.SetRange("Document No.", PostedDocNo);
        CustLedgerEntry.FindLast();
        CustLedgerEntry.TestField(Open, false);
    end;

    [Test]
    procedure PaymentSalesAdvLetterWithForeignCurrency()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        Currency: Record Currency;
        AmountInclVAT, AmountInclVATLCY : Decimal;
    begin
        // [SCENARIO] Test creation Sales Advance Letter with foreign currency, changing exchange rate and posting payment
        Initialize();

        // [GIVEN] Foreign currency has been created
        FindForeignCurrency(Currency);

        // [GIVEN] Sales advance letter with foreign currency has been crrated and released
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ, Currency.Code);
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);
        AmountInclVAT := -SalesAdvLetterLineCZZ."Amount Including VAT";

        // [WHEN] Post sales advance payment with different exchange rate
        AmountInclVATLCY := CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, AmountInclVAT, 0.9, 0D);

        // [THEN] Sales advance letter status will be To Use
        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterHeaderCZZ.TestField(Status, SalesAdvLetterHeaderCZZ.Status::"To Use");

        // [THEN] Sales advance letter entry Payment has correct amounts
        SalesAdvLetterEntryCZZ.SetCurrentKey("Sales Adv. Letter No.");
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Payment);
        SalesAdvLetterEntryCZZ.FindFirst();
        Assert.AreEqual(SalesAdvLetterEntryCZZ.Amount, AmountInclVAT, 'Wrong payment entry Amount.');
        Assert.AreEqual(SalesAdvLetterEntryCZZ."Amount (LCY)", AmountInclVATLCY, 'Wrong payment entry Amount (LCY).');
    end;

    [Test]
    procedure LinkSalesAdvLetterToInvoice()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        VATEntry: Record "VAT Entry";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Create sales advance letter and link to invoice
        Initialize();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

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
    procedure LinkSalesAdvLetterToInvoiceWithOlderDate()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        TempAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ" temporary;
    begin
        // [SCENARIO] Create sales advance letter and link to invoice with older date
        Initialize();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Sales invoice has been created
        // [GIVEN] Sales invoice line has been created
        LibrarySalesAdvancesCZZ.CreateSalesInvoice(
            SalesHeader, SalesLine, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", SalesAdvLetterHeaderCZZ."Posting Date" - 1,
            SalesAdvLetterLineCZZ."VAT Bus. Posting Group", SalesAdvLetterLineCZZ."VAT Prod. Posting Group", '', 0,
            true, SalesAdvLetterLineCZZ."Amount Including VAT");

        // [WHEN] Get list of advance letter available for linking
        LibrarySalesAdvancesCZZ.GetPossibleSalesAdvance(
            Enum::"Adv. Letter Usage Doc.Type CZZ"::"Sales Invoice", SalesHeader."No.", SalesHeader."Bill-to Customer No.",
            SalesHeader."Posting Date", SalesHeader."Currency Code", TempAdvanceLetterApplicationCZZ);

        // [THEN] Sales advance letter won't be available for linking
        TempAdvanceLetterApplicationCZZ.SetRange("Advance Letter Type", Enum::"Advance Letter Type CZZ"::Sales);
        TempAdvanceLetterApplicationCZZ.SetRange("Advance Letter No.", SalesAdvLetterHeaderCZZ."No.");
        Assert.RecordIsEmpty(TempAdvanceLetterApplicationCZZ);
    end;

    [Test]
    procedure AdditionalLinkSalesAdvLetterToPayment()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
    begin
        // [SCENARIO] Additional link sales advance letter to payment
        Initialize();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Payment has been posted
        CreateAndPostPayment(SalesAdvLetterHeaderCZZ."Bill-to Customer No.", -SalesAdvLetterLineCZZ."Amount Including VAT");

        // [WHEN] Link advance letter to payment
        CustLedgerEntry.FindLast(); // entry of payment
        LibrarySalesAdvancesCZZ.LinkSalesAdvancePayment(SalesAdvLetterHeaderCZZ, CustLedgerEntry);

        // [THEN] Sales advance letter will be paid
        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterHeaderCZZ.TestField(Status, SalesAdvLetterHeaderCZZ.Status::"To Use");

        // [THEN] Sales advance letter entries will be created. One of the type "Payment" and the other of the "VAT Payment".
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.Find('+');
        Assert.AreEqual(SalesAdvLetterEntryCZZ."Entry Type"::"VAT Payment", SalesAdvLetterEntryCZZ."Entry Type", 'The sales advance letter entry must be of type "VAT Payment".');

        SalesAdvLetterEntryCZZ.Next(-1);
        Assert.AreEqual(SalesAdvLetterEntryCZZ."Entry Type"::Payment, SalesAdvLetterEntryCZZ."Entry Type", 'The sales advance letter entry must be of type "Payment".');
    end;

    [Test]
    procedure UnlinkSalesAdvLetterFromPayment()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        SalesAdvLetterEntryCZZ1: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
    begin
        // [SCENARIO] Unlink sales advance letter from payment
        Initialize();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

        // [WHEN] Unlink advance letter from payment
        FindLastPaymentAdvanceLetterEntry(SalesAdvLetterHeaderCZZ."No.", SalesAdvLetterEntryCZZ1);
        LibrarySalesAdvancesCZZ.UnlinkSalesAdvancePayment(SalesAdvLetterEntryCZZ1);

        // [THEN] Sales advance letter entries will be create. One of the type "Payment" and the other of the "VAT Payment".
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
    procedure AdditionalLinkSalesAdvLetterToInvoice()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Create sales advance letter and additionally link to invoice
        Initialize();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Sales invoice has been created
        // [GIVEN] Sales invoice line has been created
        LibrarySalesAdvancesCZZ.CreateSalesInvoice(
            SalesHeader, SalesLine, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", SalesAdvLetterHeaderCZZ."Posting Date",
            SalesAdvLetterLineCZZ."VAT Bus. Posting Group", SalesAdvLetterLineCZZ."VAT Prod. Posting Group", '', 0,
            true, SalesAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Sales invoice has been posted
        PostedDocumentNo := PostSalesDocument(SalesHeader);

        // [WHEN] Link advance letter to posted sales invoice
        SalesInvoiceHeader.Get(PostedDocumentNo);
        SetExpectedConfirm(ApplyAdvanceLetterQst, true);
        LibrarySalesAdvancesCZZ.ApplySalesAdvanceLetter(SalesAdvLetterHeaderCZZ, SalesInvoiceHeader);

        // [THEN] Sales advance letter entries for posted sales invoice are created
        SalesAdvLetterEntryCZZ.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Usage);
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ);

        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Usage");
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure AdditionalUnlinkSalesAdvLetterFromPostedInvoice()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Create sales advance letter, link to invoice, post the invoice and unlink the sales advance letter
        Initialize();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

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

        // [WHEN] Unlink sales advance letter from posted sales invoice
        SalesInvoiceHeader.Get(PostedDocumentNo);
        SetExpectedConfirm(StrSubstNo(UnapplyAdvLetterQst, SalesAdvLetterHeaderCZZ."No."), true);
        LibrarySalesAdvancesCZZ.UnapplyAdvanceLetter(SalesInvoiceHeader);

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
    procedure ManualVATPaymentInSalesAdvLetter()
    var
        SalesAdvLetterEntryCZZ1: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
    begin
        // [SCENARIO] Manual VAT payment in sales advance letter
        Initialize();

        // [GIVEN] Sales advance letter without automatic post VAT document has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);
        SalesAdvLetterHeaderCZZ."Automatic Post VAT Document" := false;
        SalesAdvLetterHeaderCZZ.Modify();

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

        // [WHEN] Post advance letter payment VAT
        SalesAdvLetterEntryCZZ1.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ1.SetRange("Entry Type", SalesAdvLetterEntryCZZ1."Entry Type"::Payment);
        SalesAdvLetterEntryCZZ1.FindFirst();
        LibrarySalesAdvancesCZZ.PostSalesAdvancePaymentVAT(SalesAdvLetterEntryCZZ1);

        // [THEN] Sales advance letter entry of "VAT Payment" type will be created
        SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ2.SetRange("Entry Type", SalesAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
        SalesAdvLetterEntryCZZ2.FindFirst();
        Assert.AreEqual(SalesAdvLetterEntryCZZ1."Posting Date", SalesAdvLetterEntryCZZ2."Posting Date", 'The entry must have the same posting date as related entry.');
        Assert.AreEqual(SalesAdvLetterEntryCZZ1.Amount, SalesAdvLetterEntryCZZ2.Amount, 'The entry must have the same amount as related entry.');
    end;

    [Test]
    procedure ManualPaymentVATUsageInSalesAdvanceLetter()
    var
        SalesAdvLetterEntryCZZ1: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [SCENARIO] Manual payment VAT usage in sales advance letter
        Initialize();

        // [GIVEN] Sales advance letter without automatic post VAT document has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);
        SalesAdvLetterHeaderCZZ."Automatic Post VAT Document" := false;
        SalesAdvLetterHeaderCZZ.Modify();

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Advance letter payment VAT has been posted
        SalesAdvLetterEntryCZZ1.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ1.SetRange("Entry Type", SalesAdvLetterEntryCZZ1."Entry Type"::Payment);
        SalesAdvLetterEntryCZZ1.FindFirst();
        LibrarySalesAdvancesCZZ.PostSalesAdvancePaymentVAT(SalesAdvLetterEntryCZZ1);

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
        PostSalesDocument(SalesHeader);

        // [WHEN] Post advance payment usage VAT from advance letter entry of "Usage" type
        SalesAdvLetterEntryCZZ1.Reset();
        SalesAdvLetterEntryCZZ1.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ1.SetRange("Entry Type", SalesAdvLetterEntryCZZ1."Entry Type"::Usage);
        SalesAdvLetterEntryCZZ1.FindFirst();
        LibrarySalesAdvancesCZZ.PostSalesAdvancePaymentUsageVAT(SalesAdvLetterEntryCZZ1);

        // [THEN] Sales advance letter entry of "VAT Usage" type will be created
        SalesAdvLetterEntryCZZ2.Reset();
        SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ2.SetRange("Entry Type", SalesAdvLetterEntryCZZ2."Entry Type"::"VAT Usage");
        SalesAdvLetterEntryCZZ2.FindFirst();
        Assert.AreEqual(SalesAdvLetterEntryCZZ1."Posting Date", SalesAdvLetterEntryCZZ2."Posting Date", 'The entry must have the same posting date as related entry.');
        Assert.AreEqual(SalesAdvLetterEntryCZZ1.Amount, SalesAdvLetterEntryCZZ2.Amount, 'The entry must have the same amount as related entry.');

        // [THEN] Sales advance letter will be closed
        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterHeaderCZZ.TestField(Status, SalesAdvLetterHeaderCZZ.Status::Closed);
    end;

    [Test]
    procedure CloseSalesAdvanceLetterWithoutVATPayment()
    var
        SalesAdvLetterEntryCZZ1: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
    begin
        // [SCENARIO] It must be possible to close the sales advance letter without VAT payment
        Initialize();

        // [GIVEN] Sales advance letter without automatic post VAT document has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);
        SalesAdvLetterHeaderCZZ."Automatic Post VAT Document" := false;
        SalesAdvLetterHeaderCZZ.Modify();

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

        // [WHEN] Close advance letter
        LibrarySalesAdvancesCZZ.CloseSalesAdvanceLetter(SalesAdvLetterHeaderCZZ);

        // [THEN] Sales advance letter entry of "Close" type will be created
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
    procedure LinkSalesAdvanceLetterWithReverseChargeToInvoice()
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        VATEntry: Record "VAT Entry";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Link sales advance letter with reverse charge to invoice
        Initialize();

        // [GIVEN] Posting of VAT documents for reverse charge has been enabled
        SetPostVATDocForReverseCharge(true);

        // [GIVEN] Sales advance letter  has been created
        // [GIVEN] Sales advance letter line with reverse charge has been created
        CreateSalesAdvLetterWithReverseCharge(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

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

        // [WHEN] Post sales invoice
        PostedDocumentNo := PostSalesDocument(SalesHeader);

        // [THEN] VAT entries of sales invoice and advance letter will exist
        VATEntry.Reset();
        VATEntry.SetRange("Document No.", PostedDocumentNo);
        VATEntry.SetRange("Posting Date", SalesHeader."Posting Date");
        Assert.RecordIsNotEmpty(VATEntry);

        // [THEN] Sum of base and VAT amounts in VAT entries will be zero
        VATEntry.CalcSums(Base, Amount);
        Assert.AreEqual(0, VATEntry.Base, 'The sum of base amount in VAT Entries must be zero.');
        Assert.AreEqual(0, VATEntry.Amount, 'The sum of VAT amount in VAT Entries must be zero.');

        // [THEN] Sum of base and VAT amounts in advance letter entries will be zero
        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.CalcSums("VAT Base Amount", "VAT Amount");
        Assert.AreEqual(0, SalesAdvLetterEntryCZZ."VAT Base Amount", 'The sum of base amount in advance letter entries must be zero.');
        Assert.AreEqual(0, SalesAdvLetterEntryCZZ."VAT Amount", 'The sum of VAT amount in VAT advance letter must be zero.');

        // [THEN] Sales advance letter will be closed
        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterHeaderCZZ.TestField(Status, SalesAdvLetterHeaderCZZ.Status::Closed);

        SetPostVATDocForReverseCharge(false);
    end;

    [Test]
    procedure MultipleAdvancePayment()
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        FirstPaymentAmount: Decimal;
        SecondPaymentAmount: Decimal;
    begin
        // [SCENARIO] The payment of the sales advance letter can be split into several payments
        Initialize();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been partially paid
        FirstPaymentAmount := Round(SalesAdvLetterLineCZZ."Amount Including VAT" / 2);
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -FirstPaymentAmount);

        // [WHEN] Sales advance letter has been paid in full by the general journal
        SecondPaymentAmount := SalesAdvLetterLineCZZ."Amount Including VAT" - FirstPaymentAmount;
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SecondPaymentAmount);

        // [THEN] Sum of amounts of advance letter entries with type Init and Payment will be zero
        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetFilter("Entry Type", '%1|%2', SalesAdvLetterEntryCZZ."Entry Type"::"Initial Entry", SalesAdvLetterEntryCZZ."Entry Type"::Payment);
        SalesAdvLetterEntryCZZ.CalcSums(Amount);
        Assert.AreEqual(0, SalesAdvLetterEntryCZZ.Amount, 'The sum of amount in advance letter entries must be zero.');
    end;

    [Test]
    procedure MultipleAdvancePaymentWithTimeShift()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TempAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ" temporary;
        FirstPaymentAmount: Decimal;
        SecondPaymentAmount: Decimal;
    begin
        // [SCENARIO] Only advance payments paid up to the posting date of sales invoice can be assigned to the invoice
        Initialize();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been partially paid
        FirstPaymentAmount := Round(SalesAdvLetterLineCZZ."Amount Including VAT" / 2);
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -FirstPaymentAmount);

        // [GIVEN] Sales advance letter has been paid in full a month later
        SecondPaymentAmount := SalesAdvLetterLineCZZ."Amount Including VAT" - FirstPaymentAmount;
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SecondPaymentAmount, 0, CalcDate('<+1M>', SalesAdvLetterHeaderCZZ."Posting Date"));

        // [GIVEN] Sales invoice has been created
        // [GIVEN] Sales invoice line has been created
        LibrarySalesAdvancesCZZ.CreateSalesInvoice(
            SalesHeader, SalesLine, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", SalesAdvLetterHeaderCZZ."Posting Date",
            SalesAdvLetterLineCZZ."VAT Bus. Posting Group", SalesAdvLetterLineCZZ."VAT Prod. Posting Group", '', 0,
            true, SalesAdvLetterLineCZZ."Amount Including VAT");

        // [WHEN] Get possible sales advance to link
        LibrarySalesAdvancesCZZ.GetPossibleSalesAdvance(
            Enum::"Adv. Letter Usage Doc.Type CZZ"::"Sales Invoice", SalesHeader."No.", SalesHeader."Bill-to Customer No.",
            SalesHeader."Posting Date", SalesHeader."Currency Code", TempAdvanceLetterApplicationCZZ);

        // [THEN] Only first payment amount is possible to use for link
        TempAdvanceLetterApplicationCZZ.Get(
            Enum::"Advance Letter Type CZZ"::Sales, SalesAdvLetterHeaderCZZ."No.",
            Enum::"Adv. Letter Usage Doc.Type CZZ"::"Sales Invoice", SalesHeader."No.");
        Assert.AreEqual(FirstPaymentAmount, TempAdvanceLetterApplicationCZZ.Amount, 'Only first payment amount can be used.');
    end;

    [Test]
    procedure LinkMultipleAdvanceLetterToOneInvoice()
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ1: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ1: Record "Sales Adv. Letter Line CZZ";
        SalesAdvLetterHeaderCZZ2: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ2: Record "Sales Adv. Letter Line CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine1: Record "Sales Line";
        SalesLine2: Record "Sales Line";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Multiple advance letters can be linked to a sales invoice
        Initialize();

        // [GIVEN] First sales advance letter  has been created
        // [GIVEN] First sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ1, SalesAdvLetterLineCZZ1);

        // [GIVEN] First sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ1);

        // [GIVEN] First sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ1, -SalesAdvLetterLineCZZ1."Amount Including VAT");

        // [GIVEN] Second sales advance letter  has been created
        // [GIVEN] Second sales advance letter line with normal VAT has been created
        CreateSalesAdvLetterWithCustomer(SalesAdvLetterHeaderCZZ2, SalesAdvLetterLineCZZ2, SalesAdvLetterHeaderCZZ1."Bill-to Customer No.");

        // [GIVEN] Second sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ2);

        // [GIVEN] Second sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ2, -SalesAdvLetterLineCZZ2."Amount Including VAT");

        // [GIVEN] Sales invoice has been created
        // [GIVEN] First sales invoice line has been created
        LibrarySalesAdvancesCZZ.CreateSalesInvoice(
            SalesHeader, SalesLine1, SalesAdvLetterHeaderCZZ1."Bill-to Customer No.", SalesAdvLetterHeaderCZZ1."Posting Date",
            SalesAdvLetterLineCZZ1."VAT Bus. Posting Group", SalesAdvLetterLineCZZ1."VAT Prod. Posting Group", '', 0,
            true, SalesAdvLetterLineCZZ1."Amount Including VAT");

        // [GIVEN] Second sales invoice line has been created
        LibrarySales.CreateSalesLine(SalesLine2, SalesHeader, SalesLine2.Type::"G/L Account", SalesLine1."No.", 1);
        SalesLine2.Validate("Unit Price", SalesAdvLetterHeaderCZZ2."Amount Including VAT");
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

        // [THEN] The first advance letter will be used by invoice
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ1."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Usage);
        SalesAdvLetterEntryCZZ.FindFirst();
        SalesAdvLetterEntryCZZ.TestField("Document No.", PostedDocumentNo);

        // [THEN] The second advance letter will be used by invoice
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ2."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Usage);
        SalesAdvLetterEntryCZZ.FindFirst();
        SalesAdvLetterEntryCZZ.TestField("Document No.", PostedDocumentNo);
    end;

    [Test]
    procedure CancelApplicationOfCustLedgerEntryForAdvancePayment()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        LastCustLedgerEntryNo: Integer;
    begin
        // [SCENARIO] Cancellation of application of customer ledger entry for advance payment must fail
        Initialize();

        CustLedgerEntry.FindLast();
        LastCustLedgerEntryNo := CustLedgerEntry."Entry No.";

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");
        Commit();

        // [WHEN] Unapply all customer ledger entries created by advance payment
        UnApplyCustLedgerEntries(LastCustLedgerEntryNo, true);

        // [THEN] The three customer ledger entries will be created
        VerifyCustLedgerEntryCount(LastCustLedgerEntryNo, 3);

        // [THEN] The error will occurs when attempting to unapply customer ledger entries
        VerifyErrors();
    end;

    [Test]
    procedure CancelApplicationOfCustLedgerEntryForClosedAdvanceLetter()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        LastCustLedgerEntryNo: Integer;
    begin
        // [SCENARIO] Cancellation of application of customer ledger entry for closed advance letter must fail
        Initialize();

        LastCustLedgerEntryNo := GetLastCustLedgerEntryNo();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Sales advance letter has been closed
        LibrarySalesAdvancesCZZ.CloseSalesAdvanceLetter(SalesAdvLetterHeaderCZZ);
        Commit();

        // [WHEN] Unapply all customer ledger entries created by advance payment
        UnApplyCustLedgerEntries(LastCustLedgerEntryNo, true);

        // [THEN] The five customer ledger entries will be created
        VerifyCustLedgerEntryCount(LastCustLedgerEntryNo, 5);

        // [THEN] The error will occurs when attempting to unapply customer ledger entries
        VerifyErrors();
    end;

    [Test]
    procedure CancelApplicationOfCustLedgerEntryForUnappliedPaymentFromAdvanceLetter()
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        LastCustLedgerEntryNo: Integer;
    begin
        // [SCENARIO] Cancellation of application of customer ledger entry for an unapplied payment from advance letter must fail
        Initialize();

        LastCustLedgerEntryNo := GetLastCustLedgerEntryNo();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Sales advance payment has been unlinked
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", Enum::"Advance Letter Entry Type CZZ"::Payment);
        SalesAdvLetterEntryCZZ.FindFirst();
        LibrarySalesAdvancesCZZ.UnlinkSalesAdvancePayment(SalesAdvLetterEntryCZZ);
        Commit();

        // [WHEN] Unapply all customer ledger entries created by advance payment
        UnApplyCustLedgerEntries(LastCustLedgerEntryNo, true);

        // [THEN] The five customer ledger entries will be created
        VerifyCustLedgerEntryCount(LastCustLedgerEntryNo, 5);

        // [THEN] The error will occurs when attempting to unapply customer ledger entries
        VerifyErrors();
    end;

    [Test]
    procedure CancelApplicationOfCustLedgerEntryForReappliedPaymentToAdvanceLetter()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        LastCustLedgerEntryNo: Integer;
    begin
        // [SCENARIO] Cancellation of application of customer ledger entry for a reapplied payment to advance letter must fail
        Initialize();

        LastCustLedgerEntryNo := GetLastCustLedgerEntryNo();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] Sales advance payment has been unlinked
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", Enum::"Advance Letter Entry Type CZZ"::Payment);
        SalesAdvLetterEntryCZZ.FindFirst();
        LibrarySalesAdvancesCZZ.UnlinkSalesAdvancePayment(SalesAdvLetterEntryCZZ);

        // [GIVEN] Sales advance payment has been relinked to advance letter
        CustLedgerEntry.Reset();
        CustLedgerEntry.SetFilter("Entry No.", '>%1', LastCustLedgerEntryNo);
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Payment);
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.FindLast();
        LibrarySalesAdvancesCZZ.LinkSalesAdvancePayment(SalesAdvLetterHeaderCZZ, CustLedgerEntry);
        Commit();

        // [WHEN] Unapply all customer ledger entries created by advance payment
        UnApplyCustLedgerEntries(LastCustLedgerEntryNo, true);

        // [THEN] The seven customer ledger entries will be created
        VerifyCustLedgerEntryCount(LastCustLedgerEntryNo, 7);

        // [THEN] The error will occurs when attempting to unapply customer ledger entries
        VerifyErrors();
    end;

    [Test]
    procedure CancelApplicationOfCustLedgerEntryForLinkedAdvanceLetterToInvoice()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LastCustLedgerEntryNo: Integer;
    begin
        // [SCENARIO] Cancellation of application of customer ledger entry for a linked advance letter to invoice must fail
        Initialize();

        LastCustLedgerEntryNo := GetLastCustLedgerEntryNo();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

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
        PostSalesDocument(SalesHeader);
        Commit();

        // [WHEN] Unapply all customer ledger entries created by advance payment
        UnApplyCustLedgerEntries(LastCustLedgerEntryNo, true);

        // [THEN] The seven customer ledger entries will be created
        VerifyCustLedgerEntryCount(LastCustLedgerEntryNo, 6);

        // [THEN] The error will occurs when attempting to unapply customer ledger entries
        VerifyErrors();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure CancelApplicationOfCustLedgerEntryForUnlinkedAdvanceLetterFromInvoice()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesLine: Record "Sales Line";
        PostedDocumentNo: Code[20];
        LastCustLedgerEntryNo: Integer;
    begin
        // [SCENARIO] Cancellation of application of customer ledger entry for an unlinked advance letter to invoice must fail
        Initialize();

        LastCustLedgerEntryNo := GetLastCustLedgerEntryNo();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

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

        // [GIVEN] Unlink sales advance letter from posted sales invoice
        SalesInvoiceHeader.Get(PostedDocumentNo);
        SetExpectedConfirm(StrSubstNo(UnapplyAdvLetterQst, SalesAdvLetterHeaderCZZ."No."), true);
        LibrarySalesAdvancesCZZ.UnapplyAdvanceLetter(SalesInvoiceHeader);
        Commit();

        // [WHEN] Unapply all customer ledger entries created by advance payment
        UnApplyCustLedgerEntries(LastCustLedgerEntryNo, true);

        // [THEN] The seven customer ledger entries will be created
        VerifyCustLedgerEntryCount(LastCustLedgerEntryNo, 8);

        // [THEN] The error will occurs when attempting to unapply customer ledger entries
        VerifyErrors();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure CancelApplicationOfCustLedgerEntryForRelinkedAdvanceLetterToInvoice()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesLine: Record "Sales Line";
        PostedDocumentNo: Code[20];
        LastCustLedgerEntryNo: Integer;
    begin
        // [SCENARIO] Cancellation of application of customer ledger entry for a relinked advance letter to invoice must fail
        Initialize();

        LastCustLedgerEntryNo := GetLastCustLedgerEntryNo();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ);

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

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

        // [GIVEN] Unlink sales advance letter from posted sales invoice
        SalesInvoiceHeader.Get(PostedDocumentNo);
        SetExpectedConfirm(StrSubstNo(UnapplyAdvLetterQst, SalesAdvLetterHeaderCZZ."No."), true);
        LibrarySalesAdvancesCZZ.UnapplyAdvanceLetter(SalesInvoiceHeader);

        // [GIVEN] Link advance letter to posted sales invoice
        SetExpectedConfirm(ApplyAdvanceLetterQst, true);
        LibrarySalesAdvancesCZZ.ApplySalesAdvanceLetter(SalesAdvLetterHeaderCZZ, SalesInvoiceHeader);
        Commit();

        // [WHEN] Unapply all customer ledger entries created by advance payment
        UnApplyCustLedgerEntries(LastCustLedgerEntryNo, true);

        // [THEN] The seven customer ledger entries will be created
        VerifyCustLedgerEntryCount(LastCustLedgerEntryNo, 10);

        // [THEN] The error will occurs when attempting to unapply customer ledger entries
        VerifyErrors();
    end;

    [Test]
    [HandlerFunctions('CreateSalesAdvLetterHandler,ConfirmHandler')]
    procedure CreateSalesAdvanceLetterFromOrderFor100Per()
    begin
        // [SCENARIO] Create sales advance letter from order for 100% of amount
        // [GIVEN] Sales order has been created
        // [GIVEN] Sales order line has been created
        // [GIVEN] Sales advance letter for 100% has been created from order
        // [WHEN] Release sales advance letter
        // [THEN] Sales advance letter will be created for 100% of order amount
        // [THEN] Sales advance letter will be linked with sales order
        CreateSalesAdvanceLetterFromOrderForAdvancePer(100);
    end;

    [Test]
    [HandlerFunctions('CreateSalesAdvLetterHandler,ConfirmHandler')]
    procedure CreateSalesAdvanceLetterFromOrderFor80Per()
    begin
        // [SCENARIO] Create sales advance letter from order for 80% of amount
        // [GIVEN] Sales order has been created
        // [GIVEN] Sales order line has been created
        // [GIVEN] Sales advance letter for 80% has been created from order
        // [WHEN] Release sales advance letter
        // [THEN] Sales advance letter will be created for 80% of order amount
        // [THEN] Sales advance letter will be linked with sales order
        CreateSalesAdvanceLetterFromOrderForAdvancePer(80);
    end;

    procedure CreateSalesAdvanceLetterFromOrderForAdvancePer(AdvancePer: Decimal)
    var
        Currency: Record Currency;
        TempAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ" temporary;
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        AdvanceAmount: Decimal;
    begin
        Initialize();

        LibrarySalesAdvancesCZZ.CreateSalesOrder(SalesHeader, SalesLine);
        SalesHeader.CalcFields("Amount Including VAT");

        SetExpectedConfirm(OpenAdvanceLetterQst, false);
        CreateSalesAdvLetterFromOrderWithAdvancePer(SalesHeader, AdvanceLetterTemplateCZZ.Code, AdvancePer, false, SalesAdvLetterHeaderCZZ);
        Currency.InitRoundingPrecision();
        AdvanceAmount := Round(SalesHeader."Amount Including VAT" * (AdvancePer / 100), Currency."Amount Rounding Precision");

        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        SalesAdvLetterHeaderCZZ.TestField("Amount Including VAT", AdvanceAmount);
        SalesAdvLetterHeaderCZZ.TestField(Status, SalesAdvLetterHeaderCZZ.Status::"To Pay");

        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"Initial Entry");
        SalesAdvLetterEntryCZZ.SetRange(Amount, AdvanceAmount);
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ);

        TempAdvanceLetterApplicationCZZ.GetAssignedAdvance(Enum::"Adv. Letter Usage Doc.Type CZZ"::"Sales Order", SalesHeader."No.", TempAdvanceLetterApplicationCZZ);
        TempAdvanceLetterApplicationCZZ.SetRange("Advance Letter Type", Enum::"Advance Letter Type CZZ"::Sales);
        TempAdvanceLetterApplicationCZZ.SetRange("Advance Letter No.", SalesAdvLetterHeaderCZZ."No.");
        TempAdvanceLetterApplicationCZZ.SetRange(Amount, AdvanceAmount);
        Assert.RecordIsNotEmpty(TempAdvanceLetterApplicationCZZ);
    end;

    [Test]
    [HandlerFunctions('CreateSalesAdvLetterHandler,ConfirmHandler')]
    procedure CreateSalesAdvanceLetterFromOrderForAdvanceAmount()
    var
        Currency: Record Currency;
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        AdvanceAmount: Decimal;
    begin
        // [SCENARIO] Create sales advance letter from order for specified advance amount
        Initialize();

        // [GIVEN] Sales order has been created
        // [GIVEN] Sales order line has been created
        LibrarySalesAdvancesCZZ.CreateSalesOrder(SalesHeader, SalesLine);
        SalesHeader.CalcFields("Amount Including VAT");

        // [GIVEN] Sales advance letter for specified amount has been created from order
        Currency.InitRoundingPrecision();
        AdvanceAmount := Round(SalesHeader."Amount Including VAT" * (LibraryRandom.RandIntInRange(1, 99) / 100), Currency."Amount Rounding Precision");
        SetExpectedConfirm(OpenAdvanceLetterQst, false);
        CreateSalesAdvLetterFromOrderWithAdvanceAmount(SalesHeader, AdvanceLetterTemplateCZZ.Code, AdvanceAmount, false, SalesAdvLetterHeaderCZZ);

        // [WHEN] Release sales advance letter
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [THEN] Sales advance letter will be created for specified amount of order
        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        SalesAdvLetterHeaderCZZ.TestField("Amount Including VAT", AdvanceAmount);
        SalesAdvLetterHeaderCZZ.TestField(Status, SalesAdvLetterHeaderCZZ.Status::"To Pay");

        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"Initial Entry");
        SalesAdvLetterEntryCZZ.SetRange(Amount, AdvanceAmount);
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ);
    end;

    [Test]
    [HandlerFunctions('CreateSalesAdvLetterHandler,ConfirmHandler')]
    procedure CreateSalesAdvanceLetterFromOrderByLines()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine1: Record "Sales Line";
        SalesLine2: Record "Sales Line";
        SalesLine3: Record "Sales Line";
    begin
        // [SCENARIO] Create sales advance letter from order by lines
        Initialize();

        // [GIVEN] Sales order has been created
        // [GIVEN] First sales order line has been created
        LibrarySalesAdvancesCZZ.CreateSalesOrder(SalesHeader, SalesLine1);

        // [GIVEN] Second sales order line has been created
        LibrarySales.CreateSalesLine(
          SalesLine2, SalesHeader, SalesLine2.Type::"G/L Account", SalesLine1."No.", 1);
        SalesLine2.Validate("Unit Price", LibraryRandom.RandDec(1000, 2));
        SalesLine2.Modify(true);

        // [GIVEN] Third sales order line has been created
        LibrarySales.CreateSalesLine(
          SalesLine3, SalesHeader, SalesLine3.Type::"G/L Account", SalesLine1."No.", 1);
        SalesLine3.Validate("Unit Price", LibraryRandom.RandDec(1000, 2));
        SalesLine3.Modify(true);

        // [WHEN] Create sales advance letter from order and suggest by lines
        SetExpectedConfirm(OpenAdvanceLetterQst, false);
        CreateSalesAdvLetterFromOrderWithAdvancePer(SalesHeader, AdvanceLetterTemplateCZZ.Code, 100, true, SalesAdvLetterHeaderCZZ);

        // [THEN] Sales advance letter will have the same lines as sales order
        SalesAdvLetterLineCZZ.SetRange("Document No.", SalesAdvLetterHeaderCZZ."No.");
        Assert.RecordCount(SalesAdvLetterLineCZZ, 3);

        // [THEN] Separate sales advance line will be created for each line from sales order
        SalesAdvLetterLineCZZ.SetRange("Line No.", SalesLine1."Line No.");
        SalesAdvLetterLineCZZ.SetRange("Amount Including VAT", SalesLine1."Amount Including VAT");
        Assert.RecordIsNotEmpty(SalesAdvLetterLineCZZ);

        SalesAdvLetterLineCZZ.SetRange("Line No.", SalesLine2."Line No.");
        SalesAdvLetterLineCZZ.SetRange("Amount Including VAT", SalesLine2."Amount Including VAT");
        Assert.RecordIsNotEmpty(SalesAdvLetterLineCZZ);

        SalesAdvLetterLineCZZ.SetRange("Line No.", SalesLine3."Line No.");
        SalesAdvLetterLineCZZ.SetRange("Amount Including VAT", SalesLine3."Amount Including VAT");
        Assert.RecordIsNotEmpty(SalesAdvLetterLineCZZ);
    end;

    [Test]
    procedure LinkUnpaidAdvanceLetterToSalesOrder()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TempAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ" temporary;
    begin
        // [SCENARIO] Link unpaid sales advance letter to sales order
        Initialize();

        // [GIVEN] Sales order has been created
        // [GIVEN] Sales order line has been created
        LibrarySalesAdvancesCZZ.CreateSalesOrder(SalesHeader, SalesLine);

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetterWithCustomer(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ, SalesHeader."Bill-to Customer No.");

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [WHEN] Get list of advance letter available for linking
        TempAdvanceLetterApplicationCZZ.GetPossibleSalesAdvance(
            Enum::"Adv. Letter Usage Doc.Type CZZ"::"Sales Order", SalesHeader."No.", SalesHeader."Bill-to Customer No.",
            SalesHeader."Posting Date", SalesHeader."Currency Code", TempAdvanceLetterApplicationCZZ);

        // [THEN] Sales advance letter won't be available for linking
        TempAdvanceLetterApplicationCZZ.SetRange("Advance Letter Type", Enum::"Advance Letter Type CZZ"::Sales);
        TempAdvanceLetterApplicationCZZ.SetRange("Advance Letter No.", SalesAdvLetterHeaderCZZ."No.");
        Assert.RecordIsEmpty(TempAdvanceLetterApplicationCZZ);
    end;

    [Test]
    procedure LinkPaidAdvanceLetterToSalesOrder()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TempAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ" temporary;
    begin
        // [SCENARIO] Link paid sales advance letter to sales order
        Initialize();

        // [GIVEN] Sales order has been created
        // [GIVEN] Sales order line has been created
        LibrarySalesAdvancesCZZ.CreateSalesOrder(SalesHeader, SalesLine);

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetterWithCustomer(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ, SalesHeader."Bill-to Customer No.");

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

        // [WHEN] Get list of advance letter available for linking
        TempAdvanceLetterApplicationCZZ.GetPossibleSalesAdvance(
            Enum::"Adv. Letter Usage Doc.Type CZZ"::"Sales Order", SalesHeader."No.", SalesHeader."Bill-to Customer No.",
            SalesHeader."Posting Date", SalesHeader."Currency Code", TempAdvanceLetterApplicationCZZ);

        // [THEN] Sales advance letter will be available for linking
        TempAdvanceLetterApplicationCZZ.SetRange("Advance Letter Type", Enum::"Advance Letter Type CZZ"::Sales);
        TempAdvanceLetterApplicationCZZ.SetRange("Advance Letter No.", SalesAdvLetterHeaderCZZ."No.");
        Assert.RecordIsNotEmpty(TempAdvanceLetterApplicationCZZ);
    end;

    [Test]
    [HandlerFunctions('CreateSalesAdvLetterHandler,ConfirmHandler')]
    procedure CloseLinkedAdvanceLetterWithSalesOrder()
    var
        TempAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ" temporary;
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [SCENARIO] Close linked sales advance letter with sales order
        Initialize();

        // [GIVEN] Sales order has been created
        // [GIVEN] Sales order line has been created
        LibrarySalesAdvancesCZZ.CreateSalesOrder(SalesHeader, SalesLine);

        // [GIVEN] Sales advance letter for 100% has been created from order
        SetExpectedConfirm(OpenAdvanceLetterQst, false);
        CreateSalesAdvLetterFromOrderWithAdvancePer(SalesHeader, AdvanceLetterTemplateCZZ.Code, 100, false, SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [WHEN] Close sales advance letter
        LibrarySalesAdvancesCZZ.CloseSalesAdvanceLetter(SalesAdvLetterHeaderCZZ);

        // [THEN] Sales advance letter won't be linked with sales order
        TempAdvanceLetterApplicationCZZ.GetAssignedAdvance(
            Enum::"Adv. Letter Usage Doc.Type CZZ"::"Sales Order", SalesHeader."No.", TempAdvanceLetterApplicationCZZ);
        TempAdvanceLetterApplicationCZZ.Reset();
        Assert.RecordIsEmpty(TempAdvanceLetterApplicationCZZ);
    end;

    [Test]
    [HandlerFunctions('CreateSalesAdvLetterHandler,ConfirmHandler')]
    procedure AdvancePaymentByCashDesk()
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [SCENARIO] Advance payment by cash desk
        Initialize();

        // [GIVEN] Sales order has been created
        // [GIVEN] Sales order line has been created
        LibrarySalesAdvancesCZZ.CreateSalesOrder(SalesHeader, SalesLine);

        // [GIVEN] Sales advance letter for 100% has been created from order
        SetExpectedConfirm(OpenAdvanceLetterQst, false);
        CreateSalesAdvLetterFromOrderWithAdvancePer(SalesHeader, AdvanceLetterTemplateCZZ.Code, 100, false, SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Cash document has been created
        CreateCashDocument(CashDocumentHeaderCZP, CashDocumentLineCZP,
            Enum::"Cash Document Type CZP"::Receipt, SalesAdvLetterHeaderCZZ);

        // [WHEN] Post cash document
        SetExpectedConfirm(StrSubstNo(PostCashDocumentQst, CashDocumentHeaderCZP."No."), true);
        PostCashDocument(CashDocumentHeaderCZP);

        // [THEN] Sales advance letter will be paid in full by cash document
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Payment);
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ);

        // [THEN] Sales advance letter will be to use
        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterHeaderCZZ.TestField(Status, SalesAdvLetterHeaderCZZ.Status::"To Use");
    end;

    [Test]
    [HandlerFunctions('CreateSalesAdvLetterHandler,ConfirmHandler')]
    procedure SalesInvoiceWithAdvanceLetterPostedFromSalesOrder()
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        VATEntry: Record "VAT Entry";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Sales invoice with advance letter posted from sales order
        Initialize();

        // [GIVEN] Sales order has been created
        // [GIVEN] Sales order line has been created
        LibrarySalesAdvancesCZZ.CreateSalesOrder(SalesHeader, SalesLine);

        // [GIVEN] Sales advance letter for 100% has been created from order
        SetExpectedConfirm(OpenAdvanceLetterQst, false);
        CreateSalesAdvLetterFromOrderWithAdvancePer(SalesHeader, AdvanceLetterTemplateCZZ.Code, 100, false, SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Cash document has been created
        CreateCashDocument(CashDocumentHeaderCZP, CashDocumentLineCZP,
            Enum::"Cash Document Type CZP"::Receipt, SalesAdvLetterHeaderCZZ);

        // [GIVEN] Cash document has been posted
        SetExpectedConfirm(StrSubstNo(PostCashDocumentQst, CashDocumentHeaderCZP."No."), true);
        PostCashDocument(CashDocumentHeaderCZP);

        // [WHEN] Post sales order
        PostedDocumentNo := PostSalesDocument(SalesHeader);

        // [THEN] VAT entries of sales invoice and advance letter will exist
        VATEntry.Reset();
        VATEntry.SetRange("Document No.", PostedDocumentNo);
        VATEntry.SetRange("Posting Date", SalesHeader."Posting Date");
        Assert.RecordIsNotEmpty(VATEntry);

        // [THEN] Sum of base and VAT amounts in VAT entries will be zero
        VATEntry.CalcSums(Base, Amount);
        Assert.AreEqual(0, VATEntry.Base, 'The sum of base amount in VAT Entries must be zero.');
        Assert.AreEqual(0, VATEntry.Amount, 'The sum of VAT amount in VAT Entries must be zero.');

        // [THEN] Sales advance letter will exist
        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ);

        // [THEN] Sum of base and VAT amounts in advance letter entries will be zero
        SalesAdvLetterEntryCZZ.CalcSums("VAT Base Amount", "VAT Amount");
        Assert.AreEqual(0, SalesAdvLetterEntryCZZ."VAT Base Amount", 'The sum of base amount in advance letter entries must be zero.');
        Assert.AreEqual(0, SalesAdvLetterEntryCZZ."VAT Amount", 'The sum of VAT amount in VAT advance letter must be zero.');

        // [THEN] Sales advance letter will be closed
        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterHeaderCZZ.TestField(Status, SalesAdvLetterHeaderCZZ.Status::Closed);
    end;

    [Test]
    [HandlerFunctions('CreateSalesAdvLetterHandler,ConfirmHandler')]
    procedure AdvancePaymentWithLaterDateThanOrderDate()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TempAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ" temporary;
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Advance payment with later date than order date
        Initialize();

        // [GIVEN] Sales order has been created
        // [GIVEN] Sales order line has been created
        LibrarySalesAdvancesCZZ.CreateSalesOrder(SalesHeader, SalesLine);

        // [GIVEN] Sales advance letter for 100% has been created from order
        SetExpectedConfirm(OpenAdvanceLetterQst, false);
        CreateSalesAdvLetterFromOrderWithAdvancePer(SalesHeader, AdvanceLetterTemplateCZZ.Code, 100, false, SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT", 0, WorkDate() + 1);

        // [WHEN] Post sales order
        SetExpectedConfirm(StrSubstNo(LaterAdvancePaymentQst, SalesAdvLetterHeaderCZZ."No.", SalesHeader."Posting Date"), true);
        PostedDocumentNo := PostSalesDocument(SalesHeader);

        // [THEN] Customer ledger entry created by invoice will be unapplied
        CustLedgerEntry.SetRange("Document No.", PostedDocumentNo);
        CustLedgerEntry.FindLast();
        CustLedgerEntry.CalcFields("Remaining Amount");
        Assert.AreNotEqual(0, CustLedgerEntry."Remaining Amount", 'The remaining amount in customer ledger entry must be not zero.');

        // [THEN] Sales advance lettere won't be deducted
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Usage);
        Assert.RecordIsEmpty(SalesAdvLetterEntryCZZ);

        TempAdvanceLetterApplicationCZZ.GetAssignedAdvance(Enum::"Adv. Letter Usage Doc.Type CZZ"::"Sales Order", SalesHeader."No.", TempAdvanceLetterApplicationCZZ);
        Assert.RecordIsEmpty(TempAdvanceLetterApplicationCZZ);

        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterHeaderCZZ.TestField(Status, SalesAdvLetterHeaderCZZ.Status::"To Use");
    end;

    [Test]
    [HandlerFunctions('CreateSalesAdvLetterHandler,ConfirmHandler')]
    procedure NoticeToUnpaidSalesAdvanceLetter()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [SCENARIO] Notice to unpaid sales advance letter
        Initialize();

        // [GIVEN] Sales order has been created
        // [GIVEN] Sales order line has been created
        LibrarySalesAdvancesCZZ.CreateSalesOrder(SalesHeader, SalesLine);

        // [GIVEN] Sales advance letter for 100% has been created from order
        SetExpectedConfirm(OpenAdvanceLetterQst, false);
        CreateSalesAdvLetterFromOrderWithAdvancePer(SalesHeader, AdvanceLetterTemplateCZZ.Code, 100, false, SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [WHEN] Post sales order
        SetExpectedConfirm(StrSubstNo(UsageNoPossibleQst), true);
        PostSalesDocument(SalesHeader);

        // [THEN] Confirm handler will be called
    end;

    [Test]
    [HandlerFunctions('CreateSalesAdvLetterHandler,ConfirmHandler')]
    procedure DeductAdvanceLetterByQuantityToInvoice()
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesLine: Record "Sales Line";
        VATEntry: Record "VAT Entry";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Deduct advance letter by quantity to invoice
        Initialize();

        // [GIVEN] Sales order has been created
        // [GIVEN] Sales order line has been created
        LibrarySalesAdvancesCZZ.CreateSalesOrder(SalesHeader, SalesLine);

        // [GIVEN] Sales advance letter for 100% has been created from order
        SetExpectedConfirm(OpenAdvanceLetterQst, false);
        CreateSalesAdvLetterFromOrderWithAdvancePer(SalesHeader, AdvanceLetterTemplateCZZ.Code, 100, false, SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

        // [GIVEN] "Qty. to Invoice" and "Qty. to Ship" fields in sales order line have been modified to 1
        SalesLine.Validate("Qty. to Invoice", 1);
        SalesLine.Validate("Qty. to Ship", 1);
        SalesLine.Modify(true);

        // [WHEN] Post sales order
        PostedDocumentNo := PostSalesDocument(SalesHeader);

        // [THEN] VAT entries of sales invoice and advance letter will exist
        VATEntry.Reset();
        VATEntry.SetRange("Document No.", PostedDocumentNo);
        VATEntry.SetRange("Posting Date", SalesHeader."Posting Date");
        Assert.RecordIsNotEmpty(VATEntry);

        // [THEN] Sum of base and VAT amounts in VAT entries will be zero
        VATEntry.CalcSums(Base, Amount);
        Assert.AreEqual(0, VATEntry.Base, 'The sum of base amount in VAT Entries must be zero.');
        Assert.AreEqual(0, VATEntry.Amount, 'The sum of VAT amount in VAT Entries must be zero.');

        // [THEN] Sales advance letter entry with usage will exist
        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Document No.", PostedDocumentNo);
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Usage);
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ);

        SalesInvoiceHeader.Get(PostedDocumentNo);
        SalesInvoiceHeader.CalcFields("Amount Including VAT");
        SalesAdvLetterEntryCZZ.FindFirst();
        SalesAdvLetterEntryCZZ.TestField(Amount, SalesInvoiceHeader."Amount Including VAT");

        // [THEN] Sales advance letter will be to use
        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterHeaderCZZ.TestField(Status, SalesAdvLetterHeaderCZZ.Status::"To Use");
    end;

    [Test]
    [HandlerFunctions('CreateSalesAdvLetterHandler,ConfirmHandler')]
    procedure NegativeLineInSalesOrder()
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine1: Record "Sales Line";
        SalesLine2: Record "Sales Line";
        VATEntry: Record "VAT Entry";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Negative line in sales order
        Initialize();

        // [GIVEN] Sales order has been created
        // [GIVEN] Sales order line has been created
        LibrarySalesAdvancesCZZ.CreateSalesOrder(SalesHeader, SalesLine1);

        // [GIVEN] Second sales order line has been created
        LibrarySales.CreateSalesLine(
          SalesLine2, SalesHeader, SalesLine2.Type::"G/L Account", SalesLine1."No.", -1);
        SalesLine2.Validate("Unit Price", SalesLine1."Unit Price" / 2);
        SalesLine2.Modify(true);

        // [GIVEN] Sales advance letter for 100% has been created from order
        SetExpectedConfirm(OpenAdvanceLetterQst, false);
        CreateSalesAdvLetterFromOrderWithAdvancePer(SalesHeader, AdvanceLetterTemplateCZZ.Code, 100, false, SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT");

        // [WHEN] Post sales order
        PostedDocumentNo := PostSalesDocument(SalesHeader);

        // [THEN] VAT entries of sales invoice and advance letter will exist
        VATEntry.Reset();
        VATEntry.SetRange("Document No.", PostedDocumentNo);
        VATEntry.SetRange("Posting Date", SalesHeader."Posting Date");
        Assert.RecordIsNotEmpty(VATEntry);

        // [THEN] Sum of base and VAT amounts in VAT entries will be zero
        VATEntry.CalcSums(Base, Amount);
        Assert.AreEqual(0, VATEntry.Base, 'The sum of base amount in VAT Entries must be zero.');
        Assert.AreEqual(0, VATEntry.Amount, 'The sum of VAT amount in VAT Entries must be zero.');

        // [THEN] Sales advance letter will exist
        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ);

        // [THEN] Sum of base and VAT amounts in advance letter entries will be zero
        SalesAdvLetterEntryCZZ.CalcSums("VAT Base Amount", "VAT Amount");
        Assert.AreEqual(0, SalesAdvLetterEntryCZZ."VAT Base Amount", 'The sum of base amount in advance letter entries must be zero.');
        Assert.AreEqual(0, SalesAdvLetterEntryCZZ."VAT Amount", 'The sum of VAT amount in VAT advance letter must be zero.');

        // [THEN] Sales advance letter will be closed
        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterHeaderCZZ.TestField(Status, SalesAdvLetterHeaderCZZ.Status::Closed);
    end;

    [Test]
    procedure VATPaymentToSalesAdvLetterWithTwoVATRates()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ1: Record "Sales Adv. Letter Line CZZ";
        SalesAdvLetterLineCZZ2: Record "Sales Adv. Letter Line CZZ";
        SalesAdvLetterEntryCZZ1: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        // [SCENARIO] VAT payment to Sales advance letter with two VAT rates
        Initialize();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ1);

        // [GIVEN] Second Sales advance letter line with normal VAT has been created
        FindNextVATPostingSetup(VATPostingSetup);
        LibrarySalesAdvancesCZZ.CreateSalesAdvLetterLine(
            SalesAdvLetterLineCZZ2, SalesAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [WHEN] Create and post payment of sales advance letter
        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterHeaderCZZ."Amount Including VAT");

        // [THEN] Two Sales advance letter entries of "VAT Payment" type will exist
        SalesAdvLetterEntryCZZ1.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ1.SetRange("Entry Type", SalesAdvLetterEntryCZZ1."Entry Type"::"VAT Payment");
        Assert.RecordCount(SalesAdvLetterEntryCZZ1, 2);

        // [THEN] Sum of amounts in Sales advance letter entries will be the same as in entry with "Payment" type
        SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ2.SetRange("Entry Type", SalesAdvLetterEntryCZZ2."Entry Type"::Payment);
        SalesAdvLetterEntryCZZ2.FindLast();
        SalesAdvLetterEntryCZZ1.CalcSums(Amount);
        Assert.AreEqual(SalesAdvLetterEntryCZZ1.Amount, SalesAdvLetterEntryCZZ2.Amount, 'The sum of amounts in Sales advance letter entries must be the same as in entry with "Payment" type.');
    end;

    [Test]
    procedure UnlinkAdvancePaymentFromSalesAdvLetterWithTwoLines()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ1: Record "Sales Adv. Letter Line CZZ";
        SalesAdvLetterLineCZZ2: Record "Sales Adv. Letter Line CZZ";
        SalesAdvLetterEntryCZZ1: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        // [SCENARIO] Unlink advance payment from Sales advance letter with two lines
        Initialize();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ1);

        // [GIVEN] Second Sales advance letter line with normal VAT has been created
        FindNextVATPostingSetup(VATPostingSetup);
        LibrarySalesAdvancesCZZ.CreateSalesAdvLetterLine(
            SalesAdvLetterLineCZZ2, SalesAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterHeaderCZZ."Amount Including VAT");

        // [WHEN] Unlink advance letter from payment
        FindLastPaymentAdvanceLetterEntry(SalesAdvLetterHeaderCZZ."No.", SalesAdvLetterEntryCZZ1);
        LibrarySalesAdvancesCZZ.UnlinkSalesAdvancePayment(SalesAdvLetterEntryCZZ1);

        // [THEN] Sales advance letter entries of "Payment" and "VAT Payment" type with opposite sign will exist
        SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ2.Find('+');
        Assert.AreEqual(SalesAdvLetterEntryCZZ2."Entry Type"::Payment, SalesAdvLetterEntryCZZ2."Entry Type", 'The Sales advance letter entry must be of type "Payment".');
        Assert.AreEqual(-SalesAdvLetterEntryCZZ1.Amount, SalesAdvLetterEntryCZZ2.Amount, 'The amount must have the opposite sign.');
        Assert.AreEqual(SalesAdvLetterEntryCZZ1."Entry No.", SalesAdvLetterEntryCZZ2."Related Entry", 'The entry must be related to entry of "Payment" type');

        SalesAdvLetterEntryCZZ2.Next(-1);
        Assert.AreEqual(SalesAdvLetterEntryCZZ2."Entry Type"::"VAT Payment", SalesAdvLetterEntryCZZ2."Entry Type", 'The Sales advance letter entry must be of type "VAT Payment".');
        Assert.AreEqual(SalesAdvLetterLineCZZ2."Amount Including VAT", SalesAdvLetterEntryCZZ2.Amount, 'The amount must have the opposite sign.');

        SalesAdvLetterEntryCZZ2.Next(-1);
        Assert.AreEqual(SalesAdvLetterEntryCZZ2."Entry Type"::"VAT Payment", SalesAdvLetterEntryCZZ2."Entry Type", 'The Sales advance letter entry must be of type "VAT Payment".');
        Assert.AreEqual(SalesAdvLetterLineCZZ1."Amount Including VAT", SalesAdvLetterEntryCZZ2.Amount, 'The amount must have the opposite sign.');

        SalesAdvLetterEntryCZZ2.SetFilter("Entry Type", '%1|%2',
            SalesAdvLetterEntryCZZ2."Entry Type"::Payment, SalesAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
        SalesAdvLetterEntryCZZ2.CalcSums(Amount);
        Assert.AreEqual(0, SalesAdvLetterEntryCZZ2.Amount, 'The sum of amounts in Sales advance letter entries must be zero.');

        // [THEN] Sales advance letter status will be "To Pay"
        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterHeaderCZZ.TestField(Status, SalesAdvLetterHeaderCZZ.Status::"To Pay");
    end;

    [Test]
    procedure CreateSalesAdvLetterWithTwoLinesAndLinkToInvoice()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ1: Record "Sales Adv. Letter Line CZZ";
        SalesAdvLetterLineCZZ2: Record "Sales Adv. Letter Line CZZ";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        VATEntry: Record "VAT Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Create Sales advance letter with two lines and link to invoice with line which is the same as first line in advance letter
        Initialize();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ1);

        // [GIVEN] Second Sales advance letter line with normal VAT has been created
        FindNextVATPostingSetup(VATPostingSetup);
        LibrarySalesAdvancesCZZ.CreateSalesAdvLetterLine(
            SalesAdvLetterLineCZZ2, SalesAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterHeaderCZZ."Amount Including VAT");

        // [GIVEN] Sales invoice has been created
        // [GIVEN] Sales invoice line has been created
        LibrarySalesAdvancesCZZ.CreateSalesInvoice(
            SalesHeader, SalesLine, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", SalesAdvLetterHeaderCZZ."Posting Date",
            SalesAdvLetterLineCZZ1."VAT Bus. Posting Group", SalesAdvLetterLineCZZ1."VAT Prod. Posting Group", '', 0,
            true, SalesAdvLetterLineCZZ1."Amount Including VAT");

        // [GIVEN] Whole advance letter has been linked to Sales invoice
        LibrarySalesAdvancesCZZ.LinkSalesAdvanceLetterToDocument(
            SalesAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Sales Invoice", SalesHeader."No.",
            SalesAdvLetterLineCZZ1."Amount Including VAT", SalesAdvLetterLineCZZ1."Amount Including VAT (LCY)");

        // [WHEN] Post Sales invoice
        PostedDocumentNo := PostSalesDocument(SalesHeader);

        // [THEN] VAT entries of Sales invoice will exist
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

        // [THEN] Only one Sales advance letter entry of "VAT Usage" type will exist
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Usage");
        Assert.RecordCount(SalesAdvLetterEntryCZZ, 1);

        // [THEN] Sum of amounts in Sales advance letter entries of "VAT payment" and "VAT usage" type will be zero
        SalesAdvLetterEntryCZZ.FindFirst();
        SalesAdvLetterEntryCZZ.SetRange("VAT Bus. Posting Group", SalesAdvLetterEntryCZZ."VAT Bus. Posting Group");
        SalesAdvLetterEntryCZZ.SetRange("VAT Prod. Posting Group", SalesAdvLetterEntryCZZ."VAT Prod. Posting Group");
        SalesAdvLetterEntryCZZ.SetFilter("Entry Type", '%1|%2',
            SalesAdvLetterEntryCZZ."Entry Type"::"VAT Usage", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        SalesAdvLetterEntryCZZ.CalcSums(Amount);
        Assert.AreEqual(0, SalesAdvLetterEntryCZZ.Amount, 'The sum of amounts in Sales advance letter entries must be zero.');
    end;

    [Test]
    procedure CreateSalesAdvLetterWithTwoLinesAndLinkToInvoice2()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ1: Record "Sales Adv. Letter Line CZZ";
        SalesAdvLetterLineCZZ2: Record "Sales Adv. Letter Line CZZ";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        VATEntry: Record "VAT Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Create Sales advance letter with two lines and link to invoice with line which is the same as second line in advance letter
        Initialize();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ1);

        // [GIVEN] Second Sales advance letter line with normal VAT has been created
        FindNextVATPostingSetup(VATPostingSetup);
        LibrarySalesAdvancesCZZ.CreateSalesAdvLetterLine(
            SalesAdvLetterLineCZZ2, SalesAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterHeaderCZZ."Amount Including VAT");

        // [GIVEN] Sales invoice has been created
        // [GIVEN] Sales invoice line has been created
        LibrarySalesAdvancesCZZ.CreateSalesInvoice(
            SalesHeader, SalesLine, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", SalesAdvLetterHeaderCZZ."Posting Date",
            SalesAdvLetterLineCZZ2."VAT Bus. Posting Group", SalesAdvLetterLineCZZ2."VAT Prod. Posting Group", '', 0,
            true, SalesAdvLetterLineCZZ2."Amount Including VAT");

        // [GIVEN] Whole advance letter has been linked to Sales invoice
        LibrarySalesAdvancesCZZ.LinkSalesAdvanceLetterToDocument(
            SalesAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Sales Invoice", SalesHeader."No.",
            SalesAdvLetterLineCZZ2."Amount Including VAT", SalesAdvLetterLineCZZ2."Amount Including VAT (LCY)");

        // [WHEN] Post Sales invoice
        PostedDocumentNo := PostSalesDocument(SalesHeader);

        // [THEN] VAT entries of Sales invoice will exist
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

        // [THEN] Only one Sales advance letter entry of "VAT Usage" type will exist
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Usage");
        Assert.RecordCount(SalesAdvLetterEntryCZZ, 1);

        // [THEN] Sum of amounts in Sales advance letter entries of "VAT payment" and "VAT usage" type will be zero
        SalesAdvLetterEntryCZZ.FindFirst();
        SalesAdvLetterEntryCZZ.SetRange("VAT Bus. Posting Group", SalesAdvLetterEntryCZZ."VAT Bus. Posting Group");
        SalesAdvLetterEntryCZZ.SetRange("VAT Prod. Posting Group", SalesAdvLetterEntryCZZ."VAT Prod. Posting Group");
        SalesAdvLetterEntryCZZ.SetFilter("Entry Type", '%1|%2',
            SalesAdvLetterEntryCZZ."Entry Type"::"VAT Usage", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        SalesAdvLetterEntryCZZ.CalcSums(Amount);
        Assert.AreEqual(0, SalesAdvLetterEntryCZZ.Amount, 'The sum of amounts in Sales advance letter entries must be zero.');
    end;

    [Test]
    procedure VATPaymentToSalesAdvLetterWithTwoVATRatesPartiallyPaid()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ1: Record "Sales Adv. Letter Line CZZ";
        SalesAdvLetterLineCZZ2: Record "Sales Adv. Letter Line CZZ";
        SalesAdvLetterEntryCZZ1: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        // [SCENARIO] VAT payment to Sales advance letter with two VAT rates partially paid
        Initialize();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ1);

        // [GIVEN] Second Sales advance letter line with normal VAT has been created
        FindNextVATPostingSetup(VATPostingSetup);
        LibrarySalesAdvancesCZZ.CreateSalesAdvLetterLine(
            SalesAdvLetterLineCZZ2, SalesAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been half paid by the general journal
        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ,
            Round(-SalesAdvLetterLineCZZ1."Amount Including VAT" / 2) +
            Round(-SalesAdvLetterLineCZZ2."Amount Including VAT" / 2));

        // [THEN] Two Sales advance letter entries of "VAT Payment" type will exist
        SalesAdvLetterEntryCZZ1.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ1.SetRange("Entry Type", SalesAdvLetterEntryCZZ1."Entry Type"::"VAT Payment");
        Assert.RecordCount(SalesAdvLetterEntryCZZ1, 2);

        // [THEN] Sum of amounts in Sales advance letter entries will be the same as in entry with "Payment" type
        SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ2.SetRange("Entry Type", SalesAdvLetterEntryCZZ2."Entry Type"::Payment);
        SalesAdvLetterEntryCZZ2.FindLast();
        SalesAdvLetterEntryCZZ1.CalcSums(Amount);
        Assert.AreEqual(SalesAdvLetterEntryCZZ1.Amount, SalesAdvLetterEntryCZZ2.Amount, 'The sum of amounts in Sales advance letter entries must be the same as in entry with "Payment" type.');
    end;

    [Test]
    procedure CreateSalesAdvLetterWithTwoLinesAndLinkToInvoiceWithLowerAmount()
    var
        GLAccount: Record "G/L Account";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ1: Record "Sales Adv. Letter Line CZZ";
        SalesAdvLetterLineCZZ2: Record "Sales Adv. Letter Line CZZ";
        SalesAdvLetterEntryCZZ1: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine1: Record "Sales Line";
        SalesLine2: Record "Sales Line";
        VATEntry: Record "VAT Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Create Sales advance letter with two lines and link to invoice with amount lower than advance letter
        Initialize();

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ1);

        // [GIVEN] Second Sales advance letter line with normal VAT has been created
        FindNextVATPostingSetup(VATPostingSetup);
        LibrarySalesAdvancesCZZ.CreateSalesAdvLetterLine(
            SalesAdvLetterLineCZZ2, SalesAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterHeaderCZZ."Amount Including VAT");

        // [GIVEN] Sales invoice has been created
        // [GIVEN] First Sales invoice line with amount lower than first line of advance letter has been created
        LibrarySalesAdvancesCZZ.CreateSalesInvoice(
            SalesHeader, SalesLine1, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", SalesAdvLetterHeaderCZZ."Posting Date",
            SalesAdvLetterLineCZZ1."VAT Bus. Posting Group", SalesAdvLetterLineCZZ1."VAT Prod. Posting Group", '', 0,
            true, SalesAdvLetterLineCZZ1."Amount Including VAT" - 1);

        // [GIVEN] Second Sales invoice line with amount lower than second line of advance letter has been created
        LibrarySalesAdvancesCZZ.CreateGLAccount(GLAccount);
        GLAccount.Validate("VAT Bus. Posting Group", SalesAdvLetterLineCZZ2."VAT Bus. Posting Group");
        GLAccount.Validate("VAT Prod. Posting Group", SalesAdvLetterLineCZZ2."VAT Prod. Posting Group");
        GLAccount.Modify(true);
        LibrarySales.CreateSalesLine(SalesLine2, SalesHeader, SalesLine2.Type::"G/L Account", GLAccount."No.", 1);
        SalesLine2.Validate("Unit Price", SalesAdvLetterLineCZZ2."Amount Including VAT" - 1);
        SalesLine2.Modify(true);

        // [GIVEN] Whole advance letter has been linked to Sales invoice
        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT", "Amount Including VAT (LCY)");
        LibrarySalesAdvancesCZZ.LinkSalesAdvanceLetterToDocument(
            SalesAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Sales Invoice", SalesHeader."No.",
            SalesAdvLetterHeaderCZZ."Amount Including VAT", SalesAdvLetterHeaderCZZ."Amount Including VAT (LCY)");

        // [WHEN] Post Sales invoice
        PostedDocumentNo := PostSalesDocument(SalesHeader);

        // [THEN] VAT entries of Sales invoice will exist
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

        // [THEN] One Sales advance letter entry of "Usage" type will exist
        SalesAdvLetterEntryCZZ1.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ1.SetRange("Entry Type", SalesAdvLetterEntryCZZ1."Entry Type"::Usage);
        Assert.RecordCount(SalesAdvLetterEntryCZZ1, 1);

        // [THEN] Two Sales advance letter entries of "VAT Usage" type will exist
        SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ2.SetRange("Entry Type", SalesAdvLetterEntryCZZ2."Entry Type"::"VAT Usage");
        Assert.RecordCount(SalesAdvLetterEntryCZZ2, 2);

        // [THEN] Sum of amounts in Sales advance letter entries of "VAT Usage" type will be the same as in Usage type of entry
        SalesAdvLetterEntryCZZ1.FindFirst();
        SalesAdvLetterEntryCZZ2.CalcSums(Amount);
        Assert.AreEqual(SalesAdvLetterEntryCZZ1.Amount, SalesAdvLetterEntryCZZ2.Amount, 'The sum of amounts in Sales advance letter entries must be the same as in entry with "Usage" type.');
    end;

    [Test]
    procedure CreateSalesAdvLetterWithTwoDiffVATRatesAndLinkToInvoiceWithOneVATRate()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ1: Record "Sales Adv. Letter Line CZZ";
        SalesAdvLetterLineCZZ2: Record "Sales Adv. Letter Line CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        VATEntry: Record "VAT Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        PostedDocumentNo: Code[20];
        VATEntryCount: Integer;
    begin
        // [SCENARIO] Create Sales advance letter with two lines with different VAT rates and link to invoice with
        //            with line which is the same as first line in advance letter and one VAT rate
        Initialize();

        // [GIVEN] Posting of VAT documents for reverse charge has been enabled
        SetPostVATDocForReverseCharge(true);

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ1);

        // [GIVEN] Second Sales advance letter line with reverse charge has been created
        LibrarySalesAdvancesCZZ.FindVATPostingSetupEU(VATPostingSetup);
        LibrarySalesAdvancesCZZ.CreateSalesAdvLetterLine(
            SalesAdvLetterLineCZZ2, SalesAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterHeaderCZZ."Amount Including VAT");

        // [GIVEN] Sales invoice has been created
        // [GIVEN] Sales invoice line by first line of advance letter has been created
        LibrarySalesAdvancesCZZ.CreateSalesInvoice(
            SalesHeader, SalesLine, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", SalesAdvLetterHeaderCZZ."Posting Date",
            SalesAdvLetterLineCZZ1."VAT Bus. Posting Group", SalesAdvLetterLineCZZ1."VAT Prod. Posting Group", '', 0,
            true, SalesAdvLetterLineCZZ1."Amount Including VAT");

        // [GIVEN] Whole advance letter has been linked to Sales invoice
        LibrarySalesAdvancesCZZ.LinkSalesAdvanceLetterToDocument(
            SalesAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Sales Invoice", SalesHeader."No.",
            SalesAdvLetterLineCZZ1."Amount Including VAT", SalesAdvLetterLineCZZ1."Amount Including VAT (LCY)");

        // [WHEN] Post Sales invoice
        PostedDocumentNo := PostSalesDocument(SalesHeader);

        // [THEN] VAT entries of Sales invoice will exist
        VATEntry.Reset();
        VATEntry.SetRange("VAT Bus. Posting Group", SalesAdvLetterLineCZZ1."VAT Bus. Posting Group");
        VATEntry.SetRange("VAT Prod. Posting Group", SalesAdvLetterLineCZZ1."VAT Prod. Posting Group");
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

        // [THEN] All VAT entries will have the same VAT posting group
        VATEntryCount := VATEntry.Count();
        VATEntry.FindFirst();
        VATEntry.SetRange("VAT Bus. Posting Group", VATEntry."VAT Bus. Posting Group");
        VATEntry.SetRange("VAT Prod. Posting Group", VATEntry."VAT Prod. Posting Group");
        Assert.RecordCount(VATEntry, VATEntryCount);

        SetPostVATDocForReverseCharge(false);
    end;

    [Test]
    procedure CreateSalesAdvLetterWithTwoDiffVATRatesAndLinkToInvoiceWithOneVATRate2()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ1: Record "Sales Adv. Letter Line CZZ";
        SalesAdvLetterLineCZZ2: Record "Sales Adv. Letter Line CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        VATEntry: Record "VAT Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        PostedDocumentNo: Code[20];
        VATEntryCount: Integer;
    begin
        // [SCENARIO] Create Sales advance letter with two lines with different VAT rates and link to invoice with line which is the same as second line in advance letter and one VAT rate
        Initialize();

        // [GIVEN] Posting of VAT documents for reverse charge has been enabled
        SetPostVATDocForReverseCharge(true);

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ1);

        // [GIVEN] Second Sales advance letter line with reverse charge has been created
        LibrarySalesAdvancesCZZ.FindVATPostingSetupEU(VATPostingSetup);
        LibrarySalesAdvancesCZZ.CreateSalesAdvLetterLine(
            SalesAdvLetterLineCZZ2, SalesAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterHeaderCZZ."Amount Including VAT");

        // [GIVEN] Sales invoice has been created
        // [GIVEN] Sales invoice line by first line of advance letter has been created
        LibrarySalesAdvancesCZZ.CreateSalesInvoice(
            SalesHeader, SalesLine, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", SalesAdvLetterHeaderCZZ."Posting Date",
            SalesAdvLetterLineCZZ2."VAT Bus. Posting Group", SalesAdvLetterLineCZZ2."VAT Prod. Posting Group", '', 0,
            true, SalesAdvLetterLineCZZ2."Amount Including VAT");

        // [GIVEN] Whole advance letter has been linked to Sales invoice
        LibrarySalesAdvancesCZZ.LinkSalesAdvanceLetterToDocument(
            SalesAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Sales Invoice", SalesHeader."No.",
            SalesAdvLetterLineCZZ2."Amount Including VAT", SalesAdvLetterLineCZZ2."Amount Including VAT (LCY)");

        // [WHEN] Post Sales invoice
        PostedDocumentNo := PostSalesDocument(SalesHeader);

        // [THEN] VAT entries of Sales invoice will exist
        VATEntry.Reset();
        VATEntry.SetRange("VAT Bus. Posting Group", SalesAdvLetterLineCZZ2."VAT Bus. Posting Group");
        VATEntry.SetRange("VAT Prod. Posting Group", SalesAdvLetterLineCZZ2."VAT Prod. Posting Group");
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

        // [THEN] All VAT entries will have the same VAT posting group
        VATEntryCount := VATEntry.Count();
        VATEntry.FindFirst();
        VATEntry.SetRange("VAT Bus. Posting Group", VATEntry."VAT Bus. Posting Group");
        VATEntry.SetRange("VAT Prod. Posting Group", VATEntry."VAT Prod. Posting Group");
        Assert.RecordCount(VATEntry, VATEntryCount);

        SetPostVATDocForReverseCharge(false);
    end;

    [Test]
    procedure CreateSalesAdvLetterWithTwoDiffVATRatesAndLinkToInvoiceWithOneVATRate3()
    var
        SalesAdvLetterEntryCZZ1: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ1: Record "Sales Adv. Letter Line CZZ";
        SalesAdvLetterLineCZZ2: Record "Sales Adv. Letter Line CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        // [SCENARIO] Create Sales advance letter with two lines with different VAT rates and link to invoice with line which has the higher amount as first line in advance letter and one VAT rate
        Initialize();

        // [GIVEN] Posting of VAT documents for reverse charge has been enabled
        SetPostVATDocForReverseCharge(true);

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ1);

        // [GIVEN] Second Sales advance letter line with reverse charge has been created
        LibrarySalesAdvancesCZZ.FindVATPostingSetupEU(VATPostingSetup);
        LibrarySalesAdvancesCZZ.CreateSalesAdvLetterLine(
            SalesAdvLetterLineCZZ2, SalesAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT", "Amount Including VAT (LCY)");
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterHeaderCZZ."Amount Including VAT");

        // [GIVEN] Sales invoice has been created
        // [GIVEN] Sales invoice line with amount higher than first line of advance letter has been created
        LibrarySalesAdvancesCZZ.CreateSalesInvoice(
            SalesHeader, SalesLine, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", SalesAdvLetterHeaderCZZ."Posting Date",
            SalesAdvLetterLineCZZ1."VAT Bus. Posting Group", SalesAdvLetterLineCZZ1."VAT Prod. Posting Group", '', 0,
            true, SalesAdvLetterLineCZZ1."Amount Including VAT" + 1);

        // [GIVEN] Whole advance letter has been linked to Sales invoice
        LibrarySalesAdvancesCZZ.LinkSalesAdvanceLetterToDocument(
            SalesAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Sales Invoice", SalesHeader."No.",
            SalesAdvLetterHeaderCZZ."Amount Including VAT", SalesAdvLetterHeaderCZZ."Amount Including VAT (LCY)");

        // [WHEN] Post Sales invoice
        PostSalesDocument(SalesHeader);

        // [THEN] Amount in Sales advance letter entry of "VAT Payment" type will be the sames as in entry with "VAT Usage" type of the same VAT posting group as in first line of advance letter
        SalesAdvLetterEntryCZZ1.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ1.SetRange("VAT Bus. Posting Group", SalesAdvLetterLineCZZ1."VAT Bus. Posting Group");
        SalesAdvLetterEntryCZZ1.SetRange("VAT Prod. Posting Group", SalesAdvLetterLineCZZ1."VAT Prod. Posting Group");
        SalesAdvLetterEntryCZZ1.SetRange("Entry Type", SalesAdvLetterEntryCZZ1."Entry Type"::"VAT Payment");
        SalesAdvLetterEntryCZZ1.FindFirst();

        SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ2.SetRange("VAT Bus. Posting Group", SalesLine."VAT Bus. Posting Group");
        SalesAdvLetterEntryCZZ2.SetRange("VAT Prod. Posting Group", SalesLine."VAT Prod. Posting Group");
        SalesAdvLetterEntryCZZ2.SetRange("Entry Type", SalesAdvLetterEntryCZZ2."Entry Type"::"VAT Usage");
        SalesAdvLetterEntryCZZ2.FindFirst();
        Assert.AreEqual(SalesAdvLetterEntryCZZ1.Amount, -SalesAdvLetterEntryCZZ2.Amount, 'The amount in Sales advance letter entry of "VAT Payment" type must be the same as in entry with "VAT Usage" type.');

        // [THEN] Sales advance letter entry of "VAT Usage" type with the same VAT posting group as in second line of advance letter will exist
        SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ2.SetRange("VAT Bus. Posting Group", SalesAdvLetterLineCZZ2."VAT Bus. Posting Group");
        SalesAdvLetterEntryCZZ2.SetRange("VAT Prod. Posting Group", SalesAdvLetterLineCZZ2."VAT Prod. Posting Group");
        SalesAdvLetterEntryCZZ2.SetRange("Entry Type", SalesAdvLetterEntryCZZ2."Entry Type"::"VAT Usage");
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ2);

        SetPostVATDocForReverseCharge(false);
    end;

    [Test]
    procedure CreateSalesAdvLetterWithTwoDiffVATRatesAndLinkToInvoiceWithOneVATRate4()
    var
        SalesAdvLetterEntryCZZ1: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ1: Record "Sales Adv. Letter Line CZZ";
        SalesAdvLetterLineCZZ2: Record "Sales Adv. Letter Line CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        // [SCENARIO] Create Sales advance letter with two lines with different VAT rates and link to invoice with line which has the higher amount as second line in advance letter and one VAT rate
        Initialize();

        // [GIVEN] Posting of VAT documents for reverse charge has been enabled
        SetPostVATDocForReverseCharge(true);

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ1);

        // [GIVEN] Second Sales advance letter line with reverse charge has been created
        LibrarySalesAdvancesCZZ.FindVATPostingSetupEU(VATPostingSetup);
        LibrarySalesAdvancesCZZ.CreateSalesAdvLetterLine(
            SalesAdvLetterLineCZZ2, SalesAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT", "Amount Including VAT (LCY)");
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterHeaderCZZ."Amount Including VAT");

        // [GIVEN] Sales invoice has been created
        // [GIVEN] Sales invoice line with amount higher than second line of advance letter has been created
        LibrarySalesAdvancesCZZ.CreateSalesInvoice(
            SalesHeader, SalesLine, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", SalesAdvLetterHeaderCZZ."Posting Date",
            SalesAdvLetterLineCZZ2."VAT Bus. Posting Group", SalesAdvLetterLineCZZ2."VAT Prod. Posting Group", '', 0,
            true, SalesAdvLetterLineCZZ2."Amount Including VAT" + 1);

        // [GIVEN] Whole advance letter has been linked to Sales invoice
        LibrarySalesAdvancesCZZ.LinkSalesAdvanceLetterToDocument(
            SalesAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Sales Invoice", SalesHeader."No.",
            SalesAdvLetterHeaderCZZ."Amount Including VAT", SalesAdvLetterHeaderCZZ."Amount Including VAT (LCY)");

        // [WHEN] Post Sales invoice
        PostSalesDocument(SalesHeader);

        // [THEN] Amount in Sales advance letter entry of "VAT Payment" type will be the same as in entry with "VAT Usage" type of the same VAT posting group as in second line of advance letter
        SalesAdvLetterEntryCZZ1.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ1.SetRange("VAT Bus. Posting Group", SalesAdvLetterLineCZZ2."VAT Bus. Posting Group");
        SalesAdvLetterEntryCZZ1.SetRange("VAT Prod. Posting Group", SalesAdvLetterLineCZZ2."VAT Prod. Posting Group");
        SalesAdvLetterEntryCZZ1.SetRange("Entry Type", SalesAdvLetterEntryCZZ1."Entry Type"::"VAT Payment");
        SalesAdvLetterEntryCZZ1.FindFirst();

        SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ2.SetRange("VAT Bus. Posting Group", SalesLine."VAT Bus. Posting Group");
        SalesAdvLetterEntryCZZ2.SetRange("VAT Prod. Posting Group", SalesLine."VAT Prod. Posting Group");
        SalesAdvLetterEntryCZZ2.SetRange("Entry Type", SalesAdvLetterEntryCZZ2."Entry Type"::"VAT Usage");
        SalesAdvLetterEntryCZZ2.FindFirst();
        Assert.AreEqual(SalesAdvLetterEntryCZZ1.Amount, -SalesAdvLetterEntryCZZ2.Amount, 'The amount in Sales advance letter entry of "VAT Payment" type must be the same as in entry with "VAT Usage" type.');

        // [THEN] Sales advance letter entry of "VAT Usage" type with the same VAT posting group as in first line of advance letter will exist
        SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ2.SetRange("VAT Bus. Posting Group", SalesAdvLetterLineCZZ1."VAT Bus. Posting Group");
        SalesAdvLetterEntryCZZ2.SetRange("VAT Prod. Posting Group", SalesAdvLetterLineCZZ1."VAT Prod. Posting Group");
        SalesAdvLetterEntryCZZ2.SetRange("Entry Type", SalesAdvLetterEntryCZZ2."Entry Type"::"VAT Usage");
        Assert.RecordIsNotEmpty(SalesAdvLetterEntryCZZ2);

        SetPostVATDocForReverseCharge(false);
    end;

    [Test]
    procedure CreateSalesAdvLetterWithTwoDiffVATRatesAndLinkToInvoice()
    var
        GLAccount: Record "G/L Account";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ1: Record "Sales Adv. Letter Line CZZ";
        SalesAdvLetterLineCZZ2: Record "Sales Adv. Letter Line CZZ";
        SalesHeader: Record "Sales Header";
        SalesLine1: Record "Sales Line";
        SalesLine2: Record "Sales Line";
        VATEntry: Record "VAT Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Create Sales advance letter with two lines with different VAT rates and link to invoice with two lines which have the lower amounts as lines in advance letter
        Initialize();

        // [GIVEN] Posting of VAT documents for reverse charge has been enabled
        SetPostVATDocForReverseCharge(true);

        // [GIVEN] Sales advance letter has been created
        // [GIVEN] Sales advance letter line with normal VAT has been created
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ1);

        // [GIVEN] Second Sales advance letter line with reverse charge has been created
        LibrarySalesAdvancesCZZ.FindVATPostingSetupEU(VATPostingSetup);
        LibrarySalesAdvancesCZZ.CreateSalesAdvLetterLine(
            SalesAdvLetterLineCZZ2, SalesAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Sales advance letter has been released
        LibrarySalesAdvancesCZZ.ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance letter has been paid in full by the general journal
        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT", "Amount Including VAT (LCY)");
        CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterHeaderCZZ."Amount Including VAT");

        // [GIVEN] Sales invoice has been created
        // [GIVEN] First Sales invoice line with amount lower than first line of advance letter has been created
        LibrarySalesAdvancesCZZ.CreateSalesInvoice(
            SalesHeader, SalesLine1, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", SalesAdvLetterHeaderCZZ."Posting Date",
            SalesAdvLetterLineCZZ1."VAT Bus. Posting Group", SalesAdvLetterLineCZZ1."VAT Prod. Posting Group", '', 0,
            true, SalesAdvLetterLineCZZ1."Amount Including VAT" - 1);

        // [GIVEN] Second Sales invoice line with amount lower than second line of advance letter has been created
        LibrarySalesAdvancesCZZ.CreateGLAccount(GLAccount);
        GLAccount.Validate("VAT Bus. Posting Group", SalesAdvLetterLineCZZ2."VAT Bus. Posting Group");
        GLAccount.Validate("VAT Prod. Posting Group", SalesAdvLetterLineCZZ2."VAT Prod. Posting Group");
        GLAccount.Modify(true);
        LibrarySales.CreateSalesLine(SalesLine2, SalesHeader, SalesLine2.Type::"G/L Account", GLAccount."No.", 1);
        SalesLine2.Validate("Unit Price", SalesAdvLetterLineCZZ2."Amount Including VAT" - 1);
        SalesLine2.Modify(true);

        // [GIVEN] Whole advance letter has been linked to Sales invoice
        LibrarySalesAdvancesCZZ.LinkSalesAdvanceLetterToDocument(
            SalesAdvLetterHeaderCZZ, Enum::"Adv. Letter Usage Doc.Type CZZ"::"Sales Invoice", SalesHeader."No.",
            SalesAdvLetterHeaderCZZ."Amount Including VAT", SalesAdvLetterHeaderCZZ."Amount Including VAT (LCY)");

        // [WHEN] Post Sales invoice
        PostedDocumentNo := PostSalesDocument(SalesHeader);

        // [THEN] VAT entries of Sales invoice will exist
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

        // [THEN] Sum of base and VAT amount in VAT entries with the same VAT posting group as in first line of advance letter will be zero
        VATEntry.SetRange("VAT Bus. Posting Group", SalesAdvLetterLineCZZ1."VAT Bus. Posting Group");
        VATEntry.SetRange("VAT Prod. Posting Group", SalesAdvLetterLineCZZ1."VAT Prod. Posting Group");
        VATEntry.CalcSums(Base, Amount);
        Assert.AreEqual(0, VATEntry.Base, 'The sum of base amount in VAT Entries must be zero.');
        Assert.AreEqual(0, VATEntry.Amount, 'The sum of VAT amount in VAT Entries must be zero.');

        // [THEN] Sum of base and VAT amount in VAT entries with the same VAT posting group as in second line of advance letter will be zero
        VATEntry.SetRange("VAT Bus. Posting Group", SalesAdvLetterLineCZZ2."VAT Bus. Posting Group");
        VATEntry.SetRange("VAT Prod. Posting Group", SalesAdvLetterLineCZZ2."VAT Prod. Posting Group");
        VATEntry.CalcSums(Base, Amount);
        Assert.AreEqual(0, VATEntry.Base, 'The sum of base amount in VAT Entries must be zero.');
        Assert.AreEqual(0, VATEntry.Amount, 'The sum of VAT amount in VAT Entries must be zero.');

        SetPostVATDocForReverseCharge(false);
    end;

    local procedure CreateSalesAdvLetterBase(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; CustomerNo: Code[20]; CurrencyCode: Code[10]; VATPostingSetup: Record "VAT Posting Setup")
    var
        Customer: Record Customer;
    begin
        if CustomerNo = '' then begin
            LibrarySalesAdvancesCZZ.CreateCustomer(Customer);
            Customer.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
            Customer.Modify(true);
            CustomerNo := Customer."No.";
        end;

        LibrarySalesAdvancesCZZ.CreateSalesAdvLetterHeader(SalesAdvLetterHeaderCZZ, AdvanceLetterTemplateCZZ.Code, CustomerNo, CurrencyCode);
        LibrarySalesAdvancesCZZ.CreateSalesAdvLetterLine(SalesAdvLetterLineCZZ, SalesAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));
    end;

    local procedure CreateSalesAdvLetter(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; CurrencyCode: Code[10])
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        LibrarySalesAdvancesCZZ.FindVATPostingSetup(VATPostingSetup);
        CreateSalesAdvLetterBase(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ, '', CurrencyCode, VATPostingSetup);
    end;

    local procedure CreateSalesAdvLetter(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ")
    begin
        CreateSalesAdvLetter(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ, '');
    end;

    local procedure CreateSalesAdvLetterWithCustomer(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; CustomerNo: Code[20])
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        LibrarySalesAdvancesCZZ.FindVATPostingSetup(VATPostingSetup);
        CreateSalesAdvLetterBase(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ, CustomerNo, '', VATPostingSetup);
    end;

    local procedure CreateSalesAdvLetterWithReverseCharge(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ")
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        LibrarySalesAdvancesCZZ.FindVATPostingSetupEU(VATPostingSetup);
        CreateSalesAdvLetterBase(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ, '', '', VATPostingSetup);
    end;

    local procedure CreateSalesAdvLetterFromOrderWithAdvanceAmount(var SalesHeader: Record "Sales Header"; AdvanceLetterCode: Code[20]; AdvanceAmount: Decimal; SuggestByLine: Boolean; var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
        CreateSalesAdvLetterFromOrder(SalesHeader, AdvanceLetterCode, 0, AdvanceAmount, SuggestByLine, SalesAdvLetterHeaderCZZ);
    end;

    local procedure CreateSalesAdvLetterFromOrderWithAdvancePer(var SalesHeader: Record "Sales Header"; AdvanceLetterCode: Code[20]; AdvancePer: Decimal; SuggestByLine: Boolean; var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
        CreateSalesAdvLetterFromOrder(SalesHeader, AdvanceLetterCode, AdvancePer, 0, SuggestByLine, SalesAdvLetterHeaderCZZ);
    end;

    local procedure CreateSalesAdvLetterFromOrder(var SalesHeader: Record "Sales Header"; AdvanceLetterCode: Code[20]; AdvancePer: Decimal; AdvanceAmount: Decimal; SuggestByLine: Boolean; var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
    begin
        Commit();
        LibraryVariableStorage.Enqueue(AdvanceLetterCode);
        LibraryVariableStorage.Enqueue(AdvancePer);
        LibraryVariableStorage.Enqueue(AdvanceAmount);
        LibraryVariableStorage.Enqueue(SuggestByLine);
        LibrarySalesAdvancesCZZ.CreateSalesAdvanceLetterFromOrder(SalesHeader);

        AdvanceLetterApplicationCZZ.SetRange("Advance Letter Type", AdvanceLetterApplicationCZZ."Advance Letter Type"::Sales);
        AdvanceLetterApplicationCZZ.SetRange("Document Type", AdvanceLetterApplicationCZZ."Document Type"::"Sales Order");
        AdvanceLetterApplicationCZZ.SetRange("Document No.", SalesHeader."No.");
        AdvanceLetterApplicationCZZ.FindFirst();
        SalesAdvLetterHeaderCZZ.Get(AdvanceLetterApplicationCZZ."Advance Letter No.");
    end;

    local procedure CreateAndPostPaymentSalesAdvLetter(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; Amount: Decimal; ExchangeRate: Decimal; PostingDate: Date): Decimal
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        LibrarySalesAdvancesCZZ.CreateSalesAdvancePayment(GenJournalLine, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", Amount, SalesAdvLetterHeaderCZZ."Currency Code", SalesAdvLetterHeaderCZZ."No.", ExchangeRate, PostingDate);
        LibrarySalesAdvancesCZZ.PostSalesAdvancePayment(GenJournalLine);
        exit(GenJournalLine."Amount (LCY)");
    end;

    local procedure CreateAndPostPaymentSalesAdvLetter(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; Amount: Decimal): Decimal
    begin
        exit(CreateAndPostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, Amount, 0, 0D));
    end;

    local procedure CreateAndPostPayment(CustomerNo: Code[20]; Amount: Decimal)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        LibraryJournals.CreateGenJournalLineWithBatch(
            GenJournalLine, GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::Customer, CustomerNo, Amount);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateCashDocument(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var CashDocumentLineCZP: Record "Cash Document Line CZP"; CashDocType: Enum "Cash Document Type CZP"; SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    var
        CashDeskCZP: Record "Cash Desk CZP";
        CashDeskUserCZP: Record "Cash Desk User CZP";
    begin
        LibraryCashDeskCZP.CreateCashDeskCZP(CashDeskCZP);
        LibraryCashDeskCZP.SetupCashDeskCZP(CashDeskCZP, false);
        LibraryCashDeskCZP.CreateCashDeskUserCZP(CashDeskUserCZP, CashDeskCZP."No.", true, true, true);
        LibraryCashDocumentCZP.CreateCashDocumentHeaderCZP(CashDocumentHeaderCZP, CashDocType, CashDeskCZP."No.");
        LibraryCashDocumentCZP.CreateCashDocumentLineCZP(CashDocumentLineCZP, CashDocumentHeaderCZP,
            Enum::"Cash Document Account Type CZP"::Customer, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", 0);
        CashDocumentLineCZP.Validate("Advance Letter No. CZZ", SalesAdvLetterHeaderCZZ."No.");
        CashDocumentLineCZP.Modify();
    end;

    local procedure FindForeignCurrency(var Currency: Record Currency)
    begin
        Currency.SetFilter(Code, '<>%1', GeneralLedgerSetup."LCY Code");
        LibraryERM.FindCurrency(Currency);
    end;

    local procedure PostSalesDocument(var SalesHeader: Record "Sales Header"): Code[20]
    begin
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure SetPostVATDocForReverseCharge(Value: Boolean)
    begin
        AdvanceLetterTemplateCZZ."Post VAT Doc. for Rev. Charge" := Value;
        AdvanceLetterTemplateCZZ.Modify();
    end;

    local procedure FindLastPaymentAdvanceLetterEntry(AdvanceLetterNo: Code[20]; var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    begin
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", AdvanceLetterNo);
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Payment);
        SalesAdvLetterEntryCZZ.FindLast();
    end;

    local procedure SetExpectedConfirm(Question: Text; Reply: Boolean)
    begin
        LibraryDialogHandler.SetExpectedConfirm(Question, Reply);
    end;

    local procedure GetLastCustLedgerEntryNo(): Integer
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.FindLast();
        exit(CustLedgerEntry."Entry No.");
    end;

    local procedure UnApplyCustLedgerEntries(FromEntryNo: Integer; IsErrorExpected: Boolean)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetFilter("Entry No.", '>%1', FromEntryNo);
        if CustLedgerEntry.FindSet() then
            repeat
                if not IsErrorExpected then
                    LibrarySalesAdvancesCZZ.UnApplyCustLedgEntry(CustLedgerEntry."Entry No.")
                else begin
                    asserterror LibrarySalesAdvancesCZZ.UnApplyCustLedgEntry(CustLedgerEntry."Entry No.");
                    LibraryVariableStorage.Enqueue(CustLedgerEntry);
                    LibraryVariableStorage.Enqueue(GetLastErrorText());
                end;
            until CustLedgerEntry.Next() = 0;
    end;

    local procedure VerifyCustLedgerEntryCount(FromEntryNo: Integer; ExpectedCount: Integer)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetFilter("Entry No.", '>%1', FromEntryNo);
        Assert.RecordCount(CustLedgerEntry, ExpectedCount);
    end;

    local procedure VerifyErrors()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Variant: Variant;
        ErrorText: Text;
        i: Integer;
    begin
        for i := 1 to LibraryVariableStorage.Length() / 2 do begin
            LibraryVariableStorage.Dequeue(Variant);
            CustLedgerEntry := Variant;
            LibraryVariableStorage.Dequeue(Variant);
            ErrorText := Variant;
            if CustLedgerEntry.Open then
                Assert.AreEqual(StrSubstNo(NoApplicationEntryErr, CustLedgerEntry."Entry No."), ErrorText, 'Unexpected error occur.')
            else
                Assert.AreEqual(AppliedToAdvanceLetterErr, ErrorText, 'Unexpected error occur.');
        end;
    end;

    local procedure PostCashDocument(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
        LibraryCashDocumentCZP.PostCashDocumentCZP(CashDocumentHeaderCZP);
    end;

    local procedure FindNextVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup")
    begin
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        if VATPostingSetup.Next() = 0 then
            LibraryERM.CreateVATPostingSetupWithAccounts(
                VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT", LibraryRandom.RandDecInDecimalRange(10, 25, 0));
        LibrarySalesAdvancesCZZ.AddAdvLetterAccounsToVATPostingSetup(VATPostingSetup);
    end;

    [RequestPageHandler]
    procedure CreateSalesAdvLetterHandler(var CreateSalesAdvLetterCZZ: TestRequestPage "Create Sales Adv. Letter CZZ")
    var
        DecimalValue: Decimal;
    begin
        CreateSalesAdvLetterCZZ.AdvLetterCode.SetValue(LibraryVariableStorage.DequeueText());
        DecimalValue := LibraryVariableStorage.DequeueDecimal();
        if DecimalValue <> 0 then
            CreateSalesAdvLetterCZZ.AdvPer.SetValue(DecimalValue);
        DecimalValue := LibraryVariableStorage.DequeueDecimal();
        if DecimalValue <> 0 then
            CreateSalesAdvLetterCZZ.AdvAmount.SetValue(DecimalValue);
        CreateSalesAdvLetterCZZ.SuggByLine.SetValue(LibraryVariableStorage.DequeueBoolean());
        CreateSalesAdvLetterCZZ.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        LibraryDialogHandler.HandleConfirm(Question, Reply);
    end;
}
