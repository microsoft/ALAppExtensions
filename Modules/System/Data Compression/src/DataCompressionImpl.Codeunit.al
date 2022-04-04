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
        GZipStream: DotNet GZipStream;

    procedure CreateZipArchive()
    var
        OutputOutStream: OutStream;
    begin
        Clear(TempBlobZip);
        TempBlobZip.CreateOutStream(OutputOutStream);
        ZipArchive := ZipArchive.ZipArchive(OutputOutStream, ZipArchiveMode.Create);
    end;

    procedure GZipCompress(InputInStream: InStream; CompressedOutStream: OutStream)
    var
        DotNetCompressionMode: DotNet CompressionMode;
    begin
        GZipStream := GZipStream.GZipStream(CompressedOutStream, DotNetCompressionMode::Compress);
        CopyStream(GZipStream, InputInStream);
        GZipStream.Dispose();
    end;

    procedure GZipDecompress(InputInStream: InStream; DecompressedOutStream: OutStream)
    var
        DotNetCompressionMode: DotNet CompressionMode;
    begin
        GZipStream := GZipStream.GZipStream(InputInStream, DotNetCompressionMode::Decompress);
        GZipStream.CopyTo(DecompressedOutStream);
        GZipStream.Dispose();
    end;

    procedure OpenZipArchive(InputInStream: InStream; OpenForUpdate: Boolean)
    var
        DefaultEncoding: DotNet Encoding;
    begin
        DefaultEncoding := DefaultEncoding.Default();
        OpenZipArchive(InputInStream, OpenForUpdate, DefaultEncoding.CodePage());
    end;

    procedure OpenZipArchive(InputInStream: InStream; OpenForUpdate: Boolean; EncodingCodePageNumber: Integer)
    var
        Encoding: DotNet Encoding;
        Mode: DotNet ZipArchiveMode;
        OutputOutStream: OutStream;
    begin
        Encoding := Encoding.GetEncoding(EncodingCodePageNumber);
        Clear(TempBlobZip);
        TempBlobZip.CreateOutStream(OutputOutStream);
        CopyStream(OutputOutStream, InputInStream);

        if (OpenForUpdate) then
            Mode := ZipArchiveMode.Update
        else
            Mode := ZipArchiveMode.Read;

        ZipArchive := ZipArchive.ZipArchive(OutputOutStream, Mode, false, Encoding)
    end;

    procedure OpenZipArchive(TempBlob: Codeunit "Temp Blob"; OpenForUpdate: Boolean)
    var
        InputInStream: InStream;
    begin
        TempBlob.CreateInStream(InputInStream);
        OpenZipArchive(InputInStream, OpenForUpdate);
    end;

    procedure SaveZipArchive(OutputOutStream: OutStream)
    var
        InputInStream: InStream;
    begin
        if IsNull(ZipArchive) then
            exit;
        ZipArchive.Dispose();
        TempBlobZip.CreateInStream(InputInStream);
        CopyStream(OutputOutStream, InputInStream);
        Clear(TempBlobZip);
    end;

    procedure SaveZipArchive(var TempBlob: Codeunit "Temp Blob")
    var
        OutputOutStream: OutStream;
    begin
        if IsNull(ZipArchive) then
            exit;
        Clear(TempBlob);
        TempBlob.CreateOutStream(OutputOutStream);
        SaveZipArchive(OutputOutStream);
    end;

    procedure CloseZipArchive()
    begin
        if not IsNull(ZipArchive) then begin
            ZipArchive.Dispose();
            Clear(TempBlobZip);
        end;
    end;

    procedure IsGZip(InputInStream: InStream): Boolean
    var
        OriginalStream: DotNet Stream;
        ID: array[2] of Byte;
    begin
        OriginalStream := InputInStream;
        InputInStream.Read(ID[1]);
        InputInStream.Read(ID[2]);

        // from GZIP file format specification version 4.3
        // Member header and trailer
        // ID1 (IDentification 1)
        // ID2 (IDentification 2)
        // These have the fixed values ID1 = 31 (0x1f, \037), ID2 = 139 (0x8b, \213), to identify the file as being in gzip format.

        OriginalStream.Position := 0;
        InputInStream := OriginalStream;
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

    procedure ExtractEntry(EntryName: Text; OutputOutStream: OutStream; var EntryLength: Integer)
    var
        ZipArchiveEntry: DotNet ZipArchiveEntry;
        ZipArchiveEntryStream: DotNet Stream;
    begin
        ZipArchiveEntry := ZipArchive.GetEntry(EntryName);
        ZipArchiveEntryStream := ZipArchiveEntry.Open();
        ZipArchiveEntryStream.CopyTo(OutputOutStream);
        EntryLength := ZipArchiveEntry.Length();
        ZipArchiveEntryStream.Close();
    end;

    procedure AddEntry(InStreamToAdd: InStream; PathInArchive: Text)
    var
        ZipArchiveEntry: DotNet ZipArchiveEntry;
    begin
        ZipArchiveEntry := ZipArchive.CreateEntry(PathInArchive);
        CopyStream(ZipArchiveEntry.Open(), InStreamToAdd);
    end;
}

