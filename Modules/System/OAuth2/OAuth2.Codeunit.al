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
    /// Gets the authorization token based on the authorization code via the OAuth2.0 code grant flow. 
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
    /// Gets the authentication token via the On-Behalf-Of OAuth2.0 protocol flow. 
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
    /// Gets the access token via the Client Credentials grant flow. 
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
    /// Gets the access token from the cache. 
    /// </summary>
    /// <param name="ClientId">The Application (client) ID that the Azure portal – App registrations experience assigned to your app.</param>
    /// <param name="ClientSecret">The Application (client) secret configured in the Azure Portal - Certificates &amp; Secrets.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="ResourceURL">The Application ID of the resource the application is requesting access to. This parameter can be empty.</param>
    /// <param name="AccessToken">Exit parameter containing the access token.</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireAuthorizationCodeTokenFromCache(ClientId: Text; ClientSecret: Text; RedirectURL: Text; ResourceURL: Text; var AccessToken: Text)
    begin
        OAuth2Impl.AcquireTokenFromCache(RedirectURL, ClientId, ClientSecret, ResourceURL, AccessToken);
    end;

    /// <summary>
    /// Gets the access and refresh token via the On-Behalf-Of OAuth2.0 protocol flow. 
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
        OAuth2Impl.AcquireOnBehalfAccessTokenAndRefreshToken(OAuthAuthorityUrl, RedirectURL, ResourceURL, AccessToken, RefreshToken);
    end;

    /// <summary>
    /// Gets the access and refresh token via the On-Behalf-Of OAuth2.0 protocol flow. 
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
        OAuth2Impl.AcquireOnBehalfOfTokenByRefreshToken(ClientId, RedirectURL, ResourceURL, RefreshToken, AccessToken, NewRefreshToken);
    end;
}