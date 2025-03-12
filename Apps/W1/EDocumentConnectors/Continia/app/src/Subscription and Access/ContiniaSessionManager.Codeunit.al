// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

codeunit 6396 "Continia Session Manager"
{
    Access = Internal;
    SingleInstance = true;

    var
        ClientCredentialLoaded: Boolean;
        IsAccessTokenLoaded: Boolean;
        AccessTokenRequested: DateTime;
        AccessTokenExpiresInMs: Integer;
        NextAccessTokenUpdateInMs: Integer;
        CachedAccessToken: SecretText;
        ClientIdentifier: SecretText;

    internal procedure ClearAccessToken()
    var
        ConnectionSetup: Record "Continia Connection Setup";
    begin
        Clear(CachedAccessToken);
        AccessTokenRequested := 0DT;
        IsAccessTokenLoaded := false;
        if CurrentClientType <> ClientType::ChildSession then
            ConnectionSetup.ClearToken();
    end;

    internal procedure RefreshClientIdentifier()
    begin
        ClientCredentialLoaded := false;
        GetClientIdentifier();
    end;

    internal procedure GetClientIdentifier(): SecretText
    var
        ConnectionSetup: Record "Continia Connection Setup";
    begin
        if ClientCredentialLoaded then
            exit(ClientIdentifier);

        Clear(ClientIdentifier);
        if ConnectionSetup.Get() then
            ClientIdentifier := ConnectionSetup.GetClientId();

        ClientCredentialLoaded := true;
        exit(ClientIdentifier);
    end;

    [NonDebuggable]
    internal procedure GetAccessToken() AccessTokenValue: SecretText
    var
        ConnectionSetup: Record "Continia Connection Setup";
    begin
        // Get token from Cache if possible
        if IsAccessTokenLoaded then
            if AccessTokenRequested > CreateDateTime(Today, Time) - NextAccessTokenUpdateInMs then
                exit(CachedAccessToken);

        if ConnectionSetup.AcquireTokenFromCache(CachedAccessToken, AccessTokenRequested, AccessTokenExpiresInMs, NextAccessTokenUpdateInMs, true) then begin
            IsAccessTokenLoaded := true;
            exit(CachedAccessToken);
        end;
        // Not found in cache - make new request to Online
        if AcquireToken(false) then
            exit(CachedAccessToken);

        // Fallback code Allow the access token to live for 23 hours
        if ConnectionSetup.AcquireTokenFromCache(CachedAccessToken, AccessTokenRequested, AccessTokenExpiresInMs, NextAccessTokenUpdateInMs, false) then begin
            IsAccessTokenLoaded := true;
            exit(CachedAccessToken);
        end else
            if AcquireToken(true) then
                exit(CachedAccessToken);
    end;

    local procedure AcquireToken(ShowError: Boolean): Boolean
    var
        ConnectionSetup: Record "Continia Connection Setup";
        ActivationMgt: Codeunit "Continia Subscription Mgt.";
        ExpiresIn: Integer;
        AccessTokenValue: Text;
    begin
        ClearLastError();
        if not ActivationMgt.TryAcquireClientToken(AccessTokenValue, ExpiresIn) then
            if ShowError then
                Error(GetLastErrorText())
            else
                exit(false);

        if ShouldSaveToken() then
            ConnectionSetup.SetAccessToken(AccessTokenValue, ExpiresIn);

        Clear(CachedAccessToken);
        AccessTokenRequested := 0DT;

        // Add to cache
        CachedAccessToken := AccessTokenValue;
        AccessTokenExpiresInMs := ExpiresIn;
        if ShouldSaveToken() then
            AccessTokenRequested := ConnectionSetup."Token Timestamp"
        else
            AccessTokenRequested := CurrentDateTime;

        IsAccessTokenLoaded := true;
        exit(true);
    end;

    local procedure ShouldSaveToken(): Boolean
    begin
        if CurrentClientType = ClientType::ChildSession then
            exit(false);

        if GetCurrentModuleExecutionContext() <> ExecutionContext::Normal then
            exit(false);

        exit(true);
    end;
}