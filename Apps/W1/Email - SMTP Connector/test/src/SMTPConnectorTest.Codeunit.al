// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139760 "SMTP Connector Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('SMTPAccountRegisterPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestMultipleAccountsCanBeRegistered()
    var
        EmailAccount: Record "Email Account";
        SMTPConnector: Codeunit "SMTP Connector";
        EmailAccounts: TestPage "Email Accounts";
        AccountIds: array[3] of Guid;
        AccountName: array[3] of Text[250];
        AccountUserId: array[3] of Text[250];
        Index: Integer;
    begin
        // [Scenario] Create multiple SMTP accounts
        Initialize();

        // [When] Multiple accounts are registered
        for Index := 1 to 3 do begin
            SetBasicAccount(Index);

            Assert.IsTrue(SMTPConnector.RegisterAccount(EmailAccount), 'Failed to register account.');
            AccountIds[Index] := EmailAccount."Account Id";
            AccountName[Index] := SMTPAccountMock.Name();
            AccountUserId[Index] := SMTPAccountMock.UserID();

            // [Then] Accounts are retrieved from the GetAccounts method
            EmailAccount.DeleteAll();
            SMTPConnector.GetAccounts(EmailAccount);
            Assert.RecordCount(EmailAccount, Index);
        end;

        EmailAccounts.OpenView();
        for Index := 1 to 3 do begin
            EmailAccounts.GoToKey(AccountIds[Index], Enum::"Email Connector"::SMTP);
            Assert.AreEqual(AccountName[Index], EmailAccounts.NameField.Value(), 'A different name was expected.');
            Assert.AreEqual(AccountUserId[Index], EmailAccounts.EmailAddress.Value(), 'A different email address was expected.');
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('SMTPAccountRegisterPageHandler,SMTPAccountShowPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestShowAccountInformation()
    var
        EmailAccount: Record "Email Account";
        SMTPConnector: Codeunit "SMTP Connector";
    begin
        // [Scenario] Account Information is displayed in the "SMTP Account" page.

        // [Given] An SMTP account
        Initialize();
        SetBasicAccount(1);
        SMTPConnector.RegisterAccount(EmailAccount);

        // [When] The ShowAccountInformation method is invoked
        SMTPConnector.ShowAccountInformation(EmailAccount."Account Id");

        // [Then] The account page opens and displays the information
        // Verify in SMTPAccountModalPageHandler
    end;

    [Test]
    [Scope('OnPrem')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestSendMailPayloadMessage()
    var
        SMTPAccount: Record "SMTP Account";
        EmailMessage: Codeunit "Email Message";
        SMTPClientMock: Codeunit "SMTP Client Mock";
        SMTPMessageMock: Codeunit "SMTP Message Mock";
        SMTPMessage: Codeunit "SMTP Message";
        SMTPConnectorImpl: Codeunit "SMTP Connector Impl.";
        SMTPClient: Interface "SMTP Client";
    begin
        // [Scenario] Create a message and send
        Initialize();

        // [Given] SMTP Account and Email Message with recipients
        SMTPClientMock.Initialize();
        SMTPClientMock.AddAccount(SMTPAccount);
        SMTPMessageMock.CreateEmailMessage(SMTPAccount.Id, EmailMessage);
        SMTPMessageMock.GetMessage(EmailMessage, SMTPAccount.Id, SMTPMessage);
        SMTPClientMock.InitializeClient(SMTPAccount, SMTPMessage, SMTPClient);
        SMTPConnectorImpl.SetClient(SMTPClient);

        // [When] Client connected, authenticated and email sent. No error should be thrown
        SMTPConnectorImpl.Send(EmailMessage, SMTPAccount.Id);

        // [Then] Message sent is the same as the created message
        SMTPMessageMock.VerifyEmail();
    end;

    local procedure Initialize()
    var
        SMTPAccount: Record "SMTP Account";
    begin
        SMTPAccount.DeleteAll();
    end;

    local procedure SetBasicAccount(Index: Integer)
    begin
        SMTPAccountMock.Name(CopyStr(Any.AlphanumericText(250), 1, 250));
        SMTPAccountMock.Server('smtp.office365.com');
        SMTPAccountMock.ServerPort(587);
        SMTPAccountMock.Authentication("SMTP Authentication"::Basic);
        SMTPAccountMock.EmailAddress('test' + Format(Index) + '@mail.com');
        SMTPAccountMock.UserID('test' + Format(Index) + '@mail.com');
        SMTPAccountMock.Password('testpassword');
        SMTPAccountMock.SecureConnection(true);
    end;

    [ModalPageHandler]
    procedure SMTPAccountRegisterPageHandler(var SMTPAccountWizard: TestPage "SMTP Account Wizard")
    begin
        // Setup SMTP account

        SMTPAccountWizard.NameField.SetValue(SMTPAccountMock.Name());
        SMTPAccountWizard.ServerUrl.SetValue(SMTPAccountMock.Server());
        SMTPAccountWizard.ServerPort.SetValue(SMTPAccountMock.ServerPort());
        SMTPAccountWizard.Authentication.SetValue(SMTPAccountMock.Authentication());
        SMTPAccountWizard.EmailAddress.SetValue(SMTPAccountMock.UserID());
        SMTPAccountWizard.Password.SetValue(SMTPAccountMock.Password());
        SMTPAccountWizard.SecureConnection.SetValue(SMTPAccountMock.SecureConnection());

        SMTPAccountWizard.Next.Invoke();
    end;

    [PageHandler]
    procedure SMTPAccountShowPageHandler(var SMTPAccount: TestPage "SMTP Account")
    begin
        // Verify the SMTP account
        Assert.AreEqual(SMTPAccountMock.Name(), SMTPAccount.NameField.Value(), 'A different name was expected.');
        Assert.AreEqual(SMTPAccountMock.UserID(), SMTPAccount.UserName.Value(), 'A different email address was expected.');
        Assert.AreEqual(SMTPAccountMock.Server(), SMTPAccount.ServerUrl.Value(), 'A different server url was expected.');
        Assert.AreEqual(SMTPAccountMock.ServerPort(), SMTPAccount.ServerPort.AsInteger(), 'A different server port was expected.');
        Assert.AreEqual(Format(SMTPAccountMock.Authentication()), SMTPAccount.Authentication.Value(), 'A different authentication was expected.');
        Assert.AreEqual(SMTPAccountMock.SecureConnection(), SMTPAccount.SecureConnection.AsBoolean(), 'A different secure connection was expected.');
    end;

    var
        Any: Codeunit Any;
        Assert: Codeunit "Library Assert";
        SMTPAccountMock: Codeunit "SMTP Account Mock";
}