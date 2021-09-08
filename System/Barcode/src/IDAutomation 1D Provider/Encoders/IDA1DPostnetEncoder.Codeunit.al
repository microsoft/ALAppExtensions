// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9211 "IDA 1D Postnet Encoder" implements "Barcode Font Encoder"
{
    Access = Internal;

    procedure EncodeFont(InputText: Text; var BarcodeEncodeSettings: Record "Barcode Encode Settings"): Text
    var
        DotNetFontEncoder: DotNet FontEncoder;
    begin
        DotNetFontEncoder := DotNetFontEncoder.FontEncoder();
        exit(DotNetFontEncoder.Postnet(InputText));
    end;

    procedure IsValidInput(InputText: Text; var BarcodeEncodeSettings: Record "Barcode Encode Settings"): Boolean;
    var
        RegexPattern: codeunit Regex;
    begin
        if InputText = '' then
            exit(false);

        // match any string containing 5, 6, 9 or 11 digits
        exit(RegexPattern.IsMatch(InputText, '^[0-9]{5,6}$|^[0-9]{9}$|^[0-9]{11}$'));
    end;
}
