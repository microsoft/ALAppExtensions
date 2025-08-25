// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Event subscribers for External Storage functionality.
/// Handles automatic upload of new attachments and cleanup operations.
/// </summary>
codeunit 8752 "DA External Storage Subs."
{
    Access = Internal;

    #region Document Attachment Handling
    /// <summary>
    /// Handles automatic upload of new document attachments to external storage.
    /// Triggers on insert of Document Attachment records.
    /// </summary>
    [EventSubscriber(ObjectType::Table, Database::"Document Attachment", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsertDocumentAttachment(var Rec: Record "Document Attachment"; RunTrigger: Boolean)
    var
        ExternalStorageSetup: Record "DA External Storage Setup";
        ExternalStorageProcessor: Codeunit "DA External Storage Processor";
    begin
        // Exit early if trigger is not running
        if not RunTrigger then
            exit;

        // Check if auto upload is enabled
        if not ExternalStorageSetup.Get() then
            exit;

        if not ExternalStorageSetup."Auto Upload" then
            exit;

        // Only process files with actual content
        if not Rec."Document Reference ID".HasValue then
            exit;

        // Upload to external storage
        if not ExternalStorageProcessor.UploadToExternalStorage(Rec) then
            exit;

        // Check if it should be immediately deleted
        if ExternalStorageProcessor.ShouldBeDeleted() then
            ExternalStorageProcessor.DeleteFromInternalStorage(Rec);
    end;

    /// <summary>
    /// Handles cleanup of external storage when document attachments are deleted.
    /// Triggers on delete of Document Attachment records.
    /// </summary>
    [EventSubscriber(ObjectType::Table, Database::"Document Attachment", 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDeleteDocumentAttachment(var Rec: Record "Document Attachment"; RunTrigger: Boolean)
    var
        ExternalStorageSetup: Record "DA External Storage Setup";
        ExternalStorageProcessor: Codeunit "DA External Storage Processor";
    begin
        // Exit early if trigger is not running
        if not RunTrigger then
            exit;

        // Check if auto upload is enabled
        if not ExternalStorageSetup.Get() then
            exit;

        if not ExternalStorageSetup."Auto Delete" then
            exit;

        // Only process files that were uploaded to external storage
        if not Rec."Uploaded Externally" then
            exit;

        // Delete from external storage
        ExternalStorageProcessor.DeleteFromExternalStorage(Rec);
    end;

    /// <summary>
    /// Handles export to stream for externally stored document attachments.
    /// Downloads from external storage when internal content is not available.
    /// </summary>
    [EventSubscriber(ObjectType::Table, Database::"Document Attachment", 'OnBeforeExportToStream', '', false, false)]
    local procedure DocumentAttachment_OnBeforeExportToStream(var DocumentAttachment: Record "Document Attachment"; var AttachmentOutStream: OutStream; var IsHandled: Boolean)
    var
        ExternalStorageProcessor: Codeunit "DA External Storage Processor";
    begin
        // Only handle if file is uploaded externally and not available internally
        if not ExternalStorageProcessor.IsFileUploadedToExternalStorageAndDeletedInternally(DocumentAttachment) then
            exit;

        ExternalStorageProcessor.DownloadFromExternalStorageToStream(DocumentAttachment."External File Path", AttachmentOutStream);
        IsHandled := true;
    end;

    /// <summary>
    /// Handles getting content as TempBlob for externally stored document attachments.
    /// Downloads from external storage when internal content is not available.
    /// </summary>
    [EventSubscriber(ObjectType::Table, Database::"Document Attachment", 'OnBeforeGetAsTempBlob', '', false, false)]
    local procedure DocumentAttachment_OnBeforeGetAsTempBlob(var DocumentAttachment: Record "Document Attachment"; var TempBlob: Codeunit "Temp Blob"; var IsHandled: Boolean)
    var
        ExternalStorageProcessor: Codeunit "DA External Storage Processor";
    begin
        // Only handle if file is uploaded externally and not available internally
        if not ExternalStorageProcessor.IsFileUploadedToExternalStorageAndDeletedInternally(DocumentAttachment) then
            exit;

        ExternalStorageProcessor.DownloadFromExternalStorageToTempBlob(DocumentAttachment."External File Path", TempBlob);
        IsHandled := true;
    end;

    /// <summary>
    /// Handles content type determination for externally stored document attachments.
    /// Uses file extension to determine content type when internal content is not available.
    /// </summary>
    [EventSubscriber(ObjectType::Table, Database::"Document Attachment", 'OnBeforeGetContentType', '', false, false)]
    local procedure DocumentAttachment_OnBeforeGetContentType(var Rec: Record "Document Attachment"; var ContentType: Text[100]; var IsHandled: Boolean)
    var
        ExternalStorageProcessor: Codeunit "DA External Storage Processor";
    begin
        // Only handle if file is uploaded externally and not available internally
        if not ExternalStorageProcessor.IsFileUploadedToExternalStorageAndDeletedInternally(Rec) then
            exit;

        ExternalStorageProcessor.FileExtensionToContentMimeType(Rec, ContentType);
        IsHandled := true;
    end;

    /// <summary>
    /// Handles content availability check for externally stored document attachments.
    /// Returns true if file is available externally even when not available internally.
    /// </summary>
    [EventSubscriber(ObjectType::Table, Database::"Document Attachment", 'OnBeforeHasContent', '', false, false)]
    local procedure DocumentAttachment_OnBeforeHasContent(var DocumentAttachment: Record "Document Attachment"; var AttachmentIsAvailable: Boolean; var IsHandled: Boolean)
    var
        ExternalStorageProcessor: Codeunit "DA External Storage Processor";
    begin
        // Only handle if file is uploaded externally and not available internally
        if not ExternalStorageProcessor.IsFileUploadedToExternalStorageAndDeletedInternally(DocumentAttachment) then
            exit;

        AttachmentIsAvailable := ExternalStorageProcessor.CheckIfFileExistInExternalStorage(DocumentAttachment."External File Path");
        IsHandled := true;
    end;
    #endregion

    #region File Scenario Handling
    /// <summary>
    /// Handles the scenario setup action for External Storage file scenario.
    /// Opens the External Storage Setup page when triggered.
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"File Scenario", OnScenarioSetupAction, '', false, false)]
    local procedure FileScenario_OnScenarioSetupAction(Scenario: Integer; Connector: Enum "Ext. File Storage Connector"; var IsHandled: Boolean)
    var
        ExternalStorageSetup: Page "DA External Storage Setup";
    begin
        if not (Scenario = Enum::"File Scenario"::"Doc. Attach. - External Storage".AsInteger()) then
            exit;

        ExternalStorageSetup.RunModal();
        IsHandled := true;
    end;

    /// <summary>
    /// Shows a disclaimer before enabling External Storage file scenario.
    /// Warns users about the risks and gets confirmation.
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"File Scenario", OnBeforeAddOrModifyFileScenario, '', false, false)]
    local procedure FileScenario_OnBeforeAddOrModifyFileScenario(Scenario: Integer; Connector: Enum "Ext. File Storage Connector"; var IsHandled: Boolean)
    var
        DisclaimerPart1: Label 'You are about to enable External Storage!!!';
        DisclaimerPart2: Label '\\This feature is provided as-is, and you use it at your own risk.';
        DisclaimerPart3: Label '\Microsoft is not responsible for any issues or data loss that may occur.';
        DisclaimerPart4: Label '\\Do you wish to continue?';
    begin
        if not (Scenario = Enum::"File Scenario"::"Doc. Attach. - External Storage".AsInteger()) then
            exit;

        IsHandled := not Dialog.Confirm(
                    DisclaimerPart1 +
                    DisclaimerPart2 +
                    DisclaimerPart3 +
                    DisclaimerPart4);
    end;

    /// <summary>
    /// Prevents deletion of External Storage file scenario when there are uploaded files.
    /// Shows an error message and blocks the operation.
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"File Scenario", OnBeforeFileScenarioDelete, '', false, false)]
    local procedure FileScenario_OnBeforeFileScenarioDelete(Scenario: Integer; Connector: Enum "Ext. File Storage Connector"; var IsHandled: Boolean)
    var
        ExternalStorageSetup: Record "DA External Storage Setup";
        NotPossibleToUnassignScenarioMsg: Label 'External Storage scenario can not be unassigned when there are uploaded files.';
    begin
        if not (Scenario = Enum::"File Scenario"::"Doc. Attach. - External Storage".AsInteger()) then
            exit;

        if not ExternalStorageSetup.Get() then
            exit;

        ExternalStorageSetup.CalcFields("Has Uploaded Files");
        if not ExternalStorageSetup."Has Uploaded Files" then
            exit;

        Message(NotPossibleToUnassignScenarioMsg);
        IsHandled := true;
    end;
    #endregion
}
