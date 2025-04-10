// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.EServices.EDocumentConnector.Logiq;

codeunit 6430 "Logiq Auth"
{
    Access = Internal;
    Permissions =
        tabledata "Logiq Connection Setup" = r,
        tabledata "Logiq Connection User Setup" = rm;

    procedure SetIsolatedStorageValue(var ValueKey: Guid; Value: SecretText; TokenDataScope: DataScope)
    begin
        if IsNullGuid(ValueKey) then
            ValueKey := CreateGuid();

        IsolatedStorage.Set(ValueKey, Value, TokenDataScope);
    end;

    procedure GetIsolatedStorageValue(var ValueKey: Guid; var Value: SecretText; TokenDataScope: DataScope)
    begin
        if IsNullGuid(ValueKey) then
            exit;
        IsolatedStorage.Get(ValueKey, TokenDataScope, Value);
    end;

    [NonDebuggable]
    procedure GetTokens()
    var
        LogiqConnectionSetup: Record "Logiq Connection Setup";
        LogiqConnectionUserSetup: Record "Logiq Connection User Setup";
        Client: HttpClient;
        Headers: HttpHeaders;
        Content: HttpContent;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        AccessToken, RefreshToken : SecretText;
        AccessTokExpires, RefreshTokExpires : DateTime;
    begin
        this.CheckSetup(LogiqConnectionSetup);
        this.CheckUserCredentials(LogiqConnectionUserSetup);

        RequestMessage.Method('POST');
        RequestMessage.SetRequestUri(LogiqConnectionSetup."Authentication URL");

        this.BuildTokenRequestBody(Content);

        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/x-www-form-urlencoded');

        RequestMessage.Content(Content);

        Client.Send(RequestMessage, ResponseMessage);

        if not ResponseMessage.IsSuccessStatusCode() then begin
            if GuiAllowed then
                Message(this.AuthenticationFailedErr);
            exit;
        end;

        this.ParseTokens(ResponseMessage, AccessToken, RefreshToken, AccessTokExpires, RefreshTokExpires);
        this.SaveTokens(AccessToken, RefreshToken, AccessTokExpires, RefreshTokExpires);
    end;

    local procedure BuildTokenRequestBody(var Content: HttpContent)
    var
        LogiqConnectionSetup: Record "Logiq Connection Setup";
        LogiqConnectionUserSetup: Record "Logiq Connection User Setup";
        BodyText, ClientSecret : SecretText;
    begin
        LogiqConnectionSetup.Get();
        LogiqConnectionUserSetup.Get(UserId());

        IsolatedStorage.Get(GetConnectionSetupClientSecretKey(), DataScope::Company, ClientSecret);
        if (not IsNullGuid(LogiqConnectionUserSetup."Refresh Token - Key")) and (LogiqConnectionUserSetup."Refresh Token Expiration" > (CurrentDateTime + 60 * 1000)) then
            BodyText := SecretStrSubstNo(this.RefreshTokenBodyTok, LogiqConnectionSetup."Client ID", ClientSecret, GetRefreshToken(LogiqConnectionUserSetup))
        else
            BodyText := SecretStrSubstNo(this.CredentialsBodyTok, LogiqConnectionSetup."Client ID", ClientSecret, LogiqConnectionUserSetup.Username, GetPassword(LogiqConnectionUserSetup));

        Content.WriteFrom(BodyText);
    end;

    procedure CheckUserCredentials(var LogiqConnectionUserSetup: Record "Logiq Connection User Setup")
    begin
        if not LogiqConnectionUserSetup.Get(UserId()) then
            Error(this.NoUserSetupErr);

        if (LogiqConnectionUserSetup.Username = '') or (IsNullGuid(LogiqConnectionUserSetup."Password - Key")) then
            Error(this.MissingCredentialsErr);
    end;

    procedure CheckUserSetup(var LogiqConnectionUserSetup: Record "Logiq Connection User Setup")
    begin
        this.CheckUserCredentials(LogiqConnectionUserSetup);

        if (LogiqConnectionUserSetup."API Engine" = LogiqConnectionUserSetup."API Engine"::" ") then
            Error(this.MissingAPIEngineErr);

        if (LogiqConnectionUserSetup."Document Transfer Endpoint" = '') or (LogiqConnectionUserSetup."Document Status Endpoint" = '') then
            Error(this.MissingEndpointsErr);
    end;

    procedure CheckSetup(var LogiqConnectionSetup: Record "Logiq Connection Setup")
    var
        ClientSecret: SecretText;
    begin
        if not LogiqConnectionSetup.Get() then
            Error(this.NoSetupErr);

        IsolatedStorage.Get(GetConnectionSetupClientSecretKey(), DataScope::Company, ClientSecret);
        if (LogiqConnectionSetup."Client ID" = '') or (ClientSecret.IsEmpty()) then
            Error(this.MissingClientInfoErr);

        if LogiqConnectionSetup."Authentication URL" = '' then
            Error(this.MissingAuthUrlErr);

        if LogiqConnectionSetup."Base URL" = '' then
            Error(this.MissingBaseUrlErr);
    end;

    [NonDebuggable]
    local procedure ParseTokens(ResponseMessage: HttpResponseMessage; var AccessToken: SecretText; var RefreshToken: SecretText; var AccessTokExpires: DateTime; var RefreshTokExpires: DateTime)
    var
        ContentJson: JsonObject;
        JsonTok: JsonToken;
        ResponseTxt: Text;
    begin
        ResponseMessage.Content.ReadAs(ResponseTxt);
        ContentJson.ReadFrom(ResponseTxt);
        if ContentJson.Get('access_token', JsonTok) then
            AccessToken := JsonTok.AsValue().AsText();
        if ContentJson.Get('refresh_token', JsonTok) then
            RefreshToken := JsonTok.AsValue().AsText();
        if ContentJson.Get('expires_in', JsonTok) then
            AccessTokExpires := CurrentDateTime + JsonTok.AsValue().AsInteger() * 1000;
        if ContentJson.Get('refresh_expires_in', JsonTok) then
            RefreshTokExpires := CurrentDateTime + JsonTok.AsValue().AsInteger() * 1000;
    end;

    local procedure SaveTokens(AccessToken: SecretText; RefreshToken: SecretText; AccessTokExpires: DateTime; RefreshTokExpires: DateTime)
    var
        LogiqConnectionUserSetup: Record "Logiq Connection User Setup";
    begin
        LogiqConnectionUserSetup.Get(UserId());
        this.SetIsolatedStorageValue(LogiqConnectionUserSetup."Access Token - Key", AccessToken, DataScope::User);
        this.SetIsolatedStorageValue(LogiqConnectionUserSetup."Refresh Token - Key", RefreshToken, DataScope::User);
        LogiqConnectionUserSetup."Access Token Expiration" := AccessTokExpires;
        LogiqConnectionUserSetup."Refresh Token Expiration" := RefreshTokExpires;
        LogiqConnectionUserSetup.Modify(false);
    end;

    procedure GetConnectionSetupClientSecretKey(): Guid
    begin
        exit(IsolatedStorageConnSetupClientSecretTok);
    end;

    procedure HasToken(ValueKey: Guid; DataScope: DataScope): Boolean
    begin
        exit(IsolatedStorage.Contains(ValueKey, DataScope));
    end;

    procedure CheckUpdateTokens()
    var
        LogiqConnectionUserSetup: Record "Logiq Connection User Setup";
    begin
        if not LogiqConnectionUserSetup.Get(UserId()) then
            Error(this.NoUserSetupErr);
        if IsNullGuid(LogiqConnectionUserSetup."Access Token - Key") or (LogiqConnectionUserSetup."Access Token Expiration" < (CurrentDateTime + 5 * 60 * 1000)) then
            this.GetTokens();
    end;

    procedure GetPassword(var LogiqConnectionUserSetup: Record "Logiq Connection User Setup"): SecretText
    var
        ClientSecret: SecretText;
    begin
        this.GetIsolatedStorageValue(LogiqConnectionUserSetup."Password - Key", ClientSecret, DataScope::User);
        exit(ClientSecret);
    end;

    procedure GetAccessToken(var LogiqConnectionUserSetup: Record "Logiq Connection User Setup"): SecretText
    var
        AccessToken: SecretText;
    begin
        this.GetIsolatedStorageValue(LogiqConnectionUserSetup."Access Token - Key", AccessToken, DataScope::User);
        exit(AccessToken);
    end;

    procedure GetRefreshToken(var LogiqConnectionUserSetup: Record "Logiq Connection User Setup"): SecretText
    var
        RefreshToken: SecretText;
    begin
        this.GetIsolatedStorageValue(LogiqConnectionUserSetup."Refresh Token - Key", RefreshToken, DataScope::User);
        exit(RefreshToken);
    end;

    procedure DeleteUserTokens(var LogiqConnectionUserSetup: Record "Logiq Connection User Setup")
    begin
        if (not IsNullGuid(LogiqConnectionUserSetup."Access Token - Key")) then
            if IsolatedStorage.Contains(LogiqConnectionUserSetup."Access Token - Key", DataScope::User) then
                IsolatedStorage.Delete(LogiqConnectionUserSetup."Access Token - Key", DataScope::User);
        if (not IsNullGuid(LogiqConnectionUserSetup."Refresh Token - Key")) then
            if IsolatedStorage.Contains(LogiqConnectionUserSetup."Refresh Token - Key", DataScope::User) then
                IsolatedStorage.Delete(LogiqConnectionUserSetup."Refresh Token - Key", DataScope::User);
        LogiqConnectionUserSetup."Access Token Expiration" := 0DT;
        LogiqConnectionUserSetup."Refresh Token Expiration" := 0DT;
        LogiqConnectionUserSetup.Modify();
    end;

    procedure DeletePassword(var LogiqConnectionUserSetup: Record "Logiq Connection User Setup")
    begin
        if (not IsNullGuid(LogiqConnectionUserSetup."Password - Key")) then
            if IsolatedStorage.Contains(LogiqConnectionUserSetup."Password - Key", DataScope::User) then
                IsolatedStorage.Delete(LogiqConnectionUserSetup."Password - Key", DataScope::User);
    end;



    var
        AuthenticationFailedErr: Label 'Logiq authentication failed. Please check the user credentials.';
        CredentialsBodyTok: Label 'grant_type=password&scope=openid&client_id=%1&client_secret=%2&username=%3&password=%4', Locked = true;
        MissingAPIEngineErr: Label 'API Engine is missing. Please select the API Engine in the Logiq Connection User Setup page.';
        MissingAuthUrlErr: Label 'Authentication URL is missing. Please fill the Authentication URL in the Logiq Connection Setup page.';
        MissingBaseUrlErr: Label 'Base URL is missing. Please fill the API Base URL in the Logiq Connection Setup page.';
        MissingClientInfoErr: Label 'Client ID or Client Secret is missing. Please fill the Client ID and Client Secret in the Logiq Connection Setup page.';
        MissingCredentialsErr: Label 'User credentials are missing. Please enter username and password in the Logiq Connection User Setup page.';
        MissingEndpointsErr: Label 'Endpoints are missing. Please fill the Document Transfer Endpoint and Document Status Endpoint in the Logiq Connection User Setup page.';
        NoSetupErr: Label 'No setup found. Please fill the setup in the Logiq Connection Setup page.';
        NoUserSetupErr: Label 'No user setup found. Please fill the user setup in the Logiq Connection User Setup page.';
        RefreshTokenBodyTok: Label 'grant_type=refresh_token&client_id=%1&client_secret=%2&refresh_token=%3', Locked = true;
        IsolatedStorageConnSetupClientSecretTok: Label '41ef583e-1774-4103-97c6-c6c93e5902f5', Locked = true;

}
