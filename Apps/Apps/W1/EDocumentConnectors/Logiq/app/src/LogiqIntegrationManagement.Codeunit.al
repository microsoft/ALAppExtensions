// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Logiq;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Send;
using Microsoft.eServices.EDocument.Integration.Receive;
using System.Utilities;
using System.Xml;

codeunit 6432 "Logiq Integration Management"
{
    Access = Internal;
    Permissions = tabledata "E-Document" = m;

    internal procedure Send(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext)
    var
        ConnectionUserSetup: Record "Logiq Connection User Setup";
        LogiqAuth: Codeunit "Logiq Auth";
        Client: HttpClient;
        Headers: HttpHeaders;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        BodyText: Text;
        FileNameText: Text;
        Boundary: Text;
    begin
        HttpRequest.Method('POST');

        LogiqAuth.CheckUserSetup(ConnectionUserSetup);
        LogiqAuth.CheckUpdateTokens();

        HttpRequest.SetRequestUri(this.BuildRequestUri(ConnectionUserSetup."Document Transfer Endpoint"));

        HttpRequest.GetHeaders(Headers);
        SetAuthorizationHeader(Headers, LogiqAuth, ConnectionUserSetup);

        FileNameText := StrSubstNo(this.FileNameTok, EDocument."Document No.");
        Boundary := DelChr(Format(CreateGuid()), '<>=', '{}&[]*()!@#$%^+=;:"''<>,.?/|\\~`');

        BodyText := this.GetFileContentAsMultipart(SendContext.GetTempBlob(), FileNameText, Boundary);
        Content.WriteFrom(BodyText);

        Content.GetHeaders(ContentHeaders);
        if ContentHeaders.Contains('Content-Type') then
            ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', StrSubstNo(this.ContentTypeTok, Boundary));

        HttpRequest.Content(Content);

        Client.Send(HttpRequest, HttpResponse);

        if HttpResponse.IsSuccessStatusCode() then begin
            EDocument."Logiq External Document Id" := this.GetExternalIdFromReponse(HttpResponse);
            EDocument.Modify();
        end else
            this.LogSendingError(EDocument, HttpResponse);

        SendContext.Http().SetHttpRequestMessage(HttpRequest);
        SendContext.Http().SetHttpResponseMessage(HttpResponse);
    end;

    internal procedure GetResponse(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext): Boolean
    var
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        InStr: InStream;
        JsonObj: JsonObject;
        JsonTok: JsonToken;
        RequestSuccessful: Boolean;
    begin
        RequestSuccessful := this.GetStatus(EDocument, HttpRequest, HttpResponse);
        if not RequestSuccessful then begin
            this.EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, StrSubstNo(this.FailedHttpCallMsg, EDocument."Document No.", HttpResponse.HttpStatusCode, HttpResponse.ReasonPhrase));
            exit(false);
        end;

        SendContext.Http().SetHttpRequestMessage(HttpRequest);
        SendContext.Http().SetHttpResponseMessage(HttpResponse);

        HttpResponse.Content.ReadAs(InStr);
        if not JsonObj.ReadFrom(InStr) then
            Error(this.InvalidResponseErr);

        JsonObj.Get('state', JsonTok);
        if not JsonTok.IsValue() then
            Error(this.InvalidResponseErr);

        case JsonTok.AsValue().AsText() of
            'distributed':
                exit(true);
            'failed':
                Error(ServiceFailedFileErr);
            else
                exit(false);
        end;
    end;

    internal procedure GetStatus(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    var
        ConnectionUserSetup: Record "Logiq Connection User Setup";
        LogiqAuth: Codeunit "Logiq Auth";
        Client: HttpClient;
        Headers: HttpHeaders;
    begin
        HttpRequest.Method('GET');

        LogiqAuth.CheckUserSetup(ConnectionUserSetup);
        LogiqAuth.CheckUpdateTokens();

        EDocument.TestField("Logiq External Document Id");
        HttpRequest.SetRequestUri(this.BuildRequestUri(this.JoinUrlParts(ConnectionUserSetup."Document Status Endpoint", EDocument."Logiq External Document Id")));

        HttpRequest.GetHeaders(Headers);
        SetAuthorizationHeader(Headers, LogiqAuth, ConnectionUserSetup);

        Client.Send(HttpRequest, HttpResponse);

        exit(HttpResponse.IsSuccessStatusCode());
    end;

    internal procedure DownloadDocuments(var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    var
        ConnectionUserSetup: Record "Logiq Connection User Setup";
        ConnectionSetup: Record "Logiq Connection Setup";
        LogiqAuth: Codeunit "Logiq Auth";
        Client: HttpClient;
        Headers: HttpHeaders;
    begin
        HttpRequest.Method('GET');

        LogiqAuth.CheckSetup(ConnectionSetup);
        LogiqAuth.CheckUserSetup(ConnectionUserSetup);
        LogiqAuth.CheckUpdateTokens();

        HttpRequest.SetRequestUri(this.JoinUrlParts(ConnectionSetup."Base URL", ConnectionSetup."File List Endpoint"));
        HttpRequest.GetHeaders(Headers);
        SetAuthorizationHeader(Headers, LogiqAuth, ConnectionUserSetup);

        Client.Send(HttpRequest, HttpResponse);

        if not HttpResponse.IsSuccessStatusCode() then
            Error(this.DownloadDocumentsErr, HttpResponse.HttpStatusCode, HttpResponse.ReasonPhrase);
    end;

    internal procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; Documents: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)
    var
        ConnectionUserSetup: Record "Logiq Connection User Setup";
        ConnectionSetup: Record "Logiq Connection Setup";
        LogiqAuth: Codeunit "Logiq Auth";
        TempBlob: Codeunit "Temp Blob";
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        DocumentsArray: JsonArray;
        InStr: InStream;
        OutStr: OutStream;
        i: Integer;
    begin
        HttpRequest.Method('GET');

        LogiqAuth.CheckSetup(ConnectionSetup);
        LogiqAuth.CheckUserSetup(ConnectionUserSetup);
        LogiqAuth.CheckUpdateTokens();

        this.DownloadDocuments(HttpRequest, HttpResponse);

        HttpResponse.Content.ReadAs(InStr);
        DocumentsArray.ReadFrom(InStr);
        for i := 0 to DocumentsArray.Count() - 1 do begin
            Clear(TempBlob);
            TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
            DocumentsArray.GetObject(i).WriteTo(OutStr);
            Documents.Add(TempBlob);
        end;

        ReceiveContext.Http().SetHttpRequestMessage(HttpRequest);
        ReceiveContext.Http().SetHttpResponseMessage(HttpResponse);
    end;

    internal procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; Document: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    var
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        InStr: InStream;
        OutStr: OutStream;
        DocumentData, FileName : Text;
    begin
        Document.CreateInStream(InStr, TextEncoding::UTF8);
        InStr.ReadText(DocumentData);
        if not this.ParseReceivedFileName(DocumentData, FileName) then begin
            this.EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, this.FileNameNotFoundErr);
            exit;
        end;

        this.DownloadFile(FileName, HttpRequest, HttpResponse);
        HttpResponse.Content.ReadAs(DocumentData);
        if DocumentData = '' then
            this.EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, StrSubstNo(this.FileNotFoundErr, FileName));

        ReceiveContext.GetTempBlob().CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(DocumentData);

        ReceiveContext.Http().SetHttpRequestMessage(HttpRequest);
        ReceiveContext.Http().SetHttpResponseMessage(HttpResponse);
    end;

    internal procedure DownloadFile(FileName: Text; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    var
        ConnectionUserSetup: Record "Logiq Connection User Setup";
        ConnectionSetup: Record "Logiq Connection Setup";
        LogiqAuth: Codeunit "Logiq Auth";
        Client: HttpClient;
        Headers: HttpHeaders;
    begin
        HttpRequest.Method('GET');

        LogiqAuth.CheckSetup(ConnectionSetup);
        LogiqAuth.CheckUserSetup(ConnectionUserSetup);
        LogiqAuth.CheckUpdateTokens();

        HttpRequest.SetRequestUri(FileName);
        HttpRequest.GetHeaders(Headers);
        SetAuthorizationHeader(Headers, LogiqAuth, ConnectionUserSetup);

        Client.Send(HttpRequest, HttpResponse);
    end;

    local procedure SetAuthorizationHeader(var Headers: HttpHeaders; var LogiqAuth: Codeunit "Logiq Auth"; var LogiqConnectionUserSetup: Record "Logiq Connection User Setup")
    begin
        if Headers.Contains('Authorization') then
            Headers.Remove('Authorization');
        Headers.Add('Authorization', SecretStrSubstNo('Bearer %1', LogiqAuth.GetAccessToken(LogiqConnectionUserSetup)));
    end;

    local procedure BuildRequestUri(Endpoint: Text) FullUrl: Text
    var
        LogiqConnectionSetup: Record "Logiq Connection Setup";
        LogiqAuth: Codeunit "Logiq Auth";
    begin
        LogiqAuth.CheckSetup(LogiqConnectionSetup);

        FullUrl := this.JoinUrlParts(LogiqConnectionSetup."Base URL", Endpoint);
    end;

    local procedure JoinUrlParts(Part1: Text; Part2: Text) JoinedUrl: Text
    begin
        if Part1.EndsWith('/') then begin
            if Part2.StartsWith('/') then
                Part2 := Part2.Substring(2);
        end else
            if not Part2.StartsWith('/') then
                Part2 := '/' + Part2;

        JoinedUrl := Part1 + Part2;
    end;

    local procedure GetFileContentAsMultipart(FileBlob: Codeunit "Temp Blob"; FileName: Text; Boundary: Text): Text
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        MultiPartContentBuilder: TextBuilder;
        BizDoc: Text;
        InStr: InStream;
    begin
        MultiPartContentBuilder.AppendLine('--' + Format(Boundary));

        // bizDoc
        FileBlob.CreateInStream(InStr, TextEncoding::UTF8);
        XMLDOMManagement.TryGetXMLAsText(InStr, BizDoc);

        MultiPartContentBuilder.AppendLine(StrSubstNo(this.ContentTok, FileName));
        MultiPartContentBuilder.AppendLine(this.ContentTypeMultipartTok);
        MultiPartContentBuilder.AppendLine('');
        MultiPartContentBuilder.AppendLine(BizDoc);

        // filename
        MultiPartContentBuilder.AppendLine('--' + Format(Boundary));
        MultiPartContentBuilder.AppendLine(this.FileNameContentTok);
        MultiPartContentBuilder.AppendLine('');
        MultiPartContentBuilder.AppendLine(FileName);

        MultiPartContentBuilder.AppendLine('--' + Format(Boundary) + '--');
        exit(MultiPartContentBuilder.ToText());
    end;

    local procedure GetExternalIdFromReponse(ResponseMessage: HttpResponseMessage) ExternalId: Text[50]
    var
        ResponseTxt: Text;
        JsonObj: JsonObject;
        JsonTok: JsonToken;
    begin
        ResponseMessage.Content.ReadAs(ResponseTxt);
        if not JsonObj.ReadFrom(ResponseTxt) then
            Error(this.InvalidResponseErr);

        if JsonObj.Get('externalId', JsonTok) then
            if JsonTok.IsValue() then
                ExternalId := CopyStr(JsonTok.AsValue().AsText(), 1, MaxStrLen(ExternalId))
            else
                if JsonTok.IsObject then begin
                    JsonObj := JsonTok.AsObject();
                    if JsonObj.Get('value', JsonTok) then
                        ExternalId := CopyStr(JsonTok.AsValue().AsText(), 1, MaxStrLen(ExternalId));
                end;
    end;

    local procedure LogSendingError(EDocument: Record "E-Document"; ResponseMessage: HttpResponseMessage)
    var
        EDocumentsErrorHelper: Codeunit "E-Document Error Helper";
    begin
        if ResponseMessage.IsBlockedByEnvironment() then
            EDocumentsErrorHelper.LogSimpleErrorMessage(EDocument, this.BlockedByEnvErr)
        else
            EDocumentsErrorHelper.LogSimpleErrorMessage(EDocument, StrSubstNo(this.SendingFailedErr, ResponseMessage.HttpStatusCode(), ResponseMessage.ReasonPhrase()));
    end;

    local procedure ParseReceivedFileName(ContentTxt: Text; var FileName: Text): Boolean
    var
        JsonObj: JsonObject;
        JsonTok: JsonToken;
    begin
        if not JsonObj.ReadFrom(ContentTxt) then
            exit(false);

        if not JsonObj.Get('fileName', JsonTok) then
            exit(false);

        FileName := JsonTok.AsValue().AsText();

        if FileName = '' then
            exit(false)
        else
            exit(true);
    end;

    var
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        BlockedByEnvErr: Label 'Logiq E-Document API is blocked by environment';
        ContentTok: Label 'Content-Disposition: form-data; name="bizDoc"; filename="%1"', Locked = true;
        ContentTypeMultipartTok: Label 'Content-Type: text/xml', Locked = true;
        ContentTypeTok: Label 'multipart/form-data; boundary="%1"', Locked = true;
        DownloadDocumentsErr: Label 'Failed to download documents from Logiq system. Http response code: %1; error: %2', Comment = '%1=HTTP response code,%2=error message';
        FailedHttpCallMsg: Label 'Failed to get status of document %1 in Logiq system. Http call returned status code %2 with error: %3', Comment = '%1=Document No., %2=HTTP status code, %3=error message';
        FileNameContentTok: Label 'Content-Disposition: form-data; name="filename"', Locked = true;
        FileNameNotFoundErr: Label 'File name not found in response';
        FileNameTok: Label '%1.xml', Locked = true;
        FileNotFoundErr: Label 'File %1 could not be downloaded', Comment = '%1=file name';
        InvalidResponseErr: Label 'Invalid response from Logiq E-Document API';
        SendingFailedErr: Label 'Sending document failed with HTTP Status code %1. Error message: %2', Comment = '%1=HTTP Status code, %2=error message';
        ServiceFailedFileErr: Label 'Logiq rejected the sent file';

}
