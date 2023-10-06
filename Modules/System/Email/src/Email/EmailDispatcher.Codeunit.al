// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

using System.Telemetry;

codeunit 8888 "Email Dispatcher"
{
    Access = Internal;
    TableNo = "Email Outbox";
    Permissions = tabledata "Sent Email" = ri,
                  tabledata "Email Outbox" = rimd,
                  tabledata "Email Message" = r,
                  tabledata "Email Error" = ri;

    var
        EmailMessageImpl: Codeunit "Email Message Impl.";
        Success: Boolean;
        EmailCategoryLbl: Label 'Email', Locked = true;
        EmailFeatureNameLbl: Label 'Emailing', Locked = true;
        FailedToFindEmailMessageMsg: Label 'Failed to find email message %1', Comment = '%1 - Email Message Id', Locked = true;
        FailedToFindEmailMessageErrorMsg: Label 'The email message has been deleted by another user.';
        AttachmentMsg: Label 'Sending email with attachment file size: %1, Content type: %2', Comment = '%1 - File size, %2 - Content type', Locked = true;

    trigger OnRun()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        EmailRateLimitImpl: Codeunit "Email Rate Limit Impl.";
        Dimensions: Dictionary of [Text, Text];
        RateLimitDuration: Duration;
    begin
        Dimensions.Add('Connector', Format(Rec.Connector));
        Dimensions.Add('EmailMessageID', Format(Rec."Message Id", 0, 4));
        Dimensions.Add('EmailAccountID', Format(Rec."Account Id", 0, 4));
        FeatureTelemetry.LogUptake('0000CTM', EmailFeatureNameLbl, Enum::"Feature Uptake Status"::Used, Dimensions);

        // -----------
        // NB: Avoid adding events here as any error would cause a roll-back and possibly an inconsistent state of the Email Outbox.
        // -----------

        Rec.LockTable(true);
        if EmailRateLimitImpl.IsRateLimitExceeded(Rec."Account Id", Rec.Connector, Rec."Send From", RateLimitDuration) then
            RescheduleEmail(RateLimitDuration, Dimensions, Rec)
        else
            SendEmail(Rec);
    end;

    local procedure SendEmail(var EmailOutbox: Record "Email Outbox")
    var
        EmailMessage: Record "Email Message";
        SentEmail: Record "Sent Email";
        SendEmailCodeunit: Codeunit "Send Email";
        Email: Codeunit Email;
        FeatureTelemetry: Codeunit "Feature Telemetry";
        Dimensions: Dictionary of [Text, Text];
    begin
        // -----------
        // NB: Avoid adding events here as any error would cause a roll-back and possibly an inconsistent state of the Email Outbox.
        // -----------

        UpdateOutboxStatus(EmailOutbox, EmailOutbox.Status::Processing);

        if EmailMessageImpl.Get(EmailOutbox."Message Id") then begin
            LogAttachments();

            SendEmailCodeunit.SetConnector(EmailOutbox.Connector);
            SendEmailCodeunit.SetAccount(EmailOutbox."Account Id");

            EmailMessageImpl.GetEmailMessage(EmailMessage);
            Success := SendEmailCodeunit.Run(EmailMessage);

            if Success then begin
                FeatureTelemetry.LogUsage('0000CTV', EmailFeatureNameLbl, 'Email sent', Dimensions);

                InsertToSentEmail(EmailOutbox, SentEmail);

                EmailOutbox.Delete();
                EmailMessageImpl.MarkAsRead();
                Commit();
            end else begin
                FeatureTelemetry.LogError('0000CTP', EmailFeatureNameLbl, 'Failed to send email', GetLastErrorText(true), GetLastErrorCallStack(), Dimensions);

                UpdateOutboxError(GetLastErrorText(), EmailOutbox);
                UpdateOutboxStatus(EmailOutbox, EmailOutbox.Status::Failed);
            end;
        end else begin
            FeatureTelemetry.LogError('0000CTR', EmailFeatureNameLbl, 'Failed to find email', StrSubstNo(FailedToFindEmailMessageMsg, EmailOutbox."Message Id"), '', Dimensions);
            UpdateOutboxError(FailedToFindEmailMessageErrorMsg, EmailOutbox);
            UpdateOutboxStatus(EmailOutbox, EmailOutbox.Status::Failed);
        end;

        if Success then
            Email.OnAfterEmailSent(SentEmail)
        else
            Email.OnAfterEmailSendFailed(EmailOutbox);
    end;

    local procedure RescheduleEmail(Delay: Duration; Dimensions: Dictionary of [Text, Text]; var EmailOutbox: Record "Email Outbox")
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        TaskId: Guid;
    begin
        // -----------
        // NB: Avoid adding events here as any error would cause a roll-back and possibly an inconsistent state of the Email Outbox.
        // -----------

        TaskId := TaskScheduler.CreateTask(Codeunit::"Email Dispatcher", Codeunit::"Email Error Handler", true, CompanyName(), CurrentDateTime() + Delay, EmailOutbox.RecordId());

        EmailOutbox."Task Scheduler Id" := TaskId;
        EmailOutbox."Date Sending" := CurrentDateTime() + Delay;
        EmailOutbox.Modify();

        Dimensions.Add('TaskId', Format(TaskId));
        FeatureTelemetry.LogUsage('0000CTK', EmailFeatureNameLbl, 'Email being rescheduled', Dimensions);
        Success := true;
    end;

    local procedure InsertToSentEmail(EmailOutbox: Record "Email Outbox"; var SentEmail: Record "Sent Email")
    begin
        Clear(SentEmail);
        SentEmail.TransferFields(EmailOutbox);
        Clear(SentEmail.Id);
        SentEmail."Date Time Sent" := CurrentDateTime();
        SentEmail.Insert();

        Commit();
    end;

    local procedure UpdateOutboxStatus(var EmailOutbox: Record "Email Outbox"; Status: Enum "Email Status")
    begin
        EmailOutbox.Status := Status;
        EmailOutbox.Modify();
        Commit();
    end;

    local procedure UpdateOutboxError(LastError: Text; var EmailOutbox: Record "Email Outbox")
    var
        EmailError: Record "Email Error";
        ErrorOutStream: OutStream;
    begin
        EmailError."Outbox Id" := EmailOutbox.Id;
        EmailError."Error Message".CreateOutStream(ErrorOutStream, TextEncoding::UTF8);
        ErrorOutStream.WriteText(LastError);
        EmailError."Error Callstack".CreateOutStream(ErrorOutStream, TextEncoding::UTF8);
        ErrorOutStream.WriteText(GetLastErrorCallStack());
        EmailError.Insert();

        EmailOutbox."Error Message" := CopyStr(LastError, 1, MaxStrLen(EmailOutbox."Error Message"));
        EmailOutbox."Date Failed" := CurrentDateTime();
        EmailOutbox.Modify();
    end;

    local procedure LogAttachments()
    begin
        if not EmailMessageImpl.Attachments_First() then
            exit;

        repeat
            Session.LogMessage('0000CTS', StrSubstNo(AttachmentMsg, EmailMessageImpl.Attachments_GetLength(), EmailMessageImpl.Attachments_GetContentType()), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailCategoryLbl, 'EmailMessageID', EmailMessageImpl.GetId());
        until EmailMessageImpl.Attachments_Next() = 0;
    end;

    procedure GetSuccess(): Boolean
    begin
        exit(Success);
    end;
}