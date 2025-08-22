// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using System.Agents;
using System.Email;

codeunit 4582 "SOA Retrieve Emails"
{
    Access = Internal;
    Permissions = tabledata "Email Inbox" = rd;
    InherentEntitlements = X;
    InherentPermissions = X;
    TableNo = "SOA Setup";

    trigger OnRun()
    begin
        RetrieveEmails(Rec);
    end;

    var
        SOAImpl: Codeunit "SOA Impl";
        SOAMailSetup: Codeunit "SOA Email Setup";
        SOATaskMessage: Codeunit "SOA Task Message";
        TelemetryNoEmailsFoundLbl: Label 'No emails found.', Locked = true;
        TelemetryEmailsFoundLbl: Label 'Emails found.', Locked = true;
        AgentTaskTitleLbl: Label 'Email from %1', Comment = '%1 = Sender Name';
        TelemetryEmailAddedAsTaskLbl: Label 'Email added as agent task.', Locked = true;
        TelemetryAgentTaskNotFoundLbl: Label 'Agent task not found.', Locked = true;
        TelemetryAgentTaskMessageExistsLbl: Label 'Agent task message with external message id already exists.', Locked = true;
        TelemetryEmailAddedToExistingTaskLbl: Label 'Email added to existing task.', Locked = true;
        TelemetryEmailInboxNotFoundLbl: Label 'Email inbox not found.', Locked = true;
        MessageTemplateLbl: Label '<b>Subject:</b> %1<br/><b>Body:</b> %2', Comment = '%1 = Subject, %2 = Body';
        TelemetrySOAEmailNotModifiedLbl: Label 'SOA Email record not modified.', Locked = true;
        TelemetryEmailHasAttachmentsLbl: Label 'Email has attachments.', Locked = true;
        ScheduleBillingTask: Boolean;

    local procedure RetrieveEmails(SOASetup: Record "SOA Setup")
    var
        EmailInbox: Record "Email Inbox";
        TempFilters: Record "Email Retrieval Filters" temporary;
        SOAEmail: Record "SOA Email";
        Email: Codeunit "Email";
        SOASetupCU: Codeunit "SOA Setup";
        SOABillingTask: Codeunit "SOA Billing Task";
        CustomDimensions: Dictionary of [Text, Text];
        StartDateTime: DateTime;
    begin
        if not SOASetupCU.CheckSOASetupStillValid(SOASetup) then
            exit;

        CustomDimensions := SOAImpl.GetCustomDimensions();

        TempFilters."Unread Emails" := true;
        TempFilters."Load Attachments" := true;
        TempFilters."Max No. of Emails" := SOAMailSetup.GetMaxNoOfEmails();
        TempFilters."Earliest Email" := SOASetup."Last Sync At";
        TempFilters."Last Message Only" := true;
        TempFilters.Insert();
        Email.RetrieveEmails(SOASetup."Email Account ID", SOASetup."Email Connector", EmailInbox, TempFilters);

        if not EmailInbox.FindSet() then begin
            Session.LogMessage('0000NDN', TelemetryNoEmailsFoundLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
            exit;
        end;

        Session.LogMessage('0000NDO', TelemetryEmailsFoundLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);

        if not SOASetupCU.CheckSOASetupStillValid(SOASetup) then
            exit;

        //Get latest instructions from KV
        if SOASetupCU.InstructionsSyncRequired(SOASetup) then begin
            SOASetupCU.UpdateInstructions(SOASetup);
            SOASetupCU.UpdateSOASetupInstructionsLastSync(SOASetup);
        end;

        RemoveEmailsOutsideSyncRange(EmailInbox);
        AddEmailInboxToSOAEmails(SOASetup, EmailInbox);
        Commit();

        SOAEmail.SetRange(Processed, false);
        if SOAEmail.FindSet() then;

        StartDateTime := CurrentDateTime();
        repeat
            AddEmailToAgentTask(SOASetup, SOAEmail);
            // Prevent locks from being held for too long
            if CurrentDateTime() - StartDateTime > 25000 then begin
                Commit();
                StartDateTime := CurrentDateTime();
            end;
        until SOAEmail.Next() = 0;

        if ScheduleBillingTask then
            SOABillingTask.ScheduleBillingTask();
    end;

    local procedure AddEmailToAgentTask(SOASetup: Record "SOA Setup"; var SOAEmail: Record "SOA Email")
    var
        EmailInbox: Record "Email Inbox";
        AgentTaskBuilder: Codeunit "Agent Task Builder";
    begin
        if not EmailInbox.Get(SOAEmail."Email Inbox ID") then begin
            Session.LogMessage('0000NJT', TelemetryEmailInboxNotFoundLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, SOAImpl.GetCustomDimensions());
            SOAEmail.Delete(true);
            exit;
        end;

        if AgentTaskBuilder.TaskExists(SOASetup."Agent User Security ID", EmailInbox."Conversation Id") then
            AddEmailToExistingAgentTask(SOASetup, EmailInbox, SOAEmail)
        else
            AddEmailToNewAgentTask(SOASetup, EmailInbox, SOAEmail);

        OnAfterProcessEmail(SOAEmail."Email Inbox ID");
    end;

    local procedure RemoveEmailsOutsideSyncRange(var EmailInbox: Record "Email Inbox")
    begin
        repeat
            if EmailInbox."Is Read" then
                EmailInbox.Delete(true);
        until EmailInbox.Next() = 0;

        if EmailInbox.FindSet() then;
    end;

    procedure AddEmailInboxToSOAEmails(SOASetup: Record "SOA Setup"; var EmailInbox: Record "Email Inbox")
    var
        SOAEmail: Record "SOA Email";
        Email: Codeunit "Email";
    begin
        repeat
            SOAEmail."Email Inbox ID" := EmailInbox.Id;
            SOAEmail."Sender Name" := EmailInbox."Sender Name";
            SOAEmail."Sender Address" := EmailInbox."Sender Address";
            SOAEmail."Sent DateTime" := EmailInbox."Sent DateTime";
            SOAEmail."Received DateTime" := EmailInbox."Received DateTime";

            if SOAEmail.Insert() then
                Email.MarkAsRead(SOASetup."Email Account ID", SOASetup."Email Connector", EmailInbox."External Message Id");
        until EmailInbox.Next() = 0;
    end;

    procedure AddEmailToNewAgentTask(var SOASetup: Record "SOA Setup"; var EmailInbox: Record "Email Inbox"; var SOAEmail: Record "SOA Email")
    var
        AgentTaskRecord: Record "Agent Task";
        AgentTaskMessage: Record "Agent Task Message";
        AgentTaskBuilder: Codeunit "Agent Task Builder";
        AgentMessageBuilder: Codeunit "Agent Task Message Builder";
        EmailMessage: Codeunit "Email Message";
        SOABilling: Codeunit "SOA Billing";
        MessageText: Text;
        AgentTaskTitle: Text[150];
    begin
        EmailMessage.Get(EmailInbox."Message Id");
        MessageText := StrSubstNo(MessageTemplateLbl, EmailMessage.GetSubject(), EmailMessage.GetBody());
        AgentTaskTitle := CopyStr(StrSubstNo(AgentTaskTitleLbl, EmailInbox."Sender Name"), 1, MaxStrLen(AgentTaskRecord.Title));

        AgentMessageBuilder.Initialize(EmailInbox."Sender Address", MessageText)
            .SetMessageExternalID(EmailInbox."External Message Id")
            .SetRequiresReview(SOATaskMessage.MessageRequiresReview(SOASetup, EmailInbox, true));

        AgentTaskBuilder.Initialize(SOASetup."Agent User Security ID", AgentTaskTitle)
            .SetExternalId(EmailInbox."Conversation Id")
            .AddTaskMessage(AgentMessageBuilder);

        AddEmailAttachmentToTaskMessage(AgentMessageBuilder, EmailMessage);
        AgentTaskBuilder.Create();

        AgentTaskMessage := AgentTaskBuilder.GetAgentTaskMessageCreated();
        SOAEmail.SetAgentMessageFields(AgentTaskMessage);
        SOAEmail.Modify();
        SOABilling.LogEmailRead(AgentTaskMessage.ID, AgentTaskMessage."Task ID");
        ScheduleBillingTask := true;

        Session.LogMessage('0000NDP', TelemetryEmailAddedAsTaskLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, SOAImpl.GetCustomDimensions());
    end;

    local procedure AddEmailAttachmentToTaskMessage(AgentTaskMessageBuilder: Codeunit "Agent Task Message Builder"; var EmailMessage: Codeunit "Email Message")
    var
        InStream: InStream;
    begin
        if not EmailMessage.Attachments_First() then
            exit;

        repeat
            EmailMessage.Attachments_GetContent(InStream);
            AgentTaskMessageBuilder.AddAttachment(EmailMessage.Attachments_GetName(), CopyStr(EmailMessage.Attachments_GetContentType(), 1, 100), InStream);
        until EmailMessage.Attachments_Next() = 0;

        Session.LogMessage('0000PN1', TelemetryEmailHasAttachmentsLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, SOAImpl.GetCustomDimensions());
    end;

    procedure AddEmailToExistingAgentTask(SOASetup: Record "SOA Setup"; EmailInbox: Record "Email Inbox"; var SOAEmail: Record "SOA Email")
    var
        AgentTaskRecord: Record "Agent Task";
        AgentTaskMessage: Record "Agent Task Message";
        AgentTaskMessageBuilder: Codeunit "Agent Task Message Builder";
        EmailMessage: Codeunit "Email Message";
        SOABilling: Codeunit "SOA Billing";
        MessageText: Text;
    begin
        AgentTaskRecord.ReadIsolation(IsolationLevel::ReadCommitted);
        AgentTaskRecord.SetRange("External ID", EmailInbox."Conversation Id");
        if not AgentTaskRecord.FindFirst() then begin
            Session.LogMessage('0000NDX', TelemetryAgentTaskNotFoundLbl, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, SOAImpl.GetCustomDimensions());
            exit;
        end;

        AgentTaskMessage.ReadIsolation(IsolationLevel::ReadCommitted);
        AgentTaskMessage.SetRange("Task ID", AgentTaskRecord.ID);
        AgentTaskMessage.SetRange("External ID", EmailInbox."External Message Id");
        if AgentTaskMessage.Count() >= 1 then begin
            Session.LogMessage('0000OFS', TelemetryAgentTaskMessageExistsLbl, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, SOAImpl.GetCustomDimensions());
            exit;
        end;

        EmailMessage.Get(EmailInbox."Message Id");
        MessageText := StrSubstNo(MessageTemplateLbl, EmailMessage.GetSubject(), EmailMessage.GetBody());

        AgentTaskMessageBuilder.Initialize(EmailInbox."Sender Address", MessageText)
            .SetMessageExternalID(EmailInbox."External Message Id")
            .SetRequiresReview(SOATaskMessage.MessageRequiresReview(SOASetup, EmailInbox, false))
            .SetAgentTask(AgentTaskRecord);

        AddEmailAttachmentToTaskMessage(AgentTaskMessageBuilder, EmailMessage);
        AgentTaskMessage := AgentTaskMessageBuilder.Create();

        SOAEmail.SetAgentMessageFields(AgentTaskMessage);
#pragma warning disable AA0214
        SOAEmail.Modify();
#pragma warning restore AA0214
        SOABilling.LogEmailRead(AgentTaskMessage.ID, AgentTaskMessage."Task ID");
        ScheduleBillingTask := true;

        Session.LogMessage('0000NGP', TelemetryEmailAddedToExistingTaskLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, SOAImpl.GetCustomDimensions());
    end;

    [InternalEvent(false, true)]
    local procedure OnAfterProcessEmail(EmailInboxId: BigInteger)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SOA Retrieve Emails", 'OnAfterProcessEmail', '', false, false)]
    local procedure OnAfterEmailProcessed(EmailInboxId: BigInteger)
    var
        SOAEmail: Record "SOA Email";
        CustomDimensions: Dictionary of [Text, Text];
    begin
        SOAEmail.Get(EmailInboxId);
        SOAEmail.Processed := true;
        if not SOAEmail.Modify() then begin
            CustomDimensions := SOAImpl.GetCustomDimensions();
            CustomDimensions.Set('EmailInboxID', Format(EmailInboxId));
            Session.LogMessage('0000OA0', TelemetrySOAEmailNotModifiedLbl, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"SOA Email", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeleteSOAEmailEvent(var Rec: Record "SOA Email"; RunTrigger: Boolean)
    var
        EmailInbox: Record "Email Inbox";
    begin
        EmailInbox.Id := Rec."Email Inbox ID";
        if EmailInbox.Delete(true) then;
    end;
}