// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 134696 "Email Editor Validation Tests"
{
    SubType = Test;

    var
        Assert: Codeunit "Library Assert";
        Any: Codeunit Any;
        InvalidEmailAddressErr: Label 'The email address "%1" is not valid.', Locked = true;

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

        // [GIVEN] There are no outbox or sent email entries
        Outbox.DeleteAll();
        SentEmail.DeleteAll();

        // [GIVEN] The Email Editor pages opens up and no details are filled
        Editor.Trap();
        EmailEditor.Run();

        // [WHEN] The send action is invoked, an error appears
        asserterror Editor.Send.Invoke();

        // [THEN] The error is as expected
        Assert.ExpectedError('You must specify an email account from which to send the message.');
        Editor.Close();

        // [THEN] No outbox or sent emails entries have been created
        Assert.TableIsEmpty(Database::"Email Outbox");
        Assert.TableIsEmpty(Database::"Sent Email");
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
        Assert.TableIsEmpty(Database::"Email Outbox");
        Assert.TableIsEmpty(Database::"Sent Email");
    end;

    [Test]
    [HandlerFunctions('EmailAccountLookUpHandler,DiscardEmailEditorHandler')]
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
        Assert.TableIsEmpty(Database::"Email Outbox");
        Assert.TableIsEmpty(Database::"Sent Email");

        Editor.Close();
    end;

    [Test]
    [HandlerFunctions('EmailAccountLookUpHandler,DontSendWithoutSubjectHandler,DiscardEmailEditorHandler')]
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

        // [GIVEN] The Email Editor pages opens up and no details are filled
        Editor.Trap();
        EmailEditor.Run();

        Editor.Account.AssistEdit();
        Editor.ToField.SetValue(ValidEmailAddress);

        // [WHEN] The send action is invoked
        Editor.Send.Invoke(); // Confirm dialog appears. See DontSendWithoutSubjectHandler

        Editor.Close();

        // [THEN] No outbox and sent emails entries are created.
        Assert.TableIsEmpty(Database::"Email Outbox");
        Assert.TableIsEmpty(Database::"Sent Email");
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