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

codeunit 6389 APIRequestsImpl
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    #region variables

    var
        MissingSetupErr: Label 'Connection Setup is missing';
        MissingSetupMessageErr: Label 'You must set up service integration in the e-document service card.';
        MissingSetupNavigationActionErr: Label 'Show E-Document Services';
        UnSupportedDocumentTypeTxt: Label 'Document %1 is not supported.', Comment = '%1 = EDocument Type', Locked = true;
        SenderReceiverPrefixTxt: Label 'iso6523-actorid-upis::', Locked = true;
        ContentTypeTxt: Label 'Content-Type', Locked = true;
        ApplicationJsonTxt: Label 'application/json', Locked = true;
        AuthorizationTxt: Label 'Authorization', Locked = true;
        AcceptTxt: Label 'Accept', Locked = true;
        AllTxt: Label '*/*', Locked = true;
        ApplicationResponseTxt: Label 'ApplicationResponse', Locked = true;
        InvoiceTxt: Label 'Invoice', Locked = true;
        PaymentReminderTxt: Label 'PaymentReminder', Locked = true;
        DocumentTypeTxt: Label 'documentType', Locked = true;
        ReceiverTxt: Label 'receiver', Locked = true;
        SenderTxt: Label 'sender', Locked = true;
        SenderCountryCodeTxt: Label 'senderCountryCode', Locked = true;
        DocumentIdTxt: Label 'documentId', Locked = true;
        DocumentIdValueTxt: Label 'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2::Invoice##urn:cen.eu:en16931:2017#compliant#urn:fdc:peppol.eu:2017:poacc:billing:3.0::2.1', Locked = true;
        DocumentIdSchemeTxt: Label 'documentIdScheme', Locked = true;
        BusdoxDocIdQNSTxt: Label 'busdox-docid-qns', Locked = true;
        ProcessIdTxt: Label 'processId', Locked = true;
        ProcessIdValueTxt: Label 'urn:fdc:peppol.eu:2017:poacc:billing:01:1.0', Locked = true;
        ProcessIdSchemeTxt: Label 'processIdScheme', Locked = true;
        ProcessIdSchemeValueTxt: Label 'cenbii-procid-ubl', Locked = true;
        SendModeTxt: Label 'sendMode', Locked = true;
        DocumentTxt: Label 'document', Locked = true;

    #endregion

    #region public methods

    // https://<BASE URL>/api/Peppol
    procedure SendFilePostRequest(var TempBlob: Codeunit "Temp Blob"; EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        ConnectionSetup: Record ConnectionSetup;
        HttpContent: HttpContent;
        Payload: Text;
    begin
        Payload := this.XmlToTxt(TempBlob);
        if Payload = '' then
            exit;

        this.InitRequest(HttpRequestMessage, HttpResponseMessage);
        ConnectionSetup.SetLoadFields("Company Id", "Environment Type", ServiceURL);
        this.GetSetup(ConnectionSetup);

        HttpRequestMessage := this.PrepareRequestMsg("Http Request Type"::POST, ConnectionSetup.ServiceURL + '/api/Peppol');
        this.PrepareContent(HttpContent, Payload, EDocument, ConnectionSetup);
        HttpRequestMessage.Content(HttpContent);
        exit(this.SendRequest(HttpRequestMessage, HttpResponseMessage));
    end;

    // https://<BASE URL>/api/Peppol/status?peppolInstanceId=
    procedure GetSentDocumentStatus(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        ConnectionSetup: Record ConnectionSetup;
    begin
        this.InitRequest(HttpRequestMessage, HttpResponseMessage);
        ConnectionSetup.SetLoadFields(ServiceURL);
        this.GetSetup(ConnectionSetup);

        HttpRequestMessage := this.PrepareRequestMsg("Http Request Type"::GET, ConnectionSetup.ServiceURL + '/api/Peppol/status?peppolInstanceId=' + EDocument."Document Id");
        exit(this.SendRequest(HttpRequestMessage, HttpResponseMessage));
    end;

    // https://<BASE URL>/api/Peppol/outbox?peppolInstanceId=
    procedure PatchDocument(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        ConnectionSetup: Record ConnectionSetup;
    begin
        this.InitRequest(HttpRequestMessage, HttpResponseMessage);
        ConnectionSetup.SetLoadFields(ServiceURL);
        this.GetSetup(ConnectionSetup);

        HttpRequestMessage := this.PrepareRequestMsg("Http Request Type"::PATCH, ConnectionSetup.ServiceURL + '/api/Peppol/outbox?peppolInstanceId=' + EDocument."Document Id");
        exit(this.SendRequest(HttpRequestMessage, HttpResponseMessage));
    end;

    //  https://<BASE URL>/api/Peppol/Inbox?peppolId=
    procedure GetReceivedDocumentsRequest(var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        ConnectionSetup: Record ConnectionSetup;
    begin
        this.InitRequest(HttpRequestMessage, HttpResponseMessage);
        ConnectionSetup.SetLoadFields(ServiceURL, "Company Id");
        this.GetSetup(ConnectionSetup);

        HttpRequestMessage := this.PrepareRequestMsg("Http Request Type"::GET, ConnectionSetup.ServiceURL + '/api/Peppol/Inbox?peppolId=' + this.SenderReceiverPrefixTxt + ConnectionSetup."Company Id");
        exit(this.SendRequest(HttpRequestMessage, HttpResponseMessage));
    end;

    // https://<BASE URL>/api/Peppol/inbox-document?peppolId=
    procedure GetTargetDocumentRequest(DocumentId: Text; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        ConnectionSetup: Record ConnectionSetup;
    begin
        this.InitRequest(HttpRequestMessage, HttpResponseMessage);
        ConnectionSetup.SetLoadFields(ServiceURL, "Company Id");
        this.GetSetup(ConnectionSetup);

        HttpRequestMessage := this.PrepareRequestMsg("Http Request Type"::GET, ConnectionSetup.ServiceURL + '/api/Peppol/inbox-document?peppolId=' + this.SenderReceiverPrefixTxt + ConnectionSetup."Company Id" + '&peppolInstanceId=' + DocumentId);
        exit(this.SendRequest(HttpRequestMessage, HttpResponseMessage));
    end;

    // https://<BASE URL>/api/Peppol/inbox?peppolInstanceId=
    procedure PatchReceivedDocument(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        ConnectionSetup: Record ConnectionSetup;
    begin
        this.InitRequest(HttpRequestMessage, HttpResponseMessage);
        ConnectionSetup.SetLoadFields(ServiceURL);
        this.GetSetup(ConnectionSetup);

        HttpRequestMessage := this.PrepareRequestMsg("Http Request Type"::PATCH, ConnectionSetup.ServiceURL + '/api/Peppol/inbox?peppolInstanceId=' + EDocument."Document Id");
        exit(this.SendRequest(HttpRequestMessage, HttpResponseMessage));
    end;

    procedure GetMarketPlaceCredentials(var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        Authentication: Codeunit Authentication;
    begin
        this.InitRequest(HttpRequestMessage, HttpResponseMessage);

        HttpRequestMessage := this.PrepareRequestMsg("Http Request Type"::POST, Authentication.GetRootUrl() + '/api/Registration/init?EntraTenantId=' + Authentication.GetBCInstanceIdentifier());
        exit(this.SendRequest(HttpRequestMessage, HttpResponseMessage, true));
    end;

    #endregion

    #region local methods

    local procedure InitRequest(var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    begin
        Clear(HttpRequestMessage);
        Clear(HttpResponseMessage);
    end;

    local procedure GetSetup(var ConnectionSetup: Record ConnectionSetup)
    var
        MissingSetupErrorInfo: ErrorInfo;
    begin
        if not IsNullGuid(ConnectionSetup.SystemId) then
            exit;

        if not ConnectionSetup.Get() then begin
            MissingSetupErrorInfo.Title := this.MissingSetupErr;
            MissingSetupErrorInfo.Message := this.MissingSetupMessageErr;
            MissingSetupErrorInfo.PageNo := Page::"E-Document Services";
            MissingSetupErrorInfo.AddNavigationAction(this.MissingSetupNavigationActionErr);
            Error(MissingSetupErrorInfo);
        end;
    end;

    local procedure PrepareContent(var HttpContent: HttpContent; Payload: Text; EDocument: Record "E-Document"; ConnectionSetup: Record ConnectionSetup)
    var
        ContentText: Text;
        HttpHeaders: HttpHeaders;
    begin
        Clear(HttpContent);
        ContentText := this.PrepareContentForSend(this.GetDocumentType(EDocument), ConnectionSetup."Company Id", this.GetCustomerID(EDocument), this.GetSenderCountryCode(), Payload, ConnectionSetup."Environment Type");
        HttpContent.WriteFrom(ContentText);
        HttpContent.GetHeaders(HttpHeaders);
        if HttpHeaders.Contains(this.ContentTypeTxt) then
            HttpHeaders.Remove(this.ContentTypeTxt);
        HttpHeaders.Add(this.ContentTypeTxt, this.ApplicationJsonTxt);
    end;

    local procedure SendRequest(HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        this.SendRequest(HttpRequestMessage, HttpResponseMessage, false);
    end;

    local procedure SendRequest(HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage; RootRequest: Boolean): Boolean
    var
        Authentication: Codeunit Authentication;
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
    begin
        HttpRequestMessage.GetHeaders(HttpHeaders);
        if RootRequest then
            HttpHeaders.Add(this.AuthorizationTxt, Authentication.GetRootBearerAuthToken())
        else
            HttpHeaders.Add(this.AuthorizationTxt, Authentication.GetBearerAuthToken());
        exit(HttpClient.Send(HttpRequestMessage, HttpResponseMessage));
    end;

    local procedure PrepareRequestMsg(HttpRequestType: Enum "Http Request Type"; Uri: Text) RequestMessage: HttpRequestMessage
    var
        HttpHeaders: HttpHeaders;
    begin
        RequestMessage.Method(Format(HttpRequestType));
        RequestMessage.SetRequestUri(Uri);
        RequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add(this.AcceptTxt, this.AllTxt);
    end;

    local procedure XmlToTxt(var TempBlob: Codeunit "Temp Blob"): Text
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        Content: Text;
    begin
        XMLDOMManagement.TryGetXMLAsText(TempBlob.CreateInStream(TextEncoding::UTF8), Content);
        exit(Content);
    end;

    local procedure GetDocumentType(EDocument: Record "E-Document"): Text
    begin
        if EDocument.Direction = EDocument.Direction::Incoming then
            exit(this.ApplicationResponseTxt);

        case EDocument."Document Type" of
            "E-Document Type"::"Sales Invoice", "E-Document Type"::"Sales Credit Memo", "E-Document Type"::"Service Invoice", "E-Document Type"::"Service Credit Memo":
                exit(this.InvoiceTxt);
            "E-Document Type"::"Issued Finance Charge Memo", "E-Document Type"::"Issued Reminder":
                exit(this.PaymentReminderTxt);
            else
                Error(this.UnSupportedDocumentTypeTxt, EDocument."Document Type");
        end;
    end;

    local procedure GetCustomerID(EDocument: Record "E-Document"): Text[50]
    var
        Customer: Record Customer;
    begin
        Customer.SetLoadFields("Service Participant Id");
        Customer.Get(EDocument."Bill-to/Pay-to No.");
        Customer.TestField("Service Participant Id");
        exit(Customer."Service Participant Id");
    end;

    local procedure GetSenderCountryCode(): Text
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.SetLoadFields("Country/Region Code");
        CompanyInformation.Get();
        CompanyInformation.TestField("Country/Region Code");
        exit(CompanyInformation."Country/Region Code");
    end;

    local procedure PrepareContentForSend(DocumentType: Text; SendingCompanyID: Text; RecieverCompanyID: Text; SenderCountryCode: Text; Payload: Text; SendMode: Enum EnvironmentType): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        JsonObject: JsonObject;
        ContentText: Text;
    begin
        JsonObject.Add(this.DocumentTypeTxt, DocumentType);
        JsonObject.Add(this.ReceiverTxt, this.SenderReceiverPrefixTxt + RecieverCompanyID);
        JsonObject.Add(this.SenderTxt, this.SenderReceiverPrefixTxt + SendingCompanyID);
        JsonObject.Add(this.SenderCountryCodeTxt, SenderCountryCode);
        JsonObject.Add(this.DocumentIdTxt, this.DocumentIdValueTxt);
        JsonObject.Add(this.DocumentIdSchemeTxt, this.BusdoxDocIdQNSTxt);
        JsonObject.Add(this.ProcessIdTxt, this.ProcessIdValueTxt);
        JsonObject.Add(this.ProcessIdSchemeTxt, this.ProcessIdSchemeValueTxt);
        JsonObject.Add(this.SendModeTxt, Format(SendMode));
        JsonObject.Add(this.DocumentTxt, Base64Convert.ToBase64(Payload));
        JsonObject.WriteTo(ContentText);
        exit(ContentText);
    end;

    #endregion
}