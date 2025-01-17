// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using System;
using System.Telemetry;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Item;
using System.AI;

codeunit 7282 "Search"
{
    Access = Internal;

    [TryFunction]
    internal procedure SearchMultiple(ItemResultsArray: JsonArray; SearchStyle: Enum "Search Style"; Intent: Text; SearchQuery: Text; Top: Integer; MaximumQueryResultsToRank: Integer; IncludeSynonyms: Boolean; UseContextAwareRanking: Boolean; var TempSalesLineAiSuggestion: Record "Sales Line AI Suggestions" temporary; ItemNoFilter: Text)
    var
        Item: Record Item;
        TempSearchResponse: Record "Search API Response" temporary;
        FeatureTelemetry: Codeunit "Feature Telemetry";
        SalesLineAISuggestionImpl: Codeunit "Sales Lines Suggestions Impl.";
        ALCopilotCapability: DotNet ALCopilotCapability;
        ALSearch: DotNet ALSearch;
        ALSearchOptions: DotNet ALSearchOptions;
        ALSearchQuery: DotNet ALSearchQuery;
        ALSearchRankingContext: DotNet ALSearchRankingContext;
        ALSearchResult: DotNet ALSearchResult;
        SearchFilter: DotNet SearchFilter;
        QueryResults: DotNet GenericList1;
        ALSearchQueryResult: DotNet ALSearchQueryResult;
        SearchProgress: Dialog;
        ItemToken: JsonToken;
        ItemTokenForQueryIndex: JsonToken;
        ItemTokenForQueryIndexText: Text;
        QuantityToken: JsonToken;
        UOMToken: JsonToken;
        NameJsonToken: JsonToken;
        SearchPrimaryKeyWords: List of [Text];
        SearchAdditionalKeyWords: List of [Text];
        Quantity: Decimal;
        UnitOfMeasure: Text;
        TelemetryCD: Dictionary of [Text, Text];
        ItemTokenToItemSystemIdMap: Dictionary of [Text, Guid];
        ItemTokenToQueryIdMap: Dictionary of [Text, Integer];
        StartDateTime: DateTime;
        DurationAsBigInt: BigInteger;
        SearchItemNames: Text;
        CapabilityName: Text;
        i: Integer;
        CurrentModuleInfo: ModuleInfo;
        SearchSetupProgressLbl: Label 'Looking through item information';
        SearchingItemsLbl: Label 'Looking for items matching: %1', Comment = '%1= list of item names';
    begin
        if not ALSearch.IsItemSearchReady() then begin
            SearchProgress.Open(SearchSetupProgressLbl);
            while not ALSearch.IsItemSearchReady() do
                Sleep(3000);
            SearchProgress.Close();
        end;

        //Add ALSearch Options
        ALSearchOptions := ALSearchOptions.SearchOptions();
        ALSearchOptions.IncludeSynonyms := IncludeSynonyms;
        ALSearchOptions.UseContextAwareRanking := UseContextAwareRanking;

        //Add Search Queries
        for i := 0 to ItemResultsArray.Count() - 1 do begin
            ItemResultsArray.Get(i, ItemToken);
            ItemTokenForQueryIndex := ItemToken.Clone();

            SearchPrimaryKeyWords := GetItemNameKeywords(ItemToken);
            SearchAdditionalKeyWords := GetItemFeaturesKeywords(ItemToken);
            ItemToken.AsObject().Get('name', NameJsonToken);
            SearchItemNames += NameJsonToken.AsValue().AsText() + ', ';

            // Prepare ItemTokenForQueryIndex
            if ItemToken.AsObject().Get('quantity', QuantityToken) then
                ItemTokenForQueryIndex.AsObject().Remove('quantity');

            if ItemToken.AsObject().Get('unit_of_measure', UOMToken) then
                ItemTokenForQueryIndex.AsObject().Remove('unit_of_measure');

            ItemTokenForQueryIndex.AsObject().WriteTo(ItemTokenForQueryIndexText);

            // ItemTokenToItemNoMap has the priority over ItemTokenToQueryIdMap
            // If we can get the item uniquely by it's key fields, then we don't need to perform extensive search when there is ItemNoFilter, search style is Permissive or Balanced or no additional keywords are provided.
            // For example: "Yellow 1928-W" with precise search style will be searched using platform data search. 
            // Check if the items is already added to the ItemTokenToItemNoMap
            if (ItemNoFilter = '') and (StrLen(NameJsonToken.AsValue().AsText()) <= MaxStrLen(Item."No.")) and (((SearchStyle = "Search Style"::Balanced) or (SearchStyle = "Search Style"::Permissive) or (SearchAdditionalKeyWords.Count = 0))) then
                if not ItemTokenToItemSystemIdMap.ContainsKey(ItemTokenForQueryIndexText) then begin
                    Clear(Item);
                    Item.SetLoadFields(SystemId);
                    Item.ReadIsolation := IsolationLevel::ReadCommitted;
                    Item.SetRange("No.", NameJsonToken.AsValue().AsText());
                    Item.SetRange(Blocked, false);
                    Item.SetRange("Sales Blocked", false);

                    // Search only using key fields
                    if Item.FindFirst() then
                        ItemTokenToItemSystemIdMap.Add(ItemTokenForQueryIndexText, Item.SystemId);
                end;

            // Check if the item is already added to the ItemTokenToQueryIdMap
            if not ItemTokenToItemSystemIdMap.ContainsKey(ItemTokenForQueryIndexText) then
                if not ItemTokenToQueryIdMap.ContainsKey(ItemTokenForQueryIndexText) then begin
                    BuildSearchQuery(SearchPrimaryKeyWords, SearchAdditionalKeyWords, Format(i), SearchStyle, Top, ALSearchQuery);
                    ALSearchOptions.AddSearchQuery(ALSearchQuery);
                    ItemTokenToQueryIdMap.Add(ItemTokenForQueryIndexText, i);
                end;
        end;

        TelemetryCD.Add('No. of items fetched using FindFirst()', Format(ItemTokenToItemSystemIdMap.Count));
        TelemetryCD.Add('No. of items being searched using FindItems()', Format(ItemTokenToQueryIdMap.Count));
        FeatureTelemetry.LogUsage('0000NJG', SalesLineAISuggestionImpl.GetFeatureName(), 'Search for items', TelemetryCD);

        // Set properties for platform data search and search items
        if ItemTokenToQueryIdMap.Count > 0 then begin
            //Add Search Filters
            SearchFilter := SearchFilter.SearchFilter();
            SearchFilter.FieldNo := Item.FieldNo(Blocked);
            SearchFilter.Expression := Text.StrSubstNo('<> %1', true);
            ALSearchOptions.AddSearchFilter(SearchFilter);

            if ItemNoFilter <> '' then begin
                SearchFilter := SearchFilter.SearchFilter();
                SearchFilter.FieldNo := Item.FieldNo("No.");
                SearchFilter.Expression := Text.StrSubstNo('%1', ItemNoFilter);
                ALSearchOptions.AddSearchFilter(SearchFilter);
            end;
            SearchFilter := SearchFilter.SearchFilter();
            SearchFilter.FieldNo := Item.FieldNo("Sales Blocked");
            SearchFilter.Expression := Text.StrSubstNo('<> %1', true);
            ALSearchOptions.AddSearchFilter(SearchFilter);

            //Add Search Ranking Context
            if UseContextAwareRanking then begin
                ALSearchRankingContext := ALSearchRankingContext.SearchRankingContext();
                ALSearchRankingContext.Intent := Intent;
                ALSearchRankingContext.UserMessage := SearchQuery;
                ALSearchRankingContext.MaximumQueryResultsToRank := MaximumQueryResultsToRank;
                ALSearchOptions.RankingContext := ALSearchRankingContext;
            end;

            // Setup capability information
            NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
            CapabilityName := Enum::"Copilot Capability".Names().Get(Enum::"Copilot Capability".Ordinals().IndexOf(Enum::"Copilot Capability"::"Sales Lines Suggestions".AsInteger()));
            ALCopilotCapability := ALCopilotCapability.ALCopilotCapability(CurrentModuleInfo.Publisher(), CurrentModuleInfo.Id(), Format(CurrentModuleInfo.AppVersion()), CapabilityName);

            //Search Items using platform data search
            SearchProgress.Open(StrSubstNo(SearchingItemsLbl, SearchItemNames.TrimEnd(', ')));
            StartDateTime := CurrentDateTime();

            ALSearchResult := ALSearch.FindItems(ALSearchOptions, ALCopilotCapability);

            SearchProgress.Close();
            DurationAsBigInt := (CurrentDateTime() - StartDateTime);
            Clear(TelemetryCD);
            TelemetryCD.Add('Response time', Format(DurationAsBigInt));
            FeatureTelemetry.LogUsage('0000MDW', SalesLineAISuggestionImpl.GetFeatureName(), 'FindItems', TelemetryCD);
        end;

        //Process Search Results
        foreach ItemToken in ItemResultsArray do begin
            Quantity := 0;
            UnitOfMeasure := '';

            ItemTokenForQueryIndex := ItemToken.Clone();
            if ItemToken.AsObject().Get('quantity', QuantityToken) then begin
                ItemTokenForQueryIndex.AsObject().Remove('quantity');
                if (QuantityToken.IsValue() and (QuantityToken.AsValue().AsText() <> '')) then
                    if not JsonValueAsDecimal(QuantityToken.AsValue(), Quantity) then
                        Quantity := 0;
            end;

            if ItemToken.AsObject().Get('unit_of_measure', UOMToken) then begin
                ItemTokenForQueryIndex.AsObject().Remove('unit_of_measure');
                if (UOMToken.IsValue() and (UOMToken.AsValue().AsText() <> '')) then
                    UnitOfMeasure := UOMToken.AsValue().AsText();
            end;

            ItemTokenForQueryIndex.AsObject().WriteTo(ItemTokenForQueryIndexText);
            TempSearchResponse.DeleteAll();
            TempSearchResponse.Init();

            // Try to find the first from ItemTokenToItemNoMap and then ItemTokenToQueryIdMap
            if ItemTokenToItemSystemIdMap.ContainsKey(ItemTokenForQueryIndexText) then begin
                TempSearchResponse.SysId := ItemTokenToItemSystemIdMap.Get(ItemTokenForQueryIndexText);
                TempSearchResponse.Score := 1;
                TempSearchResponse.Insert();

                ItemToken.AsObject().Get('name', NameJsonToken);
                Clear(SearchPrimaryKeyWords);
                Clear(SearchAdditionalKeyWords);
                SearchPrimaryKeyWords.Add(NameJsonToken.AsValue().AsText());
            end
            else
                if ItemTokenToQueryIdMap.ContainsKey(ItemTokenForQueryIndexText) then begin
                    i := ItemTokenToQueryIdMap.Get(ItemTokenForQueryIndexText);
                    QueryResults := ALSearchResult.GetResultsForQuery(Format(i));

                    foreach ALSearchQueryResult in QueryResults do
                        if ALSearchQueryResult.ContextAwareRankingScore > 0.70 then begin
                            TempSearchResponse.SysId := ALSearchQueryResult.SystemId;
                            TempSearchResponse.Score := ALSearchQueryResult.ContextAwareRankingScore;
                            TempSearchResponse.Insert();

                            SearchPrimaryKeyWords := GetItemNameKeywords(ItemToken);
                            SearchAdditionalKeyWords := GetItemFeaturesKeywords(ItemToken);
                        end;
                end;
            GetSalesLineFromItemSystemIds(TempSearchResponse, Quantity, UnitOfMeasure, TempSalesLineAiSuggestion, SearchPrimaryKeyWords, SearchAdditionalKeyWords);
        end;
    end;

    local procedure BuildSearchQuery(SearchPrimaryKeyWords: List of [Text]; SearchAdditionalKeyWords: List of [Text]; QueryId: Text; SearchStyle: Enum "Search Style"; Top: Integer; var ALSearchQuery: DotNet ALSearchQuery)
    var
        ALSearchMode: DotNet ALSearchMode;
        Keyword: Text;
    begin
        ALSearchQuery := ALSearchQuery.SearchQuery(QueryId);

        foreach Keyword in SearchPrimaryKeyWords do
            ALSearchQuery.AddRequiredTerm(Keyword.ToLower());

        case SearchStyle of
            "Search Style"::Precise:
                foreach Keyword in SearchAdditionalKeyWords do
                    ALSearchQuery.AddRequiredTerm(Keyword.ToLower());
            else
                foreach Keyword in SearchAdditionalKeyWords do
                    ALSearchQuery.AddOptionalTerm(Keyword.ToLower());
        end;

        case SearchStyle of
            "Search Style"::Permissive:
                ALSearchQuery.Mode := ALSearchMode::Any;
            else
                ALSearchQuery.Mode := ALSearchMode::All;
        end;

        ALSearchQuery.Top := Top;
    end;

    local procedure GetSalesLineFromItemSystemIds(var TempSearchResponse: Record "Search API Response" temporary; Quantity: Decimal; UnitOfMeasureText: Text; var TempSalesLineAiSuggestion: Record "Sales Line AI Suggestions" temporary; var SearchPrimaryKeyWords: List of [Text];
        var SearchAdditionalKeyWords: List of [Text])
    var
        Item: Record "Item";
        UnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        UnitOfMeasureCode: Code[10];
        LineNumber: Integer;
    begin

        if not TempSalesLineAiSuggestion.FindLast() then
            LineNumber := 1
        else
            LineNumber := TempSalesLineAiSuggestion."Line No.";

        Item.SetLoadFields("No.", "Description", "Base Unit of Measure");
        if TempSearchResponse.FindSet() then
            repeat
                if Item.GetBySystemId(TempSearchResponse.SysId) then begin
                    Item.SetRecFilter();

                    UnitOfMeasureCode := Item."Sales Unit of Measure";
                    if UnitOfMeasureCode = '' then
                        UnitOfMeasureCode := Item."Base Unit of Measure";
                    UnitOfMeasure.SetRange(Description, UnitOfMeasureText);
                    if UnitOfMeasure.FindFirst() then begin
                        ItemUnitOfMeasure.SetRange("Item No.", Item."No.");
                        ItemUnitOfMeasure.SetRange(Code, UnitOfMeasure.Code);
                        if ItemUnitOfMeasure.FindFirst() then
                            UnitOfMeasureCode := ItemUnitOfMeasure.Code;
                    end;

                    TempSalesLineAiSuggestion.Init();
                    LineNumber := LineNumber + 1;
                    TempSalesLineAiSuggestion."Line No." := LineNumber;
                    TempSalesLineAiSuggestion."No." := Item."No.";
                    TempSalesLineAiSuggestion.Description := Item.Description;
                    TempSalesLineAiSuggestion.Type := "Sales Line Type"::Item;
                    TempSalesLineAiSuggestion.Quantity := Quantity;
                    TempSalesLineAiSuggestion."Unit of Measure Code" := UnitOfMeasureCode;
                    TempSalesLineAiSuggestion.Confidence := GetConfidence(TempSearchResponse.Score);
                    TempSalesLineAiSuggestion.SetPrimarySearchTerms(SearchPrimaryKeyWords);
                    TempSalesLineAiSuggestion.SetAdditionalSearchTerms(SearchAdditionalKeyWords);
                    TempSalesLineAiSuggestion.Insert();
                end;
            until TempSearchResponse.Next() = 0;
    end;

    local procedure GetItemNameKeywords(ItemObjectToken: JsonToken): List of [Text]
    var
        JsonToken: JsonToken;
        JsonArray: JsonArray;
        SearchKeywords: List of [Text];
        SearchKeyword: Text;
    begin
        if ItemObjectToken.AsObject().Get('split_name_terms', JsonToken) then begin
            JsonArray := JsonToken.AsArray();
            foreach JsonToken in JsonArray do begin
                SearchKeyword := '(' + JsonToken.AsValue().AsText() + AddSynonyms(ItemObjectToken);
                if ItemObjectToken.AsObject().Get('origin_name', JsonToken) then
                    if (JsonToken.AsValue().AsText() <> '') then
                        SearchKeyword := SearchKeyword + '|(' + JsonToken.AsValue().AsText() + ')';
                SearchKeywords.Add(SearchKeyword);
            end;
        end;
        exit(SearchKeywords);
    end;

    local procedure AddSynonyms(ItemObjectToken: JsonToken): Text
    var
        JsonToken: JsonToken;
        JsonArray: JsonArray;
        Synonyms: Text;
    begin
        if ItemObjectToken.AsObject().Get('common_synonyms_of_name_terms', JsonToken) then begin
            JsonArray := JsonToken.AsArray();
            foreach JsonToken in JsonArray do
                Synonyms += '|' + JsonToken.AsValue().AsText();
        end;
        exit(Synonyms + ')');
    end;

    local procedure GetItemFeaturesKeywords(ItemObjectToken: JsonToken): List of [Text]
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

    local procedure GetConfidence(Score: Decimal): Enum "Search Confidence"
    begin
        if Score > 0.81 then
            exit("Search Confidence"::High);
        if Score > 0.75 then
            exit("Search Confidence"::Medium);
        if Score > 0.70 then
            exit("Search Confidence"::Low);

        exit("Search Confidence"::None);
    end;

    [TryFunction]
    local procedure JsonValueAsDecimal(JsonValue: JsonValue; var Value: Decimal)
    begin
        Value := JsonValue.AsDecimal();
    end;
}