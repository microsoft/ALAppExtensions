// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8906 "Email Editor"
{
    Access = Internal;
    Permissions = tabledata "Email Outbox" = rimd;

    procedure Open(EmailOutbox: Record "Email Outbox"; IsModal: Boolean): Enum "Email Action"
    var
        EmailEditor: Page "Email Editor";
    begin
        EmailEditor.SetRecord(EmailOutbox);

        if EmailOutbox.Description <> '' then
            EmailEditor.Caption := EmailOutbox.Description;

        if IsNewOutbox then
            EmailEditor.SetAsNew();

        if IsModal then begin
            EmailEditor.RunModal();
            exit(EmailEditor.GetAction());
        end
        else
            EmailEditor.Run();
    end;

    procedure CheckPermissions(EmailOutbox: Record "Email Outbox")
    begin
        if IsNullGuid(EmailOutbox."User Security Id") then
            exit;

        if EmailOutbox."User Security Id" = UserSecurityId() then
            exit;

        Error(EmailMessageOpenPermissionErr);
    end;

    procedure SetAsNew()
    begin
        IsNewOutbox := true;
    end;

    procedure GetEmailAccount(EmailOutbox: Record "Email Outbox"; var EmailAccount: Record "Email Account");
    var
        EmailAccounts: Codeunit "Email Account";
    begin
        EmailAccounts.GetAllAccounts(EmailAccount);

        if not EmailAccount.Get(EmailOutbox."Account Id", EmailOutbox.Connector) then
            Clear(EmailAccount);
    end;

    procedure GetEmailMessage(var EmailOutbox: Record "Email Outbox"; var EmailMessage: Codeunit "Email Message Impl.");
    begin
        if EmailMessage.Get(EmailOutbox."Message Id") then
            exit;

        EmailMessage.Create('', '', '', true);
        EmailOutbox."Message Id" := EmailMessage.GetId();
        EmailOutbox.Modify();
    end;

    procedure CreateOutbox(var EmailOutbox: Record "Email Outbox")
    var
        DefaultEmailAccount: Record "Email Account";
        EmailScenario: Codeunit "Email Scenario";
    begin
        EmailOutbox."User Security Id" := UserSecurityId();
        EmailOutbox.Status := Enum::"Email Status"::Draft;

        if EmailScenario.GetDefaultEmailAccount(DefaultEmailAccount) then begin
            EmailOutbox."Account Id" := DefaultEmailAccount."Account Id";
            EmailOutbox.Connector := DefaultEmailAccount.Connector;
        end;

        EmailOutbox.Insert();
    end;

    procedure ChangeEmailAccount(var EmailOutbox: Record "Email Outbox"; var ChosenEmailAccount: Record "Email Account")
    var
        EmailAccounts: Page "Email Accounts";
    begin
        EmailAccounts.EnableLookupMode();

        if not IsNullGuid(ChosenEmailAccount."Account Id") then
            EmailAccounts.SetAccount(ChosenEmailAccount);

        if EmailAccounts.RunModal() = Action::LookupOK then begin
            EmailAccounts.GetAccount(ChosenEmailAccount);

            EmailOutbox."Account Id" := ChosenEmailAccount."Account Id";
            EmailOutbox.Connector := ChosenEmailAccount.Connector;
            EmailOutbox.Modify();
        end;
    end;

    procedure UploadAttachment(EmailMessage: Codeunit "Email Message Impl.")
    var
        FileName: Text;
        Instream: Instream;
        AttachmentName, ContentType : Text[250];
        AttachamentSize: Integer;
    begin
        if not UploadIntoStream('', '', '', FileName, Instream) then
            exit;

        AttachmentName := CopyStr(FileName, 1, 250);
        ContentType := EmailMessage.GetContentTypeFromFilename(Filename);
        AttachamentSize := EmailMessage.AddAttachmentInternal(AttachmentName, ContentType, Instream);

        Session.LogMessage('0000CTX', StrSubstNo(UploadingAttachmentMsg, AttachamentSize, ContentType), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailCategoryLbl);
    end;

    procedure ValidateEmailData(FromEmailAddress: Text; var EmailMessage: Codeunit "Email Message Impl."): Boolean
    begin
        // Validate email account
        if FromEmailAddress = '' then
            Error(NoFromAccountErr);

        // Validate recipients
        EmailMessage.ValidateRecipients(Enum::"Email Recipient Type"::"To");
        EmailMessage.ValidateRecipients(Enum::"Email Recipient Type"::Cc);
        EmailMessage.ValidateRecipients(Enum::"Email Recipient Type"::Bcc);

        if EmailMessage.GetSubject() = '' then
            exit(Dialog.Confirm(NoSubjectlineQst, false));

        exit(true);
    end;

    procedure SendOutbox(var EmailOutbox: Record "Email Outbox")
    var
        Email: Codeunit "Email Impl";
        EmailMessage: Codeunit "Email Message";
    begin
        EmailMessage.Get(EmailOutbox."Message Id");

        if not Email.Send(EmailMessage, EmailOutbox."Account Id", EmailOutbox.Connector, EmailOutbox) then
            Error(SendingFailedErr, GetLastErrorText());
    end;

    procedure DiscardEmail(var EmailOutbox: Record "Email Outbox"; Confirm: Boolean): Boolean
    begin
        if Confirm then
            if not Confirm(ConfirmDiscardEmailQst, true) then
                exit(false);

        exit(EmailOutbox.Delete(true)); // This should detele the email message, recipients and attachments as well.
    end;

    var
        IsNewOutbox: Boolean;
        ConfirmDiscardEmailQst: Label 'Go ahead and discard?';
        EmailMessageOpenPermissionErr: Label 'You can only open your own email messages.';
        NoSubjectlineQst: Label 'Do you want to send this message without a subject?';
        NoFromAccountErr: Label 'You must specify an email account from which to send the message.';
        UploadingAttachmentMsg: Label 'Attached file with size: %1, Content type: %2', Comment = '%1 - File size, %2 - Content type', Locked = true;
        EmailCategoryLbl: Label 'Email', Locked = true;
        SendingFailedErr: Label 'The email was not sent because of the following error: "%1" \\Depending on the error, you might need to contact your administrator.', Comment = '%1 - the error that occurred.';
}