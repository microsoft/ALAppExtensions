// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135030 "Temp Blob Test"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Assert: Codeunit "Library Assert";
        SampleTxt: Label 'Lorem ipsum dolor sit amet, consectetur adipiscing elit';

    [Test]
    procedure CreateStreamTest()
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        // [SCENARIO] Streams (InStream and OutStream) can be created and used.
        WriteSampleTextToBlob(TempBlob);
        Assert.IsTrue(BlobContentIsEqualToSampleText(TempBlob), 'Same text was expected.');
    end;

    [Test]
    procedure CreateStreamWithEncodingTest()
    var
        TempBlob: Codeunit "Temp Blob";
        BlobOutStream: OutStream;
        BlobInStream: InStream;
        OutputText: Text;
    begin
        // [SCENARIO] Streams with encoding (InStream and OutStream) can be created and used.

        // [GIVEN] Some value in TempBlob.
        TempBlob.CreateOutStreamWithEncoding(BlobOutStream, TextEncoding::Windows);
        BlobOutStream.WriteText(SampleTxt);

        // [WHEN] The correct encoding is used.
        TempBlob.CreateInStreamWithEncoding(BlobInStream, TextEncoding::Windows);
        BlobInStream.ReadText(OutputText);
        // [THEN] Correct result.
        Assert.AreEqual(SampleTxt, OutputText, 'Same text was expected.');

        // [WHEN] The wrong encoding is used.
        TempBlob.CreateInStreamWithEncoding(BlobInStream, TextEncoding::UTF16);
        BlobInStream.ReadText(OutputText);
        // [THEN] Incorrect result.
        Assert.AreNotEqual(SampleTxt, OutputText, 'Different text was expected.');
    end;

    [Test]
    procedure ReadFromRecordTest()
    var
        PersistentBlob: Record "PersistentBlob";
        TempBlob: Codeunit "Temp Blob";
        BlobOutStream: OutStream;
        BlobFieldNo: Integer;
        IntegerFieldNo: Integer;
    begin
        // [SCENARIO] TempBlob can be set from Record.

        IntegerFieldNo := 1;
        BlobFieldNo := 2;

        // [THEN] cannot set the BLOB from non-BLOB field.
        asserterror TempBlob.FromRecord(PersistentBlob, IntegerFieldNo);

        // [GIVEN] A value is written on the record.
        PersistentBlob.Blob.CreateOutStream(BlobOutStream);
        BlobOutStream.Write(SampleTxt);

        TempBlob.FromRecord(PersistentBlob, BlobFieldNo);

        // [THEN] The value is copied In TempBlob.
        Assert.IsTrue(BlobContentIsEqualToSampleText(TempBlob), 'Same text was expected.');
    end;

    [Test]
    procedure ReadFromRecordRefTest()
    var
        PersistentBlob: Record "PersistentBlob";
        TempBlob: Codeunit "Temp Blob";
        PersistentBlobRecordRef: RecordRef;
        BlobOutStream: OutStream;
        BlobFieldNo: Integer;
        IntegerFieldNo: Integer;
    begin
        // [SCENARIO] TempBlob can be set from RecordRef.

        IntegerFieldNo := 1;
        BlobFieldNo := 2;

        // [THEN] Cannot set the value of an uninitialized RecordRef.
        asserterror TempBlob.FromRecordRef(PersistentBlobRecordRef, BlobFieldNo);

        // [GIVEN] RecordRef is initialized.
        PersistentBlobRecordRef.GetTable(PersistentBlob);

        // [THEN] Cannot set the BLOB from a non-BLOB field.
        asserterror TempBlob.FromRecordRef(PersistentBlobRecordRef, IntegerFieldNo);

        // [GIVEN] Some value is written on the record.
        PersistentBlob.Blob.CreateOutStream(BlobOutStream);
        BlobOutStream.Write(SampleTxt);
        PersistentBlobRecordRef.GetTable(PersistentBlob);

        TempBlob.FromRecordRef(PersistentBlobRecordRef, BlobFieldNo);

        // [THEN] The value is copied In TempBlob.
        Assert.IsTrue(BlobContentIsEqualToSampleText(TempBlob), 'Same text was expected.');
    end;

    [Test]
    procedure WriteToRecordRefTest()
    var
        PersistentBlob: Record "PersistentBlob";
        TempBlob: Codeunit "Temp Blob";
        PersistentBlobRecordRef: RecordRef;
        BlobInStream: InStream;
        OutputText: Text;
        BlobFieldNo: Integer;
        IntegerFieldNo: Integer;
    begin
        // [SCENARIO] TempBlob can be exported to RecordRef.

        IntegerFieldNo := 1;
        BlobFieldNo := 2;

        // [GIVEN] A value in TempBlob.
        WriteSampleTextToBlob(TempBlob);

        // [THEN] Cannot get a value for an uninitialized RecordRef.
        asserterror TempBlob.ToRecordRef(PersistentBlobRecordRef, BlobFieldNo);

        // [GIVEN] RecordRef is initialized.
        PersistentBlobRecordRef.GetTable(PersistentBlob);

        // [THEN] Cannot get a value for a non-BLOB field.
        asserterror TempBlob.ToRecordRef(PersistentBlobRecordRef, IntegerFieldNo);

        TempBlob.ToRecordRef(PersistentBlobRecordRef, BlobFieldNo);

        PersistentBlobRecordRef.SetTable(PersistentBlob);
        PersistentBlob.Blob.CreateInStream(BlobInStream);
        BlobInStream.ReadText(OutputText);
        // [THEN] The same value is copied on the record.
        Assert.AreEqual(SampleTxt, OutputText, 'Same text was expected.');
    end;

    local procedure WriteSampleTextToBlob(TempBlob: Codeunit "Temp Blob")
    var
        BlobOutStream: OutStream;
    begin
        TempBlob.CreateOutStream(BlobOutStream);
        BlobOutStream.WriteText(SampleTxt);
    end;

    local procedure BlobContentIsEqualToSampleText(TempBlob: Codeunit "Temp Blob"): Boolean
    var
        BlobInStream: InStream;
        OutputText: Text;
    begin
        TempBlob.CreateInStream(BlobInStream);
        BlobInStream.ReadText(OutputText);
        exit(SampleTxt = OutputText);
    end;
}

