// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135068 "Regex Performance Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        RegexPerformanceUrlMatchTxt: Label '^https*://(?<storageAccount>(?:bcartifacts|bcinsider))\.[\w\.]+/(?<type>(?:Sandbox|OnPrem))/(?<version>(?:(?:\d+)*(?:\.\d+)*(?:\.\d+)*(?:\.\d+)*))/(?<country>\w{2})', Locked = true;

    [Test]
    procedure RegexPerformanceStaticCalls()
    var
        RegexOptions: Record "Regex Options";
        Regex: Codeunit Regex;
    begin
        RegexOptions.Compiled := true;
        RegexOptions.IgnoreCase := true;

        RegexPerformanceCall(Regex, RegexOptions, false);
    end;

    [Test]
    procedure RegexPerformanceInstanceCalls()
    var
        RegexOptions: Record "Regex Options";
        Regex: Codeunit Regex;
    begin
        RegexOptions.Compiled := true;
        RegexOptions.IgnoreCase := true;
        Regex.Regex(RegexPerformanceUrlMatchTxt, RegexOptions);

        RegexPerformanceCall(Regex, RegexOptions, true);
    end;

    local procedure RegexPerformanceCall(var ThisRegex: Codeunit Regex; RegexOptions: Record "Regex Options"; RunOnInstance: Boolean)
    var
        Matches: Record Matches;
        Groups: Record Groups;
        Counter: Integer;
        UrlTxt: Label 'https://bcartifacts.azureedge.net/onprem/18.3.27240.27480/de', Locked = true;
    begin
        for counter := 0 to 100 do begin
            case RunOnInstance of
                true:
                    ThisRegex.Match(UrlTxt, Matches);
                false:
                    ThisRegex.Match(UrlTxt, RegexPerformanceUrlMatchTxt, RegexOptions, Matches);
            end;

            if Matches.Success then
                ThisRegex.Groups(Matches, Groups);
        end;
    end;

}