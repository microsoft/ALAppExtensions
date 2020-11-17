// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
/// <summary> 
/// EAN-13 barcode font implementation from IDAutomation
/// from: https://www.barcodefaq.com/barcode-properties/symbologies/ean-13/
/// Is most commonly used to encode 13 digits of the GTIN barcode symbology and also to identify books with Bookland or ISBN barcode symbols.
/// </summary>
codeunit 9220 EAN13BarcodeEncoder implements IBarcodeEncoder
{
    Access = Public;

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
    /// <param name="IsHandled">Parameter of type Boolean.</param>
    procedure FontEncoder(var TempBarcodeParameters: Record BarcodeParameters temporary) EncodedText: Text
    var
        SymbologyEncoderImpl: Codeunit EAN13_BarcodeEncoderImpl;
        IsHandled: Boolean;
    begin
        OnBeforeEncodeSymbology(TempBarcodeParameters, EncodedText, IsHandled);

        SymbologyEncoderImpl.FontEncoder(TempBarcodeParameters, EncodedText, IsHandled);

        OnAfterEncodeSymbology(TempBarcodeParameters, EncodedText);
    end;

    /// <summary> 
    /// Validates if the Input String is a valid string to encode the barcode.
    /// From: https://en.wikipedia.org/wiki/Universal_Product_Code#EAN-13
    /// Assumes that input is not-null and non-empty
    /// Only 0-9 characters are valid input characters
    /// input string must be exactly 12, 13, 15, or 18 characters long
    /// Using regex from https://www.neodynamic.com/Products/Help/BarcodeWinControl2.5/working_barcode_symbologies.htm
    /// </summary>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary.</param>
    procedure ValidateInputString(var TempBarcodeParameters: Record BarcodeParameters temporary) ValidationResult: Boolean
    var
        SymbologyEncoderImpl: Codeunit EAN13_BarcodeEncoderImpl;
        IsHandled: Boolean;
    begin
        OnBeforeValidateSymbology(TempBarcodeParameters, ValidationResult, IsHandled);

        SymbologyEncoderImpl.ValidateInputString(TempBarcodeParameters, ValidationResult, IsHandled);

        OnAfterValidateSymbology(TempBarcodeParameters, ValidationResult);
    end;

    procedure Barcode(var TempBarcodeParameters: Record BarcodeParameters temporary) Base64Data: Text
    var
        SymbologyEncoderImpl: Codeunit EAN13_BarcodeEncoderImpl;
        IsHandled: Boolean;
    begin
        OnBeforeFormatSymbology(TempBarcodeParameters, Base64Data, IsHandled);

        SymbologyEncoderImpl.Barcode(TempBarcodeParameters, Base64Data, IsHandled);

        OnAfterFormatSymbology(TempBarcodeParameters, Base64Data);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeEncodeSymbology(var TempBarcodeParameters: Record BarcodeParameters temporary; var EncodedText: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterEncodeSymbology(var TempBarcodeParameters: Record BarcodeParameters temporary; var EncodedText: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateSymbology(var TempBarcodeParameters: Record BarcodeParameters temporary; var ValidationResult: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateSymbology(var TempBarcodeParameters: Record BarcodeParameters temporary; ValidationResult: Boolean)
    begin
    end;


    [IntegrationEvent(false, false)]
    local procedure OnBeforeFormatSymbology(var TempBarcodeParameters: Record BarcodeParameters temporary; var Base64Data: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFormatSymbology(var TempBarcodeParameters: Record BarcodeParameters temporary; var Base64Data: Text)
    begin
    end;
}
