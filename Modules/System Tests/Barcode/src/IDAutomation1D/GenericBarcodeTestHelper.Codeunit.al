// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135055 "Generic Barcode Test Helper"
{
    Subtype = Test;
    Access = Internal;

    var
        LibraryAssert: Codeunit "Library Assert";

    procedure EncodeFontSuccessTest(TextToEncode: Text; BarcodeSymbology: Enum "Barcode Symbology"; ExpectedResult: Text)
    var
        BarcodeFontProvider: Interface "Barcode Font Provider";
        EncodedText: Text;
    begin
        BarcodeFontProvider := Enum::"Barcode Font Provider"::IDAutomation1D;

        EncodedText := BarcodeFontProvider.EncodeFont(TextToEncode, BarcodeSymbology);

        LibraryAssert.AreEqual(ExpectedResult, EncodedText, 'The encoded text is incorrect');
    end;

    procedure EncodeFontSuccessTest(TextToEncode: Text; BarcodeSymbology: Enum "Barcode Symbology"; BarcodeEncodeSettings: Record "Barcode Encode Settings"; ExpectedResult: Text)
    var
        BarcodeFontProvider: Interface "Barcode Font Provider";
        EncodedText: Text;
    begin
        BarcodeFontProvider := Enum::"Barcode Font Provider"::IDAutomation1D;

        EncodedText := BarcodeFontProvider.EncodeFont(TextToEncode, BarcodeSymbology, BarcodeEncodeSettings);

        LibraryAssert.AreEqual(ExpectedResult, EncodedText, 'The encoded text is incorrect');
    end;

    procedure EncodeFontFailureTest(TextToEncode: Text; BarcodeSymbology: Enum "Barcode Symbology"; ExpectedError: Text)
    var
        BarcodeFontProvider: Interface "Barcode Font Provider";
    begin
        BarcodeFontProvider := Enum::"Barcode Font Provider"::IDAutomation1D;

        asserterror BarcodeFontProvider.EncodeFont(TextToEncode, BarcodeSymbology);

        LibraryAssert.ExpectedError(ExpectedError);
    end;

    procedure ValidateFontSuccessTest(TextToValidate: Text; BarcodeSymbology: Enum "Barcode Symbology")
    var
        BarcodeFontProvider: Interface "Barcode Font Provider";
    begin
        BarcodeFontProvider := Enum::"Barcode Font Provider"::IDAutomation1D;

        ClearLastError();
        BarcodeFontProvider.ValidateInput(TextToValidate, BarcodeSymbology);

        LibraryAssert.AreEqual('', GetLastErrorText(), 'The validation should succeed.');
    end;

    procedure ValidateFontSuccessTest(TextToValidate: Text; BarcodeSymbology: Enum "Barcode Symbology"; BarcodeEncodeSettings: Record "Barcode Encode Settings")
    var
        BarcodeFontProvider: Interface "Barcode Font Provider";
    begin
        BarcodeFontProvider := Enum::"Barcode Font Provider"::IDAutomation1D;

        ClearLastError();
        BarcodeFontProvider.ValidateInput(TextToValidate, BarcodeSymbology, BarcodeEncodeSettings);

        LibraryAssert.AreEqual('', GetLastErrorText(), 'The validation should succeed.');
    end;

    procedure ValidateFontFailureTest(TextToValidate: Text; BarcodeSymbology: Enum "Barcode Symbology"; BarcodeEncodeSettings: Record "Barcode Encode Settings"; ExpectedError: Text)
    var
        BarcodeFontProvider: Interface "Barcode Font Provider";
    begin
        BarcodeFontProvider := Enum::"Barcode Font Provider"::IDAutomation1D;

        asserterror BarcodeFontProvider.ValidateInput(TextToValidate, BarcodeSymbology, BarcodeEncodeSettings);

        LibraryAssert.AreEqual(ExpectedError, GetLastErrorText(), 'The validation throws an incorrent error');
    end;

    procedure ValidateFontFailureTest(TextToValidate: Text; BarcodeSymbology: Enum "Barcode Symbology"; ExpectedError: Text)
    var
        BarcodeFontProvider: Interface "Barcode Font Provider";
    begin
        BarcodeFontProvider := Enum::"Barcode Font Provider"::IDAutomation1D;

        asserterror BarcodeFontProvider.ValidateInput(TextToValidate, BarcodeSymbology);

        LibraryAssert.AreEqual(ExpectedError, GetLastErrorText(), 'The validation throws an incorrect error');
    end;

    procedure Encode2DFontTest(TextToEncode: Text; BarcodeSymbology2D: Enum "Barcode Symbology 2D"; ExpectedResult: Text)
    var
        BarcodeFontProvider2D: Interface "Barcode Font Provider 2D";
        EncodedText: Text;
    begin
        BarcodeFontProvider2D := Enum::"Barcode Font Provider 2D"::IDAutomation2D;

        EncodedText := BarcodeFontProvider2D.EncodeFont(TextToEncode, BarcodeSymbology2D);

        LibraryAssert.AreEqual(ExpectedResult, EncodedText, 'The encoded text is incorrect');
    end;

    procedure Encode2DFontFailureTest(TextToEncode: Text; BarcodeSymbology2D: Enum "Barcode Symbology 2D"; ExpectedError: Text)
    var
        BarcodeFontProvider2D: Interface "Barcode Font Provider 2D";
    begin
        BarcodeFontProvider2D := Enum::"Barcode Font Provider 2D"::IDAutomation2D;

        asserterror BarcodeFontProvider2D.EncodeFont(TextToEncode, BarcodeSymbology2D);

        LibraryAssert.ExpectedError(ExpectedError);
    end;
}