// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135042 "Barcode Test"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Assert: Codeunit "Library Assert";
        ExampleTxt: Label 'Lorem ipsum dolor sit amet', Locked = true;

    [Test]
    procedure CodebarTest()
    var
        FontEncoder: DotNet FontEncoder;
        EncodedText: Text;
    begin
        // [SCENARIO] The barcode encoder can be used from within the application code

        // [GIVEN] The font encoder is initialized
        FontEncoder := FontEncoder.FontEncoder();

        // [WHEN] The Codabar barcode type is used to encode the provided text
        EncodedText := FontEncoder.Codabar(ExampleTxt);

        // [THEN] The encoded text has the correct value
        Assert.AreEqual('AB', EncodedText, 'Expected the result to have the correct value.');
    end;
}
