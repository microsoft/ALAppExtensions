// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135046 "IDA 1D EAN13 Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        InvalidInputErr: Label 'Input text %1 contains invalid characters for the chosen provider IDAutomation 1D Barcode Provider and encoding symbology EAN-13', Comment = '%1 = input text';

    [Test]
    procedure TestEAN13Encoding();
    var
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Encoding a text using EAN-13 symbology yields the correct result

        GenericBarcodeTestHelper.EncodeFontSuccessTest(/* input */'1234567891012', Enum::"Barcode Symbology"::"EAN-13", /* expected result */'V(23E5GH*STLKLT(');
    end;

    [Test]
    procedure TestEAN13ValidationWithEmptyString();
    var
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Validating an empty text using EAN-13 symbology yeilds an error

        GenericBarcodeTestHelper.ValidateFontFailureTest(/* input */'', Enum::"Barcode Symbology"::"EAN-13", /* expected error */StrSubstNo(InvalidInputErr, ''));
    end;

    [Test]
    procedure TestEAN13ValidationWithNormalString();
    var
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Validating a correctly formatted text using EAN-13 symbology doesn't yield an error

        GenericBarcodeTestHelper.ValidateFontSuccessTest(/* input */'1234567891012', Enum::"Barcode Symbology"::"EAN-13");
    end;

    [Test]
    procedure TestEAN13ValidationWithInvalidString();
    var
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Validating an incorrectly formatted text using EAN-13 symbology yields an error

        GenericBarcodeTestHelper.ValidateFontFailureTest(/* input */'&&&&&&&', Enum::"Barcode Symbology"::"EAN-13", /* expected error */StrSubstNo(InvalidInputErr, '&&&&&&&'));
    end;

    [Test]
    procedure TestEAN13ValidationWithInvalidStringLength();
    var
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Validating a text with wrong length using EAN-13 symbology yields an error

        GenericBarcodeTestHelper.ValidateFontFailureTest(/* input */'12345678901234', Enum::"Barcode Symbology"::"EAN-13", /* expected error */StrSubstNo(InvalidInputErr, '12345678901234'));
    end;
}
