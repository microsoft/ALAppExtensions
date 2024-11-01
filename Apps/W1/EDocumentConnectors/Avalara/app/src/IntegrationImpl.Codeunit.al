// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Avalara;

using System.Utilities;
using Microsoft.eServices.EDocument.Integration.Interfaces;
using Microsoft.EServices.EDocument;

codeunit 6372 "Integration Impl." implements Sender, Receiver, "Default Int. Actions"
{
    Access = Internal;

    procedure Send(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    begin
        IsAsync := false;
    end;

    procedure SendBatch(var EDocuments: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    begin
        IsAsync := false;
        Error(BatchSendingErr);
    end;

    procedure GetResponse(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    begin
    end;

    procedure GetApproval(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    begin
        Error(ApprovalErr);
    end;

    procedure Cancel(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    begin
        Error(CancelErr);
    end;

    procedure ReceiveDocument(var TempBlob: Codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    begin
    end;

    procedure GetDocumentCountInBatch(var TempBlob: Codeunit "Temp Blob"): Integer
    begin
    end;

    procedure GetIntegrationSetup(var SetupPage: Integer; var SetupTable: Integer)
    begin
        SetupPage := 0;
        SetupTable := 0;
    end;


    procedure Send(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var TempBlob: codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; var IsAsync: Boolean)
    begin
        this.AvalaraProcessing.SendEDocument(EDocument, EDocumentService, TempBlob, IsAsync, HttpRequest, HttpResponse);
    end;

    procedure SendBatch(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var TempBlob: codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; var IsAsync: Boolean)
    begin
        IsAsync := false;
        Error(BatchSendingErr);
    end;

    procedure GetResponse(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    begin
        exit(this.AvalaraProcessing.GetDocumentStatus(EDocument, HttpRequest, HttpResponse));
    end;

    procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; var TempBlob: codeunit "Temp Blob"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage; var Count: Integer)
    begin
        this.AvalaraProcessing.ReceiveDocument(TempBlob, HttpRequestMessage, HttpResponseMessage, Count);
    end;

    procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var DocumentsBlob: codeunit "Temp Blob"; var DocumentBlob: codeunit "Temp Blob"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    begin
        this.AvalaraProcessing.DownloadDocument(EDocument, EDocumentService, DocumentsBlob, DocumentBlob, HttpRequestMessage, HttpResponseMessage);
    end;

    procedure GetSentDocumentApprovalStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; var Status: Enum "E-Document Service Status"): Boolean
    begin
        Error(ApprovalErr);
    end;

    procedure GetSentDocumentCancelationStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; var Status: Enum "E-Document Service Status"): Boolean
    begin
        Error(CancelErr);
    end;

    procedure OpenServiceIntegrationSetupPage(var EDocumentService: Record "E-Document Service"): Boolean
    var
        ConnectionSetup: Page "Connection Setup Card";
    begin
        ConnectionSetup.Run();
        exit(true);
    end;

    var
        AvalaraProcessing: Codeunit Processing;
        BatchSendingErr: Label 'Batch sending is not supported in this version.';
        ApprovalErr: Label 'Approvals are not supported in this version.';
        CancelErr: Label 'Cancel is not supported in this version';
}