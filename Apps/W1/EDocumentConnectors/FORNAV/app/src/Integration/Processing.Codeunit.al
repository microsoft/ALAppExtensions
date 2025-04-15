namespace Microsoft.EServices.EDocumentConnector.ForNAV;

using Microsoft.EServices.EDocument;
using System.Text;
using System.Utilities;
using Microsoft.eServices.EDocument.Integration.Send;
using Microsoft.eServices.EDocument.Integration.Receive;
codeunit 6246268 "ForNAV Processing"
{
    Access = Internal;
    Permissions = tabledata "E-Document" = m,
                  tabledata "E-Document Service Status" = m;

    procedure SendDocument(var EDocument: Record "E-Document"; SendContext: Codeunit SendContext)
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
        EdocumentService: Record "E-Document Service";
    begin
        EdocumentService := GetEdocumentService(EDocument);
        EDocumentServiceStatus.Get(EDocument."Entry No", EdocumentService.Code);

        case EDocumentServiceStatus.Status of
            EDocumentServiceStatus.Status::Exported:
                SendEDocument(EDocument, SendContext);
            EDocumentServiceStatus.Status::"Sending Error":
                if EDocument."ForNAV Core ID" = '' then
                    SendEDocument(EDocument, SendContext)
                else
                    RestartDocument(EDocument, SendContext);
        end;
    end;

    procedure RestartDocument(EDocument: Record "E-Document"; SendContext: Codeunit SendContext): Boolean
    var
        EDocumentService: Record "E-Document Service";
    begin
        EdocumentService := GetEdocumentService(EDocument);
        if not EDocumentService.IsForNAVServiceIntegration() then
            exit;

        if ForNAVConnection.HandleSendActionRequest(EDocument, SendContext, 'Restart') then
            exit(true);
    end;

    procedure GetDocumentApproval(EDocument: Record "E-Document") Status: Enum "ForNAV Incoming Doc Status"
    var
        IncomingDoc: Codeunit "ForNAV Inbox";
        StatusDescription: Text;
    begin
        Status := IncomingDoc.GetApprovalStatus(EDocument, StatusDescription);
        case IncomingDoc.GetApprovalStatus(EDocument, StatusDescription) of
            "ForNAV Incoming Doc Status"::Rejected:
                begin
                    if StatusDescription <> '' then
                        EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, 'Reason: ' + StatusDescription);
                end;
        end;
        exit(Status);
    end;


    procedure GetResponse(var EDocument: Record "E-Document"; SendContext: Codeunit SendContext): Boolean
    var
        InBox: Codeunit "ForNAV Inbox";
    begin
        exit(InBox.GetEvidence(EDocument, SendContext));
    end;

    local procedure FetchDocument(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; DocumentId: Text)
    var
        Documents: JsonArray;
        SendContext: Codeunit SendContext;
    begin
        if DocumentId = '' then
            exit;
        // Mark document as fetched
        Documents.Add(DocumentId);
        ForNAVConnection.HandleSendFetchDocumentRequest(Documents, SendContext);
        EDocumentLogHelper.InsertIntegrationLog(EDocument, EDocumentService, SendContext.Http().GetHttpRequestMessage(), SendContext.Http().GetHttpResponseMessage());
    end;

    procedure ReceiveDocuments(ReceiveContext: Codeunit ReceiveContext; DocumentsMetadata: Codeunit "Temp Blob List")
    var
        ContentData: Text;
        OutStream: OutStream;
    begin
        if not ForNAVConnection.GetReceivedDocuments(ReceiveContext, DocumentsMetadata) then
            exit;

        ReceiveContext.Http().GetHttpResponseMessage().Content.ReadAs(ContentData);
        ReceiveContext.GetTempBlob().CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(ContentData);
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

    internal procedure SendEDocument(EDocument: Record "E-Document"; SendContext: Codeunit SendContext);
    var
        HttpContentResponse: HttpContent;
        FileId: Text;
    begin
        ForNAVConnection.HandleSendFilePostRequest(EDocument, SendContext);
        HttpContentResponse := SendContext.Http().GetHttpResponseMessage().Content;
        FileId := ParseSendFileResponse(HttpContentResponse);
        SetEDocument(EDocument."Entry No", FileId);
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

        JsonManagement.GetArrayPropertyValueAsStringByName('items', Value);
        JsonManagement.InitializeCollection(Value);

        if Index = 0 then
            Index := 1;

        if Index > JsonManagement.GetCollectionCount() then
            exit(false);

        JsonManagement.GetObjectFromCollectionByIndex(IncrementalTable, Index - 1);
        JsonManagement2.InitializeObject(IncrementalTable);
        JsonManagement2.GetArrayPropertyValueAsStringByName('id', DocumentId);
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

    local procedure SetEDocument(EDocEntryNo: Integer; FileId: Text)
    var
        EDocument: Record "E-Document";
    begin
        if FileId = '' then
            exit;
        if not EDocument.Get(EDocEntryNo) then
            exit;

        EDocument."ForNAV Core ID" := CopyStr(FileId, 1, MaxStrLen(EDocument."ForNAV Core ID"));
        EDocument.Modify();
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

    procedure GetDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadata: codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    var
        InStream: InStream;
        DocumentOutStream: OutStream;
        ContentData: Text;
        DocumentId: Text;
        TempBlob: Codeunit "Temp Blob";
    begin
        if not EDocumentService.IsForNAVServiceIntegration() then
            exit;
        DocumentMetadata.CreateInStream(InStream, TextEncoding::UTF8);
        InStream.ReadText(DocumentId);

        ForNAVConnection.HandleGetTargetDocumentRequest(DocumentId, ReceiveContext);
        EDocumentLogHelper.InsertIntegrationLog(EDocument, EDocumentService, ReceiveContext.Http().GetHttpRequestMessage(), ReceiveContext.Http().GetHttpResponseMessage());

        ReceiveContext.Http().GetHttpResponseMessage().Content.ReadAs(ContentData);
        if ContentData = '' then
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, StrSubstNo(CouldNotRetrieveDocumentErr, DocumentId));

        TempBlob.CreateOutStream(DocumentOutStream, TextEncoding::UTF8);
        DocumentOutStream.WriteText(ContentData);
        ReceiveContext.SetTempBlob(TempBlob); // To clear the tempblob from previous data

        FetchDocument(EDocument, EDocumentService, DocumentId);

        EDocument."ForNAV Core ID" := CopyStr(DocumentId, 1, MaxStrLen(EDocument."ForNAV Core ID"));
        EDocument."Document Sending Profile" := 'FORNAV';
        EDocument.Modify();
        EDocumentLogHelper.InsertLog(EDocument, EDocumentService, TempBlob, "E-Document Service Status"::Imported);
    end;

    local procedure GetEdocumentService(EDocument: Record "E-Document") EDocumentService: Record "E-Document Service"
    begin
        EDocumentService.Get('FORNAV');
    end;

    var
        ForNAVConnection: Codeunit "ForNAV Connection";
        EDocumentLogHelper: Codeunit "E-Document Log Helper";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        GetApprovalCheckStatusErr: Label 'You cannot ask for approval with the E-Document in this current status %1. You can request for approval when E-document status is Sent.', Comment = '%1 - Status', Locked = true;
        CouldNotRetrieveDocumentErr: Label 'Could not retrieve document with id: %1 from the service', Comment = '%1 - Document ID', Locked = true;
        DocumentIdNotFoundErr: Label 'Document ID not found in response', Locked = true;
}