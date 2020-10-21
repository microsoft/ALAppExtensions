// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4503 "Microsoft 365 Connector" implements "Email Connector"
{
    Access = Internal;
    Permissions = tabledata "Email - Outlook Account" = r;

    var
        DescriptionTxt: Label 'Use Microsoft 365 shared mailboxes.';
        NotRegisteredAccountErr: Label 'We could not find the account. Typically, this is because the account has been deleted.';
        Microsoft365ConnectorBase64LogoTxt: Label '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', Locked = true;

    procedure Send(EmailMessage: Codeunit "Email Message"; AccountId: Guid)
    var
        EmailOutlookAPIHelper: Codeunit "Email - Outlook API Helper";
    begin
        EmailOutlookAPIHelper.Send(EmailMessage, AccountId);
    end;

    procedure RegisterAccount(var Account: Record "Email Account"): Boolean
    var
        OutlookAccount: Record "Email - Outlook Account";
        EmailOutlookAPIHelper: Codeunit "Email - Outlook API Helper";
        Microsoft365EmailWizard: Page "Microsoft 365 Email Wizard";
    begin
        EmailOutlookAPIHelper.SetupAzureAppRegistration();

        OutlookAccount."Outlook API Email Connector" := Enum::"Email Connector"::"Microsoft 365";
        OutlookAccount."Created By" := CopyStr(UserId(), 1, MaxStrLen(OutlookAccount."Created By"));

        Microsoft365EmailWizard.SetRecord(OutlookAccount);
        Microsoft365EmailWizard.RunModal();

        if not Microsoft365EmailWizard.IsAccountCreated() then
            exit(false);

        Microsoft365EmailWizard.GetRecord(OutlookAccount);

        Account."Account Id" := OutlookAccount.Id;
        Account.Name := OutlookAccount.Name;
        Account."Email Address" := OutlookAccount."Email Address";
        Account.Connector := Enum::"Email Connector"::"Microsoft 365";

        exit(true);
    end;

    procedure ShowAccountInformation(AccountId: Guid)
    var
        OutlookAccount: Record "Email - Outlook Account";
        Microsoft365EmailAccount: Page "Microsoft 365 Email Account";
    begin
        if not OutlookAccount.Get(AccountId) then
            Error(NotRegisteredAccountErr);

        Page.Run(Page::"Microsoft 365 Email Account", OutlookAccount);
    end;

    procedure GetAccounts(var Accounts: Record "Email Account")
    var
        OutlookAPIHelper: Codeunit "Email - Outlook API Helper";
    begin
        OutlookAPIHelper.GetAccounts(Enum::"Email Connector"::"Microsoft 365", Accounts);
    end;

    procedure DeleteAccount(AccountId: Guid): Boolean
    var
        EmailOutlookAPIHelper: Codeunit "Email - Outlook API Helper";
    begin
        exit(EmailOutlookAPIHelper.DeleteAccount(AccountId));
    end;

    procedure GetDescription(): Text[250]
    begin
        exit(DescriptionTxt);
    end;

    procedure GetLogoAsBase64(): Text
    begin
        exit(Microsoft365ConnectorBase64LogoTxt);
    end;
}