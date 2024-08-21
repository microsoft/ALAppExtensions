// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item.Substitution;

using System.AI;
using System.Telemetry;
using Microsoft.Inventory.Item;

codeunit 7342 "Suggest Substitutions Function" implements "AOAI Function"
{
    Access = Internal;

    var
        SearchQuery: Text;
        ItemNoFilter: Text;
        SearchStyle: Enum "Search Style";
        ItemType: Enum "Item Type";
        FunctionNameLbl: Label 'suggest_substitutions', Locked = true;
        SuggestSubstitutionsLbl: Label 'function_call: suggest_substitutions', Locked = true;
        SearchIntentLbl: Label 'Suggesting Item Substitutions.', Locked = true;

    [NonDebuggable]
    procedure GetPrompt(): JsonObject
    var
        ItemSubstPrompts: Codeunit "Create Product Info. Prompts";
        PromptJson: JsonObject;
    begin
        PromptJson.ReadFrom(ItemSubstPrompts.GetSuggestSubstitutionsPrompt());
        exit(PromptJson);
    end;

    [NonDebuggable]
    procedure Execute(Arguments: JsonObject): Variant
    var
        TempItemSubst: Record "Item Substitution" temporary;
        SearchUtility: Codeunit "Search";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        ItemSubstSuggestionsImpl: Codeunit "Item Subst. Suggestion Impl.";
        CreateProductInfoUtility: Codeunit "Create Product Info. Utility";
        NotificationManager: Codeunit "Notification Manager";
        ItemsResults: JsonToken;
        ItemResultsArray: JsonArray;
    begin
        if Arguments.Get('results', ItemsResults) then begin
            ItemResultsArray := ItemsResults.AsArray();
            if SearchUtility.SearchMultiple(ItemResultsArray, SearchStyle, SearchIntentLbl, SearchQuery, 0, 25, false, true, TempItemSubst, ItemNoFilter, ItemType) then begin
                TempItemSubst.SetRange(Confidence, "Search Confidence"::None);
                if TempItemSubst.FindSet() then
                    TempItemSubst.DeleteAll();
                TempItemSubst.Reset();

                FeatureTelemetry.LogUsage('0000N34', CreateProductInfoUtility.GetFeatureName(), SuggestSubstitutionsLbl);
                if TempItemSubst.Count = 0 then
                    NotificationManager.SendNotification(ItemSubstSuggestionsImpl.GetNoItemSubstSuggestionsMsg());
            end else begin
                FeatureTelemetry.LogError('0000N32', CreateProductInfoUtility.GetFeatureName(), SuggestSubstitutionsLbl, 'Search API resulted in an error', GetLastErrorCallStack());
                NotificationManager.SendNotification(CreateProductInfoUtility.GetChatCompletionResponseErr());
            end;
        end else begin
            FeatureTelemetry.LogError('0000N33', CreateProductInfoUtility.GetFeatureName(), 'Process Suggest Substitutions', 'results not found in tools object.');
            NotificationManager.SendNotification(CreateProductInfoUtility.GetChatCompletionResponseErr());
        end;
        exit(TempItemSubst);
    end;

    procedure GetName(): Text
    begin
        exit(FunctionNameLbl);
    end;

    procedure SetSearchQuery(NewSearchQuery: Text)
    begin
        SearchQuery := NewSearchQuery;
    end;

    procedure SetItemType(NewItemType: Enum "Item Type")
    begin
        ItemType := NewItemType;
    end;

    procedure SetSearchStyle(NewSearchStyle: Enum "Search Style")
    begin
        SearchStyle := NewSearchStyle;
    end;

    procedure SetItemNoFilter(NewItemNoFilter: Text)
    begin
        ItemNoFilter := NewItemNoFilter;
    end;
}