// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using System;
using System.AI;
using System.Telemetry;
using System.Environment;
using Microsoft.Sales.Document.Attachment;

codeunit 7275 "Sales Lines Suggestions Impl."
{
    Access = Internal;

    var
        ChatCompletionResponseErr: Label 'Sorry, something went wrong. Please rephrase and try again.';
        NoSalesLinesSuggestionsMsg: Label 'There are no suggestions for this description. Please rephrase it.';
        UnknownDocTypeMsg: Label 'Copilot does not support the specified document type. Please rephrase the description.';
        DocumentNotFoundMsg: Label 'Copilot could not find the document. Please rephrase the description.';
        ItemNotFoundMsg: Label 'Copilot could not find the requsted items. Please rephrase the description.';
        CopyFromMultipleDocsMsg: Label 'You cannot copy lines from more than one document. Please rephrase the description.';
        SalesHeaderNotInitializedErr: Label '%1 header is not initialized', Comment = '%1 = Document Type';


    internal procedure GetFeatureName(): Text
    begin
        exit('Sales Lines Suggestions');
    end;

    internal procedure GetChatCompletionResponseErr(): Text
    begin
        exit(ChatCompletionResponseErr);
    end;

    internal procedure GetNoSalesLinesSuggestionsMsg(): Text
    begin
        exit(NoSalesLinesSuggestionsMsg);
    end;

    internal procedure GetUnknownDocTypeMsg(): Text
    begin
        exit(UnknownDocTypeMsg);
    end;

    internal procedure GetDocumentNotFoundMsg(): Text
    begin
        exit(DocumentNotFoundMsg);
    end;

    internal procedure GetItemNotFoundMsg(): Text
    begin
        exit(ItemNotFoundMsg);
    end;

    internal procedure GetCopyFromMultipleDocsMsg(): Text
    begin
        exit(CopyFromMultipleDocsMsg);
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
        SearchItemsWithFiltersFunc: Codeunit "Search Items With Filters Func";
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

        SearchItemsWithFiltersFunc.SetSearchQuery(SearchQuery);
        SearchItemsWithFiltersFunc.SetSourceDocumentRecordId(SourceSalesHeader.RecordId);
        SearchItemsWithFiltersFunc.SetSearchStyle(SearchStyle);

        AOAIChatMessages.AddTool(MagicFunction);
        AOAIChatMessages.AddTool(SearchItemsWithFiltersFunc);
        AOAIChatMessages.SetToolChoice('auto');

        AOAIChatMessages.SetPrimarySystemMessage(SystemPromptTxt);
        AOAIChatMessages.AddUserMessage(SearchQuery);

        StartDateTime := CurrentDateTime();
        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);
        DurationAsBigInt := CurrentDateTime() - StartDateTime;
        TelemetryCD.Add('Response time', Format(DurationAsBigInt));

        if AOAIOperationResponse.IsSuccess() then begin
            CompletionAnswer := AOAIOperationResponse.GetResult();
            if AOAIOperationResponse.IsFunctionCall() then
                foreach AOAIFunctionResponse in AOAIOperationResponse.GetFunctionResponses() do begin
                    FeatureTelemetry.LogUsage('0000MED', GetFeatureName(), 'Call Chat Completion API', TelemetryCD);

                    if (not AOAIFunctionResponse.IsSuccess()) or (AOAIFunctionResponse.GetFunctionName() = MagicFunction.GetName()) then begin
                        MagicFunction.Execute(EmptyArguments);
                        FeatureTelemetry.LogError('0000ME9', GetFeatureName(), 'Process function_call', 'Function not supported, defaulting to magic_function');
                        Clear(TempSalesLineAiSuggestion);
                        exit(CompletionAnswer);
                    end else
                        TempSalesLineAiSuggestion.Copy(AOAIFunctionResponse.GetResult(), true);
                end
            else begin
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

    [NonDebuggable]
    internal procedure AICall(SystemPromptTxt: SecretText; SearchQuery: Text; AOAIFunction: interface "AOAI Function"; var CompletionAnswer: Text): Variant
    var
        AzureOpenAI: Codeunit "Azure OpenAi";
        AOAIDeployments: Codeunit "AOAI Deployments";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIFunctionResponse: Codeunit "AOAI Function Response";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        MagicFunction: Codeunit "Magic Function";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        NotificationManager: Codeunit "Notification Manager";
        FileHandlerResult: Codeunit "File Handler Result";
        FunctionResponseVariant: Variant;
        TelemetryCD: Dictionary of [Text, Text];
        StartDateTime: DateTime;
        DurationAsBigInt: BigInteger;
        EmptyArguments: JsonObject;
        ResponseTelemetryErr: Label 'Response error code: %1', Comment = '%1 = Error code', Locked = true;
    begin
        if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"Sales Lines Suggestions") then
            exit;

        // Generate OpenAI Completion
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", AOAIDeployments.GetGPT4Latest());
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Sales Lines Suggestions");

        AOAIChatCompletionParams.SetMaxTokens(MaxTokens());
        AOAIChatCompletionParams.SetTemperature(0);

        AOAIChatMessages.AddTool(MagicFunction);
        AOAIChatMessages.AddTool(AOAIFunction);
        AOAIChatMessages.SetToolChoice('auto');

        AOAIChatMessages.SetPrimarySystemMessage(SystemPromptTxt);
        AOAIChatMessages.AddUserMessage(SearchQuery);

        StartDateTime := CurrentDateTime();
        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);
        DurationAsBigInt := CurrentDateTime() - StartDateTime;
        TelemetryCD.Add('Response time', Format(DurationAsBigInt));

        if AOAIOperationResponse.IsSuccess() then begin
            CompletionAnswer := AOAIOperationResponse.GetResult();
            if AOAIOperationResponse.IsFunctionCall() then
                foreach AOAIFunctionResponse in AOAIOperationResponse.GetFunctionResponses() do begin
                    FeatureTelemetry.LogUsage('0000MZC', GetFeatureName(), 'Call Chat Completion API', TelemetryCD);

                    if AOAIFunctionResponse.IsSuccess() then begin
                        FunctionResponseVariant := AOAIFunctionResponse.GetResult();
                        if FunctionResponseVariant.IsCodeunit() then
                            FileHandlerResult := AOAIFunctionResponse.GetResult()
                        else begin
                            MagicFunction.Execute(EmptyArguments);
                            FeatureTelemetry.LogError('0000N6J', GetFeatureName(), 'Process function_call', 'Function not supported, defaulting to magic_function');
                            Clear(FileHandlerResult);
                            exit(FileHandlerResult);
                        end;
                    end else begin
                        MagicFunction.Execute(EmptyArguments);
                        FeatureTelemetry.LogError('0000MZ8', GetFeatureName(), 'Process function_call', 'Function not supported, defaulting to magic_function');
                        Clear(FileHandlerResult);
                        exit(FileHandlerResult);
                    end
                end
            else begin
                if AOAIOperationResponse.GetResult() = '' then
                    FeatureTelemetry.LogError('0000MZ9', GetFeatureName(), 'Call Chat Completion API', 'Completion answer is empty', '', TelemetryCD)
                else
                    FeatureTelemetry.LogError('0000MZA', GetFeatureName(), 'Process function_call', 'function_call not found in the completion answer');
                NotificationManager.SendNotification(ChatCompletionResponseErr);
            end;
        end else begin
            FeatureTelemetry.LogError('0000MZB', GetFeatureName(), 'Call Chat Completion API', StrSubstNo(ResponseTelemetryErr, AOAIOperationResponse.GetStatusCode()), '', TelemetryCD);
            NotificationManager.SendNotification(ChatCompletionResponseErr);
        end;

        exit(FileHandlerResult);
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