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

codeunit 148195 "Drive Int. Test Impl." implements IDocumentReceiver, IDocumentSender, IReceivedDocumentMarker
{
    Access = Internal;

    procedure Send(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext)
    begin
        Error(SendNotSupportedErr);
    end;

    procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; Documents: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)
    begin
        OneDriveSharepointIntTest.ReceiveDocuments(EDocumentService, Documents, ReceiveContext);
    end;

    procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadataBlob: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    begin
        OneDriveSharepointIntTest.DownloadDocument(EDocument, EDocumentService, DocumentMetadataBlob, ReceiveContext);
    end;

    procedure MarkFetched(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var DocumentBlob: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    var
        Assert: Codeunit Assert;
    begin
        Assert.AreNotEqual(EDocument."Drive Item Id", '', 'Drive Item Id must have a value when MarkFetched is called');
    end;

    [EventSubscriber(ObjectType::Page, Page::"E-Document Service", OnBeforeOpenServiceIntegrationSetupPage, '', false, false)]
    local procedure OnBeforeOpenServiceIntegrationSetupPage(EDocumentService: Record "E-Document Service"; var IsServiceIntegrationSetupRun: Boolean)
    var
        OneDriveSetup: Page "OneDrive Setup";
        SharepointSetup: Page "Sharepoint Setup";
    begin
        if EDocumentService."Service Integration V2" <> EDocumentService."Service Integration V2"::TestOneDrive then begin
            OneDriveSetup.RunModal();
            IsServiceIntegrationSetupRun := true;
        end;

        if EDocumentService."Service Integration V2" <> EDocumentService."Service Integration V2"::TestSharepoint then begin
            SharepointSetup.RunModal();
            IsServiceIntegrationSetupRun := true;
        end;
    end;

    var
        OneDriveSharepointIntTest: Codeunit "OneDrive Sharepoint Int. Test";
        SendNotSupportedErr: label 'Sending document is not supported in this context.';
}