// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary> 
/// Interface IBarcodeEncoder to select the correct barcode symbol
/// </summary>
interface IBarcodeEncoder
{
    /// <summary> 
    /// Interface to a specific Barcode Symbol Encoding to generate a barcode for use in a Barcode Font
    /// </summary>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary containing the specific Barcode options .</param>
    /// <returns>Return variable "EncodedText" of type Text.</returns>
    procedure FontEncoder(var TempBarcodeParameters: Record BarcodeParameters temporary) EncodedText: Text;

    /// <summary> 
    /// Interface to a specific Barcode Formatting Handler for the inputstring when generating a barcode as a Base64 Image
    /// </summary>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary which sets the neccessary parameters for the requested barcode.</param>
    /// <returns>Return variable "Base64Image" of type Text.</returns>
    procedure Base64ImageEncoder(var TempBarcodeParameters: Record BarcodeParameters temporary) Base64Image: Text;

    /// <summary> 
    /// Interface to a specific Barcode Validation Handler when generating a barcode.
    /// The validation is based at a regular expression accoring to
    /// https://www.neodynamic.com/Products/Help/BarcodeWinControl2.5/working_barcode_symbologies.htm
    /// </summary>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary which sets the neccessary parameters for the requested barcode.</param>
    /// <returns>Return variable "InputStringOK" of type Boolean.</returns>
    procedure ValidateInputString(var TempBarcodeParameters: Record BarcodeParameters temporary) InputStringOK: Boolean;

    /// <summary> 
    /// Shows if this encoder is implemented as a Barcode Font Encoder
    /// </summary>
    /// <returns>Return variable "Boolean".</returns>
    procedure IsFontEncoder(): Boolean;

    /// <summary> 
    /// Shows if this encoder is implemeted as a Barcode Image in Base64 format
    /// </summary>
    /// <returns>Return variable "Boolean".</returns>
    procedure IsBase64ImageEncoder(): Boolean;
}