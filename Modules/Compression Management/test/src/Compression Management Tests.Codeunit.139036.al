// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139036 "Compression Management Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
    end;

    var
        CompressionManagement: Codeunit "Compression Management";
        Assert: Codeunit "Library Assert";
        DotNetVariableNotCreatedErr: Label 'DotNetVariableNotCreated';

    [Test]
    [Scope('OnPrem')]
    procedure TestCreateArchive()
    var
        EntryTempBlob: Codeunit "Temp Blob";
        ArchiveTempBlob: Codeunit "Temp Blob";
        CompressionManagementLocal: Codeunit "Compression Management";
        EntryInStream: InStream;
        ArchiveInStream: InStream;
        ArchiveOutStream: OutStream;
    begin
        Clear(CompressionManagement);
        CompressionManagement.CreateZipArchive();
        EntryTempBlob.CreateInStream(EntryInStream);
        CompressionManagement.AddEntry(EntryInStream, 'some/directory/test.txt');
        ArchiveTempBlob.CreateOutStream(ArchiveOutStream);
        CompressionManagement.SaveZipArchiveToOutStream(ArchiveOutStream);
        CompressionManagement.CloseZipArchive();
        ArchiveTempBlob.CreateInStream(ArchiveInStream);

        // assert that you can successfuly construct a ZipArchive out of the saved InStream
        CompressionManagementLocal.OpenZipArchive(ArchiveInStream, false);

        // Clean up
        Clear(CompressionManagement);
    end;


    [Test]
    [Scope('OnPrem')]
    procedure TestCloseArchive()
    var
        EntryTempBlob: Codeunit "Temp Blob";
        EntryInStream: InStream;
        EntryList: List of [Text];
    begin
        Clear(CompressionManagement);
        CompressionManagement.CreateZipArchive();
        EntryTempBlob.CreateInStream(EntryInStream);
        CompressionManagement.AddEntry(EntryInStream, 'some/directory/test.txt');
        CompressionManagement.CloseZipArchive();

        // assert that you cannot get an entry list because the archive has been disposed
        asserterror CompressionManagement.GetEntryList(EntryList);

        // Clean up
        Clear(CompressionManagement);
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
        Clear(CompressionManagement);
        EntryTempBlob.CreateInStream(EntryInStream);

        // Exercise: Try to add a file to an uninitialized ZIP archive
        asserterror CompressionManagement.AddEntry(EntryInStream, 'some/directory/test.txt');
        Assert.ExpectedErrorCode(DotNetVariableNotCreatedErr);

        // Clean up
        Clear(EntryTempBlob);
        Clear(CompressionManagement);
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
        FileContent: array[2] of Text[64];
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
        CompressionManagement.CreateZipArchive();

        // [WHEN] add the streams to zip stream
        for Index := 1 to ArrayLen(FilePath) do begin
            TempBlob.CreateOutStream(OutStream);
            OutStream.WriteText(FileContent[Index]);
            TempBlob.CreateInStream(InStream);
            CompressionManagement.AddEntry(InStream, FilePath[Index]);
        end;
        CompressionManagement.SaveZipArchiveToOutStream(ZipStream);
        CompressionManagement.CloseZipArchive();
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
        Clear(CompressionManagement);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetEntryList()
    var
        TempBlob: Codeunit "Temp Blob";
        CompressionManagementLocal: Codeunit "Compression Management";
        EntryList: List of [Text];
        ZipArchiveLocal: DotNet ZipArchive;
        ZipArchiveEntry: DotNet ZipArchiveEntry;
        StreamReader: DotNet StreamReader;
        ZipArchiveMode: DotNet ZipArchiveMode;
        InStream: InStream;
        OutStream: OutStream;
        FilePath: array[2] of Text;
        FileContent: array[2] of Text[64];
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
        CompressionManagement.CreateZipArchive();

        // [WHEN] add the streams to zip stream
        for Index := 1 to ArrayLen(FilePath) do begin
            TempBlob.CreateOutStream(OutStream);
            OutStream.WriteText(FileContent[Index]);
            TempBlob.CreateInStream(InStream);
            CompressionManagement.AddEntry(InStream, FilePath[Index]);
        end;

        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStream);
        CompressionManagement.SaveZipArchiveToOutStream(OutStream);
        CompressionManagement.CloseZipArchive();
        TempBlob.CreateInStream(InStream);

        // [THEN] verify that GetEntryList returns the list of entries
        CompressionManagementLocal.OpenZipArchive(InStream, false);
        CompressionManagementLocal.GetEntryList(EntryList);
        Index := 1;
        foreach EntryKey in EntryList do begin
            Assert.AreEqual(FilePath[Index], EntryKey, '');
            Index += 1;
        end;

        // Clean up
        Clear(CompressionManagement);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestExtractEntry()
    var
        TempBlob: Codeunit "Temp Blob";
        CompressionManagementLocal: Codeunit "Compression Management";
        ZipArchiveLocal: DotNet ZipArchive;
        ZipArchiveEntry: DotNet ZipArchiveEntry;
        StreamReader: DotNet StreamReader;
        ZipArchiveMode: DotNet ZipArchiveMode;
        EntryList: List of [Text];
        InStream: InStream;
        OutStream: OutStream;
        FilePath: array[2] of Text;
        FileContent: array[2] of Text[64];
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
        CompressionManagement.CreateZipArchive();

        // [WHEN] add the streams to zip stream
        for Index := 1 to ArrayLen(FilePath) do begin
            TempBlob.CreateOutStream(OutStream);
            OutStream.WriteText(FileContent[Index]);
            TempBlob.CreateInStream(InStream);
            CompressionManagement.AddEntry(InStream, FilePath[Index]);
        end;

        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStream);
        CompressionManagement.SaveZipArchiveToOutStream(OutStream);
        CompressionManagement.CloseZipArchive();
        TempBlob.CreateInStream(InStream);

        // [THEN] verify that ExtractEntry extracts the entry correctly
        CompressionManagementLocal.OpenZipArchive(InStream, false);
        CompressionManagementLocal.GetEntryList(EntryList);
        Index := 1;
        foreach EntryKey in EntryList do begin
            Clear(TempBlob);
            TempBlob.CreateOutStream(OutStream);
            CompressionManagementLocal.ExtractEntry(EntryKey, OutStream, EntryLength);
            TempBlob.CreateInStream(InStream);
            InStream.ReadText(FileText);
            Assert.AreEqual(FileContent[Index], FileText, 'wrong content extracted');
            Assert.AreEqual(StrLen(FileContent[Index]), EntryLength, 'wrong entry length extracted');
            Index += 1;
        end;

        // Clean up
        Clear(CompressionManagement);
    end;
}

