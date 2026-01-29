#if not CLEAN28
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.Reports;
using Microsoft.Foundation.Reporting;

codeunit 10800 "Substitute Report"
{
    ObsoleteReason = 'Feature FAReportsFR will be enabled by default in version 31.0.';
    ObsoleteState = Pending;
    ObsoleteTag = '28.0';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ReportManagement, 'OnAfterSubstituteReport', '', false, false)]
    local procedure OnSubstituteReport(ReportId: Integer; var NewReportId: Integer)
    var
        FAReportsFR: Codeunit "FA Reports FR";
    begin
        if not FAReportsFR.IsEnabled() then
            exit;

        case ReportId of
            Report::"FA - Proj. Value (Derogatory)":
                NewReportId := Report::"FA-Proj. Value (Derogatory) FR";
            Report::"Fixed Asset-Professional Tax":
                NewReportId := Report::"Fixed Asset-Professional TaxFR"
        end;
    end;
}
#endif