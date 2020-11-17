// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
/// <summary> 
/// Code-39 barcode font implementation from IDAutomation
/// from: https://www.idautomation.com/barcode-fonts/code-39/ 
/// An alpha-numeric barcode that encodes uppercase letters, numbers and some symbols; it is also referred to as Barcode/39, the 3 of 9 Code and LOGMARS Code.
/// </summary>
codeunit 9210 Code39BarcodeEncoder implements IBarcodeEncoder
{
    Access = Public;

    /// <summary> 
    /// Encodes the barcode string to print a barcode using the IDautomation barcode font.
    /// From: https://en.wikipedia.org/wiki/Code_39/
    /// aka Alpha39, Code 3 of 9, Code 3/9, Type 39, USS Code 39, or USD-3
    /// Replace any spaces with = signs
    /// IDAutomation Uses ! as stop/start symbol
    /// Extended Code 39 barcode fonts barcode fonts are provided to easily encode lower case and special characters in a self checking font environment and begin with IDAutomationSX. 
    /// Extended Code 39 fonts are not compatible with IDAutomation's font encoders, such as the MOD43 function, and the asterisk (*) must be used as the start and stop character. 
    /// For extended characters to scan properly, the scanner must first be enabled to read extended code 39. These fonts are not part of the standard install, and therefore must be manually installed.
    /// </summary>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary which sets the neccessary parameters for the requested barcode.</param>
    procedure FontEncoder(var TempBarcodeParameters: Record BarcodeParameters temporary) EncodedText: Text
    var
        SymbologyEncoderImpl: Codeunit Code39_BarcodeEncoderImpl;
        IsHandled: Boolean;
    begin
        OnBeforeEncodeSymbology(TempBarcodeParameters, EncodedText, IsHandled);

        SymbologyEncoderImpl.FontEncoder(TempBarcodeParameters, EncodedText, IsHandled);

        OnAfterEncodeSymbology(TempBarcodeParameters, EncodedText);
    end;

    /// <summary> 
    /// Validates if the Input String is a valid string to encode the barcode.
    /// From: https://en.wikipedia.org/wiki/Code_39
    /// The Code 39 specification defines 43 characters, consisting of 
    /// uppercase letters(A through Z), numeric digits(0 through 9) 
    /// and a number of special characters(-, ., $, /, +, %, and space).
    /// Using regex from https://www.neodynamic.com/Products/Help/BarcodeWinControl2.5/working_barcode_symbologies.htm
    /// </summary>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary which sets the neccessary parameters for the requested barcode.</param>
    procedure ValidateInputString(var TempBarcodeParameters: Record BarcodeParameters temporary) ValidationResult: Boolean
    var
        SymbologyEncoderImpl: Codeunit Code39_BarcodeEncoderImpl;
        IsHandled: Boolean;
    begin
        OnBeforeValidateSymbology(TempBarcodeParameters, ValidationResult, IsHandled);

        SymbologyEncoderImpl.ValidateInputString(TempBarcodeParameters, ValidationResult, IsHandled);

        OnAfterValidateSymbology(TempBarcodeParameters, ValidationResult);
    end;

    /// <summary> 
    /// Description for Format.
    /// </summary>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters which sets the neccessary parameters for the requested barcode.</param>
    procedure Barcode(var TempBarcodeParameters: Record BarcodeParameters temporary) Base64Data: Text
    var
        SymbologyEncoderImpl: Codeunit Code39_BarcodeEncoderImpl;
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
