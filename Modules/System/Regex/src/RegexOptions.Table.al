// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Table with options to use with Regular Expressions
/// </summary>
/// <remark>
/// For more information, visit https://docs.microsoft.com/en-us/dotnet/api/system.text.regularexpressions.regexoptions?view=netcore-3.1.
/// </remark>
table 3966 "Regex Options"
{
    Extensible = false;
    TableType = Temporary;

    fields
    {
        field(1; IgnoreCase; Boolean)
        {
            DataClassification = SystemMetadata;
            Description = 'Specifies case-insensitive matching.';
        }
        field(2; Multiline; Boolean)
        {
            DataClassification = SystemMetadata;
            Description = 'Changes the meaning of ^ and $ so they match at the beginning and end respectively of any line.';
        }
        field(3; ExplicitCapture; Boolean)
        {
            DataClassification = SystemMetadata;
            Description = 'Specifies that the only valid captures are explicitly named or numbered groups of the form (?<name>...).';
        }
        field(4; Compiled; Boolean)
        {
            DataClassification = SystemMetadata;
            Description = 'Specifies that the regular expression is compiled to an assembly';
        }
        field(5; Singleline; Boolean)
        {
            DataClassification = SystemMetadata;
            Description = 'Specifies single-line mode. Changes the meaning of the dot (.) so it matches every character (instead of every character except \n).';
        }
        field(6; IgnorePatternWhitespace; Boolean)
        {
            DataClassification = SystemMetadata;
            Description = 'Eliminates unescaped white space from the pattern and enables comments marked with #.';
        }
        field(7; RightToLeft; Boolean)
        {
            DataClassification = SystemMetadata;
            Description = 'Specifies that the search will be from right to left instead of from left to right.';
        }
        field(8; ECMAScript; Boolean)
        {
            DataClassification = SystemMetadata;
            Description = 'Enables ECMAScript-compliant behavior for the expression.';
        }
        field(9; CultureInvariant; Boolean)
        {
            DataClassification = SystemMetadata;
            Description = 'Specifies that cultural differences in language is ignored.';
        }
        field(10; MatchTimeoutInMs; Integer)
        {
            DataClassification = SystemMetadata;
            Description = 'A time-out interval in miliseconds, to indicate when the matching should time out.';
            InitValue = -1; // Indicates no time-out 
        }
    }

    /// <summary>
    /// Gets the integer-representation of the combined regex options. 
    /// </summary>
    /// <returns>An integer for the combined regex options.</returns>
    procedure GetRegexOptions(): Integer
    var
        CombinedOptions: Integer;
    begin
        if Rec.IgnoreCase then
            CombinedOptions += Enum::RegexOptions::IgnoreCase.AsInteger();

        if Rec.Multiline then
            CombinedOptions += Enum::RegexOptions::Multiline.AsInteger();

        if Rec.ExplicitCapture then
            CombinedOptions += Enum::RegexOptions::ExplicitCapture.AsInteger();

        if Rec.Compiled then
            CombinedOptions += Enum::RegexOptions::Compiled.AsInteger();

        if Rec.Singleline then
            CombinedOptions += Enum::RegexOptions::Singleline.AsInteger();

        if Rec.IgnorePatternWhitespace then
            CombinedOptions += Enum::RegexOptions::IgnorePatternWhitespace.AsInteger();

        if Rec.RightToLeft then
            CombinedOptions += Enum::RegexOptions::RightToLeft.AsInteger();

        if Rec.ECMAScript then
            CombinedOptions += Enum::RegexOptions::ECMAScript.AsInteger();

        if Rec.CultureInvariant then
            CombinedOptions += Enum::RegexOptions::CultureInvariant.AsInteger();

        exit(CombinedOptions);
    end;

}