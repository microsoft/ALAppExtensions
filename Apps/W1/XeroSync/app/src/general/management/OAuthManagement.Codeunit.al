codeunit 2410 "XS OAuth Management"
{
    SingleInstance = true;

    var
        XeroSyncSetup: Record "Sync Setup";
        RequestTokenKey: Text;
        RequestTokenSecret: Text;
        ConsumerKeyTxt: Label 'xeroimportapp-key', locked = true;
        ConsumerSecretTxt: Label 'xeroimportapp-secret', locked = true;
        RequestTokenUrlTxt: Label 'https://api.xero.com/oauth/RequestToken', locked = true;
        Leg2UrlTxt: Label 'https://api.xero.com/oauth/Authorize?oauth_token=%1', locked = true;
        AccessTokenUrlTxt: Label 'https://api.xero.com/oauth/AccessToken', locked = true;

    [Scope('Internal')]
    procedure GetAuthUrl(SyncApplication: Text; var AuthUrl: Text; CallbackUrl: Text)
    var
        OAuth: Codeunit OAuth;
        ConsumerKey: Text;
        ConsumerSecret: Text;
    begin
        if SyncApplication <> 'Xero' then
            exit;

        GetConsumerKeyAndSecret(ConsumerKey, ConsumerSecret);

        OAuth.GetOAuthAccessToken(
            ConsumerKey,
            ConsumerSecret,
            RequestTokenUrlTxt,
            CallbackUrl,
            RequestTokenKey,
            RequestTokenSecret);

        AuthUrl := StrSubstNo(Leg2UrlTxt, RequestTokenKey);
    end;

    [Scope('Internal')]
    procedure RetrieveAccessToken(SyncApplication: Text; AuthProperties: Text; var AccessTokenKey: Text; var AccessTokenSecret: Text)
    var
        OAuth: Codeunit OAuth;
        CryptographyManagement: Codeunit "Cryptography Management";
        OAuthVerifier: Text;
        ConsumerKey: Text;
        ConsumerSecret: Text;
    begin
        if SyncApplication <> 'Xero' then
            exit;

        GetConsumerKeyAndSecret(ConsumerKey, ConsumerSecret);

        // OAuthVerifier := OAuthManagement.GetPropertyFromCode(AuthProperties, 'oauth_verifier');       
        OAuthVerifier := AuthProperties;  // TODO: remove - temporary

        OAuth.GetOAuthAccessToken(
            ConsumerKey,
            ConsumerSecret,
            AccessTokenUrlTxt,
            OAuthVerifier,
            RequestTokenKey,
            RequestTokenSecret,
            AccessTokenKey,
            AccessTokenSecret);

        with XeroSyncSetup do begin
            GetSingleInstance();

            IF CryptographyManagement.IsEncryptionEnabled() then begin
                IsolatedStorage.SetEncrypted('XS Xero Access Key', CopyStr(AccessTokenKey, 1, 250), DataScope::Company);
                IsolatedStorage.SetEncrypted('XS Xero Access Secret', CopyStr(AccessTokenSecret, 1, 250), DataScope::Company);
            end else begin
                IsolatedStorage.Set('XS Xero Access Key', CopyStr(AccessTokenKey, 1, 250), DataScope::Company);
                IsolatedStorage.Set('XS Xero Access Secret', CopyStr(AccessTokenSecret, 1, 250), DataScope::Company);
            end;
            //"Access Key Expiration" := date (OAuthManagement.GetPropertyFromCode(AuthProperties, 'oauth_verifier'));
            Modify(true);
        end;
    end;

    [Scope('Internal')]
    procedure GetConsumerKeyAndSecret(var ConsumerKey: Text; var ConsumerSecret: Text): Boolean
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(ConsumerKeyTxt, ConsumerKey) then
            exit(false);
        if not AzureKeyVault.GetAzureKeyVaultSecret(ConsumerSecretTxt, ConsumerSecret) then
            exit(false);

        exit((ConsumerKey <> '') and (ConsumerSecret <> ''));
    end;
}