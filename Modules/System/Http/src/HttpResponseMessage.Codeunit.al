// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 9161 HttpResponseMessage implements IHttpResponseMessage
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        HttpResponseMessageGlobal: HttpResponseMessage;

    procedure Initialize(NewHttpResponseMessage: HttpResponseMessage)
    begin
        HttpResponseMessageGlobal := NewHttpResponseMessage;
    end;

    procedure IsBlockedByEnvironment(): Boolean;
    begin
        exit(HttpResponseMessageGlobal.IsBlockedByEnvironment());
    end;

    procedure IsSuccessStatusCode(): Boolean;
    begin
        exit(HttpResponseMessageGlobal.IsSuccessStatusCode());
    end;

    procedure HttpStatusCode(): Integer;
    begin
        exit(HttpResponseMessageGlobal.HttpStatusCode());
    end;

    procedure ReasonPhrase(): Text;
    begin
        exit(HttpResponseMessageGlobal.ReasonPhrase());
    end;

    procedure Content(): HttpContent;
    begin
        exit(HttpResponseMessageGlobal.Content());
    end;

    procedure Headers(): HttpHeaders;
    begin
        exit(HttpResponseMessageGlobal.Headers());
    end;
}