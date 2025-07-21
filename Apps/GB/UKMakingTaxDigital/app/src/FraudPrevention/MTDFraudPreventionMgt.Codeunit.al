// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

codeunit 10541 "MTD Fraud Prevention Mgt."
{
    // Hardcoded:
    // Gov-Client-Connection-Method
    // Gov-Vendor-Version
    // Gov-Vendor-Product-Name

    // Calculated here in cod 10541:
    // Gov-Vendor-License-IDs
    // Gov-Client-User-IDs
    // Gov-Vendor-Forwarded
    // Gov-Vendor-Public-IP

    // Calculated using Web Client JS:
    // Gov-Client-Browser-Do-Not-Track
    // Gov-Client-Browser-JS-User-Agent
    // Gov-Client-Device-ID
    // Gov-Client-Public-IP
    // Gov-Client-Public-IP-Timestamp
    // Gov-Client-Screens
    // Gov-Client-Timezone
    // Gov-Client-Window-Size

    // Excluded:
    // Gov-Client-Public-Port
    // Gov-Client-Multi-Factor

    var
        TypeHelper: Codeunit "Type Helper";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        EnvironmentInformation: Codeunit "Environment Information";
        ConnectionMethodWebClientTxt: Label 'WEB_APP_VIA_SERVER', Locked = true;
        ProdNameTxt: Label 'Microsoft Dynamics 365 Business Central', Locked = true;
        ProdNameOnPremSuffixTxt: Label ' OnPrem', Locked = true;
        DefaultProdVersionTxt: Label '25.0.0.0', Locked = true;
        IPAddressErr: Label 'Public IP address lookup failed. Specify a service that will return the public IP address of the current user.';
        IPAddressOkTxt: Label 'Public IP address lookup was successful.';
        LicenseTxt: Label 'Microsoft_Dynamics_365_Business_Central,AadTenantId=%1,TenantId=%2,Start=%3,End=%4', Locked = true;
        GovClientScreensTxt: Label 'width=%1&height=%2&scaling-factor=1&colour-depth=%3', Locked = true;
        ClientWindowTxt: Label 'width=%1&height=%2', Locked = true;
        HMRCFraudPreventHeadersTok: label 'HMRC Fraud Prevention Headers', Locked = true;
        NoFPHeadersFromJSErr: Label 'No FP headers were returned from JS.', Locked = true;
        FraudPreventHeadersValidTxt: Label 'Fraud prevention headers are valid. ', Locked = true;
        FraudPreventHeadersNotValidTxt: Label 'Fraud prevention headers are NOT valid. ', Locked = true;
        JsonTextBlankErr: Label 'JSON text is blank. ', Locked = true;
        CannotReadJsonErr: Label 'Cannot read JSON. ', Locked = true;
        JsonKeyMissingErr: Label 'JSON key %1 is missing. ', Locked = true;
        CannotReadJsonValueErr: Label 'Cannot read value from JSON key %1. ', Locked = true;
        JsonValueBlankErr: Label 'Value from key %1 is blank. ', Locked = true;
        JsonValueNotMatchedErr: Label 'Value from key %1 does not match validation pattern %2. ', Locked = true;
        ClientBrowserDoNotTrackTxt: Label 'GOV-CLIENT-BROWSER-DO-NOT-TRACK', Locked = true;
        ClientBrowserJsUserAgentTxt: Label 'GOV-CLIENT-BROWSER-JS-USER-AGENT', Locked = true;
        ClientConnectionMethodTxt: Label 'GOV-CLIENT-CONNECTION-METHOD', Locked = true;
        ClientDeviceIdTxt: Label 'GOV-CLIENT-DEVICE-ID', Locked = true;
        ClientPublicIpTxt: Label 'GOV-CLIENT-PUBLIC-IP', Locked = true;
        ClientPublicIpTimestampTxt: Label 'GOV-CLIENT-PUBLIC-IP-TIMESTAMP', Locked = true;
        ClientScreensTxt: Label 'GOV-CLIENT-SCREENS', Locked = true;
        ClientTimezoneTxt: Label 'GOV-CLIENT-TIMEZONE', Locked = true;
        ClientUserIdsTxt: Label 'GOV-CLIENT-USER-IDS', Locked = true;
        ClientWindowSizeTxt: Label 'GOV-CLIENT-WINDOW-SIZE', Locked = true;
        VendorForwardedTxt: Label 'GOV-VENDOR-FORWARDED', Locked = true;
        VendorLicenseIdsTxt: Label 'GOV-VENDOR-LICENSE-IDS', Locked = true;
        VendorProductNameTxt: Label 'GOV-VENDOR-PRODUCT-NAME', Locked = true;
        VendorPublicIpTxt: Label 'GOV-VENDOR-PUBLIC-IP', Locked = true;
        VendorVersionTxt: Label 'GOV-VENDOR-VERSION', Locked = true;
        EmptyPublicIPAddressErr: Label 'Empty server public IP address was returned.', Locked = true;
        NonEmptyPublicIPAddressTxt: Label 'Non-empty server public IP address was returned by tenant settings', Locked = true;
        IPAddressNotMatchPatternErr: Label 'IP address from tenant settings does not match validation pattern %1. ', Locked = true;
        IPv4LoopbackIPAddressTxt: Label '127.0.0.1', Locked = true;
        IPv6LoopbackIPAddressTxt: Label '::1', Locked = true;
        IPAddressRegExPatternTxt: Label '[0-9]{1,3}(\.[0-9]{1,3}){3}|([0-9A-Fa-f]{0,4}:){2,7}([0-9A-Fa-f]{1,4})', Locked = true;

    internal procedure AddFraudPreventionHeaders(var RequestJSON: Text)
    var
        MTDMissingFraudPrevHdr: Record "MTD Missing Fraud Prev. Hdr";
        MTDSessionFraudPrevHdr: Record "MTD Session Fraud Prev. Hdr";
        JToken: JsonToken;
        JObject: JsonObject;
    begin
        if JObject.ReadFrom(RequestJSON) then;
        if JObject.SelectToken('Header', JToken) then
            if JToken.AsObject().Contains('GOV-CLIENT-CONNECTION-METHOD') then
                exit;

        MTDMissingFraudPrevHdr.DeleteAll();
        MTDSessionFraudPrevHdr.DeleteAll();
        GenerateSessionHeaders();

        CopySessionHeaders(JObject);
        JObject.WriteTo(RequestJSON);
    end;

    local procedure GenerateSessionHeaders()
    var
        VATReportSetup: Record "VAT Report Setup";
        MTDSessionFraudPrevHdr: Record "MTD Session Fraud Prev. Hdr";
        MTDWebClientFPHeaders: Page "MTD Web Client FP Headers";
        ServerIP: Text;
        ClientIP: Text;
        VendorForwarded: Text;
    begin
        MTDSessionFraudPrevHdr.SafeInsert('Gov-Client-Connection-Method', GetConnectionMethod());
        MTDSessionFraudPrevHdr.SafeInsert('Gov-Vendor-Version', GetVendorVersion());
        MTDSessionFraudPrevHdr.SafeInsert('Gov-Vendor-Product-Name', GetProdName());
        MTDSessionFraudPrevHdr.SafeInsert('Gov-Vendor-License-IDs', GetVendorLicenseIDs());
        MTDSessionFraudPrevHdr.SafeInsert('Gov-Client-User-IDs', GetClientUserIDs());

        VATReportSetup.Get();
        if not EnvironmentInformation.IsSaaS() then
            VATReportSetup.TestField("MTD FP Public IP Service URL");

        // public client IP address
        MTDWebClientFPHeaders.SetPublicIPServiceURL(VATReportSetup."MTD FP Public IP Service URL", false);
        Commit();
        MTDWebClientFPHeaders.RunModal();

        // public server IP address
        if EnvironmentInformation.IsSaaS() then begin
            if GetServerPublicIPFromTenantSettings(ServerIP) then;
        end else
            if GetServerPublicIPFromExternalService(ServerIP, VATReportSetup."MTD FP Public IP Service URL") then;
        MTDSessionFraudPrevHdr.SafeInsert('Gov-Vendor-Public-IP', ServerIP);

        if MTDSessionFraudPrevHdr.Get('Gov-Client-Public-IP') then
            ClientIP := MTDSessionFraudPrevHdr.Value;
        if (ClientIP <> '') and (ServerIP <> '') then
            VendorForwarded := 'by=' + ServerIP + '&for=' + ClientIP;
        MTDSessionFraudPrevHdr.SafeInsert('Gov-Vendor-Forwarded', VendorForwarded);
    end;

    local procedure CopySessionHeaders(var JObject: JsonObject)
    var
        MTDSessionFraudPrevHdr: Record "MTD Session Fraud Prev. Hdr";
        JToken: JsonToken;
        DummyJObject: JsonObject;
    begin
        if not JObject.Contains('Header') then
            JObject.Add('Header', DummyJObject);
        if JObject.SelectToken('Header', JToken) then
            if MTDSessionFraudPrevHdr.FindSet() then
                repeat
                    if not JToken.AsObject().Contains(MTDSessionFraudPrevHdr.Header) then
                        JToken.AsObject().Add(MTDSessionFraudPrevHdr.Header, MTDSessionFraudPrevHdr.Value);
                until MTDSessionFraudPrevHdr.Next() = 0;
    end;

    local procedure GetConnectionMethod(): Text
    begin
        exit(ConnectionMethodWebClientTxt);
    end;

    local procedure GetVendorVersion(): Text
    var
        ProdVersion: Text;
    begin
        ProdVersion := GetProdVersion();
        exit(GetProdName() + '=' + TypeHelper.UrlEncode(ProdVersion));
    end;

    local procedure GetProdName() Result: Text
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        Result := ProdNameTxt;
        if EnvironmentInformation.IsOnPrem() then
            Result += ProdNameOnPremSuffixTxt;
        TypeHelper.UrlEncode(Result);
    end;

    local procedure GetProdVersion(): Text
    var
        ApplicationSystemConstants: Codeunit "Application System Constants";
        VersionTxt: Text;
        TextValue: Text;
    begin
        VersionTxt := ApplicationSystemConstants.BuildFileVersion();
        VersionTxt.Split('.').Get(2, TextValue);
        if (TextValue <> '') and (TextValue <> '0') then
            exit(VersionTxt);
        exit(DefaultProdVersionTxt);
    end;

    local procedure GetClientUserIDs(): Text
    var
        TextValue: Text;
    begin
        TextValue := UserId();
        exit(GetProdName() + '=' + TypeHelper.UrlEncode(TextValue));
    end;

    local procedure GetVendorLicenseIDs(): Text
    var
        TenantInformation: Codeunit "Tenant Information";
        AzureADTenant: Codeunit "Azure AD Tenant";
        TenantLicenseState: Codeunit "Tenant License State";
        ProdName: Text;
        Hashed: Text;
    begin
        ProdName := ProdNameTxt;
        Hashed :=
            StrSubstNo(
                LicenseTxt,
                AzureADTenant.GetAadTenantId(), TenantInformation.GetTenantId(),
                TenantLicenseState.GetStartDate(), TenantLicenseState.GetEndDate());
        Hashed := GenerateHash(Hashed);
        exit(TypeHelper.UrlEncode(ProdName) + '=' + Hashed);
    end;

    local procedure GenerateHash(InputString: Text): Text
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
    begin
        exit(CryptographyManagement.GenerateHash(InputString, HashAlgorithmType::SHA256));
    end;

    internal procedure SetSessionFPHeadersFromJS(var JSHeadersJson: JsonObject)
    var
        MTDSessionFraudPrevHdr: Record "MTD Session Fraud Prev. Hdr";
    begin
        if JSHeadersJson.Keys.Count = 0 then
            FeatureTelemetry.LogError('0000NRM', HMRCFraudPreventHeadersTok, '', NoFPHeadersFromJSErr);

        MTDSessionFraudPrevHdr.SafeInsert('Gov-Client-Public-IP', GetJsonValue(JSHeadersJson, 'publicIP'));
        MTDSessionFraudPrevHdr.SafeInsert('Gov-Client-Public-IP-Timestamp', GetJsonValue(JSHeadersJson, 'timestamp'));
        MTDSessionFraudPrevHdr.SafeInsert('Gov-Client-Device-ID', GetJsonValue(JSHeadersJson, 'deviceID'));
        MTDSessionFraudPrevHdr.SafeInsert('Gov-Client-Timezone', GetJsonValue(JSHeadersJson, 'timezone'));
        MTDSessionFraudPrevHdr.SafeInsert('Gov-Client-Browser-JS-User-Agent', GetJsonValue(JSHeadersJson, 'browserUserAgent'));
        MTDSessionFraudPrevHdr.SafeInsert('Gov-Client-Browser-Do-Not-Track', GetJsonValue(JSHeadersJson, 'browserDoNotTrack'));

        MTDSessionFraudPrevHdr.SafeInsert(
            'Gov-Client-Screens',
            StrSubstNo(
                GovClientScreensTxt,
                GetJsonValue(JSHeadersJson, 'screenWidth'),
                GetJsonValue(JSHeadersJson, 'screenHeight'),
                GetJsonValue(JSHeadersJson, 'screenColorDepth')));

        MTDSessionFraudPrevHdr.SafeInsert(
            'Gov-Client-Window-Size',
            StrSubstNo(ClientWindowTxt, GetJsonValue(JSHeadersJson, 'windowWidth'), GetJsonValue(JSHeadersJson, 'windowHeight')));
    end;

    local procedure GetJsonValue(var Json: JsonObject; KeyName: Text): Text
    var
        token: JsonToken;
    begin
        if Json.Get(KeyName, token) then
            exit(token.AsValue().AsText());
    end;

    internal procedure LogFraudPreventionHeadersValidity(RequestJSON: Text)
    var
        CustomDimensions: Dictionary of [Text, Text];
        JsonObject: JsonObject;
        HeaderJsonToken: JsonToken;
        ErrorText: Text;
        ClientIPAddrErrorText: Text;
        VendorIPAddrErrorText: Text;
    begin
        if RequestJSON = '' then begin
            FeatureTelemetry.LogError('0000LJE', HMRCFraudPreventHeadersTok, '', JsonTextBlankErr);
            exit;
        end;

        if not JsonObject.ReadFrom(RequestJSON) then begin
            FeatureTelemetry.LogError('0000LJF', HMRCFraudPreventHeadersTok, '', CannotReadJsonErr);
            exit;
        end;

        if not JsonObject.Get('Header', HeaderJsonToken) then begin
            FeatureTelemetry.LogError('0000LJG', HMRCFraudPreventHeadersTok, '', StrSubstNo(JsonKeyMissingErr, 'Header'));
            exit;
        end;

        JsonObject := HeaderJsonToken.AsObject();

        ClientIPAddrErrorText := CheckJsonTokenValidity(JsonObject, ClientPublicIpTxt, IPAddressRegExPatternTxt);   // IPv4 or IPv6
        VendorIPAddrErrorText := CheckJsonTokenValidity(JsonObject, VendorPublicIpTxt, IPAddressRegExPatternTxt);   // IPv4 or IPv6
        ErrorText += ClientIPAddrErrorText;
        ErrorText += VendorIPAddrErrorText;
        CustomDimensions.Add('IsClientIPAddressLoopback', Format(IsLoopbackIPAddress(GetJsonValue(JsonObject, ClientPublicIpTxt))));
        CustomDimensions.Add('IsVendorIPAddressLoopback', Format(IsLoopbackIPAddress(GetJsonValue(JsonObject, VendorPublicIpTxt))));

        ErrorText += CheckJsonTokenValidity(JsonObject, ClientBrowserDoNotTrackTxt, 'true|false');              // true or false
        ErrorText += CheckJsonTokenValidity(JsonObject, ClientBrowserJsUserAgentTxt, '\w+');                    // any letter, digit, or underscore
        ErrorText += CheckJsonTokenValidity(JsonObject, ClientConnectionMethodTxt, 'WEB_APP_VIA_SERVER');       // WEB_APP_VIA_SERVER
        ErrorText += CheckJsonTokenValidity(JsonObject, ClientDeviceIdTxt, '\w+');                              // any letter, digit, or underscore
        ErrorText += CheckJsonTokenValidity(JsonObject, ClientPublicIpTimestampTxt, '\d+[:\.-]\d+[:\.-]\d+');   // for example 13:00:00
        ErrorText += CheckJsonTokenValidity(JsonObject, ClientScreensTxt, '^(?=.*width)(?=.*height).*$');       // width and height must be present in any order
        ErrorText += CheckJsonTokenValidity(JsonObject, ClientTimezoneTxt, '[-+]\d{1,2}');                      // for example +02
        ErrorText += CheckJsonTokenValidity(JsonObject, ClientUserIdsTxt, 'Business.*Central');                 // Business Central
        ErrorText += CheckJsonTokenValidity(JsonObject, ClientWindowSizeTxt, '^(?=.*width)(?=.*height).*$');    // width and height must be present in any order
        ErrorText += CheckJsonTokenValidity(JsonObject, VendorForwardedTxt, IPAddressRegExPatternTxt);  // IPv4 or IPv6
        ErrorText += CheckJsonTokenValidity(JsonObject, VendorLicenseIdsTxt, 'Business.*Central.*\w+');         // Business Central and any letter, digit, or underscore
        ErrorText += CheckJsonTokenValidity(JsonObject, VendorProductNameTxt, 'Business.*Central');             // Business Central
        ErrorText += CheckJsonTokenValidity(JsonObject, VendorVersionTxt, 'Business.*Central.*=\d+');           // for example Business Central=23

        if ErrorText <> '' then
            FeatureTelemetry.LogError('0000LJH', HMRCFraudPreventHeadersTok, FraudPreventHeadersNotValidTxt, ErrorText, '', CustomDimensions)
        else
            FeatureTelemetry.LogUsage('0000LJI', HMRCFraudPreventHeadersTok, FraudPreventHeadersValidTxt);
    end;

    internal procedure LogClientPublicIPInfo(JSHeadersJson: JsonObject)
    var
        ClientPublicIP: Text;
        ClientPublicIPSource: Text;
        CustomDimensions: Dictionary of [Text, Text];
    begin
        ClientPublicIP := GetJsonValue(JSHeadersJson, 'publicIP');
        CustomDimensions.Add('IsClientIPAddressEmpty', Format(ClientPublicIP = ''));
        CustomDimensions.Add('IsClientIPAddressLoopback', Format(IsLoopbackIPAddress(ClientPublicIP)));
        CustomDimensions.Add('IsClientIPAddressMatchRegex', Format(MatchRegexPattern(ClientPublicIP, IPAddressRegExPatternTxt))); // IPv4 or IPv6

        ClientPublicIPSource := GetJsonValue(JSHeadersJson, 'publicIPSource');
        CustomDimensions.Add('ClientPublicIPSource', ClientPublicIPSource);

        FeatureTelemetry.LogUsage('0000PFB', HMRCFraudPreventHeadersTok, 'ClientPublicIPSource', CustomDimensions);
    end;

    local procedure CheckJsonTokenValidity(var JsonObject: JsonObject; TokenKey: Text; ValidationRegExPattern: Text) ErrorText: Text
    var
        JsonToken: JsonToken;
        TextValue: Text;
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then begin
            ErrorText := StrSubstNo(JsonKeyMissingErr, TokenKey);
            exit;
        end;

        if not JsonToken.WriteTo(TextValue) then begin
            ErrorText := StrSubstNo(CannotReadJsonValueErr, TokenKey);
            exit;
        end;

        if TextValue = '' then begin
            ErrorText := StrSubstNo(JsonValueBlankErr, TokenKey);
            exit;
        end;

        if not MatchRegexPattern(TextValue, ValidationRegExPattern) then begin
            ErrorText := StrSubstNo(JsonValueNotMatchedErr, TokenKey, ValidationRegExPattern);
            exit;
        end;
    end;

    local procedure MatchRegexPattern(InputString: Text; RegExPattern: Text): Boolean
    var
        RegEx: DotNet Regex;
        RegExOptions: DotNet RegexOptions;
    begin
        RegEx := RegEx.Regex(RegExPattern, RegExOptions.IgnoreCase);
        exit(RegEx.IsMatch(InputString));
    end;

    local procedure IsLoopbackIPAddress(IPAddress: Text): Boolean
    begin
        exit((IPAddress = IPv4LoopbackIPAddressTxt) or (IPAddress = IPv6LoopbackIPAddressTxt));
    end;

    [TryFunction]
    internal procedure GetServerPublicIPFromTenantSettings(var ServerIPAddress: Text)
    var
        TenantSettings: DotNet NavTenantSettingsHelper;
    begin
        if not EnvironmentInformation.IsSaaS() then
            exit;

        ServerIPAddress := '';
        ServerIPAddress := TenantSettings.GetPublicIpAddress();

        if ServerIPAddress = '' then begin
            FeatureTelemetry.LogError('0000O1D', HMRCFraudPreventHeadersTok, '', EmptyPublicIPAddressErr);
            exit;
        end;

        if not MatchRegexPattern(ServerIPAddress, IPAddressRegExPatternTxt) then begin
            FeatureTelemetry.LogError('0000O1E', HMRCFraudPreventHeadersTok, '', StrSubstNo(IPAddressNotMatchPatternErr, IPAddressRegExPatternTxt));
            ServerIPAddress := '';
            exit;
        end;

        FeatureTelemetry.LogUsage('0000O1F', HMRCFraudPreventHeadersTok, NonEmptyPublicIPAddressTxt);
    end;

    [TryFunction]
    internal procedure GetServerPublicIPFromExternalService(var ServerIPAddress: Text; PublicIPServiceURL: Text)
    var
        Matches: Record Matches;
        Regex: Codeunit Regex;
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        Content: Text;
    begin
        ServerIPAddress := '';
        HttpClient.Get(PublicIPServiceURL, HttpResponseMessage);
        HttpResponseMessage.Content().ReadAs(Content);
        Regex.Match(Content, IPAddressRegExPatternTxt, 0, Matches);
        if Matches.FindFirst() then
            ServerIPAddress := Matches.ReadValue();
    end;

    internal procedure TestPublicIPServiceURL(url: Text)
    var
        MTDSessionFraudPrevHdr: Record "MTD Session Fraud Prev. Hdr";
        MTDWebClientFPHeaders: Page "MTD Web Client FP Headers";
        ServerIPAddress: Text;
    begin
        if url = '' then
            exit;

        // test getting server public IP address
        if not GetServerPublicIPFromExternalService(ServerIPAddress, url) then
            Error(IPAddressErr);
        if ServerIPAddress = '' then
            Error(EmptyPublicIPAddressErr);

        // test getting client public IP address
        MTDSessionFraudPrevHdr.DeleteAll();
        MTDWebClientFPHeaders.SetPublicIPServiceURL(url, true);
        Commit();
        MTDWebClientFPHeaders.RunModal();
        if not MTDSessionFraudPrevHdr.Get('Gov-Client-Public-IP') then
            Error(IPAddressErr);

        if MTDSessionFraudPrevHdr.Value = '' then
            Error(IPAddressErr);

        Message(IPAddressOkTxt);
        MTDSessionFraudPrevHdr.DeleteAll();
    end;
}
