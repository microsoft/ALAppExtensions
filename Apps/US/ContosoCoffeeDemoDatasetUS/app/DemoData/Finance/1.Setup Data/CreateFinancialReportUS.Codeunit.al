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
        ContosoAccountSchedule.InsertFinancialReport(BalanceSheet(), BalanceSheetLbl, BalanceSheet(), ColumnLayoutName.BalanceOnly());
        ContosoAccountSchedule.InsertFinancialReport(BalanceSheetAudit(), BalanceSheetAuditLbl, BalanceSheetAudit(), ColumnLayoutName.BalanceSheetTrend());
        ContosoAccountSchedule.InsertFinancialReport(IncomeStatement(), IncomeStatementLbl, IncomeStatement(), NetChangeTok);
        ContosoAccountSchedule.InsertFinancialReport(IncomeStatementAudit(), IncomeStatementAuditLbl, IncomeStatementAudit(), ColumnLayoutNameUS.PeriodandYeartoDate());
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
        BalanceSheetTok: Label 'BS', MaxLength = 10, Comment = 'Balance Sheet';
        BalanceSheetAuditTok: Label 'BS AUDIT', MaxLength = 10, Comment = 'Balance Sheet';
        IncomeStatementTok: Label 'IS', MaxLength = 10, Comment = 'Income Statement';
        IncomeStatementAuditTok: Label 'IS AUDIT', MaxLength = 10, Comment = 'Income Statement Audit Lead Schedule';
        NetChangeTok: Label 'M-NETCHANG', MaxLength = 10, Comment = 'Net Change';
        BalanceSheetLbl: Label 'Balance Sheet', MaxLength = 80;
        BalanceSheetAuditLbl: Label 'Balance Sheet Audit Lead Schedule', MaxLength = 80;
        IncomeStatementLbl: Label 'Income Statement', MaxLength = 80;
        IncomeStatementAuditLbl: Label 'Income Statement Audit Lead Schedule', MaxLength = 80;
}