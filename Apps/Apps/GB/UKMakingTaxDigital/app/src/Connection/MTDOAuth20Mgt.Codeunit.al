// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

codeunit 10538 "MTD OAuth 2.0 Mgt"
{
    trigger OnRun()
    begin

    end;

    var
        OAuth20Mgt: Codeunit "OAuth 2.0 Mgt.";
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
        AddFraudPreventionHeaders(RequestJSON);

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
        AddFraudPreventionHeaders(RequestJSON);

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
        AddFraudPreventionHeaders(RequestJSON);

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

    local procedure AddFraudPreventionHeaders(var RequestJSON: Text)
    var
        MTDFraudPreventionMgt: Codeunit "MTD Fraud Prevention Mgt.";
    begin
        MTDFraudPreventionMgt.AddFraudPreventionHeaders(RequestJSON);
        MTDFraudPreventionMgt.LogFraudPreventionHeadersValidity(RequestJSON);
    end;

    [EventSubscriber(ObjectType::Page, Page::"OAuth 2.0 Setup", 'OnBeforeActionEvent', 'RefreshAccessToken', false, false)]
    local procedure OnBeforeRefreshAccessTokenFromPage()
    var
        MTDSessionFraudPrevHdr: Record "MTD Session Fraud Prev. Hdr";
    begin
        MTDSessionFraudPrevHdr.DeleteAll();
    end;
}
