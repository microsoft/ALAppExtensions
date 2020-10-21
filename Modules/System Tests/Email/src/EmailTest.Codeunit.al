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
        Email: Codeunit Email;
        Base64Convert: Codeunit "Base64 Convert";
        EmailMessageDoesNotExistMsg: Label 'The email message has been deleted by another user.', Locked = true;
        EmailMessageOpenPermissionErr: Label 'You can only open your own email messages.';
        EmailMessageCannotBeEditedErr: Label 'The email message has already been sent and cannot be edited.';
        EmailMessageQueuedCannotDeleteAttachmentErr: Label 'Cannot delete the attachment because the email has been queued to be sent.';
        EmailMessageSentCannotDeleteAttachmentErr: Label 'Cannot delete the attachment because the email has already been sent.';
        AccountNameLbl: Label '%1 (%2)', Locked = true;

    [Test]
    [Scope('OnPrem')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure NonExistingEmailMessageFailsTest()
    var
        Message: Record "Email Message";
        EmailMessage: Codeunit "Email Message";
    begin
        // [Scenario] User cannot save as draft, enqueue, send or open (in editor) a non-existing email message

        // [Given] Create an Email Message and delete the underlying record
        CreateEmail(EmailMessage);
        Assert.IsTrue(Message.Get(EmailMessage.GetId()), 'The record should have been created');
        Message.Delete();

        Assert.IsFalse(EmailMessage.Get(EmailMessage.GetId()), 'The email should not exist');

        // [When] Saving a non-existing email message as draft
        ClearLastError();
        asserterror Email.SaveAsDraft(EmailMessage);

        // [Then] An error occurs
        Assert.ExpectedError(EmailMessageDoesNotExistMsg);

        // [When] Enqueuing a non-existing email message
        ClearLastError();
        asserterror Email.Enqueue(EmailMessage);

        // [Then] An error occurs
        Assert.ExpectedError(EmailMessageDoesNotExistMsg);

        // [When] Sending a non-existing email message
        ClearLastError();
        asserterror Email.Send(EmailMessage);

        // [Then] An error occurs
        Assert.ExpectedError(EmailMessageDoesNotExistMsg);

        // [When] Opening a non-existing email message
        ClearLastError();
        asserterror Email.OpenInEditor(EmailMessage);

        // [Then] An error occurs
        Assert.ExpectedError(EmailMessageDoesNotExistMsg);

        // [When] Opening a non-existing email message modally
        ClearLastError();
        asserterror Email.OpenInEditorModally(EmailMessage);

        // [Then] An error occurs
        Assert.ExpectedError(EmailMessageDoesNotExistMsg);
    end;

    [Test]
    [Scope('OnPrem')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure SaveAsDraftEmailMessage()
    var
        EmailOutbox: Record "Email Outbox";
        EmailMessage: Codeunit "Email Message";
        EmptyConnector: Enum "Email Connector";
        EmptyGuid: Guid;
    begin
        // [Scenario] When saving an existing email as draft, it appears in the outbox

        // [Given] An email message
        CreateEmail(EmailMessage);
        Assert.IsTrue(EmailMessage.Get(EmailMessage.GetId()), 'The email message should exist');

        // [When] Saving the email message as draft
        ClearLastError();
        Email.SaveAsDraft(EmailMessage);

        // [Then] No error occurs
        Assert.AreEqual('', GetLastErrorText(), 'There should be no errors when saving an email.');

        // [Then] The draft email should be correct 
        EmailOutbox.SetRange("Message Id", EmailMessage.GetId());
        Assert.AreEqual(1, EmailOutbox.Count(), 'There should be only one draft email');
        Assert.IsTrue(EmailOutbox.FindFirst(), 'The message should be in the outbox');

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
    procedure SaveAsDraftEmailMessageTwice()
    var
        EmailOutbox: Record "Email Outbox";
        EmailMessage: Codeunit "Email Message";
        EmptyConnector: Enum "Email Connector";
        EmptyGuid: Guid;
    begin
        // [Scenario] When enqueuing an existing email, it appears in the outbox

        // [Given] A GUID of an email
        CreateEmail(EmailMessage);
        Assert.IsTrue(EmailMessage.Get(EmailMessage.GetId()), 'The email message should exist');

        // [When] Enqueuing the email
        ClearLastError();
        Email.SaveAsDraft(EmailMessage);

        // [Then] No error occurs
        Assert.AreEqual('', GetLastErrorText(), 'There should be no errors when saving the email message.');

        // [Then] The draft email should be the correct one 
        EmailOutbox.SetRange("Message Id", EmailMessage.GetId());
        Assert.AreEqual(1, EmailOutbox.Count(), 'There should be only one enqueued message');
        Assert.IsTrue(EmailOutbox.FindFirst(), 'The message should be queued');

        Assert.AreEqual(EmptyGuid, EmailOutbox."Account Id", 'The account should not be set');
        Assert.AreEqual(EmptyConnector, EmailOutbox.Connector, 'The connector should not be set');
        Assert.AreEqual(EmailOutbox.Status::"Draft", EmailOutbox.Status, 'The status should be ''Draft''');
        Assert.AreEqual(UserSecurityId(), EmailOutbox."User Security Id", 'The user security ID should be the current user');
        Assert.AreEqual(EmailMessage.GetSubject(), EmailOutbox.Description, 'The description does not match the email title');
        Assert.AreEqual('', EmailOutbox."Error Message", 'The error message should be blank');

        // [When] Saving the email message again
        ClearLastError();
        Email.SaveAsDraft(EmailMessage);

        // [Then] No error occurs
        Assert.AreEqual('', GetLastErrorText(), 'There should be no errors when saving the email message again.');

        // [Then] The draft email should be the correct one 
        EmailOutbox.SetRange("Message Id", EmailMessage.GetId());
        Assert.AreEqual(1, EmailOutbox.Count(), 'There should be only one draft message');
        Assert.IsTrue(EmailOutbox.FindFirst(), 'The message should be queued');

        Assert.AreEqual(EmptyGuid, EmailOutbox."Account Id", 'The account should not be set');
        Assert.AreEqual(EmptyConnector, EmailOutbox.Connector, 'The connector should not be set');
        Assert.AreEqual(EmailOutbox.Status::"Draft", EmailOutbox.Status, 'The status should be ''Draft''');
        Assert.AreEqual(UserSecurityId(), EmailOutbox."User Security Id", 'The user security ID should be the current user');
        Assert.AreEqual(EmailMessage.GetSubject(), EmailOutbox.Description, 'The description does not match the email title');
        Assert.AreEqual('', EmailOutbox."Error Message", 'The error message should be blank');
    end;

    [Test]
    [HandlerFunctions('CloseEmailEditorHandler')]
    procedure OpenMessageInEditorTest()
    var
        TempAccount: Record "Email Account" temporary;
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        EmailEditor: TestPage "Email Editor";
        Recipients: List of [Text];
    begin
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        Recipients.Add('recipient1@test.com');
        Recipients.Add('recipient2@test.com');
        EmailMessage.Create(Recipients, 'Test subject', 'Test body', true);
        EmailMessage.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));
        EmailMessage.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));

        // Exercise
        EmailEditor.Trap();
        Email.OpenInEditor(EmailMessage);

        // Verify
        Assert.AreEqual('', EmailEditor.Account.Value(), 'Account field was not blank.');
        Assert.AreEqual('recipient1@test.com;recipient2@test.com', EmailEditor.ToField.Value(), 'A different To was expected');
        Assert.AreEqual('Test subject', EmailEditor.SubjectField.Value(), 'A different subject was expected.');
        Assert.AreEqual('Test body', EmailEditor.BodyField.Value(), 'A different body was expected.');
        Assert.AreEqual('', EmailEditor.CcField.Value(), 'Cc field was not blank.');
        Assert.AreEqual('', EmailEditor.BccField.Value(), 'Bcc field was not blank.');

        Assert.IsTrue(EmailEditor.Attachments.First(), 'First Attachment was not found.');
        Assert.AreEqual('Attachment1', EmailEditor.Attachments.FileName.Value(), 'A different attachment filename was expected');
        Assert.IsTrue(EmailEditor.Attachments.Next(), 'Second Attachment was not found.');
        Assert.AreEqual('Attachment1', EmailEditor.Attachments.FileName.Value(), 'A different attachment filename was expected');

        // Exercise
        EmailEditor.Trap();
        Email.OpenInEditor(EmailMessage, TempAccount);

        // Verify
        Assert.AreEqual(StrSubstNo(AccountNameLbl, TempAccount.Name, TempAccount."Email Address"), EmailEditor.Account.Value(), 'A different account was expected');
        Assert.AreEqual('recipient1@test.com;recipient2@test.com', EmailEditor.ToField.Value(), 'A different To was expected');
        Assert.AreEqual('Test subject', EmailEditor.SubjectField.Value(), 'A different subject was expected.');
        Assert.AreEqual('Test body', EmailEditor.BodyField.Value(), 'A different body was expected.');
        Assert.AreEqual('', EmailEditor.CcField.Value(), 'Cc field was not blank.');
        Assert.AreEqual('', EmailEditor.BccField.Value(), 'Bcc field was not blank.');

        Assert.IsTrue(EmailEditor.Attachments.First(), 'First Attachment was not found.');
        Assert.AreEqual('Attachment1', EmailEditor.Attachments.FileName.Value(), 'A different attachment filename was expected');
        Assert.IsTrue(EmailEditor.Attachments.Next(), 'Second Attachment was not found.');
        Assert.AreEqual('Attachment1', EmailEditor.Attachments.FileName.Value(), 'A different attachment filename was expected');

        // Exercise
        EmailEditor.Trap();
        Email.OpenInEditor(EmailMessage, TempAccount);

        // Verify
        Assert.AreEqual(StrSubstNo(AccountNameLbl, TempAccount.Name, TempAccount."Email Address"), EmailEditor.Account.Value(), 'A different account was expected');
        Assert.AreEqual('recipient1@test.com;recipient2@test.com', EmailEditor.ToField.Value(), 'A different To was expected');
        Assert.AreEqual('Test subject', EmailEditor.SubjectField.Value(), 'A different subject was expected.');
        Assert.AreEqual('Test body', EmailEditor.BodyField.Value(), 'A different body was expected.');
        Assert.AreEqual('', EmailEditor.CcField.Value(), 'Cc field was not blank.');
        Assert.AreEqual('', EmailEditor.BccField.Value(), 'Bcc field was not blank.');

        Assert.IsTrue(EmailEditor.Attachments.First(), 'First Attachment was not found.');
        Assert.AreEqual('Attachment1', EmailEditor.Attachments.FileName.Value(), 'A different attachment filename was expected');
        Assert.IsTrue(EmailEditor.Attachments.Next(), 'Second Attachment was not found.');
        Assert.AreEqual('Attachment1', EmailEditor.Attachments.FileName.Value(), 'A different attachment filename was expected');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OpenMessageInEditorForAQueuedMessageTest()
    var
        TempAccount: Record "Email Account" temporary;
        EmailOutBox: Record "Email Outbox";
        EmailAttachment: Record "Email Message Attachment";
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        EmailEditor: TestPage "Email Editor";
    begin
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);
        CreateEmail(EmailMessage);
        EmailMessage.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));
        EmailMessage.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));

        EmailOutBox.Init();
        EmailOutBox."Account Id" := TempAccount."Account Id";
        EmailOutBox.Connector := Enum::"Email Connector"::"Test Email Connector";
        EmailOutBox."Message Id" := EmailMessage.GetId();
        EmailOutBox.Status := Enum::"Email Status"::Queued;
        EmailOutBox."User Security Id" := UserSecurityId();
        EmailOutBox.Insert();

        // Exercise
        EmailEditor.Trap();
        Email.OpenInEditor(EmailMessage);

        // Verify
        Assert.IsFalse(EmailEditor.Account.Enabled(), 'Account field was enabled');
        Assert.IsFalse(EmailEditor.ToField.Editable(), 'To field was editable');
        Assert.IsFalse(EmailEditor.CcField.Editable(), 'Cc field was editable');
        Assert.IsFalse(EmailEditor.BccField.Editable(), 'Bcc field was editable');
        Assert.IsFalse(EmailEditor.SubjectField.Editable(), 'Subject field was editable');
        Assert.IsFalse(EmailEditor.BodyField.Editable(), 'Body field was editable');
        Assert.IsFalse(EmailEditor.Upload.Enabled(), 'Upload Action was not disabled.');
        Assert.IsFalse(EmailEditor.Send.Enabled(), 'Send Action was not disabled.');

        EmailOutBox.Status := Enum::"Email Status"::Processing;
        EmailOutBox.Modify();

        // Exercise
        EmailEditor.Trap();
        Email.OpenInEditor(EmailMessage);

        // Verify
        Assert.IsFalse(EmailEditor.Account.Enabled(), 'Account field was enabled');
        Assert.IsFalse(EmailEditor.ToField.Editable(), 'To field was editable');
        Assert.IsFalse(EmailEditor.CcField.Editable(), 'Cc field was editable');
        Assert.IsFalse(EmailEditor.BccField.Editable(), 'Bcc field was editable');
        Assert.IsFalse(EmailEditor.SubjectField.Editable(), 'Subject field was editable');
        Assert.IsFalse(EmailEditor.BodyField.Editable(), 'Body field was editable');
        Assert.IsFalse(EmailEditor.Upload.Enabled(), 'Upload Action was not disabled.');
        Assert.IsFalse(EmailEditor.Send.Enabled(), 'Send Action was not disabled.');
        EmailAttachment.SetRange("Email Message Id", EmailMessage.GetId());
        EmailAttachment.FindFirst();
        asserterror EmailAttachment.Delete();
        Assert.ExpectedError(EmailMessageQueuedCannotDeleteAttachmentErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OpenMessageInEditorForAQueuedMessageOwnedByAnotherUserTest()
    var
        TempAccount: Record "Email Account" temporary;
        EmailOutBox: Record "Email Outbox";
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        EmailEditor: TestPage "Email Editor";
    begin
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        CreateEmail(EmailMessage);

        EmailOutBox.Init();
        EmailOutBox."Account Id" := TempAccount."Account Id";
        EmailOutBox.Connector := Enum::"Email Connector"::"Test Email Connector";
        EmailOutBox."Message Id" := EmailMessage.GetId();
        EmailOutBox.Status := Enum::"Email Status"::Queued;
        EmailOutbox."User Security Id" := 'd0a983f4-0fc8-4982-8e02-ee9294ab28da'; // Created by another user
        EmailOutBox.Insert();

        // Exercise/Verify
        EmailEditor.Trap();
        asserterror Email.OpenInEditor(EmailMessage);
        Assert.ExpectedError(EmailMessageOpenPermissionErr);
    end;

    [Test]
    procedure OpenSentMessageInEditorTest()
    var
        TempAccount: Record "Email Account" temporary;
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        EmailEditor: TestPage "Email Editor";
    begin
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        CreateEmail(EmailMessage);

        Email.Send(EmailMessage, TempAccount);

        // Exercise/Verify
        EmailEditor.Trap();
        asserterror Email.OpenInEditor(EmailMessage);
        Assert.ExpectedError(EmailMessageCannotBeEditedErr);
    end;


    [Test]
    [HandlerFunctions('EmailEditorHandler,OnEmailEditorClose')]
    procedure OpenInEditorModallyDiscardAOptionTest()
    var
        TempAccount: Record "Email Account" temporary;
        EmailOutbox: Record "Email Outbox";
        SentEmail: Record "Sent Email";
        Message: Record "Email Message";
        Attachment: Record "Email Message Attachment";
        Recipient: Record "Email Recipient";
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        EmailAction: Enum "Email Action";
    begin
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        CreateEmail(EmailMessage);
        EmailMessage.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));

        OptionChoice := 2; // Discard email
        EmailAction := Email.OpenInEditorModally(EmailMessage, TempAccount);

        // Exercise/Verify 
        // See EmailEditorHandler

        // When the message was discarded, there should be no leftover records
        Assert.AreEqual(Enum::"Email Action"::Discarded, EmailAction, 'Wrong email action returned');

        Assert.IsFalse(EmailMessage.Get(EmailMessage.GetId()), 'The email message should not exist');
        Assert.IsFalse(Message.Get(EmailMessage.GetId()), 'The email message record should not exist');

        EmailOutbox.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(EmailOutbox.IsEmpty(), 'There should be no outbox to the discarded message');

        SentEmail.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(SentEmail.IsEmpty(), 'There should be no sent email to the discarded message');

        Recipient.SetRange("Email Message Id", EmailMessage.GetId());
        Assert.IsTrue(Recipient.IsEmpty(), 'There should be no recipient to the discarded message');

        Attachment.SetRange("Email Message Id", EmailMessage.GetId());
        Assert.IsTrue(Attachment.IsEmpty(), 'There should be no attachments to the discarded message');
    end;

    [Test]
    [HandlerFunctions('EmailEditorHandler,OnEmailEditorClose')]
    procedure OpenInEditorModallySaveAsDraftOptionTest()
    var
        TempAccount: Record "Email Account" temporary;
        EmailOutbox: Record "Email Outbox";
        SentEmail: Record "Sent Email";
        Message: Record "Email Message";
        Attachment: Record "Email Message Attachment";
        Recipient: Record "Email Recipient";
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        EmailAction: Enum "Email Action";
    begin
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        CreateEmail(EmailMessage);
        EmailMessage.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));

        OptionChoice := 1; // Keep as draft
        EmailAction := Email.OpenInEditorModally(EmailMessage, TempAccount);

        // Exercise/Verify 
        // See EmailEditorHandler

        // Exercise 
        // When the message was saved as draft (see OnEmailEditorClose)

        // Verify
        Assert.AreEqual(Enum::"Email Action"::"Saved As Draft", EmailAction, 'Wrong email action returned');

        Assert.IsTrue(EmailMessage.Get(EmailMessage.GetId()), 'The email message should exist');
        Assert.IsTrue(Message.Get(EmailMessage.GetId()), 'The email message record should exist');

        EmailOutbox.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsFalse(EmailOutbox.IsEmpty(), 'There should be an outbox to the message');

        SentEmail.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(SentEmail.IsEmpty(), 'There should be no sent email to the message');

        Recipient.SetRange("Email Message Id", EmailMessage.GetId());
        Assert.IsFalse(Recipient.IsEmpty(), 'There should be a recipient to the message');

        Attachment.SetRange("Email Message Id", EmailMessage.GetId());
        Assert.IsFalse(Attachment.IsEmpty(), 'There should be an attachment to the discarded message');
    end;

    [Test]
    [HandlerFunctions('SendEmailEditorHandler')]
    procedure OpenInEditorModallySendActionTest()
    var
        TempAccount: Record "Email Account" temporary;
        EmailOutbox: Record "Email Outbox";
        SentEmail: Record "Sent Email";
        Message: Record "Email Message";
        Attachment: Record "Email Message Attachment";
        Recipient: Record "Email Recipient";
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        EmailAction: Enum "Email Action";
    begin
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        CreateEmail(EmailMessage);
        EmailMessage.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));

        EmailAction := Email.OpenInEditorModally(EmailMessage, TempAccount);

        // Exercise 
        // See SendEmailEditorHandlers

        // Verify
        Assert.AreEqual(Enum::"Email Action"::Sent, EmailAction, 'Wrong email action returned');

        Assert.IsTrue(EmailMessage.Get(EmailMessage.GetId()), 'The email message should exist');
        Assert.IsTrue(Message.Get(EmailMessage.GetId()), 'The email message record should exist');

        EmailOutbox.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(EmailOutbox.IsEmpty(), 'There should be no outbox to the message');

        SentEmail.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsFalse(SentEmail.IsEmpty(), 'There should be a sent email to the message');

        Recipient.SetRange("Email Message Id", EmailMessage.GetId());
        Assert.IsFalse(Recipient.IsEmpty(), 'There should be a recipient to the message');

        Attachment.SetRange("Email Message Id", EmailMessage.GetId());
        Assert.IsFalse(Attachment.IsEmpty(), 'There should be an attachment to the discarded message');
    end;

    [Test]
    [HandlerFunctions('DiscardEmailEditorHandler,ConfirmYes')]
    procedure OpenInEditorModallyDiscardActionTest()
    var
        TempAccount: Record "Email Account" temporary;
        EmailOutbox: Record "Email Outbox";
        SentEmail: Record "Sent Email";
        Message: Record "Email Message";
        Attachment: Record "Email Message Attachment";
        Recipient: Record "Email Recipient";
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        EmailAction: Enum "Email Action";
    begin
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        CreateEmail(EmailMessage);
        EmailMessage.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));

        EmailAction := Email.OpenInEditorModally(EmailMessage, TempAccount);

        // Exercise 
        // See DiscardEmailEditorHandler

        // Verify
        Assert.AreEqual(Enum::"Email Action"::Discarded, EmailAction, 'Wrong email action returned');

        Assert.IsFalse(EmailMessage.Get(EmailMessage.GetId()), 'The email message should not exist');
        Assert.IsFalse(Message.Get(EmailMessage.GetId()), 'The email message record should not exist');

        EmailOutbox.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(EmailOutbox.IsEmpty(), 'There should be no outbox to the message');

        SentEmail.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(SentEmail.IsEmpty(), 'There should be no sent email to the message');

        Recipient.SetRange("Email Message Id", EmailMessage.GetId());
        Assert.IsTrue(Recipient.IsEmpty(), 'There should be no recipient to the message');

        Attachment.SetRange("Email Message Id", EmailMessage.GetId());
        Assert.IsTrue(Attachment.IsEmpty(), 'There should be no attachment to the discarded message');
    end;

    [Test]
    [Scope('OnPrem')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure EnqueueExistingEmailTest()
    var
        EmailOutbox: Record "Email Outbox";
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        AccountId: Guid;
    begin
        // [Scenario] When enqueuing an existing email, it appears in the outbox

        // [Given] An email message and an email account
        CreateEmail(EmailMessage);
        Assert.IsTrue(EmailMessage.Get(EmailMessage.GetId()), 'The email should exist');
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(AccountId);

        // [When] Enqueuing the email message with the email account
        ClearLastError();
        Email.Enqueue(EmailMessage, AccountId, Enum::"Email Connector"::"Test Email Connector");

        // [Then] No error occurs
        Assert.AreEqual('', GetLastErrorText(), 'There should be no errors when enqueuing an email.');

        // [Then] The enqueued email should be the correct one 
        EmailOutbox.SetRange("Message Id", EmailMessage.GetId());
        Assert.AreEqual(1, EmailOutbox.Count(), 'There should be only one enqueued message');
        Assert.IsTrue(EmailOutbox.FindFirst(), 'The message should be queued');

        Assert.AreEqual(AccountId, EmailOutbox."Account Id", 'The account should be set');
        Assert.AreEqual(Enum::"Email Connector"::"Test Email Connector", EmailOutbox.Connector, 'The connector should be set');
        Assert.AreEqual(EmailOutbox.Status::Queued, EmailOutbox.Status, 'The status should be ''Queued''');
        Assert.AreEqual(UserSecurityId(), EmailOutbox."User Security Id", 'The user security ID should be the current user');
        Assert.AreEqual(EmailMessage.GetSubject(), EmailOutbox.Description, 'The description does not match the email title');
        Assert.AreEqual('', EmailOutbox."Error Message", 'The error message should be blank');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SendEmailMessageFailTest()
    var
        EmailOutbox: Record "Email Outbox";
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        Connector: Enum "Email Connector";
        EmailStatus: Enum "Email Status";
        AccountId: Guid;
    begin
        // [Scenario] When sending an email on the foreground and the process fails, an error is shown

        // [Given] An email message and an email account
        CreateEmail(EmailMessage);
        Assert.IsTrue(EmailMessage.Get(EmailMessage.GetId()), 'The email should exist');
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(AccountId);

        // [When] Sending the email fails
        ConnectorMock.FailOnSend(true);
        Assert.IsFalse(Email.Send(EmailMessage, AccountId, Connector::"Test Email Connector"), 'Sending an email should have failed');

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
    procedure SendEmailMessageSuccessTest()
    var
        EmailOutbox: Record "Email Outbox";
        EmailAttachment: Record "Email Message Attachment";
        SentEmail: Record "Sent Email";
        Account: Record "Email Account";
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        Connector: Enum "Email Connector";
    begin
        // [Scenario] When successfuly sending an email, a recond is added on the Sent Emails table

        // [Given] An email message and an email account
        CreateEmail(EmailMessage);
        EmailMessage.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));

        Assert.IsTrue(EmailMessage.Get(EmailMessage.GetId()), 'The email should exist');

        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(Account);

        // [When] Sending the email fails
        Assert.IsTrue(Email.Send(EmailMessage, Account), 'Sending an email should have succeeded');

        // [Then] There is a Sent Mail recond and no Outbox record
        SentEmail.SetRange("Account Id", Account."Account Id");
        SentEmail.SetRange("Message Id", EmailMessage.GetId());

        Assert.IsTrue(SentEmail.FindFirst(), 'The email sent record should exist');
        Assert.AreEqual(EmailMessage.GetId(), SentEmail."Message Id", 'Wrong email message');
        Assert.AreEqual(Account."Email Address", SentEmail."Sent From", 'Wrong email address (sent from)');
        Assert.AreNotEqual(0DT, SentEmail."Date Time Sent", 'The Date Time Sent should be filled');
        Assert.AreEqual(Account."Account Id", SentEmail."Account Id", 'Wrong account');
        Assert.AreEqual(Connector::"Test Email Connector".AsInteger(), SentEmail.Connector.AsInteger(), 'Wrong connector');
        Assert.AreEqual(EmailMessage.GetSubject(), SentEmail.Description, 'Wrong description');

        // There is no related outbox
        EmailOutbox.SetRange("Account Id", Account."Account Id");
        EmailOutbox.SetRange("Message Id", EmailMessage.GetId());

        Assert.RecordIsEmpty(EmailOutbox);

        //[Then] The attachments cannot be deleted
        EmailAttachment.SetRange("Email Message Id", EmailMessage.GetId());
        EmailAttachment.FindFirst();

        asserterror EmailAttachment.Delete();
        Assert.ExpectedError(EmailMessageSentCannotDeleteAttachmentErr);
    end;

    local procedure CreateEmail(var EmailMessage: Codeunit "Email Message")
    var
        Any: Codeunit Any;
    begin
        EmailMessage.Create(Any.Email(), Any.UnicodeText(50), Any.UnicodeText(250), true);
    end;

    [StrMenuHandler]
    [Scope('OnPrem')]
    procedure CloseEmailEditorHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Choice := 1;
    end;

    [StrMenuHandler]
    [Scope('OnPrem')]
    procedure OnEmailEditorClose(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Assert.AreEqual(InstructionTxt, Instruction, 'Wrong message when closing email editor');
        Assert.AreEqual(OptionsOnClosePageTxt, Options, 'Wrong options when closing the email editor');

        Choice := OptionChoice;
    end;

    [ModalPageHandler]
    procedure EmailEditorHandler(var EmailEditor: TestPage "Email Editor")
    begin
        Assert.IsTrue(EmailEditor.Account.Enabled(), 'Account field was enabled');
        Assert.IsTrue(EmailEditor.ToField.Editable(), 'To field was editable');
        Assert.IsTrue(EmailEditor.CcField.Editable(), 'Cc field was editable');
        Assert.IsTrue(EmailEditor.BccField.Editable(), 'Bcc field was editable');
        Assert.IsTrue(EmailEditor.SubjectField.Editable(), 'Subject field was editable');
        Assert.IsTrue(EmailEditor.BodyField.Editable(), 'Body field was editable');
        Assert.IsTrue(EmailEditor.Upload.Enabled(), 'Upload Action was not disabled.');
        Assert.IsTrue(EmailEditor.Send.Enabled(), 'Send Action was not disabled.');
    end;

    [ModalPageHandler]
    procedure SendEmailEditorHandler(var EmailEditor: TestPage "Email Editor")
    begin
        EmailEditorHandler(EmailEditor);

        EmailEditor.Send.Invoke();
    end;

    [ModalPageHandler]
    procedure DiscardEmailEditorHandler(var EmailEditor: TestPage "Email Editor")
    begin
        EmailEditorHandler(EmailEditor);

        EmailEditor.Discard.Invoke();
    end;


    [ConfirmHandler]
    procedure ConfirmYes(Question: Text[1024]; var Reply: Boolean);
    begin
        Assert.AreEqual(DiscardEmailQst, Question, 'Wrong confirmation question');
        Reply := true;
    end;

    var
        InstructionTxt: Label 'The email has not been sent.';
        OptionsOnClosePageTxt: Label 'Keep as draft in Email Outbox,Discard email';
        DiscardEmailQst: Label 'Go ahead and discard?';
        OptionChoice: Integer;
}