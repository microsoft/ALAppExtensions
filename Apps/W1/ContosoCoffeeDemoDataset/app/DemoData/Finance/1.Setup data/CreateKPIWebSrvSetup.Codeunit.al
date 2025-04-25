// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 5484 "Create KPI Web Srv Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    // TODO: MS
    // Look into CreateWebServices.Codeunit.al

    trigger OnRun()
    var
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.InsertAccSchedKPIWebSrvSetup(8, 2, WebServiceNameLbl, 24);
    end;

    var
        WebServiceNameLbl: Label 'powerbifinance', MaxLength = 240, Locked = true;
}
