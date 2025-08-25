// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality to manage document attachments in external storage systems.
/// Handles upload, download, and deletion operations for Business Central attachments.
/// </summary>
codeunit 8750 "DA External Storage Processor"
{
    Access = Internal;
    Permissions = tabledata "Tenant Media" = rimd;

    /// <summary>
    /// Uploads a document attachment to external storage.
    /// </summary>
    /// <param name="DocumentAttachment">The document attachment record to upload.</param>
    /// <returns>True if upload was successful, false otherwise.</returns>
    internal procedure UploadToExternalStorage(var DocumentAttachment: Record "Document Attachment"): Boolean
    var
        FileAccount: Record "File Account";
        TenantMedia: Record "Tenant Media";
        ExternalFileStorage: Codeunit "External File Storage";
        FileScenarioCU: Codeunit "File Scenario";
        TempBlob: Codeunit "Temp Blob";
        FileScenario: Enum "File Scenario";
        InStream: InStream;
        OutStream: OutStream;
        FileName: Text;
    begin
        // Validate input parameters
        if not DocumentAttachment."Document Reference ID".HasValue() then
            exit(false);

        // Check if document is already uploaded
        if DocumentAttachment."External File Path" <> '' then
            exit(false);

        // Get file content from document attachment
        TempBlob.CreateOutStream(OutStream);
        DocumentAttachment.ExportToStream(OutStream);
        TempBlob.CreateInStream(InStream);

        // Generate unique filename to prevent collisions
        FileName := DocumentAttachment."File Name" + '-' + Format(CreateGuid()) + '.' + DocumentAttachment."File Extension";

        // Search for External Storage assigned File Scenario
        FileScenario := FileScenario::"Doc. Attach. - External Storage";
        if not FileScenarioCU.GetFileAccount(FileScenario, FileAccount) then
            exit(false);

        // Create the file with connector using the File Account framework
        ExternalFileStorage.Initialize(FileScenario);
        if ExternalFileStorage.CreateFile(FileName, InStream) then begin
            DocumentAttachment.MarkAsUploadedToExternal(FileName);
            exit(true);
        end;

        exit(false);
    end;

    /// <summary>
    /// Downloads a document attachment from external storage and prompts user to save it locally.
    /// </summary>
    /// <param name="DocumentAttachment">The document attachment record to download.</param>
    /// <returns>True if download was successful, false otherwise.</returns>
    internal procedure DownloadFromExternalStorage(var DocumentAttachment: Record "Document Attachment"): Boolean
    var
        FileAccount: Record "File Account";
        ExternalFileStorage: Codeunit "External File Storage";
        FileScenarioCU: Codeunit "File Scenario";
        FileScenario: Enum "File Scenario";
        InStream: InStream;
        ExternalFilePath, FileName : Text;
    begin
        // Validate input parameters
        if DocumentAttachment."External File Path" = '' then
            exit(false);

        if not DocumentAttachment."Uploaded Externally" then
            exit(false);

        // Use the stored external file path
        ExternalFilePath := DocumentAttachment."External File Path";
        FileName := DocumentAttachment."File Name" + '.' + DocumentAttachment."File Extension";

        // Search for External Storage assigned File Scenario
        FileScenario := FileScenario::"Doc. Attach. - External Storage";
        if not FileScenarioCU.GetFileAccount(FileScenario, FileAccount) then
            exit(false);

        // Get the file with connector using the File Account framework
        ExternalFileStorage.Initialize(FileScenario);
        ExternalFileStorage.GetFile(ExternalFilePath, InStream);

        exit(DownloadFromStream(InStream, '', '', '', FileName));
    end;

    /// <summary>
    /// Downloads a document attachment from external storage and saves it to internal storage.
    /// </summary>
    /// <param name="DocumentAttachment">The document attachment record to download and restore internally.</param>
    /// <returns>True if download and import was successful, false otherwise.</returns>
    internal procedure DownloadFromExternalStorageToInternal(var DocumentAttachment: Record "Document Attachment"): Boolean
    var
        FileAccount: Record "File Account";
        ExternalFileStorage: Codeunit "External File Storage";
        FileScenarioCU: Codeunit "File Scenario";
        TempBlob: Codeunit "Temp Blob";
        FileScenario: Enum "File Scenario";
        InStream: InStream;
        OutStream: OutStream;
        ExternalFilePath, FileName : Text;
    begin
        // Validate input parameters
        if DocumentAttachment."External File Path" = '' then
            exit(false);

        if not DocumentAttachment."Uploaded Externally" then
            exit(false);

        // Use the stored external file path
        ExternalFilePath := DocumentAttachment."External File Path";
        FileName := DocumentAttachment."File Name" + '.' + DocumentAttachment."File Extension";

        // Search for External Storage assigned File Scenario
        FileScenario := FileScenario::"Doc. Attach. - External Storage";
        if not FileScenarioCU.GetFileAccount(FileScenario, FileAccount) then
            exit(false);

        // Get the file with connector using the File Account framework
        ExternalFileStorage.Initialize(FileScenario);
        ExternalFileStorage.GetFile(ExternalFilePath, InStream);

        // Import the file into the Document Attachment
        DocumentAttachment.ImportAttachment(InStream, FileName);
        DocumentAttachment."Deleted Internally" := false;
        DocumentAttachment.Modify();

        exit(true);
    end;

    /// <summary>
    /// Downloads and previews a document attachment from external storage.
    /// </summary>
    /// <param name="DocumentAttachment">The document attachment record to preview.</param>
    /// <returns>True if preview was successful, false otherwise.</returns>
    internal procedure DownloadFromExternalStorageAndPreview(var DocumentAttachment: Record "Document Attachment"): Boolean
    var
        FileAccount: Record "File Account";
        ExternalFileStorage: Codeunit "External File Storage";
        FileScenarioCU: Codeunit "File Scenario";
        FileScenario: Enum "File Scenario";
        InStream: InStream;
        ExternalFilePath, FileName : Text;
    begin
        // Validate input parameters
        if DocumentAttachment."External File Path" = '' then
            exit(false);

        if not DocumentAttachment."Uploaded Externally" then
            exit(false);

        // Use the stored external file path
        ExternalFilePath := DocumentAttachment."External File Path";
        FileName := DocumentAttachment."File Name" + '.' + DocumentAttachment."File Extension";

        // Search for External Storage assigned File Scenario
        FileScenario := FileScenario::"Doc. Attach. - External Storage";
        if not FileScenarioCU.GetFileAccount(FileScenario, FileAccount) then
            exit(false);

        // Get the file with connector using the File Account framework
        ExternalFileStorage.Initialize(FileScenario);
        ExternalFileStorage.GetFile(ExternalFilePath, InStream);

        // Preview the file
        File.ViewFromStream(InStream, FileName, true);
        exit(true);
    end;

    /// <summary>
    /// Downloads a document attachment from external storage to a stream.
    /// </summary>
    /// <param name="ExternalFilePath">The path of the external file to download.</param>
    /// <param name="AttachmentOutStream">The output stream to write the attachment to.</param>
    /// <returns>True if the download was successful, false otherwise.</returns>
    internal procedure DownloadFromExternalStorageToStream(ExternalFilePath: Text; var AttachmentOutStream: OutStream): Boolean
    var
        FileAccount: Record "File Account";
        ExternalFileStorage: Codeunit "External File Storage";
        FileScenarioCU: Codeunit "File Scenario";
        FileScenario: Enum "File Scenario";
        InStream: InStream;
    begin
        // Search for External Storage assigned File Scenario
        FileScenario := FileScenario::"Doc. Attach. - External Storage";
        if not FileScenarioCU.GetFileAccount(FileScenario, FileAccount) then
            exit(false);

        // Get the file from external storage
        ExternalFileStorage.Initialize(FileScenario);
        if not ExternalFileStorage.GetFile(ExternalFilePath, InStream) then
            exit(false);

        // Copy to output stream
        CopyStream(AttachmentOutStream, InStream);
        exit(true);
    end;

    /// <summary>
    /// Downloads a document attachment from external storage to a temporary blob.
    /// </summary>
    /// <param name="ExternalFilePath">The path of the external file to download.</param>
    /// <param name="TempBlob">The temporary blob to store the downloaded content.</param>
    internal procedure DownloadFromExternalStorageToTempBlob(ExternalFilePath: Text; var TempBlob: Codeunit "Temp Blob"): Boolean
    var
        FileAccount: Record "File Account";
        ExternalFileStorage: Codeunit "External File Storage";
        FileScenarioCU: Codeunit "File Scenario";
        FileScenario: Enum "File Scenario";
        InStream: InStream;
        OutStream: OutStream;
    begin
        // Search for External Storage assigned File Scenario
        FileScenario := FileScenario::"Doc. Attach. - External Storage";
        if not FileScenarioCU.GetFileAccount(FileScenario, FileAccount) then
            exit(false);

        // Get the file from external storage
        ExternalFileStorage.Initialize(FileScenario);
        if not ExternalFileStorage.GetFile(ExternalFilePath, InStream) then
            exit(false);

        // Copy to TempBlob
        TempBlob.CreateOutStream(OutStream);
        CopyStream(OutStream, InStream);
        exit(true);
    end;

    /// <summary>
    /// Checks if a file exists in external storage.
    /// </summary>
    /// <param name="ExternalFilePath">The path of the external file to check.</param>
    /// <returns>True if the file exists, false otherwise.</returns>
    internal procedure CheckIfFileExistInExternalStorage(ExternalFilePath: Text): Boolean
    var
        FileAccount: Record "File Account";
        ExternalFileStorage: Codeunit "External File Storage";
        FileScenarioCU: Codeunit "File Scenario";
        FileScenario: Enum "File Scenario";
        InStream: InStream;
    begin
        // Search for External Storage assigned File Scenario
        FileScenario := FileScenario::"Doc. Attach. - External Storage";
        if not FileScenarioCU.GetFileAccount(FileScenario, FileAccount) then
            exit(false);

        // Get the file from external storage
        ExternalFileStorage.Initialize(FileScenario);
        exit(ExternalFileStorage.FileExists(ExternalFilePath));
    end;

    /// <summary>
    /// Deletes a document attachment from external storage.
    /// </summary>
    /// <param name="DocumentAttachment">The document attachment record to delete from external storage.</param>
    /// <returns>True if deletion was successful, false otherwise.</returns>
    internal procedure DeleteFromExternalStorage(var DocumentAttachment: Record "Document Attachment"): Boolean
    var
        FileAccount: Record "File Account";
        ExternalFileStorage: Codeunit "External File Storage";
        FileScenarioCU: Codeunit "File Scenario";
        FileScenario: Enum "File Scenario";
        ExternalFilePath: Text;
    begin
        // Validate input parameters
        if DocumentAttachment."External File Path" = '' then
            exit(false);

        if not DocumentAttachment."Uploaded Externally" then
            exit(false);

        // Use the stored external file path
        ExternalFilePath := DocumentAttachment."External File Path";

        // Search for External Storage assigned File Scenario
        FileScenario := FileScenario::"Doc. Attach. - External Storage";
        if not FileScenarioCU.GetFileAccount(FileScenario, FileAccount) then
            exit(false);

        // Delete the file with connector using the File Account framework
        ExternalFileStorage.Initialize(FileScenario);
        if ExternalFileStorage.DeleteFile(ExternalFilePath) then begin
            DocumentAttachment.MarkAsNotUploadedToExternal();
            exit(true);
        end;

        exit(false);
    end;

    /// <summary>
    /// Deletes a document attachment from internal storage.
    /// </summary>
    /// <param name="DocumentAttachment">The document attachment record to delete from internal storage.</param>
    /// <returns>True if deletion was successful, false otherwise.</returns>
    internal procedure DeleteFromInternalStorage(var DocumentAttachment: Record "Document Attachment"): Boolean
    var
        TenantMedia: Record "Tenant Media";
    begin
        // Validate input parameters
        if not DocumentAttachment."Document Reference ID".HasValue() then
            exit(false);

        // Check if file is uploaded externally before deleting internally
        if not DocumentAttachment."Uploaded Externally" then
            exit(false);

        // Delete from Tenant Media
        if TenantMedia.Get(DocumentAttachment."Document Reference ID".MediaId) then begin
            TenantMedia.Delete();

            // Mark Document Attachment as Deleted Internally
            DocumentAttachment.MarkAsDeletedInternally();
            exit(true);
        end;

        exit(false);
    end;

    /// <summary>
    /// Determines if files should be deleted immediately based on external storage setup.
    /// </summary>
    /// <returns>True if files should be deleted immediately, false otherwise.</returns>
    internal procedure ShouldBeDeleted(): Boolean
    var
        ExternalStorageSetup: Record "DA External Storage Setup";
    begin
        if not ExternalStorageSetup.Get() then
            exit(false);

        exit(ExternalStorageSetup."Delete After" = ExternalStorageSetup."Delete After"::Immediately);
    end;

    /// <summary>
    /// Maps file extensions to their corresponding MIME types.
    /// </summary>
    /// <param name="Rec">The document attachment record.</param>
    /// <param name="ContentType">The content type to set based on the file extension.</param>
    internal procedure FileExtensionToContentMimeType(var Rec: Record "Document Attachment"; var ContentType: Text[100])
    begin
        // Determine content type based on file extension
        case LowerCase(Rec."File Extension") of
            'pdf':
                ContentType := 'application/pdf';
            'jpg', 'jpeg':
                ContentType := 'image/jpeg';
            'png':
                ContentType := 'image/png';
            'gif':
                ContentType := 'image/gif';
            'bmp':
                ContentType := 'image/bmp';
            'tiff', 'tif':
                ContentType := 'image/tiff';
            'doc':
                ContentType := 'application/msword';
            'docx':
                ContentType := 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
            'xls':
                ContentType := 'application/vnd.ms-excel';
            'xlsx':
                ContentType := 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
            'ppt':
                ContentType := 'application/vnd.ms-powerpoint';
            'pptx':
                ContentType := 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
            'txt':
                ContentType := 'text/plain';
            'xml':
                ContentType := 'text/xml';
            'html', 'htm':
                ContentType := 'text/html';
            'zip':
                ContentType := 'application/zip';
            'rar':
                ContentType := 'application/x-rar-compressed';
            else
                ContentType := 'application/octet-stream';
        end;
    end;

    /// <summary>
    /// Checks if a Document Attachment file is uploaded to external storage and deleted internally.
    /// </summary>
    /// <param name="DocumentAttachment">The Document Attachment record to check.</param>
    /// <returns>True if the file is uploaded and deleted, false otherwise.</returns>
    procedure IsFileUploadedToExternalStorageAndDeletedInternally(var DocumentAttachment: Record "Document Attachment"): Boolean
    begin
        if not DocumentAttachment."Deleted Internally" then
            exit(false);

        if not DocumentAttachment."Uploaded Externally" then
            exit(false);

        if DocumentAttachment."Document Reference ID".HasValue() then
            exit(false);

        if DocumentAttachment."External File Path" = '' then
            exit(false);
        exit(true);
    end;
}
