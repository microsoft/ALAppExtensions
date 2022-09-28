/// <summary>
/// Provides functionality for authorizing HTTP requests made to SharePoint REST API
/// </summary>
codeunit 9142 "SharePoint Auth."
{
    Access = Public;

    /// <summary>
    /// Creates an authorization mechanism with client credentials
    /// </summary>
    /// <param name="AadTenantId">Azure Tenant Id</param>
    /// <param name="ClientId">The Application (client) ID that the Azure portal - App registrations experience assigned to your app.</param>    
    /// <param name="UserName">The user name, i.e. authentication email..</param>
    /// <param name="Credential">The user credential.</param>
    /// <param name="Scope">A scope that you want the user to consent to.</param>
    /// <returns>Codeunit instance implementing authorization interface</returns>
    [NonDebuggable]
    procedure CreateUserCredentials(AadTenantId: Text; ClientId: Text; UserName: Text; Credential: Text; Scope: Text): Interface "SharePoint Authorization";
    var
        Scopes: List of [Text];
    begin
        Scopes.Add(Scope);
        exit(CreateUserCredentials(AadTenantId, ClientId, UserName, Credential, Scopes));
    end;

    /// <summary>
    /// Creates an authorization mechanism with client credentials
    /// </summary>
    /// <param name="AadTenantId">Azure Tenant Id</param>
    /// <param name="ClientId">The Application (client) ID that the Azure portal - App registrations experience assigned to your app.</param>    
    /// <param name="UserName">The user name, i.e. authentication email..</param>
    /// <param name="Credential">The user credential.</param>    
    /// <param name="Scopes">A list of scopes that you want the user to consent to.</param>
    /// <returns>Codeunit instance implementing authorization interface</returns>
    [NonDebuggable]
    procedure CreateUserCredentials(AadTenantId: Text; ClientId: Text; UserName: Text; Credential: Text; Scopes: List of [Text]): Interface "SharePoint Authorization";
    var
        SharePointAuthImpl: Codeunit "SharePoint Auth. - Impl.";
    begin
        exit(SharePointAuthImpl.CreateUserCredentials(AadTenantId, ClientId, UserName, Credential, Scopes));
    end;

    /// <summary>
    /// Creates an authorization mechanism with authentication code
    /// </summary>
    /// <param name="AadTenantId">Azure Tenant Id</param>
    /// <param name="ClientId">The Application (client) ID that the Azure portal - App registrations experience assigned to your app.</param>        
    /// <param name="ClientSecret">The Application (client) secret configured in the "Azure Portal - Certificates &amp; Secrets".</param>    
    /// <param name="Scope">A scope that you want the user to consent to.</param>
    /// <returns>Codeunit instance implementing authorization interface</returns>
    [NonDebuggable]
    procedure CreateAuthorizationCode(AadTenantId: Text; ClientId: Text; ClientSecret: Text; Scope: Text): Interface "SharePoint Authorization";
    var
        Scopes: List of [Text];
    begin
        Scopes.Add(Scope);
        exit(CreateAuthorizationCode(AadTenantId, ClientId, ClientSecret, Scopes));
    end;

    /// <summary>
    /// Creates an authorization mechanism with authentication code
    /// </summary>
    /// <param name="AadTenantId">Azure Tenant Id</param>
    /// <param name="ClientId">The Application (client) ID that the Azure portal - App registrations experience assigned to your app.</param>        
    /// <param name="ClientSecret">The Application (client) secret configured in the "Azure Portal - Certificates &amp; Secrets".</param>    
    /// <param name="Scopes">A list of scopes that you want the user to consent to.</param>
    /// <returns>Codeunit instance implementing authorization interface</returns>
    [NonDebuggable]
    procedure CreateAuthorizationCode(AadTenantId: Text; ClientId: Text; ClientSecret: Text; Scopes: List of [Text]): Interface "SharePoint Authorization";
    var
        SharePointAuthImpl: Codeunit "SharePoint Auth. - Impl.";
    begin
        exit(SharePointAuthImpl.CreateAuthorizationCode(AadTenantId, ClientId, ClientSecret, Scopes));
    end;
}