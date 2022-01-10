// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135061 "Dynamics 2D QR Code Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        Any: Codeunit Any;
        SampleTxt: Label 'Hello, World!', Locked = true;

    [Test]
    procedure StringToQRCodeTest()
    var
        TempBlob: Codeunit "Temp Blob";
        BarcodeImageProvider2D: Enum "Barcode Image Provider 2D";
        IBarcodeImageProvider2D: Interface "Barcode Image Provider 2D";
    begin
        // [SCENARIO] A string variable is converted to qr code
        IBarcodeImageProvider2D := BarcodeImageProvider2D::Dynamics2D;

        // [WHEN] The string is converted
        TempBlob := IBarcodeImageProvider2D.EncodeImage(SampleTxt, Enum::"Barcode Symbology 2D"::"QR-Code");

        // [THEN] TempBlob contains data
        Assert.IsTrue(TempBlob.HasValue(), 'No QR Code image created.');
    end;

    [Test]
    procedure MaxCapacityStringToQRCodeTest()
    var
        BarcodeEncodeSettings2D: Record "Barcode Encode Settings 2D";
        TempBlob: Codeunit "Temp Blob";
        IBarcodeImageProvider2D: Interface "Barcode Image Provider 2D";
        BarcodeImageProvider2D: Enum "Barcode Image Provider 2D";
    begin
        // [SCENARIO] A 1273 byte string is converted to an Version 40 QR code with High Error Correction Level (Max Capacity 1273 bytes)
        IBarcodeImageProvider2D := BarcodeImageProvider2D::Dynamics2D;
        BarcodeEncodeSettings2D.Init();
        BarcodeEncodeSettings2D."Error Correction Level" := BarcodeEncodeSettings2D."Error Correction Level"::High;
        BarcodeEncodeSettings2D."Module Size" := 1;

        // [WHEN] The string is converted
        TempBlob := IBarcodeImageProvider2D.EncodeImage(GetMaxAlphaNumericString(false), Enum::"Barcode Symbology 2D"::"QR-Code", BarcodeEncodeSettings2D);

        // [THEN] no error occured
        Assert.IsTrue(TempBlob.HasValue(), 'No QR Code image created.');
    end;

    [Test]
    procedure MaxCapacityExceededStringToQRCodeTest()
    var
        BarcodeEncodeSettings2D: Record "Barcode Encode Settings 2D";
        IBarcodeImageProvider2D: Interface "Barcode Image Provider 2D";
        BarcodeImageProvider2D: Enum "Barcode Image Provider 2D";
    begin
        // [SCENARIO] A 1274 byte string is converted to an Version 40 QR code with High Error Correction Level (Max Capacity 1273 bytes)
        ClearLastError();

        IBarcodeImageProvider2D := BarcodeImageProvider2D::Dynamics2D;
        BarcodeEncodeSettings2D.Init();
        BarcodeEncodeSettings2D."Error Correction Level" := BarcodeEncodeSettings2D."Error Correction Level"::High;
        BarcodeEncodeSettings2D."Module Size" := 1;

        // [WHEN] The string is converted
        asserterror IBarcodeImageProvider2D.EncodeImage(GetMaxAlphaNumericString(true), Enum::"Barcode Symbology 2D"::"QR-Code", BarcodeEncodeSettings2D);

        // [THEN] 'Cannot accommodate input length.' error expected
        Assert.ExpectedError('Cannot accommodate input length.');
    end;

    local procedure GetMaxAlphaNumericString(PlusOne: Boolean): Text
    begin
        if PlusOne then
            exit(Any.AlphanumericText(1274));

        exit(Any.AlphanumericText(1273));
    end;
}