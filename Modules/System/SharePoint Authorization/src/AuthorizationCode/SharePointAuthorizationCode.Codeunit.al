// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9144 "SharePoint Authorization Code" implements "SharePoint Authorization"
{
    Access = Internal;

    var
        [NonDebuggable]
        ClientId: Text;
        [NonDebuggable]
        ClientSecret: Text;
        [NonDebuggable]
        AccessToken: Text;
        [NonDebuggable]
        AuthCodeErr: Text;
        [NonDebuggable]
        AadTenantId: Text;
        [NonDebuggable]
        Scopes: List of [Text];
        [NonDebuggable]
        ExpiryDate: DateTime;
        AuthorityTxt: Label 'https://login.microsoftonline.com/%1/oauth2/v2.0/authorize', Comment = '%1 = AAD tenant ID', Locked = true;
        BearerTxt: Label 'Bearer %1', Comment = '%1 - Token', Locked = true;

    [NonDebuggable]
    procedure SetParameters(NewAadTenantId: Text; NewClientId: Text; NewClientSecret: Text; NewScopes: List of [Text])
    begin
        AadTenantId := NewAadTenantId;
        ClientId := NewClientId;
        ClientSecret := NewClientSecret;
        Scopes := NewScopes;
        AccessToken := '';
        ExpiryDate := 0DT;
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
        ErrorText: Text;
    begin
        if (AccessToken = '') or (AccessToken <> '') and (ExpiryDate > CurrentDateTime()) then
            if not AcquireToken(ErrorText) then
                Error(ErrorText)
            else
                ExpiryDate := CurrentDateTime() + (3599 * 1000);
        exit(AccessToken);
    end;

    [NonDebuggable]
    local procedure AcquireToken(var ErrorText: Text): Boolean
    var
        OAuth2: Codeunit OAuth2;
        IsHandled, IsSuccess : Boolean;
    begin
        OnBeforeGetToken(IsHandled, IsSuccess, ErrorText, AccessToken);

        if not IsHandled then begin
            OAuth2.AcquireTokenByAuthorizationCode(ClientId, ClientSecret, StrSubstNo(AuthorityTxt, AadTenantId), '', Scopes, "Prompt Interaction"::Login, AccessToken, AuthCodeErr);

            if not IsSuccess then
                if AuthCodeErr <> '' then
                    ErrorText := AuthCodeErr
                else
                    ErrorText := GetLastErrorText();
        end;

        exit(IsSuccess);
    end;

    [InternalEvent(false, true)]
    local procedure OnBeforeGetToken(var IsHandled: Boolean; var IsSuccess: Boolean; var ErrorText: Text; var AccessToken: Text)
    begin
    end;
}