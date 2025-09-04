// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.Inventory.Item;

codeunit 4593 "SOA Variant Search"
{
    Access = Internal;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure GetVariantFilters(CurrentView: Text; var VaraintFilter: Text; SearchKeyWords: List of [Text])
    var
        ItemVariant: Record "Item Variant";
        VariantsKeywords: Text;
        Keyword: Text;
        OriginalFilterGroup: Integer;
    begin
        ItemVariant.SetLoadFields(SystemId);
        ItemVariant.SetView(CurrentView);

        foreach Keyword in SearchKeyWords do
            VariantsKeywords += '&&' + Keyword.ToLower() + '*|';    //Make all keywords optional
        VariantsKeywords := VariantsKeywords.TrimEnd('|');


        OriginalFilterGroup := ItemVariant.FilterGroup();
        ItemVariant.FilterGroup(-1);  //Set filters for cross column search
        ItemVariant.SetFilter(Code, VariantsKeywords);
        ItemVariant.SetFilter(Description, VariantsKeywords);
        ItemVariant.SetFilter("Description 2", VariantsKeywords);
        ItemVariant.FilterGroup(OriginalFilterGroup);

        if ItemVariant.FindSet() then
            repeat
                VaraintFilter += ItemVariant.SystemId + '|';
            until ItemVariant.Next() = 0;

        VaraintFilter := VaraintFilter.TrimEnd('|');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Item Variants", 'OnBeforeFindRecord', '', false, false)]
    local procedure FindRecordItemVariants(var Rec: Record "Item Variant"; Which: Text; var CrossColumnSearchFilter: Text; var Found: Boolean; var IsHandled: Boolean)
    begin
        FindRecordItemVariant(Rec, Which, CrossColumnSearchFilter, Found, IsHandled);
    end;

    local procedure FindRecordItemVariant(var Rec: Record "Item Variant"; Which: Text; var CrossColumnSearchFilter: Text; var Found: Boolean; var IsHandled: Boolean)
    var
        SearchKeyWords: List of [Text];
        SearchKeyWordsTrimmed: List of [Text];
        VariantSearchKeywords: Text;
        VariantFilter: Text;
        SearchKeyword: Text;
        KeyWord: Text;
        CurrentView: Text;
        OriginalFilterGroup: Integer;
    begin
        CurrentView := Rec.GetView();
        OriginalFilterGroup := Rec.FilterGroup();
        Rec.FilterGroup(-1);
        VariantSearchKeywords := Rec.GetFilter(Code); //Get current search filter
        Rec.FilterGroup(OriginalFilterGroup);

        if VariantSearchKeywords = CrossColumnSearchFilter then //If the search filter is the same as the last one, then we don't need to search again
            exit;
        CrossColumnSearchFilter := VariantSearchKeywords;

        SearchKeyWords := VariantSearchKeywords.Split('&&'); //Split and trim the search keywords
        foreach KeyWord in SearchKeyWords do begin
            SearchKeyword := KeyWord.TrimStart('&').TrimEnd('*').Trim();
            if SearchKeyword <> '' then
                SearchKeyWordsTrimmed.Add(SearchKeyword);
        end;

        if SearchKeyWordsTrimmed.Count() = 0 then
            exit;

        GetVariantFilters(CurrentView, VariantFilter, SearchKeyWordsTrimmed);
        if VariantFilter = '' then
            exit;

        if VariantFilter <> '' then begin //IsHandled only if the search is successful
            Rec.Reset();
            Rec.SetView(CurrentView);
            Rec.FilterGroup(-1);
            Rec.SetFilter(SystemId, VariantFilter);
            Rec.FilterGroup(OriginalFilterGroup);

            IsHandled := true;
            Found := Rec.Find(Which);
        end;
    end;
}