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
codeunit 9210 "IDA 1D MSI Encoder" implements "Barcode Font Encoder"
{
    Access = Internal;

    /// <summary> 
    /// Encodes the barcode string to print a barcode using the IDautomation barcode font.
    /// From: https://en.wikipedia.org/wiki/MSI_Barcode/
    /// MSI (also known as Modified Plessey) is a barcode symbology developed by the MSI Data Corporation, based on the original Plessey Code symbology. 
    /// It is a continuous symbology that is not self-checking. MSI is used primarily for inventory control, marking storage containers and shelves in warehouse environments.    
    /// </summary>
    /// <param name="InputText">The text to encode.</param>
    /// <param name="BarcodeEncodeSettings">Unused.</param>
    /// <returns>The encoded barcode.</returns>
    procedure EncodeFont(InputText: Text; var BarcodeEncodeSettings: Record "Barcode Encode Settings"): Text
    var
        DotNetFontEncoder: DotNet FontEncoder;
    begin
        DotNetFontEncoder := DotNetFontEncoder.FontEncoder();
        exit(DotNetFontEncoder.MSI(InputText));
    end;

    /// <summary> 
    /// Validates the text of the barcode.
    /// From: https://en.wikipedia.org/wiki/Interleaved_2_of_5
    /// Assumes that input is not-null and non-empty
    /// Only 0-9 characters are valid input characters
    /// Using regex from https://www.neodynamic.com/Products/Help/BarcodeWinControl2.5/working_barcode_symbologies.htm
    /// </summary>
    /// <param name="InputText">The text to validate.</param>
    /// <param name="BarcodeEncodeSettings">Unused.</param>
    /// <returns>True if the validation succeeds; otherwise - false.</returns>
    procedure IsValidInput(InputText: Text; var BarcodeEncodeSettings: Record "Barcode Encode Settings"): Boolean;
    var
        RegexPattern: Codeunit Regex;
    begin
        if InputText = '' then
            exit(false);

        // match any string containing only digit characters
        exit(RegexPattern.IsMatch(InputText, '^[0-9]*$'));
    end;
}
