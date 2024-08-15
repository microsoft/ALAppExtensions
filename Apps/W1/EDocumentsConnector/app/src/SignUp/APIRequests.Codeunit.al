// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using Microsoft.EServices.EDocument;
using System.Utilities;
using System.Xml;
using System.Security.Authentication;

codeunit 6370 SignUpAPIRequests
{
    Access = Internal;

    // https://edoc.exflowdev.cloud/api/Peppol
    procedure SendFilePostRequest(var TempBlob: Codeunit "Temp Blob"; EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        SignUpConnectionSetup: Record SignUpConnectionSetup;
        SignUpConnection: Codeunit SignUpConnection;
        Payload: Text;
        ContentHttpHeaders: HttpHeaders;
        HttpContent: HttpContent;
        ContentText: Text;
    begin
        InitRequest(SignUpConnectionSetup, HttpRequestMessage, HttpResponseMessage);
        HttpRequestMessage := PrepareRequestMsg("Http Request Type"::POST, SignUpConnectionSetup.ServiceURL);

        Payload := XmlToTxt(TempBlob);
        if Payload = '' then
            exit(false);
        Clear(HttpContent);
        ContentText := SignUpConnection.PrepareContentForSend(GetDocumentType(EDocument), SignUpConnectionSetup."Company Id", SignUpConnection.GetCustomerID(EDocument), SignUpConnection.GetSenderCountryCode(), Payload, SignUpConnectionSetup."Send Mode");
        HttpContent.WriteFrom(ContentText);
        HttpContent.GetHeaders(ContentHttpHeaders);
        if ContentHttpHeaders.Contains('Content-Type') then
            ContentHttpHeaders.Remove('Content-Type');
        ContentHttpHeaders.Add('Content-Type', 'application/json');
        HttpRequestMessage.Content(HttpContent);

        exit(SendRequest(HttpRequestMessage, HttpResponseMessage));
    end;

    // https://edoc.exflowdev.cloud/api/Peppol/status?peppolInstanceId=
    procedure GetSentDocumentStatus(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        SignUpConnectionSetup: Record SignUpConnectionSetup;
        UriTemplateLbl: Label '%1/status?peppolInstanceId=%2', Comment = '%1 = Service Url, %2 = Document ID', Locked = true;
    begin
        InitRequest(SignUpConnectionSetup, HttpRequestMessage, HttpResponseMessage);
        HttpRequestMessage := PrepareRequestMsg("Http Request Type"::GET, StrSubstNo(UriTemplateLbl, SignUpConnectionSetup.ServiceURL, EDocument."Document Id"));
        exit(SendRequest(HttpRequestMessage, HttpResponseMessage));
    end;

    // https://edoc.exflowdev.cloud/api/Peppol/outbox?peppolInstanceId=
    procedure PatchADocument(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        SignUpConnectionSetup: Record SignUpConnectionSetup;
        UriTemplateLbl: Label '%1/outbox?peppolInstanceId=%2', Comment = '%1 = Service Url, %2 = Document ID', Locked = true;
    begin
        InitRequest(SignUpConnectionSetup, HttpRequestMessage, HttpResponseMessage);
        HttpRequestMessage := PrepareRequestMsg("Http Request Type"::PATCH, StrSubstNo(UriTemplateLbl, SignUpConnectionSetup.ServiceURL, EDocument."Document Id"));
        exit(SendRequest(HttpRequestMessage, HttpResponseMessage));
    end;

    //  https://edoc.exflowdev.cloud/api/Peppol/Inbox?peppolId=
    procedure GetReceivedDocumentsRequest(var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage; Parameters: Dictionary of [Text, Text]): Boolean
    var
        SignUpConnectionSetup: Record SignUpConnectionSetup;
        SignUpConnection: Codeunit SignUpConnection;
        UriTemplateLbl: Label '%1/Inbox?peppolId=%2', Comment = '%1 = Service Url, %2 = Peppol Identifier', Locked = true;
    begin
        InitRequest(SignUpConnectionSetup, HttpRequestMessage, HttpResponseMessage);
        HttpRequestMessage := PrepareRequestMsg("Http Request Type"::GET, StrSubstNo(UriTemplateLbl, SignUpConnectionSetup.ServiceURL, SignUpConnection.GetSenderReceiverPrefix() + SignUpConnectionSetup."Company Id"));
        exit(SendRequest(HttpRequestMessage, HttpResponseMessage));
    end;

    // https://edoc.exflowdev.cloud/api/Peppol/inbox-document?peppolId=
    procedure GetTargetDocumentRequest(DocumentId: Text; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        SignUpConnectionSetup: Record SignUpConnectionSetup;
        SignUpConnection: Codeunit SignUpConnection;
        UriTemplateLbl: Label '%1/inbox-document?peppolId=%2&peppolInstanceId=%3', Comment = '%1 = Service Url, %2 = Peppol Identifier, %3 = Peppol Gateway Instance', Locked = true;
    begin
        InitRequest(SignUpConnectionSetup, HttpRequestMessage, HttpResponseMessage);
        HttpRequestMessage := PrepareRequestMsg("Http Request Type"::GET, StrSubstNo(UriTemplateLbl, SignUpConnectionSetup.ServiceURL, SignUpConnection.GetSenderReceiverPrefix() + SignUpConnectionSetup."Company Id", DocumentId));
        exit(SendRequest(HttpRequestMessage, HttpResponseMessage));
    end;

    // https://edoc.exflowdev.cloud/api/Peppol/inbox?peppolInstanceId=
    procedure PatchReceivedDocument(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        SignUpConnectionSetup: Record SignUpConnectionSetup;
    begin
        InitRequest(SignUpConnectionSetup, HttpRequestMessage, HttpResponseMessage);
        HttpRequestMessage := PrepareRequestMsg("Http Request Type"::PATCH, SignUpConnectionSetup.ServiceURL + '/inbox?peppolInstanceId=' + EDocument."Document Id");
        exit(SendRequest(HttpRequestMessage, HttpResponseMessage));
    end;

    procedure GetMarketPlaceCredentials(var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        SignUpConnectionSetup: Record SignUpConnectionSetup;
        SignUpAuth: Codeunit SignUpAuth;
        BaseUrlTxt: Label '%1/api/Registration/init?EntraTenantId=%2', Locked = true;
    begin
        InitRequest(SignUpConnectionSetup, HttpRequestMessage, HttpResponseMessage);
        HttpRequestMessage := PrepareRequestMsg("Http Request Type"::POST, StrSubstNo(BaseUrlTxt, SignUpAuth.GetRootUrl(), SignUpAuth.GetBCInstanceIdentifier()));
        exit(SendRequest(HttpRequestMessage, HttpResponseMessage, true));
    end;

    local procedure InitRequest(var SignUpConnectionSetup: Record SignUpConnectionSetup; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    begin
        Clear(HttpRequestMessage);
        Clear(HttpResponseMessage);
        if not SignUpConnectionSetup.Get() then
            Error(MissingSetupErr);
    end;

    local procedure SendRequest(HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        SendRequest(HttpRequestMessage, HttpResponseMessage, false);
    end;

    local procedure SendRequest(HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage; RootReequest: Boolean): Boolean
    var
        SignUpAuth: Codeunit SignUpAuth;
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
    begin
        HttpRequestMessage.GetHeaders(HttpHeaders);
        if RootReequest then
            HttpHeaders.Add('Authorization', SignUpAuth.GetRootBearerAuthText())
        else
            HttpHeaders.Add('Authorization', SignUpAuth.GetBearerAuthText());
        exit(HttpClient.Send(HttpRequestMessage, HttpResponseMessage));
    end;

    local procedure PrepareRequestMsg(pHttpRequestType: Enum "Http Request Type"; Uri: Text) RequestMessage: HttpRequestMessage
    var
        Headers: HttpHeaders;
    begin
        RequestMessage.Method(Format(pHttpRequestType));
        RequestMessage.SetRequestUri(Uri);
        RequestMessage.GetHeaders(Headers);
        Headers.Add('Accept', '*/*');
    end;

    local procedure XmlToTxt(var TempBlob: Codeunit "Temp Blob"): Text
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        InStr: InStream;
        Content: Text;
    begin
        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
        XMLDOMManagement.TryGetXMLAsText(InStr, Content);
        exit(Content);
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