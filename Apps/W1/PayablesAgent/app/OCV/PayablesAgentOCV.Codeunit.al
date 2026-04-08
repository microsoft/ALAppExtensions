// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Agent.PayablesAgent;

using Microsoft.eServices.EDocument;
using System.Agents;
using System.Environment;
using System.Feedback;
using System.Telemetry;
using System.Text;
using System.Utilities;

codeunit 3317 "Payables Agent OCV"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        Telemetry: Codeunit Telemetry;
        PayablesAgentFeedbackQst: Label 'We noticed you have processed several documents with Payables Agent. Before you turn it off, could you share what made you decide to disable it? Your feedback helps us improve the experience.', Comment = 'Payables Agent is a term, and should not be translated.';
        PayablesAgentDisableFeedbackQst: Label 'What could we have done better to keep Payables Agent enabled?', Comment = 'Payables Agent is a term, and should not be translated.';
        PayablesAgentThumbDownFeedbackQst: Label 'What happened that made you give a thumbs down?', Comment = 'Payables Agent is a term, and should not be translated.';
        DisableAgentFeedbackTxt: Label 'Disable agent feedback triggered', Locked = true;
        TaskThumbsFeedbackTxt: Label 'Task thumbs feedback triggered', Locked = true;
        DraftThumbsFeedbackTxt: Label 'Draft thumbs feedback triggered', Locked = true;

    /// <summary>
    /// Triggers the disable agent feedback process based on the documents processed threshold.
    /// Opens the OCV feedback if the threshold is met and resets the counter.
    /// </summary>
    procedure TriggerDisableAgentFeedback()
    var
        ConfirmMgt: Codeunit "Confirm Management";
        Feedback: Codeunit "Microsoft User Feedback";
    begin
        if not HasProcessedEnoughDocumentsForFeedback() then
            exit;

        if not ConfirmMgt.GetResponse(PayablesAgentFeedbackQst) then
            exit;

        // Run feedback trigger after resetting the counter to avoid multiple triggers
        Feedback.SetIsAIFeedback(true);
        Feedback.WithCustomQuestion(PayablesAgentDisableFeedbackQst, PayablesAgentDisableFeedbackQst).WithCustomQuestionType(Enum::FeedbackQuestionType::Text);
        Feedback.RequestDislikeFeedback('Disabled Payables Agent', 'PayablesAgent', 'Payables Agent');

        Telemetry.LogMessage('0000QSC', DisableAgentFeedbackTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All);
    end;

    procedure TriggerPayablesAgentTaskThumbsFeedback(FeedbackType: Text; AgentTaskId: Text): Boolean
    var
        EDocumentDataStorage: Record "E-Doc. Data Storage";
        Feedback: Codeunit "Microsoft User Feedback";
        Base64Convert: Codeunit "Base64 Convert";
        InStream: InStream;
        Base64Data: Text;
        ContextProperties, ContextFiles : Dictionary of [Text, Text];
        CustomDimensions: Dictionary of [Text, Text];
    begin
        Feedback.SetIsAIFeedback(true);
        case FeedbackType of
            'Copilot.ThumbsUp':
                begin
                    Feedback.RequestLikeFeedback('Payables Agent Task', 'PayablesAgent', 'Payables Agent');
                    CustomDimensions.Add('FeedbackType', 'ThumbsUp');
                end;
            'Copilot.ThumbsDown':
                begin
                    if GetInvoice(AgentTaskId, EDocumentDataStorage) then begin
                        EDocumentDataStorage.GetTempBlob().CreateInStream(InStream);
                        Base64Data := Base64Convert.ToBase64(InStream);
                        ContextFiles.Add(EDocumentDataStorage.Name, Base64Data);
                    end;

                    Feedback.WithCustomQuestion(PayablesAgentThumbDownFeedbackQst, PayablesAgentThumbDownFeedbackQst).WithCustomQuestionType(Enum::FeedbackQuestionType::Text);
                    Feedback.RequestDislikeFeedback('Payables Agent Task', 'PayablesAgent', 'Payables Agent', ContextFiles, ContextProperties);
                    CustomDimensions.Add('FeedbackType', 'ThumbsDown');
                end;
            else
                exit(false);
        end;

        Telemetry.LogMessage('0000QSD', TaskThumbsFeedbackTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
        exit(true);
    end;

    /// <summary>
    /// Trigger thumbs up or down feedback. Returns true if feedback was successfully triggered.
    /// </summary>
    /// <param name="Context"></param>
    /// <returns></returns>
    procedure TriggerPayableAgentDraftThumbsFeedback(FeedbackType: Text): Boolean
    var
        Feedback: Codeunit "Microsoft User Feedback";
        ContextProperties, ContextFiles : Dictionary of [Text, Text];
        CustomDimensions: Dictionary of [Text, Text];
    begin
        Feedback.SetIsAIFeedback(true);
        case FeedbackType of
            'Copilot.ThumbsUp':
                begin
                    Feedback.RequestLikeFeedback('Payables Agent Draft', 'PayablesAgent', 'Payables Agent');
                    CustomDimensions.Add('FeedbackType', 'ThumbsUp');
                end;
            'Copilot.ThumbsDown':
                begin
                    Feedback.WithCustomQuestion(PayablesAgentThumbDownFeedbackQst, PayablesAgentThumbDownFeedbackQst).WithCustomQuestionType(Enum::FeedbackQuestionType::Text);
                    Feedback.RequestDislikeFeedback('Payables Agent Draft', 'PayablesAgent', 'Payables Agent', ContextFiles, ContextProperties);
                    CustomDimensions.Add('FeedbackType', 'ThumbsDown');
                end;
            else
                exit(false);
        end;

        Telemetry.LogMessage('0000QSE', DraftThumbsFeedbackTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
        exit(true);
    end;

    local procedure HasProcessedEnoughDocumentsForFeedback(): Boolean
    var
        PayablesAgentSetup: Record "Payables Agent Setup";
        PayablesAgentKPI: Record "Payables Agent KPI";
        Agent: Record Agent;
        PayablesAgentSetupCU: Codeunit "Payables Agent Setup";
        EnvironmentInfo: Codeunit "Environment Information";
    begin
        PayablesAgentSetup.GetSetup();
        if PayablesAgentSetupCU.GetAgent(Agent) and (PayablesAgentSetup."Last Activated" = 0DT) then
            if Agent.State = Agent.State::Enabled then
                exit(true); // If never activated, it was activated before we introduced the field, so allow feedback

        PayablesAgentKPI.SetRange("Is Aggregate", false);
        PayablesAgentKPI.SetFilter(SystemCreatedAt, '>%1', PayablesAgentSetup."Last Activated");
        PayablesAgentKPI.SetFilter("KPI Scenario", '%1|%2',
            PayablesAgentKPI."KPI Scenario"::"Agent E-Docs Finalized by Agent",
            PayablesAgentKPI."KPI Scenario"::"Agent E-Docs Finalized by User");
        exit(PayablesAgentKPI.Count() > (EnvironmentInfo.IsSaaS() ? 10 : 2));
    end;

    local procedure GetInvoice(AgentTaskId: Text; var EDocumentDataStorage: Record "E-Doc. Data Storage"): Boolean
    var
        AgentTask: Record "Agent Task";
        EDocument: Record "E-Document";
    begin
        AgentTask.ReadIsolation := IsolationLevel::ReadUncommitted;
        EDocument.ReadIsolation := IsolationLevel::ReadUncommitted;
        EDocumentDataStorage.ReadIsolation := IsolationLevel::ReadUncommitted;
        AgentTask.SetLoadFields("External ID");
        EDocument.SetLoadFields("Unstructured Data Entry No.");
        if AgentTask.Get(AgentTaskId) then
            if EDocument.Get(AgentTask."External ID") then
                if EDocumentDataStorage.Get(EDocument."Unstructured Data Entry No.") then
                    exit(true);
    end;

}