// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.Authentication;

/// <summary>
/// Contains methods supporting authentication via OAuth 2.0 protocol.
/// </summary>
codeunit 501 OAuth2
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        [NonDebuggable]
        OAuth2Impl: Codeunit OAuth2Impl;

    /// <summary>
    /// Gets the authorization token based on the authorization code via the OAuth2 v1.0 code grant flow.
    /// </summary>
    /// <param name="ClientId">The Application (client) ID that the "Azure portal – App registrations" experience assigned to your app.</param>
    /// <param name="Certificate">The Base64-encoded certificate for the Application (client) configured in the "Azure Portal - Certificates &amp; Secrets".</param>
    /// <param name="OAuthAuthorityUrl">The identity authorization provider URL.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="ResourceURL">The Application ID of the resource the application is requesting access to. This parameter can be empty.</param>
    /// <param name="PromptInteraction">Indicates the type of user interaction that is required.</param>
    /// <param name="AccessToken">Exit parameter containing the access token. When this parameter is empty, check the AuthCodeErr for a description of the error.</param>
    /// <param name="AuthCodeErr">Exit parameter containing the encountered error in the authorization code grant flow. This parameter will be empty in case the token is aquired successfuly.</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireTokenByAuthorizationCodeWithCertificate(ClientId: Text; Certificate: Text; OAuthAuthorityUrl: Text; RedirectURL: Text; ResourceURL: Text; PromptInteraction: Enum "Prompt Interaction"; var AccessToken: Text; var AuthCodeErr: Text)
    begin
        OAuth2Impl.AcquireTokenByAuthorizationCodeWithCertificate(ClientId, Certificate, OAuthAuthorityUrl, RedirectURL, ResourceURL, PromptInteraction, AccessToken, AuthCodeErr);
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
    /// Gets the authorization token based on the authorization code via the OAuth2 v2.0 code grant flow.
    /// </summary>
    /// <param name="ClientId">The Application (client) ID that the "Azure portal – App registrations" experience assigned to your app.</param>
    /// <param name="Certificate">The Base64-encoded certificate for the application (client) configured in the "Azure Portal - Certificates &amp; Secrets".</param>
    /// <param name="OAuthAuthorityUrl">The identity authorization provider URL.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="Scopes">A list of scopes that you want the user to consent to.</param>
    /// <param name="PromptInteraction">Indicates the type of user interaction that is required.</param>
    /// <param name="AccessToken">Exit parameter containing the access token. When this parameter is empty, check the AuthCodeErr for a description of the error.</param>
    /// <param name="AuthCodeErr">Exit parameter containing the encountered error in the authorization code grant flow. This parameter will be empty in case the token is aquired successfuly.</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireTokenByAuthorizationCodeWithCertificate(ClientId: Text; Certificate: Text; OAuthAuthorityUrl: Text; RedirectURL: Text; Scopes: List of [Text]; PromptInteraction: Enum "Prompt Interaction"; var AccessToken: Text; var AuthCodeErr: Text)
    begin
        OAuth2Impl.AcquireTokenByAuthorizationCodeWithCertificate(ClientId, Certificate, OAuthAuthorityUrl, RedirectURL, Scopes, PromptInteraction, AccessToken, AuthCodeErr);
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
    /// <param name="IdToken">Exit parameter containing the id token.</param>
    /// <param name="AuthCodeErr">Exit parameter containing the encountered error in the authorization code grant flow. This parameter will be empty in case the token is aquired successfuly.</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireTokensByAuthorizationCode(ClientId: Text; ClientSecret: Text; OAuthAuthorityUrl: Text; RedirectURL: Text; Scopes: List of [Text]; PromptInteraction: Enum "Prompt Interaction"; var AccessToken: Text; var IdToken: Text; var AuthCodeErr: Text)
    begin
        OAuth2Impl.AcquireTokensByAuthorizationCode(ClientId, ClientSecret, OAuthAuthorityUrl, RedirectURL, Scopes, PromptInteraction, AccessToken, IdToken, AuthCodeErr);
    end;

    /// <summary>
    /// Gets the authorization token based on the authorization code via the OAuth2 v2.0 code grant flow.
    /// </summary>
    /// <param name="ClientId">The Application (client) ID that the "Azure portal – App registrations" experience assigned to your app.</param>
    /// <param name="Certificate">The Base64-encoded certificate for the application (client) configured in the "Azure Portal - Certificates &amp; Secrets".</param>
    /// <param name="OAuthAuthorityUrl">The identity authorization provider URL.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="Scopes">A list of scopes that you want the user to consent to.</param>
    /// <param name="PromptInteraction">Indicates the type of user interaction that is required.</param>
    /// <param name="AccessToken">Exit parameter containing the access token. When this parameter is empty, check the AuthCodeErr for a description of the error.</param>
    /// <param name="IdToken">Exit parameter containing the id token.</param>
    /// <param name="AuthCodeErr">Exit parameter containing the encountered error in the authorization code grant flow. This parameter will be empty in case the token is aquired successfuly.</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireTokensByAuthorizationCodeWithCertificate(ClientId: Text; Certificate: Text; OAuthAuthorityUrl: Text; RedirectURL: Text; Scopes: List of [Text]; PromptInteraction: Enum "Prompt Interaction"; var AccessToken: Text; var IdToken: Text; var AuthCodeErr: Text)
    begin
        OAuth2Impl.AcquireTokensByAuthorizationCodeWithCertificate(ClientId, Certificate, OAuthAuthorityUrl, RedirectURL, Scopes, PromptInteraction, AccessToken, IdToken, AuthCodeErr);
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
    /// Gets the access token and token cache state with authorization code flow.
    /// </summary>
    /// <param name="ClientId">The Application (client) ID that the "Azure portal – App registrations" experience assigned to your app.</param>
    /// <param name="Certificate">The Base64-encoded certificate for the application (client) configured in the "Azure Portal - Certificates &amp; Secrets".</param>
    /// <param name="OAuthAuthorityUrl">The identity authorization provider URL.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="Scopes">A list of scopes that you want the user to consent to.</param>
    /// <param name="PromptInteraction">Indicates the type of user interaction that is required.</param>
    /// <param name="AccessToken">Exit parameter containing the access token. When this parameter is empty, check the Error for a description of the error.</param>
    /// <param name="TokenCache">Exit parameter containing the token cache acquired when the access token was requested.</param>
    /// <param name="Error">Exit parameter containing the encountered error in the authorization code grant flow. This parameter will be empty in case the token is aquired successfuly.</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireTokenAndTokenCacheByAuthorizationCodeWithCertificate(ClientId: Text; Certificate: Text; OAuthAuthorityUrl: Text; RedirectURL: Text; Scopes: List of [Text]; PromptInteraction: Enum "Prompt Interaction"; var AccessToken: Text; var TokenCache: Text; var Error: Text)
    begin
        OAuth2Impl.AcquireTokenAndTokenCacheByAuthorizationCodeWithCertificate(ClientId, Certificate, OAuthAuthorityUrl, RedirectURL, Scopes, PromptInteraction, AccessToken, TokenCache, Error);
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
    /// <param name="IdToken">Exit parameter containing the id token.</param>
    /// <param name="TokenCache">Exit parameter containing the token cache acquired when the access token was requested.</param>
    /// <param name="Error">Exit parameter containing the encountered error in the authorization code grant flow. This parameter will be empty in case the token is aquired successfuly.</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireTokensAndTokenCacheByAuthorizationCode(ClientId: Text; ClientSecret: Text; OAuthAuthorityUrl: Text; RedirectURL: Text; Scopes: List of [Text]; PromptInteraction: Enum "Prompt Interaction"; var AccessToken: Text; var IdToken: Text; var TokenCache: Text; var Error: Text)
    begin
        OAuth2Impl.AcquireTokensAndTokenCacheByAuthorizationCode(ClientId, ClientSecret, OAuthAuthorityUrl, RedirectURL, Scopes, PromptInteraction, AccessToken, IdToken, TokenCache, Error);
    end;

    /// <summary>
    /// Gets the access token and token cache state with authorization code flow.
    /// </summary>
    /// <param name="ClientId">The Application (client) ID that the "Azure portal – App registrations" experience assigned to your app.</param>
    /// <param name="Certificate">The Base64-encoded certificate for the application (client) configured in the "Azure Portal - Certificates &amp; Secrets".</param>
    /// <param name="OAuthAuthorityUrl">The identity authorization provider URL.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="Scopes">A list of scopes that you want the user to consent to.</param>
    /// <param name="PromptInteraction">Indicates the type of user interaction that is required.</param>
    /// <param name="AccessToken">Exit parameter containing the access token. When this parameter is empty, check the Error for a description of the error.</param>
    /// <param name="IdToken">Exit parameter containing the id token.</param>
    /// <param name="TokenCache">Exit parameter containing the token cache acquired when the access token was requested.</param>
    /// <param name="Error">Exit parameter containing the encountered error in the authorization code grant flow. This parameter will be empty in case the token is aquired successfuly.</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireTokensAndTokenCacheByAuthorizationCodeWithCertificate(ClientId: Text; Certificate: Text; OAuthAuthorityUrl: Text; RedirectURL: Text; Scopes: List of [Text]; PromptInteraction: Enum "Prompt Interaction"; var AccessToken: Text; var IdToken: Text; var TokenCache: Text; var Error: Text)
    begin
        OAuth2Impl.AcquireTokensAndTokenCacheByAuthorizationCodeWithCertificate(ClientId, Certificate, OAuthAuthorityUrl, RedirectURL, Scopes, PromptInteraction, AccessToken, IdToken, TokenCache, Error);
    end;

