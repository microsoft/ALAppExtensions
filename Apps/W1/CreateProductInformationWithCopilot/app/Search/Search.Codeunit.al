// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item.Substitution;

using System;
using System.Telemetry;
using Microsoft.Inventory.Item;
using System.Security.Encryption;
using System.AI;

codeunit 7333 "Search"
{
    Access = Internal;

    [TryFunction]
    internal procedure SearchMultiple(ItemResultsArray: JsonArray; SearchStyle: Enum "Search Style"; Intent: Text; SearchQuery: Text; Top: Integer; MaximumQueryResultsToRank: Integer; IncludeSynonyms: Boolean; UseContextAwareRanking: Boolean; var TempItemSubst: Record "Item Substitution" temporary; ItemNoFilter: Text; ItemType: Enum "Item Type")
    var
        Item: Record "Item";
        TempSearchResponse: Record "Search API Response" temporary;
        FeatureTelemetry: Codeunit "Feature Telemetry";
        CryptographyManagement: Codeunit "Cryptography Management";
        ItemSubstSuggestUtility: Codeunit "Create Product Info. Utility";
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
        NameJsonToken: JsonToken;
        SearchPrimaryKeyWords: List of [Text];
        SearchAdditionalKeyWords: List of [Text];
        TelemetryCD: Dictionary of [Text, Text];
        StartDateTime: DateTime;
        DurationAsBigInt: BigInteger;
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
        SearchItemNames: Text;
        ItemTokentText: Text;
        CapabilityName: Text;
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
        ALSearchOptions.InitialSearchScoreCutoffThreshold := 0;

        //Add Search Filters
        SearchFilter := SearchFilter.SearchFilter();
        SearchFilter.FieldNo := Item.FieldNo(Type);
        SearchFilter.Expression := Text.StrSubstNo('%1', ItemType);
        ALSearchOptions.AddSearchFilter(SearchFilter);

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

        //Add Search Queries
        foreach ItemToken in ItemResultsArray do begin
            SearchPrimaryKeyWords := GetItemNameKeywords(ItemToken);
            SearchAdditionalKeyWords := GetItemFeaturesKeywords(ItemToken);
            ItemToken.AsObject().Get('name', NameJsonToken);
            ItemToken.WriteTo(ItemTokentText);
            SearchItemNames += NameJsonToken.AsValue().AsText() + ', ';

            BuildSearchQuery(SearchPrimaryKeyWords, SearchAdditionalKeyWords, CryptographyManagement.GenerateHash(ItemTokentText, HashAlgorithmType::SHA256), SearchStyle, Top, SearchQuery, ALSearchQuery);
            ALSearchOptions.AddSearchQuery(ALSearchQuery);
        end;

        // Setup capability information
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        CapabilityName := Enum::"Copilot Capability".Names().Get(Enum::"Copilot Capability".Ordinals().IndexOf(Enum::"Copilot Capability"::"Create Product Information".AsInteger()));
        ALCopilotCapability := ALCopilotCapability.ALCopilotCapability(CurrentModuleInfo.Publisher(), CurrentModuleInfo.Id(), Format(CurrentModuleInfo.AppVersion()), CapabilityName);

        //Search Items
        SearchProgress.Open(StrSubstNo(SearchingItemsLbl, SearchItemNames.TrimEnd(', ')));
        StartDateTime := CurrentDateTime();
        ALSearchResult := ALSearch.FindItems(ALSearchOptions, ALCopilotCapability);
        SearchProgress.Close();
        DurationAsBigInt := (CurrentDateTime() - StartDateTime);
        TelemetryCD.Add('Response time', Format(DurationAsBigInt));
        FeatureTelemetry.LogUsage('0000N2R', ItemSubstSuggestUtility.GetFeatureName(), 'FindItems', TelemetryCD);

        //Process Search Results
        foreach ItemToken in ItemResultsArray do begin
            ItemToken.WriteTo(ItemTokentText);
            QueryResults := ALSearchResult.GetResultsForQuery(CryptographyManagement.GenerateHash(ItemTokentText, HashAlgorithmType::SHA256));

            TempSearchResponse.DeleteAll();
            foreach ALSearchQueryResult in QueryResults do
                if not TempSearchResponse.Get(Format(ALSearchQueryResult.SystemId)) then begin
                    TempSearchResponse.Init();
                    TempSearchResponse.SysId := ALSearchQueryResult.SystemId;
                    TempSearchResponse.Score := ALSearchQueryResult.ContextAwareRankingScore;
                    TempSearchResponse.Insert();

                    SearchPrimaryKeyWords := GetItemNameKeywords(ItemToken);
                    SearchAdditionalKeyWords := GetItemFeaturesKeywords(ItemToken);
                    GetItemSubstFromItemSystemIds(TempSearchResponse, TempItemSubst, SearchPrimaryKeyWords, SearchAdditionalKeyWords);
                end;
        end;
    end;

    local procedure BuildSearchQuery(SearchPrimaryKeyWords: List of [Text]; SearchAdditionalKeyWords: List of [Text]; ItemNameHASH: Text; SearchStyle: Enum "Search Style"; Top: Integer; SearchQuery: Text; var ALSearchQuery: DotNet ALSearchQuery)
    var
        ALSearchMode: DotNet ALSearchMode;
        Keyword: Text;
    begin
        ALSearchQuery := ALSearchQuery.SearchQuery(ItemNameHASH);

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

        if Top <> 0 then
            ALSearchQuery.Top := Top;

        ALSearchQuery.EmbeddingQuery := SearchQuery;
    end;

    local procedure GetItemSubstFromItemSystemIds(var TempSearchResponse: Record "Search API Response" temporary; var TempItemSubst: Record "Item Substitution" temporary; var SearchPrimaryKeyWords: List of [Text]; var SearchAdditionalKeyWords: List of [Text])
    var
        Item: Record "Item";
    begin
        Item.SetLoadFields("No.", "Description");
        if Item.GetBySystemId(TempSearchResponse.SysId) then begin
            Item.SetRecFilter();

            TempItemSubst.Init();
            TempItemSubst."Substitute Type" := TempItemSubst."Substitute Type"::Item;
            TempItemSubst."Substitute No." := Item."No.";
            TempItemSubst.Description := Item.Description;
            TempItemSubst.Score := TempSearchResponse.Score;
            TempItemSubst.Confidence := GetConfidence(TempSearchResponse.Score * 100);
            TempItemSubst.SetPrimarySearchTerms(SearchPrimaryKeyWords);
            TempItemSubst.SetAdditionalSearchTerms(SearchAdditionalKeyWords);
            TempItemSubst.Insert();
        end;
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
            foreach JsonToken in JsonArray do
                if SearchKeyword = '' then
                    SearchKeyword := '(' + JsonToken.AsValue().AsText() + AddSynonyms(ItemObjectToken)
                else
                    SearchKeyword += '&(' + JsonToken.AsValue().AsText() + AddSynonyms(ItemObjectToken);
            if JsonArray.Count() > 1 then
                SearchKeyword := '(' + SearchKeyword + ')';
            if ItemObjectToken.AsObject().Get('origin_name', JsonToken) then
                if (JsonToken.AsValue().AsText() <> '') then
                    SearchKeyword += '|(' + JsonToken.AsValue().AsText() + ')';
            SearchKeywords.Add(SearchKeyword);
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
        if Score > 80 then
            exit("Search Confidence"::High);
        if Score > 50 then
            exit("Search Confidence"::Medium);
        if Score > 20 then
            exit("Search Confidence"::Low);

        exit("Search Confidence"::None);
    end;
}