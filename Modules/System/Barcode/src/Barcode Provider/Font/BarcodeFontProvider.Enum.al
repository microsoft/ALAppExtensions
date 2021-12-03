// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary> 
/// The available barcode font providers.
/// </summary>
enum 9203 "Barcode Font Provider" implements "Barcode Font Provider"
{
    Access = Public;
    Extensible = true;

    /// <summary>
    /// IDAutomation 1D-barcode provider.
    /// </summary>
    value(0; IDAutomation1D)
    {
        Caption = 'IDAutomation 1D Barcode Provider';
        Implementation = "Barcode Font Provider" = "IDAutomation 1D Provider";
    }
}
