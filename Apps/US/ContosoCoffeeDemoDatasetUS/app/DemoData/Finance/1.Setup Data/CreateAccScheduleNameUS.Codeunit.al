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
        CreateAnalysisView: Codeunit "Create Analysis View";
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.InsertAccScheduleName(BalanceSheet(), BalanceSheetLbl, '');
        ContosoAccountSchedule.InsertAccScheduleName(BalanceSheetAudit(), BalanceSheetAuditLbl, '');
        ContosoAccountSchedule.InsertAccScheduleName(IncomeStatement(), IncomeStatementLbl, '');
        ContosoAccountSchedule.InsertAccScheduleName(IncomeStatementAudit(), IncomeStatementAuditLbl, '');
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
}
