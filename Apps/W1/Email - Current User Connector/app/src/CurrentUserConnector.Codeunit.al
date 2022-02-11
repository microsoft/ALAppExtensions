// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4500 "Current User Connector" implements "Email Connector"
{
    Access = Internal;
    Permissions = tabledata "Email - Outlook Account" = rimd;

    var
        ConnectorDescriptionTxt: Label 'Users send emails from their sign-in account.';
        CurrentUserConnectorBase64LogoTxt: Label 'iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAABYlAAAWJQFJUiTwAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAARQSURBVHgBzVm9UhtBDJZJk9LwAjnzAnG6dDm6dJAngFSZVNhPYFNlUgFdOswTAFUmVS4dXUyZBpYnwHRJA/lk62zdcsba+/H4m9m52zO7q2+l1UqiQRUhiqImHm207UajEfMntKb8PEIbPj4+OjwvnHPnVBEaVBIs+NraWgfC7dNM4EVwIHn68PAwABlHJfCCSmBzc7ODxxnae7SXAUOZaAwSO81mcwRcUUEU1kCr1Rrgset9HkETR3gmEM7d3Nzc8kcxr9doOyw0TcxrCh4DRXSpAAoRyBHeQYg9CPHLMh6E9kCkR4oI+oPr6+uPFIhgE4LZ8A5/0gtD+A8Q/o91DpjMEKZzgbOTHnxGe2NjI7q7u7ugAAQR4J3D40vah+B9mEkXAv2lQLDhs7AgQuK1GG307/HTpXUeswlB+AgL/SRRO4RnDxKs8jx4JsnnqIW5R5axa2QE1L1HM5t1aAdUESBwR+ZksFntW8eaCWCRXfXeL+u/NXi3MedUm9B0RzzXQpgIYDLt+lj2U6oYmDOhyY3N0If7WZgIwHy203fsVGVhgA+5Q1JsW8aYCGDiSHVrIwDoeyS2DLCeAa3Owte+AS59wTmILAOsBKYHyureisBzDNUd4lWGlcB013HpvKKa4LnOSi8yl77wLUn1oa3WGVoGWL1QorrvqD5o1+ksA6wamEaIfEtSTZBcIYXJXZsI+LckbDWmiiGRbjRb0pnC6pBYaHpLYqdOrLGKBRLp9tRaA+vYEDd6TDMtRAgvDqkiYC6dnTk0c6xlTmg4aUHG9I8mCTyDM6gGkpKESgAZXl/C6TH43ZqaMoIyMgh7iYypCXW/lU8xuhHaFWdYIXOxCa6vr38jFftLcv+VAhCcE0POH1iY74KxzwaZdmh5hJ0AxnwnFbBxbo309DMFonBZBUIc5rhUJ+E2e5BhGjfxIaXJuYnzCmBLL6ukyCuPBGIk2d0xFUTZYM6R8cacAw4XbqkECmlAbJh3PqZq4EQTwalqEAEp5PbFjjOQ4CtBG4Jcgv69OgNs8xEaR7IxTeqi7Zw5BngchBQMQupC7G3OKGvvI1n0PMR3y3x8qHsYH3tzsja61hK8iYAcVr55p95DBO+WzdDEQ+37Hk1IHC0av5CACH+iPvGu74TuuGGdTOWPYSHRMEz6m2Y7z+rdqrKolbMem6lObLYkGs5FY8FkekdqFV6t25R1UxKs8Tfz1p17D/gR4jKEHy80KTNukaqVeiacQS4B9vP8D4u0X3UtdBH8WikQz0uicgn4yUUdtdBFYLv3kqhe3t89ISBMY/WpsjJ6AfDaqZvO1cITArB9XUYfLNN0fIgpPauFJwTYx6tu4SixQmgZ2n4uniEgKhr/Acc22AFTcalOyE2fSJdly9SlfA3owlJCKwKvShfr3zIEvAgxodWBDlsi/YOvAW1fpRKNijHVgB+G+wQi9e5odaAj3vmHmJb0j4xQeLJkCPwHeCccZ4D9OOkAAAAASUVORK5CYII=', Locked = true;
        CurrentUsersEmailAddressTok: Label 'Current User''s Email Address', MaxLength = 250;
        CurrentUserTok: Label 'Current User', MaxLength = 250;

    procedure Send(EmailMessage: Codeunit "Email Message"; AccountId: Guid)
    var
        EmailOutlookAPIHelper: Codeunit "Email - Outlook API Helper";
    begin
        EmailOutlookAPIHelper.Send(EmailMessage);
    end;

    procedure RegisterAccount(var EmailAccount: Record "Email Account"): Boolean
    var
        EmailOutlookAPIHelper: Codeunit "Email - Outlook API Helper";
        CurrentUserEmailAccount: Page "Current User Email Account";
    begin
        EmailOutlookAPIHelper.SetupAzureAppRegistration();

        CurrentUserEmailAccount.RunModal();
        exit(CurrentUserEmailAccount.GetAccount(EmailAccount));
    end;

    procedure ShowAccountInformation(AccountId: Guid);
    var
        EmailOutlookAccount: Record "Email - Outlook Account";
    begin
        EmailOutlookAccount.SetRange("Outlook API Email Connector", Enum::"Email Connector"::"Current User");

        if EmailOutlookAccount.FindFirst() then
            Page.RunModal(Page::"Current User Email Account", EmailOutlookAccount);
    end;

    procedure GetAccounts(var EmailAccount: Record "Email Account")
    var
        EmailOutlookAPIHelper: Codeunit "Email - Outlook API Helper";
    begin
        EmailOutlookAPIHelper.GetAccounts(Enum::"Email Connector"::"Current User", EmailAccount);
        SubstituteEmailAddress(EmailAccount);
    end;

    local procedure SubstituteEmailAddress(var EmailAccount: Record "Email Account")
    begin
        // there may only be one account of type "Current User"
        if not EmailAccount.FindFirst() then
            exit;

        EmailAccount."Email Address" := GetCurrentUserEmailAddress();
        EmailAccount.Modify();
    end;

    internal procedure GetCurrentUserEmailAddress(): Text[250]
    var
        User: Record User;
        EmailOutlookAPIHelper: Codeunit "Email - Outlook API Helper";
        EnvironmentInformation: Codeunit "Environment Information";
        APIClient: interface "Email - Outlook API Client";
        OAuthClient: interface "Email - OAuth Client";
        CurrentUserName: Text[250];
        CurrentUserEmail: Text[250];

        [NonDebuggable]
        AccessToken: Text;
    begin
        if EnvironmentInformation.IsSaaS() then begin
            if not User.Get(UserSecurityId()) then
                exit;
            if User."Authentication Email" = '' then
                exit;

            exit(User."Authentication Email");
        end else begin // OnPrem
            EmailOutlookAPIHelper.InitializeClients(APIClient, OAuthClient);

            if not EmailOutlookAPIHelper.IsAzureAppRegistrationSetup() then
                exit;
            if not OAuthClient.TryGetAccessToken(AccessToken) then
                exit;
            if not APIClient.GetAccountInformation(AccessToken, CurrentUserEmail, CurrentUserName) then
                exit;

            exit(CurrentUserEmail);
        end;
    end;

    procedure DeleteAccount(AccountId: Guid): Boolean
    var
        EmailOutlookAPIHelper: Codeunit "Email - Outlook API Helper";
    begin
        exit(EmailOutlookAPIHelper.DeleteAccount(AccountId));
    end;

    procedure GetDescription(): Text[250]
    begin
        exit(ConnectorDescriptionTxt);
    end;

    procedure GetLogoAsBase64(): Text
    begin
        exit(CurrentUserConnectorBase64LogoTxt);
    end;

    procedure GetCurrentUsersAccountEmailAddress(): Text[250]
    begin
        exit(CurrentUsersEmailAddressTok)
    end;

    procedure GetCurrentUserAccountName(): Text[250]
    begin
        exit(CurrentUserTok)
    end;
}