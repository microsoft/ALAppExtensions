// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Contains methods supporting authentication via OAuth 1.0 protocol.
/// </summary>
codeunit 1288 OAuth
{
    Access = Public;

    var
        [NonDebuggable]
        OAuthImpl: Codeunit "OAuth Impl.";

    /// <summary>
    /// Gets an OAuth request token from an OAuth provider.
    /// </summary>
    /// <param name="ConsumerKey">The OAuth consumer key. Cannot be null.</param>
    /// <param name="ConsumerSecret">The OAuth consumer secret. Cannot be null.</param>
    /// <param name="RequestTokenUrl">The URL of the OAuth provider. Cannot be null.</param>
    /// <param name="CallbackUrl">Local URL for OAuth callback. Cannot be null.</param>
    /// <param name="AccessTokenKey">The OAuth response token key.</param>
    /// <param name="AccessTokenSecret">The OAuth response token secret.</param>
    [TryFunction]
    [NonDebuggable]
    procedure GetOAuthAccessToken(ConsumerKey: Text; ConsumerSecret: Text; RequestTokenUrl: Text; CallbackUrl: Text; var AccessTokenKey: Text; var AccessTokenSecret: Text)
    begin
        OAuthImpl.GetRequestToken(ConsumerKey, ConsumerSecret, RequestTokenUrl, CallbackUrl, AccessTokenKey, AccessTokenSecret);
    end;

    /// <summary>
    /// Gets an OAuth access token from an OAuth provider.
    /// </summary>
    /// <param name="ConsumerKey">The OAuth consumer key. Cannot be null.</param>
    /// <param name="ConsumerSecret">The OAuth consumer secret. Cannot be null.</param>
    /// <param name="RequestTokenUrl">The URL of the OAuth provider. Cannot be null.</param>
    /// <param name="Verifier">An OAuth verifier string. Cannot be null.</param>
    /// <param name="RequestTokenKey">The OAuth request token key. Cannot be null.</param>
    /// <param name="RequestTokenSecret">The OAuth request token secret. Cannot be null.</param>
    /// <param name="AccessTokenKey">Exit parameter containing the OAuth response token key.</param>
    /// <param name="AccessTokenSecret">Exit parameter containing the OAuth response token secret.</param>
    [TryFunction]
    [NonDebuggable]
    procedure GetOAuthAccessToken(ConsumerKey: Text; ConsumerSecret: Text; RequestTokenUrl: Text; Verifier: Text; RequestTokenKey: Text; RequestTokenSecret: Text; var AccessTokenKey: Text; var AccessTokenSecret: Text)
    begin
        OAuthImpl.GetAccessToken(ConsumerKey, ConsumerSecret, RequestTokenUrl, Verifier, RequestTokenKey, RequestTokenSecret, AccessTokenKey, AccessTokenSecret);
    end;

    /// <summary>
    /// Gets the authorization header for an OAuth specific REST call.
    /// </summary>
    /// <param name="ConsumerKey">The OAuth consumer key. Cannot be null.</param>
    /// <param name="ConsumerSecret">The OAuth consumer secret. Cannot be null.</param>
    /// <param name="RequestTokenKey">The OAuth response token key. Cannot be null.</param>
    /// <param name="RequestTokenSecret">The OAuth response token secret. Cannot be null.</param>
    /// <param name="RequestUrl">The REST URL. Cannot be null.</param>
    /// <param name="RequestMethod">The REST method call with capital letters(POST, GET, PUT, PATCH, DELETE).</param>
    /// <param name="AuthorizationHeader">Exit parameter containing the requested OAuth specific authorization header.</param>
    [TryFunction]
    [NonDebuggable]
    procedure GetAuthorizationHeader(ConsumerKey: Text; ConsumerSecret: Text; RequestTokenKey: Text; RequestTokenSecret: Text; RequestUrl: Text; RequestMethod: Enum "Http Request Type"; var AuthorizationHeader: Text)
    begin
        OAuthImpl.GetAuthorizationHeader(ConsumerKey, ConsumerSecret, RequestTokenKey, RequestTokenSecret, RequestUrl, RequestMethod, AuthorizationHeader);
    end;

}

