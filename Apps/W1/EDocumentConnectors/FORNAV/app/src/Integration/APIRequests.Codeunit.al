namespace Microsoft.EServices.EDocumentConnector.ForNAV;

using Microsoft.EServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Send;
using System.Utilities;
using System.Xml;
using Microsoft.eServices.EDocument.Integration.Receive;
using Microsoft.eServices.EDocument.Integration;
using Microsoft.eServices.EDocument.Service.Participant;

codeunit 6414 "ForNAV API Requests"
{
    Access = Internal;

    // OnPrem only 
    internal procedure SendDocumentsDeleteRequest(Http: Codeunit "Http Message State"; RecKeys: JsonArray): Boolean
    var
        Setup: Codeunit "ForNAV Peppol Setup";
        Payload: Text;
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        HttpContent: HttpContent;
        JObject: JsonObject;
    begin
        ResetRequest('Inbox', 'DELETE', Http);
        HttpContent.GetHeaders(HttpHeaders);

        JObject.Add('ids', RecKeys);
        JObject.WriteTo(Payload);
        HttpContent.WriteFrom(Payload);
        Http.GetHttpRequestMessage().Content := HttpContent;
        if HttpHeaders.Contains('Content-Type') then
            HttpHeaders.Remove('Content-Type');
        HttpHeaders.Add('Content-Type', 'application/json');
        Setup.Send(HttpClient, Http);
    end;

    internal procedure SendDocumentsGetRequest(): Boolean
    var
        Http: Codeunit "Http Message State";
        Setup: Codeunit "ForNAV Peppol Setup";
        Inbox: Codeunit "ForNAV Inbox";
        HttpClient: HttpClient;
        Json: Text;
        JObject: JsonObject;
        RecKeys: JsonArray;
        More: Boolean;
    begin
        repeat
            ResetRequest('Inbox', 'GET', Http);

            if Setup.Send(HttpClient, Http) = 200 then begin
                Http.GetHttpResponseMessage().Content.ReadAs(Json);
                JObject.ReadFrom(Json);
                More := Inbox.GetDocsFromJson(RecKeys, JObject);
                SendDocumentsDeleteRequest(Http, RecKeys);
            end;
        until not More;

        Http.GetHttpRequestMessage().SetRequestUri('https://SendDocumentsGetRequest');
        exit(Http.GetHttpResponseMessage().IsSuccessStatusCode);
    end;

    internal procedure SendFilePostRequest(var EDocument: Record "E-Document"; SendContext: Codeunit SendContext): Boolean
    var
        ServiceParticipant: Record "Service Participant";
        Setup: Codeunit "ForNAV Peppol Setup";
        Payload: Text;
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        HttpContent: HttpContent;
    begin
        Payload := TempBlobToTxt(SendContext.GetTempBlob());
        if Payload = '' then
            exit(false);

        ResetRequest('Outgoing', 'POST', SendContext.Http());
        SendContext.Http().GetHttpRequestMessage().GetHeaders(HttpHeaders);
        HttpHeaders.Add('Accept', '*/*');
        case EDocument."Source Type" of
            EDocument."Source Type"::Customer:
                if ServiceParticipant.Get('FORNAV', "E-Document Source Type"::Customer, EDocument."Bill-to/Pay-to No.") then
                    HttpHeaders.Add('receiver-peppolid', ServiceParticipant."Participant Identifier");
            EDocument."Source Type"::Vendor:
                if ServiceParticipant.Get('FORNAV', "E-Document Source Type"::Vendor, EDocument."Bill-to/Pay-to No.") then
                    HttpHeaders.Add('receiver-peppolid', ServiceParticipant."Participant Identifier");
        end;

        SendContext.Http().GetHttpRequestMessage().Method('POST');

        HttpContent.WriteFrom(Payload);
        HttpContent.GetHeaders(HttpHeaders);
        if HttpHeaders.Contains('Content-Type') then
            HttpHeaders.Remove('Content-Type');
        HttpHeaders.Add('Content-Type', 'application/xml');

        SendContext.Http().GetHttpRequestMessage().Content := HttpContent;

        Setup.Send(HttpClient, SendContext.Http());

        SendContext.Http().GetHttpRequestMessage().SetRequestUri('https://SendFilePostRequest');
        exit(SendContext.Http().GetHttpResponseMessage().IsSuccessStatusCode);
    end;

    internal procedure SendActionPostRequest(EDocument: Record "E-Document"; ActionName: Text; SendContext: Codeunit SendContext): Boolean
    var
        Log: Record "E-Document Integration Log";
        Processing: Codeunit "ForNAV Processing";
    begin
        ClearRequest(SendContext.Http(), 'https://SendActionPostRequest');
        if ActionName = 'Restart' then begin
            Log := EDocument.DocumentLog();
            if Log."Request Blob".HasValue then begin
                SendContext.GetTempBlob().FromRecord(Log, Log.FieldNo("Request Blob"));
                Processing.SendEDocument(EDocument, SendContext);
                exit(SendContext.Http().GetHttpResponseMessage().IsSuccessStatusCode);
            end;
        end;
        exit(false);
    end;

    internal procedure GetReceivedDocumentsRequest(ReceiveContext: Codeunit ReceiveContext; DocumentsMetadata: Codeunit "Temp Blob List"): Boolean
    var
        IncomingDoc: Codeunit "ForNAV Inbox";
    begin
        ClearRequest(ReceiveContext.Http(), 'https://GetReceivedDocumentsRequest');
        exit(IncomingDoc.GetIncomingBussinessDocs(DocumentsMetadata));
    end;

    internal procedure GetTargetDocumentRequest(DocumentId: Text; ReceiveContext: Codeunit ReceiveContext): Boolean
    var
        IncomingDoc: Codeunit "ForNAV Inbox";
    begin
        ClearRequest(ReceiveContext.Http(), 'https://GetTargetDocumentRequest');
        exit(IncomingDoc.GetIncomingDoc(DocumentId, ReceiveContext));
    end;

    internal procedure SendFetchDocumentRequest(DocumentId: JsonArray; SendContext: Codeunit SendContext): Boolean
    var
        IncomingDoc: Codeunit "ForNAV Inbox";
    begin
        ClearRequest(SendContext.Http(), 'https://SendFetchDocumentRequest');
        exit(IncomingDoc.DeleteDocs(DocumentId, SendContext));
    end;

    local procedure ClearRequest(Http: Codeunit "Http Message State"; Url: Text)
    var
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
    begin
        Clear(HttpRequestMessage);
        HttpRequestMessage.SetRequestUri(Url);
        Http.SetHttpRequestMessage(HttpRequestMessage);
        Clear(HttpResponseMessage);
        Http.SetHttpResponseMessage(HttpResponseMessage);
    end;

    local procedure ResetRequest(Endpoint: Text; Method: Text; Http: Codeunit "Http Message State")
    var
        PeppolSetup: Codeunit "ForNAV Peppol Setup";
        Url: Text;
    begin
        Url := PeppolSetup.GetBaseUrl(Endpoint);
        ClearRequest(Http, Url);
        Http.GetHttpRequestMessage().Method(Method);
    end;

    local procedure TempBlobToTxt(TempBlob: Codeunit "Temp Blob"): Text
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        InStr: InStream;
        Content: Text;
    begin
        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
        XMLDOMManagement.TryGetXMLAsText(InStr, Content);
        exit(Content);
    end;
}