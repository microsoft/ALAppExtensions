// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 10538 "MTD OAuth 2.0 Mgt"
{
    trigger OnRun()
    begin

    end;

    var
        OAuth20Mgt: Codeunit "OAuth 2.0 Mgt.";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        EnvironmentInformation: Codeunit "Environment Information";
        OAuthPRODSetupLbl: Label 'HMRC VAT', Locked = true;
        OAuthSandboxSetupLbl: Label 'HMRC VAT Sandbox', Locked = true;
        ServiceURLPRODTxt: Label 'https://api.service.hmrc.gov.uk', Locked = true;
        ServiceURLSandboxTxt: Label 'https://test-api.service.hmrc.gov.uk', Locked = true;
        ServiceURLMockServiceTxt: Label 'https://localhost:8080/test-api.service.hmrc.gov.uk', Locked = true;
        ServiceConnectionPRODSetupLbl: Label 'HMRC VAT Setup';
        ServiceConnectionSandboxSetupLbl: Label 'HMRC VAT Sandbox Setup';
        OAuthPRODSetupDescriptionLbl: Label 'HMRC Making Tax Digital VAT Returns';
        OAuthSandboxSetupDescriptionLbl: Label 'HMRC Making Tax Digital VAT Returns Sandbox';
        CheckCompanyVATNoAfterSuccessAuthorizationQst: Label 'Authorization successful.\Do you want to open the Company Information setup to verify the VAT registration number?';
        PRODAzureClientIDTxt: Label 'UKHMRC-MTDVAT-PROD-ClientID', Locked = true;
        PRODAzureClientSecretTxt: Label 'UKHMRC-MTDVAT-PROD-ClientSecret', Locked = true;
        SandboxAzureClientIDTxt: Label 'UKHMRC-MTDVAT-Sandbox-ClientID', Locked = true;
        SandboxAzureClientSecretTxt: Label 'UKHMRC-MTDVAT-Sandbox-ClientSecret', Locked = true;
        RedirectURLTxt: Label 'urn:ietf:wg:oauth:2.0:oob', Locked = true;
        ScopeTxt: Label 'write:vat read:vat', Locked = true;
        AuthorizationURLPathTxt: Label '/oauth/authorize', Locked = true;
        AccessTokenURLPathTxt: Label '/oauth/token', Locked = true;
        RefreshTokenURLPathTxt: Label '/oauth/token', Locked = true;
        AuthorizationResponseTypeTxt: Label 'code', Locked = true;
        HMRCFraudPreventHeadersTok: label 'HMRC Fraud Prevention Headers', Locked = true;
        FraudPreventHeadersValidTxt: Label 'Fraud prevention headers are valid. ', Locked = true;
        FraudPreventHeadersNotValidTxt: Label 'Fraud prevention headers are NOT valid. ', Locked = true;
        JsonTextBlankErr: Label 'JSON text is blank. ', Locked = true;
        CannotReadJsonErr: Label 'Cannot read JSON. ', Locked = true;
        JsonKeyMissingErr: Label 'JSON key %1 is missing. ', Locked = true;
        CannotReadJsonValueErr: Label 'Cannot read value from JSON key %1. ', Locked = true;
        JsonValueBlankErr: Label 'Value from key %1 is blank. ', Locked = true;
        JsonValueNotMatchedErr: Label 'Value from key %1 does not match validation pattern %2. ', Locked = true;
        ClientBrowserDoNotTrackTxt: Label 'GOV-CLIENT-BROWSER-DO-NOT-TRACK', Locked = true;
        ClientBrowserJsUserAgentTxt: Label 'GOV-CLIENT-BROWSER-JS-USER-AGENT', Locked = true;
        ClientConnectionMethodTxt: Label 'GOV-CLIENT-CONNECTION-METHOD', Locked = true;
        ClientDeviceIdTxt: Label 'GOV-CLIENT-DEVICE-ID', Locked = true;
        ClientPublicIpTxt: Label 'GOV-CLIENT-PUBLIC-IP', Locked = true;
        ClientPublicIpTimestampTxt: Label 'GOV-CLIENT-PUBLIC-IP-TIMESTAMP', Locked = true;
        ClientScreensTxt: Label 'GOV-CLIENT-SCREENS', Locked = true;
        ClientTimezoneTxt: Label 'GOV-CLIENT-TIMEZONE', Locked = true;
        ClientUserIdsTxt: Label 'GOV-CLIENT-USER-IDS', Locked = true;
        ClientWindowSizeTxt: Label 'GOV-CLIENT-WINDOW-SIZE', Locked = true;
        VendorForwardedTxt: Label 'GOV-VENDOR-FORWARDED', Locked = true;
        VendorLicenseIdsTxt: Label 'GOV-VENDOR-LICENSE-IDS', Locked = true;
        VendorProductNameTxt: Label 'GOV-VENDOR-PRODUCT-NAME', Locked = true;
        VendorPublicIpTxt: Label 'GOV-VENDOR-PUBLIC-IP', Locked = true;
        VendorVersionTxt: Label 'GOV-VENDOR-VERSION', Locked = true;
        AzFunctionClientIdKeyTok: Label 'AppNetProxyFnClientID', Locked = true;
        AzFuncScopeKeyTok: Label 'AppNetProxyFnScope', Locked = true;
        AzFuncAuthURLKeyTok: Label 'AppNetProxyFnAuthUrl', Locked = true;
        AzFuncCertificateNameTok: Label 'ElectronicInvoicingCertificateName', Locked = true;
        AzFuncEndpointTextKeyTok: Label 'ClientPublicIP-Endpoint', Locked = true;
        CannotGetAuthorityURLFromKeyVaultErr: Label 'Cannot get Authority URL from Azure Key Vault using key %1', Locked = true;
        CannotGetClientIdFromKeyVaultErr: Label 'Cannot get Client ID from Azure Key Vault using key %1', Locked = true;
        CannotGetCertFromKeyVaultErr: Label 'Cannot get certificate from Azure Key Vault using key %1', Locked = true;
        CannotGetScopeFromKeyVaultErr: Label 'Cannot get Scope from Azure Key Vault using key %1', Locked = true;
        CannotGetEndpointTextFromKeyVaultErr: Label 'Cannot get Endpoint from Azure Key Vault using key %1 ', Locked = true;
        GetPublicIPAddressRequestFailedErr: Label 'Getting server public IP address from Azure Function failed.', Locked = true;
        EmptyPublicIPAddressErr: Label 'Azure Function returned empty server public IP address.', Locked = true;
        NonEmptyPublicIPAddressTxt: Label 'Non-empty server public IP address was returned by Azure Function', Locked = true;
        IPv4LoopbackIPAddressTxt: Label '127.0.0.1', Locked = true;
        IPv6LoopbackIPAddressTxt: Label '::1', Locked = true;

    internal procedure GetOAuthPRODSetupCode() Result: Code[20]
    begin
        Result := CopyStr(OAuthPRODSetupLbl, 1, MaxStrLen(Result))
    end;

    internal procedure GetOAuthSandboxSetupCode() Result: Code[20]
    begin
        Result := CopyStr(OAuthSandboxSetupLbl, 1, MaxStrLen(Result))
    end;

    internal procedure InitOAuthSetup(var OAuth20Setup: Record "OAuth 2.0 Setup"; OAuthSetupCode: Code[20])
    begin
        with OAuth20Setup do begin
            if not Get(OAuthSetupCode) then begin
                Code := OAuthSetupCode;
                Status := Status::Disabled;
                Insert();
            end;
            if OAuthSetupCode = GetOAuthPRODSetupCode() then begin
                "Service URL" := CopyStr(ServiceURLPRODTxt, 1, MaxStrLen("Service URL"));
                Description := CopyStr(OAuthPRODSetupDescriptionLbl, 1, MaxStrLen(Description));
            end else begin
                "Service URL" := CopyStr(ServiceURLSandboxTxt, 1, MaxStrLen("Service URL"));
                Description := CopyStr(OAuthsandboxSetupDescriptionLbl, 1, MaxStrLen(Description));
            end;
            "Redirect URL" := CopyStr(GetDefaultRedirectURL(), 1, MaxStrLen("Redirect URL"));
            Scope := ScopeTxt;
            "Authorization URL Path" := AuthorizationURLPathTxt;
            "Access Token URL Path" := AccessTokenURLPathTxt;
            "Refresh Token URL Path" := RefreshTokenURLPathTxt;
            "Authorization Response Type" := AuthorizationResponseTypeTxt;
            "Token DataScope" := "Token DataScope"::Company;
            "Daily Limit" := 1000;
            Modify();
        end;
    end;

    local procedure GetDefaultRedirectURL(): Text
    var
        OAuth2: Codeunit OAuth2;
        EnvironmentInformation: Codeunit "Environment Information";
        redirect: Text;
    begin
        if EnvironmentInformation.IsSaaS() then begin
            OAuth2.GetDefaultRedirectURL(redirect);
            if redirect <> '' then
                exit(redirect);
        end;

        exit(RedirectURLTxt);
    end;

    [EventSubscriber(ObjectType::Table, Database::"OAuth 2.0 Setup", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeleteEvent(var Rec: Record "OAuth 2.0 Setup")
    begin
        if Rec.IsTemporary() then
            exit;

        if not IsMTDOAuthSetup(Rec) then
            exit;

        with Rec do begin
            DeleteToken("Client ID");
            DeleteToken("Client Secret");
            DeleteToken("Access Token");
            DeleteToken("Refresh Token");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Connection", 'OnRegisterServiceConnection', '', true, true)]
    local procedure OnRegisterServiceConnection(var ServiceConnection: Record "Service Connection")
    var
        VATReportSetup: Record "VAT Report Setup";
        OAuth20Setup: Record "OAuth 2.0 Setup";
        ServiceConnectionSetupLbl: Text;
        OAuthSetupCode: Code[20];
    begin
        if not VATReportSetup.Get() then
            exit;

        OAuthSetupCode := VATReportSetup.GetMTDOAuthSetupCode();
        if OAuthSetupCode = '' then
            exit;

        if not OAuth20Setup.Get(OAuthSetupCode) then
            InitOAuthSetup(OAuth20Setup, OAuthSetupCode);
        ServiceConnection.Status := OAuth20Setup.Status;

        if OAuth20Setup.Code = GetOAuthPRODSetupCode() then
            ServiceConnectionSetupLbl := ServiceConnectionPRODSetupLbl
        else
            ServiceConnectionSetupLbl := ServiceConnectionSandboxSetupLbl;

        ServiceConnection.InsertServiceConnection(
          ServiceConnection, OAuth20Setup.RecordId(), ServiceConnectionSetupLbl, '', PAGE::"OAuth 2.0 Setup");
    end;

    [NonDebuggable]
    [EventSubscriber(ObjectType::Table, Database::"OAuth 2.0 Setup", 'OnBeforeRequestAuthoizationCode', '', true, true)]
    local procedure OnBeforeRequestAuthoizationCode(OAuth20Setup: Record "OAuth 2.0 Setup"; var Processed: Boolean)
    var
        EnvironmentInfo: Codeunit "Environment Information";
        OAuth2ControlAddIn: Page OAuth2ControlAddIn;
        auth_error: Text;
        AuthorizationCode: Text;
        url: Text;
        state: Text;
    begin
        if not IsMTDOAuthSetup(OAuth20Setup) or Processed then
            exit;
        Processed := true;

        CheckOAuthConsistencySetup(OAuth20Setup);
        UpdateClientTokens(OAuth20Setup);
        if not EnvironmentInfo.IsSaaS() then begin
            Hyperlink(OAuth20Mgt.GetAuthorizationURLAsSecretText(OAuth20Setup, GetToken(OAuth20Setup."Client ID", OAuth20Setup.GetTokenDataScope()).Unwrap()).Unwrap());
            exit;
        end;

        state := Format(CreateGuid(), 0, 4);
        url := OAuth20Mgt.GetAuthorizationURLAsSecretText(OAuth20Setup, GetToken(OAuth20Setup."Client ID", OAuth20Setup.GetTokenDataScope()).Unwrap() + '&state=' + state).Unwrap();
        OAuth2ControlAddIn.SetOAuth2Properties(url, state);
        OAuth2ControlAddIn.RunModal();

        auth_error := OAuth2ControlAddIn.GetAuthError();
        if auth_error <> '' then
            Error(auth_error);

        AuthorizationCode := OAuth2ControlAddIn.GetAuthCode();
        if AuthorizationCode <> '' then begin
            OAuth20Setup.Find();
            if not OAuth20Setup.RequestAccessToken(auth_error, AuthorizationCode) then
                Error(auth_error);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"OAuth 2.0 Setup", 'OnBeforeRequestAccessToken', '', true, true)]
    [NonDebuggable]
    local procedure OnBeforeRequestAccessToken(var OAuth20Setup: Record "OAuth 2.0 Setup"; AuthorizationCode: Text; var Result: Boolean; var MessageText: Text; var Processed: Boolean)
    var
        MTDSessionFraudPrevHdr: Record "MTD Session Fraud Prev. Hdr";
        RequestJSON: Text;
        AccessToken: SecretText;
        RefreshToken: SecretText;
        TokenDataScope: DataScope;
    begin
        if not IsMTDOAuthSetup(OAuth20Setup) or Processed then
            exit;
        Processed := true;

        CheckOAuthConsistencySetup(OAuth20Setup);
        MTDSessionFraudPrevHdr.DeleteAll();
        AddFraudPreventionHeaders(RequestJSON, false);

        TokenDataScope := OAuth20Setup.GetTokenDataScope();

        Result :=
            OAuth20Mgt.RequestAccessTokenWithGivenRequestJson(
                OAuth20Setup, RequestJSON, MessageText, AuthorizationCode,
                GetToken(OAuth20Setup."Client ID", TokenDataScope).Unwrap(),
                GetToken(OAuth20Setup."Client Secret", TokenDataScope),
                AccessToken, RefreshToken);

        if Result then
            SaveTokens(OAuth20Setup, TokenDataScope, AccessToken, RefreshToken);
    end;

    [EventSubscriber(ObjectType::Table, Database::"OAuth 2.0 Setup", 'OnAfterRequestAccessToken', '', true, true)]
    local procedure OnAfterRequestAccessToken(OAuth20Setup: Record "OAuth 2.0 Setup"; Result: Boolean; var MessageText: Text)
    begin
        if not IsMTDOAuthSetup(OAuth20Setup) then
            exit;

        if Result then begin
            MessageText := '';
            if Confirm(CheckCompanyVATNoAfterSuccessAuthorizationQst) then
                Page.RunModal(Page::"Company Information")
        end;
    end;

    [NonDebuggable]
    [EventSubscriber(ObjectType::Table, Database::"OAuth 2.0 Setup", 'OnBeforeRefreshAccessToken', '', true, true)]
    local procedure OnBeforeRefreshAccessToken(var OAuth20Setup: Record "OAuth 2.0 Setup"; var Result: Boolean; var MessageText: Text; var Processed: Boolean)
    var
        RequestJSON: Text;
        AccessToken: SecretText;
        RefreshToken: SecretText;
        TokenDataScope: DataScope;
    begin
        if not IsMTDOAuthSetup(OAuth20Setup) or Processed then
            exit;
        Processed := true;

        CheckOAuthConsistencySetup(OAuth20Setup);
        AddFraudPreventionHeaders(RequestJSON, true);

        TokenDataScope := OAuth20Setup.GetTokenDataScope();
        RefreshToken := GetToken(OAuth20Setup."Refresh Token", TokenDataScope);

        Result :=
            OAuth20Mgt.RefreshAccessTokenWithGivenRequestJson(
                OAuth20Setup, RequestJSON, MessageText,
                GetToken(OAuth20Setup."Client ID", TokenDataScope).Unwrap(),
                GetToken(OAuth20Setup."Client Secret", TokenDataScope),
                AccessToken, RefreshToken);

        if Result then
            SaveTokens(OAuth20Setup, TokenDataScope, AccessToken, RefreshToken);
    end;

    [NonDebuggable]
    local procedure SaveTokens(var OAuth20Setup: Record "OAuth 2.0 Setup"; TokenDataScope: DataScope; AccessToken: SecretText; RefreshToken: SecretText)
    var
        TypeHelper: Codeunit "Type Helper";
        NewAccessTokenDateTime: DateTime;
    begin
        SetToken(OAuth20Setup."Access Token", AccessToken, TokenDataScope);
        SetToken(OAuth20Setup."Refresh Token", RefreshToken, TokenDataScope);
        NewAccessTokenDateTime := TypeHelper.AddHoursToDateTime(CurrentDateTime(), 2);
        if OAuth20Setup."Access Token Due DateTime" = 0DT then
            OAuth20Setup."Access Token Due DateTime" := NewAccessTokenDateTime
        else
            if OAuth20Setup."Access Token Due DateTime" < NewAccessTokenDateTime then
                OAuth20Setup."Access Token Due DateTime" := NewAccessTokenDateTime;
        OAuth20Setup.Modify();
        Commit(); // need to prevent rollback to save new keys
    end;

    [NonDebuggable]
    [EventSubscriber(ObjectType::Table, Database::"OAuth 2.0 Setup", 'OnBeforeInvokeRequest', '', true, true)]
    local procedure OnBeforeInvokeRequest(var OAuth20Setup: Record "OAuth 2.0 Setup"; RequestJSON: Text; var ResponseJSON: Text; var HttpError: Text; var Result: Boolean; var Processed: Boolean; RetryOnCredentialsFailure: Boolean)
    begin
        if not IsMTDOAuthSetup(OAuth20Setup) or Processed then
            exit;
        Processed := true;

        CheckOAuthConsistencySetup(OAuth20Setup);
        AddFraudPreventionHeaders(RequestJSON, true);

        Result :=
            OAuth20Mgt.InvokeRequest(
                OAuth20Setup, RequestJSON, ResponseJSON, HttpError,
                GetToken(OAuth20Setup."Access Token", OAuth20Setup.GetTokenDataScope()), RetryOnCredentialsFailure);
    end;

    [NonDebuggable]
    local procedure UpdateClientTokens(var OAuth20Setup: Record "OAuth 2.0 Setup")
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        EnvironmentInformation: Codeunit "Environment Information";
        AzureClientIDTxt: Text;
        AzureClientSecretTxt: Text;
        KeyValue: SecretText;
        IsModify: Boolean;
        TokenDataScope: DataScope;
    begin
        if not EnvironmentInformation.IsSaaS() then
            exit;

        if OAuth20Setup.Code = GetOAuthPRODSetupCode() then begin
            AzureClientIDTxt := PRODAzureClientIDTxt;
            AzureClientSecretTxt := PRODAzureClientSecretTxt;
        end else begin
            AzureClientIDTxt := SandboxAzureClientIDTxt;
            AzureClientSecretTxt := SandboxAzureClientSecretTxt;
        end;
        TokenDataScope := OAuth20Setup.GetTokenDataScope();
        if AzureKeyVault.GetAzureKeyVaultSecret(AzureClientIDTxt, KeyValue) then
            if not KeyValue.IsEmpty() then
                if KeyValue.Unwrap() <> GetToken(OAuth20Setup."Client ID", TokenDataScope).Unwrap() then
                    IsModify := SetToken(OAuth20Setup."Client ID", KeyValue, TokenDataScope);
        if AzureKeyVault.GetAzureKeyVaultSecret(AzureClientSecretTxt, KeyValue) then
            if not KeyValue.IsEmpty() then
                if KeyValue.Unwrap() <> GetToken(OAuth20Setup."Client Secret", TokenDataScope).Unwrap() then
                    IsModify := SetToken(OAuth20Setup."Client Secret", KeyValue, TokenDataScope);
        if IsModify then
            OAuth20Setup.Modify();
    end;

    [NonDebuggable]
    internal procedure SetToken(var TokenKey: Guid; TokenValue: SecretText; TokenDataScope: DataScope) NewToken: Boolean
    begin
        if IsNullGuid(TokenKey) then
            NewToken := true;
        if NewToken then
            TokenKey := CreateGuid();

        if EncryptionEnabled() then
            IsolatedStorage.SetEncrypted(TokenKey, TokenValue, TokenDataScope)
        else
            IsolatedStorage.Set(TokenKey, TokenValue, TokenDataScope);
    end;

    local procedure GetToken(TokenKey: Guid; TokenDataScope: DataScope) TokenValue: SecretText
    begin
        if not HasToken(TokenKey, TokenDataScope) then
            exit(TokenValue);

        IsolatedStorage.Get(TokenKey, TokenDataScope, TokenValue);
    end;

    local procedure HasToken(TokenKey: Guid; TokenDataScope: DataScope): Boolean
    begin
        exit(not IsNullGuid(TokenKey) and IsolatedStorage.Contains(TokenKey, TokenDataScope));
    end;

    internal procedure IsMTDOAuthSetup(OAuth20Setup: Record "OAuth 2.0 Setup"): Boolean
    var
        VATReportSetup: Record "VAT Report Setup";
        OAuthSetupCode: Code[20];
    begin
        if VATReportSetup.Get() then
            OAuthSetupCode := VATReportSetup.GetMTDOAuthSetupCode();
        exit((OAuthSetupCode <> '') and (OAuthSetupCode = OAuth20Setup.Code));
    end;

    local procedure CheckOAuthConsistencySetup(OAuth20Setup: Record "OAuth 2.0 Setup")
    begin
        with OAuth20Setup do begin
            case Code of
                GetOAuthPRODSetupCode():
                    TestField("Service URL", CopyStr(ServiceURLPRODTxt, 1, MaxStrLen("Service URL")));
                GetOAuthSandboxSetupCode():
                    IF StrPos("Service URL", ServiceURLMockServiceTxt) <> 1 then
                        TestField("Service URL", CopyStr(ServiceURLSandboxTxt, 1, MaxStrLen("Service URL")));
                else
                    TestField("Service URL", '');
            end;

            TestField(Scope, ScopeTxt);
            TestField("Authorization URL Path", AuthorizationURLPathTxt);
            TestField("Access Token URL Path", AccessTokenURLPathTxt);
            TestField("Refresh Token URL Path", RefreshTokenURLPathTxt);
            TestField("Authorization Response Type", AuthorizationResponseTypeTxt);
            TestField("Daily Limit", 1000);
        end;
    end;

    local procedure AddFraudPreventionHeaders(var RequestJSON: Text; ConfirmHeaders: Boolean)
    var
        MTDFraudPreventionMgt: Codeunit "MTD Fraud Prevention Mgt.";
    begin
        MTDFraudPreventionMgt.AddFraudPreventionHeaders(RequestJSON, ConfirmHeaders);
        LogFraudPreventionHeadersValidity(RequestJSON);
    end;

    local procedure LogFraudPreventionHeadersValidity(RequestJSON: Text)
    var
        VATReportSetup: Record "VAT Report Setup";
        CustomDimensions: Dictionary of [Text, Text];
        JsonObject: JsonObject;
        HeaderJsonToken: JsonToken;
        ErrorText: Text;
        ClientIPAddrErrorText: Text;
        VendorIPAddrErrorText: Text;
    begin
        if RequestJSON = '' then begin
            FeatureTelemetry.LogError('0000LJE', HMRCFraudPreventHeadersTok, '', JsonTextBlankErr);
            exit;
        end;

        if not JsonObject.ReadFrom(RequestJSON) then begin
            FeatureTelemetry.LogError('0000LJF', HMRCFraudPreventHeadersTok, '', CannotReadJsonErr);
            exit;
        end;

        if not JsonObject.Get('Header', HeaderJsonToken) then begin
            FeatureTelemetry.LogError('0000LJG', HMRCFraudPreventHeadersTok, '', StrSubstNo(JsonKeyMissingErr, 'Header'));
            exit;
        end;

        JsonObject := HeaderJsonToken.AsObject();

        ClientIPAddrErrorText := CheckJsonTokenValidity(JsonObject, ClientPublicIpTxt, '[0-9]{1,3}(\.[0-9]{1,3}){3}|([0-9A-Fa-f]{0,4}:){2,7}([0-9A-Fa-f]{1,4})');   // IPv4 or IPv6
        VendorIPAddrErrorText := CheckJsonTokenValidity(JsonObject, VendorPublicIpTxt, '[0-9]{1,3}(\.[0-9]{1,3}){3}|([0-9A-Fa-f]{0,4}:){2,7}([0-9A-Fa-f]{1,4})');   // IPv4 or IPv6
        ErrorText += ClientIPAddrErrorText;
        ErrorText += VendorIPAddrErrorText;
        if (ClientIPAddrErrorText <> '') or (VendorIPAddrErrorText <> '') then
            if VATReportSetup.Get() then
                CustomDimensions.Add('PublicIPServiceURL', VATReportSetup."MTD FP Public IP Service URL");
        CustomDimensions.Add('IsClientIPAddressLoopback', Format(IsLoopbackIPAddress(GetJsonTokenValue(JsonObject, ClientPublicIpTxt))));
        CustomDimensions.Add('IsVendorIPAddressLoopback', Format(IsLoopbackIPAddress(GetJsonTokenValue(JsonObject, VendorPublicIpTxt))));

        ErrorText += CheckJsonTokenValidity(JsonObject, ClientBrowserDoNotTrackTxt, 'true|false');              // true or false
        ErrorText += CheckJsonTokenValidity(JsonObject, ClientBrowserJsUserAgentTxt, '\w+');                    // any letter, digit, or underscore
        ErrorText += CheckJsonTokenValidity(JsonObject, ClientConnectionMethodTxt, 'WEB_APP_VIA_SERVER');       // WEB_APP_VIA_SERVER
        ErrorText += CheckJsonTokenValidity(JsonObject, ClientDeviceIdTxt, '\w+');                              // any letter, digit, or underscore
        ErrorText += CheckJsonTokenValidity(JsonObject, ClientPublicIpTimestampTxt, '\d+[:\.-]\d+[:\.-]\d+');   // for example 13:00:00
        ErrorText += CheckJsonTokenValidity(JsonObject, ClientScreensTxt, '^(?=.*width)(?=.*height).*$');       // width and height must be present in any order
        ErrorText += CheckJsonTokenValidity(JsonObject, ClientTimezoneTxt, '[-+]\d{1,2}');                      // for example +02
        ErrorText += CheckJsonTokenValidity(JsonObject, ClientUserIdsTxt, 'Business.*Central');                 // Business Central
        ErrorText += CheckJsonTokenValidity(JsonObject, ClientWindowSizeTxt, '^(?=.*width)(?=.*height).*$');    // width and height must be present in any order
        ErrorText += CheckJsonTokenValidity(JsonObject, VendorForwardedTxt, '[0-9]{1,3}(\.[0-9]{1,3}){3}|([0-9A-Fa-f]{0,4}:){2,7}([0-9A-Fa-f]{1,4})');  // IPv4 or IPv6
        ErrorText += CheckJsonTokenValidity(JsonObject, VendorLicenseIdsTxt, 'Business.*Central.*\w+');         // Business Central and any letter, digit, or underscore
        ErrorText += CheckJsonTokenValidity(JsonObject, VendorProductNameTxt, 'Business.*Central');             // Business Central
        ErrorText += CheckJsonTokenValidity(JsonObject, VendorVersionTxt, 'Business.*Central.*=\d+');           // for example Business Central=23

        if ErrorText <> '' then
            FeatureTelemetry.LogError('0000LJH', HMRCFraudPreventHeadersTok, FraudPreventHeadersNotValidTxt, ErrorText, '', CustomDimensions)
        else
            FeatureTelemetry.LogUsage('0000LJI', HMRCFraudPreventHeadersTok, FraudPreventHeadersValidTxt);
    end;

    [TryFunction]
    [NonDebuggable]
    internal procedure GetServerPublicIPFromAzureFunction(var ServerIPAddress: Text)
    var
        AzureFunctions: Codeunit "Azure Functions";
        AzureFunctionsResponse: Codeunit "Azure Functions Response";
        AzureFunctionsAuthentication: Codeunit "Azure Functions Authentication";
        AzureFunctionsAuth: Interface "Azure Functions Authentication";
        ResultResponseMsg: HttpResponseMessage;
        ClientID, Scope, AuthURL, Endpoint : Text;
        CustomDimensions: Dictionary of [Text, Text];
        QueryDict: Dictionary of [Text, Text];
        Cert: SecretText;
    begin
        if not EnvironmentInformation.IsSaaS() then
            exit;

        GetAzFunctionSecrets(ClientID, Cert, AuthURL, Scope, Endpoint);
        AzureFunctionsAuth := AzureFunctionsAuthentication.CreateOAuth2WithCert(Endpoint, '', ClientID, Cert, AuthURL, '', Scope);
        AzureFunctionsResponse := AzureFunctions.SendGetRequest(AzureFunctionsAuth, QueryDict);
        if not AzureFunctionsResponse.IsSuccessful() then begin
            AzureFunctionsResponse.GetHttpResponse(ResultResponseMsg);
            CustomDimensions.Add('HttpStatusCode', Format(ResultResponseMsg.HttpStatusCode));
            CustomDimensions.Add('ResponseError', AzureFunctionsResponse.GetError());
            CustomDimensions.Add('ReasonPhrase', ResultResponseMsg.ReasonPhrase);
            CustomDimensions.Add('IsBlockedByEnvironment', Format(ResultResponseMsg.IsBlockedByEnvironment));
            FeatureTelemetry.LogError('0000NRO', HMRCFraudPreventHeadersTok, '', GetPublicIPAddressRequestFailedErr, '', CustomDimensions);
        end;
        AzureFunctionsResponse.GetResultAsText(ServerIPAddress);
        if ServerIPAddress = '' then
            FeatureTelemetry.LogError('0000NRP', HMRCFraudPreventHeadersTok, '', EmptyPublicIPAddressErr)
        else
            FeatureTelemetry.LogUsage('0000NRW', HMRCFraudPreventHeadersTok, NonEmptyPublicIPAddressTxt);
    end;

    [NonDebuggable]
    local procedure GetAzFunctionSecrets(var ClientID: Text; var Certificate: SecretText; var AuthURL: Text; var Scope: Text; var Endpoint: Text)
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        CertificateName: Text;
    begin
        if not EnvironmentInformation.IsSaaS() then
            exit;

        if not AzureKeyVault.GetAzureKeyVaultSecret(AzFunctionClientIdKeyTok, ClientID) then begin
            FeatureTelemetry.LogError('0000NRQ', HMRCFraudPreventHeadersTok, '', StrSubstNo(CannotGetClientIdFromKeyVaultErr, AzFunctionClientIdKeyTok));
            exit;
        end;

        if not AzureKeyVault.GetAzureKeyVaultSecret(AzFuncCertificateNameTok, CertificateName) then begin
            FeatureTelemetry.LogError('0000NRR', HMRCFraudPreventHeadersTok, '', StrSubstNo(CannotGetCertFromKeyVaultErr, AzFuncCertificateNameTok));
            exit;
        end;
        if not AzureKeyVault.GetAzureKeyVaultCertificate(CertificateName, Certificate) then begin
            FeatureTelemetry.LogError('0000NRS', HMRCFraudPreventHeadersTok, '', StrSubstNo(CannotGetCertFromKeyVaultErr, AzFuncCertificateNameTok));
            exit;
        end;

        if not AzureKeyVault.GetAzureKeyVaultSecret(AzFuncAuthURLKeyTok, AuthURL) then begin
            FeatureTelemetry.LogError('0000NRT', HMRCFraudPreventHeadersTok, '', StrSubstNo(CannotGetAuthorityURLFromKeyVaultErr, AzFuncAuthURLKeyTok));
            exit;
        end;

        if not AzureKeyVault.GetAzureKeyVaultSecret(AzFuncScopeKeyTok, Scope) then begin
            FeatureTelemetry.LogError('0000NRU', HMRCFraudPreventHeadersTok, '', StrSubstNo(CannotGetScopeFromKeyVaultErr, AzFuncScopeKeyTok));
            exit;
        end;

        if not AzureKeyVault.GetAzureKeyVaultSecret(AzFuncEndpointTextKeyTok, Endpoint) then begin
            FeatureTelemetry.LogError('0000NRV', HMRCFraudPreventHeadersTok, '', StrSubstNo(CannotGetEndpointTextFromKeyVaultErr, AzFuncEndpointTextKeyTok));
            exit;
        end;
    end;

    local procedure CheckJsonTokenValidity(var JsonObject: JsonObject; TokenKey: Text; ValidationRegExPattern: Text) ErrorText: Text
    var
        JsonToken: JsonToken;
        TextValue: Text;
        RegEx: DotNet Regex;
        RegExOptions: DotNet RegexOptions;
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then begin
            ErrorText := StrSubstNo(JsonKeyMissingErr, TokenKey);
            exit;
        end;

        if not JsonToken.WriteTo(TextValue) then begin
            ErrorText := StrSubstNo(CannotReadJsonValueErr, TokenKey);
            exit;
        end;

        if TextValue = '' then begin
            ErrorText := StrSubstNo(JsonValueBlankErr, TokenKey);
            exit;
        end;

        RegEx := RegEx.Regex(ValidationRegExPattern, RegExOptions.IgnoreCase);
        if not RegEx.IsMatch(TextValue) then begin
            ErrorText := StrSubstNo(JsonValueNotMatchedErr, TokenKey, ValidationRegExPattern);
            exit;
        end;
    end;

    local procedure GetJsonTokenValue(var JsonObject: JsonObject; TokenKey: Text) TextValue: Text
    var
        JsonToken: JsonToken;
    begin
        if JsonObject.Get(TokenKey, JsonToken) then
            if JsonToken.WriteTo(TextValue) then
                exit(TextValue);
    end;

    local procedure IsLoopbackIPAddress(IPAddress: Text): Boolean
    begin
        exit((IPAddress = IPv4LoopbackIPAddressTxt) or (IPAddress = IPv6LoopbackIPAddressTxt));
    end;

    [EventSubscriber(ObjectType::Page, Page::"OAuth 2.0 Setup", 'OnBeforeActionEvent', 'RefreshAccessToken', false, false)]
    local procedure OnBeforeRefreshAccessTokenFromPage()
    var
        MTDSessionFraudPrevHdr: Record "MTD Session Fraud Prev. Hdr";
    begin
        MTDSessionFraudPrevHdr.DeleteAll();
    end;
}
