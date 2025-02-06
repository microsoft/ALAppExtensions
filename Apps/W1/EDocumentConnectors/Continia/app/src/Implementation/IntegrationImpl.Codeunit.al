// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

using System.Utilities;
using Microsoft.EServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Receive;
using Microsoft.eServices.EDocument.Integration.Send;
using Microsoft.eServices.EDocument.Integration.Interfaces;

codeunit 6390 "Integration Impl." implements IDocumentSender, IDocumentResponseHandler, IDocumentReceiver, ISentDocumentActions, IReceivedDocumentMarker
{
    Access = Internal;

    #region IDocumentSender

    procedure Send(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext)
    var
        EDocumentProcessing: Codeunit "EDocument Processing";
    begin
        EDocumentProcessing.SendEDocument(EDocument, EDocumentService, SendContext);
    end;

    procedure SendBatch(var EDocuments: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    begin
        IsAsync := false;
        Error(BatchSendingNotSupportedErr);
    end;

    procedure GetResponse(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext): Boolean
    var
        EDocumentProcessing: Codeunit "EDocument Processing";
    begin
        exit(EDocumentProcessing.GetTechnicalResponse(EDocument, SendContext));
    end;

    #endregion

    #region IDocumentReceiver

    procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; DocumentsMetadata: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)
    var
        EDocumentProcessing: Codeunit "EDocument Processing";
    begin
        EDocumentProcessing.ReceiveDocuments(EDocumentService, DocumentsMetadata, ReceiveContext);
    end;

    procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadata: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    var
        EDocumentProcessing: Codeunit "EDocument Processing";
    begin
        EDocumentProcessing.DownloadDocument(EDocument, EDocumentService, DocumentMetadata, ReceiveContext);
    end;

    #endregion

    #region IReceivedDocumentMarker

    procedure MarkFetched(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var DocumentBlob: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    var
        EDocumentProcessing: Codeunit "EDocument Processing";
    begin
        EDocumentProcessing.MarkFetched(EDocument, EDocumentService, DocumentBlob, ReceiveContext);
    end;

    #endregion

    #region ISentDocumentActions

    procedure GetApprovalStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; ActionContext: Codeunit ActionContext): Boolean
    var
        EDocumentProcessing: Codeunit "EDocument Processing";
    begin
        exit(EDocumentProcessing.GetLastDocumentBusinessResponses(EDocument, ActionContext));
    end;

    procedure GetCancellationStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; ActionContext: Codeunit ActionContext): Boolean
    var
        EDocumentProcessing: Codeunit "EDocument Processing";
    begin
        exit(EDocumentProcessing.GetCancellationStatus(EDocument, EDocumentService, ActionContext));
    end;

    #endregion

    [EventSubscriber(ObjectType::Page, Page::"E-Document Service", OnBeforeOpenServiceIntegrationSetupPage, '', false, false)]
    local procedure OnBeforeOpenServiceIntegrationSetupPage(EDocumentService: Record "E-Document Service"; var IsServiceIntegrationSetupRun: Boolean)
    var
        ExtConnectionSetup: Page "Ext. Connection Setup";
    begin
        if EDocumentService."Service Integration V2" <> EDocumentService."Service Integration V2"::Continia then
            exit;

        ExtConnectionSetup.Run();
        IsServiceIntegrationSetupRun := true;
    end;

    var
        BatchSendingNotSupportedErr: Label 'Batch sending is not supported in this version';
}