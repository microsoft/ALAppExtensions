// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 134692 "Email E2E Tests"
{
    EventSubscriberInstance = Manual;
    SubType = Test;
    Permissions = tabledata "Email Message" = rid,
                  tabledata "Email Message Attachment" = r,
                  tabledata "Email Recipient" = r,
                  tabledata "Email Related Record" = r,
                  tabledata "Email Outbox" = rimd,
                  tabledata "Email View Policy" = rid,
                  tabledata "Sent Email" = rid;

    var
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        Email: Codeunit Email;
        EmailE2ETests: Codeunit "Email E2E Tests";
        EmailWasQueuedForSendingMsg: Label 'The message was queued for sending.';
        FromDisplayNameLbl: Label '%1 (%2)', Comment = '%1 - Account Name, %2 - Email address', Locked = true;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure DeleteSentEmailDeletesMessageTest()
    var
        TempAccount: Record "Email Account" temporary;
        SentEmail: Record "Sent Email";
        EmailRecipient: Record "Email Recipient";
        Attachment: Record "Email Message Attachment";
        ConnectorMock: Codeunit "Connector Mock";
        Base64Convert: Codeunit "Base64 Convert";
        Message: Codeunit "Email Message";
        Recipients: List of [Text];
    begin
        // [SCENARIO] When a sent email is deleted, the underlying email message is also deleted

        // [GIVEN] A connector is installed and an account is added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        PermissionsMock.Set('Email Edit');

        // [GIVEN] A email message is created
        Recipients.Add('recipient1@test.com');
        Recipients.Add('recipient2@test.com');
        Message.Create(Recipients, 'Test subject', 'Test body', true);
        Message.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));
        Message.AddAttachment('Attachment2', 'text/plain', Base64Convert.ToBase64('Content'));

        // [GIVEN] The message has been sent
        SentEmail.Init();
        SentEmail."Message Id" := Message.GetId();
        SentEmail.Insert();

        // [WHEN] Deleting the sent email record
        SentEmail.SetRange("Message Id", Message.GetId());
        SentEmail.FindSet();
        SentEmail.Delete();

        // [THEN] The email message is deleted as well
        Assert.IsFalse(Message.Get(Message.GetId()), 'The message was not deleted.');

        EmailRecipient.SetRange("Email Message Id", Message.GetId());
        Assert.AreEqual(0, EmailRecipient.Count(), 'Email Recipients were not deleted');

        Attachment.SetRange("Email Message Id", Message.GetId());
        Assert.AreEqual(0, Attachment.Count(), 'Email Attachment were not deleted');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure DeleteEmailOutboxDeletesMessageTest()
    var
        Outbox: Record "Email Outbox";
        TempAccount: Record "Email Account" temporary;
        EmailRecipient: Record "Email Recipient";
        Attachment: Record "Email Message Attachment";
        ConnectorMock: Codeunit "Connector Mock";
        Base64Convert: Codeunit "Base64 Convert";
        Message: Codeunit "Email Message";
        Recipients: List of [Text];
    begin
        // [SCENARIO] When an outbox entry is deleted, the underlying email message is deleted as well

        // [GIVEN] A connector is installed and an account is added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        PermissionsMock.Set('Email Edit');

        // [GIVEn] A email message is created
        Recipients.Add('recipient1@test.com');
        Recipients.Add('recipient2@test.com');
        Message.Create(Recipients, 'Test subject', 'Test body', true);
        Message.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));
        Message.AddAttachment('Attachment2', 'text/plain', Base64Convert.ToBase64('Content'));

        // [GIVEN] The message has been queued
        Outbox.Init();
        Outbox."Message Id" := Message.GetId();
        Outbox.Insert();

        // [WHEN] The first outbox record is deleted
        Outbox.SetRange("Message Id", Message.GetId());
        Outbox.FindSet();
        Outbox.Delete();

        // [THEN] The email message is deleted
        Assert.IsFalse(Message.Get(Message.GetId()), 'The message was not deleted.');

        EmailRecipient.SetRange("Email Message Id", Message.GetId());
        Assert.AreEqual(0, EmailRecipient.Count(), 'Email Recipients were not deleted');

        Attachment.SetRange("Email Message Id", Message.GetId());
        Assert.AreEqual(0, Attachment.Count(), 'Email Attachment were not deleted');
    end;

    [Test]
    [HandlerFunctions('ChooseAccountHandler,SaveAsDraftOnCloseHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure SaveDraftThroughEditor()
    var
        TempAccount: Record "Email Account" temporary;
        Outbox: Record "Email Outbox";
        Message: Record "Email Message";
        EmailRecipient: Record "Email Recipient";
        ConnectorMock: Codeunit "Connector Mock";
        EmailEditor: Page "Email Editor";
        Editor: TestPage "Email Editor";
    begin
        // [SCENARIO] When the editor page is closed and the user choose to save a draft, a draft email is enqued in the outbox

        // [GIVEN] A connector is installed and an account is added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        PermissionsMock.Set('Email Admin');
        GiveUserViewAllPolicy();

        // [GIVEN] There are no Record in Email Outbox 
        Outbox.DeleteAll();

        // [GIVEN] The Email Editor pages opens up and details are filled
        Editor.Trap();
        EmailEditor.Run();

        Editor.Account.AssistEdit(); // Handled in ChooseAccountHandler
        Editor.ToField.SetValue('recipient1@test.com');
        Editor.SubjectField.SetValue('Test Subject');
        Editor.BodyField.SetValue('Test body');

        // [WHEN] The page is closed and the email is saved as draft. See SaveAsDraftOnCloseHandler
        Editor.Close();

        // [THEN] The mail is saved in the outbox as a draft and the info is correct
        Outbox.Reset();
        Assert.AreEqual(1, Outbox.Count(), 'Only one outbox record was expected');

        Assert.IsTrue(Outbox.FindFirst(), 'An Email Outbox record should have been inserted.');
        Assert.AreEqual('Test Subject', Outbox.Description, 'A different description was expected');
        Assert.AreEqual(Enum::"Email Connector"::"Test Email Connector".AsInteger(), Outbox.Connector.AsInteger(), 'A different connector was expected.');
        Assert.AreEqual(TempAccount."Account Id", Outbox."Account Id", 'A different account was expected');
        Assert.AreEqual('', Outbox."Send From", 'An empty sent from was expected');
        Assert.AreEqual(Enum::"Email Status"::Draft.AsInteger(), Outbox.Status.AsInteger(), 'A different sent from was expected');

        Assert.IsTrue(Message.Get(Outbox."Message Id"), 'The email message should have been created');
        Assert.AreEqual('Test Subject', Message.Subject, 'Wrong subject on the email message');

        EmailRecipient.SetRange("Email Message Id", Message.Id);
        Assert.IsTrue(EmailRecipient.FindSet(), 'Email recipient should have been created');
        Assert.AreEqual(Enum::"Email Recipient Type"::"To", EmailRecipient."Email Recipient Type", 'Wrong recipient type');
        Assert.AreEqual('recipient1@test.com', EmailRecipient."Email Address", 'Wrong email address on the recipient');
        Assert.AreEqual(0, EmailRecipient.Next(), 'There should not be another recipient');
    end;

    [Test]
    [HandlerFunctions('ChooseAccountHandler,DiscardEmailEditorHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure DiscardEmailThroughEditor()
    var
        TempAccount: Record "Email Account" temporary;
        Outbox: Record "Email Outbox";
        SentEmails: Record "Sent Email";
        Message: Record "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        EmailEditor: Page "Email Editor";
        Editor: TestPage "Email Editor";
    begin
        // [SCENARIO] When the editor page is closed and the user choose to discard the email, there is no outbox entry.
        SentEmails.DeleteAll();

        // [GIVEN] A connector is installed and an account is added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        PermissionsMock.Set('Email Admin');
        GiveUserViewAllPolicy();

        // [GIVEN] There are no Record in Email Outbox and no messages
        Outbox.DeleteAll();
        Message.DeleteAll();

        // [GIVEN] The Email Editor pages opens up and details are filled
        Editor.Trap();
        EmailEditor.Run();

        Editor.Account.AssistEdit(); // Handled in ChooseAccountHandler
        Editor.ToField.SetValue('recipient@test.com');
        Editor.SubjectField.SetValue('Test Subject');
        Editor.BodyField.SetValue('Test body');

        // [WHEN] The page is closed and the email is discarded. See DiscardEmailEditorHandler
        Editor.Close();

        // [THEN] The mail is saved in the outbox as a draft and the info is correct
        Outbox.Reset();
        Assert.AreEqual(0, Outbox.Count(), 'No Outbox records were expected');
        Assert.AreEqual(0, Message.Count(), 'No Message records were expected');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure SaveExistingDraftThroughEditor()
    var
        TempAccount: Record "Email Account" temporary;
        Outbox: Record "Email Outbox";
        OutboxForUser: Record "Email Outbox" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        Message: Codeunit "Email Message";
        Editor: TestPage "Email Editor";
        OutboxPage: TestPage "Email Outbox";
        DraftId: Guid;
        Recipients: List of [Text];
    begin
        // [SCENARIO] When an existing draft is opened and the editor page is closed, the draft email is saved

        // [GIVEN] A connector is installed and an account is added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        PermissionsMock.Set('Email Edit');

        // [GIVEN] There is no Outbox record
        Outbox.DeleteAll();

        // [GIVEN] A draft email message exists
        Recipients.Add('recipient1@test.com');
        Message.Create(Recipients, 'Test Subject', 'Test body', true);
        DraftId := Message.GetId();
        Outbox.Init();
        Outbox."Message Id" := DraftId;
        Outbox.Description := 'Test Subject';
        Outbox.Connector := Enum::"Email Connector"::"Test Email Connector";
        Outbox."Account Id" := TempAccount."Account Id";
        Outbox.Status := Enum::"Email Status"::Draft;
        Outbox."User Security Id" := UserSecurityId();
        Outbox.Insert();

        // [GIVEN] The draft email was opened from outbox and subject is changed
        Editor.Trap();
        OutboxPage.OpenView();
        OutboxForUser.Transferfields(Outbox);
        OutboxPage.GoToRecord(OutboxForUser);
        OutboxPage.Desc.Drilldown();
        Editor.SubjectField.SetValue('Test Subject Changed');

        // [WHEN] The page page is closed and the email is saved as draft again
        Editor.Close(); // Draft email is saved on close

        // [THEN] The mail is saved as the same draft in the outbox, no new draft is created and the info is correct
        Outbox.Reset();
        Assert.AreEqual(1, Outbox.Count(), 'Only one outbox record was expected');
        Outbox.SetRange("Message Id", DraftId);
        Assert.AreEqual(1, Outbox.Count(), 'Only one outbox record was expected');
        Assert.IsTrue(Outbox.FindFirst(), 'An Email Outbox record should have been inserted.');
        Assert.AreEqual('Test Subject Changed', Outbox.Description, 'A different description was expected');
        Assert.AreEqual(Enum::"Email Connector"::"Test Email Connector".AsInteger(), Outbox.Connector.AsInteger(), 'A different connector was expected.');
        Assert.AreEqual(TempAccount."Account Id", Outbox."Account Id", 'A different account was expected');
        Assert.AreEqual('', Outbox."Send From", 'An empty sent from was expected');
        Assert.AreEqual(Enum::"Email Status"::Draft.AsInteger(), Outbox.Status.AsInteger(), 'A different sent from was expected');
    end;

    [Test]
    procedure SendNewMessageThroughEditorTest()
    var
        TempAccount: Record "Email Account" temporary;
        SentEmail: Record "Sent Email";
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Editor: TestPage "Email Editor";
    begin
        // [SCENARIO] A new email message can be create in the email editor page from the Accouns page
        // [GIVEN] A connector is installed and an account is added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        PermissionsMock.Set('Email Edit');

        // [GIVEN] The Email Editor pages opens up and details are filled
        Editor.Trap();
        EmailMessage.Create('', '', '', false);
        Email.OpenInEditor(EmailMessage, TempAccount);

        Editor.ToField.SetValue('recipient@test.com');
        Editor.SubjectField.SetValue('Test Subject');
        Editor.BodyField.SetValue('Test body');

        // [WHEN] The send action is invoked
        Editor.Send.Invoke();

        // [THEN] The mail is sent and the info is correct
        EmailMessage.Get(ConnectorMock.GetEmailMessageID());
        SentEmail.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(SentEmail.FindFirst(), 'A Sent Email record should have been inserted.');
        Assert.AreEqual('Test Subject', SentEmail.Description, 'A different description was expected');
        Assert.AreEqual(TempAccount."Account Id", SentEmail."Account Id", 'A different account was expected');
        Assert.AreEqual(TempAccount."Email Address", SentEmail."Sent From", 'A different sent from was expected');
        Assert.AreEqual(Enum::"Email Connector"::"Test Email Connector", SentEmail.Connector, 'A different connector was expected');
    end;

    [Test]
    procedure RunEmailDispatcherWithEventsErrorTest()
    var
        TempAccount: Record "Email Account" temporary;
        EmailOutbox: Record "Email Outbox";
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Result: Boolean;
    begin
        // [SCENARIO] Event errors should not cause email dispatcher to fail. They should be running in isolated mode.
        BindSubscription(EmailE2ETests);

        // [GIVEN] A connector is installed and an account is added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        PermissionsMock.Set('Email Edit');

        // [GIVEN] Email message is created and saved as draft
        EmailMessage.Create('', '', '', false);
        Email.SaveAsDraft(EmailMessage, EmailOutbox);
        Commit();

        // [WHEN] Run dispatcher
        // [THEN] The dispatcher runs successfully
        Result := Codeunit.Run(Codeunit::"Email Error Handler", EmailOutbox);
        Assert.IsTrue(Result, GetLastErrorText());

        UnBindSubscription(EmailE2ETests);
    end;

    [Test]
    procedure RunErrorHandlerWithEventsErrorTest()
    var
        TempAccount: Record "Email Account" temporary;
        EmailOutbox: Record "Email Outbox";
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Result: Boolean;
    begin
        // [SCENARIO] Event errors should not cause error handler to fail. They should running in isolated mode.
        BindSubscription(EmailE2ETests);

        // [GIVEN] A connector is installed and an account is added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        PermissionsMock.Set('Email Edit');

        // [GIVEN] Email message is created and saved as draft
        EmailMessage.Create('', '', '', false);
        Email.SaveAsDraft(EmailMessage, EmailOutbox);
        Commit();

        // [WHEN] Assume dispatcher error'd, run error handler
        // [THEN] The error handler runs successfully
        Result := Codeunit.Run(Codeunit::"Email Error Handler", EmailOutbox);
        Assert.IsTrue(Result, GetLastErrorText());

        UnBindSubscription(EmailE2ETests);
    end;

    [Test]
    procedure SendNewMessageThroughEditorFailureAndCorrectionTest()
    var
        TempAccount: Record "Email Account" temporary;
        SentEmail: Record "Sent Email";
        Outbox: Record "Email Outbox";
        OutboxForUser: Record "Email Outbox" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Editor: TestPage "Email Editor";
        OutboxPage: TestPage "Email Outbox";
    begin
        // [SCENARIO] A new email message can be created and corrected in the email editor after successful sending only one record in Sent emails exists and not record in outbox

        // [GIVEN] A connector is installed and an account is added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        PermissionsMock.Set('Email Edit');

        // [GIVEN] There was a mistake on typing the email
        ConnectorMock.FailOnSend(true);

        // [GIVEN] The Email Editor pages opens up and details are filled
        Editor.Trap();
        EmailMessage.Create('', '', '', false);
        Email.OpenInEditor(EmailMessage, TempAccount);

        Editor.ToField.SetValue('recipient@test.com');
        Editor.SubjectField.SetValue('Test Subject');
        Editor.BodyField.SetValue('Test body');

        // [WHEN] The send action is invoked
        asserterror Editor.Send.Invoke();
        Assert.ExpectedError('Failed to send email');
        Editor.Close();

        // [THEN] There is a record in Outbox for this email with status failed
        EmailMessage.Get(ConnectorMock.GetEmailMessageID());
        Outbox.SetRange("Message Id", EmailMessage.GetId());
        Assert.AreEqual(1, Outbox.Count(), 'Only one outbox record was expected');
        Assert.IsTrue(Outbox.FindFirst(), 'An Email Outbox record should have been inserted.');
        Assert.AreEqual('Test Subject', Outbox.Description, 'A different description was expected');
        Assert.AreEqual(Enum::"Email Connector"::"Test Email Connector".AsInteger(), Outbox.Connector.AsInteger(), 'A different connector was expected.');
        Assert.AreEqual(TempAccount."Account Id", Outbox."Account Id", 'A different account was expected');
        Assert.AreEqual(TempAccount."Email Address", Outbox."Send From", 'A different sent from was expected');
        Assert.AreEqual(Enum::"Email Status"::Failed.AsInteger(), Outbox.Status.AsInteger(), 'A different sent from was expected');

        // [GIVEN] The email was opened from outbox and corrected
        ConnectorMock.FailOnSend(false);
        Editor.Trap();
        OutboxPage.OpenView();
        OutboxForUser.Transferfields(Outbox);
        OutboxPage.GoToRecord(OutboxForUser);
        OutboxPage.Desc.Drilldown();

        // [WHEN] The email is sent again

        Editor.Send.Invoke();

        // [THEN] The mail is sent and the info is correct and the outbox record for the previous failure is deleted
        EmailMessage.Get(ConnectorMock.GetEmailMessageID());
        Outbox.SetRange("Message Id", EmailMessage.GetId());
        Assert.AreEqual(0, Outbox.Count(), 'No Oubox records were expected.');

        SentEmail.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(SentEmail.FindFirst(), 'A Sent Email record should have been inserted.');
        Assert.AreEqual('Test Subject', SentEmail.Description, 'A different description was expected');
        Assert.AreEqual(TempAccount."Account Id", SentEmail."Account Id", 'A different account was expected');
        Assert.AreEqual(TempAccount."Email Address", SentEmail."Sent From", 'A different sent from was expected');
        Assert.AreEqual(Enum::"Email Connector"::"Test Email Connector", SentEmail.Connector, 'A different connector was expected');
    end;

    [Test]
    [HandlerFunctions('MessageQueued')]
    procedure OpenAndResendSentEmailTest()
    var
        TempAccount: Record "Email Account" temporary;
        SentEmail: Record "Sent Email";
        Any: Codeunit Any;
        EmailMessage: Codeunit "Email Message";
        Base64Convert: Codeunit "Base64 Convert";
        ConnectorMock: Codeunit "Connector Mock";
        EmailViewer: TestPage "Email Viewer";
        SentEmails: TestPage "Sent Emails";
        Recipient, Subject, Body : Text;
    begin
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        PermissionsMock.Set('Email Edit');

        Recipient := Any.Email();
        Subject := Any.UnicodeText(50);
        Body := Any.UnicodeText(1024);

        EmailMessage.Create(Recipient, Subject, Body, true);
        EmailMessage.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));
        EmailMessage.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));

        // Send the email
        Email.Send(EmailMessage, TempAccount."Account Id", TempAccount.Connector);

        SentEmail.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(SentEmail.FindFirst(), 'A sent email record should have been created');

        // Exercise
        SentEmails.Trap();
        Page.Run(Page::"Sent Emails");

        Assert.IsTrue(SentEmails.GoToRecord(SentEmail), 'The sent email record should be present on the Sent Emails page');

        // Open the Sent Email
        EmailViewer.Trap();
        SentEmails.Desc.Drilldown();

        // Verify
        Assert.IsFalse(EmailViewer.Account.Editable(), 'Account field is editable');
        Assert.AreEqual(StrSubstNo(FromDisplayNameLbl, TempAccount.Name, TempAccount."Email Address"), EmailViewer.Account.Value(), 'Account value is incorrect');

        Assert.IsFalse(EmailViewer.ToField.Editable(), 'To field is editable');
        Assert.AreEqual(Recipient, EmailViewer.ToField.Value(), 'To field value is incorrect');

        Assert.IsFalse(EmailViewer.CcField.Editable(), 'Cc field is editable');
        Assert.AreEqual('', EmailViewer.CcField.Value(), 'Cc field value is incorrect');

        Assert.IsFalse(EmailViewer.BccField.Editable(), 'Bcc field is editable');
        Assert.AreEqual('', EmailViewer.BccField.Value(), 'Bcc field value is incorrect');

        Assert.IsFalse(EmailViewer.SubjectField.Editable(), 'Subject field is editable');
        Assert.AreEqual(Subject, EmailViewer.SubjectField.Value(), 'Subject field value is incorrect');

        Assert.IsFalse(EmailViewer.BodyField.Editable(), 'Body field is editable');
        Assert.AreEqual(Body, EmailViewer.BodyField.Value(), 'Body field value is incorrect');

        Assert.IsFalse(EmailViewer.Attachments.Delete.Visible(), 'Delete attachment is visible');
        Assert.IsFalse(EmailViewer.Attachments.Upload.Visible(), 'Visible attachment is visible');

        Assert.IsTrue(EmailViewer.Resend.Visible(), 'Resend action should be visible');
        Assert.IsTrue(EmailViewer.Resend.Enabled(), 'Resend action should be enabled');

        // Resend the send email
        EmailViewer.Resend.Invoke();

        // Message appears (see MessageQueued handler)
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OpenSentEmailFromAnotherUserTest()
    var
        SentEmail: Record "Sent Email";
        EmailMessage: Record "Email Message";
        Any: Codeunit Any;
        SentEmails: TestPage "Sent Emails";
        EmailViewer: TestPage "Email Viewer";
    begin
        // Create a sent email
        PermissionsMock.Set('Email Admin');
        GiveUserViewAllPolicy();

        EmailMessage.Init();
        EmailMessage.Subject := 'Test';
        EmailMessage.Insert();

        SentEmail.Init();
        SentEmail.Description := CopyStr(Any.UnicodeText(50), 1, MaxStrLen(SentEmail.Description));
        SentEmail."Date Time Sent" := CurrentDateTime();
        SentEmail."User Security Id" := CreateGuid(); // Created by another user
        SentEmail."Message Id" := EmailMessage.Id;
        SentEmail.Insert();

        // Exercise
        SentEmails.Trap();
        EmailViewer.Trap();
        Page.Run(Page::"Sent Emails");

        Assert.IsTrue(SentEmails.GoToRecord(SentEmail), 'The sent email record should be present on the Sent Emails page');

        // No error should appear when a admin user tries to open an email sent from another user
        SentEmails.Desc.Drilldown();
        EmailViewer.OK().Invoke();
    end;

    [Test]
    procedure CopyRelatedRecordsWhenEditSend()
    var
        TempAccount: Record "Email Account" temporary;
        SentEmail: Record "Sent Email";
        EmailRelatedRecord: Record "Email Related Record";
        Any: Codeunit Any;
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        EmailEditor: TestPage "Email Editor";
        SentEmails: TestPage "Sent Emails";
        Recipients: List of [Text];
        TableId, NumberOfRelations, i : Integer;
        SystemId: Guid;
    begin
        // Initialize
        SentEmail.DeleteAll();
        EmailRelatedRecord.DeleteAll();
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        PermissionsMock.Set('Email Edit');

        Recipients.Add('recipient@test.com');
        EmailMessage.Create(Recipients, 'Test subject', 'Test body', true);

        NumberOfRelations := Any.IntegerInRange(2, 5);
        TableId := Any.IntegerInRange(1, 10000);
        for i := 1 to NumberOfRelations do begin
            SystemId := Any.GuidValue();
            Email.AddRelation(EmailMessage, TableId, SystemId, Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");
        end;

        // Send the email
        Email.Send(EmailMessage, TempAccount."Account Id", TempAccount.Connector);

        SentEmail.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(SentEmail.FindFirst(), 'A sent email record should have been created');

        // Check if the email has a related record 
        EmailRelatedRecord.SetRange("Table Id", TableId);
        Assert.AreEqual(NumberOfRelations, EmailRelatedRecord.Count(), 'Not all related records were created for sent email');

        // Exercise
        SentEmails.Trap();
        Page.Run(Page::"Sent Emails");

        Assert.IsTrue(SentEmails.GoToRecord(SentEmail), 'The sent email record should be present on the Sent Emails page');

        // Open the Sent Email by Edit and Send 
        EmailEditor.Trap();
        SentEmails.EditAndSend.Invoke();

        // Send 
        EmailEditor.Send.Invoke();

        // Verify
        EmailRelatedRecord.SetRange("Table Id", TableId);
        Assert.AreEqual(2 * NumberOfRelations, EmailRelatedRecord.Count(), 'Not all related records were copied over when Edit and Send');
    end;

    [Test]
    [HandlerFunctions('MessageQueued')]
    procedure CopyRelatedRecordsWhenResend()
    var
        TempAccount: Record "Email Account" temporary;
        SentEmail: Record "Sent Email";
        EmailRelatedRecord: Record "Email Related Record";
        Any: Codeunit Any;
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        SentEmails: TestPage "Sent Emails";
        Recipients: List of [Text];
        TableId, NumberOfRelations, i : Integer;
        SystemId: Guid;
    begin
        // Initialize
        SentEmail.DeleteAll();
        EmailRelatedRecord.DeleteAll();
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        PermissionsMock.Set('Email Edit');

        Recipients.Add('recipient@test.com');
        EmailMessage.Create(Recipients, 'Test subject', 'Test body', true);

        NumberOfRelations := Any.IntegerInRange(2, 5);
        TableId := Any.IntegerInRange(1, 10000);
        for i := 1 to NumberOfRelations do begin
            SystemId := Any.GuidValue();
            Email.AddRelation(EmailMessage, TableId, SystemId, Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");
        end;

        // Send the email
        Email.Send(EmailMessage, TempAccount."Account Id", TempAccount.Connector);

        SentEmail.SetRange("Message Id", EmailMessage.GetId());
        Assert.IsTrue(SentEmail.FindFirst(), 'A sent email record should have been created');

        // Check if the email has a related record 
        EmailRelatedRecord.SetRange("Table Id", TableId);
        Assert.AreEqual(NumberOfRelations, EmailRelatedRecord.Count(), 'Not all related records were created for sent email');

        // Exercise
        SentEmails.Trap();
        Page.Run(Page::"Sent Emails");

        Assert.IsTrue(SentEmails.GoToRecord(SentEmail), 'The sent email record should be present on the Sent Emails page');

        // Open the Sent Email by Edit and Send 
        SentEmails.Resend.Invoke();

        // Verify
        EmailRelatedRecord.SetRange("Table Id", TableId);
        Assert.AreEqual(2 * NumberOfRelations, EmailRelatedRecord.Count(), 'Not all related records were copied over when resending');
    end;

    [Test]
    procedure EmailOutboxEntriesVisibilityTest()
    var
        EmailOutbox: Record "Email Outbox";
        EmailViewPolicy: Record "Email View Policy";
        EmailOutboxes: TestPage "Email Outbox";
        EmailEditor: TestPage "Email Editor";
        EmailOutboxesIds: List of [BigInteger];
        i: Integer;
        iAsText: Text;
    begin
        // [Scenario] Email Outbox entries can only be opened by the user who created them
        PermissionsMock.Set('Email Admin');

        EmailViewPolicy.DeleteAll();
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::OwnEmails;
        EmailViewPolicy.Insert();

        // Create four email outbox entries
        EmailOutbox.DeleteAll();
        for i := 1 to 4 do begin
            iAsText := Format(i);
            CreateEmailOutbox('Recipient ' + iAsText, 'Subject ' + iAsText, 'Body ' + iAsText, 'Attachment Name ' + iAsText, 'Attachment Content ' + iAsText, EmailOutbox);
            EmailOutboxesIds.Add(EmailOutbox.Id);
            if (i mod 2) = 0 then begin
                EmailOutbox."User Security Id" := CreateGuid(); // some other user;
                EmailOutbox.Modify();
            end;
        end;

        Commit(); // Commit the Email Outbox entries so they can be loaded in the Email Editor later on.

        EmailOutboxes.Trap();
        Page.Run(Page::"Email Outbox");

        EmailOutboxes.GoToKey(EmailOutboxesIds.Get(3));
        Assert.AreEqual(Enum::"Email Status"::Draft.AsInteger(), EmailOutboxes.Status.AsInteger(), 'Wrong status on the email outbox');
        Assert.AreEqual('Subject 3', EmailOutboxes.Desc.Value(), 'Wrong description on the email outbox');
        Assert.AreEqual('', EmailOutboxes.Error.Value(), 'Error message field should be empty');
        EmailEditor.Trap();
        EmailOutboxes.Desc.Drilldown();

        EmailOutboxes.GoToKey(EmailOutboxesIds.Get(1));
        Assert.AreEqual(Enum::"Email Status"::Draft.AsInteger(), EmailOutboxes.Status.AsInteger(), 'Wrong status on the email outbox');
        Assert.AreEqual('Subject 1', EmailOutboxes.Desc.Value(), 'Wrong description on the email outbox');
        Assert.AreEqual('', EmailOutboxes.Error.Value(), 'Error message field should be empty');
        EmailEditor.Trap();
        EmailOutboxes.Desc.Drilldown();

        Assert.AreEqual('Recipient 1', EmailEditor.ToField.Value(), 'Wrong recipient on the email outbox');
        Assert.AreEqual('Subject 1', EmailEditor.SubjectField.Value(), 'Wrong subject on email outbox in email editor');
        Assert.AreEqual('Body 1', EmailEditor.BodyField.Value(), 'Wrong body on email outbox in email editor');
        Assert.AreEqual('Attachment Name 1', EmailEditor.Attachments.FileName.Value(), 'Wrong attachment name on email outbox');

        RemoveViewPolicies();
    end;

    [Test]
    procedure OpenRelatedEmailsForRecord()
    var
        TempAccount: Record "Email Account" temporary;
        SentEmail: Record "Sent Email";
        Any: Codeunit Any;
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        SentEmails: TestPage "Sent Emails";
        Recipient, Subject, Body : Text;
        SourceTable: Integer;
        SourceSystemID, EmailMessageWithSource, EmailMessageWithoutSource : Guid;
    begin
        // [Scenario] Show sent emails page for emails related to a record
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        PermissionsMock.Set('Email Edit');

        // [Given] An email with a related record
        Recipient := Any.Email();
        Subject := Any.UnicodeText(50);
        Body := Any.UnicodeText(1024);

        EmailMessage.Create(Recipient, Subject, Body, true);

        SourceTable := 18;
        SourceSystemID := CreateGuid();
        Email.AddRelation(EmailMessage, SourceTable, SourceSystemID, Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Compose Context");

        EmailMessageWithSource := EmailMessage.GetId();

        // [When] Sending the email with a related record
        Email.Send(EmailMessage, TempAccount."Account Id", TempAccount.Connector);

        // [And] Sending an email without a related record
        EmailMessage.Create(Recipient, Subject, Body, true);
        EmailMessageWithoutSource := EmailMessage.GetId();
        Email.Send(EmailMessage, TempAccount."Account Id", TempAccount.Connector);

        // [When] The sent emails page is opened for the source
        SentEmail.SetRange("Message Id", EmailMessageWithSource);
        Assert.IsTrue(SentEmail.FindFirst(), 'A sent email record should have been created');

        SentEmails.Trap();
        Email.OpenSentEmails(SourceTable, SourceSystemID);

        // [Then] The email with source should appear on the sent emails page
        Assert.IsTrue(SentEmails.GoToRecord(SentEmail), 'The sent email record should be present on the Sent Emails page');

        // [And] The email without source should not 
        SentEmail.SetRange("Message Id", EmailMessageWithoutSource);
        Assert.IsTrue(SentEmail.FindFirst(), 'A sent email record should have been created');
        Assert.IsFalse(SentEmails.GoToRecord(SentEmail), 'The sent email without email relation should not be listed');
    end;

    [Test]
    procedure OpenRelatedEmailsForRecordVariant()
    var
        TempAccount: Record "Email Account" temporary;
        SentEmail: Record "Sent Email";
        Any: Codeunit Any;
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        RecordVariant: Variant;
        SentEmails: TestPage "Sent Emails";
        Recipient, Subject, Body : Text;
        EmailMessageWithSource, EmailMessageWithoutSource : Guid;
    begin
        // [Scenario] Show sent emails page for emails related to a record
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        PermissionsMock.Set('Email Edit');

        // [Given] An email with a related record
        Recipient := Any.Email();
        Subject := Any.UnicodeText(50);
        Body := Any.UnicodeText(1024);

        EmailMessage.Create(Recipient, Subject, Body, true);
        EmailMessageWithSource := EmailMessage.GetId();

        SentEmail.Id := 10000;
        SentEmail."Message Id" := CreateGuid();
        SentEmail."Account Id" := CreateGuid();
        SentEmail."Date Time Sent" := CurrentDateTime();
        SentEmail.Description := 'Test';
        SentEmail.Insert();
        RecordVariant := SentEmail;

        Email.AddRelation(EmailMessage, Database::"Sent Email", SentEmail.SystemId, Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Compose Context");

        // [When] Sending the email with a related record
        Email.Send(EmailMessage, TempAccount."Account Id", TempAccount.Connector);

        // [And] Sending an email without a related record
        EmailMessage.Create(Recipient, Subject, Body, true);
        EmailMessageWithoutSource := EmailMessage.GetId();
        Email.Send(EmailMessage, TempAccount."Account Id", TempAccount.Connector);

        // [When] The sent emails page is opened for the source
        SentEmail.SetRange("Message Id", EmailMessageWithSource);
        Assert.IsTrue(SentEmail.FindFirst(), 'A sent email record should have been created');

        SentEmails.Trap();
        Email.OpenSentEmails(RecordVariant);

        // [Then] The email with source should appear on the sent emails page
        Assert.IsTrue(SentEmails.GoToRecord(SentEmail), 'The sent email record should be present on the Sent Emails page');

        // [And] The email without source should not 
        SentEmail.SetRange("Message Id", EmailMessageWithoutSource);
        Assert.IsTrue(SentEmail.FindFirst(), 'A sent email record should have been created');
        Assert.IsFalse(SentEmails.GoToRecord(SentEmail), 'The sent email without email relation should not be listed');

        SentEmail.DeleteAll();
    end;

    local procedure GiveUserViewAllPolicy()
    var
        EmailViewPolicy: Record "Email View Policy";
    begin
        EmailViewPolicy."User Security ID" := UserSecurityId();
        EmailViewPolicy."Email View Policy" := Enum::"Email View Policy"::AllEmails;
        EmailViewPolicy.Insert();
    end;

    local procedure RemoveViewPolicies()
    var
        EmailViewPolicy: Record "Email View Policy";
    begin
        EmailViewPolicy.DeleteAll();
    end;

    local procedure CreateEmailOutbox(Recipient: Text; Subject: Text; Body: Text; AttachmentName: Text[250]; AttachmentContent: Text; var EmailOutbox: Record "Email Outbox")
    var
        EmailMessage: Codeunit "Email Message";
        Base64Convert: Codeunit "Base64 Convert";
    begin
        Clear(EmailOutbox);
        EmailMessage.Create(Recipient, Subject, Body, false);
        EmailMessage.AddAttachment(AttachmentName, 'text/plain', Base64Convert.ToBase64(AttachmentContent));
        Email.SaveAsDraft(EmailMessage, EmailOutbox);
    end;

    [MessageHandler]
    procedure MessageQueued(Message: Text[1024])
    begin
        Assert.AreEqual(EmailWasQueuedForSendingMsg, Message, 'Wrong message when resending an email');
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ChooseAccountHandler(var Page: TestPage "Email Accounts")
    begin
        Page.First();
        Page.OK().Invoke();
    end;

    [StrMenuHandler]
    [Scope('OnPrem')]
    procedure DiscardEmailEditorHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Choice := 2; // Discard email message
    end;

    [StrMenuHandler]
    [Scope('OnPrem')]
    procedure SaveAsDraftOnCloseHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Choice := 1;
    end;

    // This event is for ensuring that there are no open transactions when this event is invoked
    // It will throw an error and if there are no open transcations, the event would be isolated
    [EventSubscriber(ObjectType::Codeunit, Codeunit::Email, 'OnAfterEmailSent', '', false, false)]
    local procedure OnAfterEmailSent(SentEmail: Record "Sent Email")
    begin
        Error('An open transcation exists');
    end;

    // This event is for ensuring that there are no open transactions when this event is invoked
    // It will throw an error and if there are no open transcations, the event would be isolated
    [EventSubscriber(ObjectType::Codeunit, Codeunit::Email, 'OnAfterEmailSendFailed', '', false, false)]
    local procedure OnAfterEmailSendFailed(EmailOutbox: Record "Email Outbox")
    begin
        Error('An open transcation exists');
    end;
}