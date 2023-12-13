codeunit 148072 "Cash Desk Purchase CZP"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Cash Desk] [Purchase]
        isInitialized := false;
    end;

    var
        CashDeskCZP: Record "Cash Desk CZP";
        PaymentMethod: Record "Payment Method";
        CashDeskUserCZP: Record "Cash Desk User CZP";
        LibraryCashDeskCZP: Codeunit "Library - Cash Desk CZP";
        LibraryRandom: Codeunit "Library - Random";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryCashDocumentCZP: Codeunit "Library - Cash Document CZP";
        CashDocumentActionCZP: Enum "Cash Document Action CZP";
        isInitialized: Boolean;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Cash Desk Purchase CZP");
        LibraryRandom.Init();
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Cash Desk Purchase CZP");

        LibraryCashDeskCZP.CreateCashDeskCZP(CashDeskCZP);
        LibraryCashDeskCZP.SetupCashDeskCZP(CashDeskCZP, false);
        LibraryCashDeskCZP.CreateCashDeskUserCZP(CashDeskUserCZP, CashDeskCZP."No.", true, true, true);

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Cash Desk Purchase CZP");
    end;

    [Test]
    procedure CreatingWithdrawalCashDocumentFromPurchaseInvoice()
    begin
        // [SCENARIO] Create Cash Document in Purchase Invoice
        WithdrawalCashDocumentFromPurchaseInvoice(CashDocumentActionCZP::Create);
    end;

    [Test]
    procedure ReleasingWithdrawalCashDocumentFromPurchaseInvoice()
    begin
        // [SCENARIO] Release Cash Document in Purchase Invoice
        WithdrawalCashDocumentFromPurchaseInvoice(CashDocumentActionCZP::Release);
    end;

    [Test]
    procedure PostingWithdrawalCashDocumentFromPurchaseInvoice()
    begin
        // [SCENARIO] Post Cash Document in Purchase Invoice
        WithdrawalCashDocumentFromPurchaseInvoice(CashDocumentActionCZP::Post);
    end;

    local procedure WithdrawalCashDocumentFromPurchaseInvoice(CashDocumentActionCZP: Enum "Cash Document Action CZP")
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
        PostedCashDocumentLineCZP: Record "Posted Cash Document Line CZP";
        PostDocNo: Code[20];
    begin
        Initialize();

        // [GIVEN] New Payment method is created and used in Purchase Invoice
        LibraryCashDocumentCZP.CreatePaymentMethod(PaymentMethod, CashDeskCZP."No.", CashDocumentActionCZP);
        CreatePurchInvoice(PurchaseHeader, PurchaseLine);
        ModifyPaymentMethodInPurchaseDocument(PurchaseHeader, PaymentMethod);

        // [WHEN] Post Purchase Invoice
        PostDocNo := PostPurchaseDocument(PurchaseHeader);

        // [THEN] (Posted) Cash Document Withdrawal exists and has correct amount
        PurchInvHeader.Get(PostDocNo);
        PurchInvHeader.CalcFields("Amount Including VAT");

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
                    CashDocumentHeaderCZP.SetRange("Posting Date", PurchInvHeader."Posting Date");
                    CashDocumentHeaderCZP.FindLast();

                    CashDocumentLineCZP.SetRange("Cash Desk No.", CashDocumentHeaderCZP."Cash Desk No.");
                    CashDocumentLineCZP.SetRange("Cash Document No.", CashDocumentHeaderCZP."No.");
                    CashDocumentLineCZP.FindFirst();

                    CashDocumentLineCZP.TestField("Account Type", CashDocumentLineCZP."Account Type"::Vendor);
                    CashDocumentLineCZP.TestField("Account No.", PurchInvHeader."Buy-from Vendor No.");
                    CashDocumentLineCZP.TestField(Amount, PurchInvHeader."Amount Including VAT");
                    CashDocumentLineCZP.TestField("Applies-To Doc. Type", CashDocumentLineCZP."Applies-To Doc. Type"::Invoice);
                    CashDocumentLineCZP.TestField("Applies-To Doc. No.", PurchInvHeader."No.");
                end;
            PaymentMethod."Cash Document Action CZP"::Post:
                begin
                    PostedCashDocumentHdrCZP.SetRange("Cash Desk No.", CashDeskCZP."No.");
                    PostedCashDocumentHdrCZP.SetRange("Document Type", PostedCashDocumentHdrCZP."Document Type"::Withdrawal);
                    PostedCashDocumentHdrCZP.SetRange("Posting Date", PurchInvHeader."Posting Date");
                    PostedCashDocumentHdrCZP.FindLast();

                    PostedCashDocumentLineCZP.SetRange("Cash Desk No.", PostedCashDocumentHdrCZP."Cash Desk No.");
                    PostedCashDocumentLineCZP.SetRange("Cash Document No.", PostedCashDocumentHdrCZP."No.");
                    PostedCashDocumentLineCZP.FindFirst();

                    PostedCashDocumentLineCZP.TestField("Account Type", PostedCashDocumentLineCZP."Account Type"::Vendor);
                    PostedCashDocumentLineCZP.TestField("Account No.", PurchInvHeader."Buy-from Vendor No.");
                    PostedCashDocumentLineCZP.TestField(Amount, PurchInvHeader."Amount Including VAT");
                end;
        end;
    end;

    [Test]
    procedure CreatingReceiptCashDocumentFromPurchaseCrMemo()
    begin
        // [SCENARIO] Create Cash Documents in Purchase Credit Memo
        ReceiptCashDocumentFromPurchaseCrMemo(CashDocumentActionCZP::Create);
    end;

    [Test]
    procedure ReleasingReceiptCashDocumentFromPurchaseCrMemo()
    begin
        // [SCENARIO] Release Cash Documents in Purchase Credit Memo
        ReceiptCashDocumentFromPurchaseCrMemo(CashDocumentActionCZP::Release);
    end;

    [Test]
    procedure PostingReceiptCashDocumentFromPurchaseCrMemo()
    begin
        // [SCENARIO] Post Cash Documents in Purchase Credit Memo
        ReceiptCashDocumentFromPurchaseCrMemo(CashDocumentActionCZP::Post);
    end;

    local procedure ReceiptCashDocumentFromPurchaseCrMemo(CashDocumentActionCZP: Enum "Cash Document Action CZP")
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
        PostedCashDocumentLineCZP: Record "Posted Cash Document Line CZP";
        PostDocNo: Code[20];
    begin
        Initialize();

        // [GIVEN] New Payment method is created and used in Purchase Credit Memo
        LibraryCashDocumentCZP.CreatePaymentMethod(PaymentMethod, CashDeskCZP."No.", CashDocumentActionCZP);
        CreatePurchCreditMemo(PurchaseHeader, PurchaseLine);
        ModifyPaymentMethodInPurchaseDocument(PurchaseHeader, PaymentMethod);

        // [WHEN] Post Purchase Credit Memo
        PostDocNo := PostPurchaseDocument(PurchaseHeader);

        // [THEN] (Posted) Cash Document Receipt exists and has correct amount
        PurchCrMemoHdr.Get(PostDocNo);
        PurchCrMemoHdr.CalcFields("Amount Including VAT");

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
                    CashDocumentHeaderCZP.SetRange("Posting Date", PurchCrMemoHdr."Posting Date");
                    CashDocumentHeaderCZP.FindLast();

                    CashDocumentLineCZP.SetRange("Cash Desk No.", CashDocumentHeaderCZP."Cash Desk No.");
                    CashDocumentLineCZP.SetRange("Cash Document No.", CashDocumentHeaderCZP."No.");
                    CashDocumentLineCZP.FindFirst();

                    CashDocumentLineCZP.TestField("Account Type", CashDocumentLineCZP."Account Type"::Vendor);
                    CashDocumentLineCZP.TestField("Account No.", PurchCrMemoHdr."Buy-from Vendor No.");
                    CashDocumentLineCZP.TestField(Amount, PurchCrMemoHdr."Amount Including VAT");
                    CashDocumentLineCZP.TestField("Applies-To Doc. Type", CashDocumentLineCZP."Applies-To Doc. Type"::"Credit Memo");
                    CashDocumentLineCZP.TestField("Applies-To Doc. No.", PurchCrMemoHdr."No.");
                end;
            PaymentMethod."Cash Document Action CZP"::Post:
                begin
                    PostedCashDocumentHdrCZP.SetRange("Cash Desk No.", CashDeskCZP."No.");
                    PostedCashDocumentHdrCZP.SetRange("Document Type", PostedCashDocumentHdrCZP."Document Type"::Receipt);
                    PostedCashDocumentHdrCZP.SetRange("Posting Date", PurchCrMemoHdr."Posting Date");
                    PostedCashDocumentHdrCZP.FindLast();

                    PostedCashDocumentLineCZP.SetRange("Cash Desk No.", PostedCashDocumentHdrCZP."Cash Desk No.");
                    PostedCashDocumentLineCZP.SetRange("Cash Document No.", PostedCashDocumentHdrCZP."No.");
                    PostedCashDocumentLineCZP.FindFirst();

                    PostedCashDocumentLineCZP.TestField("Account Type", PostedCashDocumentLineCZP."Account Type"::Vendor);
                    PostedCashDocumentLineCZP.TestField("Account No.", PurchCrMemoHdr."Buy-from Vendor No.");
                    PostedCashDocumentLineCZP.TestField(Amount, PurchCrMemoHdr."Amount Including VAT");
                end;
        end;
    end;

    local procedure CreatePurchDocument(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line";
                                        DocumentType: Enum "Purchase Document Type"; Amount: Decimal)
    var
        Vendor: Record Vendor;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, Vendor."No.");
        LibraryPurchase.CreatePurchaseLine(
          PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", LibraryCashDocumentCZP.GetNewGLAccountNo(true), 1);
        PurchaseLine.Validate("Direct Unit Cost", Amount);
        PurchaseLine.Modify(true);
    end;

    local procedure CreatePurchCreditMemo(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line")
    begin
        CreatePurchDocument(PurchaseHeader, PurchaseLine, PurchaseHeader."Document Type"::"Credit Memo", LibraryRandom.RandDecInRange(5000, 10000, 2));
    end;

    local procedure CreatePurchInvoice(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line")
    begin
        CreatePurchDocument(PurchaseHeader, PurchaseLine, PurchaseHeader."Document Type"::Invoice, LibraryRandom.RandDecInRange(5000, 10000, 2));
    end;

    local procedure ModifyPaymentMethodInPurchaseDocument(var PurchaseHeader: Record "Purchase Header"; PaymentMethod: Record "Payment Method")
    begin
        PurchaseHeader.Validate("Payment Method Code", PaymentMethod.Code);
        PurchaseHeader.Modify();
    end;

    local procedure PostPurchaseDocument(var PurchaseHeader: Record "Purchase Header"): Code[20]
    begin
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;
}
