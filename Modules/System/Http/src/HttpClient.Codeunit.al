// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 9160 HttpClient implements IHttpClient
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [TryFunction]
    local procedure TrySend(RequestMessage: HttpRequestMessage; var ResponseMessage: Interface IHttpResponseMessage);
    var
        HttpResponseMessage: Codeunit HttpResponseMessage;
        Client: HttpClient;
        HttpResponse: HttpResponseMessage;
    begin
        Client.Send(RequestMessage, HttpResponse);
        HttpResponseMessage.Initialize(HttpResponse);
        ResponseMessage := HttpResponseMessage;
    end;

    procedure Send(RequestMessage: HttpRequestMessage; var ResponseMessage: Interface IHttpResponseMessage) Result: Boolean;
    var
        HttpResponse: Codeunit HttpResponseMessage;
    begin
        ClearLastError();
        ResponseMessage := HttpResponse;
        exit(TrySend(RequestMessage, ResponseMessage));
    end;
}