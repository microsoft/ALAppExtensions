// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using System.Agents;
using System.Email;
using System.Telemetry;

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
        SOASetupCU: Codeunit "SOA Setup";
        SOAMailSetup: Codeunit "SOA Email Setup";
        SOATaskMessage: Codeunit "SOA Task Message";
        FeatureTelemetry: Codeunit "Feature Telemetry";
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
        TelemetryProcessingLimitReachedLbl: Label 'Processing limit of emails reached.', Locked = true;
        PageCountExceededTelemetryTxt: label 'PDF Attachment ignored because it exceeds page count of %1.', Locked = true;
        PageCountCallFailedTelemetryTxt: label 'Unable to calculate PDF Attachment''s page count.', Locked = true;
        MaxAttachmentsExceededTelemetryTxt: label 'Number of attachments exceeds maximum allowed.', Locked = true;

    local procedure RetrieveEmails(var SOASetup: Record "SOA Setup")
    var
        EmailInbox: Record "Email Inbox";
        TempFilters: Record "Email Retrieval Filters" temporary;
        SOAEmail: Record "SOA Email";
        Email: Codeunit "Email";
        Processed: Integer;
        ProcessLimit: Integer;
        TelemetryDimensions: Dictionary of [Text, Text];
        StartDateTime: DateTime;
    begin
        if not SOASetupCU.CheckSOASetupStillValid(SOASetup) then
            exit;

        ProcessLimit := SOAImpl.GetProcessLimitPerDay(SOASetup);
        Processed := SOAMailSetup.GetEmailCountProcessedWithin24hrs();
        if Processed >= ProcessLimit then begin
            TelemetryDimensions.Set('Processed', Format(Processed));
            TelemetryDimensions.Set('ProcessLimit', Format(ProcessLimit));
            FeatureTelemetry.LogUsage('0000O9Y', SOASetupCU.GetFeatureName(), TelemetryProcessingLimitReachedLbl, TelemetryDimensions);
            exit;
        end;

        TempFilters."Unread Emails" := true;
        TempFilters."Load Attachments" := true;
        TempFilters."Max No. of Emails" := SOAMailSetup.GetMaxNoOfEmails();
        TempFilters."Last Message Only" := true;
        TempFilters."Folder Id" := SOASetup."Email Folder Id";
        TempFilters."Earliest Email" := SOASetup."Earliest Sync At";
        TempFilters.Insert();

        Email.RetrieveEmails(SOASetup."Email Account ID", SOASetup."Email Connector", EmailInbox, TempFilters);

        if not EmailInbox.FindSet() then
            FeatureTelemetry.LogUsage('0000NDN', SOASetupCU.GetFeatureName(), TelemetryNoEmailsFoundLbl, TelemetryDimensions)
        else
            FeatureTelemetry.LogUsage('0000NDO', SOASetupCU.GetFeatureName(), TelemetryEmailsFoundLbl, TelemetryDimensions);

        if not SOASetupCU.CheckSOASetupStillValid(SOASetup) then
            exit;

        //Get latest instructions from KV
        if SOASetupCU.InstructionsSyncRequired(SOASetup) then begin
            SOASetupCU.UpdateInstructions(SOASetup);
            SOASetupCU.UpdateSOASetupInstructionsLastSync(SOASetup);
        end;

        RemoveEmailsOutsideSyncRange(EmailInbox);
        AddEmailInboxToSOAEmails(SOASetup, EmailInbox);
        // Only update sync time if we're not syncing from a specific folder
        // Specifying a folder means we may miss emails if they are moved into the folder after we sync
        if TempFilters."Folder Id" = '' then
            UpdateSOAEarliestSyncAt(SOASetup, EmailInbox.Count());
        Commit();

        SOAEmail.SetRange(Processed, false);
        if not SOAEmail.FindSet() then
            exit;

        StartDateTime := CurrentDateTime();
        repeat
            AddEmailToAgentTask(SOASetup, SOAEmail);
            // Prevent locks from being held for too long
            if CurrentDateTime() - StartDateTime > 25000 then begin
                Commit();
                StartDateTime := CurrentDateTime();
            end;

            Processed += 1;
            if Processed >= ProcessLimit then begin
                TelemetryDimensions.Set('Processed', Format(Processed));
                TelemetryDimensions.Set('ProcessLimit', Format(ProcessLimit));
                FeatureTelemetry.LogUsage('0000O9Z', SOASetupCU.GetFeatureName(), TelemetryProcessingLimitReachedLbl, TelemetryDimensions);
                break;
            end;
        until SOAEmail.Next() = 0;
    end;

    local procedure UpdateSOAEarliestSyncAt(var SOASetup: Record "SOA Setup"; EmailsProcessed: Integer)
    begin
        SOASetup.Get(SOASetup.ID);
        // Only move the earliest sync time forward if we processed fewer emails than the limit
        // This ensures we'll re-query and get any we missed
        if EmailsProcessed < SOAMailSetup.GetMaxNoOfEmails() then
            SOASetup."Earliest Sync At" := CurrentDateTime();

        SOASetup.Modify();
    end;

    local procedure AddEmailToAgentTask(SOASetup: Record "SOA Setup"; var SOAEmail: Record "SOA Email")
    var
        EmailInbox: Record "Email Inbox";
        AgentTaskBuilder: Codeunit "Agent Task Builder";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        if not EmailInbox.Get(SOAEmail."Email Inbox ID") then begin
            FeatureTelemetry.LogUsage('0000NJT', SOASetupCU.GetFeatureName(), TelemetryEmailInboxNotFoundLbl, TelemetryDimensions);
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
    end;

    procedure AddEmailInboxToSOAEmails(SOASetup: Record "SOA Setup"; var EmailInbox: Record "Email Inbox")
    var
        SOAEmail: Record "SOA Email";
        Email: Codeunit "Email";
    begin
        if not EmailInbox.FindSet() then
            exit;

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
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        EmailMessage.Get(EmailInbox."Message Id");
        MessageText := StrSubstNo(MessageTemplateLbl, EmailMessage.GetSubject(), EmailMessage.GetBody());
        AgentTaskTitle := CopyStr(StrSubstNo(AgentTaskTitleLbl, EmailInbox."Sender Name"), 1, MaxStrLen(AgentTaskRecord.Title));

        AgentMessageBuilder.Initialize(EmailInbox."Sender Address", MessageText)
            .SetMessageExternalID(EmailInbox."External Message Id")
            .SetRequiresReview(SOATaskMessage.MessageRequiresReview(SOASetup, EmailInbox, true))
            .SetIgnoreAttachment(not SOASetup."Analyze Attachments");

        AgentTaskBuilder.Initialize(SOASetup."Agent User Security ID", AgentTaskTitle)
            .SetExternalId(EmailInbox."Conversation Id")
            .AddTaskMessage(AgentMessageBuilder);

        AddEmailAttachmentToTaskMessage(AgentMessageBuilder, EmailMessage);
        AgentTaskBuilder.Create();

        AgentTaskMessage := AgentTaskBuilder.GetAgentTaskMessageCreated();
        SOAEmail.SetAgentMessageFields(AgentTaskMessage);
        SetAttachmentsTransferred(SOAEmail, EmailMessage);
        SOAEmail.Modify();
        SOABilling.LogEmailRead(AgentTaskMessage.ID, AgentTaskMessage."Task ID");
        FeatureTelemetry.LogUsage('0000NDP', SOASetupCU.GetFeatureName(), TelemetryEmailAddedAsTaskLbl, TelemetryDimensions);
    end;

    local procedure AddEmailAttachmentToTaskMessage(AgentTaskMessageBuilder: Codeunit "Agent Task Message Builder"; var EmailMessage: Codeunit "Email Message")
    var
        SOASetup: Codeunit "SOA Setup";
        InStream: InStream;
        FileMIMEType: Text[100];
        IsFileMimeTypeSupported: Boolean;
        ExceedsPageCountThreshold: Boolean;
        PdfContent: Boolean;
        Ignore: Boolean;
        NoOfAttachments: Integer;
        SupportedAttachmentLbl: Label 'Email has supported attachment: %1', Locked = true, Comment = '%1 = MIME type of the attachment';
        UnsupportedAttachmentLbl: Label 'Email has unsupported attachment: %1', Locked = true, Comment = '%1 = MIME type of the attachment';
    begin
        if not EmailMessage.Attachments_First() then
            exit;

        NoOfAttachments := 0;
        repeat
            EmailMessage.Attachments_GetContent(InStream);
            FileMIMEType := CopyStr(EmailMessage.Attachments_GetContentType(), 1, 100);
            IsFileMimeTypeSupported := SOASetup.SupportedAttachmentContentType(FileMIMEType);
            if IsFileMimeTypeSupported then begin
                PdfContent := SOASetup.IsPdfAttachmentContentType(FileMIMEType);
                if PdfContent then begin
                    if not SOASetup.DocumentExceedsPageCountThreshold(InStream, ExceedsPageCountThreshold) then
                        FeatureTelemetry.LogError('0000QHK', SOASetup.GetFeatureName(), 'Document exceeds page count threshold', PageCountCallFailedTelemetryTxt);
                    if ExceedsPageCountThreshold then
                        FeatureTelemetry.LogUsage('0000QHL', SOASetup.GetFeatureName(), StrSubstNo(PageCountExceededTelemetryTxt, Format(SOASetup.PageCountThreshold())));
                end;
            end;
            Ignore := IgnoreAttachment(IsFileMimeTypeSupported, ExceedsPageCountThreshold, NoOfAttachments);
            AgentTaskMessageBuilder.AddAttachment(EmailMessage.Attachments_GetName(), FileMIMEType, InStream, Ignore);

            if not Ignore then
                NoOfAttachments += 1;

            // Log telemetry for SOA session
            if IsFileMimeTypeSupported then
                FeatureTelemetry.LogUsage('0000QBM', SOASetup.GetFeatureName(), StrSubstNo(SupportedAttachmentLbl, FileMIMEType))
            else
                FeatureTelemetry.LogUsage('0000QBN', SOASetup.GetFeatureName(), StrSubstNo(UnsupportedAttachmentLbl, FileMIMEType));
        until EmailMessage.Attachments_Next() = 0;

        if NoOfAttachments > SOASetupCU.GetMaxNoOfAttachmentsPerEmail() then
            FeatureTelemetry.LogUsage('0000QK9', SOASetup.GetFeatureName(), MaxAttachmentsExceededTelemetryTxt);
    end;

    local procedure IgnoreAttachment(IsFileMimeTypeSupported: Boolean; ExceedsPageCountThreshold: Boolean; NoOfAttachments: Integer): Boolean
    begin
        if not IsFileMimeTypeSupported then
            exit(true);

        if ExceedsPageCountThreshold then
            exit(true);

        if NoOfAttachments >= SOASetupCU.GetMaxNoOfAttachmentsPerEmail() then
            exit(true);

        exit(false);
    end;

    local procedure SetAttachmentsTransferred(var SOAEmail: Record "SOA Email"; EmailMessage: Codeunit "Email Message")
    begin
        SOAEmail."Attachment Transferred" := not EmailMessage.Attachments_First();
    end;

    procedure AddEmailToExistingAgentTask(SOASetup: Record "SOA Setup"; EmailInbox: Record "Email Inbox"; var SOAEmail: Record "SOA Email")
    var
        AgentTaskRecord: Record "Agent Task";
        AgentTaskMessage: Record "Agent Task Message";
        AgentTaskMessageBuilder: Codeunit "Agent Task Message Builder";
        EmailMessage: Codeunit "Email Message";
        SOABilling: Codeunit "SOA Billing";
        MessageText: Text;
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        AgentTaskRecord.ReadIsolation(IsolationLevel::ReadCommitted);
        AgentTaskRecord.SetRange("External ID", EmailInbox."Conversation Id");
        if not AgentTaskRecord.FindFirst() then begin
            FeatureTelemetry.LogError('0000NDX', SOASetupCU.GetFeatureName(), 'Find Agent Task', TelemetryAgentTaskNotFoundLbl, GetLastErrorCallStack(), TelemetryDimensions);
            exit;
        end;

        AgentTaskMessage.ReadIsolation(IsolationLevel::ReadCommitted);
        AgentTaskMessage.SetRange("Task ID", AgentTaskRecord.ID);
        AgentTaskMessage.SetRange("External ID", EmailInbox."External Message Id");
        if AgentTaskMessage.Count() >= 1 then begin
            FeatureTelemetry.LogUsage('0000OFS', SOASetupCU.GetFeatureName(), TelemetryAgentTaskMessageExistsLbl, TelemetryDimensions);
            exit;
        end;

        EmailMessage.Get(EmailInbox."Message Id");
        MessageText := StrSubstNo(MessageTemplateLbl, EmailMessage.GetSubject(), EmailMessage.GetBody());

        AgentTaskMessageBuilder.Initialize(EmailInbox."Sender Address", MessageText)
            .SetMessageExternalID(EmailInbox."External Message Id")
            .SetRequiresReview(SOATaskMessage.MessageRequiresReview(SOASetup, EmailInbox, false))
            .SetIgnoreAttachment(not SOASetup."Analyze Attachments")
            .SetAgentTask(AgentTaskRecord);

        AddEmailAttachmentToTaskMessage(AgentTaskMessageBuilder, EmailMessage);
        AgentTaskMessage := AgentTaskMessageBuilder.Create();

        SOAEmail.SetAgentMessageFields(AgentTaskMessage);
        SetAttachmentsTransferred(SOAEmail, EmailMessage);
#pragma warning disable AA0214
        SOAEmail.Modify();
#pragma warning restore AA0214
        SOABilling.LogEmailRead(AgentTaskMessage.ID, AgentTaskMessage."Task ID");
        FeatureTelemetry.LogUsage('0000NGP', SOASetupCU.GetFeatureName(), TelemetryEmailAddedToExistingTaskLbl, TelemetryDimensions);
    end;

    [InternalEvent(false, true)]
    local procedure OnAfterProcessEmail(EmailInboxId: BigInteger)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SOA Retrieve Emails", 'OnAfterProcessEmail', '', false, false)]
    local procedure OnAfterEmailProcessed(EmailInboxId: BigInteger)
    var
        SOAEmail: Record "SOA Email";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        SOAEmail.Get(EmailInboxId);
        SOAEmail.Processed := true;
        if not SOAEmail.Modify() then begin
            TelemetryDimensions.Set('EmailInboxID', Format(EmailInboxId));
            FeatureTelemetry.LogUsage('0000OA0', SOASetupCU.GetFeatureName(), TelemetrySOAEmailNotModifiedLbl, TelemetryDimensions);
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