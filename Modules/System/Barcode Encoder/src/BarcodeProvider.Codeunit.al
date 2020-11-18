// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 9201 BarcodeProvider implements IBarcodeProvider
{
    Access = Public;

    /// <summary> 
    /// Gets the Barcode Encoding Handler based at the Barcode Symbology
    /// </summary>
    /// <seealso cref="OnFindBarcodeEncoderSymbology"/>
    ///  <param name="iBarcodeEncoder">Parameter of type interface IBarcodeEncoder.</param>
    /// <param name="UseSymbology">Parameter of type Enum BarcodeSymbology.</param>
    procedure GetEncoder(var iBarcodeEncoder: interface IBarcodeEncoder; UseSymbology: Enum BarcodeSymbology)
    begin
        if TryGetBarcodeEncoder(iBarcodeEncoder, UseSymbology) then
            OnFindBarcodeEncoderSymbology(iBarcodeEncoder, UseSymbology)
        else
            Error(GetLastErrorText);
    end;

    /// <summary> 
    /// Encodes the barcode string to print a barcode using the providers barcode font encoder.
    /// </summary>
    /// <seealso cref="OnFindBarcodeEncoderParameters"/>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary.</param>
    procedure FontEncoder(var TempBarcodeParameters: Record BarcodeParameters temporary) EncodedText: text
    var
        iBarcodeEncoder: interface IBarcodeEncoder;
    begin
        // First Find correct Barcode Encoder based at Symbolgy set in Record
        if TryGetBarcodeEncoder(iBarcodeEncoder, TempBarcodeParameters.Symbology) then
            OnFindBarcodeEncoderParameters(iBarcodeEncoder, TempBarcodeParameters)
        else
            Error(GetLastErrorText);
        // Execute correct Barcode Encoder
        EncodedText := iBarcodeEncoder.FontEncoder(TempBarcodeParameters);
    end;

    /// <summary> 
    /// Encodes the barcode string to print a barcode using the providers barcode as a Base64 Image
    /// </summary> 
    /// <seealso cref="OnFindBarcodeEncoderParameters"/>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary.</param>
    /// <returns>Return variable "Base64Image" of type Text.</returns>
    procedure Base64ImageEncoder(var TempBarcodeParameters: Record BarcodeParameters temporary) Base64Image: Text;
    var
        iBarcodeEncoder: interface IBarcodeEncoder;
    begin
        // First Find correct Barcode Encoder based at Symbolgy set in Record
        if TryGetBarcodeEncoder(iBarcodeEncoder, TempBarcodeParameters.Symbology) then
            OnFindBarcodeEncoderParameters(iBarcodeEncoder, TempBarcodeParameters)
        else
            Error(GetLastErrorText);
        // Execute correct Barcode Encoder
        Base64Image := iBarcodeEncoder.Base64ImageEncoder(TempBarcodeParameters);
    end;

    /// <summary> 
    /// Validates if the Input String is a valid string to encode the barcode as defined in the parameter table.
    /// </summary>
    /// <seealso cref="OnFindBarcodeEncoderParameters"/>
    /// <param name="TempBarcodeParameters">Parameter of type Record BarcodeParameters temporary.</param>
    /// <returns>Return variable "InputStringOK" of type Boolean.</returns>
    procedure ValidateInputString(var TempBarcodeParameters: Record BarcodeParameters temporary) InputStringOK: Boolean;
    var
        iBarcodeEncoder: interface IBarcodeEncoder;
    begin
        // First Find correct Barcode Encoder based at Symbolgy set in Record
        if TryGetBarcodeEncoder(iBarcodeEncoder, TempBarcodeParameters.Symbology) then
            OnFindBarcodeEncoderParameters(iBarcodeEncoder, TempBarcodeParameters)
        else
            Error(GetLastErrorText);
        // Execute correct Barcode Encoder
        InputStringOK := iBarcodeEncoder.ValidateInputString(TempBarcodeParameters);
    end;

    /// <summary> 
    /// Description for GetListofImplementedEncoders.
    ///  Returns a list of implemented font encoders
    /// </summary>
    /// <param name="ListOfEncoders">Parameter of type list of [Text].</param>
    procedure GetListofImplementedEncoders(var ListOfEncoders: list of [Text])
    var
        EnumSymbololy: Enum BarcodeSymbology;
    begin
        // Include List of encoders implemented with this provider
        clear(ListOfEncoders);
        ListOfEncoders.add(format(EnumSymbololy::code39));
        ListOfEncoders.add(format(EnumSymbololy::codabar));
        ListOfEncoders.add(format(EnumSymbololy::code128));
        ListOfEncoders.add(format(EnumSymbololy::code93));
        ListOfEncoders.add(format(EnumSymbololy::interleaved2of5));
        ListOfEncoders.add(format(EnumSymbololy::postnet));
        ListOfEncoders.add(format(EnumSymbololy::MSI));
        ListOfEncoders.add(format(EnumSymbololy::ean8));
        ListOfEncoders.add(format(EnumSymbololy::ean13));
        ListOfEncoders.add(format(EnumSymbololy::"upc-a"));
        ListOfEncoders.add(format(EnumSymbololy::"upc-e"));
    end;

    [TryFunction]
    /// <summary> 
    /// tries to find the correctEncoder for the current symbology
    /// </summary>
    /// <param name="iBarcodeEncoder">Parameter of type interface IBarcodeEncoder.</param>
    /// <param name="UseSymbology">Parameter of type Enum BarcodeSymbology.</param>
    local procedure TryGetBarcodeEncoder(var iBarcodeEncoder: interface IBarcodeEncoder; UseSymbology: Enum BarcodeSymbology)
    var
        Providers: Enum BarcodeProviders;
        ListOfEncoders: list of [Text];
        CannotFindBarcodeEncoderErr: label 'Provider %1: Barcode Symbol Encoder %2 is implemented by this provider!';
    begin
        // Find which standard encoding handler to use
        GetListofImplementedEncoders(ListOfEncoders);
        if ListOfEncoders.Contains(Format(UseSymbology)) then
            iBarcodeEncoder := UseSymbology
        else
            Error(CannotFindBarcodeEncoderErr, Providers::default, UseSymbology);
    end;

    /// <summary> 
    /// Integration event, emitted from <see cref="GetBarcodeParametersHandler"/>.
    /// Subscribe to this event to change the default behavior by changing the provided parameter(s).
    /// </summary>
    /// <seealso cref="GetEncoder"/>
    /// <param name="iBarcodeEncoder">Parameter of type interface IBarcodeEncoder.</param>
    /// <param name="UseSymbology">Parameter of type Enum BarcodeSymbology.</param>
    [IntegrationEvent(false, false)]
    local procedure OnFindBarcodeEncoderSymbology(var iBarcodeEncoder: interface IBarcodeEncoder; UseSymbology: Enum BarcodeSymbology);
    begin
    end;

    /// <summary> 
    /// Integration event, emitted from <see cref="GetBarcodeParametersHandler"/>.
    /// Subscribe to this event to change the default behavior by changing the provided parameter(s).
    /// </summary>
    /// <seealso cref="FontEncoder"/>
    /// <seealso cref="Base64Encoder"/>  
    /// <seealso cref="ValidateInputString"/>   
    /// <param name="iBarcodeEncoder">Parameter of type interface IBarcodeEncoder.</param>
    /// <param name="TempBarcodeParameters">Parameter of type record BarcodeParameters temporary.</param>
    [IntegrationEvent(false, false)]
    local procedure OnFindBarcodeEncoderParameters(var iBarcodeEncoder: interface IBarcodeEncoder; var TempBarcodeParameters: record BarcodeParameters temporary);
    begin
    end;
}