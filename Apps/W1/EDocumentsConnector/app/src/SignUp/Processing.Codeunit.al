// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using Microsoft.EServices.EDocument;
using System.Telemetry;
using System.Text;
using System.Utilities;

codeunit 6378 SignUpProcessing
{
    Access = Internal;
    Permissions = tabledata "E-Document" = m,
                  tabledata "E-Document Service Status" = m;

    procedure SendEDocument(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
        EdocumentService: Record "E-Document Service";
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        IsAsync := true;

        EDocumentHelper.GetEdocumentService(EDocument, EdocumentService);
        EDocumentServiceStatus.Get(EDocument."Entry No", EdocumentService.Code);

        case EDocumentServiceStatus.Status of
            EDocumentServiceStatus.Status::Exported:
                SendEDocument(EDocument, TempBlob, HttpRequest, HttpResponse);
            EDocumentServiceStatus.Status::"Sending Error":
                if EDocument."Document Id" = '' then
                    SendEDocument(EDocument, TempBlob, HttpRequest, HttpResponse);
        end;

        FeatureTelemetry.LogUptake('', ExternalServiceTok, Enum::"Feature Uptake Status"::Used);
    end;

    procedure GetDocumentResponse(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    var
    begin
        if not CheckIfDocumentStatusSuccessful(EDocument, HttpRequest, HttpResponse) then
            exit(false);

        exit(true);
    end;

    procedure GetDocumentSentResponse(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        EDocumentService: Record "E-Document Service";
        EDocumentServiceStatus: Record "E-Document Service Status";
        SignUpAPIRequests: Codeunit SignUpAPIRequests;
        SignUpProcessing: Codeunit SignUpProcessing;
        HttpContentResponse: HttpContent;
        Status, StatusDescription : Text;
    begin
        EDocumentHelper.GetEdocumentService(EDocument, EdocumentService);
        EDocumentServiceStatus.Get(EDocument."Entry No", EdocumentService.Code);
        SignUpAPIRequests.GetSentDocumentStatus(EDocument, HttpRequestMessage, HttpResponseMessage);
        HttpContentResponse := HttpResponseMessage.Content;
        if ParseGetADocumentApprovalResponse(HttpContentResponse, Status, StatusDescription) then
            case Status of
                'Ready':
                    exit(true);
                'Failed':
                    begin
                        if StatusDescription <> '' then
                            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, 'Reason: ' + StatusDescription);
                        SignUpProcessing.InsertLogWithIntegration(EDocument, EDocumentService, Enum::"E-Document Service Status"::Rejected, 0, HttpRequestMessage, HttpResponseMessage);
                        exit(false);
                    end;
            end;
        exit(false);
    end;

    procedure GetDocumentApproval(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        EDocumentService: Record "E-Document Service";
        EDocumentServiceStatus: Record "E-Document Service Status";
        SignUpAPIRequests: Codeunit SignUpAPIRequests;
        SignUpGetReadyStatus: Codeunit SignUpGetReadyStatus;
        SignUpProcessing: Codeunit SignUpProcessing;
        BlankRecordId: RecordId;
        HttpContentResponse: HttpContent;
        Status, StatusDescription : Text;
    begin
        EDocumentHelper.GetEdocumentService(EDocument, EdocumentService);
        EDocumentServiceStatus.Get(EDocument."Entry No", EdocumentService.Code);
        if not (EDocumentServiceStatus.Status in [EDocumentServiceStatus.Status::Sent, EDocumentServiceStatus.Status::"Pending Response"]) then
            Error(GetApprovalCheckStatusErr, EDocumentServiceStatus.Status);

        SignUpAPIRequests.GetSentDocumentStatus(EDocument, HttpRequestMessage, HttpResponseMessage);
        HttpContentResponse := HttpResponseMessage.Content;
        if ParseGetADocumentApprovalResponse(HttpContentResponse, Status, StatusDescription) then
            case Status of
                'Ready':
                    begin
                        if EDocumentServiceStatus.Status = EDocumentServiceStatus.Status::Approved then
                            SignUpGetReadyStatus.ScheduleEDocumentJob(Codeunit::SignUpPatchSent, BlankRecordId, 300000)
                        else
                            SignUpGetReadyStatus.ScheduleEDocumentJob(Codeunit::SignUpGetReadyStatus, BlankRecordId, 300000);
                        exit(true);
                    end;
                'Failed':
                    begin
                        if StatusDescription <> '' then
                            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, 'Reason: ' + StatusDescription);
                        SignUpProcessing.InsertLogWithIntegration(EDocument, EDocumentService, Enum::"E-Document Service Status"::Rejected, 0, HttpRequestMessage, HttpResponseMessage);
                        exit(false);
                    end;
            end;
        exit(false);
    end;

    procedure ReceiveDocument(var TempBlob: Codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    var
        ContentData: Text;
        OutStream: OutStream;
    begin
        if not SignUpConnection.GetReceivedDocuments(HttpRequest, HttpResponse, true) then
            exit;

        HttpResponse.Content.ReadAs(ContentData);

        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(ContentData);
    end;

    procedure GetDocumentCountInBatch(var TempBlob: Codeunit "Temp Blob"): Integer
    var
        ResponseInstream: InStream;
        ResponseTxt: Text;
    begin
        TempBlob.CreateInStream(ResponseInstream);
        ResponseInstream.ReadText(ResponseTxt);

        exit(GetNumberOfReceivedDocuments(ResponseTxt));
    end;

    local procedure SendEDocument(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage);
    var
        HttpContentResponse: HttpContent;
    begin
        SignUpConnection.HandleSendFilePostRequest(TempBlob, EDocument, HttpRequest, HttpResponse, true);
        HttpContentResponse := HttpResponse.Content;
        SetEDocumentFileID(EDocument."Entry No", ParseSendFileResponse(HttpContentResponse));
    end;

    local procedure ParseReceivedDocument(InputTxt: Text; Index: Integer; var DocumentId: Text): Boolean
    var
        JsonManagement: Codeunit "JSON Management";
        JsonManagement2: Codeunit "JSON Management";
        IncrementalTable: Text;
        Value: Text;
    begin
        if not JsonManagement.InitializeFromString(InputTxt) then
            exit(false);

        JsonManagement.GetArrayPropertyValueAsStringByName('inbox', Value);
        JsonManagement.InitializeCollection(Value);

        if Index = 0 then
            Index := 1;

        if Index > JsonManagement.GetCollectionCount() then
            exit(false);

        JsonManagement.GetObjectFromCollectionByIndex(IncrementalTable, Index - 1);
        JsonManagement2.InitializeObject(IncrementalTable);
        JsonManagement2.GetArrayPropertyValueAsStringByName('instanceId', DocumentId);
        exit(true);
    end;

    local procedure GetNumberOfReceivedDocuments(InputTxt: Text): Integer
    var
        JsonManagement: Codeunit "JSON Management";
        Value: Text;
    begin
        InputTxt := LeaveJustNewLine(InputTxt);

        if not JsonManagement.InitializeFromString(InputTxt) then
            exit(0);

        JsonManagement.GetArrayPropertyValueAsStringByName('inbox', Value);
        JsonManagement.InitializeCollection(Value);

        exit(JsonManagement.GetCollectionCount());
    end;

    local procedure CheckIfDocumentStatusSuccessful(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    var
        ErrorDescription: Text;
    begin
        if not SignUpConnection.CheckDocumentStatus(EDocument, HttpRequestMessage, HttpResponse, true) then
            exit(false);

        if DocumentHasErrorOrProcessing(EDocument, HttpResponse, ErrorDescription) then
            exit(false);

        exit(true);
    end;

    local procedure ParseSendFileResponse(HttpContentResponse: HttpContent): Text
    var
        JsonManagement: Codeunit "JSON Management";
        Result: Text;
        Value: Text;
    begin
        Result := SignUpHelpers.ParseJsonString(HttpContentResponse);
        if Result = '' then
            exit('');

        if not JsonManagement.InitializeFromString(Result) then
            exit('');

        JsonManagement.GetStringPropertyValueByName('peppolInstanceId', Value);
        exit(Value);
    end;

    local procedure SetEDocumentFileID(EDocEntryNo: Integer; FileId: Text)
    var
        EDocument: Record "E-Document";
    begin
        if FileId = '' then
            exit;
        if not EDocument.Get(EDocEntryNo) then
            exit;

        EDocument."Document Id" := CopyStr(FileId, 1, MaxStrLen(EDocument."Document Id"));
        EDocument.Modify();
    end;

    local procedure DocumentHasErrorOrProcessing(EDocument: Record "E-Document"; HttpResponse: HttpResponseMessage; var ErrorDescription: Text): Boolean
    var
        EDocumentService: Record "E-Document Service";
        EDocumentServiceStatus: Record "E-Document Service Status";
        JsonManagement: Codeunit "JSON Management";
        SignUpGetReadyStatus: Codeunit SignUpGetReadyStatus;
        BlankRecordId: RecordId;
        HttpContentResponse: HttpContent;
        Result, Value : Text;
    begin
        HttpContentResponse := HttpResponse.Content;
        Result := SignUpHelpers.ParseJsonString(HttpContentResponse);
        if Result = '' then
            exit(true);

        if not JsonManagement.InitializeFromString(Result) then
            exit(true);

        JsonManagement.GetArrayPropertyValueAsStringByName('status', Value);

        if Value in ['Sent'] then begin
            SignUpGetReadyStatus.ScheduleEDocumentJob(Codeunit::SignUpGetReadyStatus, BlankRecordId, 120000);
            exit(false);
        end;

        if Value in ['Ready'] then begin
            EDocumentHelper.GetEdocumentService(EDocument, EDocumentService);
            EDocumentServiceStatus.Get(EDocument."Entry No", EdocumentService.Code);
            if EDocumentServiceStatus.Status = EDocumentServiceStatus.Status::Approved then
                SignUpGetReadyStatus.ScheduleEDocumentJob(Codeunit::SignUpPatchSent, BlankRecordId, 180000)
            else
                SignUpGetReadyStatus.ScheduleEDocumentJob(Codeunit::SignUpGetReadyStatus, BlankRecordId, 120000);
            exit(false);
        end;

        if Value = 'Failed' then begin
            JsonManagement.GetArrayPropertyValueAsStringByName('description', ErrorDescription);
            exit(false);
        end;

        JsonManagement.GetArrayPropertyValueAsStringByName('description', ErrorDescription);
        exit(true);
    end;

    procedure ParseGetADocumentApprovalResponse(HttpContentResponse: HttpContent; var Status: Text; var StatusDescription: Text): Boolean
    var
        JsonManagement: Codeunit "JSON Management";
        Result: Text;
    begin
        Result := SignUpHelpers.ParseJsonString(HttpContentResponse);
        if Result = '' then
            exit(false);

        if not JsonManagement.InitializeFromString(Result) then
            exit(false);

        JsonManagement.GetArrayPropertyValueAsStringByName('status', Status);

        if Status in ['Ready', 'Sent'] then
            exit(true);

        if Status = 'Failed' then begin
            JsonManagement.GetArrayPropertyValueAsStringByName('description', StatusDescription);
            exit(true);
        end;

        exit(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Integration Management", 'OnGetEDocumentApprovalReturnsFalse', '', false, false)]
    local procedure OnGetEDocumentApprovalReturnsFalse(EDocuments: Record "E-Document"; EDocumentService: Record "E-Document Service"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage; var IsHandled: Boolean)
    var
        HttpContentResponse: HttpContent;
        Status, StatusDescription : Text;
    begin
        HttpContentResponse := HttpResponse.Content;
        if not ParseGetADocumentApprovalResponse(HttpContentResponse, Status, StatusDescription) then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Import", 'OnAfterInsertImportedEdocument', '', false, false)]
    local procedure OnAfterInsertEdocument(var EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; EDocCount: Integer; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage)
    var
        LocalHttpRequest: HttpRequestMessage;
        LocalHttpResponse: HttpResponseMessage;
        DocumentOutStream: OutStream;
        ContentData, DocumentId : Text;
    begin

        if EDocumentService."Service Integration" <> EDocumentService."Service Integration"::"ExFlow E-Invoicing" then
            exit;

        HttpResponse.Content.ReadAs(ContentData);

        ContentData := LeaveJustNewLine(ContentData);

        if not ParseReceivedDocument(ContentData, EDocument."Index In Batch", DocumentId) then begin
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, DocumentIdNotFoundErr);
            exit;
        end;

        SignUpConnection.HandleGetTargetDocumentRequest(DocumentId, LocalHttpRequest, LocalHttpResponse, false);
        EDocumentLogHelper.InsertIntegrationLog(EDocument, EDocumentService, LocalHttpRequest, LocalHttpResponse);

        LocalHttpResponse.Content.ReadAs(ContentData);

        if not ParseContentData(ContentData) then
            ContentData := '';

        if ContentData = '' then
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, StrSubstNo(CouldNotRetrieveDocumentErr, DocumentId));

        Clear(TempBlob);
        TempBlob.CreateOutStream(DocumentOutStream, TextEncoding::UTF8);
        DocumentOutStream.WriteText(ContentData);
        EDocument."Document Id" := CopyStr(DocumentId, 1, MaxStrLen(EDocument."Document Id"));
        EDocumentLogHelper.InsertLog(EDocument, EDocumentService, TempBlob, "E-Document Service Status"::Imported);
        SignUpConnection.RemoveDocumentFromReceived(EDocument, LocalHttpRequest, LocalHttpResponse, true);
        EDocumentLogHelper.InsertIntegrationLog(EDocument, EDocumentService, LocalHttpRequest, LocalHttpResponse);
    end;


    internal procedure InsertIntegrationLog(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage)
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
        EDocumentIntegrationLog.Validate("Request URL", HttpRequest.GetRequestUri());
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


    internal procedure InsertLog(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; EDocDataStorageEntryNo: Integer; EDocumentServiceStatus: Enum "E-Document Service Status"): Integer
    var
        EDocumentLog: Record "E-Document Log";
    begin
        if EDocumentService.Code <> '' then
            UpdateServiceStatus(EDocument, EDocumentService, EDocumentServiceStatus);

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

    internal procedure UpdateServiceStatus(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; EDocumentStatus: Enum "E-Document Service Status")
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
        Exists: Boolean;
    begin
        EDocument.Get(EDocument."Entry No");
        Exists := EDocumentServiceStatus.Get(EDocument."Entry No", EDocumentService.Code);
        EDocumentServiceStatus.Validate(Status, EDocumentStatus);
        if Exists then
            EDocumentServiceStatus.Modify()
        else begin
            EDocumentServiceStatus.Validate("E-Document Entry No", EDocument."Entry No");
            EDocumentServiceStatus.Validate("E-Document Service Code", EDocumentService.Code);
            EDocumentServiceStatus.Validate(Status, EDocumentStatus);
            EDocumentServiceStatus.Insert();
        end;

        UpdateEDocumentStatus(EDocument);
    end;

    local procedure UpdateEDocumentStatus(var EDocument: Record "E-Document")
    var
        IsHandled: Boolean;
    begin
        if IsHandled then
            exit;

        if EDocumentHasErrors(EDocument) then
            exit;

        SetDocumentStatus(EDocument);
    end;

    local procedure EDocumentHasErrors(var EDocument: Record "E-Document"): Boolean
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
    begin
        EDocumentServiceStatus.SetRange("E-Document Entry No", EDocument."Entry No");
        EDocumentServiceStatus.SetFilter(Status, '%1|%2|%3|%4|%5',
            EDocumentServiceStatus.Status::"Sending Error",
            EDocumentServiceStatus.Status::"Export Error",
            EDocumentServiceStatus.Status::"Cancel Error",
            EDocumentServiceStatus.Status::"Imported Document Processing Error",
            EDocumentServiceStatus.Status::Rejected);

        if EDocumentServiceStatus.IsEmpty() then
            exit(false);

        EDocument.Validate(Status, EDocument.Status::Error);
        EDocument.Modify();
        exit(true);
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

    local procedure SetDocumentStatus(var EDocument: Record "E-Document")
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocServiceCount: Integer;
    begin
        EDocumentServiceStatus.SetRange("E-Document Entry No", EDocument."Entry No");
        EDocServiceCount := EDocumentServiceStatus.Count;

        EDocumentServiceStatus.SetFilter(Status, '%1|%2|%3|%4|%5',
            EDocumentServiceStatus.Status::Exported,
            EDocumentServiceStatus.Status::"Imported Document Created",
            EDocumentServiceStatus.Status::"Journal Line Created",
            EDocumentServiceStatus.Status::Approved,
            EDocumentServiceStatus.Status::Canceled);
        if EDocumentServiceStatus.Count = EDocServiceCount then
            EDocument.Status := EDocument.Status::Processed
        else
            EDocument.Status := EDocument.Status::"In Progress";

        EDocument.Modify();
    end;

    internal procedure InsertLogWithIntegration(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; EDocumentServiceStatus: Enum "E-Document Service Status"; EDocDataStorageEntryNo: Integer;
                                                                                                                                                           HttpRequest: HttpRequestMessage;
                                                                                                                                                           HttpResponse: HttpResponseMessage)
    begin
        InsertLog(EDocument, EDocumentService, EDocDataStorageEntryNo, EDocumentServiceStatus);
        if (HttpRequest.GetRequestUri() <> '') and (HttpResponse.Headers.Keys().Count > 0) then
            InsertIntegrationLog(EDocument, EDocumentService, HttpRequest, HttpResponse);
    end;

    local procedure LeaveJustNewLine(InputText: Text): Text
    var
        InputJson: JsonObject;
        InputJsonArray: JsonArray;
        InputJsonToken: JsonToken;
        DocumentJsonToken: JsonToken;
        OutputDocumentJsonArray: JsonArray;
        OutputDocumentJsonObject: JsonObject;
        OutputJsonObject: JsonObject;
        OutputText: text;
        DocumentList: List of [Text];
        i: Integer;
    begin
        OutputText := InputText;
        InputJson.ReadFrom(InputText);
        if InputJson.Contains('inbox') then begin
            InputJson.Get('inbox', InputJsonToken);
            InputJsonArray := InputJsonToken.AsArray();
            foreach InputJsonToken in InputJsonArray do
                if InputJsonToken.AsObject().Get('status', DocumentJsonToken) then
                    if DocumentJsonToken.AsValue().AsText() = 'New' then begin
                        InputJsonToken.AsObject().Get('instanceId', DocumentJsonToken);
                        DocumentList.Add(DocumentJsonToken.AsValue().AsText());
                    end;

            for i := 1 to DocumentList.Count do begin
                Clear(OutputDocumentJsonObject);
                OutputDocumentJsonObject.Add('instanceId', DocumentList.Get(i));
                OutputDocumentJsonArray.Add(OutputDocumentJsonObject);
            end;

            OutputJsonObject.Add('inbox', OutputDocumentJsonArray);
            OutputJsonObject.WriteTo(OutputText)

        end;
        exit(OutputText);
    end;

    local procedure ParseContentData(var InputText: Text): Boolean
    var
        JsonManagement: Codeunit "JSON Management";
        Base64Convert: Codeunit "Base64 Convert";
        Value: Text;
        ParsePosition: Integer;
    begin
        if not JsonManagement.InitializeFromString(InputText) then
            exit(false);

        JsonManagement.GetArrayPropertyValueAsStringByName('document', Value);
        InputText := Base64Convert.FromBase64(Value);
        ParsePosition := StrPos(InputText, '</StandardBusinessDocumentHeader>');
        if ParsePosition > 0 then begin
            InputText := CopyStr(InputText, parsePosition, StrLen(InputText));
            ParsePosition := StrPos(InputText, '<Invoice');
            InputText := CopyStr(InputText, parsePosition, StrLen(InputText));
            ParsePosition := StrPos(InputText, '</StandardBusinessDocument>');
            InputText := CopyStr(InputText, 1, parsePosition - 1);
        end;

        exit(true);
    end;

    var
        SignUpConnection: Codeunit SignUpConnection;
        SignUpHelpers: Codeunit SignUpHelpers;
        EDocumentHelper: Codeunit "E-Document Helper";
        EDocumentLogHelper: Codeunit "E-Document Log Helper";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        GetApprovalCheckStatusErr: Label 'You cannot ask for approval with the E-Document in this current status %1. You can request for approval when E-document status is Sent or Pending Response.', Comment = '%1 - Status';
        CouldNotRetrieveDocumentErr: Label 'Could not retrieve document with id: %1 from the service', Comment = '%1 - Document ID';
        DocumentIdNotFoundErr: Label 'Document ID not found in response';
        ExternalServiceTok: Label 'ExternalServiceConnector', Locked = true;
}