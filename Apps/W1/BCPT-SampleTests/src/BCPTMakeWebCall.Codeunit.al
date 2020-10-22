// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 149108 "BCPT Make Web Call"
{
    SingleInstance = true;

    trigger OnRun();
    var
        NewUrl: text;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Client: HttpClient;
    begin
        NewUrl := 'https://wwww.microsoft.com';

        RequestMessage.SetRequestUri(NewUrl);
        RequestMessage.Method('GET');

        Client.Send(RequestMessage, ResponseMessage);
    end;
}