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
        Microsoft365ConnectorBase64LogoTxt: Label 'iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAABYlAAAWJQFJUiTwAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAKSSURBVHgB7Zr9cRoxEMUXJv/H6UBQgV0B5wogHdABpAJwBXEqCO4AV+BzB6QCVAIVQN7LSRnGc5JP0h3yx/1mNHzcnW7falfALiLvnIF0hFKqwMMU4wpjh/Gstd5Jy7QuAIarwWDwG0+LmsP6dDqVeOSgIC2JtCYAdl8Nh8MlDFxI5fUm7IygR2gpJYJWBIzHYxq+kuaGuygxz1YCwi1JAOMc4fITT68DLqORguuKV87TOOfheDzeQ8zBddJQImCcj0ajJ9zgScKMF4YMDLrF4zeMGebY0Ni623BVeQ+Gp2u+LxJmuI3zlSRivPpoxj+nSJX4U7M61mg6iHl1VzdP4xVgnGPifRvG16ErNhjf9/s9V2dtj+G+c9d1rwpgnCNcaDhjPTVJGwMh5x5XrvO8AuD1tYlzJWkcpCOcAuD5eUq4MFkxliZZ76UjnEkMzy8knIMxdosQ+GPfrPKzG3y7UNPtkUZvpDL6WS5M0DZaA7/b3LbxnSaWqA8yC7e6nMaTJAGw/UEykyTgLdALyE0vIDe9gNz0AnLTC8hNLyA3vYDcfF4B5ndwdmIFaHGU+i6NT0BdMYoViDXGTe7fwhZnVYIhgtrQ8uw16z13vlJ3DpwCYOgPFKRYnPoqVQdF22Om/zWRhjToBUTjrQuxWvzyPRh/beqlb4KYJJ7KBWBh+eyldp0XU5ljQ4K50Wqp3XRhZhgTrPAMOfd/ftM3qyVYAJtvuNkNOjUrTDyXBJhLmKfAPMynwnEam33OLTu1yTcxPS4VcNkWBh/oZfGvoq10//LtfK20WdlLgEHsJShJwPSML9dmPcfE8AJC1gGX2dJ8KZXRwZ8xnfzVwJcfMV720eWfPZRU7VGuDD1bSqSXPzR/AUN7LgKkiMJcAAAAAElFTkSuQmCC', Locked = true;
        
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