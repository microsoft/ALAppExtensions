// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using Microsoft.EServices.EDocument;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Posting;
using System.Utilities;

codeunit 6382 SignUpConnection
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