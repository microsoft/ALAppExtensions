// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
/// <summary> 
/// MSI Plessey barcode font implementation from IDAutomation
/// from: https://www.idautomation.com/barcode-fonts/msi/
/// The MSI Plessey barcode symbology was designed in the 1970s by the Plessey Company in England and has practiced primarily in libraries and retail applications. 
/// The Plessey barcode character set consists of barcode symbols representing the numbers 0-9, the start character, and the stop character. 
/// In the MSI font, the parentheses are used for start and stop characters.
/// </summary>

codeunit 9230 MSIBarcodeEncoder implements IBarcodeEncoder
{
    Access = Public;

    /// <summary> 
    /// Encodes the barcode string to print a barcode using the IDautomation barcode font.
    /// From: https://en.wikipedia.org/wiki/MSI_Barcode/
    /// MSI (also known as Modified Plessey) is a barcode symbology developed by the MSI Data Corporation, based on the original Plessey Code symbology. 
    /// It is a continuous symbology that is not self-checking. MSI is used primarily for inventory control, marking storage containers and shelves in warehouse environments.    
    /// </summary>
    /// <seealso cref="OnBeforeEncodeFont"/> 
    /// <seealso cref="OnAfterEncodeFont"/>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary.</param>
    /// <returns>Return variable "EncodedText" of type Text.</returns>
    procedure FontEncoder(var TempBarcodeParameters: Record BarcodeParameters temporary) EncodedText: Text
    var
        SymbologyEncoderImpl: Codeunit MSI_BarcodeEncoderImpl;
        IsHandled: Boolean;
    begin
        OnBeforeEncodeFont(TempBarcodeParameters, EncodedText, IsHandled);

        SymbologyEncoderImpl.FontEncoder(TempBarcodeParameters, EncodedText, IsHandled);

        OnAfterEncodeFont(TempBarcodeParameters, EncodedText);
    end;

    /// <summary> 
    /// Encodes the barcode string to generate a barcode image in Base64 format
    /// From: https://en.wikipedia.org/wiki/MSI_Barcode/
    /// MSI (also known as Modified Plessey) is a barcode symbology developed by the MSI Data Corporation, based on the original Plessey Code symbology. 
    /// It is a continuous symbology that is not self-checking. MSI is used primarily for inventory control, marking storage containers and shelves in warehouse environments.   
    /// </summary>
    /// <seealso cref="OnBeforeEncodeBase64Image"/> 
    /// <seealso cref="OnAfterEncodeBase64Image"/>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary.</param>
    /// <returns>Return variable "Base64Image" of type Text.</returns>
    procedure Base64ImageEncoder(var TempBarcodeParameters: Record BarcodeParameters temporary) Base64Image: Text
    var
        SymbologyEncoderImpl: Codeunit MSI_BarcodeEncoderImpl;
        IsHandled: Boolean;
    begin
        OnBeforeEncodeBase64Image(TempBarcodeParameters, Base64Image, IsHandled);

        SymbologyEncoderImpl.Base64ImageEncoder(TempBarcodeParameters, Base64Image, IsHandled);

        OnAfterEncodeBase64Image(TempBarcodeParameters, Base64Image);
    end;

    /// <summary> 
    /// Validates the Input String of the barcode.
    /// From: https://en.wikipedia.org/wiki/MSI_Barcode/
    /// Assumes that input is not-null and non-empty
    /// Only 0-9 characters are valid input characters
    /// Using regex from https://www.neodynamic.com/Products/Help/BarcodeWinControl2.5/working_barcode_symbologies.htm
    /// </summary>
    /// <seealso cref="OnBeforeValidateInputString"/> 
    /// <seealso cref="OnAfterValidateInputString"/>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary.</param>
    /// <returns>Return variable "InputStringOK" of type Boolean.</returns>
    procedure ValidateInputString(var TempBarcodeParameters: Record BarcodeParameters temporary) InputStringOK: Boolean
    var
        SymbologyEncoderImpl: Codeunit MSI_BarcodeEncoderImpl;
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
