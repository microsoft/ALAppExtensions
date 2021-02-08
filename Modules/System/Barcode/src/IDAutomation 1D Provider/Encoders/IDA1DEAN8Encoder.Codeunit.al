// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
/// <summary> 
/// Ean-8 barcode font implementation from IDAutomation
/// from: https://www.barcodefaq.com/barcode-properties/symbologies/ean-8/
/// An EAN-8 is an EAN/UPC symbology barcode and is derived from the longer International Article Number (EAN-13) code
/// </summary>
codeunit 9207 "IDA 1D EAN8 Encoder" implements "Barcode Font Encoder"
{
    Access = Internal;

    /// <summary> 
    /// Encodes the barcode string to print a barcode using the IDautomation barcode font.
    /// From: https://en.wikipedia.org/wiki/EAN-8
    /// An EAN-8 is an EAN/UPC symbology barcode and is derived from the longer International Article Number (EAN-13) code.
    /// It was introduced for use on small packages where an EAN-13 barcode would be too large; for example on cigarettes, pencils, and chewing gum packets. 
    /// It is encoded identically to the 12 digits of the UPC-A barcode, except that it has 4 (rather than 6) digits in each of the left and right halves.
    /// EAN-8 barcodes may be used to encode GTIN-8 (8-digit Global Trade Identification Numbers) which are product identifiers from the GS1 System. 
    /// A GTIN-8 begins with a 2- or 3-digit GS1 prefix (which is assigned to each national GS1 authority) followed by a 5- or 4-digit item reference element depending on the length of the GS1 prefix), and a checksum digit.
    /// EAN-8 codes are common throughout the world, and companies may also use them to encode RCN-8 (8-digit Restricted Circulation Numbers), and use them to identify own-brand products sold only in their stores. 
    /// RCN-8 are a subset of GTIN-8 which begin with a first digit of 0 or 2. 
    /// </summary>
    /// <param name="InputText">The text to encode.</param>
    /// <param name="BarcodeEncodeSettings">Unused.</param>
    /// <returns>The encoded barcode.</returns>
    procedure EncodeFont(InputText: Text; var BarcodeEncodeSettings: Record "Barcode Encode Settings"): Text
    var
        DotNetFontEncoder: DotNet FontEncoder;
    begin
        DotNetFontEncoder := DotNetFontEncoder.FontEncoder();
        exit(DotNetFontEncoder.EAN8(InputText));
    end;

    /// <summary> 
    /// Validates if text is a valid string to encode the barcode.
    /// From: https://en.wikipedia.org/wiki/EAN-8
    /// Assumes that input is not-null and non-empty
    /// Only 0-9 characters are valid input characters
    /// input string must be exactly 7 characters log
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

        if StrLen(InputText) <> 7 then
            exit(false);

        // match any string containing 7, 8, 9, 10, 12 or 13 digits
        exit(RegexPattern.IsMatch(InputText, '^[0-9]{7,10}$|^[0-9]{12,13}$'));
    end;
}
