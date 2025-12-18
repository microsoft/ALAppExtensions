// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 5223 "Create Acc. Schedule Name"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateAnalysisView: Codeunit "Create Analysis View";
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.InsertAccScheduleName(AccountCategoriesOverview(), AccountCategoriesOverviewLbl, '', AccountCategoriesOverviewInternalDescriptionLbl);
        ContosoAccountSchedule.InsertAccScheduleName(CapitalStructure(), CapitalStructureLbl, '', CapitalStructureInternalDescriptionLbl);
        ContosoAccountSchedule.InsertAccScheduleName(CashFlowCalculation(), CashFlowCalculationLbl, '', CashFlowCalculationInternalDescriptionLbl);
        ContosoAccountSchedule.InsertAccScheduleName(Revenues(), RevenuesLbl, CreateAnalysisView.SalesRevenue(), RevenuesInternalDescriptionLbl);
        ContosoAccountSchedule.InsertAccScheduleName(BalanceSheetDetailed(), BalanceSheetDetailedLbl, '', BalanceSheetDetailedInternalDescriptionLbl);
        ContosoAccountSchedule.InsertAccScheduleName(BalanceSheetSummarized(), BalanceSheetSummarizedLbl, '', BalanceSheetSummarizedInternalDescriptionLbl);
        ContosoAccountSchedule.InsertAccScheduleName(IncomeStatementDetailed(), IncomeStatementDetailedLbl, '', IncomeStatementDetailedInternalDescriptionLbl);
        ContosoAccountSchedule.InsertAccScheduleName(IncomeStatementSummarized(), IncomeStatementSummarizedLbl, '', IncomeStatementSummarizedInternalDescriptionLbl);
        ContosoAccountSchedule.InsertAccScheduleName(TrialBalance(), TrialBalanceLbl, '', TrialBalanceInternalDescriptionLbl);
    end;

    internal procedure CreateSetupAccScheduleName()
    var
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.InsertAccScheduleName(CashCycle(), CashCycleDataLbl, '', CashCycleDataInternalDescriptionLbl);
        ContosoAccountSchedule.InsertAccScheduleName(CashFlow(), CashFlowDataLbl, '', CashFlowDataInternalDescriptionLbl);
        ContosoAccountSchedule.InsertAccScheduleName(IncomeExpense(), IncomeExpenseDataLbl, '', IncomeExpenseDataInternalDescriptionLbl);
        ContosoAccountSchedule.InsertAccScheduleName(ReducedTrialBalance(), ReducedTrialBalanceDataLbl, '', ReducedTrialBalanceDataInternalDescriptionLbl);
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
        CashCycleDataInternalDescriptionLbl: Label 'Eight-row layout calculating key metrics for cash cycle analysis, including total revenue, receivables, payables, and inventory balances. This layout incorporates formulas to derive days sales outstanding, days payment outstanding, days sales of inventory, and overall cash cycle in days. Useful for assessing working capital efficiency, optimizing payment terms, and improving liquidity management.', MaxLength = 500;
        CashFlowDataInternalDescriptionLbl: Label 'Four-row layout summarizing cash flow components with posting account ranges for receivables, payables, and liquid funds, plus a formula to calculate total cash flow. This layout uses balance at date with net amount for point-in-time financial positions, providing a clear snapshot of liquidity status. Useful for visual cash flow reporting, short-term financial planning, and monitoring available funds against obligations.', MaxLength = 500;
        IncomeExpenseDataInternalDescriptionLbl: Label 'Eight-row layout detailing income and expense components with posting account ranges for revenue, goods sold, external costs, personnel costs, depreciation, and other expenses. This layout includes formulas to calculate total expenditure and earnings before interest, using Net Change for accurate period performance tracking. Useful for profitability analysis, expense monitoring, and generating visual income-versus-cost comparisons for management reporting.', MaxLength = 500;
        ReducedTrialBalanceDataInternalDescriptionLbl: Label 'Nine-row layout summarizing key trial balance metrics with posting account ranges for revenue, cost, operating expenses, and other expenses. This layout includes formulas for gross margin, operating margin, and their respective percentages, as well as income before interest and tax, all based on net change for period performance. Useful for quick profitability checks, margin analysis, and providing condensed financial insights for dashboards or info parts.', MaxLength = 500;
        RevenuesLbl: Label 'Revenues', MaxLength = 80;
        AccountCategoriesOverviewInternalDescriptionLbl: Label 'Twelve-row layout combining balance sheet and income statement sections with structured account category grouping and calculated formulas. This layout organizes assets, liabilities, equity, income, cost of goods sold, and expenses, and calculates key totals such as net income to provide a comprehensive financial overview. Useful for consolidated reporting, comparative analysis, and delivering actionable insights across accounting periods.', MaxLength = 500;
        CapitalStructureInternalDescriptionLbl: Label 'Sixteen-row layout analyzing liquidity and short-term obligations through structured grouping of current assets and liabilities. This layout includes detailed rows for liquid assets, receivables, inventory, WIP, and short-term liabilities, with formulas calculating totals and net positions. Useful for assessing working capital, liquidity ratios, and short-term financial health in management and compliance reporting.', MaxLength = 500;
        BalanceSheetDetailedInternalDescriptionLbl: Label 'A detailed layout with expanded sections for current assets, long-term assets, liabilities, and equity, including granular account ranges for receivables, inventory, prepaid expenses, and fixed assets. This layout incorporates formulas for subtotals and reconciliation checks to ensure accuracy and completeness. Useful for in-depth financial analysis, audit support, and preparing comprehensive management reports.', MaxLength = 500;
        BalanceSheetSummarizedInternalDescriptionLbl: Label 'Eight-row layout presenting a summarized balance sheet with posting account ranges for assets, liabilities, and equity. This layout includes calculated totals for Assets and Liabilities & Equity, plus check-figure formulas to verify balance, and uses balance at date with net amount for point-in-time figures and clear bold totals. Useful for executive snapshots, period-end validation, and quick reconciliation.', MaxLength = 500;
        CashFlowCalculationInternalDescriptionLbl: Label 'Twenty-row layout designed for cash flow analysis, grouping cash receipts and disbursements by categories such as receivables, payables, open orders, investments, and miscellaneous transactions. This layout includes formulas for totals, surplus, and overall cash flow, using net change for dynamic period movements. Useful for liquidity planning, forecasting, and monitoring operational and investment cash positions.', MaxLength = 500;
        IncomeStatementDetailedInternalDescriptionLbl: Label 'A detailed multi-section layout for a full income statement, including revenue categories, cost of goods, and operating expenses with posting account ranges for materials, labor, overhead, and expense types. This layout incorporates formulas for gross margin, operating totals, and net income or loss, using net change for accurate period performance. Useful for financial statement preparation, profitability analysis, and management reporting with detailed account-level visibility.', MaxLength = 500;
        IncomeStatementSummarizedInternalDescriptionLbl: Label 'Ten-row layout summarizing an Income Statement with posting account ranges for revenue, cost of goods, and operating expenses. Includes formulas for gross margin, gross margin percentage, and net income or loss, using net change for period-based performance tracking. Provides a simplified structure for quick financial review while maintaining key profitability indicators. Useful for high-level reporting, management summaries, and streamlined financial analysis.', MaxLength = 500;
        RevenuesInternalDescriptionLbl: Label 'Fifteen-row layout focused on revenue categorization, including product sales, services, job-related income, and other income streams, with totals for retail and area-specific revenues. This layout consolidates multiple revenue sources into clear groupings and calculates overall totals for comprehensive reporting. Useful for revenue analysis, performance tracking, and preparing detailed income breakdowns.', MaxLength = 500;
        TrialBalanceInternalDescriptionLbl: Label 'A comprehensive layout presenting all general ledger accounts with their debit and credit balances in a structured sequence. This layout provides a complete view of account activity for the period, ensuring that total debits equal total credits for accuracy. Useful for validating ledger integrity, preparing financial statements, and supporting audit and compliance processes.', MaxLength = 500;
}
