// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.IO;

using System.IO;
using System.Utilities;
using System;
using System.TestLibraries.Utilities;

codeunit 139036 "Data Compression Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
    end;

    var
        DataCompression: Codeunit "Data Compression";
        Assert: Codeunit "Library Assert";
        DotNetVariableNotCreatedErr: Label 'DotNetVariableNotCreated';

    [Test]
    [Scope('OnPrem')]
    procedure TestCreateArchive()
    var
        EntryTempBlob: Codeunit "Temp Blob";
        ArchiveTempBlob: Codeunit "Temp Blob";
        DataCompressionLocal: Codeunit "Data Compression";
        EntryInStream: InStream;
        ArchiveInStream: InStream;
        ArchiveOutStream: OutStream;
    begin
        Clear(DataCompression);
        DataCompression.CreateZipArchive();
        EntryTempBlob.CreateInStream(EntryInStream);
        DataCompression.AddEntry(EntryInStream, 'some/directory/test.txt');
        ArchiveTempBlob.CreateOutStream(ArchiveOutStream);
        DataCompression.SaveZipArchive(ArchiveOutStream);
        DataCompression.CloseZipArchive();
        ArchiveTempBlob.CreateInStream(ArchiveInStream);

        // assert that you can successfully construct a ZipArchive out of the saved InStream
        DataCompressionLocal.OpenZipArchive(ArchiveInStream, false);

        // Clean up
        Clear(DataCompression);
    end;


    [Test]
    [Scope('OnPrem')]
    procedure TestCloseArchive()
    var
        EntryTempBlob: Codeunit "Temp Blob";
        EntryInStream: InStream;
        EntryList: List of [Text];
    begin
        Clear(DataCompression);
        DataCompression.CreateZipArchive();
        EntryTempBlob.CreateInStream(EntryInStream);
        DataCompression.AddEntry(EntryInStream, 'some/directory/test.txt');
        DataCompression.CloseZipArchive();

        // assert that you cannot get an entry list because the archive has been disposed
        asserterror DataCompression.GetEntryList(EntryList);

        // Clean up
        Clear(DataCompression);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UnintializedZipFile()
    var
        EntryTempBlob: Codeunit "Temp Blob";
        EntryInStream: InStream;
    begin
        // Purpose: Verify error is thrown if no ZIP archive have been created

        // Setup: Create an empty file
        Clear(DataCompression);
        EntryTempBlob.CreateInStream(EntryInStream);

        // Exercise: Try to add a file to an uninitialized ZIP archive
        asserterror DataCompression.AddEntry(EntryInStream, 'some/directory/test.txt');
        Assert.ExpectedErrorCode(DotNetVariableNotCreatedErr);

        // Clean up
        Clear(EntryTempBlob);
        Clear(DataCompression);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestAddEntry()
    var
        TempBlob: Codeunit "Temp Blob";
        TempBlobZip: Codeunit "Temp Blob";
        ZipArchiveLocal: DotNet ZipArchive;
        ZipArchiveEntry: DotNet ZipArchiveEntry;
        StreamReader: DotNet StreamReader;
        ZipArchiveMode: DotNet ZipArchiveMode;
        InStream: InStream;
        OutStream: OutStream;
        ZipStream: OutStream;
        FilePath: array[2] of Text;
        FileContent: array[2] of Text;
        Index: Integer;
        FileText: Text;
    begin
        // [SCERNARIO] Verify that one can add streams to ZIP stream.

        // [GIVEN] create streams with text content
        FilePath[1] := 'some/directory/test.txt';
        FilePath[2] := 'some/other/directory/test.txt';
        FileText := 'VerifyZipStreamAdd10';
        for Index := 1 to ArrayLen(FilePath) do begin
            FileText := IncStr(FileText);
            FileContent[Index] := FileText;
        end;
        TempBlobZip.CreateOutStream(ZipStream);
        DataCompression.CreateZipArchive();

        // [WHEN] add the streams to zip stream
        for Index := 1 to ArrayLen(FilePath) do begin
            TempBlob.CreateOutStream(OutStream);
            OutStream.WriteText(FileContent[Index]);
            TempBlob.CreateInStream(InStream);
            DataCompression.AddEntry(InStream, FilePath[Index]);
        end;
        DataCompression.SaveZipArchive(ZipStream);
        DataCompression.CloseZipArchive();
        TempBlobZip.CreateInStream(InStream);

        // [THEN] verify that ZIP stream contains the data
        ZipArchiveLocal := ZipArchiveLocal.ZipArchive(InStream, ZipArchiveMode.Read);
        Index := 1;
        foreach ZipArchiveEntry in ZipArchiveLocal.Entries() do begin
            Assert.AreEqual(FilePath[Index], ZipArchiveEntry.FullName(), 'names not the same');
            StreamReader := StreamReader.StreamReader(ZipArchiveEntry.Open());
            Assert.AreEqual(FileContent[Index], StreamReader.ReadToEnd(), 'content is different');
            Index += 1;
        end;

        // Clean up
        Clear(DataCompression);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetEntryList()
    var
        TempBlob: Codeunit "Temp Blob";
        DataCompressionLocal: Codeunit "Data Compression";
        EntryList: List of [Text];
        InStream: InStream;
        OutStream: OutStream;
        FilePath: array[2] of Text;
        FileContent: array[2] of Text;
        Index: Integer;
        FileText: Text;
        EntryKey: Text;
    begin
        // [GIVEN] create streams with text content
        FilePath[1] := 'some/directory/test.txt';
        FilePath[2] := 'some/other/directory/test.txt';
        FileText := 'VerifyGetEntryList10';
        for Index := 1 to ArrayLen(FilePath) do begin
            FileText := IncStr(FileText);
            FileContent[Index] := FileText;
        end;
        DataCompression.CreateZipArchive();

        // [WHEN] add the streams to zip stream
        for Index := 1 to ArrayLen(FilePath) do begin
            TempBlob.CreateOutStream(OutStream);
            OutStream.WriteText(FileContent[Index]);
            TempBlob.CreateInStream(InStream);
            DataCompression.AddEntry(InStream, FilePath[Index]);
        end;

        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStream);
        DataCompression.SaveZipArchive(OutStream);
        DataCompression.CloseZipArchive();
        TempBlob.CreateInStream(InStream);

        // [THEN] verify that GetEntryList returns the list of entries
        DataCompressionLocal.OpenZipArchive(InStream, false);
        DataCompressionLocal.GetEntryList(EntryList);
        Index := 1;
        foreach EntryKey in EntryList do begin
            Assert.AreEqual(FilePath[Index], EntryKey, '');
            Index += 1;
        end;

        // Clean up
        Clear(DataCompression);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestRemoveEntry()
    var
        TempBlob: Codeunit "Temp Blob";
        DataCompressionLocal: Codeunit "Data Compression";
        EntryList: List of [Text];
        InStream: InStream;
        OutStream: OutStream;
        FilePath: List of [Text];
        Index: Integer;
        FileText: Text;
        EntryKey: Text;
    begin
        // [GIVEN] create streams with text content
        FilePath.Add('some/directory/test.txt');
        FilePath.Add('some/other/directory/test.txt');
        FileText := 'VerifyGetEntryList10';
        DataCompression.CreateZipArchive();

        // [WHEN] add the streams to zip stream
        for Index := 1 to FilePath.Count() do begin
            TempBlob.CreateOutStream(OutStream);
            OutStream.WriteText(FileText);
            TempBlob.CreateInStream(InStream);
            DataCompression.AddEntry(InStream, FilePath.Get(Index));
        end;

        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStream);
        DataCompression.SaveZipArchive(OutStream);
        DataCompression.CloseZipArchive();
        TempBlob.CreateInStream(InStream);

        // [THEN] verify that GetEntryList returns the list of entries
        DataCompressionLocal.OpenZipArchive(InStream, true);
        DataCompressionLocal.GetEntryList(EntryList);
        Assert.AreEqual(FilePath.Count(), EntryList.Count(), 'Wrong number of entries');
        Index := 1;
        foreach EntryKey in EntryList do begin
            Assert.AreEqual(FilePath.Get(Index), EntryKey, '');
            Index += 1;
        end;

        // [WHEN] We remove an entry
        DataCompressionLocal.RemoveEntry(FilePath.Get(1));
        FilePath.RemoveAt(1);

        // [THEN] verify that GetEntryList returns the list of entries
        Clear(EntryList);
        DataCompressionLocal.GetEntryList(EntryList);
        Assert.AreEqual(FilePath.Count(), EntryList.Count(), 'Wrong number of entries');
        Index := 1;
        foreach EntryKey in EntryList do begin
            Assert.AreEqual(FilePath.Get(Index), EntryKey, '');
            Index += 1;
        end;

        // Clean up
        Clear(DataCompression);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestExtractEntry()
    var
        TempBlob: Codeunit "Temp Blob";
        DataCompressionLocal: Codeunit "Data Compression";
        EntryList: List of [Text];
        InStream: InStream;
        OutStream: OutStream;
        FilePath: array[2] of Text;
        FileContent: array[2] of Text;
        Index: Integer;
        EntryLength: Integer;
        FileText: Text;
        EntryKey: Text;
    begin
        // [GIVEN] create streams with text content
        FilePath[1] := 'some/directory/test.txt';
        FilePath[2] := 'some/other/directory/test.txt';
        FileText := 'VerifyGetEntryList10';
        for Index := 1 to ArrayLen(FilePath) do begin
            FileText := IncStr(FileText);
            FileContent[Index] := FileText;
        end;
        DataCompression.CreateZipArchive();

        // [WHEN] add the streams to zip stream
        for Index := 1 to ArrayLen(FilePath) do begin
            TempBlob.CreateOutStream(OutStream);
            OutStream.WriteText(FileContent[Index]);
            TempBlob.CreateInStream(InStream);
            DataCompression.AddEntry(InStream, FilePath[Index]);
        end;

        Clear(TempBlob);
        DataCompression.SaveZipArchive(TempBlob);
        DataCompression.CloseZipArchive();

        // [THEN] verify that ExtractEntry extracts the entry correctly
        DataCompressionLocal.OpenZipArchive(TempBlob, false);
        DataCompressionLocal.GetEntryList(EntryList);
        Index := 1;
        foreach EntryKey in EntryList do begin
            Clear(TempBlob);
            TempBlob.CreateOutStream(OutStream);
            EntryLength := DataCompressionLocal.ExtractEntry(EntryKey, OutStream);
            TempBlob.CreateInStream(InStream);
            InStream.ReadText(FileText);
            Assert.AreEqual(FileContent[Index], FileText, 'wrong content extracted');
            Assert.AreEqual(StrLen(FileContent[Index]), EntryLength, 'wrong entry length extracted');
            Index += 1;
        end;

        // Clean up
        Clear(DataCompression);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGZipCompressAndDecompress()
    var
        TempBlob: Codeunit "Temp Blob";
        TempBlobGZipCompressed: Codeunit "Temp Blob";
        TempBlobGZipDecompressed: Codeunit "Temp Blob";
        ContentInStream: InStream;
        ContentOutStream: OutStream;
        GZipCompressedInStream: InStream;
        GZipCompressedOutStream: OutStream;
        GZipDecompressedInStream: InStream;
        GZipDecompressedOutStream: OutStream;
        StreamContent: Text;
        DecompressedStreamContent: Text;
    begin
        // [SCERNARIO] Verify that one can compress and decompress streams with GZip

        // [GIVEN] create stream with text content
        StreamContent := 'VerifyGZipStreamAdd10';
        TempBlob.CreateOutStream(ContentOutStream);
        ContentOutStream.WriteText(StreamContent);
        TempBlob.CreateInStream(ContentInStream);

        // [WHEN] compress the the stream with GZip
        TempBlobGZipCompressed.CreateOutStream(GZipCompressedOutStream);
        DataCompression.GZipCompress(ContentInStream, GZipCompressedOutStream);
        TempBlobGZipCompressed.CreateInStream(GZipCompressedInStream);

        // [WHEN] Decompress the Gzip stream
        TempBlobGZipDecompressed.CreateOutStream(GZipDecompressedOutStream);
        DataCompression.GZipDecompress(GZipCompressedInStream, GZipDecompressedOutStream);
        TempBlobGZipDecompressed.CreateInStream(GZipDecompressedInStream);

        // [THEN] verify that the decompressed stream contains the data
        GZipDecompressedInStream.ReadText(DecompressedStreamContent);
        Assert.AreEqual(StreamContent, DecompressedStreamContent, 'Stream content changed after GZip compression and decompression.');
        // Clean up
        Clear(DataCompression);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestIsGZip()
    var
        TempBlob: array[2] of Codeunit "Temp Blob";
        TempBlobGZipCompressed: Codeunit "Temp Blob";
        ShortContentInStream, ContentInStream : InStream;
        ContentOutStream: OutStream;
        GZipCompressedInStream: InStream;
        GZipCompressedOutStream: OutStream;
        StreamContent: Text;
    begin
        // [SCERNARIO] Verify that one can add streams to GZIP stream.

        // [GIVEN] create stream with text content
        StreamContent := 'VerifyGZipStreamAdd10';
        TempBlob[1].CreateOutStream(ContentOutStream);
        ContentOutStream.WriteText(StreamContent);
        TempBlob[1].CreateInStream(ContentInStream);

        StreamContent := '_';
        TempBlob[2].CreateOutStream(ContentOutStream);
        ContentOutStream.WriteText(StreamContent);
        TempBlob[2].CreateInStream(ShortContentInStream);

        // [WHEN] compress the the stream with GZip
        TempBlobGZipCompressed.CreateOutStream(GZipCompressedOutStream);
        DataCompression.GZipCompress(ContentInStream, GZipCompressedOutStream);
        TempBlobGZipCompressed.CreateInStream(GZipCompressedInStream);

        // [THEN] verify that IsGZip returns true for compressed stream and false for the uncompressed stream
        Assert.IsTrue((ShortContentInStream.Length > 0) and (ShortContentInStream.Length < 2), 'ShortContentInStream should be less than 2 bytes long, but never zero.');
        Assert.IsFalse(DataCompression.IsGZip(ShortContentInStream), 'Stream with less bytes than the header must not fail.');
        Assert.IsTrue(DataCompression.IsGZip(GZipCompressedInStream), 'IsGzip should have returned true for the GZip compressed stream.');
        Assert.IsFalse(DataCompression.IsGZip(ContentInStream), 'IsGzip should have returned false for the uncompressed stream.');
        Assert.IsFalse(GZipCompressedInStream.EOS(), 'IsGzip should not have moved the input stream to EOS.');
        Assert.IsFalse(ContentInStream.EOS(), 'IsGzip should not have moved the input stream to EOS.');

        // Clean up
        Clear(DataCompression);
    end;

    [Test]
    procedure TestIsZip()
    var
        TempBlob: array[2] of Codeunit "Temp Blob";
        TempBlobZipCompressed: Codeunit "Temp Blob";
        ShortContentInStream, ContentInStream : InStream;
        ContentOutStream: OutStream;
        ZipCompressedInStream: InStream;
        ZipCompressedOutStream: OutStream;
    begin
        // [SCERNARIO] Verify that one can add streams to ZIP stream.

        // [GIVEN] create stream with text content
        TempBlob[1].CreateOutStream(ContentOutStream);
        ContentOutStream.WriteText('Any.AlphabeticText(20) would be nice to have here.');
        TempBlob[1].CreateInStream(ContentInStream);

        TempBlob[2].CreateOutStream(ContentOutStream);
        ContentOutStream.WriteText('_');
        TempBlob[2].CreateInStream(ShortContentInStream);

        // [WHEN] compress the the stream with Zip
        DataCompression.CreateZipArchive();
        DataCompression.AddEntry(ContentInStream, 'some/directory/test.txt');
        TempBlobZipCompressed.CreateOutStream(ZipCompressedOutStream);
        DataCompression.SaveZipArchive(ZipCompressedOutStream);
        TempBlobZipCompressed.CreateInStream(ZipCompressedInStream);

        // [THEN] verify that IsGZip returns true for compressed stream and false for the uncompressed stream
        Assert.IsTrue((ShortContentInStream.Length > 0) and (ShortContentInStream.Length < 4), 'ShortContentInStream should be less than 4 bytes long, but never zero.');
        Assert.IsFalse(DataCompression.IsZip(ShortContentInStream), 'Stream with less bytes than the header must not fail.');
        Assert.IsFalse(DataCompression.IsGZip(ZipCompressedInStream), 'ZIP compressed stream must not be recognized as GZIP.');
        Assert.IsTrue(DataCompression.IsZip(ZipCompressedInStream), 'ZIP compressed stream must be recognized as ZIP.');
        Assert.IsFalse(ZipCompressedInStream.EOS(), 'IsZip should not have moved the input stream to EOS.');
        Assert.IsFalse(ContentInStream.EOS(), 'IsZip should not have moved the input stream to EOS.');

        // Clean up
        Clear(DataCompression);
    end;

}