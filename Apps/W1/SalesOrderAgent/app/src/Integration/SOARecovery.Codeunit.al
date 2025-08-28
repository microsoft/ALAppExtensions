// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using System.Agents;
using System.AI;
using System.Environment;
using System.Telemetry;

codeunit 4584 "SOA Recovery"
{
    Access = Internal;
    TableNo = "SOA Setup";
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        RunSOARecovery(Rec);
    end;

    var
        TelemetrySalesOrderAgentIsNotEnabledLbl: Label 'Sales order agent is not enabled', Locked = true;
        TelemetryAgentCapabilityNotEnabledLbl: Label 'Sales order agent capability is not enabled', Locked = true;

    internal procedure RunSOARecovery(Setup: Record "SOA Setup")
    var
        ScheduledTask: Record "Scheduled Task";
        Agent: Codeunit Agent;
        AzureOpenAI: Codeunit "Azure OpenAI";
        SOAImpl: Codeunit "SOA Impl";
        Telemetry: Codeunit Telemetry;
        CustomDimensions: Dictionary of [Text, Text];
    begin
        CustomDimensions := SOAImpl.GetCustomDimensions();
        CustomDimensions.Add('SOASetupId', Format(Setup.ID));

        // Check if capability is enabled
        if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"Sales Order Agent", true) then begin
            Telemetry.LogMessage('0000NF6', TelemetryAgentCapabilityNotEnabledLbl, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
            exit;
        end;

        // Check if the agent is enabled
        if not Agent.IsActive(Setup."Agent User Security ID") then begin
            Telemetry.LogMessage('0000NDW', TelemetrySalesOrderAgentIsNotEnabledLbl, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
            exit;
        end;

        // Check if task exists
        ScheduledTask.SetRange("Run Codeunit", Codeunit::"SOA Dispatcher");
        ScheduledTask.SetRange(Company, CompanyName());
        if not ScheduledTask.IsEmpty() then
            exit; // Task already exists

        // Recover task
        SOAImpl.ScheduleSOAgent(Setup);
    end;
}