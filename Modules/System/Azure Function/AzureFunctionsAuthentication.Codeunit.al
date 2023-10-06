// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Azure.Functions;

/// <summary>
/// Provides functionality for setting authentication parameters to Azure function.
/// </summary>
codeunit 7800 "Azure Functions Authentication"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    /// <summary>
    /// Creates OAuth2 authentication instance of Azure function interface.
    /// </summary>
    /// <param name="Endpoint">Azure function endpoint</param>
    /// <param name="AuthenticationCode">Azure function authentication code, empty if anonymous.</param>
    /// <param name="ClientId">The Application (client) ID that the Azure portal – App registrations experience assigned to your app.</param>
    /// <param name="ClientSecret">The Application (client) secret configured in the Azure Portal.</param>
    /// <param name="OAuthAuthorityUrl">The identity authorization provider URL.</param>
    /// <param name="RedirectURL">The redirectURL of your app, for azure function this could be empty</param>
    /// <param name="ResourceURL">The Application ID URI</param>
    /// <returns>Instance of Azure function response object.</returns>
    [NonDebuggable]
    procedure CreateOAuth2(Endpoint: Text; AuthenticationCode: Text; ClientId: Text; ClientSecret: Text; OAuthAuthorityUrl: Text; RedirectURL: Text; ResourceURL: Text): Interface "Azure Functions Authentication"
    var
        AzureFunctionsOAuth2: Codeunit "Azure Functions OAuth2";
    begin
        AzureFunctionsOAuth2.SetAuthParameters(Endpoint, AuthenticationCode, ClientId, ClientSecret, OAuthAuthorityUrl, RedirectURL, ResourceURL);
        exit(AzureFunctionsOAuth2);
    end;

    /// <summary>
    /// Creates code authentication instance of Azure function interface.
    /// </summary>
    /// <param name="Endpoint">Azure function endpoint</param>
    /// <param name="AuthenticationCode">Azure function authentication code, empty if anonymous.</param>
    /// <returns>Instance of Azure function response object.</returns>
    [NonDebuggable]
    procedure CreateCodeAuth(Endpoint: Text; AuthenticationCode: Text): Interface "Azure Functions Authentication"
    var
        AzureFunctionsCodeAuth: Codeunit "Azure Functions Code Auth";
    begin
        AzureFunctionsCodeAuth.SetAuthParameters(Endpoint, AuthenticationCode);
        exit(AzureFunctionsCodeAuth);
    end;

}