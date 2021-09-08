// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9210 "IDA 1D MSI Encoder" implements "Barcode Font Encoder"
{
    Access = Internal;

    procedure EncodeFont(InputText: Text; var BarcodeEncodeSettings: Record "Barcode Encode Settings"): Text
    var
        DotNetFontEncoder: DotNet FontEncoder;
    begin
        DotNetFontEncoder := DotNetFontEncoder.FontEncoder();
        exit(DotNetFontEncoder.MSI(InputText));
    end;

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
