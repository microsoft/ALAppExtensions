// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8900 "Email Impl"
{
    Access = Internal;
    Permissions = tabledata "Sent Email" = r,
                  tabledata "Email Outbox" = rim,
                  tabledata "Email Message" = r,
                  tabledata "Email Error" = r;

    var
        EmailSendNoRecipientsMsg: Label 'You must specify one or more recipients.';
        EmailMessageDoesNotExistMsg: Label 'The email message has been deleted by another user.';
        EmailAccountwasRemovedErr: Label 'The email account: %1 of type: %2 was removed', Comment = '%1 = Account Name, %2 = The type of the Account';

    procedure Enqueue(EmailMessageId: Guid)
    var
        EmptyConnector: Enum "Email Connector";
        EmptyGuid: Guid;
    begin
        Enqueue(EmailMessageId, EmptyGuid, EmptyConnector, false);
    end;

    procedure Enqueue(EmailMessageId: Guid; AccountId: Guid; EmailConnector: Enum "Email Connector")
    begin
        Enqueue(EmailMessageId, AccountId, EmailConnector, true);
    end;

    procedure Enqueue(EmailMessageId: Guid; AccountId: Guid; EmailConnector: Enum "Email Connector"; Queue: Boolean)
    var
        EmailOutbox: Record "Email Outbox";
        EmailMessage: Record "Email Message";
        TaskId: Guid;
    begin
        if not EmailMessage.Get(EmailMessageId) then
            Error(EmailMessageDoesNotExistMsg);

        CreateEmailOutbox(EmailMessageId, AccountId, EmailConnector, EmailMessage.Subject, Queue, EmailOutbox);

        if Queue then begin
            TaskId := TaskScheduler.CreateTask(Codeunit::"Email Dispatcher", 0, true, CompanyName(), CurrentDateTime(), EmailOutbox.RecordId());
            EmailOutbox."Task Scheduler Id" := TaskId;
            EmailOutbox.Modify();
        end;
    end;

    procedure Send(EmailMessageId: Guid; AccountId: Guid; EmailConnector: Enum "Email Connector"): Boolean
    var
        EmailOutbox: Record "Email Outbox";
        EmailMessage: Record "Email Message";
        EmailDispatcher: Codeunit "Email Dispatcher";
    begin
        if not EmailMessage.Get(EmailMessageId) then
            Error(EmailMessageDoesNotExistMsg);

        CreateEmailOutbox(EmailMessageId, AccountId, EmailConnector, EmailMessage.Subject, true, EmailOutbox);
        Commit();

        EmailDispatcher.Run(EmailOutbox);
        exit(EmailDispatcher.GetSuccess());
    end;

    procedure IsAnyConnectorInstalled(): Boolean
    var
        EmailConnector: Enum "Email Connector";
    begin
        exit(EmailConnector.Names.Count() > 0);
    end;

    internal procedure SendEmail(var EmailOutbox: Record "Email Outbox")
    var
        EmailRecipients: Record "Email Recipient";
    begin
        if EmailOutbox.Status = EmailOutbox.Status::Processing then
            exit;

        if IsNullGuid(EmailOutbox."Account Id") then
            exit;

        EmailRecipients.SetRange("Email Message Id", EmailOutbox."Message Id");
        if EmailRecipients.IsEmpty() then begin
            Message(EmailSendNoRecipientsMsg);
            exit;
        end;

        CreateEmailTask(EmailOutbox);
    end;

    internal procedure QueueEmail(var SentEmail: Record "Sent Email")
    var
        EmailOutbox: Record "Email Outbox";
    begin
        CreateEmailOutbox(SentEmail."Message Id", SentEmail."Account Id", SentEmail.Connector, SentEmail.Description, true, EmailOutbox);

        CreateEmailTask(EmailOutbox);
    end;

    internal procedure QueueEmailNow(var EmailOutbox: Record "Email Outbox")
    begin
        if EmailOutbox.Status = EmailOutbox.Status::Processing then
            exit;

        Codeunit.Run(Codeunit::"Email Dispatcher", EmailOutbox);
    end;

    local procedure CreateEmailOutbox(EmailMessageId: Guid; AccountId: Guid; EmailConnector: Enum "Email Connector"; EmailSubject: Text;
                                                                                                 Queue: Boolean; var EmailOutbox: Record "Email Outbox")
    var
        Accounts: Record "Email Account";
        Account: Codeunit "Email Account";
    begin
        if Queue then begin
            Account.GetAllAccounts(false, Accounts);
            if not Accounts.Get(AccountId) then
                Error(EmailAccountwasRemovedErr, Accounts.Name, Accounts.Connector);

            EmailOutbox."Send From" := Accounts."Email Address";
            EmailOutbox.Status := EmailOutbox.Status::Queued;
        end else
            EmailOutbox.Status := EmailOutbox.Status::Draft;

        EmailOutbox.Connector := EmailConnector;
        EmailOutbox."Message Id" := EmailMessageId;
        EmailOutbox."Account Id" := AccountId;
        EmailOutbox.Description := CopyStr(EmailSubject, 1, MaxStrLen(EmailOutbox.Description));
        EmailOutbox."User Security Id" := UserSecurityId();
        EmailOutbox."Date Queued" := CurrentDateTime();

        EmailOutbox.Insert();
    end;

    local procedure CreateEmailTask(var EmailOutbox: Record "Email Outbox")
    var
        TaskId: Guid;
    begin
        TaskId := TaskScheduler.CreateTask(Codeunit::"Email Dispatcher", 0, true, CompanyName(), CurrentDateTime(), EmailOutbox.RecordId());

        EmailOutbox."Task Scheduler Id" := TaskId;
        EmailOutbox.Status := EmailOutbox.Status::Queued;
        EmailOutbox.Modify();
    end;

    procedure FindLastErrorCallStack(EmailOutboxId: BigInteger): Text
    var
        EmailError: Record "Email Error";
        ErrorInstream: InStream;
        ErrorText: Text;
    begin
        EmailError.SetRange("Outbox Id", EmailOutboxId);
        EmailError.FindLast();
        EmailError.CalcFields(EmailError."Error Callstack");
        EmailError."Error Callstack".CreateInStream(ErrorInstream, TextEncoding::UTF8);
        ErrorInstream.ReadText(ErrorText);
        exit(ErrorText);
    end;

    procedure FindAllConnectors(var EmailConnector: Record "Email Connector")
    var
        Base64Convert: Codeunit "Base64 Convert";
        ConnectorInterface: Interface "Email Connector";
        Connector: Enum "Email Connector";
        ConnectorLogoBase64: Text;
        OutStream: Outstream;
    begin
        foreach Connector in Enum::"Email Connector".Ordinals() do begin
            ConnectorInterface := Connector;
            ConnectorLogoBase64 := ConnectorInterface.GetLogoAsBase64();
            EmailConnector.Connector := Connector;
            EmailConnector.Description := ConnectorInterface.GetDescription();
            if ConnectorLogoBase64 <> '' then begin
                EmailConnector.Logo.CreateOutStream(OutStream);
                Base64Convert.FromBase64(ConnectorLogoBase64, OutStream);
            end;
            EmailConnector.Insert();
        end;
    end;

    procedure RefreshEmailOutboxForUser(EmailStatus: Enum "Email Status"; var EmailOutboxForUser: Record "Email Outbox For User" temporary)
    var
        EmailOutbox: Record "Email Outbox";
        UserPermissions: Codeunit "User Permissions";
    begin
        if not EmailOutboxForUser.IsEmpty() then
            EmailOutboxForUser.DeleteAll();

        if not UserPermissions.IsSuper(UserSecurityId()) then
            EmailOutbox.SetRange("User Security Id", UserSecurityId());

        if EmailStatus.AsInteger() <> 0 then
            EmailOutboxForUser.SetRange(Status, EmailStatus);

        if EmailOutbox.FindSet() then
            repeat
                EmailOutboxForUser.TransferFields(EmailOutbox);
                EmailOutboxForUser.Insert();
            until EmailOutbox.Next() = 0;
    end;

    procedure RefreshSentMailForUser(AccountId: Guid; NewerThan: DateTime; var SentEmailForUser: Record "Sent Email For User")
    var
        SentEmail: Record "Sent Email";
        UserPermissions: Codeunit "User Permissions";
    begin
        if not SentEmailForUser.IsEmpty() then
            SentEmailForUser.DeleteAll();

        if not UserPermissions.IsSuper(UserSecurityId()) then
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

    internal procedure CountEmailsInOutbox(EmailStatus: Enum "Email Status"): Integer
    var
        EmailOutbox: Record "Email Outbox";
    begin
        EmailOutbox.SetRange(Status, EmailStatus);
        exit(EmailOutbox.Count());
    end;

    internal procedure CountSentEmails(NewerThan: DateTime): Integer
    var
        SentEmails: Record "Sent Email";
    begin
        SentEmails.SetRange("Date Time Sent", NewerThan, System.CurrentDateTime());
        exit(SentEmails.Count());
    end;
}
