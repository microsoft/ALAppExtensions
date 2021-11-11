// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary> 
/// Interface for 2D barcode font providers.
/// </summary>
interface "Barcode Font Provider 2D"
{
    /// <summary>
    /// Gets a list of the 2D barcode symbologies that the provider supports.
    /// </summary>
    /// <param name="Result">A list of barcode symbologies.</param>
    procedure GetSupportedBarcodeSymbologies(var Result: List of [Enum "Barcode Symbology 2D"])

    /// <summary>
    /// Encodes an input text into a 2D barcode. 
    /// </summary>
    /// <param name="InputText">The text to encode.</param>
    /// <param name="BarcodeSymbology2D">The 2D symbology to use for the encoding.</param>
    /// <returns>The encoded barcode.</returns>
    procedure EncodeFont(InputText: Text; BarcodeSymbology2D: Enum "Barcode Symbology 2D"): Text;

}