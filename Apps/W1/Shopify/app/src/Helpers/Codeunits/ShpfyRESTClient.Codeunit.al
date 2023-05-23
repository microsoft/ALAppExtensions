/// <summary>
/// Codeunit Shpfy REST Client (ID 30159).
/// </summary>
codeunit 30159 "Shpfy REST Client"
{
    Access = Internal;
    SingleInstance = true;
    ObsoleteTag = '21.4';
    ObsoleteState = Pending;
    ObsoleteReason = 'Is not used';

    var
        LastResponseHeaders: HttpHeaders;
        BaseUrl: Text;
        HttpClient: HttpClient;

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
    /// Create Http Request Message.
    /// </summary>
    /// <param name="Url">Parameter of type text.</param>
    /// <param name="Method">Parameter of type Text.</param>
    /// <param name="RequestString">Parameter of type Text.</param>
    /// <param name="HttpRequestMessage">Parameter of type HttpRequestMessage.</param>
    /// <param name="HeaderValues">Parameter of type Dictionary of [Text, Text].</param>
    local procedure CreateHttpRequestMessage(Url: text; Method: Text; RequestString: Text; var HttpRequestMessage: HttpRequestMessage; HeaderValues: Dictionary of [Text, Text]);
    var
        HttpContent: HttpContent;
        Headers: HttpHeaders;
        HeaderKey: Text;
        HeaderValue: Text;
    begin
        if not url.StartsWith(BaseUrl) then
            Url := BaseUrl + Url;
        HttpRequestMessage.SetRequestUri(Url);
        HttpRequestMessage.Method := Method;
        HttpRequestMessage.GetHeaders(Headers);
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
            HttpContent.WriteFrom(RequestString);
            HttpContent.GetHeaders(Headers);
            if Headers.Contains('Content-Type') then
                Headers.Remove('Content-Type');
            Headers.Add('Content-Type', 'application/json');
            HttpRequestMessage.Content(HttpContent);
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
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
    begin
        CreateHttpRequestMessage(Url, Method, Request, HttpRequestMessage, HeaderValues);

        if HttpClient.send(HttpRequestMessage, HttpResponseMessage) then begin
            HttpResponseMessage.Content.ReadAs(Response);
            LastResponseHeaders := HttpResponseMessage.Headers;
        end;
    end;
}