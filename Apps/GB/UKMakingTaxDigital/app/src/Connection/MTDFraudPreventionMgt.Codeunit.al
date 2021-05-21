// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 10541 "MTD Fraud Prevention Mgt."
{
    var
        VATReportSetup: Record "VAT Report Setup";
        ClientWMIBuffer: Record "Name/Value Buffer" temporary;
        ServerWMIBuffer: Record "Name/Value Buffer" temporary;
        ClientPublicIPsBuffer: Record "Name/Value Buffer" temporary;
        ClientLocalIPsBuffer: Record "Name/Value Buffer" temporary;
        ServerPublicIPsBuffer: Record "Name/Value Buffer" temporary;
        TypeHelper: Codeunit "Type Helper";
        JObject: JsonObject;
        OnPrem: Boolean;
        WebClient: Boolean;
        WinClient: Boolean;
        BatchClient: Boolean;
        ConnectionMethodWinClientTxt: Label 'DESKTOP_APP_VIA_SERVER', Locked = true;
        ConnectionMethodWebClientTxt: Label 'WEB_APP_VIA_SERVER', Locked = true;
        ConnectionMethodBatchClientTxt: Label 'BATCH_PROCESS_DIRECT', Locked = true;
        ProdNameTxt: Label 'Microsoft_Dynamics_365_Business_Central', Locked = true;
        ProdNameOnPremSuffixTxt: Label '_OnPrem', Locked = true;
        DefaultProdVersionTxt: Label '16.0.0.0', Locked = true;
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

    local procedure Init()
    var
        EnvironmentInfo: Codeunit "Environment Information";
        ClientTypeMgt: Codeunit "Client Type Management";
    begin
        VATReportSetup.Get();
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
    end;

    internal procedure GenerateFraudPreventionHeaders() Result: Text
    var
        ConnectionMethod: Text;
    begin
        Init();
        if VATReportSetup."MTD Disable FraudPrev. Headers" then
            exit;

        if not GetConnectionMethod(ConnectionMethod) then
            exit;

        CollectData();
        JObject.Add('Gov-Client-Connection-Method', ConnectionMethod);
        JObject.Add('Gov-Vendor-Version', GetVendorVersion());
        JObject.WriteTo(Result);
    end;

    local procedure CollectData()
    begin
        with VATReportSetup do
            case true of
                WinClient:
                    CollectDataForClient("MTD FP WinClient Due DateTime", FieldNo("MTD FP WinClient Json"));
                WebClient:
                    CollectDataForClient("MTD FP WebClient Due DateTime", FieldNo("MTD FP WebClient Json"));
                BatchClient:
                    CollectDataForClient("MTD FP Batch Due DateTime", FieldNo("MTD FP Batch Json"));
            end;
    end;

    local procedure CollectDataForClient(var DueDateTime: DateTime; JsonFieldNo: Integer)
    var
        TempBlob: Codeunit "Temp Blob";
        RecordRef: RecordRef;
        Expired: Boolean;
        OutStream: OutStream;
        InStream: InStream;
        JsonText: Text;
    begin
        Expired := true;
        if DueDateTime <> 0DT then
            Expired := DueDateTime < CurrentDateTime();
        TempBlob.FromRecord(VATReportSetup, JsonFieldNo);
        if not TempBlob.HasValue() or Expired then begin
            InvokeWMIQueries();
            CreateSourceJson();
            TempBlob.CreateOutStream(OutStream);
            if JObject.WriteTo(JsonText) then
                OutStream.Write(JsonText);
            RecordRef.GetTable(VATReportSetup);
            TempBlob.ToRecordRef(RecordRef, JsonFieldNo);
            RecordRef.SetTable(VATReportSetup);
            DueDateTime := CalcNextDueDateTime();
            VATReportSetup.Modify();
        end else begin
            TempBlob.CreateInStream(InStream);
            if InStream.Read(JsonText) <> 0 then
                JObject.ReadFrom(JsonText);
        end;
    end;

    local procedure CalcNextDueDateTime(): DateTime
    begin
        exit(TypeHelper.AddHoursToDateTime(CurrentDateTime(), 12));
    end;

    local procedure CreateSourceJson()
    var
        TextValue: Text;
    begin
        if GetClientPublicIPs(TextValue) then
            JObject.Add('Gov-Client-Public-IP', TextValue);
        if GetClientDeviceID(TextValue) then
            JObject.Add('Gov-Client-Device-ID', TextValue);
        if GetClientUserIDs(TextValue) then
            JObject.Add('Gov-Client-User-IDs', TextValue);
        if GetClientTimezone(TextValue) then
            JObject.Add('Gov-Client-Timezone', TextValue);
        if GetClientLocalIPs(TextValue) then
            JObject.Add('Gov-Client-Local-IPs', TextValue);
        if GetClientMACAddresses(TextValue) then
            JObject.Add('Gov-Client-MAC-Addresses', TextValue);
        if GetClientScreens(TextValue) then
            JObject.Add('Gov-Client-Screens', TextValue);
        if GetClientUserAgent(TextValue) then
            JObject.Add('Gov-Client-User-Agent', TextValue);
        if GetVendorLicenseIDs(TextValue) then
            JObject.Add('Gov-Vendor-License-IDs', TextValue);
        if GetVendorPublicIPs(TextValue) then
            JObject.Add('Gov-Vendor-Public-IP', TextValue);
    end;

    local procedure GetConnectionMethod(var Result: Text): Boolean
    begin
        case true of
            WinClient:
                Result := ConnectionMethodWinClientTxt;
            WebClient:
                Result := ConnectionMethodWebClientTxt;
            BatchClient:
                Result := ConnectionMethodBatchClientTxt;
        end;

        exit(Result <> '');
    end;

    local procedure GetVendorVersion(): Text
    var
        ProdName: Text;
        ProdVersion: Text;
    begin
        ProdName := GetProdName();
        ProdVersion := GetProdVersion();
        exit(StrSubstNo('%1=%2', TypeHelper.UrlEncode(ProdName), TypeHelper.UrlEncode(ProdVersion)));
    end;

    local procedure GetProdName() Result: Text
    begin
        Result := ProdNameTxt;
        if OnPrem then
            Result += ProdNameOnPremSuffixTxt;
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
    var
    begin
        if not GetBufferValue(Result, 'Win32_ComputerSystemProduct.UUID') then
            exit(false);
        Result := TypeHelper.UrlEncode(Result);
        exit(true);
    end;

    local procedure GetClientUserIDs(var Result: Text): Boolean
    begin
        if WebClient then
            exit;

        if not GetBufferValue(Result, 'Win32_ComputerSystem.UserName') then
            if not GetCurrentNAVUserName(Result) then
                exit(false);

        Result := StrSubstNo('os=%1', TypeHelper.UrlEncode(Result));
        exit(true);
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

        exit(true);
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

        Result := StrSubstNo('width=%1&height=%2', Width, Height);
        exit(true);
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

        Result := StrSubstNo('width=%1&height=%2', Width, Height);
        if BPP <> 0 then
            Result += StrSubstNo('&colour-depth=%1', BPP);

        exit(true);
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
            exit;

        OSFamily := DefaultOSFamilyTxt;
        GetBufferValue(OSVersion, 'Win32_OperatingSystem.Version');
        GetBufferValue(DeviceVendor, 'Win32_ComputerSystemProduct.Vendor');
        GetBufferValue(DeviceVersion, 'Win32_ComputerSystemProduct.Version');
        GetBufferValue(DeviceName, 'Win32_ComputerSystemProduct.Name');

        if (DeviceVersion <> '') and (DeviceVersion <> ' ') then
            DeviceName := StrSubstNo('%1_%2', DeviceVersion, DeviceName);

        Result :=
            StrSubstNo('%1/%2 (%3/%4)',
                TypeHelper.UrlEncode(OSFamily), TypeHelper.UrlEncode(OSVersion),
                TypeHelper.UrlEncode(DeviceVendor), TypeHelper.UrlEncode(DeviceName));
        exit(true);
    end;

    local procedure GetVendorLicenseIDs(var Result: Text): Boolean
    var
        TenantSettings: Codeunit "Tenant Information";
        AzureADTenant: Codeunit "Azure AD Tenant";
        TenantLicenseState: Codeunit "Tenant License State";
        CryptographyManagement: Codeunit "Cryptography Management";
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
        ProdName: Text;
        Hashed: Text;
    begin
        ProdName := ProdNameTxt;
        Hashed :=
            StrSubstNo(
                'Microsoft_Dynamics_365_Business_Central,AadTenantId=%1,TenantId=%2,Start=%3,End=%4',
                AzureADTenant.GetAadTenantId(), TenantSettings.GetTenantId(),
                TenantLicenseState.GetStartDate(), TenantLicenseState.GetEndDate());
        Hashed := CryptographyManagement.GenerateHash(Hashed, HashAlgorithmType::SHA256);
        Result := StrSubstNo('%1=%2', TypeHelper.UrlEncode(ProdName), Hashed);
        exit(true);
    end;

    local procedure GetVendorPublicIPs(var Result: Text): Boolean
    begin
        if BatchClient then
            exit(false);

        exit(GetBufferValues(Result, ServerPublicIPsBuffer, 'Win32_NetworkAdapterConfiguration.IPAddress', 1));
    end;

    local procedure GetCurrentNAVUserName(var Result: Text): Boolean
    begin
        Result := UserId();
        exit(Result <> '');
    end;

    local procedure GetTimezoneOffset(var Hours: Integer; var Minutes: Integer): Boolean
    var
        MinutesTxt: Text;
    begin
        if not GetBufferValue(MinutesTxt, 'Win32_OperatingSystem.CurrentTimeZone') then
            exit(false);
        if not Evaluate(Minutes, MinutesTxt) then
            exit(false);
        Hours := Minutes div 60;
        Minutes := Minutes mod 60;
        exit(true);
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
        ClientMgtObjSearcher: dotnet MTD_ManagementObjectSearcher;
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
        ServerMgtObjSearcher: dotnet MTD_ManagementObjectSearcher;
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
}
