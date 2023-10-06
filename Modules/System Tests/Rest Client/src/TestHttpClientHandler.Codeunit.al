// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.RestClient;

using System.RestClient;

codeunit 134974 "Test Http Client Handler" implements "Http Client Handler"
{
    SingleInstance = true;

    procedure Send(HttpClient: HttpClient; HttpRequestMessage: codeunit "Http Request Message"; var HttpResponseMessage: codeunit "Http Response Message") Success: Boolean;
    var
        ResponseMessage: HttpResponseMessage;
    begin
        Success := HttpClient.Send(HttpRequestMessage.GetHttpRequestMessage(), ResponseMessage);
        HttpResponseMessage.SetResponseMessage(ResponseMessage);
    end;
}