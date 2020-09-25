// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 134692 "Email E2E Tests"
{
    SubType = Test;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    // [HandlerFunctions()]
    procedure SendNewMessageThroughEditorTest()
    var
        TempAccount: Record "Email Account" temporary;
        SentEmail: Record "Sent Email";
        ConnectorMock: Codeunit "Connector Mock";
        Message: Codeunit "Email Message";
        EmailEditor: Page "Email Editor";
        Editor: TestPage "Email Editor";
    begin
        // [SCENARIO] A new email message can be create in the email editor page from the Accouns page

        // [GIVEN] A connector is installed and an account is added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        // [GIVEN] The Email Editor pages opens up and details are filled
        Editor.Trap();
        EmailEditor.SetEmailAccount(TempAccount);
        EmailEditor.Run();

        Editor.ToField.SetValue('recipient@test.com');
        Editor.SubjectField.SetValue('Test Subject');
        Editor.BodyField.SetValue('Test body');

        // [WHEN] The send action is invoked
        Editor.Send.Invoke();

        // [THEN] The mail is sent and the info is correct
        Message.Find(ConnectorMock.GetEmailMessageID());
        SentEmail.SetRange("Message Id", Message.GetId());
        Assert.IsTrue(SentEmail.FindFirst(), 'A Sent Email record should have been inserted.');
        Assert.AreEqual('Test Subject', SentEmail.Description, 'A different description was expected');
        Assert.AreEqual(TempAccount."Account Id", SentEmail."Account Id", 'A different account was expected');
        Assert.AreEqual(TempAccount."Email Address", SentEmail."Sent From", 'A different sent from was expected');
        Assert.AreEqual(Enum::"Email Connector"::"Test Email Connector", SentEmail.Connector, 'A different connector was expected');
    end;

    [Test]
    [HandlerFunctions('CloseEmailEditorHandler')]
    procedure SendNewMessageThroughEditorFailureAndCorrectionTest()
    var
        TempAccount: Record "Email Account" temporary;
        SentEmail: Record "Sent Email";
        Outbox: Record "Email Outbox";
        OutboxForUser: Record "Email Outbox For User";
        ConnectorMock: Codeunit "Connector Mock";
        Message: Codeunit "Email Message";
        EmailEditor: Page "Email Editor";
        Editor: TestPage "Email Editor";
        OutboxPage: TestPage "Email Outbox";
    begin
        // [SCENARIO] A new email message can be created and corrected in the email editor after successful sending only one record in Sent emails exists and not record in outbox

        // [GIVEN] A connector is installed and an account is added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        // [GIVEN] There was a mistake on typing the email
        ConnectorMock.FailOnSend(true);

        // [GIVEN] The Email Editor pages opens up and details are filled
        Editor.Trap();
        EmailEditor.SetEmailAccount(TempAccount);
        EmailEditor.Run();

        Editor.ToField.SetValue('recipient@test.com');
        Editor.SubjectField.SetValue('Test Subject');
        Editor.BodyField.SetValue('Test body');

        // [WHEN] The send action is invoked
        asserterror Editor.Send.Invoke();
        Assert.ExpectedError('Failed to send email');
        Editor.Close();

        // [THEN] There is a record in Outbox for this email with status failed
        Message.Find(ConnectorMock.GetEmailMessageID());
        Outbox.SetRange("Message Id", Message.GetId());
        Assert.RecordCount(Outbox, 1);
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
        Message.Find(ConnectorMock.GetEmailMessageID());
        Outbox.SetRange("Message Id", Message.GetId());
        Assert.RecordIsEmpty(Outbox);

        SentEmail.SetRange("Message Id", Message.GetId());
        Assert.IsTrue(SentEmail.FindFirst(), 'A Sent Email record should have been inserted.');
        Assert.AreEqual('Test Subject', SentEmail.Description, 'A different description was expected');
        Assert.AreEqual(TempAccount."Account Id", SentEmail."Account Id", 'A different account was expected');
        Assert.AreEqual(TempAccount."Email Address", SentEmail."Sent From", 'A different sent from was expected');
        Assert.AreEqual(Enum::"Email Connector"::"Test Email Connector", SentEmail.Connector, 'A different connector was expected');
    end;

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
        // [SCENARIO] When the last entry for a specific message is deleted from the sent mails the whole message is deleted


        // [GIVEN] A connector is installed and an account is added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        // [GIVEn] A email message is created
        Recipients.Add('recipient1@test.com');
        Recipients.Add('recipient2@test.com');
        Message.CreateMessage(Recipients, 'Test subject', 'Test body', true);
        Message.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));
        Message.AddAttachment('Attachment2', 'text/plain', Base64Convert.ToBase64('Content'));

        // [GIVEN] The message has been sent several times
        SentEmail.Init();
        SentEmail."Message Id" := Message.GetId();
        SentEmail.Insert();

        SentEmail.Id := SentEmail.Id + 1;
        SentEmail."Message Id" := Message.GetId();
        SentEmail.Insert();

        // [WHEN] The first sent mail record is deleted
        SentEmail.SetRange("Message Id", Message.GetId());
        SentEmail.FindSet();
        SentEmail.Delete();

        // [THEN] The email message is kept
        Assert.IsTrue(Message.Find(Message.GetId()), 'The message was not found.');

        // [WHEN] The second sent mail record is deleted
        SentEmail.Next();
        SentEmail.Delete();



        // [THEN] All references to the message are also deleted
        Assert.IsFalse(Message.Find(Message.GetId()), 'The message was not deleted.');

        EmailRecipient.SetRange("Email Message Id", Message.GetId());
        Assert.RecordIsEmpty(EmailRecipient);

        Attachment.SetRange("Email Message Id", Message.GetId());
        Assert.RecordIsEmpty(Attachment);
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
        // [SCENARIO] When the last entry for a specific message is deleted from the outbox the whole message is deleted


        // [GIVEN] A connector is installed and an account is added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        // [GIVEn] A email message is created
        Recipients.Add('recipient1@test.com');
        Recipients.Add('recipient2@test.com');
        Message.CreateMessage(Recipients, 'Test subject', 'Test body', true);
        Message.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));
        Message.AddAttachment('Attachment2', 'text/plain', Base64Convert.ToBase64('Content'));

        // [GIVEN] The message has been queued several times
        Outbox.Init();
        Outbox."Message Id" := Message.GetId();
        Outbox.Insert();

        Outbox.Id := Outbox.Id + 1;
        Outbox."Message Id" := Message.GetId();
        Outbox.Insert();

        // [WHEN] The first outbox record is deleted
        Outbox.SetRange("Message Id", Message.GetId());
        Outbox.FindSet();
        Outbox.Delete();

        // [THEN] The email message is kept
        Assert.IsTrue(Message.Find(Message.GetId()), 'The message was not found.');

        // [WHEN] The second outbox record is deleted
        Outbox.Next();
        Outbox.Delete();



        // [THEN] All references to the message are also deleted
        Assert.IsFalse(Message.Find(Message.GetId()), 'The message was not deleted.');

        EmailRecipient.SetRange("Email Message Id", Message.GetId());
        Assert.RecordIsEmpty(EmailRecipient);

        Attachment.SetRange("Email Message Id", Message.GetId());
        Assert.RecordIsEmpty(Attachment);
    end;

    //     [MessageHandler()]
    //     procedure EmailQueuedMessageHandler(Message: Text[1024])
    //     begin
    //         Assert.AreEqual('', Message);
    //     end;
    [StrMenuHandler]
    [Scope('OnPrem')]
    procedure CloseEmailEditorHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Choice := 2;
    end;
}