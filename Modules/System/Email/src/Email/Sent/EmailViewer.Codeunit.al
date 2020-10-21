// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8907 "Email Viewer"
{
    Access = Internal;
    Permissions = tabledata "Sent Email" = ri;

    procedure Open(SentEmail: Record "Sent Email")
    var
        EmailViewer: Page "Email Viewer";
    begin
        EmailViewer.SetRecord(SentEmail);

        if SentEmail.Description <> '' then
            EmailViewer.Caption := SentEmail.Description;

        EmailViewer.Run();
    end;

    procedure Resend(SentEmail: Record "Sent Email")
    var
        Email: Codeunit Email;
        NewEmailMessageImpl, OldEmailMessageImpl : Codeunit "Email Message Impl.";
        NewEmailMessage: Codeunit "Email Message";
    begin
        if not OldEmailMessageImpl.Get(SentEmail."Message Id") then
            Error(EmailMessageDoesNotExistMsg);

        NewEmailMessageImpl.Create(OldEmailMessageImpl);
        NewEmailMessage.Get(NewEmailMessageImpl.GetId());

        Email.Enqueue(NewEmailMessage, SentEmail."Account Id", SentEmail.Connector);

        Message(EmailWasQueuedForSendingMsg);
    end;

    procedure CheckPermissions(SentEmail: Record "Sent Email")
    begin
        if IsNullGuid(SentEmail."User Security Id") then
            exit;

        if SentEmail."User Security Id" = UserSecurityId() then
            exit;

        Error(EmailMessageOpenPermissionErr);
    end;

    procedure EditAndSend(SentEmail: Record "Sent Email")
    var
        Email: Codeunit Email;
        NewEmailMessageImpl, OldEmailMessageImpl : Codeunit "Email Message Impl.";
        NewEmailMessage: Codeunit "Email Message";
    begin
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

    procedure GetEmailMessage(var SentEmail: Record "Sent Email"; var EmailMessage: Codeunit "Email Message Impl.");
    begin
        if not EmailMessage.Get(SentEmail."Message Id") then
            Error(EmailMessageDoesNotExistMsg);
    end;

    procedure RefreshSentMailForUser(AccountId: Guid; NewerThan: DateTime; var SentEmailForUser: Record "Sent Email" temporary)
    var
        SentEmail: Record "Sent Email";
        EmailAccountImpl: Codeunit "Email Account Impl.";
    begin
        if not SentEmailForUser.IsEmpty() then
            SentEmailForUser.DeleteAll();

        if not EmailAccountImpl.IsUserEmailAdmin() then
            SentEmail.SetRange("User Security Id", UserSecurityId());

        if not IsNullGuid(AccountId) then
            SentEmail.SetRange("Account Id", AccountId);

        if NewerThan <> 0DT then
            SentEmailForUser.SetRange("Date Time Sent", NewerThan, System.CurrentDateTime());

        if SentEmail.FindSet() then
            repeat
                SentEmailForUser.TransferFields(SentEmail);
                SentEmailForUser.Insert();
            until SentEmail.Next() = 0;
    end;

    var
        EmailMessageOpenPermissionErr: Label 'You can only open your own email messages.';
        EmailMessageDoesNotExistMsg: Label 'The email message has been deleted by another user.';
        EmailWasQueuedForSendingMsg: Label 'The message was queued for sending.';
}