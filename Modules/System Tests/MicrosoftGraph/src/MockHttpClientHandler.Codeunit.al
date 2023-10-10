// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Test.Integration.Microsoft.Graph;

using System.RestClient;

codeunit 135142 "Mock Http Client Handler" implements "Http Client Handler"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        _httpRequestMessage: codeunit System.RestClient."Http Request Message";
        _httpResponseMessage: codeunit System.RestClient."Http Response Message";
        _responseMessageSet: Boolean;
        _sendError: Text;


    procedure Send(HttpClient: HttpClient; HttpRequestMessage: codeunit System.RestClient."Http Request Message"; var HttpResponseMessage: codeunit System.RestClient."Http Response Message") Success: Boolean;
    begin

        ClearLastError();
        exit(TrySend(HttpRequestMessage, HttpResponseMessage));
    end;

    procedure ExpectSendToFailWithError(SendError: Text)
    begin
        _sendError := SendError;
    end;

    procedure SetResponse(var NewHttpResponseMessage: codeunit System.RestClient."Http Response Message")
    begin
        _httpResponseMessage := NewHttpResponseMessage;
        _responseMessageSet := true;
    end;

    procedure GetHttpRequestMessage(var OutHttpRequestMessage: codeunit System.RestClient."Http Request Message")
    begin
        OutHttpRequestMessage := _httpRequestMessage;
    end;

    [TryFunction]
    local procedure TrySend(HttpRequestMessage: codeunit System.RestClient."Http Request Message"; var HttpResponseMessage: codeunit System.RestClient."Http Response Message")
    begin
        _httpRequestMessage := HttpRequestMessage;
        if _sendError <> '' then
            Error(_sendError);

        if _responseMessageSet then
            HttpResponseMessage := _httpResponseMessage;
    end;
}