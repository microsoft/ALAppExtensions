codeunit 148073 "Cash Desk Service CZP"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Cash Desk] [Service]
        isInitialized := false;
    end;

    var
        CashDeskCZP: Record "Cash Desk CZP";
        PaymentMethod: Record "Payment Method";
        CashDeskUserCZP: Record "Cash Desk User CZP";
        LibraryCashDeskCZP: Codeunit "Library - Cash Desk CZP";
        LibraryRandom: Codeunit "Library - Random";
        LibraryService: Codeunit "Library - Service";
        LibraryCashDocumentCZP: Codeunit "Library - Cash Document CZP";
        CashDocumentActionCZP: Enum "Cash Document Action CZP";
        isInitialized: Boolean;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Cash Desk Service CZP");
        LibraryRandom.Init();
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Cash Desk Service CZP");

        LibraryCashDeskCZP.CreateCashDeskCZP(CashDeskCZP);
        LibraryCashDeskCZP.SetupCashDeskCZP(CashDeskCZP, false);
        LibraryCashDeskCZP.CreateCashDeskUserCZP(CashDeskUserCZP, CashDeskCZP."No.", true, true, true);

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Cash Desk Service CZP");
    end;

    [Test]
    procedure CreatingReceiptCashDocumentFromServiceInvoice()
    begin
        // [SCENARIO] Create Cash Documents in Service Invoice
        ReceiptCashDocumentFromServiceInvoice(CashDocumentActionCZP::Create);
    end;

    [Test]
    procedure ReleasingReceiptCashDocumentFromServiceInvoice()
    begin
        // [SCENARIO] Release Cash Documents in Service Invoice
        ReceiptCashDocumentFromServiceInvoice(CashDocumentActionCZP::Release);
    end;

    [Test]
    procedure PostingReceiptCashDocumentFromServiceInvoice()
    begin
        // [SCENARIO] Post Cash Documents in Service Invoice
        ReceiptCashDocumentFromServiceInvoice(CashDocumentActionCZP::Post);
    end;

    local procedure ReceiptCashDocumentFromServiceInvoice(CashDocumentActionCZP: Enum "Cash Document Action CZP")
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
        PostedCashDocumentLineCZP: Record "Posted Cash Document Line CZP";
        PostDocNo: Code[20];
    begin
        Initialize();

        // [GIVEN] New Payment method is created and used in Service Invoice
        LibraryCashDocumentCZP.CreatePaymentMethod(PaymentMethod, CashDeskCZP."No.", CashDocumentActionCZP);
        CreateServiceInvoice(ServiceHeader, ServiceLine);
        ModifyPaymentMethodInServiceDocument(ServiceHeader, PaymentMethod);

        // [WHEN] Post Service Invoice
        PostDocNo := PostServiceDocument(ServiceHeader);

        // [THEN] (Posted) Cash Document Receipt exists and has correct amount
        ServiceInvoiceHeader.Get(PostDocNo);

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
                    CashDocumentHeaderCZP.SetRange("Posting Date", ServiceInvoiceHeader."Posting Date");
                    CashDocumentHeaderCZP.FindLast();

                    CashDocumentLineCZP.SetRange("Cash Desk No.", CashDocumentHeaderCZP."Cash Desk No.");
                    CashDocumentLineCZP.SetRange("Cash Document No.", CashDocumentHeaderCZP."No.");
                    CashDocumentLineCZP.FindFirst();

                    CashDocumentLineCZP.TestField("Account Type", CashDocumentLineCZP."Account Type"::Customer);
                    CashDocumentLineCZP.TestField("Account No.", ServiceInvoiceHeader."Bill-to Customer No.");
                    CashDocumentLineCZP.TestField("Applies-To Doc. Type", CashDocumentLineCZP."Applies-To Doc. Type"::Invoice);
                    CashDocumentLineCZP.TestField("Applies-To Doc. No.", ServiceInvoiceHeader."No.");
                end;
            PaymentMethod."Cash Document Action CZP"::Post:
                begin
                    PostedCashDocumentHdrCZP.SetRange("Cash Desk No.", CashDeskCZP."No.");
                    PostedCashDocumentHdrCZP.SetRange("Document Type", PostedCashDocumentHdrCZP."Document Type"::Receipt);
                    PostedCashDocumentHdrCZP.SetRange("Posting Date", ServiceInvoiceHeader."Posting Date");
                    PostedCashDocumentHdrCZP.FindLast();

                    PostedCashDocumentLineCZP.SetRange("Cash Desk No.", PostedCashDocumentHdrCZP."Cash Desk No.");
                    PostedCashDocumentLineCZP.SetRange("Cash Document No.", PostedCashDocumentHdrCZP."No.");
                    PostedCashDocumentLineCZP.FindFirst();

                    PostedCashDocumentLineCZP.TestField("Account Type", PostedCashDocumentLineCZP."Account Type"::Customer);
                    PostedCashDocumentLineCZP.TestField("Account No.", ServiceInvoiceHeader."Bill-to Customer No.");
                end;
        end;
    end;

    [Test]
    procedure CreatingWithdrawalCashDocumentFromServiceCrMemo()
    begin
        // [SCENARIO] Create Cash Documents in Service Credit Memo
        WithdrawalCashDocumentFromServiceCrMemo(CashDocumentActionCZP::Create);
    end;

    [Test]
    procedure ReleasingWithdrawalCashDocumentFromServiceCrMemo()
    begin
        // [SCENARIO] Release Cash Documents in Service Credit Memo
        WithdrawalCashDocumentFromServiceCrMemo(CashDocumentActionCZP::Release);
    end;

    [Test]
    procedure PostingWithdrawalCashDocumentFromServiceCrMemo()
    begin
        // [SCENARIO] Post Cash Documents in Service Credit Memo
        WithdrawalCashDocumentFromServiceCrMemo(CashDocumentActionCZP::Post);
    end;

    local procedure WithdrawalCashDocumentFromServiceCrMemo(CashDocumentActionCZP: Enum "Cash Document Action CZP")
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
        PostedCashDocumentLineCZP: Record "Posted Cash Document Line CZP";
        PostDocNo: Code[20];
    begin
        Initialize();

        // [GIVEN] New Payment method is created and used in Service Credit Memo
        LibraryCashDocumentCZP.CreatePaymentMethod(PaymentMethod, CashDeskCZP."No.", CashDocumentActionCZP);
        CreateServiceCreditMemo(ServiceHeader, ServiceLine);
        ModifyPaymentMethodInServiceDocument(ServiceHeader, PaymentMethod);

        // [WHEN] Post Service Credit Memo
        PostDocNo := PostServiceDocument(ServiceHeader);

        // [THEN] (Posted) Cash Document Withdrawal exists and has correct amount
        ServiceCrMemoHeader.Get(PostDocNo);

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
                    CashDocumentHeaderCZP.SetRange("Posting Date", ServiceCrMemoHeader."Posting Date");
                    CashDocumentHeaderCZP.FindLast();

                    CashDocumentLineCZP.SetRange("Cash Desk No.", CashDocumentHeaderCZP."Cash Desk No.");
                    CashDocumentLineCZP.SetRange("Cash Document No.", CashDocumentHeaderCZP."No.");
                    CashDocumentLineCZP.FindFirst();

                    CashDocumentLineCZP.TestField("Account Type", CashDocumentLineCZP."Account Type"::Customer);
                    CashDocumentLineCZP.TestField("Account No.", ServiceCrMemoHeader."Bill-to Customer No.");
                    CashDocumentLineCZP.TestField("Applies-To Doc. Type", CashDocumentLineCZP."Applies-To Doc. Type"::"Credit Memo");
                    CashDocumentLineCZP.TestField("Applies-To Doc. No.", ServiceCrMemoHeader."No.");
                end;
            PaymentMethod."Cash Document Action CZP"::Post:
                begin
                    PostedCashDocumentHdrCZP.SetRange("Cash Desk No.", CashDeskCZP."No.");
                    PostedCashDocumentHdrCZP.SetRange("Document Type", PostedCashDocumentHdrCZP."Document Type"::Withdrawal);
                    PostedCashDocumentHdrCZP.SetRange("Posting Date", ServiceCrMemoHeader."Posting Date");
                    PostedCashDocumentHdrCZP.FindLast();

                    PostedCashDocumentLineCZP.SetRange("Cash Desk No.", PostedCashDocumentHdrCZP."Cash Desk No.");
                    PostedCashDocumentLineCZP.SetRange("Cash Document No.", PostedCashDocumentHdrCZP."No.");
                    PostedCashDocumentLineCZP.FindFirst();

                    PostedCashDocumentLineCZP.TestField("Account Type", PostedCashDocumentLineCZP."Account Type"::Customer);
                    PostedCashDocumentLineCZP.TestField("Account No.", ServiceCrMemoHeader."Bill-to Customer No.");
                end;
        end;
    end;

    local procedure CreateServiceDocument(var ServiceHeader: Record "Service Header"; var ServiceLine: Record "Service Line";
                                            DocumentType: Enum "Service Document Type"; Amount: Decimal)
    begin
        LibraryService.CreateServiceHeader(ServiceHeader, DocumentType, '');
        LibraryService.CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::Item, '');
        ServiceLine.Validate(Quantity, 1);
        ServiceLine.Validate("Unit Price", Amount);
        ServiceLine.Modify(true);
    end;

    local procedure CreateServiceCreditMemo(var ServiceHeader: Record "Service Header"; var ServiceLine: Record "Service Line")
    begin
        CreateServiceDocument(ServiceHeader, ServiceLine, ServiceHeader."Document Type"::"Credit Memo", LibraryRandom.RandDecInRange(5000, 10000, 2));
    end;

    local procedure CreateServiceInvoice(var ServiceHeader: Record "Service Header"; var ServiceLine: Record "Service Line")
    begin
        CreateServiceDocument(ServiceHeader, ServiceLine, ServiceHeader."Document Type"::Invoice, LibraryRandom.RandDecInRange(5000, 10000, 2));
    end;

    local procedure ModifyPaymentMethodInServiceDocument(var ServiceHeader: Record "Service Header"; PaymentMethod: Record "Payment Method")
    begin
        ServiceHeader.Validate("Payment Method Code", PaymentMethod.Code);
        ServiceHeader.Modify();
    end;

    local procedure PostServiceDocument(var ServiceHeader: Record "Service Header"): Code[20]
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
    begin
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);

        ServiceInvoiceHeader.SetRange("Pre-Assigned No.", ServiceHeader."No.");
        if ServiceInvoiceHeader.FindFirst() then
            exit(ServiceInvoiceHeader."No.");

        ServiceCrMemoHeader.SetRange("Pre-Assigned No.", ServiceHeader."No.");
        if ServiceCrMemoHeader.FindFirst() then
            exit(ServiceCrMemoHeader."No.");
    end;
}
