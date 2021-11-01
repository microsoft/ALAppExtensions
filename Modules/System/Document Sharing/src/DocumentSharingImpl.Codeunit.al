// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Codeunit that contains the implementation for document sharing.
/// </summary>
codeunit 9561 "Document Sharing Impl."
{
    Access = Internal;
    TableNo = "Document Sharing";

    trigger OnRun()
    var
        DocumentSharing: Codeunit "Document Sharing";
        UploadDialog: Dialog;
        CanHandle: Boolean;
        Handled: Boolean;
    begin
        if Rec.IsEmpty() then
            Error(NoDocToShareErr);

        DocumentSharing.OnCanUploadDocument(CanHandle);
        if not CanHandle then
            Error(NoDocServiceConfiguredErr);

        UploadDialog.Open(StrSubstNo(UploadingBlobTxt, ProductName.Short()));
        Session.LogMessage('0000FKT', UploadingBlobTelemetryTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', DocumentSharingCategoryLbl);
        DocumentSharing.OnUploadDocument(Rec, Handled);
        UploadDialog.Close();

        if not Handled then
            Error('');

        Rec.CalcFields(Token);
        if (Token.Length > 0) and (Rec.DocumentUri <> '') and (Rec.DocumentRootUri <> '') then begin
            Session.LogMessage('0000FKU', ShareUxOpenTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', DocumentSharingCategoryLbl);
            Page.Run(Page::"Document Sharing", Rec);
            exit;
        end;

        if Rec.DocumentPreviewUri <> '' then begin
            Session.LogMessage('0000FKV', PreviewOpenTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', DocumentSharingCategoryLbl);
            Hyperlink(Rec.DocumentPreviewUri);
            exit;
        end;

        if Rec.DocumentUri <> '' then begin
            Session.LogMessage('0000FKW', DocumentOpenTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', DocumentSharingCategoryLbl);
            Hyperlink(Rec.DocumentUri);
            exit;
        end;

        Error(NoDocUploadedErr);
    end;

    procedure ShareEnabled(): Boolean
    var
        DocumentSharing: Codeunit "Document Sharing";
        CanHandle: Boolean;
    begin
        DocumentSharing.OnCanUploadDocument(CanHandle);
        exit(CanHandle);
    end;

    var
        NoDocToShareErr: Label 'No document to share';
        NoDocServiceConfiguredErr: Label 'Document service is not configured';
        NoDocUploadedErr: Label 'Could not share this document.';
        UploadingBlobTxt: Label 'We''re copying this to your %1 folder in OneDrive', Comment = '%1 is the short product name (e.g. Business Central)';
        DocumentSharingCategoryLbl: Label 'AL DocumentSharing';
        UploadingBlobTelemetryTxt: Label 'Uploading document.', Locked = true;
        ShareUxOpenTxt: Label 'Opening share dialog.', Locked = true;
        PreviewOpenTxt: Label 'Opening document preview.', Locked = true;
        DocumentOpenTxt: Label 'Opening document uri.', Locked = true;
}