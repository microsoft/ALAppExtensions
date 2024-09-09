namespace Microsoft.EServices.EDocumentConnector.Logiq;

codeunit 6380 "Logiq Auth"
{
    internal procedure SetIsolatedStorageValue(var ValueKey: Guid; Value: SecretText; TokenDataScope: DataScope)
    begin
        if IsNullGuid(ValueKey) then
            ValueKey := CreateGuid();

        IsolatedStorage.Set(ValueKey, Value, TokenDataScope);
    end;

    internal procedure SetIsolatedStorageValue(var ValueKey: Guid; Value: SecretText)
    begin
        SetIsolatedStorageValue(ValueKey, Value, DataScope::Company);
    end;

    internal procedure GetIsolatedStorageValue(var ValueKey: Guid; var Value: SecretText; TokenDataScope: DataScope)
    begin
        if IsNullGuid(ValueKey) then
            exit;
        IsolatedStorage.Get(ValueKey, TokenDataScope, Value);
    end;

    internal procedure GetIsolatedStorageValue(var ValueKey: Guid; var Value: SecretText)
    begin
        GetIsolatedStorageValue(ValueKey, Value, DataScope::Company);
    end;

    [NonDebuggable]
    internal procedure GetTokens()
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
        AuthenticationFailedErr: Label 'Logiq authentication failed. Please check the user credentials.';
    begin
        CheckSetup(LogiqConnectionSetup);
        CheckUserCredentials(LogiqConnectionUserSetup);

        RequestMessage.Method('POST');
        RequestMessage.SetRequestUri(LogiqConnectionSetup."Authentication URL");

        BuildTokenRequestBody(Content);

        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/x-www-form-urlencoded');

        RequestMessage.Content(Content);

        Client.Send(RequestMessage, ResponseMessage);

        if not ResponseMessage.IsSuccessStatusCode() then begin
            if GuiAllowed then
                Message(AuthenticationFailedErr);
            exit;
        end;

        ParseTokens(ResponseMessage, AccessToken, RefreshToken, AccessTokExpires, RefreshTokExpires);

        SaveTokens(AccessToken, RefreshToken, AccessTokExpires, RefreshTokExpires);
    end;

    local procedure BuildTokenRequestBody(var Content: HttpContent)
    var
        LogiqConnectionSetup: Record "Logiq Connection Setup";
        LogiqConnectionUserSetup: Record "Logiq Connection User Setup";
        BodyText: SecretText;
        CredentialsBodyTok: Label 'grant_type=password&scope=openid&client_id=%1&client_secret=%2&username=%3&password=%4', Locked = true;
        RefreshTokenBodyTok: Label 'grant_type=refresh_token&client_id=%1&client_secret=%2&refresh_token=%3', Locked = true;
    begin
        LogiqConnectionSetup.Get();
        LogiqConnectionUserSetup.Get(UserId());

        if (not IsNullGuid(LogiqConnectionUserSetup."Refresh Token")) and (LogiqConnectionUserSetup."Refresh Token Expiration" > (CurrentDateTime + 60 * 1000)) then
            BodyText := SecretText.SecretStrSubstNo(RefreshTokenBodyTok, LogiqConnectionSetup."Client ID", LogiqConnectionSetup.GetClientSecret(), LogiqConnectionUserSetup.GetRefreshToken())
        else
            BodyText := SecretText.SecretStrSubstNo(CredentialsBodyTok, LogiqConnectionSetup."Client ID", LogiqConnectionSetup.GetClientSecret(), LogiqConnectionUserSetup.Username, LogiqConnectionUserSetup.GetPassword());

        Content.WriteFrom(BodyText);
    end;

    internal procedure CheckUserCredentials(var LogiqConnectionUserSetup: Record "Logiq Connection User Setup")
    var
        NoSetupErr: Label 'No user setup found. Please fill the user setup in the Logiq Connection User Setup page.';
        MissingCredentialsErr: Label 'User credentials are missing. Please enter username and password in the Logiq Connection User Setup page.';
    begin
        if not LogiqConnectionUserSetup.Get(UserId()) then
            Error(NoSetupErr);

        if (LogiqConnectionUserSetup.Username = '') or (IsNullGuid(LogiqConnectionUserSetup."Password")) then
            Error(MissingCredentialsErr);
    end;

    internal procedure CheckUserSetup(var LogiqConnectionUserSetup: Record "Logiq Connection User Setup")
    var
        MissingAPIEngineErr: Label 'API Engine is missing. Please select the API Engine in the Logiq Connection User Setup page.';
        MissingEndpointsErr: Label 'Endpoints are missing. Please fill the Document Transfer Endpoint and Document Status Endpoint in the Logiq Connection User Setup page.';
    begin
        CheckUserCredentials(LogiqConnectionUserSetup);

        if (LogiqConnectionUserSetup."API Engine" = LogiqConnectionUserSetup."API Engine"::" ") then
            Error(MissingAPIEngineErr);

        if (LogiqConnectionUserSetup."Document Transfer Endpoint" = '') or (LogiqConnectionUserSetup."Document Status Endpoint" = '') then
            Error(MissingEndpointsErr);
    end;

    internal procedure CheckSetup(var LogiqConnectionSetup: Record "Logiq Connection Setup")
    var
        NoSetupErr: Label 'No setup found. Please fill the setup in the Logiq Connection Setup page.';
        MissingClientInfoErr: Label 'Client ID or Client Secret is missing. Please fill the Client ID and Client Secret in the Logiq Connection Setup page.';
        MissingAuthUrlErr: Label 'Authentication URL is missing. Please fill the Authentication URL in the Logiq Connection Setup page.';
        MissingBaseUrlErr: Label 'Base URL is missing. Please fill the API Base URL in the Logiq Connection Setup page.';
    begin
        if not LogiqConnectionSetup.Get() then
            Error(NoSetupErr);

        if (LogiqConnectionSetup."Client ID" = '') or (IsNullGuid(LogiqConnectionSetup."Client Secret")) then
            Error(MissingClientInfoErr);

        if LogiqConnectionSetup."Authentication URL" = '' then
            Error(MissingAuthUrlErr);

        if LogiqConnectionSetup."Base URL" = '' then
            Error(MissingBaseUrlErr);
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
        SetIsolatedStorageValue(LogiqConnectionUserSetup."Access Token", AccessToken, DataScope::User);
        SetIsolatedStorageValue(LogiqConnectionUserSetup."Refresh Token", RefreshToken, DataScope::User);
        LogiqConnectionUserSetup."Access Token Expiration" := AccessTokExpires;
        LogiqConnectionUserSetup."Refresh Token Expiration" := RefreshTokExpires;
        LogiqConnectionUserSetup.Modify(false);
    end;

    internal procedure HasToken(ValueKey: Guid; DataScope: DataScope): Boolean
    begin
        exit(IsolatedStorage.Contains(ValueKey, DataScope));
    end;

    internal procedure CheckUpdateTokens()
    var
        LogiqConnectionUserSetup: Record "Logiq Connection User Setup";
        NoSetupErr: Label 'No user setup found. Please fill the user setup in the Logiq Connection User Setup page.';
    begin
        if not LogiqConnectionUserSetup.Get(UserId()) then
            Error(NoSetupErr);
        if IsNullGuid(LogiqConnectionUserSetup."Access Token") or (LogiqConnectionUserSetup."Access Token Expiration" < (CurrentDateTime + 5 * 60 * 1000)) then
            GetTokens();
    end;
}
