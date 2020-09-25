// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 134685 "Email Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        EmailMessageDoesNotExistMsg: Label 'The email message has been deleted by another user.', Locked = true;

    [Test]
    [Scope('OnPrem')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure EnqueueNonExistingEmailFailsTest()
    var
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        RandomGuid: Guid;
    begin
        // [Scenario] When enqueuing an email that does not exit, there's an error

        // [Given] A GUID of an email that does not exist
        RandomGuid := System.CreateGuid();
        Assert.IsFalse(EmailMessage.Find(RandomGuid), 'The email should not exist');

        // [When] Enqueuing a non-existing email
        ClearLastError();
        asserterror Email.Enqueue(RandomGuid);

        // [Then] An error occurs
        Assert.ExpectedError(EmailMessageDoesNotExistMsg);
    end;

    [Test]
    [Scope('OnPrem')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure EnqueueExistingEmailWithNoAccountTest()
    var
        EmailOutbox: Record "Email Outbox";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmptyConnector: Enum "Email Connector";
        EmptyGuid: Guid;
    begin
        // [Scenario] When enqueuing an existing email, it appears in the outbox

        // [Given] A GUID of an email
        CreateEmail(EmailMessage);
        Assert.IsTrue(EmailMessage.Find(EmailMessage.GetId()), 'The email should exist');

        // [When] Enqueuing the email
        ClearLastError();
        Email.Enqueue(EmailMessage.GetId());

        // [Then] No error occurs
        Assert.AreEqual('', GetLastErrorText(), 'There should be no errors when enqueuing an email.');

        // [Then] The enqueued email should be the correct one 
        EmailOutbox.SetRange("Message Id", EmailMessage.GetId());
        Assert.AreEqual(1, EmailOutbox.Count(), 'There should be only one enqueued message');
        Assert.IsTrue(EmailOutbox.FindFirst(), 'The message should be queued');

        Assert.AreEqual(EmptyGuid, EmailOutbox."Account Id", 'The account should not be set');
        Assert.AreEqual(EmptyConnector, EmailOutbox.Connector, 'The connector should not be set');
        Assert.AreEqual(EmailOutbox.Status::"Draft", EmailOutbox.Status, 'The status should be ''Draft''');
        Assert.AreEqual(UserSecurityId(), EmailOutbox."User Security Id", 'The user security ID should be the current user');
        Assert.AreEqual(EmailMessage.GetSubject(), EmailOutbox.Description, 'The description does not match the email title');
        Assert.AreEqual('', EmailOutbox."Error Message", 'The error message should be blank');
    end;

    [Test]
    [Scope('OnPrem')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure EnqueueExistingEmailTest()
    var
        EmailOutbox: Record "Email Outbox";
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        Email: Codeunit Email;
        AccountId: Guid;
    begin
        // [Scenario] When enqueuing an existing email, it appears in the outbox

        // [Given] A GUID of an email
        CreateEmail(EmailMessage);
        Assert.IsTrue(EmailMessage.Find(EmailMessage.GetId()), 'The email should exist');

        // [When] Enqueuing the email
        ClearLastError();
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(AccountId);
        Email.Enqueue(EmailMessage.GetId(), AccountId, Enum::"Email Connector"::"Test Email Connector");

        // [Then] No error occurs
        Assert.AreEqual('', GetLastErrorText(), 'There should be no errors when enqueuing an email.');

        // [Then] The enqueued email should be the correct one 
        EmailOutbox.SetRange("Message Id", EmailMessage.GetId());
        Assert.AreEqual(1, EmailOutbox.Count(), 'There should be only one enqueued message');
        Assert.IsTrue(EmailOutbox.FindFirst(), 'The message should be queued');

        Assert.AreEqual(AccountId, EmailOutbox."Account Id", 'The account should not be set');
        Assert.AreEqual(Enum::"Email Connector"::"Test Email Connector", EmailOutbox.Connector, 'The connector should not be set');
        Assert.AreEqual(EmailOutbox.Status::Queued, EmailOutbox.Status, 'The status should be ''Queued''');
        Assert.AreEqual(UserSecurityId(), EmailOutbox."User Security Id", 'The user security ID should be the current user');
        Assert.AreEqual(EmailMessage.GetSubject(), EmailOutbox.Description, 'The description does not match the email title');
        Assert.AreEqual('', EmailOutbox."Error Message", 'The error message should be blank');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure DirectSendFailTest()
    var
        EmailOutbox: Record "Email Outbox";
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        Email: Codeunit Email;
        Connector: Enum "Email Connector";
        EmailStatus: Enum "Email Status";
        AccountId: Guid;
    begin
        // [Scenario] When sending an email on the foreground and the process fails, an error is shown

        // [Given] A GUID of an email
        CreateEmail(EmailMessage);
        Assert.IsTrue(EmailMessage.Find(EmailMessage.GetId()), 'The email should exist');

        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(AccountId);
        ConnectorMock.FailOnSend(true);

        // [When] Sending the email fails
        Assert.IsFalse(Email.Send(EmailMessage.GetId(), AccountId, Connector::"Test Email Connector"), 'Sending an email should have failed');

        // [Then] The error is as expected
        EmailOutbox.SetRange("Account Id", AccountId);
        EmailOutbox.SetRange("Message Id", EmailMessage.GetId());

        Assert.IsTrue(EmailOutbox.FindFirst(), 'The email outbox entry should exist');
        Assert.AreEqual(Connector::"Test Email Connector".AsInteger(), EmailOutbox.Connector.AsInteger(), 'Wrong connector');
        Assert.AreEqual(EmailStatus::Failed.AsInteger(), EmailOutbox.Status.AsInteger(), 'Wrong status');
        Assert.AreEqual('Failed to send email', EmailOutbox."Error Message", 'Wrong error message');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure DirectSendSuccessTest()
    var
        EmailOutbox: Record "Email Outbox";
        SentEmail: Record "Sent Email";
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        Email: Codeunit Email;
        Connector: Enum "Email Connector";
        AccountId: Guid;
    begin
        // [Scenario] When successfuly sending an email a Record is added on the Sent Emails table

        // [Given] A GUID of an email
        CreateEmail(EmailMessage);
        Assert.IsTrue(EmailMessage.Find(EmailMessage.GetId()), 'The email should exist');

        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(AccountId);

        // [When] Sending the email fails
        Assert.IsTrue(Email.Send(EmailMessage.GetId(), AccountId, Connector::"Test Email Connector"), 'Sending an email should have failed');

        // [Then] There is a Sent Mail recond and no Outbox record
        SentEmail.SetRange("Account Id", AccountId);
        SentEmail.SetRange("Message Id", EmailMessage.GetId());

        Assert.IsTrue(SentEmail.FindFirst(), 'The email sent record should exist');
        Assert.AreEqual(Connector::"Test Email Connector".AsInteger(), SentEmail.Connector.AsInteger(), 'Wrong connector');
        Assert.AreEqual(EmailMessage.GetSubject(), SentEmail.Description, 'Wrong connector');

        EmailOutbox.SetRange("Account Id", AccountId);
        EmailOutbox.SetRange("Message Id", EmailMessage.GetId());

        Assert.RecordIsEmpty(EmailOutbox);
    end;

    local procedure CreateEmail(var Message: Codeunit "Email Message")
    var
        Recipients: List of [Text];
    begin
        Recipients.Add('Test recipient');
        Message.CreateMessage(Recipients, 'Test Subject', 'Test Body', true);
    end;

}