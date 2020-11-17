// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
/// <summary> 
/// codabar barcode font implementation from IDAutomation
/// from: https://www.idautomation.com/barcode-fonts/codabar/ 
/// The Codabar symbology is used for several numeric barcoding applications including libraries, blood banks, and parcels. 
/// </summary>
codeunit 9213 CodabarBarcodeEncoderImpl
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
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters which sets the neccessary parameters for the requested barcode.</param>
    /// 
    procedure FontEncoder(var TempBarcodeParameters: Record BarcodeParameters temporary; var EncodedText: Text; IsHandled: Boolean)
    var
        FontEncoder: DotNet dnFontEncoder;
    begin
        if IsHandled then exit;

        FontEncoder := FontEncoder.FontEncoder();
        EncodedText := FontEncoder.Codabar(TempBarcodeParameters."Input String");
    end;

    /// <summary> 
    /// Validates if the Input String is a valid string to encode the barcode.
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
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary which sets the neccessary parameters for the requested barcode.</param>
    /// <param name="IsHandled">Parameter of type Boolean.</param>
    procedure ValidateInputString(var TempBarcodeParameters: Record BarcodeParameters temporary; var ValidationResult: Boolean; IsHandled: Boolean)
    var
        RegexPattern: codeunit Regex;
    begin
        if IsHandled then exit;

        ValidationResult := true;
        // null or empty
        if (TempBarcodeParameters."Input String" = '') then begin
            ValidationResult := false;
            exit;
        end;

        // Verify if input string containings only valid characters
        // and check if this input string contains Start-chars A, B, C or D
        if copystr(TempBarcodeParameters."Input String", 1, 1) in ['A', 'B', 'C', 'D'] then
            ValidationResult := RegexPattern.IsMatch(TempBarcodeParameters."Input String", '^[A-D][0-9\+$:\-\.\/]*[A-D]$')
        else
            ValidationResult := RegexPattern.IsMatch(TempBarcodeParameters."Input String", '^[0-9\+$:\-\.\/]*$');
    end;

    /// <summary> 
    /// Format is mapping the the data from D365 Business Central table data to a valid barcode input string.
    /// </summary>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary which sets the neccessary parameters for the requested barcode.</param>
    /// <param name="IsHandled">Parameter of type Boolean.</param>
    procedure Barcode(var TempBarcodeParameters: Record BarcodeParameters temporary; var Base64Data: Text; IsHandled: Boolean);
    begin
        if IsHandled then exit;
    end;
}
