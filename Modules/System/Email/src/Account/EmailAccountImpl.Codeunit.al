// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8889 "Email Account Impl."
{
    Access = Internal;
    Permissions = tabledata "Email Connector Logo" = rimd,
                  tabledata "Email Scenario" = imd;

    procedure GetAllAccounts(LoadLogos: Boolean; var TempEmailAccount: Record "Email Account" temporary)
    var
        EmailAccounts: Record "Email Account";
        IEmailConnector: Interface "Email Connector";
        Connector: Enum "Email Connector";
    begin
        TempEmailAccount.Reset();
        TempEmailAccount.DeleteAll();

        foreach Connector in Connector.Ordinals do begin
            IEmailConnector := Connector;

            EmailAccounts.DeleteAll();
            IEmailConnector.GetAccounts(EmailAccounts);

            if EmailAccounts.FindSet() then
                repeat
                    TempEmailAccount := EmailAccounts;
                    TempEmailAccount.Connector := Connector;

                    if LoadLogos then begin
                        ImportLogo(TempEmailAccount, Connector);
                        ImportLogoBlob(TempEmailAccount, Connector);
                    end;

                    if not TempEmailAccount.Insert() then;
                until EmailAccounts.Next() = 0;
        end;

        // Sort by account name
        TempEmailAccount.SetCurrentKey(Name);
    end;

    procedure DeleteAccounts(var EmailAccountsToDelete: Record "Email Account")
    var
        CurrentDefaultEmailAccount: Record "Email Account";
        ConfirmManagement: Codeunit "Confirm Management";
        EmailScenario: Codeunit "Email Scenario";
        EmailConnector: Interface "Email Connector";
    begin
        CheckPermissions();

        if not ConfirmManagement.GetResponseOrDefault(ConfirmDeleteQst, true) then
            exit;

        if not EmailAccountsToDelete.FindSet() then
            exit;

        // Get the current default account to track if it was deleted
        EmailScenario.GetDefaultEmailAccount(CurrentDefaultEmailAccount);

        // Delete all selected acounts
        repeat
            // Check to validate that the connector is still installed
            // The connector could have been uninstalled by another user/session
            if IsValidConnector(EmailAccountsToDelete.Connector) then begin
                EmailConnector := EmailAccountsToDelete.Connector;
                EmailConnector.DeleteAccount(EmailAccountsToDelete."Account Id");
            end;
        until EmailAccountsToDelete.Next() = 0;

        HandleDefaultAccountDeletion(CurrentDefaultEmailAccount."Account Id", CurrentDefaultEmailAccount.Connector);
    end;

    local procedure HandleDefaultAccountDeletion(CurrentDefaultAccountId: Guid; Connector: Enum "Email Connector")
    var
        AllEmailAccounts: Record "Email Account";
        NewDefaultEmailAccount: Record "Email Account";
        EmailScenario: Codeunit "Email Scenario";
    begin
        GetAllAccounts(false, AllEmailAccounts);

        if AllEmailAccounts.IsEmpty() then
            exit; //All of the accounts were deleted, nothing to do

        if AllEmailAccounts.Get(CurrentDefaultAccountId, Connector) then
            exit; // The default account was not deleted or it never existed

        // In case there's only one account, set it as default
        if AllEmailAccounts.Count() = 1 then begin
            MakeDefault(AllEmailAccounts);
            exit;
        end;

        Commit();  // Commit the accounts deletion in order to prompt for new default account
        if PromptNewDefaultAccountChoice(NewDefaultEmailAccount) then
            MakeDefault(NewDefaultEmailAccount)
        else
            EmailScenario.UnassignScenario(Enum::"Email Scenario"::Default); // remove the default scenario as it is pointing to a non-existent account
    end;

    local procedure PromptNewDefaultAccountChoice(var NewDefaultEmailAccount: Record "Email Account"): Boolean
    var
        EmailAccountsPage: Page "Email Accounts";
    begin
        EmailAccountsPage.LookupMode(true);
        EmailAccountsPage.EnableLookupMode();
        EmailAccountsPage.Caption(ChooseNewDefaultTxt);
        if EmailAccountsPage.RunModal() = Action::LookupOK then begin
            EmailAccountsPage.GetAccount(NewDefaultEmailAccount);
            exit(true);
        end;

        exit(false);
    end;

    local procedure ImportLogo(var EmailAccount: Record "Email Account"; Connector: Interface "Email Connector")
    var
        EmailConnectorLogo: Record "Email Connector Logo";
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
        if not EmailConnectorLogo.Get(EmailAccount.Connector) then begin
            TempBlob.CreateOutStream(OutStream);
            Base64Convert.FromBase64(ConnectorLogoBase64, OutStream);
            TempBlob.CreateInStream(InStream);
            EmailConnectorLogo.Connector := EmailAccount.Connector;
            EmailConnectorLogo.Logo.ImportStream(InStream, StrSubstNo(ConnectorLogoDescriptionTxt, EmailAccount.Connector));
            if EmailConnectorLogo.Insert() then;
        end;
        EmailAccount.Logo := EmailConnectorLogo.Logo
    end;

    procedure IsAnyAccountRegistered(): Boolean
    var
        EmailAccount: Record "Email Account";
    begin
        GetAllAccounts(false, EmailAccount);

        exit(not EmailAccount.IsEmpty());
    end;

    internal procedure IsUserEmailAdmin(): Boolean
    var
        EmailScenario: Record "Email Scenario";
    begin
        exit(EmailScenario.WritePermission());
    end;

    procedure FindAllConnectors(var EmailConnector: Record "Email Connector")
    var
        Base64Convert: Codeunit "Base64 Convert";
        ConnectorInterface: Interface "Email Connector";
        Connector: Enum "Email Connector";
        ConnectorLogoBase64: Text;
        OutStream: Outstream;
    begin
        foreach Connector in Enum::"Email Connector".Ordinals() do begin
            ConnectorInterface := Connector;
            ConnectorLogoBase64 := ConnectorInterface.GetLogoAsBase64();
            EmailConnector.Connector := Connector;
            EmailConnector.Description := ConnectorInterface.GetDescription();
            if ConnectorLogoBase64 <> '' then begin
                EmailConnector.Logo.CreateOutStream(OutStream);
                Base64Convert.FromBase64(ConnectorLogoBase64, OutStream);
            end;
            EmailConnector.Insert();
        end;
    end;

    procedure IsValidConnector(Connector: Enum "Email Connector"): Boolean
    begin
        exit("Email Connector".Ordinals().Contains(Connector.AsInteger()));
    end;

    procedure MakeDefault(var EmailAccount: Record "Email Account")
    var
        EmailScenario: Codeunit "Email Scenario";
    begin
        CheckPermissions();

        if IsNullGuid(EmailAccount."Account Id") then
            exit;

        EmailScenario.SetDefaultEmailAccount(EmailAccount);
    end;

    internal procedure CheckPermissions()
    begin
        if not IsUserEmailAdmin() then
            Error(CannotManageSetupErr);
    end;

    local procedure ImportLogoBlob(var EmailAccount: Record "Email Account"; Connector: Interface "Email Connector")
    var
        Base64Convert: Codeunit "Base64 Convert";
        ConnectorLogoBase64: Text;
        OutStream: Outstream;
    begin
        ConnectorLogoBase64 := Connector.GetLogoAsBase64();

        if ConnectorLogoBase64 <> '' then begin
            EmailAccount.LogoBlob.CreateOutStream(OutStream);
            Base64Convert.FromBase64(ConnectorLogoBase64, OutStream);
        end;
    end;

    [TryFunction]
    procedure ValidateEmailAddresses(EmailAddresses: Text; AllowEmptyValue: Boolean)
    var
        EmailAddress: Text;
    begin
        if (EmailAddresses = '') and not AllowEmptyValue then
            Error(EmptyEmailAddressErr);

        foreach EmailAddress in EmailAddresses.Split(';') do
            ValidateEmailAddress(EmailAddress, AllowEmptyValue);
    end;

    [TryFunction]
    procedure ValidateEmailAddress(EmailAddress: Text; AllowEmptyValue: Boolean)
    var
        EmailAccount: Codeunit "Email Account";
        ValidatedEmailAddress: Text;
    begin
        if (EmailAddress = '') and not AllowEmptyValue then
            Error(EmptyEmailAddressErr);

        if EmailAddress <> '' then begin
            ValidatedEmailAddress := EmailAddress;
            if not ConvertEmailAddress(ValidatedEmailAddress) then
                Error(InvalidEmailAddressErr, EmailAddress);

            // do not allow passing email address together with display name (e. g. "Tom Smith <tsmith@contoso.com>")
            if not (ValidatedEmailAddress = EmailAddress) then
                Error(InvalidEmailAddressErr, EmailAddress);
        end;

        EmailAccount.OnAfterValidateEmailAddress(EmailAddress, AllowEmptyValue);
    end;

    [TryFunction]
    local procedure ConvertEmailAddress(var EmailAddress: Text)
    var
        MailAddress: DotNet MailAddress;
    begin
        // throws an exception if the address is invalid
        MailAddress := MailAddress.MailAddress(EmailAddress);

        EmailAddress := MailAddress.Address;
    end;

    [InternalEvent(false)]
    internal procedure OnAfterSetSelectionFilter(var EmailAccount: Record "Email Account")
    begin
    end;

    var
        ConfirmDeleteQst: Label 'Go ahead and delete?';
        ChooseNewDefaultTxt: Label 'Choose a Default Account';
        InvalidEmailAddressErr: Label 'The email address "%1" is not valid.', Comment = '%1=The email address';
        EmptyEmailAddressErr: Label 'The email address cannot be empty.';
        CannotManageSetupErr: Label 'Your user account does not give you permission to set up email. Please contact your administrator.';
}