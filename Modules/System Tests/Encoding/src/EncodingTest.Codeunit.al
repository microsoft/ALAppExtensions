// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 132510 "EncodingTest"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    procedure TestConvertEncoding()
    var
        Encoding: Codeunit Encoding;
        TextToConvert: Text;
        ConvertedText: Text;
        ExpectedText: Text;
        UTF8: Integer;
        ISO88591: Integer;
    begin
        // [GIVEN] Assign text to convert
        TextToConvert := 'Unidoce èëüöï$æôà&. ÐÊÏp $ € A';
        ExpectedText := 'Unidoce èëüöï$æôà&. ÐÊÏp $ ? A';
        UTF8 := 65001;
        ISO88591 := 28591;

        // [WHEN] Convert the encoding of the text
        ConvertedText := Encoding.Convert(UTF8, ISO88591, TextToConvert);

        // [THEN] Compare converted text to expected text
        Assert.AreEqual(ConvertedText, ExpectedText, 'Unexpected text when converting an encoded text');
    end;
}