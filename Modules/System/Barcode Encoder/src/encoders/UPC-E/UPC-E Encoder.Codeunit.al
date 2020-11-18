// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
/// <summary> 
/// UPC-E barcode font implementation from IDAutomation
/// from: https://www.barcodefaq.com/barcode-properties/symbologies/upc-e/
/// Is most commonly used to encode 12 digits of the GTIN.
/// </summary>
codeunit 9224 UPCE_BarcodeEncoder implements IBarcodeEncoder
{
    Access = Public;

    /// <summary> 
    /// Encodes the barcode string to print a barcode using the IDautomation barcode font.
    /// From: https://www.barcodefaq.com/barcode-properties/symbologies/upc-e/
    /// To allow the use of UPC barcodes on smaller packages, where a full 12-digit barcode may not fit, a 'zero-suppressed version of UPC was developed, called UPC-E, in which the number system digit, all trailing zeros in the manufacturer code, and all leading zeros in the product code, are suppressed (omitted). 
    /// This symbology differs from UPC-A in that it only uses a 6-digit code, does not use M (middle) guard pattern, and the E (end) guard pattern is formed as space-bar-space-bar-space-bar, i.e. UPC-E barcode follows the pattern SDDDDDDE. 
    /// The way in which a 6-digit UPC-E relates to a 12-digit UPC-A, is determined by UPC-E numerical pattern and UPC-E parity pattern. 
    /// It can only correspond to UPC-A number system 0 or 1, the value of which, along with the UPC-A check digit, determines the UPC-E parity pattern of the encoding.
    /// </summary>
    /// <seealso cref="OnBeforeEncodeFont"/> 
    /// <seealso cref="OnAfterEncodeFont"/>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary.</param>
    /// <returns>Return variable "EncodedText" of type Text.</returns>
    procedure FontEncoder(var TempBarcodeParameters: Record BarcodeParameters temporary) EncodedText: Text
    var
        SymbologyEncoderImpl: Codeunit UPCE_BarcodeEncoderImpl;
        IsHandled: Boolean;
    begin
        OnBeforeEncodeFont(TempBarcodeParameters, EncodedText, IsHandled);

        SymbologyEncoderImpl.FontEncoder(TempBarcodeParameters, EncodedText, IsHandled);

        OnAfterEncodeFont(TempBarcodeParameters, EncodedText);
    end;

    /// <summary> 
    /// Encodes the barcode string to generate a barcode image in Base64 format
    /// From: https://www.barcodefaq.com/barcode-properties/symbologies/upc-e/
    /// To allow the use of UPC barcodes on smaller packages, where a full 12-digit barcode may not fit, a 'zero-suppressed version of UPC was developed, called UPC-E, in which the number system digit, all trailing zeros in the manufacturer code, and all leading zeros in the product code, are suppressed (omitted). 
    /// This symbology differs from UPC-A in that it only uses a 6-digit code, does not use M (middle) guard pattern, and the E (end) guard pattern is formed as space-bar-space-bar-space-bar, i.e. UPC-E barcode follows the pattern SDDDDDDE. 
    /// The way in which a 6-digit UPC-E relates to a 12-digit UPC-A, is determined by UPC-E numerical pattern and UPC-E parity pattern. 
    /// It can only correspond to UPC-A number system 0 or 1, the value of which, along with the UPC-A check digit, determines the UPC-E parity pattern of the encoding.
    /// </summary>
    /// <seealso cref="OnBeforeEncodeBase64Image"/> 
    /// <seealso cref="OnAfterEncodeBase64Image"/>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary.</param>
    /// <returns>Return variable "Base64Image" of type Text.</returns>
    procedure Base64ImageEncoder(var TempBarcodeParameters: Record BarcodeParameters temporary) Base64Image: Text
    var
        SymbologyEncoderImpl: Codeunit UPCE_BarcodeEncoderImpl;
        IsHandled: Boolean;
    begin
        OnBeforeEncodeBase64Image(TempBarcodeParameters, Base64Image, IsHandled);

        SymbologyEncoderImpl.Base64ImageEncoder(TempBarcodeParameters, Base64Image, IsHandled);

        OnAfterEncodeBase64Image(TempBarcodeParameters, Base64Image);
    end;

    /// <summary> 
    /// Validates if the Input String is a valid string to encode the barcode.
    /// From: https://en.wikipedia.org/wiki/Universal_Product_Code#UPC-E
    /// Assumes that input is not-null and non-empty
    /// Only 0-9 characters are valid input characters
    /// input string must be exactly 6, 7, or 8 characters long
    /// Using regex from https://www.neodynamic.com/Products/Help/BarcodeWinControl2.5/working_barcode_symbologies.htm
    /// </summary>
    /// <seealso cref="OnBeforeValidateInputString"/> 
    /// <seealso cref="OnAfterValidateInputString"/>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary.</param>
    /// <returns>Return variable "InputStringOK" of type Boolean.</returns>
    procedure ValidateInputString(var TempBarcodeParameters: Record BarcodeParameters temporary) InputStringOK: Boolean
    var
        SymbologyEncoderImpl: Codeunit UPCE_BarcodeEncoderImpl;
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
