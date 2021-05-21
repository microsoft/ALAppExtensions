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
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Encoding a text using Codabar symbology yields the correct result

        GenericIDAutomation1DTest.EncodeFontSuccessTest(/* input */'1234', Enum::"Barcode Symbology"::Codabar, /* expected result */'A1234B');
    end;

    [Test]
    procedure TestCodabarEncodingWithStartStopSymbols();
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Encoding a text that contains start/stop symbols using Codabar symbology yields the correct result

        GenericIDAutomation1DTest.EncodeFontSuccessTest(/* input */'A1234B', Enum::"Barcode Symbology"::Codabar, /* expected result */'A1234B');
    end;

    [Test]
    procedure TestCodabarValidationWithEmptyString()
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Validating an empty text using Codabar symbology yeilds an error

        GenericIDAutomation1DTest.ValidateFontFailureTest(/* input */'', Enum::"Barcode Symbology"::Codabar, /* expected error */'Input text  contains invalid characters for the chosen provider IDAutomation 1D Barcode Provider and encoding symbology Codabar');
    end;

    [Test]
    procedure TestCodabarValidationWithNormalString();
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Validating a correctly formatted text using Codabar symbology doesn't yield an error

        GenericIDAutomation1DTest.ValidateFontSuccessTest(/* input */'1234', Enum::"Barcode Symbology"::Codabar);
    end;

    [Test]
    procedure TestCodabarValidationWithStartStopString();
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Validating a correctly formatted text that contains start/stop symbols using Codabar symbology doesn't yield an error

        GenericIDAutomation1DTest.ValidateFontSuccessTest(/* input */'A1234B', Enum::"Barcode Symbology"::Codabar)
    end;

    [Test]
    procedure TestCodabarValidationWithInvalidString();
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Validating an invalid text using Codabar symbology yields an error

        GenericIDAutomation1DTest.ValidateFontFailureTest(/* input */'XXXXXXXX', Enum::"Barcode Symbology"::Codabar, /* expected error */'Input text XXXXXXXX contains invalid characters for the chosen provider IDAutomation 1D Barcode Provider and encoding symbology Codabar');
    end;
}
