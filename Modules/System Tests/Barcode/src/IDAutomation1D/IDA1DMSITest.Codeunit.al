// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135049 "IDA 1D MSI Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        InvalidInputErr: Label 'Input text %1 contains invalid characters for the chosen provider IDAutomation 1D Barcode Provider and encoding symbology MSI', Comment = '%1 = input text';

    [Test]
    procedure TestMSIEncoding();
    var
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] ncoding a text using MSI symbology yields the correct result

        GenericBarcodeTestHelper.EncodeFontSuccessTest(/* input */'123456', Enum::"Barcode Symbology"::MSI, /* expected result */'(1234566)');
    end;

    [Test]
    procedure TestMSIValidationWithEmptyString();
    var
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Validating an empty text using MSI symbology yeilds an error

        GenericBarcodeTestHelper.ValidateFontFailureTest(/* input */'', Enum::"Barcode Symbology"::MSI, /* expected error */StrSubstNo(InvalidInputErr, ''));
    end;

    [Test]
    procedure TestMSIValidationWithNormalString();
    var
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Validating a correctly formatted text using MSI symbology doesn't yield an error

        GenericBarcodeTestHelper.ValidateFontSuccessTest(/* input */'123456', Enum::"Barcode Symbology"::MSI);
    end;

    [Test]
    procedure TestMSIValidationWithInvalidString();
    var
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Validating an incorrectly formatted text using MSI symbology yields an error

        GenericBarcodeTestHelper.ValidateFontFailureTest(/* input */'abcd', Enum::"Barcode Symbology"::MSI, /* expected error */StrSubstNo(InvalidInputErr, 'abcd'));
    end;
}
