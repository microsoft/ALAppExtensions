/// <summary>
/// Codeunit Shpfy REST Client (ID 30159).
/// </summary>
codeunit 30159 "Shpfy REST Client"
{
    SingleInstance = true;

    var
        LastResponseHeaders: HttpHeaders;
        LastResultStatusCode: Integer;
        BaseUrl: Text;
        Client: HttpClient;

    /// <summary> 
    /// Delete.
    /// </summary>
    /// <param name="Url">Parameter of type Text.</param>
    /// <returns>Return value of type JsonToken.</returns>
    internal procedure Delete(Url: Text): JsonToken
    var
        JRequest: JsonToken;
    begin
        exit(ExecuteWebRequest(Url, 'DELETE', JRequest));
    end;

    /// <summary> 
    /// Delete.
    /// </summary>
    /// <param name="Url">Parameter of type Text.</param>
    /// <param name="JRequest">Parameter of type JsonToken.</param>
    /// <returns>Return value of type JsonToken.</returns>
    internal procedure Delete(Url: Text; JRequest: JsonToken): JsonToken
    begin
        exit(ExecuteWebRequest(Url, 'DELETE', JRequest));
    end;

    /// <summary> 
    /// Delete.
    /// </summary>
    /// <param name="Url">Parameter of type Text.</param>
    /// <param name="HeaderValues">Parameter of type Dictionary of [Text, Text].</param>
    /// <returns>Return value of type JsonToken.</returns>
    internal procedure Delete(Url: Text; HeaderValues: Dictionary of [Text, Text]): JsonToken
    var
        JRequest: JsonToken;
    begin
        ExecuteWebRequest(Url, 'DELETE', JRequest, HeaderValues);
    end;

    /// <summary> 
    /// Delete.
    /// </summary>
    /// <param name="Url">Parameter of type Text.</param>
    /// <param name="JRequest">Parameter of type JsonToken.</param>
    /// <param name="HeaderValues">Parameter of type Dictionary of [Text, Text].</param>
    /// <returns>Return value of type JsonToken.</returns>
    internal procedure Delete(Url: Text; JRequest: JsonToken; HeaderValues: Dictionary of [Text, Text]): JsonToken
    begin
        exit(ExecuteWebRequest(Url, 'DELETE', JRequest, HeaderValues));
    end;

    /// <summary> 
    /// Execute Web Request.
    /// </summary>
    /// <param name="Url">Parameter of type Text.</param>
    /// <param name="Method">Parameter of type Text.</param>
    /// <param name="JRequest">Parameter of type JsonToken.</param>
    /// <returns>Return value of type JsonToken.</returns>
    internal procedure ExecuteWebRequest(Url: Text; Method: Text; JRequest: JsonToken): JsonToken
    var
        HeaderValues: Dictionary of [Text, Text];
    begin
        exit(ExecuteWebRequest(Url, Method, JRequest, HeaderValues));
    end;

    /// <summary> 
    /// Execute Web Request.
    /// </summary>
    /// <param name="Url">Parameter of type Text.</param>
    /// <param name="Method">Parameter of type Text.</param>
    /// <param name="JRequest">Parameter of type JsonToken.</param>
    /// <param name="HeaderValues">Parameter of type Dictionary of [Text, Text].</param>
    /// <returns>Return value of type JsonToken.</returns>
    internal procedure ExecuteWebRequest(Url: Text; Method: Text; JRequest: JsonToken; HeaderValues: Dictionary of [Text, Text]): JsonToken
    var
        JResponse: JsonToken;
        Request: Text;
    begin

        JRequest.WriteTo(Request);
        if Request = 'null' then
            Request := '';
        Clear(JResponse);
        if JResponse.ReadFrom(ExecuteWebRequest(Url, Method, Request, HeaderValues)) then
            exit(JResponse);
    end;

    /// <summary> 
    /// Get.
    /// </summary>
    /// <param name="Url">Parameter of type Text.</param>
    /// <returns>Return value of type JsonToken.</returns>
    internal procedure Get(Url: Text): JsonToken
    var
        JRequest: JsonToken;
    begin
        exit(ExecuteWebRequest(Url, 'GET', JRequest));
    end;

    /// <summary> 
    /// Get.
    /// </summary>
    /// <param name="Url">Parameter of type Text.</param>
    /// <param name="HeaderValues">Parameter of type Dictionary of [Text, Text].</param>
    /// <returns>Return value of type JsonToken.</returns>
    internal procedure Get(Url: Text; HeaderValues: Dictionary of [Text, Text]): JsonToken
    var
        JRequest: JsonToken;
    begin
        exit(ExecuteWebRequest(Url, 'GET', JRequest, HeaderValues));
    end;

    /// <summary> 
    /// Get Base Url.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetBaseUrl(): Text
    begin
        exit(BaseUrl);
    end;

    /// <summary> 
    /// Get Last Response Headers.
    /// </summary>
    /// <param name="ResponseResult">Parameter of type HttpHeaders.</param>
    internal procedure GetLastResponseHeaders(var ResponseResult: HttpHeaders)
    begin
        ResponseResult := LastResponseHeaders;
    end;

    /// <summary> 
    /// Get Last Result Status Code.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetLastResultStatusCode(): Integer
    begin
        exit(LastResultStatusCode);
    end;

    /// <summary> 
    /// Patch.
    /// </summary>
    /// <param name="Url">Parameter of type Text.</param>
    /// <returns>Return value of type JsonToken.</returns>
    internal procedure Patch(Url: Text): JsonToken
    var
        JRequest: JsonToken;
    begin
        exit(ExecuteWebRequest(Url, 'PATCH', JRequest));
    end;

    /// <summary> 
    /// Patch.
    /// </summary>
    /// <param name="Url">Parameter of type Text.</param>
    /// <param name="JRequest">Parameter of type JsonToken.</param>
    /// <returns>Return value of type JsonToken.</returns>
    internal procedure Patch(Url: Text; JRequest: JsonToken): JsonToken
    begin
        exit(ExecuteWebRequest(Url, 'PATCH', JRequest));
    end;

    /// <summary> 
    /// Patch.
    /// </summary>
    /// <param name="Url">Parameter of type Text.</param>
    /// <param name="HeaderValues">Parameter of type Dictionary of [Text, Text].</param>
    /// <returns>Return value of type JsonToken.</returns>
    internal procedure Patch(Url: Text; HeaderValues: Dictionary of [Text, Text]): JsonToken
    var
        JRequest: JsonToken;
    begin
        exit(ExecuteWebRequest(Url, 'PATCH', JRequest, HeaderValues));
    end;

    /// <summary> 
    /// Patch.
    /// </summary>
    /// <param name="Url">Parameter of type Text.</param>
    /// <param name="JRequest">Parameter of type JsonToken.</param>
    /// <param name="HeaderValues">Parameter of type Dictionary of [Text, Text].</param>
    /// <returns>Return value of type JsonToken.</returns>
    internal procedure Patch(Url: Text; JRequest: JsonToken; HeaderValues: Dictionary of [Text, Text]): JsonToken
    begin
        exit(ExecuteWebRequest(Url, 'PATCH', JRequest, HeaderValues));
    end;

    /// <summary> 
    /// Post.
    /// </summary>
    /// <param name="Url">Parameter of type Text.</param>
    /// <returns>Return value of type JsonToken.</returns>
    internal procedure Post(Url: Text): JsonToken
    var
        JRequest: JsonToken;
    begin
        exit(ExecuteWebRequest(Url, 'POST', JRequest));
    end;

    /// <summary> 
    /// Post.
    /// </summary>
    /// <param name="Url">Parameter of type Text.</param>
    /// <param name="JRequest">Parameter of type JsonToken.</param>
    /// <returns>Return value of type JsonToken.</returns>
    internal procedure Post(Url: Text; JRequest: JsonToken): JsonToken
    begin
        exit(ExecuteWebRequest(Url, 'POST', JRequest));
    end;

    /// <summary> 
    /// Post.
    /// </summary>
    /// <param name="Url">Parameter of type Text.</param>
    /// <param name="HeaderValues">Parameter of type Dictionary of [Text, Text].</param>
    /// <returns>Return value of type JsonToken.</returns>
    internal procedure Post(Url: Text; HeaderValues: Dictionary of [Text, Text]): JsonToken
    var
        JRequest: JsonToken;
    begin
        exit(ExecuteWebRequest(Url, 'POST', JRequest, HeaderValues));
    end;

    /// <summary> 
    /// Post.
    /// </summary>
    /// <param name="Url">Parameter of type Text.</param>
    /// <param name="JRequest">Parameter of type JsonToken.</param>
    /// <param name="HeaderValues">Parameter of type Dictionary of [Text, Text].</param>
    /// <returns>Return value of type JsonToken.</returns>
    internal procedure Post(Url: Text; JRequest: JsonToken; HeaderValues: Dictionary of [Text, Text]): JsonToken
    begin
        exit(ExecuteWebRequest(Url, 'POST', JRequest, HeaderValues));
    end;

    /// <summary> 
    /// Put.
    /// </summary>
    /// <param name="Url">Parameter of type Text.</param>
    /// <returns>Return value of type JsonToken.</returns>
    internal procedure Put(Url: Text): JsonToken
    var
        JRequest: JsonToken;
    begin
        exit(ExecuteWebRequest(Url, 'PUT', JRequest));
    end;

    /// <summary> 
    /// Put.
    /// </summary>
    /// <param name="Url">Parameter of type Text.</param>
    /// <param name="JRequest">Parameter of type JsonToken.</param>
    /// <returns>Return value of type JsonToken.</returns>
    internal procedure Put(Url: Text; JRequest: JsonToken): JsonToken
    begin
        exit(ExecuteWebRequest(Url, 'PUT', JRequest));
    end;

    /// <summary> 
    /// Put.
    /// </summary>
    /// <param name="Url">Parameter of type Text.</param>
    /// <param name="HeaderValues">Parameter of type Dictionary of [Text, Text].</param>
    /// <returns>Return value of type JsonToken.</returns>
    internal procedure Put(Url: Text; HeaderValues: Dictionary of [Text, Text]): JsonToken
    var
        JRequest: JsonToken;
    begin
        exit(ExecuteWebRequest(Url, 'PUT', JRequest, HeaderValues));
    end;

    /// <summary> 
    /// Put.
    /// </summary>
    /// <param name="Url">Parameter of type Text.</param>
    /// <param name="JRequest">Parameter of type JsonToken.</param>
    /// <param name="HeaderValues">Parameter of type Dictionary of [Text, Text].</param>
    /// <returns>Return value of type JsonToken.</returns>
    internal procedure Put(Url: Text; JRequest: JsonToken; HeaderValues: Dictionary of [Text, Text]): JsonToken
    begin
        exit(ExecuteWebRequest(Url, 'PUT', JRequest, HeaderValues));
    end;

    /// <summary> 
    /// Reset Last Result.
    /// </summary>
    internal procedure ResetLastResult()
    begin
        Clear(LastResultStatusCode);
        Clear(LastResponseHeaders);
    end;

    /// <summary> 
    /// Set Base Url.
    /// </summary>
    /// <param name="Url">Parameter of type Text.</param>
    internal procedure SetBaseUrl(Url: Text)
    begin
        BaseUrl := Url;
    end;

    /// <summary> 
    /// Create Http Request Message.
    /// </summary>
    /// <param name="Url">Parameter of type text.</param>
    /// <param name="Method">Parameter of type Text.</param>
    /// <param name="RequestString">Parameter of type Text.</param>
    /// <param name="RequestMessage">Parameter of type HttpRequestMessage.</param>
    /// <param name="HeaderValues">Parameter of type Dictionary of [Text, Text].</param>
    local procedure CreateHttpRequestMessage(Url: text; Method: Text; RequestString: Text; var RequestMessage: HttpRequestMessage; HeaderValues: Dictionary of [Text, Text]);
    var
        Content: HttpContent;
        Headers: HttpHeaders;
        HeaderKey: Text;
        HeaderValue: Text;
    begin
        if not url.StartsWith(BaseUrl) then
            Url := BaseUrl + Url;
        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method := Method;
        RequestMessage.GetHeaders(Headers);
        if Headers.Contains('Accept') then
            Headers.Remove('Accept');
        Headers.Add('Accept', 'application/json');

        foreach HeaderKey in HeaderValues.Keys() do begin
            if Headers.Contains(HeaderKey) then
                Headers.Remove(HeaderKey);
            if HeaderValues.Get(HeaderKey, HeaderValue) then
                Headers.Add(HeaderKey, HeaderValue);
        end;

        if Method <> 'GET' then begin
            Content.WriteFrom(RequestString);
            Content.GetHeaders(Headers);
            if Headers.Contains('Content-Type') then
                Headers.Remove('Content-Type');
            Headers.Add('Content-Type', 'application/json');
            RequestMessage.Content(Content);
        end;
    end;

    /// <summary> 
    /// Execute Web Request.
    /// </summary>
    /// <param name="Url">Parameter of type Text.</param>
    /// <param name="Method">Parameter of type Text.</param>
    /// <param name="Request">Parameter of type Text.</param>
    /// <param name="HeaderValues">Parameter of type Dictionary of [Text, Text].</param>
    /// <returns>Return variable "Response" of type Text.</returns>
    local procedure ExecuteWebRequest(Url: Text; Method: Text; Request: Text; HeaderValues: Dictionary of [Text, Text]) Response: Text
    var
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
    begin
        CreateHttpRequestMessage(Url, Method, Request, RequestMessage, HeaderValues);

        if Client.send(RequestMessage, ResponseMessage) then begin
            ResponseMessage.Content.ReadAs(Response);
            LastResultStatusCode := ResponseMessage.HttpStatusCode;
            LastResponseHeaders := ResponseMessage.Headers;
        end;
    end;
}