// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using System.Agents;
using System.Email;
using System.Telemetry;

codeunit 4581 "SOA Send Replies"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    TableNo = "SOA Setup";

    trigger OnRun()
    begin
        SendEmailReplies(Rec);
    end;

    var
        SOASetupCU: Codeunit "SOA Setup";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        AllSentSuccessfully: Boolean;
        TelemetryEmailReplySentLbl: Label 'Email reply sent.', Locked = true;
        TelemetryEmailReplyFailedToSendLbl: Label 'Email reply failed to send.', Locked = true;
        TelemetryEmailReplyExternalIdEmptyLbl: Label 'Email reply failed to be sent due to input agent task message containing empty External Id.', Locked = true;
        TelemetryFailedToGetInputAgentTaskMessageLbl: Label 'Failed to get input agent task message.', Locked = true;
        TelemetryFailedToGetAgentTaskMessageAttachmentLbl: Label 'Failed to get agent task message attachment.', Locked = true;
        TelemetryAttachmentAddedToEmailLbl: Label 'Attachment added to email.', Locked = true;
        EmailSubjectTxt: Label 'Sales order agent reply to task %1', Comment = '%1 = Agent Task id';

    local procedure SendEmailReplies(SOASetup: Record "SOA Setup")
    var
        OutputAgentTaskMessage: Record "Agent Task Message";
        InputAgentTaskMessage: Record "Agent Task Message";
        EmailOutbox: Record "Email Outbox";
        AgentMessage: Codeunit "Agent Message";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        AllSentSuccessfully := true;

        OutputAgentTaskMessage.ReadIsolation(IsolationLevel::ReadCommitted);
        OutputAgentTaskMessage.SetRange(Status, OutputAgentTaskMessage.Status::Reviewed);
        OutputAgentTaskMessage.SetRange(Type, OutputAgentTaskMessage.Type::Output);
        OutputAgentTaskMessage.SetRange("Agent User Security ID", SOASetup."Agent User Security ID");

        if not OutputAgentTaskMessage.FindSet() then
            exit;

        repeat
            Clear(EmailOutbox);
            TelemetryDimensions.Set('AgentTaskID', Format(OutputAgentTaskMessage."Task ID"));
            TelemetryDimensions.Set('AgentTaskMessageID', OutputAgentTaskMessage."ID");

            if not InputAgentTaskMessage.Get(OutputAgentTaskMessage."Task ID", OutputAgentTaskMessage."Input Message ID") then begin
                FeatureTelemetry.LogError('0000NDQ', SOASetupCU.GetFeatureName(), 'Get Input Agent Task Message', TelemetryFailedToGetInputAgentTaskMessageLbl, GetLastErrorCallStack(), TelemetryDimensions);
                exit;
            end;
            if (InputAgentTaskMessage."External ID" = '') then begin
                FeatureTelemetry.LogUsage('0000NDR', SOASetupCU.GetFeatureName(), TelemetryEmailReplyExternalIdEmptyLbl, TelemetryDimensions);
                exit;
            end;

            if TryReply(InputAgentTaskMessage, OutputAgentTaskMessage, SOASetup) then begin
                AgentMessage.SetStatusToSent(OutputAgentTaskMessage);
                FeatureTelemetry.LogUsage('0000NDS', SOASetupCU.GetFeatureName(), TelemetryEmailReplySentLbl, TelemetryDimensions);
            end else begin
                AllSentSuccessfully := false;
                TelemetryDimensions.Set('Error', GetLastErrorText());
                FeatureTelemetry.LogError('0000OAB', SOASetupCU.GetFeatureName(), 'Send Email Reply', TelemetryEmailReplyFailedToSendLbl, GetLastErrorCallStack(), TelemetryDimensions);
            end;
        until OutputAgentTaskMessage.Next() = 0;
    end;

    procedure GetAllSentSuccessfully(): Boolean
    begin
        exit(AllSentSuccessfully);
    end;

    local procedure TryReply(InputAgentTaskMessage: Record "Agent Task Message"; OutputAgentTaskMessage: Record "Agent Task Message"; SOASetup: Record "SOA Setup"): Boolean
    var
        AgentMessage: Codeunit "Agent Message";
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        Body: Text;
        Subject: Text;
    begin
        Subject := StrSubstNo(EmailSubjectTxt, InputAgentTaskMessage."Task ID");
        Body := AgentMessage.GetText(OutputAgentTaskMessage);
        EmailMessage.CreateReplyAll(Subject, Body, true, InputAgentTaskMessage."External ID");
        AddMessageAttachments(EmailMessage, OutputAgentTaskMessage);

        exit(Email.ReplyAll(EmailMessage, SOASetup."Email Account ID", SOASetup."Email Connector"));
    end;

    local procedure AddMessageAttachments(var EmailMessage: Codeunit "Email Message"; var AgentTaskMessage: Record "Agent Task Message")
    var
        AgentTaskFile: Record "Agent Task File";
        AgentTaskMessageAttachment: Record "Agent Task Message Attachment";
        AgentTaskFileInStream: InStream;
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        AgentTaskMessageAttachment.SetRange("Task ID", AgentTaskMessage."Task ID");
        AgentTaskMessageAttachment.SetRange("Message ID", AgentTaskMessage.ID);
        if not AgentTaskMessageAttachment.FindSet() then
            exit;

        repeat
            if not AgentTaskFile.Get(AgentTaskMessageAttachment."Task ID", AgentTaskMessageAttachment."File ID") then begin
                FeatureTelemetry.LogError('0000NE7', SOASetupCU.GetFeatureName(), 'Get Agent Task Message Attachment', TelemetryFailedToGetAgentTaskMessageAttachmentLbl, '', TelemetryDimensions);
                exit;
            end;
            AgentTaskFile.CalcFields(Content);
            //TODO: Refactor to a better interface 
            AgentTaskFile.Content.CreateInStream(AgentTaskFileInStream, TextEncoding::UTF8);
            EmailMessage.AddAttachment(AgentTaskFile."File Name", AgentTaskFile."File MIME Type", AgentTaskFileInStream);
            FeatureTelemetry.LogUsage('0000NE8', SOASetupCU.GetFeatureName(), TelemetryAttachmentAddedToEmailLbl, TelemetryDimensions);
        until AgentTaskMessageAttachment.Next() = 0;
    end;
}