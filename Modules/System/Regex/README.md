This module provides an interface, that lets you use regular expresssions.

You can use this module to: 
- Check for a match given a pattern and a target 
- Return all matches of a regular expression
- Replace text based on regular expressions
- Split text into a list of substrings
- Escape and Unescape text
# Public Objects
## Captures (Table 3963)

 Provides a representation of Regex Captures that models Capture objects in .Net
 

### ReadValue (Method) <a name="ReadValue"></a> 

 Reads the value of the capture
 

#### Syntax
```
procedure ReadValue()TextValue: Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The value of the capture.

## Groups (Table 3964)

 Provides a representation of Regex Groups that models Group objects in .Net
 

### ReadValue (Method) <a name="ReadValue"></a> 

 Reads the value of the group
 

#### Syntax
```
procedure ReadValue()TextValue: Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The value of the group.

## Matches (Table 3965)

 Provides a representation of Regex Matches that models Match objects in .Net
 

### ReadValue (Method) <a name="ReadValue"></a> 

 Reads the value of the match
 

#### Syntax
```
procedure ReadValue()TextValue: Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The value of the match.

## Regex Options (Table 3966)

 Table with options to use with Regular Expressions
 

### GetRegexOptions (Method) <a name="GetRegexOptions"></a> 

 Gets the integer-representation of the combined regex options.
 

#### Syntax
```
procedure GetRegexOptions(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

An integer for the combined regex options.

## Regex (Codeunit 3960)

 Provides functionality to use regular expressions to match text, split text, replace text etc.
 

### GetCacheSize (Method) <a name="GetCacheSize"></a> 

 Gets the maximum number of entries in the current static cache of compiled regular expressions
 

#### Syntax
```
procedure GetCacheSize(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The maximum number of entries in the static cache.
### SetCacheSize (Method) <a name="SetCacheSize"></a> 

 Sets the maximum number of entries in the current static cache of compiled regular expressions
 

#### Syntax
```
procedure SetCacheSize(CacheSize: Integer)
```
#### Parameters
*CacheSize ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The maximum number of entries in the static cache.

### GetGroupNames (Method) <a name="GetGroupNames"></a> 

 Gets an array of capturing group names for the regular expression.
 

#### Syntax
```
procedure GetGroupNames(var GroupNames: List of [Text])
```
#### Parameters
*GroupNames ([List of [Text]]())* 

An list of group names.

### GetGroupNumbers (Method) <a name="GetGroupNumbers"></a> 

 Gets an array of capturing group numbers that correspond to group names in an array.
 

#### Syntax
```
procedure GetGroupNumbers(var GroupNumbers: List of [Integer])
```
#### Parameters
*GroupNumbers ([List of [Integer]]())* 

An array of group numbers.

### GroupNameFromNumber (Method) <a name="GroupNameFromNumber"></a> 

 Gets the group name that corresponds to the specified group number.
 

#### Syntax
```
procedure GroupNameFromNumber(Number: Integer): Text
```
#### Parameters
*Number ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The group number to convert to the corresponding group name.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

A string that contains the group name associated with the specified group number. If there is no group name that corresponds to i, the method returns Empty.
### GroupNumberFromName (Method) <a name="GroupNumberFromName"></a> 

 Gets the group number that corresponds to the specified group name.
 

#### Syntax
```
procedure GroupNumberFromName(Name: Text): Integer
```
#### Parameters
*Name ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The group name to convert to the corresponding group number.

#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The group number that corresponds to the specified group name, or -1 if name is not a valid group name.
### IsMatch (Method) <a name="IsMatch"></a> 

 Indicates whether the regular expression finds a match in the input string, beginning at the specified starting position in the string.
 

#### Syntax
```
procedure IsMatch(Input: Text; Pattern: Text; StartAt: Integer): Boolean
```
#### Parameters
*Input ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to search for a match.

*Pattern ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A regular expression pattern to match.

*StartAt ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The character position at which to start the search.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the regular expression finds a match; otherwise, false.
### IsMatch (Method) <a name="IsMatch"></a> 

 Indicates whether the regular expression finds a match in the input string, beginning at the specified starting position in the string.
 

#### Syntax
```
procedure IsMatch(Input: Text; Pattern: Text; StartAt: Integer; var RegexOptions: Record "Regex Options"): Boolean
```
#### Parameters
*Input ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to search for a match.

*Pattern ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A regular expression pattern to match.

*StartAt ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The character position at which to start the search.

*RegexOptions ([Record "Regex Options"]())* 

A combination of the enumeration values that modify the regular expression.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the regular expression finds a match; otherwise, false.
### IsMatch (Method) <a name="IsMatch"></a> 

 Indicates whether the regular expression finds a match in the input string.
 

#### Syntax
```
procedure IsMatch(Input: Text; Pattern: Text): Boolean
```
#### Parameters
*Input ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to search for a match.

*Pattern ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A regular expression pattern to match.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the regular expression finds a match; otherwise, false.
### IsMatch (Method) <a name="IsMatch"></a> 

 Indicates whether the specified regular expression finds a match in the specified input string, using the specified matching options.
 

#### Syntax
```
procedure IsMatch(Input: Text; Pattern: Text; var RegexOptions: Record "Regex Options"): Boolean
```
#### Parameters
*Input ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to search for a match.

*Pattern ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A regular expression pattern to match.

*RegexOptions ([Record "Regex Options"]())* 

A combination of the enumeration values that modify the regular expression.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the regular expression finds a match; otherwise, false.
### Match (Method) <a name="Match"></a> 

 Searches the input string for the first occurrence of a regular expression, beginning at the specified starting position in the string.
 

#### Syntax
```
procedure Match(Input: Text; Pattern: Text; StartAt: Integer; var Matches: Record Matches)
```
#### Parameters
*Input ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to search for a match.

*Pattern ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A regular expression pattern to match.

*StartAt ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The zero-based character position at which to start the search.

*Matches ([Record Matches]())* 

The Match object to write information about the match to.

### Match (Method) <a name="Match"></a> 

 Searches the input string for the first occurrence of a regular expression, beginning at the specified starting position in the string.
 

#### Syntax
```
procedure Match(Input: Text; Pattern: Text; StartAt: Integer; var RegexOptions: Record "Regex Options"; var Matches: Record Matches)
```
#### Parameters
*Input ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to search for a match.

*Pattern ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A regular expression pattern to match.

*StartAt ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The zero-based character position at which to start the search.

*RegexOptions ([Record "Regex Options"]())* 

A combination of the enumeration values that provide options for matching.

*Matches ([Record Matches]())* 

The Match object to write information about the match to.

### Match (Method) <a name="Match"></a> 

 Searches the input string for the first occurrence of a regular expression, beginning at the specified starting position and searching only the specified number of characters.
 

#### Syntax
```
procedure Match(Input: Text; Pattern: Text; Beginning: Integer; Length: Integer; var Matches: Record Matches)
```
#### Parameters
*Input ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to search for a match.

*Pattern ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A regular expression pattern to match.

*Beginning ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The zero-based character position in the input string that defines the leftmost position to be searched.

*Length ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The number of characters in the substring to include in the search.

*Matches ([Record Matches]())* 

The Match object to write information about the match to.

### Match (Method) <a name="Match"></a> 

 Searches the input string for the first occurrence of a regular expression, beginning at the specified starting position and searching only the specified number of characters.
 

#### Syntax
```
procedure Match(Input: Text; Pattern: Text; Beginning: Integer; Length: Integer; var RegexOptions: Record "Regex Options"; var Matches: Record Matches)
```
#### Parameters
*Input ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to search for a match.

*Pattern ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A regular expression pattern to match.

*Beginning ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The zero-based character position in the input string that defines the leftmost position to be searched.

*Length ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The number of characters in the substring to include in the search.

*RegexOptions ([Record "Regex Options"]())* 

A combination of the enumeration values that provide options for matching.

*Matches ([Record Matches]())* 

The Match object to write information about the match to.

### Match (Method) <a name="Match"></a> 

 Searches the input string for the first occurrence of the specified regular expression, using the specified matching options.
 

#### Syntax
```
procedure Match(Input: Text; Pattern: Text; var Matches: Record Matches)
```
#### Parameters
*Input ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to search for a match.

*Pattern ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A regular expression pattern to match.

*Matches ([Record Matches]())* 

The Match object to write information about the match to.

### Match (Method) <a name="Match"></a> 

 Searches the input string for the first occurrence of the specified regular expression, using the specified matching options.
 

#### Syntax
```
procedure Match(Input: Text; Pattern: Text; var RegexOptions: Record "Regex Options"; var Matches: Record Matches)
```
#### Parameters
*Input ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to search for a match.

*Pattern ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A regular expression pattern to match.

*RegexOptions ([Record "Regex Options"]())* 

A combination of the enumeration values that provide options for matching.

*Matches ([Record Matches]())* 

The Match object to write information about the match to.

### Replace (Method) <a name="Replace"></a> 

 Replaces strings that match a regular expression pattern with a specified replacement string.
 

#### Syntax
```
procedure Replace(Input: Text; Pattern: Text; Replacement: Text; "Count": Integer): Text
```
#### Parameters
*Input ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to search for a match.

*Pattern ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A regular expression pattern to match.

*Replacement ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The replacement string.

*Count ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The maximum number of times the replacement can occur.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

A new string that is identical to the input string, except that the replacement string takes the place of each matched string. If the pattern is not matched the method returns the current instance unchanged
### Replace (Method) <a name="Replace"></a> 

 Replaces strings that match a regular expression pattern with a specified replacement string.
 

#### Syntax
```
procedure Replace(Input: Text; Pattern: Text; Replacement: Text; "Count": Integer; var RegexOptions: Record "Regex Options"): Text
```
#### Parameters
*Input ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to search for a match.

*Pattern ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A regular expression pattern to match.

*Replacement ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The replacement string.

*Count ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The maximum number of times the replacement can occur.

*RegexOptions ([Record "Regex Options"]())* 

A combination of the enumeration values that provide options for matching.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

A new string that is identical to the input string, except that the replacement string takes the place of each matched string. If the pattern is not matched the method returns the current instance unchanged
### Replace (Method) <a name="Replace"></a> 

 In a specified input substring, replaces a specified maximum number of strings that match a regular expression pattern with a specified replacement string.
 

#### Syntax
```
procedure Replace(Input: Text; Pattern: Text; Replacement: Text; "Count": Integer; StartAt: Integer): Text
```
#### Parameters
*Input ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to search for a match.

*Pattern ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A regular expression pattern to match.

*Replacement ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The replacement string.

*Count ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The maximum number of times the replacement can occur.

*StartAt ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The character position in the input string where the search begins.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

A new string that is identical to the input string, except that the replacement string takes the place of each matched string. If the pattern is not matched the method returns the current instance unchanged
### Replace (Method) <a name="Replace"></a> 

 In a specified input substring, replaces a specified maximum number of strings that match a regular expression pattern with a specified replacement string.
 

#### Syntax
```
procedure Replace(Input: Text; Pattern: Text; Replacement: Text; "Count": Integer; StartAt: Integer; var RegexOptions: Record "Regex Options"): Text
```
#### Parameters
*Input ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to search for a match.

*Pattern ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A regular expression pattern to match.

*Replacement ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The replacement string.

*Count ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The maximum number of times the replacement can occur.

*StartAt ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The character position in the input string where the search begins.

*RegexOptions ([Record "Regex Options"]())* 

A combination of the enumeration values that provide options for matching.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

A new string that is identical to the input string, except that the replacement string takes the place of each matched string. If the pattern is not matched the method returns the current instance unchanged
### Replace (Method) <a name="Replace"></a> 

 Replaces all strings that match a specified regular expression with a specified replacement string.
 

#### Syntax
```
procedure Replace(Input: Text; Pattern: Text; Replacement: Text): Text
```
#### Parameters
*Input ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to search for a match.

*Pattern ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A regular expression pattern to match.

*Replacement ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The replacement string.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

A new string that is identical to the input string, except that the replacement string takes the place of each matched string. If the pattern is not matched the method returns the current instance unchanged
### Replace (Method) <a name="Replace"></a> 

 Replaces all strings that match a specified regular expression with a specified replacement string. Specified options modify the matching operation.
 

#### Syntax
```
procedure Replace(Input: Text; Pattern: Text; Replacement: Text; var RegexOptions: Record "Regex Options"): Text
```
#### Parameters
*Input ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to search for a match.

*Pattern ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A regular expression pattern to match.

*Replacement ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The replacement string.

*RegexOptions ([Record "Regex Options"]())* 

A combination of the enumeration values that provide options for matching.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

A new string that is identical to the input string, except that the replacement string takes the place of each matched string. If the pattern is not matched the method returns the current instance unchanged
### Split (Method) <a name="Split"></a> 

 Splits an input string a specified maximum number of times into an array of substrings, at the positions defined by a regular expression specified in the Regex constructor.
 

#### Syntax
```
procedure Split(Input: Text; Pattern: Text; "Count": Integer; var "Array": List of [Text])
```
#### Parameters
*Input ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to split.

*Pattern ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A regular expression pattern to match.

*Count ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The maximum number of times the split can occur.

*Array ([List of [Text]]())* 

An empty list that will be populated with the result of the split query.

### Split (Method) <a name="Split"></a> 

 Splits an input string a specified maximum number of times into an array of substrings, at the positions defined by a regular expression specified in the Regex constructor.
 

#### Syntax
```
procedure Split(Input: Text; Pattern: Text; "Count": Integer; var RegexOptions: Record "Regex Options"; var "Array": List of [Text])
```
#### Parameters
*Input ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to split.

*Pattern ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A regular expression pattern to match.

*Count ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The maximum number of times the split can occur.

*RegexOptions ([Record "Regex Options"]())* 

A combination of the enumeration values that provide options for matching.

*Array ([List of [Text]]())* 

An empty list that will be populated with the result of the split query.

### Split (Method) <a name="Split"></a> 

 Splits an input string a specified maximum number of times into an array of substrings, at the positions defined by a regular expression specified in the Regex constructor. The search for the regular expression pattern starts at a specified character position in the input string.
 

#### Syntax
```
procedure Split(Input: Text; Pattern: Text; "Count": Integer; StartAt: Integer; var "Array": List of [Text])
```
#### Parameters
*Input ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to split.

*Pattern ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A regular expression pattern to match.

*Count ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The maximum number of times the split can occur.

*StartAt ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The character position in the input string where the search will begin.

*Array ([List of [Text]]())* 

An empty list that will be populated with the result of the split query.

### Split (Method) <a name="Split"></a> 

 Splits an input string a specified maximum number of times into an array of substrings, at the positions defined by a regular expression specified in the Regex constructor. The search for the regular expression pattern starts at a specified character position in the input string.
 

#### Syntax
```
procedure Split(Input: Text; Pattern: Text; "Count": Integer; StartAt: Integer; var RegexOptions: Record "Regex Options"; var "Array": List of [Text])
```
#### Parameters
*Input ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to split.

*Pattern ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A regular expression pattern to match.

*Count ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The maximum number of times the split can occur.

*StartAt ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The character position in the input string where the search will begin.

*RegexOptions ([Record "Regex Options"]())* 

A combination of the enumeration values that provide options for matching.

*Array ([List of [Text]]())* 

An empty list that will be populated with the result of the split query.

### Split (Method) <a name="Split"></a> 

 Splits an input string a specified maximum number of times into an array of substrings, at the positions defined by a regular expression specified in the Regex constructor. Specified options modify the matching operation.
 

#### Syntax
```
procedure Split(Input: Text; Pattern: Text; var "Array": List of [Text])
```
#### Parameters
*Input ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to split.

*Pattern ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A regular expression pattern to match.

*Array ([List of [Text]]())* 

An empty list that will be populated with the result of the split query.

### Split (Method) <a name="Split"></a> 

 Splits an input string a specified maximum number of times into an array of substrings, at the positions defined by a regular expression specified in the Regex constructor. Specified options modify the matching operation.
 

#### Syntax
```
procedure Split(Input: Text; Pattern: Text; var RegexOptions: Record "Regex Options"; var "Array": List of [Text])
```
#### Parameters
*Input ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string to split.

*Pattern ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A regular expression pattern to match.

*RegexOptions ([Record "Regex Options"]())* 

A combination of the enumeration values that provide options for matching.

*Array ([List of [Text]]())* 

An empty list that will be populated with the result of the split query.

### GetHashCode (Method) <a name="GetHashCode"></a> 

 Serves as the default hash function.
 

#### Syntax
```
procedure GetHashCode(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

A hash code for the current object.
### Escape (Method) <a name="Escape"></a> 

 Escapes a minimal set of characters (\, *, +, ?, |, {, [, (,), ^, $, ., #, and white space) by replacing them with their escape codes.
 

#### Syntax
```
procedure Escape(String: Text): Text
```
#### Parameters
*String ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The input string that contains the text to convert.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

A string of characters with metacharacters converted to their escaped form.
### Unescape (Method) <a name="Unescape"></a> 

 Converts any escaped characters in the input string.
 

#### Syntax
```
procedure Unescape(String: Text): Text
```
#### Parameters
*String ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The input string containing the text to convert.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

A string of characters with any escaped characters converted to their unescaped form.
### Groups (Method) <a name="Groups"></a> 

 Get the Groups for one particular Match
 

#### Syntax
```
procedure Groups(var Matches: Record Matches; var Groups: Record Groups)
```
#### Parameters
*Matches ([Record Matches]())* 

The Match record to get Groups for.

*Groups ([Record Groups]())* 

Groups Record to write the resulting Groups to.

### Captures (Method) <a name="Captures"></a> 

 Get the Captures for one particular Group
 

#### Syntax
```
procedure Captures(var Group: Record Groups; var Captures: Record Captures)
```
#### Parameters
*Group ([Record Groups]())* 

The Group record to get Captures for.

*Captures ([Record Captures]())* 

Captures Record to write the resulting Captures to.

### MatchResult (Method) <a name="MatchResult"></a> 

 Returns the expansion of the specified replacement pattern.
 

#### Syntax
```
procedure MatchResult(var Matches: Record Matches; Replacement: Text): Text
```
#### Parameters
*Matches ([Record Matches]())* 

The Match Record to perform replacement on.

*Replacement ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The replacement pattern to use.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The expanded version of the replacement parameter.

## RegexOptions (Enum 3962)
### None (value: 0)

### IgnoreCase (value: 1)

### Multiline (value: 2)

### ExplicitCapture (value: 4)

### Compiled (value: 8)

### Singleline (value: 16)

### IgnorePatternWhitespace (value: 32)

### RightToLeft (value: 64)

### ECMAScript (value: 256)

### CultureInvariant (value: 512)

