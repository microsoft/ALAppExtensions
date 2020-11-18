// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
/// <summary> 
/// EAN-13 barcode font implementation from IDAutomation
/// from: https://www.barcodefaq.com/barcode-properties/symbologies/ean-13/
/// Is most commonly used to encode 13 digits of the GTIN barcode symbology and also to identify books with Bookland or ISBN barcode symbols.
/// </summary>
codeunit 9221 EAN13_BarcodeEncoderImpl
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
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary which sets the neccessary parameters for the requested barcode.</param>
    /// <param name="EncodedText">Parameter of type Text.</param>
    /// <param name="IsHandled">Parameter of type Boolean.</param>
    procedure FontEncoder(var TempBarcodeParameters: Record BarcodeParameters temporary; var EncodedText: Text; IsHandled: Boolean)
    var
        FontEncoder: DotNet dnFontEncoder;
    begin
        if IsHandled then exit;

        FontEncoder := FontEncoder.FontEncoder();
        EncodedText := FontEncoder.EAN13(TempBarcodeParameters."Input String");
    end;

    /// <summary> 
    /// Encodes the barcode string to generate a barcode image in Base64 format
    /// From: https://en.wikipedia.org/wiki/Universal_Product_Code#EAN-13
    /// The EAN-13 was developed as a superset of UPC-A, adding an extra digit to the beginning of every UPC-A number. 
    /// This expanded the number of unique values theoretically possible by ten times to 1 trillion. 
    /// EAN-13 barcodes also indicate the country in which the company that sells the product is based (which may or may not be the same as the country in which the good is manufactured). 
    /// The three leading digits of the code determine this, according to the GS1 country codes. Every UPC-A code can be easily converted to the equivalent EAN-13 code by prepending 0 digit to the UPC-A code. 
    /// This does not change the check digit. All point-of-sale systems can now understand both equally.
    /// </summary>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary.</param>
    /// <param name="Base64Image">Parameter of type Text.</param>
    /// <param name="IsHandled">Parameter of type Boolean.</param>
    procedure Base64ImageEncoder(var TempBarcodeParameters: Record BarcodeParameters temporary; var Base64Image: Text; IsHandled: Boolean)
    begin
        if IsHandled then exit;
    end;

    /// <summary> 
    /// Validates if the Input String is a valid string to encode the barcode.
    /// From: https://en.wikipedia.org/wiki/Universal_Product_Code#EAN-13
    /// Assumes that input is not-null and non-empty
    /// Only 0-9 characters are valid input characters
    /// input string must be exactly 12, 13, 15, or 18 characters long
    /// Using regex from https://www.neodynamic.com/Products/Help/BarcodeWinControl2.5/working_barcode_symbologies.htm
    /// </summary>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary which sets the neccessary parameters for the requested barcode.</param>
    /// <param name="InputStringOK">Parameter of type Boolean.</param>
    /// <param name="IsHandled">Parameter of type Boolean.</param>
    procedure ValidateInputString(var TempBarcodeParameters: Record BarcodeParameters temporary; var InputStringOK: Boolean; IsHandled: Boolean)
    var
        RegexPattern: codeunit Regex;
    begin
        if IsHandled then exit;

        InputStringOK := true;
        // null or empty
        if (TempBarcodeParameters."Input String" = '') then begin
            InputStringOK := false;
            exit;
        end;

        // exit early if input string is not 12, 13, 15, or 18 characters long
        case strlen(TempBarcodeParameters."Input String") of
            12:
                exit;
            13:
                exit;
            15:
                exit;
            18:
                exit;
            else
                InputStringOK := false;
        end;
        // match any string containing non-digit characters
        InputStringOK := RegexPattern.IsMatch(TempBarcodeParameters."Input String", '@"[^\d]"');
    end;
}
