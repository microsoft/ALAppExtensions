// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4507 "Email - OAuth Client" implements "Email - OAuth Client"
{
    /// <summary>
    /// Retrieves the Access token for the current user to connect to Outlook API
    /// </summary>
    /// <param name="AccessToken">Out parameter with the Access token of the account</param>
    [NonDebuggable]
    procedure GetAccessToken(var AccessToken: Text)
    begin
        TryGetAccessTokenInternal(AccessToken);
    end;

    [NonDebuggable]
    procedure TryGetAccessToken(var AccessToken: Text): Boolean
    begin
        exit(TryGetAccessTokenInternal(AccessToken));
    end;

    // Interfaces do not support properties for the procedures, so using an internal function
    [TryFunction]
    [NonDebuggable]
    local procedure TryGetAccessTokenInternal(var AccessToken: Text)
    var
        AzureAdMgt: Codeunit "Azure AD Mgt.";
        UrlHelper: Codeunit "Url Helper";
        EnvironmentInformation: Codeunit "Environment Information";
        OAuthErr: Text;
    begin
        Initialize();

        if EnvironmentInformation.IsSaaSInfrastructure() then begin
            AccessToken := AzureAdMgt.GetAccessToken(UrlHelper.GetGraphUrl(), '', false);
            if AccessToken = '' then begin
                Session.LogMessage('000040Z', CouldNotAcquireAccessTokenErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailCategoryLbl);
                if OAuth2.AcquireOnBehalfOfToken('', Scopes, AccessToken) then;
            end;
        end else
            if (not OAuth2.AcquireAuthorizationCodeTokenFromCache(ClientId, ClientSecret, RedirectURL, OAuthAuthorityUrlTxt, Scopes, AccessToken)) or (AccessToken = '') then
                OAuth2.AcquireTokenByAuthorizationCode(ClientId, ClientSecret, OAuthAuthorityUrlTxt, RedirectURL, Scopes, Enum::"Prompt Interaction"::None, AccessToken, OAuthErr);

        if AccessToken = '' then
            Error(CouldNotGetAccessTokenErr);
    end;

    internal procedure GetLastAuthorizationErrorMessage(): Text
    begin
        exit(OAuth2.GetLastErrorMessage());
    end;

    local procedure Initialize()
    var
        EnvironmentInformation: Codeunit "Environment Information";
        EmailOutlookAPIHelper: Codeunit "Email - Outlook API Helper";
    begin
        if IsInitialized then
            exit;

        Scopes.Add(GraphScopesLbl);
        if not EnvironmentInformation.IsSaaSInfrastructure() then begin
            EmailOutlookAPIHelper.GetClientIDAndSecret(ClientId, ClientSecret);
            RedirectURL := EmailOutlookAPIHelper.GetRedirectURL();
            if RedirectURL = '' then
                OAuth2.GetDefaultRedirectUrl(RedirectURL);
        end;

        IsInitialized := true;
    end;

    internal procedure AuthorizationCodeTokenCacheExists(): Boolean
    var
        [NonDebuggable]
        AccessToken: Text;
    begin
        Initialize();
        exit(OAuth2.AcquireAuthorizationCodeTokenFromCache(ClientId, ClientSecret, RedirectURL, OAuthAuthorityUrlTxt, Scopes, AccessToken) and (AccessToken <> ''))
    end;

    internal procedure SignInUsingAuthorizationCode(): Boolean
    var
        [NonDebuggable]
        AccessToken: Text;
        OAuthErr: Text;
    begin
        Initialize();
        exit(OAuth2.AcquireTokenByAuthorizationCode(ClientID, ClientSecret, OAuthAuthorityUrlTxt, RedirectURL, Scopes, Enum::"Prompt Interaction"::"Select Account", AccessToken, OAuthErr) and (AccessToken <> ''));
    end;

    var
        OAuth2: Codeunit OAuth2;

        [NonDebuggable]
        ClientId: Text;
        [NonDebuggable]
        ClientSecret: Text;
        RedirectURL: Text;
        IsInitialized: Boolean;
        Scopes: List of [Text];
        OAuthAuthorityUrlTxt: Label 'https://login.microsoftonline.com/common/oauth2', Locked = true;
        GraphScopesLbl: Label 'https://graph.microsoft.com/.default', Locked = true;
        CouldNotGetAccessTokenErr: Label 'Could not get access token. Please, try to log out and log in again.';
        EmailCategoryLbl: Label 'EmailOAuth', Locked = true;
        CouldNotAcquireAccessTokenErr: Label 'Failed to acquire access token.', Locked = true;
}