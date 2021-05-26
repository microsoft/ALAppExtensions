// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9214 "IDA 1D Codabar Encoder" implements "Barcode Font Encoder"
{
    Access = Internal;

    procedure EncodeFont(InputText: Text; var BarcodeEncodeSettings: Record "Barcode Encode Settings"): Text
    var
        DotNetFontEncoder: DotNet FontEncoder;
    begin
        DotNetFontEncoder := DotNetFontEncoder.FontEncoder();
        exit(DotNetFontEncoder.Codabar(InputText));
    end;

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
