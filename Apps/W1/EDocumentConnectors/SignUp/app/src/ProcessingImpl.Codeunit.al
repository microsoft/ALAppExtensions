// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using Microsoft.EServices.EDocument;
using System.Telemetry;
using System.Text;
using System.Utilities;

codeunit 6383 ProcessingImpl
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "E-Document" = rim,
                  tabledata "E-Document Service Status" = rm,
                  tabledata "E-Document Service" = r,
                  tabledata "E-Document Integration Log" = ri,
                  tabledata "E-Document Log" = ri;

    #region variables
    var
        Connection: Codeunit Connection;
        HelpersImpl: Codeunit HelpersImpl;
        EDocumentHelper: Codeunit "E-Document Helper";
        EDocumentLogHelper: Codeunit "E-Document Log Helper";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        GetApprovalCheckStatusErr: Label 'You cannot ask for approval with the E-Document in this current status %1. You can request for approval when E-document status is Sent or Pending Response.', Comment = '%1 - Status';
        CouldNotRetrieveDocumentErr: Label 'Could not retrieve document with id: %1 from the service', Comment = '%1 - Document ID';
        DocumentIdNotFoundErr: Label 'Document ID not found in response';
        ExternalServiceTok: Label 'E-Document - SignUp', Locked = true;
        InboxTxt: Label 'inbox', Locked = true;
        InstanceIdTxt: Label 'instanceId', Locked = true;
        PeppolInstanceIdTxt: Label 'peppolInstanceId', Locked = true;
        StatusTxt: Label 'status', Locked = true;
        SentTxt: Label 'sent', Locked = true;
        ReadyTxt: Label 'ready', Locked = true;
        FailedTxt: Label 'failed', Locked = true;
        DescriptionTxt: Label 'description', Locked = true;
        ReasonTxt: Label 'Reason: ', Locked = true;
        NewTxt: Label 'new', Locked = true;
        DocumentTxt: Label 'document', Locked = true;
        StandardBusinessDocumentHeaderTxt: Label '</StandardBusinessDocumentHeader>', Locked = true;
        InvoiceTxt: Label '<Invoice', Locked = true;
        StandardBusinessDocumentTxt: Label '</StandardBusinessDocument>', Locked = true;


    #endregion

    #region public methods

    procedure SendEDocument(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocumentService: Record "E-Document Service";
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        IsAsync := true;

        this.EDocumentHelper.GetEdocumentService(EDocument, EDocumentService);
        EDocumentServiceStatus.Get(EDocument."Entry No", EDocumentService.Code);

        case EDocumentServiceStatus.Status of
            EDocumentServiceStatus.Status::Exported:
                this.SendEDocument(EDocument, TempBlob, HttpRequestMessage, HttpResponseMessage);
            EDocumentServiceStatus.Status::"Sending Error":
                if EDocument."Document Id" = '' then
                    this.SendEDocument(EDocument, TempBlob, HttpRequestMessage, HttpResponseMessage);
        end;

        FeatureTelemetry.LogUptake('', this.ExternalServiceTok, Enum::"Feature Uptake Status"::Used);
    end;

    procedure GetDocumentResponse(var EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        ErrorDescription: Text;
    begin
        if not this.Connection.CheckDocumentStatus(EDocument, HttpRequestMessage, HttpResponseMessage) then
            exit;
        exit(not this.DocumentHasErrorOrStillInProcessing(EDocument, HttpResponseMessage, ErrorDescription));
    end;

    procedure GetDocumentSentResponse(var EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        EDocumentService: Record "E-Document Service";
        APIRequests: Codeunit APIRequests;
        Status, StatusDescription : Text;
    begin
        this.EDocumentHelper.GetEdocumentService(EDocument, EdocumentService);
        APIRequests.GetSentDocumentStatus(EDocument, HttpRequestMessage, HttpResponseMessage);
        if not this.ParseGetADocumentApprovalResponse(HttpResponseMessage.Content, Status, StatusDescription) then
            exit;

        case Status of
            this.ReadyTxt:
                exit(true);
            this.FailedTxt:
                begin
                    if StatusDescription <> '' then
                        this.EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, this.ReasonTxt + StatusDescription);
                    this.InsertLogWithIntegration(EDocument, EDocumentService, Enum::"E-Document Service Status"::Rejected, 0, HttpRequestMessage, HttpResponseMessage);
                    exit;
                end;
        end;
    end;

    procedure GetDocumentApproval(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        EDocumentService: Record "E-Document Service";
        EDocumentServiceStatus: Record "E-Document Service Status";
        APIRequests: Codeunit APIRequests;
        JobHelperImpl: Codeunit JobHelperImpl;
        BlankRecordId: RecordId;
        Status, StatusDescription : Text;
    begin
        this.EDocumentHelper.GetEdocumentService(EDocument, EdocumentService);
        EDocumentServiceStatus.SetLoadFields(Status);
        EDocumentServiceStatus.Get(EDocument."Entry No", EdocumentService.Code);
        if not (EDocumentServiceStatus.Status in [EDocumentServiceStatus.Status::Sent, EDocumentServiceStatus.Status::"Pending Response"]) then
            Error(this.GetApprovalCheckStatusErr, EDocumentServiceStatus.Status);

        APIRequests.GetSentDocumentStatus(EDocument, HttpRequestMessage, HttpResponseMessage);
        if not this.ParseGetADocumentApprovalResponse(HttpResponseMessage.Content, Status, StatusDescription) then
            exit;

        case Status of
            this.ReadyTxt:
                begin
                    if EDocumentServiceStatus.Status = EDocumentServiceStatus.Status::Approved then
                        JobHelperImpl.ScheduleEDocumentJob(Codeunit::PatchSentJob, BlankRecordId, 300000)
                    else
                        JobHelperImpl.ScheduleEDocumentJob(Codeunit::GetReadyStatusJob, BlankRecordId, 300000);
                    exit(true);
                end;
            this.FailedTxt:
                begin
                    if StatusDescription <> '' then
                        this.EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, this.ReasonTxt + StatusDescription);
                    this.InsertLogWithIntegration(EDocument, EDocumentService, Enum::"E-Document Service Status"::Rejected, 0, HttpRequestMessage, HttpResponseMessage);
                    exit;
                end;
        end;
    end;

    procedure ReceiveDocument(var TempBlob: Codeunit "Temp Blob"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    var
        ContentData: Text;
    begin
        if not this.Connection.GetReceivedDocuments(HttpRequestMessage, HttpResponseMessage) then
            exit;

        if not HttpResponseMessage.Content.ReadAs(ContentData) then
            exit;

        TempBlob.CreateOutStream(TextEncoding::UTF8).WriteText(ContentData);
    end;

    procedure GetDocumentCountInBatch(var TempBlob: Codeunit "Temp Blob"): Integer
    var
        ResponseTxt: Text;
    begin
        TempBlob.CreateInStream().ReadText(ResponseTxt);
        exit(this.GetNumberOfReceivedDocuments(ResponseTxt));
    end;

    procedure InsertIntegrationLog(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; HttpRequestMessage: HttpRequestMessage; HttpResponseMessage: HttpResponseMessage)
    var
        EDocumentIntegrationLog: Record "E-Document Integration Log";
        EDocIntegrationLogRecordRef: RecordRef;
        RequestTxt: Text;
    begin
        if EDocumentService."Service Integration" = EDocumentService."Service Integration"::"No Integration" then
            exit;

        EDocumentIntegrationLog.Validate("E-Doc. Entry No", EDocument."Entry No");
        EDocumentIntegrationLog.Validate("Service Code", EDocumentService.Code);
        EDocumentIntegrationLog.Validate("Response Status", HttpResponseMessage.HttpStatusCode());
        EDocumentIntegrationLog.Validate("Request URL", HttpRequestMessage.GetRequestUri());
        EDocumentIntegrationLog.Validate(Method, HttpRequestMessage.Method());
        EDocumentIntegrationLog.Insert();

        EDocIntegrationLogRecordRef.GetTable(EDocumentIntegrationLog);

        if HttpRequestMessage.Content.ReadAs(RequestTxt) then begin
            this.InsertIntegrationBlob(EDocIntegrationLogRecordRef, RequestTxt, EDocumentIntegrationLog.FieldNo(EDocumentIntegrationLog."Request Blob"));
            EDocIntegrationLogRecordRef.Modify();
        end;

        if HttpResponseMessage.Content.ReadAs(RequestTxt) then begin
            this.InsertIntegrationBlob(EDocIntegrationLogRecordRef, RequestTxt, EDocumentIntegrationLog.FieldNo(EDocumentIntegrationLog."Response Blob"));
            EDocIntegrationLogRecordRef.Modify();
        end;
    end;

    procedure InsertLogWithIntegration(var EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service";
                EDocumentServiceStatus: Enum "E-Document Service Status"; EDocDataStorageEntryNo: Integer; HttpRequestMessage: HttpRequestMessage; HttpResponseMessage: HttpResponseMessage)
    begin
        this.InsertLog(EDocument, EDocumentService, EDocDataStorageEntryNo, EDocumentServiceStatus);

        if (HttpRequestMessage.GetRequestUri() <> '') and (HttpResponseMessage.Headers.Keys().Count > 0) then
            this.InsertIntegrationLog(EDocument, EDocumentService, HttpRequestMessage, HttpResponseMessage);
    end;

    #endregion

    #region local methods

    local procedure ParseGetADocumentApprovalResponse(HttpContentResponse: HttpContent; var Status: Text; var StatusDescription: Text): Boolean
    var
        JsonManagement: Codeunit "JSON Management";
        Result: Text;
    begin
        Result := this.HelpersImpl.ParseJsonString(HttpContentResponse);
        if Result = '' then
            exit;

        if not JsonManagement.InitializeFromString(Result) then
            exit;

        Status := this.GetStatus(JsonManagement);

        if Status in [this.ReadyTxt, this.SentTxt] then
            exit(true);

        if Status = this.FailedTxt then begin
            JsonManagement.GetArrayPropertyValueAsStringByName(this.DescriptionTxt, StatusDescription);
            exit(true);
        end;

        exit;
    end;

    local procedure InsertLog(var EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; EDocDataStorageEntryNo: Integer; EDocumentServiceStatus: Enum "E-Document Service Status"): Integer
    var
        EDocumentLog: Record "E-Document Log";
    begin
        if EDocumentService.Code <> '' then
            this.UpdateServiceStatus(EDocument, EDocumentService, EDocumentServiceStatus);

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

    local procedure UpdateServiceStatus(var EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; EDocumentStatus: Enum "E-Document Service Status")
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

        this.UpdateEDocumentStatus(EDocument);
    end;

    local procedure SendEDocument(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob"; HttpRequestMessage: HttpRequestMessage; HttpResponseMessage: HttpResponseMessage);
    begin
        this.Connection.SendFilePostRequest(TempBlob, EDocument, HttpRequestMessage, HttpResponseMessage);
        this.SetEDocumentFileID(EDocument."Entry No", this.ParseSendFileResponse(HttpResponseMessage.Content));
    end;

    local procedure ParseReceivedDocument(InputTxt: Text; Index: Integer; var DocumentId: Text): Boolean
    var
        JsonManagement: Codeunit "JSON Management";
        IncrementalTable, Value : Text;
    begin
        if not JsonManagement.InitializeFromString(InputTxt) then
            exit;

        JsonManagement.GetArrayPropertyValueAsStringByName(this.InboxTxt, Value);
        JsonManagement.InitializeCollection(Value);

        if Index = 0 then
            Index := 1;

        if Index > JsonManagement.GetCollectionCount() then
            exit;

        JsonManagement.GetObjectFromCollectionByIndex(IncrementalTable, Index - 1);

        Clear(JsonManagement);
        JsonManagement.InitializeObject(IncrementalTable);
        JsonManagement.GetArrayPropertyValueAsStringByName(this.InstanceIdTxt, DocumentId);

        exit(true);
    end;

    local procedure GetNumberOfReceivedDocuments(InputTxt: Text): Integer
    var
        JsonManagement: Codeunit "JSON Management";
        Value: Text;
    begin
        InputTxt := this.LeaveJustNewLine(InputTxt);

        if not JsonManagement.InitializeFromString(InputTxt) then
            exit(0);

        JsonManagement.GetArrayPropertyValueAsStringByName(this.InboxTxt, Value);
        JsonManagement.InitializeCollection(Value);

        exit(JsonManagement.GetCollectionCount());
    end;

    local procedure ParseSendFileResponse(HttpContentResponse: HttpContent): Text
    var
        JsonManagement: Codeunit "JSON Management";
        Result, Value : Text;
    begin
        Result := this.HelpersImpl.ParseJsonString(HttpContentResponse);
        if Result = '' then
            exit;

        if not JsonManagement.InitializeFromString(Result) then
            exit;

        JsonManagement.GetStringPropertyValueByName(this.PeppolInstanceIdTxt, Value);
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

    local procedure DocumentHasErrorOrStillInProcessing(EDocument: Record "E-Document"; HttpResponseMessage: HttpResponseMessage; var ErrorDescription: Text): Boolean
    var
        EDocumentService: Record "E-Document Service";
        EDocumentServiceStatus: Record "E-Document Service Status";
        JsonManagement: Codeunit "JSON Management";
        JobHelperImpl: Codeunit JobHelperImpl;
        BlankRecordId: RecordId;
        Result, Status : Text;
    begin
        Result := this.HelpersImpl.ParseJsonString(HttpResponseMessage.Content);
        if Result = '' then
            exit(true);

        if not JsonManagement.InitializeFromString(Result) then
            exit(true);

        Status := this.GetStatus(JsonManagement);

        if Status in [this.SentTxt] then begin
            JobHelperImpl.ScheduleEDocumentJob(Codeunit::GetReadyStatusJob, BlankRecordId, 120000);
            exit;
        end;

        if Status in [this.ReadyTxt] then begin
            this.EDocumentHelper.GetEdocumentService(EDocument, EDocumentService);
            EDocumentServiceStatus.SetLoadFields(Status);
            EDocumentServiceStatus.Get(EDocument."Entry No", EdocumentService.Code);
            if EDocumentServiceStatus.Status = EDocumentServiceStatus.Status::Approved then
                JobHelperImpl.ScheduleEDocumentJob(Codeunit::PatchSentJob, BlankRecordId, 180000)
            else
                JobHelperImpl.ScheduleEDocumentJob(Codeunit::GetReadyStatusJob, BlankRecordId, 120000);
            exit;
        end;

        if Status = this.FailedTxt then begin
            JsonManagement.GetArrayPropertyValueAsStringByName(this.DescriptionTxt, ErrorDescription);
            exit;
        end;

        JsonManagement.GetArrayPropertyValueAsStringByName(this.DescriptionTxt, ErrorDescription);
        exit(true);
    end;

    local procedure GetStatus(var JsonManagement: Codeunit "Json Management") Status: Text
    begin
        JsonManagement.GetArrayPropertyValueAsStringByName(this.StatusTxt, Status);
        Status := Status.ToLower();
    end;

    local procedure UpdateEDocumentStatus(var EDocument: Record "E-Document")
    var
        IsHandled: Boolean;
    begin
        if IsHandled then
            exit;

        if this.EDocumentHasErrors(EDocument) then
            exit;

        this.SetDocumentStatus(EDocument);
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
            exit;

        EDocument.Validate(Status, EDocument.Status::Error);
        EDocument.Modify();
        exit(true);
    end;

    local procedure InsertIntegrationBlob(var EDocIntegrationLogRecordRef: RecordRef; Data: Text; FieldNo: Integer)
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        TempBlob.CreateOutStream().WriteText(Data);
        TempBlob.ToRecordRef(EDocIntegrationLogRecordRef, FieldNo);
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
        if EDocumentServiceStatus.Count() = EDocServiceCount then
            EDocument.Status := EDocument.Status::Processed
        else
            EDocument.Status := EDocument.Status::"In Progress";

        EDocument.Modify();
    end;

    local procedure LeaveJustNewLine(InputText: Text): Text
    var
        InputJson, OutputDocumentJsonObject, OutputJsonObject : JsonObject;
        InputJsonArray, OutputDocumentJsonArray : JsonArray;
        InputJsonToken, DocumentJsonToken : JsonToken;
        OutputText: text;
        DocumentList: List of [Text];
        i: Integer;
    begin
        OutputText := InputText;
        InputJson.ReadFrom(InputText);
        if InputJson.Contains(this.InboxTxt) then begin
            InputJson.Get(this.InboxTxt, InputJsonToken);
            InputJsonArray := InputJsonToken.AsArray();
            foreach InputJsonToken in InputJsonArray do
                if InputJsonToken.AsObject().Get(this.StatusTxt, DocumentJsonToken) then
                    if DocumentJsonToken.AsValue().AsText().ToLower() = this.NewTxt then begin
                        InputJsonToken.AsObject().Get(this.InstanceIdTxt, DocumentJsonToken);
                        DocumentList.Add(DocumentJsonToken.AsValue().AsText());
                    end;

            for i := 1 to DocumentList.Count do begin
                Clear(OutputDocumentJsonObject);
                OutputDocumentJsonObject.Add(this.InstanceIdTxt, DocumentList.Get(i));
                OutputDocumentJsonArray.Add(OutputDocumentJsonObject);
            end;

            OutputJsonObject.Add(this.InboxTxt, OutputDocumentJsonArray);
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
            exit;

        JsonManagement.GetArrayPropertyValueAsStringByName(this.DocumentTxt, Value);
        InputText := Base64Convert.FromBase64(Value);
        ParsePosition := StrPos(InputText, this.StandardBusinessDocumentHeaderTxt);
        if ParsePosition > 0 then begin
            InputText := CopyStr(InputText, parsePosition, StrLen(InputText));
            ParsePosition := StrPos(InputText, this.InvoiceTxt);
            InputText := CopyStr(InputText, parsePosition, StrLen(InputText));
            ParsePosition := StrPos(InputText, this.StandardBusinessDocumentTxt);
            InputText := CopyStr(InputText, 1, parsePosition - 1);
        end;

        exit(true);
    end;

    #endregion

    #region event subscribers

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Integration Management", OnGetEDocumentApprovalReturnsFalse, '', false, false)]
    local procedure OnGetEDocumentApprovalReturnsFalse(EDocuments: Record "E-Document"; EDocumentService: Record "E-Document Service"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage; var IsHandled: Boolean)
    var
        HttpContent: HttpContent;
        Status, StatusDescription : Text;
    begin
        HttpContent := HttpResponse.Content;
        if not this.ParseGetADocumentApprovalResponse(HttpContent, Status, StatusDescription) then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Import", OnAfterInsertImportedEdocument, '', false, false)]
    local procedure OnAfterInsertEdocument(var EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; EDocCount: Integer; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage)
    var
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        ContentData, DocumentId : Text;
    begin
        if EDocumentService."Service Integration" <> EDocumentService."Service Integration"::"ExFlow E-Invoicing" then
            exit;

        if not HttpResponse.Content.ReadAs(ContentData) then
            exit;

        ContentData := this.LeaveJustNewLine(ContentData);

        if not this.ParseReceivedDocument(ContentData, EDocument."Index In Batch", DocumentId) then begin
            this.EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, this.DocumentIdNotFoundErr);
            exit;
        end;

        this.Connection.GetTargetDocumentRequest(DocumentId, HttpRequestMessage, HttpResponseMessage);
        this.EDocumentLogHelper.InsertIntegrationLog(EDocument, EDocumentService, HttpRequestMessage, HttpResponseMessage);

        if not HttpResponseMessage.Content.ReadAs(ContentData) then
            exit;

        if not this.ParseContentData(ContentData) then
            ContentData := '';

        if ContentData = '' then
            this.EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, StrSubstNo(this.CouldNotRetrieveDocumentErr, DocumentId));

        Clear(TempBlob);
        TempBlob.CreateOutStream(TextEncoding::UTF8).WriteText(ContentData);
        EDocument."Document Id" := CopyStr(DocumentId, 1, MaxStrLen(EDocument."Document Id"));
        this.EDocumentLogHelper.InsertLog(EDocument, EDocumentService, TempBlob, "E-Document Service Status"::Imported);
        this.Connection.RemoveDocumentFromReceived(EDocument, HttpRequestMessage, HttpResponseMessage);
        this.EDocumentLogHelper.InsertIntegrationLog(EDocument, EDocumentService, HttpRequestMessage, HttpResponseMessage);
    end;

    #endregion

}