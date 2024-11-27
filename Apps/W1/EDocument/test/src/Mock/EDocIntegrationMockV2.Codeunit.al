codeunit 139658 "E-Doc. Integration Mock V2" implements IDocumentSender, IDocumentReceiver, IDocumentResponseHandler, ISentDocumentActions
{

    Access = Internal;

    procedure Send(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext)
    var
        TempBlob: codeunit "Temp Blob";
        IsAsync: Boolean;
    begin
        TempBlob := SendContext.GetTempBlob();
        OnSend(EDocument, EDocumentService, TempBlob, IsAsync, SendContext.Http().GetHttpRequestMessage(), SendContext.Http().GetHttpResponseMessage());
    end;

    procedure SendBatch(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext)
    begin

    end;

    procedure GetResponse(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext): Boolean
    var
        Success: Boolean;
    begin
        OnGetResponse(EDocument, SendContext.Http().GetHttpRequestMessage(), SendContext.Http().GetHttpResponseMessage(), Success);
        exit(Success);
    end;

    procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; DocumentsMetadata: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)
    begin
        OnReceiveDocuments(DocumentsMetadata, ReceiveContext.Http().GetHttpRequestMessage(), ReceiveContext.Http().GetHttpResponseMessage());
    end;

    procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadata: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    var
        DocumentDownloadBlob: Codeunit "Temp Blob";
    begin
        OnDownloadDocument(EDocument, EDocumentService, DocumentMetadata, DocumentDownloadBlob, ReceiveContext.Http().GetHttpRequestMessage(), ReceiveContext.Http().GetHttpResponseMessage());
        ReceiveContext.SetTempBlob(DocumentDownloadBlob);
    end;

    procedure GetApprovalStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; ActionContext: Codeunit ActionContext): Boolean
    var
        Status: Enum "E-Document Service Status";
        Update: Boolean;
    begin
        OnGetApproval(EDocument, EDocumentService, ActionContext.Http().GetHttpRequestMessage(), ActionContext.Http().GetHttpResponseMessage(), Status, Update);
        ActionContext.Status().SetStatus(Status);
        exit(Update);
    end;

    procedure GetCancellationStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; ActionContext: Codeunit ActionContext): Boolean
    begin

    end;

    procedure OpenServiceIntegrationSetupPage(var EDocumentService: Record "E-Document Service"): Boolean
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSend(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReceiveDocuments(ReceivedEDocuments: Codeunit "Temp Blob List"; HttpRequestMessage: HttpRequestMessage; HttpResponseMessage: HttpResponseMessage);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadata: Codeunit "Temp Blob"; var DocumentDownloadBlob: Codeunit "Temp Blob"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetResponse(var EDocument: Record "E-Document"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage; var Success: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetApproval(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage; var Status: Enum "E-Document Service Status"; var Update: Boolean);
    begin
    end;

}