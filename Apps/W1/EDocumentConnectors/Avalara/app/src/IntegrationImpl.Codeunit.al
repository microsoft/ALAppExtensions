// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Avalara;

using System.Utilities;
using Microsoft.EServices.EDocument;

codeunit 6372 "Integration Impl." implements "E-Document Integration"
{
    Access = Internal;

    procedure Send(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    var
    begin
        this.AvalaraProcessing.SendEDocument(EDocument, TempBlob, IsAsync, HttpRequest, HttpResponse);
    end;

    procedure SendBatch(var EDocuments: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    begin
        IsAsync := false;
        Error(BatchSendingErr);
    end;

    procedure GetResponse(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    begin
        exit(this.AvalaraProcessing.GetDocumentStatus(EDocument, HttpRequest, HttpResponse));
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
        this.AvalaraProcessing.ReceiveDocument(TempBlob, HttpRequest, HttpResponse);
    end;

    procedure GetDocumentCountInBatch(var TempBlob: Codeunit "Temp Blob"): Integer
    begin
        exit(this.AvalaraProcessing.GetDocumentCountInBatch(TempBlob));
    end;

    procedure GetIntegrationSetup(var SetupPage: Integer; var SetupTable: Integer)
    begin
        SetupPage := page::"Connection Setup Card";
        SetupTable := Database::"Connection Setup";
    end;

    var
        AvalaraProcessing: Codeunit Processing;
        BatchSendingErr: Label 'Batch sending is not supported in this version.';
        ApprovalErr: Label 'Approvals are not supported in this version.';
        CancelErr: Label 'Cancel is not supported in this version';
}