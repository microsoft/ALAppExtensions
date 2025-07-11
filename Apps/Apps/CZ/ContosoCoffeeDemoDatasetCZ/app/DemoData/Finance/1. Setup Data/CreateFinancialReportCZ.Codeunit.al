// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 31297 "Create Financial Report CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateSetupFinancialReport();
    end;

    internal procedure CreateSetupFinancialReport()
    var
        ColumnLayoutNameCZ: Codeunit "Create Column Layout Name CZ";
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
        AccountScheduleNameCZ: Codeunit "Create Acc. Schedule Name CZ";
    begin
        ContosoAccountSchedule.InsertFinancialReport(BalanceSheet(), BalanceSheetLbl, AccountScheduleNameCZ.BalanceSheet(), ColumnLayoutNameCZ.BalanceSheet());
        ContosoAccountSchedule.InsertFinancialReport(IncomeStatement(), IncomeStatementLbl, AccountScheduleNameCZ.IncomeStatement(), ColumnLayoutNameCZ.IncomeStatement());
    end;

    procedure BalanceSheet(): Code[10]
    begin
        exit(BALANCESHTTok);
    end;

    procedure IncomeStatement(): Code[10]
    begin
        exit(INCOMESTMTTok);
    end;

    var
        BALANCESHTTok: Label 'BALANCESHT', MaxLength = 10;
        INCOMESTMTTok: Label 'INCOMESTMT', MaxLength = 10;
        BalanceSheetLbl: Label 'Balance Sheet', MaxLength = 80;
        IncomeStatementLbl: Label 'Income Statement', MaxLength = 80;
}
