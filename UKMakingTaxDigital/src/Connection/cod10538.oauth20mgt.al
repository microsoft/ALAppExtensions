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
        ServiceConnectionPRODSetupLbl: Label 'HMRC VAT Setup';
        ServiceConnectionSandboxSetupLbl: Label 'HMRC VAT Sandbox Setup';
        OAuthPRODSetupDescriptionLbl: Label 'HMRC Making Tax Digital VAT Returns';
        OAuthSandboxSetupDescriptionLbl: Label 'HMRC Making Tax Digital VAT Returns Sandbox';
        CheckCompanyVATNoAfterSuccessAuthorizationQst: Label 'Authorization successful.\Do you want to open the Company Information setup to verify the VAT registration number?';
        PRODAzureClientIDTxt: Label 'UKHMRC-MTDVAT-PROD-ClientID', Locked = true;
        PRODAzureClientSecretTxt: Label 'UKHMRC-MTDVAT-PROD-ClientSecret', Locked = true;
        SandboxAzureClientIDTxt: Label 'UKHMRC-MTDVAT-Sandbox-ClientID', Locked = true;
        SandboxAzureClientSecretTxt: Label 'UKHMRC-MTDVAT-Sandbox-ClientSecret', Locked = true;

    procedure GetOAuthPRODSetupCode() Result: Code[20]
    begin
        Result := CopyStr(OAuthPRODSetupLbl, 1, MaxStrLen(Result))
    end;

    procedure GetOAuthSandboxSetupCode() Result: Code[20]
    begin
        Result := CopyStr(OAuthSandboxSetupLbl, 1, MaxStrLen(Result))
    end;

    procedure InitOAuthSetup(var OAuth20Setup: Record "OAuth 2.0 Setup"; OAuthSetupCode: Code[20])
    begin
        WITH OAuth20Setup DO BEGIN
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
            "Redirect URL" := 'urn:ietf:wg:oauth:2.0:oob';
            Scope := 'write:vat read:vat';
            "Authorization URL Path" := '/oauth/authorize';
            "Access Token URL Path" := '/oauth/token';
            "Refresh Token URL Path" := '/oauth/token';
            "Authorization Response Type" := 'code';
            "Token DataScope" := "Token DataScope"::Company;
            Modify();
        END;
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

        IF not OAuth20Setup.Get(OAuthSetupCode) then
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

        UpdateClientTokens(OAuth20Setup);
        Hyperlink(OAuth20Mgt.GetAuthorizationURL(OAuth20Setup, GetToken(OAuth20Setup."Client ID", OAuth20Setup.GetTokenDataScope())));
    end;

    [EventSubscriber(ObjectType::Table, Database::"OAuth 2.0 Setup", 'OnBeforeRequestAccessToken', '', true, true)]
    local procedure OnBeforeRequestAccessToken(var OAuth20Setup: Record "OAuth 2.0 Setup"; AuthorizationCode: Text; var Result: Boolean; var MessageText: Text; var Processed: Boolean)
    var
        AccessToken: Text;
        RefreshToken: Text;
        TokenDataScope: DataScope;
    begin
        if not IsMTDOAuthSetup(OAuth20Setup) or Processed then
            exit;
        Processed := true;
        TokenDataScope := OAuth20Setup.GetTokenDataScope();

        UpdateClientTokens(OAuth20Setup);
        Result :=
            OAuth20Mgt.RequestAccessToken(
                OAuth20Setup, MessageText, AuthorizationCode,
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
        AccessToken: Text;
        RefreshToken: Text;
        TokenDataScope: DataScope;
    begin
        if not IsMTDOAuthSetup(OAuth20Setup) or Processed then
            exit;
        Processed := true;
        TokenDataScope := OAuth20Setup.GetTokenDataScope();
        RefreshToken := GetToken(OAuth20Setup."Refresh Token", TokenDataScope);

        Result :=
            OAuth20Mgt.RefreshAccessToken(
                OAuth20Setup, MessageText, GetToken(OAuth20Setup."Client ID", TokenDataScope), GetToken(OAuth20Setup."Client Secret", TokenDataScope), AccessToken, RefreshToken);

        if Result then
            SaveTokens(OAuth20Setup, TokenDataScope, AccessToken, RefreshToken);
    end;

    local procedure SaveTokens(var OAuth20Setup: Record "OAuth 2.0 Setup"; TokenDataScope: DataScope; AccessToken: Text; RefreshToken: Text)
    begin
        SetToken(OAuth20Setup."Access Token", AccessToken, TokenDataScope);
        SetToken(OAuth20Setup."Refresh Token", RefreshToken, TokenDataScope);
        OAuth20Setup.Modify();
        Commit(); // need to prevent rollback to save new keys
    end;

    [EventSubscriber(ObjectType::Table, Database::"OAuth 2.0 Setup", 'OnBeforeInvokeRequest', '', true, true)]
    local procedure OnBeforeInvokeRequest(var OAuth20Setup: Record "OAuth 2.0 Setup"; RequestJSON: Text; var ResponseJSON: Text; var HttpError: Text; var Result: Boolean; var Processed: Boolean; RetryOnCredentialsFailure: Boolean)
    begin
        if not IsMTDOAuthSetup(OAuth20Setup) or Processed then
            exit;
        Processed := true;

        Result :=
            OAuth20Mgt.InvokeRequest(
                OAuth20Setup, RequestJSON, ResponseJSON, HttpError,
                GetToken(OAuth20Setup."Access Token", OAuth20Setup.GetTokenDataScope()), RetryOnCredentialsFailure);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Encryption Management", 'OnBeforeDecryptDataInAllCompaniesOnPrem', '', true, true)]
    local procedure OnBeforeDecryptDataInAllCompaniesOnPrem()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
    begin
        if FindMTDOAuthPRODSetup(OAuth20Setup) then
            DecryptDataInAllCompaniesOnPrem(OAuth20Setup);

        if FindMTDOAuthSandboxSetup(OAuth20Setup) then
            DecryptDataInAllCompaniesOnPrem(OAuth20Setup);
    end;

    local procedure DecryptDataInAllCompaniesOnPrem(OAuth20Setup: Record "OAuth 2.0 Setup")
    var
        TokenDataScope: DataScope;
    begin
        TokenDataScope := OAuth20Setup.GetTokenDataScope();
        IsolatedStorage_Set(OAuth20Setup."Client ID", GetToken(OAuth20Setup."Client ID", TokenDataScope), TokenDataScope);
        IsolatedStorage_Set(OAuth20Setup."Client Secret", GetToken(OAuth20Setup."Client Secret", TokenDataScope), TokenDataScope);
        IsolatedStorage_Set(OAuth20Setup."Access Token", GetToken(OAuth20Setup."Access Token", TokenDataScope), TokenDataScope);
        IsolatedStorage_Set(OAuth20Setup."Refresh Token", GetToken(OAuth20Setup."Refresh Token", TokenDataScope), TokenDataScope);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Encryption Management", 'OnBeforeEncryptDataInAllCompaniesOnPrem', '', true, true)]
    local procedure OnBeforeEncryptDataInAllCompaniesOnPrem()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
    begin
        if FindMTDOAuthPRODSetup(OAuth20Setup) then
            EncryptDataInAllCompaniesOnPrem(OAuth20Setup);

        if FindMTDOAuthSandboxSetup(OAuth20Setup) then
            EncryptDataInAllCompaniesOnPrem(OAuth20Setup);
    end;

    local procedure EncryptDataInAllCompaniesOnPrem(OAuth20Setup: Record "OAuth 2.0 Setup")
    var
        TokenDataScope: DataScope;
    begin
        TokenDataScope := OAuth20Setup.GetTokenDataScope();
        SetToken(OAuth20Setup."Client ID", IsolatedStorage_Get(OAuth20Setup."Client ID", TokenDataScope), TokenDataScope);
        SetToken(OAuth20Setup."Client Secret", IsolatedStorage_Get(OAuth20Setup."Client Secret", TokenDataScope), TokenDataScope);
        SetToken(OAuth20Setup."Access Token", IsolatedStorage_Get(OAuth20Setup."Access Token", TokenDataScope), TokenDataScope);
        SetToken(OAuth20Setup."Refresh Token", IsolatedStorage_Get(OAuth20Setup."Refresh Token", TokenDataScope), TokenDataScope);
    end;

    local procedure UpdateClientTokens(var OAuth20Setup: Record "OAuth 2.0 Setup")
    var
        AzureKeyVaultMgt: Codeunit "Azure Key Vault Management";
        AzureClientIDTxt: Text;
        AzureClientSecretTxt: Text;
        KeyValue: Text;
    begin
        if OAuth20Setup.Code = GetOAuthPRODSetupCode() then begin
            AzureClientIDTxt := PRODAzureClientIDTxt;
            AzureClientSecretTxt := PRODAzureClientSecretTxt;
        end else begin
            AzureClientIDTxt := SandboxAzureClientIDTxt;
            AzureClientSecretTxt := SandboxAzureClientSecretTxt;
        end;

        if AzureKeyVaultMgt.GetAzureKeyVaultSecret(KeyValue, AzureClientIDTxt) then
            if KeyValue <> '' then
                SetToken(OAuth20Setup."Client ID", KeyValue, OAuth20Setup.GetTokenDataScope());
        if AzureKeyVaultMgt.GetAzureKeyVaultSecret(KeyValue, AzureClientSecretTxt) then
            if KeyValue <> '' then
                SetToken(OAuth20Setup."Client Secret", KeyValue, OAuth20Setup.GetTokenDataScope());
        OAuth20Setup.Modify();
    end;

    local procedure IsolatedStorage_Set(var TokenKey: GUID; TokenValue: Text; TokenDataScope: DataScope)
    begin
        IF IsNullGuid(TokenKey) THEN
            TokenKey := CreateGuid();

        IsolatedStorage.Set(TokenKey, TokenValue, TokenDataScope);
    end;

    procedure SetToken(var TokenKey: GUID; TokenValue: Text; TokenDataScope: DataScope)
    begin
        IsolatedStorage_Set(TokenKey, OAuth20Mgt.EncryptForOnPrem(TokenValue), TokenDataScope);
    end;

    local procedure IsolatedStorage_Get(TokenKey: GUID; TokenDataScope: DataScope) TokenValue: Text
    begin
        TokenValue := '';
        IF NOT HasToken(TokenKey, TokenDataScope) THEN
            exit;

        IsolatedStorage.Get(TokenKey, TokenDataScope, TokenValue);
    end;

    local procedure GetToken(TokenKey: GUID; TokenDataScope: DataScope) TokenValue: Text
    begin
        exit(OAuth20Mgt.DecryptForOnPrem(IsolatedStorage_Get(TokenKey, TokenDataScope)));
    end;

    local procedure DeleteToken(TokenKey: GUID; TokenDataScope: DataScope)
    begin
        IF NOT HasToken(TokenKey, TokenDataScope) THEN
            exit;

        IsolatedStorage.DELETE(TokenKey, TokenDataScope);
    end;

    local procedure HasToken(TokenKey: GUID; TokenDataScope: DataScope): Boolean
    begin
        exit(NOT IsNullGuid(TokenKey) AND IsolatedStorage.Contains(TokenKey, TokenDataScope));
    end;

    local procedure FindMTDOAuthPRODSetup(var OAuth20Setup: Record "OAuth 2.0 Setup"): Boolean
    begin
        exit(OAuth20Setup.get(GetOAuthPRODSetupCode()));
    end;

    local procedure FindMTDOAuthSandboxSetup(var OAuth20Setup: Record "OAuth 2.0 Setup"): Boolean
    begin
        exit(OAuth20Setup.get(GetOAuthSandboxSetupCode()));
    end;

    procedure IsMTDOAuthSetup(OAuth20Setup: Record "OAuth 2.0 Setup"): Boolean
    var
        VATReportSetup: Record "VAT Report Setup";
        OAuthSetupCode: Code[20];
    begin
        if VATReportSetup.Get() then
            OAuthSetupCode := VATReportSetup.GetMTDOAuthSetupCode();
        exit((OAuthSetupCode <> '') and (OAuthSetupCode = OAuth20Setup.Code));
    end;
}
