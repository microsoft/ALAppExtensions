// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
/// <summary> 
/// Ean-8 barcode font implementation from IDAutomation
/// from: https://www.barcodefaq.com/barcode-properties/symbologies/ean-8/
/// An EAN-8 is an EAN/UPC symbology barcode and is derived from the longer International Article Number (EAN-13) code
/// </summary>
codeunit 9207 "IDA 1D EAN8 Encoder" implements "Barcode Font Encoder"
{
    Access = Internal;

    procedure EncodeFont(InputText: Text; var BarcodeEncodeSettings: Record "Barcode Encode Settings"): Text
    var
        DotNetFontEncoder: DotNet FontEncoder;
    begin
        DotNetFontEncoder := DotNetFontEncoder.FontEncoder();
        exit(DotNetFontEncoder.EAN8(InputText));
    end;

    procedure IsValidInput(InputText: Text; var BarcodeEncodeSettings: Record "Barcode Encode Settings"): Boolean;
    var
        RegexPattern: codeunit Regex;
    begin
        if InputText = '' then
            exit(false);

        if StrLen(InputText) <> 7 then
            exit(false);

        // match any string containing 7, 8, 9, 10, 12 or 13 digits
        exit(RegexPattern.IsMatch(InputText, '^[0-9]{7,10}$|^[0-9]{12,13}$'));
    end;
}
