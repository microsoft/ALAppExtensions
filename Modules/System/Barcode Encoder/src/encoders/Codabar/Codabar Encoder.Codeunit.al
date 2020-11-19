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
    /// 
    /// Use the Function IsFontEncoder() to check if this function implemented to prevent an error, or implement your own function by subscribing to event OnBeforeEncodeFont()
    /// </summary>
    /// <seealso cref="OnBeforeEncodeFont"/> 
    /// <seealso cref="OnAfterEncodeFont"/> 
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters which sets the neccessary parameters for the requested barcode.</param>
    /// <returns>Return variable "EncodedText" of type Text.</returns>
    procedure FontEncoder(var TempBarcodeParameters: Record BarcodeParameters temporary) EncodedText: Text
    var
        SymbologyEncoderImpl: Codeunit CodabarBarcodeEncoderImpl;
        IsHandled: Boolean;
    begin
        OnBeforeEncodeFont(TempBarcodeParameters, EncodedText, IsHandled);

        SymbologyEncoderImpl.FontEncoder(TempBarcodeParameters, EncodedText, IsHandled);

        OnAfterEncodeFont(TempBarcodeParameters, EncodedText);
    end;

    /// <summary> 
    /// Encodes the barcode string to generate a barcode image in Base64 format
    /// From: https://en.wikipedia.org/wiki/Codabar/
    /// The Codabar character set includes numeric characters 0-9, alpha letters A to D and the following symbols: - $ / +. 
    /// The Codabar barcode type has been used for various high-density numeric bar-coding applications including libraries, blood banks, and parcels. Codabar is self-checking, 
    /// eliminating the requirement for checksum characters, which allow it to be easily incorporated into existing applications.
    /// The Codabar character set consists of barcode symbols representing characters 0-9, Letters A to D and the following symbols: - $ / +. 
    /// Additional data may be encoded in the actual choice of start and stop codes. The uppercase letters A, B, C, and D are used for start and stop codes. 
    /// The parentheses ( ) may also be used as the start and stop code to eliminate the letters from appearing in the human-readable version of the fonts.
    /// 
    /// This Function is currently throwing an error and is reserved for future use when Base64ImageEncoding will be supported.
    /// Use the Function IsBase64Encoder() to check if this function implemented to prevent an error, or implement your own function by subscribing to event OnBeforeEncodeBase64Image()
    /// </summary>
    /// <seealso cref="OnBeforeEncodeBase64Image"/> 
    /// <seealso cref="OnAfterEncodeBase64Image"/>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary.</param>
    /// <returns>Return variable "Base64Image" of type Text.</returns>
    procedure Base64ImageEncoder(var TempBarcodeParameters: Record BarcodeParameters temporary) Base64Image: Text
    var
        SymbologyEncoderImpl: Codeunit CodabarBarcodeEncoderImpl;
        IsHandled: Boolean;
    begin
        OnBeforeEncodeBase64Image(TempBarcodeParameters, Base64Image, IsHandled);

        SymbologyEncoderImpl.Base64ImageEncoder(TempBarcodeParameters, Base64Image, IsHandled);

        OnAfterEncodeBase64Image(TempBarcodeParameters, Base64Image);
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
    /// <seealso cref="OnBeforeValidateInputString"/> 
    /// <seealso cref="OnAfterValidateInputString"/>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters which sets the neccessary parameters for the requested barcode.</param>
    /// <returns>Return variable "InputStringOK" of type Boolean.</returns>
    procedure ValidateInputString(var TempBarcodeParameters: Record BarcodeParameters temporary) InputStringOK: Boolean
    var
        SymbologyEncoderImpl: Codeunit CodabarBarcodeEncoderImpl;
        IsHandled: Boolean;
    begin
        OnBeforeValidateInputString(TempBarcodeParameters, InputStringOK, IsHandled);

        SymbologyEncoderImpl.ValidateInputString(TempBarcodeParameters, InputStringOK, IsHandled);

        OnAfterValidateInputString(TempBarcodeParameters, InputStringOK);
    end;

    /// <summary> 
    /// Shows if this encoder is implemented as a Barcode Font Encoder
    /// </summary>
    /// <returns>Return variable "Boolean".</returns>
    procedure IsFontEncoder(): Boolean
    begin
        exit(true);
    end;

    /// <summary> 
    /// Shows if this encoder is implemeted as a Barcode Image in Base64 format
    /// </summary>
    /// <returns>Return variable "Boolean".</returns>
    procedure IsBase64ImageEncoder(): Boolean
    begin
        exit(false);
    end;

    /// <summary> 
    /// Event publisher to overule the standard encoding
    /// </summary>
    /// <seealso cref="FontEncoder"/>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary.</param>
    /// <param name="EncodedText">Parameter of type Text.</param>
    /// <param name="IsHandled">Parameter of type Boolean.</param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeEncodeFont(var TempBarcodeParameters: Record BarcodeParameters temporary; var EncodedText: Text; var IsHandled: Boolean)
    begin
    end;

    /// <summary> 
    /// Event publisher to process the generated encoded text the standard encoding
    /// </summary>
    /// <seealso cref="FontEncoder"/>    
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary.</param>
    /// <param name="EncodedText">Parameter of type Text.</param>
    [IntegrationEvent(false, false)]
    local procedure OnAfterEncodeFont(var TempBarcodeParameters: Record BarcodeParameters temporary; var EncodedText: Text)
    begin
    end;

    /// <summary> 
    /// Event publisher to overule the standard validation of the encoding
    /// </summary>
    /// <seealso cref="Base64ImageEncoder"/> 
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary.</param>
    /// <param name="InputStringOK">Parameter of type Boolean.</param>
    /// <param name="IsHandled">Parameter of type Boolean.</param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateInputString(var TempBarcodeParameters: Record BarcodeParameters temporary; var InputStringOK: Boolean; var IsHandled: Boolean)
    begin
    end;

    /// <summary> 
    /// Event publisher to add additional validation to the standard encoding
    /// </summary>
    /// <seealso cref="ValidateInputString"/> 
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary.</param>
    /// <param name="InputStringOK">Parameter of type Boolean.</param>
    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateInputString(var TempBarcodeParameters: Record BarcodeParameters temporary; InputStringOK: Boolean)
    begin
    end;

    /// <summary> 
    /// Event publisher to overule the standard encoding
    /// </summary>
    /// <seealso cref="ValidateInputString"/> 
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary.</param>
    /// <param name="Base64Image">Parameter of type Text.</param>
    /// <param name="IsHandled">Parameter of type Boolean.</param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeEncodeBase64Image(var TempBarcodeParameters: Record BarcodeParameters temporary; var Base64Image: Text; var IsHandled: Boolean)
    begin
    end;

    /// <summary> 
    /// Event publisher to process the generated encoded base64 text of the standard encoding
    /// </summary>
    /// <seealso cref="Base64ImageEncoder"/> 
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary.</param>
    /// <param name="Base64Image">Parameter of type Text.</param>
    [IntegrationEvent(false, false)]
    local procedure OnAfterEncodeBase64Image(var TempBarcodeParameters: Record BarcodeParameters temporary; var Base64Image: Text)
    begin
    end;
}
