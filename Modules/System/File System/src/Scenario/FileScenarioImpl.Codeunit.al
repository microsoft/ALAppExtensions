// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.FileSystem;

using System;

codeunit 70003 "File Scenario Impl."
{
    Access = Internal;
    InherentPermissions = X;
    InherentEntitlements = X;
    Permissions = TableData "File Scenario" = rimd;

    procedure GetFileAccount(Scenario: Enum "File Scenario"; var FileAccount: Record "File Account"): Boolean
    var
        FileScenario: Record "File Scenario";
        AllFileAccounts: Record "File Account";
        FileAccounts: Codeunit "File Account";
    begin
        FileAccounts.GetAllAccounts(AllFileAccounts);

        // Find the account for the provided scenario
        if FileScenario.Get(Scenario) then
            if AllFileAccounts.Get(FileScenario."Account Id", FileScenario.Connector) then begin
                FileAccount := AllFileAccounts;
                exit(true);
            end;

        // Fallback to the default account if the scenario isn't mapped or the mapped account doesn't exist
        if FileScenario.Get(Enum::"File Scenario"::Default) then
            if AllFileAccounts.Get(FileScenario."Account Id", FileScenario.Connector) then begin
                FileAccount := AllFileAccounts;
                exit(true);
            end;

        exit(false);
    end;

    procedure SetFileAccount(Scenario: Enum "File Scenario"; FileAccount: Record "File Account")
    var
        FileScenario: Record "File Scenario";
    begin
        if not FileScenario.Get(Scenario) then begin
            FileScenario.Scenario := Scenario;
            FileScenario.Insert();
        end;

        FileScenario."Account Id" := FileAccount."Account Id";
        FileScenario.Connector := FileAccount.Connector;

        FileScenario.Modify();
    end;

    procedure UnassignScenario(Scenario: Enum "File Scenario")
    var
        FileScenario: Record "File Scenario";
    begin
        if FileScenario.Get(Scenario) then
            FileScenario.Delete();
    end;

    /// <summary>
    /// Get a list of entries, representing a tree structure with file accounts and the scenarios, assigned to each accout.
    /// </summary>
    /// <example>
    /// Account sales@cronus.com has scenarios "Sales Quote" and "Sales Credit Memo" assigned.
    /// Account purchase@cronus.com has scenarios "Purchase Quote" and "Purchase Invoice" assigned.
    /// The result of calling the function will be:
    /// sales@cronus.com, "Sales Quote", "Sales Credit Memo", purchase@cronus.com, "Purchase Quote", "Purchase Invoice"
    /// </example>
    /// <param name="Result">A flatten tree structure representing the all the file accounts and the scenarios assigned to them.</param>
    procedure GetScenariosByFileAccount(var Result: Record "File Account Scenario")
    var
        FileAccounts: Record "File Account";
        FileAccountScenarios: Record "File Account Scenario";
        DefaultAccount: Record "File Account";
        FileAccount: Codeunit "File Account";
        DisplayName: Text[2048];
        Position: Integer;
        Default: Boolean;
    begin
        Result.Reset();
        Result.DeleteAll();

        FileAccount.GetAllAccounts(FileAccounts);

        if not FileAccounts.FindSet() then
            exit; // No accounts, nothing to do

        // The position is set in order to be able to properly sort the entries (by order of insertion)
        Position := 1;
        GetDefaultAccount(DefaultAccount);

        repeat
            Default := (FileAccounts."Account Id" = DefaultAccount."Account Id") and (FileAccounts.Connector = DefaultAccount.Connector);
            DisplayName := FileAccounts.Name;

            // Add entry for the file account. Scenario is -1, because it isn't needed when displaying the file account.
            AddEntry(Result, Result.EntryType::Account, -1, FileAccounts."Account Id", FileAccounts.Connector, DisplayName, Default, Position);

            // Get the file scenarios assigned to the current file account, sorted by "Display Name"
            GetFileScenariosForAccount(FileAccounts, FileAccountScenarios);

            if FileAccountScenarios.FindSet() then
                repeat
                    // Add entry for every scenario that is assigned to the current file account
                    AddEntry(Result, FileAccountScenarios.EntryType::Scenario, FileAccountScenarios.Scenario, FileAccountScenarios."Account Id", FileAccountScenarios.Connector, FileAccountScenarios."Display Name", false, Position);
                until FileAccountScenarios.Next() = 0;
        until FileAccounts.Next() = 0;

        // Order by position to show accurate results
        Result.SetCurrentKey(Position);
    end;

    local procedure GetFileScenariosForAccount(FileAccount: Record "File Account"; var FileAccountScenarios: Record "File Account Scenario")
    var
        FileScenarios: Record "File Scenario";
        ValidFileScenarios: DotNet Hashtable;
        IsScenarioValid: Boolean;
        Scenario: Integer;
    begin
        FileAccountScenarios.Reset();
        FileAccountScenarios.DeleteAll();

        // Get all file scenarios assigned to the file account
        FileScenarios.SetRange("Account Id", FileAccount."Account Id");
        FileScenarios.SetRange(Connector, FileAccount.Connector);

        if not FileScenarios.FindSet() then
            exit;

        // Find all valid scenarios. Invalid scenario may occur if the extension that added them was removed.
        ValidFileScenarios := ValidFileScenarios.Hashtable();
        foreach Scenario in Enum::"File Scenario".Ordinals() do
            ValidFileScenarios.Add(Scenario, Scenario);

        // Convert File Scenario-s to File Account Scenario-s so they can be sorted by "Display Name"
        repeat
            IsScenarioValid := ValidFileScenarios.Contains(FileScenarios.Scenario.AsInteger());

            // Add entry for every scenario that exists and uses the file account. Skip the default scenario.
            if (FileScenarios.Scenario <> Enum::"File Scenario"::Default) and IsScenarioValid then begin
                FileAccountScenarios.Scenario := FileScenarios.Scenario.AsInteger();
                FileAccountScenarios."Account Id" := FileScenarios."Account Id";
                FileAccountScenarios.Connector := FileScenarios.Connector;
                FileAccountScenarios."Display Name" := Format(FileScenarios.Scenario);

                FileAccountScenarios.Insert();
            end;
        until FileScenarios.Next() = 0;

        FileAccountScenarios.SetCurrentKey("Display Name"); // sort scenarios by "Display Name"
    end;

    local procedure AddEntry(var Result: Record "File Account Scenario"; EntryType: Option; Scenario: Integer; AccountId: Guid; Connector: Enum "File System Connector"; DisplayName: Text[2048]; Default: Boolean; var Position: Integer)
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

    procedure AddScenarios(FileAccount: Record "File Account Scenario"): Boolean
    var
        FileScenario: Record "File Scenario";
        SelectedScenarios: Record "File Account Scenario";
        ScenariosForAccount: Page "File Scenarios For Account";
    begin
        FileAccountImpl.CheckPermissions();

        if FileAccount.EntryType <> FileAccount.EntryType::Account then // wrong entry, the entry should be of type "Account"
            exit;

        ScenariosForAccount.Caption := StrSubstNo(ScenariosForAccountCaptionTxt, FileAccount."Display Name");
        ScenariosForAccount.LookupMode(true);
        ScenariosForAccount.SetRecord(FileAccount);

        if ScenariosForAccount.RunModal() <> Action::LookupOK then
            exit(false);

        ScenariosForAccount.GetSelectedScenarios(SelectedScenarios);

        if not SelectedScenarios.FindSet() then
            exit(false);

        repeat
            if not FileScenario.Get(SelectedScenarios.Scenario) then begin
                FileScenario."Account Id" := FileAccount."Account Id";
                FileScenario.Connector := FileAccount.Connector;
                FileScenario.Scenario := Enum::"File Scenario".FromInteger(SelectedScenarios.Scenario);

                FileScenario.Insert();
            end else begin
                FileScenario."Account Id" := FileAccount."Account Id";
                FileScenario.Connector := FileAccount.Connector;

                FileScenario.Modify();
            end;
        until SelectedScenarios.Next() = 0;

        exit(true);
    end;

    procedure GetAvailableScenariosForAccount(FileAccount: Record "File Account Scenario"; var FileScenarios: Record "File Account Scenario")
    var
        Scenario: Record "File Scenario";
        FileScenario: Codeunit "File Scenario";
        CurrentScenario, i : Integer;
        IsAvailable: Boolean;
    begin
        FileScenarios.Reset();
        FileScenarios.DeleteAll();
        i := 1;

        foreach CurrentScenario in Enum::"File Scenario".Ordinals() do begin
            Clear(Scenario);
            Scenario.SetRange("Account Id", FileAccount."Account Id");
            Scenario.SetRange(Connector, FileAccount.Connector);
            Scenario.SetRange(Scenario, CurrentScenario);

            // If the scenario isn't already connected to the file account, then it's available. Natually, we skip the default scenario
            IsAvailable := Scenario.IsEmpty() and (not (CurrentScenario = Enum::"File Scenario"::Default.AsInteger()));

            // If the scenario is available, allow partner to determine if it should be shown
            if IsAvailable then
                FileScenario.OnBeforeInsertAvailableFileScenario(Enum::"File Scenario".FromInteger(CurrentScenario), IsAvailable);

            if IsAvailable then begin
                FileScenarios."Account Id" := FileAccount."Account Id";
                FileScenarios.Connector := FileAccount.Connector;
                FileScenarios.Scenario := CurrentScenario;
                FileScenarios."Display Name" := Format(Enum::"File Scenario".FromInteger(Enum::"File Scenario".Ordinals().Get(i)));

                FileScenarios.Insert();
            end;

            i := i + 1;
        end;
    end;

    procedure ChangeAccount(var FileScenario: Record "File Account Scenario"): Boolean
    var
        SelectedAccount: Record "File Account";
        Scenario: Record "File Scenario";
        FileAccount: Codeunit "File Account";
        AccountsPage: Page "File Accounts";
    begin
        FileAccountImpl.CheckPermissions();

        if not FileScenario.FindSet() then
            exit(false);

        FileAccount.GetAllAccounts(false, SelectedAccount);
        if SelectedAccount.Get(FileScenario."Account Id", FileScenario.Connector) then;

        AccountsPage.EnableLookupMode();
        AccountsPage.SetRecord(SelectedAccount);
        AccountsPage.Caption := ChangeFileAccountForScenarioTxt;

        if AccountsPage.RunModal() <> Action::LookupOK then
            exit(false);

        AccountsPage.GetAccount(SelectedAccount);

        if IsNullGuid(SelectedAccount."Account Id") then // defensive check, no account was selected
            exit;

        repeat
            if Scenario.Get(FileScenario.Scenario) then begin
                Scenario."Account Id" := SelectedAccount."Account Id";
                Scenario.Connector := SelectedAccount.Connector;

                Scenario.Modify();
            end;
        until FileScenario.Next() = 0;

        exit(true);
    end;

    procedure DeleteScenario(var FileScenario: Record "File Account Scenario"): Boolean
    var
        Scenario: Record "File Scenario";
    begin
        FileAccountImpl.CheckPermissions();

        if not FileScenario.FindSet() then
            exit(false);

        repeat
            if FileScenario.EntryType = FileScenario.EntryType::Scenario then begin
                Scenario.SetRange(Scenario, FileScenario.Scenario);
                Scenario.SetRange("Account Id", FileScenario."Account Id");
                Scenario.SetRange(Connector, FileScenario.Connector);

                Scenario.DeleteAll();
            end;
        until FileScenario.Next() = 0;

        exit(true);
    end;

    local procedure GetDefaultAccount(var FileAccount: Record "File Account")
    var
        Scenario: Record "File Scenario";
    begin
        if not Scenario.Get(Enum::"File Scenario"::Default) then
            exit;

        FileAccount."Account Id" := Scenario."Account Id";
        FileAccount.Connector := Scenario.Connector;
    end;

    var
        FileAccountImpl: Codeunit "File Account Impl.";
        AccountDisplayLbl: Label '%1 (%2)', Locked = true;
        ChangeFileAccountForScenarioTxt: Label 'Change file account used for the selected scenarios';
        ScenariosForAccountCaptionTxt: Label 'Assign scenarios to account %1', Comment = '%1 = the name of the e-file account';
}