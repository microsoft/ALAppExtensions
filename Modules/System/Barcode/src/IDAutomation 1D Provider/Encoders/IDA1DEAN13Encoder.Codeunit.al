// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
/// <summary> 
/// EAN-13 barcode font implementation from IDAutomation
/// from: https://www.barcodefaq.com/barcode-properties/symbologies/ean-13/
/// Is most commonly used to encode 13 digits of the GTIN barcode symbology and also to identify books with Bookland or ISBN barcode symbols.
/// </summary>
codeunit 9208 "IDA 1D EAN13 Encoder" implements "Barcode Font Encoder"
{
    Access = Internal;

    /// <summary> 
    /// Encodes the barcode string to print a barcode using the IDautomation barcode font.
    /// From: https://en.wikipedia.org/wiki/Universal_Product_Code#EAN-13
    /// The EAN-13 was developed as a superset of UPC-A, adding an extra digit to the beginning of every UPC-A number. 
    /// This expanded the number of unique values theoretically possible by ten times to 1 trillion. 
    /// EAN-13 barcodes also indicate the country in which the company that sells the product is based (which may or may not be the same as the country in which the good is manufactured). 
    /// The three leading digits of the code determine this, according to the GS1 country codes. Every UPC-A code can be easily converted to the equivalent EAN-13 code by prepending 0 digit to the UPC-A code. 
    /// This does not change the check digit. All point-of-sale systems can now understand both equally.
    /// </summary>
    /// <param name="InputText">The text to encode.</param>
    /// <param name="BarcodeEncodeSettings">Unused.</param>
    /// <returns>The encoded barcode.</returns>
    procedure EncodeFont(InputText: Text; var BarcodeEncodeSettings: Record "Barcode Encode Settings"): Text
    var
        DotNetFontEncoder: DotNet FontEncoder;
    begin
        DotNetFontEncoder := DotNetFontEncoder.FontEncoder();
        exit(DotNetFontEncoder.EAN13(InputText));
    end;

    /// <summary> 
    /// Validates if a text is a valid string to encode the barcode.
    /// From: https://en.wikipedia.org/wiki/Universal_Product_Code#EAN-13
    /// Assumes that input is not-null and non-empty
    /// Only 0-9 characters are valid input characters
    /// input string must be exactly 12, 13, 15, or 18 characters long
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

        // match any string containing 12, 13, 15 or 18 digits
        exit(RegexPattern.IsMatch(InputText, '^[0-9]{12,13}$|^[0-9]{15}$|^[0-9]{18}$'));
    end;
}
