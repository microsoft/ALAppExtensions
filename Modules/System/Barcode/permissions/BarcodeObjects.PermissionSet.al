// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9203 "Barcode - Objects"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Regex - Objects";

    Permissions = Codeunit "IDA 1D Codabar Encoder" = X,
                  Codeunit "IDA 1D Code128 Encoder" = X,
                  Codeunit "IDA 1D Code39 Encoder" = X,
                  Codeunit "IDA 1D Code93 Encoder" = X,
                  Codeunit "IDA 1D EAN13 Encoder" = X,
                  Codeunit "IDA 1D EAN8 Encoder" = X,
                  Codeunit "IDA 1D I2of5 Encoder" = X,
                  Codeunit "IDA 1D MSI Encoder" = X,
                  Codeunit "IDA 1D Postnet Encoder" = X,
                  Codeunit "IDA 1D UPCA Encoder" = X,
                  Codeunit "IDA 1D UPCE Encoder" = X,
                  Codeunit "IDAutomation 1D Provider" = X,
                  Codeunit "IDAutomation 2D Provider" = X,
                  Codeunit "IDA 2D Aztec Encoder" = X,
                  Codeunit "IDA 2D Data Matrix Encoder" = X,
                  Codeunit "IDA 2D Maxi Code Encoder" = X,
                  Codeunit "IDA 2D PDF417 Encoder" = X,
                  Codeunit "IDA 2D QR-Code Encoder" = X,
                  Codeunit "Dynamics 2D Provider" = X,
                  Codeunit "Dynamics 2D QR-Code Encoder" = X,
                  Table "Barcode Encode Settings" = X,
                  Table "Barcode Encode Settings 2D" = X;
}
