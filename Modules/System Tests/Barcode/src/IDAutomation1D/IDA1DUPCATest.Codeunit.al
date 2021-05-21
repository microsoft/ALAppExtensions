// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135053 "IDA 1D UPCA Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        InvalidInputErr: Label 'Input text %1 contains invalid characters for the chosen provider IDAutomation 1D Barcode Provider and encoding symbology UPC-A', Comment = '%1 = input text';

    [Test]
    procedure TestUPCAEncoding();
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Encoding a text using UPC-A symbology yileds the correct result

        GenericIDAutomation1DTest.EncodeFontSuccessTest(/* input */'123456789012', Enum::"Barcode Symbology"::"UPC-A", /* expected result */'V(b23456*RSTKLm(W');
    end;

    [Test]
    procedure TestUPCAValidationWithEmptyString();
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Validating an empty text using UPC-A symbology yeilds an error

        GenericIDAutomation1DTest.ValidateFontFailureTest(/* input */'', Enum::"Barcode Symbology"::"UPC-A", /* expected error */StrSubstNo(InvalidInputErr, ''));
    end;

    [Test]
    procedure TestUPCAValidationWithNormalString();
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Validating a correctly formatted text using UPC-A symbology doesn't yield an error

        GenericIDAutomation1DTest.ValidateFontSuccessTest(/* input */'123456789012', Enum::"Barcode Symbology"::"UPC-A");
    end;

    [Test]
    procedure TestUPCAValidationWithInvalidString();
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Validating an incorrectly formatted text using UPC-A yields an error

        GenericIDAutomation1DTest.ValidateFontFailureTest(/* input */'abcd', Enum::"Barcode Symbology"::"UPC-A", /* expected error */StrSubstNo(InvalidInputErr, 'abcd'));
    end;

    [Test]
    procedure TestUPCAValidationWithInvalidStringLength();
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Validating a text with wrong length using UPC-A symbology yields an error

        GenericIDAutomation1DTest.ValidateFontFailureTest(/* input */'1234567', Enum::"Barcode Symbology"::"UPC-A", /* expected error */StrSubstNo(InvalidInputErr, '1234567'));
    end;
}
