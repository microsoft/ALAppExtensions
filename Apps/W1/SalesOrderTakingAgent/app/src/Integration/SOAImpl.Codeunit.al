// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker.Integration;

using System.AI;
using System.Agents;
using System.Environment;
using System.Email;
using System.Telemetry;
using Agent.SalesOrderTaker;

codeunit 4587 "SOA Impl"
{
    Access = Internal;

    var
        Telemetry: Codeunit "Telemetry";
        AgentTaskTitleLbl: Label 'Email from %1', Comment = '%1 = Sender Name';
        CantCreateTaskErr: Label 'User cannot create tasks.';
        CategoryLbl: Label 'Sales Order Taker Agent', Locked = true;
        TelemetryEmailAddedAsTaskLbl: Label 'Email added as agent task.', Locked = true;
        TelemetryEmailReplySentLbl: Label 'Email reply sent.', Locked = true;
        TelemetryEmailReplyFailedLbl: Label 'Email reply failed to be sent.', Locked = true;
        TelemetryEmailReplyExternalIdEmptyLbl: Label 'Email reply failed to be sent due to input agent task message containing empty External Id.', Locked = true;
        TelemetryFailedToGetInputAgentTaskMessageLbl: Label 'Failed to get input agent task message.', Locked = true;
        TelemetryNoEmailsFoundLbl: Label 'No emails found.', Locked = true;
        TelemetryEmailsFoundLbl: Label 'Emails found.', Locked = true;
        TelemetrySOASetupRecordNotValidLbl: Label 'SOA Setup record is not valid.', Locked = true;
        TelemetryAgentTaskNotFoundLbl: Label 'Agent task not found.', Locked = true;
        TelemetryFailedToGetAgentTaskMessageAttachmentLbl: Label 'Failed to get agent task message attachment.', Locked = true;
        TelemetryAttachmentAddedToEmailLbl: Label 'Attachment added to email.', Locked = true;
        MessageTemplateLbl: Label 'Subject: %1%2Body: %3', Locked = true;

    procedure ScheduleSOA(var SOASetup: Record "SOA Setup")
    var
        ScheduledTaskId: Guid;
        CustomDimensions: Dictionary of [Text, Text];
    begin
        if IsNullGuid(SOASetup.SystemId) then begin
            CustomDimensions.Add('category', GetCategory());
            Telemetry.LogMessage('0000NDU', TelemetrySOASetupRecordNotValidLbl, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
            exit;
        end;

        if not TaskScheduler.CanCreateTask() then
            Error(CantCreateTaskErr);

        ScheduledTaskId := TaskScheduler.CreateTask(Codeunit::"SOA Dispatcher", Codeunit::"SOA Error Handler", true, CompanyName(), CurrentDateTime() + ScheduleDelay(), SOASetup.RecordId);
        ScheduleSOARecovery(SOASetup);
    end;

    procedure ScheduleSOARecovery(var SOASetup: Record "SOA Setup")
    var
        ScheduledTask: Record "Scheduled Task";
        CustomDimensions: Dictionary of [Text, Text];
    begin
        if IsNullGuid(SOASetup.SystemId) then begin
            CustomDimensions.Add('category', GetCategory());
            Telemetry.LogMessage('0000NDV', TelemetrySOASetupRecordNotValidLbl, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
            exit;
        end;

        // Check if recovery task exists
        ScheduledTask.SetRange("Run Codeunit", Codeunit::"SOA Recovery");
        ScheduledTask.SetRange(Company, CompanyName());
        if not ScheduledTask.IsEmpty() then
            exit; // Task already exists

        TaskScheduler.CreateTask(Codeunit::"SOA Recovery", Codeunit::"SOA Recovery", true, CompanyName(), CurrentDateTime() + ScheduleRecoveryDelay(), SOASetup.RecordId);
    end;

    local procedure ScheduleDelay(): Integer
    begin
        exit(60 * 1000) // 1 minute
    end;

    local procedure ScheduleRecoveryDelay(): Integer
    begin
        exit(4 * 60 * 60 * 1000) // 4 hours
    end;

    procedure RetrieveEmails(SOASetup: Record "SOA Setup")
    var
        EmailInbox: Record "Email Inbox";
        Email: Codeunit "Email";
        CustomDimensions: Dictionary of [Text, Text];
    begin
        Email.RetrieveEmails(SOASetup."Email Account ID", SOASetup."Email Connector", EmailInbox);

        CustomDimensions.Add('category', GetCategory());
        if not EmailInbox.FindSet() then begin
            Telemetry.LogMessage('0000NDN', TelemetryNoEmailsFoundLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
            exit;
        end;

        Telemetry.LogMessage('0000NDO', TelemetryEmailsFoundLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);

        repeat
            AddEmailToAgentTask(SOASetup, EmailInbox);
        until EmailInbox.Next() = 0;
    end;

    local procedure AddEmailToAgentTask(SOASetup: Record "SOA Setup"; EmailInbox: Record "Email Inbox")
    begin
        if HasAgentTaskWithConversationId(EmailInbox."Conversation Id") then
            AddEmailToExistingAgentTask(EmailInbox)
        else
            AddEmailToNewAgentTask(SOASetup."Agent User Security ID", EmailInbox);
    end;

    local procedure HasAgentTaskWithConversationId(ConversationId: Text): Boolean
    var
        AgentTask: Record "Agent Task";
    begin
        AgentTask.ReadIsolation(IsolationLevel::ReadCommitted);
        AgentTask.SetRange("External ID", ConversationId);
        exit(not AgentTask.IsEmpty());
    end;

    local procedure AddEmailToNewAgentTask(AgentUserSecurityId: Guid; EmailInbox: Record "Email Inbox")
    var
        AgentTask: Record "Agent Task";
        AgentMonitoringImpl: Codeunit "Agent Monitoring Impl.";
        EmailMessage: Codeunit "Email Message";
        MessageText: Text;
        NewLine: Char;
        CustomDimensions: Dictionary of [Text, Text];
    begin
        AgentTask."Agent User Security ID" := AgentUserSecurityId;
        AgentTask."External ID" := EmailInbox."Conversation Id";
        AgentTask.Title := CopyStr(StrSubstNo(AgentTaskTitleLbl, EmailInbox."Sender Name"), 1, MaxStrLen(AgentTask.Title));

        EmailMessage.Get(EmailInbox."Message Id");
        NewLine := 10;
        MessageText := StrSubstNo(MessageTemplateLbl, EmailMessage.GetSubject(), NewLine, EmailMessage.GetBody());
        AgentMonitoringImpl.CreateTaskMessage(MessageText, EmailInbox."External Message Id", AgentTask);

        CustomDimensions.Add('category', GetCategory());
        Telemetry.LogMessage('0000NDP', TelemetryEmailAddedAsTaskLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
    end;

    local procedure AddEmailToExistingAgentTask(EmailInbox: Record "Email Inbox")
    var
        AgentTask: Record "Agent Task";
        AgentMonitoringImpl: Codeunit "Agent Monitoring Impl.";
        EmailMessage: Codeunit "Email Message";
        MessageText: Text;
        NewLine: Char;
        CustomDimensions: Dictionary of [Text, Text];
    begin
        AgentTask.ReadIsolation(IsolationLevel::ReadCommitted);
        AgentTask.SetRange("External ID", EmailInbox."Conversation Id");
        if not AgentTask.FindFirst() then begin
            CustomDimensions.Add('category', GetCategory());
            Telemetry.LogMessage('0000NDX', TelemetryAgentTaskNotFoundLbl, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
            exit;
        end;

        EmailMessage.Get(EmailInbox."Message Id");
        NewLine := 10;
        MessageText := StrSubstNo(MessageTemplateLbl, EmailMessage.GetSubject(), NewLine, EmailMessage.GetBody());
        AgentMonitoringImpl.CreateTaskMessage(MessageText, EmailInbox."External Message Id", AgentTask);
    end;

    procedure SendEmailReplies(SOASetup: Record "SOA Setup")
    var
        OutputAgentTaskMessage: Record "Agent Task Message";
        InputAgentTaskMessage: Record "Agent Task Message";
        AgentMonitoringImpl: Codeunit "Agent Monitoring Impl.";
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        Body: Text;
        CustomDimensions: Dictionary of [Text, Text];
    begin
        OutputAgentTaskMessage.ReadIsolation(IsolationLevel::ReadCommitted);
        OutputAgentTaskMessage.SetRange(Status, OutputAgentTaskMessage.Status::Reviewed);
        OutputAgentTaskMessage.SetRange(Type, OutputAgentTaskMessage.Type::Output);

        if not OutputAgentTaskMessage.FindSet() then
            exit;

        repeat
            CustomDimensions.Add('AgentTaskMessageID', OutputAgentTaskMessage."ID");
            CustomDimensions.Add('category', GetCategory());

            if not InputAgentTaskMessage.Get(OutputAgentTaskMessage."Task ID", OutputAgentTaskMessage."Input Message ID") then begin
                Telemetry.LogMessage('0000NDQ', TelemetryFailedToGetInputAgentTaskMessageLbl, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
                exit;
            end;
            if (InputAgentTaskMessage."External ID" = '') then begin
                Telemetry.LogMessage('0000NDR', TelemetryEmailReplyExternalIdEmptyLbl, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
                exit;
            end;

            Body := AgentMonitoringImpl.GetMessageText(OutputAgentTaskMessage);
            EmailMessage.CreateReplyAll(Body, true, InputAgentTaskMessage."External ID");
            AddMessageAttachments(EmailMessage, OutputAgentTaskMessage);

            if Email.ReplyAll(EmailMessage, InputAgentTaskMessage."External ID", SOASetup."Email Account ID", SOASetup."Email Connector") then begin
                AgentMonitoringImpl.UpdateAgentTaskMessageStatus(OutputAgentTaskMessage, OutputAgentTaskMessage.Status::Sent);
                Telemetry.LogMessage('0000NDS', TelemetryEmailReplySentLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
            end else
                Telemetry.LogMessage('0000NDT', TelemetryEmailReplyFailedLbl, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
        until OutputAgentTaskMessage.Next() = 0;
    end;

    local procedure AddMessageAttachments(var EmailMessage: Codeunit "Email Message"; var AgentTaskMessage: Record "Agent Task Message")
    var
        AgentTaskFile: Record "Agent Task File";
        AgentTaskMessageAttachment: Record "Agent Task Message Attachment";
        AgentMonitoringImpl: Codeunit "Agent Monitoring Impl.";
        CustomDimensions: Dictionary of [Text, Text];
        InStream: InStream;
    begin
        CustomDimensions.Add('category', GetCategory());
        AgentTaskMessageAttachment.SetRange("Task ID", AgentTaskMessage."Task ID");
        // AgentTaskMessageAttachment.SetRange("Message ID", AgentTaskMessage.ID); // Temp until platform fix
        if not AgentTaskMessageAttachment.FindSet() then
            exit;

        repeat
            if not AgentTaskFile.Get(AgentTaskMessageAttachment."File ID") then begin
                Telemetry.LogMessage('0000NE7', TelemetryFailedToGetAgentTaskMessageAttachmentLbl, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
                exit;
            end;

            AgentTaskFile.Content.CreateInStream(InStream, AgentMonitoringImpl.GetDefaultEncoding());
            EmailMessage.AddAttachment(AgentTaskFile."File Name", AgentTaskFile."File MIME Type", InStream);
            Telemetry.LogMessage('0000NE8', TelemetryAttachmentAddedToEmailLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
        until AgentTaskMessageAttachment.Next() = 0;
    end;

    procedure GetCategory(): Text
    begin
        exit(CategoryLbl);
    end;

    procedure RegisterCapability()
    var
        CopilotCapability: Codeunit "Copilot Capability";
        EnvironmentInformation: Codeunit "Environment Information";
        LearnMoreUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2281481', Locked = true;
    begin
        if EnvironmentInformation.IsSaaSInfrastructure() then
            if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Sales Order Taker Agent") then
                CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Sales Order Taker Agent", Enum::"Copilot Availability"::Preview, LearnMoreUrlTxt);
    end;

    [EventSubscriber(ObjectType::Table, Database::Agent, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterAgentModified(var Rec: Record Agent; var xRec: Record Agent; RunTrigger: Boolean)
    var
        SOASetup: Record "SOA Setup";
    begin
        if Rec.State = Rec.State::Enabled then begin
            SOASetup.SetRange("Agent User Security ID", Rec."User Security ID");
            if SOASetup.FindFirst() then
                ScheduleSOA(SOASetup);
        end;
    end;
}