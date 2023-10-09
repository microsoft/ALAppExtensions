// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 9160 HttpClient implements IHttpClient
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var

        _httpClient: HttpClient;

    procedure Send(HttpRequestMessage: HttpRequestMessage; var IHttpResponseMessage: Interface IHttpResponseMessage) Result: Boolean;
    var
        HttpResponseMessageWrapper: Codeunit HttpResponseMessage;
        HttpResponseMessage: HttpResponseMessage;
    begin
        ClearLastError();
        Result := _httpClient.Send(HttpRequestMessage, HttpResponseMessage);
        HttpResponseMessageWrapper.Initialize(HttpResponseMessage);
        IHttpResponseMessage := HttpResponseMessageWrapper;
    end;

    procedure AddCertificate(Certificate: Text)
    begin
        _httpClient.AddCertificate(Certificate);
    end;

    procedure AddCertificate(Certificate: Text; Password: Text)
    begin
        _httpClient.AddCertificate(Certificate, Password);
    end;

    procedure GetBaseAddress(): Text
    begin
        exit(_httpClient.GetBaseAddress());
    end;

    procedure DefaultRequestHeaders(): HttpHeaders
    begin
        exit(_httpClient.DefaultRequestHeaders());
    end;

    procedure Clear()
    begin
        _httpClient.Clear();
    end;
}