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
        LibraryRandom: Codeunit "Library - Random";
        LibrarySalesAdvancesCZZ: Codeunit "Library - Sales Advances CZZ";
        LibrarySales: Codeunit "Library - Sales";
        LibraryERM: Codeunit "Library - ERM";
        isInitialized: Boolean;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Sales Advance Payments CZZ");
        LibraryRandom.Init();
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
        CreateSalesAdvLetterBase(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ, '');

        // [THEN] Sales advance letter will be created
        SalesAdvLetterLineCZZ.SetRange("Document No.", SalesAdvLetterHeaderCZZ."No.");
        Assert.IsFalse(SalesAdvLetterLineCZZ.IsEmpty(), 'Advance Letter was not created.');
    end;

    [Test]
    [HandlerFunctions('CreateSalesAdvLetterHandler,OpenAdvanceLetterHandler')]
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
        CreateSalesAdvLetterFromSalesDoc(SalesAdvLetterHeaderCZZ, SalesHeader);

        // [THEN] Sales advance letter will be created
        SalesAdvLetterLineCZZ.SetRange("Document No.", SalesAdvLetterHeaderCZZ."No.");
        Assert.IsFalse(SalesAdvLetterLineCZZ.IsEmpty(), 'Advance Letter was not created.');
    end;

    [Test]
    [HandlerFunctions('CreateSalesAdvLetterHandler,OpenAdvanceLetterHandler')]
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
        CreateSalesAdvLetterFromSalesDoc(SalesAdvLetterHeaderCZZ, SalesHeader);

        // [WHEN] Release sales advance
        ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

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
        CreateSalesAdvLetterBase(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ, '');

        // [GIVEN] Sales advance letter bas been released
        ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);
        AmountInclVAT := -SalesAdvLetterLineCZZ."Amount Including VAT";

        // [WHEN] Post sales advance payment
        AmountInclVATLCY := PostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, AmountInclVAT, 0);

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
    [HandlerFunctions('CreateSalesAdvLetterHandler,OpenAdvanceLetterHandler')]
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
        CreateSalesAdvLetterFromSalesDoc(SalesAdvLetterHeaderCZZ, SalesHeader);

        // [GIVEN] Sales advance letter has been released
        ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);

        // [GIVEN] Sales advance has been paid
        PostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, -SalesAdvLetterLineCZZ."Amount Including VAT", 0);

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
        CreateSalesAdvLetterBase(SalesAdvLetterHeaderCZZ, SalesAdvLetterLineCZZ, Currency.Code);
        ReleaseSalesAdvLetter(SalesAdvLetterHeaderCZZ);
        AmountInclVAT := -SalesAdvLetterLineCZZ."Amount Including VAT";

        // [WHEN] Post sales advance payment with different exchange rate
        AmountInclVATLCY := PostPaymentSalesAdvLetter(SalesAdvLetterHeaderCZZ, AmountInclVAT, 0.9);

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

    local procedure CreateSalesAdvLetterBase(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; CurrencyCode: Code[10])
    var
        VATPostingSetup: Record "VAT Posting Setup";
        Customer: Record Customer;
    begin
        LibrarySalesAdvancesCZZ.FindVATPostingSetup(VATPostingSetup);
        LibrarySalesAdvancesCZZ.CreateCustomer(Customer);
        Customer.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        Customer.Modify(true);

        LibrarySalesAdvancesCZZ.CreateSalesAdvLetterHeader(SalesAdvLetterHeaderCZZ, AdvanceLetterTemplateCZZ.Code, Customer."No.", CurrencyCode);
        LibrarySalesAdvancesCZZ.CreateSalesAdvLetterLine(SalesAdvLetterLineCZZ, SalesAdvLetterHeaderCZZ, VATPostingSetup."VAT Prod. Posting Group", LibraryRandom.RandDec(1000, 2));
    end;

    local procedure CreateSalesAdvLetterFromSalesDoc(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesHeader: Record "Sales Header")
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        CreateSalesAdvLetterCZZ: Report "Create Sales Adv. Letter CZZ";
    begin
        Commit();
        CreateSalesAdvLetterCZZ.SetSalesHeader(SalesHeader);
        CreateSalesAdvLetterCZZ.RunModal();

        AdvanceLetterApplicationCZZ.SetRange("Advance Letter Type", AdvanceLetterApplicationCZZ."Advance Letter Type"::Sales);
        AdvanceLetterApplicationCZZ.SetRange("Document Type", AdvanceLetterApplicationCZZ."Document Type"::"Sales Order");
        AdvanceLetterApplicationCZZ.SetRange("Document No.", SalesHeader."No.");
        AdvanceLetterApplicationCZZ.FindFirst();
        SalesAdvLetterHeaderCZZ.Get(AdvanceLetterApplicationCZZ."Advance Letter No.");
    end;

    local procedure PostPaymentSalesAdvLetter(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; Amount: Decimal; ExchangeRate: Decimal): Decimal
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        LibrarySalesAdvancesCZZ.CreateSalesAdvancePayment(GenJournalLine, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", Amount, SalesAdvLetterHeaderCZZ."Currency Code", SalesAdvLetterHeaderCZZ."No.", ExchangeRate);
        PostGenJournalLine(GenJournalLine);
        exit(GenJournalLine."Amount (LCY)");
    end;


    local procedure FindForeignCurrency(var Currency: Record Currency)
    begin
        Currency.SetFilter(Code, '<>%1', GeneralLedgerSetup."LCY Code");
        LibraryERM.FindCurrency(Currency);
    end;

    local procedure ReleaseSalesAdvLetter(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
        Codeunit.Run(Codeunit::"Rel. Sales Adv.Letter Doc. CZZ", SalesAdvLetterHeaderCZZ);
    end;

    local procedure PostGenJournalLine(var GenJournalLine: Record "Gen. Journal Line")
    begin
        Codeunit.Run(Codeunit::"Gen. Jnl.-Post Line", GenJournalLine);
    end;

    local procedure PostSalesDocument(var SalesHeader: Record "Sales Header"): Code[20]
    begin
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    [RequestPageHandler]
    procedure CreateSalesAdvLetterHandler(var CreateSalesAdvLetterCZZ: TestRequestPage "Create Sales Adv. Letter CZZ")
    begin
        CreateSalesAdvLetterCZZ.AdvLetterCode.SetValue := AdvanceLetterTemplateCZZ.Code;
        CreateSalesAdvLetterCZZ.AdvPer.SetValue := 100;
        CreateSalesAdvLetterCZZ.SuggByLine.SetValue := false;
        CreateSalesAdvLetterCZZ.OK().Invoke();
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
