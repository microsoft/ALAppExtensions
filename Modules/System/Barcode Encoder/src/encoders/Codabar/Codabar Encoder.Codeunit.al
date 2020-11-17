// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
/// <summary> 
/// codabar barcode font implementation from IDAutomation
/// from: https://www.idautomation.com/barcode-fonts/codabar/ 
/// A numeric barcode encoding numbers with a slightly higher density than Code 39.
/// </summary>
codeunit 9212 CodabarBarcodeEncoder implements IBarcodeEncoder
{
    Access = Public;

    /// <summary> 
    /// Encodes the barcode string to print a barcode using the IDautomation barcode font.
    /// From: https://en.wikipedia.org/wiki/Codabar/
    /// The Codabar character set includes numeric characters 0-9, alpha letters A to D and the following symbols: - $ / +. 
    /// The Codabar barcode type has been used for various high-density numeric bar-coding applications including libraries, blood banks, and parcels. Codabar is self-checking, 
    /// eliminating the requirement for checksum characters, which allow it to be easily incorporated into existing applications.
    /// The Codabar character set consists of barcode symbols representing characters 0-9, Letters A to D and the following symbols: - $ / +. 
    /// Additional data may be encoded in the actual choice of start and stop codes. The uppercase letters A, B, C, and D are used for start and stop codes. 
    /// The parentheses ( ) may also be used as the start and stop code to eliminate the letters from appearing in the human-readable version of the fonts.
    /// </summary>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters which sets the neccessary parameters for the requested barcode.</param>
    procedure FontEncoder(var TempBarcodeParameters: Record BarcodeParameters temporary) EncodedText: Text
    var
        SymbologyEncoderImpl: Codeunit CodabarBarcodeEncoderImpl;
        IsHandled: Boolean;
    begin
        OnBeforeEncodeSymbology(TempBarcodeParameters, EncodedText, IsHandled);

        SymbologyEncoderImpl.FontEncoder(TempBarcodeParameters, EncodedText, IsHandled);

        OnAfterEncodeSymbology(TempBarcodeParameters, EncodedText);
    end;

    /// <summary> 
    /// Validates if the Input String is a valid string to encode the barcode.
    /// The Codabar character set includes numeric characters 0-9, alpha letters A to D and the following symbols: - $ / +. 
    /// The Codabar barcode type has been used for various high-density numeric bar-coding applications including libraries, blood banks, and parcels. Codabar is self-checking, 
    /// eliminating the requirement for checksum characters, which allow it to be easily incorporated into existing applications.
    /// The Codabar character set consists of barcode symbols representing characters 0-9, Letters A to D and the following symbols: - $ / +. 
    /// Additional data may be encoded in the actual choice of start and stop codes. The uppercase letters A, B, C, and D are used for start and stop codes. 
    /// The parentheses ( ) may also be used as the start and stop code to eliminate the letters from appearing in the human-readable version of the fonts.
    /// </summary>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters which sets the neccessary parameters for the requested barcode.</param>
    /// <returns>Return variable "ValidationResult" of type Boolean.</returns>

    procedure ValidateInputString(var TempBarcodeParameters: Record BarcodeParameters temporary) ValidationResult: Boolean
    var
        SymbologyEncoderImpl: Codeunit CodabarBarcodeEncoderImpl;
        IsHandled: Boolean;
    begin
        OnBeforeValidateSymbology(TempBarcodeParameters, ValidationResult, IsHandled);

        SymbologyEncoderImpl.ValidateInputString(TempBarcodeParameters, ValidationResult, IsHandled);

        OnAfterValidateSymbology(TempBarcodeParameters, ValidationResult);
    end;

    procedure Barcode(var TempBarcodeParameters: Record BarcodeParameters temporary) Base64Data: Text
    var
        SymbologyEncoderImpl: Codeunit CodabarBarcodeEncoderImpl;
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
