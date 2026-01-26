// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;
using Microsoft.Finance.FinancialReports;

codeunit 10895 "Create Column Layout FR"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        InsertColumnLayoutName();
        ContosoAccountSchedule.InsertColumnLayout(ProfitLossAccount(), 10000, '1', BalanceNLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(ProfitLossAccount(), 20000, '2', BalanceN1Lbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);

        UpdateColumnLayout(ProfitLossAccount(), 20000);
    end;

    procedure ProfitLossAccount(): Code[10]
    begin
        exit(ProfitAccountTok);
    end;

    local procedure InsertColumnLayoutName()
    var
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.InsertColumnLayoutName(ProfitLossAccount(), ProfitLossAccountLbl);
    end;

    local procedure UpdateColumnLayout(ColumnLayoutName: Code[20]; LineNo: Integer)
    var
        ColumnLayout: Record "Column Layout";
    begin
        ColumnLayout.Get(ColumnLayoutName, LineNo);
        Evaluate(ColumnLayout."Comparison Date Formula", '<-1Y>');
        ColumnLayout.Validate("Comparison Date Formula");
        ColumnLayout.Modify(true);
    end;

    var
        ProfitAccountTok: Label 'PROFIT', MaxLength = 10, Locked = true;
        ProfitLossAccountLbl: Label 'Prof. & Loss Acc.', MaxLength = 80;
        BalanceNLbl: Label 'Balance N', MaxLength = 30;
        BalanceN1Lbl: Label 'Balance N-1', MaxLength = 30;
}
