// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8900 "Email Impl"
{
    Access = Internal;
    Permissions = tabledata "Sent Email" = rd,
                  tabledata "Email Outbox" = rimd,
                  tabledata "Email Message" = r,
                  tabledata "Email Error" = r,
                  tabledata "Email Recipient" = r;

    var
        EmailMessageDoesNotExistMsg: Label 'The email message has been deleted by another user.';
        EmailMessageCannotBeEditedErr: Label 'The email message has already been sent and cannot be edited.';
        InvalidEmailAccountErr: Label 'The provided email account does not exist.';

    #region API

    procedure SaveAsDraft(EmailMessage: Codeunit "Email Message")
    var
        EmailOutbox: Record "Email Outbox";
    begin
        SaveAsDraft(EmailMessage, EmailOutbox);
    end;

    procedure SaveAsDraft(EmailMessage: Codeunit "Email Message"; var EmailOutbox: Record "Email Outbox")
    var
        EmailMessageImpl: Codeunit "Email Message Impl.";
        EmptyConnector: Enum "Email Connector";
        EmptyGuid: Guid;
    begin
        if not EmailMessageImpl.Get(EmailMessage.GetId()) then
            Error(EmailMessageDoesNotExistMsg);

        if GetEmailOutbox(EmailMessage.GetId(), EmailOutbox) and IsOutboxEnqueued(EmailOutbox) then
            exit;

        CreateOrUpdateEmailOutbox(EmailMessageImpl, EmptyGuid, EmptyConnector, Enum::"Email Status"::Draft, '', EmailOutbox);
    end;

    procedure Enqueue(EmailMessage: Codeunit "Email Message"; EmailScenario: Enum "Email Scenario")
    var
        EmailAccount: Record "Email Account";
        EmailScenarios: Codeunit "Email Scenario";
    begin
        EmailScenarios.GetEmailAccount(EmailScenario, EmailAccount);

        Enqueue(EmailMessage, EmailAccount."Account Id", EmailAccount.Connector);
    end;

    procedure Enqueue(EmailMessage: Codeunit "Email Message"; EmailAccountId: Guid; EmailConnector: Enum "Email Connector")
    var
        EmailOutbox: Record "Email Outbox";
    begin
        Send(EmailMessage, EmailAccountId, EmailConnector, true, EmailOutbox);
    end;

    procedure Send(EmailMessage: Codeunit "Email Message"; EmailScenario: Enum "Email Scenario"): Boolean
    var
        EmailAccount: Record "Email Account";
        EmailScenarios: Codeunit "Email Scenario";
    begin
        EmailScenarios.GetEmailAccount(EmailScenario, EmailAccount);

        exit(Send(EmailMessage, EmailAccount."Account Id", EmailAccount.Connector));
    end;

    procedure Send(EmailMessage: Codeunit "Email Message"; EmailAccountId: Guid; EmailConnector: Enum "Email Connector"): Boolean
    var
        EmailOutbox: Record "Email Outbox";
    begin
        exit(Send(EmailMessage, EmailAccountId, EmailConnector, false, EmailOutbox));
    end;


    procedure Send(EmailMessage: Codeunit "Email Message"; EmailAccountId: Guid; EmailConnector: Enum "Email Connector"; var EmailOutbox: Record "Email Outbox"): Boolean
    begin
        exit(Send(EmailMessage, EmailAccountId, EmailConnector, false, EmailOutbox));
    end;

    procedure OpenInEditor(EmailMessage: Codeunit "Email Message"; EmailScenario: Enum "Email Scenario"; IsModal: Boolean): Enum "Email Action"
    var
        EmailAccount: Record "Email Account";
        EmailScenarios: Codeunit "Email Scenario";
    begin
        EmailScenarios.GetEmailAccount(EmailScenario, EmailAccount);

        exit(OpenInEditor(EmailMessage, EmailAccount."Account Id", EmailAccount.Connector, IsModal));
    end;

    procedure OpenInEditor(EmailMessage: Codeunit "Email Message"; EmailAccountId: Guid; EmailConnector: Enum "Email Connector"; IsModal: Boolean): Enum "Email Action"
    var
        EmailOutbox: Record "Email Outbox";
        EmailMessageImpl: Codeunit "Email Message Impl.";
        EmailEditor: Codeunit "Email Editor";
        IsNew, IsEnqueued : Boolean;
    begin
        if not EmailMessageImpl.Get(EmailMessage.GetId()) then
            Error(EmailMessageDoesNotExistMsg);

        if EmailMessageImpl.IsReadOnly() then
            Error(EmailMessageCannotBeEditedErr);

        IsNew := not GetEmailOutbox(EmailMessageImpl.GetId(), EmailOutbox);
        IsEnqueued := (not IsNew) and IsOutboxEnqueued(EmailOutbox);

        if not IsEnqueued then begin
            // Modify the outbox only if it hasn't been enqueued yet
            CreateOrUpdateEmailOutbox(EmailMessageImpl, EmailAccountId, EmailConnector, Enum::"Email Status"::Draft, '', EmailOutbox);
            Commit(); // Commit the changes in case the messageis to be open modally
        end;

        if IsNew then
            EmailEditor.SetAsNew();

        exit(EmailEditor.Open(EmailOutbox, IsModal));
    end;

    local procedure GetEmailOutbox(EmailMessageId: Guid; var EmailOutbox: Record "Email Outbox"): Boolean
    begin
        EmailOutbox.SetRange("Message Id", EmailMessageId);
        exit(EmailOutbox.FindFirst());
    end;

    local procedure IsOutboxEnqueued(EmailOutbox: Record "Email Outbox"): Boolean
    begin
        exit((EmailOutbox.Status in [Enum::"Email Status"::Queued, Enum::"Email Status"::Processing]));
    end;

    local procedure Send(EmailMessage: Codeunit "Email Message"; EmailAccountId: Guid; EmailConnector: Enum "Email Connector"; InBackground: Boolean; var EmailOutbox: Record "Email Outbox"): Boolean
    var
        Accounts: Record "Email Account";
        EmailAccount: Codeunit "Email Account";
        EmailMessageImpl: Codeunit "Email Message Impl.";
        EmailDispatcher: Codeunit "Email Dispatcher";
        TaskId: Guid;
    begin
        if not EmailMessageImpl.Get(EmailMessage.GetId()) then
            Error(EmailMessageDoesNotExistMsg);

        if GetEmailOutbox(EmailMessage.GetId(), EmailOutbox) and IsOutboxEnqueued(EmailOutbox) then
            exit;

        EmailMessageImpl.ValidateRecipients(Enum::"Email Recipient Type"::"To");
        EmailMessageImpl.ValidateRecipients(Enum::"Email Recipient Type"::Cc);
        EmailMessageImpl.ValidateRecipients(Enum::"Email Recipient Type"::Bcc);

        // Validate email account
        EmailAccount.GetAllAccounts(false, Accounts);
        if not Accounts.Get(EmailAccountId, EmailConnector) then
            Error(InvalidEmailAccountErr);

        CreateOrUpdateEmailOutbox(EmailMessageImpl, EmailAccountId, EmailConnector, Enum::"Email Status"::Queued, Accounts."Email Address", EmailOutbox);

        if InBackground then begin
            TaskId := TaskScheduler.CreateTask(Codeunit::"Email Dispatcher", 0, true, CompanyName(), CurrentDateTime(), EmailOutbox.RecordId());
            EmailOutbox."Task Scheduler Id" := TaskId;
            EmailOutbox.Modify();
        end else begin // Send the email in foreground
            Commit();

            EmailDispatcher.Run(EmailOutbox);
            exit(EmailDispatcher.GetSuccess());
        end;
    end;

    local procedure CreateOrUpdateEmailOutbox(EmailMessage: Codeunit "Email Message Impl."; AccountId: Guid; EmailConnector: Enum "Email Connector"; Status: Enum "Email Status";
                                                                SentFrom: Text; var EmailOutbox: Record "Email Outbox")
    begin
        if not GetEmailOutbox(EmailMessage.GetId(), EmailOutbox) then begin
            EmailOutbox."Message Id" := EmailMessage.GetId();
            EmailOutbox.Insert();
        end;

        EmailOutbox.Connector := EmailConnector;
        EmailOutbox."Account Id" := AccountId;
        EmailOutbox.Description := CopyStr(EmailMessage.GetSubject(), 1, MaxStrLen(EmailOutbox.Description));
        EmailOutbox."User Security Id" := UserSecurityId();
        EmailOutbox."Send From" := CopyStr(SentFrom, 1, MaxStrLen(EmailOutbox."Send From"));
        EmailOutbox.Status := Status;
        if Status = Enum::"Email Status"::Queued then
            EmailOutbox."Date Queued" := CurrentDateTime();

        EmailOutbox.Modify();
    end;

    #endregion

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

    procedure RefreshEmailOutboxForUser(EmailAccountId: Guid; EmailStatus: Enum "Email Status"; var EmailOutboxForUser: Record "Email Outbox" temporary)
    var
        EmailOutbox: Record "Email Outbox";
        EmailAccountImpl: Codeunit "Email Account Impl.";
    begin
        if not EmailOutboxForUser.IsEmpty() then
            EmailOutboxForUser.DeleteAll();

        if not EmailAccountImpl.IsUserEmailAdmin() then
            EmailOutbox.SetRange("User Security Id", UserSecurityId());

        // If opening Email Outbox page from Email Accounts, filter to selected account
        if not IsNullGuid(EmailAccountId) then
            EmailOutbox.SetRange("Account Id", EmailAccountId);

        if EmailStatus.AsInteger() <> 0 then
            EmailOutboxForUser.SetRange(Status, EmailStatus);

        if EmailOutbox.FindSet() then
            repeat
                EmailOutboxForUser.TransferFields(EmailOutbox);
                EmailOutboxForUser.Insert();
            until EmailOutbox.Next() = 0;
    end;

    internal procedure CountEmailsInOutbox(EmailStatus: Enum "Email Status"): Integer
    var
        EmailOutbox: Record "Email Outbox";
        EmailAccountImpl: Codeunit "Email Account Impl.";
    begin
        if not EmailAccountImpl.IsUserEmailAdmin() then
            EmailOutbox.SetRange("User Security Id", UserSecurityId());

        EmailOutbox.SetRange(Status, EmailStatus);
        exit(EmailOutbox.Count());
    end;

    internal procedure CountSentEmails(NewerThan: DateTime): Integer
    var
        SentEmails: Record "Sent Email";
        EmailAccountImpl: Codeunit "Email Account Impl.";
    begin
        if not EmailAccountImpl.IsUserEmailAdmin() then
            SentEmails.SetRange("User Security Id", UserSecurityId());

        SentEmails.SetRange("Date Time Sent", NewerThan, System.CurrentDateTime());
        exit(SentEmails.Count());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sandbox Cleanup", 'OnClearCompanyConfiguration', '', false, false)]
    local procedure DeleteEmailsForSandbox(CompanyName: Text)
    var
        SentEmail: Record "Sent Email";
        EmailOutbox: Record "Email Outbox";
    begin
        SentEmail.ChangeCompany(CompanyName);
        SentEmail.DeleteAll();

        EmailOutbox.ChangeCompany(CompanyName);
        EmailOutbox.DeleteAll();
    end;
}
