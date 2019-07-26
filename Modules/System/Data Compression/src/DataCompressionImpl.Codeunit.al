// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 421 "Data Compression Impl."
{
    Access = Internal;

    var
        TempBlobZip: Codeunit "Temp Blob";
        ZipArchive: DotNet ZipArchive;
        ZipArchiveMode: DotNet ZipArchiveMode;

    procedure CreateZipArchive()
    var
        OutputStream: OutStream;
    begin
        Clear(TempBlobZip);
        TempBlobZip.CreateOutStream(OutputStream);
        ZipArchive := ZipArchive.ZipArchive(OutputStream, ZipArchiveMode.Create);
    end;

    procedure OpenZipArchive(InputStream: InStream; OpenForUpdate: Boolean)
    var
        DefaultEncoding: DotNet Encoding;
    begin
        DefaultEncoding := DefaultEncoding.Default();
        OpenZipArchive(InputStream, OpenForUpdate, DefaultEncoding.CodePage());
    end;

    procedure OpenZipArchive(InputStream: InStream; OpenForUpdate: Boolean; EncodingCodePageNumber: Integer)
    var
        Encoding: DotNet Encoding;
        Mode: DotNet ZipArchiveMode;
        OutputStream: OutStream;
    begin
        Encoding := Encoding.GetEncoding(EncodingCodePageNumber);
        Clear(TempBlobZip);
        TempBlobZip.CreateOutStream(OutputStream);
        CopyStream(OutputStream, InputStream);

        if (OpenForUpdate) then
            Mode := ZipArchiveMode.Update
        else
            Mode := ZipArchiveMode.Read;

        ZipArchive := ZipArchive.ZipArchive(OutputStream, Mode, false, Encoding)
    end;

    procedure OpenZipArchive(TempBlob: Codeunit "Temp Blob"; OpenForUpdate: Boolean)
    var
        InputStream: InStream;
    begin
        TempBlob.CreateInStream(InputStream);
        OpenZipArchive(InputStream, OpenForUpdate);
    end;

    procedure SaveZipArchive(OutputStream: OutStream)
    var
        InputStream: InStream;
    begin
        ZipArchive.Dispose();
        TempBlobZip.CreateInStream(InputStream);
        CopyStream(OutputStream, InputStream);
        Clear(TempBlobZip);
    end;

    procedure SaveZipArchive(var TempBlob: Codeunit "Temp Blob")
    var
        OutputStream: OutStream;
    begin
        Clear(TempBlob);
        TempBlob.CreateOutStream(OutputStream);
        SaveZipArchive(OutputStream);
    end;

    procedure CloseZipArchive()
    begin
        if not IsNull(ZipArchive) then
            ZipArchive.Dispose();
    end;

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

    procedure GetEntryList(var EntryList: List of [Text])
    var
        ZipArchiveEntry: DotNet ZipArchiveEntry;
        EntryFullName: Text;
    begin
        foreach ZipArchiveEntry in ZipArchive.Entries() do begin
            EntryFullName := ZipArchiveEntry.FullName();
            EntryList.Add(EntryFullName);
        end;
    end;

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

    procedure AddEntry(StreamToAdd: InStream; PathInArchive: Text)
    var
        ZipArchiveEntry: DotNet ZipArchiveEntry;
    begin
        ZipArchiveEntry := ZipArchive.CreateEntry(PathInArchive);
        CopyStream(ZipArchiveEntry.Open(), StreamToAdd);
    end;
}

