// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Avalara;

using System.Utilities;
using Microsoft.EServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Send;
using Microsoft.eServices.EDocument.Integration.Receive;
using Microsoft.eServices.EDocument.Integration.Interfaces;

codeunit 6372 "Integration Impl." implements IDocumentSender, IDocumentResponseHandler, IDocumentReceiver
{
    Access = Internal;

    procedure Send(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext)
    begin
        this.AvalaraProcessing.SendEDocument(EDocument, EDocumentService, SendContext);
    end;

    procedure GetResponse(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext): Boolean
    begin
        exit(this.AvalaraProcessing.GetDocumentStatus(EDocument, SendContext));
    end;

    procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; DocumentsMetadata: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)
    begin
        this.AvalaraProcessing.ReceiveDocuments(EDocumentService, DocumentsMetadata, ReceiveContext);
    end;

    procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadata: codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    begin
        this.AvalaraProcessing.DownloadDocument(EDocument, EDocumentService, DocumentMetadata, ReceiveContext);
    end;

    [EventSubscriber(ObjectType::Page, Page::"E-Document Service", OnBeforeOpenServiceIntegrationSetupPage, '', false, false)]
    local procedure OnBeforeOpenServiceIntegrationSetupPage(EDocumentService: Record "E-Document Service"; var SetupPage: Integer)
    begin
        if EDocumentService."Service Integration V2" = EDocumentService."Service Integration V2"::Avalara then
            SetupPage := Page::"Connection Setup Card";
    end;


    var
        AvalaraProcessing: Codeunit Processing;


}