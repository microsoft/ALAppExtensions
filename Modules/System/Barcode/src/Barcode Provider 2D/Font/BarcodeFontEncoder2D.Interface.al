// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary> 
/// Exposes common interface for 2D barcode font encoder.
/// </summary>
interface "Barcode Font Encoder 2D"
{
    /// <summary> 
    /// Encodes a input text to a barcode font.
    /// </summary>
    /// <param name="InputText">The text to encode.</param>
    /// <returns>The encoded barcode.</returns>
    procedure EncodeFont(InputText: Text): Text;
}