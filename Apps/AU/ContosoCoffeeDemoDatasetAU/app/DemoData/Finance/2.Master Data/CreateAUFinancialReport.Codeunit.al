codeunit 17137 "Create AU Financial Report"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
        CreateAUAccountScheduleName: Codeunit "Create AU Acc Schedule Name";
    begin
        ContosoAccountSchedule.SetOverwriteData(true);
        ContosoAccountSchedule.InsertFinancialReport(CreateAUAccountScheduleName.BalanceSheetDetail(), BalanceSheetDetailedLbl, CreateAUAccountScheduleName.BalanceSheetDetail(), BalanceSheetTrendLbl);
        ContosoAccountSchedule.InsertFinancialReport(CreateAUAccountScheduleName.BalanceSheetSummarized(), BalanceSheetSummarizedLbl, CreateAUAccountScheduleName.BalanceSheetSummarized(), BalanceSheetTrendLbl);
        ContosoAccountSchedule.InsertFinancialReport(CreateAUAccountScheduleName.IncomeStatementDetail(), IncomeStatementDetailedLbl, CreateAUAccountScheduleName.IncomeStatementDetail(), IncomeStatementTrendLbl);
        ContosoAccountSchedule.InsertFinancialReport(CreateAUAccountScheduleName.IncomeStatementSummarized(), IncomeStatementSummarizedLbl, CreateAUAccountScheduleName.IncomeStatementSummarized(), IncomeStatementTrendLbl);
        ContosoAccountSchedule.InsertFinancialReport(CreateAUAccountScheduleName.TrialBalance(), TrialBalanceLbl, CreateAUAccountScheduleName.TrialBalance(), BeginningBalanceDebitsCreditsEndingBalanceLbl);
        ContosoAccountSchedule.SetOverwriteData(false);
    end;

    var
        BalanceSheetDetailedLbl: Label 'Balance Sheet Detailed', MaxLength = 80;
        BalanceSheetSummarizedLbl: Label 'Balance Sheet Summarized', MaxLength = 80;
        IncomeStatementDetailedLbl: Label 'Income Statement Detailed', MaxLength = 80;
        IncomeStatementSummarizedLbl: Label 'Income Statement Summarized', MaxLength = 80;
        TrialBalanceLbl: Label 'Trial Balance', MaxLength = 80;
        BalanceSheetTrendLbl: Label 'BSTREND', MaxLength = 10;
        IncomeStatementTrendLbl: Label 'ISTREND', MaxLength = 10;
        BeginningBalanceDebitsCreditsEndingBalanceLbl: Label 'BBDRCREB', MaxLength = 10;
}