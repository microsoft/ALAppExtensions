// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary> 
/// Interface IBarcodeProvider.
/// The interface connects the correct Barcode Encoding Handler of a specific Barcode Provider
/// </summary>
interface IBarcodeProvider
{
    /// <summary> 
    /// Function GetBarcodeEncoder to determine the correct Barcode Encoding handler based at the Enum.
    /// </summary>
    /// <param name="iBarcodeEncoder">Interface object IBarcodeEncoder to connect the requested Encoding Handler.</param>
    /// <param name="UseEncoding">Enum BarcodeEncoder of the reqested Barcode Encoder Handler.</param>
    procedure GetEncoder(var iBarcodeEncoder: interface IBarcodeEncoder; UseSymbology: Enum BarcodeSymbology)

    /// <summary> 
    /// Function Encode encodes the Inputstring and generates a barcode according to the parameters set.
    /// </summary>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters which sets the neccessary parameters for the requested barcode.</param>
    /// <returns>Return variable "EncodedText" of type text.</returns>
    procedure FontEncoder(var TempBarcodeParameters: Record BarcodeParameters temporary) EncodedText: text

    /// <summary> 
    /// function ValidateInputString, which validates the Input string and used Paramaters if they apply the symbolgy standards.
    /// </summary>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters which sets the neccessary parameters for the requested barcode.</param>
    /// <returns>Return variable "InputStringOK" of type Boolean.</returns>
    procedure ValidateInputString(var TempBarcodeParameters: Record BarcodeParameters temporary) InputStringOK: Boolean;

    /// <summary> 
    /// Function Barcode returning the generated Barcode as Base64 data.
    /// </summary>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters which sets the neccessary parameters for the requested barcode.</param>
    /// <returns>Return variable "Base64Image" of type text.</returns>
    procedure Base64ImageEncoder(var TempBarcodeParameters: Record BarcodeParameters temporary) Base64Image: text;

    /// <summary> 
    /// Function GetlistofImplementedEncoders to return a list of the Symbology encoders implemented by this provider
    /// </summary>
    /// <param name="ListOfEncoders">ListOfEncoders of type list of [Text].</param>
    procedure GetListofImplementedEncoders(var ListOfEncoders: list of [Text])
}