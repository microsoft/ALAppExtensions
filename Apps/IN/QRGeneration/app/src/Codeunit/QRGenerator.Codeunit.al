// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.QRGeneration;

using System.Utilities;

codeunit 18650 "QR Generator"
{
    [TryFunction]
    procedure GenerateQRCodeImage(SourceText: Text; var TempBlob: Codeunit "Temp Blob")
    var
        QRCodeProvider: DotNet "India QR-Bill QRCode Provider";
        OutStream: OutStream;
    begin
        TempBlob.CreateOutStream(OutStream);
        QRCodeProvider := QRCodeProvider.QRCodeProvider();
        QRCodeProvider.GetBarcodeStream(SourceText, OutStream);
    end;
}
