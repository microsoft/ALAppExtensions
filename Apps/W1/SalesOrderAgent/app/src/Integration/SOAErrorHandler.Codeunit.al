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
        Telemetry: Codeunit Telemetry;
        CustomDimensions: Dictionary of [Text, Text];
    begin
        CustomDimensions.Add('ErrorCallStack', GetLastErrorCallStack());
        CustomDimensions.Add('SOASetupId', Format(Setup.ID));
        Telemetry.LogMessage('0000NDM', TelemetryAgentTaskFailedLbl, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);

        SOAImpl.ScheduleSOAgent(Setup);
    end;
}