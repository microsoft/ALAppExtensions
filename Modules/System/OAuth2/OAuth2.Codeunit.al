// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Contains methods supporting authentication via OAuth 2.0 protocol.
/// </summary>
codeunit 501 OAuth2
{
    Access = Public;

    var
        OAuth2Impl: Codeunit OAuth2Impl;

    /// <summary>
    /// Gets the authorization token based on the authorization code via the OAuth2 v1.0 code grant flow. 
    /// </summary>
    /// <param name="ClientId">The Application (client) ID that the "Azure portal – App registrations" experience assigned to your app.</param>
    /// <param name="ClientSecret">The Application (client) secret configured in the "Azure Portal - Certificates &amp; Secrets".</param>
    /// <param name="OAuthAuthorityUrl">The identity authorization provider URL.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="ResourceURL">The Application ID of the resource the application is requesting access to. This parameter can be empty.</param>
    /// <param name="PromptInteraction">Indicates the type of user interaction that is required.</param>
    /// <param name="AccessToken">Exit parameter containing the access token. When this parameter is empty, check the AuthCodeErr for a description of the error.</param>
    /// <param name="AuthCodeErr">Exit parameter containing the encountered error in the authorization code grant flow. This parameter will be empty in case the token is aquired successfuly.</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireTokenByAuthorizationCode(ClientId: Text; ClientSecret: Text; OAuthAuthorityUrl: Text; RedirectURL: Text; ResourceURL: Text; PromptInteraction: Enum "Prompt Interaction"; var AccessToken: Text; var AuthCodeErr: Text)
    begin
        OAuth2Impl.AcquireTokenByAuthorizationCode(ClientId, ClientSecret, OAuthAuthorityUrl, RedirectURL, ResourceURL, PromptInteraction, AccessToken, AuthCodeErr);
    end;

    /// <summary>
    /// Gets the authorization token based on the authorization code via the OAuth2 v2.0 code grant flow. 
    /// </summary>
    /// <param name="ClientId">The Application (client) ID that the "Azure portal – App registrations" experience assigned to your app.</param>
    /// <param name="ClientSecret">The Application (client) secret configured in the "Azure Portal - Certificates &amp; Secrets".</param>
    /// <param name="OAuthAuthorityUrl">The identity authorization provider URL.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="Scopes">A list of scopes that you want the user to consent to.</param>
    /// <param name="PromptInteraction">Indicates the type of user interaction that is required.</param>
    /// <param name="AccessToken">Exit parameter containing the access token. When this parameter is empty, check the AuthCodeErr for a description of the error.</param>
    /// <param name="AuthCodeErr">Exit parameter containing the encountered error in the authorization code grant flow. This parameter will be empty in case the token is aquired successfuly.</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireTokenByAuthorizationCode(ClientId: Text; ClientSecret: Text; OAuthAuthorityUrl: Text; RedirectURL: Text; Scopes: List of [Text]; PromptInteraction: Enum "Prompt Interaction"; var AccessToken: Text; var AuthCodeErr: Text)
    begin
        OAuth2Impl.AcquireTokenByAuthorizationCode(ClientId, ClientSecret, OAuthAuthorityUrl, RedirectURL, Scopes, PromptInteraction, AccessToken, AuthCodeErr);
    end;

    /// <summary>
    /// Gets the access token and token cache state with authorization code flow. 
    /// </summary>
    /// <param name="ClientId">The Application (client) ID that the "Azure portal – App registrations" experience assigned to your app.</param>
    /// <param name="ClientSecret">The Application (client) secret configured in the "Azure Portal - Certificates &amp; Secrets".</param>
    /// <param name="OAuthAuthorityUrl">The identity authorization provider URL.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="Scopes">A list of scopes that you want the user to consent to.</param>
    /// <param name="PromptInteraction">Indicates the type of user interaction that is required.</param>
    /// <param name="AccessToken">Exit parameter containing the access token. When this parameter is empty, check the Error for a description of the error.</param>
    /// <param name="TokenCache">Exit parameter containing the token cache acquired when the access token was requested.</param>
    /// <param name="Error">Exit parameter containing the encountered error in the authorization code grant flow. This parameter will be empty in case the token is aquired successfuly.</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireTokenAndTokenCacheByAuthorizationCode(ClientId: Text; ClientSecret: Text; OAuthAuthorityUrl: Text; RedirectURL: Text; Scopes: List of [Text]; PromptInteraction: Enum "Prompt Interaction"; var AccessToken: Text; var TokenCache: Text; var Error: Text)
    begin
        OAuth2Impl.AcquireTokenAndTokenCacheByAuthorizationCode(ClientId, ClientSecret, OAuthAuthorityUrl, RedirectURL, Scopes, PromptInteraction, AccessToken, TokenCache, Error);
    end;

    /// <summary>
    /// Gets the authentication token via the On-Behalf-Of OAuth2 v1.0 protocol flow. 
    /// </summary>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="ResourceURL">The Application ID of the resource the application is requesting access to. This parameter can be empty.</param>
    /// <param name="AccessToken">Exit parameter containing the access token.</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireOnBehalfOfToken(RedirectURL: Text; ResourceURL: Text; var AccessToken: Text)
    begin
        OAuth2Impl.AcquireOnBehalfOfToken(RedirectURL, ResourceURL, AccessToken);
    end;

    /// <summary>
    /// Gets the authentication token via the On-Behalf-Of OAuth2 v2.0 protocol flow. 
    /// </summary>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="Scopes">A list of scopes that you want the user to consent to.</param>
    /// <param name="AccessToken">Exit parameter containing the access token.</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireOnBehalfOfToken(RedirectURL: Text; Scopes: List of [Text]; var AccessToken: Text)
    begin
        OAuth2Impl.AcquireOnBehalfOfToken(RedirectURL, Scopes, AccessToken);
    end;

    /// <summary>
    /// Request the permissions from a directory admin.
    /// </summary>
    /// <param name="ClientId">The Application (client) ID that the Azure portal – App registrations experience assigned to your app.</param>
    /// <param name="OAuthAuthorityUrl">The identity authorization provider URL.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="HasGrantConsentSucceeded">Exit parameter indicating the success of granting application permissions.</param>
    /// <param name="PermissionGrantError">Exit parameter containing the encountered error in the application permissions grant. This parameter will be empty in case the flow is completed successfuly.</param>
    [NonDebuggable]
    [TryFunction]
    procedure RequestClientCredentialsAdminPermissions(ClientId: Text; OAuthAuthorityUrl: Text; RedirectURL: Text; var HasGrantConsentSucceeded: Boolean; var PermissionGrantError: Text)
    begin
        OAuth2Impl.RequestClientCredentialsAdminPermissions(ClientId, OAuthAuthorityUrl, RedirectURL, HasGrantConsentSucceeded, PermissionGrantError);
    end;

    /// <summary>
    /// Gets the access token via the Client Credentials OAuth2 v1.0 grant flow. 
    /// </summary>
    /// <param name="ClientId">The Application (client) ID that the Azure portal – App registrations experience assigned to your app.</param>
    /// <param name="ClientSecret">The Application (client) secret configured in the Azure Portal - Certificates &amp; Secrets.</param>
    /// <param name="OAuthAuthorityUrl">The identity authorization provider URL.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="ResourceURL">The Application ID of the resource the application is requesting access to. This parameter can be empty.</param>
    /// <param name="AccessToken">Exit parameter containing the access token.</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireTokenWithClientCredentials(ClientId: Text; ClientSecret: Text; OAuthAuthorityUrl: Text; RedirectURL: Text; ResourceURL: Text; var AccessToken: Text)
    begin
        OAuth2Impl.AcquireTokenWithClientCredentials(ClientId, ClientSecret, OAuthAuthorityUrl, RedirectURL, ResourceURL, AccessToken);
    end;

    /// <summary>
    /// Gets the access token via the Client Credentials OAuth2 v2.0 grant flow. 
    /// </summary>
    /// <param name="ClientId">The Application (client) ID that the Azure portal – App registrations experience assigned to your app.</param>
    /// <param name="ClientSecret">The Application (client) secret configured in the Azure Portal - Certificates &amp; Secrets.</param>
    /// <param name="OAuthAuthorityUrl">The identity authorization provider URL.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="Scopes">A list of scopes that you want the user to consent to.</param>
    /// <param name="AccessToken">Exit parameter containing the access token.</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireTokenWithClientCredentials(ClientId: Text; ClientSecret: Text; OAuthAuthorityUrl: Text; RedirectURL: Text; Scopes: List of [Text]; var AccessToken: Text)
    begin
        OAuth2Impl.AcquireTokenWithClientCredentials(ClientId, ClientSecret, OAuthAuthorityUrl, RedirectURL, Scopes, AccessToken);
    end;

    /// <summary>
    /// Gets the access token from cache or a refreshed token via OAuth2 v1.0 protocol. 
    /// </summary>
    /// <param name="ClientId">The Application (client) ID that the Azure portal – App registrations experience assigned to your app.</param>
    /// <param name="ClientSecret">The Application (client) secret configured in the Azure Portal - Certificates &amp; Secrets.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="ResourceURL">The Application ID of the resource the application is requesting access to. This parameter can be empty.</param>
    /// <param name="AccessToken">Exit parameter containing the access token.</param>
    [NonDebuggable]
    [Obsolete('Added OAuthority parameter', '17.0')]
    [TryFunction]
    procedure AcquireAuthorizationCodeTokenFromCache(ClientId: Text; ClientSecret: Text; RedirectURL: Text; ResourceURL: Text; var AccessToken: Text)
    begin
        OAuth2Impl.AcquireTokenFromCache(RedirectURL, ClientId, ClientSecret, ResourceURL, AccessToken);
    end;

    /// <summary>
    /// Gets the access token from cache or a refreshed token via OAuth2 v1.0 protocol. 
    /// </summary>
    /// <param name="ClientId">The Application (client) ID that the Azure portal – App registrations experience assigned to your app.</param>
    /// <param name="ClientSecret">The Application (client) secret configured in the Azure Portal - Certificates &amp; Secrets.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="OAuthAuthorityUrl">The identity authorization provider URL.</param>
    /// <param name="ResourceURL">The Application ID of the resource the application is requesting access to. This parameter can be empty.</param>
    /// <param name="AccessToken">Exit parameter containing the access token.</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireAuthorizationCodeTokenFromCache(ClientId: Text; ClientSecret: Text; RedirectURL: Text; OAuthAuthorityUrl: Text; ResourceURL: Text; var AccessToken: Text)
    begin
        OAuth2Impl.AcquireTokenFromCache(RedirectURL, ClientId, ClientSecret, OAuthAuthorityUrl, ResourceURL, AccessToken);
    end;

    /// <summary>
    /// Gets the access token from cache or a refreshed token via OAuth2 v2.0 protocol. 
    /// </summary>
    /// <param name="ClientId">The Application (client) ID that the Azure portal – App registrations experience assigned to your app.</param>
    /// <param name="ClientSecret">The Application (client) secret configured in the Azure Portal - Certificates &amp; Secrets.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="Scopes">A list of scopes that you want the user to consent to.</param>
    /// <param name="AccessToken">Exit parameter containing the access token.</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireAuthorizationCodeTokenFromCache(ClientId: Text; ClientSecret: Text; RedirectURL: Text; OAuthAuthorityUrl: Text; Scopes: List of [Text]; var AccessToken: Text)
    begin
        OAuth2Impl.AcquireTokenFromCache(RedirectURL, ClientId, ClientSecret, OAuthAuthorityUrl, Scopes, AccessToken);
    end;

    /// <summary>
    /// Gets the access and refresh token via the On-Behalf-Of OAuth2 v1.0 protocol flow. 
    /// </summary>
    /// <param name="OAuthAuthorityUrl">The identity authorization provider URL.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="ResourceURL">The Application ID of the resource the application is requesting access to. This parameter can be empty.</param>
    /// <param name="AccessToken">Exit parameter containing the access token.</param>
    /// <param name="RefreshToken">Exit parameter containing the refresh_token that you acquired when you requested an access token.</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireOnBehalfAccessTokenAndRefreshToken(OAuthAuthorityUrl: Text; RedirectURL: Text; ResourceURL: Text; var AccessToken: Text; var RefreshToken: Text)
    begin
        OAuth2Impl.AcquireOnBehalfAccessTokenAndTokenCache(OAuthAuthorityUrl, RedirectURL, ResourceURL, AccessToken, RefreshToken);
    end;

    /// <summary>
    /// Gets the access token and token cache  via the On-Behalf-Of OAuth2 v1.0 protocol flow. 
    /// </summary>
    /// <param name="OAuthAuthorityUrl">The identity authorization provider URL.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="ResourceURL">The Application ID of the resource the application is requesting access to. This parameter can be empty.</param>
    /// <param name="AccessToken">Exit parameter containing the access token.</param>
    /// <param name="TokenCache">Exit parameter containing the token cache acquired when the access token was requested .</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireOnBehalfAccessTokenAndTokenCache(OAuthAuthorityUrl: Text; RedirectURL: Text; ResourceURL: Text; var AccessToken: Text; var TokenCache: Text)
    begin
        OAuth2Impl.AcquireOnBehalfAccessTokenAndTokenCache(OAuthAuthorityUrl, RedirectURL, ResourceURL, AccessToken, TokenCache);
    end;

    /// <summary>
    /// Gets the access and refresh token via the On-Behalf-Of OAuth2 v2.0 protocol flow. 
    /// </summary>
    /// <param name="OAuthAuthorityUrl">The identity authorization provider URL.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="Scopes">A list of scopes that you want the user to consent to.</param>
    /// <param name="AccessToken">Exit parameter containing the access token.</param>
    /// <param name="RefreshToken">Exit parameter containing the refresh_token that you acquired when you requested an access token.</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireOnBehalfAccessTokenAndRefreshToken(OAuthAuthorityUrl: Text; RedirectURL: Text; Scopes: List of [Text]; var AccessToken: Text; var RefreshToken: Text)
    begin
        OAuth2Impl.AcquireOnBehalfAccessTokenAndTokenCache(OAuthAuthorityUrl, RedirectURL, Scopes, AccessToken, RefreshToken);
    end;

    /// <summary>
    /// Gets the access and refresh token via the On-Behalf-Of OAuth2 v2.0 protocol flow. 
    /// </summary>
    /// <param name="OAuthAuthorityUrl">The identity authorization provider URL.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="Scopes">A list of scopes that you want the user to consent to.</param>
    /// <param name="AccessToken">Exit parameter containing the access token.</param>
    /// <param name="TokenCache">Exit parameter containing the token cache acquired when the access token was requested .</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireOnBehalfAccessTokenAndTokenCache(OAuthAuthorityUrl: Text; RedirectURL: Text; Scopes: List of [Text]; var AccessToken: Text; var TokenCache: Text)
    begin
        OAuth2Impl.AcquireOnBehalfAccessTokenAndTokenCache(OAuthAuthorityUrl, RedirectURL, Scopes, AccessToken, TokenCache);
    end;

    /// <summary>
    /// Gets the access and refresh token via the On-Behalf-Of OAuth2 v1.0 protocol flow. 
    /// </summary>
    /// <param name="ClientId">The Application (client) ID that the Azure portal – App registrations experience assigned to your app.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="ResourceURL">The Application ID of the resource the application is requesting access to. This parameter can be empty.</param>
    /// <param name="RefreshToken">The refresh_token that you acquired when you requested an access token.</param>
    /// <param name="AccessToken">Exit parameter containing the access token.</param>
    /// <param name="NewRefreshToken">Exit parameter containing the new refresh token.</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireOnBehalfOfTokenByRefreshToken(ClientId: Text; RedirectURL: Text; ResourceURL: Text; RefreshToken: Text; var AccessToken: Text; var NewRefreshToken: Text)
    begin
        OAuth2Impl.AcquireOnBehalfOfTokenByTokenCache(ClientId, RedirectURL, ResourceURL, RefreshToken, AccessToken, NewRefreshToken);
    end;

    /// <summary>
    /// Gets the token and token cache via the On-Behalf-Of OAuth2 v1.0 protocol flow. 
    /// </summary>
    /// <param name="LoginHint">The user login hint, i.e. authentication email.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="ResourceURL">The Application ID of the resource the application is requesting access to. This parameter can be empty.</param>
    /// <param name="TokenCache">The token cache acquired when the access token was requested .</param>
    /// <param name="AccessToken">Exit parameter containing the access token.</param>
    /// <param name="NewTokenCache">Exit parameter containing the new token cache.</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireOnBehalfOfTokenByTokenCache(LoginHint: Text; RedirectURL: Text; ResourceURL: Text; TokenCache: Text; var AccessToken: Text; var NewTokenCache: Text)
    begin
        OAuth2Impl.AcquireOnBehalfOfTokenByTokenCache(LoginHint, RedirectURL, ResourceURL, TokenCache, AccessToken, NewTokenCache);
    end;

    /// <summary>
    /// Gets the access and refresh token via the On-Behalf-Of OAuth2 v2.0 protocol flow. 
    /// </summary>
    /// <param name="ClientId">The Application (client) ID that the Azure portal – App registrations experience assigned to your app.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="Scopes">A list of scopes that you want the user to consent to.</param>
    /// <param name="RefreshToken">The refresh_token that you acquired when you requested an access token.</param>
    /// <param name="AccessToken">Exit parameter containing the access token.</param>
    /// <param name="NewRefreshToken">Exit parameter containing the new refresh token.</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireOnBehalfOfTokenByRefreshToken(ClientId: Text; RedirectURL: Text; Scopes: List of [Text]; RefreshToken: Text; var AccessToken: Text; var NewRefreshToken: Text)
    begin
        OAuth2Impl.AcquireOnBehalfOfTokenByTokenCache(ClientId, RedirectURL, Scopes, RefreshToken, AccessToken, NewRefreshToken);
    end;

    /// <summary>
    /// Gets the token and token cache via the On-Behalf-Of OAuth2 v1.0 protocol flow. 
    /// </summary>
    /// <param name="LoginHint">The user login hint, i.e. authentication email.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="Scopes">A list of scopes that you want the user to consent to.</param>
    /// <param name="TokenCache">The token cache acquired when the access token was requested .</param>
    /// <param name="AccessToken">Exit parameter containing the access token.</param>
    /// <param name="NewTokenCache">Exit parameter containing the new token cache.</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireOnBehalfOfTokenByTokenCache(LoginHint: Text; RedirectURL: Text; Scopes: List of [Text]; TokenCache: Text; var AccessToken: Text; var NewTokenCache: Text)
    begin
        OAuth2Impl.AcquireOnBehalfOfTokenByTokenCache(LoginHint, RedirectURL, Scopes, TokenCache, AccessToken, NewTokenCache);
    end;

    /// <summary>
    /// Gets the token and token cache via the On-Behalf-Of OAuth2 v1.0 protocol flow. 
    /// </summary>
    /// <param name="ClientId">The Application (client) ID that the Azure portal - App registrations experience assigned to your app.</param>
    /// <param name="ClientSecret">The Application (client) secret configured in the Azure Portal - Certificates &amp; Secrets.</param>
    /// <param name="LoginHint">The user login hint, i.e. authentication email.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="Scopes">A list of scopes that you want the user to consent to.</param>
    /// <param name="TokenCache">The token cache acquired when the access token was requested .</param>
    /// <param name="AccessToken">Exit parameter containing the access token.</param>
    /// <param name="NewTokenCache">Exit parameter containing the new token cache.</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireOnBehalfOfTokenByTokenCache(ClientId: Text; ClientSecret: Text; LoginHint: Text; RedirectURL: Text; Scopes: List of [Text]; TokenCache: Text; var AccessToken: Text; var NewTokenCache: Text)
    begin
        OAuth2Impl.AcquireOnBehalfOfTokenByTokenCache(ClientId, ClientSecret, LoginHint, RedirectURL, Scopes, TokenCache, AccessToken, NewTokenCache);
    end;

    /// <summary>
    /// Returns the default Business Central redirectURL 
    /// </summary>
    [NonDebuggable]
    procedure GetDefaultRedirectURL(var RedirectUrl: text)
    begin
        RedirectUrl := OAuth2Impl.GetDefaultRedirectURL();
    end;
}