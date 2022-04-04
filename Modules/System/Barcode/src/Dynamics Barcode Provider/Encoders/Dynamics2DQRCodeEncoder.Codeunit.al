// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9224 "Dynamics 2D QR-Code Encoder" implements "Barcode Image Encoder 2D"
{
    Access = Internal;

    procedure EncodeImage(InputText: Text; BarcodeEncodeSettings2D: Record "Barcode Encode Settings 2D") QRCodeImageTempBlob: Codeunit "Temp Blob"
    var
        IBarcodeProvider: DotNet "IBarcodeProvider";
        QRCodeProvider: DotNet "QRCodeProvider";
        QRCodeErrorCorrectionLevel: DotNet "QRCodeErrorCorrectionLevel";
        QRCodeOutStream: OutStream;
        CannotCreateQrCodeErr: Label 'QR Code could not be created.';
    begin
        QRCodeImageTempBlob.CreateOutStream(QRCodeOutStream);
        IBarcodeProvider := QRCodeProvider.QRCodeProvider();
        GetErrorCorrectionLevelFromEnum(QRCodeErrorCorrectionLevel, BarcodeEncodeSettings2D);
        if not IBarcodeProvider.GetBarcodeStream(InputText, QRCodeOutStream, QRCodeErrorCorrectionLevel,
            BarcodeEncodeSettings2D."Module Size", BarcodeEncodeSettings2D."Quite Zone Width", BarcodeEncodeSettings2D."Code Page")
        then
            Error(CannotCreateQrCodeErr);
    end;

    local procedure GetErrorCorrectionLevelFromEnum(var QRCodeErrorCorrectionLevel: DotNet "QRCodeErrorCorrectionLevel"; BarcodeEncodeSettings2D: Record "Barcode Encode Settings 2D")
    begin
        case BarcodeEncodeSettings2D."Error Correction Level" of
            BarcodeEncodeSettings2D."Error Correction Level"::High:
                QRCodeErrorCorrectionLevel := QRCodeErrorCorrectionLevel::High;
            BarcodeEncodeSettings2D."Error Correction Level"::Medium:
                QRCodeErrorCorrectionLevel := QRCodeErrorCorrectionLevel::Medium;
            BarcodeEncodeSettings2D."Error Correction Level"::Low:
                QRCodeErrorCorrectionLevel := QRCodeErrorCorrectionLevel::Low;
            BarcodeEncodeSettings2D."Error Correction Level"::Quartile:
                QRCodeErrorCorrectionLevel := QRCodeErrorCorrectionLevel::Quartile;
        end;
    end;
}