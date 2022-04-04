// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary> 
/// Interface for 2D barcode image providers.
/// </summary>
interface "Barcode Image Provider 2D"
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
    procedure EncodeImage(InputText: Text; BarcodeSymbology2D: Enum "Barcode Symbology 2D"): Codeunit "Temp Blob";

    /// <summary>
    /// Encodes an input text into a 2D barcode. 
    /// </summary>
    /// <param name="InputText">The text to encode.</param>
    /// <param name="BarcodeSymbology2D">The 2D symbology to use for the encoding.</param>
    /// <param name="BarcodeEncodeSettings2D">The settings to use when encoding the text.</param>
    /// <returns>The encoded barcode.</returns>
    procedure EncodeImage(InputText: Text; BarcodeSymbology2D: Enum "Barcode Symbology 2D"; BarcodeEncodeSettings2D: Record "Barcode Encode Settings 2D"): Codeunit "Temp Blob";
}