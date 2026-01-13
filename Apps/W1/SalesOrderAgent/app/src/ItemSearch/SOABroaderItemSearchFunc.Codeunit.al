// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using System.AI;

codeunit 4597 "SOA Broader Item Search Func" implements "AOAI Function"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        BroaderItemSearch: Codeunit "SOA Broader Item Search";
        SearchQuery: Text;
        ItemResultsArray: JsonArray;
        Top: Integer;
        MaximumQueryResultsToRank: Integer;
        IncludeSynonyms: Boolean;
        UseContextAwareRanking: Boolean;

        FunctionNameLbl: Label 'split_item_keywords', Locked = true;

    [NonDebuggable]
    procedure GetPrompt(): JsonObject
    var
        SOAInstructions: Codeunit "SOA Instructions";
        PromptJson: JsonObject;
    begin
        PromptJson.ReadFrom((SOAInstructions.GetBroaderItemSearchPrompt().Unwrap()));
        exit(PromptJson);
    end;

    [NonDebuggable]
    procedure Execute(Arguments: JsonObject): Variant
    var
        ItemsResults: JsonToken;
        ItemFilter: Text;
    begin
        if Arguments.Get('results', ItemsResults) then begin
            ItemResultsArray := ItemsResults.AsArray();
            Top := 10;
            MaximumQueryResultsToRank := 25;
            IncludeSynonyms := false;
            UseContextAwareRanking := true;
            if BroaderItemSearch.SearchBroader(ItemResultsArray, SearchQuery, Top, MaximumQueryResultsToRank, IncludeSynonyms, UseContextAwareRanking, ItemFilter) then
                exit(ItemFilter);
        end;
    end;

    procedure SetSearchQuery(NewSearchQuery: Text)
    begin
        SearchQuery := NewSearchQuery;
    end;

    procedure GetName(): Text
    begin
        exit(FunctionNameLbl);
    end;

    internal procedure GetSearchParameters(var ItemResultsArr: JsonArray; var SearchQ: Text; var IncludeSyn: Boolean; var UseContextAwareRank: Boolean; var MaxQueryResultsToRank: Integer; var TakeTop: Integer)
    begin
        ItemResultsArr := ItemResultsArray;
        SearchQ := SearchQuery;
        IncludeSyn := IncludeSynonyms;
        UseContextAwareRank := UseContextAwareRanking;
        MaxQueryResultsToRank := MaximumQueryResultsToRank;
        TakeTop := Top;
    end;
}