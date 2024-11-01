codeunit 139658 "E-Doc. Integration Mock V2" implements Sender, Receiver, "Default Int. Actions"
{

    Access = Internal;

    procedure Send(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var TempBlob: codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; var IsAsync: Boolean)
    begin
        OnSend(EDocument, EDocumentService, TempBlob, IsAsync, HttpRequest, HttpResponse);
    end;

    procedure SendBatch(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var TempBlob: codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; var IsAsync: Boolean)
    begin

    end;

    procedure GetResponse(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    var
        Success: Boolean;
    begin
        OnGetResponse(EDocument, HttpRequest, HttpResponse, Success);
        exit(Success);
    end;

    procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; var TempBlob: codeunit "Temp Blob"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage; var Count: Integer)
    begin
        OnReceiveDocuments(TempBlob, HttpRequestMessage, HttpResponseMessage, Count);
    end;

    procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var DocumentsBlob: codeunit "Temp Blob"; var DocumentBlob: codeunit System.Utilities."Temp Blob"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    begin
        OnDownloadDocument(EDocument, EDocumentService, DocumentsBlob, DocumentBlob, HttpRequestMessage, HttpResponseMessage);
    end;

    procedure GetSentDocumentApprovalStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; var Status: Enum "E-Document Service Status"): Boolean
    var
        Update: Boolean;
    begin
        OnGetApproval(EDocument, EDocumentService, HttpRequest, HttpResponse, Status, Update);
        exit(Update);
    end;

    procedure GetSentDocumentCancelationStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; var Status: Enum "E-Document Service Status"): Boolean
    begin

    end;

    procedure OpenServiceIntegrationSetupPage(var EDocumentService: Record "E-Document Service"): Boolean
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSend(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReceiveDocuments(var TempBlob: codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; var Count: Integer);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetResponse(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; var Success: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetApproval(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; var Status: Enum "E-Document Service Status"; var Update: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var DocumentsBlob: codeunit "Temp Blob"; var DocumentBlob: codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage);
    begin
    end;

#if not CLEAN26
    procedure Send(var EDocument: Record "E-Document"; var TempBlob: codeunit System.Utilities."Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    begin

    end;

    procedure SendBatch(var EDocuments: Record "E-Document"; var TempBlob: codeunit System.Utilities."Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    begin

    end;

    procedure GetResponse(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    begin

    end;

    procedure GetApproval(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    begin

    end;

    procedure Cancel(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    begin

    end;

    procedure ReceiveDocument(var TempBlob: codeunit System.Utilities."Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    begin

    end;

    procedure GetDocumentCountInBatch(var TempBlob: codeunit System.Utilities."Temp Blob"): Integer
    begin

    end;

    procedure GetIntegrationSetup(var SetupPage: Integer; var SetupTable: Integer)
    begin

    end;
#endif
}