// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using System.Azure.KeyVault;
using System.Environment;
using System.Security.Authentication;
using System.Azure.Identity;

codeunit 6390 AuthenticationImpl
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    #region variables
    var
        ConnectionSetup: Record ConnectionSetup;
        HelpersImpl: Codeunit HelpersImpl;
        BearerTxt: Label 'Bearer %1', Comment = '%1 = text value', Locked = true;
        AuthURLTxt: Label 'https://login.microsoftonline.com/%1/oauth2/token', Comment = '%1 Entra Tenant Id', Locked = true;
        ProdTenantIdTxt: Label '0d725623-dc26-484f-a090-b09d2003d092', Locked = true;
        ProdServiceAPITxt: Label 'https://edoc.exflow.io', Locked = true;
        ErrorTokenLbl: Label 'Unable to fetch a root token.';
        ErrorUnableToCreateClientCredentialsLbl: Label 'Unable to create client credentials.';
        ClientIdTxt: Label 'clientId', Locked = true;
        ClientSecretTxt: Label 'clientSecret', Locked = true;
        SignupRootUrlTxt: Label 'signup-root-url', Locked = true;
        RootIdTxt: Label '-root-id', Locked = true;
        SignUpRootSecretTxt: Label 'signup-root-secret', Locked = true;
        SignUpRootTenantTxt: Label 'signup-root-tenant', Locked = true;
        SignUpAccessTokenKeyTxt: Label '{E45BB975-E67B-4A87-AC24-D409A5EF8301}', Locked = true;

    #endregion

    #region public methods

    procedure InitConnectionSetup()
    begin
        if this.ConnectionSetup.Get() then
            exit;

        this.ConnectionSetup."Authentication URL" := this.AuthURLTxt;
        this.ConnectionSetup.ServiceURL := this.ProdServiceAPITxt;
        this.StorageSet(this.ConnectionSetup."Client Tenant", this.ProdTenantIdTxt);
        this.ConnectionSetup.Insert();
    end;

    procedure GetRootOnboardingUrl(): Text
    begin
        exit(this.GetRootUrl() + '/supm/landingpage?EntraTenantId=' + this.GetBCInstanceIdentifier());
    end;

    [NonDebuggable]
    procedure CreateClientCredentials()
    var
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        ClientId, Response : Text;
        ClientSecret: SecretText;
    begin
        if not this.GetClientCredentials(HttpRequestMessage, HttpResponseMessage) then
            Error(this.ErrorUnableToCreateClientCredentialsLbl);

        if not HttpResponseMessage.Content.ReadAs(Response) then
            exit;

        ClientId := this.HelpersImpl.GetJsonValueFromText(Response, this.ClientIdTxt);
        ClientSecret := this.HelpersImpl.GetJsonValueFromText(Response, this.ClientSecretTxt);

        if (ClientId <> '') and (not ClientSecret.IsEmpty()) then
            this.SaveClientCredentials(ClientId, ClientSecret);
    end;

    procedure GetBearerAuthToken(): SecretText;
    begin
        exit(SecretStrSubstNo(this.BearerTxt, this.GetAuthToken()));
    end;

    procedure GetRootBearerAuthToken(): SecretText;
    begin
        exit(SecretStrSubstNo(this.BearerTxt, this.GetRootAuthToken()));
    end;

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

    procedure StorageSet(var TokenKey: Guid; Value: SecretText): Boolean
    begin
        exit(this.StorageSet(TokenKey, Value, DataScope::Module));
    end;

    procedure GetBCInstanceIdentifier() Identifier: Text
    var
        AADTenantID, AADDomainName : Text;
    begin
        Identifier := '10000000-d8ef-4dfb-b761-ffb073057794'; // Hardcoded fake during testing only

        if this.GetAADTenantInformation(AADTenantID, AADDomainName) then
            Identifier := AADTenantID;
    end;

    [NonDebuggable]
    procedure GetRootUrl() ReturnValue: Text
    begin
        if this.FetchSecretFromKeyVault(this.SignupRootUrlTxt, ReturnValue) then
            exit;

        if not this.ConnectionSetup.GetSetup() then
            exit;

        this.ConnectionSetup.TestField("Root Market URL");
        ReturnValue := this.StorageGetText(this.ConnectionSetup."Root Market URL", DataScope::Module);
    end;

    #endregion

    #region local methods

    local procedure GetAuthToken() AccessToken: SecretText;
    var
        HttpError: Text;
    begin
        AccessToken := this.StorageGet(this.SignUpAccessTokenKeyTxt, DataScope::Company);

        if this.HelpersImpl.IsTokenValid(AccessToken) then
            exit;

        if not this.RefreshAccessToken(HttpError) then
            Error(HttpError);

        exit(this.StorageGet(this.SignUpAccessTokenKeyTxt, DataScope::Company));
    end;

    local procedure GetRootAuthToken() ReturnValue: SecretText;
    begin
        if not this.GetRootAccessToken(ReturnValue) then
            Error(this.ErrorTokenLbl);
    end;

    local procedure SaveClientCredentials(ClientId: Text; ClientSecret: SecretText)
    begin
        Clear(this.ConnectionSetup);

        this.ConnectionSetup.GetSetup();
        this.StorageSet(this.ConnectionSetup."Client ID", ClientId);
        this.StorageSet(this.ConnectionSetup."Client Secret", ClientSecret);
        this.ConnectionSetup.Modify();

        Clear(this.ConnectionSetup);
    end;

    [NonDebuggable]
    local procedure GetClientCredentials(var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        APIRequests: Codeunit APIRequests;
    begin
        APIRequests.GetMarketPlaceCredentials(HttpRequestMessage, HttpResponseMessage);

        if not HttpResponseMessage.IsSuccessStatusCode() then
            exit;

        exit(this.HelpersImpl.ParseJsonString(HttpResponseMessage.Content) <> '');
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

        exit(this.SaveSignUpAccessToken(DataScope::Company, SecretToken));
    end;

    [NonDebuggable]
    local procedure GetRootAccessToken(var AccessToken: SecretText): Boolean
    begin
        exit(this.GetAccessToken(AccessToken, this.GetRootId(), this.GetRootSecret(), this.GetRootTenant()));
    end;

    [NonDebuggable]
    local procedure GetClientAccessToken(var AccessToken: SecretText): Boolean
    var
        ModuleDataScope: DataScope;
    begin
        ModuleDataScope := ModuleDataScope::Module;
        this.ConnectionSetup.GetSetup();

        exit(this.GetAccessToken(AccessToken, this.StorageGetText(this.ConnectionSetup."Client ID", ModuleDataScope),
                                                this.StorageGet(this.ConnectionSetup."Client Secret", ModuleDataScope),
                                                this.StorageGetText(this.ConnectionSetup."Client Tenant", ModuleDataScope)));
    end;

    [NonDebuggable]
    local procedure GetAccessToken(var AccessToken: SecretText; ClientId: Text; ClientSecret: SecretText; ClientTenant: Text) Success: Boolean
    var
        OAuth2: Codeunit OAuth2;
    begin
        Success := OAuth2.AcquireTokenWithClientCredentials(ClientId, ClientSecret, StrSubstNo(this.ConnectionSetup."Authentication URL", ClientTenant), '', ClientId, AccessToken);
        exit(Success and not AccessToken.IsEmpty());
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

    [NonDebuggable]
    local procedure GetRootId() ReturnValue: Text
    begin
        if this.FetchSecretFromKeyVault(this.RootIdTxt, ReturnValue) then
            exit;

        if not this.ConnectionSetup.GetSetup() then
            exit;

        this.ConnectionSetup.TestField("Root App ID");
        ReturnValue := this.StorageGetText(this.ConnectionSetup."Root App ID", DataScope::Module);
    end;

    [NonDebuggable]
    local procedure GetRootSecret() ReturnValue: Text
    begin
        if this.FetchSecretFromKeyVault(this.SignUpRootSecretTxt, ReturnValue) then
            exit;

        if not this.ConnectionSetup.GetSetup() then
            exit;

        this.ConnectionSetup.TestField("Root Secret");
        ReturnValue := this.StorageGetText(this.ConnectionSetup."Root Secret", DataScope::Module);
    end;

    [NonDebuggable]
    local procedure GetRootTenant() ReturnValue: Text
    begin
        if this.FetchSecretFromKeyVault(this.SignUpRootTenantTxt, ReturnValue) then
            exit;

        if not this.ConnectionSetup.GetSetup() then
            exit;

        this.ConnectionSetup.TestField("Root Tenant");
        ReturnValue := this.StorageGetText(this.ConnectionSetup."Root Tenant", DataScope::Module);
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
        AADDomainName := AzureADTenant.GetAadTenantId();
    end;

    #endregion
}