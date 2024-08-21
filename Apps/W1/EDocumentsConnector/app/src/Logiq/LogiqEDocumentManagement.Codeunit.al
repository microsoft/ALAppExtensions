namespace Microsoft.EServices.EDocumentConnector.Logiq;

using Microsoft.eServices.EDocument;
using System.Utilities;
using System.Xml;

codeunit 6382 "Logiq E-Document Management"
{
    Access = Internal;
    Permissions = tabledata "E-Document" = m;

#pragma warning disable AA0150
    internal procedure Send(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    var
        LogiqConnectionUserSetup: Record "Logiq Connection User Setup";
        LogiqAuth: Codeunit "Logiq Auth";
        Client: HttpClient;
        Headers: HttpHeaders;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        BodyText: Text;
        FileNameText: Text;
        Boundary: Text;
        FileNameTok: Label '%1.xml', Locked = true;
        ContentTypeTok: Label 'multipart/form-data; boundary="%1"', Locked = true;
    begin
        HttpRequest.Method('POST');

        LogiqAuth.CheckUserSetup(LogiqConnectionUserSetup);
        LogiqAuth.CheckUpdateTokens();

        HttpRequest.SetRequestUri(BuildRequestUri(LogiqConnectionUserSetup."Document Transfer Endpoint"));

        HttpRequest.GetHeaders(Headers);
        if Headers.Contains('Authorization') then
            Headers.Remove('Authorization');
        Headers.Add('Authorization', SecretStrSubstNo('Bearer %1', LogiqConnectionUserSetup.GetAccessToken()));

        FileNameText := StrSubstNo(FileNameTok, EDocument."Document No.");
        Boundary := DelChr(Format(CreateGuid()), '<>=', '{}&[]*()!@#$%^+=;:"''<>,.?/|\\~`');

        BodyText := GetFileContentAsMultipart(TempBlob, FileNameText, Boundary);
        Content.WriteFrom(BodyText);

        Content.GetHeaders(ContentHeaders);
        if ContentHeaders.Contains('Content-Type') then
            ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', StrSubstNo(ContentTypeTok, Boundary));

        HttpRequest.Content(Content);

        Client.Send(HttpRequest, HttpResponse);

        if HttpResponse.IsSuccessStatusCode() then
            SaveLogiqExternalId(EDocument, GetExternalIdFromReponse(HttpResponse))
        else
            LogSendingError(EDocument, HttpResponse);
    end;
#pragma warning restore AA0150

    local procedure SaveLogiqExternalId(EDocument: Record "E-Document"; ExternalId: Text[50])
    begin
        if EDocument.Get(EDocument."Entry No") then begin
            EDocument."Logiq External Id" := ExternalId;
            EDocument.Modify(false);
        end;
    end;

    internal procedure UpdateStatus(var EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service")
    var
        Status: Enum "E-Document Service Status";
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        RequestSuccessful: Boolean;
        FailedHttpCallMsg: Label 'Failed to get status of document %1 in Logiq system. Http call returned status code %2 with error: %3', Comment = '%1=Document No., %2=HTTP status code, %3=error message';
    begin
        if EDocumentService."Service Integration" <> EDocumentService."Service Integration"::Logiq then
            exit;

        RequestSuccessful := GetStatus(EDocument, HttpRequest, HttpResponse);

        if RequestSuccessful then begin
            Status := ParseDocumentStatus(HttpResponse);
            EDocumentLogHelper.InsertLog(EDocument, EDocumentService, Status);
            EDocumentLogHelper.InsertIntegrationLog(EDocument, EDocumentService, HttpRequest, HttpResponse);
        end else begin
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, StrSubstNo(FailedHttpCallMsg, EDocument."Document No.", HttpResponse.HttpStatusCode, HttpResponse.ReasonPhrase));
            if EDocument.Status <> EDocument.Status::Processed then
                EDocumentLogHelper.InsertIntegrationLog(EDocument, EDocumentService, HttpRequest, HttpResponse);
            Error(FailedHttpCallMsg, EDocument."Document No.", HttpResponse.HttpStatusCode, HttpResponse.ReasonPhrase);
        end;
    end;

    internal procedure GetStatus(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    var
        LogiqConnectionUserSetup: Record "Logiq Connection User Setup";
        LogiqAuth: Codeunit "Logiq Auth";
        Client: HttpClient;
        Headers: HttpHeaders;
    begin
        HttpRequest.Method('GET');

        LogiqAuth.CheckUserSetup(LogiqConnectionUserSetup);
        LogiqAuth.CheckUpdateTokens();

        HttpRequest.SetRequestUri(BuildRequestUri(JoinUrlParts(LogiqConnectionUserSetup."Document Status Endpoint", EDocument."Logiq External Id")));

        HttpRequest.GetHeaders(Headers);
        if Headers.Contains('Authorization') then
            Headers.Remove('Authorization');
        Headers.Add('Authorization', SecretStrSubstNo('Bearer %1', LogiqConnectionUserSetup.GetAccessToken()));

        Client.Send(HttpRequest, HttpResponse);

        exit(HttpResponse.IsSuccessStatusCode());
    end;

    internal procedure DownloadDocuments(var TempBlob: Codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    var
        LogiqConnectionUserSetup: Record "Logiq Connection User Setup";
        LogiqConnectionSetup: Record "Logiq Connection Setup";
        LogiqAuth: Codeunit "Logiq Auth";
        Client: HttpClient;
        Headers: HttpHeaders;
        InStr: InStream;
        OutStr: OutStream;
        DownloadDocumentsErr: Label 'Failed to download documents from Logiq system. Http response code: %1; error: %2', Comment = '%1=HTTP response code,%2=error message';
    begin
        HttpRequest.Method('GET');

        LogiqAuth.CheckSetup(LogiqConnectionSetup);
        LogiqAuth.CheckUserSetup(LogiqConnectionUserSetup);
        LogiqAuth.CheckUpdateTokens();

        HttpRequest.SetRequestUri(JoinUrlParts(LogiqConnectionSetup."Base URL", LogiqConnectionSetup."File List Endpoint"));

        HttpRequest.GetHeaders(Headers);
        if Headers.Contains('Authorization') then
            Headers.Remove('Authorization');
        Headers.Add('Authorization', SecretStrSubstNo('Bearer %1', LogiqConnectionUserSetup.GetAccessToken()));

        Client.Send(HttpRequest, HttpResponse);

        if HttpResponse.IsSuccessStatusCode() then begin
            HttpResponse.Content.ReadAs(InStr);
            TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
            CopyStream(OutStr, InStr);
        end else
            Error(DownloadDocumentsErr, HttpResponse.HttpStatusCode, HttpResponse.ReasonPhrase);
    end;

    internal procedure GetDocumentCountInBatch(var TempBlob: Codeunit "Temp Blob"): Integer
    var
        JsonArray: JsonArray;
        InStr: InStream;
    begin
        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);

        if not JsonArray.ReadFrom(InStr) then
            exit(0);

        exit(JsonArray.Count());
    end;

    internal procedure DownloadFile(FileName: Text; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    var
        LogiqConnectionUserSetup: Record "Logiq Connection User Setup";
        LogiqConnectionSetup: Record "Logiq Connection Setup";
        LogiqAuth: Codeunit "Logiq Auth";
        Client: HttpClient;
        Headers: HttpHeaders;
    begin
        HttpRequest.Method('GET');

        LogiqAuth.CheckSetup(LogiqConnectionSetup);
        LogiqAuth.CheckUserSetup(LogiqConnectionUserSetup);
        LogiqAuth.CheckUpdateTokens();

        HttpRequest.SetRequestUri(FileName);

        HttpRequest.GetHeaders(Headers);
        if Headers.Contains('Authorization') then
            Headers.Remove('Authorization');
        Headers.Add('Authorization', SecretStrSubstNo('Bearer %1', LogiqConnectionUserSetup.GetAccessToken()));

        Client.Send(HttpRequest, HttpResponse);
    end;

    local procedure BuildRequestUri(Endpoint: Text) FullUrl: Text
    var
        LogiqConnectionSetup: Record "Logiq Connection Setup";
        LogiqAuth: Codeunit "Logiq Auth";
    begin
        LogiqAuth.CheckSetup(LogiqConnectionSetup);

        FullUrl := JoinUrlParts(LogiqConnectionSetup."Base URL", Endpoint);
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
        ContentTok: Label 'Content-Disposition: form-data; name="bizDoc"; filename="%1"', Locked = true;
        ContentTypeTok: Label 'Content-Type: text/xml', Locked = true;
        FileNameTok: Label 'Content-Disposition: form-data; name="filename"', Locked = true;
        BizDoc: Text;
        InStr: InStream;
    begin
        MultiPartContentBuilder.AppendLine('--' + Format(Boundary));

        // bizDoc
        FileBlob.CreateInStream(InStr, TextEncoding::UTF8);
        XMLDOMManagement.TryGetXMLAsText(InStr, BizDoc);

        MultiPartContentBuilder.AppendLine(StrSubstNo(ContentTok, FileName));
        MultiPartContentBuilder.AppendLine(ContentTypeTok);
        MultiPartContentBuilder.AppendLine('');
        MultiPartContentBuilder.AppendLine(BizDoc);

        // filename
        MultiPartContentBuilder.AppendLine('--' + Format(Boundary));
        MultiPartContentBuilder.AppendLine(FileNameTok);
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
        InvalidResponseErr: Label 'Invalid response from Logiq E-Document API';
    begin
        ResponseMessage.Content.ReadAs(ResponseTxt);
        if not JsonObj.ReadFrom(ResponseTxt) then
            Error(InvalidResponseErr);

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
        BlockedByEnvErr: Label 'Logiq E-Document API is blocked by environment';
        SendingFailedErr: Label 'Sending document failed with HTTP Status code %1. Error message: %2', Comment = '%1=HTTP Status code, %2=error message';
    begin
        if ResponseMessage.IsBlockedByEnvironment() then
            EDocumentsErrorHelper.LogSimpleErrorMessage(EDocument, BlockedByEnvErr)
        else
            EDocumentsErrorHelper.LogSimpleErrorMessage(EDocument, StrSubstNo(SendingFailedErr, ResponseMessage.HttpStatusCode(), ResponseMessage.ReasonPhrase()));
    end;

    local procedure ParseReceivedFileName(ContentTxt: Text; Index: Integer; var FileName: Text): Boolean
    var
        JsonArray: JsonArray;
        JsonObj: JsonObject;
        JsonTok: JsonToken;
    begin
        if not JsonArray.ReadFrom(ContentTxt) then
            exit(false);

        if Index > JsonArray.Count() then
            exit(false);

        if Index = 0 then
            JsonArray.Get(Index, JsonTok)
        else
            JsonArray.Get(Index - 1, JsonTok);
        if not JsonTok.IsObject() then
            exit(false);

        JsonObj := JsonTok.AsObject();
        if not JsonObj.Get('fileName', JsonTok) then
            exit(false);

        FileName := JsonTok.AsValue().AsText();

        if FileName = '' then
            exit(false)
        else
            exit(true);
    end;

    local procedure ParseDocumentStatus(Response: HttpResponseMessage) Status: Enum "E-Document Service Status"
    var
        InStr: InStream;
        JsonObj: JsonObject;
        JsonTok: JsonToken;
    begin
        Response.Content.ReadAs(InStr);
        if not JsonObj.ReadFrom(InStr) then
            exit(Status::"In Progress Logiq");

        if JsonObj.Get('state', JsonTok) then
            if JsonTok.IsValue() then
                case JsonTok.AsValue().AsText() of
                    'distributed':
                        exit(Status::Approved);
                    'failed':
                        exit(Status::"Failed Logiq");
                    else
                        exit(Status::"In Progress Logiq");
                end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Import", OnAfterInsertImportedEdocument, '', false, false)]
    local procedure OnAfterInsertEdocument(var EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; EDocCount: Integer; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage)
    var
        LocalHttpRequest: HttpRequestMessage;
        LocalHttpResponse: HttpResponseMessage;
        DocumentOutStream: OutStream;
        ContentData, FileName : Text;
        FileNameNotFoundErr: Label 'File name not found in response';
        FileNotFoundErr: Label 'File %1 could not be downloaded', Comment = '%1=file name';
    begin
        if EDocumentService."Service Integration" <> EDocumentService."Service Integration"::Logiq then
            exit;

        HttpResponse.Content.ReadAs(ContentData);
        if not ParseReceivedFileName(ContentData, EDocument."Index In Batch", FileName) then begin
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, FileNameNotFoundErr);
            exit;
        end;

        DownloadFile(FileName, LocalHttpRequest, LocalHttpResponse);
        EDocumentLogHelper.InsertIntegrationLog(EDocument, EDocumentService, LocalHttpRequest, LocalHttpResponse);

        LocalHttpResponse.Content.ReadAs(ContentData);
        if ContentData = '' then
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, StrSubstNo(FileNotFoundErr, FileName));

        Clear(TempBlob);
        TempBlob.CreateOutStream(DocumentOutStream, TextEncoding::UTF8);
        DocumentOutStream.WriteText(ContentData);

        EDocumentLogHelper.InsertLog(EDocument, EDocumentService, TempBlob, "E-Document Service Status"::Imported);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Document Log", OnUpdateEDocumentStatus, '', false, false)]
    local procedure OnUpdateEDocumentStatus(var EDocument: Record "E-Document"; var IsHandled: Boolean)
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
    begin
        EDocumentServiceStatus.SetRange("E-Document Entry No", EDocument."Entry No");
        EDocumentServiceStatus.SetRange(Status, EDocumentServiceStatus.Status::"Failed Logiq");

        if not EDocumentServiceStatus.IsEmpty() then begin
            EDocument.Validate(Status, EDocument.Status::Error);
            EDocument.Modify(false);
            IsHandled := true;
        end;
    end;

    var
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        EDocumentLogHelper: Codeunit "E-Document Log Helper";
}
