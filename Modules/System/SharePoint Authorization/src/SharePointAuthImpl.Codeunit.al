// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9143 "SharePoint Auth. - Impl."
{
    Access = Internal;

    [NonDebuggable]
    procedure CreateUserCredentials(AadTenantId: Text; ClientId: Text; Login: Text; Password: Text; Scopes: List of [Text]): Interface "SharePoint Authorization";
    var
        SharePointUserCredentials: Codeunit "SharePoint User Credentials";
    begin
        SharePointUserCredentials.SetParameters(AadTenantId, ClientId, Login, Password, Scopes);
        exit(SharePointUserCredentials);
    end;

    [NonDebuggable]
    procedure CreateAuthorizationCode(AadTenantId: Text; ClientId: Text; ClientSecret: Text; Scopes: List of [Text]): Interface "SharePoint Authorization";
    var
        SharePointAuthorizationCode: Codeunit "SharePoint Authorization Code";
    begin
        SharePointAuthorizationCode.SetParameters(AadTenantId, ClientId, ClientSecret, Scopes);
        exit(SharePointAuthorizationCode);
    end;
}