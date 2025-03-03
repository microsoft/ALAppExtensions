// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using Microsoft.EServices.EDocument;
using System.Text;
using System.Utilities;
using Microsoft.eServices.EDocument.Integration.Send;
using Microsoft.eServices.EDocument.Integration.Receive;

codeunit 6445 "SignUp Processing"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "E-Document" = rim,
                  tabledata "E-Document Service Status" = rm,
                  tabledata "E-Document Service" = r,
                  tabledata "E-Document Integration Log" = rim,
                  tabledata "E-Document Log" = ri;

    #region variables
    var
        SignUpConnection: Codeunit "SignUp Connection";
        SignUpHelpersImpl: Codeunit "SignUp Helpers";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        EDocumentLogHelper: Codeunit "E-Document Log Helper";
        CouldNotRetrieveDocumentErr: Label 'Could not retrieve document with id: %1 from the service', Comment = '%1 - Document ID';
        CouldNotSendPatchErr: Label 'Could not Send Patch for document with id: %1', Comment = '%1 - Document ID';
        CouldNotRetrieveStatusFromResponseLbl: Label 'Could not retrieve status from response';
        DocumentIdNotFoundErr: Label 'Document ID not found in response';
        ErrorMessageMissingErr: Label 'Error message is missing or could not be parsed in the response';
        InboxTxt: Label 'inbox', Locked = true;
        InstanceIdTxt: Label 'instanceId', Locked = true;
        TransactionIdTxt: Label 'transactionId', Locked = true;
        StatusTxt: Label 'status', Locked = true;
        SentTxt: Label 'sent', Locked = true;
        ProcessingTxt: Label 'processing', Locked = true;
        FailedTxt: Label 'failed', Locked = true;
        DescriptionTxt: Label 'description', Locked = true;
        ResponseErrorTxt: Label 'ERROR', Locked = true;
        LevelTxt: Label 'level', Locked = true;
        EventsTxt: Label 'events', Locked = true;
        ReasonTxt: Label 'Reason: ', Locked = true;
        NewTxt: Label 'new', Locked = true;
        DocumentTxt: Label 'document', Locked = true;

    #endregion

    #region public methods

    /// <summary>
    /// The method sends the E-Document to the API.
    /// </summary>
    /// <param name="EDocument">The E-Document record to be sent.</param>
    /// <param name="EDocumentService">The E-Document Service record associated with the E-Document.</param>
    /// <param name="SendContext">The context in which the document is being sent, encapsulated in a SendContext codeunit.</param>
    procedure Send(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext);
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
        TempBlob: Codeunit "Temp Blob";
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
    begin
        TempBlob := SendContext.GetTempBlob();

        EDocumentServiceStatus.Get(EDocument."Entry No", EDocumentService.Code);

        case EDocumentServiceStatus.Status of
            EDocumentServiceStatus.Status::Exported:
                this.SendEDocument(EDocument, TempBlob, HttpRequestMessage, HttpResponseMessage);
            EDocumentServiceStatus.Status::"Sending Error":
                if EDocument."SignUp Document Id" = '' then
                    this.SendEDocument(EDocument, TempBlob, HttpRequestMessage, HttpResponseMessage);
        end;

        SendContext.SetTempBlob(TempBlob);
        SendContext.Http().SetHttpRequestMessage(HttpRequestMessage);
        SendContext.Http().SetHttpResponseMessage(HttpResponseMessage);

    end;

    /// <summary>
    /// The method retrieves the response for the sent E-Document from the API.
    /// </summary>
    /// <param name="EDocument">The E-Document record for which the response is being retrieved.</param>
    /// <param name="EDocumentService">The E-Document Service record associated with the E-Document.</param>
    /// <param name="SendContext">The context in which the document was sent, encapsulated in a SendContext codeunit.</param>
    /// <returns>Returns true if the response was successfully retrieved, otherwise false.</returns>
    procedure GetResponse(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext): Boolean;
    var
        Status, ErrorDescription : Text;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
    begin
        if EDocument."SignUp Document Id" = '' then
            exit;

        if not this.SignUpConnection.CheckDocumentStatus(EDocument, HttpRequestMessage, HttpResponseMessage) then
            exit;

        SendContext.Http().SetHttpRequestMessage(HttpRequestMessage);
        SendContext.Http().SetHttpResponseMessage(HttpResponseMessage);

        if not this.ParseDocumentResponse(HttpResponseMessage.Content, Status, ErrorDescription) then begin
            this.EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, this.CouldNotRetrieveStatusFromResponseLbl);
            exit;
        end;


        case Status of
            this.SentTxt:
                exit(this.SendAcknowledgePatch(EDocument, EDocumentService));
            this.ProcessingTxt:
                exit(false);
            this.FailedTxt:
                begin
                    if ErrorDescription <> '' then
                        this.EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, this.ReasonTxt + ErrorDescription)
                    else
                        this.EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, this.ErrorMessageMissingErr);
                    exit(this.SendAcknowledgePatch(EDocument, EDocumentService));
                end;
        end;

    end;

    /// <summary>
    /// The method receives documents from the API.
    /// </summary>
    /// <param name="EDocumentService">The E-Document Service record associated with the documents being received.</param>
    /// <param name="DocumentsMetadataTempBlobList">A codeunit containing metadata for the received documents.</param>
    /// <param name="ReceiveContext">The context in which the documents are being received, encapsulated in a ReceiveContext codeunit.</param>
    procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; DocumentsMetadataTempBlobList: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)
    var
        TempBlob: Codeunit "Temp Blob";
        JSONManagement: Codeunit "JSON Management";
        ContentData: Text;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        ReceiveSucceed: Boolean;
    begin
        ReceiveSucceed := this.SignUpConnection.GetReceivedDocuments(HttpRequestMessage, HttpResponseMessage);
        ReceiveContext.Http().SetHttpRequestMessage(HttpRequestMessage);
        ReceiveContext.Http().SetHttpResponseMessage(HttpResponseMessage);
        if not ReceiveSucceed then
            exit;

        if not HttpResponseMessage.Content.ReadAs(ContentData) then
            exit;

        if not JsonManagement.InitializeFromString(ContentData) then
            exit;

        JsonManagement.GetArrayPropertyValueAsStringByName(this.InboxTxt, ContentData);
        JsonArray.ReadFrom(ContentData);

        foreach JsonToken in JsonArray do begin
            Clear(TempBlob);
            JsonToken.WriteTo(TempBlob.CreateOutStream(TextEncoding::UTF8));
            DocumentsMetadataTempBlobList.Add(TempBlob);
        end;
    end;

    procedure GetDocumentCountInBatch(var TempBlob: Codeunit "Temp Blob"): Integer
    var
        ResponseTxt: Text;
    begin
        TempBlob.CreateInStream().ReadText(ResponseTxt);
        exit(this.GetNumberOfReceivedDocuments(ResponseTxt));
    end;

    procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadataTempBlob: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    var
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        ContentData, DocumentId : Text;
    begin
        if EDocumentService."Service Integration V2" <> EDocumentService."Service Integration V2"::"ExFlow E-Invoicing" then
            exit;

        DocumentMetadataTempBlob.CreateInStream(TextEncoding::UTF8).ReadText(ContentData);

        ContentData := this.LeaveJustNewLine(ContentData);

        if not this.ParseReceivedDocument(ContentData, DocumentId) then begin
            this.EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, this.DocumentIdNotFoundErr);
            exit;
        end;

        EDocument."SignUp Document Id" := CopyStr(DocumentId, 1, MaxStrLen(EDocument."SignUp Document Id"));
        EDocument.Modify();

        Clear(ContentData);

        this.SignUpConnection.GetTargetDocumentRequest(EDocument."SignUp Document Id", HttpRequestMessage, HttpResponseMessage);
        ReceiveContext.Http().SetHttpRequestMessage(HttpRequestMessage);
        ReceiveContext.Http().SetHttpResponseMessage(HttpResponseMessage);

        if not HttpResponseMessage.Content.ReadAs(ContentData) then
            exit;

        if not this.ParseContentData(ContentData) then
            ContentData := '';

        if ContentData = '' then
            this.EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, StrSubstNo(this.CouldNotRetrieveDocumentErr, DocumentId))
        else
            ReceiveContext.GetTempBlob().CreateOutStream(TextEncoding::UTF8).WriteText(ContentData);
    end;

    procedure MarkFetched(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    var
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
    begin
        this.SignUpConnection.RemoveDocumentFromReceived(EDocument, HttpRequestMessage, HttpResponseMessage);

        ReceiveContext.Http().SetHttpRequestMessage(HttpRequestMessage);
        ReceiveContext.Http().SetHttpResponseMessage(HttpResponseMessage);

    end;
    #endregion

    #region local methods

    local procedure ParseDocumentResponse(HttpContentResponse: HttpContent; var Status: Text; var StatusDescription: Text): Boolean
    var
        JsonManagement: Codeunit "JSON Management";
        Result: Text;
    begin
        Status := '';
        StatusDescription := '';

        Result := this.SignUpHelpersImpl.ParseJsonString(HttpContentResponse);
        if Result = '' then
            exit;

        if not JsonManagement.InitializeFromString(Result) then
            exit;

        if not this.GetStatus(JsonManagement, Status) then
            exit;

        case Status of
            this.FailedTxt:
                StatusDescription := this.GetErrorDescriptionFromJson(Result);
        end;

        exit(true);
    end;

    local procedure GetErrorDescriptionFromJson(JsonText: Text): Text
    var
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        EventObject: JsonObject;
        ErrorDescription: Text;
    begin
        if JsonObject.ReadFrom(JsonText) then
            if JsonObject.Get(this.EventsTxt, JsonToken) then
                if JsonToken.IsArray() then begin
                    JsonArray := JsonToken.AsArray();
                    foreach JsonToken in JsonArray do
                        if JsonToken.IsObject then begin
                            EventObject := JsonToken.AsObject();
                            if EventObject.Get(this.LevelTxt, JsonToken) then
                                if (JsonToken.AsValue().AsText() = this.ResponseErrorTxt) then
                                    if EventObject.Get(this.DescriptionTxt, JsonToken) then
                                        if JsonToken.AsValue().AsText() <> '' then
                                            ErrorDescription += JsonToken.AsValue().AsText() + ', ';
                        end;
                end;
        if ErrorDescription <> '' then
            ErrorDescription := ErrorDescription.TrimEnd(', ');
        exit(ErrorDescription);
    end;

    local procedure SendEDocument(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage);
    begin
        this.SignUpConnection.SendFilePostRequest(TempBlob, EDocument, HttpRequestMessage, HttpResponseMessage);
        this.SetEDocumentFileID(EDocument."Entry No", this.ParseSendFileResponse(HttpResponseMessage.Content));
    end;

    local procedure ParseReceivedDocument(InputTxt: Text; var DocumentId: Text): Boolean
    var
        SignUpHelpers: Codeunit "SignUp Helpers";
    begin
        DocumentId := SignUpHelpers.GetJsonValueFromText(InputTxt, this.TransactionIdTxt);
        exit(DocumentId <> '');
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
        Result := this.SignUpHelpersImpl.ParseJsonString(HttpContentResponse);
        if Result = '' then
            exit;

        if not JsonManagement.InitializeFromString(Result) then
            exit;

        JsonManagement.GetStringPropertyValueByName(this.TransactionIdTxt, Value);
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

        EDocument."SignUp Document Id" := CopyStr(FileId, 1, MaxStrLen(EDocument."SignUp Document Id"));
        EDocument.Modify();
    end;

    local procedure GetStatus(var JsonManagement: Codeunit "Json Management"; var Status: Text): Boolean
    begin
        if not JsonManagement.GetArrayPropertyValueAsStringByName(this.StatusTxt, Status) then
            exit;

        Status := Status.ToLower();
        exit(true);
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
    begin
        if not JsonManagement.InitializeFromString(InputText) then
            exit;

        JsonManagement.GetArrayPropertyValueAsStringByName(this.DocumentTxt, Value);
        InputText := Base64Convert.FromBase64(Value);
        exit(true);
    end;

    local procedure SendAcknowledgePatch(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"): Boolean
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
        SignUpAPIRequests: Codeunit "SignUp API Requests";
        HttpResponseMessage: HttpResponseMessage;
        HttpRequestMessage: HttpRequestMessage;
    begin
        EDocumentServiceStatus.SetLoadFields(Status);
        EDocumentServiceStatus.Get(EDocument."Entry No", EDocumentService.Code);
        if not (EDocumentServiceStatus.Status in [EDocumentServiceStatus.Status::Sent, EDocumentServiceStatus.Status::"Pending Response", EDocumentServiceStatus.Status::"Pending Batch"]) then
            exit;

        if SignUpAPIRequests.PatchDocument(EDocument, HttpRequestMessage, HttpResponseMessage) then begin
            this.EDocumentLogHelper.InsertIntegrationLog(EDocument, EDocumentService, HttpRequestMessage, HttpResponseMessage);
            exit(true);
        end else
            this.EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, StrSubstNo(this.CouldNotSendPatchErr, EDocument."SignUp Document Id"));
    end;

    #endregion
}