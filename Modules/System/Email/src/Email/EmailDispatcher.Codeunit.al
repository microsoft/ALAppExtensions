// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8888 "Email Dispatcher"
{
    Access = Internal;
    TableNo = "Email Outbox";
    Permissions = tabledata "Sent Email" = i,
                  tabledata "Email Outbox" = rimd,
                  tabledata "Email Message" = r,
                  tabledata "Email Error" = ri;

    var
        EmailMessageImpl: Codeunit "Email Message Impl.";
        Success: Boolean;
        EmailCategoryLbl: Label 'Email', Locked = true;
        EmailFeatureNameLbl: Label 'Emailing', Locked = true;
        SuccessfullySentEmailMsg: Label 'Email sent successfully', Locked = true;
        SuccessfullySentEmailDetailedMsg: Label 'The email %1 was successfully sent using the %2 email connector.', Comment = '%1 - Email Message Id, %2 - Connector', Locked = true;
        FailedToSendEmailErrorMsg: Label 'Could not send the email %1 because of the following error: %2. Call stack: %3.', Comment = '%1 - Email Message Id, %2 - Error message, %3 - Error call stack', Locked = true;
        FailedToFindEmailMessageMsg: Label 'Failed to find email message %1', Comment = '%1 - Email Message Id', Locked = true;
        FailedToFindEmailMessageErrorMsg: Label 'The email message has been deleted by another user.';
        AttachmentMsg: Label 'Sending email with attachment file size: %1, Content type: %2', Comment = '%1 - File size, %2 - Content type', Locked = true;

    trigger OnRun()
    var
        EmailMessage: Record "Email Message";
        SendEmail: Codeunit "Send Email";
        Email: Codeunit Email;
        ClientTypeManagement: Codeunit "Client Type Management";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        Dimensions: Dictionary of [Text, Text];
    begin
        Dimensions.Add('Connector', Format(Rec.Connector));
        Dimensions.Add('EmailMessageID', Format(Rec."Message Id", 0, 4));
        Dimensions.Add('EmailAccountID', Format(Rec."Account Id", 0, 4));
        Dimensions.Add('Category', EmailCategoryLbl);

        Session.LogMessage('0000CTM', Format(Rec.Connector), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, Dimensions);

        // -----------
        // NB: Avoid adding events here as any error would cause a roll-back and possibly an inconsistent state of the Email Outbox.
        // -----------

        UpdateOutboxStatus(Rec, Rec.Status::Processing);

        if EmailMessageImpl.Get(Rec."Message Id") then begin
            LogAttachments();

            SendEmail.SetTelemetryDimensions(Dimensions);
            SendEmail.SetConnector(Rec.Connector);
            SendEmail.SetAccount(Rec."Account Id");

            EmailMessageImpl.GetEmailMessage(EmailMessage);
            Success := SendEmail.Run(EmailMessage);

            if Success then begin
                Session.LogMessage('0000CTV', SuccessfullySentEmailMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, Dimensions);
                Session.LogMessage('0000CTO', StrSubstNo(SuccessfullySentEmailDetailedMsg, Rec."Message Id", Rec.Connector), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, Dimensions);
                FeatureTelemetry.LogUsage('0000CTQ', EmailFeatureNameLbl, 'Email sent');

                InsertToSentEmail(Rec);

                Rec.Delete();
                EmailMessageImpl.MarkAsRead();
                Commit();
            end
            else begin
                Dimensions.Add('ErrorText', GetLastErrorText(true));
                Dimensions.Add('ErrorCallStack', GetLastErrorCallStack());
                Session.LogMessage('0000CTP', StrSubstNo(FailedToSendEmailErrorMsg, Rec."Message Id", GetLastErrorText(true), GetLastErrorCallStack()), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, Dimensions);
                FeatureTelemetry.LogError('0000CTB', EmailFeatureNameLbl, 'Failed to send email', GetLastErrorText(true), GetLastErrorCallStack());

                UpdateOutboxError(GetLastErrorText(), Rec);
                UpdateOutboxStatus(Rec, Rec.Status::Failed);
            end;
        end
        else begin
            Session.LogMessage('0000CTR', StrSubstNo(FailedToFindEmailMessageMsg, Rec."Message Id"), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, Dimensions);
            UpdateOutboxError(FailedToFindEmailMessageErrorMsg, Rec);
            UpdateOutboxStatus(Rec, Rec.Status::Failed);
        end;

        if (ClientTypeManagement.GetCurrentClientType() = ClientType::Background) then
            Email.OnAfterSendEmail(Rec."Message Id", Success);
    end;

    local procedure InsertToSentEmail(EmailOutbox: Record "Email Outbox")
    var
        SentEmail: Record "Sent Email";
    begin
        SentEmail.TransferFields(EmailOutbox);
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