// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8958 "AFS HttpHeader Helper"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [NonDebuggable]
    procedure GetHttpResponseHeaders(HttpResponseMessage: HttpResponseMessage): Dictionary of [Text, List of [Text]]
    begin
        exit(GetHttpResponseHeaders(HttpResponseMessage.Headers));
    end;

    [NonDebuggable]
    procedure GetHttpResponseHeaders(ResponseHeaders: HttpHeaders): Dictionary of [Text, List of [Text]]
    var
        HeaderKey: Text;
        ResponseHeadersDict: Dictionary of [Text, List of [Text]];
        HeaderValues: List of [Text];
    begin
        foreach HeaderKey in ResponseHeaders.Keys() do
            if not ResponseHeadersDict.ContainsKey(HeaderKey) then begin
                ResponseHeaders.GetValues(HeaderKey, HeaderValues);
                ResponseHeadersDict.Add(HeaderKey, HeaderValues);
            end;
        exit(ResponseHeadersDict);
    end;

    [NonDebuggable]
    procedure GetMetadataHeaders(HttpResponseMessage: HttpResponseMessage): Dictionary of [Text, Text]
    begin
        exit(GetMetadataHeaders(HttpResponseMessage.Headers));
    end;

    [NonDebuggable]
    procedure GetMetadataHeaders(ResponseHeaders: HttpHeaders): Dictionary of [Text, Text]
    var
        HeaderKey: Text;
        TrimmedHeaderKey: Text;
        MetadataHeaders: Dictionary of [Text, Text];
        HeaderValues: List of [Text];
        HeaderValue: Text;
    begin
        foreach HeaderKey in ResponseHeaders.Keys() do
            if HeaderKey.StartsWith('x-ms-meta-') then begin
                TrimmedHeaderKey := HeaderKey.Remove(1, StrLen('x-ms-meta-'));
                if not MetadataHeaders.ContainsKey(TrimmedHeaderKey) then begin
                    Clear(HeaderValues);
                    ResponseHeaders.GetValues(HeaderKey, HeaderValues);
                    if HeaderValues.Count > 0 then begin
                        HeaderValue := HeaderValues.Get(1);
                        MetadataHeaders.Add(TrimmedHeaderKey, HeaderValue);
                    end;
                end;
            end;
        exit(MetadataHeaders);
    end;

    [NonDebuggable]
    procedure HandleRequestHeaders(HttpRequestType: Enum "Http Request Type"; var HttpRequestMessage: HttpRequestMessage; var AFSOperationPayload: Codeunit "AFS Operation Payload")
    var
        AFSFormatHelper: Codeunit "AFS Format Helper";
        UsedDateTimeText: Text;
        Headers: HttpHeaders;
        RequestHeaders: Dictionary of [Text, Text];
        HeaderKey: Text;
    begin
        // Add to the following headers to all requests
        UsedDateTimeText := AFSFormatHelper.GetRfc1123DateTime(CurrentDateTime());
        AFSOperationPayload.AddRequestHeader('Date', UsedDateTimeText);
        AFSOperationPayload.AddRequestHeader('x-ms-version', Format(AFSOperationPayload.GetApiVersion()));

        RequestHeaders := AFSOperationPayload.GetRequestHeaders();
        HttpRequestMessage.GetHeaders(Headers);

        foreach HeaderKey in RequestHeaders.Keys() do begin
            if Headers.Remove(HeaderKey) then;
            Headers.Add(HeaderKey, RequestHeaders.Get(HeaderKey));
        end;
    end;

    [NonDebuggable]
    procedure HandleContentHeaders(var HttpContent: HttpContent; var AFSOperationPayload: Codeunit "AFS Operation Payload"): Boolean
    var
        Headers: HttpHeaders;
        ContentHeaders: Dictionary of [Text, Text];
        HeaderKey: Text;
    begin
        HttpContent.GetHeaders(Headers);

        ContentHeaders := AFSOperationPayload.GetContentHeaders();

        foreach HeaderKey in ContentHeaders.Keys() do begin
            if Headers.Remove(HeaderKey) then;
            Headers.Add(HeaderKey, ContentHeaders.Get(HeaderKey));
        end;
        exit(ContentHeaders.Count > 0);
    end;
}