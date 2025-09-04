// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Agent.SalesOrderAgent;

using System;
using System.AI;

codeunit 4395 "Global Item Search"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        ALSearchOptions: DotNet ALSearchOptions;
        ALCopilotCapability: DotNet ALCopilotCapability;

    internal procedure InitializeSearchOptionsObject(IncludeSynonyms: Boolean; UseContextAwareRanking: Boolean)
    begin
        ALSearchOptions := ALSearchOptions.SearchOptions();
        ALSearchOptions.IncludeSynonyms := IncludeSynonyms;
        ALSearchOptions.UseContextAwareRanking := UseContextAwareRanking;
    end;

    internal procedure AddSearchFilter(FieldNo: Integer; Expression: Text)
    var
        SearchFilter: DotNet SearchFilter;
    begin
        SearchFilter := SearchFilter.SearchFilter();
        SearchFilter.FieldNo := FieldNo;
        SearchFilter.Expression := Expression;
        ALSearchOptions.AddSearchFilter(SearchFilter);
    end;

    internal procedure AddSearchRankingContext(SearchQuery: Text; Intent: Text; MaximumQueryResultsToRank: Integer)
    var
        ALSearchRankingContext: DotNet ALSearchRankingContext;
    begin
        //Add Search Ranking Context
        ALSearchRankingContext := ALSearchRankingContext.SearchRankingContext();
        if SearchQuery <> '' then
            ALSearchRankingContext.UserMessage := SearchQuery;
        if Intent <> '' then
            ALSearchRankingContext.Intent := Intent;
        if MaximumQueryResultsToRank > 0 then
            ALSearchRankingContext.MaximumQueryResultsToRank := MaximumQueryResultsToRank;
        ALSearchRankingContext.RerankEvenIfOneResult := true;
        ALSearchOptions.RankingContext := ALSearchRankingContext;
    end;

    internal procedure SetupSOACapabilityInformation()
    var
        CurrentModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        SetupCapabilityInformation(CurrentModuleInfo, Enum::"Copilot Capability"::"Sales Order Agent".AsInteger());
    end;

    internal procedure SetupCapabilityInformation(CurrentModuleInfo: ModuleInfo; CopilotCapabilityAsInteger: Integer)
    var
        CapabilityName: Text;
    begin
        // Setup capability information
        CapabilityName :=
            Enum::"Copilot Capability".Names().Get(Enum::"Copilot Capability".Ordinals().IndexOf(CopilotCapabilityAsInteger));
        ALCopilotCapability :=
            ALCopilotCapability.ALCopilotCapability(CurrentModuleInfo.Publisher(), CurrentModuleInfo.Id(), Format(CurrentModuleInfo.AppVersion()), CapabilityName);
    end;

    internal procedure SetupSearchQuery(SearchQueryText: Text; SearchPrimaryKeyWords: List of [Text]; SearchOptionalKeyWords: List of [Text]; PreciseSearch: Boolean; SearchTopResults: Integer)
    var
        ALSearchQuery: DotNet ALSearchQuery;
        ALSearchMode: DotNet ALSearchMode;
        Keyword: Text;
    begin
        ALSearchQuery := ALSearchQuery.SearchQuery(SearchQueryText);

        foreach Keyword in SearchPrimaryKeyWords do
            ALSearchQuery.AddRequiredTerm(Keyword.ToLower());

        foreach Keyword in SearchOptionalKeyWords do
            ALSearchQuery.AddOptionalTerm(Keyword.ToLower());

        ALSearchQuery.Top(SearchTopResults);
        if PreciseSearch then
            ALSearchQuery.Mode := ALSearchMode::All
        else
            ALSearchQuery.Mode := ALSearchMode::Any;
        ALSearchOptions.AddSearchQuery(ALSearchQuery);
    end;

    internal procedure SearchAndReturnResultAsTxt(SearchPrimaryKeyWord: Text; MinContextAwareRankingScore: Decimal; Delimiter: Text): Text
    var
        ALSearch: DotNet ALSearch;
        ALSearchResult: DotNet ALSearchResult;
        QueryResults: DotNet GenericList1;
        ALSearchQueryResult: DotNet ALSearchQueryResult;
        ResultFilter: Text;
        IncludeResult: Boolean;
    begin
        if Delimiter = '' then
            Delimiter := '|';

        // Search
        ALSearchResult := ALSearch.FindItems(ALSearchOptions, ALCopilotCapability);

        // Process results
        QueryResults := ALSearchResult.GetResultsForQuery(SearchPrimaryKeyWord);

        foreach ALSearchQueryResult in QueryResults do begin
            IncludeResult := (MinContextAwareRankingScore = 0) or (ALSearchQueryResult.ContextAwareRankingScore >= MinContextAwareRankingScore);
            if IncludeResult then
                ResultFilter += ALSearchQueryResult.SystemId + Delimiter;
        end;

        ResultFilter := ResultFilter.TrimEnd(Delimiter);
        exit(ResultFilter);
    end;

    internal procedure CheckIsItemSearchReady(ErrorOnFalse: Boolean): Boolean
    var
        WaitingTime, SleepTime, TimeOutPeriod : Integer;
        ItemSearchNotReadyErr: Label 'Item search is not ready';
    begin
        WaitingTime := GetWaitingTimeForItemSearch();
        SleepTime := GetSleepTimeForItemSearch();
        TimeOutPeriod := GetTimeOutPeriodForItemSearch();

        while (not IsItemSearchReady()) and (WaitingTime <= TimeOutPeriod) do begin
            WaitingTime += SleepTime;
            Sleep(SleepTime);
        end;

        if IsItemSearchReady() then
            exit(true);

        if ErrorOnFalse then
            Error(ItemSearchNotReadyErr);
    end;

    local procedure GetWaitingTimeForItemSearch(): Integer
    begin
        exit(0);
    end;

    local procedure GetSleepTimeForItemSearch(): Integer
    begin
        exit(3000); // 3 seconds
    end;

    local procedure GetTimeOutPeriodForItemSearch(): Integer
    begin
        exit(300000); // 5 minutes
    end;

    internal procedure IsItemSearchReady(): Boolean
    var
        ALSearch: DotNet ALSearch;
    begin
        exit(ALSearch.IsItemSearchReady());
    end;

    internal procedure EnableItemSearch()
    var
        ALSearch: DotNet ALSearch;
    begin
        if not ALSearch.IsItemSearchReady() then
            ALSearch.EnableItemSearch();
    end;

}