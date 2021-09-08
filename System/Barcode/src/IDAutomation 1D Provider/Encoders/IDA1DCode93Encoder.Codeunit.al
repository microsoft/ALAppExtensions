// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
/// <summary> 
/// Code-93 barcode font implementation from IDAutomation
/// from: https://www.idautomation.com/barcode-fonts/code-93/
/// Similar to Code 39, but requires two checksum characters.
/// </summary>
codeunit 9205 "IDA 1D Code93 Encoder" implements "Barcode Font Encoder"
{
    Access = Internal;

    procedure EncodeFont(InputText: Text; var BarcodeEncodeSettings: Record "Barcode Encode Settings"): Text
    var
        DotNetFontEncoder: DotNet FontEncoder;
    begin
        DotNetFontEncoder := DotNetFontEncoder.FontEncoder();
        exit(DotNetFontEncoder.Code93(InputText));
    end;

    procedure IsValidInput(InputText: Text; var BarcodeEncodeSettings: Record "Barcode Encode Settings"): Boolean;
    var
        RegexPattern: Codeunit Regex;
    begin
        if InputText = '' then
            exit(false);

        // Verify if input string containings only valid characters
        if BarcodeEncodeSettings."Allow Extended Charset" then
            exit(RegexPattern.IsMatch(InputText, '^[\000-\177]*$'));

        exit(RegexPattern.IsMatch(InputText, '^[0-9A-Z\-.$\/\+%\*\s]*$'));
    end;
}
