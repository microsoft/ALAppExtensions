codeunit 148059 "Financial Reports CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Core] [Financial Reports]
        isInitialized := false;
    end;

    var
        GLAccount: Record "G/L Account";
        LibraryRandom: Codeunit "Library - Random";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryTaxCZL: Codeunit "Library - Tax CZL";
        RequestPageXML: Text;
        isInitialized: Boolean;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Financial Reports CZL");
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Financial Reports CZL");

        LibraryTaxCZL.SetUseVATDate(true);

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Financial Reports CZL");
    end;

    [Test]
    [HandlerFunctions('CalcPostVATSettlementRequestPageHandler')]
    procedure CalcPostVATSettlement()
    begin
        // [SCENARIO] Run report Calc and Post VAT Settlement
        Initialize();

        // [WHEN] Report run
        RequestPageXML := Report.RunRequestPage(Report::"Calc. and Post VAT Settl. CZL");
        LibraryReportDataset.RunReportAndLoad(Report::"Calc. and Post VAT Settl. CZL", '', RequestPageXML);

        // [THEN] Report Dataset will contain Company Name
        LibraryReportDataset.AssertElementWithValueExists('CompanyName', CompanyProperty.DisplayName());
    end;

    [RequestPageHandler]
    procedure CalcPostVATSettlementRequestPageHandler(var CalcandPostVATSettlCZL: TestRequestPage "Calc. and Post VAT Settl. CZL")
    var
        VATPeriodCZL: Record "VAT Period CZL";
    begin
        VATPeriodCZL.SetFilter("Starting Date", '..%1', WorkDate());
        VATPeriodCZL.FindLast();

#pragma warning disable AA0210
        GLAccount.SetRange(Blocked, false);
        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
        GLAccount.SetRange("Direct Posting", true);
        GLAccount.SetFilter("Gen. Bus. Posting Group", '%1', '');
        GLAccount.SetFilter("Gen. Prod. Posting Group", '%1', '');
        GLAccount.SetFilter("VAT Prod. Posting Group", '%1', '');
        GLAccount.FindFirst();
#pragma warning restore

        CalcandPostVATSettlCZL.StartingDate.SetValue(VATPeriodCZL."Starting Date");
        CalcandPostVATSettlCZL.PostingDt.SetValue(WorkDate());
        CalcandPostVATSettlCZL.SettlementAcc.SetValue(GLAccount."No.");
        CalcandPostVATSettlCZL.DocumentNo.SetValue(CopyStr(LibraryRandom.RandText(20), 1, 20));
        CalcandPostVATSettlCZL.ShowVATEntries.SetValue(true);
        CalcandPostVATSettlCZL.OK().Invoke();
    end;

    [Test]
    [HandlerFunctions('BalanceSheetRequestPageHandler')]
    procedure BalanceSheet()
    begin
        // [SCENARIO] Run report Balance Sheet
        Initialize();

        // [WHEN] Report run
        RequestPageXML := Report.RunRequestPage(Report::"Balance Sheet CZL");
        LibraryReportDataset.RunReportAndLoad(Report::"Balance Sheet CZL", '', RequestPageXML);

        // [THEN] Report Dataset will contain Company Name
        LibraryReportDataset.AssertElementWithValueExists('COMPANYNAME', CompanyProperty.DisplayName());
    end;

    [RequestPageHandler]
    procedure BalanceSheetRequestPageHandler(var BalanceSheetCZL: TestRequestPage "Balance Sheet CZL")
    var
        AccScheduleName: Record "Acc. Schedule Name";
    begin
        AccScheduleName.FindFirst();

        BalanceSheetCZL.AccSchedNameCZL.SetValue(AccScheduleName.Name);
        BalanceSheetCZL.DateFilterCZL.SetValue(WorkDate());
        BalanceSheetCZL.OK().Invoke();
    end;

    [Test]
    [HandlerFunctions('IncomeStatementRequestPageHandler')]
    procedure IncomeStatement()
    begin
        // [SCENARIO] Run report Income Statement
        Initialize();

        // [WHEN] Report run
        RequestPageXML := Report.RunRequestPage(Report::"Income Statement CZL");
        LibraryReportDataset.RunReportAndLoad(Report::"Income Statement CZL", '', RequestPageXML);

        // [THEN] Report Dataset will contain Company Name
        LibraryReportDataset.AssertElementWithValueExists('COMPANYNAME', CompanyProperty.DisplayName());
    end;

    [RequestPageHandler]
    procedure IncomeStatementRequestPageHandler(var IncomeStatementCZL: TestRequestPage "Income Statement CZL")
    var
        AccScheduleName: Record "Acc. Schedule Name";
    begin
        AccScheduleName.FindFirst();

        IncomeStatementCZL.AccSchedNameCZL.SetValue(AccScheduleName.Name);
        IncomeStatementCZL.DateFilterCZL.SetValue(WorkDate());
        IncomeStatementCZL.OK().Invoke();
    end;
}
