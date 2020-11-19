// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
/// <summary> 
/// Ean-8 barcode font implementation from IDAutomation
/// from: https://www.barcodefaq.com/barcode-properties/symbologies/ean-8/
/// An EAN-8 is an EAN/UPC symbology barcode and is derived from the longer International Article Number (EAN-13) code
/// </summary>
codeunit 9219 EAN8_BarcodeEncoderImpl
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
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary.</param>
    /// <param name="EncodedText">Parameter of type Text.</param>
    /// <param name="IsHandled">Parameter of type Boolean.</param>
    procedure FontEncoder(var TempBarcodeParameters: Record BarcodeParameters temporary; var EncodedText: Text; IsHandled: Boolean)
    var
        FontEncoder: DotNet dnFontEncoder;
    begin
        if IsHandled then exit;

        FontEncoder := FontEncoder.FontEncoder();
        EncodedText := FontEncoder.EAN8(TempBarcodeParameters."Input String");
    end;

    /// <summary> 
    /// Encodes the barcode string to generate a barcode image in Base64 format
    /// From: https://en.wikipedia.org/wiki/EAN-8
    /// An EAN-8 is an EAN/UPC symbology barcode and is derived from the longer International Article Number (EAN-13) code.
    /// It was introduced for use on small packages where an EAN-13 barcode would be too large; for example on cigarettes, pencils, and chewing gum packets. 
    /// It is encoded identically to the 12 digits of the UPC-A barcode, except that it has 4 (rather than 6) digits in each of the left and right halves.
    /// EAN-8 barcodes may be used to encode GTIN-8 (8-digit Global Trade Identification Numbers) which are product identifiers from the GS1 System. 
    /// A GTIN-8 begins with a 2- or 3-digit GS1 prefix (which is assigned to each national GS1 authority) followed by a 5- or 4-digit item reference element depending on the length of the GS1 prefix), and a checksum digit.
    /// EAN-8 codes are common throughout the world, and companies may also use them to encode RCN-8 (8-digit Restricted Circulation Numbers), and use them to identify own-brand products sold only in their stores. 
    /// RCN-8 are a subset of GTIN-8 which begin with a first digit of 0 or 2. 
    /// 
    /// This Function is currently throwing an error when the paramater "IsHandled" = false, and is reserved for future use when Base64ImageEncoding will be supported.
    /// </summary>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary.</param>
    /// <param name="Base64Image">Parameter of type Text.</param>
    /// <param name="IsHandled">Parameter of type Boolean.</param>
    procedure Base64ImageEncoder(var TempBarcodeParameters: Record BarcodeParameters temporary; var Base64Image: Text; IsHandled: Boolean);
    var
        NotImplementedErr: Label 'Base64 Image Encoding is currently not implemented for Provider%1 and Symbology %2', comment = '%1 =  Provider Caption, %2 = Symbology Caption';
    begin
        if IsHandled then exit;

        Error(NotImplementedErr, TempBarcodeParameters.Provider, TempBarcodeParameters.Symbology);
    end;

    /// <summary> 
    /// Validates if the Input String is a valid string to encode the barcode.
    /// From: https://en.wikipedia.org/wiki/EAN-8
    /// Assumes that input is not-null and non-empty
    /// Only 0-9 characters are valid input characters
    /// input string must be exactly 7 characters log
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

        if strlen(TempBarcodeParameters."Input String") <> 7 then begin
            InputStringOK := false;
            exit;
        end;

        // match any string containing non-digit characters
        InputStringOK := RegexPattern.IsMatch(TempBarcodeParameters."Input String", '@"[^\d]"');
    end;
}
