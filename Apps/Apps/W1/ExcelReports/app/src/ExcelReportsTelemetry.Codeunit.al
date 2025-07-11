// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.ExcelReports;
using System.Telemetry;

codeunit 4412 "Excel Reports Telemetry"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        FeatureNameLbl: Label '1st Party Excel Layout Reports', Locked = true;

    internal procedure GetFeatureTelemetryName(): Text
    begin
        exit(FeatureNameLbl);
    end;

    internal procedure LogReportUsage(ReportId: Integer)
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        CustomDimensions: Dictionary of [Text, Text];
    begin
        CustomDimensions.Add('ReportId', Format(ReportId));
        FeatureTelemetry.LogUsage('0000NWG', GetFeatureTelemetryName(), 'Running report', CustomDimensions);
    end;
}