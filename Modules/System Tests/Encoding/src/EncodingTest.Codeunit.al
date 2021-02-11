// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132512 "Encoding Test"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";
        Any: Codeunit Any;

    [Test]
    procedure ConvertEncodingTest()
    var
        Encoding: Codeunit Encoding;
        TextToConvert, ConvertedText, ExpectedText : Text;
        UTF8, ISO88591 : Integer;
    begin
        // [Given] Assign text to convert
        TextToConvert := 'Unidoce èëüöï$æôà&. ÐÊÏp $ € A';
        ExpectedText := 'Unidoce èëüöï$æôà&. ÐÊÏp $ ? A';
        UTF8 := 65001;
        ISO88591 := 28591;

        // [When] Convert the encoding of the text
        ConvertedText := Encoding.Convert(UTF8, ISO88591, TextToConvert);

        // [Then] Compare converted text to expected text
        Assert.AreEqual(ConvertedText, ExpectedText, 'Unexpected text when converting an encoded text');
    end;

    [Test]
    procedure ConvertToSameEncodingTest()
    var
        Encoding: Codeunit Encoding;
        TextToConvert, ConvertedText : Text;
        UTF8: Integer;
    begin
        // [Given] Assign text to convert
        TextToConvert := Any.AlphanumericText(50);
        UTF8 := 65001;

        // [When] Convert the encoding of the text to the same encoding
        ConvertedText := Encoding.Convert(UTF8, UTF8, TextToConvert);

        // [Then] Compare converted text to expected text
        Assert.AreEqual(ConvertedText, TextToConvert, 'Unexpected text when converting an encoded text to the same encoding');
    end;

    [Test]
    procedure ConvertEncodingErrorTest()
    var
        Encoding: Codeunit Encoding;
        TextToConvert: Text;
        NonExistingEncoding, ISO88591 : Integer;
    begin
        // [Given] Any text and a non-existing encoding
        TextToConvert := Any.AlphanumericText(25);
        NonExistingEncoding := -42;
        ISO88591 := 28591;

        // [When] Convert the encoding of the text
        asserterror Encoding.Convert(NonExistingEncoding, ISO88591, TextToConvert);

        // [Then] An error occurs if the source encoding isn't valid
        Assert.ExpectedError('Valid values are between 0 and 65535');

        // [When] Convert the encoding of the text
        asserterror Encoding.Convert(ISO88591, NonExistingEncoding, TextToConvert);

        // [Then] An error occurs if the destination encoding isn't valid
        Assert.ExpectedError('Valid values are between 0 and 65535');
    end;
}