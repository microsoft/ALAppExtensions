// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using System.Telemetry;

codeunit 4585 "SOA Error Handler"
{
    Access = Internal;
    TableNo = "SOA Setup";
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        RunSOAErrorHandler(Rec);
    end;

    var
        TelemetryAgentTaskFailedLbl: Label 'Sales order agent task failed', Locked = true;

    local procedure RunSOAErrorHandler(Setup: Record "SOA Setup")
    var
        SOAImpl: Codeunit "SOA Impl";
        SOASetupCU: Codeunit "SOA Setup";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        TelemetryDimensions.Add('SOASetupId', Format(Setup.ID));
        FeatureTelemetry.LogError('0000NDM', SOASetupCU.GetFeatureName(), 'RunSOAErrorHandler', TelemetryAgentTaskFailedLbl, GetLastErrorCallStack(), TelemetryDimensions);

        SOAImpl.ScheduleSOAgent(Setup);
    end;
}