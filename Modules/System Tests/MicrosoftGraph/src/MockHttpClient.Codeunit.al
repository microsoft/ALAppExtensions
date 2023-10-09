codeunit 135142 "Mock HttpClient" implements IHttpClient
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        _responseMessageSet: Boolean;
        _httpRequestMessage: HttpRequestMessage;
        _httpResponseMessage: Interface IHttpResponseMessage;
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

    procedure Send(RequestMessage: HttpRequestMessage; var ResponseMessage: Interface IHttpResponseMessage): Boolean;
    var
        HttpResponse: Codeunit "Dummy - HttpResponseMessage";
    begin
        ClearLastError();
        ResponseMessage := HttpResponse;
        exit(TrySend(RequestMessage, ResponseMessage));
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
}