// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;
using Microsoft.EServices.EDocument;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Purchases.Document;
using Microsoft.Utilities;
using System.Telemetry;
using System.Text;
using System.Utilities;

codeunit 6369 "Pagero Processing"
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
                if EDocument."File Id" = '' then
                    SendEDocument(EDocument, TempBlob, HttpRequest, HttpResponse)
                else
                    RestartEDocument(EDocument, HttpRequest, HttpResponse);
        end;

        FeatureTelemetry.LogUptake('0000MSC', ExternalServiceTok, Enum::"Feature Uptake Status"::Used);
    end;

    procedure GetDocumentResponse(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    var
    begin
        if not CheckIfDocumentStatusSuccessful(EDocument, HttpRequest, HttpResponse) then
            exit(false);

        if not PageroConnection.GetADocument(EDocument, HttpRequest, HttpResponse) then
            exit(false);

        exit(true);
    end;

    procedure CancelEDocument(EDocument: Record "E-Document"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage): Boolean
    var
        EDocumentService: Record "E-Document Service";
        EDocumentServiceStatus: Record "E-Document Service Status";
    begin
        EDocumentHelper.GetEdocumentService(EDocument, EdocumentService);
        EDocumentServiceStatus.Get(EDocument."Entry No", EdocumentService.Code);

        if not (EDocumentServiceStatus.Status in [EDocumentServiceStatus.Status::"Cancel Error", EDocumentServiceStatus.Status::"Sending Error"]) then
            Error(CancelCheckStatusErr, EDocumentServiceStatus.Status);

        if PageroConnection.HandleSendActionRequest(EDocument, HttpRequest, HttpResponse, 'Cancel', false) then
            exit(true);
    end;

    procedure RestartEDocument(EDocument: Record "E-Document"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage): Boolean
    var
        EDocumentService: Record "E-Document Service";
    begin
        EDocumentHelper.GetEdocumentService(EDocument, EdocumentService);
        if EDocumentService."Service Integration" <> EDocumentService."Service Integration"::Pagero then
            exit;

        if PageroConnection.HandleSendActionRequest(EDocument, HttpRequest, HttpResponse, 'Restart', false) then
            exit(true);
    end;

    procedure GetDocumentApproval(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        EDocumentService: Record "E-Document Service";
        EDocumentServiceStatus: Record "E-Document Service Status";
        PageroAPIRequests: Codeunit "Pagero API Requests";
        HttpContentResponse: HttpContent;
        Status, StatusDescription : Text;
    begin
        EDocumentHelper.GetEdocumentService(EDocument, EdocumentService);
        EDocumentServiceStatus.Get(EDocument."Entry No", EdocumentService.Code);
        if EDocumentServiceStatus.Status <> EDocumentServiceStatus.Status::Sent then
            Error(GetApprovalCheckStatusErr, EDocumentServiceStatus.Status);

        PageroAPIRequests.GetADocument(EDocument, HttpRequestMessage, HttpResponseMessage);

        HttpContentResponse := HttpResponseMessage.Content;
        if ParseGetADocumentApprovalResponse(HttpContentResponse, Status, StatusDescription) then
            case Status of
                'Accepted':
                    exit(true);
                'Rejected':
                    begin
                        if StatusDescription <> '' then
                            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, 'Reason: ' + StatusDescription);
                        exit(false);
                    end;
            end;
        exit(false);
    end;

    procedure GetEDocumentsApproval(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        EDocumentService: Record "E-Document Service";
        EDocumentServiceStatus: Record "E-Document Service Status";
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        PageroAPIRequests: Codeunit "Pagero API Requests";
        HttpContentResponse: HttpContent;
    begin
        EDocumentHelper.GetEdocumentService(EDocument, EdocumentService);
        EDocumentServiceStatus.Get(EDocument."Entry No", EdocumentService.Code);
        if EDocumentServiceStatus.Status <> EDocumentServiceStatus.Status::Sent then
            Error(GetApprovalCheckStatusErr, EDocumentServiceStatus.Status);

        PageroAPIRequests.GetAppResponseDocumentsRequest(EDocument, HttpRequestMessage, HttpResponseMessage);

        HttpContentResponse := HttpResponseMessage.Content;
        ParseGetDocumentsApprovalResponse(HttpContentResponse, TempNameValueBuffer);

        if TempNameValueBuffer.IsEmpty then
            exit(false);

        TempNameValueBuffer.FindSet();
        repeat
            UpdateEDocumentApprovalRejection(TempNameValueBuffer);
        until TempNameValueBuffer.Next() = 0;

        exit(false);
    end;

    local procedure UpdateEDocumentApprovalRejection(NameValueBuffer: Record "Name/Value Buffer")
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocuemtServiceStatus: Record "E-Document Service Status";
    begin
        EDocument.SetRange(Direction, EDocument.Direction::Outgoing);
        EDocument.SetRange("Document No.", NameValueBuffer.Value);
        if not EDocument.FindLast() then
            exit;

        EDocumentHelper.GetEdocumentService(EDocument, EDocumentService);
        EDocuemtServiceStatus.Get(EDocument."Entry No", EDocumentService.Code);
        case EDocuemtServiceStatus.Status of
            "E-Document Service Status"::Approved, "E-Document Service Status"::Rejected:
                FetchEDocument(EDocument, EDocumentService, NameValueBuffer.Name);
            "E-Document Service Status"::Sent:
                begin
                    case NameValueBuffer."Value Long" of
                        'RecipientAccept':
                            EDocuemtServiceStatus.Status := "E-Document Service Status"::Approved;
                        'RecipientReject':
                            EDocuemtServiceStatus.Status := "E-Document Service Status"::Rejected;
                    end;
                    FetchEDocument(EDocument, EDocumentService, NameValueBuffer.Name);
                end;
        end;
    end;

    local procedure FetchEDocument(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; DocumentId: Text)
    var
        LocalHttpRequest: HttpRequestMessage;
        LocalHttpResponse: HttpResponseMessage;
        Documents: JsonArray;
    begin
        if DocumentId = '' then
            exit;
        // Mark document as fetched
        Documents.Add(DocumentId);
        PageroConnection.HandleSendFetchDocumentRequest(Documents, LocalHttpRequest, LocalHttpResponse, false);
        EDocumentLogHelper.InsertIntegrationLog(EDocument, EDocumentService, LocalHttpRequest, LocalHttpResponse);
    end;

    procedure ReceiveDocument(var TempBlob: Codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    var
        ContentData: Text;
        OutStream: OutStream;
    begin
        if not PageroConnection.GetReceivedDocuments(HttpRequest, HttpResponse, true) then
            exit;

        HttpResponse.Content.ReadAs(ContentData);

        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(ContentData);
    end;

    procedure ApproveEDocument(EDocument: Record "E-Document")
    var
        EDocumentService: Record "E-Document Service";
        EDocumentServiceStatus: Record "E-Document Service Status";
        PageroAPIRequests: Codeunit "Pagero API Requests";
        PageroApplicationResponse: Codeunit "Pagero Application Response";
        TempBlob: Codeunit "Temp Blob";
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        Parameters: Dictionary of [Text, Text];
    begin
        EDocumentService := SelectEDocumentService();
        if EDocumentService.Code = '' then
            exit;

        EDocumentServiceStatus.Get(EDocument."Entry No", EDocumentService.Code);
        if EDocumentServiceStatus.Status <> EDocumentServiceStatus.Status::"Imported Document Created" then
            Error(SendApproveRejectCheckStatusErr, 'Approve', EDocumentServiceStatus.Status);

        Parameters.Add('fileId', EDocument."File Id");
        Parameters.Add('documentId', EDocument."Document Id");
        Parameters.Add('ResponseId', EDocument."Incoming E-Document No.");
        Parameters.Add('DocumentReference', EDocument."Incoming E-Document No.");
        Parameters.Add('VendorNo', EDocument."Bill-to/Pay-to No.");
        Parameters.Add('Note', 'Approve' + ' ' + EDocument."Incoming E-Document No.");
        Parameters.Add('Approve', 'true');

        PageroApplicationResponse.PrepareResponse(TempBlob, Parameters);

        PageroAPIRequests.SendFilePostRequest(TempBlob, EDocument, HttpRequest, HttpResponse);
        EDocumentLogHelper.InsertIntegrationLog(EDocument, EDocumentService, HttpRequest, HttpResponse);

        if HttpResponse.HttpStatusCode = 201 then begin
            EDocumentServiceStatus.Status := EDocumentServiceStatus.Status::Approved;
            EDocumentServiceStatus.Modify();
        end;
    end;

    procedure RejectEDocument(EDocument: Record "E-Document")
    var
        EDocumentService: Record "E-Document Service";
        EDocumentServiceStatus: Record "E-Document Service Status";
        ReasonCode: Record "Reason Code";
        PageroAPIRequests: Codeunit "Pagero API Requests";
        PageroApplicationResponse: Codeunit "Pagero Application Response";
        TempBlob: Codeunit "Temp Blob";
        ReasonCodes: Page "Reason Codes";
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        Parameters: Dictionary of [Text, Text];
    begin
        EDocumentService := SelectEDocumentService();
        if EDocumentService.Code = '' then
            exit;

        EDocumentServiceStatus.Get(EDocument."Entry No", EDocumentService.Code);
        if EDocumentServiceStatus.Status <> EDocumentServiceStatus.Status::"Imported Document Created" then
            Error(SendApproveRejectCheckStatusErr, 'Reject', EDocumentServiceStatus.Status);

        ReasonCodes.LookupMode(true);
        if ReasonCodes.RunModal() = Action::LookupOK then
            ReasonCodes.GetRecord(ReasonCode);

        Parameters.Add('fileId', EDocument."File Id");
        Parameters.Add('documentId', EDocument."Document Id");
        Parameters.Add('ResponseId', EDocument."Incoming E-Document No.");
        Parameters.Add('DocumentReference', EDocument."Incoming E-Document No.");
        Parameters.Add('VendorNo', EDocument."Bill-to/Pay-to No.");
        Parameters.Add('Note', 'Approve' + ' ' + EDocument."Incoming E-Document No.");
        Parameters.Add('Approve', 'false');
        Parameters.Add('RejectReason', ReasonCode.Description);

        PageroApplicationResponse.PrepareResponse(TempBlob, Parameters);

        PageroAPIRequests.SendFilePostRequest(TempBlob, EDocument, HttpRequest, HttpResponse);
        EDocumentLogHelper.InsertIntegrationLog(EDocument, EDocumentService, HttpRequest, HttpResponse);

        if HttpResponse.HttpStatusCode = 201 then begin
            EDocumentServiceStatus.Status := EDocumentServiceStatus.Status::Rejected;
            EDocumentServiceStatus.Modify();

            DeleteRelatedDocument(EDocument);
        end;
    end;

    local procedure DeleteRelatedDocument(EDocument: Record "E-Document")
    var
        PurchaseHeader: Record "Purchase Header";
        RelatedRecordID: RecordID;
        RelatedRecordRef: RecordRef;
    begin
        RelatedRecordID := EDocument."Document Record ID";
        RelatedRecordRef := RelatedRecordID.GetRecord();
        RelatedRecordRef.Get(RelatedRecordID);

        case RelatedRecordRef.Number of
            database::"Purchase Header":
                begin
                    RelatedRecordRef.SetTable(PurchaseHeader);
                    PurchaseHeader.Delete(true);
                end;
        end;
    end;

    procedure GetDocumentCountInBatch(var TempBlob: Codeunit "Temp Blob"): Integer
    var
        ResponseInstream: InStream;
        ResponseTxt:
                Text;
    begin
        TempBlob.CreateInStream(ResponseInstream);
        ResponseInstream.ReadText(ResponseTxt);

        exit(GetNumberOfReceivedDocuments(ResponseTxt));
    end;

    local procedure SendEDocument(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage);
    var
        HttpContentResponse: HttpContent;
    begin
        PageroConnection.HandleSendFilePostRequest(TempBlob, EDocument, HttpRequest, HttpResponse, true);
        HttpContentResponse := HttpResponse.Content;
        SetEDocumentFileID(EDocument."Entry No", ParseSendFileResponse(HttpContentResponse));
    end;

    local procedure ParseReceivedDocument(InputTxt: Text; Index: Integer; var DocumentId: Text; var FileId: Text): Boolean
    var
        JsonManagement: Codeunit "JSON Management";
        JsonManagement2: Codeunit "JSON Management";
        IncrementalTable: Text;
        Value: Text;
    begin
        if not JsonManagement.InitializeFromString(InputTxt) then
            exit(false);

        JsonManagement.GetArrayPropertyValueAsStringByName('items', Value);
        JsonManagement.InitializeCollection(Value);

        if Index = 0 then
            Index := 1;

        if Index > JsonManagement.GetCollectionCount() then
            exit(false);

        JsonManagement.GetObjectFromCollectionByIndex(IncrementalTable, Index - 1);
        JsonManagement2.InitializeObject(IncrementalTable);
        JsonManagement2.GetArrayPropertyValueAsStringByName('id', DocumentId);
        JsonManagement2.GetArrayPropertyValueAsStringByName('fileId', FileId);
        exit(true);
    end;

    local procedure GetNumberOfReceivedDocuments(InputTxt: Text): Integer
    var
        JsonManagement: Codeunit "JSON Management";
        Value: Text;
    begin
        if not JsonManagement.InitializeFromString(InputTxt) then
            exit(0);

        JsonManagement.GetArrayPropertyValueAsStringByName('items', Value);
        JsonManagement.InitializeCollection(Value);

        exit(JsonManagement.GetCollectionCount());
    end;

    local procedure CheckIfDocumentStatusSuccessful(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    var
        EDocumentService: Record "E-Document Service";
        Telemetry: Codeunit Telemetry;
        Status, FilepartID, ErrorDescription : Text;
    begin
        if not PageroConnection.CheckDocumentFileParts(EDocument, HttpRequestMessage, HttpResponse, true) then
            exit(false);

        if IsFilePartsDocumentProcessed(HttpResponse, Status, FilepartID, ErrorDescription) then begin
            EDocumentHelper.GetEdocumentService(EDocument, EDocumentService);
            EDocumentLogHelper.InsertIntegrationLog(EDocument, EDocumentService, HttpRequestMessage, HttpResponse);
            exit(true);
        end;

        // FilepartID only exists when document is not processed 
        if FilepartID = '' then
            exit(false);

        EDocument."Filepart Id" := CopyStr(FilepartID, 1, MaxStrLen(EDocument."Filepart Id"));
        EDocument.Modify();

        case Status of
            PageroProcessingStatusLbl:
                exit(false);
            PageroErrorStatusLbl:
                begin
                    EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, ErrorDescription);
                    exit(false);
                end;
            PageroAwaitingInteractionStatusLbl:
                exit(false);
            else begin
                Telemetry.LogMessage('0000MSB', StrSubstNo(WrongParseStatusErr, Status), Verbosity::Error, DataClassification::SystemMetadata);
                exit(false);
            end;
        end;
    end;

    local procedure IsFilePartsDocumentProcessed(HttpResponse: HttpResponseMessage; var Status: Text; var FilepartID: Text; var ErrorDescription: Text): Boolean
    var
        JsonManagement: Codeunit "JSON Management";
        HttpContentResponse: HttpContent;
        IncrementalTable, Result, Value : Text;
    begin
        HttpContentResponse := HttpResponse.Content;
        Result := ParseJsonString(HttpContentResponse);
        if Result = '' then
            Error(ParseErr);

        if not JsonManagement.InitializeFromString(Result) then
            Error(ParseErr);

        JsonManagement.GetArrayPropertyValueAsStringByName('items', Value);
        JsonManagement.InitializeCollection(Value);

        // A Filepart which has been successfully processed will not be visible in the API.
        if JsonManagement.GetCollectionCount() = 0 then
            exit(true);

        JsonManagement.GetObjectFromCollectionByIndex(IncrementalTable, 0);
        JsonManagement.InitializeObject(IncrementalTable);

        JsonManagement.GetStringPropertyValueByName('status', Status);
        JsonManagement.GetStringPropertyValueByName('id', FilepartID);
        JsonManagement.GetArrayPropertyValueAsStringByName('error', ErrorDescription);
        JsonManagement.InitializeFromString(ErrorDescription);
        JsonManagement.GetArrayPropertyValueAsStringByName('description', ErrorDescription);
        exit(false);
    end;

    local procedure ParseSendFileResponse(HttpContentResponse: HttpContent): Text
    var
        JsonManagement: Codeunit "JSON Management";
        Result: Text;
        Value: Text;
    begin
        Result := ParseJsonString(HttpContentResponse);
        if Result = '' then
            exit('');

        if not JsonManagement.InitializeFromString(Result) then
            exit('');

        JsonManagement.GetStringPropertyValueByName('id', Value);
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
        EDocument."File Id" := CopyStr(FileId, 1, MaxStrLen(EDocument."File Id"));
        EDocument.Modify();
    end;


    procedure ParseGetADocumentApprovalResponse(HttpContentResponse: HttpContent; var Status: Text; var StatusDescription: Text): Boolean
    var
        JsonManagement: Codeunit "JSON Management";
        JsonManagement2: Codeunit "JSON Management";
        JsonManagement3: Codeunit "JSON Management";
        Value: Text;
        IncrementalTable: Text;
        i: Integer;
        Result: Text;
    begin
        Result := ParseJsonString(HttpContentResponse);
        if Result = '' then
            exit(false);

        if not JsonManagement.InitializeFromString(Result) then
            exit(false);

        JsonManagement.GetArrayPropertyValueAsStringByName('items', Value);
        JsonManagement.InitializeCollection(Value);

        if JsonManagement.GetCollectionCount() = 0 then
            exit(false);

        for i := 0 to JsonManagement.GetCollectionCount() - 1 do begin
            JsonManagement.GetObjectFromCollectionByIndex(IncrementalTable, i);
            JsonManagement2.InitializeObject(IncrementalTable);
            JsonManagement2.GetArrayPropertyValueAsStringByName('documentInfo', Value);

            JsonManagement3.InitializeFromString(Value);
            JsonManagement3.GetArrayPropertyValueAsStringByName('direction', Value);
            if Value = 'Received' then
                if JsonManagement2.GetArrayPropertyValueAsStringByName('latestBusinessStatus', Value) then begin
                    JsonManagement2.InitializeFromString(Value);

                    JsonManagement2.GetArrayPropertyValueAsStringByName('businessStatus', Status);
                    JsonManagement2.GetArrayPropertyValueAsStringByName('description', StatusDescription);
                    exit(true);
                end;
        end;
        exit(false);
    end;

    procedure ParseGetDocumentsApprovalResponse(HttpContentResponse: HttpContent; var TempNameValueBuffer: Record "Name/Value Buffer" temporary): Boolean
    var
        JsonManagement: Codeunit "JSON Management";
        JsonManagement2: Codeunit "JSON Management";
        JsonManagement3: Codeunit "JSON Management";
        Value, DocumentId, DocumentNo, Status : Text;
        IncrementalTable: Text;
        i: Integer;
        Result: Text;
    begin
        Result := ParseJsonString(HttpContentResponse);
        if Result = '' then
            exit(false);

        if not JsonManagement.InitializeFromString(Result) then
            exit(false);

        JsonManagement.GetArrayPropertyValueAsStringByName('items', Value);
        JsonManagement.InitializeCollection(Value);

        if JsonManagement.GetCollectionCount() = 0 then
            exit(false);

        for i := 0 to JsonManagement.GetCollectionCount() - 1 do begin
            JsonManagement.GetObjectFromCollectionByIndex(IncrementalTable, i);
            JsonManagement2.InitializeObject(IncrementalTable);
            JsonManagement2.GetArrayPropertyValueAsStringByName('documentInfo', Value);
            JsonManagement2.GetArrayPropertyValueAsStringByName('id', DocumentId);

            JsonManagement3.InitializeFromString(Value);
            JsonManagement3.GetArrayPropertyValueAsStringByName('direction', Value);
            JsonManagement3.GetArrayPropertyValueAsStringByName('documentIdentifier', DocumentNo);
            JsonManagement3.GetArrayPropertyValueAsStringByName('documentSubType', Status);

            if Value = 'Received' then begin
                TempNameValueBuffer.Init();
                TempNameValueBuffer.Name := CopyStr(DocumentId, 1, 250);
                TempNameValueBuffer.Value := CopyStr(DocumentNo, 1, 250);
                TempNameValueBuffer."Value Long" := CopyStr(Status, 1, 2048);
                TempNameValueBuffer.Insert();
            end;
        end;
        exit(false);
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

    local procedure SelectEDocumentService() EDocumentService: Record "E-Document Service"
    var
        EDocumentServices: Page "E-Document Services";
    begin
        EDocumentServices.LookupMode(true);
        if EDocumentServices.RunModal() = Action::LookupOK then
            EDocumentServices.GetRecord(EDocumentService);
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
        ContentData, DocumentId, FileId : Text;
    begin
        if EDocumentService."Service Integration" <> EDocumentService."Service Integration"::Pagero then
            exit;

        HttpResponse.Content.ReadAs(ContentData);
        if not ParseReceivedDocument(ContentData, EDocument."Index In Batch", DocumentId, FileId) then begin
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, DocumentIdNotFoundErr);
            exit;
        end;

        PageroConnection.HandleGetTargetDocumentRequest(DocumentId, LocalHttpRequest, LocalHttpResponse, false);
        EDocumentLogHelper.InsertIntegrationLog(EDocument, EDocumentService, LocalHttpRequest, LocalHttpResponse);

        LocalHttpResponse.Content.ReadAs(ContentData);
        if ContentData = '' then
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, StrSubstNo(CouldNotRetrieveDocumentErr, DocumentId));

        Clear(TempBlob);
        TempBlob.CreateOutStream(DocumentOutStream, TextEncoding::UTF8);
        DocumentOutStream.WriteText(ContentData);

        FetchEDocument(EDocument, EDocumentService, DocumentId);

        EDocument."Document Id" := CopyStr(DocumentId, 1, MaxStrLen(EDocument."Document Id"));
        EDocument."File Id" := CopyStr(FileId, 1, MaxStrLen(EDocument."File Id"));

        EDocumentLogHelper.InsertLog(EDocument, EDocumentService, TempBlob, "E-Document Service Status"::Imported);
    end;


    var
        PageroConnection: Codeunit "Pagero Connection";
        EDocumentHelper: Codeunit "E-Document Helper";
        EDocumentLogHelper: Codeunit "E-Document Log Helper";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        GetApprovalCheckStatusErr: Label 'You cannot ask for approval with the E-Document in this current status %1. You can request for approval when E-document status is Sent.', Comment = '%1 - Status';
        SendApproveRejectCheckStatusErr: Label 'You cannot send %1 response with the E-Socument in this current status %2. You can send response when E-document status is ''Imported Document Created''.', Comment = '%1 - Action response, %2 - Status';
        CancelCheckStatusErr: Label 'You cannot ask for cancel with the E-Document in this current status %1. You can request for cancel when E-document status is ''Cancel Error'' or ''Sending Error''.', Comment = '%1 - Status';
        CouldNotRetrieveDocumentErr: Label 'Could not retrieve document with id: %1 from the service', Comment = '%1 - Document ID';
        DocumentIdNotFoundErr: Label 'Document ID not found in response';
        ParseErr: Label 'Failed to parse document from Pagero API';
        WrongParseStatusErr: Label 'Got unexected status from Pagero API: %1', Comment = '%1 - Status that we received from API', Locked = true;
        PageroAwaitingInteractionStatusLbl: Label 'AwaitingInteraction', Locked = true;
        PageroErrorStatusLbl: Label 'Error', Locked = true;
        PageroProcessingStatusLbl: Label 'Processing', Locked = true;
        ExternalServiceTok: Label 'ExternalServiceConnector', Locked = true;
}