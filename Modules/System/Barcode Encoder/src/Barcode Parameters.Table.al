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
        field(100; ReverseColors; Boolean)
        {
            Caption = 'Reverse Colors';
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
    /// Validates if the Input String is a valid string to encode the barcode.
    /// </summary>
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

    procedure FormatBarcode() Base64Data: Text
    var
        iBarcodeProvider: Interface IBarcodeProvider;
    begin
        // Find correct Provider
        iBarcodeProvider := Provider;

        // Write Barcode Data 
        Base64Data := iBarcodeProvider.Barcode(Rec);
    end;
}

