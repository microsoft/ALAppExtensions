// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.Inventory.Item;
using System.AI;

codeunit 4596 "SOA Broader Item Search"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    internal procedure BroaderItemSearch(var ItemFilter: Text; SearchFilter: Text)
    var
        BroaderItemSearchFunc: Codeunit "SOA Broader Item Search Func";
        ExtractedItemEntities: JsonArray;
        SearchQuery: Text;
        IncludeSynonyms: Boolean;
        UseContextAwareRanking: Boolean;
        MaximumQueryResultsToRank: Integer;
        Top: Integer;
    begin
        if AICall(BroaderItemSearchFunc, BuildBroaderItemSearchSystemPrompt(), ItemFilter, SearchFilter) then begin
            BroaderItemSearchFunc.GetSearchParameters(ExtractedItemEntities, SearchQuery, IncludeSynonyms, UseContextAwareRanking, MaximumQueryResultsToRank, Top);

            OnAfterBroaderSearchLog(ItemFilter, ExtractedItemEntities, SearchQuery, IncludeSynonyms, UseContextAwareRanking, MaximumQueryResultsToRank, Top);
        end;
    end;

    [NonDebuggable]
    [TryFunction]
    local procedure AICall(var BroaderItemSearchFunc: Codeunit "SOA Broader Item Search Func"; SystemPromptTxt: SecretText; var ItemFilter: Text; SearchFilter: Text)
    var
        AzureOpenAI: Codeunit "Azure OpenAi";
        AOAIDeployments: Codeunit "AOAI Deployments";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIFunctionResponse: Codeunit "AOAI Function Response";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        CompletionAnswer: Text;
    begin
        // Generate OpenAI Completion
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", AOAIDeployments.GetGPT41Latest());
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Sales Order Agent");

        AOAIChatCompletionParams.SetMaxTokens(MaxTokens());
        AOAIChatCompletionParams.SetTemperature(0);

        BroaderItemSearchFunc.SetSearchQuery(SearchFilter);
        AOAIChatMessages.AddTool(BroaderItemSearchFunc);

        AOAIChatMessages.SetPrimarySystemMessage(SystemPromptTxt);
        AOAIChatMessages.AddUserMessage(SearchFilter);

        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);
        if AOAIOperationResponse.IsSuccess() then begin
            CompletionAnswer := AOAIOperationResponse.GetResult();
            if AOAIOperationResponse.IsFunctionCall() then
                foreach AOAIFunctionResponse in AOAIOperationResponse.GetFunctionResponses() do
                    ItemFilter := BroaderItemSearchFunc.Execute(AOAIFunctionResponse.GetArguments());
        end;
    end;

    [NonDebuggable]
    local procedure BuildBroaderItemSearchSystemPrompt(): SecretText
    var
        SOAInstructions: Codeunit "SOA Instructions";
        BroaderItemSearchSystemPrompt: SecretText;
    begin
        BroaderItemSearchSystemPrompt := SOAInstructions.GetBroaderItemSearchSystemPrompt();
        exit(BroaderItemSearchSystemPrompt);
    end;

    [TryFunction]
    internal procedure SearchBroader(ItemResultsArray: JsonArray; SearchQuery: Text; Top: Integer; MaximumQueryResultsToRank: Integer; IncludeSynonyms: Boolean; UseContextAwareRanking: Boolean; var ItemFilter: Text)
    var
        Item: Record "Item";
        GlobalItemSearch: Codeunit "Global Item Search";
        ItemToken: JsonToken;
        SearchAdditionalKeyWords: List of [Text];
        SearchPrimaryKeyWords: List of [Text];
    begin
        GlobalItemSearch.InitializeSearchOptionsObject(IncludeSynonyms, UseContextAwareRanking);
        GlobalItemSearch.AddSearchFilter(Item.FieldNo(Blocked), Text.StrSubstNo('<> %1', true));
        GlobalItemSearch.AddSearchFilter(Item.FieldNo("Sales Blocked"), Text.StrSubstNo('<> %1', true));
        if UseContextAwareRanking then
            GlobalItemSearch.AddSearchRankingContext(SearchQuery, '', MaximumQueryResultsToRank);
        GlobalItemSearch.SetupSOACapabilityInformation();

        //Add Search Queries
        ItemResultsArray.Get(0, ItemToken);
        SearchPrimaryKeyWords.Add(GetMandatoryKeyword(ItemToken));
        SearchAdditionalKeyWords := GetOptionalKeywords(ItemToken);
        GlobalItemSearch.SetupSearchQuery(SearchPrimaryKeyWords.Get(1), SearchPrimaryKeyWords, SearchAdditionalKeyWords, true, Top);

        //Search Items using platform data search
        ItemFilter := GlobalItemSearch.SearchAndReturnResultAsTxt(SearchPrimaryKeyWords.Get(1), 0.79, '|');
    end;

    local procedure GetMandatoryKeyword(ItemObjectToken: JsonToken) SearchKeyword: Text
    var
        JsonToken: JsonToken;
    begin
        if ItemObjectToken.AsObject().Get('item_name', JsonToken) then
            SearchKeyword := '(' + JsonToken.AsValue().AsText() + AddSynonyms(ItemObjectToken) + AddConcatenatedKeyword(ItemObjectToken) + AddPluralItemName(ItemObjectToken) + ')';
    end;

    local procedure AddSynonyms(ItemObjectToken: JsonToken): Text
    var
        JsonToken: JsonToken;
        JsonArray: JsonArray;
        Synonyms: Text;
    begin
        if ItemObjectToken.AsObject().Get('synonyms', JsonToken) then begin
            JsonArray := JsonToken.AsArray();
            foreach JsonToken in JsonArray do
                Synonyms += '|' + JsonToken.AsValue().AsText();
        end;
        exit(Synonyms);
    end;

    local procedure AddConcatenatedKeyword(ItemObjectToken: JsonToken): Text
    var
        JsonToken: JsonToken;
        ConcatenatedKeyword: Text;
    begin
        if not ItemObjectToken.AsObject().Get('concatenated_keyword', JsonToken) then
            exit('');

        if JsonToken.AsValue().IsNull() then
            exit('');

        ConcatenatedKeyword := JsonToken.AsValue().AsText();
        if ConcatenatedKeyword = '' then
            exit('');

        ConcatenatedKeyword := '|' + ConcatenatedKeyword;
        exit(ConcatenatedKeyword);
    end;

    local procedure AddPluralItemName(ItemObjectToken: JsonToken): Text
    var
        JsonToken: JsonToken;
        PluralItemName: Text;
    begin
        if ItemObjectToken.AsObject().Get('item_name_plural', JsonToken) then begin
            PluralItemName := JsonToken.AsValue().AsText();
            if PluralItemName <> '' then
                PluralItemName := '|' + PluralItemName;
        end;
        exit(PluralItemName);
    end;

    local procedure GetOptionalKeywords(ItemObjectToken: JsonToken): List of [Text]
    var
        JsonToken: JsonToken;
        JsonArray: JsonArray;
        SearchKeywords: List of [Text];
    begin
        if ItemObjectToken.AsObject().Get('features', JsonToken) then begin
            JsonArray := JsonToken.AsArray();
            foreach JsonToken in JsonArray do
                SearchKeywords.Add(JsonToken.AsValue().AsText());
        end;
        exit(SearchKeywords);
    end;

    local procedure MaxTokens(): Integer
    begin
        exit(4096);
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterBroaderSearchLog(ItemFilter: Text; ItemResultsArray: JsonArray; SearchQuery: Text; IncludeSynonyms: Boolean; UseContextAwareRanking: Boolean; MaximumQueryResultsToRank: Integer; Top: Integer)
    begin
    end;
}