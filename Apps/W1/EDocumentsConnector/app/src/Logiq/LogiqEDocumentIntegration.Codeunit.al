namespace Microsoft.EServices.EDocumentConnector.Logiq;

using Microsoft.eServices.EDocument;
using System.Utilities;

codeunit 6381 "Logiq E-Document Integration" implements "E-Document Integration"
{
    Access = Internal;

    procedure Send(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    begin
        LogiqEDocumentManagement.Send(EDocument, TempBlob, IsAsync, HttpRequest, HttpResponse);
    end;

#pragma warning disable AA0150
    procedure SendBatch(var EDocuments: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    begin
        Error('Batch sending is not supported');
    end;
#pragma warning restore AA0150
    procedure GetResponse(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    begin
        Error('Getting response is not supported');
    end;

    procedure GetApproval(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    begin
        Error('Approval is not supported');
    end;

    procedure Cancel(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    begin
        Error('Cancelling sent document is not supported');
    end;

    procedure ReceiveDocument(var TempBlob: Codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    begin
        LogiqEDocumentManagement.DownloadDocuments(TempBlob, HttpRequest, HttpResponse);
    end;

    procedure GetDocumentCountInBatch(var TempBlob: Codeunit "Temp Blob"): Integer
    begin
        exit(LogiqEDocumentManagement.GetDocumentCountInBatch(TempBlob));
    end;

    procedure GetIntegrationSetup(var SetupPage: Integer; var SetupTable: Integer)
    begin
        SetupTable := Database::"Logiq Connection Setup";
        SetupPage := Page::"Logiq Connection Setup";
    end;

    var
        LogiqEDocumentManagement: Codeunit "Logiq E-Document Management";
}
