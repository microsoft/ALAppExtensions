// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using System.Azure.KeyVault;
using System.Environment;
using System.Reflection;

codeunit 6381 Auth
{
    Access = Internal;

    procedure InitConnectionSetup()
    var
        LConnectionSetup: Record ConnectionSetup;
    begin
        if LConnectionSetup.Get() then
            exit;
        LConnectionSetup."Authentication URL" := AuthURLTxt;
        LConnectionSetup.ServiceURL := ProdServiceAPITxt;
        StorageSet(LConnectionSetup."Client Tenant", ProdTenantIdTxt);
        LConnectionSetup.Insert();
    end;

    procedure GetRootOnboardingUrl(): Text
    var
        UrlTxt: Label '%1/supm/landingpage?EntraTenantId=%2', Comment = '%1 = Root Market URL, %2 = BC Instance Identifier', Locked = true;
    begin
        exit(StrSubstNo(UrlTxt, GetRootUrl(), GetBCInstanceIdentifier()));
    end;

    [NonDebuggable]
    procedure CreateClientCredentials()
    var
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        JText: Text;
        ClientId: Text;
        ClientSecret: SecretText;
        ErrorUnableToCreateClientCredentialsLbl: Label 'Unable to create client credentials.';
    begin
        if not GetClientCredentials(HttpRequestMessage, HttpResponseMessage) then
            Error(ErrorUnableToCreateClientCredentialsLbl);
        if HttpResponseMessage.Content.ReadAs(JText) then begin
            ClientId := Helpers.GetJsonValueFromText(JText, 'clientId');
            ClientSecret := Helpers.GetJsonValueFromText(JText, 'clientSecret');
            if (ClientId <> '') and (not ClientSecret.IsEmpty()) then
                SaveClientCredentials(ClientId, ClientSecret);
        end;
    end;

    [NonDebuggable]
    local procedure GetClientCredentials(var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    var
        APIRequests: Codeunit APIRequests;
    begin
        APIRequests.GetMarketPlaceCredentials(HttpRequest, HttpResponse);
        if not HttpResponse.IsSuccessStatusCode then
            exit(false);
        exit(Helpers.ParseJsonString(HttpResponse.Content) <> '');
    end;

    procedure GetBearerAuthText(): SecretText;
    begin
        exit(secretStrSubstNo(BearerTxt, GetAuthBearerToken()));
    end;

    procedure GetRootBearerAuthText(): SecretText;
    begin
        exit(secretStrSubstNo(BearerTxt, GetRootAuthBearerToken()));
    end;

    procedure GetAuthBearerToken(): SecretText;
    var
        ConnectionAuth: Record ConnectionAuth;
        HttpError: Text;
    begin
        ConnectionAuth.GetRecordOnce();
        if ConnectionAuth."Token Timestamp" < CurrentDateTime() + 60 * 1000 then
            if not RefreshAccessToken(HttpError) then
                Error(HttpError);

        exit(StorageGet(ConnectionAuth."Access Token", DataScope::Company));
    end;

    procedure GetRootAuthBearerToken() ReturnValue: SecretText;
    var
        ErrorTokenLbl: Label 'Unable to fetch a root token.';
    begin
        if not GetRootAccessToken(ReturnValue) then
            Error(ErrorTokenLbl);
    end;

    [NonDebuggable]
    local procedure RefreshAccessToken(var HttpError: Text): Boolean;
    var
        ConnectionAuth: Record ConnectionAuth;
        SecretToken: SecretText;
        RefreshToken: SecretText;
    begin
        ConnectionAuth.GetRecordOnce();
        if not GetClientAccessToken(SecretToken) then begin
            HttpError := GetLastErrorText();
            exit(false);
        end;
        ConnectionAuth."Token Timestamp" := CurrentDateTime();
        SaveTokens(ConnectionAuth, DataScope::Company, SecretToken, RefreshToken);
        ConnectionAuth.Modify();
        exit(true);
    end;

    [NonDebuggable]
    local procedure GetRootAccessToken(var AccessToken: SecretText): Boolean
    begin
        exit(GetAccessToken(AccessToken, GetRootId(), GetRootSecret(), GetRootTenant()));
    end;

    [NonDebuggable]
    local procedure GetClientAccessToken(var AccessToken: SecretText): Boolean
    begin
        ConnectionSetup.GetRecordOnce();
        exit(GetAccessToken(
            AccessToken,
            StorageGetText(ConnectionSetup."Client ID", DataScope::Module),
            StorageGet(ConnectionSetup."Client Secret", DataScope::Module),
            StorageGetText(ConnectionSetup."Client Tenant", DataScope::Module)));
    end;

    [NonDebuggable]
    local procedure GetAccessToken(var AccessToken: SecretText; ClientId: Text; ClientSecret: SecretText; ClientTenant: Text): Boolean
    var
        TypeHelper: Codeunit "Type Helper";
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        ContentText: SecretText;
        ContentTemplateTxt: Label 'grant_type=client_credentials&client_id=%1&client_secret=%2&resource=%3', Locked = true;
        JText: Text;
    begin
        ConnectionSetup.GetRecordOnce();
        ConnectionSetup.TestField("Authentication URL");

        ContentText := SecretStrSubstNo(ContentTemplateTxt, TypeHelper.UriEscapeDataString(ClientId), ClientSecret, TypeHelper.UriEscapeDataString(ClientId));

        HttpContent.WriteFrom(ContentText);

        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Remove('Content-Type');
        HttpHeaders.Add('Content-Type', 'application/x-www-form-urlencoded');

        HttpRequestMessage.Method := 'POST';
        HttpRequestMessage.SetRequestUri(StrSubstNo(ConnectionSetup."Authentication URL", ClientTenant));
        HttpRequestMessage.Content(HttpContent);

        Clear(AccessToken);
        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then
            if HttpResponseMessage.IsSuccessStatusCode() then
                if HttpResponseMessage.Content.ReadAs(JText) then
                    AccessToken := Helpers.GetJsonValueFromText(JText, 'access_token');
        exit(not AccessToken.IsEmpty());
    end;

    local procedure SaveTokens(var ConnectionAuth: Record ConnectionAuth; TokenDataScope: DataScope; AccessToken: SecretText; RefreshToken: SecretText)
    begin
        StorageSet(ConnectionAuth."Access Token", AccessToken, TokenDataScope);
        StorageSet(ConnectionAuth."Refresh Token", RefreshToken, TokenDataScope);
    end;

    procedure SaveClientCredentials(ClientId: Text; ClientSecret: SecretText)
    begin
        Clear(ConnectionSetup);
        ConnectionSetup.GetRecordOnce();
        StorageSet(ConnectionSetup."Client ID", ClientId);
        StorageSet(ConnectionSetup."Client Secret", ClientSecret);
        ConnectionSetup.Modify();
        Clear(ConnectionSetup);
    end;

    local procedure StorageGet(TokenKey: Text; TokenDataScope: DataScope) TokenValueAsSecret: SecretText
    begin
        if not StorageContains(TokenKey, TokenDataScope) then
            exit(TokenValueAsSecret);

        IsolatedStorage.Get(TokenKey, TokenDataScope, TokenValueAsSecret);
    end;

    [NonDebuggable]
    local procedure StorageGetText(TokenKey: Text; TokenDataScope: DataScope) TokenValue: Text
    begin
        if not StorageContains(TokenKey, TokenDataScope) then
            exit(TokenValue);

        IsolatedStorage.Get(TokenKey, TokenDataScope, TokenValue);
    end;

    local procedure StorageContains(TokenKey: Text; TokenDataScope: DataScope): Boolean
    begin
        exit(IsolatedStorage.Contains(TokenKey, TokenDataScope));
    end;

    [NonDebuggable]
    procedure StorageSet(var TokenKey: Guid; Value: Text)
    begin
        ValidateValueKey(TokenKey);
        if Value = '' then begin
            if IsolatedStorage.Contains(TokenKey, DataScope::Module) then
                IsolatedStorage.Delete(TokenKey, DataScope::Module)
        end else
            IsolatedStorage.Set(TokenKey, Value, DataScope::Module);
    end;

    procedure StorageSet(var TokenKey: Guid; Value: SecretText)
    begin
        ValidateValueKey(TokenKey);
        if Value.IsEmpty() then begin
            if IsolatedStorage.Contains(TokenKey, DataScope::Module) then
                IsolatedStorage.Delete(TokenKey, DataScope::Module)
        end else
            IsolatedStorage.Set(TokenKey, Value, DataScope::Module);
    end;

    procedure StorageSet(var TokenKey: Guid; Value: SecretText; TokenDataScope: DataScope)
    begin
        ValidateValueKey(TokenKey);
        if Value.IsEmpty() then begin
            if IsolatedStorage.Contains(TokenKey, TokenDataScope) then
                IsolatedStorage.Delete(TokenKey, TokenDataScope)
        end else
            IsolatedStorage.Set(TokenKey, Value, TokenDataScope);
    end;

    local procedure ValidateValueKey(var ValueKey: Guid)
    begin
        if IsNullGuid(ValueKey) then
            ValueKey := CreateGuid();
    end;

    [NonDebuggable]
    local procedure GetRootId() ReturnValue: Text
    begin
        if FetchSecretFromKeyVault('-root-id', ReturnValue) then
            exit;
        if ConnectionSetup.GetRecordOnce() then begin
            ConnectionSetup.TestField("Root App ID");
            ReturnValue := StorageGetText(ConnectionSetup."Root App ID", DataScope::Module);
        end;
    end;

    [NonDebuggable]
    local procedure GetRootSecret() ReturnValue: Text
    begin
        if FetchSecretFromKeyVault('signup-root-secret', ReturnValue) then
            exit;
        if ConnectionSetup.GetRecordOnce() then begin
            ConnectionSetup.TestField("Root Secret");
            ReturnValue := StorageGetText(ConnectionSetup."Root Secret", DataScope::Module);
        end;
    end;

    [NonDebuggable]
    local procedure GetRootTenant() ReturnValue: Text
    begin
        if FetchSecretFromKeyVault('signup-root-tenant', ReturnValue) then
            exit;
        if ConnectionSetup.GetRecordOnce() then begin
            ConnectionSetup.TestField("Root Tenant");
            ReturnValue := StorageGetText(ConnectionSetup."Root Tenant", DataScope::Module);
        end;
    end;

    [NonDebuggable]
    procedure GetRootUrl() ReturnValue: Text
    begin
        if FetchSecretFromKeyVault('signup-root-url', ReturnValue) then
            exit;
        if ConnectionSetup.GetRecordOnce() then begin
            ConnectionSetup.TestField("Root Market URL");
            ReturnValue := StorageGetText(ConnectionSetup."Root Market URL", DataScope::Module);
        end;
    end;

    [NonDebuggable]
    local procedure FetchSecretFromKeyVault(KeyName: Text; var KeyValue: Text): Boolean
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        EnvironmentInfo: Codeunit "Environment Information";
    begin
        if EnvironmentInfo.IsSaaSInfrastructure() then
            exit(AzureKeyVault.GetAzureKeyVaultSecret(KeyName, KeyValue));
    end;

    procedure GetBCInstanceIdentifier() Identifier: Text
    var
        AADTenantID, AADDomainName : Text;
    begin
        Identifier := '10000000-d8ef-4dfb-b761-ffb073057794'; // Hardcoded fake during testing only
        if GetAADTenantInformation(AADTenantID, AADDomainName) then
            Identifier := AADTenantID;
    end;

    local procedure GetAADTenantInformation(var AADTenantID: Text; var AADDomainName: Text): Boolean
    var
        ErrorSensitive: Codeunit ErrorSensitive;
    begin
        Clear(ErrorSensitive);
        ErrorSensitive.SetParameter('AADDETAILS');
        Commit();
        if ErrorSensitive.Run() then begin
            AADTenantID := ErrorSensitive.GetFirstResult();
            AADDomainName := ErrorSensitive.GetSecondResult();
            exit(true);
        end;
    end;

    var
        ConnectionSetup: Record ConnectionSetup;
        Helpers: Codeunit Helpers;
        BearerTxt: Label 'Bearer %1', Comment = '%1 = text value', Locked = true;
        AuthURLTxt: Label 'https://login.microsoftonline.com/%1/oauth2/token', Comment = '%1 Entra Tenant Id', Locked = true;
        ProdTenantIdTxt: Label '0d725623-dc26-484f-a090-b09d2003d092', Locked = true;
        ProdServiceAPITxt: Label 'https://edoc.exflow.io', Locked = true;
}