// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

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
        ContosoAccountSchedule.InsertFinancialReport(AccountCategoriesOverview(), AccountCategoriesOverviewLbl, AccountScheduleName.AccountCategoriesOverview(), ColumnLayoutName.PeriodsDefinition(), AccCatInternalDescriptionLbl);
        ContosoAccountSchedule.InsertFinancialReport(CapitalStructure(), CapitalStructureLbl, AccountScheduleName.CapitalStructure(), ColumnLayoutName.BalanceOnly(), CapitalStructureLblInternalDescriptionLbl);
        ContosoAccountSchedule.InsertFinancialReport(CalculationOfCashFlow(), CalculationOfCashFlowLbl, AccountScheduleName.CashFlowCalculation(), ColumnLayoutName.CashFlowComparison(), CalculationOfCashFlowInternalDescriptionLbl);
        ContosoAccountSchedule.InsertFinancialReport(Revenues(), RevenuesLbl, AccountScheduleName.Revenues(), ColumnLayoutName.BudgetAnalysis(), RevenuesInternalDescriptionLbl);

        ContosoAccountSchedule.InsertFinancialReport(BalanceSheetDetailed(), BalanceSheetDetailedLbl, AccountScheduleName.BalanceSheetDetailed(), ColumnLayoutName.BalanceSheetTrend(), BalanceSheetDetailedInternalDescriptionLbl);
        ContosoAccountSchedule.InsertFinancialReport(BalanceSheetSummarized(), BalanceSheetSummarizedLbl, AccountScheduleName.BalanceSheetSummarized(), ColumnLayoutName.BalanceSheetTrend(), BalanceSheetSummarizedInternalDescriptionLbl);
        ContosoAccountSchedule.InsertFinancialReport(IncomeStatementDetailed(), IncomeStatementDetailedLbl, AccountScheduleName.IncomeStatementDetailed(), ColumnLayoutName.IncomeStatementTrend(), IncomeStatementDetailedInternalDescriptionLbl);
        ContosoAccountSchedule.InsertFinancialReport(IncomeStatementSummarized(), IncomeStatementSummarizedLbl, AccountScheduleName.IncomeStatementSummarized(), ColumnLayoutName.IncomeStatementTrend(), IncomeStatementSummarizedInternalDescriptionLbl);
        ContosoAccountSchedule.InsertFinancialReport(TrialBalance(), TrialBalanceLbl, AccountScheduleName.TrialBalance(), ColumnLayoutName.BeginningBalanceDebitsCreditsEndingBalance(), TrialBalanceInternalDescriptionLbl);
    end;

    internal procedure CreateSetupFinancialReport()
    var
        ColumnLayoutName: Codeunit "Create Column Layout Name";
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
        AccountScheduleName: Codeunit "Create Acc. Schedule Name";
    begin
        ContosoAccountSchedule.InsertFinancialReport(DataForCashCycleChart(), DataForCashCycleChartLbl, AccountScheduleName.CashCycle(), ColumnLayoutName.PeriodsDefinition(), CashCycleInternalDescriptionLbl);
        ContosoAccountSchedule.InsertFinancialReport(DataForCashFlowChart(), DataForCashFlowChartLbl, AccountScheduleName.CashFlow(), ColumnLayoutName.PeriodsDefinition(), CashFlowInternalDescriptionLbl);
        ContosoAccountSchedule.InsertFinancialReport(DataForIncomeExpenseChart(), DataForIncomeExpenseChartLbl, AccountScheduleName.IncomeExpense(), ColumnLayoutName.PeriodsDefinition(), IncExpInternalDescriptionLbl);
        ContosoAccountSchedule.InsertFinancialReport(DataForReducedTrialBalanceInfoPart(), DataForReducedTrialBalanceInfoPartLbl, AccountScheduleName.ReducedTrialBalance(), ColumnLayoutName.PeriodsDefinition(), ReducedTrialBalInternalDescriptionLbl);
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
        AccCatInternalDescriptionLbl: Label 'Organizes balance sheet and income statement categories into structured rows with calculated totals like net income, combined with columns showing net changes for the current and two prior periods. Useful for delivering consolidated financial overviews, short-term trend analysis, dashboards, and comparative reporting to help management monitor fluctuations and make timely, informed decisions.', MaxLength = 500;
        AccountCategoriesOverviewInternalLbl: Label '', MaxLength = 500;
        AccountCategoriesOverviewLbl: Label 'Account Categories overview', MaxLength = 80;
        AccountCategoriesOverviewTok: Label 'ACC-CAT', MaxLength = 10;
        BalanceSheetDetailedInternalDescriptionLbl: Label 'Provides a detailed balance sheet layout with expanded sections for current and long-term assets, liabilities, and equity, including granular account ranges and reconciliation formulas for accuracy. Incorporates twelve columns showing month-end balances for the current fiscal year to reveal trends and seasonal changes. Useful for in-depth financial analysis, audit support, and preparing comprehensive management and compliance reports.', MaxLength = 500;
        BalanceSheetDetailedLbl: Label 'Balance Sheet Detailed', MaxLength = 80;
        BalanceSheetDetailedTok: Label 'BS DET', MaxLength = 10, Comment = 'Balance Sheet Detailed';
        BalanceSheetInternalDescriptionLbl: Label 'Presents a complete balance sheet structure with grouped sections for assets, liabilities, and equity, including formulas for totals like total assets and total liabilities. Shows data with a single-column balance snapshot as of a specific date for accurate figures. Useful for reporting financial position, preparing compliance statements, validating balances, and supporting period-end reconciliations and reviews.', MaxLength = 500;
        BalanceSheetSummarizedInternalDescriptionLbl: Label 'Provides a concise balance sheet layout with a row layout summarizing assets, liabilities, and equity, including totals and check-figure formulas for accuracy. Includes twelve columns showing month-end balances for the current fiscal year to highlight trends and seasonal changes. Useful for executive snapshots, quick reconciliation, period-end validation, and monitoring monthly financial position shifts for reporting and compliance.', MaxLength = 500;
        BalanceSheetSummarizedLbl: Label 'Balance Sheet Summarized', MaxLength = 80;
        BalanceSheetSummarizedTok: Label 'BS SUM', MaxLength = 10, Comment = 'Balance Sheet Summarized';
        CalculationOfCashFlowInternalDescriptionLbl: Label 'Analyzes cash flow analysis, grouping receipts and disbursements by categories like receivables, payables, open orders, investments, and miscellaneous transactions, with formulas for totals, surplus, and overall cash flow using net change for dynamic movements. Includes three columns comparing monthly, cumulative, and annual figures. Useful for liquidity planning, forecasting, trend analysis, and monitoring operational and investment cash positions.', MaxLength = 500;
        CalculationOfCashFlowLbl: Label 'Calculation Of Cash Flow', MaxLength = 80;
        CalculationOfCashFlowTok: Label 'CASHFLOW', MaxLength = 10;
        CapitalStructureLbl: Label 'Capital Structure', MaxLength = 80;
        CapitalStructureLblInternalDescriptionLbl: Label 'Analyzes liquidity and short-term obligations with a row layout grouping current assets, receivables, inventory, WIP, and short-term liabilities, calculating totals and net positions. Paired with a single-column balance snapshot as of a specific date. Useful for assessing working capital, liquidity ratios, and short-term financial health, supporting compliance, period-end reviews, and management reporting.', MaxLength = 500;
        CapitalStructureTok: Label 'ANALYSIS', MaxLength = 10;
        CashCycleInternalDescriptionLbl: Label 'Calculates key cash cycle metrics, including revenue, receivables, payables, and inventory balances, with formulas for DSO, DPO, DSI, and overall cash cycle in days. Includes three columns showing net changes for the current and two prior periods to enable short-term trend analysis. Useful for assessing working capital efficiency, optimizing payment terms, improving liquidity management, and supporting dashboards and mini charts. Internal report used for providing data for the Cash Cycle chart.', MaxLength = 500;
        CashFlowInternalDescriptionLbl: Label 'Summarizes cash flow components, including receivables, payables, and liquid funds, with a formula to calculate total cash flow using balance at date for point-in-time positions. Incorporates three columns showing net changes for the current and two prior periods to enable short-term trend analysis. Useful for visual cash flow reporting, short-term financial planning, and monitoring available funds against obligations. Internal report used for providing data for the Cash Flow chart.', MaxLength = 500;
        DataForCashCycleChartLbl: Label 'Data for Cash Cycle Chart', MaxLength = 80;
        DataForCashCycleChartTok: Label 'I_CACYCLE', MaxLength = 10;
        DataForCashFlowChartLbl: Label 'Data for Cash Flow Chart', MaxLength = 80;
        DataForCashFlowChartTok: Label 'I_CASHFLOW', MaxLength = 10;
        DataForIncomeExpenseChartLbl: Label 'Data for Income & Expense Chart', MaxLength = 80;
        DataForIncomeExpenseChartTok: Label 'I_INCEXP', MaxLength = 10;
        DataForReducedTrialBalanceInfoPartLbl: Label 'Data for Reduced Trial Balance Info Part', MaxLength = 80;
        DataForReducedTrialBalanceInfoPartTok: Label 'I_MINTRIAL', MaxLength = 10;
        IncExpInternalDescriptionLbl: Label 'Analyzes income and expense components, including revenue, goods sold, external costs, personnel costs, depreciation, and other expenses, with formulas for total expenditure and earnings before interest using net change for accurate period tracking. Incorporates three columns showing net changes for the current and two prior periods. Useful for profitability analysis, expense monitoring, and management reporting. Internal report used for providing data for the Income & Expense chart.', MaxLength = 500;
        IncomeStatementDetailedInternalDescriptionLbl: Label 'Provides a detailed multi-section income statement layout, covering revenue categories, cost of goods, and operating expenses with account ranges for materials, labor, overhead, and expense types, plus formulas for gross margin, operating totals, and net income or loss using. Includes thirteen columns showing monthly net changes across the fiscal year with a total column. Useful for financial statement preparation, profitability analysis, trend monitoring, and management reporting.', MaxLength = 500;
        IncomeStatementDetailedLbl: Label 'Income Statement Detailed', MaxLength = 80;
        IncomeStatementDetailedTok: Label 'IS DET', MaxLength = 10, Comment = 'Income Statement Detailed';
        IncomeStatementSummarizedInternalDescriptionLbl: Label 'Summarizes key income statement components, including revenue, cost of goods, and operating expenses, with formulas for gross margin, margin percentage, and net income or loss. Includes thirteen columns showing monthly net changes across the fiscal year plus a total column for cumulative performance. Useful for high-level reporting, management summaries, streamlined financial analysis, and monitoring profitability trends.', MaxLength = 500;
        IncomeStatementSummarizedLbl: Label 'Income Statement Summarized', MaxLength = 80;
        IncomeStatementSummarizedTok: Label 'IS SUM', MaxLength = 10, Comment = 'Income Statement Summarized';
        ReducedTrialBalInternalDescriptionLbl: Label 'Summarizes nine key trial balance metrics in a structured layout, covering revenue, cost, operating expenses, and other expenses, with formulas for gross margin, operating margin, their percentages, and income before interest and tax. Includes three columns showing net changes for the current and two prior periods. Useful for quick profitability checks, margin analysis, and delivering condensed financial insights. Internal report used for providing data for the Reduced Trial Balance info part.', MaxLength = 500;
        RevenuesInternalDescriptionLbl: Label 'Categorizes revenue streams, including product sales, services, job-related income, and other income sources, with totals for retail and area-specific revenues to consolidate reporting. Shows actual net change, budgeted amounts, variance percentage, and prior-year figures for performance comparison. Useful for revenue analysis, tracking budget accuracy, identifying variances, and evaluating year-over-year trends for financial planning.', MaxLength = 500;
        RevenuesLbl: Label 'Revenues', MaxLength = 80;
        RevenuesTok: Label 'REVENUE', MaxLength = 10;
        TrialBalanceInternalDescriptionLbl: Label 'Displays a comprehensive trial balance layout listing all G/L accounts with debit and credit balances, ensuring total debits equal total credits for accuracy. Shows beginning balance, debit and credit movements, and calculated ending balance for reconciliation. Useful for validating ledger integrity, preparing financial statements, reconciling account activity, and supporting audit and compliance processes.', MaxLength = 500;
        TrialBalanceLbl: Label 'Trial Balance', MaxLength = 80;
        TrialBalanceTok: Label 'TB', MaxLength = 10, Comment = 'Trial Balance';
}
