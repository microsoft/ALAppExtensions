// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 425 "Compression Management"
{

    trigger OnRun()
    begin
    end;

    var
        CompressionManagementImpl: Codeunit "Compression Management Impl.";

    /// <summary>
    /// Creates a new ZipArchive instance.
    /// </summary>
    procedure CreateZipArchive()
    begin
        CompressionManagementImpl.CreateZipArchive();
    end;

    /// <summary>
    /// Creates a ZipArchive instance from the given InStream.
    /// </summary>
    /// <param name="InputStream">The InStream that contains the content of the compressed archive.</param>
    /// <param name="ZipArchiveModeIsUpdate">Indicates whether the archive should be open in Update or Read mode.</param>
    procedure OpenZipArchive(InputStream: InStream; ZipArchiveModeIsUpdate: Boolean)
    begin
        CompressionManagementImpl.OpenZipArchive(InputStream, ZipArchiveModeIsUpdate);
    end;

    /// <summary>
    /// Saves the ZipArchive to the given OutStream.
    /// </summary>
    /// <param name="OutputStream">The OutStream to which the ZipArchive is saved.</param>
    procedure SaveZipArchiveToOutStream(OutputStream: OutStream)
    begin
        CompressionManagementImpl.SaveZipArchiveToOutStream(OutputStream);
    end;

    /// <summary>
    /// Disposes the ZipArchive.
    /// </summary>
    procedure CloseZipArchive()
    begin
        CompressionManagementImpl.CloseZipArchive();
    end;

    /// <summary>
    /// Returns true if and only if the given InStream contains a GZip archive.
    /// </summary>
    /// <param name="InStream">The InStream that contains binary content.</param>
    [Scope('OnPrem')]
    procedure IsGZip(InStream: InStream): Boolean
    begin
        EXIT(CompressionManagementImpl.IsGZip(InStream));
    end;

    /// <summary>
    /// Returns the list of entries for the ZipArchive.
    /// </summary>
    /// <param name="EntryList">The list that is populated with the list of entries of the ZipArchive instance.</param>
    procedure GetEntryList(var EntryList: List of [Text])
    begin
        CompressionManagementImpl.GetEntryList(EntryList);
    end;

    /// <summary>
    /// Extracts an entry from the ZipArchive.
    /// </summary>
    /// <param name="EntryName">The name of the ZipArchive entry to be extracted.</param>
    /// <param name="OutputStream">The OutStream to which binary content of the extracted entry is saved.</param>
    /// <param name="EntryLength">The length of the extracted entry.</param>
    procedure ExtractEntry(EntryName: Text; OutputStream: OutStream; var EntryLength: Integer)
    begin
        CompressionManagementImpl.ExtractEntry(EntryName, OutputStream, EntryLength);
    end;

    /// <summary>
    /// Adds an entry to the ZipArchive.
    /// </summary>
    /// <param name="StreamToAdd">The InStream that contains the binary content that should be added as an entry in the ZipArchive.</param>
    /// <param name="PathInArchive">The path that the added entry should have within the ZipArchive.</param>
    procedure AddEntry(StreamToAdd: InStream; PathInArchive: Text)
    begin
        CompressionManagementImpl.AddEntry(StreamToAdd, PathInArchive);
    end;
}

