// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9215 "IDAutomation 1D Provider" implements "Barcode Font Provider"
{
    Access = Internal;

    var
        CannotFindBarcodeEncoderErr: Label 'Provider %1: Barcode symbol encoder %2 is not implemented by this provider!', comment = '%1 Provider Caption, %2 = Symbology Caption';
        InvalidTextErr: Label 'Input text %1 contains invalid characters for the chosen provider %2 and encoding symbology %3', comment = '%1 = Input String, %2 = Provider Caption, %3 = Symbology Caption';

    procedure GetSupportedBarcodeSymbologies(var Result: List of [Enum "Barcode Symbology"])
    var
        DummyEncoder: Interface "Barcode Font Encoder";
        CurrentBarcodeSymbology: Enum "Barcode Symbology";
    begin
        Clear(Result);

        foreach CurrentBarcodeSymbology in Enum::"Barcode Symbology".Ordinals() do
            if GetBarcodeFontEncoder(CurrentBarcodeSymbology, DummyEncoder) then
                Result.Add(CurrentBarcodeSymbology);
    end;

    procedure EncodeFont(InputText: Text; Encoder: Enum "Barcode Symbology"): Text;
    var
        BarcodeEncodeSettings: Record "Barcode Encode Settings";
    begin
        exit(EncodeFont(InputText, Encoder, BarcodeEncodeSettings));
    end;

    procedure EncodeFont(InputText: Text; BarcodeSymbology: Enum "Barcode Symbology"; BarcodeEncodeSettings: Record "Barcode Encode Settings"): Text;
    var
        BarcodeFontEncoder: Interface "Barcode Font Encoder";
    begin
        if not GetBarcodeFontEncoder(BarcodeSymbology, BarcodeFontEncoder) then
            Error(CannotFindBarcodeEncoderErr, Enum::"Barcode Font Provider"::IDAutomation1D, BarcodeSymbology);

        exit(BarcodeFontEncoder.EncodeFont(InputText, BarcodeEncodeSettings));
    end;

    procedure ValidateInput(InputText: Text; BarcodeSymbology: Enum "Barcode Symbology")
    var
        BarcodeEncodeSettings: Record "Barcode Encode Settings";
    begin
        ValidateInput(InputText, BarcodeSymbology, BarcodeEncodeSettings);
    end;

    procedure ValidateInput(InputText: Text; BarcodeSymbology: Enum "Barcode Symbology"; BarcodeEncodeSettings: Record "Barcode Encode Settings")
    var
        BarcodeFontEncoder: Interface "Barcode Font Encoder";
    begin
        if not GetBarcodeFontEncoder(BarcodeSymbology, BarcodeFontEncoder) then
            Error(CannotFindBarcodeEncoderErr, Enum::"Barcode Font Provider"::IDAutomation1D, BarcodeSymbology);

        if not BarcodeFontEncoder.IsValidInput(InputText, BarcodeEncodeSettings) then
            Error(InvalidTextErr, InputText, Format(Enum::"Barcode Font Provider"::IDAutomation1D), Format(BarcodeSymbology));
    end;

    local procedure GetBarcodeFontEncoder(BarcodeSymbology: Enum "Barcode Symbology"; var BarcodeFontEncoder: Interface "Barcode Font Encoder"): Boolean
    var
        IDA1DCode39Encoder: Codeunit "IDA 1D Code39 Encoder";
        IDA1DCodabarEncoder: Codeunit "IDA 1D Codabar Encoder";
        IDA1DCode128Encoder: Codeunit "IDA 1D Code128 Encoder";
        IDA1DCode93Encoder: Codeunit "IDA 1D Code93 Encoder";
        IDA1DI2of5Encoder: Codeunit "IDA 1D I2of5 Encoder";
        IDA1DPostnetEncoder: Codeunit "IDA 1D Postnet Encoder";
        IDA1DMsiEncoder: Codeunit "IDA 1D MSI Encoder";
        IDA1DEan8Encoder: Codeunit "IDA 1D EAN8 Encoder";
        IDA1DEan13Encoder: Codeunit "IDA 1D EAN13 Encoder";
        IDA1DUpcaEncoder: Codeunit "IDA 1D UPCA Encoder";
        IDA1DUpceEncoder: Codeunit "IDA 1D UPCE Encoder";
    begin
        case BarcodeSymbology of
            Enum::"Barcode Symbology"::Code39:
                BarcodeFontEncoder := IDA1DCode39Encoder;
            Enum::"Barcode Symbology"::Codabar:
                BarcodeFontEncoder := IDA1DCodabarEncoder;
            Enum::"Barcode Symbology"::Code128:
                BarcodeFontEncoder := IDA1DCode128Encoder;
            Enum::"Barcode Symbology"::Code93:
                BarcodeFontEncoder := IDA1DCode93Encoder;
            Enum::"Barcode Symbology"::Interleaved2of5:
                BarcodeFontEncoder := IDA1DI2of5Encoder;
            Enum::"Barcode Symbology"::Postnet:
                BarcodeFontEncoder := IDA1DPostnetEncoder;
            Enum::"Barcode Symbology"::MSI:
                BarcodeFontEncoder := IDA1DMsiEncoder;
            Enum::"Barcode Symbology"::"EAN-8":
                BarcodeFontEncoder := IDA1DEan8Encoder;
            Enum::"Barcode Symbology"::"EAN-13":
                BarcodeFontEncoder := IDA1DEan13Encoder;
            Enum::"Barcode Symbology"::"UPC-A":
                BarcodeFontEncoder := IDA1DUpcaEncoder;
            Enum::"Barcode Symbology"::"UPC-E":
                BarcodeFontEncoder := IDA1DUpceEncoder;
            else
                exit(false);
        end;

        exit(true);
    end;
}