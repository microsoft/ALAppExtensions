// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 134696 "Email Editor Validation Tests"
{
    SubType = Test;
    Permissions = tabledata "Email Outbox" = rd,
                  tabledata "Email View Policy" = rid,
                  tabledata "Sent Email" = rd;
    EventSubscriberInstance = Manual;

    var
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        Any: Codeunit Any;
        InvalidEmailAddressErr: Label 'The email address "%1" is not valid.', Locked = true;
        EmailToRecipientsLbl: Label '%1; %2', Locked = true;

    [Test]
    [HandlerFunctions('DiscardEmailEditorHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure SendNewMessageThroughEditorFailsNoFromAccount()
    var
        SentEmail: Record "Sent Email";
        Outbox: Record "Email Outbox";
        EmailEditor: Page "Email Editor";
        Editor: TestPage "Email Editor";
    begin
        // [SCENARIO] A new email message cannot be sent out if there is no "from" account set.
        PermissionsMock.Set('Email Admin');
        GiveUserViewAllPolicy();

        // [GIVEN] There are no outbox or sent email entries
        Outbox.DeleteAll();
        SentEmail.DeleteAll();

        // [GIVEN] The Email Editor pages opens up and no details are filled
        Editor.Trap();
        EmailEditor.Run();

        // [WHEN] The send action is invoked, an error appears
        asserterror Editor.Send.Invoke();

        // [THEN] The error is as expected
        Assert.ExpectedError('You must specify a valid email account to send the message to.');
        Editor.Close();

        // [THEN] No outbox or sent emails entries have been created
        Assert.AreEqual(0, Outbox.Count(), 'No records in Email Outbox were expected');
        Assert.AreEqual(0, SentEmail.Count(), 'No records in Sent Email were expected');
    end;

    [Test]
    [HandlerFunctions('EmailAccountLookUpHandler,DiscardEmailEditorHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure SendNewMessageThroughEditorFailsNoToRecipient()
    var
        EmailAccount: Record "Email Account";
        SentEmail: Record "Sent Email";
        Outbox: Record "Email Outbox";
        ConnectorMock: Codeunit "Connector Mock";
        EmailEditor: Page "Email Editor";
        Editor: TestPage "Email Editor";
    begin
        // [SCENARIO] A new email message cannot be sent out if there is no at least one TO recipient.

        // [GIVEN] A connector is installed and an account is added
        Outbox.DeleteAll();
        SentEmail.DeleteAll();
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(EmailAccount);

        PermissionsMock.Set('Email Admin');
        GiveUserViewAllPolicy();

        // [GIVEN] The Email Editor pages opens up and no details are filled
        Editor.Trap();
        EmailEditor.Run();

        Editor.Account.AssistEdit();

        // [WHEN] The send action is invoked, an error appears
        asserterror Editor.Send.Invoke();

        // [THEN] The error is as expected
        Assert.ExpectedError('You must specify a valid email account to send the message to.');
        Editor.Close();

        // [THEN] No outbox and sent emails entries are created.
        Assert.AreEqual(0, Outbox.Count(), 'No records in Email Outbox were expected');
        Assert.AreEqual(0, SentEmail.Count(), 'No records in Sent Email were expected');
    end;

    [Test]
    [HandlerFunctions('EmailAccountLookUpHandler,DiscardEmailEditorHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure SendNewMessageThroughEditorFailsInvalidRecipients()
    var
        EmailAccount: Record "Email Account";
        SentEmail: Record "Sent Email";
        Outbox: Record "Email Outbox";
        ConnectorMock: Codeunit "Connector Mock";
        EmailEditor: Page "Email Editor";
        Editor: TestPage "Email Editor";
        InvalidEmailAddress: Text;
        ValidEmailAddress: Text;
    begin
        // [SCENARIO] A new email message cannot be sent out if the TO recipient is invalid.

        // [GIVEN] A connector is installed and an account is added
        Outbox.DeleteAll();
        SentEmail.DeleteAll();
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(EmailAccount);
        ValidEmailAddress := Any.Email();
        InvalidEmailAddress := 'invalid email address';

        PermissionsMock.Set('Email Admin');
        GiveUserViewAllPolicy();

        // [GIVEN] The Email Editor pages opens up and no details are filled
        Editor.Trap();
        EmailEditor.Run();

        Editor.Account.AssistEdit();
        Editor.ToField.SetValue(InvalidEmailAddress);

        // [WHEN] The send action is invoked, an error appears
        asserterror Editor.Send.Invoke();

        // [THEN] The error is as expected
        Assert.ExpectedError(StrSubstNo(InvalidEmailAddressErr, InvalidEmailAddress));

        // [THEN] No outbox and sent emails entries are created.
        Assert.TableIsEmpty(Database::"Email Outbox");
        Assert.TableIsEmpty(Database::"Sent Email");

        // [WHEN] Set a valid and an invalid email address for To recipients
        Editor.ToField.SetValue(StrSubstNo(EmailToRecipientsLbl, ValidEmailAddress, InvalidEmailAddress));

        // [WHEN] The send action is invoked, an error appears
        asserterror Editor.Send.Invoke();

        // [THEN] The error is as expected
        Assert.ExpectedError(StrSubstNo(InvalidEmailAddressErr, InvalidEmailAddress));

        // [THEN] No outbox and sent emails entries are created.
        Assert.TableIsEmpty(Database::"Email Outbox");
        Assert.TableIsEmpty(Database::"Sent Email");

        // [WHEN] Set a valid and an invalid email address for To recipients
        Editor.ToField.SetValue(ValidEmailAddress);
        Editor.CcField.SetValue(InvalidEmailAddress);

        // [WHEN] The send action is invoked, an error appears
        asserterror Editor.Send.Invoke();

        // [THEN] The error is as expected
        Assert.ExpectedError(StrSubstNo(InvalidEmailAddressErr, InvalidEmailAddress));

        // [THEN] No outbox and sent emails entries are created.
        Assert.TableIsEmpty(Database::"Email Outbox");
        Assert.TableIsEmpty(Database::"Sent Email");

        // [WHEN] Set a valid and an invalid email address for To recipients
        Editor.ToField.SetValue(ValidEmailAddress);
        Editor.CcField.SetValue(ValidEmailAddress);
        Editor.BccField.SetValue(InvalidEmailAddress);

        // [WHEN] The send action is invoked, an error appears
        asserterror Editor.Send.Invoke();

        // [THEN] The error is as expected
        Assert.ExpectedError(StrSubstNo(InvalidEmailAddressErr, InvalidEmailAddress));

        // [THEN] No outbox and sent emails entries are created.
        Assert.AreEqual(0, Outbox.Count(), 'No records in Email Outbox were expected');
        Assert.AreEqual(0, SentEmail.Count(), 'No records in Sent Email were expected');

        Editor.Close();
    end;

    [Test]
    [HandlerFunctions('EmailAccountLookUpHandler,DontSendWithoutSubjectHandler,DiscardEmailEditorHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure SendNewMessageThroughEditorNoSubjectTest()
    var
        EmailAccount: Record "Email Account";
        SentEmail: Record "Sent Email";
        Outbox: Record "Email Outbox";
        ConnectorMock: Codeunit "Connector Mock";
        EmailEditor: Page "Email Editor";
        Editor: TestPage "Email Editor";
        ValidEmailAddress: Text;
    begin
        // [SCENARIO] A new email message cannot be sent out if the TO recipient is invalid.

        // [GIVEN] A connector is installed and an account is added
        Outbox.DeleteAll();
        SentEmail.DeleteAll();
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(EmailAccount);
        ValidEmailAddress := Any.Email();

        PermissionsMock.Set('Email Admin');
        GiveUserViewAllPolicy();

        // [GIVEN] The Email Editor pages opens up and no details are filled
        Editor.Trap();
        EmailEditor.Run();

        Editor.Account.AssistEdit();
        Editor.ToField.SetValue(ValidEmailAddress);

        // [WHEN] The send action is invoked
        Editor.Send.Invoke(); // Confirm dialog appears. See DontSendWithoutSubjectHandler

        Editor.Close();

        // [THEN] No outbox and sent emails entries are created.
        Assert.AreEqual(0, Outbox.Count(), 'No records in Email Outbox were expected');
        Assert.AreEqual(0, SentEmail.Count(), 'No records in Sent Email were expected');
    end;

    [Test]
    [HandlerFunctions('EmailAccountLookUpHandler,SendWithoutSubjectHandler')]
    procedure SendNewMessageThroughEditorNoSubjectSendTest()
    var
        EmailAccount: Record "Email Account";
        SentEmail: Record "Sent Email";
        Outbox: Record "Email Outbox";
        ConnectorMock: Codeunit "Connector Mock";
        Message: Codeunit "Email Message";
        EmailEditor: Page "Email Editor";
        Editor: TestPage "Email Editor";
        ValidEmailAddress: Text;
    begin
        // [SCENARIO] A new email message cannot be sent out if the TO recipient is invalid.

        // [GIVEN] A connector is installed and an account is added
        Outbox.DeleteAll();
        SentEmail.DeleteAll();
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(EmailAccount);
        ValidEmailAddress := Any.Email();

        PermissionsMock.Set('Email Admin');
        GiveUserViewAllPolicy();

        // [GIVEN] The Email Editor pages opens up and no details are filled
        Editor.Trap();
        EmailEditor.Run();

        Editor.Account.AssistEdit();
        Editor.ToField.SetValue(ValidEmailAddress);

        // [WHEN] The send action is invoked, no error appears and the email is sent
        Editor.Send.Invoke();

        // [THEN] Verify the data
        Message.Get(ConnectorMock.GetEmailMessageID());
        SentEmail.SetRange("Message Id", Message.GetId());
        Assert.IsTrue(SentEmail.FindFirst(), 'A Sent Email record should have been inserted.');
        Assert.AreEqual('', SentEmail.Description, 'The email subject should be empty');
        Assert.AreEqual(EmailAccount."Account Id", SentEmail."Account Id", 'A different account was expected');
        Assert.AreEqual(EmailAccount."Email Address", SentEmail."Sent From", 'A different sent from was expected');
        Assert.AreEqual(Enum::"Email Connector"::"Test Email Connector", SentEmail.Connector, 'A different connector was expected');

        RemoveViewPolicies();
    end;

    [Test]
    procedure SendNewMessageThroughEditorTest()
    var
        TempAccount: Record "Email Account" temporary;
        SentEmail: Record "Sent Email";
        Email: Codeunit Email;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Editor: TestPage "Email Editor";
    begin
        // [SCENARIO] A new email message can be create in the email editor page from the Accounts page

        // [GIVEN] A connector is installed and an account is added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        PermissionsMock.Set('Email Edit');

        // [GIVEN] The Email Editor pages opens up and details are filled
        Editor.Trap();
        EmailMessage.Create('', '', '', false);
        Email.OpenInEditor(EmailMessage, TempAccount);

        // [GIVEN] Recipient is given in pure email format and other details are filled out
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
    procedure SendNewMessageWithDisplayNameRecipientThroughEditorTest()
    var
        TempAccount: Record "Email Account" temporary;
        SentEmail: Record "Sent Email";
        Email: Codeunit Email;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        Editor: TestPage "Email Editor";
    begin
        // [SCENARIO] A new email message can be create in the email editor page from the Accounts page

        // [GIVEN] A connector is installed and an account is added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        PermissionsMock.Set('Email Edit');

        // [GIVEN] The Email Editor pages opens up
        Editor.Trap();
        EmailMessage.Create('', '', '', false);
        Email.OpenInEditor(EmailMessage, TempAccount);

        // [GIVEN] Recipient is given in display name + email address format and other details are filled out
        Editor.ToField.SetValue('Recipient <recipient@test.com>');
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
    [HandlerFunctions('WordTemplateToBodyModalHandler')]
    procedure EmailEditorApplyWordTemplate()
    var
        EmailAccount: Record "Email Account";
        TestEmailAccount: Record "Test Email Account";
        ConnectorMock: Codeunit "Connector Mock";
        WordTemplateCreator: Codeunit "Word Template Creator";
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        EmailMessageImpl: Codeunit "Email Message Impl.";
        EmailEditor: Codeunit "Email Editor";
        EmailEditorTest: TestPage "Email Editor";
        TableId: Integer;
        PrimaryRecordEmail: Text[250];
        EmailBodyText: Text;
    begin
        // [SCENARIO] A word template is applied to the email body and the content of the word template is merged for a primary source record.

        // [GIVEN] A connector is installed, an account is added, and a template is created for the table id of the primary source
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(EmailAccount);
        PermissionsMock.Set('Email Word Template');
        TableId := Database::"Test Email Account";
        WordTemplateCreator.CreateWordTemplateWithMergeValues(TableId);

        // [WHEN] A email is created and a primary source is added.
        EmailMessage.Create(Any.Email(), Any.UnicodeText(50), Any.UnicodeText(250), true);
        PrimaryRecordEmail := CopyStr(Any.Email(), 1, 250);
        TestEmailAccount.Init();
        TestEmailAccount.Id := Any.GuidValue();
        TestEmailAccount.Email := PrimaryRecordEmail;
        TestEmailAccount.Insert();
        Email.AddRelation(EmailMessage, TableId, TestEmailAccount.SystemId, Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");

        // [GIVEN] The word template for the primary source is loaded from the email editor
        EmailMessageImpl.Get(EmailMessage.GetId());
        EmailEditorTest.Trap();
        EmailEditor.LoadWordTemplate(EmailMessageImpl, EmailMessage.GetId());

        // [THEN] The email body is filled with the merged content for the primary source
        EmailBodyText := EmailMessage.GetBody();
        Assert.IsTrue(StrLen(EmailBodyText) > 0, 'Failed to load template to email body');
        Assert.IsTrue(EmailBodyText.Contains(PrimaryRecordEmail), 'Failed to merge email of record.');
    end;

    [Test]
    [HandlerFunctions('WordTemplateToBodyModalHandler')]
    procedure EmailEditorApplyWordTemplateForMultipleRelatedEntities()
    var
        EmailAccount: Record "Email Account";
        TestEmailAccount: Record "Test Email Account";
        ConnectorMock: Codeunit "Connector Mock";
        WordTemplateCreator: Codeunit "Word Template Creator";
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        EmailMessageImpl: Codeunit "Email Message Impl.";
        EmailEditor: Codeunit "Email Editor";
        EmailEditorTest: TestPage "Email Editor";
        PrimaryTableId, RelatedTableId : Integer;
        FirstRelatedRecordEmail, SecondRelatedRecordEmail : Text[250];
        EmailBodyText: Text;
    begin
        // [SCENARIO] A word template is applied to the email body and the content of the word template is merged for a multiple related entities

        // [GIVEN] A connector is installed, an account is added, and a template is created for the related table id
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(EmailAccount);
        PermissionsMock.Set('Email Word Template');
        PrimaryTableId := Database::"Test Email Connector Setup";
        RelatedTableId := Database::"Test Email Account";
        WordTemplateCreator.CreateWordTemplateWithMergeValues(RelatedTableId);

        // [WHEN] A email is created and a primary source is added.
        EmailMessage.Create(Any.Email(), Any.UnicodeText(50), Any.UnicodeText(250), true);
        Email.AddRelation(EmailMessage, PrimaryTableId, Any.GuidValue(), Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");

        // [GIVEN] Two related records are inserted, for which the word template is created (the test email account table is used as the related record)
        FirstRelatedRecordEmail := CopyStr(Any.Email(), 1, 250);
        TestEmailAccount.Init();
        TestEmailAccount.Id := Any.GuidValue();
        TestEmailAccount.Email := FirstRelatedRecordEmail;
        TestEmailAccount.Insert();
        Email.AddRelation(EmailMessage, RelatedTableId, TestEmailAccount.SystemId, Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Compose Context");

        SecondRelatedRecordEmail := CopyStr(Any.Email(), 1, 250);
        TestEmailAccount.Init();
        TestEmailAccount.Id := Any.GuidValue();
        TestEmailAccount.Email := SecondRelatedRecordEmail;
        TestEmailAccount.Insert();
        Email.AddRelation(EmailMessage, RelatedTableId, TestEmailAccount.SystemId, Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Compose Context");

        // [GIVEN] The word template for the related records is loaded from the email editor
        EmailMessageImpl.Get(EmailMessage.GetId());
        EmailEditorTest.Trap();
        EmailEditor.LoadWordTemplate(EmailMessageImpl, EmailMessage.GetId());

        // [THEN] The email body is filled with the merged content for the two related records
        EmailBodyText := EmailMessage.GetBody();
        Assert.IsTrue(StrLen(EmailBodyText) > 0, 'Failed to load template to email body');
        Assert.IsTrue(EmailBodyText.Contains(FirstRelatedRecordEmail), 'Failed to merge email of first related record.');
        Assert.IsTrue(EmailBodyText.Contains(SecondRelatedRecordEmail), 'Failed to merge email of second related record.');
    end;

    [Test]
    [HandlerFunctions('WordTemplateAttachmentModalHandler')]
    procedure EmailEditorAttachWordTemplate()
    var
        EmailAccount: Record "Email Account";
        TestEmailAccount: Record "Test Email Account";
        ConnectorMock: Codeunit "Connector Mock";
        WordTemplateCreator: Codeunit "Word Template Creator";
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        EmailMessageImpl: Codeunit "Email Message Impl.";
        EmailEditor: Codeunit "Email Editor";
        EmailEditorTest: TestPage "Email Editor";
        AttachmentInStream: InStream;
        TableId: Integer;
        PrimaryRecordEmail: Text[250];
        AttachmentAsText: Text;
    begin
        // [SCENARIO] A word template is attached to an email and the content of the word template is merged for a primary source.

        // [GIVEN] A connector is installed, an account is added, and a template is created for the table id of the primary source
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(EmailAccount);
        PermissionsMock.Set('Email Word Template');
        TableId := Database::"Test Email Account";
        WordTemplateCreator.CreateWordTemplateWithMergeValues(TableId);

        // [WHEN] An email is created and a primary source is added.
        EmailMessage.Create(Any.Email(), Any.UnicodeText(50), Any.UnicodeText(250), true);
        PrimaryRecordEmail := CopyStr(Any.Email(), 1, 250);
        TestEmailAccount.Init();
        TestEmailAccount.Id := Any.GuidValue();
        TestEmailAccount.Email := PrimaryRecordEmail;
        TestEmailAccount.Insert();
        Email.AddRelation(EmailMessage, TableId, TestEmailAccount.SystemId, Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");

        // [GIVEN] The word template for the primary source is attached from the email editor
        EmailMessageImpl.Get(EmailMessage.GetId());
        EmailEditorTest.Trap();
        EmailEditor.AttachFromWordTemplate(EmailMessageImpl, EmailMessage.GetId());

        // [Then] The email message contains an attachment of correct type, that has the merged content of the word template.
        Assert.IsTrue(EmailMessageImpl.Attachments_First(), 'Failed to find attachment');
        Assert.IsTrue(EmailMessageImpl.Attachments_GetLength() > 0, 'Failed to load template to email body');

        EmailMessageImpl.Attachments_GetContent(AttachmentInStream);
        AttachmentInStream.ReadText(AttachmentAsText);
        Assert.IsTrue(StrLen(AttachmentAsText) > 0, 'Failed to read attachment body');
        Assert.IsTrue(AttachmentAsText.Contains(PrimaryRecordEmail), 'Failed to merge email of record.');
    end;

    [Test]
    [HandlerFunctions('WordTemplateAttachmentModalHandler')]
    procedure EmailEditorAttachWordTemplateForMultipleRelatedEntities()
    var
        EmailAccount: Record "Email Account";
        TestEmailAccount: Record "Test Email Account";
        ConnectorMock: Codeunit "Connector Mock";
        WordTemplateCreator: Codeunit "Word Template Creator";
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        EmailMessageImpl: Codeunit "Email Message Impl.";
        EmailEditor: Codeunit "Email Editor";
        EmailEditorTest: TestPage "Email Editor";
        AttachmentInStream: InStream;
        PrimaryTableId, RelatedTableId : Integer;
        FirstRelatedRecordEmail, SecondRelatedRecordEmail : Text[250];
        AttachmentAsText: Text;
    begin
        // [SCENARIO] A word template is attached to an email and the content of the word template is merged for multiple related entities.

        // [GIVEN] A connector is installed, an account is added, and a template is created for the related table id
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(EmailAccount);
        PermissionsMock.Set('Email Word Template');
        PrimaryTableId := Database::"Test Email Connector Setup";
        RelatedTableId := Database::"Test Email Account";
        WordTemplateCreator.CreateWordTemplateWithMergeValues(RelatedTableId);

        // [WHEN] A email is created and a primary source is added.
        EmailMessage.Create(Any.Email(), Any.UnicodeText(50), Any.UnicodeText(250), true);
        Email.AddRelation(EmailMessage, PrimaryTableId, Any.GuidValue(), Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");

        // [GIVEN] Two related records are inserted, for which the word template is created (the test email account table is used as the related record)
        FirstRelatedRecordEmail := CopyStr(Any.Email(), 1, 250);
        TestEmailAccount.Init();
        TestEmailAccount.Id := Any.GuidValue();
        TestEmailAccount.Email := FirstRelatedRecordEmail;
        TestEmailAccount.Insert();
        Email.AddRelation(EmailMessage, RelatedTableId, TestEmailAccount.SystemId, Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Compose Context");

        SecondRelatedRecordEmail := CopyStr(Any.Email(), 1, 250);
        TestEmailAccount.Init();
        TestEmailAccount.Id := Any.GuidValue();
        TestEmailAccount.Email := SecondRelatedRecordEmail;
        TestEmailAccount.Insert();
        Email.AddRelation(EmailMessage, RelatedTableId, TestEmailAccount.SystemId, Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Compose Context");

        // [GIVEN] The word template for the related records is loaded from the email editor
        EmailMessageImpl.Get(EmailMessage.GetId());
        EmailEditorTest.Trap();
        EmailEditor.AttachFromWordTemplate(EmailMessageImpl, EmailMessage.GetId());

        // [Then] The email message contains an attachment of correct type, that has the merged content of the word template.
        Assert.IsTrue(EmailMessageImpl.Attachments_First(), 'Failed to find first attachment');
        Assert.IsTrue(EmailMessageImpl.Attachments_GetLength() > 0, 'Failed to load template to email body for first attachment');

        EmailMessageImpl.Attachments_GetContent(AttachmentInStream);
        AttachmentInStream.ReadText(AttachmentAsText);
        Assert.IsTrue(StrLen(AttachmentAsText) > 0, 'Failed to read attachment body');
        Assert.IsTrue(AttachmentAsText.Contains(FirstRelatedRecordEmail), 'Failed to merge email of first related record.');
        Assert.IsTrue(AttachmentAsText.Contains(SecondRelatedRecordEmail), 'Failed to merge email of second related record.');
    end;

    [Test]
    [HandlerFunctions('ValidateDraftDefaultOptionEmailEditorHandler')]
    procedure EmailEditorCloseDefaultDraft()
    var
        EmailAccount: Record "Email Account";
        EmailOutbox: Record "Email Outbox";
        Email: Codeunit Email;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        EmailMessageImpl: Codeunit "Email Message Impl.";
        EmailEditorValues: Codeunit "Email Editor Values";
        EmailEditorTest: TestPage "Email Editor";
    begin
        // [GIVEN] All outbox records are deleted, connector is installed and an account is added.
        EmailOutbox.DeleteAll();
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(EmailAccount);

        // [GIVEN] Default exit parameter is draft (1)
        EmailEditorValues.SetDefaultExitOption(1);

        // [WHEN] A email is created and opened in the editor
        EmailMessage.Create(Any.Email(), Any.UnicodeText(50), Any.UnicodeText(250), true);
        EmailMessageImpl.Get(EmailMessage.GetId());
        EmailEditorTest.Trap();
        Email.OpenInEditor(EmailMessage, EmailAccount);

        // [WHEN] Editor is closed, the email is discarded
        EmailEditorTest.Close();

        // [THEN] There should be no drafts saved
        Assert.AreEqual(1, EmailOutbox.Count(), 'There is more or less than the expected number of drafts.');
    end;

    [Test]
    [HandlerFunctions('ValidateDiscardDefaultOptionEmailEditorHandler')]
    procedure EmailEditorCloseDefaultDiscard()
    var
        EmailAccount: Record "Email Account";
        EmailOutbox: Record "Email Outbox";
        Email: Codeunit Email;
        ConnectorMock: Codeunit "Connector Mock";
        EmailMessage: Codeunit "Email Message";
        EmailMessageImpl: Codeunit "Email Message Impl.";
        EmailEditorValues: Codeunit "Email Editor Values";
        EmailEditorTest: TestPage "Email Editor";
    begin
        // [GIVEN] All outbox records are deleted, connector is installed and an account is added.
        EmailOutbox.DeleteAll();
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(EmailAccount);

        // [GIVEN] Default exit parameter is discard (2)
        EmailEditorValues.SetDefaultExitOption(2);

        // [WHEN] A email is created and opened in the editor
        EmailMessage.Create(Any.Email(), Any.UnicodeText(50), Any.UnicodeText(250), true);
        EmailMessageImpl.Get(EmailMessage.GetId());
        EmailEditorTest.Trap();
        Email.OpenInEditor(EmailMessage, EmailAccount);

        // [WHEN] Editor is closed, the email is discarded
        EmailEditorTest.Close();

        // [THEN] There should be no drafts saved
        Assert.AreEqual(0, EmailOutbox.Count(), 'There should be no drafts');
    end;

    local procedure GiveUserViewAllPolicy()
    var
        EmailViewPolicy: Record "Email View Policy";
    begin
        // [Given] An own email policy
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

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure WordTemplateToBodyModalHandler(var WordTemplate: TestPage "Word Template To Text Wizard")
    begin
        WordTemplate.First();
        WordTemplate.Finish.Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure WordTemplateAttachmentModalHandler(var WordTemplate: TestPage "Word Template Selection Wizard")
    begin
        WordTemplate.First();
        WordTemplate.Next.Invoke();
        WordTemplate.Output.SetValue(Enum::"Word Templates Save Format"::Html);
        WordTemplate.Finish.Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure EmailAccountLookUpHandler(var EmailAccounts: TestPage "Email Accounts")
    begin
        EmailAccounts.First();
        EmailAccounts.OK().Invoke();
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure DontSendWithoutSubjectHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := false; // Don't send the email without subject
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure SendWithoutSubjectHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true; // Send the email without subject
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

    [StrMenuHandler]
    [Scope('OnPrem')]
    procedure ValidateDraftDefaultOptionEmailEditorHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Assert.AreEqual(1, Choice, 'The default option is not draft.');
    end;

    [StrMenuHandler]
    [Scope('OnPrem')]
    procedure ValidateDiscardDefaultOptionEmailEditorHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Assert.AreEqual(2, Choice, 'The default option is not discard.');
    end;
}