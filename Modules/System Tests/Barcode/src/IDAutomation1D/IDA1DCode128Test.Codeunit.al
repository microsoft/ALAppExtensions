// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135043 "IDA 1D Code128 Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        InvalidTextErr: Label 'Input text %1 contains invalid characters for the chosen provider IDAutomation 1D Barcode Provider and encoding symbology Code-128', Comment = '%1 = input text';

    [Test]
    procedure TestCode128aEncoding();
    var
        BarcodeEncodeSettings: Record "Barcode Encode Settings";
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Encoding a text using Code128 symbology with code set 'A' yields the correct result

        BarcodeEncodeSettings."Code Set" := BarcodeEncodeSettings."Code Set"::A;

        GenericBarcodeTestHelper.EncodeFontSuccessTest(/* input */'1234', Enum::"Barcode Symbology"::Code128, BarcodeEncodeSettings, /* expected result */'Ë1234wÎ');
    end;

    [Test]
    procedure TestCode128bEncoding();
    var
        BarcodeEncodeSettings: Record "Barcode Encode Settings";
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Encoding a text using Code128 symbology with code set 'B' yields the correct result

        BarcodeEncodeSettings."Code Set" := BarcodeEncodeSettings."Code Set"::B;

        GenericBarcodeTestHelper.EncodeFontSuccessTest(/* input */'1234', Enum::"Barcode Symbology"::Code128, BarcodeEncodeSettings, /* expected result */'Ì1234xÎ');
    end;

    [Test]
    procedure TestCode128cEncoding();
    var
        BarcodeEncodeSettings: Record "Barcode Encode Settings";
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Encoding a text using Code128 symbology with code set 'C' yields the correct result

        BarcodeEncodeSettings."Code Set" := BarcodeEncodeSettings."Code Set"::C;

        GenericBarcodeTestHelper.EncodeFontSuccessTest(/* input */'1234', Enum::"Barcode Symbology"::Code128, BarcodeEncodeSettings, /* expected result */'Í,BrÎ');
    end;

    [Test]
    procedure TestCode128EncodingWithNoCodeSetSelected();
    var
        BarcodeEncodeSettings: Record "Barcode Encode Settings";
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Encoding a text using Code128 symbology with no code set set yields an error

        BarcodeEncodeSettings."Code Set" := BarcodeEncodeSettings."Code Set"::None;

        GenericBarcodeTestHelper.EncodeFontSuccessTest(/* input */'1234', Enum::"Barcode Symbology"::Code128, 'Í,BrÎ');
        GenericBarcodeTestHelper.EncodeFontSuccessTest(/* input */'1234', Enum::"Barcode Symbology"::Code128, BarcodeEncodeSettings, /* expected result */'Í,BrÎ');
    end;

    [Test]
    procedure TestCode128ValidationWithEmptyString();
    var
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Validating an empty text using Code128 symbology yeilds an error

        GenericBarcodeTestHelper.ValidateFontFailureTest(/* input */'', Enum::"Barcode Symbology"::Code128, /* expected error */StrSubstNo(InvalidTextErr, ''));
    end;

    [Test]
    procedure TestCode128aValidationWithNormalString();
    var
        BarcodeEncodeSettings: Record "Barcode Encode Settings";
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Validating a correctly formatted text using Code128 symbology with code set 'A' doesn't yield an error

        BarcodeEncodeSettings."Code Set" := BarcodeEncodeSettings."Code Set"::A;

        GenericBarcodeTestHelper.ValidateFontSuccessTest(/* input */'1234', Enum::"Barcode Symbology"::Code128, BarcodeEncodeSettings);
    end;

    [Test]
    procedure TestCode128aValidationWithInvalidString();
    var
        BarcodeEncodeSettings: Record "Barcode Encode Settings";
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Validating an incorrectly formatted text using Code128 symbology with code set 'A' yields an error

        BarcodeEncodeSettings."Code Set" := BarcodeEncodeSettings."Code Set"::A;

        GenericBarcodeTestHelper.ValidateFontFailureTest(/* input */'lowercase', Enum::"Barcode Symbology"::Code128, BarcodeEncodeSettings, /* expected error */StrSubstNo(InvalidTextErr, 'lowercase'));
    end;

    [Test]
    procedure TestCode128bValidationWithInvalidString();
    var
        BarcodeEncodeSettings: Record "Barcode Encode Settings";
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Validating an incorrectly formatted text using Code128 symbology with code set 'B' yields an error

        BarcodeEncodeSettings."Code Set" := BarcodeEncodeSettings."Code Set"::B;

        GenericBarcodeTestHelper.ValidateFontFailureTest(/* input */'€€€', Enum::"Barcode Symbology"::Code128, BarcodeEncodeSettings, /* expected error */StrSubstNo(InvalidTextErr, '€€€'));
    end;

    [Test]
    procedure TestCode128cValidationWithInvalidString();
    var
        BarcodeEncodeSettings: Record "Barcode Encode Settings";
        GenericBarcodeTestHelper: Codeunit "Generic Barcode Test Helper";
    begin
        // [Scenario] Validating an incorrectly formatted text using Code128 symbology with code set 'C' yields an error

        BarcodeEncodeSettings."Code Set" := BarcodeEncodeSettings."Code Set"::C;

        GenericBarcodeTestHelper.ValidateFontFailureTest(/* input */'ABC', Enum::"Barcode Symbology"::Code128, BarcodeEncodeSettings, /* expected error */StrSubstNo(InvalidTextErr, 'ABC'));
    end;
}