#pragma warning disable AS0022

    /// <summary>
    /// Gets the authentication token via the On-Behalf-Of OAuth2 v2.0 protocol flow.
    /// </summary>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="Scopes">A list of scopes that you want the user to consent to.</param>
    /// <param name="AccessToken">Exit parameter containing the access token.</param>
    [NonDebuggable]
    [Scope('OnPrem')]
    [TryFunction]
    procedure AcquireOnBehalfOfToken(RedirectURL: Text; Scopes: List of [Text]; var AccessToken: Text)
    begin
        OAuth2Impl.AcquireOnBehalfOfToken(RedirectURL, Scopes, AccessToken);
    end;

    /// <summary>
    /// Gets the authentication token via the On-Behalf-Of OAuth2 v2.0 protocol flow.
    /// </summary>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="Scopes">A list of scopes that you want the user to consent to.</param>
    /// <param name="AccessToken">Exit parameter containing the access token.</param>
    /// <param name="IdToken">Exit parameter containing the id token.</param>
    [NonDebuggable]
    [Scope('OnPrem')]
    [TryFunction]
    procedure AcquireOnBehalfOfTokens(RedirectURL: Text; Scopes: List of [Text]; var AccessToken: Text; var IdToken: Text)
    begin
        OAuth2Impl.AcquireOnBehalfOfTokens(RedirectURL, Scopes, AccessToken, IdToken);
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
    /// <param name="Certificate">The Base64-encoded certificate for the Application (client) configured in the Azure Portal - Certificates &amp; Secrets.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="OAuthAuthorityUrl">The identity authorization provider URL.</param>
    /// <param name="ResourceURL">The Application ID of the resource the application is requesting access to. This parameter can be empty.</param>
    /// <param name="AccessToken">Exit parameter containing the access token.</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireAuthorizationCodeTokenFromCacheWithCertificate(ClientId: Text; Certificate: Text; RedirectURL: Text; OAuthAuthorityUrl: Text; ResourceURL: Text; var AccessToken: Text)
    begin
        OAuth2Impl.AcquireTokenFromCacheWithCertificate(RedirectURL, ClientId, Certificate, OAuthAuthorityUrl, ResourceURL, AccessToken);
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
    /// Gets the access token from cache or a refreshed token via OAuth2 v2.0 protocol.
    /// </summary>
    /// <param name="ClientId">The Application (client) ID that the Azure portal – App registrations experience assigned to your app.</param>
    /// <param name="ClientSecret">The Application (client) secret configured in the Azure Portal - Certificates &amp; Secrets.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="Scopes">A list of scopes that you want the user to consent to.</param>
    /// <param name="AccessToken">Exit parameter containing the access token.</param>
    /// <param name="IdToken">Exit parameter containing the id token.</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireTokensFromCache(ClientId: Text; ClientSecret: Text; RedirectURL: Text; OAuthAuthorityUrl: Text; Scopes: List of [Text]; var AccessToken: Text; var IdToken: Text)
    begin
        OAuth2Impl.AcquireTokensFromCache(RedirectURL, ClientId, ClientSecret, OAuthAuthorityUrl, Scopes, AccessToken, IdToken);
    end;

    /// <summary>
    /// Gets the access token from cache or a refreshed token via OAuth2 v2.0 protocol.
    /// </summary>
    /// <param name="ClientId">The Application (client) ID that the Azure portal – App registrations experience assigned to your app.</param>
    /// <param name="Certificate">The Base64-encoded certificate for the Application (client) configured in the Azure Portal - Certificates &amp; Secrets.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="Scopes">A list of scopes that you want the user to consent to.</param>
    /// <param name="AccessToken">Exit parameter containing the access token.</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireAuthorizationCodeTokenFromCacheWithCertificate(ClientId: Text; Certificate: Text; RedirectURL: Text; OAuthAuthorityUrl: Text; Scopes: List of [Text]; var AccessToken: Text)
    begin
        OAuth2Impl.AcquireTokenFromCacheWithCertificate(RedirectURL, ClientId, Certificate, OAuthAuthorityUrl, Scopes, AccessToken);
    end;

    /// <summary>
    /// Gets the access token from cache or a refreshed token via OAuth2 v2.0 protocol.
    /// </summary>
    /// <param name="ClientId">The Application (client) ID that the Azure portal – App registrations experience assigned to your app.</param>
    /// <param name="Certificate">The Base64-encoded certificate for the Application (client) configured in the Azure Portal - Certificates &amp; Secrets.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="Scopes">A list of scopes that you want the user to consent to.</param>
    /// <param name="AccessToken">Exit parameter containing the access token.</param>
    /// <param name="IdToken">Exit parameter containing the id token.</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireTokensFromCacheWithCertificate(ClientId: Text; Certificate: Text; RedirectURL: Text; OAuthAuthorityUrl: Text; Scopes: List of [Text]; var AccessToken: Text; var IdToken: Text)
    begin
        OAuth2Impl.AcquireTokensFromCacheWithCertificate(RedirectURL, ClientId, Certificate, OAuthAuthorityUrl, Scopes, AccessToken, IdToken);
    end;

    /// <summary>
    /// Gets the access token via OAuth2 v2.0 protocol, authenticating as a service principal (as the app whose credentials you are providing).
    /// </summary>
    /// <param name="ClientId">The Application (client) ID that the Azure portal – App registrations experience assigned to your app.</param>
    /// <param name="Certificate">The Base64-encoded certificate for the Application (client) configured in the Azure Portal - Certificates &amp; Secrets.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="Scopes">A list of scopes that you want the user to consent to.</param>
    /// <param name="AccessToken">Exit parameter containing the access token.</param>
    /// <param name="IdToken">Exit parameter containing the id token.</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireTokensWithCertificate(ClientId: Text; Certificate: Text; RedirectURL: Text; OAuthAuthorityUrl: Text; Scopes: List of [Text]; var AccessToken: Text; var IdToken: Text)
    begin
        OAuth2Impl.AcquireTokensWithCertificate(RedirectURL, ClientId, Certificate, OAuthAuthorityUrl, Scopes, AccessToken, IdToken);
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
    [Scope('OnPrem')]
    [TryFunction]
    procedure AcquireOnBehalfAccessTokenAndTokenCache(OAuthAuthorityUrl: Text; RedirectURL: Text; Scopes: List of [Text]; var AccessToken: Text; var TokenCache: Text)
    begin
        OAuth2Impl.AcquireOnBehalfAccessTokenAndTokenCache(OAuthAuthorityUrl, RedirectURL, Scopes, AccessToken, TokenCache);
    end;

    /// <summary>
    /// Gets the access and refresh token via the On-Behalf-Of OAuth2 v2.0 protocol flow.
    /// </summary>
    /// <param name="OAuthAuthorityUrl">The identity authorization provider URL.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="Scopes">A list of scopes that you want the user to consent to.</param>
    /// <param name="AccessToken">Exit parameter containing the access token.</param>
    /// <param name="IdToken">Exit parameter containing the id token.</param>
    /// <param name="TokenCache">Exit parameter containing the token cache acquired when the access token was requested .</param>
    [NonDebuggable]
    [Scope('OnPrem')]
    [TryFunction]
    procedure AcquireOnBehalfTokensAndTokenCache(OAuthAuthorityUrl: Text; RedirectURL: Text; Scopes: List of [Text]; var AccessToken: Text; var IdToken: Text; var TokenCache: Text)
    begin
        OAuth2Impl.AcquireOnBehalfTokensAndTokenCache(OAuthAuthorityUrl, RedirectURL, Scopes, AccessToken, IdToken, TokenCache);
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
    [Scope('OnPrem')]
    [TryFunction]
    procedure AcquireOnBehalfOfTokenByTokenCache(LoginHint: Text; RedirectURL: Text; Scopes: List of [Text]; TokenCache: Text; var AccessToken: Text; var NewTokenCache: Text)
    begin
        OAuth2Impl.AcquireOnBehalfOfTokenByTokenCache(LoginHint, RedirectURL, Scopes, TokenCache, AccessToken, NewTokenCache);
    end;

    /// <summary>
    /// Gets the token and token cache via the On-Behalf-Of OAuth2 v1.0 protocol flow.
    /// </summary>
    /// <param name="LoginHint">The user login hint, i.e. authentication email.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="Scopes">A list of scopes that you want the user to consent to.</param>
    /// <param name="TokenCache">The token cache acquired when the access token was requested .</param>
    /// <param name="AccessToken">Exit parameter containing the access token.</param>
    /// <param name="IdToken">Exit parameter containing the id token.</param>
    /// <param name="NewTokenCache">Exit parameter containing the new token cache.</param>
    [NonDebuggable]
    [Scope('OnPrem')]
    [TryFunction]
    procedure AcquireOnBehalfOfTokensByTokenCache(LoginHint: Text; RedirectURL: Text; Scopes: List of [Text]; TokenCache: Text; var AccessToken: Text; var IdToken: Text; var NewTokenCache: Text)
    begin
        OAuth2Impl.AcquireOnBehalfOfTokensByTokenCache(LoginHint, RedirectURL, Scopes, TokenCache, AccessToken, IdToken, NewTokenCache);
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
    /// Gets the token and token cache via the On-Behalf-Of OAuth2 v1.0 protocol flow.
    /// </summary>
    /// <param name="ClientId">The Application (client) ID that the Azure portal - App registrations experience assigned to your app.</param>
    /// <param name="ClientSecret">The Application (client) secret configured in the Azure Portal - Certificates &amp; Secrets.</param>
    /// <param name="LoginHint">The user login hint, i.e. authentication email.</param>
    /// <param name="RedirectURL">The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.</param>
    /// <param name="Scopes">A list of scopes that you want the user to consent to.</param>
    /// <param name="TokenCache">The token cache acquired when the access token was requested .</param>
    /// <param name="AccessToken">Exit parameter containing the access token.</param>
    /// <param name="IdToken">Exit parameter containing the id token.</param>
    /// <param name="NewTokenCache">Exit parameter containing the new token cache.</param>
    [NonDebuggable]
    [TryFunction]
    procedure AcquireOnBehalfOfTokensByTokenCache(ClientId: Text; ClientSecret: Text; LoginHint: Text; RedirectURL: Text; Scopes: List of [Text]; TokenCache: Text; var AccessToken: Text; var IdToken: Text; var NewTokenCache: Text)
    begin
        OAuth2Impl.AcquireOnBehalfOfTokensByTokenCache(ClientId, ClientSecret, LoginHint, RedirectURL, Scopes, TokenCache, AccessToken, IdToken, NewTokenCache);
    end;

