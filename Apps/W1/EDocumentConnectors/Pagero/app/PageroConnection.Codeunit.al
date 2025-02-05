// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

using Microsoft.EServices.EDocument;
using System.Utilities;
using System.Text;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Document;
codeunit 6361 "Pagero Connection"
{
    Access = Internal;
    Permissions = tabledata "E-Document" = m;

    procedure HandleSendFilePostRequest(var TempBlob: Codeunit "Temp Blob"; var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; Retry: Boolean): Boolean
    begin
        if not PageroAPIRequests.SendFilePostRequest(TempBlob, EDocument, HttpRequest, HttpResponse) then
            if Retry then
                PageroAPIRequests.SendFilePostRequest(TempBlob, EDocument, HttpRequest, HttpResponse);

        exit(CheckIfSuccessfulRequest(EDocument, HttpResponse));
    end;

    procedure HandleSendActionRequest(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; ActionName: Text; Retry: Boolean): Boolean
    begin
        if not PageroAPIRequests.SendActionPostRequest(EDocument, ActionName, HttpRequest, HttpResponse) then
            if Retry then
                PageroAPIRequests.SendActionPostRequest(EDocument, ActionName, HttpRequest, HttpResponse);

        exit(CheckIfSuccessfulRequest(EDocument, HttpResponse));
    end;

    procedure CheckDocumentFileParts(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; Retry: Boolean): Boolean
    begin
        if not PageroAPIRequests.GetFilepartsErrorRequest(EDocument, HttpRequest, HttpResponse) then
            if Retry then
                PageroAPIRequests.GetFilepartsErrorRequest(EDocument, HttpRequest, HttpResponse);

        exit(CheckIfSuccessfulRequest(EDocument, HttpResponse));
    end;

    procedure GetADocument(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    var
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        InputTxt: Text;
    begin
        if not PageroAPIRequests.GetADocument(EDocument, HttpRequest, HttpResponse) then begin
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, StrSubstNo(UnsuccessfulResponseErr, HttpResponse.HttpStatusCode(), HttpResponse.ReasonPhrase()));
            exit(false);
        end;

        if not CheckIfSuccessfulRequest(EDocument, HttpResponse) then
            exit(false);

        InputTxt := ParseJsonString(HttpResponse.Content);
        if InputTxt = '' then begin
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, UnsuccessfulResponseParseErr);
            exit;
        end;

        EDocument."Document Id" := CopyStr(ParseGetADocumentResponse(InputTxt), 1, MaxStrLen(EDocument."Document Id"));
        EDocument.Modify();
        exit(true);
    end;

    procedure GetReceivedDocuments(HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage; Retry: Boolean): Boolean
    var
        Parameters: Dictionary of [Text, Text];
        InputTxt: Text;
    begin
        if not PageroAPIRequests.GetReceivedDocumentsRequest(HttpRequest, HttpResponse, Parameters) then
            if Retry then
                PageroAPIRequests.GetReceivedDocumentsRequest(HttpRequest, HttpResponse, Parameters);

        if not HttpResponse.IsSuccessStatusCode then
            exit(false);

        InputTxt := ParseJsonString(HttpResponse.Content);
        if InputTxt <> '' then
            exit(true);
    end;

    procedure HandleGetTargetDocumentRequest(DocumentId: Text; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage; Retry: Boolean): Boolean
    begin
        if not PageroAPIRequests.GetTargetDocumentRequest(DocumentId, HttpRequest, HttpResponse) then
            if Retry then
                PageroAPIRequests.GetTargetDocumentRequest(DocumentId, HttpRequest, HttpResponse);

        if HttpResponse.IsSuccessStatusCode then
            exit(true);
    end;

    procedure HandleSendFetchDocumentRequest(DocumentId: JsonArray; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; Retry: Boolean): Boolean
    begin
        if not PageroAPIRequests.SendFetchDocumentRequest(DocumentId, HttpRequest, HttpResponse) then
            if Retry then
                PageroAPIRequests.SendFetchDocumentRequest(DocumentId, HttpRequest, HttpResponse);

        if HttpResponse.IsSuccessStatusCode then
            exit(true);
    end;

    procedure PrepareMultipartContent(DocumentType: Text; SendMode: Text; SendingCompanyID: Text; SenderReference: Text; FileName: Text; Payload: Text; var Boundary: Text): Text
    var
        MultiPartContent: TextBuilder;
        ContentTxt: Text;
    begin

        Boundary := Format(CreateGuid());
        Boundary := DelChr(Boundary, '<>=', '{}&[]*()!@#$%^+=;:"''<>,.?/|\\~`');
        MultiPartContent.AppendLine('--' + Format(Boundary));

        // payload
        ContentTxt := 'Content-Disposition: form-data; name="payload"; filename="%1.xml"';
        MultiPartContent.AppendLine(StrSubstNo(ContentTxt, FileName));
        MultiPartContent.AppendLine('');
        MultiPartContent.AppendLine(Payload);

        // documentType 
        MultiPartContent.AppendLine('--' + Format(Boundary));
        ContentTxt := 'Content-Disposition: form-data; name="documentType"';
        MultiPartContent.AppendLine(ContentTxt);
        MultiPartContent.AppendLine('');
        MultiPartContent.AppendLine(DocumentType);

        // sendMode
        MultiPartContent.AppendLine('--' + Format(Boundary));
        ContentTxt := 'Content-Disposition: form-data; name="sendMode"';
        MultiPartContent.AppendLine(ContentTxt);
        MultiPartContent.AppendLine('');
        MultiPartContent.AppendLine(SendMode);

        // sendingCompanyId
        MultiPartContent.AppendLine('--' + Format(Boundary));
        ContentTxt := 'Content-Disposition: form-data; name="sendingCompanyId"';
        MultiPartContent.AppendLine(ContentTxt);
        MultiPartContent.AppendLine('');
        MultiPartContent.AppendLine(SendingCompanyID);

        // senderReference 
        MultiPartContent.AppendLine('--' + Format(Boundary));
        ContentTxt := 'Content-Disposition: form-data; name="senderReference"';
        MultiPartContent.AppendLine(ContentTxt);
        MultiPartContent.AppendLine('');
        MultiPartContent.AppendLine(SenderReference);

        // close boundary
        MultiPartContent.AppendLine('--' + Format(Boundary) + '--');
        ContentTxt := MultiPartContent.ToText();
        exit(MultiPartContent.ToText());
    end;

    procedure ParseGetADocumentResponse(InputTxt: Text): Text
    var
        JsonManagement: Codeunit "JSON Management";
        JsonManagement2: Codeunit "JSON Management";
        Value: Text;
        IncrementalTable: Text;
    begin
        if not JsonManagement.InitializeFromString(InputTxt) then
            exit('');

        JsonManagement.GetArrayPropertyValueAsStringByName('items', Value);
        JsonManagement.InitializeCollection(Value);

        if JsonManagement.GetCollectionCount() > 0 then begin
            JsonManagement.GetObjectFromCollectionByIndex(IncrementalTable, 0);
            JsonManagement2.InitializeObject(IncrementalTable);
            JsonManagement2.GetArrayPropertyValueAsStringByName('id', Value);
            exit(Value);
        end;
        exit('');
    end;

    procedure ParseJsonString(HttpContentResponse: HttpContent): Text
    var
        ResponseJObject: JsonObject;
        ResponseJson: Text;
        Result: Text;
        IsJsonResponse: Boolean;
    begin
        HttpContentResponse.ReadAs(Result);
        IsJsonResponse := ResponseJObject.ReadFrom(Result);
        if IsJsonResponse then
            ResponseJObject.WriteTo(ResponseJson)
        else
            exit('');

        if not TryInitJson(ResponseJson) then
            exit('');

        exit(Result);
    end;

    [TryFunction]
    local procedure TryInitJson(JsonTxt: Text)
    var
        JsonManagement: Codeunit "JSON Management";
    begin
        JSONManagement.InitializeObject(JsonTxt);
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

        EDocumentService.SetRange("Service Integration V2", EDocumentService."Service Integration V2"::Pagero);
        if EDocumentService.FindFirst() then;
        EDocumentServiceStatus.SetRange("E-Document Entry No", EDocument."Entry No");
        EDocumentServiceStatus.SetRange("E-Document Service Code", EDocumentService.Code);
        if EDocumentServiceStatus.FindSet() then
            repeat
                EDocumentServiceStatus.TestField(EDocumentServiceStatus.Status, EDocumentServiceStatus.Status::Approved);
            until EDocumentServiceStatus.Next() = 0;
    end;

    var
        PageroAPIRequests: Codeunit "Pagero API Requests";
        UnsuccessfulResponseErr: Label 'There was an error sending the request. Response code: %1 and error message: %2', Comment = '%1 - http response status code, e.g. 400, %2- error message';
        UnsuccessfulResponseParseErr: Label 'Failed to parse response from document';
        EnvironmentBlocksErr: Label 'The request to send documents has been blocked. To resolve the problem, enable outgoing HTTP requests for the E-Document apps on the Extension Management page.';
}