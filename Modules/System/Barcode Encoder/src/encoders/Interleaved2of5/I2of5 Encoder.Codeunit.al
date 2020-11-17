// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
/// <summary> 
/// ITF barcode font implementation from IDAutomation
/// from: https://www.idautomation.com/barcode-fonts/interleaved-2of5/
/// Interleaved 2 of 5 (ITF) is a numeric only barcode used to encode pairs of numbers into a self-checking, high-density barcode format
/// </summary>
codeunit 9226 I2of5BarcodeEncoder implements IBarcodeEncoder
{
    Access = Public;

    /// <summary> 
    /// Encodes the barcode string to print a barcode using the IDautomation barcode font.
    /// From: https://en.wikipedia.org/wiki/Interleaved_2_of_5
    /// Interleaved 2 of 5 (ITF) is a continuous two-width barcode symbology encoding digits. 
    /// It is used commercially on 135 film, for ITF-14 barcodes, and on cartons of some products, while the products inside are labeled with UPC or EAN.
    /// ITF encodes pairs of digits; the first digit is encoded in the five bars (or black lines), while the second digit is encoded in the five spaces (or white lines) interleaved with them. 
    /// Two out of every five bars or spaces are wide (hence exactly 2 of 5).
    /// </summary>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary.</param>
    procedure FontEncoder(var TempBarcodeParameters: Record BarcodeParameters temporary) EncodedText: Text
    var
        SymbologyEncoderImpl: Codeunit I2of5_BarcodeEncoderImpl;
        IsHandled: Boolean;
    begin
        OnBeforeEncodeSymbology(TempBarcodeParameters, EncodedText, IsHandled);

        SymbologyEncoderImpl.FontEncoder(TempBarcodeParameters, EncodedText, IsHandled);

        OnAfterEncodeSymbology(TempBarcodeParameters, EncodedText);
    end;

    /// <summary> 
    /// Validates the Input String of the barcode.
    /// From: https://en.wikipedia.org/wiki/Interleaved_2_of_5
    /// Assumes that input is not-null and non-empty
    /// Only 0-9 characters are valid input characters
    /// Using regex from https://www.neodynamic.com/Products/Help/BarcodeWinControl2.5/working_barcode_symbologies.htm
    /// </summary>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary.</param>
    procedure ValidateInputString(var TempBarcodeParameters: Record BarcodeParameters temporary) ValidationResult: Boolean
    var
        SymbologyEncoderImpl: Codeunit I2of5_BarcodeEncoderImpl;
        IsHandled: Boolean;
    begin
        OnBeforeValidateSymbology(TempBarcodeParameters, ValidationResult, IsHandled);

        SymbologyEncoderImpl.ValidateInputString(TempBarcodeParameters, ValidationResult, IsHandled);

        OnAfterValidateSymbology(TempBarcodeParameters, ValidationResult);
    end;

    procedure Barcode(var TempBarcodeParameters: Record BarcodeParameters temporary) Base64Data: Text
    var
        SymbologyEncoderImpl: Codeunit I2of5_BarcodeEncoderImpl;
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
