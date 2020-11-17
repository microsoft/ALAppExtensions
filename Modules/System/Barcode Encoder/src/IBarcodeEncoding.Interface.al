// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary> 
/// Interface IBarcodeSymbolIdentifier to select the correct barcode symbol
/// </summary>
interface IBarcodeEncoder
{
    /// <summary> 
    /// Interface to a specific Barcode Symbol Encoding to generate a barcode
    /// </summary>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary containing the specific Barcode options .</param>
    procedure FontEncoder(var TempBarcodeParameters: Record BarcodeParameters temporary) EncodedText: Text;

    /// <summary> 
    /// Interface to a specific Barcode Validation Handler when generating a barcode.
    /// The validation is based at a regular expression accoring to
    /// https://www.neodynamic.com/Products/Help/BarcodeWinControl2.5/working_barcode_symbologies.htm
    /// </summary>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary which sets the neccessary parameters for the requested barcode.</param>
    procedure ValidateInputString(var TempBarcodeParameters: Record BarcodeParameters temporary) ValidationResult: Boolean;

    /// <summary> 
    /// Interface to a specific Barcode Formatting Handler for the inputstring when generating a barcode
    /// </summary>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary which sets the neccessary parameters for the requested barcode.</param>
    procedure Barcode(var TempBarcodeParameters: Record BarcodeParameters temporary) Base64Data: Text;
}