// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
/// <summary> 
/// Code-93 barcode font implementation from IDAutomation
/// from: https://www.idautomation.com/barcode-fonts/code-93/
/// Similar to Code 39, but requires two checksum characters.
/// </summary>
codeunit 9214 Code93BarcodeEncoder implements IBarcodeEncoder
{
    Access = Public;

    /// <summary> 
    /// Encodes the barcode string to print a barcode using the IDautomation barcode font.
    /// From: https://en.wikipedia.org/wiki/Code_93/
    /// It is an alphanumeric, variable length symbology. Code 93 is used primarily by Canada Post to encode supplementary delivery information. 
    /// Every symbol includes two check characters.
    /// Each Code 93 character is nine modules wide, and always has three bars and three spaces, thus the name. 
    /// Each bar and space is from 1 to 4 modules wide. (For comparison, a Code 39 character consists of five bars and four spaces, three of which are wide, for a total width of 13–16 modules.)
    /// </summary>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary.</param>
    procedure FontEncoder(var TempBarcodeParameters: Record BarcodeParameters temporary) EncodedText: Text
    var
        SymbologyEncoderImpl: Codeunit Code93_BarcodeEncoderImpl;
        IsHandled: Boolean;
    begin
        OnBeforeEncodeSymbology(TempBarcodeParameters, EncodedText, IsHandled);

        SymbologyEncoderImpl.FontEncoder(TempBarcodeParameters, EncodedText, IsHandled);

        OnAfterEncodeSymbology(TempBarcodeParameters, EncodedText);
    end;

    /// <summary> 
    /// Validates if the Input String is a valid string to encode the barcode.
    /// From: https://en.wikipedia.org/wiki/Code_93
    /// Each Code 93 character is nine modules wide, and always has three bars and three spaces, thus the name. 
    /// Each bar and space is from 1 to 4 modules wide. 
    /// (For comparison, a Code 39 character consists of five bars and four spaces, three of which are wide, for a total width of 13–16 modules.)
    ///
    /// Code 93 is designed to encode the same 26 upper case letters, 10 digits and 7 special characters as code 39:
    ///      A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
    ///      0 1 2 3 4 5 6 7 8 9
    ///      - . $ / + % SPACE
    /// Using regex from https://www.neodynamic.com/Products/Help/BarcodeWinControl2.5/working_barcode_symbologies.htm
    /// </summary>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary which sets the neccessary parameters for the requested barcode.</param>

    procedure ValidateInputString(var TempBarcodeParameters: Record BarcodeParameters temporary) ValidationResult: Boolean
    var
        SymbologyEncoderImpl: Codeunit Code93_BarcodeEncoderImpl;
        IsHandled: Boolean;
    begin
        OnBeforeValidateSymbology(TempBarcodeParameters, ValidationResult, IsHandled);

        SymbologyEncoderImpl.ValidateInputString(TempBarcodeParameters, ValidationResult, IsHandled);

        OnAfterValidateSymbology(TempBarcodeParameters, ValidationResult);
    end;

    procedure Barcode(var TempBarcodeParameters: Record BarcodeParameters temporary) Base64Data: Text
    var
        SymbologyEncoderImpl: Codeunit Code93_BarcodeEncoderImpl;
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
