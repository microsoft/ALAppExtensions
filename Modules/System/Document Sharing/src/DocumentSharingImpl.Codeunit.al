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
        CanShare: Boolean;
        CanOpen: Boolean;
        Handled: Boolean;
    begin
        if Rec.IsEmpty() then
            Error(NoDocToShareErr);

        DocumentSharing.OnCanUploadDocument(CanHandle);
        if not CanHandle then
            Error(NoDocServiceConfiguredErr);

        if Rec."Document Sharing Intent" = Rec."Document Sharing Intent"::Share then
            UploadDialog.Open(StrSubstNo(UploadingToShareBlobTxt, ProductName.Short()))
        else
            UploadDialog.Open(StrSubstNo(UploadingBlobTxt, ProductName.Short()));

        Session.LogMessage('0000FKT', UploadingBlobTelemetryTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', DocumentSharingCategoryLbl);
        DocumentSharing.OnUploadDocument(Rec, Handled);
        UploadDialog.Close();

        if not Handled then
            Error('');

        Rec.CalcFields(Rec.Token);
        CanShare := (Rec.Token.Length > 0) and (Rec.DocumentUri <> '') and (Rec.DocumentRootUri <> '');
        CanOpen := (Rec.DocumentPreviewUri <> '') or (Rec.DocumentUri <> '');

        Session.LogMessage('0000GGK', StrSubstNo(DocumentSharingIntentTelemetryTxt, Rec."Document Sharing Intent", CanShare, CanOpen), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', DocumentSharingCategoryLbl);

        if not (CanShare or CanOpen) then
            Error(NoDocUploadedErr);

        // Validate intent
        case Rec."Document Sharing Intent" of
            Rec."Document Sharing Intent"::Open:
                ValidateIntent(Rec, CanOpen, NoOpenQst, Rec."Document Sharing Intent"::Share); // here for readability, but will never fail
            Rec."Document Sharing Intent"::Share:
                ValidateIntent(Rec, CanShare, NoShareQst, Rec."Document Sharing Intent"::Open);
            else begin
                    if not GuiAllowed() then
                        Error(PromptNoGuiErr);

                    ValidateIntent(Rec, CanOpen, NoPromptShareOnlyQst, Rec."Document Sharing Intent"::Share);
                    ValidateIntent(Rec, CanShare, NoPromptOpenOnlyQst, Rec."Document Sharing Intent"::Open);

                    // If the prior validations have not changed the intent, continue with the prompt.
                    if Rec."Document Sharing Intent" = Rec."Document Sharing Intent"::Prompt then
                        case StrMenu(StrSubstNo(ConcatenatedStringTxt, Rec."Document Sharing Intent"::Open, Rec."Document Sharing Intent"::Share), 1, PromptQst) of
                            1:
                                Rec."Document Sharing Intent" := Rec."Document Sharing Intent"::Open;
                            2:
                                Rec."Document Sharing Intent" := Rec."Document Sharing Intent"::Share;
                            else
                                Error(NoDocToShareErr);
                        end
                end;
        end;

        // Perform intent
        case Rec."Document Sharing Intent" of
            Rec."Document Sharing Intent"::Open:
                OpenDocument(Rec);
            Rec."Document Sharing Intent"::Share:
                OpenShare(Rec);
            else begin
                    Session.LogMessage('0000GGL', StrSubstNo(DocumentSharingIntentTelemetryTxt, Rec."Document Sharing Intent", CanShare, CanOpen), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', DocumentSharingCategoryLbl);
                    Error(NoDocUploadedErr);
                end;
        end;
    end;

    procedure ShareEnabled(): Boolean
    var
        DocumentSharing: Codeunit "Document Sharing";
        ClientTypeManagement: Codeunit "Client Type Management";
        CanHandle: Boolean;
    begin
        if ClientTypeManagement.GetCurrentClientType() in [ClientType::Phone, ClientType::Tablet] then
            exit(false);

        DocumentSharing.OnCanUploadDocument(CanHandle);
        exit(CanHandle);
    end;

    procedure Share(FileName: Text; FileExtension: Text; InStream: Instream; DocumentSharingIntent: Enum "Document Sharing Intent")
    var
        TempDocumentSharing: Record "Document Sharing" temporary;
        OutStream: OutStream;
    begin
        TempDocumentSharing.Name := CopyStr(FileName, 1, MaxStrLen(TempDocumentSharing.Name) - StrLen(FileExtension)) + FileExtension;
        TempDocumentSharing.Extension := CopyStr(FileExtension, 1, MaxStrLen(TempDocumentSharing.Extension));

        TempDocumentSharing.Data.CreateOutStream(OutStream);
        CopyStream(OutStream, InStream);
        TempDocumentSharing."Document Sharing Intent" := DocumentSharingIntent;
        TempDocumentSharing.Insert();

        Codeunit.Run(Codeunit::"Document Sharing Impl.", TempDocumentSharing);
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
        UploadingBlobTelemetryTxt: Label 'Uploading document.', Locked = true;
        ShareUxOpenTxt: Label 'Opening share dialog.', Locked = true;
        PreviewOpenTxt: Label 'Opening document preview.', Locked = true;
        DocumentOpenTxt: Label 'Opening document uri.', Locked = true;
        DocumentSharingIntentTelemetryTxt: Label 'Sharing intent: %1, CanShare: %2, CanOpen: %3', Locked = true;
        IntentChangedTelemetryTxt: Label 'Selected new intent: %1', Locked = true;
        ConcatenatedStringTxt: Label '%1,%2', Locked = true;
}