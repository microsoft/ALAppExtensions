// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

using Microsoft.EServices.EDocument;
using System.Utilities;
using System.Text;
using System.Xml;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Document;
codeunit 6361 "Pagero Connection"

{
    Access = Internal;

    procedure SendEDocument(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    var
        PageroAuth: Codeunit "Pagero Auth.";
        HttpContentResponse: HttpContent;
        RefreshTokResult: Boolean;
        HttpError: Text;
    begin
        IsAsync := true;
        if not HandleSendFilePostRequest(TempBlob, EDocument, HttpRequest, HttpResponse, false) then begin
            RefreshTokResult := PageroAuth.RefreshAccessToken(HttpError);
            if RefreshTokResult then
                HandleSendFilePostRequest(TempBlob, EDocument, HttpRequest, HttpResponse, true);
        end;

        HttpContentResponse := HttpResponse.Content;

        EDocument."File ID" := CopyStr(ParseSendFileResponse(HttpContentResponse), 1, MaxStrLen(EDocument."File ID"));
    end;

    procedure HandleErrors(EDocument: Record "E-Document")
    var
        EDocumentService: Record "E-Document Service";
        EDocumentServiceStatus: Record "E-Document Service Status";
        PageroAuthMgt: Codeunit "Pagero Auth.";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        HttpContentResponse: HttpContent;
        ResultBool: Boolean;
        HttpError: Text;
        Result: Text;
        FilepartID, ErrorDescription : Text;
    begin
        FindCheckEDocumentServiceStatus(EDocumentServiceStatus, EDocument, EDocumentService, EDocumentServiceStatus.Status::"Sending Error");

        EDocumentService.Get(GetEDocumentServiceCode());
        if not HandleErrorsGetRequest(EDocument, HttpRequestMessage, HttpResponseMessage, false) then begin
            ResultBool := PageroAuthMgt.RefreshAccessToken(HttpError);
            if ResultBool then
                HandleErrorsGetRequest(EDocument, HttpRequestMessage, HttpResponseMessage, false);
        end;

        EDocumentService.Get(GetEDocumentServiceCode());
        InsertIntegrationLog(EDocument, EDocumentService, HttpRequestMessage, HttpResponseMessage);

        HttpContentResponse := HttpResponseMessage.Content;
        Result := ParseHandleErrorResponse(HttpContentResponse, FilepartID, ErrorDescription);
        if Result <> '' then begin
            EDocument."Filepart Id" := FilepartID;
            EDocument.Modify();
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, ErrorDescription);
            EDocumentServiceStatus.Status := EDocumentServiceStatus.Status::Sent;
            EDocumentServiceStatus.Modify();
        end;

        EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, Result);
    end;

    procedure CancelEDocument(EDocument: Record "E-Document"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage): Boolean
    var
        EDocumentService: Record "E-Document Service";
        EDocumentServiceStatus: Record "E-Document Service Status";
    begin
        EDocumentService.Get(GetEDocumentServiceCode());
        FindCheckEDocumentServiceStatus(EDocumentServiceStatus, EDocument, EDocumentService, EDocumentServiceStatus.Status::"Sending Error");

        if not HandleSendActionRequest(EDocument, HttpRequest, HttpResponse, 'Cancel', false) then
            exit(false);
        if not IsSuccessStatus(HttpResponse) then
            exit(false);

        exit(true);
    end;

    procedure RestartEDocument(EDocument: Record "E-Document")
    var
        EDocumentService: Record "E-Document Service";
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocumentServices: Page "E-Document Services";
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
    begin
        EDocumentServices.LookupMode(true);
        if EDocumentServices.RunModal() = Action::LookupOK then
            EDocumentServices.GetRecord(EDocumentService);
        if EDocumentService."Service Integration" <> EDocumentService."Service Integration"::Pagero then
            exit;

        FindCheckEDocumentServiceStatus(EDocumentServiceStatus, EDocument, EDocumentService, EDocumentServiceStatus.Status::"Sending Error");

        HandleSendActionRequest(EDocument, HttpRequest, HttpResponse, 'Restart', false);
        InsertIntegrationLog(EDocument, EDocumentService, HttpRequest, HttpResponse);
        if not IsSuccessStatus(HttpResponse) then
            exit;

        EDocumentServiceStatus.Status := EDocumentServiceStatus.Status::Sent;
        EDocumentServiceStatus.Modify();
    end;

    procedure GetADocument(EDocument: Record "E-Document")
    var
        EDocumentService: Record "E-Document Service";
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocumentServices: Page "E-Document Services";
    begin
        EDocumentServices.LookupMode(true);
        if EDocumentServices.RunModal() = Action::LookupOK then
            EDocumentServices.GetRecord(EDocumentService);
        if EDocumentService."Service Integration" <> EDocumentService."Service Integration"::Pagero then
            exit;

        FindCheckEDocumentServiceStatus(EDocumentServiceStatus, EDocument, EDocumentService, EDocumentServiceStatus.Status::Sent);
    end;

    procedure ReceiveAppResponse(EDocument: Record "E-Document")
    begin

    end;

    procedure GetTargetDocument(EDocument: Record "E-Document")
    var
        EDocumentService: Record "E-Document Service";
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocumentLog: Record "E-Document Log";
        TempBlob: Codeunit "Temp Blob";
        EDocumentServices: Page "E-Document Services";
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        HttpContentResponse: HttpContent;
        OutStr: OutStream;
        InStr: InStream;
    begin
        EDocumentServices.LookupMode(true);
        if EDocumentServices.RunModal() = Action::LookupOK then
            EDocumentServices.GetRecord(EDocumentService);
        if EDocumentService."Service Integration" <> EDocumentService."Service Integration"::Pagero then
            exit;

        FindCheckEDocumentServiceStatus(EDocumentServiceStatus, EDocument, EDocumentService, EDocumentServiceStatus.Status::"Sending Error");

        HandleGetTargetDocumentRequest(EDocument, HttpRequest, HttpResponse, false);
        if not IsSuccessStatus(HttpResponse) then
            exit;

        InsertIntegrationLog(EDocument, EDocumentService, HttpRequest, HttpResponse);

        InsertLog(EdocumentLog, EDocument, EDocumentService, 0, EDocumentServiceStatus.Status::Imported);
        HttpContentResponse := HttpResponse.Content;
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        HttpContentResponse.ReadAs(InStr);
        CopyStream(OutStr, InStr);
        EdocumentLog."E-Doc. Data Storage Entry No." := AddTempBlobToLog(TempBlob);
        EdocumentLog.Modify();
    end;

    procedure GetCreateReceivedDocument(EDocumentService: Record "E-Document Service")
    begin
        // GetReceivedDocumentsRequest
    end;

    local procedure FindCheckEDocumentServiceStatus(var EDocumentServiceStatus: Record "E-Document Service Status"; EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; EDocStatus: Enum "E-Document Service Status"): Boolean
    begin
        EDocumentServiceStatus.SetRange("E-Document Entry No", EDocument."Entry No");
        EDocumentServiceStatus.SetRange("E-Document Service Code", EDocumentService.Code);
        if not EDocumentServiceStatus.FindLast() then
            exit;
        EDocumentServiceStatus.TestField(Status, EDocStatus);
    end;

    procedure PpocessLogResponse(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; IsSuccess: Boolean)
    var
        ErrorMessage: Text;
    begin
        if not IsSuccess then
            if HttpResponse.IsBlockedByEnvironment() then
                ErrorMessage := StrSubstNo(EnvironmentBlocksErr, HttpRequest.GetRequestUri())
            else
                ErrorMessage := StrSubstNo(ConnectionErr, HttpRequest.GetRequestUri());

        InsertIntegrationLog(EDocument, EDocumentService, HttpRequest, HttpResponse);
    end;

    procedure TempBlobToTxt(var TempBlob: Codeunit "Temp Blob"): Text
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        InStr: InStream;
        Content: Text;
    begin
        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
        XMLDOMManagement.TryGetXMLAsText(InStr, Content);
        exit(Content);
    end;

    local procedure HandleSendFilePostRequest(var TempBlob: Codeunit "Temp Blob"; var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; Retry: Boolean): Boolean
    var
        PageroAPIRequests: Codeunit "Pagero API Requests";
    begin
        if not Retry then begin
            PageroAPIRequests.SendFilePostRequest(TempBlob, EDocument);
            if PageroAPIRequests.IsNotAuthorized() then
                exit(false);
        end else
            PageroAPIRequests.SendFilePostRequest(TempBlob, EDocument);
        PageroAPIRequests.GetRequestResponse(HttpRequest, HttpResponse);
        exit(true);
    end;

    local procedure HandleErrorsGetRequest(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; Retry: Boolean): Boolean
    var
        PageroAPIRequests: Codeunit "Pagero API Requests";
    begin
        if not Retry then begin
            PageroAPIRequests.GetFilepartsErrorRequest(EDocument);
            if PageroAPIRequests.IsNotAuthorized() then
                exit(false);
        end else
            PageroAPIRequests.GetFilepartsErrorRequest(EDocument);
        PageroAPIRequests.GetRequestResponse(HttpRequest, HttpResponse);
        exit(true);
    end;

    local procedure HandleSendActionRequest(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; ActionName: Text; Retry: Boolean): Boolean
    var
        PageroAPIRequests: Codeunit "Pagero API Requests";
    begin
        if not Retry then begin
            PageroAPIRequests.SendActionPostRequest(EDocument, ActionName);
            if PageroAPIRequests.IsNotAuthorized() then
                exit(false);
        end else
            PageroAPIRequests.SendActionPostRequest(EDocument, ActionName);
        PageroAPIRequests.GetRequestResponse(HttpRequest, HttpResponse);
        exit(true);
    end;

    local procedure HandleGetTargetDocumentRequest(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; Retry: Boolean): Boolean
    var
        PageroAPIRequests: Codeunit "Pagero API Requests";
    begin
        if not Retry then begin
            PageroAPIRequests.GetTargetDocumentRequest(EDocument);
            if PageroAPIRequests.IsNotAuthorized() then
                exit(false);
        end else
            PageroAPIRequests.GetTargetDocumentRequest(EDocument);
        PageroAPIRequests.GetRequestResponse(HttpRequest, HttpResponse);
        exit(true);
    end;


    procedure PrepareMultipartContent(DocumentType: Text; SendMode: Text; SendingCompanyID: Text; SenderReference: Text; FileName: Text; Payload: Text; var Boundary: Text): Text
    var
        MultiPartContent: TextBuilder;
        ContentTxt: Text;
    begin
        Boundary := Format(CreateGuid());
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

    procedure ParseSendFileResponse(HttpContentResponse: HttpContent): Text
    var
        JsonManagement: Codeunit "JSON Management";
        Result: Text;
        Value: Text;
    begin
        Result := IsJsonString(HttpContentResponse);
        if Result = '' then
            exit('');

        if not JsonManagement.InitializeFromString(Result) then
            exit('');

        JsonManagement.GetStringPropertyValueByName('id', Value);
        exit(Value);
    end;

    procedure ParseHandleErrorResponse(HttpContentResponse: HttpContent; var FilepartID: Text; var ErrorDescription: Text): Text
    var
        JsonManagement: Codeunit "JSON Management";
        Result: Text;
        Value: Text;
    begin
        Result := IsJsonString(HttpContentResponse);
        if Result = '' then
            exit('');

        if not JsonManagement.InitializeFromString(Result) then
            exit('');

        JsonManagement.GetStringPropertyValueByName('id', Value);
        JsonManagement.GetStringPropertyValueByName('description', ErrorDescription);
        exit(Value);
    end;

    procedure IsJsonString(HttpContentResponse: HttpContent): Text
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

    procedure IsSuccessStatus(HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        exit(HttpResponseMessage.HttpStatusCode() = 200);
    end;

    procedure IsCreatedStatus(HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        exit(HttpResponseMessage.HttpStatusCode() = 201);
    end;

    local procedure GetEDocumentServices(var EDocumentService: Record "E-Document Service"): Boolean
    begin
        EDocumentService.SetRange("Service Integration", EDocumentService."Service Integration"::Pagero);
        exit(EDocumentService.FindSet());
    end;

    local procedure GetEDocumentServiceCode(): Text
    var
        EDocumentService: Record "E-Document Service";
    begin
        if GetEDocumentServices(EDocumentService) then
            exit(EDocumentService.Code);
        exit('');
    end;

    procedure InsertEDocumentService(var EDocumentServiceStatus: Record "E-Document Service Status"; EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service")
    begin
        EDocumentServiceStatus."E-Document Entry No" := EDocument."Entry No";
        EDocumentServiceStatus."E-Document Service Code" := EDocumentService.Code;
        EDocumentServiceStatus.Insert(true);
    end;

    procedure UpdateEDocumentServiceStatus(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; Status: Enum "E-Document Service Status")
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
    begin
        EDocumentServiceStatus.SetRange("E-Document Entry No", EDocument."Entry No");
        EDocumentServiceStatus.SetRange("E-Document Service Code", EDocumentService.Code);
        if not EDocumentServiceStatus.Findlast() then
            exit;

        EDocumentServiceStatus.Validate(Status, Status);
        EDocumentServiceStatus.Modify(true);
    end;

    procedure InsertLog(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; EDocDataStorageEntryNo: Integer; EDocumentServiceStatus: Enum "E-Document Service Status"): Integer
    var
        EDocumentLog: Record "E-Document Log";
    begin
        // if EDocumentService.Code <> '' then
        //     UpdateServiceStatus(EDocument, EDocumentService, EDocumentServiceStatus);
        EDocumentLog."Entry No." := 0;
        EDocumentLog.Validate("Document Type", EDocument."Document Type");
        EDocumentLog.Validate("Document No.", EDocument."Document No.");
        EDocumentLog.Validate("E-Doc. Entry No", EDocument."Entry No");
        EDocumentLog.Validate(Status, EDocumentServiceStatus);
        EDocumentLog.Validate("Service Integration", EDocumentService."Service Integration");
        EDocumentLog.Validate("Service Code", EDocumentService.Code);
        EDocumentLog.Validate("Document Format", EDocumentService."Document Format");
        EDocumentLog.Validate("E-Doc. Data Storage Entry No.", EDocDataStorageEntryNo);

        EDocumentLog.Insert();
        exit(EDocumentLog."Entry No.");
    end;

    procedure InsertLog(var EDocumentLog: Record "E-Document Log"; EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; EDocDataStorageEntryNo: Integer; EDocumentServiceStatus: Enum "E-Document Service Status"): Integer
    begin
        EDocumentLog."Entry No." := 0;
        EDocumentLog.Validate("Document Type", EDocument."Document Type");
        EDocumentLog.Validate("Document No.", EDocument."Document No.");
        EDocumentLog.Validate("E-Doc. Entry No", EDocument."Entry No");
        EDocumentLog.Validate(Status, EDocumentServiceStatus);
        EDocumentLog.Validate("Service Integration", EDocumentService."Service Integration");
        EDocumentLog.Validate("Service Code", EDocumentService.Code);
        EDocumentLog.Validate("Document Format", EDocumentService."Document Format");
        EDocumentLog.Validate("E-Doc. Data Storage Entry No.", EDocDataStorageEntryNo);

        EDocumentLog.Insert();
        exit(EDocumentLog."Entry No.");
    end;

    procedure InsertIntegrationLog(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage)
    var
        EDocumentIntegrationLog: Record "E-Document Integration Log";
        EDocumentIntegrationLogRecRef: RecordRef;
        RequestTxt: Text;
    begin
        if EDocumentService."Service Integration" = EDocumentService."Service Integration"::"No Integration" then
            exit;

        EDocumentIntegrationLog.Validate("E-Doc. Entry No", EDocument."Entry No");
        EDocumentIntegrationLog.Validate("Service Code", EDocumentService.Code);
        EDocumentIntegrationLog.Validate("Response Status", HttpResponse.HttpStatusCode());
        EDocumentIntegrationLog.Validate(URL, HttpRequest.GetRequestUri());
        EDocumentIntegrationLog.Validate(Method, HttpRequest.Method());
        EDocumentIntegrationLog.Insert();

        EDocumentIntegrationLogRecRef.GetTable(EDocumentIntegrationLog);


        if HttpRequest.Content.ReadAs(RequestTxt) then begin
            InsertIntegrationBlob(EDocumentIntegrationLogRecRef, RequestTxt, EDocumentIntegrationLog.FieldNo(EDocumentIntegrationLog."Request Blob"));
            EDocumentIntegrationLogRecRef.Modify();
        end;

        if HttpResponse.Content.ReadAs(RequestTxt) then begin
            InsertIntegrationBlob(EDocumentIntegrationLogRecRef, RequestTxt, EDocumentIntegrationLog.FieldNo(EDocumentIntegrationLog."Response Blob"));
            EDocumentIntegrationLogRecRef.Modify();
        end;

    end;

    local procedure InsertIntegrationBlob(var EDocumentIntegrationLogRecRef: RecordRef; Data: Text; FieldNo: Integer)
    var
        TempBlob: Codeunit "Temp Blob";
        OutStreamObj: OutStream;
    begin
        TempBlob.CreateOutStream(OutStreamObj);
        OutStreamObj.WriteText(Data);

        TempBlob.ToRecordRef(EDocumentIntegrationLogRecRef, FieldNo);
    end;

    procedure AddTempBlobToLog(var TempBlob: Codeunit "Temp Blob"): Integer
    var
        EDocDataStorage: Record "E-Doc. Data Storage";
        EDocRecRef: RecordRef;
    begin
        EDocDataStorage.Init();
        EDocDataStorage.Insert();
        EDocDataStorage."Data Storage Size" := TempBlob.Length();
        EDocRecRef.GetTable(EDocDataStorage);
        TempBlob.ToRecordRef(EDocRecRef, EDocDataStorage.FieldNo("Data Storage"));
        EDocRecRef.Modify();
        exit(EDocDataStorage."Entry No.");
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

        EDocumentService.SetRange("Service Integration", EDocumentService."Service Integration"::Pagero);
        if EDocumentService.FindFirst() then;
        EDocumentServiceStatus.SetRange("E-Document Entry No", EDocument."Entry No");
        EDocumentServiceStatus.SetRange("E-Document Service Code", EDocumentService.Code);
        if EDocumentServiceStatus.FindSet() then
            repeat
                EDocumentServiceStatus.TestField(EDocumentServiceStatus.Status, EDocumentServiceStatus.Status::Approved);
            until EDocumentServiceStatus.Next() = 0;
    end;

    var
        EnvironmentBlocksErr: Label 'Environment blocks an outgoing HTTP request to ''%1''.', Comment = '%1 - url, e.g. https://microsoft.com';
        ConnectionErr: Label 'Could not connect to the remote service %1.', Comment = '%1 - url, e.g. https://microsoft.com';
}