#if not CLEAN21
    /// <summary>
    /// Gets the token with username and password.
    /// </summary>
    /// <param name="OAuthAuthorityUrl">The identity authorization provider URL.</param>
    /// <param name="ClientId">The Application (client) ID that the Azure portal - App registrations experience assigned to your app.</param>
    /// <param name="Scopes">A list of scopes that you want the user to consent to.</param>
    /// <param name="UserName">The user name, i.e. authentication email..</param>
    /// <param name="Credential">The user credential.</param>
    /// <param name="AccessToken">Exit parameter containing the access token.</param>
    /// <param name="IdToken">Exit parameter containing the id token.</param>
    [NonDebuggable]
    [Obsolete('AcquireTokensWithUserCredentials is deprecated and will be removed in version 23.0. We recommend that you switch to any of the remaining non-deprecated functions in this class to acquire tokens already now.', '21.0')]
    [TryFunction]
    procedure AcquireTokensWithUserCredentials(OAuthAuthorityUrl: Text; ClientId: Text; Scopes: List of [Text]; UserName: Text; Credential: Text; var AccessToken: Text; var IdToken: Text)
    begin
        OAuth2Impl.AcquireTokensWithUserCredentials(OAuthAuthorityUrl, ClientId, Scopes, UserName, Credential, AccessToken, IdToken);
    end;
