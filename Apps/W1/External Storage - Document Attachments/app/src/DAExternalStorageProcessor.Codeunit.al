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
}
