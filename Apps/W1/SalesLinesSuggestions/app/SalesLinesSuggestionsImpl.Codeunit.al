// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using System;
using System.AI;
using System.Telemetry;
using System.Environment;

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
    var
        CompletionAnswerTxt: Text;
    begin
        CompletionAnswerTxt := AICall(BuildIntentSystemPrompt(), SearchQuery);
        ProcessCompletionAnswer(CompletionAnswerTxt, SearchQuery, SearchStyle, SourceSalesHeader, TempSalesLineAiSuggestion);
    end;

    [NonDebuggable]
    internal procedure AICall(SystemPromptTxt: SecretText; SearchQuery: Text): Text
    var
        AzureOpenAI: Codeunit "Azure OpenAi";
        AOAIDeployments: Codeunit "AOAI Deployments";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
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
        CompletionAnswerTxt: Text;
        ResponseErr: Label 'Response error code: %1', Comment = '%1 = Error code', Locked = true;
    begin
        if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"Sales Lines Suggestions") then
            exit;

        // Generate OpenAI Completion
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", AOAIDeployments.GetGPT4Latest());
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Sales Lines Suggestions");

        AOAIChatCompletionParams.SetMaxTokens(MaxTokens());
        AOAIChatCompletionParams.SetTemperature(0);

        AOAIChatMessages.AddTool(MagicFunction.GetToolPrompt());
        AOAIChatMessages.AddTool(SearchItemsFunction.GetToolPrompt());
        AOAIChatMessages.AddTool(DocumentLookup.GetToolPrompt());
        AOAIChatMessages.SetToolChoice('auto');

        AOAIChatMessages.SetPrimarySystemMessage(SystemPromptTxt);
        AOAIChatMessages.AddUserMessage(SearchQuery);

        StartDateTime := CurrentDateTime();
        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);
        DurationAsBigInt := CurrentDateTime() - StartDateTime;
        TelemetryCD.Add('Response time', Format(DurationAsBigInt));

        if AOAIOperationResponse.IsSuccess() then begin
            CompletionAnswerTxt := AOAIOperationResponse.GetResult();
            if CompletionAnswerTxt = '' then begin
                FeatureTelemetry.LogError('0000ME8', GetFeatureName(), 'Call Chat Completion API', 'Completion answer is empty', '', TelemetryCD);
                NotificationManager.SendNotification(ChatCompletionResponseErr);
            end
            else
                FeatureTelemetry.LogUsage('0000MED', GetFeatureName(), 'Call Chat Completion API', TelemetryCD);
        end
        else begin
            FeatureTelemetry.LogError('0000ME7', GetFeatureName(), 'Call Chat Completion API', StrSubstNo(ResponseErr, AOAIOperationResponse.GetStatusCode()), '', TelemetryCD);
            NotificationManager.SendNotification(ChatCompletionResponseErr);
        end;

        exit(CompletionAnswerTxt);
    end;

    [NonDebuggable]
    local procedure ProcessCompletionAnswer(CompletionAnswerTxt: Text; SearchQuery: Text; SearchStyle: Enum "Search Style"; SourceSalesHeader: Record "Sales Header"; var TempSalesLineAiSuggestion: Record "Sales Line AI Suggestions" temporary)
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        NotificationManager: Codeunit "Notification Manager";
        CustomDimension: Dictionary of [Text, Text];
        AnswerJson: JsonObject;
        ArgumentJson: JsonObject;
        ToolsArrayToken: JsonToken;
        ToolType: JsonToken;
        Tool: JsonToken;
        Function: JsonToken;
        FunctionName: JsonToken;
        FunctionArgument: JsonToken;
        Tools: Interface SalesAzureOpenAITools;
        SupportedTools: Enum "Sales Supported Tools";
        Result: Variant;
    begin
        if CompletionAnswerTxt = '' then
            exit;

        AnswerJson.ReadFrom(CompletionAnswerTxt);
        CustomDimension.Add('SearchQuery', SearchQuery);
        CustomDimension.Add('SearchStyle', Format(SearchStyle));
        CustomDimension.Add('SourceDocumentRecordID', Format(SourceSalesHeader.RecordId));

        if AnswerJson.Get('tool_calls', ToolsArrayToken) then
            foreach Tool in ToolsArrayToken.AsArray() do begin
                Tool.AsObject().Get('type', ToolType);
                if ToolType.AsValue().asText() = 'function' then begin
                    Tool.AsObject().Get('function', Function);
                    Function.AsObject().Get('name', FunctionName);
                    Function.AsObject().Get('arguments', FunctionArgument);

                    if Evaluate(SupportedTools, FunctionName.AsValue().asText()) then
                        Tools := SupportedTools
                    else begin
                        Tools := SupportedTools::magic_function;
                        FeatureTelemetry.LogError('0000ME9', GetFeatureName(), 'Process function_call', 'Function not supported, defaulting to magic_function');
                    end;
                    ArgumentJson.ReadFrom(FunctionArgument.AsValue().AsText());
                    Result := Tools.ToolCall(ArgumentJson, CustomDimension);

                    if Result.IsRecord then
                        TempSalesLineAiSuggestion.Copy(Result, true);
                end;
                break;
            end
        else begin
            FeatureTelemetry.LogError('0000MEA', GetFeatureName(), 'Process function_call', 'function_call not found in the completion answer');
            NotificationManager.SendNotification(ChatCompletionResponseErr);
        end;
    end;

    procedure CheckSupportedApplicationFamily(): Boolean
    var
        EnvironmentInformation: Codeunit "Environment Information";
        ApplicationFamily: Text;
    begin
        ApplicationFamily := EnvironmentInformation.GetApplicationFamily();
        if ApplicationFamily = 'CA' then   //Disabled for Canada due to legal reasons
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
            if CheckSupportedApplicationFamily() then
                if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Sales Lines Suggestions") then
                    CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Sales Lines Suggestions", DocUrlLbl);

    end;

    [EventSubscriber(ObjectType::Page, Page::"Copilot AI Capabilities", 'OnRegisterCopilotCapability', '', false, false)]
    local procedure OnRegisterCopilotCapability()
    begin
        RegisterCapability();
    end;
}