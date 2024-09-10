// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

using System.Security.Authentication;
using System.Azure.KeyVault;
using System.Environment;
using System.Integration;

codeunit 96364 "Tietoevry Auth."
{
    Access = Internal;
    Permissions = tabledata "OAuth 2.0 Setup" = im;

    procedure InitConnectionSetup()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        EDocExtConnectionSetup: Record "Tietoevry Connection Setup";
    begin
        if not EDocExtConnectionSetup.Get() then begin
            EDocExtConnectionSetup."OAuth Feature GUID" := CreateGuid();
            EDocExtConnectionSetup."Send Mode" := EDocExtConnectionSetup."Send Mode"::Certification;
            SetDefaultEndpoints(EDocExtConnectionSetup, EDocExtConnectionSetup."Send Mode");
            EDocExtConnectionSetup.Insert();
        end;
        InitOAuthSetup(OAuth20Setup);
    end;

    procedure SetDefaultEndpoints(var EDocExtConnectionSetup: Record "Tietoevry Connection Setup"; SendMode: Enum "E-Doc. Tietoevry Send Mode")
    begin
        case SendMode of
            SendMode::Production:
                begin
                    EDocExtConnectionSetup."Authentication URL" := ProdAuthURLTxt;
                    EDocExtConnectionSetup."Inbound API URL" := ProdInboundAPITxt;
                    EDocExtConnectionSetup."Outbound API URL" := ProdOutboundAPITxt;
                end;
            SendMode::Certification:
                begin
                    EDocExtConnectionSetup."Authentication URL" := CertAuthURLTxt;
                    EDocExtConnectionSetup."Inbound API URL" := CertInboundAPITxt;
                    EDocExtConnectionSetup."Outbound API URL" := CertOutboundAPITxt;
                end;
        end;
    end;

    [NonDebuggable]
    procedure SetClientId(var ClienId: Guid; ClientID: Text)
    var
    begin
        SetIsolatedStorageValue(ClienId, ClientID, DataScope::Company);
    end;

    procedure SetClientSecret(var ClienSecret: Guid; ClientSecret: SecretText)
    begin
        SetIsolatedStorageValue(ClienSecret, ClientSecret, DataScope::Company);
    end;

    procedure IsClientCredsSet(var ClientId: Text; var ClientSecret: Text): Boolean
    var
        EDocExtConnectionSetup: Record "Tietoevry Connection Setup";
    begin
        EDocExtConnectionSetup.Get();
#if not DOCKER
        if EnvironmentInfo.IsSaaS() then
            exit(true);
#endif
        if HasToken(EDocExtConnectionSetup."Client ID", DataScope::Company) then
            ClientId := '*';
        if HasToken(EDocExtConnectionSetup."Client Secret", DataScope::Company) then
            ClientSecret := '*';
    end;

    procedure OpenOAuthSetupPage()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
    begin
        InitOAuthSetup(OAuth20Setup);
        Commit();
        Page.RunModal(Page::"OAuth 2.0 Setup", OAuth20Setup);
    end;

    procedure GetAuthBearerTxt(): SecretText;
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        HttpError: Text;
    begin
        GetOAuth2Setup(OAuth20Setup);
        if OAuth20Setup."Access Token Due DateTime" < CurrentDateTime() + 60 * 1000 then
            if not RefreshAccessToken(HttpError) then
                Error(HttpError);

        exit(SecretStrSubstNo(BearerTxt, GetToken(OAuth20Setup."Access Token", OAuth20Setup.GetTokenDataScope())));
    end;

    local procedure ParseAccessTokens(ResponseJson: Text; var AccessToken: SecretText; var ExpireInSec: BigInteger): Boolean
    var
        JToken: JsonToken;
        NewAccessToken: Text;
    begin
        NewAccessToken := '';

        AccessToken := NewAccessToken;

        ExpireInSec := 0;

        if JToken.ReadFrom(ResponseJson) then
            foreach JToken in JToken.AsObject().Values() do
                case JToken.Path() of
                    'access_token':
                        NewAccessToken := JToken.AsValue().AsText();
                    'expires_in':
                        ExpireInSec := JToken.AsValue().AsBigInteger();
                end;
        if (NewAccessToken = '') then
            exit(false);

        AccessToken := NewAccessToken;
        exit(true);
    end;

    procedure TestOAuth2Setup()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        HttpError: Text;
    begin
        GetOAuth2Setup(OAuth20Setup);
        OAuth20Setup.RequestAccessToken(HttpError, '');
    end;

    [NonDebuggable]
    local procedure AcquireTokenWithClientCredentials(ClientId: Text; ClientSecret: SecretText; OAuthAuthorityUrl: Text; var AccessToken: SecretText; var ExpireInSec: BigInteger): Boolean
    var
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpResponse: HttpResponseMessage;
        HttpHeaders: HttpHeaders;
        RequestContent: Text;
        HttpResponseBodyText: Text;
    begin
        RequestContent := StrSubstNo(TokenRequestContentTxt, ClientId, ClientSecret.Unwrap());
        HttpClient.Clear();
        HttpContent.WriteFrom(RequestContent);
        HttpContent.GetHeaders(HttpHeaders);
        if HttpHeaders.Contains('Content-Type') then
            HttpHeaders.Remove('Content-Type');
        HttpHeaders.Add('Content-Type', 'application/x-www-form-urlencoded');

        HttpClient.Post(OAuthAuthorityUrl, HttpContent, HttpResponse);
        if HttpResponse.IsSuccessStatusCode then begin
            HttpResponse.Content().ReadAs(HttpResponseBodyText);
            exit(ParseAccessTokens(HttpResponseBodyText, AccessToken, ExpireInSec));
        end;
    end;

    [NonDebuggable]
    local procedure RefreshAccessToken(var HttpError: Text): Boolean;
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
    begin
        GetOAuth2Setup(OAuth20Setup);
        exit(OAuth20Setup.RefreshAccessToken(HttpError));
    end;

    [NonDebuggable]
    local procedure InitOAuthSetup(var OAuth20Setup: Record "OAuth 2.0 Setup")
    var
        EDocExtConnectionSetup: Record "Tietoevry Connection Setup";
        Exists: Boolean;
    begin
        EDocExtConnectionSetup.Get();

        if OAuth20Setup.Get(GetAuthSetupCode()) then
            Exists := true;

        OAuth20Setup.Code := GetAuthSetupCode();
        OAuth20Setup."Client ID" := CreateGuid();
        OAuth20Setup."Client Secret" := CreateGuid();
        OAuth20Setup."Service URL" := EDocExtConnectionSetup."Authentication URL";
        OAuth20Setup.Description := 'Tietoevry Online';
        OAuth20Setup.Scope := 'all';
        OAuth20Setup."Access Token URL Path" := AccessTokenURLPathTxt;
        OAuth20Setup."Token DataScope" := OAuth20Setup."Token DataScope"::Company;
        OAuth20Setup."Daily Limit" := 1000;
        OAuth20Setup."Feature GUID" := EDocExtConnectionSetup."OAuth Feature GUID";
        OAuth20Setup."User ID" := CopyStr(UserId(), 1, MaxStrLen(OAuth20Setup."User ID"));
        if not Exists then
            OAuth20Setup.Insert()
        else
            OAuth20Setup.Modify();
    end;

    [NonDebuggable]
    local procedure GetOAuth2Setup(var OAuth20Setup: Record "OAuth 2.0 Setup"): Boolean;
    var
        ExternalConnectionSetup: Record "Tietoevry Connection Setup";
    begin
        if not ExternalConnectionSetup.Get() then
            Error(MissingAuthErr);

        ExternalConnectionSetup.TestField("OAuth Feature GUID");

        OAuth20Setup.Get(GetAuthSetupCode());
        exit(true);
    end;

    [NonDebuggable]
    local procedure CheckOAuthConsistencySetup(OAuth20Setup: Record "OAuth 2.0 Setup")
    begin
        OAuth20Setup.TestField("Access Token URL Path", AccessTokenURLPathTxt);
        OAuth20Setup.TestField("Daily Limit");
    end;

    local procedure SetIsolatedStorageValue(var ValueKey: Guid; Value: SecretText; TokenDataScope: DataScope) NewToken: Boolean
    begin
        if IsNullGuid(ValueKey) then
            NewToken := true;
        if NewToken then
            ValueKey := CreateGuid();

        IsolatedStorage.Set(ValueKey, Value, TokenDataScope);
    end;

    local procedure GetToken(TokenKey: Text; TokenDataScope: DataScope) TokenValueAsSecret: SecretText
    begin
        if not HasToken(TokenKey, TokenDataScope) then
            exit(TokenValueAsSecret);

        IsolatedStorage.Get(TokenKey, TokenDataScope, TokenValueAsSecret);
    end;

    [NonDebuggable]
    local procedure HasToken(TokenKey: Text; TokenDataScope: DataScope): Boolean
    begin
        exit(IsolatedStorage.Contains(TokenKey, TokenDataScope));
    end;

    [NonDebuggable]
    local procedure GetAuthSetupCode(): Code[20]
    begin
        exit(TietoevryOAuthCodeLbl);
    end;

    [NonDebuggable]
    local procedure GetClientId(): Text
    var
        EDocExtConnectionSetup: Record "Tietoevry Connection Setup";
#if not DOCKER 
        AzureKeyVault: Codeunit "Azure Key Vault";
        Secret: Text;
#endif
    begin
#if not DOCKER        
        if EnvironmentInfo.IsSaaS() then begin
            AzureKeyVault.GetAzureKeyVaultSecret('tietoevry-client-id', Secret);
            exit(Secret);
        end;
#endif
        if EDocExtConnectionSetup.Get() then
            exit(GetToken(EDocExtConnectionSetup."Client ID", DataScope::Company).Unwrap());
    end;

    local procedure GetClientSecret(): SecretText
    var
        EDocExtConnectionSetup: Record "Tietoevry Connection Setup";
#if not DOCKER         
        AzureKeyVault: Codeunit "Azure Key Vault";
        Secret: SecretText;
#endif
    begin
#if not DOCKER        
        if EnvironmentInfo.IsSaaS() then begin
            AzureKeyVault.GetAzureKeyVaultSecret('tietoevry-client-secret', Secret);
            exit(Secret);
        end;
#endif
        if EDocExtConnectionSetup.Get() then
            exit(GetToken(EDocExtConnectionSetup."Client Secret", DataScope::Company));
    end;

    local procedure SaveToken(var OAuth20Setup: Record "OAuth 2.0 Setup"; TokenDataScope: DataScope; AccessToken: SecretText)
    begin
        SetIsolatedStorageValue(OAuth20Setup."Access Token", AccessToken, TokenDataScope);
        OAuth20Setup.Modify();
    end;

    [NonDebuggable]
    [EventSubscriber(ObjectType::Table, Database::"OAuth 2.0 Setup", 'OnBeforeRequestAccessToken', '', true, true)]
    local procedure OnBeforeRequestAccessToken(var OAuth20Setup: Record "OAuth 2.0 Setup"; AuthorizationCode: Text; var Result: Boolean; var MessageText: Text; var Processed: Boolean)
    var
        EDocExtConnectionSetup: Record "Tietoevry Connection Setup";
        NewAccessToken: SecretText;
        ExpireInSec: BigInteger;
        TokenDataScope: DataScope;
    begin
        if not EDocExtConnectionSetup.Get() then
            exit;

        CheckOAuthConsistencySetup(OAuth20Setup);

        Processed := true;

        TokenDataScope := OAuth20Setup.GetTokenDataScope();

        Result := AcquireTokenWithClientCredentials(GetClientId(), GetClientSecret(), OAuth20Setup."Service URL" + OAuth20Setup."Access Token URL Path", NewAccessToken, ExpireInSec);

        if not Result then
            Error(AuthenticationFailedErr);

        OAuth20Setup."Access Token Due DateTime" := CurrentDateTime() + ExpireInSec * 1000;
        SaveToken(OAuth20Setup, TokenDataScope, NewAccessToken);

        Message(AuthorizationSuccessfulTxt);
    end;

    [NonDebuggable]
    [EventSubscriber(ObjectType::Table, Database::"OAuth 2.0 Setup", 'OnBeforeRefreshAccessToken', '', true, true)]
    local procedure OnBeforeRefreshAccessToken(var OAuth20Setup: Record "OAuth 2.0 Setup"; var Result: Boolean; var MessageText: Text; var Processed: Boolean)
    var
        EDocExtConnectionSetup: Record "Tietoevry Connection Setup";
        NewAccessToken: SecretText;
        ExpireInSec: BigInteger;
        TokenDataScope: DataScope;
    begin
        if not EDocExtConnectionSetup.Get() then
            exit;
        if not GetOAuth2Setup(OAuth20Setup) or Processed then
            exit;

        CheckOAuthConsistencySetup(OAuth20Setup);

        Processed := true;

        TokenDataScope := OAuth20Setup.GetTokenDataScope();

        Result := AcquireTokenWithClientCredentials(GetClientId(), GetClientSecret(), OAuth20Setup."Service URL" + OAuth20Setup."Access Token URL Path", NewAccessToken, ExpireInSec);
        if not Result then
            Error(AuthenticationFailedErr);

        OAuth20Setup."Access Token Due DateTime" := CurrentDateTime() + ExpireInSec * 1000;
        SaveToken(OAuth20Setup, TokenDataScope, NewAccessToken);
    end;

    [EventSubscriber(ObjectType::Table, Database::"OAuth 2.0 Setup", 'OnBeforeRequestAuthoizationCode', '', true, true)]
    [NonDebuggable]
    local procedure OnBeforeRequestAuthoizationCode(OAuth20Setup: Record "OAuth 2.0 Setup"; var Processed: Boolean)
    var
        EDocExtConnectionSetup: Record "Tietoevry Connection Setup";
    begin
        if not EDocExtConnectionSetup.Get() or Processed then
            exit;
        Processed := true;
    end;

    var
        AccessTokenURLPathTxt: Label '/token', Locked = true;
        BearerTxt: Label 'Bearer %1', Comment = '%1 = text value', Locked = true;
        TokenRequestContentTxt: Label 'grant_type=client_credentials&client_id=%1&client_secret=%2', Comment = '%1 = Client Id, %2 = Client Secret', Locked = true;
        ProdAuthURLTxt: Label 'https://auth.infotorg.no/auth/realms/fms-realm/protocol/openid-connect', Locked = true;
        ProdInboundAPITxt: Label 'https://accesspoint-api.dataplatfor.ms/inbound', Locked = true;
        ProdOutboundAPITxt: Label 'https://accesspoint-api.dataplatfor.ms/outbound', Locked = true;
        CertAuthURLTxt: Label 'https://auth-qa.infotorg.no/auth/realms/fms-realm/protocol/openid-connect', Locked = true;
        CertInboundAPITxt: Label 'https://accesspoint-api.qa.dataplatfor.ms/inbound', Locked = true;
        CertOutboundAPITxt: Label 'https://accesspoint-api.qa.dataplatfor.ms/outbound', Locked = true;
        TietoevryOAuthCodeLbl: Label 'EDocTietoevry', Locked = true;
        AuthorizationSuccessfulTxt: Label 'Authorization successful.';
        MissingAuthErr: Label 'You must set up authentication to the service integration in the E-Document service card.';
        AuthenticationFailedErr: Label 'Authentication failed, check your credentials in the E-Document service card.';
}