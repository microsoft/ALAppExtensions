Codeunit 9108 "SharePoint Operation Response"
{
    Access = Internal;

    procedure IsSuccessful(): Boolean
    begin
        exit(HttpResponseMessage.IsSuccessStatusCode);
    end;

    procedure GetError(): Text
    begin
        exit(ResponseError);
    end;

    internal procedure SetError(Error: Text)
    begin
        ResponseError := Error;
    end;

    [NonDebuggable]
    [TryFunction]
    internal procedure GetResultAsText(var Result: Text);
    begin
        HttpResponseMessage.Content.ReadAs(Result);
    end;

    [NonDebuggable]
    [TryFunction]
    internal procedure GetResultAsStream(var ResultInStream: InStream)
    begin
        HttpResponseMessage.Content.ReadAs(ResultInStream);
    end;

    [NonDebuggable]
    internal procedure SetHttpResponse(NewHttpResponseMessage: HttpResponseMessage)
    begin
        HttpResponseMessage := NewHttpResponseMessage;
    end;

    [NonDebuggable]
    internal procedure GetHeaderValueFromResponseHeaders(HeaderName: Text): Text
    var
        Headers: HttpHeaders;
        Values: array[100] of Text;
    begin
        Headers := HttpResponseMessage.Headers;
        if not Headers.GetValues(HeaderName, Values) then
            exit('');
        exit(Values[1]);
    end;

    var
        [NonDebuggable]
        HttpResponseMessage: HttpResponseMessage;
        ResponseError: Text;
}
