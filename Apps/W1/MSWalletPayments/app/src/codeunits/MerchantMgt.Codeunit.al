#if not CLEAN20
codeunit 1084 "MS - Wallet Merchant Mgt"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'MS Wallet have been deprecated';
    ObsoleteTag = '20.0';

    var
        MSWalletSignUpBaseUrlTxt: Label 'MSWalletSignUpUrl', Locked = true;
        MSWalletMerchantAPITxt: Label 'MSWalletMerchantAPI', Locked = true;
        MSWalletMerchantAPIResourceTxt: Label 'MSWalletMerchantAPIResource', Locked = true;
        MMXMarketPlaceTxt: Label 'Dynamics', Locked = true;
        AzureKeyVaultRetreiveErr: Label 'Could not retreive azure key vault secrets for Microsoft Pay Payments.';
        AzureKeyVaultTelemetryTxt: Label 'Could not retreive azure key vault secret %1 for Microsoft Pay Payments.', Locked = true;
        EmptyValueErr: Label 'Error: %1 should not be empty.', Comment = '%1 settings name';
        TelemetryCategoryTok: Label 'AL MSPAY', Locked = true;
        MerchantAPITelemetryErr: Label 'Error while calling merchant API. Response status code %1, Error: %2.', Locked = true;
        MerchantAPICannotReadResponseTelemetryTxt: Label 'Cannot read response on calling merchant API.', Locked = true;
        MerchantAPICannotReadResponseTxt: Label 'Cannot read response on calling merchant API.';
        MerchantAPIEmptyResponseTelemetryTxt: Label 'Empty response on calling merchant API.', Locked = true;
        MerchantAPIEmptyResponseTxt: Label 'Empty response on calling merchant API.';
        MerchantAPIIncorrectResponseTelemetryTxt: Label 'Incorrect response on calling merchant API.', Locked = true;
        MerchantAPIIncorrectResponseTxt: Label 'Incorrect response on calling merchant API.';
        OnBehalfFailedTelemetryTxt: Label 'Could not retrieve the OnBehalf token.', Locked = true;
        AuthTokenFallbackFailedTelemetryTxt: Label 'Could not retrieve access token through token cache.', Locked = true;
        MerchantAPIErrUserTxt: Label 'Error while calling merchant API. Try again later.';
        MerchantAPIChargableTelemetryErr: Label 'Error: Merchant does not have a chargable account.', Locked = true;
        MerchantAPIChargableErr: Label 'Error: Merchant %1 does not have a chargable account.';
        MerchantAPIJsonPropertyTelemetryErr: Label 'Error: Could not find property %1 in merchant API response.', Locked = true;
        MerchantAPIJsonPropertyErr: Label 'Error: Could not find property %1 in merchant API response.';
        UpdateMerchantIdTxt: Label 'Update merchant ID.', Locked = true;
        MerchantIDRetreivalSuccessMsg: Label 'Your merchant ID was updated sucessfully.';
        MerchantIDRetreivalSuccessInvMsg: Label 'Your merchant profile was connected successfully.';
        FailedToRetrieveMerchantInvErr: Label 'We could not retrieve your Microsoft Pay Payments merchant profile. If you didn''t see the Microsoft Pay Payments page, make sure that your browser allows pop-ups.';
        DoneWithSignupMsg: Label 'The merchant''s sign-up page has been opened. When you have finished adding your accounts, choose Done.';
        DoneWithSignupActionNameTxt: Label 'Done';
        TermsOfServiceNotAcceptedErr: Label 'You must accept the Microsoft Pay Payments terms of service before you can use the service.';
        TermsOfServiceNotAcceptedInvErr: Label 'You must accept the Microsoft Pay Payments terms of service before you can continue.';
        EmptyAccessTokenTxt: Label 'Received empty Access Token for resource: %1.', Locked = true;

    [Scope('OnPrem')]
    procedure GetMerchantSignupUrl(): Text;
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        UrlHelper: Codeunit "Url Helper";
        SignUpBaseUrl: Text;
        AccessToken: Text;
        MerchantAPIResource: Text;
    begin
        IF NOT AzureKeyVault.GetAzureKeyVaultSecret(MSWalletSignUpBaseUrlTxt, SignUpBaseUrl) THEN
            ERROR(AzureKeyVaultRetreiveErr);

        IF SignUpBaseUrl = '' THEN
            ERROR(EmptyValueErr, MSWalletSignUpBaseUrlTxt);

        IF NOT AzureKeyVault.GetAzureKeyVaultSecret(MSWalletMerchantAPIResourceTxt, MerchantAPIResource) THEN
            ERROR(AzureKeyVaultRetreiveErr);

        IF MerchantAPIResource = '' THEN
            ERROR(EmptyValueErr, MSWalletMerchantAPIResourceTxt);

        AccessToken := GetAuthorizationToken(MerchantAPIResource);

        IF AccessToken = '' THEN
            Session.LogMessage('00001PG', STRSUBSTNO(EmptyAccessTokenTxt, MerchantAPIResource), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTok);

        IF UrlHelper.IsPPE() THEN
            EXIT(STRSUBSTNO('%1?marketplace=%2&mode=test#ticket=%3', SignUpBaseUrl, MMXMarketPlaceTxt, AccessToken));

        EXIT(STRSUBSTNO('%1?marketplace=%2#ticket=%3', SignUpBaseUrl, MMXMarketPlaceTxt, AccessToken));
    end;

    procedure StartMerchantOnboardingExperience(PrimaryKey: Integer; var MSWalletMerchantTemplate: Record 1081);
    var
        EnvInfoProxy: Codeunit "Env. Info Proxy";
    begin
        if Page.RunModal(Page::"MS - Wallet Merchant Terms", MSWalletMerchantTemplate) = Action::LookupCancel then
            exit;
        MSWalletMerchantTemplate.Get();

        if EnvInfoProxy.IsInvoicing() then begin
            if not MSWalletMerchantTemplate."Accept Terms of Service" then
                Error(TermsOfServiceNotAcceptedInvErr);

            Hyperlink(GetMerchantSignupUrl());
            ShowDialogAndRetrieveMerchant(PrimaryKey, MSWalletMerchantTemplate)
        end else begin
            if not MSWalletMerchantTemplate."Accept Terms of Service" then
                Error(TermsOfServiceNotAcceptedErr);

            Hyperlink(GetMerchantSignupUrl());
            SendDoneWithSignupNotification(PrimaryKey, MSWalletMerchantTemplate);
        end;
    end;

    procedure SendDoneWithSignupNotification(PrimaryKey: Integer; var MSWalletMerchantTemplate: Record 1081);
    var
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        SendNotification: Notification;
    begin
        SendNotification.Id := GetDoneWithSignupNotificationID();
        SendNotification.Message := DoneWithSignupMsg;
        SendNotification.Scope := NotificationScope::LocalScope;
        SendNotification.AddAction(DoneWithSignupActionNameTxt, Codeunit::"MS - Wallet Merchant Mgt", 'MerchantSignupCallBack');
        SendNotification.SetData(MerchantIDNotificationKey(), Format(PrimaryKey));
        NotificationLifecycleMgt.SendNotification(SendNotification, MSWalletMerchantTemplate.RecordId());
    end;

    procedure ShowDialogAndRetrieveMerchant(PrimaryKey: Integer; var MSWalletMerchantTemplate: Record 1081);
    var
        MSWalletMerchantAccount: Record "MS - Wallet Merchant Account";
        PaymentServiceSetup: Record "Payment Service Setup";
        O365SalesInvoicePayment: Codeunit "O365 Sales Invoice Payment";
        UrlHelper: Codeunit "Url Helper";
        DummySetId: Integer;
        ErrorMsg: Text;
    begin
        MSWalletMerchantAccount.Get(PrimaryKey);
        if Page.RunModal(Page::"MS - Wallet Merchant Callback") <> Action::LookupOK then;

        if not RetrieveMerchantID(MSWalletMerchantAccount, ErrorMsg) then begin
            Message(FailedToRetrieveMerchantInvErr);
            exit;
        end;

        MSWalletMerchantAccount.Find();
        MSWalletMerchantAccount.HideAllDialogs();
        MSWalletMerchantAccount.Validate(Enabled, true);
        if UrlHelper.IsPPE() or UrlHelper.IsTIE() then
            MSWalletMerchantAccount.Validate("Test Mode", true);
        MSWalletMerchantAccount.Modify(true);

        if not PaymentServiceSetup.GetDefaultPaymentServices(DummySetId) then begin
            MSWalletMerchantAccount.Validate("Always Include on Documents", true);
            MSWalletMerchantAccount.Modify(true);
            O365SalesInvoicePayment.UpdatePaymentServicesForInvoicesQuotesAndOrders();
        end;

        Message(MerchantIDRetreivalSuccessInvMsg)
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRetrieveMerchantId(var MSWalletMerchantAccount: Record "MS - Wallet Merchant Account"; var Handled: Boolean);
    begin
    end;

    procedure GetDoneWithSignupNotificationID(): Guid;
    begin
        EXIT('ce917438-506c-4724-9b01-13c1b860e851');
    end;

    local procedure RetrieveMerchantID(var MSWalletMerchantAccount: Record "MS - Wallet Merchant Account"; var ErrorMsg: Text): Boolean;
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        EnvironmentInfo: Codeunit "Environment Information";
        UrlHelper: Codeunit "Url Helper";
        AzureADTenant: Codeunit "Azure AD Tenant";
        RequestHttpClient: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        JObject: JsonObject;
        ResponseText: Text;
        AccessToken: Text;
        MerchantAPI: Text;
        MerchantID: Text;
        MerchantAPIResource: Text;
        hasChargeableAccount: Boolean;
        Handled: Boolean;
    begin
        if not EnvironmentInfo.IsSaaS() then begin
            OnBeforeRetrieveMerchantId(MSWalletMerchantAccount, Handled);
            if Handled then
                exit(true);
        end;

        IF NOT AzureKeyVault.GetAzureKeyVaultSecret(MSWalletMerchantAPITxt, MerchantAPI) THEN BEGIN
            Session.LogMessage('00001NN', STRSUBSTNO(AzureKeyVaultTelemetryTxt, MSWalletMerchantAPITxt), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTok);
            ErrorMsg := AzureKeyVaultRetreiveErr;
            EXIT(FALSE);
        END;

        IF NOT AzureKeyVault.GetAzureKeyVaultSecret(MSWalletMerchantAPIResourceTxt, MerchantAPIResource) THEN BEGIN
            Session.LogMessage('00001NO', STRSUBSTNO(AzureKeyVaultTelemetryTxt, MSWalletMerchantAPIResourceTxt), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTok);
            ErrorMsg := AzureKeyVaultRetreiveErr;
            EXIT(FALSE);
        END;

        IF NOT AzureKeyVault.GetAzureKeyVaultSecret(MSWalletMerchantAPITxt, MerchantAPI) THEN BEGIN
            Session.LogMessage('00001NP', STRSUBSTNO(AzureKeyVaultTelemetryTxt, MSWalletMerchantAPITxt), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTok);
            ErrorMsg := AzureKeyVaultRetreiveErr;
            EXIT(FALSE);
        END;

        AccessToken := GetAuthorizationToken(MerchantAPIResource);

        IF AccessToken = '' THEN
            Session.LogMessage('00001PH', STRSUBSTNO(EmptyAccessTokenTxt, MerchantAPIResource), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTok);

        RequestMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Accept', 'application/json');
        RequestHeaders.Add('Authorization', STRSUBSTNO('Bearer %1', AccessToken));
        RequestHeaders.Add('x-ms-tenant-id', AzureADTenant.GetAadTenantId());
        IF UrlHelper.IsPPE() THEN
            RequestHeaders.Add('MS-AccountMode', 'Test');

        RequestMessage.SetRequestUri(MerchantAPI);
        RequestMessage.Method('GET');

        if not RequestHttpClient.Send(RequestMessage, ResponseMessage) then begin
            Session.LogMessage('00001NQ', STRSUBSTNO(MerchantAPITelemetryErr, ResponseMessage.HttpStatusCode(), GETLASTERRORTEXT()), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTok);
            ErrorMsg := MerchantAPIErrUserTxt;
            EXIT(FALSE);
        END;

        IF not ResponseMessage.IsSuccessStatusCode() THEN BEGIN
            Session.LogMessage('00001NR', STRSUBSTNO(MerchantAPITelemetryErr, ResponseMessage.HttpStatusCode(), ResponseMessage.ReasonPhrase()), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTok);
            ErrorMsg := MerchantAPIErrUserTxt;
            EXIT(FALSE);
        END;

        if not ResponseMessage.Content().ReadAs(ResponseText) then begin
            Session.LogMessage('00008IF', MerchantAPICannotReadResponseTelemetryTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTok);
            ErrorMsg := MerchantAPICannotReadResponseTxt;
            exit(false);
        end;

        if ResponseText = '' then begin
            Session.LogMessage('00008I1', MerchantAPIEmptyResponseTelemetryTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTok);
            ErrorMsg := MerchantAPIEmptyResponseTxt;
            exit(false);
        end;

        if not JObject.ReadFrom(ResponseText) then begin
            Session.LogMessage('00008I2', MerchantAPIIncorrectResponseTelemetryTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTok);
            ErrorMsg := MerchantAPIIncorrectResponseTxt;
            exit(false);
        end;

        IF NOT GetBooleanPropertyFromJObject(JObject, 'hasChargeableAccount', hasChargeableAccount) THEN BEGIN
            Session.LogMessage('00001NS', STRSUBSTNO(MerchantAPIJsonPropertyTelemetryErr, 'hasChargeableAccount'), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTok);
            ErrorMsg := STRSUBSTNO(MerchantAPIJsonPropertyErr, 'hasChargeableAccount');
            EXIT(FALSE);
        END;

        IF NOT GetTextPropertyFromJObject(JObject, 'id', MerchantID) THEN BEGIN
            Session.LogMessage('00001NT', STRSUBSTNO(MerchantAPIJsonPropertyTelemetryErr, 'id'), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTok);
            ErrorMsg := STRSUBSTNO(MerchantAPIJsonPropertyErr, 'id');
            EXIT(FALSE);
        END;

        IF NOT hasChargeableAccount THEN BEGIN
            Session.LogMessage('00001NU', MerchantAPIChargableTelemetryErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTok);
            ErrorMsg := STRSUBSTNO(MerchantAPIChargableErr, MerchantID);
            EXIT(FALSE);
        END;

        IF MSWalletMerchantAccount."Merchant ID" <> MerchantID THEN BEGIN
            Session.LogMessage('00008I3', UpdateMerchantIdTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTok);
            MSWalletMerchantAccount.VALIDATE("Merchant ID", COPYSTR(MerchantID, 1, MAXSTRLEN(MSWalletMerchantAccount."Merchant ID")));
            MSWalletMerchantAccount.MODIFY(TRUE);
        END;

        EXIT(TRUE);
    end;

    procedure MerchantSignupCallBack(SendNotification: Notification);
    var
        MSWalletMerchantAccount: Record "MS - Wallet Merchant Account";
        ErrorMsg: Text;
    begin
        MSWalletMerchantAccount.GET(SendNotification.GETDATA(MerchantIDNotificationKey()));

        IF RetrieveMerchantID(MSWalletMerchantAccount, ErrorMsg) THEN
            MESSAGE(MerchantIDRetreivalSuccessMsg)
        ELSE
            ERROR(ErrorMsg);
    end;

    procedure MerchantIDNotificationKey(): Text;
    begin
        EXIT('PrimaryKey');
    end;

    local procedure GetAuthorizationToken(MerchantAPIResource: Text) AccessToken: Text;
    var
        AzureADMgt: Codeunit "Azure AD Mgt.";
        EnvInfoProxy: Codeunit "Env. Info Proxy";
        ShowAzureAdDialog: Boolean;
    begin
        // OnBehalfOf - Only works for JWT Tokens
        AccessToken := AzureADMgt.GetOnBehalfAccessToken(MerchantAPIResource);

        if AccessToken <> '' then
            exit;

        // Fallback to AuthorizationCode based refresh token
        Session.LogMessage('00007AD', OnBehalfFailedTelemetryTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTok);
        ShowAzureAdDialog := true;
        if EnvInfoProxy.IsInvoicing() then
            ShowAzureAdDialog := false;

        AccessToken := AzureADMgt.GetAccessToken(MerchantAPIResource, 'Merchant Management', ShowAzureAdDialog);

        if AccessToken = '' then
            Session.LogMessage('00007AE', AuthTokenFallbackFailedTelemetryTxt, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTok);
    end;

    local procedure GetBooleanPropertyFromJObject(JObject: JsonObject; PropertyKey: Text; var PropertyValue: Boolean): Boolean;
    var
        JValue: JsonValue;
    begin
        if not GetJsonValueFromJObject(JObject, PropertyKey, JValue) then
            exit(false);
        PropertyValue := JValue.AsBoolean();
        exit(true);
    end;

    local procedure GetTextPropertyFromJObject(JObject: JsonObject; PropertyKey: Text; var PropertyValue: Text): Boolean;
    var
        JValue: JsonValue;
    begin
        if not GetJsonValueFromJObject(JObject, PropertyKey, JValue) then
            exit(false);
        PropertyValue := JValue.AsText();
        exit(true);
    end;

    local procedure GetJsonValueFromJObject(JObject: JsonObject; PropertyKey: Text; var JValue: JsonValue): Boolean;
    var
        JToken: JsonToken;
    begin
        if not JObject.Get(PropertyKey, JToken) then
            exit(false);
        if not JToken.IsValue() then
            exit(false);
        JValue := JToken.AsValue();
        if JValue.IsNull() then
            exit(false);
        exit(true);
    end;
}
#endif