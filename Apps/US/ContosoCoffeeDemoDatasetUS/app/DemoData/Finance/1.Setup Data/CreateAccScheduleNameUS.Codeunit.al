// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 11492 "Create Acc. Schedule Name US"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.InsertAccScheduleName(BalanceSheet(), BalanceSheetLbl, '', BalanceSheetInternalDescriptionLbl);
        ContosoAccountSchedule.InsertAccScheduleName(BalanceSheetAudit(), BalanceSheetAuditLbl, '', BalanceSheetAuditInternalDescriptionLbl);
        ContosoAccountSchedule.InsertAccScheduleName(IncomeStatement(), IncomeStatementLbl, '', IncomeStatementInternalDescriptionLbl);
        ContosoAccountSchedule.InsertAccScheduleName(IncomeStatementAudit(), IncomeStatementAuditLbl, '', IncomeStatementAuditInternalDescriptionLbl);
    end;


    procedure BalanceSheet(): Code[10]
    begin
        exit(BalanceSheetTok);
    end;

    procedure BalanceSheetAudit(): Code[10]
    begin
        exit(BalanceSheetAuditTok);
    end;

    procedure BalanceSheetDetailed(): Code[10]
    begin
        exit(BalanceSheetDetailedTok);
    end;

    procedure BalanceSheetSummarized(): Code[10]
    begin
        exit(BalanceSheetSummarizedTok);
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
        BalanceSheetTok: Label 'BS', MaxLength = 10, Comment = 'Balance Sheet';
        BalanceSheetAuditTok: Label 'BS AUDIT', MaxLength = 10, Comment = 'Balance Sheet';
        BalanceSheetDetailedTok: Label 'BS DET', MaxLength = 10, Comment = 'Balance Sheet Audit Lead Schedule';
        BalanceSheetSummarizedTok: Label 'BS SUM', MaxLength = 10, Comment = 'Balance Sheet Summarized';
        IncomeStatementTok: Label 'IS', MaxLength = 10, Comment = 'Income Statement';
        IncomeStatementAuditTok: Label 'IS AUDIT', MaxLength = 10, Comment = 'Income Statement Audit Lead Schedule';
        BalanceSheetLbl: Label 'Balance Sheet', MaxLength = 80;
        BalanceSheetAuditLbl: Label 'Balance Sheet Audit Lead Schedule', MaxLength = 80;
        IncomeStatementLbl: Label 'Income Statement', MaxLength = 80;
        IncomeStatementAuditLbl: Label 'Income Statement Audit Lead Schedule', MaxLength = 80;
        BalanceSheetInternalDescriptionLbl: Label 'A comprehensive row layout presenting a full balance sheet structure with grouped sections for current assets, long-term assets, liabilities, and equity. This layout includes detailed account ranges and formulas to calculate totals such as total assets, total liabilities, and equity, ensuring alignment with accounting principles. Useful for financial position reporting, compliance statements, and period-end reconciliations.', MaxLength = 500;
        BalanceSheetAuditInternalDescriptionLbl: Label 'An audit-focused balance sheet row layout with highly detailed sections for cash, receivables, inventory, prepaid expenses, fixed assets, liabilities, and equity. This layout includes granular account-level rows and reconciliation formulas to validate totals and ensure accuracy across all components. Useful for audit preparation, variance analysis, and supporting detailed financial substantiation during compliance reviews.', MaxLength = 500;
        IncomeStatementInternalDescriptionLbl: Label 'A comprehensive multi-section row layout structuring a full income statement with detailed sections for revenue, cost of goods, operating expenses, and calculated margins. This layout includes posting account ranges for product, job, and service revenue, materials, labor, overhead, and expenses, plus formulas for gross margin, operating totals, and net income or loss. Useful for comprehensive profitability reporting, variance analysis, and financial statement preparation.', MaxLength = 500;
        IncomeStatementAuditInternalDescriptionLbl: Label 'An audit-focused row layout detailing a full income statement with granular breakdowns for revenue streams, cost of goods, and operating expenses. Includes posting account ranges for product, job, and service revenue, materials, labor, overhead, and detailed expense categories, plus formulas for gross margin, operating totals, and net income or loss. Useful for audit lead schedules, variance analysis, and supporting financial statement verification.', MaxLength = 500;
}