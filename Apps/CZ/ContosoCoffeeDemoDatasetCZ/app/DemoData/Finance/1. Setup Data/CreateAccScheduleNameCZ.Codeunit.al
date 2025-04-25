// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 31295 "Create Acc. Schedule Name CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateSetupAccScheduleName();
    end;

    internal procedure CreateSetupAccScheduleName()
    var
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.InsertAccScheduleName(BalanceSheet(), BalanceSheetLbl, '');
        ContosoAccountSchedule.InsertAccScheduleName(IncomeStatement(), IncomeStatementLbl, '');
    end;

    procedure BalanceSheet(): Code[10]
    begin
        exit(CreateFinancialReportCZ.BalanceSheet());
    end;

    procedure IncomeStatement(): Code[10]
    begin
        exit(CreateFinancialReportCZ.IncomeStatement());
    end;

    var
        CreateFinancialReportCZ: Codeunit "Create Financial Report CZ";
        BalanceSheetLbl: Label 'Balance Sheet', MaxLength = 80;
        IncomeStatementLbl: Label 'Income Statement', MaxLength = 80;
}
