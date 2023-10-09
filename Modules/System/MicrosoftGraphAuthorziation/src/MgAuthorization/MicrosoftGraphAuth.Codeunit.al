// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality for creating means for authorizing HTTP requests made to Microsoft Graph API.
/// </summary>
codeunit 9130 "Microsoft Graph Auth."
{
    Access = Public;

    /// <summary>
    /// Creates an authorization mechanism with authentication code.
    /// </summary>
    /// <param name="AadTenantId">Azure Active Directory tenant ID</param>
    /// <param name="ClientId">The Application (client) ID that the Azure portal - App registrations experience assigned to your app.</param>        
    /// <param name="ClientSecret">The Application (client) secret configured in the "Azure Portal - Certificates &amp; Secrets".</param>    
    /// <param name="Scope">A scope that you want the user to consent to.</param>
    /// <returns>Codeunit instance implementing authorization interface</returns>
    [NonDebuggable]
    procedure CreateAuthorizationWithClientCredentials(AadTenantId: Text; ClientId: Text; ClientSecret: Text; Scope: Text): Interface "Microsoft Graph Authorization";
    var
        Scopes: List of [Text];
    begin
        Scopes.Add(Scope);
        exit(CreateAuthorizationWithClientCredentials(AadTenantId, ClientId, ClientSecret, Scopes));
    end;

    /// <summary>
    /// Creates an authorization mechanism with authentication code.
    /// </summary>
    /// <param name="AadTenantId">Azure Active Directory tenant ID</param>
    /// <param name="ClientId">The Application (client) ID that the Azure portal - App registrations experience assigned to your app.</param>        
    /// <param name="ClientSecret">The Application (client) secret configured in the "Azure Portal - Certificates &amp; Secrets".</param>    
    /// <param name="Scopes">A list of scopes that you want the user to consent to.</param>
    /// <returns>Codeunit instance implementing authorization interface</returns>
    [NonDebuggable]
    procedure CreateAuthorizationWithClientCredentials(AadTenantId: Text; ClientId: Text; ClientSecret: Text; Scopes: List of [Text]): Interface "Microsoft Graph Authorization";
    var
        MicrosoftGraphAuthImpl: Codeunit "Microsoft Graph Auth. - Impl.";
    begin
        exit(MicrosoftGraphAuthImpl.CreateAuthorizationWithClientCredentials(AadTenantId, ClientId, ClientSecret, Scopes));
    end;
}