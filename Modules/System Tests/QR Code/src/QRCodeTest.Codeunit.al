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
}
