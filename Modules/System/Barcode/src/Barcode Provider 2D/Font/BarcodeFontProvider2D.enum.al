// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary> 
/// The available 2D barcode font providers.
/// </summary>
enum 9206 "Barcode Font Provider 2D" implements "Barcode Font Provider 2D"
{
    Access = Public;
    Extensible = true;

    /// <summary>
    /// IDAutomation 2D-barcode provider.
    /// </summary>
    value(0; IDAutomation2D)
    {
        Caption = 'IDAutomation 2D Barcode Provider';
        Implementation = "Barcode Font Provider 2D" = "IDAutomation 2D Provider";
    }
}
