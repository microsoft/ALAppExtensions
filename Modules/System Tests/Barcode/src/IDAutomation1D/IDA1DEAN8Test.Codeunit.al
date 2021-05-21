// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135047 "IDA 1D EAN8 Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        InvalidInputErr: Label 'Input text %1 contains invalid characters for the chosen provider IDAutomation 1D Barcode Provider and encoding symbology EAN-8', Comment = '%1 = input text';

    [Test]
    procedure TestEAN8Encoding()
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Encoding a text using EAN-8 symbology yields the correct result

        GenericIDAutomation1DTest.EncodeFontSuccessTest(/* input */'1234567', Enum::"Barcode Symbology"::"EAN-8", /* expected result */'(1234*PQRK(');
    end;

    [Test]
    procedure TestEAN8ValidationWithEmptyString()
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Validating an empty text using EAN-8 symbology yeilds an error

        GenericIDAutomation1DTest.ValidateFontFailureTest(/* input */'', Enum::"Barcode Symbology"::"EAN-8", /* expected error */StrSubstNo(InvalidInputErr, ''));
    end;

    [Test]
    procedure TestEAN8ValidationWithNormalString()
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Validating a correctly formatted text using EAN-8 doesn't yield an error

        GenericIDAutomation1DTest.ValidateFontSuccessTest(/* input */'2345678', Enum::"Barcode Symbology"::"EAN-8");
    end;

    [Test]
    procedure TestEAN8ValidationWithInvalidString()
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Validating an incorrectly formatted text using EAN-8 yields an error

        GenericIDAutomation1DTest.ValidateFontFailureTest(/* input */'&&&&&&&', Enum::"Barcode Symbology"::"EAN-8", /* expected error */StrSubstNo(InvalidInputErr, '&&&&&&&'));
    end;

    [Test]
    procedure TestEAN8ValidationWithInvalidStringLength();
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Validating a text with wrong length using EAN-8 symbology yields an error

        GenericIDAutomation1DTest.ValidateFontFailureTest(/* input */'12345678901', Enum::"Barcode Symbology"::"EAN-8", /* expected error */StrSubstNo(InvalidInputErr, '12345678901'));
    end;
}
