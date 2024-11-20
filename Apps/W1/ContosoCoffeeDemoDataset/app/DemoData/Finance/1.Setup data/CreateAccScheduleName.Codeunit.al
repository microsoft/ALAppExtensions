codeunit 5223 "Create Acc. Schedule Name"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateAnalysisView: Codeunit "Create Analysis View";
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.InsertAccScheduleName(AccountCategoriesOverview(), AccountCategoriesOverviewLbl, '');
        ContosoAccountSchedule.InsertAccScheduleName(CapitalStructure(), CapitalStructureLbl, '');
        ContosoAccountSchedule.InsertAccScheduleName(CashFlowCalculation(), CashFlowCalculationLbl, '');
        ContosoAccountSchedule.InsertAccScheduleName(CashCycle(), CashCycleDataLbl, '');
        ContosoAccountSchedule.InsertAccScheduleName(CashFlow(), CashFlowDataLbl, '');
        ContosoAccountSchedule.InsertAccScheduleName(IncomeExpense(), IncomeExpenseDataLbl, '');
        ContosoAccountSchedule.InsertAccScheduleName(ReducedTrialBalance(), ReducedTrialBalanceDataLbl, '');
        ContosoAccountSchedule.InsertAccScheduleName(Revenues(), RevenuesLbl, CreateAnalysisView.SalesRevenue());
        ContosoAccountSchedule.InsertAccScheduleName(BalanceSheetDetailed(), BalanceSheetDetailedLbl, '');
        ContosoAccountSchedule.InsertAccScheduleName(BalanceSheetSummarized(), BalanceSheetSummarizedLbl, '');
        ContosoAccountSchedule.InsertAccScheduleName(IncomeStatementDetailed(), IncomeStatementDetailedLbl, '');
        ContosoAccountSchedule.InsertAccScheduleName(IncomeStatementSummarized(), IncomeStatementSummarizedLbl, '');
        ContosoAccountSchedule.InsertAccScheduleName(TrialBalance(), TrialBalanceLbl, '');
    end;

    procedure AccountCategoriesOverview(): Code[10]
    begin
        exit(AccountCategoriesOverviewTok);
    end;

    procedure CapitalStructure(): Code[10]
    begin
        exit(CapitalStructureTok);
    end;

    procedure CashFlowCalculation(): Code[10]
    begin
        exit(CashFlowCalculationTok);
    end;

    procedure CashCycle(): Code[10]
    begin
        exit(CashCycleDataTok);
    end;

    procedure CashFlow(): Code[10]
    begin
        exit(CashFlowDataTok);
    end;

    procedure IncomeExpense(): Code[10]
    begin
        exit(IncomeExpenseDataTok);
    end;

    procedure ReducedTrialBalance(): Code[10]
    begin
        exit(ReducedTrialBalanceDataTok);
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
        exit(IncomeStatementSummerizedTok);
    end;

    procedure TrialBalance(): Code[10]
    begin
        exit(TrialBalanceTok);
    end;

    var
        AccountCategoriesOverviewTok: Label 'ACC-CAT', MaxLength = 10;
        CapitalStructureTok: Label 'ANALYSIS', MaxLength = 10;
        CashFlowCalculationTok: Label 'CASHFLOW', MaxLength = 10;
        CashCycleDataTok: Label 'I_CACYCLE', MaxLength = 10;
        CashFlowDataTok: Label 'I_CASHFLOW', MaxLength = 10;
        IncomeExpenseDataTok: Label 'I_INCEXP', MaxLength = 10;
        ReducedTrialBalanceDataTok: Label 'I_MINTRIAL', MaxLength = 10;
        RevenuesTok: Label 'REVENUE', MaxLength = 10;
        BalanceSheetDetailedTok: Label 'BS DET', MaxLength = 10, Comment = 'Balance Sheet Detailed';
        BalanceSheetSummarizedTok: Label 'BS SUM', MaxLength = 10, Comment = 'Balance Sheet Summarized';
        IncomeStatementDetailedTok: Label 'IS DET', MaxLength = 10, Comment = 'Income Statement Detailed';
        IncomeStatementSummerizedTok: Label 'IS SUM', MaxLength = 10, Comment = 'Income Statement Summarized';
        TrialBalanceTok: Label 'TB', MaxLength = 10, Comment = 'Trial Balance';
        BalanceSheetDetailedLbl: Label 'Balance Sheet Detailed', MaxLength = 80;
        BalanceSheetSummarizedLbl: Label 'Balance Sheet Summarized', MaxLength = 80;
        IncomeStatementDetailedLbl: Label 'Income Statement Detailed', MaxLength = 80;
        IncomeStatementSummarizedLbl: Label 'Income Statement Summarized', MaxLength = 80;
        TrialBalanceLbl: Label 'Trial Balance', MaxLength = 80;
        AccountCategoriesOverviewLbl: Label 'Account Categories overview', MaxLength = 80;
        CapitalStructureLbl: Label 'Capital Structure', MaxLength = 80;
        CashFlowCalculationLbl: Label 'Calculation Of Cash Flow', MaxLength = 80;
        CashCycleDataLbl: Label 'Data for Cash Cycle Chart', MaxLength = 80;
        CashFlowDataLbl: Label 'Data for Cash Flow Chart', MaxLength = 80;
        IncomeExpenseDataLbl: Label 'Data for Income & Expense Chart', MaxLength = 80;
        ReducedTrialBalanceDataLbl: Label 'Data for Reduced Trial Balance Info Part', MaxLength = 80;
        RevenuesLbl: Label 'Revenues', MaxLength = 80;
}