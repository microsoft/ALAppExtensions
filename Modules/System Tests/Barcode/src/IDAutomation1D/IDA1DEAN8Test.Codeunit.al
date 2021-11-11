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
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Encoding a text using EAN-8 symbology yields the correct result

        GenericBarcodeTestHelper.EncodeFontSuccessTest(/* input */'1234567', Enum::"Barcode Symbology"::"EAN-8", /* expected result */'(1234*PQRK(');
    end;

    [Test]
    procedure TestEAN8ValidationWithEmptyString()
    var
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Validating an empty text using EAN-8 symbology yeilds an error

        GenericBarcodeTestHelper.ValidateFontFailureTest(/* input */'', Enum::"Barcode Symbology"::"EAN-8", /* expected error */StrSubstNo(InvalidInputErr, ''));
    end;

    [Test]
    procedure TestEAN8ValidationWithNormalString()
    var
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Validating a correctly formatted text using EAN-8 doesn't yield an error

        GenericBarcodeTestHelper.ValidateFontSuccessTest(/* input */'2345678', Enum::"Barcode Symbology"::"EAN-8");
    end;

    [Test]
    procedure TestEAN8ValidationWithInvalidString()
    var
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Validating an incorrectly formatted text using EAN-8 yields an error

        GenericBarcodeTestHelper.ValidateFontFailureTest(/* input */'&&&&&&&', Enum::"Barcode Symbology"::"EAN-8", /* expected error */StrSubstNo(InvalidInputErr, '&&&&&&&'));
    end;

    [Test]
    procedure TestEAN8ValidationWithInvalidStringLength();
    var
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Validating a text with wrong length using EAN-8 symbology yields an error

        GenericBarcodeTestHelper.ValidateFontFailureTest(/* input */'12345678901', Enum::"Barcode Symbology"::"EAN-8", /* expected error */StrSubstNo(InvalidInputErr, '12345678901'));
    end;
}
