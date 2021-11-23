// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 2891 "QR Code Impl."
{
    Access = Internal;

    [TryFunction]
    procedure GenerateQRCodeImage(SourceText: Text; QRCodeImageTempBlob: Codeunit "Temp Blob"; ErrorCorrectionLevel: Enum "QR Code Error Correction Level"; ModuleSize: Integer; QuiteZoneWidth: Integer; CodePage: Integer)
    var
        IBarcodeProvider: DotNet "IBarcodeProvider";
        QRCodeProvider: DotNet "QRCodeProvider";
        QRCodeErrorCorrectionLevel: DotNet "QRCodeErrorCorrectionLevel";
        QRCodeOutStream: OutStream;
    begin
        QRCodeImageTempBlob.CreateOutStream(QRCodeOutStream);
        IBarcodeProvider := QRCodeProvider.QRCodeProvider();
        GetErrorCorrectionLevelFromEnum(QRCodeErrorCorrectionLevel, ErrorCorrectionLevel);
        IBarcodeProvider.GetBarcodeStream(SourceText, QRCodeOutStream, QRCodeErrorCorrectionLevel::Medium, ModuleSize, QuiteZoneWidth, CodePage);
    end;

    local procedure GetErrorCorrectionLevelFromEnum(var QRCodeErrorCorrectionLevel: DotNet "QRCodeErrorCorrectionLevel"; ErrorCorrectionLevel: Enum "QR Code Error Correction Level")
    begin
        case ErrorCorrectionLevel of
            ErrorCorrectionLevel::High:
                QRCodeErrorCorrectionLevel := QRCodeErrorCorrectionLevel::High;
            ErrorCorrectionLevel::Medium:
                QRCodeErrorCorrectionLevel := QRCodeErrorCorrectionLevel::Medium;
            ErrorCorrectionLevel::Low:
                QRCodeErrorCorrectionLevel := QRCodeErrorCorrectionLevel::Low;
            ErrorCorrectionLevel::Quartile:
                QRCodeErrorCorrectionLevel := QRCodeErrorCorrectionLevel::Quartile;
        end;
    end;
}
