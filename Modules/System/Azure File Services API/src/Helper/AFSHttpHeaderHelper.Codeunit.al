codeunit 50113 "AFS HttpHeader Helper"
{
    Access = Internal;

    // [NonDebuggable]
    procedure HandleRequestHeaders(HttpRequestType: Enum "Http Request Type"; var HttpRequestMessage: HttpRequestMessage; var ABSOperationPayload: Codeunit "AFS Operation Payload")
    var
        AFSFormatHelper: Codeunit "AFS Format Helper";
        UsedDateTimeText: Text;
        Headers: HttpHeaders;
        RequestHeaders: Dictionary of [Text, Text];
        HeaderKey: Text;
    begin
        // Add to the following headers to all requests
        UsedDateTimeText := AFSFormatHelper.GetRfc1123DateTime(CurrentDateTime());
        ABSOperationPayload.AddRequestHeader('Date', UsedDateTimeText);
        ABSOperationPayload.AddRequestHeader('x-ms-version', Format(ABSOperationPayload.GetApiVersion()));

        RequestHeaders := ABSOperationPayload.GetRequestHeaders();
        HttpRequestMessage.GetHeaders(Headers);

        foreach HeaderKey in RequestHeaders.Keys() do begin
            if Headers.Remove(HeaderKey) then;
            Headers.Add(HeaderKey, RequestHeaders.Get(HeaderKey));
        end;
    end;

    // [NonDebuggable]
    procedure HandleContentHeaders(var HttpContent: HttpContent; var ABSOperationPayload: Codeunit "AFS Operation Payload"): Boolean
    var
        Headers: HttpHeaders;
        ContentHeaders: Dictionary of [Text, Text];
        HeaderKey: Text;
    begin
        HttpContent.GetHeaders(Headers);

        ContentHeaders := ABSOperationPayload.GetContentHeaders();

        foreach HeaderKey in ContentHeaders.Keys() do begin
            if Headers.Remove(HeaderKey) then;
            Headers.Add(HeaderKey, ContentHeaders.Get(HeaderKey));
        end;
        exit(ContentHeaders.Count > 0);
    end;
}