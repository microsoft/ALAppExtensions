// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using Microsoft.EServices.EDocument;
using System.Utilities;
using System.Text;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Document;
using Microsoft.Sales.Customer;
using Microsoft.Foundation.Company;

codeunit 6372 SignUpConnection
{
    Access = Internal;
    Permissions = tabledata "E-Document" = m;

    procedure HandleSendFilePostRequest(var TempBlob: Codeunit "Temp Blob"; var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; Retry: Boolean): Boolean
    begin
        if not SignUpAPIRequests.SendFilePostRequest(TempBlob, EDocument, HttpRequest, HttpResponse) then
            if Retry then
                SignUpAPIRequests.SendFilePostRequest(TempBlob, EDocument, HttpRequest, HttpResponse);

        exit(CheckIfSuccessfulRequest(EDocument, HttpResponse));
    end;

    procedure CheckDocumentStatus(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; Retry: Boolean): Boolean
    begin
        if not SignUpAPIRequests.GetSentDocumentStatus(EDocument, HttpRequest, HttpResponse) then
            if Retry then
                SignUpAPIRequests.GetSentDocumentStatus(EDocument, HttpRequest, HttpResponse);

        exit(CheckIfSuccessfulRequest(EDocument, HttpResponse));
    end;

    procedure GetReceivedDocuments(var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; Retry: Boolean): Boolean
    var
        Parameters: Dictionary of [Text, Text];
    begin
        if not SignUpAPIRequests.GetReceivedDocumentsRequest(HttpRequest, HttpResponse, Parameters) then
            if Retry then
                SignUpAPIRequests.GetReceivedDocumentsRequest(HttpRequest, HttpResponse, Parameters);

        if not HttpResponse.IsSuccessStatusCode then
            exit(false);

        exit(SignUpHelpers.ParseJsonString(HttpResponse.Content) <> '');
    end;

    procedure HandleGetTargetDocumentRequest(DocumentId: Text; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; Retry: Boolean): Boolean
    begin
        if not SignUpAPIRequests.GetTargetDocumentRequest(DocumentId, HttpRequest, HttpResponse) then
            if Retry then
                SignUpAPIRequests.GetTargetDocumentRequest(DocumentId, HttpRequest, HttpResponse);

        exit(HttpResponse.IsSuccessStatusCode);
    end;

    procedure RemoveDocumentFromReceived(EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; Retry: Boolean): Boolean
    begin
        if not SignUpAPIRequests.PatchReceivedDocument(EDocument, HttpRequest, HttpResponse) then
            if Retry then
                SignUpAPIRequests.PatchReceivedDocument(EDocument, HttpRequest, HttpResponse);
        exit(HttpResponse.IsSuccessStatusCode);
    end;

    procedure PrepareContentForSend(DocumentType: Text; SendingCompanyID: Text; RecieverCompanyID: Text; SenderCountryCode: Text; Payload: Text; SendMode: Enum SignUpSendMode): Text
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

    internal procedure GetCustomerID(EDocument: Record "E-Document"): Text[50]
    var
        Customer: Record Customer;
    begin
        if EDocument.Direction <> EDocument.Direction::Outgoing then
            exit('');

        Customer.Get(EDocument."Bill-to/Pay-to No.");
        Customer.TestField("SignUpService Participant Id");
        exit(Customer."SignUpService Participant Id");
    end;

    internal procedure GetSenderCountryCode(): Text
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation.TestField("Country/Region Code");
        exit(CompanyInformation."Country/Region Code");
    end;

    internal procedure GetSenderReceiverPrefix(): Text
    var
        SenderReceiverPrefixLbl: Label 'iso6523-actorid-upis::', Locked = true;
    begin
        exit(SenderReceiverPrefixLbl);
    end;

    local procedure CheckIfSuccessfulRequest(EDocument: Record "E-Document"; HttpResponse: HttpResponseMessage): Boolean
    var
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
    begin
        if HttpResponse.IsSuccessStatusCode then
            exit(true);

        if HttpResponse.IsBlockedByEnvironment then
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, EnvironmentBlocksErr)
        else
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, StrSubstNo(UnsuccessfulResponseErr, HttpResponse.HttpStatusCode, HttpResponse.ReasonPhrase));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterCheckAndUpdate', '', false, false)]
    local procedure CheckOnPosting(var PurchaseHeader: Record "Purchase Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocumentServiceStatus: Record "E-Document Service Status";
    begin
        EDocument.SetRange("Document Record ID", PurchaseHeader.RecordId);
        if not EDocument.FindFirst() then
            exit;

        EDocumentService.SetRange("Service Integration", EDocumentService."Service Integration"::"ExFlow E-Invoicing");
        if EDocumentService.FindFirst() then;
        EDocumentServiceStatus.SetRange("E-Document Entry No", EDocument."Entry No");
        EDocumentServiceStatus.SetRange("E-Document Service Code", EDocumentService.Code);
        if EDocumentServiceStatus.FindSet() then
            repeat
                EDocumentServiceStatus.TestField(EDocumentServiceStatus.Status, EDocumentServiceStatus.Status::Approved);
            until EDocumentServiceStatus.Next() = 0;
    end;

    var
        SignUpAPIRequests: Codeunit SignUpAPIRequests;
        SignUpHelpers: Codeunit SignUpHelpers;
        UnsuccessfulResponseErr: Label 'There was an error sending the request. Response code: %1 and error message: %2', Comment = '%1 - http response status code, e.g. 400, %2- error message';
        EnvironmentBlocksErr: Label 'The request to send documents has been blocked. To resolve the problem, enable outgoing HTTP requests for the E-Document apps on the Extension Management page.';
}