// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.QRGeneration;

dotnet
{
    assembly(Microsoft.Dynamics.Nav.MX)
    {
        type(Microsoft.Dynamics.Nav.MX.BarcodeProviders.QRCodeProvider; "India QR-Bill QRCode Provider") { }
    }
}
