// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

using Microsoft.EServices.EDocument;
using System.Utilities;
using System.Xml;

codeunit 6363 "Pagero API Requests"
{
    Access = Internal;

    // https://api.pageroonline.com/file/v1/files
    procedure SendFilePostRequest(var TempBlob: Codeunit "Temp Blob"; EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        ExternalConnectionSetup: Record "E-Doc. Ext. Connection Setup";
        PageroConnection: Codeunit "Pagero Connection";
        PageroAuthMgt: Codeunit "Pagero Auth.";
        Payload: Text;
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        HttpContent: HttpContent;
        MultipartContent: Text;
        Boundary: Text;
    begin
        InitRequest(ExternalConnectionSetup, HttpRequestMessage, HttpResponseMessage);

        Payload := TempBlobToTxt(TempBlob);
        if Payload = '' then
            exit(false);

        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Authorization', PageroAuthMgt.GetAuthBearerTxt());
        HttpHeaders.Add('Accept', '*/*');
        HttpRequestMessage.Method('POST');
        HttpRequestMessage.SetRequestUri(ExternalConnectionSetup."FileAPI URL");

        MultiPartContent :=
            PageroConnection.PrepareMultipartContent(
                GetDocumentType(EDocument), GetSendMode(ExternalConnectionSetup), ExternalConnectionSetup."Company Id", Format(EDocument."Entry No"), EDocument."Document No.", Payload, Boundary);
        HttpContent.WriteFrom(MultiPartContent);
        HttpContent.GetHeaders(HttpHeaders);

        if HttpHeaders.Contains('Content-Type') then
            HttpHeaders.Remove('Content-Type');
        HttpHeaders.Add('Content-Type', 'multipart/form-data; boundary="' + Boundary + '"');
        HttpRequestMessage.Content := HttpContent;

        exit(HttpClient.Send(HttpRequestMessage, HttpResponseMessage));
    end;

    // https://api.pageroonline.com/file/v1/fileparts/{id}/action
    // Restart, Cancel
    procedure SendActionPostRequest(EDocument: Record "E-Document"; ActionName: Text; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        ExternalConnectionSetup: Record "E-Doc. Ext. Connection Setup";
        PageroAuthMgt: Codeunit "Pagero Auth.";
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        Payload: Text;
        EndpointUrl: Text;
        JsonObj: JsonObject;
    begin
        InitRequest(ExternalConnectionSetup, HttpRequestMessage, HttpResponseMessage);

        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Authorization', PageroAuthMgt.GetAuthBearerTxt());
        HttpHeaders.Add('Accept', '*/*');
        HttpRequestMessage.Method('POST');

        EndpointUrl := ExternalConnectionSetup."Fileparts URL" + '/' + EDocument."Filepart ID" + '/action';
        HttpRequestMessage.SetRequestUri(EndpointUrl);
        JsonObj.Add('action', ActionName);
        JsonObj.WriteTo(Payload);
        HttpRequestMessage.Content.WriteFrom(Payload);

        exit(HttpClient.Send(HttpRequestMessage, HttpResponseMessage));
    end;

    // https://api.pageroonline.com/file/v1/files/{fileId}/fileparts?Status=AwaitingInteraction,Error
    procedure GetFilepartsErrorRequest(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        ExternalConnectionSetup: Record "E-Doc. Ext. Connection Setup";
        PageroAuth: Codeunit "Pagero Auth.";
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        EndpointURL: Text;
    begin
        InitRequest(ExternalConnectionSetup, HttpRequestMessage, HttpResponseMessage);

        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Authorization', PageroAuth.GetAuthBearerTxt());
        HttpHeaders.Add('Accept', 'application/json');
        HttpRequestMessage.Method('GET');

        EndpointURL := ExternalConnectionSetup."FileAPI URL" + '/' + EDocument."File ID" + '/fileparts?Status=AwaitingInteraction,Error';
        HttpRequestMessage.SetRequestUri(EndpointURL);

        exit(HttpClient.Send(HttpRequestMessage, HttpResponseMessage));
    end;

    // https://api.pageroonline.com/document/v1/documents/{id}
    procedure GetADocument(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        ExternalConnectionSetup: Record "E-Doc. Ext. Connection Setup";
        PageroAuth: Codeunit "Pagero Auth.";
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        EndpointURL: Text;
    begin
        InitRequest(ExternalConnectionSetup, HttpRequestMessage, HttpResponseMessage);

        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Authorization', PageroAuth.GetAuthBearerTxt());
        HttpHeaders.Add('Accept', 'application/json');

        HttpRequestMessage.Method('GET');
        EndpointURL := ExternalConnectionSetup."DocumentAPI Url" + '?fileId=' + EDocument."File ID";
        HttpRequestMessage.SetRequestUri(EndpointURL);

        exit(HttpClient.Send(HttpRequestMessage, HttpResponseMessage));
    end;

    // https://api.pageroonline.com/document/v1/documents
    procedure GetReceivedDocumentsRequest(var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage; Parameters: Dictionary of [Text, Text]): Boolean
    var
        ExternalConnectionSetup: Record "E-Doc. Ext. Connection Setup";
        PageroAuth: Codeunit "Pagero Auth.";
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        EndpointURL: Text;
    begin
        InitRequest(ExternalConnectionSetup, HttpRequestMessage, HttpResponseMessage);

        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Authorization', PageroAuth.GetAuthBearerTxt());
        HttpHeaders.Add('Accept', 'application/json');

        HttpRequestMessage.Method('GET');
        EndpointURL :=
            ExternalConnectionSetup."DocumentAPI Url" +
            '?direction=Received&documentType=Invoice&documentType=PaymentReminder&showFetchedOnly=false&companyId=' + ExternalConnectionSetup."Company Id";
        if Parameters.ContainsKey('limit') then
            if Parameters.Get('limit') <> '' then
                EndpointURL += '&limit=' + Parameters.Get('limit');
        if Parameters.ContainsKey('offset') then
            if Parameters.Get('offset') <> '' then
                EndpointURL += '&offset=' + Parameters.Get('offset');
        HttpRequestMessage.SetRequestUri(EndpointURL);

        exit(HttpClient.Send(HttpRequestMessage, HttpResponseMessage));
    end;

    // https://api.pageroonline.com/document/v1/documents/{id}/targetdocument
    procedure GetTargetDocumentRequest(DocumentId: Text; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        ExternalConnectionSetup: Record "E-Doc. Ext. Connection Setup";
        PageroAuth: Codeunit "Pagero Auth.";
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        EndpointURL: Text;
    begin
        InitRequest(ExternalConnectionSetup, HttpRequestMessage, HttpResponseMessage);

        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Authorization', PageroAuth.GetAuthBearerTxt());
        HttpHeaders.Add('Accept', 'application/json');
        HttpRequestMessage.Method('GET');

        EndpointURL := ExternalConnectionSetup."DocumentAPI URL" + '/' + DocumentId + '/targetdocument';
        HttpRequestMessage.SetRequestUri(EndpointURL);

        exit(HttpClient.Send(HttpRequestMessage, HttpResponseMessage));
    end;

    // https://api.pageroonline.com/document/v1/documents
    procedure GetAppResponseDocumentsRequest(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        ExternalConnectionSetup: Record "E-Doc. Ext. Connection Setup";
        PageroAuth: Codeunit "Pagero Auth.";
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        EndpointURL: Text;
    begin
        InitRequest(ExternalConnectionSetup, HttpRequestMessage, HttpResponseMessage);

        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Authorization', PageroAuth.GetAuthBearerTxt());
        HttpHeaders.Add('Accept', 'application/json');

        HttpRequestMessage.Method('GET');
        EndpointURL :=
            ExternalConnectionSetup."DocumentAPI Url" +
            '?documentType=ApplicationResponse&direction=Received&showFetchedOnly=false&senderReference=' + EDocument."Document No.";
        HttpRequestMessage.SetRequestUri(EndpointURL);

        exit(HttpClient.Send(HttpRequestMessage, HttpResponseMessage));
    end;

    // https://api.pageroonline.com/document/v1/documents/fetch
    procedure SendFetchDocumentRequest(DocumentId: JsonArray; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        ExternalConnectionSetup: Record "E-Doc. Ext. Connection Setup";
        PageroAuthMgt: Codeunit "Pagero Auth.";
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        Payload: Text;
        EndpointUrl: Text;
        JsonObj: JsonObject;
    begin
        InitRequest(ExternalConnectionSetup, HttpRequestMessage, HttpResponseMessage);

        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Authorization', PageroAuthMgt.GetAuthBearerTxt());
        HttpHeaders.Add('Accept', '*/*');
        HttpRequestMessage.Method('POST');

        EndpointUrl := ExternalConnectionSetup."DocumentAPI URL" + '/fetch';
        HttpRequestMessage.SetRequestUri(EndpointUrl);
        JsonObj.Add('ids', DocumentId);
        JsonObj.WriteTo(Payload);
        HttpRequestMessage.Content.WriteFrom(Payload);

        HttpRequestMessage.Content.GetHeaders(HttpHeaders);
        if HttpHeaders.Contains('Content-Type') then
            HttpHeaders.Remove('Content-Type');
        HttpHeaders.Add('Content-Type', 'application/json');

        exit(HttpClient.Send(HttpRequestMessage, HttpResponseMessage));
    end;

    local procedure InitRequest(var ExternalConnectionSetup: Record "E-Doc. Ext. Connection Setup"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    begin
        Clear(HttpRequestMessage);
        Clear(HttpResponseMessage);
        if not ExternalConnectionSetup.Get() then
            Error(MissingSetupErr);
        ExternalConnectionSetup.TestField("Send Mode");
        ExternalConnectionSetup.TestField("Company Id");
    end;

    local procedure TempBlobToTxt(var TempBlob: Codeunit "Temp Blob"): Text
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        InStr: InStream;
        Content: Text;
    begin
        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
        XMLDOMManagement.TryGetXMLAsText(InStr, Content);
        exit(Content);
    end;

    local procedure GetSendMode(ExternalConnectionSetup: Record "E-Doc. Ext. Connection Setup"): Text
    begin
        exit(Format(ExternalConnectionSetup."Send Mode"));
    end;

    local procedure GetDocumentType(EDocument: Record "E-Document"): Text
    begin
        if EDocument.Direction = EDocument.Direction::Incoming then
            exit('ApplicationResponse');

        case EDocument."Document Type" of
            "E-Document Type"::"Sales Invoice", "E-Document Type"::"Sales Credit Memo", "E-Document Type"::"Service Invoice", "E-Document Type"::"Service Credit Memo":
                exit('Invoice');
            "E-Document Type"::"Issued Finance Charge Memo", "E-Document Type"::"Issued Reminder":
                exit('PaymentReminder');
        end;
    end;

    var
        MissingSetupErr: Label 'You must set up service integration in the E-Document service card.';
}