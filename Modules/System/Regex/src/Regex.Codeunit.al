// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality to use regular expressions to match text, split text, replace text etc.  
/// </summary>
codeunit 3960 Regex
{
    Access = Public;

    var
        RegexImpl: Codeunit "Regex Impl.";

    /// <summary>
    /// Initializes a new instance of the Regex class for the specified regular expression.
    /// </summary>
    /// <param name="Pattern">A regular expression pattern to match.</param>
    procedure Regex(Pattern: Text)
    begin
        RegexImpl.Regex(Pattern);
    end;

    /// <summary>
    /// Initializes a new instance of the Regex class for the specified regular expression, with options that modify the pattern.
    /// </summary>
    /// <param name="Pattern">A regular expression pattern to match.</param>
    /// <param name="RegexOptions">A combination of the enumeration values that modify the regular expression.</param>
    procedure Regex(Pattern: Text; var RegexOptions: Record "Regex Options")
    begin
        RegexImpl.Regex(Pattern, RegexOptions);
    end;

    /// <summary>
    /// Gets the maximum number of entries in the current static cache of compiled regular expressions.
    /// </summary>
    /// <returns>The maximum number of entries in the static cache.</returns>
    procedure GetCacheSize(): Integer
    begin
        exit(RegexImpl.GetCacheSize());
    end;

    /// <summary>
    /// Sets the maximum number of entries in the current static cache of compiled regular expressions.
    /// </summary>
    /// <param name="CacheSize">The maximum number of entries in the static cache.</param>
    procedure SetCacheSize(CacheSize: Integer)
    begin
        RegexImpl.SetCacheSize(CacheSize);
    end;

    /// <summary>
    /// Gets an array of capturing group names for the regular expression.
    /// </summary>
    /// <param name="GroupNames">An list of group names.</param>
    procedure GetGroupNames(var GroupNames: List of [Text])
    begin
        RegexImpl.GetGroupNames(GroupNames);
    end;

    /// <summary>
    /// Gets an array of capturing group numbers that correspond to group names in an array.
    /// </summary>
    /// <param name="GroupNumbers">An array of group numbers.</param>
    procedure GetGroupNumbers(var GroupNumbers: List of [Integer])
    begin
        RegexImpl.GetGroupNumbers(GroupNumbers);
    end;

    /// <summary>
    /// Gets the group name that corresponds to the specified group number.
    /// </summary>
    /// <param name="Number">The group number to convert to the corresponding group name.</param>
    /// <returns>A string that contains the group name associated with the specified group number. If there is no group name that corresponds to i, the method returns Empty.</returns>
    procedure GroupNameFromNumber(Number: Integer): Text
    begin
        exit(RegexImpl.GroupNameFromNumber(Number));
    end;

    /// <summary>
    /// Gets the group number that corresponds to the specified group name.
    /// </summary>
    /// <param name="Name">The group name to convert to the corresponding group number.</param>
    /// <returns>The group number that corresponds to the specified group name, or -1 if name is not a valid group name.</returns>
    procedure GroupNumberFromName(Name: Text): Integer
    begin
        exit(RegexImpl.GroupNumberFromName(Name))
    end;

    /// <summary>
    /// Indicates whether the regular expression finds a match in the input string, beginning at the specified starting position in the string.
    /// </summary>
    /// <param name="Input">The string to search for a match.</param>
    /// <param name="Pattern">A regular expression pattern to match.</param>
    /// <param name="StartAt">The character position at which to start the search.</param>
    /// <returns>True if the regular expression finds a match; otherwise, false.</returns>
    procedure IsMatch(Input: Text; Pattern: Text; StartAt: Integer): Boolean
    begin
        exit(RegexImpl.IsMatch(Input, Pattern, StartAt));
    end;

    /// <summary>
    /// Indicates whether the regular expression specified in the Regex constructor finds a match in the input string, beginning at the specified starting position in the string.
    /// </summary>
    /// <param name="Input">The string to search for a match.</param>
    /// <param name="StartAt">The character position at which to start the search.</param>
    /// <returns>True if the regular expression finds a match; otherwise, false.</returns>
    /// <error>Regex is not Instantiated. Consider calling Regex() first or use an overload supporting a pattern.</error>
    procedure IsMatch(Input: Text; StartAt: Integer): Boolean
    begin
        exit(RegexImpl.IsMatch(Input, StartAt));
    end;

    /// <summary>
    /// Indicates whether the regular expression finds a match in the input string, beginning at the specified starting position in the string.
    /// </summary>
    /// <param name="Input">The string to search for a match.</param>
    /// <param name="Pattern">A regular expression pattern to match.</param>
    /// <param name="StartAt">The character position at which to start the search.</param>
    /// <param name="RegexOptions">A combination of the enumeration values that modify the regular expression.</param>
    /// <returns>True if the regular expression finds a match; otherwise, false.</returns>
    procedure IsMatch(Input: Text; Pattern: Text; StartAt: Integer; var RegexOptions: Record "Regex Options"): Boolean
    begin
        exit(RegexImpl.IsMatch(Input, Pattern, StartAt, RegexOptions));
    end;

    /// <summary>
    /// Indicates whether the regular expression finds a match in the input string.
    /// </summary>
    /// <param name="Input">The string to search for a match.</param>
    /// <param name="Pattern">A regular expression pattern to match.</param>
    /// <returns>True if the regular expression finds a match; otherwise, false.</returns>
    procedure IsMatch(Input: Text; Pattern: Text): Boolean
    begin
        exit(RegexImpl.IsMatch(Input, Pattern));
    end;

    /// <summary>
    /// Indicates whether the regular expression specified in the Regex constructor finds a match in the input string.
    /// </summary>
    /// <param name="Input">The string to search for a match.</param>
    /// <returns>True if the regular expression finds a match; otherwise, false.</returns>
    /// <error>Regex is not Instantiated. Consider calling Regex() first or use an overload supporting a pattern.</error> 
    procedure IsMatch(Input: Text): Boolean
    begin
        exit(RegexImpl.IsMatch(Input));
    end;

    /// <summary>
    /// Indicates whether the specified regular expression finds a match in the specified input string, using the specified matching options.
    /// </summary>
    /// <param name="Input">The string to search for a match.</param>
    /// <param name="Pattern">A regular expression pattern to match.</param>
    /// <param name="RegexOptions">A combination of the enumeration values that modify the regular expression.</param>
    /// <returns>True if the regular expression finds a match; otherwise, false.</returns>
    procedure IsMatch(Input: Text; Pattern: Text; var RegexOptions: Record "Regex Options"): Boolean
    begin
        exit(RegexImpl.IsMatch(Input, Pattern, RegexOptions));
    end;

    /// <summary>
    /// Searches the input string for the first occurrence of a regular expression, beginning at the specified starting position in the string.
    /// </summary>
    /// <param name="Input">The string to search for a match.</param>
    /// <param name="Pattern">A regular expression pattern to match.</param>
    /// <param name="StartAt">The zero-based character position at which to start the search.</param>
    /// <param name="Matches">The Match object to write information about the match to.</param>
    procedure Match(Input: Text; Pattern: Text; StartAt: Integer; var Matches: Record Matches)
    begin
        RegexImpl.Match(Input, Pattern, StartAt, Matches);
    end;

    /// <summary>
    /// Searches the input string for the first occurrence of a regular expression specified in the Regex constructor, beginning at the specified starting position in the string.
    /// </summary>
    /// <param name="Input">The string to search for a match.</param>
    /// <param name="StartAt">The zero-based character position at which to start the search.</param>
    /// <param name="Matches">The Match object to write information about the match to.</param>
    /// <error>Regex is not Instantiated. Consider calling Regex() first or use an overload supporting a pattern.</error> 
    procedure Match(Input: Text; StartAt: Integer; var Matches: Record Matches)
    begin
        RegexImpl.Match(Input, StartAt, Matches);
    end;

    /// <summary>
    /// Searches the input string for the first occurrence of a regular expression, beginning at the specified starting position in the string.
    /// </summary>
    /// <param name="Input">The string to search for a match.</param>
    /// <param name="Pattern">A regular expression pattern to match.</param>
    /// <param name="StartAt">The zero-based character position at which to start the search.</param>
    /// <param name="RegexOptions">A combination of the enumeration values that provide options for matching.</param>
    /// <param name="Matches">The Match object to write information about the match to.</param>
    procedure Match(Input: Text; Pattern: Text; StartAt: Integer; var RegexOptions: Record "Regex Options"; var Matches: Record Matches)
    begin
        RegexImpl.Match(Input, Pattern, StartAt, RegexOptions, Matches);
    end;

    /// <summary>
    /// Searches the input string for the first occurrence of a regular expression, beginning at the specified starting position and searching only the specified number of characters.
    /// </summary>
    /// <param name="Input">The string to search for a match.</param>
    /// <param name="Pattern">A regular expression pattern to match.</param>
    /// <param name="StartAt">The zero-based character position in the input string that defines the leftmost position to be searched.</param>
    /// <param name="Length">The number of characters in the substring to include in the search.</param>
    /// <param name="Matches">The Match object to write information about the match to.</param>
    procedure Match(Input: Text; Pattern: Text; StartAt: Integer; Length: Integer; var Matches: Record Matches)
    begin
        RegexImpl.Match(Input, Pattern, StartAt, Length, Matches);
    end;

    /// <summary>
    /// Searches the input string for the first occurrence of a regular expression specified in the Regex constructor, beginning at the specified starting position and searching only the specified number of characters.
    /// </summary>
    /// <param name="Input">The string to search for a match.</param>
    /// <param name="StartAt">The zero-based character position in the input string that defines the leftmost position to be searched.</param>
    /// <param name="Length">The number of characters in the substring to include in the search.</param>
    /// <param name="Matches">The Match object to write information about the match to.</param>
    /// <error>Regex is not Instantiated. Consider calling Regex() first or use an overload supporting a pattern.</error>
    procedure Match(Input: Text; StartAt: Integer; Length: Integer; var Matches: Record Matches)
    begin
        RegexImpl.Match(Input, StartAt, Length, Matches);
    end;

    /// <summary>
    /// Searches the input string for the first occurrence of a regular expression, beginning at the specified starting position and searching only the specified number of characters.
    /// </summary>
    /// <param name="Input">The string to search for a match.</param>
    /// <param name="Pattern">A regular expression pattern to match.</param>
    /// <param name="StartAt">The zero-based character position in the input string that defines the leftmost position to be searched.</param>
    /// <param name="Length">The number of characters in the substring to include in the search.</param>
    /// <param name="RegexOptions">A combination of the enumeration values that provide options for matching.</param>
    /// <param name="Matches">The Match object to write information about the match to.</param>
    procedure Match(Input: Text; Pattern: Text; StartAt: Integer; Length: Integer; var RegexOptions: Record "Regex Options"; var Matches: Record Matches)
    begin
        RegexImpl.Match(Input, Pattern, StartAt, Length, RegexOptions, Matches);
    end;

    /// <summary>
    /// Searches the input string for the first occurrence of the specified regular expression, using the specified matching options.
    /// </summary>
    /// <param name="Input">The string to search for a match.</param>
    /// <param name="Pattern">A regular expression pattern to match.</param>
    /// <param name="Matches">The Match object to write information about the match to.</param>
    procedure Match(Input: Text; Pattern: Text; var Matches: Record Matches)
    begin
        RegexImpl.Match(Input, Pattern, Matches);
    end;

    /// <summary>
    /// Searches the input string for the first occurrence of the specified regular expression specified in the Regex constructor, using the specified matching options.
    /// </summary>
    /// <param name="Input">The string to search for a match.</param>
    /// <param name="Pattern">A regular expression pattern to match.</param>
    /// <param name="Matches">The Match object to write information about the match to.</param>
    /// <error>Regex is not Instantiated. Consider calling Regex() first or use an overload supporting a pattern.</error>
    procedure Match(Input: Text; var Matches: Record Matches)
    begin
        RegexImpl.Match(Input, Matches);
    end;

    /// <summary>
    /// Searches the input string for the first occurrence of the specified regular expression, using the specified matching options.
    /// </summary>
    /// <param name="Input">The string to search for a match.</param>
    /// <param name="Pattern">A regular expression pattern to match.</param>
    /// <param name="RegexOptions">A combination of the enumeration values that provide options for matching.</param>
    /// <param name="Matches">The Match object to write information about the match to.</param>
    procedure Match(Input: Text; Pattern: Text; var RegexOptions: Record "Regex Options"; var Matches: Record Matches)
    begin
        RegexImpl.Match(Input, Pattern, RegexOptions, Matches);
    end;

    /// <summary>
    /// Replaces strings that match a regular expression pattern with a specified replacement string.
    /// </summary>
    /// <param name="Input">The string to search for a match.</param>
    /// <param name="Pattern">A regular expression pattern to match.</param>
    /// <param name="Replacement">The replacement string.</param>
    /// <param name="Count">The maximum number of times the replacement can occur.</param>
    /// <returns>A new string that is identical to the input string, except that the replacement string takes the place of each matched string. If the pattern is not matched the method returns the current instance unchanged</returns>
    procedure Replace(Input: Text; Pattern: Text; Replacement: Text; "Count": Integer): Text
    begin
        exit(RegexImpl.Replace(Input, Pattern, Replacement, "Count"));
    end;

    /// <summary>
    /// Replaces strings that match a regular expression pattern specified in the Regex constructor with a specified replacement string.
    /// </summary>
    /// <param name="Input">The string to search for a match.</param>
    /// <param name="Replacement">The replacement string.</param>
    /// <param name="Count">The maximum number of times the replacement can occur.</param>
    /// <returns>A new string that is identical to the input string, except that the replacement string takes the place of each matched string. If the pattern is not matched the method returns the current instance unchanged</returns>
    /// <error>Regex is not Instantiated. Consider calling Regex() first or use an overload supporting a pattern.</error>
    procedure Replace(Input: Text; Replacement: Text; "Count": Integer): Text
    begin
        exit(RegexImpl.Replace(Input, Replacement, "Count"));
    end;

    /// <summary>
    /// Replaces strings that match a regular expression pattern with a specified replacement string.
    /// </summary>
    /// <param name="Input">The string to search for a match.</param>
    /// <param name="Pattern">A regular expression pattern to match.</param>
    /// <param name="Replacement">The replacement string.</param>
    /// <param name="Count">The maximum number of times the replacement can occur.</param>
    /// <param name="RegexOptions">A combination of the enumeration values that provide options for matching.</param>
    /// <returns>A new string that is identical to the input string, except that the replacement string takes the place of each matched string. If the pattern is not matched the method returns the current instance unchanged</returns>
    procedure Replace(Input: Text; Pattern: Text; Replacement: Text; "Count": Integer; var RegexOptions: Record "Regex Options"): Text
    begin
        exit(RegexImpl.Replace(Input, Pattern, Replacement, "Count", RegexOptions));
    end;

    /// <summary>
    /// In a specified input substring, replaces a specified maximum number of strings that match a regular expression pattern with a specified replacement string.
    /// </summary>
    /// <param name="Input">The string to search for a match.</param>
    /// <param name="Pattern">A regular expression pattern to match.</param>
    /// <param name="Replacement">The replacement string.</param>
    /// <param name="Count">The maximum number of times the replacement can occur.</param>
    /// <param name="StartAt">The character position in the input string where the search begins.</param>
    /// <returns>A new string that is identical to the input string, except that the replacement string takes the place of each matched string. If the pattern is not matched the method returns the current instance unchanged</returns>
    procedure Replace(Input: Text; Pattern: Text; Replacement: Text; "Count": Integer; StartAt: Integer): Text
    begin
        exit(RegexImpl.Replace(Input, Pattern, Replacement, "Count", StartAt));
    end;

    /// <summary>
    /// In a specified input substring, replaces a specified maximum number of strings that match a regular expression pattern specified in the Regex constructor with a specified replacement string.
    /// </summary>
    /// <param name="Input">The string to search for a match.</param>
    /// <param name="Replacement">The replacement string.</param>
    /// <param name="Count">The maximum number of times the replacement can occur.</param>
    /// <param name="StartAt">The character position in the input string where the search begins.</param>
    /// <returns>A new string that is identical to the input string, except that the replacement string takes the place of each matched string. If the pattern is not matched the method returns the current instance unchanged</returns>
    /// <error>Regex is not Instantiated. Consider calling Regex() first or use an overload supporting a pattern.</error>
    procedure Replace(Input: Text; Replacement: Text; "Count": Integer; StartAt: Integer): Text
    begin
        exit(RegexImpl.Replace(Input, Replacement, "Count", StartAt));
    end;

    /// <summary>
    /// In a specified input substring, replaces a specified maximum number of strings that match a regular expression pattern with a specified replacement string.
    /// </summary>
    /// <param name="Input">The string to search for a match.</param>
    /// <param name="Pattern">A regular expression pattern to match.</param>
    /// <param name="Replacement">The replacement string.</param>
    /// <param name="Count">The maximum number of times the replacement can occur.</param>
    /// <param name="StartAt">The character position in the input string where the search begins.</param>
    /// <param name="RegexOptions">A combination of the enumeration values that provide options for matching.</param>
    /// <returns>A new string that is identical to the input string, except that the replacement string takes the place of each matched string. If the pattern is not matched the method returns the current instance unchanged</returns>
    procedure Replace(Input: Text; Pattern: Text; Replacement: Text; "Count": Integer; StartAt: Integer; var RegexOptions: Record "Regex Options"): Text
    begin
        exit(RegexImpl.Replace(Input, Pattern, Replacement, "Count", StartAt, RegexOptions));
    end;

    /// <summary>
    /// Replaces all strings that match a specified regular expression with a specified replacement string.
    /// </summary>
    /// <param name="Input">The string to search for a match.</param>
    /// <param name="Pattern">A regular expression pattern to match.</param>
    /// <param name="Replacement">The replacement string.</param>
    /// <returns>A new string that is identical to the input string, except that the replacement string takes the place of each matched string. If the pattern is not matched the method returns the current instance unchanged</returns>
    procedure Replace(Input: Text; Pattern: Text; Replacement: Text): Text
    begin
        exit(RegexImpl.Replace(Input, Pattern, Replacement));
    end;

    /// <summary>
    /// Replaces all strings that match a specified regular expression specified in the Regex constructor with a specified replacement string.
    /// </summary>
    /// <param name="Input">The string to search for a match.</param>
    /// <param name="Replacement">The replacement string.</param>
    /// <returns>A new string that is identical to the input string, except that the replacement string takes the place of each matched string. If the pattern is not matched the method returns the current instance unchanged</returns>
    /// <error>Regex is not Instantiated. Consider calling Regex() first or use an overload supporting a pattern.</error>
    procedure Replace(Input: Text; Replacement: Text): Text
    begin
        exit(RegexImpl.Replace(Input, Replacement));
    end;

    /// <summary>
    /// Replaces all strings that match a specified regular expression with a specified replacement string. Specified options modify the matching operation.
    /// </summary>
    /// <param name="Input">The string to search for a match.</param>
    /// <param name="Pattern">A regular expression pattern to match.</param>
    /// <param name="Replacement">The replacement string.</param>
    /// <param name="RegexOptions">A combination of the enumeration values that provide options for matching.</param>
    /// <returns>A new string that is identical to the input string, except that the replacement string takes the place of each matched string. If the pattern is not matched the method returns the current instance unchanged</returns>
    procedure Replace(Input: Text; Pattern: Text; Replacement: Text; var RegexOptions: Record "Regex Options"): Text
    begin
        exit(RegexImpl.Replace(Input, Pattern, Replacement, RegexOptions));
    end;

    /// <summary>
    /// Splits an input string a specified maximum number of times into an array of substrings, at the positions defined by a regular expression pattern.
    /// </summary>
    /// <param name="Input">The string to split.</param>
    /// <param name="Pattern">A regular expression pattern to match.</param>
    /// <param name="Count">The maximum number of times the split can occur.</param>
    /// <param name="Array">An empty list that will be populated with the result of the split query.</param>
    procedure Split(Input: Text; Pattern: Text; "Count": Integer; var "Array": List of [Text])
    begin
        RegexImpl.Split(Input, Pattern, "Count", "Array");
    end;

    /// <summary>
    /// Splits an input string a specified maximum number of times into an array of substrings, at the positions defined by a regular expression pattern specified in the Regex constructor.
    /// </summary>
    /// <param name="Input">The string to split.</param>
    /// <param name="Count">The maximum number of times the split can occur.</param>
    /// <param name="Array">An empty list that will be populated with the result of the split query.</param>
    /// <error>Regex is not Instantiated. Consider calling Regex() first or use an overload supporting a pattern.</error>
    procedure Split(Input: Text; "Count": Integer; var "Array": List of [Text])
    begin
        RegexImpl.Split(Input, "Count", "Array");
    end;

    /// <summary>
    /// Splits an input string a specified maximum number of times into an array of substrings, at the positions defined by a regular expression pattern.
    /// </summary>
    /// <param name="Input">The string to split.</param>
    /// <param name="Pattern">A regular expression pattern to match.</param>
    /// <param name="Count">The maximum number of times the split can occur.</param>
    /// <param name="RegexOptions">A combination of the enumeration values that provide options for matching.</param>
    /// <param name="Array">An empty list that will be populated with the result of the split query.</param>
    procedure Split(Input: Text; Pattern: Text; "Count": Integer; var RegexOptions: Record "Regex Options"; var "Array": List of [Text])
    begin
        RegexImpl.Split(Input, Pattern, "Count", RegexOptions, "Array");
    end;

    /// <summary>
    /// Splits an input string a specified maximum number of times into an array of substrings, at the positions defined by a regular expression pattern. The search for the pattern starts at a specified character position in the input string.
    /// </summary>
    /// <param name="Input">The string to split.</param>
    /// <param name="Pattern">A regular expression pattern to match.</param>
    /// <param name="Count">The maximum number of times the split can occur.</param>
    /// <param name="StartAt">The character position in the input string where the search will begin.</param>
    /// <param name="Array">An empty list that will be populated with the result of the split query.</param>
    procedure Split(Input: Text; Pattern: Text; "Count": Integer; StartAt: Integer; var "Array": List of [Text])
    begin
        RegexImpl.Split(Input, Pattern, "Count", StartAt, "Array");
    end;

    /// <summary>
    /// Splits an input string a specified maximum number of times into an array of substrings, at the positions defined by a regular expression pattern specified in the Regex constructor. The search for the pattern starts at a specified character position in the input string.
    /// </summary>
    /// <param name="Input">The string to split.</param>
    /// <param name="Count">The maximum number of times the split can occur.</param>
    /// <param name="StartAt">The character position in the input string where the search will begin.</param>
    /// <param name="Array">An empty list that will be populated with the result of the split query.</param>
    /// <error>Regex is not Instantiated. Consider calling Regex() first or use an overload supporting a pattern.</error>
    procedure Split(Input: Text; "Count": Integer; StartAt: Integer; var "Array": List of [Text])
    begin
        RegexImpl.Split(Input, "Count", StartAt, "Array");
    end;

    /// <summary>
    /// Splits an input string a specified maximum number of times into an array of substrings, at the positions defined by a regular expression pattern. The search for the pattern starts at a specified character position in the input string.
    /// </summary>
    /// <param name="Input">The string to split.</param>
    /// <param name="Pattern">A regular expression pattern to match.</param>
    /// <param name="Count">The maximum number of times the split can occur.</param>
    /// <param name="StartAt">The character position in the input string where the search will begin.</param>
    /// <param name="RegexOptions">A combination of the enumeration values that provide options for matching.</param>
    /// <param name="Array">An empty list that will be populated with the result of the split query.</param>
    procedure Split(Input: Text; Pattern: Text; "Count": Integer; StartAt: Integer; var RegexOptions: Record "Regex Options"; var "Array": List of [Text])
    begin
        RegexImpl.Split(Input, Pattern, "Count", StartAt, RegexOptions, "Array");
    end;

    /// <summary>
    /// Splits an input string a specified maximum number of times into an array of substrings, at the positions defined by a regular expression pattern. Specified options modify the matching operation.
    /// </summary>
    /// <param name="Input">The string to split.</param>
    /// <param name="Pattern">A regular expression pattern to match.</param>
    /// <param name="Array">An empty list that will be populated with the result of the split query.</param>
    procedure Split(Input: Text; Pattern: Text; var "Array": List of [Text])
    begin
        RegexImpl.Split(Input, Pattern, "Array");
    end;

    /// <summary>
    /// Splits an input string a specified maximum number of times into an array of substrings, at the positions defined by a regular expression pattern specified in the Regex constructor. Specified options modify the matching operation.
    /// </summary>
    /// <param name="Input">The string to split.</param>
    /// <param name="Array">An empty list that will be populated with the result of the split query.</param>
    /// <error>Regex is not Instantiated. Consider calling Regex() first or use an overload supporting a pattern.</error>
    procedure Split(Input: Text; var "Array": List of [Text])
    begin
        RegexImpl.Split(Input, "Array");
    end;

    /// <summary>
    /// Splits an input string a specified maximum number of times into an array of substrings, at the positions defined by a regular expression pattern. Specified options modify the matching operation.
    /// </summary>
    /// <param name="Input">The string to split.</param>
    /// <param name="Pattern">A regular expression pattern to match.</param>
    /// <param name="RegexOptions">A combination of the enumeration values that provide options for matching.</param>
    /// <param name="Array">An empty list that will be populated with the result of the split query.</param>
    procedure Split(Input: Text; Pattern: Text; var RegexOptions: Record "Regex Options"; var "Array": List of [Text])
    begin
        RegexImpl.Split(Input, Pattern, RegexOptions, "Array");
    end;

    /// <summary>
    /// Serves as the default hash function.
    /// </summary>
    /// <returns>A hash code for the current object.</returns>
    procedure GetHashCode(): Integer
    begin
        exit(RegexImpl.GetHashCode());
    end;

    /// <summary>
    /// Escapes a minimal set of characters (\, *, +, ?, |, {, [, (,), ^, $, ., #, and white space) by replacing them with their escape codes. 
    /// </summary>
    /// <param name="String">The input string that contains the text to convert.</param>
    /// <returns>A string of characters with metacharacters converted to their escaped form.</returns>
    procedure Escape(String: Text): Text
    begin
        exit(RegexImpl.Escape(String));
    end;

    /// <summary>
    /// Converts any escaped characters in the input string.
    /// </summary>
    /// <param name="String">The input string containing the text to convert.</param>
    /// <returns>A string of characters with any escaped characters converted to their unescaped form.</returns>
    procedure Unescape(String: Text): Text
    begin
        exit(RegexImpl.Unescape(String));
    end;

    /// <summary>
    /// Get the Groups for one particular Match.
    /// </summary>
    /// <param name="Matches">The Match record to get Groups for.</param>
    /// <param name="Groups">Groups Record to write the resulting Groups to.</param>
    procedure Groups(var Matches: Record Matches; var Groups: Record Groups)
    begin
        RegexImpl.Groups(Matches, Groups)
    end;

    /// <summary>
    /// Get the Captures for one particular Group.
    /// </summary>
    /// <param name="Group">The Group record to get Captures for.</param>
    /// <param name="Captures">Captures Record to write the resulting Captures to.</param>
    procedure Captures(var Group: Record Groups; var Captures: Record Captures)
    begin
        RegexImpl.Captures(Group, Captures)
    end;

    /// <summary>
    /// Returns the expansion of the specified replacement pattern.
    /// </summary>
    /// <param name="Matches">The Match Record to perform replacement on.</param>
    /// <param name="Replacement">The replacement pattern to use.</param>
    /// <returns>The expanded version of the replacement parameter.</returns>
    procedure MatchResult(var Matches: Record Matches; Replacement: Text): Text
    begin
        exit(RegexImpl.MatchResult(Matches, Replacement));
    end;
}