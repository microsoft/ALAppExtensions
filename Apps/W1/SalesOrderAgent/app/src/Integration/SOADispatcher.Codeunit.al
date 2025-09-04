// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using System.Agents;
using System.AI;
using System.Azure.Identity;
using System.Environment;
using System.Telemetry;
using System.Utilities;

codeunit 4586 "SOA Dispatcher"
{
    Access = Internal;
    TableNo = "SOA Setup";
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        SOAImpl: Codeunit "SOA Impl";
        SOASetup: Codeunit "SOA Setup";
        Telemetry: Codeunit Telemetry;
        TelemetryAgentNotEnabledLbl: Label 'Sales order agent is not enabled', Locked = true;
        TelemetryAgentCapabilityNotEnabledLbl: Label 'Sales order agent capability is not enabled', Locked = true;
        TelemetryAgentEmailMonitoringNotEnabledLbl: Label 'Sales order agent email monitoring is not enabled', Locked = true;
        TelemetryRetrieveEmailsSuccessLbl: Label 'Emails retrieved successfully', Locked = true;
        TelemetryRetrieveEmailsFailedLbl: Label 'Emails failed to be retrieved', Locked = true;
        TelemetrySendEmailRepliesSuccessLbl: Label 'Email replies sent successfully', Locked = true;
        TelemetrySendEmailRepliesFailedLbl: Label 'Email replies failed to be sent', Locked = true;

    trigger OnRun()
    begin
        RunSOAgent(Rec);
    end;

    procedure RunSOAgent(Setup: Record "SOA Setup")
    var
        SOATask: Record "SOA Task";
        SOAEmailSetup: Codeunit "SOA Email Setup";
        CopilotQuota: Codeunit "Copilot Quota";
        QuotaCanConsume: Boolean;
        RetrievalSuccess: Boolean;
        ReplySuccess: Boolean;
        TaskSuccess: Boolean;
        CustomDimensions: Dictionary of [Text, Text];
        LastSync: DateTime;
    begin
        if not SOASetup.CheckSOASetupStillValid(Setup) then
            exit;

        CustomDimensions := SOAImpl.GetCustomDimensions();
        CustomDimensions.Add('SOASetupId', Format(Setup.ID));

        if not CanRunTask(Setup) then
            exit;

        AddTask(SOATask);

        if not SOASetup.CheckSOASetupStillValid(Setup) then
            exit;

        QuotaCanConsume := CopilotQuota.CanConsume();
        if QuotaCanConsume then begin
            // Retrieve emails
            LastSync := CurrentDateTime();
            RetrievalSuccess := Codeunit.Run(Codeunit::"SOA Retrieve Emails", Setup);
            if RetrievalSuccess then
                Telemetry.LogMessage('0000NIU', TelemetryRetrieveEmailsSuccessLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions)
            else
                Telemetry.LogMessage('0000NIV', TelemetryRetrieveEmailsFailedLbl, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
        end;

        // Send emails
        if not SOASetup.CheckSOASetupStillValid(Setup) then
            exit;

        ReplySuccess := Codeunit.Run(Codeunit::"SOA Send Replies", Setup);
        if ReplySuccess then
            Telemetry.LogMessage('0000NIW', TelemetrySendEmailRepliesSuccessLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions)
        else
            Telemetry.LogMessage('0000NIX', TelemetrySendEmailRepliesFailedLbl, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);

        TaskSuccess := (RetrievalSuccess or not QuotaCanConsume) and ReplySuccess;

        // Reschedule
        if not SOASetup.CheckSOASetupStillValid(Setup) then
            exit;

        SOAImpl.ScheduleSOAgent(Setup);
        Commit();

        if TaskSuccess then begin
            if RetrievalSuccess then
                UpdateLastSync(Setup, LastSync);
            UpdateTaskSucceeded(SOATask);
        end;

        // Remove processed emails that are outside limit
        SOAEmailSetup.RemoveProcessedEmailsOutsideLast24hrs();
        // Remove processed tasks older than 24 hours
        SOAImpl.RemoveTaskLogsOlderThan24hrs();
    end;

    local procedure CanRunTask(var Setup: Record "SOA Setup"): Boolean
    var
        Agent: Codeunit Agent;
        AzureOpenAI: Codeunit "Azure OpenAI";
        CustomDimensions: Dictionary of [Text, Text];
    begin
        CustomDimensions := SOAImpl.GetCustomDimensions();
        CustomDimensions.Add('SOASetupId', Format(Setup.ID));

        if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"Sales Order Agent", true) then begin
            Telemetry.LogMessage('0000NF5', TelemetryAgentCapabilityNotEnabledLbl, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
            exit(false);
        end;

        // Check if the agent is enabled
        if not Agent.IsActive(Setup."Agent User Security ID") then begin
            Telemetry.LogMessage('0000NDL', TelemetryAgentNotEnabledLbl, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
            exit(false);
        end;

        if not Setup."Email Monitoring" then begin
            Telemetry.LogMessage('0000NGL', TelemetryAgentEmailMonitoringNotEnabledLbl, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
            exit(false);
        end;

        exit(true);
    end;

    local procedure UpdateLastSync(var Setup: Record "SOA Setup"; DT: DateTime)
    begin
        Setup.Get(Setup.ID);
        Setup."Last Sync At" := DT;
        Setup.Modify();
        Commit();
    end;

    local procedure AddTask(var SOATask: Record "SOA Task")
    var
        AzureAdMgt: Codeunit "Azure AD Mgt.";
        EnvironmentInformation: Codeunit "Environment Information";
        UrlHelper: Codeunit "Url Helper";
    begin
        Clear(SOATask);
        SOATask.Status := SOATask.Status::"In Progress";
        if EnvironmentInformation.IsSaaSInfrastructure() then
            SOATask."Access Token Retrieved" := not AzureAdMgt.GetAccessTokenAsSecretText(UrlHelper.GetGraphUrl(), '', false).IsEmpty()
        else
            SOATask."Access Token Retrieved" := true;
        SOATask.Insert();
        Commit();
    end;

    local procedure UpdateTaskSucceeded(var SOATask: Record "SOA Task")
    begin
        SOATask.Status := SOATask.Status::Succeeded;
        SOATask.Modify();
        Commit();
    end;
}