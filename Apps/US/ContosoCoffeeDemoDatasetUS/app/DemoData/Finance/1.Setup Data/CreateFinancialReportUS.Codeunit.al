// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 11497 "Create Financial Report US"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ColumnLayoutName: Codeunit "Create Column Layout Name";
        ColumnLayoutNameUS: Codeunit "Create Column Layout Name US";
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.InsertFinancialReport(BalanceSheet(), BalanceSheetLbl, BalanceSheet(), ColumnLayoutName.BalanceOnly(), BalanceSheetInternalDescriptionLbl);
        ContosoAccountSchedule.InsertFinancialReport(BalanceSheetAudit(), BalanceSheetAuditLbl, BalanceSheetAudit(), ColumnLayoutName.BalanceSheetTrend(), BalanceSheetAuditInternalDescriptionLbl);
        ContosoAccountSchedule.InsertFinancialReport(IncomeStatement(), IncomeStatementLbl, IncomeStatement(), NetChangeTok, IncomeStatementInternalDescriptionLbl);
        ContosoAccountSchedule.InsertFinancialReport(IncomeStatementAudit(), IncomeStatementAuditLbl, IncomeStatementAudit(), ColumnLayoutNameUS.PeriodandYeartoDate(), IncomeStatementAuditInternalDescriptionLbl);
    end;

    procedure BalanceSheet(): Code[10]
    begin
        exit(BalanceSheetTok);
    end;

    procedure BalanceSheetAudit(): Code[10]
    begin
        exit(BalanceSheetAuditTok);
    end;

    procedure IncomeStatement(): Code[10]
    begin
        exit(IncomeStatementTok);
    end;

    procedure IncomeStatementAudit(): Code[10]
    begin
        exit(IncomeStatementAuditTok);
    end;

    var
        BalanceSheetAuditInternalDescriptionLbl: Label 'Provides a detailed audit-focused balance sheet layout with sections for cash, receivables, inventory, prepaid expenses, fixed assets, liabilities, and equity, including granular account-level rows and reconciliation formulas for accuracy. Incorporates twelve columns showing month-end balances for the current fiscal year to highlight trends and seasonal changes. Useful for audit preparation, variance analysis, compliance reviews, and monitoring monthly financial position shifts.', MaxLength = 500;
        BalanceSheetAuditLbl: Label 'Balance Sheet Audit Lead Schedule', MaxLength = 80;
        BalanceSheetAuditTok: Label 'BS AUDIT', MaxLength = 10, Comment = 'Balance Sheet';
        BalanceSheetInternalDescriptionLbl: Label 'Presents a complete balance sheet structure with grouped sections and subsections for assets, liabilities, and equity, including totals per section and formulas for total liabilities and equity, and check figure for accuracy. A single column shows a snapshot of the balance as of a specific date. Useful for reporting financial position, preparing compliance statements, validating balances, and supporting period-end reconciliations and reviews.', MaxLength = 500;
        BalanceSheetLbl: Label 'Balance Sheet', MaxLength = 80;
        BalanceSheetTok: Label 'BS', MaxLength = 10, Comment = 'Balance Sheet';
        IncomeStatementAuditInternalDescriptionLbl: Label 'Provides an audit-focused income statement layout with granular breakdowns, covering revenue streams, cost of goods, and operating expenses with account ranges for product, job, and service revenue, materials, labor, overhead, and detailed expense categories, plus formulas for gross margin, operating totals, and net income or loss. Displays two columns for current period and year-to-date figures. Useful for audit lead schedules, variance analysis, and financial statement verification.', MaxLength = 500;
        IncomeStatementAuditLbl: Label 'Income Statement Audit Lead Schedule', MaxLength = 80;
        IncomeStatementAuditTok: Label 'IS AUDIT', MaxLength = 10, Comment = 'Income Statement Audit Lead Schedule';
        IncomeStatementInternalDescriptionLbl: Label 'Provides a summarized income statement with sections for revenue, cost of goods, operating expenses, with subrows for account ranges related to product, job, and service revenue, materials, labor, overhead, and expenses, plus formulas for gross margin, operating totals, net income or loss, and check figure for accuracy. A single column shows net change for the selected period. Useful for profitability reporting, variance analysis, and accurate financial statement preparation.', MaxLength = 500;
        IncomeStatementLbl: Label 'Income Statement', MaxLength = 80;
        IncomeStatementTok: Label 'IS', MaxLength = 10, Comment = 'Income Statement';
        NetChangeTok: Label 'M-NETCHANG', MaxLength = 10, Comment = 'Net Change';
}