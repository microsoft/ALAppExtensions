Codeunit 9108 "SharePoint Operation Response"
{
    Access = Internal;

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
    var
        ResultInStream: InStream;
    begin
        TempBlobContent.CreateInStream(ResultInStream);
        ResultInStream.ReadText(Result);
    end;

    [NonDebuggable]
    [TryFunction]
    internal procedure GetResultAsStream(var ResultInStream: InStream)
    begin
        TempBlobContent.CreateInStream(ResultInStream);
    end;

    [NonDebuggable]
    internal procedure SetHttpResponse(HttpResponseMessage: HttpResponseMessage)
    var
        ContentOutStream: OutStream;
        ContentInStream: InStream;
    begin
        TempBlobContent.CreateOutStream(ContentOutStream);
        HttpResponseMessage.Content().ReadAs(ContentInStream);
        CopyStream(ContentOutStream, ContentInStream);
        HttpHeaders := HttpResponseMessage.Headers();
        HttpStatusCode := HttpResponseMessage.HttpStatusCode;
        Success := HttpResponseMessage.IsSuccessStatusCode;
        ReasonPhrase := HttpResponseMessage.ReasonPhrase;
    end;

    [NonDebuggable]
    internal procedure SetHttpResponse(ResponseContent: Text; ResponseHttpHeaders: HttpHeaders; ResponseHttpStatusCode: Integer; IsSuccessStatusCode: Boolean; ResponseReasonPhrase: Text)
    var
        ContentOutStream: OutStream;
    begin
        TempBlobContent.CreateOutStream(ContentOutStream);
        ContentOutStream.WriteText(ResponseContent);
        HttpHeaders := ResponseHttpHeaders;
        HttpStatusCode := ResponseHttpStatusCode;
        Success := IsSuccessStatusCode;
        ReasonPhrase := ResponseReasonPhrase;
    end;

    [NonDebuggable]
    internal procedure GetHeaderValueFromResponseHeaders(HeaderName: Text): Text
    var
        Values: array[100] of Text;
    begin
        if not HttpHeaders.GetValues(HeaderName, Values) then
            exit('');
        exit(Values[1]);
    end;

    [NonDebuggable]
    internal procedure GetIsSuccessStatusCode(): Boolean
    begin
        exit(Success);
    end;

    [NonDebuggable]
    internal procedure GetHttpStatusCode(): Integer
    begin
        exit(HttpStatusCode);
    end;

    var
        TempBlobContent: Codeunit "Temp Blob";
        ResponseError, ReasonPhrase : Text;
        HttpHeaders: HttpHeaders;
        HttpStatusCode: Integer;
        Success: Boolean;

}
