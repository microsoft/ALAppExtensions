// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9143 "SharePoint Auth. - Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [NonDebuggable]
    procedure CreateAuthorizationCode(AadTenantId: Text; ClientId: Text; ClientSecret: Text; Scopes: List of [Text]): Interface "SharePoint Authorization";
    var
        SharePointAuthorizationCode: Codeunit "SharePoint Authorization Code";
    begin
        SharePointAuthorizationCode.SetParameters(AadTenantId, ClientId, ClientSecret, Scopes);
        exit(SharePointAuthorizationCode);
    end;
}