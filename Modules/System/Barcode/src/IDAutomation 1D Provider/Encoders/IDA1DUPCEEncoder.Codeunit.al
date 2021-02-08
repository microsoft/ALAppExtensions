// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary> 
/// From: https://en.wikipedia.org/wiki/Universal_Product_Code#UPC-E
/// UPC-E is a 6-digit code, that has its equivalent in UPC-A 12-digit code with number system 0 or 1.
/// </summary>
codeunit 9213 "IDA 1D UPCE Encoder" implements "Barcode Font Encoder"
{
    Access = Internal;

    /// <summary> 
    /// Encodes the barcode string to print a barcode using the IDautomation barcode font.
    /// From: https://www.barcodefaq.com/barcode-properties/symbologies/upc-e/
    /// To allow the use of UPC barcodes on smaller packages, where a full 12-digit barcode may not fit, a 'zero-suppressed version of UPC was developed, called UPC-E, in which the number system digit, all trailing zeros in the manufacturer code, and all leading zeros in the product code, are suppressed (omitted). 
    /// This symbology differs from UPC-A in that it only uses a 6-digit code, does not use M (middle) guard pattern, and the E (end) guard pattern is formed as space-bar-space-bar-space-bar, i.e. UPC-E barcode follows the pattern SDDDDDDE. 
    /// The way in which a 6-digit UPC-E relates to a 12-digit UPC-A, is determined by UPC-E numerical pattern and UPC-E parity pattern. 
    /// It can only correspond to UPC-A number system 0 or 1, the value of which, along with the UPC-A check digit, determines the UPC-E parity pattern of the encoding.
    /// </summary>
    /// ///<param name="InputText">The text to encode.</param>
    /// <param name="BarcodeEncodeSettings">Unused.</param>
    /// <returns>The encoded barcode.</returns>
    /// <returns>The encoded barcode.</returns>
    procedure EncodeFont(InputText: Text; var BarcodeEncodeSettings: Record "Barcode Encode Settings"): Text
    var
        DotNetFontEncoder: DotNet FontEncoder;
    begin
        DotNetFontEncoder := DotNetFontEncoder.FontEncoder();
        exit(DotNetFontEncoder.UPCE(InputText));
    end;

    /// <summary> 
    /// Validates if text is a valid string to encode the barcode.
    /// From: https://en.wikipedia.org/wiki/Universal_Product_Code#UPC-E
    /// Assumes that input is not-null and non-empty
    /// Only 0-9 characters are valid input characters
    /// input string must be exactly 6, 7, or 8 characters long
    /// Using regex from https://www.neodynamic.com/Products/Help/BarcodeWinControl2.5/working_barcode_symbologies.htm
    /// </summary>
    /// <param name="InputText">The text to validate.</param>
    /// <param name="BarcodeEncodeSettings">Unused.</param>
    /// <returns>True if the validation succeeds; otherwise - false.</returns>
    procedure IsValidInput(InputText: Text; var BarcodeEncodeSettings: Record "Barcode Encode Settings"): Boolean;
    var
        RegexPattern: codeunit Regex;
    begin
        if InputText = '' then
            exit(false);

        // match any string containing 7 or 8 digits
        exit(RegexPattern.IsMatch(InputText, '^[0-9]{7,8}$'));
    end;
}
