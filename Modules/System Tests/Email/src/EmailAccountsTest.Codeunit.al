// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 134686 "Email Accounts Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        AccountNameLbl: Label '%1 (%2)';
        AccountToSelect: Guid;

    [Test]
    [Scope('OnPrem')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure AccountsAppearOnThePageTest()
    var
        EmailAccount: Record "Email Account";
        ConnectorMock: Codeunit "Connector Mock";
        AccountsPage: TestPage "Email Accounts";
    begin
        // [Scenario] When there's a email account for a connector, it appears on the accounts page

        // [Given] A email account
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(EmailAccount);

        PermissionsMock.Set('Email Edit');

        // [When] The accounts page is open
        AccountsPage.OpenView();

        // [Then] The email entry is visible on the page
        Assert.IsTrue(AccountsPage.GoToKey(EmailAccount."Account Id", EmailAccount.Connector), 'The email account should be on the page');

        Assert.AreEqual(EmailAccount."Email Address", Format(AccountsPage.EmailAddress), 'The email address on the page is wrong');
        Assert.AreEqual(EmailAccount.Name, Format(AccountsPage.NameField), 'The account name on the page is wrong');
    end;

    [Test]
    [Scope('OnPrem')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TwoAccountsAppearOnThePageTest()
    var
        FirstEmailAccount, SecondEmailAccount : Record "Email Account";
        ConnectorMock: Codeunit "Connector Mock";
        AccountsPage: TestPage "Email Accounts";
    begin
        // [Scenario] When there's a email account for a connector, it appears on the accounts page

        // [Given] Two email accounts
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(FirstEmailAccount);
        ConnectorMock.AddAccount(SecondEmailAccount);

        PermissionsMock.Set('Email Edit');

        // [When] The accounts page is open
        AccountsPage.OpenView();

        // [Then] The email entries are visible on the page
        Assert.IsTrue(AccountsPage.GoToKey(FirstEmailAccount."Account Id", Enum::"Email Connector"::"Test Email Connector"), 'The first email account should be on the page');
        Assert.AreEqual(FirstEmailAccount."Email Address", Format(AccountsPage.EmailAddress), 'The first email address on the page is wrong');
        Assert.AreEqual(FirstEmailAccount.Name, Format(AccountsPage.NameField), 'The first account name on the page is wrong');

        Assert.IsTrue(AccountsPage.GoToKey(SecondEmailAccount."Account Id", Enum::"Email Connector"::"Test Email Connector"), 'The second email account should be on the page');
        Assert.AreEqual(SecondEmailAccount."Email Address", Format(AccountsPage.EmailAddress), 'The second email address on the page is wrong');
        Assert.AreEqual(SecondEmailAccount.Name, Format(AccountsPage.NameField), 'The second account name on the page is wrong');
    end;

    [Test]
    [Scope('OnPrem')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure AddNewAccountTest()
    var
        ConnectorMock: Codeunit "Connector Mock";
        AccountWizardPage: TestPage "Email Account Wizard";
    begin
        // [SCENARIO] A new Account can be added through the Account Wizard
        PermissionsMock.Set('Email Admin');

        ConnectorMock.Initialize();

        // [WHEN] The AddAccount action is invoked
        AccountWizardPage.Trap();
        Page.Run(Page::"Email Account Wizard");

        // [WHEN] The next field is invoked
        AccountWizardPage.Next.Invoke();

        // [THEN] The connector screen is shown and the test connector is shown
        Assert.IsTrue(AccountWizardPage.Logo.Visible(), 'Connector Logo should be visible');
        Assert.IsTrue(AccountWizardPage.Name.Visible(), 'Connector Name should be visible');
        Assert.IsTrue(AccountWizardPage.Details.Visible(), 'Connector Details should be visible');

        Assert.IsTrue(AccountWizardPage.GoToKey(Enum::"Email Connector"::"Test Email Connector"), 'Test Email connector was not shown in the page');

        // [WHEN] The Name field is drilled down
        AccountWizardPage.Next.Invoke();

        // [THEN] The Connector registers the Account and the last page is shown
        Assert.AreEqual(AccountWizardPage.EmailAddressfield.Value(), 'Test email address', 'A different Email address was expected');
        Assert.AreEqual(AccountWizardPage.NameField.Value(), 'Test account', 'A different name was expected');
        Assert.AreEqual(AccountWizardPage.DefaultField.AsBoolean(), True, 'Default should be set to true if it''s the first account to be set up');
    end;

    [Test]
    [Scope('OnPrem')]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('AddAccountModalPageHandler')]
    procedure AddNewAccountActionRunsPageInModalTest()
    var
        AccountsPage: TestPage "Email Accounts";
    begin
        // [SCENARIO] The add Account action open the Account Wizard page in modal mode
        PermissionsMock.Set('Email Admin');

        AccountsPage.OpenView();
        // [WHEN] The AddAccount action is invoked
        AccountsPage.AddAccount.Invoke();

        // Verify with AddAccountModalPageHandler
    end;

    [Test]
    procedure OpenEditorFromAccountsPageTest()
    var
        TempAccount: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        Accounts: TestPage "Email Accounts";
        Editor: TestPage "Email Editor";
    begin
        // [SCENARIO] Email editor page can be opened from the Accounts page
        Editor.Trap();
        // [GIVEN] A connector is installed and an account is added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);
        
        PermissionsMock.Set('Email Edit');

        // [WHEN] The Send Email action is invoked
        Accounts.OpenView();
        Accounts.GoToKey(TempAccount."Account Id", TempAccount.Connector);
        Accounts.SendEmail.Invoke();

        // [THEN] The Editor page opens to create a new message
        Assert.AreEqual(StrSubstNo(AccountNameLbl, TempAccount.Name, TempAccount."Email Address"), Editor.Account.Value(), 'A different from was expected.');
    end;

    [Test]
    procedure OpenSentMailsFromAccountsPageTest()
    var
        TempAccount: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        Accounts: TestPage "Email Accounts";
        SentEmails: TestPage "Sent Emails";
    begin
        // [SCENARIO] Sent emails page can be opened from the Accouns page
        SentEmails.Trap();
        // [GIVEN] A connector is installed and an account is added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        PermissionsMock.Set('Email Edit');

        // [WHEN] The Outbox action is invoked
        Accounts.OpenView();
        Accounts.Outbox.Invoke();

        // [THEN] The Editor page opens to create a new message
        // Verify with Trap
    end;

    [Test]
    [Scope('OnPrem')]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('SentEmailsPageHandler')]
    procedure OpenOutBoxFromAccountsPageTest()
    var
        TempAccount: Record "Email Account" temporary;
        ConnectorMock: Codeunit "Connector Mock";
        Accounts: TestPage "Email Accounts";
        Outbox: TestPage "Email Outbox";
    begin
        // [SCENARIO] Outbox page can be opened from the Accounts page
        Outbox.Trap();
        // [GIVEN] A connector is installed and an account is added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(TempAccount);

        PermissionsMock.Set('Email Edit');

        // [WHEN] The Sent Emails action is invoked
        Accounts.OpenView();
        Accounts.SentEmails.Invoke();

        // [THEN] The Editor page opens to create a new message
        // Verify with Trap
    end;

    [Test]
    procedure GetAllAccountsTest()
    var
        EmailAccountBuffer, EmailAccounts : Record "Email Account";
        EmailAccount: Codeunit "Email Account";
        ConnectorMock: Codeunit "Connector Mock";
    begin
        // [SCENARIO] GetAllAccounts retrieves all the registered accounts

        // [GIVEN] A connector is installed and no account is added
        ConnectorMock.Initialize();

        PermissionsMock.Set('Email Edit');

        // [WHEN] GetAllAccounts is called
        EmailAccount.GetAllAccounts(EmailAccounts);

        // [THEN] The returned record is empty (there are no registered accounts)
        Assert.IsTrue(EmailAccounts.IsEmpty(), 'Record should be empty');

        // [GIVEN] An account is added to the connector
        ConnectorMock.AddAccount(EmailAccountBuffer);

        // [WHEN] GetAllAccounts is called
        EmailAccount.GetAllAccounts(EmailAccounts);

        // [THEN] The returned record is not empty and the values are as expected
        Assert.AreEqual(1, EmailAccounts.Count(), 'Record should not be empty');
        EmailAccounts.FindFirst();
        Assert.AreEqual(EmailAccountBuffer."Account Id", EmailAccounts."Account Id", 'Wrong account ID');
        Assert.AreEqual(Enum::"Email Connector"::"Test Email Connector", EmailAccounts.Connector, 'Wrong connector');
        Assert.AreEqual(EmailAccountBuffer.Name, EmailAccounts.Name, 'Wrong account name');
        Assert.AreEqual(EmailAccountBuffer."Email Address", EmailAccounts."Email Address", 'Wrong account email address');
    end;

    [Test]
    procedure IsAnyAccountRegisteredTest()
    var
        EmailAccount: Codeunit "Email Account";
        ConnectorMock: Codeunit "Connector Mock";
        AccountId: Guid;
    begin
        // [SCENARIO] Email Account Exists works as expected

        // [GIVEN] A connector is installed and no account is added
        ConnectorMock.Initialize();

        PermissionsMock.Set('Email Edit');

        // [WHEN] Calling IsAnyAccountRegistered
        // [THEN] it evaluates to false
        Assert.IsFalse(EmailAccount.IsAnyAccountRegistered(), 'There should be no registered accounts');

        // [WHEN] An email account is added
        ConnectorMock.AddAccount(AccountId);

        // [WHEN] Calling IsAnyAccountRegistered
        // [THEN] it evaluates to true
        Assert.IsTrue(EmailAccount.IsAnyAccountRegistered(), 'There should be a registered account');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure DeleteAllAccountsTest()
    var
        ConnectorMock: Codeunit "Connector Mock";
        EmailAccountsSelectionMock: Codeunit "Email Accounts Selection Mock";
        EmailAccountsTestPage: TestPage "Email Accounts";
        FirstAccountId, SecondAccountId, ThirdAccountId : Guid;
    begin
        // [SCENARIO] When all accounts are deleted, the Email Accounts page is empty
        PermissionsMock.Set('Email Admin');

        // [GIVEN] A connector is installed and three account are added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(FirstAccountId);
        ConnectorMock.AddAccount(SecondAccountId);
        ConnectorMock.AddAccount(ThirdAccountId);

        // [WHEN] Open the Email Accounts page
        EmailAccountsTestPage.OpenView();

        // [WHEN] Select all of the accounts
        BindSubscription(EmailAccountsSelectionMock);
        EmailAccountsSelectionMock.SelectAccount(FirstAccountId);
        EmailAccountsSelectionMock.SelectAccount(SecondAccountId);
        EmailAccountsSelectionMock.SelectAccount(ThirdAccountId);

        // [WHEN] Delete action is invoked and the action is confirmed (see ConfirmYesHandler)
        EmailAccountsTestPage.Delete.Invoke();

        // [THEN] The page is empty
        Assert.IsFalse(EmailAccountsTestPage.First(), 'The Email Accounts page should be empty');
    end;

    [Test]
    [HandlerFunctions('ConfirmNoHandler')]
    procedure DeleteAllAccountsCancelTest()
    var
        ConnectorMock: Codeunit "Connector Mock";
        EmailAccountsSelectionMock: Codeunit "Email Accounts Selection Mock";
        EmailAccountsTestPage: TestPage "Email Accounts";
        FirstAccountId, SecondAccountId, ThirdAccountId : Guid;
    begin
        // [SCENARIO] When all accounts are about to be deleted but the action in canceled, the Email Accounts page contains all of them.
        PermissionsMock.Set('Email Admin');

        // [GIVEN] A connector is installed and three account are added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(FirstAccountId);
        ConnectorMock.AddAccount(SecondAccountId);
        ConnectorMock.AddAccount(ThirdAccountId);

        // [WHEN] Open the Email Accounts page
        EmailAccountsTestPage.OpenView();

        // [WHEN] Select all of the accounts
        BindSubscription(EmailAccountsSelectionMock);
        EmailAccountsSelectionMock.SelectAccount(FirstAccountId);
        EmailAccountsSelectionMock.SelectAccount(SecondAccountId);
        EmailAccountsSelectionMock.SelectAccount(ThirdAccountId);

        // [WHEN] Delete action is invoked and the action is not confirmed (see ConfirmNoHandler)
        EmailAccountsTestPage.Delete.Invoke();

        // [THEN] All of the accounts are on the page
        Assert.IsTrue(EmailAccountsTestPage.GoToKey(FirstAccountId, Enum::"Email Connector"::"Test Email Connector"), 'The first email account should be on the page');
        Assert.IsTrue(EmailAccountsTestPage.GoToKey(SecondAccountId, Enum::"Email Connector"::"Test Email Connector"), 'The second email account should be on the page');
        Assert.IsTrue(EmailAccountsTestPage.GoToKey(ThirdAccountId, Enum::"Email Connector"::"Test Email Connector"), 'The third email account should be on the page');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure DeleteSomeAccountsTest()
    var
        ConnectorMock: Codeunit "Connector Mock";
        EmailAccountsSelectionMock: Codeunit "Email Accounts Selection Mock";
        EmailAccountsTestPage: TestPage "Email Accounts";
        FirstAccountId, SecondAccountId, ThirdAccountId : Guid;
    begin
        // [SCENARIO] When some accounts are deleted, they cannot be found on the page
        PermissionsMock.Set('Email Admin');

        // [GIVEN] A connector is installed and three account are added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(FirstAccountId);
        ConnectorMock.AddAccount(SecondAccountId);
        ConnectorMock.AddAccount(ThirdAccountId);

        // [WHEN] Open the Email Accounts page
        EmailAccountsTestPage.OpenView();

        // [WHEN] Select only two of the accounts
        BindSubscription(EmailAccountsSelectionMock);
        EmailAccountsSelectionMock.SelectAccount(FirstAccountId);
        EmailAccountsSelectionMock.SelectAccount(ThirdAccountId);

        // [WHEN] Delete action is invoked and the action is confirmed (see ConfirmYesHandler)
        EmailAccountsTestPage.Delete.Invoke();

        // [THEN] The deleted accounts are not on the page, the non-deleted accounts are on the page.
        Assert.IsFalse(EmailAccountsTestPage.GoToKey(FirstAccountId, Enum::"Email Connector"::"Test Email Connector"), 'The first email account should not be on the page');
        Assert.IsTrue(EmailAccountsTestPage.GoToKey(SecondAccountId, Enum::"Email Connector"::"Test Email Connector"), 'The second email account should be on the page');
        Assert.IsFalse(EmailAccountsTestPage.GoToKey(ThirdAccountId, Enum::"Email Connector"::"Test Email Connector"), 'The third email account should not be on the page');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure DeleteNonDefaultAccountTest()
    var
        SecondAccount: Record "Email Account";
        ConnectorMock: Codeunit "Connector Mock";
        EmailAccountsSelectionMock: Codeunit "Email Accounts Selection Mock";
        EmailScenario: Codeunit "Email Scenario";
        EmailAccountsTestPage: TestPage "Email Accounts";
        FirstAccountId, ThirdAccountId : Guid;
    begin
        // [SCENARIO] When the a non default account is deleted, the user is not prompted to choose a new default account.
        PermissionsMock.Set('Email Admin');

        // [GIVEN] A connector is installed and three account are added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(FirstAccountId);
        ConnectorMock.AddAccount(SecondAccount);
        ConnectorMock.AddAccount(ThirdAccountId);

        // [GIVEN] The second account is set as default
        EmailScenario.SetDefaultEmailAccount(SecondAccount);

        // [WHEN] Open the Email Accounts page
        EmailAccountsTestPage.OpenView();

        // [WHEN] Select a non-default account
        BindSubscription(EmailAccountsSelectionMock);
        EmailAccountsSelectionMock.SelectAccount(FirstAccountId);

        // [WHEN] Delete action is invoked and the action is confirmed (see ConfirmYesHandler)
        EmailAccountsTestPage.Delete.Invoke();

        // [THEN] The deleted accounts are not on the page, the non-deleted accounts are on the page.
        Assert.IsFalse(EmailAccountsTestPage.GoToKey(FirstAccountId, Enum::"Email Connector"::"Test Email Connector"), 'The first email account should not be on the page');

        Assert.IsTrue(EmailAccountsTestPage.GoToKey(SecondAccount."Account Id", Enum::"Email Connector"::"Test Email Connector"), 'The second email account should be on the page');
        Assert.IsTrue(GetDefaultFieldValueAsBoolean(EmailAccountsTestPage.DefaultField.Value), 'The second account should be marked as default');

        Assert.IsTrue(EmailAccountsTestPage.GoToKey(ThirdAccountId, Enum::"Email Connector"::"Test Email Connector"), 'The third email account should be on the page');
        Assert.IsFalse(GetDefaultFieldValueAsBoolean(EmailAccountsTestPage.DefaultField.Value), 'The third account should not be marked as default');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure DeleteDefaultAccountTest()
    var
        SecondAccount: Record "Email Account";
        ConnectorMock: Codeunit "Connector Mock";
        EmailAccountsSelectionMock: Codeunit "Email Accounts Selection Mock";
        EmailScenario: Codeunit "Email Scenario";
        EmailAccountsTestPage: TestPage "Email Accounts";
        FirstAccountId, ThirdAccountId : Guid;
    begin
        // [SCENARIO] When the default account is deleted, the user is not prompted to choose a new default account if there's only one account left
        PermissionsMock.Set('Email Admin');

        // [GIVEN] A connector is installed and three account are added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(FirstAccountId);
        ConnectorMock.AddAccount(SecondAccount);
        ConnectorMock.AddAccount(ThirdAccountId);

        // [GIVEN] The second account is set as default
        EmailScenario.SetDefaultEmailAccount(SecondAccount);

        // [WHEN] Open the Email Accounts page
        EmailAccountsTestPage.OpenView();

        // [WHEN] Select accounts including the default one
        BindSubscription(EmailAccountsSelectionMock);
        EmailAccountsSelectionMock.SelectAccount(SecondAccount."Account Id");
        EmailAccountsSelectionMock.SelectAccount(ThirdAccountId);

        // [WHEN] Delete action is invoked and the action is confirmed (see ConfirmYesHandler)
        EmailAccountsTestPage.Delete.Invoke();

        // [THEN] The deleted accounts are not on the page, the non-deleted accounts are on the page.
        Assert.IsTrue(EmailAccountsTestPage.GoToKey(FirstAccountId, Enum::"Email Connector"::"Test Email Connector"), 'The first email account should be on the page');
        Assert.IsTrue(GetDefaultFieldValueAsBoolean(EmailAccountsTestPage.DefaultField.Value), 'The first account should be marked as default');

        Assert.IsFalse(EmailAccountsTestPage.GoToKey(SecondAccount."Account Id", Enum::"Email Connector"::"Test Email Connector"), 'The second email account should not be on the page');
        Assert.IsFalse(EmailAccountsTestPage.GoToKey(ThirdAccountId, Enum::"Email Connector"::"Test Email Connector"), 'The third email account should not be on the page');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler,ChooseNewDefaultAccountCancelHandler')]
    procedure DeleteDefaultAccountPromptNewAccountCancelTest()
    var
        SecondAccount: Record "Email Account";
        ConnectorMock: Codeunit "Connector Mock";
        EmailAccountsSelectionMock: Codeunit "Email Accounts Selection Mock";
        EmailScenario: Codeunit "Email Scenario";
        EmailAccountsTestPage: TestPage "Email Accounts";
        FirstAccountId, ThirdAccountId : Guid;
    begin
        // [SCENARIO] When the default account is deleted, the user is prompted to choose a new default account but they cancel.
        PermissionsMock.Set('Email Admin');

        // [GIVEN] A connector is installed and three account are added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(FirstAccountId);
        ConnectorMock.AddAccount(SecondAccount);
        ConnectorMock.AddAccount(ThirdAccountId);

        // [GIVEN] The second account is set as default
        EmailScenario.SetDefaultEmailAccount(SecondAccount);

        // [WHEN] Open the Email Accounts page
        EmailAccountsTestPage.OpenView();

        // [WHEN] Select the default account
        BindSubscription(EmailAccountsSelectionMock);
        EmailAccountsSelectionMock.SelectAccount(SecondAccount."Account Id");

        // [WHEN] Delete action is invoked and the action is confirmed (see ConfirmYesHandler)
        AccountToSelect := ThirdAccountId; // The third account is selected as the new default account
        EmailAccountsTestPage.Delete.Invoke();

        // [THEN] The default account was deleted and there is no new default account
        Assert.IsTrue(EmailAccountsTestPage.GoToKey(FirstAccountId, Enum::"Email Connector"::"Test Email Connector"), 'The first email account should be on the page');
        Assert.IsFalse(GetDefaultFieldValueAsBoolean(EmailAccountsTestPage.DefaultField.Value), 'The third account should not be marked as default');

        Assert.IsFalse(EmailAccountsTestPage.GoToKey(SecondAccount."Account Id", Enum::"Email Connector"::"Test Email Connector"), 'The second email account should not be on the page');

        Assert.IsTrue(EmailAccountsTestPage.GoToKey(ThirdAccountId, Enum::"Email Connector"::"Test Email Connector"), 'The third email account should be on the page');
        Assert.IsFalse(GetDefaultFieldValueAsBoolean(EmailAccountsTestPage.DefaultField.Value), 'The third account should not be marked as default');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler,ChooseNewDefaultAccountHandler')]
    procedure DeleteDefaultAccountPromptNewAccountTest()
    var
        SecondAccount: Record "Email Account";
        ConnectorMock: Codeunit "Connector Mock";
        EmailAccountsSelectionMock: Codeunit "Email Accounts Selection Mock";
        EmailScenario: Codeunit "Email Scenario";
        EmailAccountsTestPage: TestPage "Email Accounts";
        FirstAccountId, ThirdAccountId : Guid;
    begin
        // [SCENARIO] When the default account is deleted, the user is prompted to choose a new default account
        PermissionsMock.Set('Email Admin');

        // [GIVEN] A connector is installed and three account are added
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(FirstAccountId);
        ConnectorMock.AddAccount(SecondAccount);
        ConnectorMock.AddAccount(ThirdAccountId);

        // [GIVEN] The second account is set as default
        EmailScenario.SetDefaultEmailAccount(SecondAccount);

        // [WHEN] Open the Email Accounts page
        EmailAccountsTestPage.OpenView();

        // [WHEN] Select the default account
        BindSubscription(EmailAccountsSelectionMock);
        EmailAccountsSelectionMock.SelectAccount(SecondAccount."Account Id");

        // [WHEN] Delete action is invoked and the action is confirmed (see ConfirmYesHandler)
        AccountToSelect := ThirdAccountId; // The third account is selected as the new default account
        EmailAccountsTestPage.Delete.Invoke();

        // [THEN] The second account is not on the page, the third account is set as default
        Assert.IsTrue(EmailAccountsTestPage.GoToKey(FirstAccountId, Enum::"Email Connector"::"Test Email Connector"), 'The first email account should be on the page');
        Assert.IsFalse(GetDefaultFieldValueAsBoolean(EmailAccountsTestPage.DefaultField.Value), 'The first account should not be marked as default');

        Assert.IsFalse(EmailAccountsTestPage.GoToKey(SecondAccount."Account Id", Enum::"Email Connector"::"Test Email Connector"), 'The second email account should not be on the page');

        Assert.IsTrue(EmailAccountsTestPage.GoToKey(ThirdAccountId, Enum::"Email Connector"::"Test Email Connector"), 'The third email account should be on the page');
        Assert.IsTrue(GetDefaultFieldValueAsBoolean(EmailAccountsTestPage.DefaultField.Value), 'The third account should be marked as default');
    end;


    [ModalPageHandler]
    procedure AddAccountModalPageHandler(var AccountWizzardTestPage: TestPage "Email Account Wizard")
    begin

    end;

    [PageHandler]
    procedure SentEmailsPageHandler(var SentEmailsPage: TestPage "Sent Emails")
    begin

    end;

    [ModalPageHandler]
    procedure ChooseAccountCancel(var AccountWizzardTestPage: TestPage "Email Account Wizard")
    begin

    end;

    [ModalPageHandler]
    procedure ChooseNewDefaultAccountCancelHandler(var AccountsPage: TestPage "Email Accounts")
    begin
        AccountsPage.Cancel().Invoke();
    end;


    [ModalPageHandler]
    procedure ChooseNewDefaultAccountHandler(var AccountsPage: TestPage "Email Accounts")
    begin
        AccountsPage.GoToKey(AccountToSelect, Enum::"Email Connector"::"Test Email Connector");
        AccountsPage.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [ConfirmHandler]
    procedure ConfirmNoHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := false;
    end;

    local procedure GetDefaultFieldValueAsBoolean(DefaultFieldValue: Text): Boolean
    begin
        exit(DefaultFieldValue = '✓');
    end;
}
