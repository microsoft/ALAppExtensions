// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

using Microsoft.EServices.EDocument;
using System.Utilities;
using System.Text;
using System.Xml;
using System.Reflection;

codeunit 96363 "Tietoevry API Requests"
{
    Access = Internal;

    procedure SendDocumentRequest(var TempBlob: Codeunit "Temp Blob"; EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        ExternalConnectionSetup: Record "Tietoevry Connection Setup";
        TietoevryAuthMgt: Codeunit "Tietoevry Auth.";
        Base64Convert: Codeunit "Base64 Convert";
        Payload: Text;
        Content: Text;
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        HttpContent: HttpContent;
        ContentJson: JsonObject;
    begin
        InitRequest(ExternalConnectionSetup, HttpRequestMessage, HttpResponseMessage);

        Payload := TempBlobToTxt(TempBlob);
        if Payload = '' then
            exit(false);

        EDocument.Get(EDocument."Entry No"); //Refresh
        ContentJson.Add('payload', Base64Convert.ToBase64(Payload));
        ContentJson.Add('sender', ExternalConnectionSetup."Company Id");
        ContentJson.Add('receiver', EDocument."Bill-to/Pay-to Id");
        ContentJson.Add('profileId', EDocument."Message Profile Id");
        ContentJson.Add('documentId', EDocument."Message Document Id");
        ContentJson.Add('channel', 'PEPPOL');
        ContentJson.Add('reference', Format(EDocument."Entry No"));
        ContentJson.WriteTo(Content);

        if HttpClient.DefaultRequestHeaders.Contains('Authorization') then
            HttpClient.DefaultRequestHeaders.Remove('Authorization');
        HttpClient.DefaultRequestHeaders.Add('Authorization', TietoevryAuthMgt.GetAuthBearerTxt());

        HttpRequestMessage.Method('POST');
        HttpRequestMessage.SetRequestUri(ExternalConnectionSetup."Outbound API URL");

        HttpContent.WriteFrom(Content);

        HttpContent.GetHeaders(HttpHeaders);
        if HttpHeaders.Contains('Content-Type') then
            HttpHeaders.Remove('Content-Type');
        HttpHeaders.Add('Content-Type', 'application/json');

        HttpRequestMessage.Content := HttpContent;

        exit(HttpClient.Send(HttpRequestMessage, HttpResponseMessage));
    end;

    procedure GetDocumentStatusRequest(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        ExternalConnectionSetup: Record "Tietoevry Connection Setup";
        TietoevryAuth: Codeunit "Tietoevry Auth.";
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        EndpointURL: Text;
    begin
        InitRequest(ExternalConnectionSetup, HttpRequestMessage, HttpResponseMessage);

        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Authorization', TietoevryAuth.GetAuthBearerTxt());
        HttpHeaders.Add('Accept', 'application/json');
        HttpRequestMessage.Method('GET');

        EndpointURL := ExternalConnectionSetup."Outbound API URL" + '/' + EDocument."Message Id";
        HttpRequestMessage.SetRequestUri(EndpointURL);

        exit(HttpClient.Send(HttpRequestMessage, HttpResponseMessage));
    end;

    procedure GetReceivedDocumentsRequest(var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        ExternalConnectionSetup: Record "Tietoevry Connection Setup";
        TypeHelper: Codeunit "Type Helper";
        TietoevryAuth: Codeunit "Tietoevry Auth.";
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        EndpointURL: Text;
    begin
        InitRequest(ExternalConnectionSetup, HttpRequestMessage, HttpResponseMessage);

        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Authorization', TietoevryAuth.GetAuthBearerTxt());
        HttpHeaders.Add('Accept', 'application/json');

        HttpRequestMessage.Method('GET');
        EndpointURL :=
            ExternalConnectionSetup."Inbound API URL" + '?receiver=' + TypeHelper.UrlEncode(ExternalConnectionSetup."Company Id");
        HttpRequestMessage.SetRequestUri(EndpointURL);

        exit(HttpClient.Send(HttpRequestMessage, HttpResponseMessage));
    end;

    procedure GetTargetDocumentRequest(DocumentId: Text; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        ExternalConnectionSetup: Record "Tietoevry Connection Setup";
        TietoevryAuth: Codeunit "Tietoevry Auth.";
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        EndpointURL: Text;
    begin
        InitRequest(ExternalConnectionSetup, HttpRequestMessage, HttpResponseMessage);

        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Authorization', TietoevryAuth.GetAuthBearerTxt());
        HttpHeaders.Add('Accept', 'application/octet-stream');

        HttpRequestMessage.Method('GET');
        EndpointURL := ExternalConnectionSetup."Inbound API URL" + '/' + DocumentId + '/PAYLOAD/document';
        HttpRequestMessage.SetRequestUri(EndpointURL);

        exit(HttpClient.Send(HttpRequestMessage, HttpResponseMessage));
    end;

    procedure SendAcknowledgeDocumentRequest(DocumentId: Text; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        ExternalConnectionSetup: Record "Tietoevry Connection Setup";
        TietoevryAuthMgt: Codeunit "Tietoevry Auth.";
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        EndpointUrl: Text;
    begin
        InitRequest(ExternalConnectionSetup, HttpRequestMessage, HttpResponseMessage);

        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Authorization', TietoevryAuthMgt.GetAuthBearerTxt());
        HttpHeaders.Add('Accept', '*/*');
        HttpRequestMessage.Method('POST');

        EndpointURL := ExternalConnectionSetup."Inbound API URL" + '/' + DocumentId + '/read';
        HttpRequestMessage.SetRequestUri(EndpointUrl);

        exit(HttpClient.Send(HttpRequestMessage, HttpResponseMessage));
    end;

    local procedure InitRequest(var ExternalConnectionSetup: Record "Tietoevry Connection Setup"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
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

    var
        MissingSetupErr: Label 'You must set up service integration in the E-Document service card.';

}