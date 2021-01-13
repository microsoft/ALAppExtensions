// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 11111800 "ConvertTest"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    procedure TestConvertTextEncoding()
    var
        Convert: Codeunit Convert;
        TextToConvert: Text;
        ConvertedText: Text;
        ExpectedText: Text;
    begin
        // [GIVEN] Assign text to convert
        TextToConvert := 'Unidoce èëüöï$æôà&. ÐÊÏp $ € A';
        ExpectedText := 'Unidoce èëüöï$æôà&. ÐÊÏp $ ? A';

        // [WHEN] Get XmlDocument to text
        ConvertedText := Convert.ConvertTextEncoding(65001, 28591, TextToConvert);

        // [THEN] Compare converted text to expected text
        Assert.AreEqual(ConvertedText, ExpectedText, 'Unexpected text when converting an encoded text');
    end;
}