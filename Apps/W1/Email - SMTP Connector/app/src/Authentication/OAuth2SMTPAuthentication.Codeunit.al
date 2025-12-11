// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

using System.Azure.Identity;
using System.Environment;
using System.Security.Authentication;
using System.Text;

codeunit 4516 "OAuth2 SMTP Authentication"
{
    Access = Internal;

    var
        CouldNotAuthenticateErr: Label 'Could not authenticate. To resolve the problem, choose the Authenticate action on the SMTP Account page.';
        AuthenticationSuccessfulMsg: Label '%1 was authenticated.', Comment = '%1 - user email, for example, admin@domain.com';
        AuthenticationFailedMsg: Label 'Could not authenticate.';
        GetSMTPClientSecretFailedErr: Label 'Failed to get SMTP Client Secret Storage Id.';
        GetSMTPClientIdFailedErr: Label 'Failed to get SMTP Client Id.';
        FetchAccessTokenFromHttpsErr: Label 'Failed to acquire access token. HTTP Status: %1.', Comment = '%1 - Status code of http request.';
        NoTokenInReposonseErr: Label 'The response does not contain an access token.';
        FailedToParseResponseErr: Label 'Failed to parse the response as JSON.';
        AdminConsentErrLbl: Label 'Consent authorization failed. Please try again or contact your administrator.';
        TelemetryCategoryLbl: Label 'SMTP OAuth2 Authentication', Locked = true;
        UsingCustomizedOAuth2TelemetryLbl: Label 'Using customized OAuth2 for SMTP authentication.', Locked = true;
        UsingDefaultOAuth2TelemetryLbl: Label 'Using default OAuth2 for SMTP authentication.', Locked = true;

    /// <summary>
    /// Provide the credentials to authenticate using OAuth 2.0 for Exchange Online mailboxes.
    /// </summary>
    /// <param name="UserName">Authentication user name for SMTP client. Email address of the user who is attempting to authenticate.</param>
    /// <param name="AccessToken">Acquired access token for SMTP client.</param>
    [NonDebuggable]
    internal procedure GetOAuth2Credentials(var UserName: Text; var AccessToken: SecretText)
    var
        AzureAdMgt: Codeunit "Azure AD Mgt.";
    begin
        AccessToken := AzureAdMgt.GetAccessTokenAsSecretText(AzureADMgt.GetO365Resource(), AzureADMgt.GetO365ResourceName(), true);
        if AccessToken.IsEmpty() then
            Error(CouldNotAuthenticateErr);
        GetUserName(AccessToken, UserName);
    end;

    /// <summary>
    /// Authenticate the current user.
    /// Disregard the token cache and show the authentication dialog.
    /// </summary>
    [NonDebuggable]
    internal procedure AuthenticateWithOAuth2()
    var
        AzureAdMgt: Codeunit "Azure AD Mgt.";
        AzureADAccessDialog: Page "Azure AD Access Dialog";
        AuthorizationCode: SecretText;
        AccessToken: SecretText;
    begin
        AuthorizationCode := AzureADAccessDialog.GetAuthorizationCodeAsSecretText(AzureADMgt.GetO365Resource(), AzureADMgt.GetO365ResourceName());
        if not AuthorizationCode.IsEmpty() then
            AccessToken := AzureAdMgt.AcquireTokenByAuthorizationCodeAsSecretText(AuthorizationCode, AzureADMgt.GetO365Resource());
    end;

    [NonDebuggable]
    internal procedure AuthenticateWithOAuth2CustomAppReg(var SMTPAccount: Record "SMTP Account")
    var
        OAuth2: Codeunit OAuth2;
        EnvironmentInformation: Codeunit "Environment Information";
        ClientId: SecretText;
        ClientSecret: SecretText;
        PermissionGrantError: Text;
        RedirectUri: Text;
        ConsentGranted: Boolean;
        ConsentUrlLbl: Label 'https://login.microsoftonline.com/common/adminconsent', Locked = true;
    begin
        ClientId := SMTPAccount.GetClientId(SMTPAccount."Client Id Storage Id");
        if ClientId.IsEmpty() then Error(GetSMTPClientIdFailedErr);

        ClientSecret := SMTPAccount.GetClientSecret(SMTPAccount."Client Secret Storage Id");
        if ClientSecret.IsEmpty() then Error(GetSMTPClientSecretFailedErr);

        RedirectUri := EnvironmentInformation.IsOnPrem() ? Format(SMTPAccount."Redirect Uri") : '';

        if OAuth2.RequestClientCredentialsAdminPermissions(ClientId.Unwrap(), ConsentUrlLbl, RedirectUri, ConsentGranted, PermissionGrantError) then begin
            if not ConsentGranted then
                Error(PermissionGrantError)
        end else
            Error(AdminConsentErrLbl);
    end;

    /// <summary>
    /// Verify if the current user is successfully authenticated.
    /// If there is token cache, it will be used. Otherwise, the authentication dialog will be shown.
    /// </summary>
    [NonDebuggable]
    internal procedure CheckOAuth2Authentication()
    var
        AzureAdMgt: Codeunit "Azure AD Mgt.";
        UserName: Text;
        AccessToken: SecretText;
    begin
        AccessToken := AzureAdMgt.GetAccessTokenAsSecretText(AzureADMgt.GetO365Resource(), AzureADMgt.GetO365ResourceName(), true);
        if not AccessToken.IsEmpty() then begin
            GetUserName(AccessToken, UserName);
            Message(AuthenticationSuccessfulMsg, UserName);
        end else
            Message(AuthenticationFailedMsg);
    end;

    /// <summary>
    /// Get user's email address by the access token.
    /// </summary>
    /// <param name="AccessToken">The access token for outlook.office.com</param>
    /// <param name="UserName">The email address of the user for whom the access token got acquired.</param>
    [NonDebuggable]
    [TryFunction]
    internal procedure GetUserName(AccessToken: SecretText; var UserName: Text)
    var
        Base64Convert: Codeunit "Base64 Convert";
        AccessTokenSections: List of [Text];
        AccessTokenBodyEncoded: Text;
        AccessTokenBodyDecoded: Text;
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        // Access token consists of a header, body and signature
        AccessTokenSections := AccessToken.Unwrap().split('.');

        // Get the encoded body
        AccessTokenBodyEncoded := AccessTokenSections.Get(2);

        // Base64 encoded string should always have a length that is a multiple of 4
        while StrLen(AccessTokenBodyEncoded) mod 4 > 0 do
            AccessTokenBodyEncoded += '=';

        AccessTokenBodyDecoded := Base64Convert.FromBase64(AccessTokenBodyEncoded);
        JObject.ReadFrom(AccessTokenBodyDecoded);
        JObject.Get('unique_name', JToken);
        UserName := JToken.AsValue().AsText();
    end;

    [NonDebuggable]
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SMTP Authentication", 'OnSMTPOAuth2Authenticate', '', false, false)]
    local procedure OnSMTPOAuth2Authenticate(var Handled: Boolean; var SMTPAuthentication: Codeunit "SMTP Authentication"; SMTPServer: Text)
    var
        SMTPAccount: Record "SMTP Account";
        SMTPConnectorImpl: Codeunit "SMTP Connector Impl.";
        AccessToken: SecretText;
        UserName: Text;
    begin
        if Handled then
            exit;
        if SMTPServer = SMTPConnectorImpl.GetO365SmtpServer() then begin
            if SMTPConnectorImpl.CheckIfCustomizedSMTPOAuth(SMTPAuthentication.GetAccountId(), SMTPAccount) then begin
                // if it is customized, use the token stored.
                GetCustomTenantOAuthToken(UserName, AccessToken, SMTPAccount);
                Session.LogMessage('0000QPH', UsingCustomizedOAuth2TelemetryLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
            end
            else begin
                // if it is not customized - use the normal way to fetch token
                GetOAuth2Credentials(UserName, AccessToken);
                Session.LogMessage('0000QPI', UsingDefaultOAuth2TelemetryLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
            end;

            SMTPAuthentication.SetOAuth2AuthInfo(CopyStr(UserName, 1, 250), AccessToken);
            Handled := true;
        end;
    end;

    [NonDebuggable]
    local procedure GetValueFromStorage(SecrectKey: Guid; var ClientSecret: SecretText): Boolean
    var
        StoredSecret: SecretText;
    begin
        if IsNullGuid(SecrectKey) then
            exit(false);

        if not IsolatedStorage.Contains(SecrectKey, DataScope::Company) then
            exit(false);

        IsolatedStorage.Get(SecrectKey, DataScope::Company, StoredSecret);
        ClientSecret := StoredSecret;
        exit(true);
    end;

    [NonDebuggable]
    local procedure GetCustomTenantOAuthToken(var UserName: Text; var AccessToken: SecretText; SMTPAccount: Record "SMTP Account")
    var
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        Headers: HttpHeaders;
        Resp: HttpResponseMessage;
        RespTxt: Text;
        JsonObj: JsonObject;
        ClientSecret: SecretText;
        ClientID: SecretText;
        TenantID: Text;
        BodyTxt: Label 'client_id=%1&client_secret=%2&scope=https://outlook.office365.com/.default&grant_type=client_credentials', Locked = true;
        AuthorityLbl: Label 'https://login.microsoftonline.com/%1/oauth2/v2.0/token', Locked = true;
    begin
        if not GetValueFromStorage(SMTPAccount."Client Id Storage Id", ClientID) then Error(GetSMTPClientIdFailedErr);

        if not GetValueFromStorage(SMTPAccount."Client Secret Storage Id", ClientSecret) then Error(GetSMTPClientSecretFailedErr);

        HttpContent.WriteFrom(SecretStrSubstNo(BodyTxt, ClientID, ClientSecret));
        HttpContent.GetHeaders(Headers);

        Headers.Clear();
        Headers.Add('Content-Type', 'application/x-www-form-urlencoded');

        TenantID := SMTPAccount."Tenant Id".ToText();
        HttpClient.Post(StrSubstNo(AuthorityLbl, TenantID), HttpContent, Resp);

        if not Resp.IsSuccessStatusCode() then
            Error(FetchAccessTokenFromHttpsErr, Resp.HttpStatusCode());

        Resp.Content().ReadAs(RespTxt);

        if JsonObj.ReadFrom(RespTxt) then begin
            if JsonObj.Contains('access_token') then
                AccessToken := JsonObj.GetText('access_token')
            else
                Error(NoTokenInReposonseErr);
        end else
            Error(FailedToParseResponseErr);

        UserName := SMTPAccount."Email Address";
    end;
}