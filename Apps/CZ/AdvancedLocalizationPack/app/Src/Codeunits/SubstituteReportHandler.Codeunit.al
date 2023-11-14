// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Reporting;

using Microsoft.Inventory.Reports;
using System.Apps;

codeunit 31445 "Substitute Report Handler CZA"
{
    Permissions = tabledata "NAV App Installed App" = r;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ReportManagement, 'OnAfterSubstituteReport', '', false, false)]
    local procedure OnAfterSubstituteReport(ReportId: Integer; var NewReportId: Integer)
    begin
        if IsTestingEnvironment() then
            exit;

        case ReportId of
            Report::"Inventory Valuation - WIP":
                NewReportId := Report::"Inventory Valuation - WIP CZA";
        end;
    end;

    local procedure IsTestingEnvironment(): Boolean
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
    begin
        exit(NAVAppInstalledApp.Get('fa3e2564-a39e-417f-9be6-c0dbe3d94069')); // application "Tests-ERM"
    end;
}
