// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9203 "Dynamics 2D QR-Code Encoder" implements "Barcode Image Encoder 2D"
{
    Access = Internal;

    procedure EncodeImage(InputText: Text) QRCodeImageTempBlob: Codeunit "Temp Blob"
    var
        IBarcodeProvider: DotNet "IBarcodeProvider";
        QRCodeProvider: DotNet "QRCodeProvider";
        QRCodeErrorCorrectionLevel: DotNet "QRCodeErrorCorrectionLevel";
        QRCodeOutStream: OutStream;
    begin
        QRCodeImageTempBlob.CreateOutStream(QRCodeOutStream);
        IBarcodeProvider := QRCodeProvider.QRCodeProvider();
        IBarcodeProvider.GetBarcodeStream(InputText, QRCodeOutStream, QRCodeErrorCorrectionLevel::Medium, 5, 0, 932);
    end;
}