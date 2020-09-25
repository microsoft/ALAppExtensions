codeunit 134689 "Email Message Unit Test"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";
#pragma warning disable AA0240
#pragma warning disable AA0470
        RecipientLbl: Label 'recipient%1@test.com',;
        AccountNameLbl: Label '%1 (%2)';
#pragma warning restore AA0240
#pragma warning restore AA0470
        EmailMessageQueuedCannotModifyErr: Label 'Cannot edit the email because it has been queued to be sent.';
        EmailMessageSentCannotModifyErr: Label 'Cannot edit the message because it has already been sent.';
        EmailMessageQueuedCannotDeleteAttachmentErr: Label 'Cannot delete the attachment because the email has been queued to be sent.';
        EmailMessageSentCannotDeleteAttachmentErr: Label 'Cannot delete the attachment because the email has already been sent.';
        EmailMessageQueuedCannotInsertAttachmentErr: Label 'Cannot add the attachment because the email is queued to be sent.';
        EmailMessageSentCannotInsertAttachmentErr: Label 'Cannot add the attachment because the email has already been sent.';
        EmailMessageQueuedCannotDeleteRecipientErr: Label 'Cannot delete the recipient because the email is queued to be sent.';
        EmailMessageSentCannotDeleteRecipientErr: Label 'Cannot delete the recipient because the email has already been sent.';
        EmailMessageQueuedCannotInsertRecipientErr: Label 'Cannot add a recipient because the email is queued to be sent.';
        EmailMessageSentCannotInsertRecipientErr: Label 'Cannot add the recipient because the email has already been sent.';
        EmailMessageOpenPermissionErr: Label 'You can only open your own email messages.';

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
        Recipients.Add('recipient1@test.com');
        Recipients.Add('recipient2@test.com');
        Recipients.Add('recipient3@test.com');

        // Exercise
        Message.CreateMessage(Recipients, 'Test subject', 'Test body', true);

        // Verify
        Assert.IsTrue(Message.Find(Message.GetId()), 'The meesage was not found');
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
        Message.CreateMessage(Recipients, 'Test subject', 'Test body', true, CcRecipients, BccRecipients);

        // Verify
        Assert.IsTrue(Message.Find(Message.GetId()), 'The meesage was not found');
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
        Recipients.Add('recipient@test.com');
        TempBLob.CreateOutStream(OutStream);
        OutStream.WriteText('Content');
        TempBLob.CreateInStream(InStream);

        // Exercise
        Message.CreateMessage(Recipients, 'Test subject', 'Test body', true);
        Message.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));
        Message.AddAttachment('Attachment1', 'text/plain', InStream);

        // Verify
        Assert.IsTrue(Message.Attachments_First(), 'First attachment was not found');
        Message.Attachments_GetContent(InStream);
        InStream.ReadText(Result);
        Assert.AreEqual('Attachment1', Message.Attachments_GetName(), 'A different attachement name was expected');
        Assert.AreEqual('Content', Result, 'A different attachment content was expected');
        Assert.AreEqual('Q29udGVudA==', Message.Attachments_GetContentBase64(), 'A different attachment content was expected');
        Assert.IsFalse(Message.Attachments_IsInline(), 'Attachment was not expected to be inline');
        Assert.AreEqual('text/plain', Message.Attachments_GetContentType(), 'A different attachment content type was expected');

        Assert.IsTrue(Message.Attachments_Next() <> 0, 'Second attachment was not found');
        Message.Attachments_GetContent(InStream);
        InStream.ReadText(Result);
        Assert.AreEqual('Attachment1', Message.Attachments_GetName(), 'A different attachement name was expected');
        Assert.AreEqual('Content', Result, 'A different attachment content was expected');
        Assert.AreEqual('Q29udGVudA==', Message.Attachments_GetContentBase64(), 'A different attachment content was expected');
        Assert.IsFalse(Message.Attachments_IsInline(), 'Attachment was not expected to be inline');
        Assert.AreEqual('text/plain', Message.Attachments_GetContentType(), 'A different attachment content type was expected');

        Assert.IsTrue(Message.Attachments_Next() = 0, 'A third attachment was found.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure CreateMessageWithInLineAttachmetnsTest()
    var
        Message: Codeunit "Email Message";
        Base64Convert: Codeunit "Base64 Convert";
        Recipients: List of [Text];
        InStream: InStream;
        Result: Text;
        Expected: Text;
        Body: Text;
        ConvertedBody: Text;
    begin
        // Initialize
        Recipients.Add('recipient@test.com');
        Body := '<html><body><img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAAIpElEQVR4Xu2df6hlVRXH17pn73vfjGb0Q40RLDNJMUkJC4WU0hBFR7RpSEXFTDF/j6aWo06JPwccRaUoSTHJxEzxRwlpSQWGSmSoiKhpgaL9ULJ05r29z12y3qwrF3lP77nv3L3Xe3udv+YMe++11nd9zjr77L3vDIJdRSuARUdvwYMBUDgEBoABULgChYdvFcAAKFyBwsO3CmAAFK5A4eFbBTAACleg8PCtAhgAhStQePhWAQyAwhUoPHyrAAZA4QoUHr5VAAOgcAUKD98qgAFQuAKFh28VwAAoXIHCw7cKYAAUrkDh4VsFMAAKV6Dw8K0CGACFK1B4+FYBDIDmCnjvqXkv6zEJBYg2pwJx87McQmj0UDdqLAEs996/OYlgbMxmCgwnn//MEKQAAOaoAH8CgDUhhEeahWCtGygw/LB2nHOXAcA5iIj9fv8GRDwhOQBEdAAiXgMAu3AgRLQ2xsiO2dWuApz8wWt3W+fcnYi4NxFtJKJv1nV9m/e+TvUKeKcCSLmpvPdXA8BpEvNDUg3+2q4GNppzbi8AuBsRtwaAZ0MIKwHgGVbGe9/PBcBsZnq93sp+v88gfFKqwdkxxg2WtnYUcM59BwAuQcSKiO6IMR4LAG8NRh+8lpPOAeYwtoVUgxNkZno/Iq6Znp6epdSusRTYyjl3GyIeSEQziPjtEMJ17x5JCwCzfnW73dVcDRBxBQDMyCvhB2OFX3an3b33dwPA9kT0EiIeFkJ4bC5JVAEgDn5EqsHR8kq4yzm3ZtOmTX8vO6ejRe+9P4mIrkHEHhE9GGNcDQCvz9dbIwCzvnrvjwEAnht8GADekGpw42gyFNlqyjl3CyKuIiKe2H0vxnjJ0FfAnKKoBYC9XbZs2XYxRobga+L9z0MIawDg1SJTPH/Qn/Le38Of1UT0LwBYFWP8wygaqQZgaKZ6olSD5QDwT54gzszM3DpKgEu9TVVVX0XEmxFxCyJ6NMbIn3gjPyCLAgBOYq/X27Gua54gHiJJvUmqwX+XepLnia9bVdWGTqdzisyVNsQYzwOA2ESPRQPAUDU4XapBBwD+IdXgziZBL4G2K7z39wHAHkT0PyI6qq7re8eJa9EBIJ+LuxIRzw2+IkH/UKrB9DgiLKY+zrn9AOB2ROTJ8ROyqvfiuDEsSgAGwTrnzkXEK+X+2X6/f2Zd178eVwzl/Xgj5/sAsJY3cgDg1hDCcbJeMrbrixoA+Vz8nLwSvigqXB1COGtsRXR2/Khz7g5E3Fc2ck6t67qVT+JFD8BQNbgIEfkJ4esJIjozxvg7nfkc3SvZyOFdvI8BwAtS8p8cfYT3brlkAOAwnXN7yzbznnyPiJfPzMyc35ZYqcdxzp0NAFcgoiOie2KMRwHA/9v0Y0kBMBCm2+1eRkTflfvHpBo83KZwEx5rS+fczxBxJRHxZ915k9ohXZIASDX4slSD3fieiNbFGC+ecOLaGP4zsqq3AxG9whDMt5HThrElC8BAHO89ny3g5WO+/ih7Cn9uQ7y2x6iq6nhEvB4Rp4jo9zHGVQDw77btDI+35AHgYKuqOqjT6fARtJ2kGnBJXT9JYRuO3fXe3wQAR9LmE5uXxhjXAcDsaZ1JXkUAIAL2ZJv5W3L/gKwiPjVJgUcY+xNS8ncjotcAYHWM8bcj9GulSUkAzArW7XYPl1XE7eUJ41PJ17aiZsNBqqo6BBF5svcBAPhLCOFgAHi54TALal4cAKLWB6Ua8EoaTxDvraqKj6A9vyA1R+/snHPruQJxl36/f31d1/zJx6egkl6lAjCoBvzO5T2FbeSgJFeDH084Ayucc3ch4ueJ6E0iOrau619O2Oa8wxcNgKiyrVSDI+T+F3wEbePGjS+1nRTn3D4AwMnnjZynZVXvubbtNBnPABC1vPffkD2FrQCAJ2NcDX7aRMz3aIvOuQsBYB0i8jY2b+QcDwCbWhp/7GEMgCHppqamPs5H0PgUrfz1LbLN/J+xFQb4kHOOt2/3J6JpRDwjhPCjBYzXalcDYA45vfcnSzXoEtHLnU6Hj6Dd3lR57/2eRMQlfzs+vBJCOBQAHm86ziTbGwDzqNvr9T7NE0QiOlCa3CDVYKRfOHvvTyOiqxDRE9H9Mcavy+nmSeaz8dgGwPtI5pw7CxGvkmZ/42owPT3NJ3Dnu5Y75/iQJh/P5h9eXhBjvKJxZhJ1MABGENp7/1l5JXxJml8n1WD2l7VD186yqreTHM8+NMbIP4FXexkADVLjnDsfES+VLk/LNvNv+L6qqiMQ8SeIuIyIHo4xHt7keHYDN1ptagA0lNN7/wWpBvyTa15F3ICIWwLAibKRsz7GuBYA3l0dGlpK09wAGFPnbrd7MRFdOPgnVojoDSI6sq7rX405ZJZuBsACZOeVPTl08mQIgbdvX1jAcFm6GgBZZNdj1ADQk4ssnhgAWWTXY9QA0JOLLJ4YAFlk12PUANCTiyyeGABZZNdj1ADQk4ssnhgAWWTXY9QA0JOLLJ4YAFlk12PUANCTiyyeGABZZNdj1ADQk4ssnhgAWWTXY9QA0JOLLJ4YAFlk12PUANCTiyyeGABZZNdj1ADQk4ssnhgAWWTXY9QA0JOLLJ4YAFlk12PUANCTiyyeGABZZNdj1ADQk4ssnhgAWWTXY9QA0JOLLJ4YAFlk12PUANCTiyyeGABZZNdj1ADQk4ssnhgAWWTXY9QA0JOLLJ4YAFlk12M0CwB6wjdPBgqEEPh/Ix35atR4MOqAtpGtWMNkCiQBIFk0ZmjiCoxVASbulRlIpoABkExqnYYMAJ15SeaVAZBMap2GDACdeUnmlQGQTGqdhgwAnXlJ5pUBkExqnYYMAJ15SeaVAZBMap2GDACdeUnmlQGQTGqdhgwAnXlJ5pUBkExqnYYMAJ15SeaVAZBMap2GDACdeUnmlQGQTGqdhgwAnXlJ5pUBkExqnYYMAJ15SeaVAZBMap2G3gZ7j5m9OcaZOgAAAABJRU5ErkJggg=="/><img src="data:image/png;base64,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"/></body></html>';
        Expected := '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';

        // Exercise
        Message.CreateMessage(Recipients, 'Test subject', Body, true);

        // Verify
        ConvertedBody := Message.GetBody();
        Assert.IsTrue(Message.Attachments_First(), 'First attachment was not found');
        Message.Attachments_GetContent(InStream);
        Result := Base64Convert.ToBase64(InStream);
        Assert.AreEqual(Expected, Result, 'A different attachment content was expected');
        Assert.AreEqual(Result, Message.Attachments_GetContentBase64(), 'A different attachment content was expected');
        Assert.IsTrue(Message.Attachments_IsInline(), 'Attachment was expected to be inline');
        Assert.AreEqual('image/png', Message.Attachments_GetContentType(), 'A different attachment content type was expected');
        Assert.IsTrue(ConvertedBody.Contains(Message.Attachments_GetContentId()), 'Attachment content id was not found in the converted body');

        Assert.IsTrue(Message.Attachments_Next() <> 0, 'Second attachment was not found');
        Message.Attachments_GetContent(InStream);
        Result := Base64Convert.ToBase64(InStream);
        Assert.AreEqual(Expected, Result, 'A different attachment content was expected');
        Assert.AreEqual(Expected, Message.Attachments_GetContentBase64(), 'A different attachment content was expected');
        Assert.IsTrue(Message.Attachments_IsInline(), 'Attachment was expected to be inline');
        Assert.AreEqual('image/png', Message.Attachments_GetContentType(), 'A different attachment content type was expected');
        Assert.IsTrue(ConvertedBody.Contains(Message.Attachments_GetContentId()), 'Attachment content id was not found in the converted body');

        Assert.IsTrue(Message.Attachments_Next() = 0, 'A third attachment was found.');
    end;

    [Test]
    [HandlerFunctions('CloseEmailEditorHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OpenMessageInEditorTest()
    var
        TempAccount: Record "Email Account" temporary;
        Message: Codeunit "Email Message";
        Base64Convert: Codeunit "Base64 Convert";
        ConnectorMock: Codeunit "Connector Mock";
        EmailEditor: TestPage "Email Editor";
        Recipients: List of [Text];
    begin
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);
        Recipients.Add('recipient1@test.com');
        Recipients.Add('recipient2@test.com');
        Message.CreateMessage(Recipients, 'Test subject', 'Test body', true);
        Message.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));
        Message.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));

        // Exercise
        EmailEditor.Trap();
        Message.OpenInEditor();

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
        Message.OpenInEditor(TempAccount."Account Id");

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
        Message.OpenInEditor(TempAccount."Account Id");

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
        Message: Codeunit "Email Message";
        Base64Convert: Codeunit "Base64 Convert";
        ConnectorMock: Codeunit "Connector Mock";
        EmailEditor: TestPage "Email Editor";
        Recipients: List of [Text];
    begin
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);
        Recipients.Add('recipient@test.com');
        Message.CreateMessage(Recipients, 'Test subject', 'Test body', true);
        Message.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));
        Message.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));

        EmailOutBox.Init();
        EmailOutBox."Account Id" := TempAccount."Account Id";
        EmailOutBox.Connector := Enum::"Email Connector"::"Test Email Connector";
        EmailOutBox."Message Id" := Message.GetId();
        EmailOutBox.Status := Enum::"Email Status"::Queued;
        EmailOutBox."User Security Id" := UserSecurityId();
        EmailOutBox.Insert();

        // Exercise
        EmailEditor.Trap();
        Message.OpenInEditor();

        // Verify
        Assert.IsFalse(EmailEditor.Account.Editable(), 'Account field was editable');
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
        Message.OpenInEditor();

        // Verify
        Assert.IsFalse(EmailEditor.Account.Editable(), 'Account field was editable');
        Assert.IsFalse(EmailEditor.ToField.Editable(), 'To field was editable');
        Assert.IsFalse(EmailEditor.CcField.Editable(), 'Cc field was editable');
        Assert.IsFalse(EmailEditor.BccField.Editable(), 'Bcc field was editable');
        Assert.IsFalse(EmailEditor.SubjectField.Editable(), 'Subject field was editable');
        Assert.IsFalse(EmailEditor.BodyField.Editable(), 'Body field was editable');
        Assert.IsFalse(EmailEditor.Upload.Enabled(), 'Upload Action was not disabled.');
        Assert.IsFalse(EmailEditor.Send.Enabled(), 'Send Action was not disabled.');
        EmailAttachment.SetRange("Email Message Id", Message.GetId());
        EmailAttachment.FindFirst();
        asserterror EmailAttachment.Delete();
        Assert.ExpectedError(EmailMessageQueuedCannotDeleteAttachmentErr);
    end;

    [Test]
    procedure OpenMessageInEditorForASentMessageTest()
    var
        TempAccount: Record "Email Account" temporary;
        EmailAttachment: Record "Email Message Attachment";
        Email: Codeunit Email;
        Message: Codeunit "Email Message";
        Base64Convert: Codeunit "Base64 Convert";
        ConnectorMock: Codeunit "Connector Mock";
        EmailEditor: TestPage "Email Editor";
        Recipients: List of [Text];
    begin
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);
        Recipients.Add('recipient@test.com');
        Message.CreateMessage(Recipients, 'Test subject', 'Test body', true);
        Message.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));
        Message.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));
        Email.Send(Message.GetId(), TempAccount."Account Id", TempAccount.Connector);

        // Exercise
        EmailEditor.Trap();
        Message.OpenInEditor();

        // Verify
        Assert.IsFalse(EmailEditor.Account.Editable(), 'Account field was editable');
        Assert.IsFalse(EmailEditor.ToField.Editable(), 'To field was editable');
        Assert.IsFalse(EmailEditor.CcField.Editable(), 'Cc field was editable');
        Assert.IsFalse(EmailEditor.BccField.Editable(), 'Bcc field was editable');
        Assert.IsFalse(EmailEditor.SubjectField.Editable(), 'Subject field was editable');
        Assert.IsFalse(EmailEditor.BodyField.Editable(), 'Body field was editable');
        Assert.IsFalse(EmailEditor.Upload.Enabled(), 'Upload Action was not disabled.');
        Assert.IsFalse(EmailEditor.Send.Enabled(), 'Send Action was not disabled.');
        EmailAttachment.SetRange("Email Message Id", Message.GetId());
        EmailAttachment.FindFirst();
        asserterror EmailAttachment.Delete();
        Assert.ExpectedError(EmailMessageSentCannotDeleteAttachmentErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OpenMessageInEditorForAQueuedMessageOwnedByAnotherUserTest()
    var
        TempAccount: Record "Email Account" temporary;
        EmailOutBox: Record "Email Outbox";
        Message: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        EmailEditor: TestPage "Email Editor";
        Recipients: List of [Text];
    begin
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);
        Recipients.Add('recipient1@test.com');
        Recipients.Add('recipient2@test.com');
        Message.CreateMessage(Recipients, 'Test subject', 'Test body', true);

        EmailOutBox.Init();
        EmailOutBox."Account Id" := TempAccount."Account Id";
        EmailOutBox.Connector := Enum::"Email Connector"::"Test Email Connector";
        EmailOutBox."Message Id" := Message.GetId();
        EmailOutBox.Status := Enum::"Email Status"::Queued;
        EmailOutbox."User Security Id" := 'd0a983f4-0fc8-4982-8e02-ee9294ab28da'; // Created by another user
        EmailOutBox.Insert();

        // Exercise/Verify
        EmailEditor.Trap();
        asserterror Message.OpenInEditor();
        Assert.ExpectedError(EmailMessageOpenPermissionErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OpenMessageInEditorForASentMessageOwnedByAnotherUserTest()
    var
        TempAccount: Record "Email Account" temporary;
        SentEmail: Record "Sent Email";
        Message: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        EmailEditor: TestPage "Email Editor";
        Recipients: List of [Text];
    begin
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);
        Recipients.Add('recipient1@test.com');
        Recipients.Add('recipient2@test.com');
        Message.CreateMessage(Recipients, 'Test subject', 'Test body', true);

        SentEmail.Init();
        SentEmail."Account Id" := TempAccount."Account Id";
        SentEmail.Connector := Enum::"Email Connector"::"Test Email Connector";
        SentEmail."Message Id" := Message.GetId();
        SentEmail."User Security Id" := 'd0a983f4-0fc8-4982-8e02-ee9294ab28da'; // Created by another user
        SentEmail.Insert();

        // Exercise/Verify
        EmailEditor.Trap();
        asserterror Message.OpenInEditor();
        Assert.ExpectedError(EmailMessageOpenPermissionErr);
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
        Recipients.Add('recipient@test.com');
        Message.CreateMessage(Recipients, 'Test subject', 'Test body', true);

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
    procedure AddAttachmentsOnSentMessageTest()
    var
        TempAccount: Record "Email Account" temporary;
        Email: Codeunit Email;
        Message: Codeunit "Email Message";
        Base64Convert: Codeunit "Base64 Convert";
        ConnectorMock: Codeunit "Connector Mock";
        Recipients: List of [Text];
    begin
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);
        Recipients.Add('recipient@test.com');
        Message.CreateMessage(Recipients, 'Test subject', 'Test body', true);
        Email.Send(Message.GetId(), TempAccount."Account Id", TempAccount.Connector);

        // Exercise/Verify
        asserterror Message.AddAttachment('Attachment1', 'text/plain', Base64Convert.ToBase64('Content'));
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
        Recipients.Add('recipient@test.com');
        Message.CreateMessage(Recipients, 'Test subject', 'Test body', true);

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
        Email: Codeunit Email;
        Message: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        Recipients: List of [Text];
    begin
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);
        Recipients.Add('recipient@test.com');
        Message.CreateMessage(Recipients, 'Test subject', 'Test body', true);
        Email.Send(Message.GetId(), TempAccount."Account Id", TempAccount.Connector);

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
        Recipients.Add('recipient@test.com');
        Message.CreateMessage(Recipients, 'Test subject', 'Test body', true);

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
        Email: Codeunit Email;
        Message: Codeunit "Email Message";
        ConnectorMock: Codeunit "Connector Mock";
        Recipients: List of [Text];
    begin
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);
        Recipients.Add('recipient@test.com');
        Message.CreateMessage(Recipients, 'Test subject', 'Test body', true);
        Email.Send(Message.GetId(), TempAccount."Account Id", TempAccount.Connector);

        // Exercise/Verify
        EmailRecipient."Email Address" := 'anotherrecipient@test.com';
        EmailRecipient."Email Message Id" := Message.GetId();
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
        Recipients.Add('recipient@test.com');
        Message.CreateMessage(Recipients, 'Test subject', 'Test body', true);

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
        Recipients: List of [Text];
    begin
        // Initialize
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);
        Recipients.Add('recipient@test.com');
        Message.CreateMessage(Recipients, 'Test subject', 'Test body', true);
        Email.Send(Message.GetId(), TempAccount."Account Id", TempAccount.Connector);

        // Exercise/Verify
        EmailRecipient.SetRange("Email Message Id", Message.GetId());
        EmailRecipient.FindFirst();
        asserterror EmailRecipient.Delete();
        Assert.ExpectedError(EmailMessageSentCannotDeleteRecipientErr);
    end;

    [StrMenuHandler]
    [Scope('OnPrem')]
    procedure CloseEmailEditorHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Choice := 2;
    end;
}
