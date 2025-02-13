// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using System.Azure.Identity;
using System.Reflection;
using System.Security.Authentication;
using System.Azure.KeyVault;
using System.Environment;

codeunit 6390 "SignUp Authentication"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    #region variables
    var
        SignUpConnectionSetup: Record "SignUp Connection Setup";
        SignUpHelpersImpl: Codeunit "SignUp Helpers";
        BearerTxt: Label 'Bearer %1', Comment = '%1 = text value', Locked = true;
        AuthURLTxt: Label 'https://login.microsoftonline.com/%1/oauth2/token', Comment = '%1 Entra Tenant Id', Locked = true;
        AuthTemplateTxt: Label 'grant_type=client_credentials&client_id=%1&client_secret=%2&resource=%3', Locked = true;
        ProdRootTenantIdTxt: Label '0d725623-dc26-484f-a090-b09d2003d092', Locked = true;
        ProdClientTenantIdTxt: Label 'eef4ab2c-2b10-4380-bf4b-214157971162', Locked = true;
        ProdServiceAPITxt: Label 'https://edoc.exflow.io', Locked = true;
        ErrorTokenLbl: Label 'Unable to fetch a root token.';
        ErrorUnableToCreateClientCredentialsLbl: Label 'Unable to create client credentials.';
        ClientIdTxt: Label 'clientId', Locked = true;
        ClientSecretTxt: Label 'clientSecret', Locked = true;
        SignupRootUrlTxt: Label 'signup-root-url', Locked = true;
        SignUpRootIdTxt: Label 'signup-root-id', Locked = true;
        SignUpRootSecretTxt: Label 'signup-root-secret', Locked = true;
        SignUpRootTenantTxt: Label 'signup-root-tenant', Locked = true;
        SignUpClientTenantTxt: Label 'signup-client-tenant', Locked = true;
        SignUpServiceAPITxt: Label 'signup-service-api', Locked = true;
        SignUpAccessTokenKeyTxt: Label '{E45BB975-E67B-4A87-AC24-D409A5EF8301}', Locked = true;
        ContentTypeTxt: Label 'Content-Type', Locked = true;
        FormUrlEncodedTxt: Label 'application/x-www-form-urlencoded', Locked = true;
        AccessTokenTxt: Label 'access_token', Locked = true;

    #endregion

    #region public methods

    /// <summary>
    /// The method initializes the connection setup.
    /// </summary>
    procedure InitConnectionSetup()
    begin
        if this.SignUpConnectionSetup.Get() then
            exit;

        this.SignUpConnectionSetup."Authentication URL" := this.AuthURLTxt;
        this.SignUpConnectionSetup."Service URL" := this.GetServiceApi();
        this.StorageSet(this.SignUpConnectionSetup."Root Tenant", this.GetRootTenant());
        this.StorageSet(this.SignUpConnectionSetup."Client Tenant", this.GetClientTenant());
        this.SignUpConnectionSetup.Insert();
    end;

    /// <summary>
    /// The method returns the onboarding URL.
    /// </summary>
    /// <returns>Onboarding URL</returns>
    procedure GetRootOnboardingUrl(): Text
    begin
        exit(this.GetRootUrl() + '/supm/landingpage?EntraTenantId=' + this.GetBCInstanceIdentifier());
    end;

    /// <summary>
    /// The method creates the client credentials.
    /// </summary>
    [NonDebuggable]
    procedure CreateClientCredentials()
    var
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        ClientId, Response : Text;
        ClientSecret: SecretText;
    begin
        if not this.GetClientCredentials(HttpRequestMessage, HttpResponseMessage) then
            this.ShowErrorMessage(HttpResponseMessage);

        if not HttpResponseMessage.Content.ReadAs(Response) then
            exit;

        ClientId := this.SignUpHelpersImpl.GetJsonValueFromText(Response, this.ClientIdTxt);
        ClientSecret := this.SignUpHelpersImpl.GetJsonValueFromText(Response, this.ClientSecretTxt);

        if (ClientId <> '') and (not ClientSecret.IsEmpty()) then
            this.SaveClientCredentials(ClientId, ClientSecret);
    end;

    /// <summary>
    /// The method returns the bearer authentication text.
    /// </summary>
    /// <returns>Bearer authentication token</returns>
    procedure GetBearerAuthToken(): SecretText;
    begin
        exit(SecretStrSubstNo(this.BearerTxt, this.GetAuthToken()));
    end;

    /// <summary>
    /// The method returns the root bearer authentication token.
    /// </summary>
    /// <returns>Root bearer authentication token</returns>   
    procedure GetRootBearerAuthToken(): SecretText;
    begin
        exit(SecretStrSubstNo(this.BearerTxt, this.GetRootAuthToken()));
    end;

    /// <summary>
    /// The mehod saves the token to the storage.
    /// </summary>
    /// <param name="TokenKey">Token Key</param>
    /// <param name="Value">Token</param>
    [NonDebuggable]
    procedure StorageSet(var TokenKey: Guid; Value: Text): Boolean
    var
        ModuleDataScope: DataScope;
    begin
        ModuleDataScope := ModuleDataScope::Module;
        this.ValidateValueKey(TokenKey);

        if Value = '' then begin
            if IsolatedStorage.Contains(TokenKey, ModuleDataScope) then
                exit(IsolatedStorage.Delete(TokenKey, ModuleDataScope))
        end else
            exit(IsolatedStorage.Set(TokenKey, Value, ModuleDataScope));
    end;

    /// <summary>
    /// The mehod saves the token to the storage.
    /// </summary>
    /// <param name="TokenKey">Token Key</param>
    /// <param name="Value">Token</param>
    [NonDebuggable]
    procedure StorageSet(var TokenKey: Guid; Value: SecretText): Boolean
    begin
        exit(this.StorageSet(TokenKey, Value, DataScope::Module));
    end;

    /// <summary>
    /// The method returns BC instance identifier.
    /// </summary>
    /// <returns>Identifier</returns>
    procedure GetBCInstanceIdentifier() Identifier: Text
    var
        AADTenantID, AADDomainName : Text;
    begin
        if this.GetAADTenantInformation(AADTenantID, AADDomainName) then
            Identifier := AADTenantID;
    end;

    /// <summary>
    /// The method returns the root URL.
    /// </summary>
    /// <returns></returns>
    [NonDebuggable]
    procedure GetRootUrl() ReturnValue: Text
    begin
        if this.FetchSecretFromKeyVault(this.SignupRootUrlTxt, ReturnValue) then
            exit;

        if not this.SignUpConnectionSetup.GetSetup() then
            exit;

        this.SignUpConnectionSetup.TestField("Root Market URL");
        ReturnValue := this.SignUpConnectionSetup."Root Market URL";
    end;

    #endregion

    #region local methods

    local procedure GetAuthToken() AccessToken: SecretText;
    var
        HttpError: Text;
    begin
        AccessToken := this.StorageGet(this.SignUpAccessTokenKeyTxt, DataScope::Module);

        if this.SignUpHelpersImpl.IsTokenValid(AccessToken) then
            exit;

        if not this.RefreshAccessToken(HttpError) then
            Error(HttpError);

        exit(this.StorageGet(this.SignUpAccessTokenKeyTxt, DataScope::Module));
    end;

    local procedure GetRootAuthToken() ReturnValue: SecretText;
    begin
        if not this.GetRootAccessToken(ReturnValue) then
            Error(this.ErrorTokenLbl);
    end;

    local procedure SaveClientCredentials(ClientId: Text; ClientSecret: SecretText)
    begin
        Clear(this.SignUpConnectionSetup);

        this.SignUpConnectionSetup.GetSetup();
        this.StorageSet(this.SignUpConnectionSetup."Client ID", ClientId);
        this.StorageSet(this.SignUpConnectionSetup."Client Secret", ClientSecret);
        this.SignUpConnectionSetup.Modify();

        Clear(this.SignUpConnectionSetup);
    end;

    [NonDebuggable]
    local procedure GetClientCredentials(var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        SignUpAPIRequests: Codeunit "SignUp API Requests";
    begin
        SignUpAPIRequests.GetMarketPlaceCredentials(HttpRequestMessage, HttpResponseMessage);

        if not HttpResponseMessage.IsSuccessStatusCode() then
            exit;

        exit(this.SignUpHelpersImpl.ParseJsonString(HttpResponseMessage.Content) <> '');
    end;

    [NonDebuggable]
    local procedure RefreshAccessToken(var HttpError: Text): Boolean;
    var
        SecretToken: SecretText;
    begin
        if not this.GetClientAccessToken(SecretToken) then begin
            HttpError := GetLastErrorText();
            exit;
        end;

        exit(this.SaveSignUpAccessToken(DataScope::Module, SecretToken));
    end;

    [NonDebuggable]
    local procedure GetRootAccessToken(var AccessToken: SecretText): Boolean
    var
        ModuleDataScope: DataScope;
    begin
        ModuleDataScope := ModuleDataScope::Module;
        this.SignUpConnectionSetup.GetSetup();

        exit(this.GetAccessToken(AccessToken, this.GetRootId(),
                                                this.GetRootSecret(),
                                                this.StorageGetText(this.SignUpConnectionSetup."Root Tenant", ModuleDataScope)));
    end;

    [NonDebuggable]
    local procedure GetClientAccessToken(var AccessToken: SecretText): Boolean
    var
        ModuleDataScope: DataScope;
    begin
        ModuleDataScope := ModuleDataScope::Module;
        this.SignUpConnectionSetup.GetSetup();

        exit(this.GetAccessToken(AccessToken, this.StorageGetText(this.SignUpConnectionSetup."Client ID", ModuleDataScope),
                                                this.StorageGet(this.SignUpConnectionSetup."Client Secret", ModuleDataScope),
                                                this.StorageGetText(this.SignUpConnectionSetup."Client Tenant", ModuleDataScope)));
    end;

    [NonDebuggable]
    local procedure GetAccessToken(var AccessToken: SecretText; ClientId: Text; ClientSecret: SecretText; ClientTenant: Text): Boolean
    var
        TypeHelper: Codeunit "Type Helper";
        HttpRequestMessage: HttpRequestMessage;
        Response: Text;
    begin
        Clear(AccessToken);
        this.SignUpConnectionSetup.GetSetup();
        this.SignUpConnectionSetup.TestField("Authentication URL");

        HttpRequestMessage := this.PrepareRequest(SecretStrSubstNo(this.AuthTemplateTxt, TypeHelper.UriEscapeDataString(ClientId), ClientSecret, TypeHelper.UriEscapeDataString(ClientId)),
                                                  StrSubstNo(this.SignUpConnectionSetup."Authentication URL", ClientTenant));

        if not this.SendRequest(HttpRequestMessage, Response) then
            exit;

        AccessToken := this.SignUpHelpersImpl.GetJsonValueFromText(Response, this.AccessTokenTxt);
        exit(not AccessToken.IsEmpty());
    end;


    local procedure PrepareRequest(Content: SecretText; Url: text) HttpRequestMessage: HttpRequestMessage
    var
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
    begin
        HttpContent.WriteFrom(Content);
        HttpContent.GetHeaders(HttpHeaders);

        HttpHeaders.Remove(this.ContentTypeTxt);
        HttpHeaders.Add(this.ContentTypeTxt, this.FormUrlEncodedTxt);

        HttpRequestMessage.Method := Format(Enum::"Http Request Type"::POST);
        HttpRequestMessage.SetRequestUri(Url);
        HttpRequestMessage.Content(HttpContent);
    end;

    [NonDebuggable]
    local procedure SendRequest(HttpRequestMessage: HttpRequestMessage; var Response: Text): Boolean
    var
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
    begin
        if not HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then
            exit;
        if not HttpResponseMessage.IsSuccessStatusCode() then
            exit;

        exit(HttpResponseMessage.Content.ReadAs(Response));
    end;

    local procedure StorageSet(var TokenKey: Guid; Value: SecretText; TokenDataScope: DataScope): Boolean
    begin
        this.ValidateValueKey(TokenKey);

        if Value.IsEmpty() then begin
            if IsolatedStorage.Contains(TokenKey, TokenDataScope) then
                exit(IsolatedStorage.Delete(TokenKey, TokenDataScope))
        end else
            exit(IsolatedStorage.Set(TokenKey, Value, TokenDataScope));
    end;

    local procedure StorageGet(TokenKey: Text; TokenDataScope: DataScope) TokenValueAsSecret: SecretText
    begin
        if not this.StorageContains(TokenKey, TokenDataScope) then
            exit(TokenValueAsSecret);

        IsolatedStorage.Get(TokenKey, TokenDataScope, TokenValueAsSecret);
    end;

    [NonDebuggable]
    local procedure StorageGetText(TokenKey: Text; TokenDataScope: DataScope) TokenValue: Text
    begin
        if not this.StorageContains(TokenKey, TokenDataScope) then
            exit(TokenValue);

        IsolatedStorage.Get(TokenKey, TokenDataScope, TokenValue);
    end;

    local procedure SaveSignUpAccessToken(TokenDataScope: DataScope; AccessToken: SecretText): Boolean
    var
        SignUpAccessTokenKey: Guid;
    begin
        SignUpAccessTokenKey := this.GetSignUpAccessTokenKey();
        exit(this.StorageSet(SignUpAccessTokenKey, AccessToken, TokenDataScope));
    end;

    local procedure StorageContains(TokenKey: Text; TokenDataScope: DataScope): Boolean
    begin
        exit(IsolatedStorage.Contains(TokenKey, TokenDataScope));
    end;

    local procedure ValidateValueKey(var ValueKey: Guid)
    begin
        if IsNullGuid(ValueKey) then
            ValueKey := CreateGuid();
    end;

    local procedure GetSignUpAccessTokenKey() SignUpAccessTokenKey: Guid
    begin
        Evaluate(SignUpAccessTokenKey, this.SignUpAccessTokenKeyTxt);
    end;

    local procedure ShowErrorMessage(HttpResponseMessage: HttpResponseMessage)
    var
        UnsuccessfulResponseErr: Label 'There was an error sending the request. Response code: %1 and error message: %2', Comment = '%1 - http response status code, e.g. 400, %2- error message';
    begin
        if HttpResponseMessage.ReasonPhrase() <> '' then
            Error(UnsuccessfulResponseErr, HttpResponseMessage.HttpStatusCode, HttpResponseMessage.ReasonPhrase());

        Error(this.ErrorUnableToCreateClientCredentialsLbl);
    end;

    [NonDebuggable]
    local procedure GetRootId() ReturnValue: Text
    begin
        if this.FetchSecretFromKeyVault(this.SignUpRootIdTxt, ReturnValue) then
            exit;

        if not this.SignUpConnectionSetup.GetSetup() then
            exit;

        this.SignUpConnectionSetup.TestField("Root App ID");
        ReturnValue := this.StorageGetText(this.SignUpConnectionSetup."Root App ID", DataScope::Module);
    end;

    local procedure GetRootSecret() ReturnValue: SecretText
    begin
        if this.FetchSecretFromKeyVault(this.SignUpRootSecretTxt, ReturnValue) then
            exit;

        if not this.SignUpConnectionSetup.GetSetup() then
            exit;

        this.SignUpConnectionSetup.TestField("Root Secret");
        ReturnValue := this.StorageGet(this.SignUpConnectionSetup."Root Secret", DataScope::Module);
    end;

    [NonDebuggable]
    local procedure GetRootTenant() ReturnValue: Text
    begin
        if this.FetchSecretFromKeyVault(this.SignUpRootTenantTxt, ReturnValue) then
            exit;
        ReturnValue := this.ProdRootTenantIdTxt;
    end;

    local procedure GetClientTenant() ReturnValue: Text
    begin
        if this.FetchSecretFromKeyVault(this.SignUpClientTenantTxt, ReturnValue) then
            exit;
        ReturnValue := this.ProdClientTenantIdTxt;
    end;

    local procedure GetServiceApi() ReturnValue: Text[2048]
    var
        KeyVaultReturn: Text;
    begin
        if this.FetchSecretFromKeyVault(this.SignUpServiceAPITxt, KeyVaultReturn) then begin
            ReturnValue := CopyStr(KeyVaultReturn, 1, MaxStrLen(ReturnValue));
            exit;
        end;
        ReturnValue := this.ProdServiceAPITxt;
    end;

    local procedure FetchSecretFromKeyVault(KeyName: Text; var KeyValue: SecretText): Boolean
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if EnvironmentInformation.IsSaaSInfrastructure() then
            exit(AzureKeyVault.GetAzureKeyVaultSecret(KeyName, KeyValue));
    end;

    [NonDebuggable]
    local procedure FetchSecretFromKeyVault(KeyName: Text; var KeyValue: Text): Boolean
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if EnvironmentInformation.IsSaaSInfrastructure() then
            exit(AzureKeyVault.GetAzureKeyVaultSecret(KeyName, KeyValue));
    end;

    local procedure GetAADTenantInformation(var AADTenantID: Text; var AADDomainName: Text): Boolean
    begin
        exit(this.GetAADTenantID(AADTenantID) and this.GetAADDomainName(AADDomainName));
    end;

    [TryFunction]
    local procedure GetAADTenantID(var AADTenantID: Text)
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
    begin
        AADTenantID := AzureADTenant.GetAadTenantId();
    end;

    [TryFunction]
    local procedure GetAADDomainName(var AADDomainName: Text)
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
    begin
        AADDomainName := AzureADTenant.GetAadTenantDomainName()
    end;

    #endregion
}