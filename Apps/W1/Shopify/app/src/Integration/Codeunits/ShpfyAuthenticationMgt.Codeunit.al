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
        ScopeTxt: Label 'write_orders,read_all_orders,write_assigned_fulfillment_orders,read_checkouts,write_customers,read_discounts,write_files,write_merchant_managed_fulfillment_orders,write_fulfillments,write_inventory,read_locations,write_products,write_shipping,read_shopify_payments_disputes,read_shopify_payments_payouts,write_returns,write_translations,write_third_party_fulfillment_orders,write_order_edits,write_companies,write_publications,read_payment_terms,write_payment_terms,write_draft_orders,read_locales', Locked = true;
        ShopifyAPIKeyAKVSecretNameLbl: Label 'ShopifyApiKey', Locked = true;
        ShopifyAPISecretAKVSecretNameLbl: Label 'ShopifyApiSecret', Locked = true;
        MissingAPIKeyTelemetryTxt: Label 'The api key has not been initialized.', Locked = true;
        MissingAPISecretTelemetryTxt: Label 'The api secret has not been initialized.', Locked = true;
        CategoryTok: Label 'Shopify Integration', Locked = true;
        NoCallbackErr: Label 'No callback was received from Shopify. Make sure that you haven''t closed the page that says "Waiting for a response - do not close this page", and then try again.';
        HttpRequestBlockedErr: Label 'Shopify connector is not allowed to make HTTP requests when running in a non-production environment.';
        EnableHttpRequestActionLbl: Label 'Allow HTTP requests';
        NotSupportedOnPremErr: Label 'Shopify connector is only supported in SaaS environments.';

    [Scope('OnPrem')]
    local procedure GetClientId(): SecretText
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        EnvironmentInformation: Codeunit "Environment Information";
        ClientId: SecretText;
    begin
        if not EnvironmentInformation.IsSaaS() then
            Error(NotSupportedOnPremErr);

        if not AzureKeyVault.GetAzureKeyVaultSecret(ShopifyAPIKeyAKVSecretNameLbl, ClientId) then
            Session.LogMessage('0000HCA', MissingAPIKeyTelemetryTxt, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok)
        else
            exit(ClientId);
    end;

    [Scope('OnPrem')]
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

    [Scope('OnPrem')]
    internal procedure InstallShopifyApp(InstalllToStore: Text)
    var
        OAuth2: Codeunit "OAuth2";
        ShopifyAuthentication: Page "Shpfy Authentication";
        State: Integer;
        GrandOptionsTxt: Label 'value', Locked = true;
        FullUrl: SecretText;
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
        Url := StrSubstNo(InstallURLTxt, InstalllToStore, ScopeTxt, RedirectUrl, State, GrandOptionsTxt);
        FullUrl := SecretStrSubstNo(InstallURLWithClientIdParamTok, Url, GetClientId());
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
    [Scope('OnPrem')]
    local procedure GetToken(Store: Text; AuthorizationCode: SecretText)
    var
        JsonHelper: Codeunit "Shpfy Json Helper";
        Body: Text;
        Url: Text;
        HttpClient: HttpClient;
        RequestHeaders: HttpHeaders;
        RequestHttpContent: HttpContent;
        HttpResponseMessage: HttpResponseMessage;
        JObject: JsonObject;
        RequestBody: JsonObject;
        AccessTokenURLTxt: Label 'https://%1/admin/oauth/access_token', Comment = '%1 = Store', Locked = true;
        HttpRequestBlockedErrorInfo: ErrorInfo;
    begin
        RequestBody.Add('client_id', GetClientId().Unwrap());
        RequestBody.Add('client_secret', GetClientSecret().Unwrap());
        RequestBody.Add('code', AuthorizationCode.Unwrap());
        RequestBody.WriteTo(Body);

        Url := StrSubstNo(AccessTokenURLTxt, Store);

        RequestHttpContent.WriteFrom(Body);
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


    [Scope('OnPrem')]
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
        RegisteredStoreNew."Requested Scope" := ScopeTxt;
        RegisteredStoreNew."Actual Scope" := CopyStr(ActualScope, 1, MaxStrLen(RegisteredStoreNew."Actual Scope"));
        RegisteredStoreNew.Modify();
        RegisteredStoreNew.SetAccessToken(AccessToken);
    end;

    [Scope('OnPrem')]
    internal procedure GetAccessToken(Store: Text): SecretText
    var
        RegisteredStoreNew: Record "Shpfy Registered Store New";
        AccessToken: SecretText;
        NoAccessTokenErr: label 'No Access token for the store "%1".\Please request an access token for this store.', Comment = '%1 = Store';
        ChangedScopeErr: Label 'The application scope is changed, please request a new access token for the store "%1".', Comment = '%1 = Store';
    begin
        if RegisteredStoreNew.Get(Store) then
            if RegisteredStoreNew."Requested Scope" = ScopeTxt then begin
                AccessToken := RegisteredStoreNew.GetAccessToken();
                if not AccessToken.IsEmpty() then
                    exit(AccessToken)
                else
                    Error(NoAccessTokenErr, Store);
            end else
                Error(ChangedScopeErr, Store);
        Error(NoAccessTokenErr, Store);
    end;

    [Scope('OnPrem')]
    internal procedure AccessTokenExist(Store: Text): Boolean
    var
        RegisteredStoreNew: Record "Shpfy Registered Store New";
    begin
        if RegisteredStoreNew.Get(Store) then
            if RegisteredStoreNew."Requested Scope" = ScopeTxt then
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
            exit(RegisteredStoreNew."Actual Scope" <> ScopeTxt);

        exit(false);
    end;
}