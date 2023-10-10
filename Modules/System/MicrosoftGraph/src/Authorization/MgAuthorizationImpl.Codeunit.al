// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Integration.Microsoft.Graph.Authorization;
codeunit 9356 "Mg Authorization - Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure CreateAuthorizationWithClientCredentials(AadTenantId: Text; ClientId: Text; ClientSecret: SecretText; Scopes: List of [Text]): Interface "Mg Authorization";
    var
        MgAuthClientCredentials: Codeunit "Mg Auth. Client Credentials";
    begin
        MgAuthClientCredentials.SetParameters(AadTenantId, ClientId, ClientSecret, Scopes);
        exit(MgAuthClientCredentials);
    end;
}