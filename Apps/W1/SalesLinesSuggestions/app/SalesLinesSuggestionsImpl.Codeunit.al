// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using System;
using System.AI;
using System.Telemetry;
using System.Environment;
using System.Globalization;

codeunit 7275 "Sales Lines Suggestions Impl."
{
    Access = Internal;

    var
        ChatCompletionResponseErr: Label 'Sorry, something went wrong. Please rephrase and try again.';

    internal procedure GetFeatureName(): Text
    begin
        exit('Sales Lines Suggestions');
    end;

    internal procedure GetChatCompletionResponseErr(): Text
    begin
        exit(ChatCompletionResponseErr);
    end;

    internal procedure GetNoSalesLinesSuggestionsMsg(): Text
    var
        NoSalesLinesSuggestionsMsg: Label 'There are no suggestions for this description. Please rephrase it.';
    begin
        exit(NoSalesLinesSuggestionsMsg);
    end;

    local procedure MaxTokens(): Integer
    begin
        exit(4096);
    end;

    internal procedure GetLinesSuggestions(SalesLine: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
        AzureOpenAI: Codeunit "Azure OpenAI";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        SalesLineAISuggestionImpl: Codeunit "Sales Lines Suggestions Impl.";
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        ALSearch: DotNet ALSearch;
        FeatureTelemetryCustomDimension: Dictionary of [Text, Text];
        SalesHeaderNotInitializedErr: Label '%1 header is not initialized', Comment = '%1 = Document Type';
        ErrorTxt: Text;
    begin
        SalesLine.TestStatusOpen();
        if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"Sales Lines Suggestions") then
            exit;

        FeatureTelemetryCustomDimension.Add('Document Type', SalesLine."Document Type".Names().Get(SalesLine."Document Type".Ordinals.IndexOf(SalesLine."Document Type".AsInteger())));
        FeatureTelemetry.LogUptake('0000MEB', SalesLineAISuggestionImpl.GetFeatureName(), Enum::"Feature Uptake Status"::Discovered, FeatureTelemetryCustomDimension);

        if not ALSearch.IsItemSearchReady() then
            ALSearch.EnableItemSearch();

        if SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.") then begin
            SalesLineAISuggestions.SetSalesHeader(SalesHeader);
            SalesLineAISuggestions.LookupMode := true;
            FeatureTelemetry.LogUptake('0000MEC', SalesLineAISuggestionImpl.GetFeatureName(), Enum::"Feature Uptake Status"::"Set up", FeatureTelemetryCustomDimension);
            SalesLineAISuggestions.Run();
        end else begin
            ErrorTxt := StrSubstNo(SalesHeaderNotInitializedErr, SalesLine."Document Type");
            FeatureTelemetry.LogError('0000ME6', SalesLineAISuggestionImpl.GetFeatureName(), 'Get the source sales header', ErrorTxt);
            Error(ErrorTxt);
        end;
    end;

    [NonDebuggable]
    local procedure BuildIntentSystemPrompt(): SecretText
    var
        Prompt: Codeunit "SLS Prompts";
        IntentSystemPrompt: SecretText;
    begin
        IntentSystemPrompt := Prompt.GetSLSSystemPrompt();
        exit(IntentSystemPrompt);
    end;

    internal procedure GenerateSalesLineSuggestions(SearchQuery: Text; SearchStyle: Enum "Search Style"; SourceSalesHeader: Record "Sales Header"; var TempSalesLineAiSuggestion: Record "Sales Line AI Suggestions" temporary)
    begin
        AICall(BuildIntentSystemPrompt(), SearchQuery, SearchStyle, SourceSalesHeader, TempSalesLineAiSuggestion);
    end;

    [NonDebuggable]
    internal procedure AICall(SystemPromptTxt: SecretText; SearchQuery: Text; SearchStyle: Enum "Search Style"; SourceSalesHeader: Record "Sales Header"; var TempSalesLineAiSuggestion: Record "Sales Line AI Suggestions" temporary): Text
    var
        AzureOpenAI: Codeunit "Azure OpenAi";
        AOAIDeployments: Codeunit "AOAI Deployments";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIFunctionResponse: Codeunit "AOAI Function Response";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        DocumentLookup: Codeunit "Document Lookup Function";
        SearchItemsFunction: Codeunit "Search Items Function";
        MagicFunction: Codeunit "Magic Function";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        NotificationManager: Codeunit "Notification Manager";
        TelemetryCD: Dictionary of [Text, Text];
        StartDateTime: DateTime;
        DurationAsBigInt: BigInteger;
        EmptyArguments: JsonObject;
        CompletionAnswer: Text;
        ResponseErr: Label 'Response error code: %1', Comment = '%1 = Error code', Locked = true;
    begin
        if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"Sales Lines Suggestions") then
            exit;

        // Generate OpenAI Completion
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", AOAIDeployments.GetGPT4Latest());
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Sales Lines Suggestions");

        AOAIChatCompletionParams.SetMaxTokens(MaxTokens());
        AOAIChatCompletionParams.SetTemperature(0);

        SearchItemsFunction.SetSearchQuery(SearchQuery);
        SearchItemsFunction.SetSearchStyle(SearchStyle);
        DocumentLookup.SetSearchQuery(SearchQuery);
        DocumentLookup.SetSourceDocumentRecordId(SourceSalesHeader.RecordId);
        DocumentLookup.SetSearchStyle(SearchStyle);

        AOAIChatMessages.AddTool(MagicFunction);
        AOAIChatMessages.AddTool(SearchItemsFunction);
        AOAIChatMessages.AddTool(DocumentLookup);
        AOAIChatMessages.SetToolChoice('auto');

        AOAIChatMessages.SetPrimarySystemMessage(SystemPromptTxt);
        AOAIChatMessages.AddUserMessage(SearchQuery);

        StartDateTime := CurrentDateTime();
        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);
        DurationAsBigInt := CurrentDateTime() - StartDateTime;
        TelemetryCD.Add('Response time', Format(DurationAsBigInt));

        if AOAIOperationResponse.IsSuccess() then begin
            CompletionAnswer := AOAIOperationResponse.GetResult();
            if AOAIOperationResponse.IsFunctionCall() then begin
                AOAIFunctionResponse := AOAIOperationResponse.GetFunctionResponse();
                FeatureTelemetry.LogUsage('0000MED', GetFeatureName(), 'Call Chat Completion API', TelemetryCD);

                if AOAIFunctionResponse.IsSuccess() then
                    TempSalesLineAiSuggestion.Copy(AOAIFunctionResponse.GetResult(), true)
                else begin
                    MagicFunction.Execute(EmptyArguments);
                    FeatureTelemetry.LogError('0000ME9', GetFeatureName(), 'Process function_call', 'Function not supported, defaulting to magic_function');
                end
            end else begin
                if AOAIOperationResponse.GetResult() = '' then
                    FeatureTelemetry.LogError('0000ME8', GetFeatureName(), 'Call Chat Completion API', 'Completion answer is empty', '', TelemetryCD)
                else
                    FeatureTelemetry.LogError('0000MEA', GetFeatureName(), 'Process function_call', 'function_call not found in the completion answer');
                NotificationManager.SendNotification(ChatCompletionResponseErr);
            end;
        end else begin
            FeatureTelemetry.LogError('0000ME7', GetFeatureName(), 'Call Chat Completion API', StrSubstNo(ResponseErr, AOAIOperationResponse.GetStatusCode()), '', TelemetryCD);
            NotificationManager.SendNotification(ChatCompletionResponseErr);
        end;

        exit(CompletionAnswer);
    end;

    procedure CheckSupportedLanguages(): Boolean
    var
        LanguageSelection: Record "Language Selection";
        UserSessionSettings: SessionSettings;
    begin
        UserSessionSettings.Init();
        LanguageSelection.SetLoadFields("Language Tag");
        LanguageSelection.SetRange("Language ID", UserSessionSettings.LanguageId());
        if LanguageSelection.FindFirst() then
            if LanguageSelection."Language Tag".StartsWith('pt-') then
                exit(false);
        exit(true);
    end;

    procedure RegisterCapability()
    var
        CopilotCapability: Codeunit "Copilot Capability";
        EnvironmentInformation: Codeunit "Environment Information";
        DocUrlLbl: Label 'https://go.microsoft.com/fwlink/?linkid=2261665', Locked = true;
    begin
        if EnvironmentInformation.IsSaaSInfrastructure() then
            if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Sales Lines Suggestions") then
                CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Sales Lines Suggestions", DocUrlLbl);

    end;

    [EventSubscriber(ObjectType::Page, Page::"Copilot AI Capabilities", 'OnRegisterCopilotCapability', '', false, false)]
    local procedure OnRegisterCopilotCapability()
    begin
        RegisterCapability();
    end;
}