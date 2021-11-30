// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139915 "QR Code Test"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Assert: Codeunit "Library Assert";
        QRCode: Codeunit "QR Code";
        SampleTxt: Label 'Hello, World!', Locked = true;
        MaxCapacityLengthTxt: Label 'AaBbCcDdEe', Locked = true;
        MaxCapacityLengthExceededTxt: Label 'AaBbCcDdEeFf', Locked = true;
        ConvertionToQrCodeErr: Label 'An error occured during the conversion.';

    [Test]
    procedure StringToQRCodeTest()
    var
        TempBlob: Codeunit "Temp Blob";
        ConvertionResult: Boolean;
    begin
        // [SCENARIO] A string variable is converted to qr code

        // [WHEN] The string is converted
        ConvertionResult := QRCode.GenerateQRCodeImage(SampleTxt, TempBlob);

        // [THEN] The result is correct
        Assert.AreEqual(ConvertionResult, true, ConvertionToQrCodeErr);
    end;

    [Test]
    procedure MaxCapacityStringToQRCodeTest()
    var
        TempBlob: Codeunit "Temp Blob";
        ConvertionResult: Boolean;
    begin
        // [SCENARIO] A 10 character string is converted to an Version 1 QR code with High Error Correction Level (Max Capacity 10 Alphanumeric characters)

        // [WHEN] The string is converted
        ConvertionResult := QRCode.GenerateQRCodeImage(MaxCapacityLengthTxt, TempBlob, Enum::"QR Code Error Correction Level"::High, 1);

        // [THEN] The result is correct
        Assert.AreEqual(ConvertionResult, true, ConvertionToQrCodeErr);
    end;

    [Test]
    procedure MaxCapacityExceededStringToQRCodeTest()
    var
        TempBlob: Codeunit "Temp Blob";
        ConvertionResult: Boolean;
    begin
        // [SCENARIO] A 12 character string is converted to an Version 1 QR code with High Error Correction Level (Max Capacity 10 Alphanumeric characters)

        // [WHEN] The string is converted
        QRCode.GenerateQRCodeImage(MaxCapacityLengthExceededTxt, TempBlob, Enum::"QR Code Error Correction Level"::High, 1);

        // [THEN] The qr code is not generated
        Assert.AreEqual(ConvertionResult, false, ConvertionToQrCodeErr);
    end;
}
