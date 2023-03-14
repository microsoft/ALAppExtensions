// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 134687 "Test Email Connector" implements "Email Connector"
{
    procedure Send(EmailMessage: Codeunit "Email Message"; AccountId: Guid)
    begin
        ConnectorMock.SetEmailMessageID(EmailMessage.GetId());
        Commit();
        if ConnectorMock.FailOnSend() then
            Error('Failed to send email');
    end;

    procedure GetAccounts(var Accounts: Record "Email Account")
    begin
        ConnectorMock.GetAccounts(Accounts);
    end;

    procedure ShowAccountInformation(AccountId: Guid)
    begin
        Message('Showing information for account: %1', AccountId);
    end;

    procedure RegisterAccount(var EmailAccount: Record "Email Account"): Boolean
    var
    begin
        if ConnectorMock.FailOnRegisterAccount() then
            Error('Failed to register account');

        if ConnectorMock.UnsuccessfulRegister() then
            exit(false);

        EmailAccount."Account Id" := CreateGuid();
        EmailAccount."Email Address" := 'Test email address';
        EmailAccount.Name := 'Test account';

        exit(true);
    end;

    procedure DeleteAccount(AccountId: Guid): Boolean
    var
        TestEmailAccount: Record "Test Email Account";
    begin
        if TestEmailAccount.Get(AccountId) then
            exit(TestEmailAccount.Delete());
        exit(false);
    end;

    procedure GetLogoAsBase64(): Text
    begin

    end;

    procedure GetDescription(): Text[250]
    begin
        exit('Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis ornare ante a est commodo interdum. Pellentesque eu diam maximus, faucibus neque ut, viverra leo. Praesent ullamcorper nibh ut pretium dapibus. Nullam eu dui libero. Etiam ac cursus metus.')
    end;

    var
        ConnectorMock: Codeunit "Connector Mock";
}