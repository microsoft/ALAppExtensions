// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

using System.Environment;
using System.Security.Authentication;
using System.Azure.Identity;
using System.Utilities;

#if not CLEAN24
#pragma warning disable AL0432
codeunit 4507 "Email - OAuth Client" implements "Email - OAuth Client", "Email - OAuth Client v2"
#pragma warning restore AL0432
#else
codeunit 4507 "Email - OAuth Client" implements "Email - OAuth Client v2"
#endif
{
#if not CLEAN24
    /// <summary>
    /// Retrieves the Access token for the current user to connect to Outlook API
    /// </summary>
    /// <param name="AccessToken">Out parameter with the Access token of the account</param>
    [NonDebuggable]
    [Obsolete('Replaced by GetAccessToken with SecretText data type for AccessToken parameter.', '24.0')]
    procedure GetAccessToken(var AccessToken: Text)
    begin
#pragma warning disable AL0432
        TryGetAccessTokenInternal(AccessToken);
#pragma warning restore AL0432
    end;

    [NonDebuggable]
    [Obsolete('Replaced by GetAccessToken with SecretText data type for AccessToken parameter.', '24.0')]

    procedure TryGetAccessToken(var AccessToken: Text): Boolean
    begin
        exit(TryGetAccessTokenInternal(AccessToken));
    end;
#endif

    /// <summary>
    /// Retrieves the Access token for the current user to connect to Outlook API
    /// </summary>
    /// <param name="AccessToken">Out parameter with the Access token of the account</param>
    [NonDebuggable]
    procedure GetAccessToken(var AccessToken: SecretText)
    begin
        TryGetAccessTokenInternal(AccessToken);
    end;

    [NonDebuggable]
    procedure TryGetAccessToken(var AccessToken: SecretText): Boolean
    begin
        exit(TryGetAccessTokenInternal(AccessToken));
    end;

#if not CLEAN24
    // Interfaces do not support properties for the procedures, so using an internal function
    [TryFunction]
    [NonDebuggable]
    local procedure TryGetAccessTokenInternal(var AccessToken: Text)
    var
        Token: SecretText;
    begin
        TryGetAccessTokenInternal(Token);
        if not Token.IsEmpty() then
            AccessToken := Token.Unwrap();
    end;
#endif

    // Interfaces do not support properties for the procedures, so using an internal function
    [TryFunction]
    [NonDebuggable]
    local procedure TryGetAccessTokenInternal(var AccessToken: SecretText)
    var
        AzureAdMgt: Codeunit "Azure AD Mgt.";
        UrlHelper: Codeunit "Url Helper";
        EnvironmentInformation: Codeunit "Environment Information";
        OAuthErr: Text;
    begin
        Initialize();

        ClearLastError();
        if EnvironmentInformation.IsSaaSInfrastructure() then begin
            AccessToken := AzureAdMgt.GetAccessToken(UrlHelper.GetGraphUrl(), '', false);
            if AccessToken.IsEmpty() then begin
                Session.LogMessage('000040Z', CouldNotAcquireAccessTokenErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailCategoryLbl);
                if OAuth2.AcquireOnBehalfOfToken('', Scopes, AccessToken) then;
            end;
        end else
            if (not OAuth2.AcquireAuthorizationCodeTokenFromCache(ClientId, ClientSecret, RedirectURL, GetOAuthAuthorityUrl(), Scopes, AccessToken)) or AccessToken.IsEmpty() then
                OAuth2.AcquireTokenByAuthorizationCode(ClientId, ClientSecret, GetOAuthAuthorityUrl(), RedirectURL, Scopes, Enum::"Prompt Interaction"::None, AccessToken, OAuthErr);

        if AccessToken.IsEmpty() then begin
            if AzureADMgt.GetLastErrorMessage() <> '' then
                Error(AzureADMgt.GetLastErrorMessage());

            Error(CouldNotGetAccessTokenErr);
        end
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
        AccessToken: SecretText;
    begin
        Initialize();
        exit(OAuth2.AcquireAuthorizationCodeTokenFromCache(ClientId, ClientSecret, RedirectURL, GetOAuthAuthorityUrl(), Scopes, AccessToken) and (not AccessToken.IsEmpty()))
    end;

    internal procedure SignInUsingAuthorizationCode(): Boolean
    var
        AccessToken: SecretText;
        OAuthErr: Text;
    begin
        Initialize();
        exit(OAuth2.AcquireTokenByAuthorizationCode(ClientID, ClientSecret, GetOAuthAuthorityUrl(), RedirectURL, Scopes, Enum::"Prompt Interaction"::"Select Account", AccessToken, OAuthErr) and (not AccessToken.IsEmpty()));
    end;

    local procedure GetOAuthAuthorityUrl(): Text
    var
        UrlHelper: Codeunit "Url Helper";
        AuthUrl: Text;
    begin
        AuthUrl := UrlHelper.GetAzureADAuthEndpoint();
        exit(AuthUrl.Replace('/authorize', ''));
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
        GraphScopesLbl: Label 'https://graph.microsoft.com/.default', Locked = true;
        CouldNotGetAccessTokenErr: Label 'Could not get access token.';
        EmailCategoryLbl: Label 'EmailOAuth', Locked = true;
        CouldNotAcquireAccessTokenErr: Label 'Failed to acquire access token.', Locked = true;
}