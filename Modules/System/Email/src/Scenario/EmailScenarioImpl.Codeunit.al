// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8892 "Email Scenario Impl."
{
    Access = Internal;
    Permissions = TableData "Email Scenario" = rimd;

    procedure GetEmailAccount(Scenario: Enum "Email Scenario"; var EmailAccount: Record "Email Account"): Boolean
    var
        EmailScenario: Record "Email Scenario";
        AllEmailAccounts: Record "Email Account";
        EmailAccounts: Codeunit "Email Account";
    begin
        EmailAccounts.GetAllAccounts(AllEmailAccounts);

        // Find the account for the provided scenario
        if EmailScenario.Get(Scenario) then
            if AllEmailAccounts.Get(EmailScenario."Account Id", EmailScenario.Connector) then begin
                EmailAccount := AllEmailAccounts;
                exit(true);
            end;

        // Fallback to the default account if the scenario isn't mapped or the mapped account doesn't exist
        if EmailScenario.Get(Enum::"Email Scenario"::Default) then
            if AllEmailAccounts.Get(EmailScenario."Account Id", EmailScenario.Connector) then begin
                EmailAccount := AllEmailAccounts;
                exit(true);
            end;

        exit(false);
    end;

    procedure SetEmailAccount(Scenario: Enum "Email Scenario"; EmailAccount: Record "Email Account")
    var
        EmailScenario: Record "Email Scenario";
    begin
        if not EmailScenario.Get(Scenario) then begin
            EmailScenario.Scenario := Scenario;
            EmailScenario.Insert();
        end;

        EmailScenario."Account Id" := EmailAccount."Account Id";
        EmailScenario.Connector := EmailAccount.Connector;

        EmailScenario.Modify();
    end;

    procedure UnassignScenario(Scenario: Enum "Email Scenario")
    var
        EmailScenario: Record "Email Scenario";
    begin
        if EmailScenario.Get(Scenario) then
            EmailScenario.Delete();
    end;

    /// <summary>
    /// Get a list of entries, representing a tree structure with email accounts and the scenarios, assigned to each accout.
    /// </summary>
    /// <example>
    /// Account sales@cronus.com has scenarios "Sales Quote" and "Sales Credit Memo" assigned.
    /// Account purchase@cronus.com has scenarios "Purchase Quote" and "Purchase Invoice" assigned.
    /// The result of calling the function will be:
    /// sales@cronus.com, "Sales Quote", "Sales Credit Memo", purchase@cronus.com, "Purchase Quote", "Purchase Invoice"
    /// </example>
    /// <param name="Result">A flatten tree structure representing the all the email accounts and the scenarios assigned to them.</param>
    procedure GetScenariosByEmailAccount(var Result: Record "Email Account Scenario")
    var
        EmailAccounts: Record "Email Account";
        EmailAccountScenarios: Record "Email Account Scenario";
        DefaultAccount: Record "Email Account";
        EmailAccount: Codeunit "Email Account";
        DisplayName: Text[2048];
        Position: Integer;
        Default: Boolean;
    begin
        Result.Reset();
        Result.DeleteAll();

        EmailAccount.GetAllAccounts(EmailAccounts);

        if not EmailAccounts.FindSet() then
            exit; // No accounts, nothing to do

        // The position is set in order to be able to properly sort the entries (by order of insertion)
        Position := 1;
        GetDefaultAccount(DefaultAccount);

        repeat
            Default := (EmailAccounts."Account Id" = DefaultAccount."Account Id") and (EmailAccounts.Connector = DefaultAccount.Connector);
            DisplayName := StrSubstNo(AccountDisplayLbl, EmailAccounts.Name, EmailAccounts."Email Address");

            // Add entry for the email account. Scenario is -1, because it isn't needed when displaying the email account.
            AddEntry(Result, Result.EntryType::Account, -1, EmailAccounts."Account Id", EmailAccounts.Connector, DisplayName, Default, Position);

            // Get the email scenarios assigned to the current email account, sorted by "Display Name"
            GetEmailScenariosForAccount(EmailAccounts, EmailAccountScenarios);

            if EmailAccountScenarios.FindSet() then
                repeat
                    // Add entry for every scenario that is assigned to the current email account
                    AddEntry(Result, EmailAccountScenarios.EntryType::Scenario, EmailAccountScenarios.Scenario, EmailAccountScenarios."Account Id", EmailAccountScenarios.Connector, EmailAccountScenarios."Display Name", false, Position);
                until EmailAccountScenarios.Next() = 0;
        until EmailAccounts.Next() = 0;

        // Order by position to show accurate results
        Result.SetCurrentKey(Position);
    end;

    local procedure GetEmailScenariosForAccount(EmailAccount: Record "Email Account"; var EmailAccountScenarios: Record "Email Account Scenario")
    var
        EmailScenarios: Record "Email Scenario";
        ValidEmailScenarios: DotNet Hashtable;
        IsScenarioValid: Boolean;
        Scenario: Integer;
    begin
        EmailAccountScenarios.Reset();
        EmailAccountScenarios.DeleteAll();

        // Get all email scenarios assigned to the email account
        EmailScenarios.SetRange("Account Id", EmailAccount."Account Id");
        EmailScenarios.SetRange(Connector, EmailAccount.Connector);

        if not EmailScenarios.FindSet() then
            exit;

        // Find all valid scenarios. Invalid scenario may occur if the extension that added them was removed.
        ValidEmailScenarios := ValidEmailScenarios.Hashtable();
        foreach Scenario in Enum::"Email Scenario".Ordinals() do
            ValidEmailScenarios.Add(Scenario, Scenario);

        // Convert Email Scenario-s to Email Account Scenario-s so they can be sorted by "Display Name"
        repeat
            IsScenarioValid := ValidEmailScenarios.Contains(EmailScenarios.Scenario.AsInteger());

            // Add entry for every scenario that exists and uses the email account. Skip the default scenario.
            if (EmailScenarios.Scenario <> Enum::"Email Scenario"::Default) and IsScenarioValid then begin
                EmailAccountScenarios.Scenario := EmailScenarios.Scenario.AsInteger();
                EmailAccountScenarios."Account Id" := EmailScenarios."Account Id";
                EmailAccountScenarios.Connector := EmailScenarios.Connector;
                EmailAccountScenarios."Display Name" := Format(EmailScenarios.Scenario);

                EmailAccountScenarios.Insert();
            end;
        until EmailScenarios.Next() = 0;

        EmailAccountScenarios.SetCurrentKey("Display Name"); // sort scenarios by "Display Name"
    end;

    local procedure AddEntry(var Result: Record "Email Account Scenario"; EntryType: Option; Scenario: Integer; AccountId: Guid; Connector: Enum "Email Connector"; DisplayName: Text[2048]; Default: Boolean; var Position: Integer)
    begin
        // Add entry to the result while maintaining the position so that the tree represents the data correctly
        Result.EntryType := EntryType;
        Result.Scenario := Scenario;
        Result."Account Id" := AccountId;
        Result.Connector := Connector;
        Result."Display Name" := DisplayName;
        Result.Default := Default;
        Result.Position := Position;

        Result.Insert();

        Position := Position + 1;
    end;

    procedure AddScenarios(EmailAccount: Record "Email Account Scenario"): Boolean
    var
        EmailScenario: Record "Email Scenario";
        SelectedScenarios: Record "Email Account Scenario";
        ScenariosForAccount: Page "Email Scenarios For Account";
    begin
        EmailAccountImpl.CheckPermissions();

        if EmailAccount.EntryType <> EmailAccount.EntryType::Account then // wrong entry, the entry should be of type "Account"
            exit;

        ScenariosForAccount.Caption := StrSubstNo(ScenariosForAccountCaptionTxt, EmailAccount."Display Name");
        ScenariosForAccount.LookupMode(true);
        ScenariosForAccount.SetRecord(EmailAccount);

        if ScenariosForAccount.RunModal() <> Action::LookupOK then
            exit(false);

        ScenariosForAccount.GetSelectedScenarios(SelectedScenarios);

        if not SelectedScenarios.FindSet() then
            exit(false);

        repeat
            if not EmailScenario.Get(SelectedScenarios.Scenario) then begin
                EmailScenario."Account Id" := EmailAccount."Account Id";
                EmailScenario.Connector := EmailAccount.Connector;
                EmailScenario.Scenario := Enum::"Email Scenario".FromInteger(SelectedScenarios.Scenario);

                EmailScenario.Insert();
            end else begin
                EmailScenario."Account Id" := EmailAccount."Account Id";
                EmailScenario.Connector := EmailAccount.Connector;

                EmailScenario.Modify();
            end;
        until SelectedScenarios.Next() = 0;

        exit(true);
    end;

    procedure GetAvailableScenariosForAccount(EmailAccount: Record "Email Account Scenario"; var EmailScenarios: Record "Email Account Scenario")
    var
        Scenario: Record "Email Scenario";
        CurrentScenario, i : Integer;
        IsAvailable: Boolean;
    begin
        EmailScenarios.Reset();
        EmailScenarios.DeleteAll();
        i := 1;

        foreach CurrentScenario in Enum::"Email Scenario".Ordinals() do begin
            Clear(Scenario);
            Scenario.SetRange("Account Id", EmailAccount."Account Id");
            Scenario.SetRange(Connector, EmailAccount.Connector);
            Scenario.SetRange(Scenario, CurrentScenario);

            // If the scenario isn't already connected to the email account, then it's available. Natually, we skip the default scenario
            IsAvailable := Scenario.IsEmpty() and (not (CurrentScenario = Enum::"Email Scenario"::Default.AsInteger()));

            if IsAvailable then begin
                EmailScenarios."Account Id" := EmailAccount."Account Id";
                EmailScenarios.Connector := EmailAccount.Connector;
                EmailScenarios.Scenario := CurrentScenario;
                EmailScenarios."Display Name" := Format(Enum::"Email Scenario".FromInteger(Enum::"Email Scenario".Ordinals().Get(i)));

                EmailScenarios.Insert();
            end;

            i := i + 1;
        end;
    end;

    procedure ChangeAccount(var EmailScenario: Record "Email Account Scenario"): Boolean
    var
        SelectedAccount: Record "Email Account";
        Scenario: Record "Email Scenario";
        EmailAccount: Codeunit "Email Account";
        AccountsPage: Page "Email Accounts";
    begin
        EmailAccountImpl.CheckPermissions();

        if not EmailScenario.FindSet() then
            exit(false);

        EmailAccount.GetAllAccounts(false, SelectedAccount);
        if SelectedAccount.Get(EmailScenario."Account Id", EmailScenario.Connector) then;

        AccountsPage.EnableLookupMode();
        AccountsPage.SetRecord(SelectedAccount);
        AccountsPage.Caption := ChangeEmailAccountForScenarioTxt;

        if AccountsPage.RunModal() <> Action::LookupOK then
            exit(false);

        AccountsPage.GetAccount(SelectedAccount);

        if IsNullGuid(SelectedAccount."Account Id") then // defensive check, no account was selected
            exit;

        repeat
            if Scenario.Get(EmailScenario.Scenario) then begin
                Scenario."Account Id" := SelectedAccount."Account Id";
                Scenario.Connector := SelectedAccount.Connector;

                Scenario.Modify();
            end;
        until EmailScenario.Next() = 0;

        exit(true);
    end;

    procedure DeleteScenario(var EmailScenario: Record "Email Account Scenario"): Boolean
    var
        Scenario: Record "Email Scenario";
    begin
        EmailAccountImpl.CheckPermissions();

        if not EmailScenario.FindSet() then
            exit(false);

        repeat
            if EmailScenario.EntryType = EmailScenario.EntryType::Scenario then begin
                Scenario.SetRange(Scenario, EmailScenario.Scenario);
                Scenario.SetRange("Account Id", EmailScenario."Account Id");
                Scenario.SetRange(Connector, EmailScenario.Connector);

                Scenario.DeleteAll();
            end;
        until EmailScenario.Next() = 0;

        exit(true);
    end;

    local procedure GetDefaultAccount(var EmailAccount: Record "Email Account")
    var
        Scenario: Record "Email Scenario";
    begin
        if not Scenario.Get(Enum::"Email Scenario"::Default) then
            exit;

        EmailAccount."Account Id" := Scenario."Account Id";
        EmailAccount.Connector := Scenario.Connector;
    end;

    var
        EmailAccountImpl: Codeunit "Email Account Impl.";
        AccountDisplayLbl: Label '%1 (%2)', Locked = true;
        ChangeEmailAccountForScenarioTxt: Label 'Change e-mail account used for the selected scenarios';
        ScenariosForAccountCaptionTxt: Label 'Assign scenarios to account %1', Comment = '%1 = the name of the e-mail accout, e.g. Notification Account (notification@cronus.com)';
}