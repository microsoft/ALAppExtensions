codeunit 134689 "Email Message Unit Test"
{
    Subtype = Test;
    Permissions = tabledata "Email Outbox" = ri,
                  tabledata "Email Message" = rm,
                  tabledata "Email Recipient" = ri;

    var
        Assert: Codeunit "Library Assert";
        Email: Codeunit Email;
        PermissionsMock: Codeunit "Permissions Mock";
#pragma warning disable AA0240
#pragma warning disable AA0470
        RecipientLbl: Label 'recipient%1@test.com',;
#pragma warning restore AA0240
#pragma warning restore AA0470
        EmailMessageQueuedCannotModifyErr: Label 'Cannot edit the email because it has been queued to be sent.';
        EmailMessageSentCannotModifyErr: Label 'Cannot edit the message because it has already been sent.';
        EmailMessageQueuedCannotInsertAttachmentErr: Label 'Cannot add the attachment because the email is queued to be sent.';
        EmailMessageSentCannotInsertAttachmentErr: Label 'Cannot add the attachment because the email has already been sent.';
        EmailMessageQueuedCannotDeleteRecipientErr: Label 'Cannot delete the recipient because the email is queued to be sent.';
        EmailMessageSentCannotDeleteRecipientErr: Label 'Cannot delete the recipient because the email has already been sent.';
        EmailMessageQueuedCannotInsertRecipientErr: Label 'Cannot add a recipient because the email is queued to be sent.';
        EmailMessageSentCannotInsertRecipientErr: Label 'Cannot add the recipient because the email has already been sent.';
        NoAccountErr: Label 'You must specify a valid email account to send the message to.';

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure CreateMessageTest()
    var
        Message: Codeunit "Email Message";
        Recipients: List of [Text];
        Result: List of [Text];
        Index: Integer;
    begin
        // Initialize
        PermissionsMock.Set('Email Edit');

        Recipients.Add('recipient1@test.com');
        Recipients.Add('recipient2@test.com');
        Recipients.Add('recipient3@test.com');

        // Exercise
        Message.Create(Recipients, 'Test subject', 'Test body', true);

        // Verify
        Assert.IsTrue(Message.Get(Message.GetId()), 'The meesage was not found');
        Assert.AreEqual('Test subject', Message.GetSubject(), 'A different subject was expected');
        Assert.AreEqual('Test body', Message.GetBody(), 'A different body was expected');
        Assert.IsTrue(Message.IsBodyHTMLFormatted(), 'Message body was expected to be HTML formated');

        Message.GetRecipients(Enum::"Email Recipient Type"::"To", Result);
        for Index := 1 to Result.Count() do
            Assert.AreEqual(StrSubstNo(RecipientLbl, Index), Result.Get(Index), 'A different recipient was expected');

        Message.GetRecipients(Enum::"Email Recipient Type"::Cc, Result);
        Assert.AreEqual(0, Result.Count(), 'No Cc Recipients were expected');

        Message.GetRecipients(Enum::"Email Recipient Type"::Bcc, Result);
        Assert.AreEqual(0, Result.Count(), 'No Bcc Recipients were expected');

        Assert.IsFalse(Message.Attachments_First(), 'No attachments were expected');
        Assert.IsTrue(Message.Attachments_Next() = 0, 'No attachments were expected');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure CreateMessageWithCCAndBCCTest()
    var
        Message: Codeunit "Email Message";
        Recipients: List of [Text];
        CcRecipients: List of [Text];
        BccRecipients: List of [Text];
        Result: List of [Text];
        Index: Integer;
    begin
        // Initialize
        PermissionsMock.Set('Email Edit');

        Recipients.Add('recipient1@test.com');
        Recipients.Add('recipient2@test.com');
        Recipients.Add('recipient3@test.com');

        CcRecipients.Add('recipient1@test.com');
        CcRecipients.Add('recipient2@test.com');
        CcRecipients.Add('recipient3@test.com');

        BccRecipients.Add('recipient1@test.com');
        BccRecipients.Add('recipient2@test.com');
        BccRecipients.Add('recipient3@test.com');

        // Exercise
        Message.Create(Recipients, 'Test subject', 'Test body', true, CcRecipients, BccRecipients);

        // Verify
        Assert.IsTrue(Message.Get(Message.GetId()), 'The meesage was not found');
        Assert.AreEqual('Test subject', Message.GetSubject(), 'A different subject was expected');
        Assert.AreEqual('Test body', Message.GetBody(), 'A different body was expected');
        Assert.IsTrue(Message.IsBodyHTMLFormatted(), 'Message body was expected to be HTML formated');

        Message.GetRecipients(Enum::"Email Recipient Type"::"To", Result);
        for Index := 1 to Result.Count() do
            Assert.AreEqual(StrSubstNo(RecipientLbl, Index), Result.Get(Index), 'A different recipient was expected');

        Message.GetRecipients(Enum::"Email Recipient Type"::Cc, Result);
        for Index := 1 to Result.Count() do
            Assert.AreEqual(StrSubstNo(RecipientLbl, Index), Result.Get(Index), 'A different recipient was expected');

        Message.GetRecipients(Enum::"Email Recipient Type"::Bcc, Result);
        for Index := 1 to Result.Count() do
            Assert.AreEqual(StrSubstNo(RecipientLbl, Index), Result.Get(Index), 'A different recipient was expected');

        Assert.IsFalse(Message.Attachments_First(), 'No attachments were expected');
        Assert.IsTrue(Message.Attachments_Next() = 0, 'No attachments were expected');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure CreateMessageWithRgbaColors()
    var
        Message: Codeunit "Email Message";
        Recipients: List of [Text];
        Expected: Text;
        Body: Text;
        ConvertedBody: Text;
    begin
        // Initialize
        PermissionsMock.Set('Email Edit');

        Recipients.Add('recipient@test.com');
        Body := '<div style="font-family: &quot;segoe ui&quot;, &quot;segoe wp&quot;, segoe, device-segoe, tahoma, helvetica, arial, sans-serif; font-size: 10.5pt; color: rgba(33, 33, 33, 1)"><span style="background-color: rgba(255, 0, 0, 1)">a</span> <span style="background-color: rgba(0, 255, 255, 1)">te</span><span style="color: rgba(220, 190, 34, 1); background-color: rgba(0, 255, 255, 1)">st</span> <span style="color: rgba(12, 100, 192, 1)">email</span></div>';
        Expected := '<div style="font-family: &quot;segoe ui&quot;, &quot;segoe wp&quot;, segoe, device-segoe, tahoma, helvetica, arial, sans-serif; font-size: 10.5pt; color: rgb(33, 33, 33)"><span style="background-color: rgb(255, 0, 0)">a</span> <span style="background-color: rgb(0, 255, 255)">te</span><span style="color: rgb(220, 190, 34); background-color: rgb(0, 255, 255)">st</span> <span style="color: rgb(12, 100, 192)">email</span></div>';

        // Exercise
        Message.Create(Recipients, 'Test subject', Body, true);

        // Verify
        ConvertedBody := Message.GetBody();
        Assert.AreEqual(Expected, ConvertedBody, 'The rgba colors in the body was not converted as expected.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure CreateMessageWithAttachmentsTest()
    var
        Message: Codeunit "Email Message";
        TempBLob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        Recipients: List of [Text];
        Result: Text;
        InStream: InStream;
        OutStream: OutStream;
    begin
        // Initialize
        PermissionsMock.Set('Email Edit');

        Recipients.Add('recipient@test.com');
        TempBLob.CreateOutStream(OutStream);
        OutStream.WriteText('Content');
        TempBLob.CreateInStream(InStream);

        // Exercise
        Message.Create(Recipients, 'Test subject', 'Test body', true);
        Message.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));
        Message.AddAttachment('Attachment1', 'text/plain', InStream);

        // Verify
        Assert.IsTrue(Message.Attachments_First(), 'First attachment was not found');
        Message.Attachments_GetContent(InStream);
        InStream.ReadText(Result);
        Assert.AreEqual('Attachment1', Message.Attachments_GetName(), 'A different attachment name was expected');
        Assert.AreEqual('Content', Result, 'A different attachment content was expected');
        Assert.AreEqual('Q29udGVudA==', Message.Attachments_GetContentBase64(), 'A different attachment content was expected');
        Assert.IsFalse(Message.Attachments_IsInline(), 'Attachment was not expected to be inline');
        Assert.AreEqual('text/plain', Message.Attachments_GetContentType(), 'A different attachment content type was expected');

        Assert.IsTrue(Message.Attachments_Next() <> 0, 'Second attachment was not found');
        Message.Attachments_GetContent(InStream);
        InStream.ReadText(Result);
        Assert.AreEqual('Attachment1', Message.Attachments_GetName(), 'A different attachment name was expected');
        Assert.AreEqual('Content', Result, 'A different attachment content was expected');
        Assert.AreEqual('Q29udGVudA==', Message.Attachments_GetContentBase64(), 'A different attachment content was expected');
        Assert.IsFalse(Message.Attachments_IsInline(), 'Attachment was not expected to be inline');
        Assert.AreEqual('text/plain', Message.Attachments_GetContentType(), 'A different attachment content type was expected');

        Assert.IsTrue(Message.Attachments_Next() = 0, 'A third attachment was found.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure CreateMessageWithAttachmentsWithFindNextTest()
    var
        Message: Codeunit "Email Message";
        TempBLob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        Recipients: List of [Text];
        Result: Text;
        InStream: InStream;
        OutStream: OutStream;
    begin
        // Initialize
        PermissionsMock.Set('Email Edit');

        Recipients.Add('recipient@test.com');
        TempBLob.CreateOutStream(OutStream);
        OutStream.WriteText('Content');
        TempBLob.CreateInStream(InStream);

        // Exercise
        Message.Create(Recipients, 'Test subject', 'Test body', true);
        Message.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));
        Message.AddAttachment('Attachment1', 'text/plain', InStream);

        // Verify
        Assert.IsTrue(Message.Attachments_Next() <> 0, 'First attachment was not found');
        Message.Attachments_GetContent(InStream);
        InStream.ReadText(Result);
        Assert.AreEqual('Attachment1', Message.Attachments_GetName(), 'A different attachment name was expected');
        Assert.AreEqual('Content', Result, 'A different attachment content was expected');
        Assert.AreEqual('Q29udGVudA==', Message.Attachments_GetContentBase64(), 'A different attachment content was expected');
        Assert.IsFalse(Message.Attachments_IsInline(), 'Attachment was not expected to be inline');
        Assert.AreEqual('text/plain', Message.Attachments_GetContentType(), 'A different attachment content type was expected');

        Assert.IsTrue(Message.Attachments_Next() <> 0, 'Second attachment was not found');
        Message.Attachments_GetContent(InStream);
        InStream.ReadText(Result);
        Assert.AreEqual('Attachment1', Message.Attachments_GetName(), 'A different attachment name was expected');
        Assert.AreEqual('Content', Result, 'A different attachment content was expected');
        Assert.AreEqual('Q29udGVudA==', Message.Attachments_GetContentBase64(), 'A different attachment content was expected');
        Assert.IsFalse(Message.Attachments_IsInline(), 'Attachment was not expected to be inline');
        Assert.AreEqual('text/plain', Message.Attachments_GetContentType(), 'A different attachment content type was expected');

        Assert.IsTrue(Message.Attachments_Next() = 0, 'A third attachment was found.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure AddAttachmentsOnQueuedMessageTest()
    var
        TempAccount: Record "Email Account" temporary;
        EmailOutBox: Record "Email Outbox";
        Message: Codeunit "Email Message";
        Base64Convert: Codeunit "Base64 Convert";
        ConnectorMock: Codeunit "Connector Mock";
        Recipients: List of [Text];
    begin
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        PermissionsMock.Set('Email Edit');

        Recipients.Add('recipient@test.com');
        Message.Create(Recipients, 'Test subject', 'Test body', true);

        EmailOutBox.Init();
        EmailOutBox."Account Id" := TempAccount."Account Id";
        EmailOutBox.Connector := Enum::"Email Connector"::"Test Email Connector";
        EmailOutBox."Message Id" := Message.GetId();
        EmailOutBox.Status := Enum::"Email Status"::Queued;
        EmailOutBox.Insert();

        // Exercise/Verify// Exercise/Verify
        asserterror Message.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));
        Assert.ExpectedError(EmailMessageQueuedCannotInsertAttachmentErr);
    end;

    [Test]
    procedure SendMessageBccOnly()
    var
        TempEmailAccount: Record "Email Account" temporary;
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        Recipients: List of [Text];
        RecipientsCC: List of [Text];
        RecipientsBCC: List of [Text];
    begin
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempEmailAccount);

        PermissionsMock.Set('Email Edit');

        // [GIVEN] The message only has recipients in BCC
        RecipientsBCC.Add('recipient@test.com');
        EmailMessage.Create(Recipients, 'Test subject', 'Test body', true, RecipientsCC, RecipientsBCC);

        // [WHEN] An email is sent
        // [THEN] No error occurs
        Email.Send(EmailMessage, TempEmailAccount."Account Id", TempEmailAccount.Connector);
    end;

    [Test]
    procedure SendMessageNoRecipientsError()
    var
        TempEmailAccount: Record "Email Account" temporary;
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        Recipients: List of [Text];
        RecipientsCC: List of [Text];
        RecipientsBCC: List of [Text];
    begin
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempEmailAccount);

        PermissionsMock.Set('Email Edit');

        // [GIVEN] The message doesn't have any recipients
        EmailMessage.Create(Recipients, 'Test subject', 'Test body', true, RecipientsCC, RecipientsBCC);

        // [WHEN] An email is sent
        // [THEN] A validation error occurs
        asserterror Email.Send(EmailMessage, TempEmailAccount."Account Id", TempEmailAccount.Connector);

        // [THEN] The validation error is as expected
        Assert.ExpectedError(NoAccountErr);
    end;

    [Test]
    procedure AddAttachmentsOnSentMessageTest()
    var
        TempAccount: Record "Email Account" temporary;
        EmailMessage: Codeunit "Email Message";
        Base64Convert: Codeunit "Base64 Convert";
        ConnectorMock: Codeunit "Connector Mock";
        Recipients: List of [Text];
    begin
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        PermissionsMock.Set('Email Edit');

        Recipients.Add('recipient@test.com');
        EmailMessage.Create(Recipients, 'Test subject', 'Test body', true);
        Email.Send(EmailMessage, TempAccount."Account Id", TempAccount.Connector);

        // Exercise/Verify
        asserterror EmailMessage.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));
        Assert.ExpectedError(EmailMessageSentCannotInsertAttachmentErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ModifyQueuedMessageTest()
    var
        TempAccount: Record "Email Account" temporary;
        EmailOutBox: Record "Email Outbox";
        EmailMessage: Record "Email Message";
        Message: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        Recipients: List of [Text];
    begin
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        PermissionsMock.Set('Email Edit');

        Recipients.Add('recipient@test.com');
        Message.Create(Recipients, 'Test subject', 'Test body', true);

        EmailOutBox.Init();
        EmailOutBox."Account Id" := TempAccount."Account Id";
        EmailOutBox.Connector := Enum::"Email Connector"::"Test Email Connector";
        EmailOutBox."Message Id" := Message.GetId();
        EmailOutBox.Status := Enum::"Email Status"::Queued;
        EmailOutBox.Insert();

        // Exercise/Verify// Exercise/Verify
        EmailMessage.Get(Message.GetId());
        EmailMessage.Subject := 'New Subject';
        asserterror EmailMessage.Modify();
        Assert.ExpectedError(EmailMessageQueuedCannotModifyErr);
    end;

    [Test]
    procedure ModifySentMessageTest()
    var
        TempAccount: Record "Email Account" temporary;
        EmailMessage: Record "Email Message";
        Message: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        Recipients: List of [Text];
    begin
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        PermissionsMock.Set('Email Edit');

        Recipients.Add('recipient@test.com');
        Message.Create(Recipients, 'Test subject', 'Test body', true);
        Email.Send(Message, TempAccount."Account Id", TempAccount.Connector);

        // Exercise/Verify
        EmailMessage.Get(Message.GetId());
        EmailMessage.Subject := 'New Subject';
        asserterror EmailMessage.Modify();
        Assert.ExpectedError(EmailMessageSentCannotModifyErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure AddRecipientsOnQueuedMessageTest()
    var
        TempAccount: Record "Email Account" temporary;
        EmailOutBox: Record "Email Outbox";
        EmailRecipient: Record "Email Recipient";
        Message: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        Recipients: List of [Text];
    begin
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        PermissionsMock.Set('Email Edit');

        Recipients.Add('recipient@test.com');
        Message.Create(Recipients, 'Test subject', 'Test body', true);

        EmailOutBox.Init();
        EmailOutBox."Account Id" := TempAccount."Account Id";
        EmailOutBox.Connector := Enum::"Email Connector"::"Test Email Connector";
        EmailOutBox."Message Id" := Message.GetId();
        EmailOutBox.Status := Enum::"Email Status"::Queued;
        EmailOutBox.Insert();

        // Exercise/Verify// Exercise/Verify
        EmailRecipient."Email Address" := 'anotherrecipient@test.com';
        EmailRecipient."Email Message Id" := Message.GetId();
        EmailRecipient."Email Recipient Type" := Enum::"Email Recipient Type"::Bcc;
        asserterror EmailRecipient.Insert();
        Assert.ExpectedError(EmailMessageQueuedCannotInsertRecipientErr);
    end;

    [Test]
    procedure AddRecipientsOnSentMessageTest()
    var
        TempAccount: Record "Email Account" temporary;
        EmailRecipient: Record "Email Recipient";
        EmailMessage: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        Recipients: List of [Text];
    begin
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        PermissionsMock.Set('Email Edit');

        Recipients.Add('recipient@test.com');
        EmailMessage.Create(Recipients, 'Test subject', 'Test body', true);
        Email.Send(EmailMessage, TempAccount."Account Id", TempAccount.Connector);

        // Exercise/Verify
        EmailRecipient."Email Address" := 'anotherrecipient@test.com';
        EmailRecipient."Email Message Id" := EmailMessage.GetId();
        EmailRecipient."Email Recipient Type" := Enum::"Email Recipient Type"::Bcc;
        asserterror EmailRecipient.Insert();
        Assert.ExpectedError(EmailMessageSentCannotInsertRecipientErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure DeleteRecipientsOnQueuedMessageTest()
    var
        TempAccount: Record "Email Account" temporary;
        EmailOutBox: Record "Email Outbox";
        EmailRecipient: Record "Email Recipient";
        Message: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        Recipients: List of [Text];
    begin
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        PermissionsMock.Set('Email Edit');

        Recipients.Add('recipient@test.com');
        Message.Create(Recipients, 'Test subject', 'Test body', true);

        EmailOutBox.Init();
        EmailOutBox."Account Id" := TempAccount."Account Id";
        EmailOutBox.Connector := Enum::"Email Connector"::"Test Email Connector";
        EmailOutBox."Message Id" := Message.GetId();
        EmailOutBox.Status := Enum::"Email Status"::Queued;
        EmailOutBox.Insert();

        // Exercise/Verify// Exercise/Verify
        EmailRecipient.SetRange("Email Message Id", Message.GetId());
        EmailRecipient.FindFirst();
        asserterror EmailRecipient.Delete();
        Assert.ExpectedError(EmailMessageQueuedCannotDeleteRecipientErr);
    end;

    [Test]
    procedure DeleteRecipientsOnSentMessageTest()
    var
        TempAccount: Record "Email Account" temporary;
        EmailRecipient: Record "Email Recipient";
        Email: Codeunit Email;
        Message: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
    begin
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        PermissionsMock.Set('Email Edit');

        Message.Create('recipient@test.com', 'Test subject', 'Test body', true);
        Email.Send(Message, TempAccount."Account Id", TempAccount.Connector);

        // Exercise/Verify
        EmailRecipient.SetRange("Email Message Id", Message.GetId());
        EmailRecipient.FindFirst();
        asserterror EmailRecipient.Delete();
        Assert.ExpectedError(EmailMessageSentCannotDeleteRecipientErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure SetBodyTest()
    var
        Message: Codeunit "Email Message";
        Recipients: List of [Text];
    begin
        // Initialize
        PermissionsMock.Set('Email Edit');
        Recipients.Add('recipient@test.com');


        // [GIVEN] We create a message and change its body        
        Message.Create(Recipients, 'Test subject', 'Test body', true);
        Message.SetBody('Changed test body');

        // [THEN] The GetBody returns the changed body and not the original
        Assert.AreEqual('Changed test body', Message.GetBody(), 'A different body was expected');
        Assert.AreEqual(true, Message.IsBodyHTMLFormatted(), 'The email body should be HTML formatted');
        Assert.AreEqual('Test subject', Message.GetSubject(), 'The email subject should not be changed');

        Message.GetRecipients(Enum::"Email Recipient Type"::"To", Recipients);

        Assert.AreEqual(1, Recipients.Count(), 'The number of recipients should not change');
        Assert.AreEqual('recipient@test.com', Recipients.Get(1), 'The number of recipients should not change');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure AppendToBodyTest()
    var
        Message: Codeunit "Email Message";
        Recipients: List of [Text];
    begin
        // Initialize
        PermissionsMock.Set('Email Edit');
        Recipients.Add('recipient@test.com');

        // [GIVEN] We create a message and append to its body
        Message.Create(Recipients, 'Test subject', 'Test body', true);
        Message.AppendToBody(' extended');

        // [THEN] The GetBody returns the body with the appended text
        Assert.AreEqual('Test body extended', Message.GetBody(), 'A different body was expected');
        Assert.AreEqual(true, Message.IsBodyHTMLFormatted(), 'The email body should be HTML formatted');
        Assert.AreEqual('Test subject', Message.GetSubject(), 'The email subject should not be changed');

        Message.GetRecipients(Enum::"Email Recipient Type"::"To", Recipients);

        Assert.AreEqual(1, Recipients.Count(), 'The number of recipients should not change');
        Assert.AreEqual('recipient@test.com', Recipients.Get(1), 'The number of recipients should not change');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure AppendToBodyEmptyTest()
    var
        Message: Codeunit "Email Message";
        Recipients: List of [Text];
    begin
        // Initialize
        PermissionsMock.Set('Email Edit');
        Recipients.Add('recipient@test.com');

        // [GIVEN] We create a message and append nothing to its body
        Message.Create(Recipients, 'Test subject', 'Test body', true);
        Message.AppendToBody('');

        // [THEN] The GetBody returns the original body
        Assert.AreEqual('Test body', Message.GetBody(), 'A different body was expected');
        Assert.AreEqual(true, Message.IsBodyHTMLFormatted(), 'The email body should be HTML formatted');
        Assert.AreEqual('Test subject', Message.GetSubject(), 'The email subject should not be changed');

        Message.GetRecipients(Enum::"Email Recipient Type"::"To", Recipients);

        Assert.AreEqual(1, Recipients.Count(), 'The number of recipients should not change');
        Assert.AreEqual('recipient@test.com', Recipients.Get(1), 'The number of recipients should not change');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure SetSubjectTest()
    var
        Message: Codeunit "Email Message";
        Recipients: List of [Text];
    begin
        // Initialize
        PermissionsMock.Set('Email Edit');
        Recipients.Add('recipient@test.com');

        // [GIVEN] We create a message and change the subject
        Message.Create(Recipients, 'Test subject', 'Test body', true);
        Message.SetSubject('Changed test subject');

        // [THEN] The GetSubject returns the changed subject
        Assert.AreEqual('Changed test subject', Message.GetSubject(), 'A different subject was expected');
        Assert.AreEqual('Test body', Message.GetBody(), 'A different body was expected');
        Assert.AreEqual(true, Message.IsBodyHTMLFormatted(), 'The email body should be HTML formatted');

        Message.GetRecipients(Enum::"Email Recipient Type"::"To", Recipients);

        Assert.AreEqual(1, Recipients.Count(), 'The number of recipients should not change');
        Assert.AreEqual('recipient@test.com', Recipients.Get(1), 'The number of recipients should not change');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure SetBodyHTMLFormattedTest()
    var
        Message: Codeunit "Email Message";
        Recipients: List of [Text];
    begin
        // Initialize
        PermissionsMock.Set('Email Edit');
        Recipients.Add('recipient@test.com');


        // [GIVEN] We create a message and set HTML format to false
        Message.Create(Recipients, 'Test subject', 'Test body', true);
        Message.SetBodyHTMLFormatted(false);

        // [THEN] The IsBodyHTMLFormatted returns false
        Assert.IsFalse(Message.IsBodyHTMLFormatted(), 'Body was expected not to be HTML formatted');
        Assert.AreEqual('Test subject', Message.GetSubject(), 'A different subject was expected');
        Assert.AreEqual('Test body', Message.GetBody(), 'A different subject was expected');

        Message.GetRecipients(Enum::"Email Recipient Type"::"To", Recipients);

        Assert.AreEqual(1, Recipients.Count(), 'The number of recipients should not change');
        Assert.AreEqual('recipient@test.com', Recipients.Get(1), 'The number of recipients should not change');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure SetToRecipientsTest()
    var
        EmailMessage: Codeunit "Email Message";
        ToRecipients, CcRecipients, BccRecipients : List of [Text];
        ToRecipientsResult, CcRecipientsResult, BccRecipientsResult : List of [Text];
        NewRecipients: List of [Text];
    begin
        // Initialize
        PermissionsMock.Set('Email Edit');

        ToRecipients.Add('toRecipient1@test.com');
        ToRecipients.Add('toRecipient2@test.com');
        ToRecipients.Add('toRecipient3@test.com');

        CcRecipients.Add('ccRecipient1@test.com');
        CcRecipients.Add('ccRecipient2@test.com');

        BccRecipients.Add('bccRecipient@test.com');

        // Exercise
        EmailMessage.Create(ToRecipients, 'Test subject', 'Test body', true, CcRecipients, BccRecipients);

        NewRecipients.Add('newRecipient1@test.com');
        NewRecipients.Add('newRecipient2@test.com');
        NewRecipients.Add('newRecipient3@test.com');

        EmailMessage.SetRecipients(Enum::"Email Recipient Type"::"To", NewRecipients);

        EmailMessage.GetRecipients(Enum::"Email Recipient Type"::"To", ToRecipientsResult);
        EmailMessage.GetRecipients(Enum::"Email Recipient Type"::"Cc", CcRecipientsResult);
        EmailMessage.GetRecipients(Enum::"Email Recipient Type"::"BCc", BccRecipientsResult);

        // Verify
        AssertExpectedRecipients(NewRecipients, ToRecipientsResult);
        AssertExpectedRecipients(CcRecipients, CcRecipientsResult);
        AssertExpectedRecipients(BccRecipients, BccRecipientsResult);

        Assert.AreEqual('Test subject', EmailMessage.GetSubject(), 'Wrong subject');
        Assert.AreEqual('Test body', EmailMessage.GetBody(), 'Wrong body');
        Assert.AreEqual(true, EmailMessage.IsBodyHTMLFormatted(), 'Body should be HMTL formatted');

    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure SetCCRecipientsTest()
    var
        EmailMessage: Codeunit "Email Message";
        ToRecipients, CcRecipients, BccRecipients : List of [Text];
        ToRecipientsResult, CcRecipientsResult, BccRecipientsResult : List of [Text];
        NewRecipients: List of [Text];
    begin
        // Initialize
        PermissionsMock.Set('Email Edit');

        ToRecipients.Add('toRecipient1@test.com');
        ToRecipients.Add('toRecipient2@test.com');
        ToRecipients.Add('toRecipient3@test.com');

        CcRecipients.Add('ccRecipient1@test.com');
        CcRecipients.Add('ccRecipient2@test.com');

        BccRecipients.Add('bccRecipient@test.com');

        // Exercise
        EmailMessage.Create(ToRecipients, 'Test subject', 'Test body', true, CcRecipients, BccRecipients);

        NewRecipients.Add('newRecipient1@test.com');
        NewRecipients.Add('newRecipient2@test.com');
        NewRecipients.Add('newRecipient3@test.com');

        EmailMessage.SetRecipients(Enum::"Email Recipient Type"::Cc, NewRecipients);

        EmailMessage.GetRecipients(Enum::"Email Recipient Type"::"To", ToRecipientsResult);
        EmailMessage.GetRecipients(Enum::"Email Recipient Type"::"Cc", CcRecipientsResult);
        EmailMessage.GetRecipients(Enum::"Email Recipient Type"::"BCc", BccRecipientsResult);

        // Verify
        AssertExpectedRecipients(ToRecipients, ToRecipientsResult);
        AssertExpectedRecipients(NewRecipients, CcRecipientsResult);
        AssertExpectedRecipients(BccRecipients, BccRecipientsResult);

        Assert.AreEqual('Test subject', EmailMessage.GetSubject(), 'Wrong subject');
        Assert.AreEqual('Test body', EmailMessage.GetBody(), 'Wrong body');
        Assert.AreEqual(true, EmailMessage.IsBodyHTMLFormatted(), 'Body should be HMTL formatted');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure SetBccRecipientsTest()
    var
        EmailMessage: Codeunit "Email Message";
        ToRecipients, CcRecipients, BccRecipients : List of [Text];
        ToRecipientsResult, CcRecipientsResult, BccRecipientsResult : List of [Text];
        NewRecipients: List of [Text];
    begin
        // Initialize
        PermissionsMock.Set('Email Edit');

        ToRecipients.Add('toRecipient1@test.com');
        ToRecipients.Add('toRecipient2@test.com');
        ToRecipients.Add('toRecipient3@test.com');

        CcRecipients.Add('ccRecipient1@test.com');
        CcRecipients.Add('ccRecipient2@test.com');

        BccRecipients.Add('bccRecipient@test.com');

        // Exercise
        EmailMessage.Create(ToRecipients, 'Test subject', 'Test body', true, CcRecipients, BccRecipients);

        NewRecipients.Add('newRecipient1@test.com');
        NewRecipients.Add('newRecipient2@test.com');
        NewRecipients.Add('newRecipient3@test.com');

        EmailMessage.SetRecipients(Enum::"Email Recipient Type"::Bcc, NewRecipients);

        EmailMessage.GetRecipients(Enum::"Email Recipient Type"::"To", ToRecipientsResult);
        EmailMessage.GetRecipients(Enum::"Email Recipient Type"::"Cc", CcRecipientsResult);
        EmailMessage.GetRecipients(Enum::"Email Recipient Type"::"BCc", BccRecipientsResult);

        // Verify 
        AssertExpectedRecipients(ToRecipients, ToRecipientsResult);
        AssertExpectedRecipients(CcRecipients, CcRecipientsResult);
        AssertExpectedRecipients(NewRecipients, BccRecipientsResult);

        Assert.AreEqual('Test subject', EmailMessage.GetSubject(), 'Wrong subject');
        Assert.AreEqual('Test body', EmailMessage.GetBody(), 'Wrong body');
        Assert.AreEqual(true, EmailMessage.IsBodyHTMLFormatted(), 'Body should be HMTL formatted');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure AddToRecipientTest()
    var
        EmailMessage: Codeunit "Email Message";
        ToRecipients, CcRecipients, BccRecipients : List of [Text];
        ToRecipientsResult, CcRecipientsResult, BccRecipientsResult : List of [Text];
        NewRecipient, Recipient : Text;
    begin
        // Initialize
        PermissionsMock.Set('Email Edit');

        ToRecipients.Add('toRecipient1@test.com');
        ToRecipients.Add('toRecipient2@test.com');
        ToRecipients.Add('toRecipient3@test.com');

        CcRecipients.Add('ccRecipient1@test.com');
        CcRecipients.Add('ccRecipient2@test.com');

        BccRecipients.Add('bccRecipient@test.com');

        // Exercise
        EmailMessage.Create(ToRecipients, 'Test subject', 'Test body', true, CcRecipients, BccRecipients);

        NewRecipient := 'newRecipient@test.com';

        EmailMessage.AddRecipient(Enum::"Email Recipient Type"::"To", NewRecipient);

        EmailMessage.GetRecipients(Enum::"Email Recipient Type"::"To", ToRecipientsResult);
        EmailMessage.GetRecipients(Enum::"Email Recipient Type"::"Cc", CcRecipientsResult);
        EmailMessage.GetRecipients(Enum::"Email Recipient Type"::"BCc", BccRecipientsResult);

        // Verify 
        Assert.AreEqual(ToRecipients.Count() + 1, ToRecipientsResult.Count(), 'Wrong number of recipients');
        foreach Recipient in ToRecipients do
            Assert.IsTrue(ToRecipientsResult.Contains(Recipient), 'Recipient missing: ' + Recipient);

        Assert.IsTrue(ToRecipientsResult.Contains(NewRecipient.ToLower()), 'Recipient missing: ' + NewRecipient);

        AssertExpectedRecipients(CcRecipients, CcRecipientsResult);
        AssertExpectedRecipients(BccRecipients, BccRecipientsResult);

        Assert.AreEqual('Test subject', EmailMessage.GetSubject(), 'Wrong subject');
        Assert.AreEqual('Test body', EmailMessage.GetBody(), 'Wrong body');
        Assert.AreEqual(true, EmailMessage.IsBodyHTMLFormatted(), 'Body should be HMTL formatted');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure AddCcRecipientTest()
    var
        EmailMessage: Codeunit "Email Message";
        ToRecipients, CcRecipients, BccRecipients : List of [Text];
        ToRecipientsResult, CcRecipientsResult, BccRecipientsResult : List of [Text];
        NewRecipient, Recipient : Text;
    begin
        // Initialize
        PermissionsMock.Set('Email Edit');

        ToRecipients.Add('toRecipient1@test.com');
        ToRecipients.Add('toRecipient2@test.com');
        ToRecipients.Add('toRecipient3@test.com');

        CcRecipients.Add('ccRecipient1@test.com');
        CcRecipients.Add('ccRecipient2@test.com');

        BccRecipients.Add('bccRecipient@test.com');

        // Exercise
        EmailMessage.Create(ToRecipients, 'Test subject', 'Test body', true, CcRecipients, BccRecipients);

        NewRecipient := 'newRecipient@test.com';

        EmailMessage.AddRecipient(Enum::"Email Recipient Type"::Cc, NewRecipient);

        EmailMessage.GetRecipients(Enum::"Email Recipient Type"::"To", ToRecipientsResult);
        EmailMessage.GetRecipients(Enum::"Email Recipient Type"::"Cc", CcRecipientsResult);
        EmailMessage.GetRecipients(Enum::"Email Recipient Type"::"BCc", BccRecipientsResult);

        // Verify 
        AssertExpectedRecipients(ToRecipients, ToRecipientsResult);

        Assert.AreEqual(CcRecipients.Count() + 1, CcRecipientsResult.Count(), 'Wrong number of recipients');
        foreach Recipient in CcRecipients do
            Assert.IsTrue(CcRecipientsResult.Contains(Recipient), 'Recipient missing: ' + Recipient);

        Assert.IsTrue(CcRecipientsResult.Contains(NewRecipient.ToLower()), 'Recipient missing: ' + NewRecipient);

        AssertExpectedRecipients(BccRecipientsResult, BccRecipientsResult);

        Assert.AreEqual('Test subject', EmailMessage.GetSubject(), 'Wrong subject');
        Assert.AreEqual('Test body', EmailMessage.GetBody(), 'Wrong body');
        Assert.AreEqual(true, EmailMessage.IsBodyHTMLFormatted(), 'Body should be HMTL formatted');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure AddBccRecipientTest()
    var
        EmailMessage: Codeunit "Email Message";
        ToRecipients, CcRecipients, BccRecipients : List of [Text];
        ToRecipientsResult, CcRecipientsResult, BccRecipientsResult : List of [Text];
        NewRecipient, Recipient : Text;
    begin
        // Initialize
        PermissionsMock.Set('Email Edit');

        ToRecipients.Add('toRecipient1@test.com');
        ToRecipients.Add('toRecipient2@test.com');
        ToRecipients.Add('toRecipient3@test.com');

        CcRecipients.Add('ccRecipient1@test.com');
        CcRecipients.Add('ccRecipient2@test.com');

        BccRecipients.Add('bccRecipient@test.com');

        // Exercise
        EmailMessage.Create(ToRecipients, 'Test subject', 'Test body', true, CcRecipients, BccRecipients);

        NewRecipient := 'newRecipient@test.com';

        EmailMessage.AddRecipient(Enum::"Email Recipient Type"::Bcc, NewRecipient);

        EmailMessage.GetRecipients(Enum::"Email Recipient Type"::"To", ToRecipientsResult);
        EmailMessage.GetRecipients(Enum::"Email Recipient Type"::"Cc", CcRecipientsResult);
        EmailMessage.GetRecipients(Enum::"Email Recipient Type"::"BCc", BccRecipientsResult);

        // Verify 
        AssertExpectedRecipients(ToRecipients, ToRecipientsResult);
        AssertExpectedRecipients(CcRecipients, CcRecipientsResult);

        Assert.AreEqual(BccRecipients.Count() + 1, BccRecipientsResult.Count(), 'Wrong number of recipients');
        foreach Recipient in BccRecipients do
            Assert.IsTrue(BccRecipientsResult.Contains(Recipient), 'Recipient missing: ' + Recipient);

        Assert.IsTrue(BccRecipientsResult.Contains(NewRecipient.ToLower()), 'Recipient missing: ' + NewRecipient);

        Assert.AreEqual('Test subject', EmailMessage.GetSubject(), 'Wrong subject');
        Assert.AreEqual('Test body', EmailMessage.GetBody(), 'Wrong body');
        Assert.AreEqual(true, EmailMessage.IsBodyHTMLFormatted(), 'Body should be HMTL formatted');
    end;

    [StrMenuHandler]
    [Scope('OnPrem')]
    procedure CloseEmailEditorHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Choice := 1;
    end;

    local procedure AssertExpectedRecipients(ExpectedRecipients: List of [Text]; ActualRecipient: List of [Text])
    var
        Recipient: Text;
    begin
        Assert.AreEqual(ExpectedRecipients.Count(), ActualRecipient.Count(), 'Wrong number of recipients');

        foreach Recipient in ExpectedRecipients do
            Assert.IsTrue(ActualRecipient.Contains(Recipient), 'Recipient missing: ' + Recipient);
    end;
}
