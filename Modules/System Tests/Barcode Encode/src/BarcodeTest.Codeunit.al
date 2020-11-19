// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135042 "Barcode Test"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Assert: Codeunit "Library Assert";
        ExampleTxt: Label 'Lorem ipsum dolor sit amet', Locked = true;

    [Test]
    procedure CodebarTest()
    var
        TempBarcodeParameter: record BarcodeParameters temporary;
        EncodedText: Text;
    begin
        // [SCENARIO] The barcode encoder can be used from within the application code

        // [GIVEN] The font encoder is initialized
        TempBarcodeParameter.Init();
        TempBarcodeParameter.Provider := TempBarcodeParameter.Provider::default;
        TempBarcodeParameter.Symbology := TempBarcodeParameter.Symbology::code39;
        TempBarcodeParameter."Allow Extended Charset" := true;
        TempBarcodeParameter."Enable Checksum" := false;  // Checksum should work with the latest Dotnet Lib from IDAutomation!!

        // To create a barcode that scans in 1234 and then a return function, *1234$M* would need to be entered as the data to encode. 
        // These may also be combined. For example: *12$I34$M* prints a barcode that scans 12, a tab, then 34 and a return. 
        // Refer to the Code 39 Full ASCII Chart for other codes. 
        // For the extended characters to scan properly, the scanner must be enabled to read Extended Code 39. 
        TempBarcodeParameter."Input String" := '1234';

        // [WHEN] The Code-39 Extended barcode type is used to encode the provided text
        If TempBarcodeParameter.IsFontEncoder() then
            EncodedText := TempBarcodeParameter.EncodeBarcodeFont();

        // [THEN] The encoded text has the correct value
        Assert.AreEqual('*1234$M*', EncodedText, 'Expected the result to have the correct value.');
    end;
}
