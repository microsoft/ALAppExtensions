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
            "Redirect URL" := RedirectURLTxt;
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

    [EventSubscriber(ObjectType::Table, Database::"OAuth 2.0 Setup", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeleteEvent(var Rec: Record "OAuth 2.0 Setup")
    begin
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

    [EventSubscriber(ObjectType::Table, Database::"OAuth 2.0 Setup", 'OnBeforeRequestAuthoizationCode', '', true, true)]
    local procedure OnBeforeRequestAuthoizationCode(OAuth20Setup: Record "OAuth 2.0 Setup"; var Processed: Boolean)
    begin
        if not IsMTDOAuthSetup(OAuth20Setup) or Processed then
            exit;
        Processed := true;

        CheckOAuthConsistencySetup(OAuth20Setup);
        UpdateClientTokens(OAuth20Setup);
        Hyperlink(OAuth20Mgt.GetAuthorizationURL(OAuth20Setup, GetToken(OAuth20Setup."Client ID", OAuth20Setup.GetTokenDataScope())));
    end;

    [EventSubscriber(ObjectType::Table, Database::"OAuth 2.0 Setup", 'OnBeforeRequestAccessToken', '', true, true)]
    local procedure OnBeforeRequestAccessToken(var OAuth20Setup: Record "OAuth 2.0 Setup"; AuthorizationCode: Text; var Result: Boolean; var MessageText: Text; var Processed: Boolean)
    var
        RequestJSON: Text;
        AccessToken: Text;
        RefreshToken: Text;
        TokenDataScope: DataScope;
    begin
        if not IsMTDOAuthSetup(OAuth20Setup) or Processed then
            exit;
        Processed := true;

        CheckOAuthConsistencySetup(OAuth20Setup);
        AddFraudPreventionHeaders(RequestJSON);

        TokenDataScope := OAuth20Setup.GetTokenDataScope();

        Result :=
            OAuth20Mgt.RequestAccessTokenWithGivenRequestJson(
                OAuth20Setup, RequestJSON, MessageText, AuthorizationCode,
                GetToken(OAuth20Setup."Client ID", TokenDataScope),
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

    [EventSubscriber(ObjectType::Table, Database::"OAuth 2.0 Setup", 'OnBeforeRefreshAccessToken', '', true, true)]
    local procedure OnBeforeRefreshAccessToken(var OAuth20Setup: Record "OAuth 2.0 Setup"; var Result: Boolean; var MessageText: Text; var Processed: Boolean)
    var
        RequestJSON: Text;
        AccessToken: Text;
        RefreshToken: Text;
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
                GetToken(OAuth20Setup."Client ID", TokenDataScope),
                GetToken(OAuth20Setup."Client Secret", TokenDataScope),
                AccessToken, RefreshToken);

        if Result then
            SaveTokens(OAuth20Setup, TokenDataScope, AccessToken, RefreshToken);
    end;

    local procedure SaveTokens(var OAuth20Setup: Record "OAuth 2.0 Setup"; TokenDataScope: DataScope; AccessToken: Text; RefreshToken: Text)
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

    local procedure UpdateClientTokens(var OAuth20Setup: Record "OAuth 2.0 Setup")
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        EnvironmentInfo: Codeunit "Environment Information";
        AzureClientIDTxt: Text;
        AzureClientSecretTxt: Text;
        KeyValue: Text;
        IsModify: Boolean;
        TokenDataScope: DataScope;
    begin
        if not EnvironmentInfo.IsSaaS() then
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
            if KeyValue <> '' then
                if KeyValue <> GetToken(OAuth20Setup."Client ID", TokenDataScope) then
                    IsModify := SetToken(OAuth20Setup."Client ID", KeyValue, TokenDataScope);
        if AzureKeyVault.GetAzureKeyVaultSecret(AzureClientSecretTxt, KeyValue) then
            if KeyValue <> '' then
                if KeyValue <> GetToken(OAuth20Setup."Client Secret", TokenDataScope) then
                    IsModify := SetToken(OAuth20Setup."Client Secret", KeyValue, TokenDataScope);
        if IsModify then
            OAuth20Setup.Modify();
    end;

    internal procedure SetToken(var TokenKey: Guid; TokenValue: Text; TokenDataScope: DataScope) NewToken: Boolean
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

    local procedure GetToken(TokenKey: Guid; TokenDataScope: DataScope) TokenValue: Text
    begin
        if not HasToken(TokenKey, TokenDataScope) then
            exit('');

        IsolatedStorage.Get(TokenKey, TokenDataScope, TokenValue);
    end;

    local procedure DeleteToken(TokenKey: Guid; TokenDataScope: DataScope)
    begin
        if not HasToken(TokenKey, TokenDataScope) then
            exit;

        IsolatedStorage.Delete(TokenKey, TokenDataScope);
    end;

    local procedure HasToken(TokenKey: Guid; TokenDataScope: DataScope): Boolean
    begin
        exit(not IsNullGuid(TokenKey) and IsolatedStorage.Contains(TokenKey, TokenDataScope));
    end;

    local procedure FindMTDOAuthPRODSetup(var OAuth20Setup: Record "OAuth 2.0 Setup"): Boolean
    begin
        exit(OAuth20Setup.get(GetOAuthPRODSetupCode()));
    end;

    local procedure FindMTDOAuthSandboxSetup(var OAuth20Setup: Record "OAuth 2.0 Setup"): Boolean
    begin
        exit(OAuth20Setup.get(GetOAuthSandboxSetupCode()));
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
                    IF StrPos("Service URL", ServiceURLMockServiceTxt) <> 1 THEN
                        TestField("Service URL", CopyStr(ServiceURLSandboxTxt, 1, MaxStrLen("Service URL")));
                else
                    TestField("Service URL", '');
            end;

            TestField("Redirect URL", RedirectURLTxt);
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
        FraudPreventionMgt: Codeunit "MTD Fraud Prevention Mgt.";
        JToken: JsonToken;
        JToken2: JsonToken;
        JObject: JsonObject;
        DummyJObject: JsonObject;
    begin
        if JObject.ReadFrom(RequestJSON) then;
        if not JObject.Contains('Header') then
            JObject.Add('Header', DummyJObject);
        if JObject.SelectToken('Header', JToken) then
            if JToken2.ReadFrom(FraudPreventionMgt.GenerateFraudPreventionHeaders()) then begin
                foreach JToken2 in JToken2.AsObject().Values() do
                    if not JToken.AsObject().Contains(JToken2.Path()) then
                        JToken.AsObject().Add(JToken2.Path(), JToken2.AsValue().AsText());
                JObject.WriteTo(RequestJSON);
            end;
    end;
}
