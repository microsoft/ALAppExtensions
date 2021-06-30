// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 134695 "Email Scenario Page Test"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";
        ConnectorMock: Codeunit "Connector Mock";
        EmailScenarioMock: Codeunit "Email Scenario Mock";
        PermissionsMock: Codeunit "Permissions Mock";
        DisplayNameTxt: Label '%1 (%2)', Locked = true;


    [Test]
    [Scope('OnPrem')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure PageOpenNoData()
    var
        EmailScenarioPage: TestPage "Email Scenario Setup";
    begin
        // [Scenario] The "Email Scenario Setup" shows no data when there are no email accounts
        PermissionsMock.Set('Email Admin');

        // [Given] No email account is registered.
        ConnectorMock.Initialize();

        // [When] Opening the the page
        EmailScenarioPage.Trap();
        EmailScenarioPage.OpenView();

        // [Then] There is no data on the page
        Assert.IsFalse(EmailScenarioPage.First(), 'There should be no data on the page');
    end;

    [Test]
    [Scope('OnPrem')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure PageOpenOneEntryTest()
    var
        EmailAccount: Record "Email Account";
        EmailScenarioPage: TestPage "Email Scenario Setup";
    begin
        // [Scenario] The "Email Scenario Setup" shows one entry when there is only one email account and no scenarios
        PermissionsMock.Set('Email Admin');

        // [Given] One email account is registered.
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(EmailAccount);

        // [When] Opening the the page
        EmailScenarioPage.Trap();
        EmailScenarioPage.OpenView();

        // [Then] There is one entry on the page  and it is not set as default
        Assert.IsTrue(EmailScenarioPage.First(), 'There should be an entry on the page');

        // Properties are as expected
        Assert.AreEqual(StrSubstNo(DisplayNameTxt, EmailAccount.Name, EmailAccount."Email Address"), EmailScenarioPage.Name.Value, 'Wrong entry name');
        Assert.IsFalse(GetDefaultFieldValueAsBoolean(EmailScenarioPage.Default.Value), 'The account should not be marked as default');

        // Actions visibility is as expected
        Assert.IsTrue(EmailScenarioPage.AddScenario.Visible(), 'The action "Add Scenarios" should be visible');
        Assert.IsFalse(EmailScenarioPage.ChangeAccount.Visible(), 'The action "Change Accounts" should not be visible');
        Assert.IsFalse(EmailScenarioPage.Unassign.Visible(), 'The action "Unassign" should not be visible');

        Assert.IsFalse(EmailScenarioPage.Next(), 'There should not be another entry on the page');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PageOpenOneDefaultEntryTest()
    var
        EmailAccount: Record "Email Account";
        EmailScenarioPage: TestPage "Email Scenario Setup";
    begin
        // [Scenario] The "Email Scenario Setup" shows one entry when there is only one email account and no scenarios
        PermissionsMock.Set('Email Admin');

        // [Given] One email account is registered and it's set as default.
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(EmailAccount);

        EmailScenarioMock.DeleteAllMappings();
        EmailScenarioMock.AddMapping(Enum::"Email Scenario"::Default, EmailAccount."Account Id", EmailAccount.Connector);

        // [When] Opening the the page
        EmailScenarioPage.Trap();
        EmailScenarioPage.OpenView();

        // [Then] There is one entry on the page and it is set as default
        Assert.IsTrue(EmailScenarioPage.First(), 'There should be an entry on the page');

        // Properties are as expected
        Assert.AreEqual(StrSubstNo(DisplayNameTxt, EmailAccount.Name, EmailAccount."Email Address"), EmailScenarioPage.Name.Value, 'Wrong entry name');
        Assert.IsTrue(GetDefaultFieldValueAsBoolean(EmailScenarioPage.Default.Value), 'The account should be marked as default');

        // Actions visibility is as expected
        Assert.IsTrue(EmailScenarioPage.AddScenario.Visible(), 'The action "Add Scenarios" should be visible');
        Assert.IsFalse(EmailScenarioPage.ChangeAccount.Visible(), 'The action "Change Accounts" should not be visible');
        Assert.IsFalse(EmailScenarioPage.Unassign.Visible(), 'The action "Unassign" should not be visible');

        Assert.IsFalse(EmailScenarioPage.Next(), 'There should not be another entry on the page');
    end;


    [Test]
    [Scope('OnPrem')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure PageOpenOneAcountsTwoScenariosTest()
    var
        EmailAccount: Record "Email Account";
        EmailScenarioPage: TestPage "Email Scenario Setup";
    begin
        // [Scenario] Having one default account with a non-default scenario assigned displays propely on "Email Scenario Setup"
        PermissionsMock.Set('Email Admin');

        // [Given] One email account is registered and it's set as default.
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(EmailAccount);

        EmailScenarioMock.DeleteAllMappings();
        EmailScenarioMock.AddMapping(Enum::"Email Scenario"::Default, EmailAccount."Account Id", EmailAccount.Connector);
        EmailScenarioMock.AddMapping(Enum::"Email Scenario"::"Test Email Scenario", EmailAccount."Account Id", EmailAccount.Connector);

        // [When] Opening the the page
        EmailScenarioPage.Trap();
        EmailScenarioPage.OpenView();

        // [Then] There is one entry on the page and it is set as default. There's another entry for the other assigned scenario
        Assert.IsTrue(EmailScenarioPage.First(), 'There should be data on the page');

        // Properties are as expected
        Assert.AreEqual(StrSubstNo(DisplayNameTxt, EmailAccount.Name, EmailAccount."Email Address"), EmailScenarioPage.Name.Value, 'Wrong entry name');
        Assert.IsTrue(GetDefaultFieldValueAsBoolean(EmailScenarioPage.Default.Value), 'The account should be marked as default');

        // Actions visibility is as expected
        Assert.IsTrue(EmailScenarioPage.AddScenario.Visible(), 'The action "Add Scenarios" should be visible');
        Assert.IsFalse(EmailScenarioPage.ChangeAccount.Visible(), 'The action "Change Accounts" should not be visible');
        Assert.IsFalse(EmailScenarioPage.Unassign.Visible(), 'The action "Unassign" should not be visible');

        EmailScenarioPage.Expand(true);
        Assert.IsTrue(EmailScenarioPage.Next(), 'There should be another entry on the page');

        // Properies are as expected
        Assert.AreEqual(Format(Enum::"Email Scenario"::"Test Email Scenario"), EmailScenarioPage.Name.Value, 'Wrong entry name');
        Assert.IsFalse(GetDefaultFieldValueAsBoolean(EmailScenarioPage.Default.Value), 'The account should not be marked as default');

        // Actions visibility is as expected
        Assert.IsFalse(EmailScenarioPage.AddScenario.Visible(), 'The action "Add Scenarios" should be visible');
        Assert.IsTrue(EmailScenarioPage.ChangeAccount.Visible(), 'The action "Change Accounts" should not be visible');
        Assert.IsTrue(EmailScenarioPage.Unassign.Visible(), 'The action "Unassign" should not be visible');
    end;

    [Test]
    [Scope('OnPrem')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure PageOpenTwoAcountsTwoScenariosTest()
    var
        FirstEmailAccount, SecondEmailAccount : Record "Email Account";
        EmailScenarioPage: TestPage "Email Scenario Setup";
    begin
        // [Scenario] The "Email Scenario Setup" shows three entries when there are two accounts - one with the default scenario and one with a non-default scenario
        PermissionsMock.Set('Email Admin');
    
        // [Given] Two email accounts are registered. One is set as default.
        ConnectorMock.Initialize();
        ConnectorMock.AddAccount(FirstEmailAccount);
        ConnectorMock.AddAccount(SecondEmailAccount);

        EmailScenarioMock.DeleteAllMappings();
        EmailScenarioMock.AddMapping(Enum::"Email Scenario"::Default, FirstEmailAccount."Account Id", FirstEmailAccount.Connector);
        EmailScenarioMock.AddMapping(Enum::"Email Scenario"::"Test Email Scenario", SecondEmailAccount."Account Id", SecondEmailAccount.Connector);

        // [When] Opening the the page
        EmailScenarioPage.Trap();
        EmailScenarioPage.OpenView();

        // [Then] There are three entries on the page. One is set as dedault
        Assert.IsTrue(EmailScenarioPage.GoToKey(-1, FirstEmailAccount."Account Id", FirstEmailAccount.Connector), 'There should be data on the page');
        Assert.AreEqual(StrSubstNo(DisplayNameTxt, FirstEmailAccount.Name, FirstEmailAccount."Email Address"), EmailScenarioPage.Name.Value, 'Wrong first entry name');
        Assert.IsTrue(GetDefaultFieldValueAsBoolean(EmailScenarioPage.Default.Value), 'The account should be marked as default');

        Assert.IsTrue(EmailScenarioPage.GoToKey(-1, SecondEmailAccount."Account Id", SecondEmailAccount.Connector), 'There should be another entry on the page');
        Assert.AreEqual(StrSubstNo(DisplayNameTxt, SecondEmailAccount.Name, SecondEmailAccount."Email Address"), EmailScenarioPage.Name.Value, 'Wrong second entry name');
        Assert.IsFalse(GetDefaultFieldValueAsBoolean(EmailScenarioPage.Default.Value), 'The account should not be marked as default');

        EmailScenarioPage.Expand(true);
        Assert.IsTrue(EmailScenarioPage.Next(), 'There should be a third entry on the page');
        Assert.AreEqual(Format(Enum::"Email Scenario"::"Test Email Scenario"), EmailScenarioPage.Name.Value, 'Wrong third entry name');
        Assert.IsFalse(GetDefaultFieldValueAsBoolean(EmailScenarioPage.Default.Value), 'The account should not be marked as default');
    end;

    local procedure GetDefaultFieldValueAsBoolean(DefaultFieldValue: Text): Boolean
    begin
        exit(DefaultFieldValue = '✓');
    end;
}