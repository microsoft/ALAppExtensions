codeunit 1686 "Email Logging OAuth Client" implements "Email Logging OAuth Client"
{
    Access = Internal;
    Permissions = tabledata "Email Logging Setup" = r;

    var
        OAuth2: Codeunit OAuth2;
        [NonDebuggable]
        ClientId: Text;
        [NonDebuggable]
        ClientSecret: Text;
        RedirectUrl: Text;
        [NonDebuggable]
        ClientIdSaved: Text;
        [NonDebuggable]
        ClientSecretSaved: Text;
        SavedRedirectUrl: Text;
        AreSavedParamsLoaded: Boolean;
        UseFirstPartyApp: Boolean;
        IsInitialized: Boolean;
        Scopes: List of [Text];
        GraphScopesLbl: Label 'https://graph.microsoft.com/.default', Locked = true;
        CommonOAuthAuthorityUrlLbl: Label 'https://login.microsoftonline.com/common/oauth2', Locked = true;
        CouldNotGetAccessTokenErr: Label 'Could not get an access token.';
        CategoryTok: Label 'Email Logging', Locked = true;
        CouldNotAcquireAccessTokenErr: Label 'Failed to acquire access token.', Locked = true;
        MissingClientIdTxt: Label 'The client ID is not specified.', Locked = true;
        MissingClientIdErr: Label 'The client ID is not specified.';
        MissingClientSecretTxt: Label 'The client secret is not specified.', Locked = true;
        MissingClientSecretErr: Label 'The client secret is not specified.';
        InitializedClientIdTxt: Label 'The client ID is specified.', Locked = true;
        InitializedClientSecretTxt: Label 'The client secret is specified.', Locked = true;
        InitializedRedirectUrlTxt: Label 'The redirect URL is initialized.', Locked = true;
        ClientIdAKVSecretNameLbl: Label 'emaillogging-clientid', Locked = true;
        ClientSecretAKVSecretNameLbl: Label 'emaillogging-clientsecret', Locked = true;
        UseThirdPartyAppAKVSecretNameLbl: Label 'emaillogging-usethirdpartyapp', Locked = true;
        UseThirdPartyAppAKVSecretValueLbl: Label '1', Locked = true;
        AuthTokenNotReceivedTxt: Label 'No access token received.', Locked = true;
        AccessTokenReceivedTxt: Label 'Access token has been received.', Locked = true;
        AcquireAccessTokenTxt: Label 'Asquire access token.', Locked = true;
        ThirdPartyAppOnlyErr: Label 'Authentication using the client ID and secret for email logging is not enabled.';

    [NonDebuggable]
    internal procedure GetAccessToken(PromptInteraction: Enum "Prompt Interaction"; var AccessToken: Text)
    begin
        TryGetAccessTokenInternal(PromptInteraction, AccessToken);
    end;

    [NonDebuggable]
    internal procedure TryGetAccessToken(PromptInteraction: Enum "Prompt Interaction"; var AccessToken: Text): Boolean
    begin
        exit(TryGetAccessTokenInternal(PromptInteraction, AccessToken));
    end;

    [NonDebuggable]
    internal procedure GetAccessToken(var AccessToken: Text)
    begin
        TryGetAccessTokenInternal(AccessToken);
    end;

    [NonDebuggable]
    internal procedure TryGetAccessToken(var AccessToken: Text): Boolean
    begin
        exit(TryGetAccessTokenInternal(AccessToken));
    end;

    // Interfaces do not support properties for the procedures, so using an internal function
    [TryFunction]
    [NonDebuggable]
    local procedure TryGetAccessTokenInternal(var AccessToken: Text)
    var
        AzureAdMgt: Codeunit "Azure AD Mgt.";
        UrlHelper: Codeunit "Url Helper";
    begin
        Initialize();

        Session.LogMessage('0000G06', AcquireAccessTokenTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        if UseFirstPartyApp then begin
            AccessToken := AzureAdMgt.GetAccessToken(UrlHelper.GetGraphUrl(), '', false);
            if AccessToken = '' then begin
                Session.LogMessage('0000G07', CouldNotAcquireAccessTokenErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                if OAuth2.AcquireOnBehalfOfToken('', Scopes, AccessToken) then;
            end;
        end else
            TryGetAccessTokenInternal(Enum::"Prompt Interaction"::None, AccessToken);
        if AccessToken = '' then
            Error(CouldNotGetAccessTokenErr);
    end;

    // Interfaces do not support properties for the procedures, so using an internal function
    [TryFunction]
    [NonDebuggable]
    local procedure TryGetAccessTokenInternal(PromptInteraction: Enum "Prompt Interaction"; var AccessToken: Text)
    var
        OAuthError: Text;
    begin
        Initialize();

        Session.LogMessage('0000G08', AcquireAccessTokenTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        if UseFirstPartyApp then
            Error(ThirdPartyAppOnlyErr);

        if PromptInteraction = PromptInteraction::None then begin
            if not OAuth2.AcquireAuthorizationCodeTokenFromCache(ClientId, ClientSecret, RedirectUrl, CommonOAuthAuthorityUrlLbl, Scopes, AccessToken) then
                AccessToken := '';
            if AccessToken <> '' then
                Session.LogMessage('0000G09', AccessTokenReceivedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok)
            else
                Session.LogMessage('0000G0A', AuthTokenNotReceivedTxt, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        end else begin
            if not OAuth2.AcquireTokenByAuthorizationCode(ClientId, ClientSecret, CommonOAuthAuthorityUrlLbl, RedirectUrl, Scopes, PromptInteraction, AccessToken, OAuthError) then
                AccessToken := '';
            if AccessToken <> '' then
                Session.LogMessage('0000G0B', AccessTokenReceivedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok)
            else begin
                Session.LogMessage('0000G0C', AuthTokenNotReceivedTxt, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                if OAuthError <> '' then
                    Session.LogMessage('0000G0D', OAuthError, Verbosity::Error, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            end;
        end;
        if AccessToken = '' then
            Error(CouldNotGetAccessTokenErr);
    end;

    [NonDebuggable]
    internal procedure GetLastErrorMessage(): Text
    begin
        exit(OAuth2.GetLastErrorMessage());
    end;

    [NonDebuggable]
    internal procedure Initialize()
    begin
        if IsInitialized then
            exit;

        UseFirstPartyApp := GetUseFirstPartyApp();
        if UseFirstPartyApp then
            exit;

        ClientId := GetClientId();
        ClientSecret := GetClientSecret();
        RedirectUrl := GetRedirectUrl();
        Initialize(ClientId, ClientSecret, RedirectUrl);
    end;

    [NonDebuggable]
    internal procedure Initialize(NewClientId: Text; NewClientSecret: Text; NewRedirectUrl: Text)
    begin
        Scopes.Add(GraphScopesLbl);

        UseFirstPartyApp := GetUseFirstPartyApp();
        if UseFirstPartyApp then begin
            OAuth2.GetDefaultRedirectUrl(RedirectUrl);
            IsInitialized := true;
            exit;
        end;

        if (NewClientId <> '') and (NewClientSecret <> '') then begin
            ClientId := NewClientId;
            ClientSecret := NewClientSecret;
        end;
        if NewRedirectUrl <> '' then
            RedirectUrl := NewRedirectUrl
        else
            OAuth2.GetDefaultRedirectUrl(RedirectUrl);
        IsInitialized := true;
    end;

    internal procedure AuthorizationCodeTokenCacheExists(): Boolean
    var
        [NonDebuggable]
        AccessToken: Text;
    begin
        Initialize();
        exit(OAuth2.AcquireAuthorizationCodeTokenFromCache(ClientId, ClientSecret, RedirectUrl, CommonOAuthAuthorityUrlLbl, Scopes, AccessToken) and (AccessToken <> ''))
    end;

    internal procedure GetApplicationType() ApplicationType: Enum "Email Logging App Type"
    var
        EnvironmentInformation: Codeunit "Environment Information";
        UrlHelper: Codeunit "Url Helper";
        AzureKeyVault: Codeunit "Azure Key Vault";
        UseThirdPartyApp: Text;
    begin
        if not EnvironmentInformation.IsSaaSInfrastructure() then
            exit(ApplicationType::"Third Party");

        if not UrlHelper.IsPROD() then
            exit(ApplicationType::"Third Party");

        if AzureKeyVault.GetAzureKeyVaultSecret(UseThirdPartyAppAKVSecretNameLbl, UseThirdPartyApp) then
            if UseThirdPartyApp = UseThirdPartyAppAKVSecretValueLbl then
                exit(ApplicationType::"Third Party");

        exit(ApplicationType::"First Party");
    end;

    local procedure GetUseFirstPartyApp(): Boolean
    var
        ApplicationType: Enum "Email Logging App Type";
    begin
        exit(GetApplicationType() = ApplicationType::"First Party");
    end;

    local procedure GetClientId(): Text
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        EnvironmentInformation: Codeunit "Environment Information";
        ClientIdLocal: Text;
    begin
        OnGetClientId(ClientIdLocal);
        if ClientIdLocal <> '' then begin
            Session.LogMessage('0000G0E', InitializedClientIdTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(ClientIdLocal);
        end;

        if EnvironmentInformation.IsSaaSInfrastructure() then
            if not AzureKeyVault.GetAzureKeyVaultSecret(ClientIdAKVSecretNameLbl, ClientIdLocal) then
                Session.LogMessage('0000G0F', MissingClientIdTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok)
            else begin
                Session.LogMessage('0000G0G', InitializedClientIdTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                exit(ClientIdLocal);
            end;

        if LoadSavedParams() then begin
            ClientIdLocal := ClientIdSaved;
            if ClientIdLocal <> '' then begin
                Session.LogMessage('0000G0H', InitializedClientIdTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                exit(ClientIdLocal);
            end;
        end;

        Session.LogMessage('0000G0I', MissingClientIdTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        Error(MissingClientIdErr);
    end;

    [NonDebuggable]
    local procedure GetClientSecret(): Text
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        EnvironmentInformation: Codeunit "Environment Information";
        ClientSecretLocal: Text;
    begin
        OnGetClientSecret(ClientSecretLocal);
        if ClientSecretLocal <> '' then begin
            Session.LogMessage('0000G0J', InitializedClientSecretTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(ClientSecretLocal);
        end;

        if EnvironmentInformation.IsSaaSInfrastructure() then
            if not AzureKeyVault.GetAzureKeyVaultSecret(ClientSecretAKVSecretNameLbl, ClientSecretLocal) then
                Session.LogMessage('0000G0K', MissingClientSecretTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok)
            else begin
                Session.LogMessage('0000G0L', InitializedClientSecretTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                exit(ClientSecretLocal);
            end;

        if LoadSavedParams() then begin
            ClientSecretLocal := ClientSecretSaved;
            if ClientSecretLocal <> '' then begin
                Session.LogMessage('0000G0M', InitializedClientSecretTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                exit(ClientSecretLocal);
            end;
        end;

        Session.LogMessage('0000G0N', MissingClientSecretTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        Error(MissingClientSecretErr);
    end;

    local procedure GetRedirectUrl(): Text
    var
        EnvironmentInformation: Codeunit "Environment Information";
        RedirectUrlLocal: Text;
    begin
        OnGetRedirectUrl(RedirectUrlLocal);
        if RedirectUrlLocal <> '' then begin
            Session.LogMessage('0000G0O', InitializedRedirectUrlTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(RedirectUrlLocal);
        end;

        if EnvironmentInformation.IsSaaSInfrastructure() then
            exit('');

        if LoadSavedParams() then
            exit(SavedRedirectUrl);

        exit('');
    end;

    [NonDebuggable]
    local procedure LoadSavedParams(): Boolean
    var
        EmailLoggingSetup: Record "Email Logging Setup";
    begin
        if AreSavedParamsLoaded then
            exit(true);

        if not EmailLoggingSetup.Get() then
            exit(false);

        ClientIdSaved := EmailLoggingSetup."Client Id";
        ClientSecretSaved := EmailLoggingSetup.GetClientSecret();
        SavedRedirectUrl := EmailLoggingSetup.GetRedirectUrl();
        AreSavedParamsLoaded := true;
        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetClientId(var ClientId: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetClientSecret(var ClientSecret: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetRedirectUrl(var RedirectUrl: Text)
    begin
    end;
}