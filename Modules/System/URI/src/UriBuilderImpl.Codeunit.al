// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 3062 "Uri Builder Impl."
{
    Access = Internal;

    procedure Init(Uri: Text)
    begin
        UriBuilder := UriBuilder.UriBuilder(Uri);
    end;

    procedure SetScheme(Scheme: Text)
    begin
        UriBuilder.Scheme := Scheme;
    end;

    procedure GetScheme(): Text
    begin
        exit(UriBuilder.Scheme);
    end;

    procedure SetHost(Host: Text)
    begin
        UriBuilder.Host := Host;
    end;

    procedure GetHost(): Text
    begin
        exit(UriBuilder.Host);
    end;

    procedure SetPort(Port: Integer)
    begin
        UriBuilder.Port := Port;
    end;

    procedure GetPort(): Integer
    begin
        exit(UriBuilder.Port);
    end;

    procedure SetPath(Path: Text)
    begin
        UriBuilder.Path := Path;
    end;

    procedure GetPath(): Text
    begin
        exit(UriBuilder.Path);
    end;

    procedure SetQuery(Query: Text)
    begin
        UriBuilder.Query := Query;
    end;

    procedure GetQuery(): Text
    begin
        exit(UriBuilder.Query);
    end;

    procedure SetFragment(Fragment: Text)
    begin
        UriBuilder.Fragment := Fragment;
    end;

    procedure GetFragment(): Text
    begin
        exit(UriBuilder.Fragment);
    end;

    procedure GetUri(var Uri: Codeunit Uri)
    begin
        Uri.SetUri(UriBuilder.Uri);
    end;

    procedure AddQueryFlag(Flag: Text; DuplicateAction: Enum "Uri Query Duplicate Behaviour")
    var
        KeysWithValueList: Dictionary of [Text, List of [Text]];
        Flags: List of [Text];
        QueryString: Text;
    begin
        if Flag = '' then
            Error(FlagCannotBeEmptyErr);

        QueryString := GetQuery();
        ParseParametersAndFlags(QueryString, KeysWithValueList, Flags);
        ProcessNewFlag(Flags, Flag, DuplicateAction);
        QueryString := CreateNewQueryString(KeysWithValueList, Flags);

        SetQuery(QueryString);
    end;

    procedure AddQueryParameter(ParameterKey: Text; ParameterValue: Text; DuplicateAction: Enum "Uri Query Duplicate Behaviour")
    var
        KeysWithValueList: Dictionary of [Text, List of [Text]];
        Flags: List of [Text];
        QueryString: Text;
    begin
        if ParameterKey = '' then
            Error(QueryParameterKeyCannotBeEmptyErr);

        QueryString := GetQuery();
        ParseParametersAndFlags(QueryString, KeysWithValueList, Flags);
        ProcessNewParameter(KeysWithValueList, ParameterKey, ParameterValue, DuplicateAction);
        QueryString := CreateNewQueryString(KeysWithValueList, Flags);

        SetQuery(QueryString);
    end;

    local procedure ParseParametersAndFlags(QueryString: Text; var KeysWithValueList: Dictionary of [Text, List of [Text]]; var Flags: List of [Text])
    var
        ValueList: List of [Text];
        NameValueCollection: DotNet NameValueCollection;
        HttpUtility: DotNet HttpUtility;
        QueryKey: Text;
        QueryValue: Text;
        KeysCount: Integer;
        KeysIndex: Integer;
    begin
        // NOTE: ParseQueryString returns the value unencoded
        NameValueCollection := HttpUtility.ParseQueryString(QueryString);
        KeysCount := NameValueCollection.Count();

        for KeysIndex := 0 to KeysCount - 1 do
            // Flags (e.g. 'foo' and 'bar' in '?foo&bar') are all grouped under a null key.
            if IsNull(NameValueCollection.GetKey(KeysIndex)) then
                foreach QueryValue in NameValueCollection.GetValues(KeysIndex) do
                    Flags.Add(QueryValue) // No easy way to convert DotNet Array to AL List
            else begin
                QueryKey := NameValueCollection.GetKey(KeysIndex);
                Clear(ValueList);

                foreach QueryValue in NameValueCollection.GetValues(KeysIndex) do
                    ValueList.Add(QueryValue); // No easy way to convert DotNet Array to AL List

                KeysWithValueList.Add(QueryKey, ValueList);
            end;
    end;

    local procedure ProcessNewParameter(var KeysWithValueList: Dictionary of [Text, List of [Text]]; QueryKey: Text; QueryValue: Text; DuplicateAction: Enum "Uri Query Duplicate Behaviour")
    var
        Values: List of [Text];
    begin
        if not KeysWithValueList.ContainsKey(QueryKey) then begin
            Values.Add(QueryValue);
            KeysWithValueList.Add(QueryKey, Values);
            exit;
        end;

        KeysWithValueList.Get(QueryKey, Values);
        case DuplicateAction of
            DuplicateAction::"Overwrite All Matching":
                begin
                    Clear(Values);
                    Values.Add(QueryValue);
                    KeysWithValueList.Remove(QueryKey);
                    KeysWithValueList.Add(QueryKey, Values);
                end;
            DuplicateAction::Skip:
                ; // Do nothing
            DuplicateAction::"Keep All":
                Values.Add(QueryValue);
            DuplicateAction::"Throw Error":
                Error(DuplicateParameterErr);
            else // In case the duplicate action is invalid, it's safer to error out than to have a malformed URL
                Error(DuplicateParameterErr);
        end;
    end;

    local procedure ProcessNewFlag(var Flags: List of [Text]; Flag: Text; DuplicateAction: Enum "Uri Query Duplicate Behaviour")
    var
        FlagsSizeBeforeRemove: Integer;
    begin
        if not Flags.Contains(Flag) then begin
            Flags.Add(Flag);
            exit;
        end;

        case DuplicateAction of
            DuplicateAction::Skip:
                ;
            DuplicateAction::"Overwrite All Matching":
                begin
                    // If multiple matching flags exist, we need to keep only one
                    repeat
                        FlagsSizeBeforeRemove := Flags.Count; // Doing this instead of "while flags.remove do;" protects against infinite loops
                        if Flags.Contains(Flag) then
                            if Flags.Remove(Flag) then;
                    until Flags.Count >= FlagsSizeBeforeRemove;

                    Flags.Add(Flag);
                end;
            DuplicateAction::"Keep All":
                Flags.Add(Flag);
            DuplicateAction::"Throw Error":
                Error(DuplicateFlagErr);
            else // In case the duplicate action is invalid, it's safer to error out than to have a malformed URL
                Error(DuplicateFlagErr);
        end;
    end;

    local procedure CreateNewQueryString(KeysWithValueList: Dictionary of [Text, List of [Text]]; Flags: List of [Text]) FinalQuery: Text
    var
        Uri: Codeunit Uri;
        CurrentKey: Text;
        CurrentValues: List of [Text];
        CurrentValue: Text;
    begin
        foreach CurrentKey in KeysWithValueList.Keys() do begin
            KeysWithValueList.Get(CurrentKey, CurrentValues);
            foreach CurrentValue in CurrentValues do
                FinalQuery += '&' + Uri.EscapeDataString(CurrentKey) + '=' + Uri.EscapeDataString(CurrentValue);
        end;

        foreach CurrentKey in Flags do
            FinalQuery += '&' + Uri.EscapeDataString(CurrentKey);

        FinalQuery := DelChr(FinalQuery, '<', '&');
    end;

    var
        FlagCannotBeEmptyErr: Label 'The flag cannot be empty.';
        QueryParameterKeyCannotBeEmptyErr: Label 'The query parameter key cannot be empty.';
        DuplicateFlagErr: Label 'The provided query flag is already present in the URI.';
        DuplicateParameterErr: Label 'The provided query parameter is already present in the URI.';
        UriBuilder: DotNet UriBuilder;
}
