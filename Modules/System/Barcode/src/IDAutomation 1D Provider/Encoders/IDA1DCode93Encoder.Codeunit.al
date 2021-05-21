// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
/// <summary> 
/// Code-93 barcode font implementation from IDAutomation
/// from: https://www.idautomation.com/barcode-fonts/code-93/
/// Similar to Code 39, but requires two checksum characters.
/// </summary>
codeunit 9205 "IDA 1D Code93 Encoder" implements "Barcode Font Encoder"
{
    Access = Internal;

    /// <summary> 
    /// Encodes the barcode string to print a barcode using the IDautomation barcode font.
    /// From: https://en.wikipedia.org/wiki/Code_93/
    /// It is an alphanumeric, variable length symbology. Code 93 is used primarily by Canada Post to encode supplementary delivery information. 
    /// Every symbol includes two check characters.
    /// Each Code 93 character is nine modules wide, and always has three bars and three spaces, thus the name. 
    /// Each bar and space is from 1 to 4 modules wide. (For comparison, a Code 39 character consists of five bars and four spaces, three of which are wide, for a total width of 13–16 modules.)
    /// </summary>
    ///<param name="InputText">The text to encode.</param>
    /// <param name="BarcodeEncodeSettings">Unused.</param>
    /// <returns>The encoded barcode.</returns>
    procedure EncodeFont(InputText: Text; var BarcodeEncodeSettings: Record "Barcode Encode Settings"): Text
    var
        DotNetFontEncoder: DotNet FontEncoder;
    begin
        DotNetFontEncoder := DotNetFontEncoder.FontEncoder();
        exit(DotNetFontEncoder.Code93(InputText));
    end;

    /// <summary> 
    /// Validates if text is a valid string to encode the barcode.
    /// From: https://en.wikipedia.org/wiki/Code_93
    /// Each Code 93 character is nine modules wide, and always has three bars and three spaces, thus the name. 
    /// Each bar and space is from 1 to 4 modules wide. 
    /// (For comparison, a Code 39 character consists of five bars and four spaces, three of which are wide, for a total width of 13–16 modules.)
    ///
    /// Code 93 is designed to encode the same 26 upper case letters, 10 digits and 7 special characters as code 39:
    ///      A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
    ///      0 1 2 3 4 5 6 7 8 9
    ///      - . $ / + % SPACE
    /// Using regex from https://www.neodynamic.com/Products/Help/BarcodeWinControl2.5/working_barcode_symbologies.htm
    /// </summary>
    /// <param name="InputText">The text to validate.</param>
    /// <param name="BarcodeEncodeSettings">The settings to use. The encoder uses 'Allow Extended Charset' flag.</param>
    /// <returns>True if the validation succeeds; otherwise - false.</returns>
    procedure IsValidInput(InputText: Text; var BarcodeEncodeSettings: Record "Barcode Encode Settings"): Boolean;
    var
        RegexPattern: Codeunit Regex;
    begin
        if InputText = '' then
            exit(false);

        // Verify if input string containings only valid characters
        if BarcodeEncodeSettings."Allow Extended Charset" then
            exit(RegexPattern.IsMatch(InputText, '^[\000-\177]*$'));

        exit(RegexPattern.IsMatch(InputText, '^[0-9A-Z\-.$\/\+%\*\s]*$'));
    end;
}
