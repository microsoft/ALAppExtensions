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
        BalanceSheetInternalDescriptionLbl: Label 'Twelve-column layout showing month-end balances (Jan-Dec) using Balance at Date net amounts. Useful for balance-sheet monthly trend analysis, spotting seasonal patterns, monitoring cash and working capital, and reviewing month-to-month variances.', MaxLength = 250;
        IncomeStatementInternalDescriptionLbl: Label 'Thirteen-column layout showing monthly net-change amounts for the current fiscal year with a formula total aggregating the 12 months. Useful for trending monthly performance across the fiscal year and reporting the annual net-change total.', MaxLength = 250;
        TrialBalanceInternalDescriptionLbl: Label 'Four-column layout showing beginning balance, debits, credits, and a formula ending balance (1+2-3). Useful for trial-balance reconciliation, tracking period activity, and validating period-end balances.', MaxLength = 250;
        CurrentMonthBalanceInternalDescriptionLbl: Label 'Single-column layout showing Current Month Balance using Balance at Date net amount. Useful for presenting the period-end closing balance on the balance sheet, quick month-end review and reconciliation.', MaxLength = 250;
        CurrentMonthBalanceVPriorMonthInternalDescriptionLbl: Label 'Three-column layout showing Current Month Balance, Prior Month Balance, and Difference (Current - Prior). Displays month-end net amounts and calculates change; useful for month-over-month balance comparisons, reconciliation, and anomaly detection.', MaxLength = 250;
        CurrentMonthBalanceVSameMonthPriorYearInternalDescriptionLbl: Label 'Three-column layout showing Current Month Balance, Same Month Prior Year Balance, and Difference (Current-Prior). Calculates month-end net amounts and change; useful for year-over-year balance comparisons, trend spotting, and variance analysis.', MaxLength = 250;
        CurrentMonthNetChangeInternalDescriptionLbl: Label 'Single-column layout showing Current Month Net Change using Net Change ledger net amounts. Useful for presenting monthly income statement movement, quick profit or loss review, and monitoring month-to-month operating performance.', MaxLength = 250;
        CurrentMonthNetChangeBudgetInternalDescriptionLbl: Label 'Thirteen-column layout showing monthly budgeted net changes and a calculated year total using budget entries. Useful for tracking monthly budget performance and aggregating annual totals in financial statements.', MaxLength = 250;
        CurrentMonthNetChangeVPriorMonthInternalDescriptionLbl: Label 'Three-column layout showing current-month and prior-month net changes with a formula column for the difference. Useful for month-over-month variance analysis and short-term performance reviews.', MaxLength = 250;
        CurrentMonthNetChangeVSameMonthPriorYearInternalDescriptionLbl: Label 'Three-column layout showing current-month and same-month prior-year net changes with a formula column for the difference. Useful for year-over-year variance analysis and comparing seasonal performance.', MaxLength = 250;
        CurrentMonthVPriorMonthCYInternalDescriptionLbl: Label 'Seven-column layout: CY current-month and prior-month net change plus formula variance, and PY current-month vs. same-month prior-year plus formula variance. Useful for month-over-month and year-over-year analysis.', MaxLength = 250;
        CurrentMonthVBudgetYearToDateInternalDescriptionLbl: Label 'Ten-column layout comparing current-month actual vs. budget and YTD actual vs. budget with variance columns, plus total planned budget and calculated remaining budget. Useful for monitoring monthly and YTD budget performance.', MaxLength = 250;
        ActualBudgetComparisonInternalDescriptionLbl: Label 'Four-column layout showing Net Change (Actual), Budget Net Change, Variance (A-B), and Percent (A/Bx100). Calculates ledger and budget amounts plus formulas; useful for actual vs. budget comparisons, variance and percentage analysis.', MaxLength = 250;
        BalanceOnlyInternalDescriptionLbl: Label 'Single-column balance-at-date showing ledger net amount. Useful for point-in-time account balances, statement of financial position, reconciliations, cash position snapshots, and concise balance reporting.', MaxLength = 250;
        BudgetAnalysisInternalDescriptionLbl: Label 'Three-column layout showing Net Change (actual), Budget Net Change, and Variance% calculated as 100*(N/B-1). Compares actuals to budget and highlights percent variance for budget performance, analysis, and forecasting.', MaxLength = 250;
        CashFlowComparisonInternalDescriptionLbl: Label 'Three-column layout showing current-period net change, balance-at-date year-to-date, and entire fiscal-year totals using ledger net amounts. Useful for month vs. YTD vs. full-year comparisons and variance/trend analysis.', MaxLength = 250;
        DefaultLayoutInternalDescriptionLbl: Label 'Four-column layout showing net change and balance-at-date split into debit and credit columns using ledger net amounts with conditional display for positive/negative values. Useful for clear debit/credit breakdowns and period balances.', MaxLength = 250;
        KeyCashFlowRatioInternalDescriptionLbl: Label 'Single-column layout showing a balance-at-date key figure using ledger net amounts. Useful for point-in-time cash position, liquidity and cash-flow ratio calculations, and summarizing cash-related balances in financial reports.', MaxLength = 250;
        PeriodsDefinitionInternalDescriptionLbl: Label 'Three-column layout showing net change for current period and two prior periods. Useful for mini charts and small trend charts to display short-term trends, quick period-over-period comparisons, and compact visual performance cues.', MaxLength = 250;
}
