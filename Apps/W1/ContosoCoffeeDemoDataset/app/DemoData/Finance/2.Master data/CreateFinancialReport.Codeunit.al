codeunit 5425 "Create Financial Report"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ColumnLayoutName: Codeunit "Create Column Layout Name";
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
        AccountScheduleName: Codeunit "Create Acc. Schedule Name";
    begin
        ContosoAccountSchedule.InsertFinancialReport(AccountCategoriesOverview(), AccountCategoriesOverviewLbl, AccountScheduleName.AccountCategoriesOverview(), ColumnLayoutName.PeriodsDefinition());
        ContosoAccountSchedule.InsertFinancialReport(CapitalStructure(), CapitalStructureLbl, AccountScheduleName.CapitalStructure(), ColumnLayoutName.BalanceOnly());
        ContosoAccountSchedule.InsertFinancialReport(CalculationOfCashFlow(), CalculationOfCashFlowLbl, AccountScheduleName.CashFlowCalculation(), ColumnLayoutName.CashFlowComparison());
        ContosoAccountSchedule.InsertFinancialReport(DataForCashCycleChart(), DataForCashCycleChartLbl, AccountScheduleName.CashCycle(), ColumnLayoutName.PeriodsDefinition());
        ContosoAccountSchedule.InsertFinancialReport(DataForCashFlowChart(), DataForCashFlowChartLbl, AccountScheduleName.CashFlow(), ColumnLayoutName.PeriodsDefinition());
        ContosoAccountSchedule.InsertFinancialReport(DataForIncomeExpenseChart(), DataForIncomeExpenseChartLbl, AccountScheduleName.IncomeExpense(), ColumnLayoutName.PeriodsDefinition());
        ContosoAccountSchedule.InsertFinancialReport(DataForReducedTrialBalanceInfoPart(), DataForReducedTrialBalanceInfoPartLbl, AccountScheduleName.ReducedTrialBalance(), ColumnLayoutName.PeriodsDefinition());
        ContosoAccountSchedule.InsertFinancialReport(Revenues(), RevenuesLbl, AccountScheduleName.Revenues(), ColumnLayoutName.BudgetAnalysis());

        ContosoAccountSchedule.InsertFinancialReport(BalanceSheetDetailed(), BalanceSheetDetailedLbl, AccountScheduleName.BalanceSheetDetailed(), ColumnLayoutName.BalanceSheetTrend());
        ContosoAccountSchedule.InsertFinancialReport(BalanceSheetSummarized(), BalanceSheetSummarizedLbl, AccountScheduleName.BalanceSheetSummarized(), ColumnLayoutName.BalanceSheetTrend());
        ContosoAccountSchedule.InsertFinancialReport(IncomeStatementDetailed(), IncomeStatementDetailedLbl, AccountScheduleName.IncomeStatementDetailed(), ColumnLayoutName.IncomeStatementTrend());
        ContosoAccountSchedule.InsertFinancialReport(IncomeStatementSummarized(), IncomeStatementSummarizedLbl, AccountScheduleName.IncomeStatementSummarized(), ColumnLayoutName.IncomeStatementTrend());
        ContosoAccountSchedule.InsertFinancialReport(TrialBalance(), TrialBalanceLbl, AccountScheduleName.TrialBalance(), ColumnLayoutName.BeginningBalanceDebitsCreditsEndingBalance());
    end;

    procedure AccountCategoriesOverview(): Code[10]
    begin
        exit(AccountCategoriesOverviewTok);
    end;

    procedure CapitalStructure(): Code[10]
    begin
        exit(CapitalStructureTok);
    end;

    procedure CalculationOfCashFlow(): Code[10]
    begin
        exit(CalculationOfCashFlowTok);
    end;

    procedure DataForCashCycleChart(): Code[10]
    begin
        exit(DataForCashCycleChartTok);
    end;

    procedure DataForCashFlowChart(): Code[10]
    begin
        exit(DataForCashFlowChartTok);
    end;

    procedure DataForIncomeExpenseChart(): Code[10]
    begin
        exit(DataForIncomeExpenseChartTok);
    end;

    procedure DataForReducedTrialBalanceInfoPart(): Code[10]
    begin
        exit(DataForReducedTrialBalanceInfoPartTok);
    end;

    procedure Revenues(): Code[10]
    begin
        exit(RevenuesTok);
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
        AccountCategoriesOverviewTok: Label 'ACC-CAT', MaxLength = 10;
        CapitalStructureTok: Label 'ANALYSIS', MaxLength = 10;
        CalculationOfCashFlowTok: Label 'CASHFLOW', MaxLength = 10;
        DataForCashCycleChartTok: Label 'I_CACYCLE', MaxLength = 10;
        DataForCashFlowChartTok: Label 'I_CASHFLOW', MaxLength = 10;
        DataForIncomeExpenseChartTok: Label 'I_INCEXP', MaxLength = 10;
        DataForReducedTrialBalanceInfoPartTok: Label 'I_MINTRIAL', MaxLength = 10;
        RevenuesTok: Label 'REVENUE', MaxLength = 10;
        BalanceSheetDetailedTok: Label 'BS DET', MaxLength = 10, Comment = 'Balance Sheet Detailed';
        BalanceSheetSummarizedTok: Label 'BS SUM', MaxLength = 10, Comment = 'Balance Sheet Summarized';
        IncomeStatementDetailedTok: Label 'IS DET', MaxLength = 10, Comment = 'Income Statement Detailed';
        IncomeStatementSummarizedTok: Label 'IS SUM', MaxLength = 10, Comment = 'Income Statement Summarized';
        TrialBalanceTok: Label 'TB', MaxLength = 10, Comment = 'Trial Balance';
        AccountCategoriesOverviewLbl: Label 'Account Categories overview', MaxLength = 80;
        CapitalStructureLbl: Label 'Capital Structure', MaxLength = 80;
        CalculationOfCashFlowLbl: Label 'Calculation Of Cash Flow', MaxLength = 80;
        DataForCashCycleChartLbl: Label 'Data for Cash Cycle Chart', MaxLength = 80;
        DataForCashFlowChartLbl: Label 'Data for Cash Flow Chart', MaxLength = 80;
        DataForIncomeExpenseChartLbl: Label 'Data for Income & Expense Chart', MaxLength = 80;
        DataForReducedTrialBalanceInfoPartLbl: Label 'Data for Reduced Trial Balance Info Part', MaxLength = 80;
        RevenuesLbl: Label 'Revenues', MaxLength = 80;
        BalanceSheetDetailedLbl: Label 'Balance Sheet Detailed', MaxLength = 80;
        BalanceSheetSummarizedLbl: Label 'Balance Sheet Summarized', MaxLength = 80;
        IncomeStatementDetailedLbl: Label 'Income Statement Detailed', MaxLength = 80;
        IncomeStatementSummarizedLbl: Label 'Income Statement Summarized', MaxLength = 80;
        TrialBalanceLbl: Label 'Trial Balance', MaxLength = 80;
}