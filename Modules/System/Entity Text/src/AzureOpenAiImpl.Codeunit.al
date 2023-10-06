// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Implements functionality to call Azure OpenAI.
/// </summary>
codeunit 2011 "Azure OpenAi Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure IsEnabled(Silent: Boolean): Boolean
    var
        FeatureKey: Record "Feature Key";
        EntityText: Record "Entity Text";
        PrivacyNotice: Codeunit "Privacy Notice";
        PrivacyResult: Boolean;
    begin
        if FeatureKey.Get('EntityText') and (FeatureKey.Enabled <> FeatureKey.Enabled::"All Users") then begin
            Session.LogMessage('0000JVN', TelemetryFeatureKeyDisabledTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
            exit(false);
        end;

        if not IsSupportedLanguage() then begin
            Session.LogMessage('0000JXG', TelemetryUnsupportedLanguageTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
            exit(false);
        end;

        if not IsTenantAllowed() then begin
            Session.LogMessage('0000JVO', TelemetryTenantDisabledTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
            exit(false);
        end;

        if not EntityText.WritePermission() then begin
            Session.LogMessage('0000JY0', TelemetryMissingPermissionTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
            exit(false);
        end;

        if Silent then
            PrivacyResult := PrivacyNotice.GetPrivacyNoticeApprovalState(AzureOpenAiTxt, false) = Enum::"Privacy Notice Approval State"::Agreed
        else
            PrivacyResult := PrivacyNotice.ConfirmPrivacyNoticeApproval(AzureOpenAiTxt, false);

        Session.LogMessage('0000JVP', StrSubstNo(TelemetryPrivacyResultTxt, Format(PrivacyResult)), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
        exit(PrivacyResult);
    end;

    procedure IsPendingPrivacyApproval(): Boolean
    var
        FeatureKey: Record "Feature Key";
        EntityText: Record "Entity Text";
        PrivacyNotice: Codeunit "Privacy Notice";
    begin
        if FeatureKey.Get('EntityText') and (FeatureKey.Enabled <> FeatureKey.Enabled::"All Users") then
            exit(false);

        if not IsSupportedLanguage() then
            exit(false);

        if not IsTenantAllowed() then
            exit(false);

        if not EntityText.WritePermission() then
            exit(false);

        exit(PrivacyNotice.GetPrivacyNoticeApprovalState(AzureOpenAiTxt, false) = Enum::"Privacy Notice Approval State"::"Not set");
    end;

    local procedure IsSupportedLanguage(): Boolean
    begin
        exit(LowerCase(GetLanguageName()).StartsWith('english'));
    end;

    procedure GetLanguageName(): Text
    var
        Language: Codeunit Language;
        LanguageValue: Text;
        CurrentLanguage: Integer;
    begin
        CurrentLanguage := GlobalLanguage();
        GlobalLanguage(1033); // Get the language name in english
        LanguageValue := Language.GetWindowsLanguageName(CurrentLanguage);
        GlobalLanguage(CurrentLanguage);

        exit(LanguageValue);
    end;

    [NonDebuggable]
    internal procedure GenerateCompletion(Prompt: Text; CallerModuleInfo: ModuleInfo): Text;
    var
        TokenLimit: Integer;
        DefaultTemperature: Decimal;
    begin
        TokenLimit := 1000;
        DefaultTemperature := 0.7;

        exit(GenerateCompletion(Prompt, TokenLimit, DefaultTemperature, CallerModuleInfo));
    end;

    [NonDebuggable]
    internal procedure GenerateCompletion(Prompt: Text; MaxTokens: Integer; Temperature: Decimal; CallerModuleInfo: ModuleInfo): Text;
    var
        Configuration: JsonObject;
        Completion: Text;
        TokenLimit: Integer;
        NewLineChar: Char;
    begin
        TokenLimit := 1000;

        if (MaxTokens < 1) or (MaxTokens > TokenLimit) then
            MaxTokens := TokenLimit; // default

        if Temperature < 0 then
            Temperature := 0;

        if Temperature > 1 then
            Temperature := 1;

        Configuration.Add('prompt', Prompt);
        Configuration.Add('max_tokens', MaxTokens);
        Configuration.Add('temperature', Temperature);

        Session.LogMessage('0000JVQ', StrSubstNo(TelemetryCompletionOverviewTxt, Format(StrLen(Prompt)), Format(MaxTokens), Format(Temperature), Format(CallerModuleInfo.Id()), CallerModuleInfo.Publisher()), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);

        Completion := SendCompletionRequest(Configuration, CallerModuleInfo);

        NewLineChar := 10;
        if StrLen(Completion) > 1 then
            Completion := CopyStr(Completion, 2, StrLen(Completion) - 2);
        Completion := Completion.Replace('\n', NewLineChar);
        Completion := DelChr(Completion, '<>', ' ');
        Completion := Completion.Replace('\"', '"');
        Completion := Completion.Trim();

        exit(Completion);
    end;

    [NonDebuggable]
    local procedure IsTenantAllowed(): Boolean
    var
        EnvironmentInformation: Codeunit "Environment Information";
        AzureKeyVault: Codeunit "Azure Key Vault";
        AzureAdTenant: Codeunit "Azure AD Tenant";
        BlockList: Text;
    begin
        if not EnvironmentInformation.IsSaaSInfrastructure() then
            exit(true);

        if (not AzureKeyVault.GetAzureKeyVaultSecret(EnabledKeyTok, BlockList)) or (BlockList.Trim() = '') then
            exit(false);

        if BlockList.Contains(AzureAdTenant.GetAadTenantId()) then
            exit(false);

        exit(true);
    end;

    [NonDebuggable]
    local procedure SendCompletionRequest(Payload: JsonObject; CallerModuleInfo: ModuleInfo): Text
    var
        AzureOpenAiSettings: Record "Azure OpenAi Settings";
        CrossGeoOption: JsonObject;
        PayloadText: Text;
        Secret: Text;
        Endpoint: Text;
        Completion: Text;
        Attempt: Integer;
        MaxAttempts: Integer;
        ResponseStatusCode: Integer;
        BearerAuth: Boolean;
    begin
        AssertIsEnabled();
        if not AzureOpenAiSettings.Get() then
            AzureOpenAiSettings.SetDefaults();

        if not AzureOpenAiSettings.IsConfigured(CallerModuleInfo) then begin
            if Confirm(NotConfiguredQst) then
                Page.Run(Page::"Azure OpenAi Settings", AzureOpenAiSettings);
            Error('');
        end;

        Endpoint := AzureOpenAiSettings.CompletionsEndpoint(CallerModuleInfo, BearerAuth);
        if Endpoint = '' then
            Error(NoEndpointErr);

        Secret := AzureOpenAiSettings.GetSecret(CallerModuleInfo);
        if Secret = '' then
            Error(NoSecretErr);

        if AzureOpenAiSettings.IncludeSource(CallerModuleInfo) then begin
            CrossGeoOption.Add('enableCrossGeoCall', true);

            Payload.Add('source', 'businesscentral');
            Payload.Add('n', 1);
            Payload.Add('crossGeoOptions', CrossGeoOption);
        end;

        Payload.WriteTo(PayloadText);

        MaxAttempts := 3;
        for Attempt := 0 to MaxAttempts do begin
            Session.LogMessage('0000JVR', StrSubstNo(TelemetryRequestStartTxt, Format(BearerAuth), CallerModuleInfo.Publisher()), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
            if SendRequest(Endpoint, BearerAuth, Secret, PayloadText, ResponseStatusCode, Completion) then
                exit(Completion);

            if (ResponseStatusCode >= 400) and (ResponseStatusCode < 500) and (ResponseStatusCode <> 429) then
                Error(RequestFailedErr, ResponseStatusCode); // client error

            Session.LogMessage('0000JVS', StrSubstNo(TelemetryRequestFailedTxt, ResponseStatusCode, Attempt, MaxAttempts), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
            Sleep(Random(2000) + 1000); // wait 1-3 sec before retry
        end;

        if (ResponseStatusCode = 0) or (ResponseStatusCode = 200) then
            Error(RequestFailedUnknownErr)
        else
            Error(RequestFailedErr, ResponseStatusCode);
    end;

    [NonDebuggable]
    [TryFunction]
    local procedure SendRequest(Endpoint: Text; BearerAuth: Boolean; Secret: Text; Payload: Text; var StatusCode: Integer; var Completion: Text)
    var
        AzureAdTenant: Codeunit "Azure AD Tenant";
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        HttpContent: HttpContent;
        ResponseText: Text;
        RequestIds: List of [Text];
        ResponseJson: JsonObject;
        CompletionToken: JsonToken;
        CorrelationId: Guid;
        TenantGuid: Guid;
    begin
        HttpRequestMessage.Method('POST');
        HttpRequestMessage.SetRequestUri(Endpoint);

        if BearerAuth then
            HttpClient.DefaultRequestHeaders().Add('Authorization', 'Bearer ' + Secret)
        else
            HttpClient.DefaultRequestHeaders().Add('api-key', Secret);

        HttpContent.WriteFrom(Payload);
        CorrelationId := CreateGuid();

        if not Evaluate(TenantGuid, AzureAdTenant.GetAadTenantId()) then
            Session.LogMessage('0000K5I', TelemetryUnknownTenantIdLbl, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);

        HttpContent.GetHeaders(RequestHeaders);
        RequestHeaders.Remove('Content-Type');
        RequestHeaders.Add('Content-Type', 'application/json');
        RequestHeaders.Add('x-ms-correlation-id', Format(CorrelationId, 0, 4));
        RequestHeaders.Add('x-ms-organization-tenant-id', Format(TenantGuid, 0, 4));

        HttpRequestMessage.Content(HttpContent);

        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);

        StatusCode := HttpResponseMessage.HttpStatusCode();
        if not HttpResponseMessage.IsSuccessStatusCode() then
            Error(CompletionFailedErr);

        HttpResponseMessage.Content().ReadAs(ResponseText);
        ResponseJson.ReadFrom(ResponseText);
        ResponseJson.SelectToken('$.choices[:].text', CompletionToken);
        CompletionToken.WriteTo(Completion);

        if not HttpResponseMessage.Headers().GetValues('x-request-id', RequestIds) then
            RequestIds.Add('Unknown');

        Session.LogMessage('0000JVT', StrSubstNo(TelemetryRequestCompletedTxt, RequestIds.Get(1), CorrelationId), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);

        if ContainsWordsInDenyList(Completion) then begin
            Clear(Completion);
            Error(CompletionDeniedPhraseErr);
        end;
    end;

    [NonDebuggable]
    local procedure ContainsWordsInDenyList(Completion: Text): Boolean
    var
        EnvironmentInformation: Codeunit "Environment Information";
        AzureKeyVault: Codeunit "Azure Key Vault";
        DenyPhrasesText: Text;
        DenyPhrase: Text;
        DenyPhrases: List of [Text];
    begin
        if not EnvironmentInformation.IsSaaSInfrastructure() then
            exit(false);

        if not AzureKeyVault.GetAzureKeyVaultSecret(DenyPhrasesKeyTok, DenyPhrasesText) then
            exit(false);

        if DenyPhrasesText = '' then
            exit(false);

        DenyPhrases := DenyPhrasesText.Split('|');

        Completion := Completion.ToLower();
        foreach DenyPhrase in DenyPhrases do begin
            DenyPhrase := DenyPhrase.Trim().ToLower();
            if (DenyPhrase <> '') and Completion.Contains(DenyPhrase) then begin
                Session.LogMessage('0000JYH', StrSubstNo(TelemetryCompletionDeniedTxt, DenyPhrase), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
                exit(true);
            end;
        end;

        exit(false);
    end;

    local procedure AssertIsEnabled()
    begin
        if IsEnabled(false) then
            exit;

        Error(FeatureDisabledErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Privacy Notice", 'OnRegisterPrivacyNotices', '', false, false)]
    local procedure CreatePrivacyNoticeRegistrations(var TempPrivacyNotice: Record "Privacy Notice" temporary)
    begin
        TempPrivacyNotice.Init();
        TempPrivacyNotice.ID := AzureOpenAiTxt;
        TempPrivacyNotice."Integration Service Name" := AzureOpenAiTxt;
        if not TempPrivacyNotice.Insert() then;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Privacy Notice", OnBeforeShowPrivacyNotice, '', false, false)]
    local procedure ShowPrivacyNotice(PrivacyNotice: Record "Privacy Notice"; var Handled: Boolean)
    var
        CopilotInformation: Page "Copilot Information";
    begin
        if Handled then
            exit;

        if PrivacyNotice.ID <> UpperCase(AzureOpenAiTxt) then
            exit;

        CopilotInformation.SetRecord(PrivacyNotice);
        CopilotInformation.RunModal();
        Handled := true;
    end;

    var
        FeatureDisabledErr: Label 'The feature has been disabled.';
        RequestFailedErr: Label 'A suggestion couldn''t be generated. Review the information provided, consider your choice of words, and try again.\The error code returned was %1.', Comment = '%1 is the http status code of the failed request (e.g. 401)';
        RequestFailedUnknownErr: Label 'A suggestion couldn''t be generated. Review the information provided, consider your choice of words, and try again.';
        NoSecretErr: Label 'The service needs to be configured in the OpenAI settings page. No key has been provided.';
        NoEndpointErr: Label 'No OpenAI endpoint has been specified for this request, or the specified endpoint is invalid. Open the OpenAI settings page and verify the settings.';
        NotConfiguredQst: Label 'The service needs to be configured in the OpenAI settings page.\Would you like to open it?';
        AzureOpenAiTxt: Label 'Azure OpenAI', Locked = true;
        EnabledKeyTok: Label 'AOAI-Enabled', Locked = true;
        DenyPhrasesKeyTok: Label 'AOAI-DenyPhrases', Locked = true;
        CompletionDeniedPhraseErr: Label 'The completion contains a denied phrase.';
        CompletionFailedErr: Label 'The completion did not return a success status code.';
        TelemetryCategoryLbl: Label 'AOAI', Locked = true;
        TelemetryRequestStartTxt: Label 'Sending AI request. Bearer auth: %1, Caller publisher: %2', Locked = true;
        TelemetryPrivacyResultTxt: Label 'Privacy notice has been approved: %1, AOAI is enabled: %1.', Locked = true;
        TelemetryTenantDisabledTxt: Label 'Feature key is not enabled for the tenant, AOAI is enabled.', Locked = true;
        TelemetryFeatureKeyDisabledTxt: Label 'Feature key is disabled, AOAI is disabled.', Locked = true;
        TelemetryCompletionDeniedTxt: Label 'The completion was rejected because it contained the phrase ''%1''', Locked = true;
        TelemetryMissingPermissionTxt: Label 'Feature is disabled due to missing write permissions.', Locked = true;
        TelemetryCompletionOverviewTxt: Label 'Sending a completion request. Prompt size: %1, max tokens: %2, temperature: %3, calling module: %4 (%5).', Locked = true;
        TelemetryRequestFailedTxt: Label 'The request failed to send with error code %1. Attempt %2 of %3.', Locked = true;
        TelemetryRequestCompletedTxt: Label 'The request completed successfully, request id: %1, ms request id: %2.', Locked = true;
        TelemetryUnknownTenantIdLbl: Label 'The tenant id was not a valid guid', Locked = true;
        TelemetryUnsupportedLanguageTxt: Label 'The user is not using a supported language.', Locked = true;
}