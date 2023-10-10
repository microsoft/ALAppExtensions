/// <summary>Implementation of the "Http Authentication" interface for a request that requires basic authentication</summary>
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.RestClient;

codeunit 2361 "HttpAuthOAuthClientCredentials" implements "Http Authentication"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        BearerTxt: Label 'Bearer %1', Comment = '%1 - Token', Locked = true;
        ScopesGlobal: List of [Text];
        ClientSecretGlobal: SecretText;
        AuthCodeErrGlobal: Text;
        ClientIdGlobal: Text;
        OAuthAuthorityUrlGlobal: Text;

    /// <summary>
    /// Initializes the authentication object with the given AuthorityUrl, ClientId, ClientSecret and scopes
    /// </summary>
    /// <param name="OAuthAuthorityUrl">The OAuthAuthorityUrl to use for authentication</param>
    /// <param name="ClientId">The ClientId to use for authentication</param>
    /// <param name="ClientSecret">The ClientSecret to use for authentication</param>
    /// <param name="Scopes">The Scopes to use for authentication</param>
    procedure Initialize(OAuthAuthorityUrl: Text; ClientId: Text; ClientSecret: SecretText; Scopes: List of [Text])
    begin
        OAuthAuthorityUrlGlobal := OAuthAuthorityUrl;
        ClientIdGlobal := ClientId;
        ClientSecretGlobal := ClientSecret;
        ScopesGlobal := Scopes;
    end;

    /// <summary>Checks if authentication is required for the request</summary>
    /// <returns>Returns true because authentication is required</returns>
    procedure IsAuthenticationRequired(): Boolean;
    begin
        exit(true);
    end;

    /// <summary>Gets the authorization headers for the request</summary>
    /// <returns>Returns a dictionary of headers that need to be added to the request</returns>
    procedure GetAuthorizationHeaders() Header: Dictionary of [Text, SecretText];
    begin
        Header.Add('Authorization', SecretStrSubstNo(BearerTxt, GetToken()));
    end;

    [NonDebuggable]
    local procedure GetToken(): SecretText
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
        OAuth2: Codeunit System.Security.Authentication.OAuth2;
        IsSuccess: Boolean;
        AquireTokenFailedErr: Label 'Acquire of token with Client Credentials failed.';
    begin
        if (not OAuth2.AcquireAuthorizationCodeTokenFromCache(ClientIdGlobal, ClientSecretGlobal.Unwrap(), '', OAuthAuthorityUrlGlobal, ScopesGlobal, AccessToken)) or (AccessToken = '') then
            OAuth2.AcquireTokenWithClientCredentials(ClientIdGlobal, ClientSecretGlobal.Unwrap(), OAuthAuthorityUrlGlobal, '', ScopesGlobal, AccessToken);

        IsSuccess := AccessToken <> '';

        if AuthCodeErrGlobal <> '' then
            ErrorText := AuthCodeErrGlobal
        else
            ErrorText := GetLastErrorText();

        if not IsSuccess and (ErrorText = '') then
            ErrorText := AquireTokenFailedErr;

        exit(IsSuccess);
    end;
}