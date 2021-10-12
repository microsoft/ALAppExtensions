codeunit 148074 "Cash Desk Reports CZP"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Cash Desk] [Reports]
        isInitialized := false;
    end;

    var
        CashDeskCZP: Record "Cash Desk CZP";
        CashDeskUserCZP: Record "Cash Desk User CZP";
        CashDeskEventCZP: Record "Cash Desk Event CZP";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        LibraryCashDeskCZP: Codeunit "Library - Cash Desk CZP";
        LibraryCashDocumentCZP: Codeunit "Library - Cash Document CZP";
        isInitialized: Boolean;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Cash Desk Reports CZP");
        LibraryRandom.Init();
        LibraryVariableStorage.Clear();
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Cash Desk Reports CZP");

        LibraryCashDeskCZP.CreateCashDeskCZP(CashDeskCZP);
        LibraryCashDeskCZP.SetupCashDeskCZP(CashDeskCZP, true);
        LibraryCashDeskCZP.CreateCashDeskUserCZP(CashDeskUserCZP, CashDeskCZP."No.", true, true, true);

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Cash Desk Reports CZP");
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
        Initialize();

        // [GIVEN] Create Cash Document
        CreateCashDocument(CashDocumentHeaderCZP, CashDocumentLineCZP, CashDocType, CashDeskCZP."No.");
        Commit();

        // [WHEN] Print Cash Document
        PrintCashDocument(CashDocumentHeaderCZP);

        // [THEN] Report dataset will contain Amount Including VAT
        case CashDocType of
            CashDocType::Receipt:
                LibraryReportDataset.RunReportAndLoad(Report::"Receipt Cash Document CZP", CashDocumentHeaderCZP, '');
            CashDocType::Withdrawal:
                LibraryReportDataset.RunReportAndLoad(Report::"Withdrawal Cash Document CZP", CashDocumentHeaderCZP, '');
        end;
        LibraryReportDataset.AssertElementWithValueExists('AmountIncludingVAT_CashDocumentLine', CashDocumentLineCZP."Amount Including VAT");

        // [THEN] Report dataset will contain Cash Document No.
        LibraryReportDataset.AssertElementWithValueExists('No_CashDocumentHeader', CashDocumentHeaderCZP."No.");
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
        Initialize();

        // [GIVEN] Create Receipt Cash Document
        CreateCashDocument(CashDocumentHeaderCZP, CashDocumentLineCZP, CashDocType, CashDeskCZP."No.");

        // [GIVEN] Post Cash Document
        PostCashDocument(CashDocumentHeaderCZP);
        PostedCashDocumentHdrCZP.SetRange("Cash Desk No.", CashDeskCZP."No.");
        PostedCashDocumentHdrCZP.FindLast();

        // [WHEN] Print Posted Cash Document
        PrintPostedCashDocument(PostedCashDocumentHdrCZP);

        // [THEN] Report dataset will contain Amount Including VAT
        case CashDocType of
            CashDocType::Receipt:
                LibraryReportDataset.RunReportAndLoad(Report::"Posted Rcpt. Cash Document CZP", PostedCashDocumentHdrCZP, '');
            CashDocType::Withdrawal:
                LibraryReportDataset.RunReportAndLoad(Report::"Posted Wdrl. Cash Document CZP", PostedCashDocumentHdrCZP, '');
        end;
        LibraryReportDataset.AssertElementWithValueExists('AmountIncludingVAT_PostedCashDocumentLine', CashDocumentLineCZP."Amount Including VAT");

        // [THEN] Report dataset will contain Posted Cash Document No.
        LibraryReportDataset.AssertElementWithValueExists('No_PostedCashDocumentHeader', PostedCashDocumentHdrCZP."No.");
    end;

    [Test]
    [HandlerFunctions('YesConfirmHandler,RequestPageCashDeskBookCZPHandler')]
    procedure PrintingCashDeskBook()
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
    begin
        // [SCENARIO] Check that correct Amounts are present on Cash Desk Book Report

        // [GIVEN] Initialize new new Cash Desk
        isInitialized := false;
        Initialize();

        // [GIVEN] Create Receipt Cash Document
        LibraryCashDocumentCZP.CreateCashDocumentHeaderCZP(CashDocumentHeaderCZP, CashDocumentHeaderCZP."Document Type"::Receipt, CashDeskCZP."No.");

        // [GIVEN] Create Cash Desk Event
        LibraryCashDeskCZP.CreateCashDeskEventCZP(
          CashDeskEventCZP, CashDeskCZP."No.", CashDocumentHeaderCZP."Document Type"::Receipt,
          CashDeskEventCZP."Account Type"::"G/L Account", LibraryCashDocumentCZP.GetNewGLAccountNo(true));

        // [GIVEN] Create Receipt Cash Document Lines
        LibraryCashDocumentCZP.CreateCashDocumentLineCZPWithCashDeskEvent(
          CashDocumentLineCZP, CashDocumentHeaderCZP, CashDeskEventCZP.Code, LibraryRandom.RandInt(Round(CashDeskCZP."Cash Receipt Limit" / 10, 1, '<')));
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

        // [THEN] Report dataset will contain Cash Desk No.
        LibraryReportDataset.RunReportAndLoad(Report::"Cash Desk Book CZP", CashDeskCZP, '');
        LibraryReportDataset.AssertElementWithValueExists('CashDesk_No', CashDeskCZP."No.");

        // [THEN] Report dataset will contain Receipt Amout equal to Receipt document
        PostedCashDocumentHdrCZP.SetRange("Cash Desk No.", CashDeskCZP."No.");
        PostedCashDocumentHdrCZP.FindFirst();
        PostedCashDocumentHdrCZP.CalcFields("Amount Including VAT");
        LibraryReportDataset.AssertElementWithValueExists('Receipt', PostedCashDocumentHdrCZP."Amount Including VAT");

        // [THEN] Report dataset will contain Payment Amout equal to Wihdrwal document
        PostedCashDocumentHdrCZP.FindLast();
        PostedCashDocumentHdrCZP.CalcFields("Amount Including VAT");
        LibraryReportDataset.AssertElementWithValueExists('Payment', PostedCashDocumentHdrCZP."Amount Including VAT");
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
