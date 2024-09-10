// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item.Substitution;

using System.AI;
using System.Telemetry;
using System;
using Microsoft.Inventory.Item;

codeunit 7330 "Item Subst. Suggestion Impl."
{
    Access = Internal;

    var
        ItemSubstSuggestUtility: Codeunit "Create Product Info. Utility";
        ItemNotFoundErr: Label 'Item not found';
        NoSuggestionsMsg: Label 'There are no suggestions for this description. Please rephrase it.';
        ResponseErr: Label 'Response error code: %1', Comment = '%1 = Error code', Locked = true;

    internal procedure GetFeatureName(): Text
    begin
        exit('Item Substitution Suggestions');
    end;

    internal procedure GetNoItemSubstSuggestionsMsg(): Text
    begin
        exit(NoSuggestionsMsg);
    end;

    internal procedure GetItemSubstitutionSuggestion(var ItemSubstitution: Record "Item Substitution")
    var
        Item: Record Item;
        AzureOpenAI: Codeunit "Azure OpenAI";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        ItemSubstSuggestions: Page "Item Subst. Suggestion";
        ALSearch: DotNet ALSearch;
        FeatureTelemetryCustomDimension: Dictionary of [Text, Text];
    begin
        if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"Create Product Information") then
            exit;

        FeatureTelemetry.LogUptake('0000N2X', GetFeatureName(), Enum::"Feature Uptake Status"::Discovered, FeatureTelemetryCustomDimension);

        if not ALSearch.IsItemSearchReady() then
            ALSearch.EnableItemSearch();

        if Item.Get(ItemSubstitution.GetFilter("No.")) then begin
            Item.TestField(Description);
            ItemSubstSuggestions.SetItem(Item);
            FeatureTelemetry.LogUptake('0000N2Y', GetFeatureName(), Enum::"Feature Uptake Status"::"Set up", FeatureTelemetryCustomDimension);
            ItemSubstSuggestions.RunModal();
        end else begin
            FeatureTelemetry.LogError('0000N2S', GetFeatureName(), 'Get the item', ItemNotFoundErr);
            Error(ItemNotFoundErr);
        end;
    end;

    [NonDebuggable]
    local procedure BuildIntentSystemPrompt(): SecretText
    var
        ItemSubstPrompts: Codeunit "Create Product Info. Prompts";
    begin
        exit(ItemSubstPrompts.GetSuggestSubstitutionsSystemPrompt());
    end;

    internal procedure GenerateItemSubstitutionSuggestions(SearchQuery: Text; SearchStyle: Enum "Search Style"; ItemType: Enum "Item Type"; ItemNoFilter: Text; var TempItemSubst: Record "Item Substitution" temporary)
    begin
        AICall(BuildIntentSystemPrompt(), SearchQuery, SearchStyle, ItemType, ItemNoFilter, TempItemSubst);
    end;

    [NonDebuggable]
    internal procedure AICall(SystemPromptTxt: SecretText; SearchQuery: Text; SearchStyle: Enum "Search Style"; ItemType: Enum "Item Type"; ItemNoFilter: Text; var TempItemSubst: Record "Item Substitution" temporary): Text
    var
        AzureOpenAI: Codeunit "Azure OpenAi";
        AOAIDeployments: Codeunit "AOAI Deployments";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIFunctionResponse: Codeunit "AOAI Function Response";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        SuggestSubstitutionsFunction: Codeunit "Suggest Substitutions Function";
        MagicFunction: Codeunit "Magic Function";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        NotificationManager: Codeunit "Notification Manager";
        CreateProductInfoUtility: Codeunit "Create Product Info. Utility";
        TelemetryCD: Dictionary of [Text, Text];
        StartDateTime: DateTime;
        DurationAsBigInt: BigInteger;
        CompletionAnswer: Text;
        EmptyArguments: JsonObject;
    begin
        if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"Create Product Information") then
            exit;

        // Generate OpenAI Completion
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", AOAIDeployments.GetGPT4Preview());
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Create Product Information");

        AOAIChatCompletionParams.SetMaxTokens(ItemSubstSuggestUtility.GetMaxTokens());
        AOAIChatCompletionParams.SetTemperature(0);

        SuggestSubstitutionsFunction.SetItemType(ItemType);
        SuggestSubstitutionsFunction.SetSearchQuery(SearchQuery);
        SuggestSubstitutionsFunction.SetSearchStyle(SearchStyle);
        SuggestSubstitutionsFunction.SetItemNoFilter(ItemNoFilter);

        AOAIChatMessages.AddTool(MagicFunction);
        AOAIChatMessages.AddTool(SuggestSubstitutionsFunction);
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
                    FeatureTelemetry.LogUsage('0000N2Z', GetFeatureName(), 'Call Chat Completion API', TelemetryCD);

                    if (not AOAIFunctionResponse.IsSuccess()) or (AOAIFunctionResponse.GetFunctionName() = MagicFunction.GetName()) then begin
                        MagicFunction.Execute(EmptyArguments);
                        FeatureTelemetry.LogError('0000N2T', GetFeatureName(), 'Process function_call', 'Function not supported, defaulting to magic_function');
                        Clear(TempItemSubst);
                        exit(CompletionAnswer);
                    end else
                        TempItemSubst.Copy(AOAIFunctionResponse.GetResult(), true)
                end
            else begin
                if AOAIOperationResponse.GetResult() = '' then
                    FeatureTelemetry.LogError('0000N2U', GetFeatureName(), 'Call Chat Completion API', 'Completion answer is empty', '', TelemetryCD)
                else
                    FeatureTelemetry.LogError('0000N2V', GetFeatureName(), 'Process function_call', 'function_call not found in the completion answer');
                NotificationManager.SendNotification(CreateProductInfoUtility.GetChatCompletionResponseErr());
            end;
        end else begin
            FeatureTelemetry.LogError('0000N2W', GetFeatureName(), 'Call Chat Completion API', StrSubstNo(ResponseErr, AOAIOperationResponse.GetStatusCode()), '', TelemetryCD);
            NotificationManager.SendNotification(CreateProductInfoUtility.GetChatCompletionResponseErr());
        end;

        exit(CompletionAnswer);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Copilot AI Capabilities", 'OnRegisterCopilotCapability', '', false, false)]
    local procedure OnRegisterCopilotCapability()
    begin
        ItemSubstSuggestUtility.RegisterCapability();
    end;
}