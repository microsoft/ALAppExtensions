// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9048 "ABS HttpHeader Helper"
{
    Access = Internal;

    [NonDebuggable]
    procedure HandleRequestHeaders(HttpRequestType: Enum "Http Request Type"; var Request: HttpRequestMessage; var OperationPayload: Codeunit "ABS Operation Payload")
    var
        FormatHelper: Codeunit "ABS Format Helper";
        UsedDateTimeText: Text;
        Headers: HttpHeaders;
        RequestHeaders: Dictionary of [Text, Text];
        HeaderKey: Text;
    begin
        // Add to the following headers to all requests
        UsedDateTimeText := FormatHelper.GetRfc1123DateTime(CurrentDateTime());
        OperationPayload.AddRequestHeader('x-ms-date', UsedDateTimeText);
        OperationPayload.AddRequestHeader('x-ms-version', Format(OperationPayload.GetApiVersion()));

        RequestHeaders := OperationPayload.GetRequestHeaders();
        Request.GetHeaders(Headers);

        foreach HeaderKey in RequestHeaders.Keys() do begin
            if Headers.Remove(HeaderKey) then;
            Headers.Add(HeaderKey, RequestHeaders.Get(HeaderKey));
        end;
    end;

    [NonDebuggable]
    procedure HandleContentHeaders(var Content: HttpContent; var OperationPayload: Codeunit "ABS Operation Payload"): Boolean
    var
        Headers: HttpHeaders;
        ContentHeaders: Dictionary of [Text, Text];
        HeaderKey: Text;
    begin
        Content.GetHeaders(Headers);

        ContentHeaders := OperationPayload.GetContentHeaders();

        foreach HeaderKey in ContentHeaders.Keys() do begin
            if Headers.Remove(HeaderKey) then;
            Headers.Add(HeaderKey, ContentHeaders.Get(HeaderKey));
        end;
    end;
}