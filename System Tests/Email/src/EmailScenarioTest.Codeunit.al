// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 134693 "Email Scenario Test"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";
        Any: Codeunit Any;
        ConnectorMock: Codeunit "Connector Mock";
        EmailScenarioMock: Codeunit "Email Scenario Mock";
        EmailScenario: Codeunit "Email Scenario";

    [Test]
    [Scope('OnPrem')]
    procedure GetEmailAccountScenarioNotExistsTest()
    var
        Account: Record "Email Account";
    begin
        // [Scenario] When the email scenario isn't mapped an email account, GetEmailAccount returns false

        // [Given] No mappings between emails and scenarios
        Initialize();

        // [When] calling GetEmailAccount
        // [Then] false is retuned
        Assert.IsFalse(EmailScenario.GetEmailAccount(Enum::"Email Scenario"::"Test Email Scenario", Account), 'There should not be any account');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetEmailAccountNotExistsTest()
    var
        Account: Record "Email Account";
        NonExistentAccountId: Guid;
    begin
        // [Scenario] When the email scenario is mapped non-existing email account, GetEmailAccount returns false

        // [Given] An email scenario pointing to a non-existing email account
        Initialize();
        NonExistentAccountId := Any.GuidValue();
        EmailScenarioMock.AddMapping(Enum::"Email Scenario"::"Test Email Scenario", NonExistentAccountId, Enum::"Email Connector"::"Test Email Connector");

        // [When] calling GetEmailAccount
        // [Then] false is retuned
        Assert.IsFalse(EmailScenario.GetEmailAccount(Enum::"Email Scenario"::"Test Email Scenario", Account), 'There should not be any account mapped to the scenario');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetEmailAccountDefaultNotExistsTest()
    var
        Account: Record "Email Account";
        NonExistentAccountId: Guid;
    begin
        // [Scenario] When the default email scenario is mapped to a non-existing email account, GetEmailAccount returns false

        // [Given] An email scenario isn't mapped to a account and the default scenario is mapped to a non-existing account
        Initialize();
        NonExistentAccountId := Any.GuidValue();
        EmailScenarioMock.AddMapping(Enum::"Email Scenario"::Default, NonExistentAccountId, Enum::"Email Connector"::"Test Email Connector");

        // [When] calling GetEmailAccount
        // [Then] false is retuned
        Assert.IsFalse(EmailScenario.GetEmailAccount(Enum::"Email Scenario"::"Test Email Scenario", Account), 'There should not be any account mapped to the scenario');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetEmailAccountDefaultExistsTest()
    var
        Account: Record "Email Account";
        AccountId: Guid;
    begin
        // [Scenario] When the default email scenario is mapped to an existing email account, GetEmailAccount returns that account

        // [Given] An email scenario isn't mapped to an account and the default scenario is mapped to an existing account
        Initialize();
        ConnectorMock.AddAccount(AccountId);
        EmailScenarioMock.AddMapping(Enum::"Email Scenario"::Default, AccountId, Enum::"Email Connector"::"Test Email Connector");

        // [When] calling GetEmailAccount
        // [Then] true is retuned and the email account is as expected
        Assert.IsTrue(EmailScenario.GetEmailAccount(Enum::"Email Scenario"::"Test Email Scenario", Account), 'There should be an email account');
        Assert.AreEqual(AccountId, Account."Account Id", 'Wrong account ID');
        Assert.AreEqual(Enum::"Email Connector"::"Test Email Connector", Account.Connector, 'Wrong connector');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetEmailAccountExistsTest()
    var
        Account: Record "Email Account";
        AccountId: Guid;
    begin
        // [Scenario] When the email scenario is mapped to an existing email account, GetEmailAccount returns that account

        // [Given] An email scenario is mapped to an account
        Initialize();
        ConnectorMock.AddAccount(AccountId);
        EmailScenarioMock.AddMapping(Enum::"Email Scenario"::"Test Email Scenario", AccountId, Enum::"Email Connector"::"Test Email Connector");

        // [When] calling GetEmailAccount
        // [Then] true is retuned and the email account is as expected
        Assert.IsTrue(EmailScenario.GetEmailAccount(Enum::"Email Scenario"::"Test Email Scenario", Account), 'There should be an email account');
        Assert.AreEqual(AccountId, Account."Account Id", 'Wrong account ID');
        Assert.AreEqual(Enum::"Email Connector"::"Test Email Connector", Account.Connector, 'Wrong connector');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetEmailAccountDefaultDifferentTest()
    var
        Account: Record "Email Account";
        AccountId: Guid;
        DefaultAccountId: Guid;
    begin
        // [Scenario] When the email scenario and the default scenarion are mapped to different email accounts, GetEmailAccount returns the corrent account

        // [Given] An email scenario is mapped to an account, the default scenarion is mapped to another account
        Initialize();
        ConnectorMock.AddAccount(AccountId);
        ConnectorMock.AddAccount(DefaultAccountId);
        EmailScenarioMock.AddMapping(Enum::"Email Scenario"::"Test Email Scenario", AccountId, Enum::"Email Connector"::"Test Email Connector");
        EmailScenarioMock.AddMapping(Enum::"Email Scenario"::Default, DefaultAccountId, Enum::"Email Connector"::"Test Email Connector");

        // [When] calling GetEmailAccount
        // [Then] true is retuned and the email accounts are as expected
        Assert.IsTrue(EmailScenario.GetEmailAccount(Enum::"Email Scenario"::"Test Email Scenario", Account), 'There should be an email account');
        Assert.AreEqual(AccountId, Account."Account Id", 'Wrong account ID');
        Assert.AreEqual(Enum::"Email Connector"::"Test Email Connector", Account.Connector, 'Wrong connector');

        Assert.IsTrue(EmailScenario.GetEmailAccount(Enum::"Email Scenario"::Default, Account), 'There should be an email account');
        Assert.AreEqual(DefaultAccountId, Account."Account Id", 'Wrong account ID');
        Assert.AreEqual(Enum::"Email Connector"::"Test Email Connector", Account.Connector, 'Wrong connector');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetEmailAccountDefaultDifferentNotExistTest()
    var
        Account: Record "Email Account";
        NonExistingAccountId: Guid;
        DefaultAccountId: Guid;
    begin
        // [Scenario] When the email scenario is mapped to a non-existing account and the default scenarion is mapped to an existing accounts, GetEmailAccount returns the corrent account

        // [Given] An email scenario is mapped to a non-exisitng account, the default scenarion is mapped to an existing account
        Initialize();
        ConnectorMock.AddAccount(DefaultAccountId);
        NonExistingAccountId := Any.GuidValue();
        EmailScenarioMock.AddMapping(Enum::"Email Scenario"::"Test Email Scenario", NonExistingAccountId, Enum::"Email Connector"::"Test Email Connector");
        EmailScenarioMock.AddMapping(Enum::"Email Scenario"::Default, DefaultAccountId, Enum::"Email Connector"::"Test Email Connector");

        // [When] calling GetEmailAccount
        // [Then] true is retuned and the email accounts are as expected
        Assert.IsTrue(EmailScenario.GetEmailAccount(Enum::"Email Scenario"::"Test Email Scenario", Account), 'There should be an email account');
        Assert.AreEqual(DefaultAccountId, Account."Account Id", 'Wrong account ID');
        Assert.AreEqual(Enum::"Email Connector"::"Test Email Connector", Account.Connector, 'Wrong connector');

        Assert.IsTrue(EmailScenario.GetEmailAccount(Enum::"Email Scenario"::Default, Account), 'There should be an email account for the default scenario');
        Assert.AreEqual(DefaultAccountId, Account."Account Id", 'Wrong default account ID');
        Assert.AreEqual(Enum::"Email Connector"::"Test Email Connector", Account.Connector, 'Wrong default account connector');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetEmailAccountDifferentDefaultNotExistTest()
    var
        Account: Record "Email Account";
        AccountId: Guid;
        DefaultAccountId: Guid;
    begin
        // [Scenario] When the email scenario is mapped to an existing account and the default scenarion is mapped to a non-existing accounts, GetEmailAccount returns the corrent account

        // [Given] An email scenario is mapped to an exisitng account, the default scenarion is mapped to a non-existing account
        Initialize();
        ConnectorMock.AddAccount(AccountId);
        DefaultAccountId := Any.GuidValue();
        EmailScenarioMock.AddMapping(Enum::"Email Scenario"::"Test Email Scenario", AccountId, Enum::"Email Connector"::"Test Email Connector");
        EmailScenarioMock.AddMapping(Enum::"Email Scenario"::Default, DefaultAccountId, Enum::"Email Connector"::"Test Email Connector");

        // [When] calling GetEmailAccount
        // [Then] true is retuned and the email account is as expected
        Assert.IsTrue(EmailScenario.GetEmailAccount(Enum::"Email Scenario"::"Test Email Scenario", Account), 'There should be an email account');
        Assert.AreEqual(AccountId, Account."Account Id", 'Wrong account ID');
        Assert.AreEqual(Enum::"Email Connector"::"Test Email Connector", Account.Connector, 'Wrong connector');

        // [Then] there's no account for the default email scenario
        Assert.IsFalse(EmailScenario.GetEmailAccount(Enum::"Email Scenario"::Default, Account), 'There should not be an email account for the default scenario');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SetEmailAccountTest()
    var
        Account: Record "Email Account";
        AnotherAccount: Record "Email Account";
        EmailScenarios: Record "Email Scenario";
        Scenario: Enum "Email Scenario";
    begin
        // [Scenario] When SetAccount is called, the entry in the database is as expected

        // [Given] A random email account
        Initialize();
        Account."Account Id" := Any.GuidValue();
        Account.Connector := Enum::"Email Connector"::"Test Email Connector";
        Scenario := Scenario::Default;

        // [When] Setting the email account for the scenario
        EmailScenario.SetEmailAccount(Scenario, Account);

        // [Then] The scenario exists and is as expected
        Assert.IsTrue(EmailScenarios.Get(Scenario), 'The email scenario should exist');
        Assert.AreEqual(EmailScenarios."Account Id", Account."Account Id", 'Wrong accound ID');
        Assert.AreEqual(EmailScenarios.Connector, Account.Connector, 'Wrong connector');

        AnotherAccount."Account Id" := Any.GuidValue();
        AnotherAccount.Connector := Enum::"Email Connector"::"Test Email Connector";

        // [When] Setting overwting the email account for the scenario
        EmailScenario.SetEmailAccount(Scenario, AnotherAccount);

        // [Then] The scenario still exists and is as expected
        Assert.IsTrue(EmailScenarios.Get(Scenario), 'The email scenario should exist');
        Assert.AreEqual(EmailScenarios."Account Id", AnotherAccount."Account Id", 'Wrong accound ID');
        Assert.AreEqual(EmailScenarios.Connector, AnotherAccount.Connector, 'Wrong connector');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UnassignScenarioTest()
    var
        Account: Record "Email Account";
        DefaultAccount: Record "Email Account";
        ResultAccount: Record "Email Account";
    begin
        // [Scenario] When unassigning a scenario then it falls back to the default account.

        // [Given] Two accounts, one default and one not 
        Initialize();
        ConnectorMock.AddAccount(Account);
        ConnectorMock.AddAccount(DefaultAccount);
        EmailScenario.SetDefaultEmailAccount(DefaultAccount);
        EmailScenario.SetEmailAccount(Enum::"Email Scenario"::"Test Email Scenario", Account);

        // mid-test verification
        EmailScenario.GetEmailAccount(Enum::"Email Scenario"::"Test Email Scenario", ResultAccount);
        Assert.AreEqual(Account."Account Id", ResultAccount."Account Id", 'Wrong account');

        // [When] Unassign the email scenario
        EmailScenario.UnassignScenario(Enum::"Email Scenario"::"Test Email Scenario");

        // [Then] The default account is returned for that account
        EmailScenario.GetEmailAccount(Enum::"Email Scenario"::"Test Email Scenario", ResultAccount);
        Assert.AreEqual(DefaultAccount."Account Id", ResultAccount."Account Id", 'The default account should have been returned');
    end;

    local procedure Initialize()
    begin
        EmailScenarioMock.DeleteAllMappings();
    end;
}