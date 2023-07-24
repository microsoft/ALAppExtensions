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
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        DocumentSharing: Codeunit "Document Sharing";
        CanHandle: Boolean;
        CanShare: Boolean;
        CanOpen: Boolean;
    begin
        if Rec.IsEmpty() then
            Error(NoDocToShareErr);

        if Rec.Source = Rec.Source::App then
            DocumentSharing.OnCanUploadDocument(CanHandle)
        else
            DocumentSharing.OnCanUploadSystemDocument(CanHandle);

        if not CanHandle then
            Error(NoDocServiceConfiguredErr);

        Upload(Rec, CanShare, CanOpen);

        ValidateRecordIntent(Rec, CanShare, CanOpen);

        PerformRecordIntent(Rec, CanShare, CanOpen);
    end;

    local procedure Upload(var DocumentSharing: Record "Document Sharing"; var CanShare: Boolean; var CanOpen: Boolean)
    var
        DocumentSharingCodeunit: Codeunit "Document Sharing";
        UploadDialog: Dialog;
        Handled: Boolean;
    begin
        if DocumentSharing."Document Sharing Intent" = DocumentSharing."Document Sharing Intent"::Share then
            UploadDialog.Open(StrSubstNo(UploadingToShareBlobTxt, ProductName.Short()))
        else
            UploadDialog.Open(StrSubstNo(UploadingBlobTxt, ProductName.Short()));

        Session.LogMessage('0000FKT', StrSubstNo(UploadingBlobTelemetryTxt, DocumentSharing.Source), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', DocumentSharingCategoryLbl);
        DocumentSharingCodeunit.OnUploadDocument(DocumentSharing, Handled);
        UploadDialog.Close();

        if not Handled then
            Error('');

        DocumentSharing.CalcFields(DocumentSharing.Token);
        CanShare := (DocumentSharing.Token.Length > 0) and (DocumentSharing.DocumentUri <> '') and (DocumentSharing.DocumentRootUri <> '');
        CanOpen := (DocumentSharing.DocumentPreviewUri <> '') or (DocumentSharing.DocumentUri <> '');

        Session.LogMessage('0000GGK', StrSubstNo(DocumentSharingIntentTelemetryTxt, DocumentSharing."Document Sharing Intent", CanShare, CanOpen), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', DocumentSharingCategoryLbl);

        if not (CanShare or CanOpen) then
            Error(NoDocUploadedErr);
    end;

    local procedure ValidateRecordIntent(var DocumentSharing: Record "Document Sharing"; CanShare: Boolean; CanOpen: Boolean)
    begin
        // Validate intent
        case DocumentSharing."Document Sharing Intent" of
            DocumentSharing."Document Sharing Intent"::Open,
            DocumentSharing."Document Sharing Intent"::Edit:
                ValidateIntent(DocumentSharing, CanOpen, NoOpenQst, DocumentSharing."Document Sharing Intent"::Share); // here for readability, but will never fail
            DocumentSharing."Document Sharing Intent"::Share:
                ValidateIntent(DocumentSharing, CanShare, NoShareQst, DocumentSharing."Document Sharing Intent"::Open);
            else begin
                if not GuiAllowed() then
                    Error(PromptNoGuiErr);

                ValidateIntent(DocumentSharing, CanOpen, NoPromptShareOnlyQst, DocumentSharing."Document Sharing Intent"::Share);
                ValidateIntent(DocumentSharing, CanShare, NoPromptOpenOnlyQst, DocumentSharing."Document Sharing Intent"::Open);

                // If the prior validations have not changed the intent, continue with the prompt.
                if DocumentSharing."Document Sharing Intent" = DocumentSharing."Document Sharing Intent"::Prompt then
                    case StrMenu(StrSubstNo(ConcatenatedStringTxt, DocumentSharing."Document Sharing Intent"::Open, DocumentSharing."Document Sharing Intent"::Share), 1, PromptQst) of
                        1:
                            DocumentSharing."Document Sharing Intent" := DocumentSharing."Document Sharing Intent"::Open;
                        2:
                            DocumentSharing."Document Sharing Intent" := DocumentSharing."Document Sharing Intent"::Share;
                        else
                            Error(NoDocToShareErr);
                    end
            end;
        end;
    end;

    local procedure PerformRecordIntent(var DocumentSharing: Record "Document Sharing"; CanShare: Boolean; CanOpen: Boolean)
    var
        DocumentSharingCodeunit: Codeunit "Document Sharing";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        Language: Codeunit Language;
        DocumentSharingIntentTxt: Text;
        Handled: Boolean;
    begin
        DocumentSharingIntentTxt := Language.ToDefaultLanguage(DocumentSharing."Document Sharing Intent");
        // Perform intent
        case DocumentSharing."Document Sharing Intent" of
            DocumentSharing."Document Sharing Intent"::Open:
                begin
                    FeatureTelemetry.LogUsage('0000HUK', OneDriveFeatureNameTelemetryTxt, StrSubstNo(OneDriveExecuteIntentEventTelemetryTxt, DocumentSharingIntentTxt));
                    OpenDocument(DocumentSharing);
                end;
            DocumentSharing."Document Sharing Intent"::Share:
                begin
                    FeatureTelemetry.LogUsage('0000HUL', OneDriveFeatureNameTelemetryTxt, StrSubstNo(OneDriveExecuteIntentEventTelemetryTxt, DocumentSharingIntentTxt));
                    OpenShare(DocumentSharing);
                end;
            DocumentSharing."Document Sharing Intent"::Edit:
                begin
                    FeatureTelemetry.LogUsage('0000J1A', OneDriveFeatureNameTelemetryTxt, StrSubstNo(OneDriveExecuteIntentEventTelemetryTxt, DocumentSharingIntentTxt));
                    OpenDocument(DocumentSharing);

                    // Downloads file into DocumentSharing.Data, otherwise uploaded file is in DocumentSharing.Data
                    if Dialog.Confirm(FinishedEditingDocumentLbl, true) then begin
                        Handled := false;
                        Sleep(2000); // This sleep is to ensure the OneDrive clears the lock on the file after the user saves and closes.
                        DocumentSharingCodeunit.OnGetFileContents(DocumentSharing, Handled);
                    end;

                    Handled := False;
                    DocumentSharingCodeunit.OnDeleteDocument(DocumentSharing, Handled);
                end;
            else begin
                Session.LogMessage('0000GGL', StrSubstNo(DocumentSharingIntentTelemetryTxt, DocumentSharingIntentTxt, CanShare, CanOpen), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', DocumentSharingCategoryLbl);
                Error(NoDocUploadedErr);
            end;
        end;
    end;

    procedure ShareEnabled(DocumentSharingSource: Enum "Document Sharing Source"): Boolean
    var
        DocumentSharing: Codeunit "Document Sharing";
        AzureADUserManagement: Codeunit "Azure AD User Management";
        ClientTypeManagement: Codeunit "Client Type Management";
        CanHandle: Boolean;
    begin
        if ClientTypeManagement.GetCurrentClientType() in [ClientType::Phone, ClientType::Tablet] then
            exit(false);

        if AzureADUserManagement.IsUserDelegated(UserSecurityId()) then
            exit(false);

        if DocumentSharingSource = DocumentSharingSource::App then
            DocumentSharing.OnCanUploadDocument(CanHandle)
        else
            DocumentSharing.OnCanUploadSystemDocument(CanHandle);

        exit(CanHandle);
    end;

    procedure Share(FileName: Text; FileExtension: Text; InStream: Instream; DocumentSharingIntent: Enum "Document Sharing Intent"; DocumentSharingSource: Enum "Document Sharing Source")
    var
        TempDocumentSharing: Record "Document Sharing" temporary;
        OutStream: OutStream;
    begin
        if FileName.EndsWith(FileExtension) then
            TempDocumentSharing.Name := CopyStr(FileName, 1, MaxStrLen(TempDocumentSharing.Name))
        else
            TempDocumentSharing.Name := CopyStr(FileName, 1, MaxStrLen(TempDocumentSharing.Name) - StrLen(FileExtension)) + FileExtension;

        TempDocumentSharing.Extension := CopyStr(FileExtension, 1, MaxStrLen(TempDocumentSharing.Extension));
        TempDocumentSharing.Source := DocumentSharingSource;

        TempDocumentSharing.Data.CreateOutStream(OutStream);
        CopyStream(OutStream, InStream);
        TempDocumentSharing."Document Sharing Intent" := DocumentSharingIntent;
        TempDocumentSharing.Insert();

        Codeunit.Run(Codeunit::"Document Sharing Impl.", TempDocumentSharing);
    end;

    procedure EditEnabledForFile(FileName: Text): Boolean
    begin
        if FileName.EndsWith('.docx') then
            exit(true);
        if FileName.EndsWith('.pptx') then
            exit(true);
        if FileName.EndsWith('.xlsx') then
            exit(true);
        if FileName.EndsWith('.odt') then
            exit(true);
        if FileName.EndsWith('.txt') then
            exit(true);

        exit(false);
    end;

    local procedure ValidateIntent(var TempDocumentSharing: Record "Document Sharing" temporary; ValidIntent: Boolean; Prompt: Text; AlternateDocumentSharingIntent: Enum "Document Sharing Intent")
    begin
        if not ValidIntent then begin
            if not GuiAllowed() then
                Error(NoDocUploadedErr);

            if not Confirm(Prompt) then
                Error(NoDocUploadedErr);

            Session.LogMessage('0000GGM', StrSubstNo(IntentChangedTelemetryTxt, AlternateDocumentSharingIntent), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', DocumentSharingCategoryLbl);
            TempDocumentSharing."Document Sharing Intent" := AlternateDocumentSharingIntent;
        end;
    end;

    local procedure OpenDocument(var TempDocumentSharing: Record "Document Sharing" temporary)
    begin
        if TempDocumentSharing.DocumentPreviewUri <> '' then begin
            Session.LogMessage('0000FKV', PreviewOpenTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', DocumentSharingCategoryLbl);
            Hyperlink(TempDocumentSharing.DocumentPreviewUri);
            exit;
        end;

        if TempDocumentSharing.DocumentUri <> '' then begin
            Session.LogMessage('0000FKW', DocumentOpenTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', DocumentSharingCategoryLbl);
            Hyperlink(TempDocumentSharing.DocumentUri);
        end;
    end;

    local procedure OpenShare(var TempDocumentSharing: Record "Document Sharing" temporary)
    begin
        Session.LogMessage('0000FKU', ShareUxOpenTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', DocumentSharingCategoryLbl);
        Page.Run(Page::"Document Sharing", TempDocumentSharing);
    end;

    var
        NoDocToShareErr: Label 'No file to share.';
        NoDocServiceConfiguredErr: Label 'Document service is not configured';
        NoDocUploadedErr: Label 'We couldn''t share or open this file.';
        NoShareQst: Label 'We couldn''t share this file. Would you like to open it?';
        NoOpenQst: Label 'We couldn''t open this file. Would you like to share it?';
        PromptNoGuiErr: Label 'The prompt intent can only be used within a graphical user interface (GUI).';
        NoPromptOpenOnlyQst: Label 'Would you like to open this file?';
        NoPromptShareOnlyQst: Label 'Would you like to share this file?';
        PromptQst: Label 'The file has been copied to OneDrive. What would you like to do with it?';
        UploadingBlobTxt: Label 'We''re copying this file to your %1 folder in OneDrive', Comment = '%1 is the short product name (e.g. Business Central)';
        UploadingToShareBlobTxt: Label 'We''re copying this file to your %1 folder in OneDrive so you can share it', Comment = '%1 is the short product name (e.g. Business Central)';
        DocumentSharingCategoryLbl: Label 'AL DocumentSharing';
        FinishedEditingDocumentLbl: Label 'Do you want to add the document you edited and saved?';
        UploadingBlobTelemetryTxt: Label 'Uploading document for %1.', Locked = true;
        ShareUxOpenTxt: Label 'Opening share dialog.', Locked = true;
        PreviewOpenTxt: Label 'Opening document preview.', Locked = true;
        DocumentOpenTxt: Label 'Opening document uri.', Locked = true;
        DocumentSharingIntentTelemetryTxt: Label 'Sharing intent: %1, CanShare: %2, CanOpen: %3', Locked = true;
        IntentChangedTelemetryTxt: Label 'Selected new intent: %1', Locked = true;
        ConcatenatedStringTxt: Label '%1,%2', Locked = true;
        OneDriveFeatureNameTelemetryTxt: Label 'OneDrive', Locked = true;
        OneDriveExecuteIntentEventTelemetryTxt: Label '%1 Document', Locked = true;
}