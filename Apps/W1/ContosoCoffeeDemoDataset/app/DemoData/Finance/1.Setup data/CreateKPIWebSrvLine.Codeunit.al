// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 5491 "Create KPI Web Srv Line"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateAccountScheduleName: Codeunit "Create Acc. Schedule Name";
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.InsertAccSchedKPIWebSrvLine(CreateAccountScheduleName.CashCycle());
        ContosoAccountSchedule.InsertAccSchedKPIWebSrvLine(CreateAccountScheduleName.IncomeExpense());
        ContosoAccountSchedule.InsertAccSchedKPIWebSrvLine(CreateAccountScheduleName.ReducedTrialBalance());
    end;
}
