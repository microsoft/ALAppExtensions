// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.AI;

using System;
using System.Azure.Identity;
using System.Azure.KeyVault;
using System.Environment;
using System.Globalization;
using System.Privacy;
using System.Telemetry;

codeunit 7772 "Azure OpenAI Impl"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Copilot Settings" = r;

    var
        CopilotSettings: Record "Copilot Settings";
        CopilotCapabilityCU: Codeunit "Copilot Capability";
        CopilotCapabilityImpl: Codeunit "Copilot Capability Impl";
        ChatCompletionsAOAIAuthorization: Codeunit "AOAI Authorization";
        TextCompletionsAOAIAuthorization: Codeunit "AOAI Authorization";
        EmbeddingsAOAIAuthorization: Codeunit "AOAI Authorization";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        InvalidModelTypeErr: Label 'Selected model type is not supported.';
        GenerateRequestFailedErr: Label 'The request did not return a success status code.';
        CompletionsFailedWithCodeErr: Label 'The text completions generation failed.';
        EmbeddingsFailedWithCodeErr: Label 'The embeddings generation failed.';
        ChatCompletionsFailedWithCodeErr: Label 'The chat completions generation failed.';
        AuthenticationNotConfiguredErr: Label 'The authentication was not configured.';
        CopilotNotEnabledErr: Label 'Copilot is not enabled. Please contact your system administrator.';
        CopilotCapabilityNotSetErr: Label 'Copilot capability has not been set.';
        CapabilityBackgroundErr: Label 'Microsoft Copilot Capabilities are not allowed in the background.';
        CopilotDisabledForTenantErr: Label 'Copilot is not enabled for the tenant. Please contact your system administrator.';
        CapabilityNotRegisteredErr: Label 'Copilot capability ''%1'' has not been registered by the module.', Comment = '%1 is the name of the Copilot Capability';
        CapabilityNotEnabledErr: Label 'Copilot capability ''%1'' has not been enabled. Please contact your system administrator.', Comment = '%1 is the name of the Copilot Capability';
        ThirdPartyCapabilitySaaSErr: Label 'Available now to Insider Builds. Partners will be able to deploy and run to Business Central Online once we light this up in a minor update.';
        EmptyMetapromptErr: Label 'The metaprompt has not been set, please provide a metaprompt.';
        EnabledKeyTok: Label 'AOAI-Enabled', Locked = true;
        TelemetryGenerateTextCompletionLbl: Label 'Generate Text Completion', Locked = true;
        TelemetryGenerateEmbeddingLbl: Label 'Generate Embedding', Locked = true;
        TelemetryGenerateChatCompletionLbl: Label 'Generate Chat Completion', Locked = true;
        TelemetrySetCapabilityLbl: Label 'Set Capability', Locked = true;
        TelemetryCopilotCapabilityNotRegisteredLbl: Label 'Copilot capability was not registered.', Locked = true;
        TelemetryIsEnabledLbl: Label 'Is Enabled', Locked = true;
        TelemetryUnableToCheckEnvironmentKVTxt: Label 'Unable to check if environment is allowed to run AOAI.', Locked = true;
        TelemetryEnvironmentNotAllowedtoRunCopilotTxt: Label 'Copilot is not allowed on this environment.', Locked = true;
        TelemetryProhibitedCharactersTxt: Label 'Prohibited characters were removed from the prompt.', Locked = true;

    procedure IsEnabled(Capability: Enum "Copilot Capability"; CallerModuleInfo: ModuleInfo): Boolean
    begin
        exit(IsEnabled(Capability, false, CallerModuleInfo));
    end;

    procedure IsEnabled(Capability: Enum "Copilot Capability"; Silent: Boolean; CallerModuleInfo: ModuleInfo): Boolean
    var
        CoplilotNotAvailable: Page "Copilot Not Available";
    begin
        if not IsTenantAllowed() then begin
            if not Silent then
                Error(CopilotDisabledForTenantErr); // Copilot capabilities cannot be run on this environment.

            exit(false);
        end;

        if not CopilotCapabilityCU.IsCapabilityActive(Capability, CallerModuleInfo.Id()) then begin
            if not Silent then begin
                CoplilotNotAvailable.SetCopilotCapability(Capability);
                CoplilotNotAvailable.Run();
            end;

            exit(false);
        end;

        exit(CheckPrivacyNoticeState(Silent, Capability));
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

        if (not AzureKeyVault.GetAzureKeyVaultSecret(EnabledKeyTok, BlockList)) or (BlockList.Trim() = '') then begin
            FeatureTelemetry.LogError('0000KYC', CopilotCapabilityImpl.GetAzureOpenAICategory(), TelemetryIsEnabledLbl, TelemetryUnableToCheckEnvironmentKVTxt);
            exit(false);
        end;

        if BlockList.Contains(AzureAdTenant.GetAadTenantId()) then begin
            FeatureTelemetry.LogError('0000LFP', CopilotCapabilityImpl.GetAzureOpenAICategory(), TelemetryIsEnabledLbl, TelemetryEnvironmentNotAllowedtoRunCopilotTxt);
            exit(false);
        end;

        exit(true);
    end;

    local procedure CheckPrivacyNoticeState(Silent: Boolean; Capability: Enum "Copilot Capability"): Boolean
    var
        PrivacyNotice: Codeunit "Privacy Notice";
        CopilotNotAvailable: Page "Copilot Not Available";
        ALCopilotFunctions: DotNet ALCopilotFunctions;
        WithinGeo: Boolean;
    begin
        case PrivacyNotice.GetPrivacyNoticeApprovalState(CopilotCapabilityImpl.GetAzureOpenAICategory(), false) of
            Enum::"Privacy Notice Approval State"::Agreed:
                exit(true);
            Enum::"Privacy Notice Approval State"::Disagreed:
                begin
                    if not Silent then begin
                        CopilotNotAvailable.SetCopilotCapability(Capability);
                        CopilotNotAvailable.Run();
                    end;

                    exit(false);
                end;
            else begin
                WithinGeo := ALCopilotFunctions.IsWithinGeo();
                // Privacy notice not set, we will not cross geo-boundries                
                if not Silent then
                    if not WithinGeo then begin
                        CopilotNotAvailable.SetCopilotCapability(Capability);
                        CopilotNotAvailable.Run();
                    end;

                exit(WithinGeo);
            end;

        end;
    end;

    procedure IsAuthorizationConfigured(ModelType: Enum "AOAI Model Type"; CallerModule: ModuleInfo): Boolean
    begin
        case ModelType of
            Enum::"AOAI Model Type"::"Text Completions":
                exit(TextCompletionsAOAIAuthorization.IsConfigured(CallerModule));
            Enum::"AOAI Model Type"::Embeddings:
                exit(EmbeddingsAOAIAuthorization.IsConfigured(CallerModule));
            Enum::"AOAI Model Type"::"Chat Completions":
                exit(ChatCompletionsAOAIAuthorization.IsConfigured(CallerModule));
            else
                Error(InvalidModelTypeErr)
        end;
    end;

    procedure IsInitialized(Capability: Enum "Copilot Capability"; ModelType: Enum "AOAI Model Type"; CallerModuleInfo: ModuleInfo): Boolean
    begin
        exit(IsEnabled(Capability, CallerModuleInfo) and IsAuthorizationConfigured(ModelType, CallerModuleInfo));
    end;

    [NonDebuggable]
    procedure SetAuthorization(ModelType: Enum "AOAI Model Type"; Deployment: Text)
    var
        ApiKey: SecretText;
    begin
        SetAuthorization(ModelType, '', Deployment, ApiKey);
    end;

    [NonDebuggable]
    procedure SetAuthorization(ModelType: Enum "AOAI Model Type"; Endpoint: Text; Deployment: Text; ApiKey: SecretText)
    begin
        case ModelType of
            Enum::"AOAI Model Type"::"Text Completions":
                TextCompletionsAOAIAuthorization.SetAuthorization(Endpoint, Deployment, ApiKey);
            Enum::"AOAI Model Type"::Embeddings:
                EmbeddingsAOAIAuthorization.SetAuthorization(Endpoint, Deployment, ApiKey);
            Enum::"AOAI Model Type"::"Chat Completions":
                ChatCompletionsAOAIAuthorization.SetAuthorization(Endpoint, Deployment, ApiKey);
            else
                Error(InvalidModelTypeErr);
        end;
    end;

    [NonDebuggable]
    procedure GenerateTextCompletion(Prompt: SecretText; var AOAIOperationResponse: Codeunit "AOAI Operation Response"; CallerModuleInfo: ModuleInfo): Text
    var
        AOAICompletionParameters: Codeunit "AOAI Text Completion Params";
    begin
        exit(GenerateTextCompletion(GetMetaprompt(), Prompt, AOAICompletionParameters, AOAIOperationResponse, CallerModuleInfo));
    end;

    [NonDebuggable]
    procedure GenerateTextCompletion(Prompt: SecretText; AOAICompletionParameters: Codeunit "AOAI Text Completion Params"; var AOAIOperationResponse: Codeunit "AOAI Operation Response"; CallerModuleInfo: ModuleInfo) Result: Text
    begin
        exit(GenerateTextCompletion(GetMetaprompt(), Prompt, AOAICompletionParameters, AOAIOperationResponse, CallerModuleInfo));
    end;

    [NonDebuggable]
    procedure GenerateTextCompletion(Metaprompt: SecretText; Prompt: SecretText; var AOAIOperationResponse: Codeunit "AOAI Operation Response"; CallerModuleInfo: ModuleInfo): Text
    var
        AOAICompletionParameters: Codeunit "AOAI Text Completion Params";
    begin
        exit(GenerateTextCompletion(Metaprompt, Prompt, AOAICompletionParameters, AOAIOperationResponse, CallerModuleInfo));
    end;

    [NonDebuggable]
    procedure GenerateTextCompletion(Metaprompt: SecretText; Prompt: SecretText; AOAICompletionParameters: Codeunit "AOAI Text Completion Params"; var AOAIOperationResponse: Codeunit "AOAI Operation Response"; CallerModuleInfo: ModuleInfo) Result: Text
    var
        CustomDimensions: Dictionary of [Text, Text];
        Payload: JsonObject;
        PayloadText: Text;
        UnwrappedPrompt: Text;
    begin
        GuiCheck(CallerModuleInfo);

        CheckIfThirdParty(CallerModuleInfo);
        CheckCapabilitySet();
        CheckEnabled(CallerModuleInfo);
        CheckAuthorizationEnabled(TextCompletionsAOAIAuthorization, CallerModuleInfo);

        AddTelemetryCustomDimensions(CustomDimensions, CallerModuleInfo);
        CheckTextCompletionMetaprompt(Metaprompt, CustomDimensions);

        UnwrappedPrompt := Metaprompt.Unwrap() + Prompt.Unwrap();
        UnwrappedPrompt := RemoveProhibitedCharacters(UnwrappedPrompt);

        AOAICompletionParameters.AddCompletionsParametersToPayload(Payload);
        Payload.Add('prompt', UnwrappedPrompt);
        Payload.WriteTo(PayloadText);

        if not SendRequest(Enum::"AOAI Model Type"::"Text Completions", TextCompletionsAOAIAuthorization, PayloadText, AOAIOperationResponse) then begin
            FeatureTelemetry.LogError('0000KVD', CopilotCapabilityImpl.GetAzureOpenAICategory(), TelemetryGenerateTextCompletionLbl, CompletionsFailedWithCodeErr, '', CustomDimensions);
            exit;
        end;

        FeatureTelemetry.LogUsage('0000KVL', CopilotCapabilityImpl.GetAzureOpenAICategory(), TelemetryGenerateTextCompletionLbl, CustomDimensions);
        Result := AOAIOperationResponse.GetResult();
    end;

    [NonDebuggable]
    procedure GenerateEmbeddings(Input: SecretText; var AOAIOperationResponse: Codeunit "AOAI Operation Response"; CallerModuleInfo: ModuleInfo): List of [Decimal]
    var
        CustomDimensions: Dictionary of [Text, Text];
        Payload: JsonObject;
        PayloadText: Text;
    begin
        GuiCheck(CallerModuleInfo);

        CheckIfThirdParty(CallerModuleInfo);
        CheckCapabilitySet();
        CheckEnabled(CallerModuleInfo);
        CheckAuthorizationEnabled(EmbeddingsAOAIAuthorization, CallerModuleInfo);

        Payload.Add('input', Input.Unwrap());
        Payload.WriteTo(PayloadText);

        AddTelemetryCustomDimensions(CustomDimensions, CallerModuleInfo);
        if not SendRequest(Enum::"AOAI Model Type"::Embeddings, EmbeddingsAOAIAuthorization, PayloadText, AOAIOperationResponse) then begin
            FeatureTelemetry.LogError('0000KVE', CopilotCapabilityImpl.GetAzureOpenAICategory(), TelemetryGenerateEmbeddingLbl, EmbeddingsFailedWithCodeErr, '', CustomDimensions);
            exit;
        end;

        FeatureTelemetry.LogUsage('0000KVM', CopilotCapabilityImpl.GetAzureOpenAICategory(), TelemetryGenerateEmbeddingLbl, CustomDimensions);
        exit(ProcessEmbeddingResponse(AOAIOperationResponse));
    end;

    [NonDebuggable]
    local procedure ProcessEmbeddingResponse(AOAIOperationResponse: Codeunit "AOAI Operation Response") Result: List of [Decimal]
    var
        Response: JsonObject;
        CompletionToken: JsonToken;
        Counter: Integer;
        XPathLbl: Label '$.vector[%1]', Comment = '%1 = The n''th embedding. For more details on response, see https://aka.ms/AAlrrng', Locked = true;
    begin
        Response.ReadFrom(AOAIOperationResponse.GetResult());
        Counter := 0;
        while Response.SelectToken(StrSubstNo(XPathLbl, Counter), CompletionToken) do begin
            Counter := Counter + 1;
            Result.Add(CompletionToken.AsValue().AsDecimal());
        end;
    end;

    [NonDebuggable]
    procedure GenerateChatCompletion(var ChatMessages: Codeunit "AOAI Chat Messages"; var AOAIOperationResponse: Codeunit "AOAI Operation Response"; CallerModuleInfo: ModuleInfo)
    var
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
    begin
        GenerateChatCompletion(ChatMessages, AOAIChatCompletionParams, AOAIOperationResponse, CallerModuleInfo);
    end;

    [NonDebuggable]
    procedure GenerateChatCompletion(var ChatMessages: Codeunit "AOAI Chat Messages"; AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params"; var AOAIOperationResponse: Codeunit "AOAI Operation Response"; CallerModuleInfo: ModuleInfo)
    var
        CustomDimensions: Dictionary of [Text, Text];
        Payload: JsonObject;
        PayloadText: Text;
    begin
        GuiCheck(CallerModuleInfo);

        CheckIfThirdParty(CallerModuleInfo);
        CheckCapabilitySet();
        CheckEnabled(CallerModuleInfo);
        CheckAuthorizationEnabled(ChatCompletionsAOAIAuthorization, CallerModuleInfo);

        AOAIChatCompletionParams.AddChatCompletionsParametersToPayload(Payload);
        Payload.Add('messages', ChatMessages.AssembleHistory());
        Payload.WriteTo(PayloadText);

        AddTelemetryCustomDimensions(CustomDimensions, CallerModuleInfo);
        if not SendRequest(Enum::"AOAI Model Type"::"Chat Completions", ChatCompletionsAOAIAuthorization, PayloadText, AOAIOperationResponse) then begin
            FeatureTelemetry.LogError('0000KVF', CopilotCapabilityImpl.GetAzureOpenAICategory(), TelemetryGenerateChatCompletionLbl, ChatCompletionsFailedWithCodeErr, '', CustomDimensions);
            exit;
        end;

        ProcessChatCompletionResponse(AOAIOperationResponse.GetResult(), ChatMessages);

        FeatureTelemetry.LogUsage('0000KVN', CopilotCapabilityImpl.GetAzureOpenAICategory(), TelemetryGenerateChatCompletionLbl);
    end;

    [NonDebuggable]
    [TryFunction]
    local procedure ProcessChatCompletionResponse(ResponseText: Text; var ChatMessages: Codeunit "AOAI Chat Messages")
    var
        Response: JsonObject;
        CompletionToken: JsonToken;
        XPathLbl: Label '$.content', Comment = 'For more details on response, see https://aka.ms/AAlrz36', Locked = true;
    begin
        Response.ReadFrom(ResponseText);
        Response.SelectToken(XPathLbl, CompletionToken);
        ChatMessages.AddAssistantMessage(CompletionToken.AsValue().AsText());
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure SendRequest(ModelType: Enum "AOAI Model Type"; AOAIAuthorization: Codeunit "AOAI Authorization"; Payload: Text; var AOAIOperationResponse: Codeunit "AOAI Operation Response")
    var
        ALCopilotAuthorization: DotNet ALCopilotAuthorization;
        ALCopilotFunctions: DotNet ALCopilotFunctions;
        ALCopilotOperationResponse: DotNet ALCopilotOperationResponse;
    begin
        ClearLastError();
        ALCopilotAuthorization := ALCopilotAuthorization.Create(AOAIAuthorization.GetEndpoint(), AOAIAuthorization.GetDeployment(), AOAIAuthorization.GetApiKey());

        case ModelType of
            Enum::"AOAI Model Type"::"Text Completions":
                ALCopilotOperationResponse := ALCopilotFunctions.GenerateTextCompletion(Payload, ALCopilotAuthorization);
            Enum::"AOAI Model Type"::Embeddings:
                ALCopilotOperationResponse := ALCopilotFunctions.GenerateEmbedding(Payload, ALCopilotAuthorization);
            Enum::"AOAI Model Type"::"Chat Completions":
                ALCopilotOperationResponse := ALCopilotFunctions.GenerateChatCompletion(Payload, ALCopilotAuthorization);
            else
                Error(InvalidModelTypeErr)
        end;

        AOAIOperationResponse.SetOperationResponse(ALCopilotOperationResponse);

        if not ALCopilotOperationResponse.IsSuccess() then
            Error(GenerateRequestFailedErr);
    end;

    local procedure GuiCheck(CallerModuleInfo: ModuleInfo)
    var
        CurrentModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CurrentModuleInfo);

        if (not GuiAllowed()) and (CallerModuleInfo.Publisher = CurrentModuleInfo.Publisher) then
            Error(CapabilityBackgroundErr);
    end;

    local procedure CheckIfThirdParty(CallerModuleInfo: ModuleInfo)
    var
        EnvironmentInformation: Codeunit "Environment Information";
        CurrentModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CurrentModuleInfo);

        if EnvironmentInformation.IsSaaSInfrastructure() <> true then
            exit;

        if CallerModuleInfo.Publisher <> CurrentModuleInfo.Publisher then
            Error(ThirdPartyCapabilitySaaSErr);
    end;

    local procedure AddTelemetryCustomDimensions(var CustomDimensions: Dictionary of [Text, Text]; CallerModuleInfo: ModuleInfo)
    var
        Language: Codeunit Language;
        SavedGlobalLanguageId: Integer;
    begin
        SavedGlobalLanguageId := GlobalLanguage();
        GlobalLanguage(Language.GetDefaultApplicationLanguageId());

        CustomDimensions.Add('Capability', Format(CopilotSettings.Capability));
        CustomDimensions.Add('AppId', Format(CopilotSettings."App Id"));
        CustomDimensions.Add('Publisher', CallerModuleInfo.Publisher);
        CustomDimensions.Add('UserLanguage', Format(GlobalLanguage()));

        GlobalLanguage(SavedGlobalLanguageId);
    end;

    procedure SetCopilotCapability(Capability: Enum "Copilot Capability"; CallerModuleInfo: ModuleInfo)
    var
        CopilotTelemetry: Codeunit "Copilot Telemetry";
        Language: Codeunit Language;
        SavedGlobalLanguageId: Integer;
        CustomDimensions: Dictionary of [Text, Text];
        ErrorMessage: Text;
    begin
        if not CopilotCapabilityCU.IsCapabilityRegistered(Capability, CallerModuleInfo.Id()) then begin
            SavedGlobalLanguageId := GlobalLanguage();
            GlobalLanguage(Language.GetDefaultApplicationLanguageId());
            CustomDimensions.Add('Capability', Format(Capability));
            CustomDimensions.Add('AppId', Format(CallerModuleInfo.Id()));
            GlobalLanguage(SavedGlobalLanguageId);

            FeatureTelemetry.LogError('0000LFN', CopilotCapabilityImpl.GetAzureOpenAICategory(), TelemetrySetCapabilityLbl, TelemetryCopilotCapabilityNotRegisteredLbl);
            ErrorMessage := StrSubstNo(CapabilityNotRegisteredErr, Capability);
            Error(ErrorMessage);
        end;

        CopilotSettings.ReadIsolation(IsolationLevel::ReadCommitted);
        CopilotSettings.SetLoadFields(Status);
        CopilotSettings.Get(Capability, CallerModuleInfo.Id());
        if CopilotSettings.Status = Enum::"Copilot Status"::Inactive then begin
            ErrorMessage := StrSubstNo(CapabilityNotEnabledErr, Capability);
            Error(ErrorMessage);
        end;
        CopilotTelemetry.SetCopilotCapability(Capability, CallerModuleInfo.Id());
    end;

    local procedure CheckEnabled(CallerModuleInfo: ModuleInfo)
    begin
        if not IsEnabled(CopilotSettings.Capability, true, CallerModuleInfo) then
            Error(CopilotNotEnabledErr);
    end;

    local procedure CheckAuthorizationEnabled(AOAIAuthorization: Codeunit "AOAI Authorization"; CallerModuleInfo: ModuleInfo)
    begin
        if not AOAIAuthorization.IsConfigured(CallerModuleInfo) then
            Error(AuthenticationNotConfiguredErr);
    end;

    local procedure CheckCapabilitySet()
    begin
        if CopilotSettings.Capability.AsInteger() = 0 then
            Error(CopilotCapabilityNotSetErr);
    end;

    [NonDebuggable]
    procedure RemoveProhibitedCharacters(Prompt: Text) Result: Text
    var
        Telemetry: Codeunit Telemetry;
    begin
        Result := Prompt.Replace('<|end>', '');
        Result := Result.Replace('<|start>', '');
        Result := Result.Replace('<|im_end|>', '');
        Result := Result.Replace('<|im_start|>', '');

        if Prompt <> Result then
            Telemetry.LogMessage('0000LOB', TelemetryProhibitedCharactersTxt, Verbosity::Warning, DataClassification::SystemMetadata);

        exit(Result);
    end;

    [NonDebuggable]
    internal procedure GetMetaprompt() Metaprompt: SecretText;
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        KVSecret: Text;
    begin
        if AzureKeyVault.GetAzureKeyVaultSecret('AOAI-Metaprompt', KVSecret) then;
        Metaprompt := KVSecret;
    end;

    [NonDebuggable]
    local procedure CheckTextCompletionMetaprompt(Metaprompt: SecretText; CustomDimensions: Dictionary of [Text, Text])
    begin
        if Metaprompt.Unwrap().Trim() = '' then begin
            FeatureTelemetry.LogError('0000LO8', CopilotCapabilityImpl.GetAzureOpenAICategory(), TelemetryGenerateTextCompletionLbl, EmptyMetapromptErr, '', CustomDimensions);
            Error(EmptyMetapromptErr);
        end;
    end;

}