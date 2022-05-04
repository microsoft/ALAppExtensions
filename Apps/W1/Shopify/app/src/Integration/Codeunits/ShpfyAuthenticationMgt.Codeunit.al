/// <summary>
/// Codeunit Shpfy Authentication Mgt. (ID 30199).
/// </summary>
codeunit 30199 "Shpfy Authentication Mgt."
{
    Access = Internal;

    var
        // https://shopify.dev/api/usage/access-scopes
        ScopeTxt: Label 'write_orders,write_assigned_fulfillment_orders,read_checkouts,write_customers,read_discounts,write_fulfillments,write_inventory,read_locations,read_payment_terms,write_products,write_shipping', Locked = true;
        ShopifyAPIKeyAKVSecretNameLbl: Label 'ShopifyApiKey', Locked = true;
        ShopifyAPISecretAKVSecretNameLbl: Label 'ShopifyApiSecret', Locked = true;
        MissingAPIKeyTelemetryTxt: Label 'The api key has not been initialized.', Locked = true;

        MissingAPISecretTelemetryTxt: Label 'The api secret has not been initialized.', Locked = true;
        CategoryTok: Label 'Shopify Integration', Locked = true;



    [NonDebuggable]
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
        InstallURLTxt: Label 'https://%1/admin/oauth/authorize?client_id=%2&scope=%3&redirect_uri=%4&state=%5&grant_options[]=%6', Comment = '%1 = Store, %2 = ApiKey, %3 = Scope, %3 = RedirectUrl, %4 = State, %6= GrantOptions', Locked = true;
        NotMatchingStateErr: Label 'The state parameter value does not match.';
    begin
        OAuth2.GetDefaultRedirectURL(RedirectUrl);
        State := Random(999);
        Url := StrSubstNo(InstallURLTxt, InstalllToStore, GetApiKey(), ScopeTxt, RedirectUrl, State, GrandOptionsTxt);
        ShopifyAuthentication.SetOAuth2Properties(Url);
        Commit();
        ShopifyAuthentication.RunModal();
        if State <> ShopifyAuthentication.State() then
            Error(NotMatchingStateErr);
        Store := ShopifyAuthentication.Store();
        AuthorizationCode := ShopifyAuthentication.GetAuthorizationCode();
        GetToken(Store, AuthorizationCode);
    end;

    [NonDebuggable]
    local procedure GetToken(Store: Text; AuthorizationCode: Text)
    var
        JHelper: Codeunit "Shpfy Json Helper";
        Body: Text;
        Url: Text;
        HttpClient: HttpClient;
        RequestHeaders: HttpHeaders;
        RequestHttpContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        JObject: JsonObject;
        RequestBody: JsonObject;
        AccessTokenURLTxt: Label 'https://%1/admin/oauth/access_token', Comment = '%1 = Store', Locked = true;
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

        if not HttpClient.Post(Url, RequestHttpContent, ResponseMessage) then
            exit;

        Clear(Body);
        ResponseMessage.Content().ReadAs(Body);
        JObject.ReadFrom(Body);
        SaveStoreInfo(Store, JHelper.GetValueAsText(JObject.AsToken(), 'scope'), JHelper.GetValueAsText(JObject.AsToken(), 'access_token'));
    end;


    [NonDebuggable]
    local procedure SaveStoreInfo(Store: Text; ActualScope: Text; AccessToken: Text)
    var
        RegisteredStore: Record "Shpfy Registered Store";
    begin
        Store := Store.ToLower();
        if not RegisteredStore.Get(Store) then begin
            RegisteredStore.Init();
            RegisteredStore.Store := CopyStr(Store, 1, MaxStrLen(RegisteredStore.Store));
            RegisteredStore.Insert();
        end;
        RegisteredStore."Requested Scope" := ScopeTxt;
        RegisteredStore."Actual Scope" := CopyStr(ActualScope, 1, MaxStrLen(RegisteredStore."Actual Scope"));
        RegisteredStore.Modify();
        RegisteredStore.SetAccessToken(AccessToken);
    end;

    [NonDebuggable]
    internal procedure GetAccessToken(Store: Text): Text
    var
        RegisteredStore: Record "Shpfy Registered Store";
        AccessToken: Text;
        NoAccessTokenErr: label 'No Access token for the store "%1".\Please request an access token for this store.', Comment = '%1 = Store';
        ChangedScopeErr: Label 'The application scope is changed, please request a new access token for the store "%1".', Comment = '%1 = Store';
    begin
        if RegisteredStore.Get(Store) then
            if RegisteredStore."Requested Scope" = ScopeTxt then begin
                AccessToken := RegisteredStore.GetAccessToken();
                if AccessToken <> '' then
                    exit(AccessToken)
                else
                    Error(NoAccessTokenErr, Store);
            end else
                Error(ChangedScopeErr, Store);
        Error(NoAccessTokenErr, Store);
    end;

    [NonDebuggable]
    internal procedure AccessTokenExist(Store: Text): Boolean
    var
        RegisteredStore: Record "Shpfy Registered Store";
    begin
        if RegisteredStore.Get(Store) then
            if RegisteredStore."Requested Scope" = ScopeTxt then
                exit(RegisteredStore.GetAccessToken() <> '');
    end;
}