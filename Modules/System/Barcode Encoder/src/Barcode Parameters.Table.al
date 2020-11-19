// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
table 9200 BarcodeParameters
{
    TableType = Temporary;
    DataCaptionFields = Provider, Symbology, "Input String";
    DataClassification = CustomerContent;

    fields
    {
        field(1; PrimaryKey; Guid)
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(5; "Input String"; Text[250])
        {
            Caption = 'Input String';
            DataClassification = CustomerContent;
        }
        field(10; Provider; Enum BarcodeProviders)
        {
        }
        field(20; Symbology; Enum BarcodeSymbology)
        {
            Caption = 'use Symbology';
            DataClassification = CustomerContent;
        }
        field(110; OptionParameterString; Text[100])
        {
            Caption = 'Optional Parameters';
            DataClassification = CustomerContent;
        }

        field(120; "Allow Extended Charset"; boolean)
        {
            caption = 'Allow Extended Charset';
            DataClassification = CustomerContent;
        }
        field(130; "Enable Checksum"; boolean)
        {
            caption = 'Enable Checksum';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; PrimaryKey)
        {
            Clustered = false;
        }
    }

    trigger OnInsert();
    begin
        PrimaryKey := CreateGuid;
    end;

    /// <summary> 
    /// Encodes the input string to printable a barcode using the barcode font.
    /// </summary>
    /// <returns>Return variable "EncodedText" of type Text.</returns>
    procedure EncodeBarcodeFont() EncodedText: Text
    var
        iBarcodeProvider: Interface IBarcodeProvider;
    begin
        // Find correct Provider
        iBarcodeProvider := Provider;

        // Generate Barcode Encoded String for Barcode Fonts
        EncodedText := iBarcodeProvider.FontEncoder(Rec);
    end;

    /// <summary> 
    /// Encodes the input string to printable a barcode image as base64 string.
    /// </summary>
    /// <returns>Return variable "Base64Image" of type Text.</returns>
    procedure EncodeBarcodeImage() Base64Image: Text
    var
        iBarcodeProvider: Interface IBarcodeProvider;
    begin
        // Find correct Provider
        iBarcodeProvider := Provider;

        // Write Barcode Data as an Base64 Image
        Base64Image := iBarcodeProvider.Base64ImageEncoder(Rec);
    end;

    /// <summary> 
    /// Validates if the Input String is a valid string to encode the barcode.
    /// </summary>
    /// <returns>Return variable "ValidatedResult" of type Boolean.</returns>
    procedure ValidateInputString() ValidatedResult: Boolean
    var
        iBarcodeProvider: Interface IBarcodeProvider;
        iBarcodeEncoder: Interface IBarcodeEncoder;
        InvalidStringFormatErrMsg: label 'Input String %1 contains invalid characters for the chosen provider %2 and encoding symbolgy %3';
    begin
        // Find correct Provider
        iBarcodeProvider := Provider;

        // Verify Barcode Input String
        if not iBarcodeProvider.ValidateInputString(Rec) then
            error(InvalidStringFormatErrMsg, "Input String", Provider, Symbology);
    end;

    /// <summary> 
    /// Shows if this encoder is implemented as a Barcode Font Encoder
    /// </summary>
    /// <returns>Return variable "Boolean".</returns>
    procedure IsFontEncoder(): Boolean
    var
        iBarcodeProvider: Interface IBarcodeProvider;
        iBarcodeEncoder: Interface IBarcodeEncoder;
        NotImplementedErr: Label 'Base64 Image Encoding is currently not implemented for Provider%1 and Symbology %2', comment = '%1 =  Provider Caption, %2 = Symbology Caption';
    begin
        // Find correct Provider
        iBarcodeProvider := Provider;

        // Get correct Encoder
        if not iBarcodeProvider.IsFontEncoder(iBarcodeEncoder, Rec.Symbology) then
            error(NotImplementedErr, Rec.Provider, Rec.Symbology);

        exit(iBarcodeEncoder.IsFontEncoder());
    end;

    /// <summary> 
    /// Shows if this encoder is implemented as a Base64 Image Barcode
    /// </summary>
    /// <returns>Return variable "Boolean".</returns>
    procedure IsBase64ImageEncoder(): Boolean
    var
        iBarcodeProvider: Interface IBarcodeProvider;
        iBarcodeEncoder: Interface IBarcodeEncoder;
        NotImplementedErr: Label 'Base64 Image Encoding is currently not implemented for Provider%1 and Symbology %2', comment = '%1 =  Provider Caption, %2 = Symbology Caption';
    begin
        // Find correct Provider
        iBarcodeProvider := Provider;

        // Get correct Encoder
        if not iBarcodeProvider.IsFontEncoder(iBarcodeEncoder, Rec.Symbology) then
            error(NotImplementedErr, Rec.Provider, Rec.Symbology);

        exit(iBarcodeEncoder.IsBase64ImageEncoder());
    end;
}

