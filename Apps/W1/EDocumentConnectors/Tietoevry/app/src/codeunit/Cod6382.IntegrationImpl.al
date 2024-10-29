// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Tietoevry;

using System.Utilities;
using Microsoft.EServices.EDocument;

codeunit 6382 "Integration Impl." implements "E-Document Integration"
{
    Access = Internal;

    procedure Send(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    var
    begin
        TietoevryProcessing.SendEDocument(EDocument, TempBlob, IsAsync, HttpRequest, HttpResponse);
    end;

    procedure SendBatch(var EDocuments: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    begin
        IsAsync := false;
        Error('Batch sending is not supported in this version');
    end;

    procedure GetResponse(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    begin
        exit(TietoevryProcessing.GetDocumentResponse(EDocument, HttpRequest, HttpResponse));
    end;

    procedure GetApproval(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    begin
        Error('Get Approval is not supported in this version');
    end;

    procedure Cancel(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    begin
        exit(TietoevryProcessing.CancelEDocument(EDocument, HttpRequest, HttpResponse));
    end;

    procedure ReceiveDocument(var TempBlob: Codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    begin
        TietoevryProcessing.ReceiveDocument(TempBlob, HttpRequest, HttpResponse);
    end;

    procedure GetDocumentCountInBatch(var TempBlob: Codeunit "Temp Blob"): Integer
    begin
        exit(TietoevryProcessing.GetDocumentCountInBatch(TempBlob));
    end;

    procedure GetIntegrationSetup(var SetupPage: Integer; var SetupTable: Integer)
    begin
        SetupPage := page::"Connection Setup Card";
        SetupTable := Database::"Connection Setup";
    end;

    var
        TietoevryProcessing: Codeunit "Processing";
}