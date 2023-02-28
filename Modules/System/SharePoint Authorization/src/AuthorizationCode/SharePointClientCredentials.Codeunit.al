// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9145 "SharePoint Client Credentials" implements "SharePoint Authorization"
{
    Access = Internal;

    var
        [NonDebuggable]
        ClientId: Text;
        [NonDebuggable]
        Certificate: Text;
        [NonDebuggable]
        AuthCodeErr: Text;
        [NonDebuggable]
        AadTenantId: Text;
        [NonDebuggable]
        Scopes: List of [Text];
        AuthorityTxt: Label 'https://login.microsoftonline.com/%1/oauth2/v2.0/authorize', Comment = '%1 = AAD tenant ID', Locked = true;
        BearerTxt: Label 'Bearer %1', Comment = '%1 - Token', Locked = true;

    [NonDebuggable]
    procedure SetParameters(NewAadTenantId: Text; NewClientId: Text; NewCertificate: Text; NewScopes: List of [Text])
    begin
        AadTenantId := NewAadTenantId;
        ClientId := NewClientId;
        Certificate := NewCertificate;
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
        ErrorText: Text;
        [NonDebuggable]
        AccessToken: Text;
    begin
        if not AcquireToken(AccessToken, ErrorText) then
            Error(ErrorText);
        exit(AccessToken);
    end;

    [NonDebuggable]
    local procedure AcquireToken(var AccessToken: Text; var ErrorText: Text): Boolean
    var
        OAuth2: Codeunit OAuth2;
        FailedErr: Label 'Failed to retrieve an access token.';
        IsHandled, IsSuccess : Boolean;
        IdToken: Text;
    begin
        OnBeforeGetToken(IsHandled, IsSuccess, ErrorText, AccessToken);
        ClearLastError();

        if not IsHandled then begin
            if (not OAuth2.AcquireTokensFromCacheWithCertificate(ClientId, Certificate, '', StrSubstNo(AuthorityTxt, AadTenantId), Scopes, AccessToken, IdToken)) or (AccessToken = '') then
                OAuth2.AcquireTokensWithCertificate(ClientId, Certificate, '', StrSubstNo(AuthorityTxt, AadTenantId), Scopes, AccessToken, IdToken);

            IsSuccess := AccessToken <> '';

            if not IsSuccess then begin
                ErrorText := GetLastErrorText();
                if ErrorText = '' then
                    ErrorText := FailedErr;
            end;
        end;

        exit(IsSuccess);
    end;

    [InternalEvent(false, true)]
    local procedure OnBeforeGetToken(var IsHandled: Boolean; var IsSuccess: Boolean; var ErrorText: Text; var AccessToken: Text)
    begin
    end;
}