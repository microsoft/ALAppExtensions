// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135040 "IDA 1D Postnet Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        InvalidInputErr: Label 'Input text %1 contains invalid characters for the chosen provider IDAutomation 1D Barcode Provider and encoding symbology Postnet', Comment = '%1 = input text';

    [Test]
    procedure TestPostnetEncoding()
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] ncoding a text using Postnet symbology yields the correct result

        GenericIDAutomation1DTest.EncodeFontSuccessTest(/* input */'123456', Enum::"Barcode Symbology"::Postnet, /* expected result */'(1234569)');
    end;

    [Test]
    procedure TestPostnetValidationWithEmptyString()
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Validating an empty text using Postnet symbology yeilds an error

        GenericIDAutomation1DTest.ValidateFontFailureTest(/* input */'', Enum::"Barcode Symbology"::Postnet, /* expected error */StrSubstNo(InvalidInputErr, ''));
    end;

    [Test]
    procedure TestPostnetValidationWithNormalString()
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Validating a correctly formatted text using Postnet symbology doesn't yield an error

        GenericIDAutomation1DTest.ValidateFontSuccessTest(/* input */'123456', Enum::"Barcode Symbology"::Postnet);
    end;

    [Test]
    procedure TestPostnetValidationWithInvalidString()
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Validating an incorrectly formatted text using Postnet symbology yields an error

        GenericIDAutomation1DTest.ValidateFontFailureTest(/* input */'abcd', Enum::"Barcode Symbology"::Postnet, /* expected error */StrSubstNo(InvalidInputErr, 'abcd'));
    end;

    [Test]
    procedure TestPostnetValidationWithInvalidStringLength();
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Validating a text with wrong length using Postnet symbology yields an error

        GenericIDAutomation1DTest.ValidateFontFailureTest(/* input */'1234567', Enum::"Barcode Symbology"::Postnet, /* expected error */StrSubstNo(InvalidInputErr, '1234567'));
    end;
}
