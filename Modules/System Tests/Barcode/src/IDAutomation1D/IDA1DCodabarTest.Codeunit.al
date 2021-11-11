// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135042 "IDA 1D Codabar Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure TestCodabarEncoding();
    var
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Encoding a text using Codabar symbology yields the correct result

        GenericBarcodeTestHelper.EncodeFontSuccessTest(/* input */'1234', Enum::"Barcode Symbology"::Codabar, /* expected result */'A1234B');
    end;

    [Test]
    procedure TestCodabarEncodingWithStartStopSymbols();
    var
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Encoding a text that contains start/stop symbols using Codabar symbology yields the correct result

        GenericBarcodeTestHelper.EncodeFontSuccessTest(/* input */'A1234B', Enum::"Barcode Symbology"::Codabar, /* expected result */'A1234B');
    end;

    [Test]
    procedure TestCodabarValidationWithEmptyString()
    var
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Validating an empty text using Codabar symbology yeilds an error

        GenericBarcodeTestHelper.ValidateFontFailureTest(/* input */'', Enum::"Barcode Symbology"::Codabar, /* expected error */'Input text  contains invalid characters for the chosen provider IDAutomation 1D Barcode Provider and encoding symbology Codabar');
    end;

    [Test]
    procedure TestCodabarValidationWithNormalString();
    var
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Validating a correctly formatted text using Codabar symbology doesn't yield an error

        GenericBarcodeTestHelper.ValidateFontSuccessTest(/* input */'1234', Enum::"Barcode Symbology"::Codabar);
    end;

    [Test]
    procedure TestCodabarValidationWithStartStopString();
    var
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Validating a correctly formatted text that contains start/stop symbols using Codabar symbology doesn't yield an error

        GenericBarcodeTestHelper.ValidateFontSuccessTest(/* input */'A1234B', Enum::"Barcode Symbology"::Codabar)
    end;

    [Test]
    procedure TestCodabarValidationWithInvalidString();
    var
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Validating an invalid text using Codabar symbology yields an error

        GenericBarcodeTestHelper.ValidateFontFailureTest(/* input */'XXXXXXXX', Enum::"Barcode Symbology"::Codabar, /* expected error */'Input text XXXXXXXX contains invalid characters for the chosen provider IDAutomation 1D Barcode Provider and encoding symbology Codabar');
    end;
}
