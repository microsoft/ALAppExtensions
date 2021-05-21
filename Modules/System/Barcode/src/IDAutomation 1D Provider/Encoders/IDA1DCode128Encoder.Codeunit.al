// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
/// <summary> 
/// Code-128 barcode font implementation from IDAutomation
/// from: https://www.idautomation.com/barcode-fonts/code-128/ 
/// Alpha-numeric barcode with three character sets. Supports Code-128, GS1-128 (Formerly known as UCC/EAN-128) and ISBT-128.
/// </summary>
codeunit 9206 "IDA 1D Code128 Encoder" implements "Barcode Font Encoder"
{
    Access = Internal;

    /// <summary> 
    /// Encodes the barcode string to print a barcode using the IDautomation barcode font.
    /// From: https://en.wikipedia.org/wiki/Code_128/
    /// Code 128 is a high-density linear barcode symbology defined in ISO/IEC 15417:2007.[1] It is used for alphanumeric or numeric-only barcodes. 
    /// It can encode all 128 characters of ASCII and, by use of an extension symbol (FNC4), the Latin-1 characters defined in ISO/IEC 8859-1. 
    /// It generally results in more compact barcodes compared to other methods like Code 39, especially when the texts contain mostly digits.
    /// GS1-128 (formerly known as UCC/EAN-128) is a subset of Code 128 and is used extensively worldwide in shipping and packaging industries as a product identification code for the container and pallet levels in the supply chain.
    /// </summary>
    /// <param name="InputText">The text to encode.</param>
    /// <param name="BarcodeEncodeSettings">The settings to use. The encoder uses only the 'Code Set' setting.</param>
    /// <param name="EncodedText">Parameter of type Text.</param>
    /// <returns>The encoded barcode.</returns>
    procedure EncodeFont(InputText: Text; var BarcodeEncodeSettings: Record "Barcode Encode Settings"): Text
    var
        DotNetFontEncoder: DotNet FontEncoder;
        EncodedText: Text;
    begin
        DotNetFontEncoder := DotNetFontEncoder.FontEncoder();

        case BarcodeEncodeSettings."Code Set" of
            BarcodeEncodeSettings."Code Set"::A:
                EncodedText := DotNetFontEncoder.Code128a(InputText);
            BarcodeEncodeSettings."Code Set"::B:
                EncodedText := DotNetFontEncoder.Code128b(InputText);
            BarcodeEncodeSettings."Code Set"::C:
                EncodedText := DotNetFontEncoder.Code128c(InputText);
            else
                EncodedText := DotNetFontEncoder.Code128(InputText);
        end;

        exit(EncodedText);
    end;

    /// <summary> 
    /// Validates if text is a valid string to encode the barcode.
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
    /// <param name="InputText">The text to validate.</param>
    /// <param name="BarcodeEncodeSettings">The settings to use. The encoder uses only the 'Code Set' option.</param>
    /// <returns>True if the validation succeeds; otherwise - false.</returns>
    procedure IsValidInput(InputText: Text; var BarcodeEncodeSettings: Record "Barcode Encode Settings"): Boolean;
    var
        RegexPattern: codeunit Regex;
        Result: Boolean;
    begin
        if InputText = '' then
            exit(false);

        case BarcodeEncodeSettings."Code Set" of
            BarcodeEncodeSettings."Code Set"::A:
                Result := RegexPattern.IsMatch(InputText, '^[\000-\137]*$');
            BarcodeEncodeSettings."Code Set"::B:
                Result := RegexPattern.IsMatch(InputText, '^[\040-\177]*$');
            BarcodeEncodeSettings."Code Set"::C:
                Result := RegexPattern.IsMatch(InputText, '^(([0-9]{2})+?)*$');
            else
                Result := RegexPattern.IsMatch(InputText, '^[\000-\177]*$');
        end;

        exit(Result);
    end;
}
