// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using System.AI;
using System.Telemetry;

codeunit 7285 "Search Items Function" implements "AOAI Function"
{
    Access = Internal;

    var
        SearchQuery: Text;
        SearchStyle: Enum "Search Style";
        FunctionNameLbl: Label 'search_items', Locked = true;
        SearchItemsLbl: Label 'function_call: search_items', Locked = true;

    [NonDebuggable]
    procedure GetPrompt(): JsonObject
    var
        Prompt: Codeunit "SLS Prompts";
        PromptJson: JsonObject;
    begin
        PromptJson.ReadFrom(Prompt.GetSLSSearchItemPrompt().Unwrap());
        exit(PromptJson);
    end;

    [NonDebuggable]
    procedure Execute(Arguments: JsonObject): Variant
    var
        TempSalesLineAiSuggestion: Record "Sales Line AI Suggestions" temporary;
        SearchUtility: Codeunit "Search";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        SalesLineAISuggestionImpl: Codeunit "Sales Lines Suggestions Impl.";
        NotificationManager: Codeunit "Notification Manager";
        ItemsResults: JsonToken;
        ItemResultsArray: JsonArray;
        SearchIntentLbl: Label 'Add products to a sales order.', Locked = true;
    begin
        if Arguments.Get('results', ItemsResults) then begin
            ItemResultsArray := ItemsResults.AsArray();
            if SearchUtility.SearchMultiple(ItemResultsArray, SearchStyle, SearchIntentLbl, SearchQuery, 1, 25, false, true, TempSalesLineAiSuggestion, '') then begin
                FeatureTelemetry.LogUsage('0000ME2', SalesLineAISuggestionImpl.GetFeatureName(), SearchItemsLbl);
                if TempSalesLineAiSuggestion.Count = 0 then
                    NotificationManager.SendNotification(SalesLineAISuggestionImpl.GetNoSalesLinesSuggestionsMsg());
            end
            else begin
                FeatureTelemetry.LogError('0000ME1', SalesLineAISuggestionImpl.GetFeatureName(), SearchItemsLbl, 'Search API resulted in an error', GetLastErrorCallStack());
                NotificationManager.SendNotification(SalesLineAISuggestionImpl.GetChatCompletionResponseErr());
            end;
        end
        else begin
            FeatureTelemetry.LogError('0000ML5', SalesLineAISuggestionImpl.GetFeatureName(), 'Process Search Item', 'results not found in tools object.');
            NotificationManager.SendNotification(SalesLineAISuggestionImpl.GetChatCompletionResponseErr());
        end;

        exit(TempSalesLineAiSuggestion);
    end;

    procedure GetName(): Text
    begin
        exit(FunctionNameLbl);
    end;

    procedure SetSearchQuery(NewSearchQuery: Text)
    begin
        SearchQuery := NewSearchQuery;
    end;

    procedure SetSearchStyle(NewSearchStyle: Enum "Search Style")
    begin
        SearchStyle := NewSearchStyle;
    end;
}