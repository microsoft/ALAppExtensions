// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to provide ability to create, update, read and dispose a binary data compression archive.
/// This module supports compression and decompression with Zip format and GZip format.
/// </summary>
codeunit 425 "Data Compression"
{
    Access = Public;

    var
        DataCompressionImpl: Codeunit "Data Compression Impl.";

    /// <summary>
    /// Creates a new ZipArchive instance.
    /// </summary>
    procedure CreateZipArchive()
    begin
        DataCompressionImpl.CreateZipArchive();
    end;

    /// <summary>
    /// Creates a ZipArchive instance from the given InStream.
    /// </summary>
    /// <param name="InputStream">The InStream that contains the content of the compressed archive.</param>
    /// <param name="OpenForUpdate">Indicates whether the archive should be opened in Update mode. The default (false) indicated the archive will be opened in Read mode.</param>
    procedure OpenZipArchive(InputStream: InStream; OpenForUpdate: Boolean)
    begin
        DataCompressionImpl.OpenZipArchive(InputStream, OpenForUpdate);
    end;

    /// <summary>
    /// Creates a ZipArchive instance from the given InStream.
    /// </summary>
    /// <param name="InputStream">The InStream that contains the content of the compressed archive.</param>
    /// <param name="OpenForUpdate">Indicates whether the archive should be opened in Update mode. The default (false) indicated the archive will be opened in Read mode.</param>
    /// <param name="EncodingCodePageNumber">Specifies the code page number of the text encoding which is used for the compressed archive entry names in the input stream.</param>
    procedure OpenZipArchive(InputStream: InStream; OpenForUpdate: Boolean; EncodingCodePageNumber: Integer)
    begin
        DataCompressionImpl.OpenZipArchive(InputStream, OpenForUpdate, EncodingCodePageNumber);
    end;

    /// <summary>
    /// Creates a ZipArchive instance from the given instance of Temp Blob codeunit.
    /// </summary>
    /// <param name="TempBlob">The instance of Temp Blob codeunit that contains the content of the compressed archive.</param>
    /// <param name="OpenForUpdate">Indicates whether the archive should be opened in Update mode. The default (false) indicated the archive will be opened in Read mode.</param>
    procedure OpenZipArchive(TempBlob: Codeunit "Temp Blob"; OpenForUpdate: Boolean)
    begin
        DataCompressionImpl.OpenZipArchive(TempBlob, OpenForUpdate);
    end;

    /// <summary>
    /// Saves the ZipArchive to the given OutStream.
    /// </summary>
    /// <param name="OutputStream">The OutStream to which the ZipArchive is saved.</param>
    procedure SaveZipArchive(OutputStream: OutStream)
    begin
        DataCompressionImpl.SaveZipArchive(OutputStream);
    end;

    /// <summary>
    /// Saves the ZipArchive to the given instance of Temp Blob codeunit.
    /// </summary>
    /// <param name="TempBlob">The instance of the Temp Blob codeunit to which the ZipArchive is saved.</param>
    procedure SaveZipArchive(var TempBlob: Codeunit "Temp Blob")
    begin
        DataCompressionImpl.SaveZipArchive(TempBlob);
    end;

    /// <summary>
    /// Disposes the ZipArchive.
    /// </summary>
    procedure CloseZipArchive()
    begin
        DataCompressionImpl.CloseZipArchive();
    end;

    /// <summary>
    /// Returns the list of entries for the ZipArchive.
    /// </summary>
    /// <param name="EntryList">The list that is populated with the list of entries of the ZipArchive instance.</param>
    procedure GetEntryList(var EntryList: List of [Text])
    begin
        DataCompressionImpl.GetEntryList(EntryList);
    end;

    /// <summary>
    /// Extracts an entry from the ZipArchive.
    /// </summary>
    /// <param name="EntryName">The name of the ZipArchive entry to be extracted.</param>
    /// <param name="OutputStream">The OutStream to which binary content of the extracted entry is saved.</param>
    /// <param name="EntryLength">The length of the extracted entry.</param>
    procedure ExtractEntry(EntryName: Text; OutputStream: OutStream; var EntryLength: Integer)
    begin
        DataCompressionImpl.ExtractEntry(EntryName, OutputStream, EntryLength);
    end;

    /// <summary>
    /// Adds an entry to the ZipArchive.
    /// </summary>
    /// <param name="StreamToAdd">The InStream that contains the binary content that should be added as an entry in the ZipArchive.</param>
    /// <param name="PathInArchive">The path that the added entry should have within the ZipArchive.</param>
    procedure AddEntry(StreamToAdd: InStream; PathInArchive: Text)
    begin
        DataCompressionImpl.AddEntry(StreamToAdd, PathInArchive);
    end;


    /// <summary>
    /// Determines whether the given InStream is compressed with GZip.
    /// </summary>
    /// <param name="InStream">An InStream that contains binary content.</param>
    /// <returns>Returns true if and only if the given InStream is compressed with GZip</returns>
    procedure IsGZip(InStream: InStream): Boolean
    begin
        EXIT(DataCompressionImpl.IsGZip(InStream));
    end;

    /// <summary>
    /// Compresses a stream with GZip algorithm.
    /// <param name="InputStream">The InStream that contains the content that should be compressed.</param>
    /// <param name="CompressedStream">The OutStream into which the compressed stream is copied to.</param>
    /// </summary>
    procedure GZipCompress(InputStream: InStream; CompressedStream: OutStream)
    begin
        DataCompressionImpl.GZipCompress(InputStream, CompressedStream);
    end;

    /// <summary>
    /// Decompresses a GZipStream.
    /// <param name="InputStream">The InStream that contains the content that should be decompressed.</param>
    /// <param name="DecompressedStream">The OutStream into which the decompressed stream is copied to.</param>
    /// </summary>
    procedure GZipDecompress(InputStream: InStream; DecompressedStream: OutStream)
    begin
        DataCompressionImpl.GZipDecompress(InputStream, DecompressedStream);
    end;
}

