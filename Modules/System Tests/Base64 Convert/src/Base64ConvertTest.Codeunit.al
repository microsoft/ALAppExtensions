// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135041 "Base64 Convert Test"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Assert: Codeunit "Library Assert";
        Base64Convert: Codeunit "Base64 Convert";
        SampleTxt: Label 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.';
        Base64SampleTxt: Label 'TG9yZW0gaXBzdW0gZG9sb3Igc2l0IGFtZXQsIGNvbnNlY3RldHVyIGFkaXBpc2NpbmcgZWxpdCwgc2VkIGRvIGVpdXNtb2QgdGVtcG9yIGluY2lkaWR1bnQgdXQgbGFib3JlIGV0IGRvbG9yZSBtYWduYSBhbGlxdWEu';
        ConvertionToBase64Err: Label 'Incorrect conversion to base-64 string.';
        ConvertionFromBase64Err: Label 'Incorrect conversion from base-64 string.';
        SampleUTF16Txt: Label 'ÆØÅæøå';
        Base64SampleUTF16Txt: Label 'xgDYAMUA5gD4AOUA';
        ConvertionToBase64UTF16Err: Label 'Incorrect conversion to base-64 string (UTF16).';
        ConvertionFromBase64UTF16Err: Label 'Incorrect conversion from base-64 string (UTF16).';

    [Test]
    procedure StringToBase64Test()
    var
        ConvertedText: Text;
    begin
        // [SCENARIO] A string variable is converted to base-64 string

        // [WHEN] The string is converted
        ConvertedText := Base64Convert.ToBase64(SampleTxt);

        // [THEN] The converted value is correct
        Assert.AreEqual(Base64SampleTxt, ConvertedText, ConvertionToBase64Err);
    end;

    [Test]
    procedure StringToBase64WithLineBreaksTest()
    var
        ConvertedText: Text;
        Base64SampleTextWithLineBreaks: Text;
    begin
        // [SCENARIO] A string variable is converted to base-64 string with line breaks (every 76 characters)

        // [GIVEN] The correct base-64 representation with line breaks of sample text
        Base64SampleTextWithLineBreaks := SplitStringWithLineBreaks(Base64SampleTxt);

        // [WHEN] The string is converted with line breaks
        ConvertedText := Base64Convert.ToBase64(SampleTxt, true);

        // [THEN] The converted value is correct
        Assert.AreEqual(Base64SampleTextWithLineBreaks, ConvertedText, ConvertionToBase64Err);
    end;

    [Test]
    procedure StringToBase64UTF16Test()
    var
        ConvertedText: Text;
    begin
        // [SCENARIO] A string variable is converted to base-64 string, binary representation is kept in UTF16

        // [WHEN] The string is converted
        ConvertedText := Base64Convert.ToBase64(SampleUTF16Txt, TextEncoding::UTF16);

        // [THEN] The converted value is correct
        Assert.AreEqual(Base64SampleUTF16Txt, ConvertedText, ConvertionToBase64UTF16Err);
    end;

    [Test]
    procedure InStreamToBase64Test()
    var
        TempBlob: Codeunit "Temp Blob";
        BlobOutStream: OutStream;
        BlobInStream: InStream;
        ConvertedText: Text;
    begin
        // [SCENARIO] The data from InStream is converted to base-64 string

        // [GIVEN] InStream that contains sample text
        TempBlob.CreateOutStream(BlobOutStream);
        BlobOutStream.WriteText(SampleTxt); // WriteText doesn't insert a break at the end of the string
        TempBlob.CreateInStream(BlobInStream);

        // [WHEN] The data from InStream is converted
        ConvertedText := Base64Convert.ToBase64(BlobInStream);

        // [THEN] The converted value is correct
        Assert.AreEqual(Base64SampleTxt, ConvertedText, ConvertionToBase64Err);
    end;

    [Test]
    procedure InStreamToBase64WithLineBreaksTest()
    var
        TempBlob: Codeunit "Temp Blob";
        BlobOutStream: OutStream;
        BlobInStream: InStream;
        ConvertedText: Text;
        Base64SampleTextWithLineBreaks: Text;
    begin
        // [SCENARIO] The data from InStream is converted to base-64 string with line breaks (every 76 characters)

        // [GIVEN] InStream that contains sample text
        TempBlob.CreateOutStream(BlobOutStream);
        BlobOutStream.WriteText(SampleTxt); // WriteText doesn't insert a break at the end of the string
        TempBlob.CreateInStream(BlobInStream);

        // [GIVEN] The correct base-64 representation with line breaks of sample text
        Base64SampleTextWithLineBreaks := SplitStringWithLineBreaks(Base64SampleTxt);

        // [WHEN] The data from InStream is converted with line breaks
        ConvertedText := Base64Convert.ToBase64(BlobInStream, true);

        // [THEN] The converted value is correct
        Assert.AreEqual(Base64SampleTextWithLineBreaks, ConvertedText, ConvertionToBase64Err);
    end;

    [Test]
    procedure FromBase64StringTest()
    var
        ConvertedText: Text;
    begin
        // [SCENARIO] A base-64 string is converted to a regular string

        // [WHEN] The base-64 string is converted
        ConvertedText := Base64Convert.FromBase64(Base64SampleTxt);

        // [THEN] The converted value is correct
        Assert.AreEqual(SampleTxt, ConvertedText, ConvertionFromBase64Err);
    end;

    [Test]
    procedure FromBase64UTF16StringTest()
    var
        ConvertedText: Text;
    begin
        // [SCENARIO] A base-64 string with UTF16 encoding is converted to a regular string

        // [WHEN] The base-64 string is converted
        ConvertedText := Base64Convert.FromBase64(Base64SampleUTF16Txt, TextEncoding::UTF16);

        // [THEN] The converted value is correct
        Assert.AreEqual(SampleUTF16Txt, ConvertedText, ConvertionFromBase64UTF16Err);
    end;

    [Test]
    procedure FromBase64StringToOutStreamTest()
    var
        TempBlob: Codeunit "Temp Blob";
        BlobOutStream: OutStream;
        BlobInStream: InStream;
        ConvertedText: Text;
    begin
        // [SCENARIO] A base-64 string is converted to a regular string and written to an OutStream

        // [GIVEN] An OutStream attached to a BLOB
        TempBlob.CreateOutStream(BlobOutStream);

        // [WHEN] The base-64 is converted and written to an OutStream
        Base64Convert.FromBase64(Base64SampleTxt, BlobOutStream);

        // [WHEN] The value that was written is retrieved
        TempBlob.CreateInStream(BlobInStream);
        BlobInStream.Read(ConvertedText);

        // [THEN] The converted value is correct
        Assert.AreEqual(SampleTxt, ConvertedText, ConvertionFromBase64Err);
    end;

    [Test]
    procedure EmptyInputTest()
    var
        TempBlob: Codeunit "Temp Blob";
        BlobOutStream: OutStream;
        BlobInStream: InStream;
        ConvertedText: Text;
    begin
        // [SCENARIO] Convertion from or to an empty string results in an empty string

        // [GIVEN] An InStream attached to a BLOB
        TempBlob.CreateInStream(BlobInStream);

        // [WHEN] The input of ToBase64 is empty
        // [THEN] The output is empty
        Assert.AreEqual('', Base64Convert.ToBase64(''), ConvertionToBase64Err);
        Assert.AreEqual('', Base64Convert.ToBase64('', true), ConvertionToBase64Err);
        Assert.AreEqual('', Base64Convert.ToBase64(BlobInStream, true), ConvertionToBase64Err);
        Assert.AreEqual('', Base64Convert.ToBase64(BlobInStream), ConvertionToBase64Err);

        // [WHEN] The input of FromBase64 is empty
        // [THEN] The output is empty
        Assert.AreEqual('', Base64Convert.FromBase64(''), ConvertionFromBase64Err);

        // [GIVEN] An OutStream attached to a BLOB
        TempBlob.CreateOutStream(BlobOutStream);

        // [WHEN] The base-64 is converted and written to an OutStream
        Base64Convert.FromBase64('', BlobOutStream);

        // [WHEN] The value that was written is retrieved
        TempBlob.CreateInStream(BlobInStream);
        BlobInStream.Read(ConvertedText);

        // [THEN] The output is empty
        Assert.AreEqual('', ConvertedText, ConvertionFromBase64Err);
    end;

    [Test]
    procedure ToAndFromBase64Test()
    var
        ConvertedText: Text;
        ConvertedBackText: Text;
    begin
        // [SCENARIO] The convertion to base-64 string and then from it back results in the initial string.

        // [WHEN] The string is converted to base-64
        ConvertedText := Base64Convert.ToBase64(SampleTxt);

        // [WHEN] The string is converted back from base-64
        ConvertedBackText := Base64Convert.FromBase64(ConvertedText);

        // [THEN] The value is the same as the initial one
        Assert.AreEqual(SampleTxt, ConvertedBackText, 'The converted back value is not the same as the initial one.');
    end;

    [Test]
    procedure LineBreaksAreCorrectTest()
    var
        Base64SampleTextWithLineBreaks: Text;
        Base64SampleTextWithLineBreaksManual: Text;
        CRLF: Text[2];
    begin
        // [SCENARIO] The local function for splitting the string works correctly

        CRLF[1] := 13; // Carriage return, '\r'
        CRLF[2] := 10; // Line feed, '\n'

        // [GIVEN] The string is splitted manually
        Base64SampleTextWithLineBreaksManual := CopyStr(Base64SampleTxt, 1, 76); // Copy first 76 characters
        Base64SampleTextWithLineBreaksManual += CRLF;
        Base64SampleTextWithLineBreaksManual += CopyStr(Base64SampleTxt, 77, 76); // Copy second 76 characters
        Base64SampleTextWithLineBreaksManual += CRLF;
        Base64SampleTextWithLineBreaksManual += CopyStr(Base64SampleTxt, 153); // Copy rest

        // [WHEN] The string is splitted automatically
        Base64SampleTextWithLineBreaks := SplitStringWithLineBreaks(Base64SampleTxt);

        // [THEN] The result is the same
        Assert.AreEqual(Base64SampleTextWithLineBreaksManual, Base64SampleTextWithLineBreaks, 'The line breaks are not correct.');
    end;

    local procedure SplitStringWithLineBreaks(String: Text): Text
    var
        Result: Text;
        CurrentLineFirstIndex: Integer;
        LineLength: Integer;
        CRLF: Text[2];
    begin
        CRLF[1] := 13; // Carriage return, '\r'
        CRLF[2] := 10; // Line feed, '\n'

        CurrentLineFirstIndex := 1;
        LineLength := 76;
        Result := '';

        while CurrentLineFirstIndex + LineLength < StrLen(String) do begin
            Result += CopyStr(String, CurrentLineFirstIndex, LineLength);
            Result += CRLF;
            CurrentLineFirstIndex += LineLength;
        end;
        Result += CopyStr(String, CurrentLineFirstIndex); // Copy rest

        exit(Result);
    end;
}
