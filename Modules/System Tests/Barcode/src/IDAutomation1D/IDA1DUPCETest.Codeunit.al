// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135054 "IDA 1D UPCE Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        InvalidInputErr: Label 'Input text %1 contains invalid characters for the chosen provider IDAutomation 1D Barcode Provider and encoding symbology UPC-E', Comment = '%1 = input string';

    [Test]
    procedure TestUPCEEncoding()
    var
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Encoding a text using UPC-E symbology yileds the correct result

        GenericBarcodeTestHelper.EncodeFontSuccessTest(/* input */'123456789012', Enum::"Barcode Symbology"::"UPC-E", /* expected result */'V(b23456*RSTKLm(W');
    end;

    [Test]
    procedure TestUPCEValidationWithEmptyString()
    var
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Validating an empty text using UPC-E symbology yeilds an error

        GenericBarcodeTestHelper.ValidateFontFailureTest(/* input */'', Enum::"Barcode Symbology"::"UPC-E", /* expected error */StrSubstNo(InvalidInputErr, ''));
    end;

    [Test]
    procedure TestUPCEValidationWithNormalString()
    var
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Validating a correctly formatted text using UPC-E doesn't yield an error

        GenericBarcodeTestHelper.ValidateFontSuccessTest(/* input */'1234567', Enum::"Barcode Symbology"::"UPC-E");
    end;

    [Test]
    procedure TestUPCEValidationWithInvalidString()
    var
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Validating an incorrectly formatted text using UPC-E yields an error

        GenericBarcodeTestHelper.ValidateFontFailureTest(/* input */'abcd', Enum::"Barcode Symbology"::"UPC-E", /* expected error */StrSubstNo(InvalidInputErr, 'abcd'));
    end;

    [Test]
    procedure TestUPCEValidationWithInvalidStringLength()
    var
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Validating a text with wrong length using UPC-E symbology yields an error

        GenericBarcodeTestHelper.ValidateFontFailureTest(/* input */'1234567890', Enum::"Barcode Symbology"::"UPC-E", /* expected error */StrSubstNo(InvalidInputErr, '1234567890'));
    end;
}
