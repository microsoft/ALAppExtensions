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
        AttachmentDefaultContentTypeTxt: Label 'application/vnd.openxmlformats-officedocument.wordprocessingml.document(.docx)', Locked = true;

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
        TempEmailAccount: Record "Email Account";
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
        ConnectorMock.AddAccount(TempEmailAccount);

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
        TempEmailAccount: Record "Email Account";
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
        ConnectorMock.AddAccount(TempEmailAccount);
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
        Editor.ToField.SetValue(StrSubstNo('%1; %2', ValidEmailAddress, InvalidEmailAddress));

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
        TempEmailAccount: Record "Email Account";
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
        ConnectorMock.AddAccount(TempEmailAccount);
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
        TempEmailAccount: Record "Email Account";
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
        ConnectorMock.AddAccount(TempEmailAccount);
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
        Assert.AreEqual(TempEmailAccount."Account Id", SentEmail."Account Id", 'A different account was expected');
        Assert.AreEqual(TempEmailAccount."Email Address", SentEmail."Sent From", 'A different sent from was expected');
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
    [HandlerFunctions('WordTemplateToBodyModalHandler')]
    procedure EmailEditorApplyWordTemplate()
    var
        TempEmailAccount: Record "Email Account";
        ConnectorMock: Codeunit "Connector Mock";
        WordTemplateCreator: Codeunit "Word Template Creator";
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        EmailMessageImpl: Codeunit "Email Message Impl.";
        EmailEditor: Codeunit "Email Editor";
        EmailEditorTest: TestPage "Email Editor";
        TableId: Integer;
        Text: Text;
    begin

        // [GIVEN] A connector is installed, an account is added, and a template exists for the Table ID.
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempEmailAccount);
        PermissionsMock.Set('Email Word Template');
        TableId := Database::"Test Email Account";
        WordTemplateCreator.CreateCustomerWordTemplate(TableId);

        // [WHEN] A email is created and a word template is applied to the email.
        EmailMessage.Create(Any.Email(), Any.UnicodeText(50), Any.UnicodeText(250), true);
        Email.AddRelation(EmailMessage, TableId, Any.GuidValue(), Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");
        EmailMessageImpl.Get(EmailMessage.GetId());
        EmailEditorTest.Trap();
        EmailEditor.LoadWordTemplate(EmailMessageImpl, EmailMessage.GetId());

        // [Then] The email body is filled with the html contents that make up the word template.
        Text := EmailMessage.GetBody();
        Assert.IsTrue(StrLen(Text) > 0, 'Failed to load template to email body');
        Assert.IsTrue(Text.Contains('Test Text'), 'Failed to load correct template');
    end;

    [Test]
    [HandlerFunctions('WordTemplateAttachmentModalHandler')]
    procedure EmailEditorAttachWordTemplate()
    var
        TempEmailAccount: Record "Email Account";
        ConnectorMock: Codeunit "Connector Mock";
        WordTemplateCreator: Codeunit "Word Template Creator";
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        EmailMessageImpl: Codeunit "Email Message Impl.";
        EmailEditor: Codeunit "Email Editor";
        EmailEditorTest: TestPage "Email Editor";
        TableId: Integer;
    begin

        // [GIVEN] A connector is installed, an account is added, and a template exists for the Table ID.
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempEmailAccount);
        PermissionsMock.Set('Email Word Template');
        TableId := Database::"Test Email Account";
        WordTemplateCreator.CreateCustomerWordTemplate(TableId);

        // [WHEN] A email is created and a word template is atached as an attachment.
        EmailMessage.Create(Any.Email(), Any.UnicodeText(50), Any.UnicodeText(250), true);
        Email.AddRelation(EmailMessage, TableId, Any.GuidValue(), Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");
        EmailMessageImpl.Get(EmailMessage.GetId());
        EmailEditorTest.Trap();
        EmailEditor.AttachFromWordTemplate(EmailMessageImpl, EmailMessage.GetId());

        // [Then] The email message contains an attachment of correct type, that has the contents of the word template.
        Assert.IsTrue(EmailMessageImpl.Attachments_First(), 'Failed to find attachment');
        Assert.IsTrue(EmailMessageImpl.Attachments_GetLength() > 0, 'Failed to load template to email body');
        Assert.AreEqual(EmailMessageImpl.Attachments_GetContentType(), AttachmentDefaultContentTypeTxt, 'Wrong default type of email attachment');

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
}