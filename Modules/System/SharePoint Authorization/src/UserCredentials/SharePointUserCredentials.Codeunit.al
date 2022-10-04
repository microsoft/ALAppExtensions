// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9141 "SharePoint User Credentials" implements "SharePoint Authorization"
{
    Access = Internal;

    var
        [NonDebuggable]
        ClientId: Text;
        [NonDebuggable]
        AadTenantId: Text;
        [NonDebuggable]
        Login: Text;
        [NonDebuggable]
        Password: Text;
        [NonDebuggable]
        AccessToken: Text;
        [NonDebuggable]
        IdToken: Text;
        [NonDebuggable]
        ExpiryDate: DateTime;
        [NonDebuggable]
        Scopes: List of [Text];
        AuthorityTxt: Label 'https://login.microsoftonline.com/{AadTenantId}/oauth2/v2.0/token', Locked = true;
        BearerTxt: Label 'Bearer %1', Locked = true;

    [NonDebuggable]
    procedure SetParameters(NewAadTenantId: Text; NewClientId: Text; NewLogin: Text; NewPassword: Text; NewScopes: List of [Text])
    begin
        NewAadTenantId := AadTenantId;
        ClientId := NewClientId;
        Login := NewLogin;
        Password := NewPassword;
        Scopes := NewScopes;
        AccessToken := '';
        ExpiryDate := 0DT;
    end;

    [NonDebuggable]
    procedure Authorize(var HttpRequestMessage: HttpRequestMessage)
    var
        Headers: HttpHeaders;
    begin
        HttpRequestMessage.GetHeaders(Headers);
        Headers.Add('Authorization', GetAuthenticationHeaderValue(GetToken()));
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
            IsSuccess := OAuth2.AcquireTokensWithUserCredentials(GetAuthorityUrl(AadTenantId), ClientId, Scopes, Login, Password, AccessToken, IdToken);
            if not IsSuccess then
                ErrorText := OAuth2.GetLastErrorMessage();
        end;

        exit(IsSuccess);
    end;

    local procedure GetAuthorityUrl(AadTenantId: Text) Url: Text
    begin
        Url := AuthorityTxt;
        Url := Url.Replace('{AadTenantId}', AadTenantId);
    end;

    [NonDebuggable]
    local procedure GetAuthenticationHeaderValue(AccessToken: Text) Value: Text;
    begin
        Value := StrSubstNo(BearerTxt, AccessToken);
    end;

    [InternalEvent(false, true)]
    local procedure OnBeforeGetToken(var IsHandled: Boolean; var IsSuccess: Boolean; var ErrorText: Text; var AccessToken: Text)
    begin
    end;

}