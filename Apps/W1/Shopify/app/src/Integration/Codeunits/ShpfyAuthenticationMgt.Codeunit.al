/// <summary>
/// Codeunit Shpfy Authentication Mgt. (ID 30199).
/// </summary>
codeunit 30199 "Shpfy Authentication Mgt."
{
    Access = Internal;

    var
        // https://shopify.dev/api/usage/access-scopes
        ScopeTxt: Label 'write_orders,read_all_orders,write_assigned_fulfillment_orders,read_checkouts,write_customers,read_discounts,write_files,write_merchant_managed_fulfillment_orders,write_fulfillments,write_inventory,read_locations,read_payment_terms,write_products,write_shipping,read_shopify_payments_disputes,read_shopify_payments_payouts,write_returns,write_translations,write_third_party_fulfillment_orders,write_order_edits', Locked = true;
        ShopifyAPIKeyAKVSecretNameLbl: Label 'ShopifyApiKey', Locked = true;
        ShopifyAPISecretAKVSecretNameLbl: Label 'ShopifyApiSecret', Locked = true;
        MissingAPIKeyTelemetryTxt: Label 'The api key has not been initialized.', Locked = true;
        MissingAPISecretTelemetryTxt: Label 'The api secret has not been initialized.', Locked = true;
        CategoryTok: Label 'Shopify Integration', Locked = true;
        NoCallbackErr: Label 'No callback was received from Shopify. Make sure that you haven''t closed the page that says "Waiting for a response - do not close this page", and then try again.';
        HttpRequestBlockedErr: Label 'Shopify connector is not allowed to make HTTP requests when running in a non-production environment.';
        EnableHttpRequestActionLbl: Label 'Allow HTTP requests';

    [NonDebuggable]
    [Scope('OnPrem')]
    local procedure GetApiKey(): Text
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        ApiKey: Text;
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(ShopifyAPIKeyAKVSecretNameLbl, ApiKey) then
            Session.LogMessage('0000HCA', MissingAPIKeyTelemetryTxt, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok)
        else
            exit(ApiKey);
    end;

    [NonDebuggable]
    [Scope('OnPrem')]
    local procedure GetApiSecret(): Text
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        ApiSecret: Text;
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(ShopifyAPISecretAKVSecretNameLbl, ApiSecret) then
            Session.LogMessage('0000HCB', MissingAPISecretTelemetryTxt, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok)
        else
            exit(ApiSecret);
    end;

    [NonDebuggable]
    [Scope('OnPrem')]
    internal procedure InstallShopifyApp(InstalllToStore: Text)
    var
        OAuth2: Codeunit "OAuth2";
        ShopifyAuthentication: Page "Shpfy Authentication";
        State: Integer;
        GrandOptionsTxt: Label 'value', Locked = true;
        Url: Text;
        RedirectUrl: Text;
        Store: Text;
        AuthorizationCode: Text;
        InstallURLTxt: Label 'https://%1/admin/oauth/authorize?client_id=%2&scope=%3&redirect_uri=%4&state=%5&grant_options[]=%6', Comment = '%1 = Store, %2 = ApiKey, %3 = Scope, %3 = RedirectUrl, %4 = State, %6 = GrantOptions', Locked = true;
        NotMatchingStateErr: Label 'The state parameter value does not match.';
    begin
        OAuth2.GetDefaultRedirectURL(RedirectUrl);
        State := Random(999);
        Url := StrSubstNo(InstallURLTxt, InstalllToStore, GetApiKey(), ScopeTxt, RedirectUrl, State, GrandOptionsTxt);
        ShopifyAuthentication.SetOAuth2Properties(Url);
        Commit();
        ShopifyAuthentication.RunModal();
        Store := ShopifyAuthentication.Store();
        AuthorizationCode := ShopifyAuthentication.GetAuthorizationCode();
        if AuthorizationCode = '' then
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
    local procedure GetToken(Store: Text; AuthorizationCode: Text)
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
        RequestBody.Add('client_id', GetApiKey());
        RequestBody.Add('client_secret', GetApiSecret());
        RequestBody.Add('code', AuthorizationCode);
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


    [NonDebuggable]
    [Scope('OnPrem')]
    local procedure SaveStoreInfo(Store: Text; ActualScope: Text; AccessToken: Text)
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

    [NonDebuggable]
    [Scope('OnPrem')]
    internal procedure GetAccessToken(Store: Text): Text
    var
        RegisteredStoreNew: Record "Shpfy Registered Store New";
        AccessToken: Text;
        NoAccessTokenErr: label 'No Access token for the store "%1".\Please request an access token for this store.', Comment = '%1 = Store';
        ChangedScopeErr: Label 'The application scope is changed, please request a new access token for the store "%1".', Comment = '%1 = Store';
    begin
        if RegisteredStoreNew.Get(Store) then
            if RegisteredStoreNew."Requested Scope" = ScopeTxt then begin
                AccessToken := RegisteredStoreNew.GetAccessToken();
                if AccessToken <> '' then
                    exit(AccessToken)
                else
                    Error(NoAccessTokenErr, Store);
            end else
                Error(ChangedScopeErr, Store);
        Error(NoAccessTokenErr, Store);
    end;

    [NonDebuggable]
    [Scope('OnPrem')]
    internal procedure AccessTokenExist(Store: Text): Boolean
    var
        RegisteredStoreNew: Record "Shpfy Registered Store New";
    begin
        if RegisteredStoreNew.Get(Store) then
            if RegisteredStoreNew."Requested Scope" = ScopeTxt then
                exit(RegisteredStoreNew.GetAccessToken() <> '');
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
}