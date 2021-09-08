// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135048 "IDA 1D I2of5 Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        InvalidInputErr: Label 'Input text %1 contains invalid characters for the chosen provider IDAutomation 1D Barcode Provider and encoding symbology Interleaved 2 of 5', Comment = '%1 = input text';

    [Test]
    procedure TestInterleaved2of5Encoding()
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Encoding a text using Interleaved 2 of 5 symbology yields the correct result

        GenericIDAutomation1DTest.EncodeFontSuccessTest(/* input */'123456', Enum::"Barcode Symbology"::Interleaved2of5, /* expected result */'Ë-CYÌ');
    end;

    [Test]
    procedure TestInterleaved2of5ValidationWithEmptyString()
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Validating an empty text using Interleaved 2 of 5  symbology yeilds an error

        GenericIDAutomation1DTest.ValidateFontFailureTest(/* input */'', Enum::"Barcode Symbology"::Interleaved2of5, /* expected error */StrSubstNo(InvalidInputErr, ''));
    end;

    [Test]
    procedure TestInterleaved2of5ValidationWithNormalString()
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Validating a correctly formatted text using Interleaved 2 of 5  symbology doesn't yield an error

        GenericIDAutomation1DTest.ValidateFontSuccessTest(/* input */'123456', Enum::"Barcode Symbology"::Interleaved2of5);
    end;

    [Test]
    procedure TestInterleaved2of5ValidationWithInvalidString()
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Validating an incorrectly formatted text using Interleaved 2 of 5  symbology yields an error

        GenericIDAutomation1DTest.ValidateFontFailureTest(/* input */'abcd', Enum::"Barcode Symbology"::Interleaved2of5, /* expected error */StrSubstNo(InvalidInputErr, 'abcd'));
    end;

    [Test]
    procedure TestInterleaved2of5ValidationWithInvalidStringLength();
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Validating a text with wrong length using Interleaved 2 of 5 symbology yields an error

        GenericIDAutomation1DTest.ValidateFontFailureTest(/* input */'12345', Enum::"Barcode Symbology"::Interleaved2of5, /* expected error */StrSubstNo(InvalidInputErr, '12345'));
    end;
}
