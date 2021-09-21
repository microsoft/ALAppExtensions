codeunit 89001 "LGS Guest Outlook-OAuthClient" implements "Email - OAuth Client"
{
    /// <summary>
    /// Retrieves the Access token for the current user to connect to Outlook API
    /// </summary>
    /// <param name="AccessToken">Out parameter with the Access token of the account</param>
    [NonDebuggable]
    procedure GetAccessToken(var AccessToken: Text)
    begin
        TryGetAccessTokenInternal(AccessToken);
    end;

    [NonDebuggable]
    procedure TryGetAccessToken(var AccessToken: Text): Boolean
    begin
        exit(TryGetAccessTokenInternal(AccessToken));
    end;

    // Interfaces do not support properties for the procedures, so using an internal function
    [TryFunction]
    [NonDebuggable]
    local procedure TryGetAccessTokenInternal(var AccessToken: Text)
    var
        EnvironmentInformation: Codeunit "Environment Information";
        OAuthErr: Text;
    begin
        Initialize();
        if (not OAuth2.AcquireAuthorizationCodeTokenFromCache(ClientId, ClientSecret, RedirectURL, OAuthAuthorityUrlTxt, Scopes, AccessToken)) or (AccessToken = '') then
            OAuth2.AcquireTokenByAuthorizationCode(ClientId, ClientSecret, OAuthAuthorityUrlTxt, RedirectURL, Scopes, Enum::"Prompt Interaction"::None, AccessToken, OAuthErr);

        if AccessToken = '' then
            Error(CouldNotGetAccessTokenErr);
    end;

    local procedure Initialize()
    var
        GuestOutlookAPIHelper: Codeunit "LGS Guest Outlook - API Helper";
    begin
        if IsInitialized then
            exit;

        GuestOutlookAPIHelper.GetClientIDAndSecret(ClientId, ClientSecret);
        OAuth2.GetDefaultRedirectUrl(RedirectURL);
        Scopes.Add(GraphResourceURLTxt);

        IsInitialized := true;
    end;


    var
        OAuth2: Codeunit OAuth2;

        [NonDebuggable]
        ClientId: Text;
        [NonDebuggable]
        ClientSecret: Text;
        RedirectURL: Text;
        IsInitialized: Boolean;
        OAuthAuthorityUrlTxt: Label 'https://login.microsoftonline.com/common/oauth2', Locked = true;
        GraphResourceURLTxt: Label 'https://graph.microsoft.com/.default', Locked = true;
        Scopes: List of [Text];
        TokenCacheTok: Label 'TokenCache', Locked = true;
        CouldNotGetAccessTokenErr: Label 'Could not get access token. Please, try to log out and log in again.';
}