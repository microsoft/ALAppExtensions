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