#endif

#if not CLEAN21
    /// <summary>
    /// Gets the token with username and password.
    /// </summary>
    /// <param name="OAuthAuthorityUrl">The identity authorization provider URL.</param>
    /// <param name="Scopes">A list of scopes that you want the user to consent to.</param>
    /// <param name="UserName">The user name, i.e. authentication email..</param>
    /// <param name="Credential">The user credential.</param>
    /// <param name="AccessToken">Exit parameter containing the access token.</param>
    /// <param name="IdToken">Exit parameter containing the id token.</param>
    [NonDebuggable]
    [Obsolete('AcquireTokensWithUserCredentials is deprecated and will be removed in version 23.0. We recommend that you switch to any of the remaining non-deprecated functions in this class to acquire tokens already now', '21.0')]
    [Scope('OnPrem')]
    [TryFunction]
    procedure AcquireTokensWithUserCredentials(OAuthAuthorityUrl: Text; Scopes: List of [Text]; UserName: Text; Credential: Text; var AccessToken: Text; var IdToken: Text)
    begin
        OAuth2Impl.AcquireTokensWithUserCredentials(OAuthAuthorityUrl, Scopes, UserName, Credential, AccessToken, IdToken);
    end;
#endif
#pragma warning restore AS0022

    /// <summary>
    /// Get the last error message that happened during acquiring of an access token.
    /// </summary>
    /// <returns>The last error message that happened during acquiring of an access token.</returns>
    procedure GetLastErrorMessage(): Text
    begin
        exit(OAuth2Impl.GetLastErrorMessage());
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