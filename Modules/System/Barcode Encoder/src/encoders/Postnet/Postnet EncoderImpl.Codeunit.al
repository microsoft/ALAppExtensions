// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 9229 Postnet_BarcodeEncoderImpl
{
    Access = Internal;

    /// <summary> 
    /// Encodes the barcode string to print a barcode using the IDautomation barcode font.
    /// From: https://en.wikipedia.org/wiki/POSTNET
    /// POSTNET (Postal Numeric Encoding Technique) is a barcode symbology used by the United States Postal Service to assist in directing mail. 
    /// The ZIP Code or ZIP+4 code is encoded in half- and full-height bars.[1] Most often, the delivery point is added, usually being the last two digits of the address or PO box number.    
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
        EncodedText := FontEncoder.Postnet(TempBarcodeParameters."Input String");
    end;

    /// <summary> 
    /// Encodes the barcode string to generate a barcode image in Base64 format
    /// From: https://en.wikipedia.org/wiki/POSTNET
    /// POSTNET (Postal Numeric Encoding Technique) is a barcode symbology used by the United States Postal Service to assist in directing mail. 
    /// The ZIP Code or ZIP+4 code is encoded in half- and full-height bars.[1] Most often, the delivery point is added, usually being the last two digits of the address or PO box number.
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
    /// Validates the Input String of the barcode.
    /// From: https://en.wikipedia.org/wiki/POSTNET
    /// Assumes that input is not-null and non-empty
    /// Only 0-9 characters are valid input characters
    /// Accepts 5 digit ZIP code 
    /// 9 digit ZIP code data, 
    /// or DPBC POSTNET - 9 digit ZIP code data + two DPBC numbers
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

        // exit early if length <> 5, 9, or 11 chars
        case strlen(TempBarcodeParameters."Input String") of
            5:
                exit;
            9:
                exit;
            11:
                exit;
            else
                InputStringOK := false;
        end;
        // match any string containing non-digit characters
        InputStringOK := RegexPattern.IsMatch(TempBarcodeParameters."Input String", '@"[^\d]"');
    end;
}
