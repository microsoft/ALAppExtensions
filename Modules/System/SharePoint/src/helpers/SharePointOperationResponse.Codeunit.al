// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9108 "SharePoint Operation Response"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

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
        SharepointDiagnostics.SetParameters(HttpResponseMessage.IsSuccessStatusCode, HttpResponseMessage.HttpStatusCode, HttpResponseMessage.ReasonPhrase, GetRetryAfterHeaderValue(), GetErrorDescription());
    end;

    [NonDebuggable]
    internal procedure SetHttpResponse(ResponseContent: Text; ResponseHttpHeaders: HttpHeaders; ResponseHttpStatusCode: Integer; ResponseIsSuccessStatusCode: Boolean; ResponseReasonPhrase: Text)
    var
        ContentOutStream: OutStream;
    begin
        TempBlobContent.CreateOutStream(ContentOutStream);
        ContentOutStream.WriteText(ResponseContent);
        HttpHeaders := ResponseHttpHeaders;
        SharepointDiagnostics.SetParameters(ResponseIsSuccessStatusCode, ResponseHttpStatusCode, ResponseReasonPhrase, GetRetryAfterHeaderValue(), GetErrorDescription());
    end;

    [NonDebuggable]
    internal procedure GetHeaderValueFromResponseHeaders(HeaderName: Text): Text
    var
        Values: array[100] of Text;
    begin
        if not HttpHeaders.Contains(HeaderName) then
            exit('');
        if not HttpHeaders.GetValues(HeaderName, Values) then
            exit('');
        exit(Values[1]);
    end;

    [NonDebuggable]
    internal procedure GetRetryAfterHeaderValue() RetryAfter: Integer;
    var
        HeaderValue: Text;
    begin
        HeaderValue := GetHeaderValueFromResponseHeaders('Retry-After');
        if HeaderValue = '' then
            exit(0);
        if not Evaluate(RetryAfter, HeaderValue) then
            exit(0);
    end;

    [NonDebuggable]
    local procedure GetErrorDescription(): Text
    var
        Result: Text;
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        GetResultAsText(Result);
        if Result <> '' then
            if JObject.ReadFrom(Result) then
                if JObject.Get('error_description', JToken) then
                    exit(JToken.AsValue().AsText());
    end;

    [NonDebuggable]
    internal procedure GetDiagnostics(): Interface "HTTP Diagnostics"
    begin
        exit(SharepointDiagnostics);
    end;

    var
        TempBlobContent: Codeunit "Temp Blob";
        SharepointDiagnostics: Codeunit "SharePoint Diagnostics";
        HttpHeaders: HttpHeaders;
}