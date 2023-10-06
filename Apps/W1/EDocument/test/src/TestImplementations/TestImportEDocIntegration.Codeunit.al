codeunit 139627 "Test Import E-Doc. Integration" implements "E-Document Integration"
{
    procedure Send(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    begin
    end;

    procedure ReceiveDocument(var TempBlob: Codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var http: HttpResponseMessage);
    var
        OutStr: OutStream;
    begin
        TempBlob.CreateOutStream(OutStr);
        OutStr.WriteText('Some Test Content');
    end;

    procedure GetDocumentCountInBatch(var TempBlob: Codeunit "Temp Blob"): Integer
    var
        TmpPurchHeader: Record "Purchase Header" temporary;
        TmpPurchLine: Record "Purchase Line" temporary;
        PurchDocTestBuffer: Codeunit "Purch. Doc. Test Buffer";
    begin
        PurchDocTestBuffer.GetTempVariables(TmpPurchHeader, TmpPurchLine);
        exit(TmpPurchHeader.Count());
    end;

    procedure SendBatch(var EDocuments: Record "E-Document"; var TempBlob: codeunit System.Utilities."Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage);
    begin

    end;

    procedure GetResponse(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    begin

    end;

    procedure GetApproval(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var http: HttpResponseMessage): Boolean
    begin
    end;

    procedure Cancel(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    begin

    end;

    procedure GetIntegrationSetup(var SetupPage: Integer; var SetupTable: Integer)
    begin
    end;
}