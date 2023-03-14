// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8907 "Email Viewer"
{
    Access = Internal;
    Permissions = tabledata "Sent Email" = ri,
                  tabledata "Email View Policy" = r;

    procedure Open(SentEmail: Record "Sent Email")
    var
        EmailViewer: Page "Email Viewer";
    begin
        CheckPermissions(SentEmail);
        EmailViewer.SetRecord(SentEmail);
        EmailViewer.Run();
    end;

    procedure Resend(SentEmail: Record "Sent Email")
    var
        Email: Codeunit Email;
        NewEmailMessageImpl, OldEmailMessageImpl : Codeunit "Email Message Impl.";
        NewEmailMessage: Codeunit "Email Message";
    begin
        CheckPermissions(SentEmail);

        if not OldEmailMessageImpl.Get(SentEmail."Message Id") then
            Error(EmailMessageDoesNotExistMsg);

        NewEmailMessageImpl.Create(OldEmailMessageImpl);
        NewEmailMessage.Get(NewEmailMessageImpl.GetId());

        Email.Enqueue(NewEmailMessage, SentEmail."Account Id", SentEmail.Connector);

        Message(EmailWasQueuedForSendingMsg);
    end;

    procedure CheckPermissions(SentEmail: Record "Sent Email")
    var
        EmailImpl: Codeunit "Email Impl";
        EmailViewPolicy: Interface "Email View Policy";
    begin
        EmailViewPolicy := EmailImpl.GetUserEmailViewPolicy();
        if EmailViewPolicy.HasAccess(SentEmail) then
            exit;

        Error(EmailMessageOpenPermissionErr);
    end;

    procedure EditAndSend(SentEmail: Record "Sent Email")
    var
        Email: Codeunit Email;
        NewEmailMessageImpl, OldEmailMessageImpl : Codeunit "Email Message Impl.";
        NewEmailMessage: Codeunit "Email Message";
    begin
        CheckPermissions(SentEmail);

        if not OldEmailMessageImpl.Get(SentEmail."Message Id") then
            Error(EmailMessageDoesNotExistMsg);

        NewEmailMessageImpl.Create(OldEmailMessageImpl);
        NewEmailMessage.Get(NewEmailMessageImpl.GetId());

        Email.OpenInEditor(NewEmailMessage, SentEmail."Account Id", SentEmail.Connector);
    end;

    procedure GetEmailAccount(SentEmail: Record "Sent Email"; var EmailAccount: Record "Email Account");
    var
        EmailAccounts: Codeunit "Email Account";
    begin
        EmailAccounts.GetAllAccounts(EmailAccount);

        if not EmailAccount.Get(SentEmail."Account Id", SentEmail.Connector) then
            Clear(EmailAccount);
    end;

    procedure GetEmailMessage(var SentEmail: Record "Sent Email"; var EmailMessageImpl: Codeunit "Email Message Impl.");
    begin
        if not EmailMessageImpl.Get(SentEmail."Message Id") then
            Error(EmailMessageDoesNotExistMsg);
    end;

    procedure RefreshSentMailForUser(AccountId: Guid; NewerThan: DateTime; SourceTableID: Integer; SourceSystemID: Guid; var SentEmailForUser: Record "Sent Email" temporary)
    var
        EmailImpl: Codeunit "Email Impl";
    begin
        EmailImpl.GetSentEmails(AccountId, NewerThan, SourceTableID, SourceSystemID, SentEmailForUser);
    end;

    var
        EmailMessageOpenPermissionErr: Label 'You do not have permission to open the email message.';
        EmailMessageDoesNotExistMsg: Label 'The email message has been deleted by another user.';
        EmailWasQueuedForSendingMsg: Label 'The message was queued for sending.';
}