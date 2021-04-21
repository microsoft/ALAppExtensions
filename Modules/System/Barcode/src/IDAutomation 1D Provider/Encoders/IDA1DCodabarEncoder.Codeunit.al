// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9214 "IDA 1D Codabar Encoder" implements "Barcode Font Encoder"
{
    Access = Internal;

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
    /// <param name="InputText">The text to encode.</param>
    /// <param name="BarcodeEncodeSettings">Unused.</param>
    /// <returns>The encoded barcode.</returns>
    procedure EncodeFont(InputText: Text; var BarcodeEncodeSettings: Record "Barcode Encode Settings"): Text
    var
        DotNetFontEncoder: DotNet FontEncoder;
    begin
        DotNetFontEncoder := DotNetFontEncoder.FontEncoder();
        exit(DotNetFontEncoder.Codabar(InputText));
    end;


    /// <summary> 
    /// Validates if a text is a valid string to encode as barcode.
    /// From: https://www.idautomation.com/barcode-fonts/codabar/
    /// The Codabar symbology is used for several numeric barcoding applications including libraries, blood banks, and parcels. 
    /// The Codabar character set includes numeric characters 0-9, alpha letters A to D and the following symbols: - $ / +. 
    /// The Codabar barcode type has been used for various high-density numeric bar-coding applications including libraries, blood banks, and parcels. Codabar is self-checking, 
    /// eliminating the requirement for checksum characters, which allow it to be easily incorporated into existing applications.
    /// The Codabar character set consists of barcode symbols representing characters 0-9, Letters A to D and the following symbols: - $ / +. 
    /// Additional data may be encoded in the actual choice of start and stop codes. The uppercase letters A, B, C, and D are used for start and stop codes. 
    /// The parentheses ( ) may also be used as the start and stop code to eliminate the letters from appearing in the human-readable version of the fonts.
    /// 
    /// Using regex from https://www.neodynamic.com/Products/Help/BarcodeWinControl2.5/working_barcode_symbologies.htm
    /// </summary>
    /// <param name="InputText">The text to encode.</param>
    /// <param name="BarcodeEncodeSettings">Unused.</param>
    /// <returns>True if the validation succeeds; otherwise - false.</returns>
    procedure IsValidInput(InputText: Text; var BarcodeEncodeSettings: Record "Barcode Encode Settings"): Boolean
    var
        RegexPattern: codeunit Regex;
    begin
        if InputText = '' then
            exit(false);

        // Verify if input string containings only valid characters
        // and check if this input string contains Start-chars A, B, C or D
        if CopyStr(InputText, 1, 1) in ['A', 'B', 'C', 'D'] then
            exit(RegexPattern.IsMatch(InputText, '^[A-D][0-9\+$:\-\.\/]*[A-D]$'));

        exit(RegexPattern.IsMatch(InputText, '^[0-9\+$:\-\.\/]*$'));
    end;
}
