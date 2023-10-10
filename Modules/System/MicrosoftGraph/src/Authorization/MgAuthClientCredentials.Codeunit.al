// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Integration.Microsoft.Graph.Authorization;
using System.RestClient;

codeunit 9357 "Mg Auth. Client Credentials" implements "Mg Authorization"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        ClientCredentialsTokenAuthorityUrlTxt: Label 'https://login.microsoftonline.com/%1/oauth2/v2.0/token', Comment = '%1 = AAD tenant ID', Locked = true;
        [NonDebuggable]
        Scopes: List of [Text];
        [NonDebuggable]
        ClientSecret: SecretText;
        [NonDebuggable]
        AadTenantId: Text;
        [NonDebuggable]
        [NonDebuggable]
        ClientId: Text;

    [NonDebuggable]
    procedure SetParameters(NewAadTenantId: Text; NewClientId: Text; NewClientSecret: SecretText; NewScopes: List of [Text])
    begin
        AadTenantId := NewAadTenantId;
        ClientId := NewClientId;
        ClientSecret := NewClientSecret;
        Scopes := NewScopes;
    end;

    procedure GetHttpAuthorization(): Interface "Http Authentication"
    var
        HttpAuthOAuthClientCredentials: Codeunit HttpAuthOAuthClientCredentials;
        OAuthAuthorityUrl: Text;
    begin
        OAuthAuthorityUrl := StrSubstNo(ClientCredentialsTokenAuthorityUrlTxt, AadTenantId);
        HttpAuthOAuthClientCredentials.Initialize(OAuthAuthorityUrl, ClientId, ClientSecret, Scopes);
        exit(HttpAuthOAuthClientCredentials);
    end;

}