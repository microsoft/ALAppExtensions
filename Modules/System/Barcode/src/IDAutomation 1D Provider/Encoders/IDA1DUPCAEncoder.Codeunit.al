// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
/// <summary> 
/// UPC-A barcode font implementation from IDAutomation
/// from: https://www.barcodefaq.com/barcode-properties/symbologies/upc-a/
/// Is most commonly used to encode 12 digits of the GTIN.
/// </summary>
codeunit 9212 "IDA 1D UPCA Encoder" implements "Barcode Font Encoder"
{
    Access = Internal;

    /// <summary> 
    /// Encodes the barcode string to print a barcode using the IDautomation barcode font.
    /// From: https://en.wikipedia.org/wiki/Universal_Product_Code
    /// The Universal Product Code (UPC; redundantly: UPC code) is a barcode symbology that is widely used in the United States, Canada, Europe, Australia, New Zealand, and other countries for tracking trade items in stores.
    /// UPC (technically refers to UPC-A) consists of 12 numeric digits that are uniquely assigned to each trade item. Along with the related EAN barcode, the UPC is the barcode mainly used for scanning of trade items at the point of sale, per GS1 specifications. 
    /// UPC data structures are a component of GTINs and follow the global GS1 specification, which is based on international standards. But some retailers (clothing, furniture) do not use the GS1 system (rather other barcode symbologies or article number systems). 
    /// On the other hand, some retailers use the EAN/UPC barcode symbology, but without using a GTIN (for products sold in their own stores only).    
    /// </summary>
    /// <param name="InputText">The text to encode.</param>
    /// <param name="BarcodeEncodeSettings">Unused.</param>
    /// <returns>The encoded barcode.</returns>
    procedure EncodeFont(InputText: Text; var BarcodeEncodeSettings: Record "Barcode Encode Settings"): Text
    var
        DotNetFontEncoder: DotNet FontEncoder;
    begin
        DotNetFontEncoder := DotNetFontEncoder.FontEncoder();
        exit(DotNetFontEncoder.UPCA(InputText));
    end;

    /// <summary> 
    /// Validates the text of the barcode.
    /// From: https://en.wikipedia.org/wiki/Universal_Product_Code
    /// Assumes that input is not-null and non-empty
    /// Only 0-9 characters are valid input characters
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

        // match any string containing 11 or 12 digits
        exit(RegexPattern.IsMatch(InputText, '^[0-9]{11,12}$'));
    end;
}
