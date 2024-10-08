// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;
using Microsoft.eServices.EDocument;
using System.Utilities;
using System.Text;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;

codeunit 6393 "API Requests"
{
    Access = Internal;

    Permissions = tabledata "Network Profile" = rimd,
                  tabledata "Network Identifier" = rimd,
                  tabledata "Participation" = rimd,
                  tabledata "Activated Net. Prof." = rimd;

    #region Get Network Profiles from Continia Delivery Network API

    [InherentPermissions(PermissionObjectType::TableData, Database::"Network Profile", 'rimd', InherentPermissionsScope::Both)]
    internal procedure GetNetworkProfiles(Network: Enum "Network")
    var
        APIUrlMgt: Codeunit "API URL Mgt.";
        IsLastPage: Boolean;
        HttpResponseMessage: HttpResponseMessage;
        CurrPage: Integer;
        PageSize: Integer;
    begin
        CurrPage := 0;
        PageSize := 100;
        IsLastPage := false;
        repeat
            CurrPage += 1;
            if ExecuteRequest('GET', APIUrlMgt.NetworkProfilesURL(Network, CurrPage, PageSize), HttpResponseMessage) then
                IsLastPage := HandleNetworkProfileResponse(HttpResponseMessage, Network, PageSize);
        until IsLastPage;
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::"Network Profile", 'rimd', InherentPermissionsScope::Both)]
    local procedure HandleNetworkProfileResponse(var HttpResponseMessage: HttpResponseMessage; NetworkName: Enum "Network"; PageSize: Integer) IsLastPage: Boolean
    var
        NetworkProfile: Record "Network Profile";
        Insert: Boolean;
        CDNGUID: Guid;
        i: Integer;
        ResponseBody: Text;
        ResponseXmlDoc: XmlDocument;
        TempXMLNode: XmlNode;
        TempXMLNode2: XmlNode;
        XMLNodeList: XmlNodeList;
    begin
        HttpResponseMessage.Content.ReadAs(ResponseBody);
        if ResponseBody <> '' then begin
            XmlDocument.ReadFrom(ResponseBody, ResponseXmlDoc);
            ResponseXmlDoc.SelectNodes('/network_profiles/network_profile', XMLNodeList);
            for i := 1 to XMLNodeList.Count do begin
                if XMLNodeList.Count < PageSize then
                    IsLastPage := true;
                XMLNodeList.Get(i, TempXMLNode);

                TempXMLNode.SelectSingleNode('network_profile_id', TempXMLNode2);

                CDNGUID := StrSubstNo('{%1}', TempXMLNode2.AsXmlElement().InnerText);

                if NetworkProfile.Get(CDNGUID) then
                    Insert := false
                else begin
                    NetworkProfile.Init();
                    NetworkProfile."CDN GUID" := CDNGUID;
                    Insert := true;
                end;

                NetworkProfile.Network := NetworkName;

                if TempXMLNode.SelectSingleNode('description', TempXMLNode2) then
                    NetworkProfile.Description := CopyStr(TempXMLNode2.AsXmlElement().InnerText, 1, MaxStrLen(NetworkProfile.Description));

                if TempXMLNode.SelectSingleNode('document_identifier', TempXMLNode2) then
                    NetworkProfile."Document Identifier" := CopyStr(TempXMLNode2.AsXmlElement().InnerText, 1, MaxStrLen(NetworkProfile."Document Identifier"));

                if TempXMLNode.SelectSingleNode('mandatory', TempXMLNode2) then
                    NetworkProfile.Mandatory := TempXMLNode2.AsXmlElement().InnerText = 'true';

                if TempXMLNode.SelectSingleNode('mandatory_in_country_iso3166', TempXMLNode2) then
                    NetworkProfile."Mandatory for Country" := CopyStr(TempXMLNode2.AsXmlElement().InnerText, 1, MaxStrLen(NetworkProfile."Mandatory for Country"));

                if TempXMLNode.SelectSingleNode('process_identifier', TempXMLNode2) then
                    NetworkProfile."Process Identifier" := CopyStr(TempXMLNode2.AsXmlElement().InnerText, 1, MaxStrLen(NetworkProfile."Process Identifier"));

                if TempXMLNode.SelectSingleNode('enabled', TempXMLNode2) then
                    NetworkProfile.Enabled := TempXMLNode2.AsXmlElement().InnerText = 'true'
                else
                    NetworkProfile.Enabled := true;

                if Insert then
                    NetworkProfile.Insert()
                else
                    NetworkProfile.Modify();
            end;
        end;
    end;

    #endregion

    #region Get Network ID Types from Continia Delivery Network API

    [InherentPermissions(PermissionObjectType::TableData, Database::"Network Profile", 'rimd', InherentPermissionsScope::Both)]
    internal procedure GetNetworkIDTypes(Network: Enum "Network")
    var
        APIUrlMgt: Codeunit "API URL Mgt.";
        IsLastPage: Boolean;
        HttpResponseMessage: HttpResponseMessage;
        CurrPage: Integer;
        PageSize: Integer;
    begin
        CurrPage := 0;
        PageSize := 100;
        IsLastPage := false;
        repeat
            CurrPage += 1;
            if ExecuteRequest('GET', APIUrlMgt.NetworkIdentifiersURL(Network, CurrPage, PageSize), HttpResponseMessage) then
                IsLastPage := HandleNetworkIDTypeResponse(HttpResponseMessage, Network, PageSize);
        until IsLastPage;
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::"Network Identifier", 'rimd', InherentPermissionsScope::Both)]
    local procedure HandleNetworkIDTypeResponse(var HttpResponseMessage: HttpResponseMessage; NetworkName: Enum "Network"; PageSize: Integer) IsLastPage: Boolean
    var
        NetworkIdentifier: Record "Network Identifier";
        Insert: Boolean;
        CDNGUID: Guid;
        i: Integer;
        ResponseBody: Text;
        ResponseXmlDoc: XmlDocument;
        TempXMLNode: XmlNode;
        TempXMLNode2: XmlNode;
        XMLNodeList: XmlNodeList;
    begin
        HttpResponseMessage.Content.ReadAs(ResponseBody);
        if ResponseBody <> '' then begin
            XmlDocument.ReadFrom(ResponseBody, ResponseXmlDoc);
            ResponseXmlDoc.SelectNodes('/network_id_types/network_id_type', XMLNodeList);
            for i := 1 to XMLNodeList.Count do begin
                if XMLNodeList.Count < PageSize then
                    IsLastPage := true;
                XMLNodeList.Get(i, TempXMLNode);

                TempXMLNode.SelectSingleNode('network_id_type_id', TempXMLNode2);

                CDNGUID := StrSubstNo('{%1}', TempXMLNode2.AsXmlElement().InnerText);

                if NetworkIdentifier.Get(CDNGUID) then
                    Insert := false
                else begin
                    NetworkIdentifier.Init();
                    NetworkIdentifier."CDN GUID" := CDNGUID;
                    Insert := true;
                end;

                NetworkIdentifier.Network := NetworkName;

                if TempXMLNode.SelectSingleNode('code_iso6523-1', TempXMLNode2) then
                    NetworkIdentifier."Identifier Type ID" := CopyStr(TempXMLNode2.AsXmlElement().InnerText, 1, MaxStrLen(NetworkIdentifier."Identifier Type ID"));

                if TempXMLNode.SelectSingleNode('default_in_country_iso3166', TempXMLNode2) then
                    NetworkIdentifier."Default in Country" := CopyStr(TempXMLNode2.AsXmlElement().InnerText, 1, MaxStrLen(NetworkIdentifier."Default in Country"));

                if TempXMLNode.SelectSingleNode('description', TempXMLNode2) then
                    NetworkIdentifier.Description := CopyStr(TempXMLNode2.AsXmlElement().InnerText, 1, MaxStrLen(NetworkIdentifier.Description));

                if TempXMLNode.SelectSingleNode('icd_code', TempXMLNode2) then
                    NetworkIdentifier."ICD Code" := TempXMLNode2.AsXmlElement().InnerText = 'true';

                if TempXMLNode.SelectSingleNode('network_id_type_id', TempXMLNode2) then
                    NetworkIdentifier."CDN GUID" := TempXMLNode2.AsXmlElement().InnerText;

                if TempXMLNode.SelectSingleNode('scheme_id', TempXMLNode2) then
                    NetworkIdentifier."Scheme ID" := CopyStr(TempXMLNode2.AsXmlElement().InnerText, 1, MaxStrLen(NetworkIdentifier."Scheme ID"));

                if TempXMLNode.SelectSingleNode('vat_in_country_iso3166', TempXMLNode2) then
                    NetworkIdentifier."VAT in Country" := CopyStr(TempXMLNode2.AsXmlElement().InnerText, 1, MaxStrLen(NetworkIdentifier."VAT in Country"));

                if TempXMLNode.SelectSingleNode('enabled', TempXMLNode2) then
                    NetworkIdentifier.Enabled := TempXMLNode2.AsXmlElement().InnerText = 'true'
                else
                    NetworkIdentifier.Enabled := true;

                if NetworkIdentifier."Default in Country" <> '' then
                    if NetworkIdentifier."Default in Country" = GetCurrentCountryCode() then
                        NetworkIdentifier.Default := true;

                if Insert then
                    NetworkIdentifier.Insert()
                else
                    NetworkIdentifier.Modify();
            end;
        end;
    end;

    #endregion

    #region Participation endpoints in Continia Delivery Network
    [InherentPermissions(PermissionObjectType::TableData, Database::"Participation", 'rm', InherentPermissionsScope::Both)]
    internal procedure GetParticipation(var Participation: Record "Participation")
    var
        APIUrlMgt: Codeunit "API URL Mgt.";
        HttpResponseMessage: HttpResponseMessage;
    begin
        if ExecuteRequest('GET', APIUrlMgt.SingleParticipationURL(Participation.Network, Participation."CDN GUID"), HttpResponseMessage) then
            HandleParticipationResponse(HttpResponseMessage, Participation);
    end;

    internal procedure PostParticipation(var TempParticipation: Record "Participation" temporary) ParticipationGUID: Guid;
    var
        Participation: Record "Participation";
        APIUrlMgt: Codeunit "API URL Mgt.";
        HttpResponseMessage: HttpResponseMessage;
        HttpContentData: Text;
    begin
        HttpContentData := GetParticipationRequest(TempParticipation, false);

        if ExecuteRequest('POST', APIUrlMgt.ParticipationURL(TempParticipation.Network), HttpContentData, HttpResponseMessage) then begin
            Participation := TempParticipation;
            Participation.Insert();
            HandleParticipationResponse(HttpResponseMessage, Participation);
            exit(Participation."CDN GUID");
        end;
    end;

    internal procedure PatchParticipation(var TempParticipation: Record "Participation" temporary)
    var
        Participation: Record "Participation";
        APIUrlMgt: Codeunit "API URL Mgt.";
        HttpResponseMessage: HttpResponseMessage;
        HttpContentData: Text;
    begin
        HttpContentData := GetParticipationRequest(TempParticipation, true);

        if ExecuteRequest('PATCH', APIUrlMgt.SingleParticipationURL(TempParticipation.Network, TempParticipation."CDN GUID"), HttpContentData, HttpResponseMessage) then begin
            Participation.Get(TempParticipation.RecordId);
            HandleParticipationResponse(HttpResponseMessage, Participation);
        end;
    end;

    internal procedure DeleteParticipation(var Participation: Record "Participation")
    var
        APIUrlMgt: Codeunit "API URL Mgt.";
        HttpResponseMessage: HttpResponseMessage;
    begin
        if ExecuteRequest('DELETE', APIUrlMgt.SingleParticipationURL(Participation.Network, Participation."CDN GUID"), HttpResponseMessage) then
            case HttpResponseMessage.HttpStatusCode of
                200:
                    Participation.Delete(true);
                202:
                    begin
                        Participation."Registration Status" := Participation."Registration Status"::Disabled;
                        Participation.Modify();
                    end;
            end;
    end;

    local procedure GetParticipationRequest(Participation: Record "Participation"; IncludeTimestamp: Boolean) RequestBody: Text
    var
        CredentialManagement: Codeunit "Credential Management";
        AddressNode: XmlElement;
        CompanyIDNode: XmlElement;
        CompanyNameNode: XmlElement;
        ContactEmailNode: XmlElement;
        ContactNameNode: XmlElement;
        ContactPhoneNode: XmlElement;
        CountryCodeNode: XmlElement;
        NetworkIdTypeNode: XmlElement;
        NetworkIdValueNode: XmlElement;
        PostCodeNode: XmlElement;
        PublishInRegistryNode: XmlElement;
        RegistrantNameNode: XmlElement;
        RootNode: XmlElement;
        StatusNode: XmlElement;
        TimestampNode: XmlElement;
        VatRegistrationNoNode: XmlElement;
        ParticipationTypeNode: XmlElement;
        ParticipationTypeEnumLbl: Label 'MicrosoftConnector', Locked = true;
    begin
        RootNode := XmlElement.Create('participation');

        AddressNode := XmlElement.Create('address');
        AddressNode.Add(XmlText.Create(Participation.Address));
        RootNode.Add(AddressNode);

        CompanyIDNode := XmlElement.Create('business_central_company_code');
        CompanyIDNode.Add(XmlText.Create(GetGUIDAsText(CredentialManagement.GetCompanyId())));
        RootNode.Add(CompanyIDNode);

        CompanyNameNode := XmlElement.Create('company_name');
        CompanyNameNode.Add(XmlText.Create(Participation."Company Name"));
        RootNode.Add(CompanyNameNode);

        ContactEmailNode := XmlElement.Create('contact_email');
        ContactEmailNode.Add(XmlText.Create(Participation."Signatory Email"));
        RootNode.Add(ContactEmailNode);

        ContactNameNode := XmlElement.Create('contact_name');
        ContactNameNode.Add(XmlText.Create(Participation."Signatory Name"));
        RootNode.Add(ContactNameNode);

        ContactPhoneNode := XmlElement.Create('contact_phone');
        ContactPhoneNode.Add(XmlText.Create(Participation."Contact Phone No."));
        RootNode.Add(ContactPhoneNode);

        CountryCodeNode := XmlElement.Create('country_code_iso3166');
        CountryCodeNode.Add(XmlText.Create(Participation."Country/Region Code"));
        RootNode.Add(CountryCodeNode);

        NetworkIdTypeNode := XmlElement.Create('network_id_type_id');
        NetworkIdTypeNode.Add(XmlText.Create(Participation."Identifier Type ID"));
        RootNode.Add(NetworkIdTypeNode);

        NetworkIdValueNode := XmlElement.Create('network_id_value');
        NetworkIdValueNode.Add(XmlText.Create(Participation."Identifier Value"));
        RootNode.Add(NetworkIdValueNode);

        if not IsNullGuid(Participation."CDN GUID") then begin
            NetworkIdTypeNode := XmlElement.Create('participation_id');
            NetworkIdTypeNode.Add(XmlText.Create(GetGUIDAsText(Participation."CDN GUID")));
            RootNode.Add(NetworkIdTypeNode);
        end;

        ParticipationTypeNode := XmlElement.Create('participation_type');
        ParticipationTypeNode.Add(XmlText.Create(ParticipationTypeEnumLbl));
        RootNode.Add(ParticipationTypeNode);

        PostCodeNode := XmlElement.Create('post_code');
        PostCodeNode.Add(XmlText.Create(Participation."Post Code"));
        RootNode.Add(PostCodeNode);

        PublishInRegistryNode := XmlElement.Create('publish_in_registry');
        if Participation."Publish in Registry" then
            PublishInRegistryNode.Add(XmlText.Create('true'))
        else
            PublishInRegistryNode.Add(XmlText.Create('false'));

        RootNode.Add(PublishInRegistryNode);

        RegistrantNameNode := XmlElement.Create('registrant_name');
        RegistrantNameNode.Add(XmlText.Create(Participation."Your Name"));
        RootNode.Add(RegistrantNameNode);

        StatusNode := XmlElement.Create('status');
        StatusNode.Add(XmlText.Create(Participation.GetParticipApiStatusEnumValue(false)));
        RootNode.Add(StatusNode);

        if IncludeTimestamp then begin
            TimestampNode := XmlElement.Create('timestamp');
            TimestampNode.Add(XmlText.Create(Participation."CDN Timestamp"));
            RootNode.Add(TimestampNode);
        end;

        VatRegistrationNoNode := XmlElement.Create('vat_registration_no');
        VatRegistrationNoNode.Add(XmlText.Create(Participation."VAT Registration No."));
        RootNode.Add(VatRegistrationNoNode);

        RootNode.WriteTo(RequestBody);
    end;

    local procedure HandleParticipationResponse(var HttpResponseMessage: HttpResponseMessage; var Participation: Record "Participation")
    var
        ResponseBody: Text;
        ResponseXmlDoc: XmlDocument;
        AddressNode: XmlNode;
        CompanyNameNode: XmlNode;
        ContactEmailNode: XmlNode;
        ContactNameNode: XmlNode;
        ContactPhoneNode: XmlNode;
        CountryCodeNode: XmlNode;
        CreatedNode: XmlNode;
        ParicipationIDNode: XmlNode;
        PostCodeNode: XmlNode;
        PublishInRegistryNode: XmlNode;
        RegistrantNameNode: XmlNode;
        StatusNode: XmlNode;
        TimestampNode: XmlNode;
        UpdatedNode: XmlNode;
        VatRegistrationNoNode: XmlNode;
    begin
        HttpResponseMessage.Content.ReadAs(ResponseBody);
        if ResponseBody = '' then
            exit;

        XmlDocument.ReadFrom(ResponseBody, ResponseXmlDoc);

        ResponseXmlDoc.SelectSingleNode('/participation/company_name', CompanyNameNode);
        Participation."Company Name" := CopyStr(CompanyNameNode.AsXmlElement().InnerText, 1, MaxStrLen(Participation."Company Name"));

        ResponseXmlDoc.SelectSingleNode('/participation/vat_registration_no', VatRegistrationNoNode);
        Participation."VAT Registration No." := CopyStr(VatRegistrationNoNode.AsXmlElement().InnerText, 1, MaxStrLen(Participation."VAT Registration No."));

        ResponseXmlDoc.SelectSingleNode('/participation/address', AddressNode);
        Participation.Address := CopyStr(AddressNode.AsXmlElement().InnerText, 1, MaxStrLen(Participation.Address));

        ResponseXmlDoc.SelectSingleNode('/participation/post_code', PostCodeNode);
        Participation."Post Code" := CopyStr(PostCodeNode.AsXmlElement().InnerText, 1, MaxStrLen(Participation."Post Code"));

        ResponseXmlDoc.SelectSingleNode('/participation/country_code_iso3166', CountryCodeNode);
        Participation."Country/Region Code" := CopyStr(CountryCodeNode.AsXmlElement().InnerText, 1, MaxStrLen(Participation."Country/Region Code"));

        ResponseXmlDoc.SelectSingleNode('/participation/registrant_name', RegistrantNameNode);
        Participation."Your Name" := CopyStr(RegistrantNameNode.AsXmlElement().InnerText, 1, MaxStrLen(Participation."Your Name"));

        ResponseXmlDoc.SelectSingleNode('/participation/contact_name', ContactNameNode);
        Participation."Signatory Name" := CopyStr(ContactNameNode.AsXmlElement().InnerText, 1, MaxStrLen(Participation."Signatory Name"));

        ResponseXmlDoc.SelectSingleNode('/participation/contact_phone', ContactPhoneNode);
        Participation."Contact Phone No." := CopyStr(ContactPhoneNode.AsXmlElement().InnerText, 1, MaxStrLen(Participation."Contact Phone No."));

        ResponseXmlDoc.SelectSingleNode('/participation/contact_email', ContactEmailNode);
        Participation."Signatory Email" := CopyStr(ContactEmailNode.AsXmlElement().InnerText, 1, MaxStrLen(Participation."Signatory Email"));

        ResponseXmlDoc.SelectSingleNode('/participation/publish_in_registry', PublishInRegistryNode);
        if LowerCase(PublishInRegistryNode.AsXmlElement().InnerText) = 'true' then
            Participation."Publish in Registry" := true
        else
            Participation."Publish in Registry" := false;

        ResponseXmlDoc.SelectSingleNode('/participation/publish_in_registry', PublishInRegistryNode);
        if LowerCase(PublishInRegistryNode.AsXmlElement().InnerText) = 'true' then
            Participation."Publish in Registry" := true
        else
            Participation."Publish in Registry" := false;

        ResponseXmlDoc.SelectSingleNode('/participation/participation_id', ParicipationIDNode);
        Evaluate(Participation."CDN GUID", ParicipationIDNode.AsXmlElement().InnerText);

        ResponseXmlDoc.SelectSingleNode('/participation/status', StatusNode);
        Participation.ValidateCDNStatus(StatusNode.AsXmlElement().InnerText);

        ResponseXmlDoc.SelectSingleNode('/participation/created_utc', CreatedNode);
        Evaluate(Participation.Created, CreatedNode.AsXmlElement().InnerText, 9);

        ResponseXmlDoc.SelectSingleNode('/participation/updated_utc', UpdatedNode);
        Evaluate(Participation.Updated, UpdatedNode.AsXmlElement().InnerText, 9);

        ResponseXmlDoc.SelectSingleNode('/participation/timestamp', TimestampNode);
        Participation."CDN Timestamp" := CopyStr(TimestampNode.AsXmlElement().InnerText, 1, MaxStrLen(Participation."CDN Timestamp"));

        Participation.Modify();
    end;
    #endregion

    #region Participation Profiles endpoints in Continia Delivery Network

    internal procedure GetParticipationProfile(var ActivatedNetworkProfile: Record "Activated Net. Prof."; ParticipationGUID: Guid)
    var
        APIUrlMgt: Codeunit "API URL Mgt.";
        HttpResponseMessage: HttpResponseMessage;
    begin
        if ExecuteRequest('GET', APIUrlMgt.SingleParticipationProfileURL(ActivatedNetworkProfile.Network, ParticipationGUID, ActivatedNetworkProfile."CDN GUID"), HttpResponseMessage) then
            UpdateParticipationProfile(HttpResponseMessage, ActivatedNetworkProfile);
    end;

    internal procedure PostParticipationProfile(TempActivatedNetworkProfile: Record "Activated Net. Prof." temporary; ParticipationGUID: Guid)
    var
        APIUrlMgt: Codeunit "API URL Mgt.";
        HttpResponseMessage: HttpResponseMessage;
        HttpContentData: Text;
    begin
        HttpContentData := GetParticipationProfilesRequest(TempActivatedNetworkProfile);

        if ExecuteRequest('POST', APIUrlMgt.ParticipationProfilesURL(TempActivatedNetworkProfile.Network, ParticipationGUID), HttpContentData, HttpResponseMessage) then
            UpdateParticipationProfile(HttpResponseMessage, TempActivatedNetworkProfile);
    end;

    internal procedure PatchParticipationProfiles(var ActivatedNetworkProfile: Record "Activated Net. Prof."; ParticipationGUID: Guid)
    var
        APIUrlMgt: Codeunit "API URL Mgt.";
        HttpResponseMessage: HttpResponseMessage;
        HttpContentData: Text;
    begin
        HttpContentData := GetParticipationProfilesRequest(ActivatedNetworkProfile);

        if ExecuteRequest('PATCH', APIUrlMgt.SingleParticipationProfileURL(ActivatedNetworkProfile.Network, ParticipationGUID, ActivatedNetworkProfile."CDN GUID"), HttpContentData, HttpResponseMessage) then
            UpdateParticipationProfile(HttpResponseMessage, ActivatedNetworkProfile);
    end;

    internal procedure DeleteParticipationProfiles(var ActivatedNetworkProfile: Record "Activated Net. Prof."; ParticipationGUID: Guid)
    var
        APIUrlMgt: Codeunit "API URL Mgt.";
        HttpResponseMessage: HttpResponseMessage;
    begin
        if ExecuteRequest('DELETE', APIUrlMgt.SingleParticipationProfileURL(ActivatedNetworkProfile.Network, ParticipationGUID, ActivatedNetworkProfile."Network Profile ID"), HttpResponseMessage) then begin
            ActivatedNetworkProfile.Validate(Disabled, CreateDateTime(Today, Time));
            ActivatedNetworkProfile.Modify();
        end;
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::"Participation", 'r', InherentPermissionsScope::Both)]
    [InherentPermissions(PermissionObjectType::TableData, Database::"Activated Net. Prof.", 'rm', InherentPermissionsScope::Both)]
    internal procedure GetAllParticipationProfiles(Participation: Record "Participation")
    var
        APIUrlMgt: Codeunit "API URL Mgt.";
        IsLastPage: Boolean;
        HttpResponseMessage: HttpResponseMessage;
        CurrPage: Integer;
        PageSize: Integer;
    begin
        CurrPage := 0;
        PageSize := 100;
        IsLastPage := false;
        repeat
            CurrPage += 1;
            if ExecuteRequest('GET', APIUrlMgt.ParticipationProfilesURL(Participation.Network, Participation."CDN GUID", CurrPage, PageSize), HttpResponseMessage) then begin
                HandleAPIError(HttpResponseMessage);
                IsLastPage := ReadParticipationProfilesResponse(HttpResponseMessage, Participation, PageSize);
            end;
        until IsLastPage;
    end;

    local procedure ReadParticipationProfilesResponse(var HttpResponseMessage: HttpResponseMessage; Participation: Record "Participation"; PageSize: Integer) IsLastPage: Boolean
    var
        i: Integer;
        NodeCount: Integer;
        ResponseBody: Text;
        ResponseXmlDoc: XmlDocument;
        Node: XmlNode;
        NodeList: XmlNodeList;
    begin
        IsLastPage := false;

        HttpResponseMessage.Content.ReadAs(ResponseBody);
        if ResponseBody = '' then
            exit;

        XmlDocument.ReadFrom(ResponseBody, ResponseXmlDoc);
        ResponseXmlDoc.SelectNodes('/participation_profiles/participation_profile', NodeList);

        NodeCount := NodeList.Count;
        if NodeCount < PageSize then
            IsLastPage := true;

        for i := 1 to NodeCount do begin
            NodeList.Get(i, Node);
            CreateOrUpdateParticipProfiles(Participation, Node);
        end;
    end;

    local procedure GetParticipationProfilesRequest(ActivatedNetworkProfile: Record "Activated Net. Prof.") RequestBody: Text
    var
        ParticipationProfileNode: XmlElement;
        ProfileDirectionNode: XmlElement;
        ProfileIDNode: XmlElement;
    begin
        ParticipationProfileNode := XmlElement.Create('participation_profile');

        ProfileDirectionNode := XmlElement.Create('direction');
        ProfileDirectionNode.Add(XmlText.Create(ActivatedNetworkProfile.GetParticipAPIDirectionEnum()));
        ParticipationProfileNode.Add(ProfileDirectionNode);

        ProfileIDNode := XmlElement.Create('network_profile_id');
        ProfileIDNode.Add(XmlText.Create(GetGUIDAsText(ActivatedNetworkProfile."Network Profile ID")));
        ParticipationProfileNode.Add(ProfileIDNode);

        ParticipationProfileNode.WriteTo(RequestBody);
    end;

    local procedure CreateOrUpdateParticipProfiles(Participation: Record "Participation"; ProfilesNode: XmlNode)
    var
        ActivatedNetworkProfile: Record "Activated Net. Prof.";
        ProfileGUID: Guid;
        CreatedNode: XmlNode;
        DirectionNode: XmlNode;
        DisabledNode: XmlNode;
        ParticipationProfileIDNode: XmlNode;
        ProfileIDNode: XmlNode;
        UpdatedNode: XmlNode;
    begin
        ProfilesNode.SelectSingleNode('network_profile_id', ProfileIDNode);
        Evaluate(ProfileGUID, ProfileIDNode.AsXmlElement().InnerText);
        if not ActivatedNetworkProfile.Get(Participation.Network, Participation."Identifier Type ID", Participation."Identifier Value", ProfileGUID) then begin
            ActivatedNetworkProfile.Init();
            ActivatedNetworkProfile.Network := Participation.Network;
            ActivatedNetworkProfile."Identifier Type ID" := Participation."Identifier Type ID";
            ActivatedNetworkProfile."Identifier Value" := Participation."Identifier Value";
            ActivatedNetworkProfile."Network Profile ID" := ProfileGUID;
            ActivatedNetworkProfile.Insert();
        end;

        ProfilesNode.SelectSingleNode('participation_profile_id', ParticipationProfileIDNode);
        Evaluate(ActivatedNetworkProfile."CDN GUID", ParticipationProfileIDNode.AsXmlElement().InnerText);

        ProfilesNode.SelectSingleNode('direction', DirectionNode);
        ActivatedNetworkProfile.ValidateAPIDirection(DirectionNode.AsXmlElement().InnerText);

        ProfilesNode.SelectSingleNode('created_utc', CreatedNode);
        Evaluate(ActivatedNetworkProfile.Created, CreatedNode.AsXmlElement().InnerText, 9);

        ProfilesNode.SelectSingleNode('updated_utc', UpdatedNode);
        Evaluate(ActivatedNetworkProfile.Updated, UpdatedNode.AsXmlElement().InnerText, 9);

        if ProfilesNode.SelectSingleNode('disabled_utc', DisabledNode) then
            Evaluate(ActivatedNetworkProfile.Disabled, DisabledNode.AsXmlElement().InnerText, 9)
        else
            Clear(ActivatedNetworkProfile.Disabled);

        ActivatedNetworkProfile.Modify();
    end;

    local procedure UpdateParticipationProfile(var HttpResponseMessage: HttpResponseMessage; var ActivatedNetworkProfile: Record "Activated Net. Prof.")
    var
        ResponseBody: Text;
        ResponseXmlDoc: XmlDocument;
        CreatedNode: XmlNode;
        DirectionNode: XmlNode;
        DisabledNode: XmlNode;
        ProfileIDNode: XmlNode;
        UpdatedNode: XmlNode;
    begin
        HttpResponseMessage.Content.ReadAs(ResponseBody);
        if ResponseBody = '' then
            exit;

        XmlDocument.ReadFrom(ResponseBody, ResponseXmlDoc);
        ResponseXmlDoc.SelectSingleNode('/participation_profile/participation_profile_id', ProfileIDNode);
        Evaluate(ActivatedNetworkProfile."CDN GUID", ProfileIDNode.AsXmlElement().InnerText);

        ResponseXmlDoc.SelectSingleNode('/participation_profile/direction', DirectionNode);
        ActivatedNetworkProfile.ValidateAPIDirection(DirectionNode.AsXmlElement().InnerText);

        ResponseXmlDoc.SelectSingleNode('/participation_profile/created_utc', CreatedNode);
        Evaluate(ActivatedNetworkProfile.Created, CreatedNode.AsXmlElement().InnerText, 9);

        ResponseXmlDoc.SelectSingleNode('/participation_profile/updated_utc', UpdatedNode);
        Evaluate(ActivatedNetworkProfile.Updated, UpdatedNode.AsXmlElement().InnerText, 9);

        if ResponseXmlDoc.SelectSingleNode('/participation_profile/disabled_utc', DisabledNode) then
            Evaluate(ActivatedNetworkProfile.Disabled, DisabledNode.AsXmlElement().InnerText)
        else
            Clear(ActivatedNetworkProfile.Disabled);

        if not ActivatedNetworkProfile.Modify() then
            ActivatedNetworkProfile.Insert();
    end;

    #endregion

    #region Participation Profiles Lookup endpoints in Continia Delivery Network

    internal procedure CheckProfilesNotRegistered(TempActivatedNetworkProfile: Record "Activated Net. Prof." temporary; TempParticipation: Record "Participation" temporary)
    var
        NetworkIdentifier: Record "Network Identifier";
        APIUrlMgt: Codeunit "API URL Mgt.";
        HttpResponseMessage: HttpResponseMessage;
    begin
        NetworkIdentifier := TempParticipation.GetNetworkIdentifier();

        if ExecuteRequest('GET', APIUrlMgt.ParticipationLookupURL(TempParticipation.Network, NetworkIdentifier."Identifier Type ID", TempParticipation."Identifier Value"), HttpResponseMessage) then
            HandleProfilesLookupResponse(HttpResponseMessage, TempActivatedNetworkProfile, TempParticipation);
    end;

    local procedure HandleProfilesLookupResponse(var HttpResponseMessage: HttpResponseMessage; var TempActivatedNetworkProfile: Record "Activated Net. Prof." temporary; var TempParticipation: Record "Participation" temporary)
    var
        ErrorInfo: ErrorInfo;
        ProfileGUID: Guid;
        i: Integer;
        j: Integer;
        AccessPointEmail: Text;
        AccessPointErrText: Text;
        AccessPointName: Text;
        DetailedErrText: Text;
        RegisteredProfilesErrText: Text;
        ResponseBody: Text;
        ResponseXmlDoc: XmlDocument;
        AccessPointNode: XmlNode;
        APEmailNode: XmlNode;
        APNameNode: XmlNode;
        ProfileID: XmlNode;
        ProfileNode: XmlNode;
        AccessPointNodeList: XmlNodeList;
        ProfilesNodeList: XmlNodeList;
    begin
        HttpResponseMessage.Content.ReadAs(ResponseBody);
        if ResponseBody = '' then
            exit;

        XmlDocument.ReadFrom(ResponseBody, ResponseXmlDoc);
        ResponseXmlDoc.SelectNodes('/participation_lookups/participation_lookup/external_access_points/access_point', AccessPointNodeList);
        for i := 1 to AccessPointNodeList.Count do begin
            AccessPointNodeList.Get(i, AccessPointNode);
            AccessPointNode.SelectNodes('supported_profiles', ProfilesNodeList);
            for j := 1 to ProfilesNodeList.Count do begin
                ProfilesNodeList.Get(j, ProfileNode);
                if ProfileNode.SelectSingleNode('network_profile_id', ProfileID) then begin
                    Evaluate(ProfileGUID, ProfileID.AsXmlElement().InnerText);
                    if TempActivatedNetworkProfile.Get(TempParticipation.Network, TempParticipation."Identifier Type ID", TempParticipation."Identifier Value", ProfileGUID) then begin
                        AccessPointNode.SelectSingleNode('name', APNameNode);
                        AccessPointNode.SelectSingleNode('email', APEmailNode);
                        AccessPointName := APNameNode.AsXmlElement().InnerText;
                        AccessPointEmail := APEmailNode.AsXmlElement().InnerText;

                        TempActivatedNetworkProfile.CalcFields("Network Profile Description");
                        RegisteredProfilesErrText += StrSubstNo('%1 //', TempActivatedNetworkProfile."Network Profile Description");
                    end;
                end;
            end;

            if RegisteredProfilesErrText <> '' then begin
                AccessPointErrText := StrSubstNo(AccessPointDetailedErr, AccessPointName, AccessPointEmail, RegisteredProfilesErrText);
                DetailedErrText += StrSubstNo('%1 // //', AccessPointErrText);
            end
        end;

        if RegisteredProfilesErrText <> '' then begin
            ErrorInfo.Title := ParticipationAlreadyRegisteredTitleErr;
            ErrorInfo.Message := StrSubstNo(ParticipationAlreadyRegisteredErr, TempParticipation.Network, TempParticipation."Identifier Type ID", TempParticipation."Identifier Value");
            ErrorInfo.DetailedMessage(DetailedErrText);
            Error(ErrorInfo);
        end
    end;

    #endregion

    #region Get Documents for current company

    internal procedure GetDocumentsForCompany(var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    var
        APIUrlMgt: Codeunit "API URL Mgt.";
        CredentialManagement: Codeunit "Credential Management";
        CurrPage: Integer;
        PageSize: Integer;
    begin
        CurrPage := 1;
        PageSize := 100; // only get 100 documents at a time.

        if ExecuteRequest('GET', APIUrlMgt.DocumentsForCompanyURL(CredentialManagement.GetCompanyId(), CurrPage, PageSize, true), HttpRequest, HttpResponse) then
            exit(true);
    end;


    #endregion

    #region Send Documents

    internal procedure SendDocument(EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    var
        ConnectionSetup: Record "Connection Setup";
        CredentialManagement: Codeunit "Credential Management";
        Base64Convert: Codeunit "Base64 Convert";
        APIUrlMgt: Codeunit "API URL Mgt.";
        HttpResponseMessage: HttpResponseMessage;
        ReadStream: InStream;
        HttpContentData: Text;
        DocumentBase64Node: XmlElement;
        RootNode: XmlElement;
    begin
        ConnectionSetup.Get();

        RootNode := XmlElement.Create('unprocessed_document_request');

        DocumentBase64Node := XmlElement.Create('base64_data');
        TempBlob.CreateInStream(ReadStream);
        DocumentBase64Node.Add(XmlText.Create(Base64Convert.ToBase64(ReadStream)));
        RootNode.Add(DocumentBase64Node);

        RootNode.WriteTo(HttpContentData);

        if ExecuteRequest('POST', APIUrlMgt.PostDocumentsUrl(CredentialManagement.GetCompanyId()), HttpContentData, HttpResponseMessage) then begin
            SetEDocumentGUID(EDocument."Entry No", GetDocumentGUID(HttpResponseMessage));
            exit(true);
        end;
    end;

    local procedure SetEDocumentGUID(EDocEntryNo: Integer; DocumentID: Guid)
    var
        EDocument: Record "E-Document";
    begin
        if IsNullGuid(DocumentID) then
            exit;
        if not EDocument.Get(EDocEntryNo) then
            exit;
        EDocument."Document Id" := DocumentID;
        EDocument.Modify();
    end;

    local procedure GetDocumentGUID(var HttpResponseMessage: HttpResponseMessage) DocumentGUID: Guid
    var
        ResponseBody: Text;
        ResponseXmlDoc: XmlDocument;
        DocumentGUIDNode: XmlNode;
    begin
        HttpResponseMessage.Content.ReadAs(ResponseBody);
        if ResponseBody = '' then
            exit;

        XmlDocument.ReadFrom(ResponseBody, ResponseXmlDoc);
        ResponseXmlDoc.SelectSingleNode('/id_result/id', DocumentGUIDNode);
        Evaluate(DocumentGUID, DocumentGUIDNode.AsXmlElement().InnerText);
        exit(DocumentGUID);
    end;
    #endregion

    #region Get Technical response
    internal procedure GetTechnicalResponse(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    var
        APIUrlMgt: Codeunit "API URL Mgt.";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        DocumentGUID: Guid;
        SuccessfullStatusLbl: Label 'SuccessEnum';
        ErrorfullStatusLbl: Label 'ErrorEnum';
        DocumentStatus: Text;
        EDocumentDescription: Text;
        ResponseBody: Text;
        ResponseXmlDoc: XmlDocument;
        DocumentReceiptIDNode: XmlNode;
        DocumentStatusNode: XmlNode;
        ErrorCodeNode: XmlNode;
        ErrorMessageNode: XmlNode;
        TechnicalResponseNode: XmlNode;
    begin
        Evaluate(DocumentGUID, EDocument."Document Id");
        if ExecuteRequest('GET', APIUrlMgt.TechnicalResponseURL(DocumentGUID), HttpRequest, HttpResponse) then begin
            HttpResponse.Content.ReadAs(ResponseBody);
            if ResponseBody = '' then
                exit(false);

            XmlDocument.ReadFrom(ResponseBody, ResponseXmlDoc);
            ResponseXmlDoc.SelectSingleNode('/technical_response', TechnicalResponseNode);

            if TechnicalResponseNode.SelectSingleNode('document_receipt_id', DocumentReceiptIDNode) then begin
                Evaluate(EDocument."Filepart Id", DocumentReceiptIDNode.AsXmlElement().InnerText);
                EDocument.Modify();
            end;

            TechnicalResponseNode.SelectSingleNode('document_status', DocumentStatusNode);
            DocumentStatus := DocumentStatusNode.AsXmlElement().InnerText;
            case DocumentStatus of
                SuccessfullStatusLbl:
                    begin
                        MarkDocumentAsProcessed(DocumentGUID);
                        exit(true);
                    end;
                ErrorfullStatusLbl:
                    begin
                        if TechnicalResponseNode.SelectSingleNode('error_code', ErrorCodeNode) and TechnicalResponseNode.SelectSingleNode('error_message', ErrorMessageNode) then
                            EDocumentDescription := StrSubstNo('%1 - %2', ErrorCodeNode.AsXmlElement().InnerText, ErrorMessageNode.AsXmlElement().InnerText);
                        EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, EDocumentDescription);
                        MarkDocumentAsProcessed(DocumentGUID);
                        exit(false);
                    end;
            end;
            exit(false);
        end;
    end;

    #endregion;

    #region Get Document Business Responses
    internal procedure GetBusinessResponses(DocumentGUID: Guid; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    var
        APIUrlMgt: Codeunit "API URL Mgt.";
    begin
        exit(ExecuteRequest('GET', APIUrlMgt.BusinessResponseURL(DocumentGUID), HttpRequest, HttpResponse))
    end;

    #endregion

    #region Perform actions on document

    // Cancel document
    internal procedure CancelDocument(DocumentGUID: Guid; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    begin
        exit(PerformActionOnDocument(DocumentGUID, 'CancelEnum', HttpRequest, HttpResponse));
    end;

    // Mark document as processed
    internal procedure MarkDocumentAsProcessed(DocumentGUID: Guid): Boolean
    var
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
    begin
        exit(PerformActionOnDocument(DocumentGUID, 'MarkAsProcessedEnum', HttpRequest, HttpResponse));
    end;

    internal procedure ApproveDocument(DocumentGUID: Guid): Boolean
    var
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
    begin
        exit(PerformActionOnDocument(DocumentGUID, 'ApproveEnum', HttpRequest, HttpResponse));
    end;

    internal procedure RejectDocument(DocumentGUID: Guid): Boolean
    var
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
    begin
        exit(PerformActionOnDocument(DocumentGUID, 'RejectEnum', HttpRequest, HttpResponse));
    end;

    internal procedure PerformActionOnDocument(DocumentGUID: Guid; Action: Text; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    var
        APIUrlMgt: Codeunit "API URL Mgt.";
        HttpContentData: Text;
        ActionNode: XmlElement;
        RootNode: XmlElement;
    begin
        RootNode := XmlElement.Create('document_action_request');

        ActionNode := XmlElement.Create('action');
        ActionNode.Add(XmlText.Create(Action));
        RootNode.Add(ActionNode);

        RootNode.WriteTo(HttpContentData);

        exit(ExecuteRequest('POST', APIUrlMgt.DocumentActionUrl(DocumentGUID), HttpContentData, HttpRequest, HttpResponse));
    end;
    #endregion

    #region Helper functions
    internal procedure DownloadFileFromURL(URL: Text; var TempBlob: Codeunit "Temp Blob")
    var
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        ReadStream: InStream;
        WriteStream: OutStream;
    begin
        HttpClient.Get(URL, HttpResponseMessage);
        TempBlob.CreateOutStream(WriteStream);
        HttpResponseMessage.Content.ReadAs(ReadStream);
        CopyStream(WriteStream, ReadStream);
    end;

    local procedure ExecuteRequest(Method: Text; Url: Text; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        HttpContentData: Text;
    begin
        exit(ExecuteRequest(Method, Url, HttpContentData, HttpRequestMessage, HttpResponseMessage));
    end;

    local procedure ExecuteRequest(Method: Text; Url: Text; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        HttpRequestMessage: HttpRequestMessage;
        HttpContentData: Text;
    begin
        exit(ExecuteRequest(Method, Url, HttpContentData, HttpRequestMessage, HttpResponseMessage));
    end;

    local procedure ExecuteRequest(Method: Text; Url: Text; HttpContentData: Text; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        HttpRequestMessage: HttpRequestMessage;
    begin
        exit(ExecuteRequest(Method, Url, HttpContentData, HttpRequestMessage, HttpResponseMessage));
    end;


    local procedure ExecuteRequest(Method: Text; Url: Text; HttpContentData: Text; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        SessionManager: Codeunit "Session Manager";
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpContentHeaders: HttpHeaders;
        HttpHeaders: HttpHeaders;
        AccessTokenValue: SecretText;
    begin
        HttpRequestMessage.GetHeaders(HttpHeaders);
        AccessTokenValue := SecretStrSubstNo('Bearer %1', SessionManager.GetAccessToken());

        HttpHeaders.Add('Authorization', AccessTokenValue);
        HttpHeaders.Add('Accept', 'application/xml;charset=utf-8');
        HttpRequestMessage.Method(Method);
        HttpRequestMessage.SetRequestUri(Url);

        if HttpContentData <> '' then begin
            HttpContent.WriteFrom(HttpContentData);
            HttpContent.GetHeaders(HttpContentHeaders);
            if HttpContentHeaders.Contains('Content-Type') then
                HttpContentHeaders.Remove('Content-Type');
            HttpContentHeaders.Add('Content-Type', 'application/xml');
            HttpRequestMessage.Content := HttpContent;
        end;

        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then
            exit(HandleAPIError(HttpResponseMessage));
    end;

    internal procedure HandleAPIError(var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        HttpStatusCode: Integer;
        ResponseBody: Text;
        ResponseBodyXML: XmlDocument;
    begin
        HttpStatusCode := HttpResponseMessage.HttpStatusCode;
        if HttpStatusCode in [200, 201, 202] then
            exit(true);

        HttpResponseMessage.Content().ReadAs(ResponseBody);
        if ResponseBody <> '' then
            if not XmlDocument.ReadFrom(ResponseBody, ResponseBodyXML) then
                exit(ThrowError(UnexpectedAPIErr));

        ReadErrorResponse(ResponseBodyXML, HttpStatusCode);
    end;

    internal procedure ReadErrorResponse(var ResponseXML: XmlDocument; HttpStatusCode: Integer): Boolean
    var
        APIErrorCode: Text;
        APIErrorMessage: Text;
        ErrorCodeNode: XmlNode;
        ErrorMessageNode: XmlNode;
    begin
        if not ResponseXML.SelectSingleNode('/error/code', ErrorCodeNode) then
            exit(ThrowError(UnexpectedAPIErr));
        if not ResponseXML.SelectSingleNode('/error/message', ErrorMessageNode) then
            exit(ThrowError(UnexpectedAPIErr));

        APIErrorCode := ErrorCodeNode.AsXmlElement().InnerText;
        APIErrorMessage := ErrorMessageNode.AsXmlElement().InnerText;

        case HttpStatusCode of
            500, 501:
                exit(ThrowError(StrSubstNo(Error500Err, APIErrorCode, APIErrorMessage)));
            400, 401, 402, 404:
                exit(ThrowError(StrSubstNo(APIErr, APIErrorCode, APIErrorMessage)));
            else
                exit(ThrowError(UnexpectedAPIErr));
        end;
    end;

    local procedure ThrowError(ErrorMsg: Text): Boolean
    begin
        if SupressError then
            exit;
        Error(ErrorMsg);
    end;


    local procedure GetCurrentCountryCode(): Code[10]
    var
        CompanyInformation: Record "Company Information";
        CountryRegion: Record "Country/Region";
    begin
        CompanyInformation.Get();
        if CompanyInformation."Country/Region Code" = '' then
            exit('');
        if CountryRegion.Get(CompanyInformation."Country/Region Code") then
            exit(CountryRegion."ISO Code");
    end;

    internal procedure GetGUIDAsText(Value: Guid): Text[36]
    begin
        exit(CopyStr(DelChr(Value, '<>', '{}'), 1, 36))
    end;

    internal procedure SetSupressError(NewSupressError: Boolean)
    begin
        SupressError := NewSupressError;
    end;

    #endregion

    var
        SupressError: Boolean;
        AccessPointDetailedErr: Label 'Access Point: %1// Contact Email: %2// Registered Profiles://%3', Comment = '%1 = Access Point Name, %2 = Access Point Email, %3 = Registered Profiles';
        APIErr: Label 'The Continia Delivery Network API returned the following error: Error Code %1 - %2', Comment = '%1 = Continia Delivery Network Error Code, %2 = Error Message';
        Error500Err: Label 'The Continia Delivery Network API returned the following system error: Error Code %1 - %2', Comment = '%1 = Continia Delivery Network Error Code, %2 = Error Message';
        ParticipationAlreadyRegisteredErr: Label 'There is already a registration in %1 network with the identifier type %2 and value %3.', Comment = '%1 = Network Name, %2 = Identifier Type, %3 = Identifier Value';

        ParticipationAlreadyRegisteredTitleErr: Label 'Registration Already Exists';
        UnexpectedAPIErr: Label 'There was an unexpected error while communicating with the Continia Delivery Network API.';


}