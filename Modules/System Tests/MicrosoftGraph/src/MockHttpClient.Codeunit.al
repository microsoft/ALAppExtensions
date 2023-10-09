codeunit 135142 "Mock HttpClient" implements IHttpClient
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        _responseMessageSet: Boolean;
        _httpRequestMessage: HttpRequestMessage;
        _httpResponseMessage: Interface IHttpResponseMessage;
        NotImplementedErr: Label 'Not implemented for mocking.';
        _sendError: Text;

    procedure ExpectSendToFailWithError(SendError: Text)
    begin
        _sendError := SendError;
    end;

    procedure SetResponse(NewHttpResponseMessage: Interface IHttpResponseMessage)
    begin
        _httpResponseMessage := NewHttpResponseMessage;
        _responseMessageSet := true;
    end;

    procedure GetHttpRequestMessage(var OutHttpRequestMessage: HttpRequestMessage)
    begin
        OutHttpRequestMessage := _httpRequestMessage;
    end;

    procedure Send(HttpRequestMessage: HttpRequestMessage; var IHttpResponseMessage: Interface IHttpResponseMessage): Boolean;
    var
        DummyHttpResponseMessage: Codeunit "Dummy - HttpResponseMessage";
    begin
        ClearLastError();
        IHttpResponseMessage := DummyHttpResponseMessage;
        exit(TrySend(HttpRequestMessage, IHttpResponseMessage));
    end;

    [TryFunction]
    local procedure TrySend(HttpRequestMessage: HttpRequestMessage; var ResponseMessage: Interface IHttpResponseMessage)
    begin
        _httpRequestMessage := HttpRequestMessage;
        if _sendError <> '' then
            Error(_sendError);

        if _responseMessageSet then
            ResponseMessage := _httpResponseMessage;
    end;


    procedure AddCertificate(Certificate: Text)
    begin
        Error(NotImplementedErr);
    end;

    procedure AddCertificate(Certificate: Text; Password: Text)
    begin
        Error(NotImplementedErr);
    end;

    procedure GetBaseAddress(): Text
    begin
        Error(NotImplementedErr);
    end;

    procedure DefaultRequestHeaders(): HttpHeaders
    begin
        Error(NotImplementedErr);
    end;

    procedure Clear()
    begin
        ClearAll();
    end;
}