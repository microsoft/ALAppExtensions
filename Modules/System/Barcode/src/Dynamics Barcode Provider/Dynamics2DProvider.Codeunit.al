// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9222 "Dynamics 2D Provider" implements "Barcode Image Provider 2D"
{
    Access = Internal;

    var
        CannotFindBarcodeEncoderErr: Label 'Provider %1: 2D Barcode symbol encoder %2 is not implemented by this provider!', comment = '%1 Provider Caption, %2 = Symbology Caption';

    procedure GetSupportedBarcodeSymbologies(var Result: List of [Enum "Barcode Symbology 2D"])
    var
        DummyEncoder2D: Interface "Barcode Image Encoder 2D";
        CurrentBarcodeSymbology2D: Enum "Barcode Symbology 2D";
    begin
        Clear(Result);

        foreach CurrentBarcodeSymbology2D in Enum::"Barcode Symbology 2D".Ordinals() do
            if GetBarcodeImageEncoder2D(CurrentBarcodeSymbology2D, DummyEncoder2D) then
                Result.Add(CurrentBarcodeSymbology2D);
    end;

    procedure EncodeImage(InputText: Text; BarcodeSymbology2D: Enum "Barcode Symbology 2D"): Codeunit "Temp Blob"
    var
        BarcodeImageEncoder2D: Interface "Barcode Image Encoder 2D";
    begin
        if not GetBarcodeImageEncoder2D(BarcodeSymbology2D, BarcodeImageEncoder2D) then
            Error(CannotFindBarcodeEncoderErr, Enum::"Barcode Image Provider 2D"::Dynamics2D, BarcodeSymbology2D);

        exit(BarcodeImageEncoder2D.EncodeImage(InputText));
    end;

    local procedure GetBarcodeImageEncoder2D(BarcodeSymbology2D: Enum "Barcode Symbology 2D"; var BarcodeImageEncoder2D: Interface "Barcode Image Encoder 2D"): Boolean
    var
        Dynamics2DQRCodeEncoder: Codeunit "Dynamics 2D QR-Code Encoder";
    begin
        case BarcodeSymbology2D of
            Enum::"Barcode Symbology 2D"::"QR-Code":
                BarcodeImageEncoder2D := Dynamics2DQRCodeEncoder;
            else
                exit(false);
        end;

        exit(true);
    end;
}