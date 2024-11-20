codeunit 5401 "Create Column Layout Name"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.InsertColumnLayoutName(ActualBudgetComparison(), ActualBudgetComparisonLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(BalanceOnly(), BalanceOnlyLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(BudgetAnalysis(), BudgetAnalysisLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(CashFlowComparison(), CashFlowComparisonLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(DefaultLayout(), DefaultLayoutLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(KeyCashFlowRatio(), KeyCashFlowRatioLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(PeriodsDefinition(), PeriodsDefinitionLbl);

        ContosoAccountSchedule.InsertColumnLayoutName(BalanceSheetTrend(), BalanceSheetLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(IncomeStatementTrend(), IncomeStatementLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(BeginningBalanceDebitsCreditsEndingBalance(), TrialBalanceLbl);

        ContosoAccountSchedule.InsertColumnLayoutName(CurrentMonthBalance(), CurrentMonthBalanceLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(CurrentMonthBalanceVPriorMonth(), CurrentMonthBalanceVPriorMonthLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(CurrentMonthBalanceVSameMonthPriorYear(), CurrentMonthBalanceVSameMonthPriorYearLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(CurrentMonthNetChange(), CurrentMonthNetChangeLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(CurrentMonthNetChangeBudget(), CurrentMonthNetChangeBudgetLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(CurrentMonthNetChangeVPriorMonth(), CurrentMonthNetChangeVPriorMonthLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(CurrentMonthNetChangeVSameMonthPriorYear(), CurrentMonthNetChangeVSameMonthPriorYearLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(CurrentMonthVPriorMonthCY(), CurrentMonthVPriorMonthCYLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(CurrentMonthVBudgetYearToDate(), CurrentMonthVBudgetYearToDateLbl);
    end;


    procedure ActualBudgetComparison(): Code[10]
    begin
        exit(ActualBudgetComparisonTok);
    end;

    procedure BalanceOnly(): Code[10]
    begin
        exit(BalanceOnlyTok);
    end;

    procedure BudgetAnalysis(): Code[10]
    begin
        exit(BudgetAnalysisTok);
    end;

    procedure CashFlowComparison(): Code[10]
    begin
        exit(CashFlowComparisonTok);
    end;

    procedure DefaultLayout(): Code[10]
    begin
        exit(DefaultLayoutTok);
    end;

    procedure KeyCashFlowRatio(): Code[10]
    begin
        exit(KeyCashFlowRatioTok);
    end;

    procedure PeriodsDefinition(): Code[10]
    begin
        exit(PeriodsDefinitionTok);
    end;

    procedure BalanceSheetTrend(): Code[10]
    begin
        exit(BalanceSheetTrendTok);
    end;

    procedure IncomeStatementTrend(): Code[10]
    begin
        exit(IncomeStatementTrendTok);
    end;

    procedure BeginningBalanceDebitsCreditsEndingBalance(): Code[10]
    begin
        exit(BeginningBalanceDebitsCreditsEndingBalanceTok);
    end;

    procedure CurrentMonthBalance(): Code[10]
    begin
        exit(CurrentMonthBalanceTok);
    end;

    procedure CurrentMonthBalanceVPriorMonth(): Code[10]
    begin
        exit(CurrentMonthBalanceVPriorMonthTok);
    end;

    procedure CurrentMonthBalanceVSameMonthPriorYear(): Code[10]
    begin
        exit(CurrentMonthBalanceVSameMonthPriorYearTok);
    end;

    procedure CurrentMonthNetChange(): Code[10]
    begin
        exit(CurrentMonthNetChangeTok);
    end;

    procedure CurrentMonthNetChangeBudget(): Code[10]
    begin
        exit(CurrentMonthNetChangeBudgetTok);
    end;

    procedure CurrentMonthNetChangeVPriorMonth(): Code[10]
    begin
        exit(CurrentMonthNetChangeVPriorMonthTok);
    end;

    procedure CurrentMonthNetChangeVSameMonthPriorYear(): Code[10]
    begin
        exit(CurrentMonthNetChangeVSameMonthPriorYearTok);
    end;

    procedure CurrentMonthVPriorMonthCY(): Code[10]
    begin
        exit(CurrentMonthVPriorMonthCYTok);
    end;

    procedure CurrentMonthVBudgetYearToDate(): Code[10]
    begin
        exit(CurrentMonthVBudgetYearToDateTok);
    end;

    var
        ActualBudgetComparisonTok: Label 'ACT/BUD', MaxLength = 10;
        BalanceOnlyTok: Label 'BAL ONLY', MaxLength = 10;
        BudgetAnalysisTok: Label 'BUDGANALYS', MaxLength = 10;
        CashFlowComparisonTok: Label 'CASHFLOW', MaxLength = 10;
        DefaultLayoutTok: Label 'DEFAULT', MaxLength = 10;
        KeyCashFlowRatioTok: Label 'DEGREE', MaxLength = 10;
        PeriodsDefinitionTok: Label 'PERIODS', MaxLength = 10;
        BalanceSheetTrendTok: Label 'BSTREND', MaxLength = 10, Comment = 'Balance Sheet Trend';
        IncomeStatementTrendTok: Label 'ISTREND', MaxLength = 10, Comment = 'Income Statement Trend';
        BeginningBalanceDebitsCreditsEndingBalanceTok: Label 'BBDRCREB', MaxLength = 10, Comment = 'Beginning Balance Debits Credits Ending Balance';
        CurrentMonthBalanceTok: Label 'CB', Locked = true;
        CurrentMonthBalanceVPriorMonthTok: Label 'CB V PB', Locked = true;
        CurrentMonthBalanceVSameMonthPriorYearTok: Label 'CB V SPYB', Locked = true;
        CurrentMonthNetChangeTok: Label 'CNC', Locked = true;
        CurrentMonthNetChangeBudgetTok: Label 'CNC BUD', Locked = true;
        CurrentMonthNetChangeVPriorMonthTok: Label 'CNC V PNC', Locked = true;
        CurrentMonthNetChangeVSameMonthPriorYearTok: Label 'CNC VSPYNC', Locked = true;
        CurrentMonthVPriorMonthCYTok: Label 'CNCVPNCYOY', Locked = true;
        CurrentMonthVBudgetYearToDateTok: Label 'CVC YTDBUD', Locked = true;
        BalanceSheetLbl: Label 'BS 12 Months Balance Trending Current Fiscal Year', MaxLength = 80, Comment = 'BS - abbreviation of Balance Sheet';
        IncomeStatementLbl: Label 'IS 12 Months Net Change Trending Current Fiscal Year', MaxLength = 80, Comment = 'IS - abbreviation of Income Statement';
        TrialBalanceLbl: Label 'TB Beginning Balance Debits Credits Ending Balance', MaxLength = 80, Comment = 'TB - abbreviation of Trial Balance';
        CurrentMonthBalanceLbl: Label 'BS Current Month Balance', MaxLength = 80, Comment = 'BS - abbreviation of Balance Sheet';
        CurrentMonthBalanceVPriorMonthLbl: Label 'BS Current Month Balance v Prior Month Balance', MaxLength = 80, Comment = 'BS - abbreviation of Balance Sheet';
        CurrentMonthBalanceVSameMonthPriorYearLbl: Label 'BS Current Month Balance v Same Month Prior Year Balance', MaxLength = 80, Comment = 'BS - abbreviation of Balance Sheet';
        CurrentMonthNetChangeLbl: Label 'IS Current Month Net Change', MaxLength = 80, Comment = 'IS - abbreviation of Income Statement';
        CurrentMonthNetChangeBudgetLbl: Label 'IS 12 Months Net Change Budget Only', MaxLength = 80, Comment = 'IS - abbreviation of Income Statement';
        CurrentMonthNetChangeVPriorMonthLbl: Label 'IS Current Month Net Change v Prior Month Net Change', MaxLength = 80, Comment = 'IS - abbreviation of Income Statement';
        CurrentMonthNetChangeVSameMonthPriorYearLbl: Label 'IS Current Month Net Change v Same Month Prior Year Net Change', MaxLength = 80, Comment = 'IS - abbreviation of Income Statement';
        CurrentMonthVPriorMonthCYLbl: Label 'IS Current Month v Prior Month for CY and Current Month v Prior Month for PY', MaxLength = 80, Comment = 'IS - abbreviation of Income Statement';
        CurrentMonthVBudgetYearToDateLbl: Label 'IS Current Month v Budget Year to Date v Budget and Bud Total and Bud Remaining ', MaxLength = 80, Comment = 'IS - abbreviation of Income Statement';
        ActualBudgetComparisonLbl: Label 'Actual / Budget Comparision', MaxLength = 80;
        BalanceOnlyLbl: Label 'Balance Only', MaxLength = 80;
        BudgetAnalysisLbl: Label 'Budget Analysis', MaxLength = 80;
        CashFlowComparisonLbl: Label 'Comparison month - year', MaxLength = 80;
        DefaultLayoutLbl: Label 'Standard Column Layout', MaxLength = 80;
        KeyCashFlowRatioLbl: Label 'Key Cash Flow Ratio', MaxLength = 80;
        PeriodsDefinitionLbl: Label 'Periods Definition for Mini Charts', MaxLength = 80;
}
