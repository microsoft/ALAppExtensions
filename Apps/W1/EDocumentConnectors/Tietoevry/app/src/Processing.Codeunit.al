// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Tietoevry;

using Microsoft.EServices.EDocument;
using System.Utilities;
using Microsoft.eServices.EDocument.Integration.Send;
using Microsoft.eServices.EDocument.Integration.Receive;

codeunit 6399 Processing
{
    Access = Internal;
    Permissions = tabledata "E-Document" = m,
                  tabledata "E-Document Service Status" = m,
                  tabledata "Connection Setup" = rm;


    /// <summary>
    /// Calls Tietoevry API for SubmitDocument.
    /// </summary>
    procedure SendEDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext)
    var
        Request: Codeunit Requests;
        HttpExecutor: Codeunit "Http Executor";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        RequestContent: Text;
        ResponseContent: Text;
    begin
        TempBlob := SendContext.GetTempBlob();

        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        InStream.Read(RequestContent);

        Request.Init();
        Request.Authenticate().CreateSubmitDocumentRequest(EDocument, EDocumentService, RequestContent);
        ResponseContent := HttpExecutor.ExecuteHttpRequest(Request);
        SendContext.Http().SetHttpRequestMessage(Request.GetRequest());
        SendContext.Http().SetHttpResponseMessage(HttpExecutor.GetResponse());

        EDocument.Get(EDocument."Entry No");
        EDocument."Tietoevry Document Id" := this.ParseDocumentId(ResponseContent);
        EDocument.Modify(true);
    end;

    /// <summary>
    /// Calls Tietoevry API for GetDocumentStatus.
    /// If request is successfull, but status is Error, then errors are logged and error is thrown to set document to Sending Error state
    /// </summary>
    /// <returns>False if status is Pending, True if status is Complete.</returns>
    procedure GetDocumentStatus(var EDocument: Record "E-Document"; SendContext: Codeunit SendContext): Boolean
    var
        Request: Codeunit Requests;
        HttpExecutor: Codeunit "Http Executor";
        ResponseContent: Text;
    begin
        EDocument.TestField("Tietoevry Document Id");

        Request.Init();
        Request.Authenticate().CreateGetDocumentStatusRequest(EDocument."Tietoevry Document Id");
        ResponseContent := HttpExecutor.ExecuteHttpRequest(Request);
        SendContext.Http().SetHttpRequestMessage(Request.GetRequest());
        SendContext.Http().SetHttpResponseMessage(HttpExecutor.GetResponse());
        exit(this.ParseGetDocumentStatusResponse(EDocument, ResponseContent));
    end;

    /// <summary>
    /// Get a list of messages to collect. 
    /// </summary>
    procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; ReceivedEDocuments: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)
    var
        TempBlob: Codeunit "Temp Blob";
        Request: Codeunit Requests;
        HttpExecutor: Codeunit "Http Executor";
        ResponseContent: Text;
        OutStream: OutStream;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        Response: JsonArray;
        ValueObject: JsonToken;
    begin
        Request.Init();
        Request.Authenticate().CreateReceiveDocumentsRequest();
        HttpRequest := Request.GetRequest();
        ResponseContent := HttpExecutor.ExecuteHttpRequest(Request, HttpResponse);
        ReceiveContext.Http().SetHttpRequestMessage(HttpRequest);
        ReceiveContext.Http().SetHttpResponseMessage(HttpResponse);

        Response.ReadFrom(ResponseContent);
        this.RemoveExistingDocumentsFromResponse(Response);

        foreach ValueObject in Response do begin
            Clear(TempBlob);
            TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
            OutStream.Write(ValueObject.AsValue().AsText());
            ReceivedEDocuments.Add(TempBlob);
        end;
    end;

    /// <summary>
    /// Download document XML from Tietoevry API
    /// </summary>
    procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadataBlob: codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    var
        Request: Codeunit Requests;
        HttpExecutor: Codeunit "Http Executor";
        ResponseContent: Text;
        InStream: InStream;
        DocumentId: Text;
        OutStream: OutStream;
    begin
        DocumentMetadataBlob.CreateInStream(InStream, TextEncoding::UTF8);
        InStream.ReadText(DocumentId);

        if DocumentId = '' then begin
            this.EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, this.DocumentIdNotFoundErr);
            exit;
        end;

        EDocument."Tietoevry Document Id" := CopyStr(DocumentId, 1, MaxStrLen(EDocument."Tietoevry Document Id"));
        EDocument.Modify();

        Request.Init();
        Request.Authenticate().CreateDownloadRequest(DocumentId);
        ResponseContent := HttpExecutor.ExecuteHttpRequest(Request);
        ReceiveContext.Http().SetHttpRequestMessage(Request.GetRequest());
        ReceiveContext.Http().SetHttpResponseMessage(HttpExecutor.GetResponse());

        ReceiveContext.GetTempBlob().CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(ResponseContent);
    end;

    /// <summary>
    /// Mark document as read from Tietoevry API
    /// </summary>
    procedure AcknowledgeDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadataBlob: codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    var
        Request: Codeunit Requests;
        HttpExecutor: Codeunit "Http Executor";
        ResponseContent: Text;
    begin
        Request.Init();
        Request.Authenticate().CreateAcknowledgeRequest(EDocument."Tietoevry Document Id");
        ResponseContent := HttpExecutor.ExecuteHttpRequest(Request);
        ReceiveContext.Http().SetHttpRequestMessage(Request.GetRequest());
        ReceiveContext.Http().SetHttpResponseMessage(HttpExecutor.GetResponse());
    end;


    /// <summary>
    /// Remove document ids from array that are already created as E-Documents.
    /// </summary>
    local procedure RemoveExistingDocumentsFromResponse(var Documents: JsonArray)
    var
        DocumentId: Text;
        I: Integer;
        NewArray: JsonArray;
    begin
        for I := 0 to Documents.Count() - 1 do begin
            DocumentId := this.GetDocumentIdFromArray(Documents, I);
            if not this.DocumentExists(DocumentId) then
                NewArray.Add(DocumentId);
        end;
        Documents := NewArray;
    end;

    /// <summary>
    /// Check if E-Document with Document Id exists in E-Document table
    /// </summary>
    local procedure DocumentExists(DocumentId: Text): Boolean
    var
        EDocument: Record "E-Document";
    begin
        EDocument.SetRange("Tietoevry Document Id", DocumentId);
        exit(not EDocument.IsEmpty());
    end;

    /// <summary>
    /// Parse company id
    /// </summary>
    local procedure ParseDocumentId(ResponseMsg: Text): Text[50]
    var
        EDocument: Record "E-Document";
        DocumentId: Text;
        ResponseJson: JsonObject;
        ValueJson: JsonToken;
    begin
        ResponseJson.ReadFrom(ResponseMsg);
        ResponseJson.Get('id', ValueJson);

        DocumentId := ValueJson.AsValue().AsText();
        if StrLen(DocumentId) > MaxStrLen(EDocument."Tietoevry Document Id") then
            Error(this.TietoevryIdLongerErr);

        exit(CopyStr(DocumentId, 1, MaxStrLen(EDocument."Tietoevry Document Id")));
    end;

    /// <summary>
    /// Parse Document Response. If erros log all events
    /// </summary>
    local procedure ParseGetDocumentStatusResponse(var EDocument: Record "E-Document"; ResponseMsg: Text): Boolean
    var
        ResponseJson: JsonObject;
        ValueJson, EventToken : JsonToken;
    begin
        ResponseJson.ReadFrom(ResponseMsg);
        ResponseJson.Get('id', ValueJson);
        if EDocument."Tietoevry Document Id" <> ValueJson.AsValue().AsText() then
            Error(this.IncorrectDocumentIdInResponseErr);

        ResponseJson.Get('status', ValueJson);
        case UpperCase(ValueJson.AsValue().AsText()) of
            'PROCESSED':
                exit(true);
            'PENDING':
                exit(false);
            'FAILED':
                begin
                    if not EventToken.ReadFrom(ResponseMsg) then begin
                        this.EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, this.TietoevryProcessingDocFailedErr);
                        exit(false);
                    end;
                    if ResponseJson.Get('details', ValueJson) then
                        this.EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, ValueJson.AsValue().AsText());

                    exit(false);
                end;
            else
                exit(false);
        end;
    end;

    /// <summary>
    /// Returns id from json array
    /// </summary>
    local procedure GetDocumentIdFromArray(DocumentArray: JsonArray; Index: Integer): Text
    var
        DocumentJsonToken, IdToken : JsonToken;
    begin
        DocumentArray.Get(Index, DocumentJsonToken);
        DocumentJsonToken.AsObject().Get('id', IdToken);
        exit(IdToken.AsValue().AsText());
    end;

    procedure GetTietoevryTok(): Text
    begin
        exit(this.TietoevryTok);
    end;

    internal procedure IsValidSchemeId(PeppolId: Text[50]) Result: Boolean;
    var
        ValidSchemeId: Text;
        ValidSchemeIdList: List of [Text];
        SplitSeparator: Text;
        SchemeId: Text;
        ResInStream: InStream;
        JsonObject: JsonObject;
        JsonToken: JsonToken;
    begin
        SplitSeparator := ' ';
        NavApp.GetResource(ResourceSchemeIdPath, ResInStream, TextEncoding::UTF8);
        ResInStream.ReadText(ValidSchemeId);
        JsonObject.ReadFrom(ValidSchemeId);
        JsonObject.Get('schemeids', JsonToken);
        ValidSchemeId := JsonToken.AsValue().AsText();
        ValidSchemeIdList := ValidSchemeId.Split(SplitSeparator);

        foreach SchemeId in ValidSchemeIdList do
            if PeppolId.StartsWith(SchemeId) then
                exit(true);
        exit(false);
    end;

    var
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        IncorrectDocumentIdInResponseErr: Label 'Document ID returned by API does not match E-Document.';
        DocumentIdNotFoundErr: Label 'Document ID not found in response.';
        TietoevryProcessingDocFailedErr: Label 'An error has been identified in the submitted document.';
        TietoevryIdLongerErr: Label 'Tietoevry returned id longer than supported by framework.';
        TietoevryTok: Label 'E-Document - Tietoevry', Locked = true;
        ResourceSchemeIdPath: Label 'SchemeIds.txt', Locked = true;

}