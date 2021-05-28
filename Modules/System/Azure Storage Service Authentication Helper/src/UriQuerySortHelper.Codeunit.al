// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Helper Codeunit to sort Uri-Query segments
/// Uses "Temp Sort Table" to sort a splitted String alphabetically; works similar to a Record-type variable (methods "FindSet()", "Next()")
/// but uses additionally a Dictionary to handle values longer than 250 characters
/// </summary>
codeunit 9053 "Uri Query Sort Helper"
{
    Access = Internal;

    procedure SetQueryString(QueryString: Text)
    begin
        Clear(Segments);
        if QueryString.StartsWith('?') then
            QueryString := CopyStr(QueryString, 2);
        Segments := QueryString.Split('&');
        PrepareSortedQueryValues();
    end;

    procedure FindSet(): Boolean
    begin
        exit(TempSortTable.FindSet(false, false));
    end;

    procedure Next(): Integer;
    begin
        exit(TempSortTable.Next());
    end;

    procedure Identifier(): Text
    begin
        exit(TempSortTable."Key");
    end;

    procedure Value(): Text
    var
        CurrValue: Text;
    begin
        ValueDictionary.Get(TempSortTable."Key", CurrValue);
        exit(CurrValue);
    end;

    local procedure PrepareSortedQueryValues()
    var
        Segment: Text;
        CurrIdentifier: Text;
        CurrValue: Text;
    begin
        Clear(ValueDictionary);
        TempSortTable.Reset();
        TempSortTable.DeleteAll();
        foreach Segment in Segments do begin
            GetKeyValueFromQueryParameter(Segment, CurrIdentifier, CurrValue);
            TempSortTable.Init();
            TempSortTable."Key" := CopyStr(CurrIdentifier, 1, 250);
            TempSortTable."Value" := CopyStr(CurrValue, 1, 250);
            TempSortTable.Insert();
            ValueDictionary.Add(CurrIdentifier, CurrValue);
        end;
        TempSortTable.SetCurrentKey("Key");
        TempSortTable.Ascending(true);
    end;

    local procedure GetKeyValueFromQueryParameter(QueryString: Text; var CurrIdentifier: Text; var CurrValue: Text)
    var
        Split: List of [Text];
    begin
        Split := QueryString.Split('=');
        if Split.Count <> 2 then
            Error('This should not happen'); // TODO: Make better error
        CurrIdentifier := Split.Get(1);
        CurrValue := Split.Get(2);
    end;

    var
        TempSortTable: Record "Temp. Sort Table";
        Segments: List of [Text];
        ValueDictionary: Dictionary of [Text, Text];
}