// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
/// <summary> 
/// ITF barcode font implementation from IDAutomation
/// from: https://www.idautomation.com/barcode-fonts/interleaved-2of5/
/// Interleaved 2 of 5 (ITF) is a numeric only barcode used to encode pairs of numbers into a self-checking, high-density barcode format
/// </summary>
codeunit 9209 "IDA 1D I2of5 Encoder" implements "Barcode Font Encoder"
{
    Access = Internal;

    /// <summary> 
    /// Encodes the barcode string to print a barcode using the IDautomation barcode font.
    /// From: https://en.wikipedia.org/wiki/Interleaved_2_of_5
    /// Interleaved 2 of 5 (ITF) is a continuous two-width barcode symbology encoding digits. 
    /// It is used commercially on 135 film, for ITF-14 barcodes, and on cartons of some products, while the products inside are labeled with UPC or EAN.
    /// ITF encodes pairs of digits; the first digit is encoded in the five bars (or black lines), while the second digit is encoded in the five spaces (or white lines) interleaved with them. 
    /// Two out of every five bars or spaces are wide (hence exactly 2 of 5).
    /// </summary>
    /// <param name="InputText">The text to encode.</param>
    /// <param name="BarcodeEncodeSettings">The settings to use. This encoder uses the 'Use mod 10' flag.</param>
    /// <returns>The encoded barcode.</returns>
    procedure EncodeFont(InputText: Text; var BarcodeEncodeSettings: Record "Barcode Encode Settings"): Text
    var
        DotNetFontEncoder: DotNet FontEncoder;
    begin
        DotNetFontEncoder := DotNetFontEncoder.FontEncoder();

        if BarcodeEncodeSettings."Use mod 10" then
            exit(DotNetFontEncoder.I2of5Mod10(InputText));

        exit(DotNetFontEncoder.I2of5(InputText));
    end;

    /// <summary> 
    /// Validates text of the barcode.
    /// From: https://en.wikipedia.org/wiki/Interleaved_2_of_5
    /// Assumes that input is not-null and non-empty
    /// Only 0-9 characters are valid input characters
    /// Using regex from https://www.neodynamic.com/Products/Help/BarcodeWinControl2.5/working_barcode_symbologies.htm
    /// </summary>
    /// <param name="InputText">The text to validate.</param>
    /// <param name="BarcodeEncodeSettings">The settings to use.</param>
    /// <returns>True if the validation succeeds; otherwise - false.</returns>
    procedure IsValidInput(InputText: Text; var BarcodeEncodeSettings: Record "Barcode Encode Settings"): Boolean;
    var
        RegexPattern: codeunit Regex;
    begin
        if InputText = '' then
            exit(false);

        // match any string containing pairs of digits
        exit(RegexPattern.IsMatch(InputText, '^([0-9]{2})+?$'));
    end;
}
