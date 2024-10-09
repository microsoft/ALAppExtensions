// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

using System.Utilities;
using Microsoft.EServices.EDocument;

codeunit 6390 "Integration Impl." implements "E-Document Integration"
{
    Access = Internal;

    procedure Send(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    var
        EDocumentProcessing: Codeunit "EDocument Processing";
    begin
        IsAsync := true;
        EDocumentProcessing.SendEDocument(EDocument, TempBlob, HttpRequest, HttpResponse);
    end;

    procedure SendBatch(var EDocuments: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    begin
        IsAsync := false;
        Error('Batch sending is not supported in this version');
    end;

    procedure GetResponse(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    var
        EDocumentProcessing: Codeunit "EDocument Processing";
    begin
        exit(EDocumentProcessing.GetTechnicalResponse(EDocument, HttpRequest, HttpResponse));
    end;

    procedure GetApproval(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    var
        EDocumentProcessing: Codeunit "EDocument Processing";
    begin
        exit(EDocumentProcessing.GetLastDocumentBusinessResponses(EDocument, HttpRequest, HttpResponse));
    end;

    procedure Cancel(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    var
        ApiRequests: Codeunit "Api Requests";
        DocumentId: Guid;
    begin
        Evaluate(DocumentId, EDocument."Document Id");
        ApiRequests.CancelDocument(DocumentId, HttpRequest, HttpResponse);
    end;

    procedure ReceiveDocument(var TempBlob: Codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    var
        ApiRequests: Codeunit "Api Requests";
        OutStream: OutStream;
        ContentData: Text;
    begin
        if not ApiRequests.GetDocumentsForCompany(HttpRequest, HttpResponse) then
            exit;

        HttpResponse.Content.ReadAs(ContentData);

        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(ContentData);
    end;

    procedure GetDocumentCountInBatch(var TempBlob: Codeunit "Temp Blob"): Integer
    var
        ResponseInstream: InStream;
        ResponseTxt: Text;
        Buffer: Text;
    begin
        TempBlob.CreateInStream(ResponseInstream);
        while not ResponseInstream.EOS do begin
            ResponseInstream.ReadText(Buffer);
            ResponseTxt := ResponseTxt + Buffer;
        end;

        exit(GetNumberOfReceivedDocuments(ResponseTxt));
    end;

    internal procedure GetNumberOfReceivedDocuments(DocumentResponseText: Text): Integer
    var
        DocumentResponse: XmlDocument;
        DocumentList: XmlNodeList;
    begin
        if not XmlDocument.ReadFrom(DocumentResponseText, DocumentResponse) then
            exit(0);

        if not DocumentResponse.SelectNodes('/documents/document', DocumentList) then
            exit(0);

        exit(DocumentList.Count);
    end;

    procedure GetIntegrationSetup(var SetupPage: Integer; var SetupTable: Integer)
    begin
        SetupPage := Page::"Ext. Connection Setup";
        SetupTable := Database::"Connection Setup";
    end;

    [EventSubscriber(ObjectType::Page, Page::"E-Document Service", 'OnAfterValidateEvent', "Service Integration", true, true)]
    local procedure OnAfterValidateServiceIntegration(var Rec: Record "E-Document Service")
    begin
        if Rec."Service Integration" <> Rec."Service Integration"::Continia then
            exit;

        if Rec."Document Format" = Rec."Document Format"::"Data Exchange" then
            Error(DocumentFormatUnsupportedErr);
    end;

    [EventSubscriber(ObjectType::Page, Page::"E-Document Service", 'OnAfterValidateEvent', "Export Format", true, true)]
    local procedure OnAfterValidateDocumentFormat(var Rec: Record "E-Document Service")
    begin
        if Rec."Service Integration" <> Rec."Service Integration"::Continia then
            exit;

        if Rec."Document Format" = Rec."Document Format"::"Data Exchange" then
            Error(DocumentFormatUnsupportedErr);
    end;

    var
        DocumentFormatUnsupportedErr: Label 'Data Exchange is not supported with the Continia Service Integration in this version';
}