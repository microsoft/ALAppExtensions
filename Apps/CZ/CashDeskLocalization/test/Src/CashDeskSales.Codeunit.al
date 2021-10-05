codeunit 148071 "Cash Desk Sales CZP"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Cash Desk] [Sales]
        isInitialized := false;
    end;

    var
        CashDeskCZP: Record "Cash Desk CZP";
        PaymentMethod: Record "Payment Method";
        CashDeskUserCZP: Record "Cash Desk User CZP";
        LibraryCashDeskCZP: Codeunit "Library - Cash Desk CZP";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        LibraryCashDocumentCZP: Codeunit "Library - Cash Document CZP";
        CashDocumentActionCZP: Enum "Cash Document Action CZP";
        isInitialized: Boolean;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Cash Desk Sales CZP");
        LibraryRandom.Init();
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Cash Desk Sales CZP");

        LibraryCashDeskCZP.CreateCashDeskCZP(CashDeskCZP);
        LibraryCashDeskCZP.SetupCashDeskCZP(CashDeskCZP, false);
        LibraryCashDeskCZP.CreateCashDeskUserCZP(CashDeskUserCZP, CashDeskCZP."No.", true, true, true);

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Cash Desk Sales CZP");
    end;

    [Test]
    procedure CreatingReceiptCashDocumentFromSalesInvoice()
    begin
        // [SCENARIO] Create Cash Documents in Sales Invoice
        ReceiptCashDocumentFromSalesInvoice(CashDocumentActionCZP::Create);
    end;

    [Test]
    procedure ReleasingReceiptCashDocumentFromSalesInvoice()
    begin
        // [SCENARIO] Release Cash Documents in Sales Invoice
        ReceiptCashDocumentFromSalesInvoice(CashDocumentActionCZP::Release);
    end;

    [Test]
    procedure PostingReceiptCashDocumentFromSalesInvoice()
    begin
        // [SCENARIO] Post Cash Documents in Sales Invoice
        ReceiptCashDocumentFromSalesInvoice(CashDocumentActionCZP::Post);
    end;

    local procedure ReceiptCashDocumentFromSalesInvoice(CashDocumentActionCZP: Enum "Cash Document Action CZP")
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
        PostedCashDocumentLineCZP: Record "Posted Cash Document Line CZP";
        PostDocNo: Code[20];
    begin
        Initialize();

        // [GIVEN] New Payment method is created and used in Sales Invoice
        LibraryCashDocumentCZP.CreatePaymentMethod(PaymentMethod, CashDeskCZP."No.", CashDocumentActionCZP);
        CreateSalesInvoice(SalesHeader, SalesLine);
        ModifyPaymentMethodInSalesDocument(SalesHeader, PaymentMethod);

        // [WHEN] Post Sales Invoice
        PostDocNo := PostSalesDocument(SalesHeader);

        // [THEN] (Posted) Cash Document Receipt exists and has correct amount
        SalesInvoiceHeader.Get(PostDocNo);
        SalesInvoiceHeader.CalcFields("Amount Including VAT");

        case CashDocumentActionCZP of
            PaymentMethod."Cash Document Action CZP"::Create,
            PaymentMethod."Cash Document Action CZP"::Release:
                begin
                    CashDocumentHeaderCZP.SetRange("Cash Desk No.", CashDeskCZP."No.");
                    CashDocumentHeaderCZP.SetRange("Document Type", CashDocumentHeaderCZP."Document Type"::Receipt);
                    if CashDocumentActionCZP = PaymentMethod."Cash Document Action CZP"::Create then
                        CashDocumentHeaderCZP.SetRange(Status, CashDocumentHeaderCZP.Status::Open)
                    else
                        CashDocumentHeaderCZP.SetRange(Status, CashDocumentHeaderCZP.Status::Released);
                    CashDocumentHeaderCZP.SetRange("Posting Date", SalesInvoiceHeader."Posting Date");
                    CashDocumentHeaderCZP.FindLast();

                    CashDocumentLineCZP.SetRange("Cash Desk No.", CashDocumentHeaderCZP."Cash Desk No.");
                    CashDocumentLineCZP.SetRange("Cash Document No.", CashDocumentHeaderCZP."No.");
                    CashDocumentLineCZP.FindFirst();

                    CashDocumentLineCZP.TestField("Account Type", CashDocumentLineCZP."Account Type"::Customer);
                    CashDocumentLineCZP.TestField("Account No.", SalesInvoiceHeader."Bill-to Customer No.");
                    CashDocumentLineCZP.TestField(Amount, SalesInvoiceHeader."Amount Including VAT");
                    CashDocumentLineCZP.TestField("Applies-To Doc. Type", CashDocumentLineCZP."Applies-To Doc. Type"::Invoice);
                    CashDocumentLineCZP.TestField("Applies-To Doc. No.", SalesInvoiceHeader."No.");
                end;
            PaymentMethod."Cash Document Action CZP"::Post:
                begin
                    PostedCashDocumentHdrCZP.SetRange("Cash Desk No.", CashDeskCZP."No.");
                    PostedCashDocumentHdrCZP.SetRange("Document Type", PostedCashDocumentHdrCZP."Document Type"::Receipt);
                    PostedCashDocumentHdrCZP.SetRange("Posting Date", SalesInvoiceHeader."Posting Date");
                    PostedCashDocumentHdrCZP.FindLast();

                    PostedCashDocumentLineCZP.SetRange("Cash Desk No.", PostedCashDocumentHdrCZP."Cash Desk No.");
                    PostedCashDocumentLineCZP.SetRange("Cash Document No.", PostedCashDocumentHdrCZP."No.");
                    PostedCashDocumentLineCZP.FindFirst();

                    PostedCashDocumentLineCZP.TestField("Account Type", PostedCashDocumentLineCZP."Account Type"::Customer);
                    PostedCashDocumentLineCZP.TestField("Account No.", SalesInvoiceHeader."Bill-to Customer No.");
                    PostedCashDocumentLineCZP.TestField(Amount, SalesInvoiceHeader."Amount Including VAT");
                end;
        end;
    end;

    [Test]
    procedure CreatingWithdrawalCashDocumentFromSalesCrMemo()
    begin
        // [SCENARIO] Create Cash Documents in Sales Credit Memo
        WithdrawalCashDocumentFromSalesCrMemo(CashDocumentActionCZP::Create);
    end;

    [Test]
    procedure ReleasingWithdrawalCashDocumentFromSalesCrMemo()
    begin
        // [SCENARIO] ReleaseCash Documents in Sales Credit Memo
        WithdrawalCashDocumentFromSalesCrMemo(CashDocumentActionCZP::Release);
    end;

    [Test]
    procedure PostingWithdrawalCashDocumentFromSalesCrMemo()
    begin
        // [SCENARIO] Post Cash Documents in Sales Credit Memo
        WithdrawalCashDocumentFromSalesCrMemo(CashDocumentActionCZP::Post);
    end;

    local procedure WithdrawalCashDocumentFromSalesCrMemo(CashDocumentActionCZP: Enum "Cash Document Action CZP")
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
        PostedCashDocumentLineCZP: Record "Posted Cash Document Line CZP";
        PostDocNo: Code[20];
    begin
        Initialize();

        // [GIVEN] New Payment method is created and used in Sales Credit Memo
        LibraryCashDocumentCZP.CreatePaymentMethod(PaymentMethod, CashDeskCZP."No.", CashDocumentActionCZP);
        CreateSalesCreditMemo(SalesHeader, SalesLine);
        ModifyPaymentMethodInSalesDocument(SalesHeader, PaymentMethod);

        // [WHEN] Post Sales Credit Memo
        PostDocNo := PostSalesDocument(SalesHeader);

        // [THEN] (Posted) Cash Document Withdrawal exists and has correct amount
        SalesCrMemoHeader.Get(PostDocNo);
        SalesCrMemoHeader.CalcFields("Amount Including VAT");

        case CashDocumentActionCZP of
            PaymentMethod."Cash Document Action CZP"::Create,
            PaymentMethod."Cash Document Action CZP"::Release:
                begin
                    CashDocumentHeaderCZP.SetRange("Cash Desk No.", CashDeskCZP."No.");
                    CashDocumentHeaderCZP.SetRange("Document Type", CashDocumentHeaderCZP."Document Type"::Withdrawal);
                    if CashDocumentActionCZP = PaymentMethod."Cash Document Action CZP"::Create then
                        CashDocumentHeaderCZP.SetRange(Status, CashDocumentHeaderCZP.Status::Open)
                    else
                        CashDocumentHeaderCZP.SetRange(Status, CashDocumentHeaderCZP.Status::Released);
                    CashDocumentHeaderCZP.SetRange("Posting Date", SalesCrMemoHeader."Posting Date");
                    CashDocumentHeaderCZP.FindLast();

                    CashDocumentLineCZP.SetRange("Cash Desk No.", CashDocumentHeaderCZP."Cash Desk No.");
                    CashDocumentLineCZP.SetRange("Cash Document No.", CashDocumentHeaderCZP."No.");
                    CashDocumentLineCZP.FindFirst();

                    CashDocumentLineCZP.TestField("Account Type", CashDocumentLineCZP."Account Type"::Customer);
                    CashDocumentLineCZP.TestField("Account No.", SalesCrMemoHeader."Bill-to Customer No.");
                    CashDocumentLineCZP.TestField(Amount, SalesCrMemoHeader."Amount Including VAT");
                    CashDocumentLineCZP.TestField("Applies-To Doc. Type", CashDocumentLineCZP."Applies-To Doc. Type"::"Credit Memo");
                    CashDocumentLineCZP.TestField("Applies-To Doc. No.", SalesCrMemoHeader."No.");
                end;
            PaymentMethod."Cash Document Action CZP"::Post:
                begin
                    PostedCashDocumentHdrCZP.SetRange("Cash Desk No.", CashDeskCZP."No.");
                    PostedCashDocumentHdrCZP.SetRange("Document Type", PostedCashDocumentHdrCZP."Document Type"::Withdrawal);
                    PostedCashDocumentHdrCZP.SetRange("Posting Date", SalesCrMemoHeader."Posting Date");
                    PostedCashDocumentHdrCZP.FindLast();

                    PostedCashDocumentLineCZP.SetRange("Cash Desk No.", PostedCashDocumentHdrCZP."Cash Desk No.");
                    PostedCashDocumentLineCZP.SetRange("Cash Document No.", PostedCashDocumentHdrCZP."No.");
                    PostedCashDocumentLineCZP.FindFirst();

                    PostedCashDocumentLineCZP.TestField("Account Type", PostedCashDocumentLineCZP."Account Type"::Customer);
                    PostedCashDocumentLineCZP.TestField("Account No.", SalesCrMemoHeader."Bill-to Customer No.");
                    PostedCashDocumentLineCZP.TestField(Amount, SalesCrMemoHeader."Amount Including VAT");
                end;
        end;
    end;

    local procedure CreateSalesDocument(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line";
                                        DocumentType: Enum "Sales Document Type"; UnitPrice: Decimal)
    var
        Customer: Record Customer;
    begin
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, Customer."No.");
        LibrarySales.CreateSalesLine(
          SalesLine, SalesHeader, SalesLine.Type::"G/L Account", LibraryCashDocumentCZP.GetNewGLAccountNo(true), 1);
        SalesLine.Validate("Unit Price", UnitPrice);
        SalesLine.Modify(true);
    end;

    local procedure CreateSalesCreditMemo(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        CreateSalesDocument(SalesHeader, SalesLine, SalesHeader."Document Type"::"Credit Memo", LibraryRandom.RandDecInRange(5000, 10000, 2));
    end;

    local procedure CreateSalesInvoice(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        CreateSalesDocument(SalesHeader, SalesLine, SalesHeader."Document Type"::Invoice, LibraryRandom.RandDecInRange(5000, 10000, 2));
    end;

    local procedure ModifyPaymentMethodInSalesDocument(var SalesHeader: Record "Sales Header"; PaymentMethod: Record "Payment Method")
    begin
        SalesHeader.Validate("Payment Method Code", PaymentMethod.Code);
        SalesHeader.Modify();
    end;

    local procedure PostSalesDocument(var SalesHeader: Record "Sales Header"): Code[20]
    begin
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;
}
