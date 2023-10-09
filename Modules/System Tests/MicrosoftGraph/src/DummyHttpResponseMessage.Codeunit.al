// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135144 "Dummy - HttpResponseMessage" implements IHttpResponseMessage
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure IsBlockedByEnvironment(): Boolean;
    begin
    end;

    procedure IsSuccessStatusCode(): Boolean;
    begin
    end;

    procedure HttpStatusCode(): Integer;
    begin
    end;

    procedure ReasonPhrase(): Text;
    begin
    end;

    procedure Content(): HttpContent;
    begin
    end;

    procedure Headers(): HttpHeaders;
    begin
    end;
}