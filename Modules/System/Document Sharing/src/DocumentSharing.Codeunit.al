// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Codeunit to invoke document sharing flow.
/// </summary>
codeunit 9560 "Document Sharing"
{
    Access = Public;
    TableNo = "Document Sharing";

    /// <summary>
    /// Triggers the document sharing flow with the provided Document Sharing record.
    /// </summary>
    /// <example>
    ///  TempDocumentSharing.Name := 'My Shared Document.pdf';
    ///  TempDocumentSharing.Extension := '.pdf';
    ///  TempDocumentSharing.Data := "Document Blob";
    ///  TempDocumentSharing.Insert();
    ///  Codeunit.Run(Codeunit::"Document Sharing", TempDocumentSharing);
    /// </example>
    trigger OnRun()
    begin
        Codeunit.Run(Codeunit::"Document Sharing Impl.", Rec);
    end;

    /// <summary>
    /// Triggers the document sharing flow.
    /// </summary>
    /// <param name="DocumentSharingRec">The record to invoke the share with.</param>
    /// <example>
    ///  TempDocumentSharing.Name := 'My Shared Document.pdf';
    ///  TempDocumentSharing.Extension := '.pdf';
    ///  TempDocumentSharing.Data := "Document Blob";
    ///  TempDocumentSharing.Insert();
    ///  DocumentSharing.Share(TempDocumentSharing);
    /// </example>
    procedure Share(var DocumentSharingRec: Record "Document Sharing")
    begin
        Codeunit.Run(Codeunit::"Document Sharing Impl.", DocumentSharingRec);
    end;

    /// <summary>
    /// Triggers the document sharing flow.
    /// </summary>
    /// <param name="FileName">Specifies the file name of the document (without file extension). It should only include valid filename characters.</param>
    /// <param name="FileExtension">Specifies the file extension (e.g. '.pdf').</param>
    /// <param name="InStream">Specifies the data to be shared (e.g. a report pdf).</param>
    /// <param name="DocumentSharingIntent">Specifies the sharing intent of the document.</param>
    procedure Share(FileName: Text; FileExtension: Text; InStream: Instream; DocumentSharingIntent: Enum "Document Sharing Intent")
    begin
        Share(FileName, FileExtension, Instream, DocumentSharingIntent, "Document Sharing Source"::App);
    end;

    /// <summary>
    /// Triggers the document sharing flow.
    /// </summary>
    /// <param name="FileName">Specifies the file name of the document (without file extension). It should only include valid filename characters.</param>
    /// <param name="FileExtension">Specifies the file extension (e.g. '.pdf').</param>
    /// <param name="InStream">Specifies the data to be shared (e.g. a report pdf).</param>
    /// <param name="DocumentSharingIntent">Specifies the sharing intent of the document.</param>
    /// <param name="DocumentSharingSource">Specifies the sharing source of the document.</param>
    procedure Share(FileName: Text; FileExtension: Text; InStream: Instream; DocumentSharingIntent: Enum "Document Sharing Intent"; DocumentSharingSource: Enum "Document Sharing Source")
    var
        DocumentSharingImpl: Codeunit "Document Sharing Impl.";
    begin
        DocumentSharingImpl.Share(FileName, FileExtension, Instream, DocumentSharingIntent, DocumentSharingSource);
    end;

    /// <summary>
    /// Checks if document sharing is enabled.
    /// </summary>
    /// <returns>Returns true if sharing is enabled, false otherwise.</returns>
    procedure ShareEnabled(): Boolean
    var
        DocumentSharingImpl: Codeunit "Document Sharing Impl.";
    begin
        exit(DocumentSharingImpl.ShareEnabled("Document Sharing Source"::App));
    end;

    /// <summary>
    /// Checks if document sharing is enabled.
    /// </summary>
    /// <param name="DocumentSharingSource">Specifies the sharing source of the document.</param>
    /// <returns>Returns true if sharing is enabled, false otherwise.</returns>
    procedure ShareEnabled(DocumentSharingSource: Enum "Document Sharing Source"): Boolean
    var
        DocumentSharingImpl: Codeunit "Document Sharing Impl.";
    begin
        exit(DocumentSharingImpl.ShareEnabled(DocumentSharingSource));
    end;

    /// <summary>
    /// Checks if Document can be edited online.
    /// </summary>
    /// <param name="FileName">File name of document. Ex 'Document.docx'</param>
    /// <returns>True if Document can be edited online.</returns>
    procedure EditEnabledForFile(FileName: Text): Boolean
    var
        DocumentSharingImpl: Codeunit "Document Sharing Impl.";
    begin
        exit(DocumentSharingImpl.EditEnabledForFile(FileName));
    end;

    /// <summary>
    /// Raised when the document needs to be uploaded.
    /// </summary>
    /// <param name="DocumentSharing">The record containing the document to be shared.</param>
    /// <param name="Handled">Specifies whether the event has been handled and no further execution should occur.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnUploadDocument(var DocumentSharing: Record "Document Sharing" temporary; var Handled: Boolean)
    begin
    end;

    /// <summary>
    /// Raised to test if there are any document services that can handle the upload.
    /// </summary>
    /// <param name="CanUpload">Specifies whether there is a subscriber that can handle the upload.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnCanUploadDocument(var CanUpload: Boolean)
    begin
    end;

    /// <summary>
    /// Raised to test if there are any document services that can handle the upload for a system document.
    /// </summary>
    /// <param name="CanUpload">Specifies whether there is a subscriber that can handle the upload.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnCanUploadSystemDocument(var CanUpload: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnGetFileContents(var DocumentSharing: Record "Document Sharing" temporary; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnDeleteDocument(var DocumentSharing: Record "Document Sharing" temporary; var Handled: Boolean)
    begin
    end;
}