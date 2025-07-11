// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.B2Brouter;

using System.Text;
using System.Utilities;
using Microsoft.EServices.EDocument;
using Microsoft.EServices.EDocument.Integration.Send;
using Microsoft.EServices.EDocument.Integration.Receive;

codeunit 6490 "B2Brouter Api Management"
{
    Access = Internal;

    procedure SendDocument(var EDocument: Record "E-Document"; SendContext: Codeunit SendContext)
    var
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        TempBlob: Codeunit "Temp Blob";
        RecordRef: RecordRef;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
    begin
        TempBlob := SendContext.GetTempBlob();

        if EDocument."B2Brouter File Id" = 0 then begin
            this.InitImportRequest(HttpRequest);
            this.SetContentFromTempBlob(HttpRequest, EDocument, TempBlob);
        end else
            this.InitSendRequest(HttpRequest, EDocument."B2Brouter File Id");

        SendRequest(HttpRequest, HttpResponse);

        case HttpResponse.HttpStatusCode of
            201:
                begin
                    EDocument."B2Brouter File Id" := ReadInvoiceIdFromJsonResponseAfterInvoiceCreation(HttpResponse);
                    EDocument.Modify();
                end;
            else begin
                RecordRef.Get(EDocument."Document Record ID");
                EDocumentErrorHelper.LogErrorMessage(EDocument, RecordRef, 0, Format(HttpResponse.HttpStatusCode) + ': ' + HttpResponse.ReasonPhrase);
            end;
        end;
        LogErrorMessages(EDocument, HttpResponse);

        SendContext.Http().SetHttpRequestMessage(HttpRequest);
        SendContext.Http().SetHttpResponseMessage(HttpResponse);
    end;

    local procedure SetContentFromTempBlob(var HttpRequest: HttpRequestMessage; EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob")
    var
        Base64Convert: Codeunit "Base64 Convert";
        InStream: InStream;
        HttpContentHeader: HttpHeaders;
    begin
        TempBlob.CreateInStream(InStream);
        HttpRequest.Content.WriteFrom(StrSubstNo(HttpConcentLbl, EDocument."Document No.", Base64Convert.ToBase64(InStream)));
        HttpRequest.Content.GetHeaders(HttpContentHeader);

        if HttpContentHeader.Contains('content-type') then
            HttpContentHeader.Remove('content-type');
        HttpContentHeader.Add('content-type', 'application/octet-stream');
    end;

    local procedure LogErrorMessages(EDocument: Record "E-Document"; HttpResponse: HttpResponseMessage)
    var
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        RecordRef: RecordRef;
        ResponseText: Text;
        ResponseJson: JsonObject;
        TokenJson: JsonToken;
        Errors: JsonArray;
        ErrorText: Text;
        I: Integer;
    begin
        RecordRef.Get(EDocument."Document Record ID");

        HttpResponse.Content.ReadAs(ResponseText);
        if not ResponseJson.ReadFrom(ResponseText) then
            exit;

        if not ResponseJson.SelectToken('$.errors', TokenJson) then
            if not ResponseJson.SelectToken('$.invoice.errors', TokenJson) then
                exit;

        Errors := TokenJson.AsArray();

        for I := 0 to Errors.Count - 1 do begin
            Clear(TokenJson);
            Errors.Get(I, TokenJson);
            TokenJson.WriteTo(ErrorText);
            EDocumentErrorHelper.LogErrorMessage(EDocument, RecordRef, 0, DelChr(ErrorText, '=', '"'));
        end;
    end;

    internal procedure CancelInvoice(var EDocument: Record "E-Document"; HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    begin
        EDocument.TestField("B2Brouter File Id");

        InitCancelRequest(HttpRequest, EDocument."B2Brouter File Id");
        SendRequest(HttpRequest, HttpResponse);

        if HttpResponse.HttpStatusCode = 204 then begin
            EDocument."B2Brouter File Id" := 0;
            EDocument.Modify();
            exit(true);
        end;

        exit(false);
    end;

    local procedure ReadInvoiceIdFromJsonResponseAfterInvoiceCreation(var HttpResponse: HttpResponseMessage) InvoiceId: Integer
    var
        ResponseJSON: JsonObject;
        InvoiceIdJson: JsonToken;
        InvoiceIdText: Text;
        ResponseTxt: Text;
    begin
        HttpResponse.Content.ReadAs(ResponseTxt);
        ResponseJSON.ReadFrom(ResponseTxt);
        ResponseJSON.SelectToken('$.invoice.id', InvoiceIdJson);
        InvoiceIdJson.WriteTo(InvoiceIdText);
        Evaluate(InvoiceId, InvoiceIdText);
    end;

    internal procedure MarkFetched(FileId: Integer; ReceiveContext: Codeunit ReceiveContext)
    var
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
    begin
        InitMarkFetchedRequest(HttpRequest, FileId);

        SendRequest(HttpRequest, HttpResponse);

        ReceiveContext.Http().SetHttpRequestMessage(HttpRequest);
        ReceiveContext.Http().SetHttpResponseMessage(HttpResponse);
    end;

    internal procedure GetResponse(var EDocument: Record "E-Document"; SendContext: Codeunit SendContext) Success: Boolean
    var
        ResponseText: Text;
        ResponseJSON: JsonObject;
        TokenJson: JsonToken;
        StatusText: Text;
        Status: Enum "E-Document Service Status";
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
    begin
        InitGetResponseRequest(HttpRequest, EDocument."B2Brouter File Id");

        SendRequest(HttpRequest, HttpResponse);

        HttpResponse.Content.ReadAs(ResponseText);
        ResponseJson.ReadFrom(ResponseText);

        ResponseJson.SelectToken('$.invoice.state', TokenJson);
        TokenJson.WriteTo(StatusText);
        StatusText := DelChr(StatusText, '=', '"');

        if (StatusText <> 'sent') and (StatusText <> 'error') then
            Status := Status::"Pending Response";

        Success := StatusText in ['accepted', 'paid', 'sent', 'received'];
        case StatusText of
            'accepted':
                Status := Status::Approved;

            'new':
                Status := Status::Created;

            'error':
                Status := Status::"Sending Error";

            'cancelled':
                Status := Status::Canceled;

            'processing_pdf':
                Status := Status::"Pending Response";

            'sent':
                Status := Status::Sent;
        end;

        LogErrorMessages(EDocument, HttpResponse);

        SendContext.Status().SetStatus(Status);
        SendContext.Http().SetHttpRequestMessage(HttpRequest);
        SendContext.Http().SetHttpResponseMessage(HttpResponse);
    end;

    internal procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; DocumentsMetadata: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)
    var
        TempBlob: Codeunit "Temp Blob";
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        JsonToken: JsonToken;
        Index: Integer;
        OutStream: OutStream;
        ResponseTxt: Text;
        Response: JsonObject;
        Documents: JsonArray;
    begin
        InitReceiveRequest(HttpRequest);

        SendRequest(HttpRequest, HttpResponse);

        if not HttpResponse.IsSuccessStatusCode then
            Error(FailedToConsumeApiErr);

        HttpResponse.Content.ReadAs(ResponseTxt);
        Response.ReadFrom(ResponseTxt);
        Response.Get('invoices', JsonToken);
        Documents := JsonToken.AsArray();

        for Index := Documents.Count() - 1 downto 0 do begin
            Clear(TempBlob);
            TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
            Documents.GetObject(Index).WriteTo(OutStream);
            DocumentsMetadata.Add(TempBlob);
        end;

        ReceiveContext.Http().SetHttpRequestMessage(HttpRequest);
        ReceiveContext.Http().SetHttpResponseMessage(HttpResponse);
    end;

    internal procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadata: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    var
        TempBlob: Codeunit "Temp Blob";
        JSonObject: JsonObject;
        InStream: InStream;
        JSonToken: JsonToken;
        FileId: Integer;
    begin
        DocumentMetadata.CreateInStream(InStream);

        JSonObject.ReadFrom(InStream);
        JSonObject.Get('id', JSonToken);
        FileId := JSonToken.AsValue().AsInteger();

        EDocument."B2Brouter File Id" := FileId;
        EDocument.Modify();

        DownloadDocument(TempBlob, FileId, ReceiveContext);

        ReceiveContext.SetTempBlob(TempBlob);
    end;

    internal procedure DownloadDocument(var TempBlob: Codeunit "Temp Blob"; FileId: Integer; ReceiveContext: Codeunit ReceiveContext)
    var
        HttpResponse: HttpResponseMessage;
        HttpRequest: HttpRequestMessage;
        OutStream: OutStream;
        ContentData: Text;
    begin
        InitDownloadRequest(HttpRequest, FileId);

        SendRequest(HttpRequest, HttpResponse);

        HttpResponse.Content.ReadAs(ContentData);
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(ContentData);

        ReceiveContext.Http().SetHttpRequestMessage(HttpRequest);
        ReceiveContext.Http().SetHttpResponseMessage(HttpResponse);
    end;

    internal procedure InitRequestData()
    var
        B2BrouterSetup: Record "B2Brouter Setup";
    begin
        if RequestDataInitialized then
            exit;

        B2BrouterSetup.Get();

        if B2BrouterSetup."Sandbox Mode" then begin
            if (not B2BrouterSetup.GetApiKey(true, ApiKey)) or ApiKey.IsEmpty() then
                Error(NoApiKeyFoundErr, 'staging');

            B2BrouterSetup.TestField("Sandbox Project");
            Project := B2BrouterSetup."Sandbox Project";
            BaseUrl := GetBaseURL(true);
        end else begin
            if (not B2BrouterSetup.GetApiKey(false, ApiKey)) or ApiKey.IsEmpty() then
                Error(NoApiKeyFoundErr, 'production');

            B2BrouterSetup.TestField("Production Project");
            Project := B2BrouterSetup."Production Project";
            BaseUrl := GetBaseURL(false);
        end;

        HttpHeaders := HttpClient.DefaultRequestHeaders();
        HttpHeaders.Add('X-B2B-API-Key', ApiKey);

        RequestDataInitialized := true;
    end;

    internal procedure GetBaseURL(SandboxMode: Boolean) Url: Text
    begin
        if SandboxMode then
            Url := SandboxBaseUrlLbl
        else
            Url := ProdBaseUrlLbl;
    end;

    internal procedure GetBaseUrl(): Text
    begin
        InitRequestData();
        exit(BaseUrl);
    end;

    internal procedure GetProject(): Text
    begin
        InitRequestData();
        exit(Project)
    end;

    internal procedure GetApiKey(): SecretText
    begin
        InitRequestData();
        exit(ApiKey);
    end;

    internal procedure InitImportRequest(var HttpRequest: HttpRequestMessage)
    var
        EndpointUrl: Text;
    begin
        InitRequestData();

        EndpointUrl := StrSubstNo(BaseUrl + ImportEndpointLbl, Project);
        HttpRequest := CreateNewHttpRequest(EndpointUrl, 'POST');
    end;

    internal procedure InitDownloadRequest(var HttpRequest: HttpRequestMessage; FileId: Integer)
    var
        EndpointUrl: Text;
    begin
        InitRequestData();

        EndpointUrl := StrSubstNo(BaseUrl + ConvertInvoiceEndpointLbl, FileId, 'xml.ubl.invoice.bis3');
        HttpRequest := CreateNewHttpRequest(EndpointUrl, 'GET');
    end;

    internal procedure InitReceiveRequest(var HttpRequest: HttpRequestMessage)
    var
        EndpointUrl: Text;
    begin
        InitRequestData();

        EndpointUrl := StrSubstNo(BaseUrl + ReceiveInvoicesEndpointLbl, Project);
        HttpRequest := CreateNewHttpRequest(EndpointUrl, 'GET');
    end;

    internal procedure InitGetResponseRequest(var HttpRequest: HttpRequestMessage; FileId: Integer)
    var
        EndpointUrl: Text;
    begin
        InitRequestData();

        EndpointUrl := StrSubstNo(BaseUrl + SpecificInvoiceEndpointLbl, FileId);
        HttpRequest := CreateNewHttpRequest(EndpointUrl, 'GET');
    end;

    internal procedure InitCancelRequest(var HttpRequest: HttpRequestMessage; FileId: Integer)
    var
        EndpointUrl: Text;
    begin
        InitRequestData();

        EndpointUrl := StrSubstNo(BaseUrl + SpecificInvoiceEndpointLbl, FileId);
        HttpRequest := CreateNewHttpRequest(EndpointUrl, 'DELETE');
    end;

    internal procedure InitSendRequest(var HttpRequest: HttpRequestMessage; FileId: Integer)
    var
        EndpointUrl: Text;
    begin
        InitRequestData();

        EndpointUrl := StrSubstNo(BaseUrl + SendInvoicesEndpointLbl, FileId);
        HttpRequest := CreateNewHttpRequest(EndpointUrl, 'POST');
    end;

    procedure InitUpdateRequest(var HttpRequest: HttpRequestMessage; FileId: Integer)
    var
        EndpointUrl: Text;
    begin
        InitRequestData();

        EndpointUrl := StrSubstNo(BaseUrl + SpecificInvoiceEndpointLbl, FileId);
        HttpRequest := CreateNewHttpRequest(EndpointUrl, 'PUT');
    end;

    procedure InitMarkFetchedRequest(var HttpRequest: HttpRequestMessage; FileId: Integer)
    var
        EndpointUrl: Text;
    begin
        InitRequestData();

        EndpointUrl := StrSubstNo(BaseUrl + AcknowledgeInvoiceEndpointLbl, FileId);
        HttpRequest := CreateNewHttpRequest(EndpointUrl, 'POST');
    end;

    internal procedure CreateNewHttpRequest(Url: Text; Method: Text) Result: HttpRequestMessage
    begin
        Result.SetRequestUri(Url);
        Result.Method := Method;
    end;

    local procedure SendRequest(var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    begin
        if not this.HttpClient.Send(HttpRequest, HttpResponse) then
            Error(this.FailedToConsumeApiErr);
    end;

    var
        NoApiKeyFoundErr: Label 'No API Key found for %1 environment. Please setup API Key first.', Comment = '%1 => Production/Sandbox environment';
        ImportEndpointLbl: Label '/projects/%1/invoices/import.json/?send_after_import=true', Comment = '%1 => Project.', Locked = true;
        SpecificInvoiceEndpointLbl: Label '/invoices/%1.json', Comment = '%1 => API file Id.', Locked = true;
        ConvertInvoiceEndpointLbl: Label '/invoices/%1/as/%2', Comment = '%1 => File Id. %2 => Filetype', Locked = true;
        ReceiveInvoicesEndpointLbl: Label '/projects/%1/received.json', Comment = '%1 => Project.', Locked = true;
        SendInvoicesEndpointLbl: Label '/invoices/send_invoice/%1.json', Comment = '%1 => File Id', Locked = true;
        AcknowledgeInvoiceEndpointLbl: Label '/invoices/%1/ack.json', Comment = '%1 => File Id', Locked = true;
        HttpConcentLbl: Label 'data:text/xml;name=%1.XML;base64,%2', Comment = '%1 => file name, %2 => Base64 encoded data', Locked = true;
        FailedToConsumeApiErr: Label 'Failed to consume API.';
        ProdBaseUrlLbl: Label 'https://app.b2brouter.net', Locked = true;
        SandboxBaseUrlLbl: Label 'https://app-staging.b2brouter.net', Locked = true;
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        BaseUrl: Text;
        Project: Text;
        RequestDataInitialized: Boolean;
        ApiKey: SecretText;
}