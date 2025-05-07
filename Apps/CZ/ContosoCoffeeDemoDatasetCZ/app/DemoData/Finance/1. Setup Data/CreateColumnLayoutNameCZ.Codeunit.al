// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 31290 "Create Column Layout Name CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.InsertColumnLayoutName(BalanceSheet(), CurrentPeriodBalanceVPriorFiscalYearLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(IncomeStatement(), CurrentPeriodNetChangeVPriorFiscalYearLbl);
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
        CurrentPeriodBalanceVPriorFiscalYearLbl: Label 'BS Current Period Balance v Prior Fiscal Year Balance', MaxLength = 80, Comment = 'BS - abbreviation of Balance Sheet';
        CurrentPeriodNetChangeVPriorFiscalYearLbl: Label 'IS Current Period Net Change v Prior Fiscal Year Net Change', MaxLength = 80, Comment = 'IS - abbreviation of Income Statement';
}
