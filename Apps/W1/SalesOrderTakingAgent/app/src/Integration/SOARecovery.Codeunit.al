// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker.Integration;

using System.Agents;
using System.AI;
using System.Environment;
using System.Telemetry;
using Agent.SalesOrderTaker;

codeunit 4584 "SOA Recovery"
{
    Access = Internal;
    TableNo = "SOA Setup";

    trigger OnRun()
    begin
        RunSOARecovery(Rec);
    end;

    var
        TelemetrySalesOrderAgentIsNotEnabledLbl: Label 'Sales order agent is not enabled', Locked = true;
        TelemetryAgentCapabilityNotEnabledLbl: Label 'Sales order agent capability is not enabled', Locked = true;

    procedure RunSOARecovery(Setup: Record "SOA Setup")
    var
        ScheduledTask: Record "Scheduled Task";
        AgentMonitoringImpl: Codeunit "Agent Monitoring Impl.";
        AzureOpenAI: Codeunit "Azure OpenAI";
        SOAImpl: Codeunit "SOA Impl";
        Telemetry: Codeunit Telemetry;
        CustomDimensions: Dictionary of [Text, Text];
    begin
        CustomDimensions.Add('category', SOAImpl.GetCategory());
        CustomDimensions.Add('SOASetupId', Format(Setup.ID));

        // Check if capability is enabled
        if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"Sales Order Taker Agent", true) then begin
            Telemetry.LogMessage('0000NF6', TelemetryAgentCapabilityNotEnabledLbl, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
            exit;
        end;

        // Check if the agent is enabled
        if not AgentMonitoringImpl.IsAgentEnabled(Setup."Agent User Security ID") then begin
            Telemetry.LogMessage('0000NDW', TelemetrySalesOrderAgentIsNotEnabledLbl, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
            exit;
        end;

        // Check if task exists
        ScheduledTask.SetRange("Run Codeunit", Codeunit::"SOA Dispatcher");
        ScheduledTask.SetRange(Company, CompanyName());
        if not ScheduledTask.IsEmpty() then
            exit; // Task already exists

        // Recover task
        SOAImpl.ScheduleSOA(Setup);
    end;
}