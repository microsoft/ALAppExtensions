// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Tietoevry;

using System.Utilities;
using Microsoft.EServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Send;
using Microsoft.eServices.EDocument.Integration.Receive;
using Microsoft.eServices.EDocument.Integration.Interfaces;

codeunit 6392 "Integration Impl." implements IDocumentSender, IDocumentResponseHandler, IDocumentReceiver, IReceivedDocumentMarker
{
    Access = Internal;

    procedure Send(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext)
    begin
        this.TietoevryProcessing.SendEDocument(EDocument, EDocumentService, SendContext);
    end;

    procedure GetResponse(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext): Boolean
    begin
        exit(this.TietoevryProcessing.GetDocumentStatus(EDocument, SendContext));
    end;

    procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; ReceivedEDocuments: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)
    begin
        this.TietoevryProcessing.ReceiveDocuments(EDocumentService, ReceivedEDocuments, ReceiveContext);
    end;

    procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadataBlob: codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    begin
        this.TietoevryProcessing.DownloadDocument(EDocument, EDocumentService, DocumentMetadataBlob, ReceiveContext);
    end;

    procedure MarkFetched(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var DocumentBlob: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    begin
        this.TietoevryProcessing.AcknowledgeDocument(EDocument, EDocumentService, DocumentBlob, ReceiveContext);
    end;

    [EventSubscriber(ObjectType::Page, Page::"E-Document Service", OnBeforeOpenServiceIntegrationSetupPage, '', false, false)]
    local procedure OnBeforeOpenServiceIntegrationSetupPage(EDocumentService: Record "E-Document Service"; var SetupPage: Integer)
    begin
        if EDocumentService."Service Integration V2" = EDocumentService."Service Integration V2"::Tietoevry then
            SetupPage := Page::"Connection Setup Card";
    end;

    var
        TietoevryProcessing: Codeunit Processing;
}