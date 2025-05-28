namespace Microsoft.EServices.EDocumentConnector.ForNAV;

using System.Environment;
using System.Azure.Identity;
using System.Security.AccessControl;
using System.Reflection;
using Microsoft.eServices.EDocument.Integration.Send;

codeunit 6422 "ForNAV Peppol Oauth"
{
    Access = Internal;

    var
        SetupKeyLbl: Label 'setupKey', Locked = true;
        BaseUrlLbl: Label 'https://peppolapi.fornav.com/', Locked = true;
        RequestConfigLbl: Label 'RequestConfig', Locked = true;
        RequestConfigFileLbl: Label 'RequestConfigFile', Locked = true;
        RotateSecretLbl: Label 'RotateSecret', Locked = true;
        SwapEndpointLbl: Label 'SwapEndpoint', Locked = true;
        ClientIdKeyLbl: Label 'ClientIdKey', Locked = true;
        TenantIdKeyLbl: Label 'TenantIdKey', Locked = true;
        ClientSecretKeyLbl: Label 'SecretKey', Locked = true;
        ScopeEndpointLbl: Label 'ScopeEndpoint', Locked = true;
        ScopeConfigLbl: Label 'ScopeConfig', Locked = true;
        EndpointKeyLbl: Label 'EndpointKey', Locked = true;
        SecretValidFromKeyLbl: Label 'SecretValidFromKey', Locked = true;
        SecretValidToKeyLbl: Label 'SecretValidToKey', Locked = true;
        InvalidCLientIdErr: Label 'Invalid client id. Contact your ForNAV partner.', Locked = true;



    local procedure SetSecretStorage("Key": Text; keyValue: SecretText)
    var
        Setup: Codeunit "ForNAV Peppol Setup";
    begin
        if keyValue.IsEmpty() then
            DeleteIsolatedStorage("Key")
        else
            IsolatedStorage.Set("Key", keyValue, DataScope::Module);

        Setup.ClearAccessToken();
    end;

    internal procedure GetSecretStorage("Key": Text) keyValue: SecretText
    begin
        if IsolatedStorage.Contains("Key", DataScope::Module) then
            IsolatedStorage.Get("Key", DataScope::Module, keyValue);
    end;

    local procedure SetIsolatedStorage("Key": Text; keyValue: Text)
    var
        Setup: Codeunit "ForNAV Peppol Setup";
    begin
        if keyValue = '' then
            DeleteIsolatedStorage("Key")
        else
            IsolatedStorage.Set("Key", keyValue, DataScope::Module);

        Setup.ClearAccessToken();
    end;

    local procedure GetIsolatedStorage("Key": Text) keyValue: Text
    begin
        if IsolatedStorage.Contains("Key", DataScope::Module) then
            IsolatedStorage.Get("Key", DataScope::Module, keyValue);
    end;

    local procedure DeleteIsolatedStorage("Key": Text)
    begin
        if IsolatedStorage.Contains("Key", DataScope::Module) then
            IsolatedStorage.Delete("Key", DataScope::Module);
    end;

    internal procedure ValidateClientID(ClientId: Text)
    begin
        SetIsolatedStorage(ClientIdKeyLbl, ClientId);
    end;

    internal procedure GetClientID(): Text
    begin
        exit(GetIsolatedStorage(ClientIdKeyLbl));
    end;

    internal procedure ValidateForNAVTenantID(TenantId: Text)
    begin
        SetIsolatedStorage(TenantIdKeyLbl, TenantId);
    end;

    internal procedure GetForNAVTenantID(): Text
    begin
        exit(GetIsolatedStorage(TenantIdKeyLbl));
    end;

    internal procedure ValidateSecret(Secret: SecretText)
    begin
        SetSecretStorage(ClientSecretKeyLbl, Secret);
    end;

    internal procedure GetClientSecret(): SecretText
    begin
        exit(GetSecretStorage(ClientSecretKeyLbl));
    end;

    [NonDebuggable]
    internal procedure ValidateScope(Scope: Text)
    var
        ScopePart: Text;
        EndpointLbl: Label 'endpoint', Locked = true;
        ConfigLbl: Label 'config', Locked = true;
    begin
        DeleteIsolatedStorage(ScopeEndpointLbl);
        DeleteIsolatedStorage(ScopeConfigLbl);

        if Scope = '' then
            exit;

        foreach ScopePart in Scope.Split(';') do begin
            if ScopePart.StartsWith(EndpointLbl) then
                SetSecretStorage(ScopeEndpointLbl, ScopePart.Split(',').Get(2));
            if ScopePart.StartsWith(ConfigLbl) then
                SetSecretStorage(ScopeConfigLbl, ScopePart.Split(',').Get(2));
        end;
    end;

    internal procedure GetEndpointScope() Scopes: List of [SecretText];
    begin
        Scopes.Add(GetSecretStorage(ScopeEndpointLbl));
    end;

    internal procedure GetScopeConfig() Scopes: List of [SecretText];
    begin
        Scopes.Add(GetSecretStorage(ScopeConfigLbl));
    end;

    internal procedure GetScopes() Scopes: List of [SecretText];
    begin
        Scopes.Add(GetSecretStorage(ScopeConfigLbl));
        Scopes.Add(GetSecretStorage(ScopeEndpointLbl));
    end;

    internal procedure ValidateEndpoint(Endpoint: Text; Swap: Boolean)
    begin
        if StrLen(Endpoint) > 1 then
            Endpoint := Endpoint.Substring(1, 1).ToUpper() + Endpoint.Substring(2).ToLower();

        if Swap then
            SwapEndpoint(Endpoint)
        else
            SetIsolatedStorage(EndpointKeyLbl, Endpoint);
    end;

    internal procedure GetEndpoint() Result: Text
    begin
        Result := GetIsolatedStorage(EndpointKeyLbl);
        if Result = '' then
            Result := GetDefaultEndpoint();
    end;

    internal procedure GetDefaultEndpoint(): Text
    var
        DefaultEndpointLbl: Label 'Beta', Locked = true;
    begin
        exit(DefaultEndpointLbl);
    end;

    local procedure ValidateSecretValidFrom(SecretValidFrom: DateTime)
    begin
        if SecretValidFrom.Date = 0D then
            DeleteIsolatedStorage(SecretValidFromKeyLbl)
        else
            SetIsolatedStorage(SecretValidFromKeyLbl, Format(SecretValidFrom, 0, 9));
    end;

    internal procedure GetSecretValidFrom() Result: DateTime
    var
        SecretValidFrom: Text;
    begin
        SecretValidFrom := GetIsolatedStorage(SecretValidFromKeyLbl);
        if SecretValidFrom = '' then
            exit(CreateDateTime(0D, 0T));

        Evaluate(Result, SecretValidFrom);
    end;

    internal procedure ValidateSecretValidTo(SecretValidTo: DateTime)
    begin
        if SecretValidTo.Date = 0D then begin
            ValidateSecretValidFrom(CreateDateTime(0D, 0T));
            DeleteIsolatedStorage(SecretValidToKeyLbl);
            exit;
        end;

        ValidateSecretValidFrom(CreateDateTime(Today, Time));
        SetIsolatedStorage(SecretValidToKeyLbl, Format(SecretValidTo, 0, 9));
    end;

    internal procedure GetSecretValidTo() Result: DateTime
    var
        SecretValidTo: Text;
    begin
        SecretValidTo := GetIsolatedStorage(SecretValidToKeyLbl);
        if SecretValidTo = '' then
            exit(CreateDateTime(0D, 0T));

        Evaluate(Result, SecretValidTo);
    end;

    [NonDebuggable]
    internal procedure SetSetupKey()
    var
        PasswordHandler: Codeunit "Password Handler";
    begin
        SetSecretStorage(SetupKeyLbl, PasswordHandler.GenerateSecretPassword(20));
    end;

    internal procedure GetSetupKey(): SecretText
    begin
        exit(GetSecretStorage(SetupKeyLbl));
    end;

    internal procedure ResetSetupKey()
    begin
        DeleteIsolatedStorage(SetupKeyLbl);
    end;


    internal procedure GetInstallationId() Result: SecretText
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
        EnvironmentInformation: Codeunit "Environment Information";
        InstallationIdLbl: Label 'InstallationId', Locked = true;
    begin
        if EnvironmentInformation.IsSaaS() then
            exit(AzureADTenant.GetAadTenantId());

        Result := GetSecretStorage(InstallationIdLbl);
        if not Result.IsEmpty() then
            exit;

        Result := Format(CreateGuid()).TrimStart('{').TrimEnd('}');
        SetSecretStorage(InstallationIdLbl, Result);
    end;

    internal procedure ResetForSetup()
    begin
        ValidateClientId('');
        ValidateForNAVTenantID('');
        ValidateSecret(SecretStrSubstNo(''));
        ValidateScope('');
        ValidateEndpoint('', false);
        ValidateSecretValidTo(CreateDateTime(0D, 0T));
        ResetSetupKey();
    end;

    internal procedure GetPeppolEndpointURL(): Text
    var
        PeppolAPEndpointLbl: Label 'PeppolAPEndpoint', Locked = true;
    begin
        exit(GetPeppolURL(PeppolAPEndpointLbl));
    end;

    local procedure GetPeppolSetupURL(): Text
    var
        ForNAVPeppolConfigLbl: Label 'ForNAVPeppolConfig', Locked = true;
    begin
        exit(GetPeppolURL(ForNAVPeppolConfigLbl));
    end;

    local procedure GetPeppolURL(Function: Text) Url: Text
    begin
        Url := BaseUrlLbl + Function + '/' + GetEndpoint();
        if Url.EndsWith('/') then
            exit(Url)
        else
            exit(Url + '/');
    end;

    internal procedure GetOAuthAuthorityUrl(): Text
    var
        OAuthAuthorityUrlTxt: Label 'https://login.microsoftonline.com/%1/oauth2/v2.0/token', Locked = true;
    begin
        exit(StrSubstNo(OAuthAuthorityUrlTxt, GetForNAVTenantID()));
    end;

    [TryFunction]
    internal procedure TryTestOAuth()
    begin
        TestOAuth();
    end;

    internal procedure TestOAuth(): Boolean
    var
        SendContex: Codeunit SendContext;
        Setup: Codeunit "ForNAV Peppol Setup";
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        EndpointLbl: Label '%1Test', Locked = true;
        HttpErrLbl: Label 'Http error: %1\Reason: %2', Comment = '%1= statuscode %2= reasonphrase', Locked = true;
    begin
        Setup.ClearAccessToken();
        if GetClientID() = '' then
            Error(InvalidCLientIdErr);

        HttpRequestMessage := SendContex.Http().GetHttpRequestMessage();
        HttpRequestMessage.SetRequestUri(StrSubstNo(EndpointLbl, GetPeppolEndpointURL()));
        HttpRequestMessage.Method('GET');

        if Setup.Send(HttpClient, SendContex.Http()) = 200 then
            exit(true);

        HttpResponseMessage := SendContex.Http().GetHttpResponseMessage();
        if GetLastErrorText() = '' then
            Error(HttpErrLbl, HttpResponseMessage.HttpStatusCode, HttpResponseMessage.ReasonPhrase)
        else
            Error(GetLastErrorText());
    end;

    internal procedure StoreRoles(Roles: List of [Text])
    var
        PeppolRole: Record "ForNAV Peppol Role";
        i: Integer;
    begin
        PeppolRole.DeleteAll();
        for i := 1 to Roles.Count do begin
            PeppolRole.Init();
            PeppolRole.Role := CopyStr(Roles.Get(i), 1, MaxStrLen(PeppolRole.Role));
            PeppolRole.Insert();
        end;
    end;

    [NonDebuggable]
    internal procedure SendSetupRequest(IsSaas: Boolean): Boolean
    var
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
    begin
        if IsSaas then
            HttpRequestMessage.SetRequestUri(GetPeppolSetupURL() + RequestConfigLbl)
        else
            HttpRequestMessage.SetRequestUri(GetPeppolSetupURL() + RequestConfigFileLbl);

        HttpRequestMessage.GetHeaders(HttpHeaders);
        AddSetupHeaders(HttpHeaders);
        HttpRequestMessage.Method('POST');
        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);
        exit(HttpResponseMessage.HttpStatusCode = 204);
    end;

    [NonDebuggable]
    internal procedure GetSetupFile(PassCode: SecretText; IdentificationValue: Text): Boolean
    var
        PeppolCrypto: Codeunit "ForNAV Peppol Crypto";
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        HashText: Text;
        Response: Text;
        jObject: JsonObject;
        jToken: JsonToken;
    begin
        HttpRequestMessage.SetRequestUri(GetPeppolSetupURL() + RequestConfigFileLbl);

        HttpRequestMessage.GetHeaders(HttpHeaders);
        AddSetupHeaders(HttpHeaders);
        HttpHeaders.Add('passcode', PassCode);
        HttpRequestMessage.Method('GET');
        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);
        if HttpResponseMessage.HttpStatusCode <> 200 then
            exit(false);

        HttpResponseMessage.Content.ReadAs(Response);
        if not jObject.ReadFrom(Response) then
            Error(HttpResponseMessage.ReasonPhrase);

        jObject.Get('hash', jToken);
        HashText := jToken.AsValue().AsText();
        PeppolCrypto.TestHash(HashText, StrSubstNo('%1-%2', CompanyName, IdentificationValue), GetInstallationId());

        jObject.Get('clientId', jToken);
        ValidateClientId(jToken.AsValue().AsText());
        jObject.Get('clientSecret', jToken);
        ValidateSecret(jToken.AsValue().AsText());
        jObject.Get('scope', jToken);
        ValidateScope(jToken.AsValue().AsText());
        jObject.Get('endpoint', jToken);
        ValidateEndpoint(jToken.AsValue().AsText(), false);
        jObject.Get('tenantId', jToken);
        ValidateForNAVTenantID(jToken.AsValue().AsText());
        jObject.Get('expires', jToken);
        ValidateSecretValidTo(jToken.AsValue().AsDateTime());
        exit(true);
    end;

    internal procedure GetNewSecurityKey(): Boolean
    var
        OAuthToken: Codeunit "ForNAV Peppol Oauth Token";
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        AccessToken: SecretText;
        AccessTokenExpires: DateTime;
        Response: Text;
        jObject: JsonObject;
        jToken: JsonToken;
        CannotRotateKeyErr: Label 'Cannot rotate key. Contact your ForNAV partner.\%1', Comment = '%1 = reason', Locked = true;
    begin
        HttpRequestMessage.SetRequestUri(GetPeppolSetupURL() + RotateSecretLbl);

        HttpRequestMessage.GetHeaders(HttpHeaders);
        AddSetupHeaders(HttpHeaders);

        OAuthToken.AcquireTokenWithClientCredentials(GetClientID(), GetClientSecret(), GetOAuthAuthorityUrl(), '', GetScopeConfig());
        OAuthToken.GetAccessToken(AccessToken, AccessTokenExpires);

        HttpHeaders.Add('Authorization', SecretStrSubstNo('Bearer %1', AccessToken));

        HttpRequestMessage.Method('POST');
        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);
        if HttpResponseMessage.HttpStatusCode <> 200 then
            error(CannotRotateKeyErr, HttpResponseMessage.ReasonPhrase);

        HttpResponseMessage.Content.ReadAs(Response);
        if not jObject.ReadFrom(Response) then
            Error(HttpResponseMessage.ReasonPhrase);

        jObject.Get('clientId', jToken);
        if GetClientID() <> jToken.AsValue().AsText() then
            Error(InvalidCLientIdErr);

        jObject.Get('clientSecret', jToken);
        ValidateSecret(jToken.AsValue().AsText());
        jObject.Get('expires', jToken);
        ValidateSecretValidTo(jToken.AsValue().AsDateTime());
        exit(true);
    end;

    local procedure AddSetupHeaders(var HttpHeaders: HttpHeaders)
    var
        Company: Record Company;
        PeppolSetup: Record "ForNAV Peppol Setup";
        EnvironmentInformation: Codeunit "Environment Information";
        AppInfo: ModuleInfo;
    begin
        PeppolSetup.InitSetup();
        HttpHeaders.Add(SetupKeyLbl, GetSetupKey());
        HttpHeaders.Add('tenantId', GetInstallationId());
        HttpHeaders.Add('environmentName', EnvironmentInformation.GetEnvironmentName());
        Company.Get(CompanyName);
        HttpHeaders.Add('companyId', Format(Company.SystemId).TrimStart('{').TrimEnd('}'));
        HttpHeaders.Add('companyName', HtmlEncode(PeppolSetup.Name));
        HttpHeaders.Add('idCode', HtmlEncode(PeppolSetup."Identification Code"));
        HttpHeaders.Add('idValue', HtmlEncode(PeppolSetup."Identification Value"));
        HttpHeaders.Add('serialNumber', Database.SerialNumber());
        HttpHeaders.Add('contactName', HtmlEncode(PeppolSetup."Contact Person"));
        HttpHeaders.Add('contactEmail', PeppolSetup."E-Mail");
        NavApp.GetCurrentModuleInfo(AppInfo);
        HttpHeaders.Add('appVersion', HtmlEncode(Format(AppInfo.AppVersion)));
        HttpHeaders.Add('appPublisher', HtmlEncode(Format(AppInfo.Publisher)));
    end;

    local procedure SwapEndpoint(NewEndpoint: Text): Boolean
    var
        OAuthToken: Codeunit "ForNAV Peppol Oauth Token";
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        AccessToken: SecretText;
        AccessTokenExpires: DateTime;
        Response: Text;
        jObject: JsonObject;
        jToken: JsonToken;
        CannotSwapEndpointErr: Label 'Cannot swap endpoint. Contact your ForNAV partner.\%1', Comment = '%1 = reason', Locked = true;
    begin
        case true of
            GetEndpoint() = NewEndpoint,
            not TryTestOAuth():
                exit(false);
        end;

        HttpRequestMessage.SetRequestUri(GetPeppolSetupURL() + SwapEndpointLbl);

        HttpRequestMessage.GetHeaders(HttpHeaders);
        AddSetupHeaders(HttpHeaders);
        HttpHeaders.Add('endpoint', NewEndpoint);

        OAuthToken.AcquireTokenWithClientCredentials(GetClientID(), GetClientSecret(), GetOAuthAuthorityUrl(), '', GetScopeConfig());
        OAuthToken.GetAccessToken(AccessToken, AccessTokenExpires);

        HttpHeaders.Add('Authorization', SecretStrSubstNo('Bearer %1', AccessToken));

        HttpRequestMessage.Method('POST');
        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);
        if HttpResponseMessage.HttpStatusCode <> 200 then
            error(CannotSwapEndpointErr, HttpResponseMessage.ReasonPhrase);

        HttpResponseMessage.Content.ReadAs(Response);
        if not jObject.ReadFrom(Response) then
            Error(HttpResponseMessage.ReasonPhrase);

        jObject.Get('clientId', jToken);
        if GetClientID() <> jToken.AsValue().AsText() then
            Error(InvalidCLientIdErr);

        jObject.Get('endpoint', jToken);
        ValidateEndpoint(jToken.AsValue().AsText(), false);
        jObject.Get('scope', jToken);
        ValidateScope(jToken.AsValue().AsText());
        exit(true);
    end;

    local procedure HTMLEncode(Input: Text): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(TypeHelper.HtmlEncode(Input));
    end;
}