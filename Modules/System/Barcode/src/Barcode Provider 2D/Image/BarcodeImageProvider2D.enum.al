// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary> 
/// The available 2D barcode font providers.
/// </summary>
enum 9207 "Barcode Image Provider 2D" implements "Barcode Image Provider 2D"
{
    Access = Public;
    Extensible = true;

    /// <summary>
    /// Dynamics QR Code Provider.
    /// </summary>
    value(0; Dynamics2D)
    {
        Caption = 'Dynamics QR Code Provider';
        Implementation = "Barcode Image Provider 2D" = "Dynamics 2D Provider";
    }
}
