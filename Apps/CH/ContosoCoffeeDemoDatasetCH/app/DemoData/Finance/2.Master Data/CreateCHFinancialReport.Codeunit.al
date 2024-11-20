codeunit 11601 "Create CH Financial Report"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateCHColumnLayoutName: Codeunit "Create CH Column Layout Name";
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
        CreateCHAccScheduleName: Codeunit "Create CH Acc. Schedule Name";
    begin
        ContosoAccountSchedule.InsertFinancialReport(BalanceSheetDetailed(), BalanceSheetDetailedLbl, CreateCHAccScheduleName.BalanceSheetDetailed(), CreateCHColumnLayoutName.BalanceSheetTrend());
        ContosoAccountSchedule.InsertFinancialReport(BalanceSheetSummarized(), BalanceSheetSummarizedLbl, CreateCHAccScheduleName.BalanceSheetSummarized(), CreateCHColumnLayoutName.BalanceSheetTrend());
        ContosoAccountSchedule.InsertFinancialReport(IncomeStatementDetailed(), IncomeStatementDetailedLbl, CreateCHAccScheduleName.IncomeStatementDetailed(), CreateCHColumnLayoutName.IncomeStatementTrend());
        ContosoAccountSchedule.InsertFinancialReport(IncomeStatementSummarized(), IncomeStatementSummarizedLbl, CreateCHAccScheduleName.IncomeStatementSummarized(), CreateCHColumnLayoutName.IncomeStatementTrend());
        ContosoAccountSchedule.InsertFinancialReport(TrialBalance(), TrialBalanceLbl, CreateCHAccScheduleName.TrialBalance(), CreateCHColumnLayoutName.BeginningBalanceDebitsCreditsEndingBalance());
    end;

    procedure BalanceSheetDetailed(): Code[10]
    begin
        exit(BalanceSheetDetailedTok);
    end;

    procedure BalanceSheetSummarized(): Code[10]
    begin
        exit(BalanceSheetSummarizedTok);
    end;

    procedure IncomeStatementDetailed(): Code[10]
    begin
        exit(IncomeStatementDetailedTok);
    end;

    procedure IncomeStatementSummarized(): Code[10]
    begin
        exit(IncomeStatementSummarizedTok);
    end;

    procedure TrialBalance(): Code[10]
    begin
        exit(TrialBalanceTok);
    end;

    var
        BalanceSheetDetailedTok: Label 'BS DET', MaxLength = 10;
        BalanceSheetSummarizedTok: Label 'BS SUM', MaxLength = 10;
        IncomeStatementDetailedTok: Label 'IS DET', MaxLength = 10;
        IncomeStatementSummarizedTok: Label 'IS SUM', MaxLength = 10;
        TrialBalanceTok: Label 'TB', MaxLength = 10;
        BalanceSheetDetailedLbl: Label 'Balance Sheet Detailed', MaxLength = 80;
        BalanceSheetSummarizedLbl: Label 'Balance Sheet Summarized', MaxLength = 80;
        IncomeStatementDetailedLbl: Label 'Income Statement Detailed', MaxLength = 80;
        IncomeStatementSummarizedLbl: Label 'Income Statement Summarized', MaxLength = 80;
        TrialBalanceLbl: Label 'Trial Balance', MaxLength = 80;
}