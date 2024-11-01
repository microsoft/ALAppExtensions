// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

using System.Utilities;
using Microsoft.EServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Interfaces;

codeunit 6362 "Pagero Integration Impl." implements Sender, Receiver, "Default Int. Actions"
{
    Access = Internal;

    procedure Send(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    begin
        IsAsync := false;
    end;

    procedure SendBatch(var EDocuments: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    begin
        IsAsync := false;
        Error('Batch sending is not supported in this version');
    end;

    procedure GetResponse(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    begin
    end;

    procedure GetApproval(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    begin
    end;

    procedure Cancel(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    begin
    end;

    procedure ReceiveDocument(var TempBlob: Codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    begin
    end;

    procedure GetDocumentCountInBatch(var TempBlob: Codeunit "Temp Blob"): Integer
    begin
        exit(PageroProcessing.GetDocumentCountInBatch(TempBlob));
    end;

    procedure GetIntegrationSetup(var SetupPage: Integer; var SetupTable: Integer)
    begin
        SetupPage := page::"EDoc Ext Connection Setup Card";
        SetupTable := Database::"E-Doc. Ext. Connection Setup";
    end;

    procedure Send(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var TempBlob: codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; var IsAsync: Boolean)
    begin
        PageroProcessing.SendEDocument(EDocument, EDocumentService, TempBlob, IsAsync, HttpRequest, HttpResponse);
    end;

    procedure SendBatch(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var TempBlob: codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; var IsAsync: Boolean)
    begin
        IsAsync := false;
        Error('Batch sending is not supported in this version');
    end;

    procedure GetResponse(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    begin
        exit(PageroProcessing.GetDocumentResponse(EDocument, EDocumentService, HttpRequest, HttpResponse));
    end;

    procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; var TempBlob: codeunit "Temp Blob"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage; var Count: Integer)
    begin
        PageroProcessing.ReceiveDocument(EDocumentService, TempBlob, HttpRequestMessage, HttpResponseMessage, Count);
    end;

    procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var DocumentsBlob: codeunit "Temp Blob"; var DocumentBlob: codeunit "Temp Blob"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    begin
        PageroProcessing.DownloadDocument(EDocument, EDocumentService, DocumentsBlob, DocumentBlob, HttpRequestMessage, HttpResponseMessage);
    end;

    procedure GetSentDocumentApprovalStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; var Status: Enum "E-Document Service Status"): Boolean
    begin
        exit(PageroProcessing.GetDocumentApproval(EDocument, EDocumentService, HttpRequest, HttpResponse, Status));
    end;

    procedure GetSentDocumentCancelationStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; var Status: Enum "E-Document Service Status"): Boolean
    begin
        exit(PageroProcessing.CancelEDocument(EDocument, EDocumentService, HttpRequest, HttpResponse, Status));
    end;

    procedure OpenServiceIntegrationSetupPage(var EDocumentService: Record "E-Document Service"): Boolean
    var
        SetupCard: Page "EDoc Ext Connection Setup Card";
    begin
        SetupCard.Run();
        exit(true);
    end;

    var
        PageroProcessing: Codeunit "Pagero Processing";
}