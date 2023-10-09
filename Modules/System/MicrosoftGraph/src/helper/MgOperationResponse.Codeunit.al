// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9156 "Mg Operation Response"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        MicrosoftGraphDiagnostics: Codeunit "Microsoft Graph Diagnostics";
        TempBlobContent: Codeunit "Temp Blob";
        HttpHeaders: HttpHeaders;

    [NonDebuggable]
    [TryFunction]
    procedure TryGetResultAsText(var Result: Text);
    var
        ResultInStream: InStream;
    begin
        TempBlobContent.CreateInStream(ResultInStream);
        ResultInStream.ReadText(Result);
    end;

    [NonDebuggable]
    [TryFunction]
    procedure TryGetResultAsStream(var ResultInStream: InStream)
    begin
        TempBlobContent.CreateInStream(ResultInStream);
    end;

    [NonDebuggable]
    procedure SetHttpResponse(HttpResponseMessage: HttpResponseMessage)
    var
        ContentInStream: InStream;
        ContentOutStream: OutStream;
    begin
        Clear(TempBlobContent);
        TempBlobContent.CreateOutStream(ContentOutStream);
        HttpResponseMessage.Content().ReadAs(ContentInStream);
        CopyStream(ContentOutStream, ContentInStream);
        HttpHeaders := HttpResponseMessage.Headers();
        MicrosoftGraphDiagnostics.SetParameters(HttpResponseMessage.IsSuccessStatusCode, HttpResponseMessage.HttpStatusCode, HttpResponseMessage.ReasonPhrase, GetRetryAfterHeaderValue(), GetErrorDescription());
    end;

    [NonDebuggable]
    procedure SetHttpResponse(ResponseContent: Text; ResponseHttpHeaders: HttpHeaders; ResponseHttpStatusCode: Integer; ResponseIsSuccessStatusCode: Boolean; ResponseReasonPhrase: Text)
    var
        ContentOutStream: OutStream;
    begin
        TempBlobContent.CreateOutStream(ContentOutStream);
        ContentOutStream.WriteText(ResponseContent);
        HttpHeaders := ResponseHttpHeaders;
        MicrosoftGraphDiagnostics.SetParameters(ResponseIsSuccessStatusCode, ResponseHttpStatusCode, ResponseReasonPhrase, GetRetryAfterHeaderValue(), GetErrorDescription());
    end;

    [NonDebuggable]
    procedure GetHeaderValueFromResponseHeaders(HeaderName: Text): Text
    var
        Values: array[100] of Text;
    begin
        if not HttpHeaders.GetValues(HeaderName, Values) then
            exit('');
        exit(Values[1]);
    end;

    [NonDebuggable]
    procedure GetRetryAfterHeaderValue() RetryAfter: Integer;
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
        JObject: JsonObject;
        JToken: JsonToken;
        Result: Text;
    begin
        TryGetResultAsText(Result);
        if Result <> '' then
            if JObject.ReadFrom(Result) then
                if JObject.Get('error_description', JToken) then
                    exit(JToken.AsValue().AsText());
    end;

    [NonDebuggable]
    procedure GetDiagnostics(): Interface "HTTP Diagnostics"
    begin
        exit(MicrosoftGraphDiagnostics);
    end;
}
