// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 502 OAuth2Impl
{
    Access = Internal;

    var
        AuthFlow: DotNet ALAzureAdCodeGrantFlow;
        OAuthLandingPageTxt: Label 'OAuthLanding.htm', Locked = true;
        Oauth2CategoryLbl: Label 'OAuth2', Locked = true;
        RedirectUrlTxt: Label 'The defined redirectURL is: %1', Comment = '%1 = The redirect URL', Locked = true;
        DefaultRedirectUrlTxt: Label 'The default redirectURL is: %1', Comment = '%1 = The redirect URL', Locked = true;
        AuthRequestUrlTxt: Label 'The authentication request URL %1 has been succesfully retrieved.', Comment = '%1=Authentication request URL';
        MissingClientIdRedirectUrlStateErr: Label 'The authorization request URL for the OAuth2 Grant flow cannot be constructed because of missing ClientId, RedirectUrl or state', Locked = true;
        AuthorizationCodeErr: Label 'The OAuth2 authentication code retrieved is empty.', Locked = true;
        CannotreadFromJsonErr: Label 'The Authorization code cannot be read from the JSON file.', Locked = true;
        CannotGetCodePropertyFromJsonErr: Label 'The code property cannot be extracted from the JSON body of the authorization code.', Locked = true;
        CodePropertyDoesNotHaveValueErr: Label 'The code property value from the JSON body cannot be retreieved.', Locked = true;
        CannotWriteJsonToAuthCodeErr: Label 'The authorization code cannot be written to a text value.', Locked = true;
        EmptyAccessTokenClientCredsErr: Label 'The access token failed to be retrieved by the client credentials grant flow.', Locked = true;
        StartAuthCodeFlowMsg: Label 'Starting the authorization code grant flow.', Locked = true;
        AuthorizationCodeExtractedSuccessfullyFromJsonMsg: Label 'The authorization code has been successfully extracted from the JSON body.', Locked = true;

    [NonDebuggable]
    procedure GetAuthRequestUrl(ClientId: Text; ClientSecret: Text; Url: Text; RedirectUrl: Text; State: Text; ResourceUrl: Text; PromptConsent: Enum "Prompt Interaction"): Text
    var
        AuthRequestUrl: Text;
    begin
        if (ClientId = '') or (RedirectUrl = '') or (state = '') then begin
            SendTraceTag('0000CCI', Oauth2CategoryLbl, Verbosity::Error, MissingClientIdRedirectUrlStateErr, DataClassification::SystemMetadata);
            exit('');
        end;
        AuthRequestUrl := Url + '?' + 'client_id=' + ClientId + '&redirect_uri=' + RedirectUrl + '&state=' + State + '&response_type=code';

        case PromptConsent of
            PromptConsent::Login:
                AuthRequestUrl := AuthRequestUrl + '&prompt=login';
            PromptConsent::"Select Account":
                AuthRequestUrl := AuthRequestUrl + '&prompt=select_account';
            PromptConsent::Consent:
                AuthRequestUrl := AuthRequestUrl + '&prompt=consent';
            PromptConsent::"Admin Consent":
                AuthRequestUrl := AuthRequestUrl + '&prompt=admin_consent';
        end;

        if ResourceUrl <> '' then
            AuthRequestUrl := AuthRequestUrl + '&resource=' + ResourceUrl;

        SendTraceTag('0000BRH', Oauth2CategoryLbl, Verbosity::Normal, StrSubstNo(AuthRequestUrlTxt, AuthRequestUrl), DataClassification::AccountData);
        exit(AuthRequestUrl);
    end;


    [NonDebuggable]
    procedure GetOAuthProperties(AuthorizationCode: Text; var CodeOut: Text; var StateOut: Text)
    begin
        if AuthorizationCode = '' then begin
            SendTraceTag('0000C1V', Oauth2CategoryLbl, Verbosity::Error, AuthorizationCodeErr, DataClassification::SystemMetadata);
            exit;
        end;

        ReadAuthCodeFromJson(AuthorizationCode);
        CodeOut := GetPropertyFromCode(AuthorizationCode, 'code');
        StateOut := GetPropertyFromCode(AuthorizationCode, 'state');
    end;

    [NonDebuggable]
    local procedure ReadAuthCodeFromJson(var AuthorizationCode: Text)
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        if not JObject.ReadFrom(AuthorizationCode) then begin
            SendTraceTag('0000C1W', Oauth2CategoryLbl, Verbosity::Warning, CannotreadFromJsonErr, DataClassification::SystemMetadata);
            exit;
        end;
        if not JObject.Get('code', JToken) then begin
            SendTraceTag('0000C1X', Oauth2CategoryLbl, Verbosity::Warning, CannotGetCodePropertyFromJsonErr, DataClassification::SystemMetadata);
            exit;
        end;
        if not JToken.IsValue() then begin
            SendTraceTag('0000C1Y', Oauth2CategoryLbl, Verbosity::Warning, CodePropertyDoesNotHaveValueErr, DataClassification::SystemMetadata);
            exit;
        end;
        if not JToken.WriteTo(AuthorizationCode) then begin
            SendTraceTag('0000C1Z', Oauth2CategoryLbl, Verbosity::Warning, CannotWriteJsonToAuthCodeErr, DataClassification::SystemMetadata);
            exit;
        end;
        AuthorizationCode := AuthorizationCode.TrimStart('"').TrimEnd('"');
        SendTraceTag('0000C20', Oauth2CategoryLbl, Verbosity::Normal, AuthorizationCodeExtractedSuccessfullyFromJsonMsg, DataClassification::SystemMetadata);
    end;

    procedure GetDefaultRedirectUrl(): Text
    var
        UriBuilder: DotNet UriBuilder;
        PathString: DotNet String;
        RedirectUrl: Text;
    begin
        // Retrieve the Client URL
        RedirectUrl := GetUrl(ClientType::Web);
        // Extract the Base Url (domain) from the full CLient URL
        RedirectUrl := GetBaseUrl(RedirectUrl);

        UriBuilder := UriBuilder.UriBuilder(RedirectUrl);

        // Append a '/' character to the end of the path if one does not exist already.
        PathString := UriBuilder.Path;
        if PathString.LastIndexOf('/') < (PathString.Length - 1) then
            UriBuilder.Path := UriBuilder.Path + '/';

        // Append the desired redirect page to the path.
        UriBuilder.Path := UriBuilder.Path + OAuthLandingPageTxt;
        UriBuilder.Query := '';

        // Pull out the full URL by the URI and convert it to a string.
        RedirectUrl := UriBuilder.Uri.ToString();

        SendTraceTag('0000C21', Oauth2CategoryLbl, Verbosity::Normal, StrSubstNo(DefaultRedirectUrlTxt, RedirectUrl), DataClassification::AccountData);
        exit(RedirectUrl);
    end;

    [NonDebuggable]
    [TryFunction]
    procedure AcquireTokenByAuthorizationCode(ClientId: Text; ClientSecret: Text; OAuthAuthorityUrl: Text; RedirectURL: Text; ResourceUrl: Text; PromptInteraction: Enum "Prompt Interaction"; var AccessToken: Text; var AuthCodeErr: Text)
    var
        OAuth2ControlAddIn: Page OAuth2ControlAddIn;
        AuthRequestUrl: Text;
        AuthCode: Text;
        State: Text;
    begin
        SendTraceTag('0000C22', Oauth2CategoryLbl, Verbosity::Normal, StartAuthCodeFlowMsg, DataClassification::SystemMetadata);
        Initialize(OAuthAuthorityUrl, RedirectURL);
        State := Format(CreateGuid(), 0, 4);

        AuthRequestUrl := GetAuthRequestUrl(ClientId, ClientSecret, OAuthAuthorityUrl, RedirectURL, State, ResourceUrl, PromptInteraction);
        if AuthRequestUrl = '' then begin
            AuthCodeErr := MissingClientIdRedirectUrlStateErr;
            AccessToken := '';
            exit;
        end;

        OAuth2ControlAddIn.SetOAuth2CodeFlowGrantProperties(AuthRequestUrl, State);
        OAuth2ControlAddIn.RunModal();

        AuthCode := OAuth2ControlAddIn.GetAuthCode();
        if AuthCode <> '' then begin
            AcquireTokenByAuthorizationCodeWithCredentials(AuthCode, ClientId, ClientSecret, RedirectURL, OAuthAuthorityUrl, ResourceUrl, AccessToken);
            exit;
        end;
        AuthCodeErr := OAuth2ControlAddIn.getAuthCodeError();
    end;

    [NonDebuggable]
    [TryFunction]
    procedure AcquireOnBehalfOfToken(RedirectURL: Text; ResourceURL: Text; var AccessToken: Text)
    begin
        Initialize(RedirectURL);
        AccessToken := AuthFlow.ALAcquireOnBehalfOfToken(ResourceURL);
    end;

    [NonDebuggable]
    procedure AcquireOnBehalfAccessTokenAndRefreshToken(OAuthAuthorityUrl: Text; RedirectURL: Text; ResourceUrl: Text; var AccessToken: Text; var RefreshToken: Text)
    begin
        Initialize(OAuthAuthorityUrl, RedirectURL);
        AccessToken := AuthFlow.ALAcquireOnBehalfOfToken(ResourceUrl, RefreshToken);
    end;

    [NonDebuggable]
    procedure AcquireOnBehalfOfTokenByRefreshToken(ClientId: Text; RedirectURL: Text; ResourceURL: Text; RefreshToken: Text; var AccessToken: Text; var NewRefreshToken: Text)
    begin
        Initialize(RedirectURL);
        AccessToken := AuthFlow.ALAcquireTokenFromTokenCacheState(ResourceURL, ClientId, RefreshToken, NewRefreshToken);
    end;


    [NonDebuggable]
    [TryFunction]
    procedure AcquireTokenFromCache(RedirectURL: Text; ClientId: Text; ClientSecret: Text; ResourceURL: Text; var AccessToken: Text)
    begin
        Initialize(RedirectURL);
        AccessToken := AuthFlow.ALAcquireTokenFromCacheWithCredentials(ClientID, ClientSecret, ResourceURL);
    end;

    [NonDebuggable]
    [TryFunction]
    procedure AcquireTokenWithClientCredentials(ClientId: Text; ClientSecret: Text; OAuthAuthorityUrl: Text; RedirectURL: Text; ResourceURL: Text; var AccessToken: Text)
    begin
        Initialize(OAuthAuthorityUrl, RedirectURL);
        AccessToken := AuthFlow.ALAcquireApplicationToken(ClientID, ClientSecret, OAuthAuthorityUrl, ResourceURL);
        if AccessToken = '' then
            SendTraceTag('0000C23', Oauth2CategoryLbl, Verbosity::Error, EmptyAccessTokenClientCredsErr, DataClassification::SystemMetadata);
    end;

    [NonDebuggable]
    [TryFunction]
    procedure AcquireTokenByAuthorizationCodeWithCredentials(AuthorizationCode: Text; ClientId: Text; ClientSecret: Text; RedirectUrl: Text; OAuthAuthorityUrl: Text; ResourceURL: Text; var AccessToken: Text)
    begin
        Initialize(OAuthAuthorityUrl, RedirectUrl);
        AccessToken := AuthFlow.ALAcquireTokenByAuthorizationCodeWithCredentials(AuthorizationCode, ClientId, ClientSecret, ResourceURL);
    end;

    local procedure Initialize(RedirectURL: Text)
    var
        Uri: DotNet Uri;
    begin
        if RedirectURL = '' then
            RedirectURL := GetDefaultRedirectUrl()
        else
            SendTraceTag('0000C24', Oauth2CategoryLbl, Verbosity::Normal, StrSubstNo(RedirectUrlTxt, RedirectUrl), DataClassification::AccountData);

        AuthFlow := AuthFlow.ALAzureAdCodeGrantFlow(Uri.Uri(RedirectURL));
    end;

    local procedure Initialize(OAuthAuthorityUrl: Text; var RedirectURL: Text)
    var
        Uri: DotNet Uri;
    begin
        if RedirectURL = '' then
            RedirectURL := GetDefaultRedirectUrl()
        else
            SendTraceTag('0000C24', Oauth2CategoryLbl, Verbosity::Normal, StrSubstNo(RedirectUrlTxt, RedirectUrl), DataClassification::AccountData);

        AuthFlow := AuthFlow.ALAzureAdCodeGrantFlow(Uri.Uri(RedirectURL), Uri.Uri(OAuthAuthorityUrl));
    end;

    local procedure GetBaseUrl(RedirectUrl: Text): Text
    var
        BaseIndex: Integer;
        EndBaseUrlIndex: Integer;
        Baseurl: Text;
    begin
        if StrPos(LowerCase(RedirectUrl), 'https://') <> 0 then
            BaseIndex := 9;
        if StrPos(LowerCase(RedirectUrl), 'http://') <> 0 then
            BaseIndex := 8;

        Baseurl := CopyStr(RedirectUrl, BaseIndex);
        EndBaseUrlIndex := StrPos(Baseurl, '/');

        if EndBaseUrlIndex = 0 then
            exit(RedirectUrl);

        Baseurl := CopyStr(Baseurl, 1, EndBaseUrlIndex - 1);
        exit(CopyStr(RedirectUrl, 1, BaseIndex - 1) + Baseurl);
    end;

    [NonDebuggable]
    local procedure GetPropertyFromCode(CodeTxt: Text; Property: Text): Text
    var
        PosProperty: Integer;
        PosValue: Integer;
        PosEnd: Integer;
    begin
        PosProperty := StrPos(CodeTxt, Property);
        if PosProperty = 0 then
            exit('');
        PosValue := PosProperty + StrPos(CopyStr(Codetxt, PosProperty), '=');
        PosEnd := PosValue + StrPos(CopyStr(CodeTxt, PosValue), '&');

        if PosEnd = PosValue then
            exit(CopyStr(CodeTxt, PosValue, StrLen(CodeTxt) - 1));
        exit(CopyStr(CodeTxt, PosValue, PosEnd - PosValue - 1));
    end;

}