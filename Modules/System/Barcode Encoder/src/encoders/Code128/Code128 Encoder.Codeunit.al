// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
/// <summary> 
/// Code-128 barcode font implementation from IDAutomation
/// from: https://www.idautomation.com/barcode-fonts/code-128/ 
/// Alpha-numeric barcode with three character sets. Supports Code-128, GS1-128 (Formerly known as UCC/EAN-128) and ISBT-128.
/// </summary>
codeunit 9216 Code128BarcodeEncoder implements IBarcodeEncoder
{
    Access = Public;

    /// <summary> 
    /// Encodes the barcode string to print a barcode using the IDautomation barcode font.
    /// From: https://en.wikipedia.org/wiki/Code_128/
    /// Code 128 is a high-density linear barcode symbology defined in ISO/IEC 15417:2007.[1] It is used for alphanumeric or numeric-only barcodes. 
    /// It can encode all 128 characters of ASCII and, by use of an extension symbol (FNC4), the Latin-1 characters defined in ISO/IEC 8859-1. 
    /// It generally results in more compact barcodes compared to other methods like Code 39, especially when the texts contain mostly digits.
    /// GS1-128 (formerly known as UCC/EAN-128) is a subset of Code 128 and is used extensively worldwide in shipping and packaging industries as a product identification code for the container and pallet levels in the supply chain.
    /// </summary>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary.</param>
    procedure FontEncoder(var TempBarcodeParameters: Record BarcodeParameters temporary) EncodedText: Text
    var
        SymbologyEncoderImpl: Codeunit Code128_BarcodeEncoderImpl;
        IsHandled: Boolean;
    begin
        OnBeforeEncodeSymbology(TempBarcodeParameters, EncodedText, IsHandled);

        SymbologyEncoderImpl.FontEncoder(TempBarcodeParameters, EncodedText, IsHandled);

        OnAfterEncodeSymbology(TempBarcodeParameters, EncodedText);
    end;

    /// <summary> 
    /// Validates if the Input String is a valid string to encode the barcode.
    /// From: https://en.wikipedia.org/wiki/Code_128/
    /// Code 128 includes 108 symbols: 103 data symbols, 3 start symbols, and 2 stop symbols. 
    /// Each symbol consists of three black bars and three white spaces of varying widths. All widths are multiples of a basic "module". 
    /// Each bar and space is 1 to 4 modules wide, and the symbols are fixed width: the sum of the widths of the three black bars and three white bars is 11 modules.
    /// The stop pattern is composed of two overlapped symbols and has four bars. The stop pattern permits bidirectional scanning. When the stop pattern is read left-to-right (the usual case), the stop symbol (followed by a 2-module bar) is recognized. 
    /// When the stop pattern is read right-to-left, the reverse stop symbol (followed by a 2-module bar) is recognized. A scanner seeing the reverse stop symbol then knows it must skip the 2-module bar and read the rest of the barcode in reverse.
    /// Despite its name, Code 128 does not have 128 distinct symbols, so it cannot represent 128 code points directly. To represent all 128 ASCII values, it shifts among three code sets (A, B, C). 
    /// Together, code sets A and B cover all 128 ASCII characters. Code set C is used to efficiently encode digit strings. 
    /// The initial subset is selected by using the appropriate start symbol. Within each code set, some of the 103 data code points are reserved for shifting to one of the other two code sets. 
    /// The shifts are done using code points 98 and 99 in code sets A and B, 100 in code sets A and C and 101 in code sets B and C to switch between them):
    ///    -  128A (Code Set A) – ASCII characters 00 to 95 (0–9, A–Z and control codes), special characters, and FNC 1–4
    ///    -  128B (Code Set B) – ASCII characters 32 to 127 (0–9, A–Z, a–z), special characters, and FNC 1–4
    ///    -  128C (Code Set C) – 00–99 (encodes two digits with a single code point) and FNC1
    /// </summary>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary.</param>
    procedure ValidateInputString(var TempBarcodeParameters: Record BarcodeParameters temporary) ValidationResult: Boolean
    var
        SymbologyEncoderImpl: Codeunit Code128_BarcodeEncoderImpl;
        IsHandled: Boolean;
    begin
        OnBeforeValidateSymbology(TempBarcodeParameters, ValidationResult, IsHandled);

        SymbologyEncoderImpl.ValidateInputString(TempBarcodeParameters, ValidationResult, IsHandled);

        OnAfterValidateSymbology(TempBarcodeParameters, ValidationResult);
    end;

    procedure Barcode(var TempBarcodeParameters: Record BarcodeParameters temporary) Base64Data: Text
    var
        SymbologyEncoderImpl: Codeunit Code128_BarcodeEncoderImpl;
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
