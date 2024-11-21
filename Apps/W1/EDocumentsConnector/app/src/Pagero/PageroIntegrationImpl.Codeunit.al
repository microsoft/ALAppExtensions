// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

using System.Utilities;
using Microsoft.EServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Interfaces;
using Microsoft.eServices.EDocument.Integration.Send;
using Microsoft.eServices.EDocument.Integration.Receive;

codeunit 6362 "Pagero Integration Impl." implements IDocumentSender, IDocumentResponseHandler, IDocumentReceiver, ISentDocumentActions
{
    Access = Internal;

    procedure Send(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext)
    var
        TempBlob: Codeunit "Temp Blob";
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
    begin
        TempBlob := SendContext.GetTempBlob();
        PageroProcessing.SendEDocument(EDocument, EDocumentService, TempBlob, HttpRequest, HttpResponse);
        SendContext.Http().SetHttpRequestMessage(HttpRequest);
        SendContext.Http().SetHttpResponseMessage(HttpResponse);
    end;

    procedure GetResponse(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext): Boolean
    var
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        Success: Boolean;
    begin
        Success := PageroProcessing.GetDocumentResponse(EDocument, EDocumentService, HttpRequest, HttpResponse);
        SendContext.Http().SetHttpRequestMessage(HttpRequest);
        SendContext.Http().SetHttpResponseMessage(HttpResponse);
        exit(Success);
    end;

    procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; DocumentsMetadata: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)
    begin
        PageroProcessing.ReceiveDocument(EDocumentService, DocumentsMetadata, ReceiveContext);
    end;

    procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadata: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    begin
        PageroProcessing.DownloadDocument(EDocument, EDocumentService, DocumentMetadata, ReceiveContext);
    end;

    procedure GetApprovalStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; ActionContext: Codeunit ActionContext) Success: Boolean
    var
        Status: Enum "E-Document Service Status";
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
    begin
        Success := PageroProcessing.GetDocumentApproval(EDocument, EDocumentService, HttpRequest, HttpResponse, Status);
        ActionContext.Status().SetStatus(Status);
        ActionContext.Http().SetHttpRequestMessage(HttpRequest);
        ActionContext.Http().SetHttpResponseMessage(HttpResponse);
    end;

    procedure GetCancellationStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; ActionContext: Codeunit ActionContext) Success: Boolean
    var
        Status: Enum "E-Document Service Status";
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
    begin
        Success := PageroProcessing.CancelEDocument(EDocument, EDocumentService, HttpRequest, HttpResponse, Status);
        ActionContext.Status().SetStatus(Status);
        ActionContext.Http().SetHttpRequestMessage(HttpRequest);
        ActionContext.Http().SetHttpResponseMessage(HttpResponse);
    end;

    [EventSubscriber(ObjectType::Page, Page::"E-Document Service", OnBeforeOpenServiceIntegrationSetupPage, '', false, false)]
    local procedure OnBeforeOpenServiceIntegrationSetupPage(EDocumentService: Record "E-Document Service"; var SetupPage: Integer)
    begin
        if EDocumentService."Service Integration V2" = EDocumentService."Service Integration V2"::Pagero then
            SetupPage := Page::"EDoc Ext Connection Setup Card";
    end;

    var
        PageroProcessing: Codeunit "Pagero Processing";

}