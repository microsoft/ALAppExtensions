// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Microsoft365;

using System.Utilities;
using Microsoft.EServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Interfaces;
using Microsoft.eServices.EDocument.Integration.Receive;
using Microsoft.eServices.EDocument.Integration.Send;

codeunit 6382 "Integration Impl." implements IDocumentReceiver, IDocumentSender, IReceivedDocumentMarker
{
    Permissions = tabledata "E-Document" = r,
                  tabledata "E-Document Log" = r,
                  tabledata "E-Doc. Data Storage" = r,
                  tabledata "OneDrive Setup" = r,
                  tabledata "Sharepoint Setup" = r;
    InherentPermissions = X;
    InherentEntitlements = X;

    procedure Send(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext)
    begin
        Error(SendNotSupportedErr);
    end;

    procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; Documents: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)
    begin
        DriveProcessing.ReceiveDocuments(EDocumentService, Documents, ReceiveContext);
    end;

    procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadataBlob: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    begin
        DriveProcessing.DownloadDocument(EDocument, EDocumentService, DocumentMetadataBlob, ReceiveContext);
    end;

    procedure MarkFetched(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var DocumentBlob: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    begin
        DriveProcessing.MarkEDocumentAsDownloaded(EDocument, EDocumentService);
    end;

    internal procedure PreviewContent(var EDocument: Record "E-Document")
    var
        EDocDataStorage: Record "E-Doc. Data Storage";
        EDocumentLog: Record "E-Document Log";
        FileInStr: InStream;
    begin
        if not LowerCase(EDocument."File Id").EndsWith('pdf') then
            exit;

        EDocumentLog.SetRange("E-Doc. Entry No", EDocument."Entry No");
        EDocumentLog.SetFilter(Status, '<>' + Format(EDocumentLog.Status::"Batch Imported"));

        if not EDocumentLog.FindFirst() then
            Error(NoFileErr, EDocument.TableCaption());

        EDocDataStorage.SetAutoCalcFields("Data Storage");
        if not EDocDataStorage.Get(EDocumentLog."E-Doc. Data Storage Entry No.") then
            Error(NoFileErr, EDocument.TableCaption());

        if not EDocDataStorage."Data Storage".HasValue() then
            Error(NoFileContentErr, EDocument."File Id", EDocDataStorage.TableCaption());

        EDocDataStorage."Data Storage".CreateInStream(FileInStr);
        File.ViewFromStream(FileInStr, EDocument."File Id", true);
    end;

    internal procedure SetConditionalVisibilityFlag(var VisibilityFlag: Boolean)
    var
        OneDriveSetup: Record "OneDrive Setup";
        SharepointSetup: Record "Sharepoint Setup";
    begin
        if SharepointSetup.Get() then
            if SharepointSetup.Enabled then
                VisibilityFlag := true;

        if not VisibilityFlag then
            if OneDriveSetup.Get() then
                if OneDriveSetup.Enabled then
                    VisibilityFlag := true;
    end;

    [EventSubscriber(ObjectType::Page, Page::"E-Document Service", OnBeforeOpenServiceIntegrationSetupPage, '', false, false)]
    local procedure OnBeforeOpenServiceIntegrationSetupPage(EDocumentService: Record "E-Document Service"; var IsServiceIntegrationSetupRun: Boolean)
    var
        OneDriveSetup: Page "OneDrive Setup";
        SharepointSetup: Page "Sharepoint Setup";
    begin
        if EDocumentService."Service Integration V2" = EDocumentService."Service Integration V2"::OneDrive then begin
            OneDriveSetup.RunModal();
            IsServiceIntegrationSetupRun := true;
        end;

        if EDocumentService."Service Integration V2" = EDocumentService."Service Integration V2"::Sharepoint then begin
            SharepointSetup.RunModal();
            IsServiceIntegrationSetupRun := true;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"E-Document Log", OnBeforeExportDataStorage, '', false, false)]
    local procedure HandleOnBeforeExportDataStorage(EDocumentLog: Record "E-Document Log"; var FileName: Text)
    var
        EDocument: Record "E-Document";
    begin
        if not EDocument.Get(EDocumentLog."E-Doc. Entry No") then
            exit;

        if EDocument."File Id" = '' then
            exit;

        FileName := EDocument."File Id";
    end;

    var
        DriveProcessing: Codeunit "Drive Processing";
        SendNotSupportedErr: label 'Sending document is not supported in this context.';
        NoFileErr: label 'No previewable attachment exists for this %2.', Comment = '%1 - a table caption';
        NoFileContentErr: label 'Previewing file %1 failed. The file was found in table %2, but it has no content.', Comment = '%1 - a file name; %2 - a table caption';
}