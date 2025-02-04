// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using System.Utilities;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Interfaces;
using Microsoft.eServices.EDocument.Integration.Send;
using Microsoft.eServices.EDocument.Integration.Receive;


codeunit 6386 IntegrationImpl implements IDocumentSender, IDocumentReceiver, IDocumentResponseHandler, IReceivedDocumentMarker
{
    Access = Internal;

    var
        Processing: Codeunit Processing;

    #region IDocumentSender
    procedure Send(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext);
    var
    begin
        this.Processing.Send(EDocument, EDocumentService, SendContext);
    end;
    #endregion

    #region IDocumentResponseHandler
    procedure GetResponse(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext): Boolean;
    begin
        exit(this.Processing.GetResponse(EDocument, EDocumentService, SendContext));
    end;
    #endregion

    #region IDocumentReceiver
    procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; DocumentsMetadataTempBlobList: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)
    begin
        this.Processing.ReceiveDocuments(EDocumentService, DocumentsMetadataTempBlobList, ReceiveContext);
    end;

    procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadataTempBlob: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    begin
        this.Processing.DownloadDocument(EDocument, EDocumentService, DocumentMetadataTempBlob, ReceiveContext);
    end;
    #endregion


    #region IReceivedDocumentMarker
    procedure MarkFetched(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var DocumentTempBlob: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    begin
        this.Processing.MarkFetched(EDocument, EDocumentService, DocumentTempBlob, ReceiveContext);
    end;
    #endregion


    [EventSubscriber(ObjectType::Page, Page::"E-Document Service", OnBeforeOpenServiceIntegrationSetupPage, '', false, false)]
    local procedure OnBeforeOpenServiceIntegrationSetupPage(EDocumentService: Record "E-Document Service"; var IsServiceIntegrationSetupRun: Boolean)
    var
        ConnectionSetupCard: Page ConnectionSetupCard;
    begin
        if EDocumentService."Service Integration V2" <> EDocumentService."Service Integration V2"::"ExFlow E-Invoicing" then
            exit;

        ConnectionSetupCard.RunModal();
        IsServiceIntegrationSetupRun := true;
    end;
}