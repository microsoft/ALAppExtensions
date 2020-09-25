// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8889 "Email Account Impl."
{
    Access = Internal;
    Permissions = tabledata "Email Connector Logo" = rimd;

    procedure GetAllAccounts(LoadLogos: Boolean; var Accounts: Record "Email Account" temporary)
    var
        EmailAccounts: Record "Email Account";
        IEmailConnector: Interface "Email Connector";
        Connector: Enum "Email Connector";
    begin
        Accounts.DeleteAll();

        foreach Connector in Connector.Ordinals do begin
            IEmailConnector := Connector;

            EmailAccounts.DeleteAll();
            IEmailConnector.GetAccounts(EmailAccounts);

            if EmailAccounts.FindSet() then
                repeat
                    Accounts := EmailAccounts;
                    Accounts.Connector := Connector;

                    if LoadLogos then begin
                        ImportLogo(Accounts, Connector);
                        ImportLogoBlob(Accounts, Connector);
                    end;

                    if not Accounts.Insert() then;
                until EmailAccounts.Next() = 0;
        end;

        // Sort by account name
        Accounts.SetCurrentKey(Name);
    end;

    procedure Delete(var EmailAccount: Record "Email Account"; IsDefaultAccount: Boolean)
    var
        NewDefaultAccount: Record "Email Account";
        ConfirmManagement: Codeunit "Confirm Management";
        EmailConnector: Interface "Email Connector";
    begin
        if not ConfirmManagement.GetResponseOrDefault(ConfirmDeleteQst, true) then
            exit;

        EmailConnector := EmailAccount.Connector;

        if not EmailConnector.DeleteAccount(EmailAccount."Account Id") then
            exit; // the account wasn't deleted

        if not IsDefaultAccount then
            exit; // the deleted account wasn't the default one

        if PromptNewDefaultAccountChoice(NewDefaultAccount) then
            MakeDefault(NewDefaultAccount);
    end;

    local procedure PromptNewDefaultAccountChoice(var NewDefaultAccount: Record "Email Account"): Boolean
    var
        EmailAccounts: Record "Email Account";
        EmailAccount: Codeunit "Email Account";
        AccountsPage: Page "Email Accounts";
    begin
        EmailAccount.GetAllAccounts(EmailAccounts);

        EmailAccounts.Reset();
        if EmailAccounts.IsEmpty() then
            exit(false);

        // in case there's only one account, set it as default
        if EmailAccounts.Count() = 1 then begin
            NewDefaultAccount."Account Id" := EmailAccounts."Account Id";
            NewDefaultAccount.Connector := EmailAccounts.Connector;

            exit(true);
        end;

        Commit();  // Commit the account deletion in order to prompt for new default account

        AccountsPage.LookupMode(true);
        AccountsPage.EnableLookupMode();
        AccountsPage.Caption(ChooseNewDefaultTxt);
        if AccountsPage.RunModal() = Action::LookupOK then begin
            AccountsPage.GetAccount(NewDefaultAccount);
            exit(true);
        end;

        exit(false);
    end;

    local procedure ImportLogo(var Account: Record "Email Account"; Connector: Interface "Email Connector")
    var
        ConnectorLogo: Record "Email Connector Logo";
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        ConnectorLogoBase64: Text;
        OutStream: Outstream;
        InStream: InStream;
        ConnectorLogoDescriptionTxt: Label '%1 Logo', Locked = true;
    begin
        ConnectorLogoBase64 := Connector.GetLogoAsBase64();

        if ConnectorLogoBase64 = '' then
            exit;
        if not ConnectorLogo.Get(Account.Connector) then begin
            TempBlob.CreateOutStream(OutStream);
            Base64Convert.FromBase64(ConnectorLogoBase64, OutStream);
            TempBlob.CreateInStream(InStream);
            ConnectorLogo.Connector := Account.Connector;
            ConnectorLogo.Logo.ImportStream(InStream, StrSubstNo(ConnectorLogoDescriptionTxt, Account.Connector));
            if ConnectorLogo.Insert() then;
        end;
        Account.Logo := ConnectorLogo.Logo
    end;

    procedure IsAnyAccountRegistered(): Boolean
    var
        Accounts: Record "Email Account";
    begin
        GetAllAccounts(false, Accounts);

        exit(not Accounts.IsEmpty());
    end;

    procedure MakeDefault(var EmailAccount: Record "Email Account")
    var
        EmailScenario: Codeunit "Email Scenario";
    begin
        if IsNullGuid(EmailAccount."Account Id") then
            exit;

        EmailScenario.SetDefaultEmailAccount(EmailAccount);
    end;

    local procedure ImportLogoBlob(var Account: Record "Email Account"; Connector: Interface "Email Connector")
    var
        Base64Convert: Codeunit "Base64 Convert";
        ConnectorLogoBase64: Text;
        OutStream: Outstream;
    begin
        ConnectorLogoBase64 := Connector.GetLogoAsBase64();

        if ConnectorLogoBase64 <> '' then begin
            Account.LogoBlob.CreateOutStream(OutStream);
            Base64Convert.FromBase64(ConnectorLogoBase64, OutStream);
        end;
    end;

    var
        ConfirmDeleteQst: Label 'Go ahead and delete?';
        ChooseNewDefaultTxt: Label 'Choose a Default Account';
}