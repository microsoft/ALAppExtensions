// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 5401 "Create Column Layout Name"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.InsertColumnLayoutName(ActualBudgetComparison(), ActualBudgetComparisonLbl, ActualBudgetComparisonInternalDescriptionLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(BalanceOnly(), BalanceOnlyLbl, BalanceOnlyInternalDescriptionLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(BudgetAnalysis(), BudgetAnalysisLbl, BudgetAnalysisInternalDescriptionLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(CashFlowComparison(), CashFlowComparisonLbl, CashFlowComparisonInternalDescriptionLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(DefaultLayout(), DefaultLayoutLbl, DefaultLayoutInternalDescriptionLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(KeyCashFlowRatio(), KeyCashFlowRatioLbl, KeyCashFlowRatioInternalDescriptionLbl);

        ContosoAccountSchedule.InsertColumnLayoutName(BalanceSheetTrend(), BalanceSheetLbl, BalanceSheetInternalDescriptionLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(IncomeStatementTrend(), IncomeStatementLbl, IncomeStatementInternalDescriptionLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(BeginningBalanceDebitsCreditsEndingBalance(), TrialBalanceLbl, TrialBalanceInternalDescriptionLbl);

        ContosoAccountSchedule.InsertColumnLayoutName(CurrentMonthBalance(), CurrentMonthBalanceLbl, CurrentMonthBalanceInternalDescriptionLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(CurrentMonthBalanceVPriorMonth(), CurrentMonthBalanceVPriorMonthLbl, CurrentMonthBalanceVPriorMonthInternalDescriptionLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(CurrentMonthBalanceVSameMonthPriorYear(), CurrentMonthBalanceVSameMonthPriorYearLbl, CurrentMonthBalanceVSameMonthPriorYearInternalDescriptionLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(CurrentMonthNetChange(), CurrentMonthNetChangeLbl, CurrentMonthNetChangeInternalDescriptionLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(CurrentMonthNetChangeBudget(), CurrentMonthNetChangeBudgetLbl, CurrentMonthNetChangeBudgetInternalDescriptionLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(CurrentMonthNetChangeVPriorMonth(), CurrentMonthNetChangeVPriorMonthLbl, CurrentMonthNetChangeVPriorMonthInternalDescriptionLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(CurrentMonthNetChangeVSameMonthPriorYear(), CurrentMonthNetChangeVSameMonthPriorYearLbl, CurrentMonthNetChangeVSameMonthPriorYearInternalDescriptionLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(CurrentMonthVPriorMonthCY(), CurrentMonthVPriorMonthCYLbl, CurrentMonthVPriorMonthCYInternalDescriptionLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(CurrentMonthVBudgetYearToDate(), CurrentMonthVBudgetYearToDateLbl, CurrentMonthVBudgetYearToDateInternalDescriptionLbl);
    end;

    internal procedure CreateSetupColumnLayoutName()
    var
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.InsertColumnLayoutName(PeriodsDefinition(), PeriodsDefinitionLbl, PeriodsDefinitionInternalDescriptionLbl);
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
        CurrentMonthVBudgetYearToDateLbl: Label 'IS Current Month v Budget Year to Date v Budget and Bud Total and Bud Remaining', MaxLength = 80, Comment = 'IS - abbreviation of Income Statement';
        ActualBudgetComparisonLbl: Label 'Actual / Budget Comparison', MaxLength = 80;
        BalanceOnlyLbl: Label 'Balance Only', MaxLength = 80;
        BudgetAnalysisLbl: Label 'Budget Analysis', MaxLength = 80;
        CashFlowComparisonLbl: Label 'Comparison month - year', MaxLength = 80;
        DefaultLayoutLbl: Label 'Standard Column Layout', MaxLength = 80;
        KeyCashFlowRatioLbl: Label 'Key Cash Flow Ratio', MaxLength = 80;
        PeriodsDefinitionLbl: Label 'Periods Definition for Mini Charts', MaxLength = 80;
        BalanceSheetInternalDescriptionLbl: Label 'Twelve-column layout showing month-end balances for each month of the current fiscal year using balance at date and net amount from ledger entries. This layout enables trend analysis across all months, helping identify seasonal fluctuations and financial position changes. Useful for monitoring monthly balance trends, supporting balance sheet reporting, and year-end reviews.', MaxLength = 500;
        IncomeStatementInternalDescriptionLbl: Label 'Thirteen-column layout displaying monthly net changes for each month of the current fiscal year plus a total column calculated using formulas and ledger entries. This structure provides a detailed view of income statement activity across all periods, enabling trend analysis and cumulative performance tracking. Useful for monitoring monthly revenue and expense movements, identifying seasonal patterns, and supporting financial planning, forecasting, and management reporting.', MaxLength = 500;
        TrialBalanceInternalDescriptionLbl: Label 'Four-column layout showing beginning balance, debits, credits, and a formula ending balance (1+2-3). Useful for trial-balance reconciliation, tracking period activity, and validating period-end balances.', MaxLength = 500;
        CurrentMonthBalanceInternalDescriptionLbl: Label 'Three-column layout showing current month balance, prior month balance, and the calculated difference using balance at date and net amount from ledger entries. this layout helps identify month-over-month changes and trends. Useful for variance analysis, monitoring short-term financial movements, and supporting management decisions based on recent performance comparisons.', MaxLength = 500;
        CurrentMonthBalanceVPriorMonthInternalDescriptionLbl: Label 'Three-column layout showing Current Month Balance, Prior Month Balance, and Difference (Current - Prior). Displays month-end net amounts and calculates change; useful for month-over-month balance comparisons, reconciliation, and anomaly detection.', MaxLength = 500;
        CurrentMonthBalanceVSameMonthPriorYearInternalDescriptionLbl: Label 'Three-column layout showing current month balance, same month prior year balance, and the calculated difference using balance at date and net amount from ledger entries. This layout enables year-over-year comparisons to identify seasonal trends and performance shifts. Useful for variance analysis, strategic planning, and evaluating financial consistency across fiscal periods.', MaxLength = 500;
        CurrentMonthNetChangeInternalDescriptionLbl: Label 'Single-column layout showing the current month''s net change using net change and net amount from ledger entries. This layout provides insight into income statement activity for the period. Useful for tracking monthly performance, analyzing revenue and expense fluctuations, and supporting short-term financial decision-making with accurate and timely data.', MaxLength = 500;
        CurrentMonthNetChangeBudgetInternalDescriptionLbl: Label 'Thirteen-column layout showing monthly budgeted net changes for all 12 months plus a total column using formulas and budget entries. This structure supports comprehensive budget tracking and trend analysis across the fiscal year. Useful for monitoring planned income statement activity, evaluating budget adherence, and supporting financial planning and forecasting processes.', MaxLength = 500;
        CurrentMonthNetChangeVPriorMonthInternalDescriptionLbl: Label 'Three-column layout showing current month net change, prior month net change, and the calculated difference using net change and net amount from ledger entries. This layout helps identify short-term trends and performance shifts. Useful for variance analysis, monitoring income statement movements, and supporting management decisions based on recent financial activity comparisons.', MaxLength = 500;
        CurrentMonthNetChangeVSameMonthPriorYearInternalDescriptionLbl: Label 'Three-column layout showing current month net change, same month prior year net change, and the calculated difference using net change and net amount from ledger entries. This layout enables year-over-year comparisons to identify seasonal trends and performance changes. Useful for variance analysis, strategic planning, and evaluating financial consistency across fiscal periods.', MaxLength = 500;
        CurrentMonthVPriorMonthCYInternalDescriptionLbl: Label 'Seven-column layout showing current month and prior month net changes with calculated difference for the current year, plus same month prior year comparison and its difference using net change and formulas. Useful for analyzing month-over-month and year-over-year income statement trends, identifying performance shifts, and supporting variance analysis for management reporting.', MaxLength = 500;
        CurrentMonthVBudgetYearToDateInternalDescriptionLbl: Label 'Ten-column layout showing current month actual and budget amounts with variance, year-to-date actual and budget with variance, plus total budget and remaining budget using ledger and budget entries with formulas. Useful for monitoring actual vs budget performance, tracking cumulative results, and managing budget utilization throughout the fiscal year for better financial control.', MaxLength = 500;
        ActualBudgetComparisonInternalDescriptionLbl: Label 'Four-column layout comparing actual net change, budgeted amounts, and variance using formulas for difference and percentage. Positive and negative variances are clearly calculated to highlight performance gaps. Useful for monitoring budget adherence, analyzing deviations, and evaluating financial results against planned targets in management reports for better decision-making.', MaxLength = 500;
        BalanceOnlyInternalDescriptionLbl: Label 'Single-column layout showing the net balance of general ledger entries as of a specific date using balance at date and net amount. This layout provides a clear snapshot of financial position at a point in time. Useful for balance sheet reporting, validating account balances, and supporting period-end reviews where accurate figures are critical for compliance and financial analysis.', MaxLength = 500;
        BudgetAnalysisInternalDescriptionLbl: Label 'Four-column layout showing actual net change, budgeted amounts, variance percentage, and prior-year net change using ledger and budget entries with a formula for variance. This layout provides a comprehensive view of performance against budget and historical trends. Useful for evaluating budget accuracy, analyzing year-over-year changes, and identifying variances for financial planning.', MaxLength = 500;
        CashFlowComparisonInternalDescriptionLbl: Label 'Three-column layout showing net change for the current month, balance up to date, and entire fiscal year totals using ledger entry amounts. This structure supports quick comparisons between monthly, cumulative, and annual figures. Useful for trend analysis, identifying performance patterns, and providing a complete view of financial activity for management reporting purposes.', MaxLength = 500;
        DefaultLayoutInternalDescriptionLbl: Label 'Four-column layout displaying net change and balance at date, split into debit and credit amounts using ledger entries. Positive values appear in debit columns, while negative values show in credit columns for clear interpretation. This layout is useful for detailed financial reporting, analyzing account movements, and supporting balance sheet and trial balance reconciliation by providing transparent debit-credit segregation across periods.', MaxLength = 500;
        KeyCashFlowRatioInternalDescriptionLbl: Label 'Single-column layout displaying a key financial figure as of a specific date using balance at date and net amount from ledger entries. This layout provides a clear snapshot of account balances at a point in time, ensuring accurate representation of financial position. Useful for balance sheet reporting, validating period-end figures, and supporting management decisions that require precise and timely data for compliance and performance analysis.', MaxLength = 500;
        PeriodsDefinitionInternalDescriptionLbl: Label 'Three-column layout displaying net changes for the current period and two preceding periods using net change and net amount from ledger entries. This structure provides a quick view of short-term financial performance, enabling trend analysis across consecutive periods. Useful for mini charts, dashboards, and reports that highlight recent activity, helping management monitor fluctuations and make timely decisions based on current and prior period comparisons.', MaxLength = 500;
}
