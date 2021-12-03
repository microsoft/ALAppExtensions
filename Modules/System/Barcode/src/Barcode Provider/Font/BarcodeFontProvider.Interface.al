// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary> 
/// Interface for barcode font providers.
/// </summary>
interface "Barcode Font Provider"
{
    /// <summary>
    /// Gets a list of the barcode symbologies that the provider supports.
    /// </summary>
    /// <param name="Result">A list of barcode symbologies.</param>
    procedure GetSupportedBarcodeSymbologies(var Result: List of [Enum "Barcode Symbology"])

    /// <summary>
    /// Encodes an input text into a barcode. 
    /// </summary>
    /// <param name="InputText">The text to encode.</param>
    /// <param name="BarcodeSymbology">The symbology to use for the encoding.</param>
    /// <returns>The encoded barcode.</returns>
    procedure EncodeFont(InputText: Text; BarcodeSymbology: Enum "Barcode Symbology"): Text;

    /// <summary>
    /// Encodes an input text into a barcode. 
    /// </summary>
    /// <param name="InputText">The text to encode.</param>
    /// <param name="BarcodeSymbology">The symbology to use for the encoding.</param>
    /// <param name="BarcodeEncodeSettings">The settings to use when encoding the text.</param>
    /// <returns>The encoded barcode.</returns>
    procedure EncodeFont(InputText: Text; BarcodeSymbology: Enum "Barcode Symbology"; BarcodeEncodeSettings: Record "Barcode Encode Settings"): Text;

    /// <summary>
    /// Validates if the input text is in a valid format to be encoded using the provided barcode symbology.
    /// </summary>
    /// <remarks>The function should throw an error if the input text is in invalid format or if the symbology is not supported by the provider.</remarks>
    /// <param name="InputText">The text to validate</param>
    /// <param name="BarcodeSymbology">The barcode symbology for which to check.</param>
    procedure ValidateInput(InputText: Text; BarcodeSymbology: Enum "Barcode Symbology");

    /// <summary>
    /// Validates if the input text is in a valid format to be encoded using the provided barcode symbology.
    /// </summary>
    /// <remarks>The function should throw an error if the input text is in invalid format or if the symbology is not supported by the provider.</remarks>
    /// <param name="InputText">The text to validate</param>
    /// <param name="BarcodeSymbology">The barcode symbology for which to check.</param>
    /// <param name="BarcodeEncodeSettings">The settings to use for the validation.</param>
    procedure ValidateInput(InputText: Text; BarcodeSymbology: Enum "Barcode Symbology"; BarcodeEncodeSettings: Record "Barcode Encode Settings");
}