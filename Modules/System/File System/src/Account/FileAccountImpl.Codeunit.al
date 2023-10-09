// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.FileSystem;

using System.Utilities;
using System.Text;

codeunit 70001 "File Account Impl."
{
    Access = Internal;
    InherentPermissions = X;
    InherentEntitlements = X;
    Permissions = tabledata "File System Connector Logo" = rimd,
                  tabledata "File Scenario" = imd;

    procedure GetAllAccounts(LoadLogos: Boolean; var TempFileAccount: Record "File Account" temporary)
    var
        FileAccounts: Record "File Account";
        IFileConnector: Interface "File System Connector";
        Connector: Enum "File System Connector";
    begin
        TempFileAccount.Reset();
        TempFileAccount.DeleteAll();

        foreach Connector in Connector.Ordinals do begin
            IFileConnector := Connector;

            FileAccounts.DeleteAll();
            IFileConnector.GetAccounts(FileAccounts);

            if FileAccounts.FindSet() then
                repeat
                    TempFileAccount := FileAccounts;
                    TempFileAccount.Connector := Connector;

                    if LoadLogos then begin
                        ImportLogo(TempFileAccount, Connector);
                        ImportLogoBlob(TempFileAccount, Connector);
                    end;

                    if not TempFileAccount.Insert() then;
                until FileAccounts.Next() = 0;
        end;

        // Sort by account name
        TempFileAccount.SetCurrentKey(Name);
    end;

    procedure DeleteAccounts(var FileAccountsToDelete: Record "File Account")
    var
        CurrentDefaultFileAccount: Record "File Account";
        ConfirmManagement: Codeunit "Confirm Management";
        FileScenario: Codeunit "File Scenario";
        FileConnector: Interface "File System Connector";
    begin
        CheckPermissions();

        if not ConfirmManagement.GetResponseOrDefault(ConfirmDeleteQst, true) then
            exit;

        if not FileAccountsToDelete.FindSet() then
            exit;

        // Get the current default account to track if it was deleted
        FileScenario.GetDefaultFileAccount(CurrentDefaultFileAccount);

        // Delete all selected acounts
        repeat
            // Check to validate that the connector is still installed
            // The connector could have been uninstalled by another user/session
            if IsValidConnector(FileAccountsToDelete.Connector) then begin
                FileConnector := FileAccountsToDelete.Connector;
                FileConnector.DeleteAccount(FileAccountsToDelete."Account Id");
            end;
        until FileAccountsToDelete.Next() = 0;

        HandleDefaultAccountDeletion(CurrentDefaultFileAccount."Account Id", CurrentDefaultFileAccount.Connector);
    end;

    local procedure HandleDefaultAccountDeletion(CurrentDefaultAccountId: Guid; Connector: Enum "File System Connector")
    var
        AllFileAccounts: Record "File Account";
        NewDefaultFileAccount: Record "File Account";
        FileScenario: Codeunit "File Scenario";
    begin
        GetAllAccounts(false, AllFileAccounts);

        if AllFileAccounts.IsEmpty() then
            exit; //All of the accounts were deleted, nothing to do

        if AllFileAccounts.Get(CurrentDefaultAccountId, Connector) then
            exit; // The default account was not deleted or it never existed

        // In case there's only one account, set it as default
        if AllFileAccounts.Count() = 1 then begin
            MakeDefault(AllFileAccounts);
            exit;
        end;

        Commit();  // Commit the accounts deletion in order to prompt for new default account
        if PromptNewDefaultAccountChoice(NewDefaultFileAccount) then
            MakeDefault(NewDefaultFileAccount)
        else
            FileScenario.UnassignScenario(Enum::"File Scenario"::Default); // remove the default scenario as it is pointing to a non-existent account
    end;

    local procedure PromptNewDefaultAccountChoice(var NewDefaultFileAccount: Record "File Account"): Boolean
    var
        FileAccountsPage: Page "File Accounts";
    begin
        FileAccountsPage.LookupMode(true);
        FileAccountsPage.EnableLookupMode();
        FileAccountsPage.Caption(ChooseNewDefaultTxt);
        if FileAccountsPage.RunModal() = Action::LookupOK then begin
            FileAccountsPage.GetAccount(NewDefaultFileAccount);
            exit(true);
        end;

        exit(false);
    end;

    local procedure ImportLogo(var FileAccount: Record "File Account"; Connector: Interface "File System Connector")
    var
        FileConnectorLogo: Record "File System Connector Logo";
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
        if not FileConnectorLogo.Get(FileAccount.Connector) then begin
            TempBlob.CreateOutStream(OutStream);
            Base64Convert.FromBase64(ConnectorLogoBase64, OutStream);
            TempBlob.CreateInStream(InStream);
            FileConnectorLogo.Connector := FileAccount.Connector;
            FileConnectorLogo.Logo.ImportStream(InStream, StrSubstNo(ConnectorLogoDescriptionTxt, FileAccount.Connector));
            if FileConnectorLogo.Insert() then;
        end;
        FileAccount.Logo := FileConnectorLogo.Logo
    end;

    procedure IsAnyAccountRegistered(): Boolean
    var
        FileAccount: Record "File Account";
    begin
        GetAllAccounts(false, FileAccount);

        exit(not FileAccount.IsEmpty());
    end;

    internal procedure IsUserFileAdmin(): Boolean
    var
        FileScenario: Record "File Scenario";
    begin
        exit(FileScenario.WritePermission());
    end;

    procedure FindAllConnectors(var FileConnector: Record "File System Connector")
    var
        Base64Convert: Codeunit "Base64 Convert";
        ConnectorInterface: Interface "File System Connector";
        Connector: Enum "File System Connector";
        ConnectorLogoBase64: Text;
        OutStream: Outstream;
    begin
        foreach Connector in Enum::"File System Connector".Ordinals() do begin
            ConnectorInterface := Connector;
            ConnectorLogoBase64 := ConnectorInterface.GetLogoAsBase64();
            FileConnector.Connector := Connector;
            FileConnector.Description := ConnectorInterface.GetDescription();
            if ConnectorLogoBase64 <> '' then begin
                FileConnector.Logo.CreateOutStream(OutStream);
                Base64Convert.FromBase64(ConnectorLogoBase64, OutStream);
            end;
            FileConnector.Insert();
        end;
    end;

    procedure IsValidConnector(Connector: Enum "File System Connector"): Boolean
    begin
        exit("File System Connector".Ordinals().Contains(Connector.AsInteger()));
    end;

    procedure MakeDefault(var FileAccount: Record "File Account")
    var
        FileScenario: Codeunit "File Scenario";
    begin
        CheckPermissions();

        if IsNullGuid(FileAccount."Account Id") then
            exit;

        FileScenario.SetDefaultFileAccount(FileAccount);
    end;

    procedure BrowseAccount(var FileAccount: Record "File Account")
    var
        FileAccountBrowser: Page "File Account Browser";
    begin
        CheckPermissions();

        if IsNullGuid(FileAccount."Account Id") then
            exit;

        FileAccountBrowser.SetFileAcconut(FileAccount);
        FileAccountBrowser.BrowseFileAccount('');
        FileAccountBrowser.Run();
    end;

    internal procedure CheckPermissions()
    begin
        if not IsUserFileAdmin() then
            Error(CannotManageSetupErr);
    end;

    local procedure ImportLogoBlob(var FileAccount: Record "File Account"; Connector: Interface "File System Connector")
    var
        Base64Convert: Codeunit "Base64 Convert";
        ConnectorLogoBase64: Text;
        OutStream: Outstream;
    begin
        ConnectorLogoBase64 := Connector.GetLogoAsBase64();

        if ConnectorLogoBase64 <> '' then begin
            FileAccount.LogoBlob.CreateOutStream(OutStream);
            Base64Convert.FromBase64(ConnectorLogoBase64, OutStream);
        end;
    end;

    [InternalEvent(false)]
    internal procedure OnAfterSetSelectionFilter(var FileAccount: Record "File Account")
    begin
    end;

    var
        ConfirmDeleteQst: Label 'Go ahead and delete?';
        ChooseNewDefaultTxt: Label 'Choose a Default Account';
        CannotManageSetupErr: Label 'Your user account does not give you permission to set up file. Please contact your administrator.';
}