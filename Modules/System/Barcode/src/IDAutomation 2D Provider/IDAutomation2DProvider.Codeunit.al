// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9221 "IDAutomation 2D Provider" implements "Barcode Font Provider 2D"
{
    Access = Internal;

    var
        CannotFindBarcodeEncoderErr: Label 'Provider %1: 2D Barcode symbol encoder %2 is not implemented by this provider!', comment = '%1 Provider Caption, %2 = Symbology Caption';

    procedure GetSupportedBarcodeSymbologies(var Result: List of [Enum "Barcode Symbology 2D"])
    var
        DummyEncoder2D: Interface "Barcode Font Encoder 2D";
        CurrentBarcodeSymbology2D: Enum "Barcode Symbology 2D";
    begin
        Clear(Result);

        foreach CurrentBarcodeSymbology2D in Enum::"Barcode Symbology 2D".Ordinals() do
            if GetBarcodeFontEncoder2D(CurrentBarcodeSymbology2D, DummyEncoder2D) then
                Result.Add(CurrentBarcodeSymbology2D);
    end;

    procedure EncodeFont(InputText: Text; BarcodeSymbology2D: Enum "Barcode Symbology 2D"): Text
    var
        BarcodeFontEncoder2D: Interface "Barcode Font Encoder 2D";
    begin
        if not GetBarcodeFontEncoder2D(BarcodeSymbology2D, BarcodeFontEncoder2D) then
            Error(CannotFindBarcodeEncoderErr, Enum::"Barcode Font Provider 2D"::IDAutomation2D, BarcodeSymbology2D);

        exit(BarcodeFontEncoder2D.EncodeFont(InputText));
    end;

    local procedure GetBarcodeFontEncoder2D(BarcodeSymbology2D: Enum "Barcode Symbology 2D"; var BarcodeFontEncoder2D: Interface "Barcode Font Encoder 2D"): Boolean
    var
        IDA2DAztecEncoder: Codeunit "IDA 2D Aztec Encoder";
        IDA2DDataMatrixEncoder: Codeunit "IDA 2D Data Matrix Encoder";
        IDA2DMaxiCodeEncoder: Codeunit "IDA 2D Maxi Code Encoder";
        IDA2DPDF417Encoder: Codeunit "IDA 2D PDF417 Encoder";
        IDA2DQRCodeEncoder: Codeunit "IDA 2D QR-Code Encoder";
    begin
        case BarcodeSymbology2D of
            Enum::"Barcode Symbology 2D"::Aztec:
                BarcodeFontEncoder2D := IDA2DAztecEncoder;
            Enum::"Barcode Symbology 2D"::"Data Matrix":
                BarcodeFontEncoder2D := IDA2DDataMatrixEncoder;
            Enum::"Barcode Symbology 2D"::"Maxi Code":
                BarcodeFontEncoder2D := IDA2DMaxiCodeEncoder;
            Enum::"Barcode Symbology 2D"::PDF417:
                BarcodeFontEncoder2D := IDA2DPDF417Encoder;
            Enum::"Barcode Symbology 2D"::"QR-Code":
                BarcodeFontEncoder2D := IDA2DQRCodeEncoder;
            else
                exit(false);
        end;

        exit(true);
    end;
}