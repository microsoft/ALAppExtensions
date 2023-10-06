// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using System.Text;
using System.Utilities;

codeunit 11514 "Swiss QR-Bill Image Mgt."
{
    procedure GenerateSwissQRCodeImage(SourceText: Text; QRImageTempBlob: Codeunit "Temp Blob"): Boolean
    var
        SwissQRCodeHelper: Codeunit "Swiss QR Code Helper";
    begin
        exit(SwissQRCodeHelper.GenerateQRCodeImage(SourceText, QRImageTempBlob));
    end;
}
