// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Tietoevry;

using Microsoft.EServices.EDocument;
using System.Utilities;
using System.Text;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Document;
codeunit 6381 "Connection"
{
    Access = Internal;
    Permissions = tabledata "E-Document" = m;

    procedure HandleSendDocumentRequest(var TempBlob: Codeunit "Temp Blob"; var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; Retry: Boolean): Boolean
    begin
        if not TietoevryAPIRequests.SendDocumentRequest(TempBlob, EDocument, HttpRequest, HttpResponse) then
            if Retry then
                TietoevryAPIRequests.SendDocumentRequest(TempBlob, EDocument, HttpRequest, HttpResponse);

        exit(CheckIfSuccessfulRequest(EDocument, HttpResponse));
    end;

    procedure CheckDocumentStatus(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; Retry: Boolean): Boolean
    begin
        if not TietoevryAPIRequests.GetDocumentStatusRequest(EDocument, HttpRequest, HttpResponse) then
            if Retry then
                TietoevryAPIRequests.GetDocumentStatusRequest(EDocument, HttpRequest, HttpResponse);

        exit(CheckIfSuccessfulRequest(EDocument, HttpResponse));
    end;

    procedure GetReceivedDocuments(var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; Retry: Boolean): Boolean
    var
        InputTxt: Text;
    begin
        if not TietoevryAPIRequests.GetReceivedDocumentsRequest(HttpRequest, HttpResponse) then
            if Retry then
                TietoevryAPIRequests.GetReceivedDocumentsRequest(HttpRequest, HttpResponse);

        if not HttpResponse.IsSuccessStatusCode then
            exit(false);

        InputTxt := ParseAsJsonArray(HttpResponse.Content);
        if InputTxt <> '' then
            exit(true);
    end;

    procedure HandleGetTargetDocumentRequest(DocumentId: Text; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; Retry: Boolean): Boolean
    begin
        if not TietoevryAPIRequests.GetTargetDocumentRequest(DocumentId, HttpRequest, HttpResponse) then
            if Retry then
                TietoevryAPIRequests.GetTargetDocumentRequest(DocumentId, HttpRequest, HttpResponse);

        if HttpResponse.IsSuccessStatusCode then
            exit(true);
    end;

    procedure HandleSendFetchDocumentRequest(DocumentId: Text; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; Retry: Boolean): Boolean
    begin
        if not TietoevryAPIRequests.SendAcknowledgeDocumentRequest(DocumentId, HttpRequest, HttpResponse) then
            if Retry then
                TietoevryAPIRequests.SendAcknowledgeDocumentRequest(DocumentId, HttpRequest, HttpResponse);

        if HttpResponse.IsSuccessStatusCode then
            exit(true);
    end;

    procedure ParseAsJsonArray(HttpContentResponse: HttpContent): Text
    var
        ResponseJArray: JsonArray;
        ResponseJson: Text;
        Result: Text;
        IsJsonResponse: Boolean;
    begin
        HttpContentResponse.ReadAs(Result);
        IsJsonResponse := ResponseJArray.ReadFrom(Result);
        if IsJsonResponse then
            ResponseJArray.WriteTo(ResponseJson)
        else
            exit('');

        exit(Result);
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

        EDocumentService.SetRange("Service Integration", EDocumentService."Service Integration"::Tietoevry);
        if EDocumentService.FindFirst() then;
        EDocumentServiceStatus.SetRange("E-Document Entry No", EDocument."Entry No");
        EDocumentServiceStatus.SetRange("E-Document Service Code", EDocumentService.Code);
        if EDocumentServiceStatus.FindSet() then
            repeat
                EDocumentServiceStatus.TestField(EDocumentServiceStatus.Status, EDocumentServiceStatus.Status::Approved);
            until EDocumentServiceStatus.Next() = 0;
    end;

    var
        TietoevryAPIRequests: Codeunit "API Requests";
        UnsuccessfulResponseErr: Label 'There was an error sending the request. Response code: %1 and error message: %2', Comment = '%1 - http response status code, e.g. 400, %2- error message';
        EnvironmentBlocksErr: Label 'The request to send documents has been blocked. To resolve the problem, enable outgoing HTTP requests for the E-Document apps on the Extension Management page.';
}