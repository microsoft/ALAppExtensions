// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
/// <summary> 
/// Code-39 barcode font implementation from IDAutomation
/// from: https://www.idautomation.com/barcode-fonts/code-39/ 
/// An alpha-numeric barcode that encodes uppercase letters, numbers and some symbols; it is also referred to as Barcode/39, the 3 of 9 Code and LOGMARS Code.
/// </summary>
codeunit 9204 "IDA 1D Code39 Encoder" implements "Barcode Font Encoder"
{
    Access = Internal;

    procedure EncodeFont(InputText: Text; var BarcodeEncodeSettings: Record "Barcode Encode Settings"): Text
    var
        DotNetFontEncoder: DotNet FontEncoder;
    begin
        DotNetFontEncoder := DotNetFontEncoder.FontEncoder();

        if BarcodeEncodeSettings."Allow Extended Charset" then
            if BarcodeEncodeSettings."Enable Checksum" then
                exit(DotNetFontEncoder.Code39ExtMod43(InputText))
            else
                exit(DotNetFontEncoder.Code39Ext(InputText))

        else
            if BarcodeEncodeSettings."Enable Checksum" then
                exit(DotNetFontEncoder.Code39Mod43(InputText))
            else
                exit(DotNetFontEncoder.Code39(InputText));
    end;

    procedure IsValidInput(InputText: Text; var BarcodeEncodeSettings: Record "Barcode Encode Settings"): Boolean;
    var
        RegexPattern: codeunit Regex;
    begin
        if InputText = '' then
            exit(false);

        // Verify if input string containings only valid characters
        if BarcodeEncodeSettings."Allow Extended Charset" then
            exit(RegexPattern.IsMatch(InputText, '^[\000-\177]*$'));

        exit(RegexPattern.IsMatch(InputText, '^[0-9A-Z\-.$\/\+%\*\s]*$'));
    end;
}
