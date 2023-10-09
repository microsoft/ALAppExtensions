// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9132 "MgGraph Client Credentials" implements "Microsoft Graph Authorization"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        BearerTxt: Label 'Bearer %1', Comment = '%1 - Token', Locked = true;
        ClientCredentialsTokenAuthorityUrlTxt: Label 'https://login.microsoftonline.com/%1/oauth2/v2.0/token', Comment = '%1 = AAD tenant ID', Locked = true;
        [NonDebuggable]
        Scopes: List of [Text];
        [NonDebuggable]
        AadTenantId: Text;
        [NonDebuggable]
        AuthCodeErr: Text;
        [NonDebuggable]
        ClientId: Text;
        [NonDebuggable]
        ClientSecret: Text;

    [NonDebuggable]
    procedure SetParameters(NewAadTenantId: Text; NewClientId: Text; NewClientSecret: Text; NewScopes: List of [Text])
    begin
        AadTenantId := NewAadTenantId;
        ClientId := NewClientId;
        ClientSecret := NewClientSecret;
        Scopes := NewScopes;
    end;

    [NonDebuggable]
    procedure Authorize(var HttpRequestMessage: HttpRequestMessage);
    var
        Headers: HttpHeaders;
    begin
        HttpRequestMessage.GetHeaders(Headers);
        Headers.Add('Authorization', StrSubstNo(BearerTxt, GetToken()));
    end;

    [NonDebuggable]
    local procedure GetToken(): Text
    var
        AccessToken: Text;
        ErrorText: Text;
    begin
        if not AcquireToken(AccessToken, ErrorText) then
            Error(ErrorText);
        exit(AccessToken);
    end;

    [NonDebuggable]
    local procedure AcquireToken(var AccessToken: Text; var ErrorText: Text): Boolean
    var
        OAuth2: Codeunit OAuth2;
        IsSuccess: Boolean;
        OAuthAuthorityUrl: Text;
        AquireTokenFailedErr: Label 'Acquire of token with Client Credentials failed.';
    begin
        OAuthAuthorityUrl := StrSubstNo(ClientCredentialsTokenAuthorityUrlTxt, AadTenantId);
        if (not OAuth2.AcquireAuthorizationCodeTokenFromCache(ClientId, ClientSecret, '', OAuthAuthorityUrl, Scopes, AccessToken)) or (AccessToken = '') then
            OAuth2.AcquireTokenWithClientCredentials(ClientId, ClientSecret, OAuthAuthorityUrl, '', Scopes, AccessToken);

        IsSuccess := AccessToken <> '';

        if AuthCodeErr <> '' then
            ErrorText := AuthCodeErr
        else
            ErrorText := GetLastErrorText();

        if not IsSuccess and (ErrorText = '') then
            ErrorText := AquireTokenFailedErr;

        exit(IsSuccess);
    end;
}