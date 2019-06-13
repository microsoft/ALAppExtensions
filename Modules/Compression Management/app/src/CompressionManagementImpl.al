// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 421 "Compression Management Impl."
{

    trigger OnRun()
    begin
    end;

    var
        TempBlobZip: Codeunit "Temp Blob";
        ZipArchive: DotNet ZipArchive;
        ZipArchiveMode: DotNet ZipArchiveMode;

    [Scope('OnPrem')]
    procedure CreateZipArchive()
    var
        OutputStream: OutStream;
    begin
        Clear(TempBlobZip);
        TempBlobZip.CreateOutStream(OutputStream);
        ZipArchive := ZipArchive.ZipArchive(OutputStream, ZipArchiveMode.Create);
    end;

    [Scope('OnPrem')]
    procedure OpenZipArchive(InputStream: InStream; ZipArchiveModeIsUpdate: Boolean)
    var
        OutputStream: OutStream;
    begin
        Clear(TempBlobZip);
        TempBlobZip.CreateOutStream(OutputStream);
        CopyStream(OutputStream, InputStream);

        if ZipArchiveModeIsUpdate then
            ZipArchive := ZipArchive.ZipArchive(OutputStream, ZipArchiveMode.Update)
        else
            ZipArchive := ZipArchive.ZipArchive(OutputStream, ZipArchiveMode.Read);
    end;

    [Scope('OnPrem')]
    procedure SaveZipArchiveToOutStream(OutputStream: OutStream)
    var
        InputStream: InStream;
    begin
        ZipArchive.Dispose();
        TempBlobZip.CreateInStream(InputStream);
        CopyStream(OutputStream, InputStream);
        Clear(TempBlobZip);
    end;

    [Scope('OnPrem')]
    procedure CloseZipArchive()
    begin
        if not IsNull(ZipArchive) then
            ZipArchive.Dispose();
    end;

    [Scope('OnPrem')]
    procedure IsGZip(InStream: InStream): Boolean
    var
        ID: array[2] of Byte;
    begin
        InStream.Read(ID[1]);
        InStream.Read(ID[2]);

        // from GZIP file format specification version 4.3
        // Member header and trailer
        // ID1 (IDentification 1)
        // ID2 (IDentification 2)
        // These have the fixed values ID1 = 31 (0x1f, \037), ID2 = 139 (0x8b, \213), to identify the file as being in gzip format.

        exit((ID[1] = 31) and (ID[2] = 139));
    end;

    [Scope('OnPrem')]
    procedure GetEntryList(var EntryList: List of [Text])
    var
        ZipArchiveEntry: DotNet ZipArchiveEntry;
        EntryName: Text;
        EntryFullName: Text;
    begin
        foreach ZipArchiveEntry in ZipArchive.Entries() do begin
            EntryFullName := ZipArchiveEntry.FullName();
            EntryList.Add(EntryFullName);
        end;
    end;

    [Scope('OnPrem')]
    procedure ExtractEntry(EntryName: Text; OutputStream: OutStream; var EntryLength: Integer)
    var
        ZipArchiveEntry: DotNet ZipArchiveEntry;
        ZipArchiveEntryStream: DotNet Stream;
    begin
        ZipArchiveEntry := ZipArchive.GetEntry(EntryName);
        ZipArchiveEntryStream := ZipArchiveEntry.Open();
        ZipArchiveEntryStream.CopyTo(OutputStream);
        EntryLength := ZipArchiveEntry.Length();
        ZipArchiveEntryStream.Close();
    end;

    [Scope('OnPrem')]
    procedure AddEntry(StreamToAdd: InStream; PathInArchive: Text)
    var
        ZipArchiveEntry: DotNet ZipArchiveEntry;
    begin
        ZipArchiveEntry := ZipArchive.CreateEntry(PathInArchive);
        CopyStream(ZipArchiveEntry.Open(), StreamToAdd);
    end;
}

