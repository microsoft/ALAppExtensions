// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135057 RegexTests
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Regex: Codeunit Regex;
        InstanceRegex: Codeunit Regex;
        Assert: Codeunit "Library Assert";

    [Test]
    procedure IsMatchTest()
    var
        Pattern: Text;
        StartAt: Integer;
    begin
        // [Given] A pattern that matches american phone numbers
        Pattern := '\G[a-zA-Z0-9]\d{2}[a-zA-Z0-9](-\d{3}){2}[A-Za-z0-9]$';
        InstanceRegex.Regex(Pattern);

        // [Then] It returns true for an american number and false for a danish number
        Assert.IsTrue(Regex.IsMatch('1298-673-4192', Pattern), 'Number does not match pattern');
        Assert.IsFalse(Regex.IsMatch('12 23 45 67', Pattern), 'Number wrongly matches pattern');
        Assert.IsTrue(InstanceRegex.IsMatch('1298-673-4192'), 'Number does not match pattern');
        Assert.IsFalse(InstanceRegex.IsMatch('12 23 45 67'), 'Number wrongly matches pattern');

        // [When] Starting position is set to an index 
        StartAt := 6;

        // [Then] It only matches on string with that starting positon
        Assert.IsFalse(Regex.IsMatch('Test: 1298-673-4192', Pattern), 'Number wrongly matches pattern');
        Assert.IsTrue(Regex.IsMatch('Test: 1298-673-4192', Pattern, StartAt), 'Number does not match pattern');
        Assert.IsFalse(InstanceRegex.IsMatch('Test: 1298-673-4192'), 'Number wrongly matches pattern');
        Assert.IsTrue(InstanceRegex.IsMatch('Test: 1298-673-4192', StartAt), 'Number does not match pattern');
    end;

    [Test]
    procedure MatchPatternTest()
    var
        Match: Record Matches;
        RegexOptions: Record "Regex Options";
        Pattern: Text;
    begin
        // [Given] A pattern that matches two words that are the same
        Pattern := '\b  p  \S*';
        InstanceRegex.Regex(Pattern);

        // [Then] Regex does match anything because of the whitespaces in
        Assert.IsFalse(Regex.IsMatch('Empower every person and organization...', Pattern), 'Wrongly found a match');
        Assert.IsFalse(InstanceRegex.IsMatch('Empower every person and organization...'), 'Wrongly found a match');

        Regex.Match('Empower every person and organization...', Pattern, Match);
        Assert.AreEqual('', Match.ReadValue(), 'Wrongly found a match, despite whitespace in pattern');
        InstanceRegex.Match('Empower every person and organization...', Match);
        Assert.AreEqual('', Match.ReadValue(), 'Wrongly found a match, despite whitespace in pattern');

        // [When] Regex is initialized with pattern and IgnorePatternWhiteSpace option
        RegexOptions.IgnorePatternWhitespace := true;

        // [Then] Regex matches with "person"
        Assert.IsTrue(Regex.IsMatch('Empower every person and organization...', Pattern, RegexOptions), 'Did not find a match');
        Regex.Match('Empower every person and organization...', Pattern, RegexOptions, Match);
        Assert.AreEqual('person', Match.ReadValue(), 'Did not match the right word');

        // [When] Regex is initialized with pattern and IgnorePatternWhiteSpace option
        InstanceRegex.Regex(Pattern, RegexOptions);

        // [Then] Regex matches with "person"
        Assert.IsTrue(InstanceRegex.IsMatch('Empower every person and organization...'), 'Did not find a match');
        InstanceRegex.Match('Empower every person and organization...', Match);
        Assert.AreEqual('person', Match.ReadValue(), 'Did not match the right word');
    end;

    [Test]
    procedure MatchesPatternTest()
    var
        Matches: Record Matches;
        Pattern: Text;
    begin
        // [Given] A pattern that matches words ending with 'on'
        Pattern := '\b\w+on\b';

        // [When] Regex matches pattern
        Regex.Match('Empower every person and every organization on the planet to achieve more.', Pattern, Matches);

        // [Then] Regex finds two words that match and the second one is 'organization'. 
        Assert.AreEqual(2, Matches.Count(), 'Did not match correct number of words on sentence');
        Assert.AreEqual('person', Matches.ReadValue(), 'Did not match the right words');
        Matches.Get(1);
        Assert.AreEqual('organization', Matches.ReadValue(), Format(Matches.MatchIndex));

        // [When] Regex matches pattern
        InstanceRegex.Regex(Pattern);
        InstanceRegex.Match('Empower every person and every organization on the planet to achieve more.', Matches);

        // [Then] Regex finds two words that match and the second one is 'organization'. 
        Assert.AreEqual(2, Matches.Count(), 'Did not match correct number of words on sentence');
        Assert.AreEqual('person', Matches.ReadValue(), 'Did not match the right words');
        Matches.Get(1);
        Assert.AreEqual('organization', Matches.ReadValue(), Format(Matches.MatchIndex));
    end;

    local procedure RegexGroupsTestCheckGroups(var CheckMatches: Record Matches; var CheckGroups: Record Groups)
    begin
        // [Then] Regex recognizes multiple Regex Groups on the first match "Microsoft®"
        Assert.AreEqual('Microsoft®', CheckGroups.ReadValue(), 'Did not match first group item correctly');
        Assert.AreEqual('0', CheckGroups.Name, 'Group name is wrong');

        CheckGroups.Next();
        Assert.AreEqual('Microsoft', CheckGroups.ReadValue(), 'Did not match second group item correctly');
        Assert.AreEqual('1', CheckGroups.Name, 'Group name is wrong');

        // [And] recognizes the next Regex Group as "Excel®"
        CheckMatches.Next();
        Regex.Groups(CheckMatches, CheckGroups);

        Assert.AreEqual('Excel®', CheckGroups.ReadValue(), 'Did not match first group item of second group correctly');
        CheckGroups.Next();
        Assert.AreEqual('Excel', CheckGroups.ReadValue(), 'Did not match first group item of second group correctly');
    end;

    [Test]
    procedure RegexGroupsTest()
    var
        Matches: Record Matches;
        Groups: Record Groups;
        Pattern: Text;
        Input: Text;
    begin
        // [Given] A pattern that matches Registered Trademark symbols
        Pattern := '\b(\w+?)([\u00AE\u2122])';
        Input := 'Microsoft® Office Professional Edition combines several office productivity products, including Word, Excel®, Access®, Outlook®';

        // [When] Regex matches pattern, and the resulting MatchCollection is copied to an array 
        Regex.Match(Input, Pattern, Matches);
        Regex.Groups(Matches, Groups);

        // [Then] Checks are performed
        RegexGroupsTestCheckGroups(Matches, Groups);

        // [When] Regex matches pattern, and the resulting MatchCollection is copied to an array 
        InstanceRegex.Regex(Pattern);
        InstanceRegex.Match(Input, Matches);
        InstanceRegex.Groups(Matches, Groups);

        // [Then] Checks are performed
        RegexGroupsTestCheckGroups(Matches, Groups);
    end;

    [Test]
    procedure ReplacePatternTest()
    var
        RegexOptions: Record "Regex Options";
        Pattern: Text;
    begin
        // [Given] A pattern that matches two words that are the same
        Pattern := '\b(?<word>\w+)\s+(\k<word>)\b';
        InstanceRegex.Regex(Pattern);

        // [Then] Module replaces words that are the same (sensitive to casing)
        Assert.AreEqual('This is a Test test', Regex.Replace('This is a Test test', Pattern, 'test'), 'Regex wrongly replaced words with different casing');
        Assert.AreEqual('This is a Test test', InstanceRegex.Replace('This is a Test test', 'test'), 'Regex wrongly replaced words with different casing');
        Assert.AreEqual('This is a test', Regex.Replace('This is a test test', Pattern, 'test'), 'Regex did not replace pattern');
        Assert.AreEqual('This is a test', InstanceRegex.Replace('This is a test test', 'test'), 'Regex did not replace pattern');

        // [When] Regex is initialized with pattern and Ignore Case option 
        RegexOptions.IgnoreCase := true;
        InstanceRegex.Regex(Pattern, RegexOptions);

        // [Then] Module replaces words that are the same (insensitive to casing)
        Assert.AreEqual('This is a test', Regex.Replace('This is a Test test', Pattern, 'test', RegexOptions), 'Regex correctly replaced words with different casing');
        Assert.AreEqual('This is a test', InstanceRegex.Replace('This is a Test test', 'test'), 'Regex correctly replaced words with different casing');
    end;

    [Test]
    procedure ReplacePatternCountTest()
    var
        Pattern: Text;
        Replacement: Text;
        "Count": Integer;
        StartAt: Integer;
    begin
        // [Given] A pattern that matches sequences of the same character, a replacement and count 
        Pattern := '(.)\1+';
        Replacement := '$1';
        "Count" := 1;
        InstanceRegex.Regex(Pattern);

        // [When] Replacing based on the pattern and count
        // [Then] It replaces only the first sequence of characters (aa -> a)
        Assert.AreEqual('abbccdd', Regex.Replace('aabbccdd', Pattern, Replacement, "Count"), 'Did not replace correct character');
        Assert.AreEqual('abbccdd', InstanceRegex.Replace('aabbccdd', Replacement, "Count"), 'Did not replace correct character');

        // [When] Starting position is 1
        StartAt := 1;

        // [Then] It replaces only the first sequence of characters after starting position (bb -> b)
        Assert.AreEqual('aabccdd', Regex.Replace('aabbccdd', Pattern, Replacement, "Count", StartAt), 'Did not replace correct character');
        Assert.AreEqual('aabccdd', InstanceRegex.Replace('aabbccdd', Replacement, "Count", StartAt), 'Did not replace correct character');
    end;

    [Test]
    procedure SplitStringTest()
    var
        Pattern: Text;
        TextSplitList: List of [Text];
        "Count": Integer;
        StartAt: Integer;
    begin
        // [Given] A pattern that matches sequences of lowercase letters
        Pattern := '[a-z]+';
        "Count" := 2;
        StartAt := 6;
        InstanceRegex.Regex(Pattern);

        // [When] Running Split on a string 
        Regex.Split('1234Def5678Ghi9012', Pattern, TextSplitList);

        // [Then] It is split into three items and the first one is '1234D'
        Assert.AreEqual(3, TextSplitList.Count(), 'Did not split string into correct number of subsentences');
        Assert.AreEqual('1234D', TextSplitList.Get(1), 'Incorrect split');
        System.Clear(TextSplitList);

        // [When] Running Split on a string using the Regex pattern constructor
        InstanceRegex.Split('1234Def5678Ghi9012', TextSplitList);

        // [Then] It is split into three items and the first one is '1234D'
        Assert.AreEqual(3, TextSplitList.Count(), 'Did not split string into correct number of subsentences');
        Assert.AreEqual('1234D', TextSplitList.Get(1), 'Incorrect split');
        System.Clear(TextSplitList);

        // [When] Running Split on a string with count
        Regex.Split('1234Def5678Ghi9012abc', Pattern, "Count", TextSplitList);

        // [Then] String is only split into two items
        Assert.AreEqual(2, TextSplitList.Count(), 'Did not split (w. count) string into correct number of subsentences');
        Assert.AreEqual('1234D', TextSplitList.Get(1), 'Incorrect split with count');
        System.Clear(TextSplitList);

        // [When] Running Split on a string with count using the Regex pattern constructor
        InstanceRegex.Split('1234Def5678Ghi9012abc', "Count", TextSplitList);

        // [Then] String is only split into two items
        Assert.AreEqual(2, TextSplitList.Count(), 'Did not split (w. count) string into correct number of subsentences');
        Assert.AreEqual('1234D', TextSplitList.Get(1), 'Incorrect split with count');
        System.Clear(TextSplitList);

        // [When] Running Split on a string with count and starting position
        Regex.Split('1234Def5678Ghi9012abc', Pattern, "Count", StartAt, TextSplitList);

        // [Then] String is only split into two items
        Assert.AreEqual(2, TextSplitList.Count(), 'Did not split string (w. count & starting pos.) into correct number of subsentences');
        Assert.AreEqual('1234De', TextSplitList.Get(1), 'Incorrect split with count and starting positions');
        System.Clear(TextSplitList);

        // [When] Running Split on a string with count and starting position using the Regex pattern constructor
        InstanceRegex.Split('1234Def5678Ghi9012abc', "Count", StartAt, TextSplitList);

        // [Then] String is only split into two items
        Assert.AreEqual(2, TextSplitList.Count(), 'Did not split string (w. count & starting pos.) into correct number of subsentences');
        Assert.AreEqual('1234De', TextSplitList.Get(1), 'Incorrect split with count and starting positions');
        System.Clear(TextSplitList);
    end;

    [Test]
    procedure EscapeCharactersTest()
    var
        UnescapedString: Text;
        EscapedString: Text;
    begin
        // [Given] A pattern that matches two words that are the same
        EscapedString := '\TEST	"TEST"';
        UnescapedString := '\\TEST\t"TEST"';

        // [When] Regex is initialized with pattern
        Assert.AreEqual(EscapedString, Regex.Unescape(UnescapedString), 'Did not unescape correctly');
        Assert.AreEqual(UnescapedString, Regex.Escape(EscapedString), 'Did not escape correctly');
    end;

    [Test]
    procedure ECMAScriptRegexOptionTest()
    var
        RegexOptions: Record "Regex Options";
        Pattern: Text;
        Evaluator: Text;
    begin
        // [Given] A Regex pattern, and a string of danish characters
        Pattern := '\b(\w+\s*)+';
        Evaluator := 'æøå';
        InstanceRegex.Regex(Pattern);

        // [Then] It matches the string
        Assert.IsTrue(Regex.IsMatch(Evaluator, Pattern), 'Did not match string of danish characters');
        Assert.IsTrue(InstanceRegex.IsMatch(Evaluator), 'Did not match string of danish characters');

        // [When] Running IsMatch with ECMAScript option
        RegexOptions.ECMAScript := true;
        InstanceRegex.Regex(Pattern, RegexOptions);

        // [Then] It will not match anything
        Assert.IsFalse(Regex.IsMatch(Evaluator, Pattern, RegexOptions), 'Wrongly matched string of danish characters');
        Assert.IsFalse(InstanceRegex.IsMatch(Evaluator), 'Wrongly matched string of danish characters');
    end;

    [Test]
    procedure ExplicitCaptureRegexOptionTest()
    var
        Groups: Record Groups;
        Matches: Record Matches;
        Captures: Record Captures;
        RegexOptions: Record "Regex Options";
        Pattern: Text;
        Evaluator: Text;
    begin
        // [Given] A Regex pattern, and a string of danish characters
        Pattern := '\b\(?((?>\w+),?\s?)+[\.!?]\)?';
        Evaluator := 'This is a sentence.';
        InstanceRegex.Regex(Pattern);

        // [When] Running Matches, and extracting the captures in the first group of the first match.
        Regex.Match(Evaluator, Pattern, Matches);
        Regex.Groups(Matches, Groups);
        Groups.Get(1);

        Regex.Captures(Groups, Captures);

        // [Then] There are 2 GroupCollections, where the second one contains 4 captures (one for each word)
        Assert.AreEqual(2, Groups.Count(), 'Did not find 2 groups');
        Assert.AreEqual(4, Captures.Count(), 'Did not find 4 captures');

        // [When] Running Matches, and extracting the captures in the first group of the first match using the Regex pattern constructor.
        InstanceRegex.Match(Evaluator, Matches);
        Regex.Groups(Matches, Groups);
        Groups.Get(1);

        Regex.Captures(Groups, Captures);

        // [Then] There are 2 GroupCollections, where the second one contains 4 captures (one for each word)
        Assert.AreEqual(2, Groups.Count(), 'Did not find 2 groups');
        Assert.AreEqual(4, Captures.Count(), 'Did not find 4 captures');

        // [When] Running Matches with explicit capture, and extracting the captures in the first group of the first match.
        RegexOptions.ExplicitCapture := true;
        Regex.Match(Evaluator, Pattern, RegexOptions, Matches);
        Regex.Groups(Matches, Groups);
        Regex.Captures(Groups, Captures);

        // [Then] There is 1 GroupCollections, that contains 1 capture (the entire sentence)
        Assert.AreEqual(1, Groups.Count(), 'Did not find 1 Group');
        Assert.AreEqual(1, Captures.Count(), 'Did not find 1 Capture');

        // [When] Running Matches with explicit capture, and extracting the captures in the first group of the first match using the Regex pattern constructor.
        RegexOptions.ExplicitCapture := true;
        InstanceRegex.Regex(Pattern, RegexOptions);

        InstanceRegex.Match(Evaluator, Matches);
        InstanceRegex.Groups(Matches, Groups);
        InstanceRegex.Captures(Groups, Captures);

        // [Then] There is 1 GroupCollections, that contains 1 capture (the entire sentence)
        Assert.AreEqual(1, Groups.Count(), 'Did not find 1 Group');
        Assert.AreEqual(1, Captures.Count(), 'Did not find 1 Capture');
    end;

    [Test]
    procedure RightToLeftRegexOptionTest()
    var
        RegexOptions: Record "Regex Options";
        Pattern: Text;
        Evaluator: Text;
        IsMatched: Boolean;
    begin
        // [Given] A Regex pattern that matches words beginning with 't', and a test string.
        Pattern := '\bt\w+\s';
        Evaluator := 'testing right-left';
        InstanceRegex.Regex(Pattern);

        // [When] Matching without RegexOptions starting from index 8
        IsMatched := Regex.IsMatch(Evaluator, Pattern, 8);

        // [Then] Nothing will match
        Assert.IsFalse(IsMatched, 'Wrongly matched word');

        // [When] Matching without RegexOptions starting from index 8
        IsMatched := InstanceRegex.IsMatch(Evaluator, 8);

        // [Then] Nothing will match
        Assert.IsFalse(IsMatched, 'Wrongly matched word');

        // [When] Matching with Right-To-Left RegexOption starting from index 8
        RegexOptions.RightToLeft := true;
        InstanceRegex.Regex(Pattern, RegexOptions);

        // [Then] It will match the word 'testing', since it in the substring we match against. 
        Assert.IsTrue(Regex.IsMatch(Evaluator, Pattern, 8, RegexOptions), 'Did not match word');
        Assert.IsTrue(InstanceRegex.IsMatch(Evaluator, 8), 'Did not match word');
    end;

    local procedure GroupNameGroupNumberTestCheck(var ThisRegex: Codeunit Regex)
    var
        GroupNames: List of [Text];
        GroupNumbers: List of [Integer];
        GroupName: Text;
        GroupNumber: Integer;
    begin
        // [Then] It matches 5 groups (5 group names and 5 group numbers)
        ThisRegex.GetGroupNames(GroupNames);
        Assert.AreEqual(5, GroupNames.Count(), 'Not the right number of Groupnames');

        ThisRegex.GetGroupNumbers(GroupNumbers);
        Assert.AreEqual(5, GroupNumbers.Count(), 'Not the right number of Groupnumbers');

        // [When] Getting GroupNumberFromName FirstWord
        GroupNumber := ThisRegex.GroupNumberFromName('FirstWord');

        // [Then] We get GroupNumber 3
        Assert.AreEqual(3, GroupNumber, 'Firstword Groupname did not match');

        // [And] The GroupName for Group 3 is FirstWord
        GroupName := ThisRegex.GroupNameFromNumber(GroupNumber);
        Assert.AreEqual('FirstWord', GroupName, 'Firstword Groupname did not match');

        // [When] Getting GroupNumberFromName LastWord
        GroupNumber := ThisRegex.GroupNumberFromName('LastWord');

        // [Then] We get GroupNumber 4
        Assert.AreEqual(4, GroupNumber, 'LastWord Groupname did not match');

        // [And] The GroupName for Group 4 is LastWord
        GroupName := ThisRegex.GroupNameFromNumber(GroupNumber);
        Assert.AreEqual('LastWord', GroupName, 'LastWord Groupname did not match');
    end;

    [Test]
    procedure GroupNameGroupNumberTest()
    var
        Match: Record Matches;
        Pattern: Text;
        Input: Text;
    begin
        // [Given] A Regex pattern that matches all words but creates a Regex Group for the first and last word.
        Pattern := '\b(?<FirstWord>\w+)\s?((\w+)\s)*(?<LastWord>\w+)';
        Input := 'The cow jumped over the moon.';

        // [When] Matching with an arbitrary sentence   
        Regex.Match(Input, Pattern, Match);

        // [Then] Checks are performed
        GroupNameGroupNumberTestCheck(Regex);

        // [When] Matching with an arbitrary sentence   
        InstanceRegex.Regex(Pattern);
        InstanceRegex.Match(Input, Match);

        // [Then] Checks are performed
        GroupNameGroupNumberTestCheck(InstanceRegex);
    end;

    [Test]
    procedure MultipleOptionsTest()
    var
        Match: Record Matches;
        RegexOptions: Record "Regex Options";
        Pattern: Text;
    begin
        // [Given] A pattern that matches two words that are the same
        Pattern := '\b  P  \S*';
        InstanceRegex.Regex(Pattern);

        // [Then] Regex does match anything because of the whitespaces in
        Assert.IsFalse(Regex.IsMatch('Empower every person and organization...', Pattern), 'Wrongly found a match');
        Assert.IsFalse(InstanceRegex.IsMatch('Empower every person and organization...'), 'Wrongly found a match');

        Regex.Match('Empower every person and organization...', Pattern, Match);
        Assert.AreEqual('', Match.ReadValue(), 'Wrongly found a match, despite whitespace in pattern');

        InstanceRegex.Match('Empower every person and organization...', Match);
        Assert.AreEqual('', Match.ReadValue(), 'Wrongly found a match, despite whitespace in pattern');

        // [When] Regex is initialized with pattern and IgnorePatternWhiteSpace option
        RegexOptions.IgnorePatternWhitespace := true;
        RegexOptions.IgnoreCase := true;
        RegexOptions.Compiled := true;
        InstanceRegex.Regex(Pattern, RegexOptions);

        // [Then] Regex matches with "person"
        Assert.IsTrue(Regex.IsMatch('Empower every person and organization...', Pattern, RegexOptions), 'Did not find a match');
        Regex.Match('Empower every person and organization...', Pattern, RegexOptions, Match);
        Assert.AreEqual('person', Match.ReadValue(), 'Did not match the right word');

        Assert.IsTrue(InstanceRegex.IsMatch('Empower every person and organization...'), 'Did not find a match');
        InstanceRegex.Match('Empower every person and organization...', Match);
        Assert.AreEqual('person', Match.ReadValue(), 'Did not match the right word');
    end;

    [Test]
    procedure MatchResultTest()
    var
        Matches: Record Matches;
        Pattern: Text;
        Replacement: Text;
        Input: Text;
        ResultingText: Text;
    begin
        // [Given] A pattern that matches words within two double hyphens and an input string
        Pattern := '--(.+?)--';
        Input := 'He said--decisively--that the time--whatever time it was--had come.';

        // [When] Matching
        Regex.Match(Input, Pattern, Matches);

        // [Then] Then it matches the first word within double hyphens 
        Assert.AreEqual('--decisively--', Matches.ReadValue(), 'Did not match correctly');

        // [When] Running MatchResult with replacement pattern 
        Replacement := '($1)';
        ResultingText := Regex.MatchResult(Matches, Replacement);

        // [Then] The double hyphens were replaced with parentheses 
        Assert.AreEqual('(decisively)', ResultingText, 'Did not replace correctly');

        // [When] Matching using the Regex pattern constructor
        InstanceRegex.Regex(Pattern);
        InstanceRegex.Match(Input, Matches);

        // [Then] Then it matches the first word within double hyphens 
        Assert.AreEqual('--decisively--', Matches.ReadValue(), 'Did not match correctly');

        // [When] Running MatchResult with replacement pattern 
        Replacement := '($1)';
        ResultingText := InstanceRegex.MatchResult(Matches, Replacement);

        // [Then] The double hyphens were replaced with parentheses 
        Assert.AreEqual('(decisively)', ResultingText, 'Did not replace correctly');
    end;

    [Test]
    procedure RegexMinTimeoutTest()
    var
        Matches: Record Matches;
        RegexOptions: Record "Regex Options";
        Pattern: Text;
        Input: Text;
    begin
        // [Given] A pattern and an input 
        Pattern := '^((ab)*)+$';
        Input := 'abababababababababababab a';

        // [When] Setting the match timeout to 100
        RegexOptions.MatchTimeoutInMs := 100;

        // [Then] We get an error, because the timeout should be minimum 1000 ms 
        asserterror Regex.Match(Input, Pattern, RegexOptions, Matches);
        Assert.ExpectedError('The regular expression timeout should be at least 1000 ms');

        asserterror InstanceRegex.Regex(Pattern, RegexOptions);
        Assert.ExpectedError('The regular expression timeout should be at least 1000 ms');

        // [When] Setting the match timeout to 10001
        RegexOptions.MatchTimeoutInMs := 10001;

        // [Then] We get an error, because the timeout should be maximum 10000 ms 
        asserterror Regex.Match(Input, Pattern, RegexOptions, Matches);
        Assert.ExpectedError('The regular expression timeout should be at most 10000 ms');

        asserterror InstanceRegex.Regex(Pattern, RegexOptions);
        Assert.ExpectedError('The regular expression timeout should be at most 10000 ms');
    end;

    [Test]
    procedure RegexNotInstantiatedTest()
    var
        Matches: Record Matches;
        Input: Text;
        RegexIsNotInstanciatedErr: Label 'Regex is not Instantiated. Consider calling Regex() first or use an overload supporting a pattern.', Locked = true;
    begin
        // [Given] An input and instantiated Regex
        Input := 'ba-ba-ba-ba-ba-nana ba-ba-ba-ba-ba-nana potato-na-ah-ah...';
        InstanceRegex.Regex('');

        // [When] an instance procedure is called prior to calling the constructor
        Clear(InstanceRegex);
        asserterror InstanceRegex.Match(Input, Matches);

        // [Then] We get an error, because the DotNet class is not instanciated
        Assert.ExpectedError(RegexIsNotInstanciatedErr);
    end;

}