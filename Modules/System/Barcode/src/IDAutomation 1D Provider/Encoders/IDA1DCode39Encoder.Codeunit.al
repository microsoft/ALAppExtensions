// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
/// <summary> 
/// Code-39 barcode font implementation from IDAutomation
/// from: https://www.idautomation.com/barcode-fonts/code-39/ 
/// An alpha-numeric barcode that encodes uppercase letters, numbers and some symbols; it is also referred to as Barcode/39, the 3 of 9 Code and LOGMARS Code.
/// </summary>
codeunit 9204 "IDA 1D Code39 Encoder" implements "Barcode Font Encoder"
{
    Access = Internal;

    /// <summary> 
    /// Encodes the barcode string to print a barcode using the IDautomation barcode font.
    /// From: https://en.wikipedia.org/wiki/Code_39
    /// Code 39 (also known as Alpha39, Code 3 of 9, Code 3/9, Type 39, USS Code 39, or USD-3) is a variable length, discrete barcode symbology.
    /// The Code 39 specification defines 43 characters, consisting of uppercase letters (A through Z), numeric digits (0 through 9) and a number of special characters (-, ., $, /, +, %, and space). 
    /// An additional character (denoted '*') is used for both start and stop delimiters. 
    /// Each character is composed of nine elements: five bars and four spaces. 
    /// Three of the nine elements in each character are wide (binary value 1), and six elements are narrow (binary value 0). 
    /// The width ratio between narrow and wide is not critical, and may be chosen between 1:2 and 1:3.
    /// Code 39 is sometimes used with an optional modulo 43 check digit. Using it requires this feature to be enabled in the barcode reader. The code with check digit is referred to as Code 39 mod 43.
    /// 
    /// IDAutomation Uses ! as stop/start symbol
    /// Extended Code 39 barcode fonts barcode fonts are provided to easily encode lower case and special characters in a self checking font environment and begin with IDAutomationSX. 
    /// Extended Code 39 fonts are not compatible with IDAutomation's font encoders, such as the MOD43 function, and the asterisk (*) must be used as the start and stop character. 
    /// For extended characters to scan properly, the scanner must first be enabled to read extended code 39. These fonts are not part of the standard install, and therefore must be manually installed.
    /// </summary>
    /// <param name="InputText">The text to encode.</param>
    /// <param name="BarcodeEncodeSettings">The settings to use. The encoder uses 'Enable Checksum' flag.</param>
    /// <returns>the encoded bardcode.</returns>
    procedure EncodeFont(InputText: Text; var BarcodeEncodeSettings: Record "Barcode Encode Settings"): Text
    var
        DotNetFontEncoder: DotNet FontEncoder;
    begin
        DotNetFontEncoder := DotNetFontEncoder.FontEncoder();

        if BarcodeEncodeSettings."Allow Extended Charset" then
            if BarcodeEncodeSettings."Enable Checksum" then
                exit(DotNetFontEncoder.Code39ExtMod43(InputText))
            else
                exit(DotNetFontEncoder.Code39Ext(InputText))

        else
            if BarcodeEncodeSettings."Enable Checksum" then
                exit(DotNetFontEncoder.Code39Mod43(InputText))
            else
                exit(DotNetFontEncoder.Code39(InputText));
    end;

    /// <summary> 
    /// Validates if text is a valid string to encode the barcode.
    /// From: https://en.wikipedia.org/wiki/Code_39
    /// The Code 39 specification defines 43 characters, consisting of 
    /// uppercase letters(A through Z), numeric digits(0 through 9) 
    /// and a number of special characters(-, ., $, /, +, %, and space).
    /// Using regex from https://www.neodynamic.com/Products/Help/BarcodeWinControl2.5/working_barcode_symbologies.htm
    /// </summary>
    /// <param name="InputText">The text to validate.</param>
    /// <param name="BarcodeEncodeSettings">The settings to use for validation. The encoder uses 'Allow Extended Charset' flag.</param>
    /// <returns>True if the validation succeeds; otherwise - false.</returns>
    procedure IsValidInput(InputText: Text; var BarcodeEncodeSettings: Record "Barcode Encode Settings"): Boolean;
    var
        RegexPattern: codeunit Regex;
    begin
        if InputText = '' then
            exit(false);

        // Verify if input string containings only valid characters
        if BarcodeEncodeSettings."Allow Extended Charset" then
            exit(RegexPattern.IsMatch(InputText, '^[\000-\177]*$'));

        exit(RegexPattern.IsMatch(InputText, '^[0-9A-Z\-.$\/\+%\*\s]*$'));
    end;
}
