codeunit 139668 "E-Doc. Int Mock No Async" implements IDocumentSender, IDocumentReceiver
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

}