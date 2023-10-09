// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9131 "Microsoft Graph Auth. - Impl."
{
    Access = Internal;

    [NonDebuggable]
    procedure CreateAuthorizationWithClientCredentials(AadTenantId: Text; ClientId: Text; ClientSecret: Text; Scopes: List of [Text]): Interface "Microsoft Graph Authorization";
    var
        MgGraphClientCredentials: Codeunit "MgGraph Client Credentials";
    begin
        MgGraphClientCredentials.SetParameters(AadTenantId, ClientId, ClientSecret, Scopes);
        exit(MgGraphClientCredentials);
    end;
}