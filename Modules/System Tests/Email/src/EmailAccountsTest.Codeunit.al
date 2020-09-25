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
        AccountNameLbl: Label '%1 (%2)';

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

        // [When] The accounts page is open
        AccountsPage.OpenView();

        // [Then] The email entry is visible on the page
        Assert.IsTrue(AccountsPage.GoToKey(EmailAccount."Account Id"), 'The email account should be on the page');

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

        // [When] The accounts page is open
        AccountsPage.OpenView();

        // [Then] The email entries are visible on the page
        Assert.IsTrue(AccountsPage.GoToKey(FirstEmailAccount."Account Id"), 'The first email account should be on the page');
        Assert.AreEqual(FirstEmailAccount."Email Address", Format(AccountsPage.EmailAddress), 'The first email address on the page is wrong');
        Assert.AreEqual(FirstEmailAccount.Name, Format(AccountsPage.NameField), 'The first account name on the page is wrong');

        Assert.IsTrue(AccountsPage.GoToKey(SecondEmailAccount."Account Id"), 'The second email account should be on the page');
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
        ConnectorMock.Initialize();

        // [WHEN] The AddAccount action is invoked
        AccountWizardPage.Trap();
        Page.Run(Page::"Email Account Wizard");

        // [THEN] The welcome screen is shown and the test connector is shown
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

        // [WHEN] The Send Email action is invoked
        Accounts.OpenView();
        Accounts.GoToKey(TempAccount."Account Id");
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

        // [WHEN] Calling IsAnyAccountRegistered
        // [THEN] it evaluates to false
        Assert.IsFalse(EmailAccount.IsAnyAccountRegistered(), 'There should be no registered accounts');

        // [WHEN] An email account is added
        ConnectorMock.AddAccount(AccountId);

        // [WHEN] Calling IsAnyAccountRegistered
        // [THEN] it evaluates to true
        Assert.IsTrue(EmailAccount.IsAnyAccountRegistered(), 'There should be a registered account');
    end;

    [ModalPageHandler]
    procedure AddAccountModalPageHandler(var AccountWizzardTestPage: TestPage "Email Account Wizard")
    begin

    end;

    [PageHandler]
    procedure SentEmailsPageHandler(var SentEmailsPage: TestPage "Sent Emails")
    begin

    end;

}
