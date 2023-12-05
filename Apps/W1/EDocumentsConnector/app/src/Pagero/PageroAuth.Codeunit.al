// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

using System.Security.Authentication;
using System.Reflection;

codeunit 6364 "Pagero Auth."
{
    Access = Internal;

    trigger OnRun()
    begin

    end;

    procedure OpenOAuthSetupPage()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
    begin
        InitOAuthSetup(OAuth20Setup);
        Commit();
        Page.RunModal(Page::"OAuth 2.0 Setup", OAuth20Setup);
    end;

    procedure RefreshAccessToken(var HttpError: Text): Boolean;
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
    begin
        GetOAuth2Setup(OAuth20Setup);
        exit(OAuth20Setup.RefreshAccessToken(HttpError));
    end;

    [NonDebuggable]
    [EventSubscriber(ObjectType::Table, Database::"OAuth 2.0 Setup", 'OnBeforeRequestAccessToken', '', true, true)]
    local procedure OnBeforeRequestAccessToken(var OAuth20Setup: Record "OAuth 2.0 Setup"; AuthorizationCode: Text; var Result: Boolean; var MessageText: Text; var Processed: Boolean)
    var
        PageroSetup: Record "E-Doc. Ext. Connection Setup";
        RequestJSON: Text;
        AccessToken: Text;
        RefreshToken: Text;
        TokenDataScope: DataScope;
    begin
        if not PageroSetup.Get() then
            exit;

        // if Processed then exit;
        Processed := true;

        CheckOAuthConsistencySetup(OAuth20Setup);

        TokenDataScope := OAuth20Setup.GetTokenDataScope();

        Result :=
            OAuth20Mgt.RequestAccessTokenWithContentType(
                OAuth20Setup, RequestJSON, MessageText, AuthorizationCode,
                GetToken(OAuth20Setup."Client ID", DataScope::Company),
                GetToken(OAuth20Setup."Client Secret", DataScope::Company),
                AccessToken, RefreshToken, true);

        if Result then
            SaveTokens(OAuth20Setup, TokenDataScope, AccessToken, RefreshToken);
    end;

    [NonDebuggable]
    [EventSubscriber(ObjectType::Table, Database::"OAuth 2.0 Setup", 'OnBeforeRefreshAccessToken', '', true, true)]
    local procedure OnBeforeRefreshAccessToken(var OAuth20Setup: Record "OAuth 2.0 Setup"; var Result: Boolean; var MessageText: Text; var Processed: Boolean)
    var
        // EDocExtConnectionSetup: Record "E-Doc. Ext. Connection Setup";
        RequestJSON: Text;
        AccessToken: Text;
        RefreshToken: Text;
        TokenDataScope: DataScope;
        OldServiceUrl: Text[250];
    begin
        if not GetOAuth2Setup(OAuth20Setup) or Processed then
            exit;
        Processed := true;

        CheckOAuthConsistencySetup(OAuth20Setup);

        TokenDataScope := OAuth20Setup.GetTokenDataScope();
        RefreshToken := GetToken(OAuth20Setup."Refresh Token", TokenDataScope);
        OldServiceUrl := OAuth20Setup."Service URL";
        // EDocExtConnectionSetup.Get();
        // OAuth20Setup."Service URL" := EDocExtConnectionSetup."Authentication URL";
        Result :=
            OAuth20Mgt.RefreshAccessTokenWithContentType(
                OAuth20Setup, RequestJSON, MessageText,
                GetToken(OAuth20Setup."Client ID", DataScope::Company),
                GetToken(OAuth20Setup."Client Secret", DataScope::Company),
                AccessToken, RefreshToken, true);
        OAuth20Setup."Service URL" := OldServiceUrl;

        if Result then
            SaveTokens(OAuth20Setup, TokenDataScope, AccessToken, RefreshToken);
    end;

    [NonDebuggable]
    [EventSubscriber(ObjectType::Table, Database::"OAuth 2.0 Setup", 'OnBeforeRequestAuthoizationCode', '', true, true)]
    local procedure OnBeforeRequestAuthoizationCode(OAuth20Setup: Record "OAuth 2.0 Setup"; var Processed: Boolean)
    var
        ExternalConnectionSetup: Record "E-Doc. Ext. Connection Setup";

        OAuth2ControlAddIn: Page OAuth2ControlAddIn;
        auth_error: Text;
        AuthorizationCode: Text;
        url: Text;
        state: Text;
    begin
        if not ExternalConnectionSetup.Get() or Processed then
            exit;
        Processed := true;

        CheckOAuthConsistencySetup(OAuth20Setup);
        state := '';
        url :=
           StrSubstNo(CurrUrlWithStateTxt, OAuth20Mgt.GetAuthorizationURL(OAuth20Setup, GetToken(OAuth20Setup."Client ID", DataScope::Company)), state);
        OAuth2ControlAddIn.SetOAuth2Properties(url, state);
        OAuth2ControlAddIn.RunModal();
        auth_error := OAuth2ControlAddIn.GetAuthError();
        if auth_error <> '' then
            Error(auth_error);
        AuthorizationCode := OAuth2ControlAddIn.GetAuthCode();

        if AuthorizationCode <> '' then begin
            OAuth20Setup.Get(OAuth20Setup.Code);
            if not OAuth20Setup.RequestAccessToken(auth_error, AuthorizationCode) then
                Error(auth_error);
        end;
    end;

    [NonDebuggable]
    [EventSubscriber(ObjectType::Table, Database::"OAuth 2.0 Setup", 'OnBeforeInvokeRequest', '', true, true)]
    local procedure OnBeforeInvokeRequest(var OAuth20Setup: Record "OAuth 2.0 Setup"; RequestJSON: Text; var ResponseJSON: Text; var HttpError: Text; var Result: Boolean; var Processed: Boolean; RetryOnCredentialsFailure: Boolean)
    var
        PageroSetup: Record "E-Doc. Ext. Connection Setup";
        TokenValue: Text;
        RequestJsonObj: JsonObject;
        ResponseJsonObj: JsonObject;
    begin
        if not PageroSetup.Get() or Processed then
            exit;
        Processed := true;

        CheckOAuthConsistencySetup(OAuth20Setup);
        TokenValue := GetToken(OAuth20Setup."Access Token", OAuth20Setup.GetTokenDataScope());

        Result :=
            OAuth20Mgt.InvokeRequest(
                OAuth20Setup, RequestJSON, ResponseJSON, HttpError, TokenValue, RetryOnCredentialsFailure);

        if RequestJsonObj.ReadFrom(RequestJSON) then;
        if ResponseJsonObj.ReadFrom(ResponseJSON) then;

    end;

    procedure InitOAuthSetup(var OAuth20Setup: Record "OAuth 2.0 Setup")
    var
        ExternalConnectionSetup: Record "E-Doc. Ext. Connection Setup";
        NewCode: Code[20];
    begin
        ExternalConnectionSetup.Get();
        with OAuth20Setup do begin
            if not OAuth20Setup.FindFirstOAuth20SetupByFeatureAndCurrUser(ExternalConnectionSetup."OAuth Feature GUID") then begin
                SetRange("User ID");
                if FindLast() then
                    NewCode := IncStr(Code)
                else
                    NewCode := 'Pagero';
                Code := NewCode;
                Status := Status::Disabled;
                while not Insert() do
                    Code := IncStr(Code);
            end;
            "Service URL" := ExternalConnectionSetup."Authentication URL";
            Description := 'Pagero Online';
            "Redirect URL" := ExternalConnectionSetup."Redirect URL";
            "Client ID" := ExternalConnectionSetup."Client ID";
            "Client Secret" := ExternalConnectionSetup."Client Secret";
            Scope := 'all';
            "Authorization URL Path" := AuthorizationURLPathTxt;
            "Access Token URL Path" := AccessTokenURLPathTxt;
            "Refresh Token URL Path" := RefreshTokenURLPathTxt;
            "Authorization Response Type" := AuthorizationResponseTypeTxt;
            "Token DataScope" := "Token DataScope"::UserAndCompany;
            "Daily Limit" := 1000;
            "Feature GUID" := ExternalConnectionSetup."OAuth Feature GUID";
            "User ID" := CopyStr(UserId(), 1, MaxStrLen("User ID"));
            Modify();
        end;
    end;

    procedure GetOAuth2Setup(var OAuth20Setup: Record "OAuth 2.0 Setup"): Boolean;
    var
        ExternalConnectionSetup: Record "E-Doc. Ext. Connection Setup";
    begin

        if not ExternalConnectionSetup.Get() then
            exit(false);
        ExternalConnectionSetup.TestField("OAuth Feature GUID");
        if not OAuth20Setup.FindFirstOAuth20SetupByFeatureAndCurrUser(ExternalConnectionSetup."OAuth Feature GUID") then
            InitOAuthSetup(OAuth20Setup);
        exit(true);
    end;

    procedure UpdatePageroOAuthSetupsWithClientIDAndSecret(ClientID: Guid; ClientSecret: Guid; CleintIDText: Text; ClientSecretText: Text)
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        EDocExtConnectionSetup: Record "E-Doc. Ext. Connection Setup";
    begin
        EDocExtConnectionSetup.Get();
        EDocExtConnectionSetup.TestField("OAuth Feature GUID");
        if not OAuth20Setup.FindSetOAuth20SetupByFeature(EDocExtConnectionSetup."OAuth Feature GUID") then
            exit;
        repeat
            OAuth20Setup."Client ID" := ClientID;
            OAuth20Setup."Client Secret" := ClientSecret;
            OAuth20Setup.Modify();
        until OAuth20Setup.Next() = 0;
    end;


    [NonDebuggable]
    local procedure CheckOAuthConsistencySetup(OAuth20Setup: Record "OAuth 2.0 Setup")
    begin
        with OAuth20Setup do begin
            TestField("Authorization URL Path", AuthorizationURLPathTxt);
            TestField("Access Token URL Path", AccessTokenURLPathTxt);
            TestField("Refresh Token URL Path", RefreshTokenURLPathTxt);
            TestField("Authorization Response Type", AuthorizationResponseTypeTxt);
            TestField("Daily Limit");
        end;
    end;

    [NonDebuggable]
    procedure GetAuthBearerTxt(): Text;
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
    begin
        GetOAuth2Setup(OAuth20Setup);
        exit(
            StrSubstNo(BearerTxt, GetToken(OAuth20Setup."Access Token", OAuth20Setup.GetTokenDataScope())));
    end;

    [NonDebuggable]
    local procedure SaveTokens(var OAuth20Setup: Record "OAuth 2.0 Setup"; TokenDataScope: DataScope; AccessToken: Text; RefreshToken: Text)
    var
        TypeHelper: Codeunit "Type Helper";
        NewAccessTokenDateTime: DateTime;
    begin
        SetToken(OAuth20Setup."Access Token", AccessToken, TokenDataScope);
        SetToken(OAuth20Setup."Refresh Token", RefreshToken, TokenDataScope);
        NewAccessTokenDateTime := TypeHelper.AddHoursToDateTime(CurrentDateTime(), 2);
        if OAuth20Setup."Access Token Due DateTime" = 0DT then
            OAuth20Setup."Access Token Due DateTime" := NewAccessTokenDateTime
        else
            if OAuth20Setup."Access Token Due DateTime" < NewAccessTokenDateTime then
                OAuth20Setup."Access Token Due DateTime" := NewAccessTokenDateTime;
        OAuth20Setup.Modify();
        Commit();
    end;

    [NonDebuggable]
    internal procedure SetToken(var TokenKey: Guid; TokenValue: Text; TokenDataScope: DataScope) NewToken: Boolean
    begin
        if IsNullGuid(TokenKey) then
            NewToken := true;
        if NewToken then
            TokenKey := CreateGuid();

        IsolatedStorage.Set(TokenKey, TokenValue, TokenDataScope);
    end;

    [NonDebuggable]
    local procedure GetToken(TokenKey: Guid; TokenDataScope: DataScope) TokenValue: Text
    begin
        if not HasToken(TokenKey, TokenDataScope) then
            exit('');

        IsolatedStorage.Get(TokenKey, TokenDataScope, TokenValue);
    end;

    local procedure HasToken(TokenKey: Guid; TokenDataScope: DataScope): Boolean
    begin
        exit(not IsNullGuid(TokenKey) and IsolatedStorage.Contains(TokenKey, TokenDataScope));
    end;

    var
        OAuth20Mgt: Codeunit "OAuth 2.0 Mgt.";
        AuthorizationURLPathTxt: Label '/authorize', Locked = true;
        AccessTokenURLPathTxt: Label '/token', Locked = true;
        RefreshTokenURLPathTxt: Label '/token', Locked = true;
        AuthorizationResponseTypeTxt: Label 'code', Locked = true;
        CurrUrlWithStateTxt: Label '%1&state=%2', Comment = '%1 = base url, %2 = guid', Locked = true;
        BearerTxt: Label 'Bearer %1', Comment = '%1 = text value', Locked = true;
}