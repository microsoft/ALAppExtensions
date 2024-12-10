codeunit 17120 "Create NZ Financial Report"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
        CreateNZAccountScheduleName: Codeunit "Create NZ Acc Schedule Name";
    begin
        ContosoAccountSchedule.SetOverwriteData(true);
        ContosoAccountSchedule.InsertFinancialReport(CreateNZAccountScheduleName.BalanceSheetDetail(), BalanceSheetDetailedLbl, CreateNZAccountScheduleName.BalanceSheetDetail(), BalanceSheetTrendLbl);
        ContosoAccountSchedule.InsertFinancialReport(CreateNZAccountScheduleName.BalanceSheetSummarized(), BalanceSheetSummarizedLbl, CreateNZAccountScheduleName.BalanceSheetSummarized(), BalanceSheetTrendLbl);
        ContosoAccountSchedule.InsertFinancialReport(CreateNZAccountScheduleName.IncomeStatementDetail(), IncomeStatementDetailedLbl, CreateNZAccountScheduleName.IncomeStatementDetail(), IncomeStatementTrendLbl);
        ContosoAccountSchedule.InsertFinancialReport(CreateNZAccountScheduleName.IncomeStatementSummarized(), IncomeStatementSummarizedLbl, CreateNZAccountScheduleName.IncomeStatementSummarized(), IncomeStatementTrendLbl);
        ContosoAccountSchedule.InsertFinancialReport(CreateNZAccountScheduleName.TrialBalance(), TrialBalanceLbl, CreateNZAccountScheduleName.TrialBalance(), BeginningBalanceDebitsCreditsEndingBalanceLbl);
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