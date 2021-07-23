codeunit 148074 "Cash Desk Reports CZP"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        CashDeskCZP: Record "Cash Desk CZP";
        CashDeskUserCZP: Record "Cash Desk User CZP";
        CashDeskEventCZP: Record "Cash Desk Event CZP";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        LibraryCashDeskCZP: Codeunit "Library - Cash Desk CZP";
        LibraryCashDocumentCZP: Codeunit "Library - Cash Document CZP";
        RowNotFoundErr: Label 'There is no dataset row corresponding to Element Name %1 with value %2.', Comment = '%1 = Field Caption, %2 = Field Value;';
        isInitialized: Boolean;

    local procedure Initialize()
    begin
        LibraryRandom.Init();
        LibraryVariableStorage.Clear();
        if isInitialized then
            exit;

        LibraryCashDeskCZP.CreateCashDeskCZP(CashDeskCZP);
        LibraryCashDeskCZP.SetupCashDeskCZP(CashDeskCZP, true);
        LibraryCashDeskCZP.CreateCashDeskUserCZP(CashDeskUserCZP, CashDeskCZP."No.", true, true, true);

        isInitialized := true;
        Commit();
    end;

    [Test]
    [HandlerFunctions('YesConfirmHandler,RequestPageReceiptCashDocumentCZPHandler')]
    procedure PrintingReceiptCashDocument()
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
    begin
        // [SCENARIO] Check that Receipt Cash Document Report is correctly printed
        PrintingCashDocument(CashDocumentHeaderCZP."Document Type"::Receipt);
    end;

    [Test]
    [HandlerFunctions('YesConfirmHandler,RequestPageWithdrawalCashDocumentCZPHandler')]
    procedure PrintingWithdrawalCashDocument()
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
    begin
        // [SCENARIO] Check that Withdrawal Cash Document Report is correctly printed
        PrintingCashDocument(CashDocumentHeaderCZP."Document Type"::Withdrawal);
    end;

    local procedure PrintingCashDocument(CashDocType: Enum "Cash Document Type CZP")
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        // [FEATURE] Cash Desk
        Initialize();

        // [GIVEN] Create Cash Document
        CreateCashDocument(CashDocumentHeaderCZP, CashDocumentLineCZP, CashDocType, CashDeskCZP."No.");
        Commit();

        // [WHEN] Print Cash Document
        PrintCashDocument(CashDocumentHeaderCZP);

        // [THEN] Verify
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.SetRange('No_CashDocumentHeader', CashDocumentHeaderCZP."No.");
        if not LibraryReportDataset.GetNextRow() then
            Error(RowNotFoundErr, 'No_CashDocumentHeader', CashDocumentHeaderCZP."No.");
        LibraryReportDataset.AssertCurrentRowValueEquals('AmountIncludingVAT_CashDocumentLine', CashDocumentLineCZP."Amount Including VAT");
    end;

    [Test]
    [HandlerFunctions('YesConfirmHandler,RequestPagePostedRcptCashDocumentCZPHandler')]
    procedure PrintingPostedReceiptCashDocument()
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
    begin
        // [SCENARIO] Check that correct Amounts are present on Receipt Cash Document Report after posting Receipt Cash Document
        PrintingPostedCashDocument(CashDocumentHeaderCZP."Document Type"::Receipt);
    end;

    [Test]
    [HandlerFunctions('YesConfirmHandler,RequestPagePostedWdrlCashDocumentCZPHandler')]
    procedure PrintingPostedWithdrawalCashDocument()
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
    begin
        // [SCENARIO] Check that correct Amounts are present on Withdrawal Cash Document Report after posting Withdrawal Cash Document
        PrintingPostedCashDocument(CashDocumentHeaderCZP."Document Type"::Withdrawal);
    end;

    local procedure PrintingPostedCashDocument(CashDocType: Enum "Cash Document Type CZP")
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
    begin
        // [FEATURE] Cash Desk
        Initialize();

        // [GIVEN] Create Receipt Cash Document
        CreateCashDocument(CashDocumentHeaderCZP, CashDocumentLineCZP, CashDocType, CashDeskCZP."No.");

        // [GIVEN] Post Cash Document
        PostCashDocument(CashDocumentHeaderCZP);
        PostedCashDocumentHdrCZP.SetRange("Cash Desk No.", CashDeskCZP."No.");
        PostedCashDocumentHdrCZP.FindLast();

        // [WHEN] Print Posted Cash Document
        PrintPostedCashDocument(PostedCashDocumentHdrCZP);

        // [THEN] Verify
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.SetRange('No_PostedCashDocumentHeader', PostedCashDocumentHdrCZP."No.");
        if not LibraryReportDataset.GetNextRow() then
            Error(RowNotFoundErr, 'No_PostedCashDocumentHeader', PostedCashDocumentHdrCZP."No.");
        case CashDocType of
            CashDocumentHeaderCZP."Document Type"::Receipt:
                begin
                    LibraryReportDataset.GetNextRow();
                    LibraryReportDataset.AssertCurrentRowValueEquals('DebitAmount_GLEntry', CashDocumentLineCZP.Amount);
                    LibraryReportDataset.GetNextRow();
                    LibraryReportDataset.AssertCurrentRowValueEquals('CreditAmount_GLEntry', CashDocumentLineCZP.Amount);
                end;
            CashDocumentHeaderCZP."Document Type"::Withdrawal:
                begin
                    LibraryReportDataset.GetNextRow();
                    LibraryReportDataset.AssertCurrentRowValueEquals('CreditAmount_GLEntry', CashDocumentLineCZP.Amount);
                    LibraryReportDataset.GetNextRow();
                    LibraryReportDataset.AssertCurrentRowValueEquals('DebitAmount_GLEntry', CashDocumentLineCZP.Amount);
                end;
        end;
    end;

    [Test]
    [HandlerFunctions('YesConfirmHandler,RequestPageCashDeskBookCZPHandler')]
    procedure PrintingCashDeskBook()
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
    begin
        // [SCENARIO] Check that correct Amount is present on Receipt Cash Desk Book Report after posting Receipt Cash Document
        // [FEATURE] Cash Desk
        isInitialized := false;
        Initialize();

        // [GIVEN] Create Receipt Cash Document
        LibraryCashDeskCZP.CreateCashDeskEventCZP(
          CashDeskEventCZP, CashDeskCZP."No.", CashDocumentHeaderCZP."Document Type"::Receipt,
          CashDeskEventCZP."Account Type"::"G/L Account", LibraryCashDocumentCZP.GetNewGLAccountNo(true));
        LibraryCashDocumentCZP.CreateCashDocumentHeaderCZP(CashDocumentHeaderCZP, CashDocumentHeaderCZP."Document Type"::Receipt, CashDeskCZP."No.");

        // [GIVEN] Create Receipt Cash Document Line 1
        LibraryCashDocumentCZP.CreateCashDocumentLineCZPWithCashDeskEvent(
          CashDocumentLineCZP, CashDocumentHeaderCZP, CashDeskEventCZP.Code, LibraryRandom.RandInt(Round(CashDeskCZP."Cash Receipt Limit" / 10, 1, '<')));

        // [GIVEN] Create Receipt Cash Document Line 2
        LibraryCashDocumentCZP.CreateCashDocumentLineCZPWithCashDeskEvent(
          CashDocumentLineCZP, CashDocumentHeaderCZP, CashDeskEventCZP.Code, LibraryRandom.RandInt(Round(CashDeskCZP."Cash Receipt Limit" / 10, 1, '<')));

        // [GIVEN] Post Cash Document
        PostCashDocument(CashDocumentHeaderCZP);

        // [GIVEN] Create Withdrawal Cash Document
        Clear(CashDocumentHeaderCZP);
        Clear(CashDocumentLineCZP);
        CreateCashDocumentWithFixedAsset(CashDocumentHeaderCZP, CashDocumentLineCZP, CashDocumentHeaderCZP."Document Type"::Withdrawal, CashDeskCZP."No.");

        // [GIVEN] Post Cash Document
        PostCashDocument(CashDocumentHeaderCZP);

        // [WHEN] Print Cash Desk Book
        CashDeskCZP.SetRecFilter();
        CashDeskCZP.SetFilter("Date Filter", '%1..%2', CalcDate('<-1D>', WorkDate()), CalcDate('<1D>', WorkDate()));
        LibraryCashDeskCZP.PrintCashDeskBook(true, CashDeskCZP);

        // [THEN] Verify amounts
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.SetRange('CashDesk_No', CashDeskCZP."No.");
        if not LibraryReportDataset.GetNextRow() then
            Error(RowNotFoundErr, 'CashDesk_No', CashDeskCZP."No.");

        PostedCashDocumentHdrCZP.SetRange("Cash Desk No.", CashDeskCZP."No.");
        PostedCashDocumentHdrCZP.FindFirst();
        PostedCashDocumentHdrCZP.CalcFields("Amount Including VAT");
        LibraryReportDataset.AssertCurrentRowValueEquals('Receipt', PostedCashDocumentHdrCZP."Amount Including VAT");
        PostedCashDocumentHdrCZP.FindLast();
        PostedCashDocumentHdrCZP.CalcFields("Amount Including VAT");
        LibraryReportDataset.GetNextRow();
        LibraryReportDataset.AssertCurrentRowValueEquals('Payment', PostedCashDocumentHdrCZP."Amount Including VAT");
    end;

    local procedure CreateCashDocument(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var CashDocumentLineCZP: Record "Cash Document Line CZP";
                                        CashDocType: Enum "Cash Document Type CZP"; CashDeskNo: Code[20])
    begin
        LibraryCashDocumentCZP.CreateCashDocumentWithEvent(CashDocumentHeaderCZP, CashDocumentLineCZP, CashDocType, CashDeskNo);
    end;

    local procedure CreateCashDocumentWithFixedAsset(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var CashDocumentLineCZP: Record "Cash Document Line CZP";
                                                        CashDocType: Enum "Cash Document Type CZP"; CashDeskNo: Code[20])
    begin
        LibraryCashDocumentCZP.CreateCashDocumentWithFixedAsset(CashDocumentHeaderCZP, CashDocumentLineCZP, CashDocType, CashDeskNo);
    end;

    local procedure PostCashDocument(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
        LibraryCashDocumentCZP.PostCashDocumentCZP(CashDocumentHeaderCZP);
    end;

    local procedure PrintCashDocument(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
        LibraryCashDocumentCZP.PrintCashDocumentCZP(CashDocumentHeaderCZP, true);
    end;

    local procedure PrintPostedCashDocument(var PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP")
    begin
        LibraryCashDocumentCZP.PrintPostedCashDocumentCZP(PostedCashDocumentHdrCZP, true);
    end;

    [ConfirmHandler]
    procedure YesConfirmHandler(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [RequestPageHandler]
    procedure RequestPageReceiptCashDocumentCZPHandler(var ReceiptCashDocumentCZP: TestRequestPage "Receipt Cash Document CZP")
    begin
        ReceiptCashDocumentCZP.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure RequestPageWithdrawalCashDocumentCZPHandler(var WithdrawalCashDocumentCZP: TestRequestPage "Withdrawal Cash Document CZP")
    begin
        WithdrawalCashDocumentCZP.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure RequestPagePostedRcptCashDocumentCZPHandler(var PostedRcptCashDocumentCZP: TestRequestPage "Posted Rcpt. Cash Document CZP")
    begin
        PostedRcptCashDocumentCZP.PrintAccountingSheetCZP.SetValue(true);
        PostedRcptCashDocumentCZP.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure RequestPagePostedWdrlCashDocumentCZPHandler(var PostedWdrlCashDocumentCZP: TestRequestPage "Posted Wdrl. Cash Document CZP")
    begin
        PostedWdrlCashDocumentCZP.PrintAccountingSheetCZP.SetValue(true);
        PostedWdrlCashDocumentCZP.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure RequestPageCashDeskBookCZPHandler(var CashDeskBookCZP: TestRequestPage "Cash Desk Book CZP")
    begin
        CashDeskBookCZP.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;
}
