// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker.Integration;

using System.Agents;
using System.AI;
using System.Telemetry;
using Agent.SalesOrderTaker;

codeunit 4586 "SOA Dispatcher"
{
    Access = Internal;
    TableNo = "SOA Setup";

    var
        SOAImpl: Codeunit "SOA Impl";
        TelemetryAgentNotEnabledLbl: Label 'Sales order taker agent is not enabled', Locked = true;
        TelemetryAgentCapabilityNotEnabledLbl: Label 'Sales order taker agent capability is not enabled', Locked = true;
        TelemetryAgentEmailMonitoringNotEnabledLbl: Label 'Sales order taker agent email monitoring is not enabled', Locked = true;


    trigger OnRun()
    begin
        RunSOA(Rec);
    end;

    procedure RunSOA(Setup: Record "SOA Setup")
    var
        AgentMonitoringImpl: Codeunit "Agent Monitoring Impl.";
        AzureOpenAI: Codeunit "Azure OpenAI";
        Telemetry: Codeunit Telemetry;
        CustomDimensions: Dictionary of [Text, Text];
    begin
        CustomDimensions.Add('category', SOAImpl.GetCategory());
        CustomDimensions.Add('SOASetupId', Format(Setup.ID));

        if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"Sales Order Taker", true) then begin
            Telemetry.LogMessage('0000NF5', TelemetryAgentCapabilityNotEnabledLbl, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
            exit;
        end;

        // Check if the agent is enabled
        if not AgentMonitoringImpl.IsAgentEnabled(Setup."Agent User Security ID") then begin
            Telemetry.LogMessage('0000NDL', TelemetryAgentNotEnabledLbl, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
            exit;
        end;

        if not Setup."Email Monitoring" then begin
            Telemetry.LogMessage('0000NGL', TelemetryAgentEmailMonitoringNotEnabledLbl, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
            exit;
        end;

        // Retrieve emails
        SOAImpl.RetrieveEmails(Setup);
        // Send emails
        SOAImpl.SendEmailReplies(Setup);
        // Reschedule
        SOAImpl.ScheduleSOA(Setup);
    end;
}