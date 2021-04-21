// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135045 "IDA 1D Code93 Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure TestCode93Encoding();
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Encoding a text using Code93 symbology yields the correct result

        GenericIDAutomation1DTest.EncodeFontSuccessTest(/* input */'1234', Enum::"Barcode Symbology"::Code93, /* expected result */'(1234K3)');
    end;

    [Test]
    procedure TestCode93ValidationWithEmptyString();
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Validating an empty text using Code93 symbology yeilds an error

        GenericIDAutomation1DTest.ValidateFontFailureTest(/* input */'', Enum::"Barcode Symbology"::Code93, /* expected error */'Input text  contains invalid characters for the chosen provider IDAutomation 1D Barcode Provider and encoding symbology Code-93');
    end;

    [Test]
    procedure TestCode93ValidationWithNormalString();
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Validating a correctly formatted text using Code93 symbology doesn't yield an error

        GenericIDAutomation1DTest.ValidateFontSuccessTest(/* input */'1234', Enum::"Barcode Symbology"::Code93);
    end;

    [Test]
    procedure TestCode93ValidationWithNormalStringExtCharSet();
    var
        BarcodeEncodeSettings: Record "Barcode Encode Settings";
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Validating a correctly formatted text using Code93 symbology with "Allow Extended Charset"  doesn't yield an error

        BarcodeEncodeSettings."Allow Extended Charset" := true;

        GenericIDAutomation1DTest.ValidateFontSuccessTest(/* input */'1234abcd', Enum::"Barcode Symbology"::Code93, BarcodeEncodeSettings);
    end;

    [Test]
    procedure TestCode93ValidationWithInvalidString();
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Validating an invalid text using Codabar symbology yields an error

        GenericIDAutomation1DTest.ValidateFontFailureTest(/* input */'&&&&&&&', Enum::"Barcode Symbology"::Code93, /* expected error */'Input text &&&&&&& contains invalid characters for the chosen provider IDAutomation 1D Barcode Provider and encoding symbology Code-93');
    end;
}
