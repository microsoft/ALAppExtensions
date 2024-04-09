// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using System;
using System.Telemetry;
using Microsoft.Inventory.Item;
using System.Security.Encryption;

codeunit 7282 "Search"
{
    Access = Internal;

    [TryFunction]
    internal procedure SearchMultiple(ItemResultsArray: JsonArray; SearchStyle: Enum "Search Style"; Intent: Text; SearchQuery: Text; Top: Integer; MaximumQueryResultsToRank: Integer; IncludeSynonyms: Boolean; UseContextAwareRanking: Boolean; var TempSalesLineAiSuggestion: Record "Sales Line AI Suggestions" temporary)
    var
        Item: Record "Item";
        TempSearchResponse: Record "Search API Response" temporary;
        FeatureTelemetry: Codeunit "Feature Telemetry";
        SalesLineAISuggestionImpl: Codeunit "Sales Lines Suggestions Impl.";
        CryptographyManagement: Codeunit "Cryptography Management";
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
        QuantityToken: JsonToken;
        NameJsonToken: JsonToken;
        SearchPrimaryKeyWords: List of [Text];
        SearchAdditionalKeyWords: List of [Text];
        Quantity: Decimal;
        TelemetryCD: Dictionary of [Text, Text];
        StartDateTime: DateTime;
        DurationAsBigInt: BigInteger;
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
        SearchItemNames: Text;
        ItemTokentText: Text;
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

        //Add Search Filters
        SearchFilter := SearchFilter.SearchFilter();
        SearchFilter.FieldNo := Item.FieldNo(Blocked);
        SearchFilter.Expression := Text.StrSubstNo('<> %1', true);
        ALSearchOptions.AddSearchFilter(SearchFilter);

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

        //Add Search Queries
        foreach ItemToken in ItemResultsArray do begin
            SearchPrimaryKeyWords := GetItemNameKeywords(ItemToken);
            SearchAdditionalKeyWords := GetItemFeaturesKeywords(ItemToken);
            ItemToken.AsObject().Get('name', NameJsonToken);
            ItemToken.WriteTo(ItemTokentText);
            SearchItemNames += NameJsonToken.AsValue().AsText() + ', ';

            BuildSearchQuery(SearchPrimaryKeyWords, SearchAdditionalKeyWords, CryptographyManagement.GenerateHash(ItemTokentText, HashAlgorithmType::SHA256), SearchStyle, Top, ALSearchQuery);
            ALSearchOptions.AddSearchQuery(ALSearchQuery);
        end;

        //Search Items
        SearchProgress.Open(StrSubstNo(SearchingItemsLbl, SearchItemNames.TrimEnd(', ')));
        StartDateTime := CurrentDateTime();
        ALSearchResult := ALSearch.FindItems(ALSearchOptions);
        SearchProgress.Close();
        DurationAsBigInt := (CurrentDateTime() - StartDateTime);
        TelemetryCD.Add('Response time', Format(DurationAsBigInt));
        FeatureTelemetry.LogUsage('0000MDW', SalesLineAISuggestionImpl.GetFeatureName(), 'FindItems', TelemetryCD);

        //Process Search Results
        foreach ItemToken in ItemResultsArray do begin
            ItemToken.WriteTo(ItemTokentText);
            if ItemToken.AsObject().Get('quantity', QuantityToken) then
                if (QuantityToken.IsValue() and (QuantityToken.AsValue().AsText() <> '')) then
                    Quantity := QuantityToken.AsValue().AsDecimal();

            QueryResults := ALSearchResult.GetResultsForQuery(CryptographyManagement.GenerateHash(ItemTokentText, HashAlgorithmType::SHA256));

            TempSearchResponse.DeleteAll();
            foreach ALSearchQueryResult in QueryResults do begin
                TempSearchResponse.Init();
                TempSearchResponse.SysId := ALSearchQueryResult.SystemId;
                TempSearchResponse.Score := ALSearchQueryResult.ContextAwareRankingScore;
                TempSearchResponse.Insert();

                SearchPrimaryKeyWords := GetItemNameKeywords(ItemToken);
                SearchAdditionalKeyWords := GetItemFeaturesKeywords(ItemToken);

                GetSalesLineFromItemSystemIds(TempSearchResponse, Quantity, TempSalesLineAiSuggestion, SearchPrimaryKeyWords, SearchAdditionalKeyWords);
            end;
        end;
    end;

    local procedure BuildSearchQuery(SearchPrimaryKeyWords: List of [Text]; SearchAdditionalKeyWords: List of [Text]; ItemNameHASH: Text; SearchStyle: Enum "Search Style"; Top: Integer; var ALSearchQuery: DotNet ALSearchQuery)
    var
        ALSearchMode: DotNet ALSearchMode;
        Keyword: Text;
    begin
        ALSearchQuery := ALSearchQuery.SearchQuery(ItemNameHASH);

        foreach Keyword in SearchPrimaryKeyWords do
            ALSearchQuery.AddRequiredTerm(Keyword);

        case SearchStyle of
            "Search Style"::Precise:
                foreach Keyword in SearchAdditionalKeyWords do
                    ALSearchQuery.AddRequiredTerm(Keyword);
            else
                foreach Keyword in SearchAdditionalKeyWords do
                    ALSearchQuery.AddOptionalTerm(Keyword);
        end;

        case SearchStyle of
            "Search Style"::Permissive:
                ALSearchQuery.Mode := ALSearchMode::Any;
            else
                ALSearchQuery.Mode := ALSearchMode::All;
        end;

        ALSearchQuery.Top := Top;
    end;

    local procedure GetSalesLineFromItemSystemIds(var TempSearchResponse: Record "Search API Response" temporary; Quantity: Decimal; var TempSalesLineAiSuggestion: Record "Sales Line AI Suggestions" temporary; var SearchPrimaryKeyWords: List of [Text];
        var SearchAdditionalKeyWords: List of [Text])
    var
        Item: Record "Item";
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

                    TempSalesLineAiSuggestion.Init();
                    LineNumber := LineNumber + 1;
                    TempSalesLineAiSuggestion."Line No." := LineNumber;
                    TempSalesLineAiSuggestion."No." := Item."No.";
                    TempSalesLineAiSuggestion.Description := Item.Description;
                    TempSalesLineAiSuggestion.Type := "Sales Line Type"::Item;
                    TempSalesLineAiSuggestion.Quantity := Quantity;
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
        if ItemObjectToken.AsObject().Get('name', JsonToken) then begin
            SearchKeyword := JsonToken.AsValue().AsText();
            if ItemObjectToken.AsObject().Get('synonyms', JsonToken) then begin
                JsonArray := JsonToken.AsArray();
                foreach JsonToken in JsonArray do
                    SearchKeyword := SearchKeyword + '|' + JsonToken.AsValue().AsText();
            end;
            SearchKeywords.Add(SearchKeyword);
        end;
        exit(SearchKeywords);
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
        if Score > 80 then
            exit("Search Confidence"::High);
        if Score > 50 then
            exit("Search Confidence"::Medium);
        if Score > 20 then
            exit("Search Confidence"::Low);

        exit("Search Confidence"::None);
    end;
}