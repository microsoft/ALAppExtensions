// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

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
        MTDOAuth20Mgt: Codeunit "MTD OAuth 2.0 Mgt";
        ConnectionMethodWebClientTxt: Label 'WEB_APP_VIA_SERVER', Locked = true;
        ProdNameTxt: Label 'Microsoft Dynamics 365 Business Central', Locked = true;
        ProdNameOnPremSuffixTxt: Label ' OnPrem', Locked = true;
        DefaultProdVersionTxt: Label '25.0.0.0', Locked = true;
        IPAddressErr: Label 'Public IP address lookup failed. Specify a service that will return the public IP address of the current user.';
        IPAddressOkTxt: Label 'Public IP address lookup was successful.';
        LicenseTxt: Label 'Microsoft_Dynamics_365_Business_Central,AadTenantId=%1,TenantId=%2,Start=%3,End=%4', Locked = true;
        ClientScreensTxt: Label 'width=%1&height=%2&scaling-factor=1&colour-depth=%3', Locked = true;
        ClientWindowTxt: Label 'width=%1&height=%2', Locked = true;
        HMRCFraudPreventHeadersTok: label 'HMRC Fraud Prevention Headers', Locked = true;
        NoFPHeadersFromJSErr: Label 'No FP headers were returned from JS.', Locked = true;
        GetPublicIPAddressRequestFailedErr: Label 'Getting server public IP address from public service failed.', Locked = true;

    internal procedure AddFraudPreventionHeaders(var RequestJSON: Text; ConfirmHeaders: Boolean)
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
        vendorIP: Text;
        clientIP: Text;
        VendorForwarded: Text;
    begin
        VATReportSetup.Get();
        VATReportSetup.TestField("MTD FP Public IP Service URL");

        MTDSessionFraudPrevHdr.SafeInsert('Gov-Client-Connection-Method', GetConnectionMethod());
        MTDSessionFraudPrevHdr.SafeInsert('Gov-Vendor-Version', GetVendorVersion());
        MTDSessionFraudPrevHdr.SafeInsert('Gov-Vendor-Product-Name', GetProdName());
        MTDSessionFraudPrevHdr.SafeInsert('Gov-Vendor-License-IDs', GetVendorLicenseIDs());
        MTDSessionFraudPrevHdr.SafeInsert('Gov-Client-User-IDs', GetClientUserIDs());

        MTDWebClientFPHeaders.SetPublicIPServiceURL(VATReportSetup."MTD FP Public IP Service URL");
        Commit();
        MTDWebClientFPHeaders.RunModal();

        if GetVendorIP(vendorIP, VATReportSetup."MTD FP Public IP Service URL") then;
        MTDSessionFraudPrevHdr.SafeInsert('Gov-Vendor-Public-IP', vendorIP);

        if MTDSessionFraudPrevHdr.Get('Gov-Client-Public-IP') then
            clientIP := MTDSessionFraudPrevHdr.Value;
        if (clientIP <> '') and (vendorIP <> '') then
            VendorForwarded := 'by=' + vendorIP + '&for=' + clientIP;
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
                ClientScreensTxt,
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

    [TryFunction]
    internal procedure GetVendorIP(var Result: Text; url: Text)
    var
        Matches: Record Matches;
        Regex: Codeunit Regex;
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        CustomDimensions: Dictionary of [Text, Text];
        Content: Text;
        RegExString: Text;
    begin
        Result := '';
        if MTDOAuth20Mgt.GetServerPublicIPFromAzureFunction(Result) then
            if Result <> '' then
                exit;

        HttpClient.Get(url, HttpResponseMessage);
        if not HttpResponseMessage.IsSuccessStatusCode() then begin
            CustomDimensions.Add('url', url);
            CustomDimensions.Add('HttpStatusCode', Format(HttpResponseMessage.HttpStatusCode()));
            CustomDimensions.Add('ReasonPhrase', HttpResponseMessage.ReasonPhrase);
            CustomDimensions.Add('IsBlockedByEnvironment', Format(HttpResponseMessage.IsBlockedByEnvironment()));
            FeatureTelemetry.LogError('0000NRN', HMRCFraudPreventHeadersTok, '', GetPublicIPAddressRequestFailedErr, '', CustomDimensions);
        end;
        HttpResponseMessage.Content().ReadAs(Content);
        RegExString := '([0-9]{1,3}(\.[0-9]{1,3}){3})|(([0-9A-Fa-f]{0,4}:){2,7}([0-9A-Fa-f]{1,4}))';
        Regex.Match(Content, RegExString, 0, Matches);
        if Matches.FindFirst() then
            Result := Matches.ReadValue();
    end;

    internal procedure TestPublicIPServiceURL(url: Text)
    var
        MTDSessionFraudPrevHdr: Record "MTD Session Fraud Prev. Hdr";
        MTDWebClientFPHeaders: Page "MTD Web Client FP Headers";
        Result: Text;
    begin
        if not GetVendorIP(Result, url) then
            Error(IPAddressErr);

        if Result = '' then
            Error(IPAddressErr);

        MTDSessionFraudPrevHdr.DeleteAll();
        MTDWebClientFPHeaders.SetPublicIPServiceURL(url);
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
