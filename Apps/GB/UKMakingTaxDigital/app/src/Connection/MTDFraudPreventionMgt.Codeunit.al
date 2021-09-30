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

    // Calculated on APP level:
    // Gov-Vendor-License-IDs
    // Gov-Client-Local-IPs-Timestamp
    // Gov-Client-Public-IP-Timestamp
    // Gov-Client-Timezone
    // Gov-Client-Multi-Factor

    // Calculated using WMI queries:
    // Gov-Client-Public-IP = Win32_NetworkAdapterConfiguration.IPAddress
    // Gov-Client-Local-IPs = Win32_NetworkAdapterConfiguration.IPAddress
    // Gov-Client-Device-ID = Win32_ComputerSystemProduct.UUID
    // Gov-Client-User-IDs = Win32_ComputerSystem.UserName
    // Gov-Client-MAC-Addresses = Win32_NetworkAdapterConfiguration.MACAddress
    // Gov-Client-Screens = Win32_DesktopMonitor + Win32_VideoController
    // Gov-Client-User-Agent = Win32_OperatingSystem.Version + Win32_ComputerSystemProduct.[Vendor,Version,Name]
    // Gov-Vendor-Public-IP = Win32_NetworkAdapterConfiguration.IPAddress

    // None:
    // Gov-Client-Public-Port
    // Gov-Client-Window-Size
    // Gov-Client-Browser-Plugins
    // Gov-Client-Browser-JS-User-Agent
    // Gov-Client-Browser-Do-Not-Track
    // Gov-Vendor-Forwarded

    var
        ClientWMIBuffer: Record "Name/Value Buffer" temporary;
        ServerWMIBuffer: Record "Name/Value Buffer" temporary;
        ClientPublicIPsBuffer: Record "Name/Value Buffer" temporary;
        ClientLocalIPsBuffer: Record "Name/Value Buffer" temporary;
        ServerPublicIPsBuffer: Record "Name/Value Buffer" temporary;
        TypeHelper: Codeunit "Type Helper";
        OnPrem: Boolean;
        WebClient: Boolean;
        WinClient: Boolean;
        BatchClient: Boolean;
        ConnectionMethodWinClientTxt: Label 'DESKTOP_APP_VIA_SERVER', Locked = true;
        ConnectionMethodWebClientTxt: Label 'WEB_APP_VIA_SERVER', Locked = true;
        ConnectionMethodBatchClientTxt: Label 'BATCH_PROCESS_DIRECT', Locked = true;
        ProdNameTxt: Label 'Microsoft Dynamics 365 Business Central', Locked = true;
        ProdNameOnPremSuffixTxt: Label ' OnPrem', Locked = true;
        DefaultProdVersionTxt: Label '19.0.0.0', Locked = true;
        DefaultOSFamilyTxt: Label 'Windows', Locked = true;
        WMI_OSInfo_FieldTxt: Label 'Version,CurrentTimeZone', Locked = true;
        WMI_OSInfo_WhereTxt: Label 'Primary=''true'' and Name like ''%Windows%''', Locked = true;
        WMI_DeviceInfo_FieldTxt: Label 'UUID,Vendor,Version,Name', Locked = true;
        WMI_DeviceInfo_WhereTxt: Label 'UUID is not null and Vendor is not null and Name is not null', Locked = true;
        WMI_SysInfo_FieldTxt: Label 'UserName', Locked = true;
        WMI_SysInfo_WhereTxt: Label 'UserName is not null', Locked = true;
        WMI_Screen_FieldTxt: Label 'CurrentBitsPerPixel,CurrentHorizontalResolution,CurrentVerticalResolution', Locked = true;
        WMI_Screen_WhereTxt: Label 'CurrentBitsPerPixel is not null and CurrentHorizontalResolution is not null and CurrentVerticalResolution is not null', Locked = true;
        WMI_Monitor_FieldTxt: Label 'ScreenHeight,ScreenWidth', Locked = true;
        WMI_Monitor_WhereTxt: Label 'ScreenHeight is not null and ScreenWidth is not null', Locked = true;
        WMI_Network_FieldTxt: Label 'IPAddress,MACAddress', Locked = true;
        WMI_Network_WhereTxt: Label 'MACAddress is not null', Locked = true;
        WMI_Win32_OperatingSystemTxt: Label 'Win32_OperatingSystem', Locked = true;
        WMI_Win32_ComputerSystemProductTxt: Label 'Win32_ComputerSystemProduct', Locked = true;
        WMI_Win32_ComputerSystemTxt: Label 'Win32_ComputerSystem', Locked = true;
        WMI_Win32_DesktopMonitorTxt: Label 'Win32_DesktopMonitor', Locked = true;
        WMI_Win32_VideoControllerTxt: Label 'Win32_VideoController', Locked = true;
        WMI_Win32_NetworkAdapterConfigurationTxt: Label 'Win32_NetworkAdapterConfiguration', Locked = true;
        TimeStamp: Text;
        GovClientPublicIPDescTxt: Label 'The public IPv4 or IPv6 address from which the originating device makes the request.';
        GovClientPublicIPTimestampDescTxt: Label 'A timestamp to show when Gov-Client-Public-IP is collected.';
        GovClientPublicPortDescTxt: Label 'The public TCP port used by the originating device when initiating the request.';
        GovClientScreensDescTxt: Label 'Information about the originating device''s screens.';
        GovClientTimezoneDescTxt: Label 'The local timezone of the originating device.';
        GovClientUserAgentDescTxt: Label 'Identifies the operating system and device.';
        GovClientUserIDsDescTxt: Label 'A key-value data structure containing user identifiers.';
        GovClientWindowSizeDescTxt: Label 'The number of pixels of the window on the originating device.';
        GovVendorForwardedDescTxt: Label 'A list that details hops over the internet between services that terminate Transport Layer Security (TLS).';
        GovVendorPublicIPDescTxt: Label 'The public IP address of the servers the originating device sent their requests to.';
        GovClientDeviceIDDescTxt: Label 'An identifier unique to the originating device.';
        GovClientLocalIPsDescTxt: Label 'A list of all local IPv4 and IPv6 addresses available to the originating device.';
        GovClientLocalIPsTimestampDescTxt: Label 'A timestamp to show when Gov-Client-Local-IPs is collected.';
        GovClientMACAddressesDescTxt: Label 'The list of MAC addresses available on the originating device.';
        GovClientMultiFactorDescTxt: Label 'A list of key-value data structures containing details of the multi-factor authentication (MFA) statuses related to the API call.';
        GovClientBrowserDoNotTrackDescTxt: Label 'A true or false value describing if the Do Not Track option is enabled on the browser.';
        GovClientBrowserJSUserAgentDescTxt: Label 'JavaScript-reported user agent string from the originating device.';
        GovClientBrowserPluginsDescTxt: Label 'A list of browser plugins on the originating device.';
        MissingHeadersMsg: Label 'The following fraud prevention headers were missing in the latest HMRC request:\\%1', Comment = '%1 - a list of the missing headers';
        OpenHeadersSetupMsg: Label 'Communication with HMRC without fraud prevention headers is not allowed. Set up the missing headers in the HMRC Fraud Prevention Headers Setup page, and specify a default value for each of them. Choose the Get Current Headers action to see which headers cannot be retrieved automatically.';
        NoMissingHeaderMsg: Label 'All required fraud prevention headers were provided in the latest HMRC request.';
        ConfirmHeadersQst: Label 'HMRC requires additional information that will be used to uniquely identify your request. The following fraud prevention headers will be sent:\\%1\If you accept that the data in the list is sent, choose the Yes button to continue. If you do not continue, the current HMRC communication will be cancelled, and no data will be sent or received.\Do you want to continue?', Comment = '%1 - a list of missing headers';

    internal procedure CheckInitDefaultHeadersList()
    var
        MTDDefaultFraudPrevHdr: Record "MTD Default Fraud Prev. Hdr";
    begin
        MTDDefaultFraudPrevHdr.DeleteAll();
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Client-Public-IP', GovClientPublicIPDescTxt, '51.145.159.126');
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Client-Local-IPs', GovClientLocalIPsDescTxt, '192.168.1.1');
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Client-Public-IP-Timestamp', GovClientPublicIPTimestampDescTxt, '');
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Client-Local-IPs-Timestamp', GovClientLocalIPsTimestampDescTxt, '');
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Client-MAC-Addresses', GovClientMACAddressesDescTxt, '18%3A60%3A24%3A95%3AE9%3A46');
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Client-Device-ID', GovClientDeviceIDDescTxt, 'D4F4EA59-CBD8-FD2A-0856-2779013B105C');
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Client-User-IDs', GovClientUserIDsDescTxt, '');
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Client-Timezone', GovClientTimezoneDescTxt, 'UTC+01:00');
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Client-Screens', GovClientScreensDescTxt, 'width=1920&height=1080&scaling-factor=1&colour-depth=32');
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Client-User-Agent', GovClientUserAgentDescTxt, 'os-family=Windows&os-version=10.0.19043&device-manufacturer=HP&device-model=HP+EliteDesk+800+G3+SFF');
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Client-Multi-Factor', GovClientMultiFactorDescTxt, '');
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Vendor-Public-IP', GovVendorPublicIPDescTxt, '51.145.159.126');
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Client-Public-Port', GovClientPublicPortDescTxt, '7045');
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Client-Window-Size', GovClientWindowSizeDescTxt, 'width=1920&height=1080');
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Client-Browser-Plugins', GovClientBrowserPluginsDescTxt, '-');
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Client-Browser-JS-User-Agent', GovClientBrowserJSUserAgentDescTxt, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36');
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Client-Browser-Do-Not-Track', GovClientBrowserDoNotTrackDescTxt, 'false');
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Vendor-Forwarded', GovVendorForwardedDescTxt, 'by=51.145.159.126&for=51.145.159.126');
    end;

    procedure CheckForMissingHeadersFromSetup()
    var
        MTDMissingFraudPrevHdr: Record "MTD Missing Fraud Prev. Hdr";
        MsgBuffer: Text;
    begin
        if MTDMissingFraudPrevHdr.IsEmpty() then begin
            Message(NoMissingHeaderMsg);
            exit;
        end;

        MsgBuffer := StrSubstNo(MissingHeadersMsg, MTDMissingFraudPrevHdr.GetHeadersListString());
        Message(MsgBuffer);
    end;

    procedure GenerateSampleValues(var TempSampleMTDDefaultFraudPrevHdr: Record "MTD Default Fraud Prev. Hdr" temporary)
    var
        MTDSessionFraudPrevHdr: Record "MTD Session Fraud Prev. Hdr";
    begin
        Init();
        MTDSessionFraudPrevHdr.DeleteAll();
        InvokeWMIQueries();
        GenerateSessionHeaders();

        TempSampleMTDDefaultFraudPrevHdr.DeleteAll();
        if MTDSessionFraudPrevHdr.FindSet() then
            repeat
                TempSampleMTDDefaultFraudPrevHdr.FromSessionHeader(MTDSessionFraudPrevHdr);
            until MTDSessionFraudPrevHdr.Next() = 0;
        MTDSessionFraudPrevHdr.DeleteAll();
    end;

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

        Init();
        MTDMissingFraudPrevHdr.DeleteAll();
        CheckInitDefaultHeadersList();
        ConfirmHeaders := ConfirmHeaders and GuiAllowed() and MTDSessionFraudPrevHdr.IsEmpty();
        if MTDSessionFraudPrevHdr.IsEmpty() then begin
            InvokeWMIQueries();
            GenerateSessionHeaders();
            ApplyDefaultToMissing();
        end;

        CopySessionHeaders(JObject);
        JObject.WriteTo(RequestJSON);
    end;

    procedure CheckForMissingHeadersAndConfirm(var ErrorMessage: Text): Boolean
    var
        MTDMissingFraudPrevHdr: Record "MTD Missing Fraud Prev. Hdr";
        MTDSessionFraudPrevHdr: Record "MTD Session Fraud Prev. Hdr";
    begin
        if MTDMissingFraudPrevHdr.IsEmpty() then
            exit(Confirm(StrSubstNo(ConfirmHeadersQst, MTDSessionFraudPrevHdr.GetHeadersListString()), false));

        ErrorMessage := StrSubstNo(MissingHeadersMsg, MTDMissingFraudPrevHdr.GetHeadersListString());
        ErrorMessage := StrSubstNo('%1\%2', ErrorMessage, OpenHeadersSetupMsg);
    end;

    local procedure Init()
    var
        EnvironmentInfo: Codeunit "Environment Information";
        ClientTypeMgt: Codeunit "Client Type Management";
    begin
        OnPrem := EnvironmentInfo.IsOnPrem();

        case ClientTypeMgt.GetCurrentClientType() of
            ClientType::Windows:
                WinClient := true;
            ClientType::Phone,
            ClientType::Tablet,
            ClientType::Web:
                WebClient := true;
            else
                BatchClient := true;
        end;
        TimeStamp := GetTimeStamp();
    end;

    local procedure GenerateSessionHeaders()
    var
        MTDSessionFraudPrevHdr: Record "MTD Session Fraud Prev. Hdr";
        TextValue: Text;
    begin
        MTDSessionFraudPrevHdr.SafeInsert('Gov-Client-Connection-Method', GetConnectionMethod());
        MTDSessionFraudPrevHdr.SafeInsert('Gov-Vendor-Version', GetVendorVersion());
        MTDSessionFraudPrevHdr.SafeInsert('Gov-Vendor-Product-Name', GetProdName());
        MTDSessionFraudPrevHdr.SafeInsert('Gov-Vendor-License-IDs', GetVendorLicenseIDs());

        if GetClientPublicIPs(TextValue) then
            MTDSessionFraudPrevHdr.SafeInsert('Gov-Client-Public-IP', TextValue);
        if GetClientDeviceID(TextValue) then
            MTDSessionFraudPrevHdr.SafeInsert('Gov-Client-Device-ID', TextValue);
        if GetClientUserIDs(TextValue) then
            MTDSessionFraudPrevHdr.SafeInsert('Gov-Client-User-IDs', TextValue);
        if GetClientTimezone(TextValue) then
            MTDSessionFraudPrevHdr.SafeInsert('Gov-Client-Timezone', TextValue);

        if not BatchClient then begin
            if GetClientLocalIPs(TextValue) then
                MTDSessionFraudPrevHdr.SafeInsert('Gov-Client-Local-IPs', TextValue);
            if GetClientScreens(TextValue) then
                MTDSessionFraudPrevHdr.SafeInsert('Gov-Client-Screens', TextValue);
            if GetClientMultiFactor(TextValue) then
                MTDSessionFraudPrevHdr.SafeInsert('Gov-Client-Multi-Factor', TextValue);
            if GetVendorPublicIPs(TextValue) then
                MTDSessionFraudPrevHdr.SafeInsert('Gov-Vendor-Public-IP', TextValue);
        end;

        if not WebClient then begin
            if GetClientMACAddresses(TextValue) then
                MTDSessionFraudPrevHdr.SafeInsert('Gov-Client-MAC-Addresses', TextValue);
            if GetClientUserAgent(TextValue) then
                MTDSessionFraudPrevHdr.SafeInsert('Gov-Client-User-Agent', TextValue);
        end;
    end;

    local procedure ApplyDefaultToMissing()
    var
        MTDSessionFraudPrevHdr: Record "MTD Session Fraud Prev. Hdr";
    begin
        if CheckApplyDefault('Gov-Client-Public-IP') then
            MTDSessionFraudPrevHdr.SafeInsert('Gov-Client-Public-IP-Timestamp', TimeStamp);
        CheckApplyDefault('Gov-Client-Device-ID');
        CheckApplyDefault('Gov-Client-User-IDs');
        CheckApplyDefault('Gov-Client-Timezone');

        if not BatchClient then begin
            CheckApplyDefault('Gov-Client-Public-Port');
            if CheckApplyDefault('Gov-Client-Local-IPs') then
                MTDSessionFraudPrevHdr.SafeInsert('Gov-Client-Local-IPs-Timestamp', TimeStamp);
            CheckApplyDefault('Gov-Client-Screens');
            CheckApplyDefault('Gov-Client-Window-Size');
            CheckApplyDefault('Gov-Client-Multi-Factor');
            CheckApplyDefault('Gov-Vendor-Public-IP');
            CheckApplyDefault('Gov-Vendor-Forwarded');
        end;

        if WebClient then begin
            CheckApplyDefault('Gov-Client-Browser-Plugins');
            CheckApplyDefault('Gov-Client-Browser-JS-User-Agent');
            CheckApplyDefault('Gov-Client-Browser-Do-Not-Track');
        end else begin
            CheckApplyDefault('Gov-Client-MAC-Addresses');
            CheckApplyDefault('Gov-Client-User-Agent');
        end;
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

    local procedure CheckApplyDefault(Header: Code[100]): Boolean
    var
        MTDMissingFraudPrevHdr: Record "MTD Missing Fraud Prev. Hdr";
        MTDDefaultFraudPrevHdr: Record "MTD Default Fraud Prev. Hdr";
        MTDSessionFraudPrevHdr: Record "MTD Session Fraud Prev. Hdr";
        Value: Text;
    begin
        Value := '';
        if MTDSessionFraudPrevHdr.Get(Header) then
            Value := MTDSessionFraudPrevHdr.Value;
        if Value = '' then begin
            if MTDDefaultFraudPrevHdr.Get(Header) then
                Value := MTDDefaultFraudPrevHdr.Value;
            if Value <> '' then
                MTDSessionFraudPrevHdr.SafeInsert(Header, Value)
            else
                MTDMissingFraudPrevHdr.SafeInsert(Header);
        end;
        exit(Value <> '');
    end;

    local procedure GetConnectionMethod(): Text
    begin
        case true of
            WinClient:
                exit(ConnectionMethodWinClientTxt);
            WebClient:
                exit(ConnectionMethodWebClientTxt);
            BatchClient:
                exit(ConnectionMethodBatchClientTxt);
        end;
    end;

    local procedure GetVendorVersion(): Text
    var
        ProdVersion: Text;
    begin
        ProdVersion := GetProdVersion();
        exit(StrSubstNo('%1=%2', GetProdName(), TypeHelper.UrlEncode(ProdVersion)));
    end;

    local procedure GetProdName() Result: Text
    begin
        Result := ProdNameTxt;
        if OnPrem then
            Result += ProdNameOnPremSuffixTxt;
        TypeHelper.UrlEncode(Result);
    end;

    local procedure GetProdVersion(): Text
    var
        AppSysConst: Codeunit "Application System Constants";
        ValueArr: array[4] of Integer;
        VersionTxt: Text;
    begin
        VersionTxt := AppSysConst.BuildFileVersion();
        if ParseIPv4Address(ValueArr, VersionTxt) then
            if ValueArr[1] <> 0 then
                exit(VersionTxt);
        exit(DefaultProdVersionTxt);
    end;

    local procedure GetClientPublicIPs(var Result: Text): Boolean
    begin
        exit(GetBufferValues(Result, ClientPublicIPsBuffer, 'Win32_NetworkAdapterConfiguration.IPAddress', 1));
    end;

    local procedure GetClientDeviceID(var Result: Text): Boolean
    begin
        if not GetBufferValue(Result, 'Win32_ComputerSystemProduct.UUID') then
            exit(false);
        Result := TypeHelper.UrlEncode(Result);
        exit(Result <> '');
    end;

    local procedure GetClientUserIDs(var Result: Text): Boolean
    begin
        if not GetBufferValue(Result, 'Win32_ComputerSystem.UserName') then
            if not GetUserId(Result) then
                exit(false);

        Result := StrSubstNo('%1=%2', GetProdName(), TypeHelper.UrlEncode(Result));
        exit(Result <> '');
    end;

    local procedure GetClientTimezone(var Result: Text): Boolean
    var
        Hours: Integer;
        Minutes: Integer;
    begin
        if not GetTimezoneOffset(Hours, Minutes) then
            exit(false);

        Result :=
            StrSubstNo('UTC%1%2:%3',
                Format(Hours + Minutes, 0, '<Sign,1><Filler Character,+>'),
                Format(Hours, 0, '<Integer,2><Filler Character,0>'),
                Format(Minutes, 0, '<Integer,2><Filler Character,0>'));

        exit(Result <> '');
    end;

    local procedure GetClientLocalIPs(var Result: Text): Boolean
    begin
        exit(GetBufferValues(Result, ClientLocalIPsBuffer, 'Win32_NetworkAdapterConfiguration.IPAddress', 0));
    end;

    local procedure GetClientMACAddresses(var Result: Text): Boolean
    begin
        exit(GetBufferValues(Result, ClientWMIBuffer, 'Win32_NetworkAdapterConfiguration.MACAddress', 0));
    end;

    local procedure GetClientScreens(var Result: Text): Boolean
    begin
        if BatchClient then
            exit(false);

        if GetBufferValue(Result, 'Win32_DesktopMonitor.ScreenHeight') then
            exit(GetClientMonitorScreens(Result));

        exit(GetClientVideoScreens(Result));
    end;

    local procedure GetClientMonitorScreens(var Result: Text): Boolean
    var
        Width: Integer;
        Height: Integer;
    begin
        if GetBufferValue(Result, 'Win32_DesktopMonitor.ScreenWidth') then
            if not Evaluate(Width, Result) then
                exit(false);
        if GetBufferValue(Result, 'Win32_DesktopMonitor.ScreenHeight') then
            if not Evaluate(Height, Result) then
                exit(false);

        Result := StrSubstNo('width=%1&height=%2&scaling-factor=1', Width, Height);
        exit(Result <> '');
    end;

    local procedure GetClientVideoScreens(var Result: Text): Boolean
    var
        Width: Integer;
        Height: Integer;
        BPP: Integer;
    begin
        if GetBufferValue(Result, 'Win32_VideoController.CurrentHorizontalResolution') then
            if not Evaluate(Width, Result) then
                exit(false);
        if GetBufferValue(Result, 'Win32_VideoController.CurrentVerticalResolution') then
            if not Evaluate(Height, Result) then
                exit(false);
        if GetBufferValue(Result, 'Win32_VideoController.CurrentBitsPerPixel') then
            if Evaluate(BPP, Result) then;

        if (Width = 0) or (Height = 0) then
            exit(false);

        Result := StrSubstNo('width=%1&height=%2&scaling-factor=1', Width, Height);
        if BPP <> 0 then
            Result += StrSubstNo('&colour-depth=%1', BPP);

        exit(Result <> '');
    end;

    local procedure GetClientUserAgent(var Result: Text): Boolean
    var
        OSFamily: Text;
        OSVersion: Text;
        DeviceVendor: Text;
        DeviceVersion: Text;
        DeviceName: Text;
    begin
        if WebClient then
            exit(false);

        OSFamily := DefaultOSFamilyTxt;
        GetBufferValue(OSVersion, 'Win32_OperatingSystem.Version');
        GetBufferValue(DeviceVendor, 'Win32_ComputerSystemProduct.Vendor');
        GetBufferValue(DeviceVersion, 'Win32_ComputerSystemProduct.Version');
        GetBufferValue(DeviceName, 'Win32_ComputerSystemProduct.Name');

        if (DeviceVersion <> '') and (DeviceVersion <> ' ') then
            DeviceName := StrSubstNo('%1_%2', DeviceVersion, DeviceName);

        Result :=
            StrSubstNo('os-family=%1&os-version=%2&device-manufacturer=%3&device-model=%4',
                TypeHelper.UrlEncode(OSFamily), TypeHelper.UrlEncode(OSVersion),
                TypeHelper.UrlEncode(DeviceVendor), TypeHelper.UrlEncode(DeviceName));
        exit(Result <> '');
    end;

    local procedure GetVendorLicenseIDs(): Text
    var
        TenantSettings: Codeunit "Tenant Information";
        AzureADTenant: Codeunit "Azure AD Tenant";
        TenantLicenseState: Codeunit "Tenant License State";
        ProdName: Text;
        Hashed: Text;
    begin
        ProdName := ProdNameTxt;
        Hashed :=
            StrSubstNo(
                'Microsoft_Dynamics_365_Business_Central,AadTenantId=%1,TenantId=%2,Start=%3,End=%4',
                AzureADTenant.GetAadTenantId(), TenantSettings.GetTenantId(),
                TenantLicenseState.GetStartDate(), TenantLicenseState.GetEndDate());
        Hashed := GenerateHash(Hashed);
        exit(StrSubstNo('%1=%2', TypeHelper.UrlEncode(ProdName), Hashed));
    end;

    local procedure GenerateHash(InputString: Text): Text
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
    begin
        exit(CryptographyManagement.GenerateHash(InputString, HashAlgorithmType::SHA256));
    end;

    local procedure GetVendorPublicIPs(var Result: Text): Boolean
    begin
        if BatchClient then
            exit(false);

        exit(GetBufferValues(Result, ServerPublicIPsBuffer, 'Win32_NetworkAdapterConfiguration.IPAddress', 1));
    end;

    local procedure GetUserId(var Result: Text): Boolean
    begin
        Result := UserId();
        exit(Result <> '');
    end;

    local procedure GetTimezoneOffset(var Hours: Integer; var Minutes: Integer): Boolean
    var
        dur: Duration;
    begin
        if not TypeHelper.GetUserTimezoneOffset(dur) then
            exit(false);

        Minutes := dur / 60000;
        Hours := Minutes div 60;
        Minutes := Minutes mod 60;
        exit(true);
    end;

    local procedure GetClientMultiFactor(var Result: Text): Boolean
    begin
        if not GetBufferValue(Result, 'Win32_ComputerSystem.UserName') then
            if not GetUserId(Result) then
                exit(false);

        Result := StrSubstNo('%1 %2', ProdNameTxt, Result);
        Result := GenerateHash(Result);
        Result := StrSubstNo('type=OTHER&timestamp=%1&unique-reference=%2', TypeHelper.UrlEncode(TimeStamp), Result);
        exit(Result <> '');
    end;

    local procedure InvokeWMIQueries()
    var
        ServerLocalIPsBuffer: Record "Name/Value Buffer" temporary;
        DummyValue: Text;
    begin
        InvokeWMIQueue(false, WMI_OSInfo_FieldTxt, WMI_Win32_OperatingSystemTxt, WMI_OSInfo_WhereTxt);
        InvokeWMIQueue(false, WMI_SysInfo_FieldTxt, WMI_Win32_ComputerSystemTxt, WMI_SysInfo_WhereTxt);
        InvokeWMIQueue(false, WMI_DeviceInfo_FieldTxt, WMI_Win32_ComputerSystemProductTxt, WMI_DeviceInfo_WhereTxt);
        InvokeWMIQueue(false, WMI_Monitor_FieldTxt, WMI_Win32_DesktopMonitorTxt, WMI_Monitor_WhereTxt);
        if not GetBufferValue(DummyValue, 'Win32_DesktopMonitor.ScreenHeight') then
            InvokeWMIQueue(false, WMI_Screen_FieldTxt, WMI_Win32_VideoControllerTxt, WMI_Screen_WhereTxt);
        InvokeWMIQueue(false, WMI_Network_FieldTxt, WMI_Win32_NetworkAdapterConfigurationTxt, WMI_Network_WhereTxt);
        if WinClient then
            InvokeWMIQueue(true, WMI_Network_FieldTxt, WMI_Win32_NetworkAdapterConfigurationTxt, WMI_Network_WhereTxt);
        SplitLocalAndPublicIPAddresses(ClientWMIBuffer, ClientLocalIPsBuffer, ClientPublicIPsBuffer);
        SplitLocalAndPublicIPAddresses(ServerWMIBuffer, ServerLocalIPsBuffer, ServerPublicIPsBuffer);
    end;

    local procedure GetBufferValue(var Result: Text; PropertyName: Text): Boolean
    begin
        if WinClient then
            exit(GetGivenBufferValue(Result, ClientWMIBuffer, PropertyName));

        exit(GetGivenBufferValue(Result, ServerWMIBuffer, PropertyName));
    end;

    local procedure GetGivenBufferValue(var Result: Text; var Buffer: Record "Name/Value Buffer"; PropertyName: Text): Boolean
    begin
        Result := '';
        with Buffer do begin
            SetRange(Name, PropertyName);
            if not FindFirst() then
                exit(false);
            Result := Value;
            exit(Result <> '');
        end;
    end;

    local procedure GetBufferValues(var Result: Text; var Buffer: Record "Name/Value Buffer"; PropertyName: Text; limit: Integer): Boolean
    var
        NextValue: Text;
    begin
        // limit = 0 means unlimit, i.e. all values
        Result := '';
        with Buffer do begin
            SetRange(Name, PropertyName);
            if FindSet() then
                repeat
                    if Result <> '' then
                        Result += ',';
                    NextValue := Value;
                    Result += TypeHelper.UrlEncode(NextValue);
                    limit -= 1;
                until (Next() = 0) or (limit = 0);
        end;
        exit(Result <> '');
    end;

    local procedure SplitLocalAndPublicIPAddresses(
                        var Buffer: Record "Name/Value Buffer";
                        var LocalIPsBuffer: Record "Name/Value Buffer";
                        var PublicIPsBuffer: Record "Name/Value Buffer")
                    : Boolean
    var
        IsLocal: Boolean;
    begin
        LocalIPsBuffer.DeleteAll();
        PublicIPsBuffer.DeleteAll();

        with Buffer do begin
            SetRange(Name, 'Win32_NetworkAdapterConfiguration.IPAddress');
            if not FindSet() then
                exit(false);

            repeat
                if IsIPv4Address(Value) then
                    IsLocal := IsLocalIPv4Address(Value)
                else
                    IsLocal := IsLocalIPv6Address(Value);

                if IsLocal then
                    LocalIPsBuffer.AddNewEntry(Name, Value)
                else
                    PublicIPsBuffer.AddNewEntry(Name, Value)
            until Next() = 0;
        end;

        exit(true);
    end;

    local procedure IsIPv4Address(IPAddressTxt: Text): Boolean
    begin
        exit(StrPos(IPAddressTxt, '.') <> 0);
    end;

    local procedure IsLocalIPv4Address(IPAddressTxt: Text): Boolean
    var
        IPByte: array[4] of Integer;
    begin
        if ParseIPv4Address(IPByte, IPAddressTxt) then
            exit(
                (IPByte[1] = 10) or
                (IPByte[1] = 172) and (IPByte[2] >= 16) and (IPByte[2] <= 31) or
                (IPByte[1] = 192) and (IPByte[2] = 168));
        exit(false);
    end;

    local procedure IsLocalIPv6Address(IPAddressTxt: Text): Boolean
    begin
        exit(StrPos(LowerCase(IPAddressTxt), 'fe80::') = 1);
    end;

    local procedure ParseIPv4Address(var IPByte: array[4] of Integer; IPAddressTxt: Text): Boolean
    var
        dotpos: Integer;
        bytepos: Integer;
    begin
        // Parse format: IPByte[0].IPByte[1].IPByte[2].IPByte[3]
        // IPByte[0] is the major byte
        if IPAddressTxt = '' then
            exit(false);

        dotpos := StrPos(IPAddressTxt, '.');
        if (dotpos < 2) or (dotpos > 4) then
            exit(false);

        bytepos := 1;
        while (dotpos > 1) and (bytepos < 4) do begin
            if not Evaluate(IPByte[bytepos], CopyStr(IPAddressTxt, 1, dotpos - 1)) then
                exit(false);
            IPAddressTxt := CopyStr(IPAddressTxt, dotpos + 1, StrLen(IPAddressTxt) - dotpos);
            dotpos := StrPos(IPAddressTxt, '.');
            bytepos += 1;
        end;

        if bytepos <> 4 then
            exit(false);
        if not Evaluate(IPByte[bytepos], IPAddressTxt) then
            exit(false);

        exit(true);
    end;

    local procedure InvokeWMIQueue(ForceServer: Boolean; QueueField: Text; QueueTable: Text; QueueWhere: Text): Boolean
    var
        BufferSource: Record "Name/Value Buffer" temporary;
        [RunOnClient]
        ClientMgtObjSearcher: DotNet MTD_ManagementObjectSearcher;
        [RunOnClient]
        ClientMgtObj: DotNet MTD_ManagementObject;
        [RunOnClient]
        ClientProperty: DotNet MTD_PropertyData;
        [RunOnClient]
        ClientIEnumerable: DotNet IEnumerable;
        [RunOnClient]
        ClientIEnumerator: DotNet IEnumerator;
        [RunOnClient]
        ClientIEnumerator2: DotNet IEnumerator;
        [RunOnClient]
        ClientIEnumerator3: DotNet IEnumerator;
        ServerMgtObjSearcher: DotNet MTD_ManagementObjectSearcher;
        ServerMgtObj: DotNet MTD_ManagementObject;
        ServerProperty: DotNet MTD_PropertyData;
        ServerIEnumerable: DotNet IEnumerable;
        ServerIEnumerator: DotNet IEnumerator;
        ServerIEnumerator2: DotNet IEnumerator;
        ServerIEnumerator3: DotNet IEnumerator;
        QueueTxt: Text;
        WinClientLcl: Boolean;
    begin
        QueueTxt := StrSubstNo('select %1 from %2', QueueField, QueueTable);
        if QueueWhere <> '' then
            QueueTxt += StrSubstNo(' where %1', QueueWhere);

        WinClientLcl := not ForceServer and WinClient;
        if WinClientLcl then
            BufferSource.Copy(ClientWMIBuffer, true)
        else
            BufferSource.Copy(ServerWMIBuffer, true);

        if WinClientLcl then
            exit(
                TryInvokeWMIQueue(
                    BufferSource, QueueTable, QueueTxt, ClientMgtObjSearcher, ClientMgtObj, ClientProperty,
                    ClientIEnumerable, ClientIEnumerator, ClientIEnumerator2, ClientIEnumerator3));

        exit(
            TryInvokeWMIQueue(
                BufferSource, QueueTable, QueueTxt, ServerMgtObjSearcher, ServerMgtObj, ServerProperty,
                ServerIEnumerable, ServerIEnumerator, ServerIEnumerator2, ServerIEnumerator3));
    end;

    [TryFunction]
    local procedure TryInvokeWMIQueue(
                        var Buffer: Record "Name/Value Buffer";
                        Scope: Text;
                        QueryText: Text;
                        MgtObjSearcher: dotnet MTD_ManagementObjectSearcher;
                        MgtObj: DotNet MTD_ManagementObject;
                        Property: DotNet MTD_PropertyData;
                        IEnumerable: DotNet IEnumerable;
                        IEnumerator: DotNet IEnumerator;
                        IEnumerator2: DotNet IEnumerator;
                        IEnumerator3: DotNet IEnumerator)
    begin
        // Try invoke WMI query
        // Parse ALL returned System Management Object records
        // Parse ALL Properties per Object
        // Parse ALL array Values per Property
        IEnumerator := MgtObjSearcher.ManagementObjectSearcher(QueryText).Get().GetEnumerator();
        if not IsNull(IEnumerator) then
            while IEnumerator.MoveNext() do begin
                MgtObj := IEnumerator.Current();
                IEnumerator2 := MgtObj.Properties().GetEnumerator();
                if not IsNull(IEnumerator2) then
                    while IEnumerator2.MoveNext() do begin
                        Property := IEnumerator2.Current();
                        if not IsNull(Property.Value()) then
                            if Property.IsArray() then begin
                                IEnumerable := Property.Value();
                                if not IsNull(IEnumerable) then begin
                                    IEnumerator3 := IEnumerable.GetEnumerator();
                                    if not IsNull(IEnumerator3) then
                                        while IEnumerator3.MoveNext() do
                                            AddUniqueNotEmptyBufferValue(Buffer, Scope, Format(Property.Name()), Format(IEnumerator3.Current()));
                                end;
                            end else
                                AddUniqueNotEmptyBufferValue(Buffer, Scope, Format(Property.Name()), Format(Property.Value()));
                    end;
            end;
    end;

    local procedure AddUniqueNotEmptyBufferValue(var Buffer: Record "Name/Value Buffer"; Scope: Text; Name: Text; Value: Text)
    var
        Buffer2: Record "Name/Value Buffer" temporary;
        NameLcl: Text[250];
        ValueLcl: Text[250];
    begin
        if (Scope = '') or (Name = '') or (Value = '') then
            exit;
        NameLcl := CopyStr(StrSubstNo('%1.%2', Scope, Name), 1, MaxStrLen(Buffer.Name));
        ValueLcl := CopyStr(Value, 1, MaxStrLen(Buffer.Value));
        Buffer2.Copy(Buffer, true);
        Buffer2.SetRange(Name, NameLcl);
        Buffer2.SetRange(Value, ValueLcl);
        if Buffer2.IsEmpty() then
            Buffer2.AddNewEntry(NameLcl, ValueLcl);
    end;

    local procedure GetTimeStamp(): Text
    begin
        exit(Format(TypeHelper.GetCurrUTCDateTime(), 0, 9));
    end;
}
