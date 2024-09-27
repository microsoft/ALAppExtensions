// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using Microsoft.EServices.EDocument;
using Microsoft.Foundation.Company;
using Microsoft.Sales.Customer;
using System.Security.Authentication;
using System.Text;
using System.Utilities;
using System.Xml;

codeunit 6380 APIRequests
{
    Access = Internal;

    // https://<BASE URL>/api/Peppol
    procedure SendFilePostRequest(var TempBlob: Codeunit "Temp Blob"; EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        ConnectionSetup: Record ConnectionSetup;
        Payload: Text;
        ContentHttpHeaders: HttpHeaders;
        HttpContent: HttpContent;
        ContentText: Text;
    begin
        InitRequest(ConnectionSetup, HttpRequestMessage, HttpResponseMessage);
        HttpRequestMessage := PrepareRequestMsg("Http Request Type"::POST, StrSubstNo(SendFilePostRequestUriTxt, ConnectionSetup.ServiceURL));

        Payload := XmlToTxt(TempBlob);
        if Payload = '' then
            exit(false);
        Clear(HttpContent);
        ContentText := PrepareContentForSend(GetDocumentType(EDocument), ConnectionSetup."Company Id", GetCustomerID(EDocument), GetSenderCountryCode(), Payload, ConnectionSetup."Send Mode");
        HttpContent.WriteFrom(ContentText);
        HttpContent.GetHeaders(ContentHttpHeaders);
        if ContentHttpHeaders.Contains('Content-Type') then
            ContentHttpHeaders.Remove('Content-Type');
        ContentHttpHeaders.Add('Content-Type', 'application/json');
        HttpRequestMessage.Content(HttpContent);

        exit(SendRequest(HttpRequestMessage, HttpResponseMessage));
    end;

    // https://<BASE URL>/api/Peppol/status?peppolInstanceId=
    procedure GetSentDocumentStatus(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        ConnectionSetup: Record ConnectionSetup;
    begin
        InitRequest(ConnectionSetup, HttpRequestMessage, HttpResponseMessage);
        HttpRequestMessage := PrepareRequestMsg("Http Request Type"::GET, StrSubstNo(GetSentDocumentStatusUriTxt, ConnectionSetup.ServiceURL, EDocument."Document Id"));
        exit(SendRequest(HttpRequestMessage, HttpResponseMessage));
    end;

    // https://<BASE URL>/api/Peppol/outbox?peppolInstanceId=
    procedure PatchADocument(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        ConnectionSetup: Record ConnectionSetup;
    begin
        InitRequest(ConnectionSetup, HttpRequestMessage, HttpResponseMessage);
        HttpRequestMessage := PrepareRequestMsg("Http Request Type"::PATCH, StrSubstNo(PatchADocumentUriTxt, ConnectionSetup.ServiceURL, EDocument."Document Id"));
        exit(SendRequest(HttpRequestMessage, HttpResponseMessage));
    end;

    //  https://<BASE URL>/api/Peppol/Inbox?peppolId=
    procedure GetReceivedDocumentsRequest(var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage; Parameters: Dictionary of [Text, Text]): Boolean
    var
        ConnectionSetup: Record ConnectionSetup;
    begin
        InitRequest(ConnectionSetup, HttpRequestMessage, HttpResponseMessage);
        HttpRequestMessage := PrepareRequestMsg("Http Request Type"::GET, StrSubstNo(GetReceivedDocumentsUriTxt, ConnectionSetup.ServiceURL, GetSenderReceiverPrefix() + ConnectionSetup."Company Id"));
        exit(SendRequest(HttpRequestMessage, HttpResponseMessage));
    end;

    // https://<BASE URL>/api/Peppol/inbox-document?peppolId=
    procedure GetTargetDocumentRequest(DocumentId: Text; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        ConnectionSetup: Record ConnectionSetup;
    begin
        InitRequest(ConnectionSetup, HttpRequestMessage, HttpResponseMessage);
        HttpRequestMessage := PrepareRequestMsg("Http Request Type"::GET, StrSubstNo(GetTargetDocumentUriTxt, ConnectionSetup.ServiceURL, GetSenderReceiverPrefix() + ConnectionSetup."Company Id", DocumentId));
        exit(SendRequest(HttpRequestMessage, HttpResponseMessage));
    end;

    // https://<BASE URL>/api/Peppol/inbox?peppolInstanceId=
    procedure PatchReceivedDocument(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        ConnectionSetup: Record ConnectionSetup;
    begin
        InitRequest(ConnectionSetup, HttpRequestMessage, HttpResponseMessage);
        HttpRequestMessage := PrepareRequestMsg("Http Request Type"::PATCH, StrSubstNo(PatchReceivedDocumentUriTxt, ConnectionSetup.ServiceURL, EDocument."Document Id"));
        exit(SendRequest(HttpRequestMessage, HttpResponseMessage));
    end;

    procedure GetMarketPlaceCredentials(var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        ConnectionSetup: Record ConnectionSetup;
        Auth: Codeunit Auth;
    begin
        InitRequest(ConnectionSetup, HttpRequestMessage, HttpResponseMessage);
        HttpRequestMessage := PrepareRequestMsg("Http Request Type"::POST, StrSubstNo(GetMarketPlaceCredentialsUriTxt, Auth.GetRootUrl(), Auth.GetBCInstanceIdentifier()));
        exit(SendRequest(HttpRequestMessage, HttpResponseMessage, true));
    end;

    local procedure InitRequest(var ConnectionSetup: Record ConnectionSetup; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    var
        MissingSetupErrorInfo: ErrorInfo;
    begin
        Clear(HttpRequestMessage);
        Clear(HttpResponseMessage);
        if not ConnectionSetup.Get() then begin
            MissingSetupErrorInfo.Title := MissingSetupErr;
            MissingSetupErrorInfo.Message := MissingSetupMessageLbl;
            MissingSetupErrorInfo.PageNo := Page::"E-Document Services";
            MissingSetupErrorInfo.AddNavigationAction(MissingSetupNavigationActionLbl);
            Error(MissingSetupErrorInfo);
        end;
    end;

    local procedure SendRequest(HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        SendRequest(HttpRequestMessage, HttpResponseMessage, false);
    end;

    local procedure SendRequest(HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage; RootRequest: Boolean): Boolean
    var
        Auth: Codeunit Auth;
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
    begin
        HttpRequestMessage.GetHeaders(HttpHeaders);
        if RootRequest then
            HttpHeaders.Add('Authorization', Auth.GetRootBearerAuthText())
        else
            HttpHeaders.Add('Authorization', Auth.GetBearerAuthText());
        exit(HttpClient.Send(HttpRequestMessage, HttpResponseMessage));
    end;

    local procedure PrepareRequestMsg(HttpRequestType: Enum "Http Request Type"; Uri: Text) RequestMessage: HttpRequestMessage
    var
        Headers: HttpHeaders;
    begin
        RequestMessage.Method(Format(HttpRequestType));
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
            else
                Error(UnSupportedDocumentTypeLbl, EDocument."Document Type");
        end;
    end;

    local procedure GetCustomerID(EDocument: Record "E-Document"): Text[50]
    var
        Customer: Record Customer;
    begin
        Customer.Get(EDocument."Bill-to/Pay-to No.");
        Customer.TestField("Service Participant Id");
        exit(Customer."Service Participant Id");
    end;

    local procedure GetSenderCountryCode(): Text
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation.TestField("Country/Region Code");
        exit(CompanyInformation."Country/Region Code");
    end;

    local procedure PrepareContentForSend(DocumentType: Text; SendingCompanyID: Text; RecieverCompanyID: Text; SenderCountryCode: Text; Payload: Text; SendMode: Enum SendMode): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        SendJsonObject: JsonObject;
        ContentText: Text;
    begin
        SendJsonObject.Add('documentType', DocumentType);
        SendJsonObject.Add('receiver', GetSenderReceiverPrefix() + RecieverCompanyID);
        SendJsonObject.Add('sender', GetSenderReceiverPrefix() + SendingCompanyID);
        SendJsonObject.Add('senderCountryCode', SenderCountryCode);
        SendJsonObject.Add('documentId', 'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2::Invoice##urn:cen.eu:en16931:2017#compliant#urn:fdc:peppol.eu:2017:poacc:billing:3.0::2.1');
        SendJsonObject.Add('documentIdScheme', 'busdox-docid-qns');
        SendJsonObject.Add('processId', 'urn:fdc:peppol.eu:2017:poacc:billing:01:1.0');
        SendJsonObject.Add('processIdScheme', 'cenbii-procid-ubl');
        SendJsonObject.Add('sendMode', Format(SendMode));
        SendJsonObject.Add('document', Base64Convert.ToBase64(Payload));
        SendJsonObject.WriteTo(ContentText);
        exit(ContentText);
    end;

    local procedure GetSenderReceiverPrefix(): Text
    begin
        exit(SenderReceiverPrefixLbl);
    end;

    var
        MissingSetupErr: Label 'Connection Setup is missing';
        MissingSetupMessageLbl: Label 'You must set up service integration in the e-document service card.';
        MissingSetupNavigationActionLbl: Label 'Show E-Document Services';
        GetSentDocumentStatusUriTxt: Label '%1/api/Peppol/status?peppolInstanceId=%2', Comment = '%1 = Service Url, %2 = Document ID', Locked = true;
        SendFilePostRequestUriTxt: Label '%1/api/Peppol', Comment = '%1 = Service Url', Locked = true;
        PatchADocumentUriTxt: Label '%1/api/Peppol/outbox?peppolInstanceId=%2', Comment = '%1 = Service Url, %2 = Document ID', Locked = true;
        GetReceivedDocumentsUriTxt: Label '%1/api/Peppol/Inbox?peppolId=%2', Comment = '%1 = Service Url, %2 = Peppol Identifier', Locked = true;
        GetTargetDocumentUriTxt: Label '%1/api/Peppol/inbox-document?peppolId=%2&peppolInstanceId=%3', Comment = '%1 = Service Url, %2 = Peppol Identifier, %3 = Peppol Gateway Instance', Locked = true;
        PatchReceivedDocumentUriTxt: Label '%1/api/Peppol/inbox?peppolInstanceId=%2', Comment = '%1 = Service Url, %2 = Peppol Gateway Instance', Locked = true;
        GetMarketPlaceCredentialsUriTxt: Label '%1/api/Registration/init?EntraTenantId=%2', Locked = true;
        UnSupportedDocumentTypeLbl: Label 'Document %1 is not supported.', Comment = '%1 = EDocument Type', Locked = true;
        SenderReceiverPrefixLbl: Label 'iso6523-actorid-upis::', Locked = true;
}