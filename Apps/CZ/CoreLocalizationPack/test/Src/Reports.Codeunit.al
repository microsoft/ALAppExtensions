codeunit 148059 "Reports CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";
        AccountNo: Code[20];
        isInitialized: Boolean;

    local procedure Initialize()
    begin
        if isInitialized then
            exit;

        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Use VAT Date CZL" := true;
        GeneralLedgerSetup.Modify();
        AccountNo := LibraryERM.CreateGLAccountNoWithDirectPosting();

        isInitialized := true;
        Commit();
    end;

    [Test]
    [HandlerFunctions('CalcPostVATSettlementRequestPageHandler')]
    procedure TestCalcPostVATSettlement()
    begin
        // [SCENARIO] Check substitued reports
        // [FEATURE] Run report Calc and Post VAT Settlement
        Initialize();

        // [WHEN] Report run
        Report.Run(Report::"Calc. and Post VAT Settl. CZL");

        // [THEN] Validation is done in the request page handler
    end;

    [RequestPageHandler]
    procedure CalcPostVATSettlementRequestPageHandler(var CalcandPostVATSettlCZL: TestRequestPage "Calc. and Post VAT Settl. CZL")
    var
        VATPeriodCZL: Record "VAT Period CZL";
    begin
        VATPeriodCZL.SetFilter("Starting Date", '..%1', WorkDate());
        VATPeriodCZL.FindLast();

        CalcandPostVATSettlCZL.StartingDate.SetValue(VATPeriodCZL."Starting Date");
        CalcandPostVATSettlCZL.PostingDt.SetValue(WorkDate());
        CalcandPostVATSettlCZL.SettlementAcc.SetValue(AccountNo);
        CalcandPostVATSettlCZL.DocumentNo.SetValue(CopyStr(LibraryRandom.RandText(20), 1, 20));
        CalcandPostVATSettlCZL.ShowVATEntries.SetValue(true);
        CalcandPostVATSettlCZL.SaveAsPdf(CalcandPostVATSettlCZL.Caption);
    end;

    [Test]
    [HandlerFunctions('BalanceSheetRequestPageHandler')]
    procedure TestBalanceSheet()
    begin
        // [SCENARIO] Check substitued reports
        // [FEATURE] Run report Balance Sheet
        Report.Run(Report::"Balance Sheet CZL");

        // [THEN] Validation is done in the request page handler
    end;

    [RequestPageHandler]
    procedure BalanceSheetRequestPageHandler(var BalanceSheetCZL: TestRequestPage "Balance Sheet CZL")
    begin
    end;

    [Test]
    [HandlerFunctions('IncomeStatementRequestPageHandler')]
    procedure TestIncomeStatement()
    begin
        // [SCENARIO] Check substitued reports
        // [FEATURE] Run report Income Statement
        Report.Run(Report::"Income Statement CZL");

        // [THEN] Validation is done in the request page handler
    end;

    [RequestPageHandler]
    procedure IncomeStatementRequestPageHandler(var IncomeStatementCZL: TestRequestPage "Income Statement CZL")
    begin
    end;
}
