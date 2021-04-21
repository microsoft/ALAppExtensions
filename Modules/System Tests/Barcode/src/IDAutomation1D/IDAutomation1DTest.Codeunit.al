// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135056 "IDAutomation 1D Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        CannotFindBarcodeEncoderErr: Label 'Provider IDAutomation 1D Barcode Provider: Barcode symbol encoder Unsupported Barcode Symbology is not implemented by this provider!', comment = '%1 Provider Caption, %2 = Symbology Caption';

    [Test]
    procedure TestEncodingWithUnsupportedSymbology()
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Encoding with unsupported barcode symbology yields an error

        GenericIDAutomation1DTest.EncodeFontFailureTest(/* input */'A1234B', Enum::"Barcode Symbology"::"Unsupported Barcode Symbology", /* expected error */CannotFindBarcodeEncoderErr);
        GenericIDAutomation1DTest.EncodeFontFailureTest(/* input */'&&&&&&', Enum::"Barcode Symbology"::"Unsupported Barcode Symbology", /* expected error */CannotFindBarcodeEncoderErr);
        GenericIDAutomation1DTest.EncodeFontFailureTest(/* input */'(A&&&&&&A)', Enum::"Barcode Symbology"::"Unsupported Barcode Symbology", /* expected error */CannotFindBarcodeEncoderErr);
    end;

    [Test]
    procedure TestValidationWithUnsupportedSymbology()
    var
        GenericIDAutomation1DTest: Codeunit "Generic IDAutomation 1D Test";
    begin
        // [Scenario] Validating with unsupported barcode symbology yields an error

        GenericIDAutomation1DTest.ValidateFontFailureTest(/* input */'A1234B', Enum::"Barcode Symbology"::"Unsupported Barcode Symbology", /* expected error */CannotFindBarcodeEncoderErr);
        GenericIDAutomation1DTest.ValidateFontFailureTest(/* input */'&&&&&&', Enum::"Barcode Symbology"::"Unsupported Barcode Symbology", /* expected error */CannotFindBarcodeEncoderErr);
        GenericIDAutomation1DTest.ValidateFontFailureTest(/* input */'(A&&&&&&A)', Enum::"Barcode Symbology"::"Unsupported Barcode Symbology", /* expected error */CannotFindBarcodeEncoderErr);
    end;
}