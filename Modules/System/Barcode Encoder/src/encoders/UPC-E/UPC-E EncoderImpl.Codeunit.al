// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary> 
/// From: https://en.wikipedia.org/wiki/Universal_Product_Code#UPC-E
/// UPC-E is a 6-digit code, that has its equivalent in UPC-A 12-digit code with number system 0 or 1.
/// </summary>
codeunit 9225 UPCE_BarcodeEncoderImpl
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
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary which sets the neccessary parameters for the requested barcode.</param>
    /// <param name="EncodedText">Parameter of type Text.</param>
    /// <param name="IsHandled">Parameter of type Boolean.</param>
    procedure FontEncoder(var TempBarcodeParameters: Record BarcodeParameters temporary; var EncodedText: Text; IsHandled: Boolean)
    var
        FontEncoder: DotNet dnFontEncoder;
    begin
        if IsHandled then exit;

        FontEncoder := FontEncoder.FontEncoder();
        EncodedText := FontEncoder.UPCE(TempBarcodeParameters."Input String");
    end;

    /// <summary> 
    /// Encodes the barcode string to generate a barcode image in Base64 format
    /// From: https://www.barcodefaq.com/barcode-properties/symbologies/upc-e/
    /// To allow the use of UPC barcodes on smaller packages, where a full 12-digit barcode may not fit, a 'zero-suppressed version of UPC was developed, called UPC-E, in which the number system digit, all trailing zeros in the manufacturer code, and all leading zeros in the product code, are suppressed (omitted). 
    /// This symbology differs from UPC-A in that it only uses a 6-digit code, does not use M (middle) guard pattern, and the E (end) guard pattern is formed as space-bar-space-bar-space-bar, i.e. UPC-E barcode follows the pattern SDDDDDDE. 
    /// The way in which a 6-digit UPC-E relates to a 12-digit UPC-A, is determined by UPC-E numerical pattern and UPC-E parity pattern. 
    /// It can only correspond to UPC-A number system 0 or 1, the value of which, along with the UPC-A check digit, determines the UPC-E parity pattern of the encoding.
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
    /// From: https://en.wikipedia.org/wiki/Universal_Product_Code#UPC-E
    /// Assumes that input is not-null and non-empty
    /// Only 0-9 characters are valid input characters
    /// input string must be exactly 6, 7, or 8 characters long
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

        // exit early if input string is not 6, 7, or 8 characters long
        case strlen(TempBarcodeParameters."Input String") of

            6:
                exit;
            7:
                exit;
            8:
                exit;
            else
                InputStringOK := false;
        end;
        // match any string containing non-digit characters
        InputStringOK := RegexPattern.IsMatch(TempBarcodeParameters."Input String", '@"[^\d]"');
    end;
}
