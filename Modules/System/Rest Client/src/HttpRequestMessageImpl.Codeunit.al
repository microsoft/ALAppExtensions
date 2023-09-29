// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.RestClient;

codeunit 2353 "Http Request Message Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        HttpRequestMessage: HttpRequestMessage;

    procedure SetHttpMethod(Method: Text)
    begin
        HttpRequestMessage.Method := Method;
    end;

    procedure SetHttpMethod(Method: Enum "Http Method")
    begin
        SetHttpMethod(Method.Names.Get(Method.Ordinals.IndexOf(Method.AsInteger())));
    end;

    procedure GetHttpMethod() ReturnValue: Text
    begin
        ReturnValue := HttpRequestMessage.Method;
    end;

    procedure SetRequestUri(Uri: Text)
    begin
        HttpRequestMessage.SetRequestUri(Uri);
    end;

    procedure GetRequestUri() Uri: Text
    begin
        Uri := HttpRequestMessage.GetRequestUri();
    end;

    procedure SetHeader(HeaderName: Text; HeaderValue: Text)
    var
        HttpHeaders: HttpHeaders;
    begin
        HttpRequestMessage.GetHeaders(HttpHeaders);
        if HttpHeaders.Contains(HeaderName) then
            HttpHeaders.Remove(HeaderName);
        HttpHeaders.Add(HeaderName, HeaderValue);
    end;

    procedure SetHeader(HeaderName: Text; HeaderValue: SecretText)
    var
        HttpHeaders: HttpHeaders;
    begin
        HttpRequestMessage.GetHeaders(HttpHeaders);
        if HttpHeaders.Contains(HeaderName) then
            HttpHeaders.Remove(HeaderName);
        HttpHeaders.Add(HeaderName, HeaderValue);
    end;

    procedure SetHttpRequestMessage(var RequestMessage: HttpRequestMessage)
    begin
        HttpRequestMessage := RequestMessage;
    end;

    procedure SetContent(HttpContent: Codeunit "Http Content")
    begin
        HttpRequestMessage.Content := HttpContent.GetHttpContent();
    end;

    procedure GetRequestMessage() ReturnValue: HttpRequestMessage
    begin
        ReturnValue := HttpRequestMessage;
    end;
}