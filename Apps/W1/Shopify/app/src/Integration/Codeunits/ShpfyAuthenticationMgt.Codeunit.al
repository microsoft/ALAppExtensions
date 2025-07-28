// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using System.Azure.KeyVault;
using System.Environment;
using System.Security.Authentication;
using System.Utilities;
using System.Apps;

/// <summary>
/// Codeunit Shpfy Authentication Mgt. (ID 30199).
/// </summary>
codeunit 30199 "Shpfy Authentication Mgt."
{
    Access = Internal;

    var
        // https://shopify.dev/api/usage/access-scopes
        ScopeTxt: Label 'write_orders,read_all_orders,write_assigned_fulfillment_orders,read_checkouts,write_customers,read_discounts,write_files,write_merchant_managed_fulfillment_orders,write_fulfillments,write_inventory,read_locations,write_products,write_shipping,read_shopify_payments_disputes,read_shopify_payments_payouts,write_returns,write_translations,write_third_party_fulfillment_orders,write_order_edits,write_companies,write_publications,write_payment_terms,write_draft_orders,read_locales,read_shopify_payments_accounts,read_users', Locked = true;
        ShopifyAPIKeyAKVSecretNameLbl: Label 'ShopifyApiKey', Locked = true;
        ShopifyAPISecretAKVSecretNameLbl: Label 'ShopifyApiSecret', Locked = true;
        MissingAPIKeyTelemetryTxt: Label 'The api key has not been initialized.', Locked = true;
        MissingAPISecretTelemetryTxt: Label 'The api secret has not been initialized.', Locked = true;
        CategoryTok: Label 'Shopify Integration', Locked = true;
        NoCallbackErr: Label 'No callback was received from Shopify. Make sure that you haven''t closed the page that says "Waiting for a response - do not close this page", and then try again.';
        HttpRequestBlockedErr: Label 'Shopify connector is not allowed to make HTTP requests when running in a non-production environment.';
        EnableHttpRequestActionLbl: Label 'Allow HTTP requests';
        NotSupportedOnPremErr: Label 'Shopify connector is only supported in SaaS environments.';

    [NonDebuggable]
    local procedure GetClientId(): Text
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        EnvironmentInformation: Codeunit "Environment Information";
        ClientId: Text;
    begin
        if not EnvironmentInformation.IsSaaS() then
            Error(NotSupportedOnPremErr);

        if not AzureKeyVault.GetAzureKeyVaultSecret(ShopifyAPIKeyAKVSecretNameLbl, ClientId) then
            Session.LogMessage('0000HCA', MissingAPIKeyTelemetryTxt, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok)
        else
            exit(ClientId);
    end;

    [NonDebuggable]
    local procedure GetClientSecret(): SecretText
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        EnvironmentInformation: Codeunit "Environment Information";
        ClientSecret: SecretText;
    begin
        if not EnvironmentInformation.IsSaaS() then
            Error(NotSupportedOnPremErr);

        if not AzureKeyVault.GetAzureKeyVaultSecret(ShopifyAPISecretAKVSecretNameLbl, ClientSecret) then
            Session.LogMessage('0000HCB', MissingAPISecretTelemetryTxt, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok)
        else
            exit(ClientSecret);
    end;

    [NonDebuggable]
    internal procedure InstallShopifyApp(InstalllToStore: Text)
    var
        OAuth2: Codeunit "OAuth2";
        ShopifyAuthentication: Page "Shpfy Authentication";
        State: Integer;
        GrandOptionsTxt: Label 'value', Locked = true;
        FullUrl: Text;
        Url: Text;
        RedirectUrl: Text;
        Store: Text;
        AuthorizationCode: SecretText;
        InstallURLTxt: Label 'https://%1/admin/oauth/authorize?scope=%2&redirect_uri=%3&state=%4&grant_options[]=%5', Comment = '%1 = Store, %2 = Scope, %3 = RedirectUrl, %4 = State, %5 = GrantOptions', Locked = true;
        InstallURLWithClientIdParamTok: Label '%1&client_id=%2', Comment = '%1 = InstallURLTxt, %2 = ClientId', Locked = true;
        NotMatchingStateErr: Label 'The state parameter value does not match.';
    begin
        OAuth2.GetDefaultRedirectURL(RedirectUrl);
        State := Random(999);
        Url := StrSubstNo(InstallURLTxt, InstalllToStore, GetScope(), RedirectUrl, State, GrandOptionsTxt);
        FullUrl := StrSubstNo(InstallURLWithClientIdParamTok, Url, GetClientId());
        ShopifyAuthentication.SetOAuth2Properties(FullUrl);
        Commit();
        ShopifyAuthentication.RunModal();
        Store := ShopifyAuthentication.Store();
        AuthorizationCode := ShopifyAuthentication.GetAuthorizationCode();
        if AuthorizationCode.IsEmpty() then
            if ShopifyAuthentication.GetAuthError() <> '' then
                Error(ShopifyAuthentication.GetAuthError())
            else
                Error(NoCallbackErr);
        if State <> ShopifyAuthentication.State() then
            Error(NotMatchingStateErr);
        GetToken(Store, AuthorizationCode);
    end;

    [NonDebuggable]
    local procedure GetToken(Store: Text; AuthorizationCode: SecretText)
    var
        JsonHelper: Codeunit "Shpfy Json Helper";
        Body: Text;
        SecretBody: SecretText;
        Url: Text;
        HttpClient: HttpClient;
        RequestHeaders: HttpHeaders;
        RequestHttpContent: HttpContent;
        HttpResponseMessage: HttpResponseMessage;
        JObject: JsonObject;
        RequestBody: JsonObject;
        Credentials: Dictionary of [Text, SecretText];
        AccessTokenURLTxt: Label 'https://%1/admin/oauth/access_token', Comment = '%1 = Store', Locked = true;
        HttpRequestBlockedErrorInfo: ErrorInfo;
    begin
        RequestBody.Add('client_id', GetClientId());
        RequestBody.Add('client_secret', '');
        RequestBody.Add('code', '');
        Credentials.Add('$.client_secret', GetClientSecret());
        Credentials.Add('$.code', AuthorizationCode);
        RequestBody.WriteWithSecretsTo(Credentials, SecretBody);

        Url := StrSubstNo(AccessTokenURLTxt, Store);

        RequestHttpContent.WriteFrom(SecretBody);
        RequestHttpContent.GetHeaders(RequestHeaders);
        RequestHeaders.Clear();
        RequestHeaders.Add('Content-Type', 'application/json');

        if not HttpClient.Post(Url, RequestHttpContent, HttpResponseMessage) then
            if HttpResponseMessage.IsBlockedByEnvironment() then begin
                HttpRequestBlockedErrorInfo.DataClassification := HttpRequestBlockedErrorInfo.DataClassification::SystemMetadata;
                HttpRequestBlockedErrorInfo.ErrorType := HttpRequestBlockedErrorInfo.ErrorType::Client;
                HttpRequestBlockedErrorInfo.Verbosity := HttpRequestBlockedErrorInfo.Verbosity::Error;
                HttpRequestBlockedErrorInfo.Message := HttpRequestBlockedErr;
                HttpRequestBlockedErrorInfo.AddAction(EnableHttpRequestActionLbl, Codeunit::"Shpfy Authentication Mgt.", 'EnableHttpRequestForShopifyConnector');
                Error(HttpRequestBlockedErrorInfo);
            end else
                exit;

        Clear(Body);
        HttpResponseMessage.Content().ReadAs(Body);
        JObject.ReadFrom(Body);
        SaveStoreInfo(Store, JsonHelper.GetValueAsText(JObject.AsToken(), 'scope'), JsonHelper.GetValueAsText(JObject.AsToken(), 'access_token'));
    end;

    local procedure SaveStoreInfo(Store: Text; ActualScope: Text; AccessToken: SecretText)
    var
        RegisteredStoreNew: Record "Shpfy Registered Store New";
    begin
        Store := Store.ToLower();
        if not RegisteredStoreNew.Get(Store) then begin
            RegisteredStoreNew.Init();
            RegisteredStoreNew.Store := CopyStr(Store, 1, MaxStrLen(RegisteredStoreNew.Store));
            RegisteredStoreNew.Insert();
        end;
        RegisteredStoreNew."Requested Scope" := GetScope();
        RegisteredStoreNew."Actual Scope" := CopyStr(ActualScope, 1, MaxStrLen(RegisteredStoreNew."Actual Scope"));
        RegisteredStoreNew.Modify();
        RegisteredStoreNew.SetAccessToken(AccessToken);
    end;

    [NonDebuggable]
    internal procedure AccessTokenExist(Store: Text): Boolean
    var
        RegisteredStoreNew: Record "Shpfy Registered Store New";
    begin
        if RegisteredStoreNew.Get(Store) then
            if RegisteredStoreNew."Requested Scope" = GetScope() then
                exit(not RegisteredStoreNew.GetAccessToken().IsEmpty());
    end;

    procedure IsValidShopUrl(ShopUrl: Text): Boolean
    var
        Regex: Codeunit Regex;
        PatternLbl: Label '^(https)\:\/\/[a-zA-Z0-9][a-zA-Z0-9\-]*\.myshopify\.com[\/]*$', Locked = true;
    begin
        exit(Regex.IsMatch(ShopUrl, PatternLbl))
    end;

    procedure IsValidHostName(Hostname: Text): Boolean
    var
        Regex: Codeunit Regex;
        PatternLbl: Label '^[a-zA-Z0-9][a-zA-Z0-9\-]*\.myshopify\.com$', Locked = true;
    begin
        exit(Regex.IsMatch(Hostname, PatternLbl))
    end;

    procedure CorrectShopUrl(var ShopUrl: Text[250])
    begin
        if not ShopUrl.ToLower().StartsWith('https://') then
            ShopUrl := CopyStr('https://' + ShopUrl, 1, MaxStrLen(ShopUrl));

        if ShopUrl.ToLower().StartsWith('https://admin.shopify.com/store/') then begin
            ShopUrl := CopyStr(ShopUrl.TrimEnd('?'), 1, MaxStrLen(ShopUrl));
            ShopUrl := CopyStr('https://' + ShopUrl.Replace('https://admin.shopify.com/store/', '').Split('/').Get(1) + '.myshopify.com', 1, MaxStrLen(ShopUrl));
        end;
    end;

    internal procedure EnableHttpRequestForShopifyConnector(ErrorInfo: ErrorInfo)
    var
        ExtensionManagement: Codeunit "Extension Management";
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CallerModuleInfo);
        ExtensionManagement.ConfigureExtensionHttpClientRequestsAllowance(CallerModuleInfo.PackageId(), true);
    end;

    internal procedure CheckScopeChange(Shop: Record "Shpfy Shop"): Boolean
    var
        RegisteredStoreNew: Record "Shpfy Registered Store New";
    begin
        if RegisteredStoreNew.Get(Shop.GetStoreName()) then
            exit(RegisteredStoreNew."Actual Scope" <> GetScope());

        exit(false);
    end;

    internal procedure GetScope(): Text[1024]
    begin
        exit(ScopeTxt);
    end;
}