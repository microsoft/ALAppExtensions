// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9211 "IDA 1D Postnet Encoder" implements "Barcode Font Encoder"
{
    Access = Internal;

    /// <summary> 
    /// Encodes the barcode string to print a barcode using the IDautomation barcode font.
    /// From: https://en.wikipedia.org/wiki/POSTNET
    /// POSTNET (Postal Numeric Encoding Technique) is a barcode symbology used by the United States Postal Service to assist in directing mail. 
    /// The ZIP Code or ZIP+4 code is encoded in half- and full-height bars.[1] Most often, the delivery point is added, usually being the last two digits of the address or PO box number.    
    /// </summary>
    ///<param name="InputText">The text to encode.</param>
    /// <param name="BarcodeEncodeSettings">Unused.</param>
    /// <returns>The encoded barcode.</returns>
    procedure EncodeFont(InputText: Text; var BarcodeEncodeSettings: Record "Barcode Encode Settings"): Text
    var
        DotNetFontEncoder: DotNet FontEncoder;
    begin
        DotNetFontEncoder := DotNetFontEncoder.FontEncoder();
        exit(DotNetFontEncoder.Postnet(InputText));
    end;

    /// <summary> 
    /// Validates the text of the barcode.
    /// From: https://en.wikipedia.org/wiki/POSTNET
    /// Assumes that input is not-null and non-empty
    /// Only 0-9 characters are valid input characters
    /// Accepts 5 digit ZIP code 
    /// 9 digit ZIP code data, 
    /// or DPBC POSTNET - 9 digit ZIP code data + two DPBC numbers
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

        // match any string containing 5, 6, 9 or 11 digits
        exit(RegexPattern.IsMatch(InputText, '^[0-9]{5,6}$|^[0-9]{9}$|^[0-9]{11}$'));
    end;
}
