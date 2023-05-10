// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Contains settings for Azure OpenAI.
/// </summary>
table 2010 "Azure OpenAi Settings"
{
    Caption = 'Azure OpenAI Settings';
    DataPerCompany = false;
    ReplicateData = false;
    Extensible = false;
    Access = Internal;

    fields
    {
        field(1; Id; Code[10])
        {
            Caption = 'Id';
            DataClassification = SystemMetadata;
        }

        field(2; Endpoint; Text[250])
        {
            Caption = 'Endpoint';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Uri: Codeunit Uri;
            begin
                ClearSecret();

                Rec.Endpoint := CopyStr(Rec.Endpoint.Trim(), 1, MaxStrLen(Rec.Endpoint));

                if Rec.Endpoint = '' then begin
                    Rec.Endpoint := '';
                    Session.LogMessage('0000JY4', TelemetryEndpointClearedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
                    exit;
                end;

                if not Uri.IsValidUri(Rec.Endpoint) then
                    Error(UriNotValidErr);

                Uri.Init(Rec.Endpoint);
                if Uri.GetScheme().ToLower() <> 'https' then
                    Error(UriNotHttpsErr);

                // tidy up the endpoint
                Rec.Endpoint := CopyStr('https://' + Uri.GetAuthority().ToLower() + '/', 1, MaxStrLen(Rec.Endpoint));

                if not Rec.Endpoint.EndsWith(AoaiSuffixTxt) then
                    Error(UriNotSupportedErr);

                Session.LogMessage('0000JY5', TelemetryEndpointSetTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
            end;
        }

        field(3; Model; Text[250])
        {
            Caption = 'Model';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Rec.Model := CopyStr(DelChr(Rec.Model.Trim(), '<>', '.'), 1, MaxStrLen(Rec.Model));
            end;
        }
    }

    keys
    {
        key(Key1; Id)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        ClearSecret();
    end;

    procedure SetDefaults()
    begin
        Rec.Init();
        Clear(Endpoint);
        Clear(Rec.Model);
        ClearSecret();
        if not Rec.Modify() then
            Rec.Insert();
    end;

    [NonDebuggable]
    procedure SetSecret(Secret: Text)
    begin
        if EncryptionEnabled() then
            IsolatedStorage.SetEncrypted(SecretKeyTok, Secret, DataScope::Module)
        else
            IsolatedStorage.Set(SecretKeyTok, Secret, DataScope::Module);
        Session.LogMessage('0000JY6', TelemetrySecretSetTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
    end;

    procedure ClearSecret()
    begin
        if IsolatedStorage.Delete(SecretKeyTok, DataScope::Module) then;
        Session.LogMessage('0000JY7', TelemetrySecretClearedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
    end;

    procedure HasSecret(): Boolean
    begin
        exit(IsolatedStorage.Contains(SecretKeyTok, DataScope::Module));
    end;

    [NonDebuggable]
    [TryFunction]
    internal procedure IsConfigured(CallerModuleInfo: ModuleInfo)
    var
        BearerAuth: Boolean;
    begin
        if CompletionsEndpoint(CallerModuleInfo, BearerAuth) = '' then
            Error('');

        if not HasSecret(CallerModuleInfo) then
            Error('');
    end;

    [NonDebuggable]
    internal procedure CompletionsEndpoint(CallerModuleInfo: ModuleInfo; var BearerAuth: Boolean): Text
    var
        EnvironmentInformation: Codeunit "Environment Information";
        UriBuilder: Codeunit "Uri Builder";
        Uri: Codeunit Uri;
        EntityTextModuleInfo: ModuleInfo;
        KvEndpoint: Text;
        AzureEndpoint: Text;
    begin
        BearerAuth := true;

        if EnvironmentInformation.IsSaaSInfrastructure() then begin
            NavApp.GetCurrentModuleInfo(EntityTextModuleInfo);
            if (not IsNullGuid(CallerModuleInfo.Id())) and (CallerModuleInfo.Publisher() = EntityTextModuleInfo.Publisher()) then begin
                KvEndpoint := GetConfigurationValue(EndpointKeyTok);
                if KvEndpoint <> '' then begin
                    Session.LogMessage('0000JVU', TelemetryKvEndpointTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
                    exit(StrSubstNo(KvEndpoint, ApiVersionKeyTok, ApiVersionTok));
                end;
            end;
        end;

        if Rec.Endpoint = '' then
            Error(EndpointEmptyErr);

        if Rec.Model = '' then
            Error(ModelEmptyErr);

        BearerAuth := false;

        UriBuilder.Init(Rec.Endpoint);
        UriBuilder.SetPath(StrSubstNo(PrivateCompletionsEndpointTxt, Uri.EscapeDataString(Rec.Model)));
        UriBuilder.AddQueryParameter(ApiVersionKeyTok, ApiVersionTok);

        UriBuilder.GetUri(Uri);

        AzureEndpoint := Uri.GetAbsoluteUri();
        Session.LogMessage('0000JVW', StrSubstNo(TelemetryAzureEndpointTxt, StrLen(AzureEndpoint)), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
        exit(AzureEndpoint);
    end;

    [NonDebuggable]
    local procedure HasSecret(CallerModuleInfo: ModuleInfo): Boolean
    var
        EnvironmentInformation: Codeunit "Environment Information";
        AzureKeyVault: Codeunit "Azure Key Vault";
        EntityTextModuleInfo: ModuleInfo;
        Secret: Text;
    begin
        if not EnvironmentInformation.IsSaaSInfrastructure() then begin
            if IsolatedStorage.Get(SecretKeyTok, DataScope::Module, Secret) then;
            exit(Secret <> '');
        end;

        NavApp.GetCurrentModuleInfo(EntityTextModuleInfo);
        if (not IsNullGuid(CallerModuleInfo.Id())) and (CallerModuleInfo.Publisher() = EntityTextModuleInfo.Publisher()) then
            if AzureKeyVault.GetAzureKeyVaultCertificate(SecretKeyTok, Secret) then
                exit(Secret <> '');

        if IsolatedStorage.Get(SecretKeyTok, DataScope::Module, Secret) then;
        exit(Secret <> '');
    end;

    [NonDebuggable]
    internal procedure GetSecret(CallerModuleInfo: ModuleInfo): Text
    var
        EnvironmentInformation: Codeunit "Environment Information";
        AzureKeyVault: Codeunit "Azure Key Vault";
        EntityTextModuleInfo: ModuleInfo;
        Secret: Text;
    begin
        if not EnvironmentInformation.IsSaaSInfrastructure() then begin
            IsolatedStorage.Get(SecretKeyTok, DataScope::Module, Secret);
            Session.LogMessage('0000JVX', TelemetrySecretIsolatedStorageTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
            exit(Secret);
        end;

        NavApp.GetCurrentModuleInfo(EntityTextModuleInfo);
        if (not IsNullGuid(CallerModuleInfo.Id())) and (CallerModuleInfo.Publisher() = EntityTextModuleInfo.Publisher()) then
            if AzureKeyVault.GetAzureKeyVaultCertificate(SecretKeyTok, Secret) then
                if Secret <> '' then begin
                    Session.LogMessage('0000JVY', TelemetrySecretKeyVaultTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
                    exit(GetOauthSecret(Secret));
                end;

        IsolatedStorage.Get(SecretKeyTok, DataScope::Module, Secret);
        Session.LogMessage('0000JVZ', TelemetrySecretIsolatedStorageTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
        exit(Secret);
    end;

    [NonDebuggable]
    local procedure GetOauthSecret(Secret: Text): Text
    var
        OAuth2: Codeunit OAuth2;
        Scopes: List of [Text];
        ClientId: Text;
        Authority: Text;
        Resource: Text;
        Token: Text;
        IdToken: Text;
    begin
        ClientId := GetConfigurationValue(ClientKeyTok);
        Authority := GetConfigurationValue(AuthorityKeyTok);
        Resource := GetConfigurationValue(ResourceKeyTok);

        if Authority = '' then
            Error('');

        if Resource = '' then
            Error('');

        Scopes.Add(Resource + '/.default');

        OAuth2.AcquireTokensWithCertificate(ClientId, Secret, '', Authority, Scopes, Token, IdToken);
        exit(Token);
    end;


    [NonDebuggable]
    internal procedure IncludeSource(CallerModuleInfo: ModuleInfo): Boolean
    var
        EnvironmentInformation: Codeunit "Environment Information";
        EntityTextModuleInfo: ModuleInfo;
    begin
        if not EnvironmentInformation.IsSaaSInfrastructure() then
            exit(false);

        NavApp.GetCurrentModuleInfo(EntityTextModuleInfo);
        if IsNullGuid(CallerModuleInfo.Id()) or (CallerModuleInfo.Publisher() <> EntityTextModuleInfo.Publisher()) then
            exit(false);

        exit(GetConfigurationValue(IncludeSourceKeyTok) = 'true');
    end;

    [NonDebuggable]
    local procedure GetConfigurationValue(Name: Text): Text;
    var
        EnvironmentInformation: Codeunit "Environment Information";
        AzureKeyVault: Codeunit "Azure Key Vault";
        Configuration: JsonObject;
        ConfigurationText: Text;
        ConfigurationToken: JsonToken;
    begin
        if not EnvironmentInformation.IsSaaSInfrastructure() then
            exit('');

        AzureKeyVault.GetAzureKeyVaultSecret(ConfigurationKeyTok, ConfigurationText);

        if ConfigurationText = '' then
            exit('');

        if not Configuration.ReadFrom(ConfigurationText) then
            exit('');

        if not Configuration.Get(Name, ConfigurationToken) then
            exit('');

        exit(ConfigurationToken.AsValue().AsText());
    end;

    var
        PrivateCompletionsEndpointTxt: Label '/openai/deployments/%1/completions', Locked = true;
        AoaiSuffixTxt: Label '.openai.azure.com/', Locked = true;
        SecretKeyTok: Label 'AOAI-Cert', Locked = true;
        ConfigurationKeyTok: Label 'AOAI-Configuration', Locked = true;
        EndpointKeyTok: Label 'Endpoint', Locked = true;
        ClientKeyTok: Label 'Client', Locked = true;
        AuthorityKeyTok: Label 'Authority', Locked = true;
        ResourceKeyTok: Label 'Resource', Locked = true;
        IncludeSourceKeyTok: Label 'IncludeSource', Locked = true;
        ApiVersionKeyTok: Label 'api-version', Locked = true;
        ApiVersionTok: Label '2022-12-01', Locked = true;
        UriNotValidErr: Label 'The specified endpoint is not valid.';
        UriNotHttpsErr: Label 'The specified endpoint should be using https.';
        UriNotSupportedErr: Label 'The specified endpoint is not a supported endpoint. It should be an Azure OpenAI endpoint.';
        EndpointEmptyErr: Label 'No endpoint has been configured. Open the OpenAI settings page and ensure the endpoint has been specified';
        ModelEmptyErr: Label 'No model has been configured. Open the OpenAI settings page and ensure the correct model has been specified.';
        TelemetryCategoryLbl: Label 'AOAI', Locked = true;
        TelemetryKvEndpointTxt: Label 'Using a KeyVault endpoint.', Locked = true;
        TelemetryAzureEndpointTxt: Label 'Using a custom Azure endpoint of length %1.', Locked = true;
        TelemetrySecretIsolatedStorageTxt: Label 'Using a secret defined in isolated storage.', Locked = true;
        TelemetrySecretKeyVaultTxt: Label 'Using a secret defined in the KeyVault.', Locked = true;
        TelemetrySecretClearedTxt: Label 'The secret was cleared.', Locked = true;
        TelemetrySecretSetTxt: Label 'The secret was set.', Locked = true;
        TelemetryEndpointClearedTxt: Label 'The endpoint was cleared.', Locked = true;
        TelemetryEndpointSetTxt: Label 'The endpoint was set.', Locked = true;
}
