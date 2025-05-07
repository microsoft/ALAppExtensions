// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;
using Microsoft.Finance.FinancialReports;
using Microsoft.Foundation.Enums;

codeunit 31291 "Create Column Layout CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateColumnLayoutNameCZ: Codeunit "Create Column Layout Name CZ";
        ContosoAccountScheduleCZ: Codeunit "Contoso Account Schedule CZ";
        ColumnLayoutName: Code[10];
    begin
        ColumnLayoutName := CreateColumnLayoutNameCZ.BalanceSheet();
        ContosoAccountScheduleCZ.InsertColumnLayout(ColumnLayoutName, 10000, 'B', CurrentPeriodLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', Enum::"Analysis Rounding Factor"::"1000");
        ContosoAccountScheduleCZ.InsertColumnLayout(ColumnLayoutName, 20000, 'M', PreviousPeriodLbl, Enum::"Column Layout Type"::"Entire Fiscal Year", Enum::"Column Layout Entry Type"::Entries, '-1FY', Enum::"Analysis Rounding Factor"::"1000");

        ColumnLayoutName := CreateColumnLayoutNameCZ.IncomeStatement();
        ContosoAccountScheduleCZ.InsertColumnLayout(ColumnLayoutName, 10000, 'B', CurrentPeriodLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', Enum::"Analysis Rounding Factor"::"1000");
        ContosoAccountScheduleCZ.InsertColumnLayout(ColumnLayoutName, 20000, 'M', PreviousPeriodLbl, Enum::"Column Layout Type"::"Entire Fiscal Year", Enum::"Column Layout Entry Type"::Entries, '-1FY', Enum::"Analysis Rounding Factor"::"1000");
    end;

    var
        CurrentPeriodLbl: Label 'Current period', MaxLength = 30;
        PreviousPeriodLbl: Label 'Previous period', MaxLength = 30;
}
