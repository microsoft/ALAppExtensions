// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8900 "Email Impl"
{
    Access = Internal;
    Permissions = tabledata "Sent Email" = rimd,
                  tabledata "Email Outbox" = rimd,
                  tabledata "Email Related Record" = rid,
                  tabledata "Email Message" = r,
                  tabledata "Email Error" = r,
                  tabledata "Email Recipient" = r;

    var
        EmailMessageDoesNotExistMsg: Label 'The email message has been deleted by another user.';
        EmailMessageCannotBeEditedErr: Label 'The email message has already been sent and cannot be edited.';
        EmailMessageQueuedErr: Label 'The email has already been queued.';
        EmailMessageSentErr: Label 'The email has already been sent.';
        InvalidEmailAccountErr: Label 'The provided email account does not exist.';
        InsufficientPermisionsErr: Label 'You do not have the permissions required to send emails. Ask your administrator to grant you the Read, Insert, Modify and Delete permissions for the Sent Email and Email Outbox tables.';
        SourceRecordErr: Label 'Could not find the source for this email.';

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

        if EmailMessageImpl.IsRead() then
            Error(EmailMessageCannotBeEditedErr);

        IsNew := not GetEmailOutbox(EmailMessageImpl.GetId(), EmailOutbox);
        IsEnqueued := (not IsNew) and IsOutboxEnqueued(EmailOutbox);

        if not IsEnqueued then begin
            // Modify the outbox only if it hasn't been enqueued yet
            CreateOrUpdateEmailOutbox(EmailMessageImpl, EmailAccountId, EmailConnector, Enum::"Email Status"::Draft, '', EmailOutbox);
            Commit(); // Commit the changes in case the message is to be open modally
        end;

        // Set the record as new so that there is a save prompt and no arrows
        if not IsEnqueued then
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

    local procedure EmailMessageSent(EmailMessageId: Guid): Boolean
    var
        SentEmail: Record "Sent Email";
    begin
        SentEmail.SetRange("Message Id", EmailMessageId);
        exit(not SentEmail.IsEmpty());
    end;

    local procedure Send(EmailMessage: Codeunit "Email Message"; EmailAccountId: Guid; EmailConnector: Enum "Email Connector"; InBackground: Boolean; var EmailOutbox: Record "Email Outbox"): Boolean
    var
        Accounts: Record "Email Account";
        Email: codeunit "Email";
        EmailAccount: Codeunit "Email Account";
        EmailMessageImpl: Codeunit "Email Message Impl.";
        EmailDispatcher: Codeunit "Email Dispatcher";
        TaskId: Guid;
    begin
        CheckRequiredPermissions();
        if not EmailMessageImpl.Get(EmailMessage.GetId()) then
            Error(EmailMessageDoesNotExistMsg);

        if GetEmailOutbox(EmailMessage.GetId(), EmailOutbox) and IsOutboxEnqueued(EmailOutbox) then
            Error(EmailMessageQueuedErr);

        if EmailMessageSent(EmailMessage.GetId()) then
            Error(EmailMessageSentErr);

        EmailMessageImpl.ValidateRecipients();

        // Validate email account
        EmailAccount.GetAllAccounts(false, Accounts);
        if not Accounts.Get(EmailAccountId, EmailConnector) then
            Error(InvalidEmailAccountErr);

        CreateOrUpdateEmailOutbox(EmailMessageImpl, EmailAccountId, EmailConnector, Enum::"Email Status"::Queued, Accounts."Email Address", EmailOutbox);

        Email.OnEnqueuedInOutbox(EmailMessage.GetId());

        if InBackground then begin
            TaskId := TaskScheduler.CreateTask(Codeunit::"Email Dispatcher", Codeunit::"Email Error Handler", true, CompanyName(), CurrentDateTime(), EmailOutbox.RecordId());
            EmailOutbox."Task Scheduler Id" := TaskId;
            EmailOutbox.Modify();
        end else begin // Send the email in foreground
            Commit();

            if EmailDispatcher.Run(EmailOutbox) then;
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
            EmailOutbox.SetRange(Status, EmailStatus);

        if EmailOutbox.FindSet() then
            repeat
                EmailOutboxForUser.TransferFields(EmailOutbox);
                EmailOutboxForUser.Insert();
            until EmailOutbox.Next() = 0;
    end;

    procedure ShowSourceRecord(EmailMessageId: Guid);
    var
        EmailRelatedRecord: Record "Email Related Record";
        Email: Codeunit Email;
        EmailRelationPicker: Page "Email Relation Picker";
        IsHandled: Boolean;
    begin
        EmailRelatedRecord.SetRange("Email Message Id", EmailMessageId);

        if not EmailRelatedRecord.FindFirst() then
            Error(SourceRecordErr);

        if EmailRelatedRecord.Count() > 1 then begin
            FilterRemovedSourceRecords(EmailRelatedRecord);
            EmailRelationPicker.SetTableView(EmailRelatedRecord);
            EmailRelationPicker.LookupMode(true);
            if EmailRelationPicker.RunModal() <> Action::LookupOK then
                exit;
            EmailRelationPicker.GetRecord(EmailRelatedRecord);
        end;

        Email.OnShowSource(EmailRelatedRecord."Table Id", EmailRelatedRecord."System Id", IsHandled);

        if not IsHandled then
            Error(SourceRecordErr);
    end;

    procedure FilterRemovedSourceRecords(var EmailRelatedRecord: Record "Email Related Record")
    var
        AllObj: Record AllObj;
        SourceReference: RecordRef;
    begin
        repeat
            if AllObj.Get(AllObj."Object Type"::Table, EmailRelatedRecord."Table Id") then begin
                SourceReference.Open(EmailRelatedRecord."Table Id");
                if SourceReference.GetBySystemId(EmailRelatedRecord."System Id") then
                    EmailRelatedRecord.Mark(true);
                SourceReference.Close();
            end;
        until EmailRelatedRecord.Next() = 0;
        EmailRelatedRecord.MarkedOnly(true);
    end;

    procedure GetSentEmailsForRecord(TableId: Integer; SystemId: Guid) ResultSentEmails: Record "Sent Email" temporary;
    begin
        GetSentEmailsForRecord(TableId, SystemId, ResultSentEmails);
    end;

    procedure GetSentEmailsForRecord(TableId: Integer; SystemId: Guid; var ResultSentEmails: Record "Sent Email" temporary)
    var
        SentEmails: Record "Sent Email";
        EmailRelatedRecord: Record "Email Related Record";
        EmailAccountImpl: Codeunit "Email Account Impl.";
    begin
        EmailRelatedRecord.SetRange("Table Id", TableId);
        EmailRelatedRecord.SetRange("System Id", SystemId);

        if not EmailRelatedRecord.FindSet() then
            exit;

        if not EmailAccountImpl.IsUserEmailAdmin() then
            SentEmails.SetRange("User Security Id", UserSecurityId());

        repeat
            SentEmails.SetCurrentKey("Message Id");
            SentEmails.SetRange("Message Id", EmailRelatedRecord."Email Message Id");
            if SentEmails.FindFirst() then begin
                ResultSentEmails := SentEmails;
                ResultSentEmails.Insert();
            end;
        until EmailRelatedRecord.Next() = 0;
    end;

    internal procedure CountEmailsInOutbox(EmailStatus: Enum "Email Status"; IsAdmin: Boolean): Integer
    var
        EmailOutbox: Record "Email Outbox";
    begin
        if not IsAdmin then
            EmailOutbox.SetRange("User Security Id", UserSecurityId());

        EmailOutbox.SetRange(Status, EmailStatus);
        exit(EmailOutbox.Count());
    end;

    internal procedure CountSentEmails(NewerThan: DateTime; IsAdmin: Boolean): Integer
    var
        SentEmails: Record "Sent Email";
    begin
        if not IsAdmin then
            SentEmails.SetRange("User Security Id", UserSecurityId());

        SentEmails.SetRange("Date Time Sent", NewerThan, System.CurrentDateTime());
        exit(SentEmails.Count());
    end;

    procedure AddRelation(EmailMessage: Codeunit "Email Message"; TableId: Integer; SystemId: Guid; RelationType: Enum "Email Relation Type")
    begin
        AddRelation(EmailMessage.GetId(), TableId, SystemId, RelationType);
    end;

    procedure AddRelation(EmailMessageId: Guid; TableId: Integer; SystemId: Guid; RelationType: Enum "Email Relation Type")
    var
        EmailRelation: Record "Email Related Record";
    begin
        if EmailRelation.Get(TableId, SystemId, EmailMessageId) then
            exit;

        EmailRelation."Email Message Id" := EmailMessageId;
        EmailRelation."Table Id" := TableId;
        EmailRelation."System Id" := SystemId;
        EmailRelation."Relation Type" := RelationType;
        EmailRelation.Insert();
    end;

    procedure OpenSentEmails(TableId: Integer; SystemId: Guid)
    var
        SentEmails: Page "Sent Emails";
    begin
        SentEmails.SetRelatedRecord(TableId, SystemId);
        SentEmails.Run();
    end;

    local procedure CheckRequiredPermissions()
    var
        SentEmail: Record "Sent Email";
        EmailOutBox: Record "Email Outbox";
    begin
        if not SentEmail.ReadPermission() or
                not SentEmail.WritePermission() or
                not EmailOutBox.ReadPermission() or
                not EmailOutBox.WritePermission() then
            Error(InsufficientPermisionsErr);
    end;

}
