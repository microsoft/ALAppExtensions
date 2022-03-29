// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 134685 "Email Test"
{
    Subtype = Test;
    Permissions = tabledata "Email Message" = rd,
                  tabledata "Email Message Attachment" = rd,
                  tabledata "Email Recipient" = rd,
                  tabledata "Email Outbox" = rimd,
                  tabledata "Scheduled Task" = rd,
                  tabledata "Sent Email" = rid;

    EventSubscriberInstance = Manual;

    var
        Assert: Codeunit "Library Assert";
        Email: Codeunit Email;
        Base64Convert: Codeunit "Base64 Convert";
        PermissionsMock: Codeunit "Permissions Mock";
        EmailMessageDoesNotExistMsg: Label 'The email message has been deleted by another user.', Locked = true;
        EmailMessageOpenPermissionErr: Label 'You do not have permission to open the email message.';
        EmailMessageCannotBeEditedErr: Label 'The email message has already been sent and cannot be edited.';
        EmailMessageQueuedCannotDeleteAttachmentErr: Label 'Cannot delete the attachment because the email has been queued to be sent.';
        EmailMessageSentCannotDeleteAttachmentErr: Label 'Cannot delete the attachment because the email has already been sent.';
        AccountNameLbl: Label '%1 (%2)', Locked = true;
        NoRelatedAttachmentsErr: Label 'Did not find any attachments related to this email.';

    [Test]
    [Scope('OnPrem')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure NonExistingEmailMessageFailsTest()
    var
        Message: Record "Email Message";
        EmailMessage: Codeunit "Email Message";
    begin
        // [Scenario] User cannot save as draft, enqueue, send or open (in editor) a non-existing email message
        PermissionsMock.Set('Email Edit');

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
        PermissionsMock.Set('Email Edit');

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
        PermissionsMock.Set('Email Edit');

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

        PermissionsMock.Set('Email Edit');

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
        EmailMessageAttachment: Record "Email Message Attachment";
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        EmailEditor: TestPage "Email Editor";
    begin
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        PermissionsMock.Set('Email Edit');

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
#if not CLEAN19
        Assert.IsFalse(EmailEditor.Upload.Enabled(), 'Upload Action was not disabled.');
#else
        Assert.IsFalse(EmailEditor.Attachments.Upload.Visible(), 'Upload Action is visible.');
#endif
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
#if not CLEAN19
        Assert.IsFalse(EmailEditor.Upload.Enabled(), 'Upload Action was not disabled.');
#else
        Assert.IsFalse(EmailEditor.Attachments.Upload.Visible(), 'Upload Action is visible.');
#endif
        Assert.IsFalse(EmailEditor.Send.Enabled(), 'Send Action was not disabled.');
        EmailMessageAttachment.SetRange("Email Message Id", EmailMessage.GetId());
        EmailMessageAttachment.FindFirst();
        asserterror EmailMessageAttachment.Delete();
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

        PermissionsMock.Set('Email Edit');

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

        PermissionsMock.Set('Email Edit');

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

        PermissionsMock.Set('Email Edit');

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

        PermissionsMock.Set('Email Edit');

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

        PermissionsMock.Set('Email Edit');

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

        PermissionsMock.Set('Email Edit');

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
        PermissionsMock.Set('Email Edit');

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
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure EnqueueScheduledEmailTest()
    var
        EmailOutbox: Record "Email Outbox";
        ScheduleTasks: Record "Scheduled Task";
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        AccountId: Guid;
        DateTime: DateTime;
    begin
        // [Scenario] When enqueuing an existing email, it appears in the outbox
        PermissionsMock.Set('Email Edit');

        // [Given] An email message and an email account
        CreateEmail(EmailMessage);
        Assert.IsTrue(EmailMessage.Get(EmailMessage.GetId()), 'The email should exist');
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(AccountId);

        // [When] Enqueuing the email message with the email account
        ScheduleTasks.DeleteAll();
        ClearLastError();

        DateTime := CreateDateTime(CalcDate('<+1D>', Today()), Time());
        Email.Enqueue(EmailMessage, AccountId, Enum::"Email Connector"::"Test Email Connector", DateTime);

        // [Then] No error occurs
        Assert.AreEqual('', GetLastErrorText(), 'There should be no errors when enqueuing an email.');

        // [Then] Job is enqueued
        Assert.AreEqual(ScheduleTasks.Count, 1, 'Enqueue should only add one entry to scheduled tasks');
        Assert.IsTrue(ScheduleTasks.FindFirst(), 'The job should be in scheduled tasks');
        Assert.AreEqual(Format(ScheduleTasks."Not Before", 0, '<Day,2>-<Month,2>-<Year> <Hours24,2>.<Minutes,2>.<Seconds,2>'), Format(DateTime, 0, '<Day,2>-<Month,2>-<Year> <Hours24,2>.<Minutes,2>.<Seconds,2>'), 'The jobs not before date should be equal to the datetime provided when enqueueing');

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
        Assert.AreEqual(DateTime, EmailOutbox."Date Sending", 'The date sending does not match the datetime provided when enqueueing');
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
        PermissionsMock.Set('Email Edit');

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
        EmailMessageAttachment: Record "Email Message Attachment";
        SentEmail: Record "Sent Email";
        EmailAccount: Record "Email Account";
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        Connector: Enum "Email Connector";
    begin
        // [Scenario] When successfuly sending an email, a recond is added on the Sent Emails table
        PermissionsMock.Set('Email Edit');

        // [Given] An email message and an email account
        CreateEmail(EmailMessage);
        EmailMessage.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));

        Assert.IsTrue(EmailMessage.Get(EmailMessage.GetId()), 'The email should exist');

        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(EmailAccount);

        // [When] The email is Sent
        Assert.IsTrue(Email.Send(EmailMessage, EmailAccount), 'Sending an email should have succeeded');

        // [Then] There is a Sent Mail recond and no Outbox record
        SentEmail.SetRange("Account Id", EmailAccount."Account Id");
        SentEmail.SetRange("Message Id", EmailMessage.GetId());

        Assert.IsTrue(SentEmail.FindFirst(), 'The email sent record should exist');
        Assert.AreEqual(EmailMessage.GetId(), SentEmail."Message Id", 'Wrong email message');
        Assert.AreEqual(EmailAccount."Email Address", SentEmail."Sent From", 'Wrong email address (sent from)');
        Assert.AreNotEqual(0DT, SentEmail."Date Time Sent", 'The Date Time Sent should be filled');
        Assert.AreEqual(EmailAccount."Account Id", SentEmail."Account Id", 'Wrong account');
        Assert.AreEqual(Connector::"Test Email Connector".AsInteger(), SentEmail.Connector.AsInteger(), 'Wrong connector');
        Assert.AreEqual(EmailMessage.GetSubject(), SentEmail.Description, 'Wrong description');

        // There is no related outbox
        EmailOutbox.SetRange("Account Id", EmailAccount."Account Id");
        EmailOutbox.SetRange("Message Id", EmailMessage.GetId());

        Assert.AreEqual(0, EmailOutbox.Count(), 'Email Outbox was not empty.');

        //[Then] The attachments cannot be deleted
        EmailMessageAttachment.SetRange("Email Message Id", EmailMessage.GetId());
        EmailMessageAttachment.FindFirst();

        asserterror EmailMessageAttachment.Delete();
        Assert.ExpectedError(EmailMessageSentCannotDeleteAttachmentErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ShowSourceRecordInOutbox()
    var
        EmailOutbox: Record "Email Outbox";
        EmailMessage: Codeunit "Email Message";
        Any: Codeunit Any;
        EmailTest: Codeunit "Email Test";
        EmailOutboxPage: Page "Email Outbox";
        EmailOutboxTestPage: TestPage "Email Outbox";
        TableId: Integer;
        SystemId: Guid;
    begin
        BindSubscription(EmailTest);

        PermissionsMock.Set('Email Edit');

        // [Scenario] Emails with source document, will see the Source Document button 
        // [Given] An Email with table id and source system id
        TableId := Any.IntegerInRange(1, 10000);
        SystemId := Any.GuidValue();

        // [When] The email is created and saved as draft
        CreateEmailWithSource(EmailMessage, TableId, SystemId);

        // [When] The email is created and saved as draft
        Email.SaveAsDraft(EmailMessage, EmailOutbox);

        // [And] The Show Source Document button is visible 
        EmailOutboxTestPage.Trap();
        EmailOutboxPage.SetRecord(EmailOutbox);
        EmailOutboxPage.Run();

        Assert.IsTrue(EmailOutboxTestPage.ShowSourceRecord.Visible(), 'Show Source Record action should be visible');

        // [When] Show Source Document button is clicked
        ClearLastError();
        EmailOutboxTestPage.ShowSourceRecord.Invoke();

        // [Then] No error appears
        Assert.AreEqual('', GetLastErrorText, 'An error occured');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('RelationPickerHandler')]
    procedure ShowMultipleSourceRecords()
    var
        EmailOutbox: Record "Email Outbox";
        EmailMessageRecord: Record "Email Message";
        EmailMessage: Codeunit "Email Message";
        EmailTest: Codeunit "Email Test";
        EmailOutboxPage: Page "Email Outbox";
        EmailOutboxTestPage: TestPage "Email Outbox";
        TableId: Integer;
        SystemId: Guid;
    begin
        BindSubscription(EmailTest);
        EmailOutbox.DeleteAll();

        // [Scenario] Emails with multiple source documents, will see the email relation picker  
        // [Given] An Email with table id and source system id

        // [And] The email is with a source and saved as draft
        CreateEmail(EmailMessage);
        Email.SaveAsDraft(EmailMessage, EmailOutbox);

        // [When] An extra relation is added - We use email outbox to have a record that actually exists
        EmailMessageRecord.Get(EmailMessage.GetId());
        TableId := Database::"Email Outbox";
        SystemId := EmailOutbox.SystemId;
        Email.AddRelation(EmailMessage, TableId, SystemId, Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");
        Email.AddRelation(EmailMessage, Database::"Email Message", EmailMessageRecord.SystemId, Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Compose Context");

        // [And] The Show Source Document button is clicked 
        EmailOutboxTestPage.Trap();
        EmailOutboxPage.SetRecord(EmailOutbox);
        EmailOutboxPage.Run();

        Assert.IsTrue(EmailOutboxTestPage.ShowSourceRecord.Visible(), 'Show Source Record action should be visible');
        Assert.IsTrue(EmailOutboxTestPage.ShowSourceRecord.Enabled(), 'Show Source Record action should be enabled');
        EmailOutboxTestPage.ShowSourceRecord.Invoke();

        // [Then] Email picker modal appears
    end;

    [Test]
    [Scope('OnPrem')]
    procedure EmailWithoutSourceInOutbox()
    var
        EmailOutbox: Record "Email Outbox";
        EmailMessage: Codeunit "Email Message";
        EmailTest: Codeunit "Email Test";
        EmailOutboxPage: Page "Email Outbox";
        EmailOutboxTestPage: TestPage "Email Outbox";
    begin
        BindSubscription(EmailTest);

        PermissionsMock.Set('Email Edit');
        EmailOutbox.DeleteAll();

        // [Scenario] Emails with source document, will see the Source Document button 
        // [Given] An Email with table id and source system id

        // [When] The email is created and saved as draft
        CreateEmail(EmailMessage);
        Email.SaveAsDraft(EmailMessage, EmailOutbox);

        // [When] The Email Outbox page is opened.
        EmailOutboxTestPage.Trap();
        EmailOutboxPage.SetRecord(EmailOutbox);
        EmailOutboxPage.Run();

        // [Then] The Show Source action is visible and disabled.
        Assert.IsTrue(EmailOutboxTestPage.ShowSourceRecord.Visible(), 'Show Source Record action should be visible');
        Assert.IsFalse(EmailOutboxTestPage.ShowSourceRecord.Enabled(), 'Show Source Record action should be disabled');
    end;


    [Test]
    [Scope('OnPrem')]
    procedure EmailWithSourceNoSubscriber()
    var
        EmailOutbox: Record "Email Outbox";
        EmailMessage: Codeunit "Email Message";
        Any: Codeunit Any;
        EmailOutboxPage: Page "Email Outbox";
        EmailOutboxTestPage: TestPage "Email Outbox";
        TableId: Integer;
        SystemId: Guid;
    begin
        // [Scenario] Emails with source document, will see the Source Document button 
        PermissionsMock.Set('Email Edit');

        // [Given] An Email with table id and source system id
        TableId := Any.IntegerInRange(1, 10000);
        SystemId := Any.GuidValue();

        // [When] The email is created and saved as draft
        CreateEmailWithSource(EmailMessage, TableId, SystemId);

        // [When] The email is created and saved as draft
        CreateEmail(EmailMessage);
        Email.SaveAsDraft(EmailMessage, EmailOutbox);

        // [When] The Email Outbox page is opened.
        EmailOutboxTestPage.Trap();
        EmailOutboxPage.SetRecord(EmailOutbox);
        EmailOutboxPage.Run();

        // [Then] The Show Source action is visible and disabled.
        Assert.IsTrue(EmailOutboxTestPage.ShowSourceRecord.Visible(), 'Show Source Record action should be visible');
        Assert.IsFalse(EmailOutboxTestPage.ShowSourceRecord.Enabled(), 'Show Source Record action should be disabled');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SendEmailMessageWithSourceTest()
    var
        TempSentEmail: Record "Sent Email" temporary;
        EmailAccount: Record "Email Account";
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        Any: Codeunit Any;
        SystemId: Guid;
        TableId, NumberOfEmails, i : Integer;
        MessageIds: List of [Guid];
    begin
        // [Scenario] When successfuly sending an email with source, a record is added to the email source document table and sent emails table. 
        PermissionsMock.Set('Email Edit');

        // [Given] An email with source and an email account
        TableId := Any.IntegerInRange(1, 10000);
        SystemId := Any.GuidValue();

        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(EmailAccount);

        NumberOfEmails := Any.IntegerInRange(2, 5);

        for i := 1 to NumberOfEmails do begin
            CreateEmailWithSource(EmailMessage, TableId, SystemId);
            Assert.IsTrue(EmailMessage.Get(EmailMessage.GetId()), 'The email should exist');
            MessageIds.Add(EmailMessage.GetId());

            // [When] The email is Sent
            Assert.IsTrue(Email.Send(EmailMessage, EmailAccount), 'Sending an email should have succeeded');
        end;

        Email.GetSentEmailsForRecord(TableId, SystemId, TempSentEmail);

        for i := 1 to NumberOfEmails do begin
            TempSentEmail.SetCurrentKey("Message Id");
            TempSentEmail.SetRange("Message Id", MessageIds.Get(i));
            Assert.AreEqual(1, TempSentEmail.Count(), 'Did not find the email in Sent Emails ');
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('RelatedAttachmentsHandler,CloseEmailEditorHandler')]
    procedure AttachFromRelatedRecords()
    var
        EmailMessageAttachments: Record "Email Message Attachment";
        EmailOutbox: Record "Email Outbox";
        EmailMessage: Codeunit "Email Message";
        EmailTest: Codeunit "Email Test";
        Email: Codeunit Email;
        EmailEditorPage: TestPage "Email Editor";
        TableId: Integer;
        SystemId: Guid;
        SourceText: Text;
    begin
        BindSubscription(EmailTest);
        VariableStorage.Clear();

        // [Given] A created email
        CreateEmail(EmailMessage);
        Email.SaveAsDraft(EmailMessage, EmailOutbox);

        // [And] A related record to the email (in this case, the email is related to an email in the outbox)
        TableId := Database::"Email Outbox";
        SystemId := EmailOutbox.SystemId;

        Email.AddRelation(EmailMessage, TableId, SystemId, Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");

        SourceText := StrSubstNo('%1: %2', EmailOutbox.TableCaption(), Format(EmailOutbox.Id));
        VariableStorage.Enqueue(SourceText);

        // [When] Opening the Email Related Attachments page
        EmailEditorPage.Trap();
        Email.OpenInEditor(EmailMessage);
        EmailEditorPage.Attachments.SourceAttachments.Invoke();

        // [Then] Attachments added through the 'OnFindRelatedAttachments' event are displayed 
        // [And] A related attachment is added

        // [Then] The related attachment is added as an attachment to the email 
        EmailMessageAttachments.SetRange("Email Message Id", EmailMessage.GetId());
        EmailMessageAttachments.FindSet();
        Assert.AreEqual(1, EmailMessageAttachments.Count(), 'Related attachment wasnt attached to the email.');
        Assert.AreEqual('Attachment1', EmailMessageAttachments."Attachment Name", 'Wrong attachment was attached to email.');
        AssertVariableStorageEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetRelatedAttachmentsTest()
    var
        EmailRelatedAttachment: Record "Email Related Attachment";
        EmailOutbox: Record "Email Outbox";
        EmailMessage: Codeunit "Email Message";
        EmailTest: Codeunit "Email Test";
        Email: Codeunit Email;
        EmailEditor: Codeunit "Email Editor";
        TableId: Integer;
        SystemId: Guid;
        SourceText: Text;
    begin
        BindSubscription(EmailTest);
        VariableStorage.Clear();

        // [Given] A created email
        CreateEmail(EmailMessage);
        Email.SaveAsDraft(EmailMessage, EmailOutbox);

        // [And] A related record to the email (in this case, the email is related to an email in the outbox)
        TableId := Database::"Email Outbox";
        SystemId := EmailOutbox.SystemId;

        Email.AddRelation(EmailMessage, TableId, SystemId, Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");

        SourceText := StrSubstNo('%1: %2', EmailOutbox.TableCaption(), Format(EmailOutbox.Id));
        VariableStorage.Enqueue(SourceText);

        EmailEditor.GetRelatedAttachments(EmailMessage.GetId(), EmailRelatedAttachment);

        Assert.AreEqual(1, EmailRelatedAttachment.Count(), 'Wrong number of attachments.');
        Assert.AreEqual('Attachment1', EmailRelatedAttachment."Attachment Name", 'Wrong attachmentname');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('RelatedAttachmentsHandler,CloseEmailEditorHandler')]
    procedure FailedAttachFromRelatedRecords()
    var
        EmailMessage: Codeunit "Email Message";
        EmailTest: Codeunit "Email Test";
        Email: Codeunit Email;
        EmailEditorPage: TestPage "Email Editor";
    begin
        BindSubscription(EmailTest);

        // [Given] A created email without source record
        CreateEmail(EmailMessage);

        // [When] Opening the Email Related Attachments page and getting related attachments 
        EmailEditorPage.Trap();
        Email.OpenInEditor(EmailMessage);
        asserterror EmailEditorPage.Attachments.SourceAttachments.Invoke();

        // [Then] An error message is displayed 
        Assert.ExpectedError(NoRelatedAttachmentsErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SendEmailInBackgroundSuccessTest()
    var
        EmailAccount: Record "Email Account";
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        TestClientType: Codeunit "Test Client Type Subscriber";
        EmailTest: Codeunit "Email Test";
        Variable: Variant;
        Status: Boolean;
        MessageID: Guid;
    begin
        // [Scenario] When Sending the email in the background an event is fired to nothify for the status of the email
        PermissionsMock.Set('Email Edit');

        TestClientType.SetClientType(ClientType::Background);
        BindSubscription(TestClientType);
        BindSubscription(EmailTest);

        // [Given] An email message and an email account
        CreateEmail(EmailMessage);
        Assert.IsTrue(EmailMessage.Get(EmailMessage.GetId()), 'The email should exist');

        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(EmailAccount);

        // [When] The email is Sent
        Email.Send(EmailMessage, EmailAccount);

        // [Then] An event is fired to notify for the status of the email
        EmailTest.DequeueVariable(Variable);
        MessageID := Variable;
        EmailTest.DequeueVariable(Variable);
        Status := Variable;

        // [Then] The event was fired once
        EmailTest.AssertVariableStorageEmpty();
        Assert.AreEqual(MessageID, EmailMessage.GetId(), 'A different Email was expected');
        Assert.IsTrue(Status, 'The email should have been sent');

        UnBindSubscription(EmailTest);
        UnBindSubscription(TestClientType);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SendEmailInBackgroundFailTest()
    var
        EmailAccount: Record "Email Account";
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        TestClientType: Codeunit "Test Client Type Subscriber";
        EmailTest: Codeunit "Email Test";
        Variable: Variant;
        Status: Boolean;
        MessageID: Guid;
    begin
        // [Scenario] When Sending the email in the background an event is fired to nothify for the status of the email
        PermissionsMock.Set('Email Edit');

        TestClientType.SetClientType(ClientType::Background);
        BindSubscription(TestClientType);
        BindSubscription(EmailTest);

        // [Given] An email message and an email account
        CreateEmail(EmailMessage);
        Assert.IsTrue(EmailMessage.Get(EmailMessage.GetId()), 'The email should exist');

        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(EmailAccount);
        ConnectorMock.FailOnSend(true);

        // [When] The email is Sent
        Email.Send(EmailMessage, EmailAccount);

        // [Then] An event is fired to notify for the status of the email
        EmailTest.DequeueVariable(Variable);
        MessageID := Variable;
        EmailTest.DequeueVariable(Variable);
        Status := Variable;

        // [Then] The event was fired once
        EmailTest.AssertVariableStorageEmpty();
        Assert.AreEqual(MessageID, EmailMessage.GetId(), 'A different Email was expected');
        Assert.IsFalse(Status, 'The email should not have been sent');

        UnBindSubscription(EmailTest);
        UnBindSubscription(TestClientType);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SendEmailInBackgroundFailSubscriberFailsTest()
    var
        EmailAccount: Record "Email Account";
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        TestClientType: Codeunit "Test Client Type Subscriber";
        EmailTest: Codeunit "Email Test";
        Variable: Variant;
        Status: Boolean;
        MessageID: Guid;
    begin
        // [Scenario] When an error occurs on the subscriber it does not propagate up the stack and the notification is sent only once
        PermissionsMock.Set('Email Edit');

        TestClientType.SetClientType(ClientType::Background);
        BindSubscription(TestClientType);
        BindSubscription(EmailTest);
        EmailTest.ThrowErrorOnAfterSendEmail();

        // [Given] An email message and an email account
        CreateEmail(EmailMessage);

        Assert.IsTrue(EmailMessage.Get(EmailMessage.GetId()), 'The email should exist');

        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(EmailAccount);
        ConnectorMock.FailOnSend(true);

        // [When] The email is Sent
        Email.Send(EmailMessage, EmailAccount);

        // [Then] An event is fired to notify for the status of the email
        EmailTest.DequeueVariable(Variable);
        MessageID := Variable;
        EmailTest.DequeueVariable(Variable);
        Status := Variable;

        // [Then] The event was fired once
        EmailTest.AssertVariableStorageEmpty();
        Assert.AreEqual(MessageID, EmailMessage.GetId(), 'A different Email was expected');
        Assert.IsFalse(Status, 'The email should not have been sent');

        UnBindSubscription(EmailTest);
        UnBindSubscription(TestClientType);
    end;


    [Test]
    [Scope('OnPrem')]
    procedure SendEmailInBackgroundSuccessSubscriberFailsTest()
    var
        EmailAccount: Record "Email Account";
        EmailOutbox: Record "Email Outbox";
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        TestClientType: Codeunit "Test Client Type Subscriber";
        EmailTest: Codeunit "Email Test";
        Variable: Variant;
        Status: Boolean;
        MessageID: Guid;
    begin
        // [Scenario] When an error occurs on the subscriber it does not propagate up the stack and the notification is sent only once
        PermissionsMock.Set('Email Edit');

        TestClientType.SetClientType(ClientType::Background);
        BindSubscription(TestClientType);
        BindSubscription(EmailTest);
        EmailTest.ThrowErrorOnAfterSendEmail();

        // [Given] An email message and an email account
        CreateEmail(EmailMessage);

        Assert.IsTrue(EmailMessage.Get(EmailMessage.GetId()), 'The email should exist');

        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(EmailAccount);

        // [When] The email is Sent
        Email.Send(EmailMessage, EmailAccount);

        // [Then] An event is fired to notify for the status of the email
        EmailTest.DequeueVariable(Variable);
        MessageID := Variable;
        EmailTest.DequeueVariable(Variable);
        Status := Variable;
        // [Then] The event was fired once
        EmailTest.AssertVariableStorageEmpty();
        Assert.AreEqual(MessageID, EmailMessage.GetId(), 'A different Email was expected');
        Assert.IsTrue(Status, 'The email should have been sent');

        EmailOutbox.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(EmailOutbox.IsEmpty(), 'Email outbox should have been deleted.');

        UnBindSubscription(EmailTest);
        UnBindSubscription(TestClientType);
    end;

    [Test]
    procedure ResendSentEmailFromAnotherUserTest()
    var
        SentEmail: Record "Sent Email";
        Any: Codeunit Any;
        EmailViewer: Codeunit "Email Viewer";
    begin
        // Create a sent email
        PermissionsMock.Set('Email Edit');

        SentEmail.Init();
        SentEmail.Description := CopyStr(Any.UnicodeText(50), 1, MaxStrLen(SentEmail.Description));
        SentEmail."Date Time Sent" := CurrentDateTime();
        SentEmail."User Security Id" := CreateGuid(); // Created by another user
        SentEmail.Insert();

        asserterror EmailViewer.Resend(SentEmail);
        Assert.ExpectedError(EmailMessageOpenPermissionErr);

        asserterror EmailViewer.EditAndSend(SentEmail);
        Assert.ExpectedError(EmailMessageOpenPermissionErr);
    end;

    [Test]
    procedure GetSourceRecordInOutbox()
    var
        SourceEmailOutbox, EmailOutbox : Record "Email Outbox";
        TempEmailOutbox: Record "Email Outbox" temporary;
        EmailMessage: Codeunit "Email Message";
        Any: Codeunit Any;
        EmailTest: Codeunit "Email Test";
        MessageIds: List of [Guid];
        SystemId: Guid;
        TableId: Integer;
        NumberOfEmails, i : Integer;
    begin
        BindSubscription(EmailTest);

        PermissionsMock.Set('Email Edit');
        EmailOutbox.DeleteAll();

        // [Scenario] Emails with source document, GetEmailOutboxForRecord procedure will return Outbox Emails
        // [Given] Source Record - Email Outbox used as a source record for test email
        CreateEmail(EmailMessage);
        Email.SaveAsDraft(EmailMessage, SourceEmailOutbox);
        TableId := Database::"Email Outbox";
        SystemId := SourceEmailOutbox.SystemId;

        // [When] Several emails are created and saved as draft
        NumberOfEmails := Any.IntegerInRange(2, 5);

        for i := 1 to NumberOfEmails do begin
            Clear(EmailOutbox);
            CreateEmailWithSource(EmailMessage, TableId, SystemId);
            Email.SaveAsDraft(EmailMessage, EmailOutbox);
            MessageIds.Add(EmailMessage.GetId());
        end;

        // [Then] GetEmailOutboxForRecord procedure return related Email Outbox
        Email.GetEmailOutboxForRecord(SourceEmailOutbox, TempEmailOutbox);
        Assert.AreEqual(NumberOfEmails, TempEmailOutbox.Count(), 'Email Outbox count is not equal to Number of Emails created.');

        for i := 1 to NumberOfEmails do begin
            TempEmailOutbox.SetCurrentKey("Message Id");
            TempEmailOutbox.SetRange("Message Id", MessageIds.Get(i));
            Assert.AreEqual(1, TempEmailOutbox.Count(), 'Did not find the email in Email Outbox');
        end;
    end;

    [Test]
    procedure GetEmailOutboxRecordStatus()
    var
        EmailOutbox: Record "Email Outbox";
        EmailMessage: Codeunit "Email Message";
        Any: Codeunit Any;
        EmailTest: Codeunit "Email Test";
        EmailStatus: Enum "Email Status";
        TableId: Integer;
        SystemId: Guid;
    begin
        BindSubscription(EmailTest);

        PermissionsMock.Set('Email Edit');

        // [Scenario] Emails with source document, GetOutboxEmailRecordStatus will return Outbox Email Status
        // [Given] An Email with table id and source system id
        TableId := Any.IntegerInRange(1, 10000);
        SystemId := Any.GuidValue();

        // [When] The email is created and saved as draft
        CreateEmailWithSource(EmailMessage, TableId, SystemId);

        // [When] The email is created and saved as draft
        Email.SaveAsDraft(EmailMessage, EmailOutbox);

        // [Then] Email Status of created Email Outbox record is equal to GetOutboxEmailRecordStatus result
        EmailStatus := Email.GetOutboxEmailRecordStatus(EmailOutbox."Message Id");
        Assert.AreEqual(EmailStatus, EmailOutbox.Status, 'Email Status should be the same as on Email Outbox record');
    end;

    [Test]
    procedure GetSentEmailsForRecordByVariant()
    var
        SentEmail: Record "Sent Email";
        TempSentEmail: Record "Sent Email" temporary;
        EmailAccount: Record "Email Account";
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        Any: Codeunit Any;
        SystemId: Guid;
        TableId, NumberOfEmails, i : Integer;
        MessageIds: List of [Guid];
    begin
        // [Scenario] When successfuly sending an email with source, GetSentEmailsForRecord return related Sent Emails. 
        PermissionsMock.Set('Email Edit');
        SentEmail.DeleteAll();

        // [Given] An email with source and an email account
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(EmailAccount);
        TableId := Database::"Email Account";
        SystemId := EmailAccount.SystemId;
        NumberOfEmails := Any.IntegerInRange(2, 5);

        for i := 1 to NumberOfEmails do begin
            CreateEmailWithSource(EmailMessage, TableId, SystemId);
            Assert.IsTrue(EmailMessage.Get(EmailMessage.GetId()), 'The email should exist');
            MessageIds.Add(EmailMessage.GetId());

            // [When] The email is Sent
            Assert.IsTrue(Email.Send(EmailMessage, EmailAccount), 'Sending an email should have succeeded');
        end;

        // [Then] GetSentEmailsForRecord procedure return related Sent Email records
        Email.GetSentEmailsForRecord(EmailAccount, TempSentEmail);
        Assert.AreEqual(NumberOfEmails, TempSentEmail.Count(), 'Sent Emails count is not equal to Number of Emails sent.');

        for i := 1 to NumberOfEmails do begin
            TempSentEmail.SetCurrentKey("Message Id");
            TempSentEmail.SetRange("Message Id", MessageIds.Get(i));
            Assert.AreEqual(1, TempSentEmail.Count(), 'Did not find the email in Sent Emails ');
        end;
    end;

    local procedure CreateEmail(var EmailMessage: Codeunit "Email Message")
    var
        Any: Codeunit Any;
    begin
        EmailMessage.Create(Any.Email(), Any.UnicodeText(50), Any.UnicodeText(250), true);
    end;

    local procedure CreateEmailWithSource(var EmailMessage: Codeunit "Email Message"; TableId: Integer; SystemId: Guid)
    var
        Any: Codeunit Any;
    begin
        EmailMessage.Create(Any.Email(), Any.UnicodeText(50), Any.UnicodeText(250), true);
        Email.AddRelation(EmailMessage, TableId, SystemId, Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");
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
    procedure RelationPickerHandler(var EmailRelationPickerTestPage: TestPage "Email Relation Picker")
    begin
        Assert.AreEqual(EmailRelationPickerTestPage."Relation Type".Value(), 'Primary Source', 'No source found on email relation picker page');

        ClearLastError();
        EmailRelationPickerTestPage."Source Name".Lookup();

        Assert.AreEqual('', GetLastErrorText, 'An error occured - opening email relation from picker');
    end;

    [ModalPageHandler]
    procedure RelatedAttachmentsHandler(var RelatedAttachmentsPage: TestPage "Email Related Attachments")
    var
        SourceLabel: Variant;
    begin
        RelatedAttachmentsPage.First();
        DequeueVariable(SourceLabel);
        Assert.AreEqual('Attachment1', RelatedAttachmentsPage.FileName.Value(), 'Wrong Attachment');
        Assert.AreEqual(SourceLabel, RelatedAttachmentsPage.Source.Value(), 'Wrong Attachment');

        RelatedAttachmentsPage.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure EmailEditorHandler(var EmailEditor: TestPage "Email Editor")
    begin
        Assert.IsTrue(EmailEditor.Account.Enabled(), 'Account field was not enabled');
        Assert.IsTrue(EmailEditor.ToField.Editable(), 'To field was not editable');
        Assert.IsTrue(EmailEditor.CcField.Editable(), 'Cc field was not editable');
        Assert.IsTrue(EmailEditor.BccField.Editable(), 'Bcc field was not editable');
        Assert.IsTrue(EmailEditor.SubjectField.Editable(), 'Subject field was not editable');
        Assert.IsTrue(EmailEditor.BodyField.Editable(), 'Body field was not editable');
#if not CLEAN19
        Assert.IsTrue(EmailEditor.Upload.Enabled(), 'Upload Action was not enabled.');
#else
        Assert.IsTrue(EmailEditor.Attachments.Upload.Visible(), 'Upload Action is not visible.');
#endif
        Assert.IsTrue(EmailEditor.Send.Enabled(), 'Send Action was not enabled.');
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::Email, 'OnAfterSendEmail', '', true, true)]
    local procedure OnAfterSendEmailSubscriber(MessageId: Guid; Status: Boolean)
    begin
        VariableStorage.Enqueue(MessageId);
        VariableStorage.Enqueue(Status);
        if ThrowError then
            Error('');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::Email, 'OnShowSource', '', true, true)]
    local procedure OnShowSourceSubscriber(SourceTableId: Integer; SourceSystemId: Guid; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::Email, 'OnFindRelatedAttachments', '', true, true)]
    local procedure OnFindRelatedAttachments(SourceTableId: Integer; SourceSystemID: Guid; var EmailRelatedAttachments: Record "Email Related Attachment")
    var
        Any: Codeunit Any;
    begin
        EmailRelatedAttachments."Attachment Name" := 'Attachment1';
        EmailRelatedAttachments."Attachment Table ID" := Any.IntegerInRange(1000);
        EmailRelatedAttachments."Attachment System ID" := System.CreateGuid();
        EmailRelatedAttachments.Insert();

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::Email, 'OnGetAttachment', '', true, true)]
    local procedure OnGetAttachment(AttachmentTableID: Integer; AttachmentSystemID: Guid; MessageID: Guid)
    var
        EmailMessage: Codeunit "Email Message";
    begin
        EmailMessage.Get(MessageID);
        EmailMessage.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));
    end;

    procedure ThrowErrorOnAfterSendEmail()
    begin
        ThrowError := true;
    end;

    procedure DequeueVariable(var Variable: Variant)
    begin
        VariableStorage.Dequeue(Variable);
    end;

    procedure AssertVariableStorageEmpty()
    begin
        VariableStorage.AssertEmpty();
    end;

    var
        VariableStorage: Codeunit "Library - Variable Storage";
        InstructionTxt: Label 'The email has not been sent.';
        OptionsOnClosePageTxt: Label 'Keep as draft in Email Outbox,Discard email';
        DiscardEmailQst: Label 'Go ahead and discard?';
        OptionChoice: Integer;
        ThrowError: Boolean;
}