// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 3961 "Regex Impl."
{
    Access = Internal;

    var
        DotNetRegex: DotNet Regex;
        DotNetRegexOptions: DotNet RegexOptions;
        DotNetMatchCollection: DotNet MatchCollection;
        DotNetGroupCollection: DotNet GroupCollection;
        DotNetCaptureCollection: DotNet CaptureCollection;
        TimeoutTooLowErr: Label 'The regular expression timeout should be at least 1000 ms';
        TimeoutTooHighErr: Label 'The regular expression timeout should be at most 10000 ms';
        RegexIsNotInstantiatedErr: Label 'Regex is not Instantiated. Consider calling Regex() first or use an overload supporting a pattern.';

    procedure GetCacheSize(): Integer
    begin
        exit(DotNetRegex.CacheSize());
    end;

    procedure SetCacheSize(CacheSize: Integer)
    begin
        DotNetRegex.CacheSize := CacheSize;
    end;

    procedure GetGroupNames(var "Array": List of [Text])
    var
        GroupName: Text;
        GroupNames: DotNet Array;
    begin
        GroupNames := DotNetRegex.GetGroupNames();
        foreach GroupName in GroupNames do "Array".Add(GroupName);
    end;

    procedure GetGroupNumbers(var "Array": List of [Integer])
    var
        GroupNumber: Integer;
        GroupNumbers: DotNet Array;
    begin
        GroupNumbers := DotNetRegex.GetGroupNumbers();
        foreach GroupNumber in GroupNumbers do "Array".Add(GroupNumber);
    end;

    procedure GroupNameFromNumber(Number: Integer): Text
    begin
        exit(DotNetRegex.GroupNameFromNumber(Number));
    end;

    procedure GroupNumberFromName(Name: Text): Integer
    begin
        exit(DotNetRegex.GroupNumberFromName(Name));
    end;

    procedure IsMatch(Input: Text; Pattern: Text; StartAt: Integer): Boolean
    begin
        Regex(Pattern);
        exit(IsMatch(Input, StartAt))
    end;

    procedure IsMatch(Input: Text; StartAt: Integer): Boolean
    begin
        exit(DotNetRegex.IsMatch(Input, StartAt))
    end;

    procedure IsMatch(Input: Text; Pattern: Text; StartAt: Integer; var RegexOptions: Record "Regex Options"): Boolean
    begin
        Regex(Pattern, RegexOptions);
        exit(DotNetRegex.IsMatch(Input, StartAt))
    end;

    procedure IsMatch(Input: Text; Pattern: Text): Boolean
    begin
        Regex(Pattern);
        exit(IsMatch(Input));
    end;

    procedure IsMatch(Input: Text): Boolean
    begin
        CheckIfInstantiated();
        exit(DotNetRegex.IsMatch(Input));
    end;

    procedure IsMatch(Input: Text; Pattern: Text; var RegexOptions: Record "Regex Options"): Boolean
    begin
        Regex(Pattern, RegexOptions);
        exit(DotNetRegex.IsMatch(Input));
    end;

    procedure Match(Input: Text; Pattern: Text; StartAt: Integer; var Matches: Record Matches)
    begin
        Regex(Pattern);
        Match(Input, StartAt, Matches);
    end;

    procedure Match(Input: Text; StartAt: Integer; var Matches: Record Matches)
    begin
        CheckIfInstantiated();
        DotNetMatchCollection := DotNetRegex.Matches(Input, StartAt);
        InsertMatch(Matches);
    end;

    procedure Match(Input: Text; Pattern: Text; StartAt: Integer; var RegexOptions: Record "Regex Options"; var Matches: Record Matches)
    begin
        Regex(Pattern, RegexOptions);
        Match(Input, StartAt, Matches);
    end;

    procedure Match(Input: Text; Pattern: Text; StartAt: Integer; Length: Integer; var Matches: Record Matches)
    begin
        Regex(Pattern);
        Match(Input, StartAt, Length, Matches)
    end;

    procedure Match(Input: Text; StartAt: Integer; Length: Integer; var Matches: Record Matches)
    begin
        CheckIfInstantiated();
        Input := Input.Substring(1, StartAt + Length);
        DotNetMatchCollection := DotNetRegex.Matches(Input, StartAt);
        InsertMatch(Matches);
    end;

    procedure Match(Input: Text; Pattern: Text; StartAt: Integer; Length: Integer; var RegexOptions: Record "Regex Options"; var Matches: Record Matches)
    begin
        Regex(Pattern, RegexOptions);
        Match(Input, StartAt, Length, Matches)
    end;

    procedure Match(Input: Text; Pattern: Text; var Matches: Record Matches)
    begin
        Regex(Pattern);
        Match(Input, Matches);
    end;

    procedure Match(Input: Text; var Matches: Record Matches)
    begin
        CheckIfInstantiated();
        DotNetMatchCollection := DotNetRegex.Matches(Input);
        InsertMatch(Matches);
    end;

    procedure Match(Input: Text; Pattern: Text; var RegexOptions: Record "Regex Options"; var Matches: Record Matches)
    begin
        Regex(Pattern, RegexOptions);
        DotNetMatchCollection := DotNetRegex.Matches(Input);
        InsertMatch(Matches);
    end;

    procedure Replace(Input: Text; Pattern: Text; Replacement: Text; "Count": Integer): Text
    begin
        Regex(Pattern);
        exit(Replace(Input, Replacement, "Count"));
    end;

    procedure Replace(Input: Text; Replacement: Text; "Count": Integer): Text
    begin
        CheckIfInstantiated();
        exit(DotNetRegex.Replace(Input, Replacement, "Count"));
    end;

    procedure Replace(Input: Text; Pattern: Text; Replacement: Text; "Count": Integer; var RegexOptions: Record "Regex Options"): Text
    begin
        Regex(Pattern, RegexOptions);
        exit(DotNetRegex.Replace(Input, Replacement, "Count"));
    end;

    procedure Replace(Input: Text; Pattern: Text; Replacement: Text; "Count": Integer; StartAt: Integer): Text
    begin
        Regex(Pattern);
        exit(Replace(Input, Replacement, "Count", StartAt));
    end;

    procedure Replace(Input: Text; Replacement: Text; "Count": Integer; StartAt: Integer): Text
    begin
        CheckIfInstantiated();
        exit(DotNetRegex.Replace(Input, Replacement, "Count", StartAt));
    end;

    procedure Replace(Input: Text; Pattern: Text; Replacement: Text; "Count": Integer; StartAt: Integer; var RegexOptions: Record "Regex Options"): Text
    begin
        Regex(Pattern, RegexOptions);
        exit(DotNetRegex.Replace(Input, Replacement, "Count", StartAt));
    end;

    procedure Replace(Input: Text; Pattern: Text; Replacement: Text): Text
    begin
        Regex(Pattern);
        exit(Replace(Input, Replacement));
    end;

    procedure Replace(Input: Text; Replacement: Text): Text
    begin
        CheckIfInstantiated();
        exit(DotNetRegex.Replace(Input, Replacement));
    end;

    procedure Replace(Input: Text; Pattern: Text; Replacement: Text; var RegexOptions: Record "Regex Options"): Text
    begin
        Regex(Pattern, RegexOptions);
        exit(DotNetRegex.Replace(Input, Replacement));
    end;

    procedure Split(Input: Text; Pattern: Text; "Count": Integer; var "Array": List of [Text])
    begin
        Regex(Pattern);
        Split(Input, "Count", "Array");
    end;

    procedure Split(Input: Text; "Count": Integer; var "Array": List of [Text])
    var
        StringsDotNetArray: DotNet Array;
        SplitElement: Text;
    begin
        CheckIfInstantiated();
        StringsDotNetArray := DotNetRegex.Split(Input, "Count");
        foreach SplitElement in StringsDotNetArray do "Array".Add(SplitElement);
    end;

    procedure Split(Input: Text; Pattern: Text; "Count": Integer; var RegexOptions: Record "Regex Options"; var "Array": List of [Text])
    begin
        Regex(Pattern, RegexOptions);
        Split(Input, "Count", "Array");
    end;

    procedure Split(Input: Text; Pattern: Text; "Count": Integer; StartAt: Integer; var "Array": List of [Text])
    begin
        Regex(Pattern);
        Split(Input, "Count", StartAt, "Array");
    end;

    procedure Split(Input: Text; "Count": Integer; StartAt: Integer; var "Array": List of [Text])
    var
        StringsDotNetArray: DotNet Array;
        SplitElement: Text;
    begin
        CheckIfInstantiated();
        StringsDotNetArray := DotNetRegex.Split(Input, "Count", StartAt);
        foreach SplitElement in StringsDotNetArray do "Array".Add(SplitElement);
    end;

    procedure Split(Input: Text; Pattern: Text; "Count": Integer; StartAt: Integer; var RegexOptions: Record "Regex Options"; var "Array": List of [Text])
    begin
        Regex(Pattern, RegexOptions);
        Split(Input, "Count", StartAt, "Array");
    end;

    procedure Split(Input: Text; Pattern: Text; var "Array": List of [Text])
    begin
        Regex(Pattern);
        Split(Input, "Array");
    end;

    procedure Split(Input: Text; var "Array": List of [Text])
    var
        StringsDotNetArray: DotNet Array;
        SplitElement: Text;
    begin
        CheckIfInstantiated();
        StringsDotNetArray := DotNetRegex.Split(Input);
        foreach SplitElement in StringsDotNetArray do
            "Array".Add(SplitElement);
    end;

    procedure Split(Input: Text; Pattern: Text; var RegexOptions: Record "Regex Options"; var "Array": List of [Text])
    begin
        Regex(Pattern, RegexOptions);
        Split(Input, "Array");
    end;

    procedure GetHashCode(): Integer
    begin
        exit(DotNetRegex.GetHashCode());
    end;

    procedure Escape(String: Text): Text
    begin
        exit(DotNetRegex.Escape(String));
    end;

    procedure Unescape(String: Text): Text
    begin
        exit(DotNetRegex.Unescape(String));
    end;

    procedure MatchResult(var Matches: Record Matches; Replacement: Text): Text
    var
        MatchIndex: Integer;
    begin
        MatchIndex := Matches.MatchIndex;
        exit(DotNetMatchCollection.Item(MatchIndex).Result(Replacement));
    end;

    procedure Groups(var Matches: Record Matches; var Groups: Record Groups)
    var
        MatchIndex: Integer;
    begin
        MatchIndex := Matches.MatchIndex;
        DotNetGroupCollection := DotNetMatchCollection.Item(MatchIndex).Groups;
        InsertGroups(Groups);
    end;

    procedure Captures(var Groups: Record Groups; var Captures: Record Captures)
    var
        GroupIndex: Integer;
    begin
        GroupIndex := Groups.GroupIndex;
        DotNetCaptureCollection := DotNetGroupCollection.Item(GroupIndex).Captures;
        InsertCaptures(Captures)
    end;

    procedure Regex(Pattern: Text)
    var
        RegexOptions: Record "Regex Options";
    begin
        Regex(Pattern, RegexOptions);
    end;

    procedure Regex(Pattern: Text; var RegexOptions: Record "Regex Options")
    var
        TimeoutDuration: DotNet TimeSpan;
    begin
        DotNetRegexOptions := RegexOptions.GetRegexOptions();
        if RegexOptions.MatchTimeoutInMs < 1000 then
            Error(TimeoutTooLowErr);
        if RegexOptions.MatchTimeoutInMs > 10000 then
            Error(TimeoutTooHighErr);
        DotNetRegex := DotNetRegex.Regex(Pattern, DotNetRegexOptions, TimeoutDuration.FromMilliseconds(RegexOptions.MatchTimeoutInMs));
    end;

    local procedure CheckIfInstantiated()
    begin
        if IsNull(DotNetRegex) then
            Error(RegexIsNotInstantiatedErr);
    end;

    local procedure InsertMatch(var Matches: Record Matches)
    var
        DotNetMatch: DotNet Match;
        Index: Integer;
    begin
        Matches.DeleteAll();
        Index := 0;
        foreach DotNetMatch in DotNetMatchCollection do begin
            Matches.Init();
            Matches.MatchIndex := Index;
            Matches.Index := DotNetMatch.Index;
            Matches.InsertValue(DotNetMatch.Value);
            Matches.Length := DotNetMatch.Length;
            Matches.Success := DotNetMatch.Success;
            Matches.Insert();
            Index += 1;
        end;
        if Matches.FindFirst() then;
    end;

    local procedure InsertGroups(var Groups: Record Groups)
    var
        DotNetGroup: DotNet Group;
        Index: Integer;
    begin
        Groups.DeleteAll();
        Index := 0;
        foreach DotNetGroup in DotNetGroupCollection do begin
            Groups.Init();
            Groups.GroupIndex := Index;
            Groups.Index := DotNetGroup.Index;
            Groups.Name := DotNetGroup.Name;
            Groups.InsertValue(DotNetGroup.Value);
            Groups.Length := DotNetGroup.Length;
            Groups.Success := DotNetGroup.Success;
            Groups.Insert();
            Index += 1;
        end;
        if Groups.FindFirst() then;
    end;

    local procedure InsertCaptures(var Captures: Record Captures)
    var
        DotNetCapture: DotNet Capture;
        Index: Integer;
    begin
        Captures.DeleteAll();
        Index := 0;
        foreach DotNetCapture in DotNetCaptureCollection do begin
            Captures.Init();
            Captures.CaptureIndex := Index;
            Captures.Index := DotNetCapture.Index;
            Captures.Length := DotNetCapture.Length;
            Captures.InsertValue(DotNetCapture.Value);
            Captures.Insert();
            Index += 1;
        end;
        if Captures.FindFirst() then;
    end;
}