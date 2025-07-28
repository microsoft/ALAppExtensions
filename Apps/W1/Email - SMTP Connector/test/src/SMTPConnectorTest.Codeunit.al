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
        SMTPConnector: Codeunit "SMTP Connector Impl.";
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
    [HandlerFunctions('SMTPAccountRegisterPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestCurrentUserAccountsCanBeRegistered()
    var
        EmailAccount: Record "Email Account";
        SMTPConnector: Codeunit "SMTP Connector Impl.";
        AccountIds: array[3] of Guid;
        AccountName: array[3] of Text[250];
        GivenEmail: Text;
        GivenName: Text;
        Index: Integer;
    begin
        // [Scenario] Create multiple SMTP accounts
        Initialize();
        GivenEmail := Any.Email();
        GivenName := Any.AlphabeticText(250);
        SetCurrentUserMailInfo(GivenName, GivenEmail);

        // [When] Multiple accounts are registered
        for Index := 1 to 3 do begin
            SetCurrentUserAccount(Index);

            Assert.IsTrue(SMTPConnector.RegisterAccount(EmailAccount), 'Failed to register account.');
            AccountIds[Index] := EmailAccount."Account Id";
            AccountName[Index] := SMTPAccountMock.Name();

            // [Then] Accounts are retrieved from the GetAccounts method
            EmailAccount.DeleteAll();
            SMTPConnector.GetAccounts(EmailAccount);
            Assert.IsTrue(EmailAccount.Get(AccountIds[Index], Enum::"Email Connector"::SMTP), 'Email account does not exist.');
            Assert.AreEqual(AccountName[Index], EmailAccount.Name, 'A different name was expected.');
            Assert.AreEqual(GivenEmail, EmailAccount."Email Address", 'A different email address was expected.');
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('SMTPAccountRegisterPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestCurrentUserAccountWithBlankContactEmail()
    var
        EmailAccount: Record "Email Account";
        EmailMessage: Codeunit "Email Message";
        SMTPConnector: Codeunit "SMTP Connector Impl.";
        AccountId: Guid;
        AccountName: Text[250];
        GivenName: Text;
        UserHasNoContactEmailErr: Label 'The user specified for SMTP emailing does not have a contact email set. Please update the user''s contact email to use Current User type for SMTP.';
    begin
        // [Scenario] Create multiple SMTP accounts
        Initialize();
        GivenName := Any.AlphabeticText(250);
        SetCurrentUserMailInfo(GivenName, '');

        // [When] Account is registered with blank email
        SetCurrentUserAccount(0, Enum::"SMTP Authentication Types"::Anonymous);

        Assert.IsTrue(SMTPConnector.RegisterAccount(EmailAccount), 'Failed to register account.');
        AccountId := EmailAccount."Account Id";
        AccountName := SMTPAccountMock.Name();

        // [When] Email Message created and sent
        // [Then] Sending fails and error with User has no contact email
        EmailMessage.Create(Any.Email(), Any.AlphabeticText(10), Any.AlphabeticText(10));
        assertError SMTPConnector.Send(EmailMessage, AccountId);
        Assert.ExpectedError(UserHasNoContactEmailErr);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('SMTPAccountRegisterPageHandler,SMTPAccountShowPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestShowAccountInformation()
    var
        EmailAccount: Record "Email Account";
        SMTPConnector: Codeunit "SMTP Connector Impl.";
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
        SMTPAccountMock.Authentication("SMTP Authentication Types"::Basic);
        SMTPAccountMock.EmailAddress('test' + Format(Index) + '@mail.com');
        SMTPAccountMock.UserID('test' + Format(Index) + '@mail.com');
        SMTPAccountMock.Password('testpassword');
        SMTPAccountMock.SecureConnection(true);
        SMTPAccountMock.SenderType(Enum::"SMTP Connector Sender Type"::"Specific User");
    end;

    local procedure SetCurrentUserAccount(Index: Integer)
    begin
        SetCurrentUserAccount(Index, Enum::"SMTP Authentication Types"::Basic);
    end;

    local procedure SetCurrentUserAccount(Index: Integer; AuthenticationType: Enum "SMTP Authentication Types")
    begin
        SMTPAccountMock.Name(CopyStr(Any.AlphanumericText(250), 1, 250));
        SMTPAccountMock.Server('smtp.office365.com');
        SMTPAccountMock.ServerPort(587);
        SMTPAccountMock.Authentication(AuthenticationType);
        SMTPAccountMock.UserID('test' + Format(Index) + '@mail.com');
        SMTPAccountMock.Password('testpassword');
        SMTPAccountMock.SenderType(Enum::"SMTP Connector Sender Type"::"Current User");
        SMTPAccountMock.SecureConnection(true);
    end;

    local procedure SetCurrentUserMailInfo(Name: Text; Email: Text)
    var
        User: Record User;
    begin
        // User should exist, otherwise create locally
        // Test is in bucket that creates users
        User.Get(UserSecurityId());
        User."Contact Email" := CopyStr(Email, 1, MaxStrLen(User."Contact Email"));
        User."Full Name" := CopyStr(Name, 1, MaxStrLen(User."Full Name"));
        User.Modify();
    end;

    [ModalPageHandler]
    procedure SMTPAccountRegisterPageHandler(var SMTPAccountWizard: TestPage "SMTP Account Wizard")
    begin
        // Setup SMTP account

        SMTPAccountWizard.NameField.SetValue(SMTPAccountMock.Name());
        SMTPAccountWizard.ServerUrl.SetValue(SMTPAccountMock.Server());
        SMTPAccountWizard.ServerPort.SetValue(SMTPAccountMock.ServerPort());
        SMTPAccountWizard.Authentication.SetValue(SMTPAccountMock.Authentication());
        SMTPAccountWizard.SenderTypeField.SetValue(SMTPAccountMock.SenderType());
        if (SMTPAccountMock.SenderType() = Enum::"SMTP Connector Sender Type"::"Specific User") then
            SMTPAccountWizard.EmailAddress.SetValue(SMTPAccountMock.UserID());
        SMTPAccountWizard.UserName.SetValue(SMTPAccountMock.UserID());
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
        Assert.AreEqual(Format(SMTPAccountMock.SenderType()), SMTPAccount.SenderTypeField.Value(), 'A different sender type was expected.');
    end;

    var
        Any: Codeunit Any;
        Assert: Codeunit "Library Assert";
        SMTPAccountMock: Codeunit "SMTP Account Mock";
}
