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