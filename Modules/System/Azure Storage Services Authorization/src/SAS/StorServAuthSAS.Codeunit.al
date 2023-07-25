// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9061 "Stor. Serv. Auth. SAS" implements "Storage Service Authorization"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [NonDebuggable]
    procedure Authorize(var HttpRequestMessage: HttpRequestMessage; StorageAccount: Text)
    var
        Uri: Codeunit Uri;
        UriBuilder: Codeunit "Uri Builder";
        UriText, QueryText : Text;
    begin
        StorageAccountName := StorageAccount;
        UriText := HttpRequestMessage.GetRequestUri();

        UriBuilder.Init(UriText);
        QueryText := UriBuilder.GetQuery();

        QueryText := DelChr(QueryText, '<', '?'); // remove ? from the query

        if QueryText <> '' then
            QueryText += '&';
        QueryText += GetSharedAccessSignature();
        
        UriBuilder.SetQuery(QueryText);

        UriBuilder.GetUri(Uri);

        HttpRequestMessage.SetRequestUri(Uri.GetAbsoluteUri());
    end;

    [NonDebuggable]
    procedure SetStorageAccountName(NewStorageAccountName: Text)
    begin
        StorageAccountName := NewStorageAccountName;
    end;

    [NonDebuggable]
    procedure SetSigningKey(NewSigningKey: Text)
    begin
        SigningKey := NewSigningKey;
    end;

    procedure SetSignedStart(SignedStart: DateTime)
    begin
        if SignedStart = 0DT then
            SignedStart := CurrentDateTime();

        StartDate := SignedStart;
    end;

    procedure SetSignedExpiry(SignedExpiry: DateTime)
    begin
        EndDate := SignedExpiry;
    end;

    procedure SetIPrange(NewIPRange: Text)
    begin
        IPRange := NewIPRange;
    end;

    procedure SetSignedEncryptionScope(NewSignedEncryptionScope: Text)
    begin
        SignedEncryptionScope := NewSignedEncryptionScope;
    end;

    procedure SetVersion(NewAPIVersion: Enum "Storage Service API Version")
    begin
        ApiVersion := NewAPIVersion;
    end;

    procedure SetSignedServices(SignedServices: List of [Enum "SAS Service Type"])
    begin
        Services := SignedServices;
    end;

    procedure SetResources(SignedResources: List of [Enum "SAS Resource Type"])
    begin
        Resources := SignedResources;
    end;

    procedure SetSignedPermissions(SignedPermissions: List of [Enum "SAS Permission"])
    begin
        Permissions := SignedPermissions;
    end;

    procedure SetProtocol(SignedProtocol: Option "https&http","https")
    begin
        Clear(Protocols);
        Protocols.Add('https');

        if SignedProtocol = SignedProtocol::"https&http" then
            Protocols.Add('http');
    end;

    [NonDebuggable]
    procedure GetSharedAccessSignature(): Text
    var
        StringToSign: Text;
        Signature: Text;
        SharedAccessSignature: Text;
    begin
        StringToSign := CreateSharedAccessSignatureStringToSign();
        Signature := AuthFormatHelper.GetAccessKeyHashCode(StringToSign, SigningKey);
        SharedAccessSignature := CreateSasUrlString(ApiVersion, StartDate, EndDate, Services, Resources, Permissions, Protocols, IPRange, Signature, SignedEncryptionScope);

        exit(SharedAccessSignature);
    end;

    [NonDebuggable]
    local procedure CreateSharedAccessSignatureStringToSign(): Text
    var
        StringToSign: TextBuilder;
    begin
        StringToSign.Append(StorageAccountName + NewLine());
        StringToSign.Append(PermissionsToString(Permissions) + NewLine());
        StringToSign.Append(ServicesToString(Services) + NewLine());
        StringToSign.Append(ResourcesToString(Resources) + NewLine());
        StringToSign.Append(DateToString(StartDate) + NewLine());
        StringToSign.Append(DateToString(EndDate) + NewLine());
        StringToSign.Append(IPRange + NewLine());
        StringToSign.Append(ProtocolsToString(Protocols) + NewLine());
        StringToSign.Append(VersionToString(ApiVersion) + NewLine());
        if ApiVersion <> Enum::"Storage Service API Version"::"2020-10-02" then // Must be provided for all versions above 2020-10-02
            StringToSign.Append(SignedEncryptionScope + NewLine());
        exit(StringToSign.ToText());
    end;

    local procedure PermissionsToString(SasPermissions: List of [Enum "SAS Permission"]): Text
    var
        Permission: Enum "SAS Permission";
        Builder: TextBuilder;
    begin
        foreach Permission in Enum::"SAS Permission".Ordinals() do
            if SasPermissions.Contains(Permission) then
                Builder.Append(Format(Permission));

        exit(Builder.ToText());
    end;

    local procedure ProtocolsToString(ProtocolsList: List of [Text]): Text
    var
        Protocol: Text;
        Builder: TextBuilder;
    begin
        foreach Protocol in ProtocolsList do begin
            if Builder.ToText() <> '' then
                Builder.Append(',');
            Builder.Append(Protocol)
        end;
        exit(Builder.ToText());
    end;

    local procedure ServicesToString(ServiceTypes: List of [Enum "SAS Service Type"]): Text
    var
        Service: Enum "SAS Service Type";
        Builder: TextBuilder;
    begin
        foreach Service in Enum::"SAS Service Type".Ordinals() do
            if ServiceTypes.Contains(Service) then
                Builder.Append(Format(Service));

        exit(Builder.ToText());
    end;

    [NonDebuggable]
    procedure CreateSasUrlString(StorageServiceApiVersion: Enum "Storage Service API Version"; StartDateTime: DateTime; EndDateTime: DateTime; SasServiceTypes: List of [Enum "SAS Service Type"]; SasResourceTypes: List of [Enum "SAS Resource Type"]; SasPermissions: List of [Enum "SAS Permission"]; ProtocolStrings: List of [Text]; IPRangeString: Text; Signature: Text; SignedEncryptionScopeString: Text): Text
    var
        Uri: Codeunit Uri;
        Builder: TextBuilder;
        KeyValueLbl: Label '%1=%2', Comment = '%1 = Key; %2 = Value', Locked = true;
    begin
        Builder.Append(StrSubstNo(KeyValueLbl, 'sv', VersionToString(StorageServiceApiVersion)));
        Builder.Append('&');
        Builder.Append(StrSubstNo(KeyValueLbl, 'ss', ServicesToString(SasServiceTypes)));
        Builder.Append('&');
        Builder.Append(StrSubstNo(KeyValueLbl, 'srt', ResourcesToString(SasResourceTypes)));
        Builder.Append('&');
        Builder.Append(StrSubstNo(KeyValueLbl, 'sp', PermissionsToString(SasPermissions)));
        Builder.Append('&');
        Builder.Append(StrSubstNo(KeyValueLbl, 'se', Uri.EscapeDataString(DateToString(EndDateTime))));
        Builder.Append('&');
        Builder.Append(StrSubstNo(KeyValueLbl, 'st', Uri.EscapeDataString(DateToString(StartDateTime))));
        Builder.Append('&');
        Builder.Append(StrSubstNo(KeyValueLbl, 'spr', ProtocolsToString(ProtocolStrings)));
        Builder.Append('&');

        if IPRangeString <> '' then begin
            Builder.Append(StrSubstNo(KeyValueLbl, 'sip', IPRangeString));
            Builder.Append('&');
        end;

        if SignedEncryptionScopeString <> '' then begin
            Builder.Append(StrSubstNo(KeyValueLbl, 'ses', SignedEncryptionScopeString));
            Builder.Append('&');
        end;

        Builder.Append(StrSubstNo(KeyValueLbl, 'sig', Uri.EscapeDataString(Signature)));

        exit(Builder.ToText());
    end;

    local procedure VersionToString(StorageServiceApiVersion: Enum "Storage Service API Version"): Text
    begin
        exit(Format(StorageServiceApiVersion));
    end;

    local procedure DateToString(MyDateTime: DateTime): Text
    begin
        exit(AuthFormatHelper.GetIso8601DateTime(MyDateTime) + 'Z'); // Must be in 'yyyy-MM-ddTHH:mm:ssZ' UTC format
    end;

    local procedure ResourcesToString(ResourceTypes: List of [Enum "SAS Resource Type"]): Text
    var
        Resource: Enum "SAS Resource Type";
        Builder: TextBuilder;
    begin
        foreach Resource in Enum::"SAS Resource Type".Ordinals() do
            if ResourceTypes.Contains(Resource) then
                Builder.Append(Format(Resource));

        exit(Builder.ToText());
    end;

    local procedure NewLine(): Text
    begin
        exit(AuthFormatHelper.NewLine());
    end;

    var
        AuthFormatHelper: Codeunit "Auth. Format Helper";
        [NonDebuggable]
        StorageAccountName: Text;
        [NonDebuggable]
        SigningKey: Text;
        SignedEncryptionScope: Text;
        StartDate: DateTime;
        EndDate: DateTime;
        ApiVersion: Enum "Storage Service API Version";
        Services: List of [Enum "SAS Service Type"];
        Resources: List of [Enum "SAS Resource Type"];
        Permissions: List of [Enum "SAS Permission"];
        Protocols: List of [Text];
        IPRange: Text;
}