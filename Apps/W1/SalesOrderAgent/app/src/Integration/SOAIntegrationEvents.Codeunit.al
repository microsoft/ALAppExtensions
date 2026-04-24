// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Agent.SalesOrderAgent;

using System.Agents;
using System.Environment;
using System.Feedback;
using System.Telemetry;

codeunit 4599 "SOA Integration Events"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Action Triggers", OnFeedbackEvent, '', false, false)]
    local procedure OnFeedbackEventForSalesOrderAgentTasks(PageId: Integer; Context: Dictionary of [Text, Text]; var Handled: Boolean)
    begin
        IsAgentTaskFeedbackContext(Context, Handled);
    end;

    local procedure IsAgentTaskFeedbackContext(Context: Dictionary of [Text, Text]; var Handled: Boolean)
    var
        FeedbackType: Text;
    begin
        // Scenario: Thumbs feedback from Sales Order Agent Tasks pane
        if not (Context.ContainsKey('Copilot.Agents.AgentTypeId') and Context.ContainsKey('Copilot.Agents.TaskId')) then
            exit;

        if Context.Get('Copilot.Agents.AgentTypeId') <> Format(Enum::"Agent Metadata Provider"::"SO Agent".AsInteger()) then
            exit;

        if Context.ContainsKey('Feedback.Type') then
            FeedbackType := Context.Get('Feedback.Type');

        Handled := TriggerSOATaskThumbsFeedback(FeedbackType, Context.Get('Copilot.Agents.TaskId'));
    end;

    local procedure TriggerSOATaskThumbsFeedback(FeedbackType: Text; AgentTaskId: Text): Boolean
    var
        Feedback: Codeunit "Microsoft User Feedback";
        Telemetry: Codeunit Telemetry;
        ContextProperties, ContextFiles : Dictionary of [Text, Text];
        CustomDimensions: Dictionary of [Text, Text];
    begin
        Feedback.SetIsAIFeedback(true);
        case FeedbackType of
            'Copilot.ThumbsUp':
                begin
                    Feedback.RequestLikeFeedback('Sales Order Agent Task', 'SalesOrderAgent', 'Sales Order Agent');
                    CustomDimensions.Add('FeedbackType', 'ThumbsUp');
                end;
            'Copilot.ThumbsDown':
                begin
                    ContextProperties.Add('AgentTaskId', AgentTaskId);
                    Feedback.WithCustomQuestion(SOAThumbDownFeedbackQst, SOAThumbDownFeedbackQst).WithCustomQuestionType(Enum::FeedbackQuestionType::Text);
                    Feedback.RequestDislikeFeedback('Sales Order Agent Task', 'SalesOrderAgent', 'Sales Order Agent', ContextFiles, ContextProperties);
                    CustomDimensions.Add('FeedbackType', 'ThumbsDown');
                end;
            else
                exit(false);
        end;

        Telemetry.LogMessage('0000QM1', TaskThumbsFeedbackTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
        exit(true);
    end;

    var
        SOAThumbDownFeedbackQst: Label 'What happened that made you give a thumbs down?', Comment = 'Sales Order Agent is a term, and should not be translated.';
        TaskThumbsFeedbackTxt: Label 'Sales Order Agent task thumbs feedback triggered', Locked = true;
}
