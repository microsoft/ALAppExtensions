// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

using Microsoft.EServices.EDocument;
using System.Utilities;

codeunit 6363 "Pagero API Requests"
{
    Access = Internal;

    trigger OnRun()
    begin

    end;

    procedure SendFilePostRequest(var TempBlob: Codeunit "Temp Blob"; EDocument: Record "E-Document"): Boolean
    // https://api.pageroonline.com/file/v1/files
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
        ExternalConnectionSetup.Get();
        Payload := PageroConnection.TempBlobToTxt(TempBlob);
        if Payload = '' then
            exit(false);

        HttpClient.Clear();
        HttpClient.Timeout(60000);
        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();

        HttpHeaders.Add('Authorization', PageroAuthMgt.GetAuthBearerTxt());
        HttpHeaders.Add('Accept', '*/*');
        HttpRequestMessage.Method('POST');
        HttpRequestMessage.SetRequestUri(ExternalConnectionSetup."FileAPI URL");

        MultiPartContent :=
            PageroConnection.PrepareMultipartContent(
                'Invoice', GetSendMode(), ExternalConnectionSetup."Company Id", EDocument."Document No.", format(EDocument."Entry No"), Payload, Boundary);
        HttpContent.WriteFrom(MultiPartContent);

        if HttpHeaders.Contains('Content-Type') then
            HttpHeaders.Remove('Content-Type');
        HttpHeaders.Add('Content-Type', 'multipart/form-data; boundary="' + Boundary + '"');
        HttpRequestMessage.Content := HttpContent;

        exit(HttpClient.Send(HttpRequestMessage, HttpResponseMessage));
    end;

    procedure SendActionPostRequest(EDocument: Record "E-Document"; ActionName: Text): Boolean
    // https://api.pageroonline.com/file/v1/fileparts/{id}/action
    // Restart, Cancel
    var
        ExternalConnectionSetup: Record "E-Doc. Ext. Connection Setup";
        PageroAuthMgt: Codeunit "Pagero Auth.";
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        Payload: Text;
        EndpointUrl: Text;
        JsonObj: JsonObject;
    begin
        ExternalConnectionSetup.Get();

        HttpClient.Clear();
        HttpClient.Timeout(60000);
        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();

        HttpHeaders.Add('Authorization', PageroAuthMgt.GetAuthBearerTxt());
        HttpHeaders.Add('Accept', '*/*');
        HttpRequestMessage.Method('POST');

        EndpointUrl := ExternalConnectionSetup."Fileparts URL" + EDocument."Filepart ID" + '/action';
        HttpRequestMessage.SetRequestUri(EndpointUrl);
        JsonObj.Add('action', ActionName);
        JsonObj.WriteTo(Payload);
        HttpRequestMessage.Content.WriteFrom(Payload);

        exit(HttpClient.Send(HttpRequestMessage, HttpResponseMessage));
    end;

    procedure GetFilepartsErrorRequest(EDocument: Record "E-Document"): Boolean
    // https://api.pageroonline.com/file/v1/files/{fileId}/fileparts?Status=AwaitingInteraction,Error
    var
        ExternalConnectionSetup: Record "E-Doc. Ext. Connection Setup";
        PageroAuth: Codeunit "Pagero Auth.";

        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;

        EndpointURL: Text;
    begin
        ExternalConnectionSetup.Get();
        HttpClient.Clear();
        HttpClient.Timeout(60000);

        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        HttpHeaders.Add('Authorization', PageroAuth.GetAuthBearerTxt());
        HttpHeaders.Add('Accept', 'application/json');
        HttpRequestMessage.Method('GET');

        EndpointURL := ExternalConnectionSetup."FileAPI URL" + '/' + EDocument."File ID" + '/fileparts?Status=AwaitingInteraction,Error';
        HttpRequestMessage.SetRequestUri(EndpointURL);

        exit(HttpClient.Send(HttpRequestMessage, HttpResponseMessage));
    end;

    procedure GetADocument(EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"): Boolean
    // https://api.pageroonline.com/document/v1/documents/{id}
    var
        ExternalConnectionSetup: Record "E-Doc. Ext. Connection Setup";
        PageroAuth: Codeunit "Pagero Auth.";
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        EndpointURL: Text;
    begin
        ExternalConnectionSetup.Get();
        HttpClient.Clear();
        HttpClient.Timeout(60000);

        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();

        HttpHeaders.Add('Authorization', PageroAuth.GetAuthBearerTxt());
        HttpHeaders.Add('Accept', 'application/json');

        HttpRequestMessage.Method('GET');
        EndpointURL := ExternalConnectionSetup."DocumentAPI Url" + '/?fileId=' + EDocument."File ID";
        HttpRequestMessage.SetRequestUri(EndpointURL);

        exit(HttpClient.Send(HttpRequestMessage, HttpResponseMessage));
    end;


    procedure GetReceivedDocumentsRequest(): Boolean
    // https://api.pageroonline.com/document/v1/documents
    var
        ExternalConnectionSetup: Record "E-Doc. Ext. Connection Setup";
        PageroAuth: Codeunit "Pagero Auth.";
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        EndpointURL: Text;
    begin
        ExternalConnectionSetup.Get();
        HttpClient.Clear();
        HttpClient.Timeout(60000);

        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();

        HttpHeaders.Add('Authorization', PageroAuth.GetAuthBearerTxt());
        HttpHeaders.Add('Accept', 'application/json');

        HttpRequestMessage.Method('GET');
        EndpointURL := ExternalConnectionSetup."DocumentAPI Url" + '/?direction=Received&documentType=ApplicationResponse';
        HttpRequestMessage.SetRequestUri(EndpointURL);

        exit(HttpClient.Send(HttpRequestMessage, HttpResponseMessage));
    end;


    procedure GetTargetDocumentRequest(EDocument: Record "E-Document"): Boolean
    // https://api.pageroonline.com/document/v1/documents/{id}/targetdocument
    var
        ExternalConnectionSetup: Record "E-Doc. Ext. Connection Setup";
        PageroAuth: Codeunit "Pagero Auth.";
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        EndpointURL: Text;
    begin
        ExternalConnectionSetup.Get();
        HttpClient.Clear();
        HttpClient.Timeout(60000);

        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();

        HttpHeaders.Add('Authorization', PageroAuth.GetAuthBearerTxt());
        HttpHeaders.Add('Accept', 'application/json');
        HttpRequestMessage.Method('GET');

        EndpointURL := ExternalConnectionSetup."DocumentAPI URL" + '/' + EDocument."Document Id" + '/targetdocument';
        HttpRequestMessage.SetRequestUri(EndpointURL);

        exit(HttpClient.Send(HttpRequestMessage, HttpResponseMessage));
    end;

    procedure GetAppResponseDocumentsRequest(EDocument: Record "E-Document"): Boolean
    // https://api.pageroonline.com/document/v1/documents
    var
        ExternalConnectionSetup: Record "E-Doc. Ext. Connection Setup";
        PageroAuth: Codeunit "Pagero Auth.";
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        EndpointURL: Text;
    begin
        ExternalConnectionSetup.Get();
        HttpClient.Clear();
        HttpClient.Timeout(60000);

        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();

        HttpHeaders.Add('Authorization', PageroAuth.GetAuthBearerTxt());
        HttpHeaders.Add('Accept', 'application/json');

        HttpRequestMessage.Method('GET');
        EndpointURL :=
            ExternalConnectionSetup."DocumentAPI Url" + '/?direction=Received&documentType=ApplicationResponse&referenceDocumentIdentifier=' + Format(EDocument."Entry No");
        HttpRequestMessage.SetRequestUri(EndpointURL);

        exit(HttpClient.Send(HttpRequestMessage, HttpResponseMessage));
    end;

    procedure IsNotAuthorized(): Boolean
    begin
        exit(HttpResponseMessage.HttpStatusCode() = 401);
    end;

    procedure GetRequestResponse(var HttpRequest2: HttpRequestMessage; var HttpResponse2: HttpResponseMessage)
    begin
        HttpRequest2 := HttpRequestMessage;
        HttpResponse2 := HttpResponseMessage;
    end;

    local procedure GetSendMode(): Text
    begin
        exit('Production');
    end;

    var
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
}