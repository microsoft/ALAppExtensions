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
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Encoding a text using UPC-A symbology yileds the correct result

        GenericBarcodeTestHelper.EncodeFontSuccessTest(/* input */'123456789012', Enum::"Barcode Symbology"::"UPC-A", /* expected result */'V(b23456*RSTKLm(W');
    end;

    [Test]
    procedure TestUPCAValidationWithEmptyString();
    var
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Validating an empty text using UPC-A symbology yeilds an error

        GenericBarcodeTestHelper.ValidateFontFailureTest(/* input */'', Enum::"Barcode Symbology"::"UPC-A", /* expected error */StrSubstNo(InvalidInputErr, ''));
    end;

    [Test]
    procedure TestUPCAValidationWithNormalString();
    var
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Validating a correctly formatted text using UPC-A symbology doesn't yield an error

        GenericBarcodeTestHelper.ValidateFontSuccessTest(/* input */'123456789012', Enum::"Barcode Symbology"::"UPC-A");
    end;

    [Test]
    procedure TestUPCAValidationWithInvalidString();
    var
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Validating an incorrectly formatted text using UPC-A yields an error

        GenericBarcodeTestHelper.ValidateFontFailureTest(/* input */'abcd', Enum::"Barcode Symbology"::"UPC-A", /* expected error */StrSubstNo(InvalidInputErr, 'abcd'));
    end;

    [Test]
    procedure TestUPCAValidationWithInvalidStringLength();
    var
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Validating a text with wrong length using UPC-A symbology yields an error

        GenericBarcodeTestHelper.ValidateFontFailureTest(/* input */'1234567', Enum::"Barcode Symbology"::"UPC-A", /* expected error */StrSubstNo(InvalidInputErr, '1234567'));
    end;
}
