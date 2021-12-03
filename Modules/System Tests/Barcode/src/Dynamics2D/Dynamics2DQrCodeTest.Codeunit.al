// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135060 "Dynamics QR Code Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        SampleTxt: Label 'Hello, World!', Locked = true;
        MaxCapacityLengthTxt: Label 'AaBbCcDdEe', Locked = true;

    [Test]
    procedure StringToQRCodeTest()
    var
        BarcodeImageProvider2D: Enum "Barcode Image Provider 2D";
        IBarcodeImageProvider2D: Interface "Barcode Image Provider 2D";
    begin
        // [SCENARIO] A string variable is converted to qr code
        IBarcodeImageProvider2D := BarcodeImageProvider2D::Dynamics2D;

        // [WHEN] The string is converted
        // [THEN] no error occured
        IBarcodeImageProvider2D.EncodeImage(SampleTxt, Enum::"Barcode Symbology 2D"::"QR-Code");
    end;


    [Test]
    procedure MaxCapacityStringToQRCodeTest()
    var
        BarcodeEncodeSettings2D: Record "Barcode Encode Settings 2D";
        BarcodeImageProvider2D: Enum "Barcode Image Provider 2D";
        IBarcodeImageProvider2D: Interface "Barcode Image Provider 2D";
    begin
        // [SCENARIO] A 1273 byte string is converted to an Version 40 QR code with High Error Correction Level (Max Capacity 1273 bytes)
        IBarcodeImageProvider2D := BarcodeImageProvider2D::Dynamics2D;
        BarcodeEncodeSettings2D.Init();
        BarcodeEncodeSettings2D."Error Correction Level" := BarcodeEncodeSettings2D."Error Correction Level"::High;
        BarcodeEncodeSettings2D."Module Size" := 1;

        // [WHEN] The string is converted
        // [THEN] no error occured
        IBarcodeImageProvider2D.EncodeImage(GetMaxAlphaNumericString(false), Enum::"Barcode Symbology 2D"::"QR-Code", BarcodeEncodeSettings2D);
    end;

    [Test]
    procedure MaxCapacityExceededStringToQRCodeTest()
    var
        BarcodeEncodeSettings2D: Record "Barcode Encode Settings 2D";
        BarcodeImageProvider2D: Enum "Barcode Image Provider 2D";
        IBarcodeImageProvider2D: Interface "Barcode Image Provider 2D";
    begin
        // [SCENARIO] A 1274 byte string is converted to an Version 40 QR code with High Error Correction Level (Max Capacity 1273 bytes)
        IBarcodeImageProvider2D := BarcodeImageProvider2D::Dynamics2D;
        BarcodeEncodeSettings2D.Init();
        BarcodeEncodeSettings2D."Error Correction Level" := BarcodeEncodeSettings2D."Error Correction Level"::High;
        BarcodeEncodeSettings2D."Module Size" := 1;

        // [WHEN] The string is converted
        // [THEN] error occured
        asserterror IBarcodeImageProvider2D.EncodeImage(GetMaxAlphaNumericString(true), Enum::"Barcode Symbology 2D"::"QR-Code", BarcodeEncodeSettings2D);
    end;

    local procedure GetMaxAlphaNumericString(PlusOne: Boolean) Result: Text
    var
        I: Integer;
    begin
        for i := 1 to 1273 do
            Result += 'A';

        if PlusOne then
            Result += 'A';
    end;
}