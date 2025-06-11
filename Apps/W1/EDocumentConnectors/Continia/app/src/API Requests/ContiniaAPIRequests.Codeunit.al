// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

using Microsoft.eServices.EDocument;
using System.Utilities;
using System.Text;
using Microsoft.eServices.EDocument.Integration.Send;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.eServices.EDocument.Integration.Receive;

codeunit 6393 "Continia Api Requests"
{
    Access = Internal;

    Permissions = tabledata "Continia Network Profile" = rimd,
                  tabledata "Continia Network Identifier" = rimd,
                  tabledata "Continia Participation" = rimd,
                  tabledata "Continia Activated Net. Prof." = rimd,
                  tabledata "E-Document" = m;

    #region Get Network Profiles from Continia Delivery Network Api
    internal procedure GetNetworkProfiles(Network: Enum "Continia E-Delivery Network")
    var
        ApiUrlMgt: Codeunit "Continia Api Url";
        HttpResponse: HttpResponseMessage;
        CurrPage: Integer;
        PageSize: Integer;
        TotalCount: Integer;
        HandledRecordsCount: Integer;
        PageRecordsCount: Integer;
    begin
        TotalCount := 0;
        HandledRecordsCount := 0;
        CurrPage := 0;
        PageSize := 100;
        repeat
            CurrPage += 1;
            if ExecuteRequest('GET', ApiUrlMgt.NetworkProfilesUrl(Network, CurrPage, PageSize), HttpResponse) then begin
                if TotalCount = 0 then
                    TotalCount := GetRecordsCount(HttpResponse);
                PageRecordsCount := HandleNetworkProfileResponse(HttpResponse, Network);
                HandledRecordsCount += PageRecordsCount;
            end;
        until (HandledRecordsCount >= TotalCount) or (PageRecordsCount = 0);
    end;

    local procedure HandleNetworkProfileResponse(var HttpResponse: HttpResponseMessage; NetworkName: Enum "Continia E-Delivery Network") HandledRecordsCount: Integer
    var
        NetworkProfile: Record "Continia Network Profile";
        Insert: Boolean;
        NetworkProfileId: Guid;
        i: Integer;
        ResponseBody: Text;
        ResponseXmlDoc: XmlDocument;
        TempXMLNode: XmlNode;
        TempXMLNode2: XmlNode;
        XMLNodeList: XmlNodeList;
    begin
        HttpResponse.Content.ReadAs(ResponseBody);
        if ResponseBody = '' then
            exit;
        XmlDocument.ReadFrom(ResponseBody, ResponseXmlDoc);
        if not ResponseXmlDoc.SelectNodes('/network_profiles/network_profile', XMLNodeList) then
            exit;

        HandledRecordsCount := XMLNodeList.Count;
        for i := 1 to XMLNodeList.Count do begin
            XMLNodeList.Get(i, TempXMLNode);

            TempXMLNode.SelectSingleNode('network_profile_id', TempXMLNode2);

            NetworkProfileId := StrSubstNo('{%1}', TempXMLNode2.AsXmlElement().InnerText);

            if NetworkProfile.Get(NetworkProfileId) then
                Insert := false
            else begin
                NetworkProfile.Init();
                NetworkProfile.Id := NetworkProfileId;
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
    #endregion

    #region Get Network Id Types from Continia Delivery Network Api
    internal procedure GetNetworkIdTypes(Network: Enum "Continia E-Delivery Network")
    var
        ApiUrlMgt: Codeunit "Continia Api Url";
        HttpResponse: HttpResponseMessage;
        CurrPage: Integer;
        PageSize: Integer;
        TotalCount: Integer;
        HandledRecordsCount: Integer;
        PageRecordsCount: Integer;
    begin
        TotalCount := 0;
        HandledRecordsCount := 0;
        CurrPage := 0;
        PageSize := 100;
        repeat
            CurrPage += 1;
            if ExecuteRequest('GET', ApiUrlMgt.NetworkIdentifiersUrl(Network, CurrPage, PageSize), HttpResponse) then begin
                if TotalCount = 0 then
                    TotalCount := GetRecordsCount(HttpResponse);
                PageRecordsCount := HandleNetworkIdTypeResponse(HttpResponse, Network);
                HandledRecordsCount += PageRecordsCount;
            end;
        until (HandledRecordsCount >= TotalCount) or (PageRecordsCount = 0);
    end;

    local procedure HandleNetworkIdTypeResponse(var HttpResponse: HttpResponseMessage; NetworkName: Enum "Continia E-Delivery Network") HandleRecordsCount: Integer
    var
        NetworkIdentifier: Record "Continia Network Identifier";
        Insert: Boolean;
        NetworkIdentifierId: Guid;
        i: Integer;
        ResponseBody: Text;
        ResponseXmlDoc: XmlDocument;
        TempXMLNode: XmlNode;
        TempXMLNode2: XmlNode;
        XMLNodeList: XmlNodeList;
    begin
        HttpResponse.Content.ReadAs(ResponseBody);
        if ResponseBody = '' then
            exit;
        XmlDocument.ReadFrom(ResponseBody, ResponseXmlDoc);
        if not ResponseXmlDoc.SelectNodes('/network_id_types/network_id_type', XMLNodeList) then
            exit;

        HandleRecordsCount := XMLNodeList.Count;
        for i := 1 to XMLNodeList.Count do begin
            XMLNodeList.Get(i, TempXMLNode);

            TempXMLNode.SelectSingleNode('network_id_type_id', TempXMLNode2);

            NetworkIdentifierId := StrSubstNo('{%1}', TempXMLNode2.AsXmlElement().InnerText);

            if NetworkIdentifier.Get(NetworkIdentifierId) then
                Insert := false
            else begin
                NetworkIdentifier.Init();
                NetworkIdentifier.Id := NetworkIdentifierId;
                Insert := true;
            end;

            NetworkIdentifier.Network := NetworkName;

            if TempXMLNode.SelectSingleNode('code_iso6523-1', TempXMLNode2) then
                NetworkIdentifier."Identifier Type Id" := CopyStr(TempXMLNode2.AsXmlElement().InnerText, 1, MaxStrLen(NetworkIdentifier."Identifier Type Id"));

            if TempXMLNode.SelectSingleNode('default_in_country_iso3166', TempXMLNode2) then
                NetworkIdentifier."Default in Country" := CopyStr(TempXMLNode2.AsXmlElement().InnerText, 1, MaxStrLen(NetworkIdentifier."Default in Country"));

            if TempXMLNode.SelectSingleNode('description', TempXMLNode2) then
                NetworkIdentifier.Description := CopyStr(TempXMLNode2.AsXmlElement().InnerText, 1, MaxStrLen(NetworkIdentifier.Description));

            if TempXMLNode.SelectSingleNode('icd_code', TempXMLNode2) then
                NetworkIdentifier."ICD Code" := TempXMLNode2.AsXmlElement().InnerText = 'true';

            if TempXMLNode.SelectSingleNode('network_id_type_id', TempXMLNode2) then
                NetworkIdentifier.Id := TempXMLNode2.AsXmlElement().InnerText;

            if TempXMLNode.SelectSingleNode('scheme_id', TempXMLNode2) then
                NetworkIdentifier."Scheme Id" := CopyStr(TempXMLNode2.AsXmlElement().InnerText, 1, MaxStrLen(NetworkIdentifier."Scheme Id"));

            if TempXMLNode.SelectSingleNode('vat_in_country_iso3166', TempXMLNode2) then
                NetworkIdentifier."VAT in Country" := CopyStr(TempXMLNode2.AsXmlElement().InnerText, 1, MaxStrLen(NetworkIdentifier."VAT in Country"));

            if TempXMLNode.SelectSingleNode('validation_rule', TempXMLNode2) then
                NetworkIdentifier."Validation Rule" := CopyStr(TempXMLNode2.AsXmlElement().InnerText, 1, MaxStrLen(NetworkIdentifier."Validation Rule"));

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
    #endregion

    #region Participation endpoints in Continia Delivery Network
    internal procedure GetParticipation(var Participation: Record "Continia Participation")
    var
        ApiUrlMgt: Codeunit "Continia Api Url";
        HttpResponse: HttpResponseMessage;
    begin
        if ExecuteRequest('GET', ApiUrlMgt.SingleParticipationUrl(Participation.Network, Participation.Id), HttpResponse) then
            HandleParticipationResponse(HttpResponse, Participation);
    end;

    internal procedure PostParticipation(var TempParticipation: Record "Continia Participation" temporary) ParticipationGuid: Guid;
    var
        Participation: Record "Continia Participation";
        ApiUrlMgt: Codeunit "Continia Api Url";
        HttpResponse: HttpResponseMessage;
        HttpContentData: Text;
    begin
        HttpContentData := GetParticipationRequest(TempParticipation, false);

        if ExecuteRequest('POST', ApiUrlMgt.ParticipationUrl(TempParticipation.Network), HttpContentData, HttpResponse) then begin
            Participation := TempParticipation;
            Participation.Insert();
            HandleParticipationResponse(HttpResponse, Participation);
            exit(Participation.Id);
        end;
    end;

    internal procedure PatchParticipation(var TempParticipation: Record "Continia Participation" temporary)
    var
        Participation: Record "Continia Participation";
        ApiUrlMgt: Codeunit "Continia Api Url";
        HttpResponse: HttpResponseMessage;
        HttpContentData: Text;
    begin
        HttpContentData := GetParticipationRequest(TempParticipation, true);

        if ExecuteRequest('PATCH', ApiUrlMgt.SingleParticipationUrl(TempParticipation.Network, TempParticipation.Id), HttpContentData, HttpResponse) then begin
            Participation.Get(TempParticipation.RecordId);
            HandleParticipationResponse(HttpResponse, Participation);
        end;
    end;

    internal procedure DeleteParticipation(var Participation: Record "Continia Participation")
    var
        ApiUrlMgt: Codeunit "Continia Api Url";
        HttpResponse: HttpResponseMessage;
    begin
        if ExecuteRequest('DELETE', ApiUrlMgt.SingleParticipationUrl(Participation.Network, Participation.Id), HttpResponse) then
            case HttpResponse.HttpStatusCode of
                200:
                    Participation.Delete(true);
                202:
                    begin
                        Participation."Registration Status" := Participation."Registration Status"::Disabled;
                        Participation.Modify();
                    end;
            end;
    end;

    local procedure GetParticipationRequest(Participation: Record "Continia Participation"; IncludeTimestamp: Boolean) RequestBody: Text
    var
        CredentialManagement: Codeunit "Continia Credential Management";
        AddressNode: XmlElement;
        CompanyIdNode: XmlElement;
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

        CompanyIdNode := XmlElement.Create('business_central_company_code');
        CompanyIdNode.Add(XmlText.Create(GetGuidAsText(CredentialManagement.GetCompanyId())));
        RootNode.Add(CompanyIdNode);

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
        NetworkIdTypeNode.Add(XmlText.Create(Participation."Identifier Type Id"));
        RootNode.Add(NetworkIdTypeNode);

        NetworkIdValueNode := XmlElement.Create('network_id_value');
        NetworkIdValueNode.Add(XmlText.Create(Participation."Identifier Value"));
        RootNode.Add(NetworkIdValueNode);

        if not IsNullGuid(Participation.Id) then begin
            NetworkIdTypeNode := XmlElement.Create('participation_id');
            NetworkIdTypeNode.Add(XmlText.Create(GetGuidAsText(Participation.Id)));
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
            TimestampNode.Add(XmlText.Create(Participation."Cdn Timestamp"));
            RootNode.Add(TimestampNode);
        end;

        VatRegistrationNoNode := XmlElement.Create('vat_registration_no');
        VatRegistrationNoNode.Add(XmlText.Create(Participation."VAT Registration No."));
        RootNode.Add(VatRegistrationNoNode);

        RootNode.WriteTo(RequestBody);
    end;

    local procedure HandleParticipationResponse(var HttpResponse: HttpResponseMessage; var Participation: Record "Continia Participation")
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
        ParicipationIdNode: XmlNode;
        PostCodeNode: XmlNode;
        PublishInRegistryNode: XmlNode;
        RegistrantNameNode: XmlNode;
        StatusNode: XmlNode;
        TimestampNode: XmlNode;
        UpdatedNode: XmlNode;
        VatRegistrationNoNode: XmlNode;
    begin
        HttpResponse.Content.ReadAs(ResponseBody);
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

        ResponseXmlDoc.SelectSingleNode('/participation/participation_id', ParicipationIdNode);
        Evaluate(Participation.Id, ParicipationIdNode.AsXmlElement().InnerText);

        ResponseXmlDoc.SelectSingleNode('/participation/status', StatusNode);
        Participation.ValidateCdnStatus(StatusNode.AsXmlElement().InnerText);

        ResponseXmlDoc.SelectSingleNode('/participation/created_utc', CreatedNode);
        Evaluate(Participation.Created, CreatedNode.AsXmlElement().InnerText, 9);

        ResponseXmlDoc.SelectSingleNode('/participation/updated_utc', UpdatedNode);
        Evaluate(Participation.Updated, UpdatedNode.AsXmlElement().InnerText, 9);

        ResponseXmlDoc.SelectSingleNode('/participation/timestamp', TimestampNode);
        Participation."Cdn Timestamp" := CopyStr(TimestampNode.AsXmlElement().InnerText, 1, MaxStrLen(Participation."Cdn Timestamp"));

        Participation.Modify();
    end;
    #endregion

    #region Participation Profiles endpoints in Continia Delivery Network
    internal procedure PostParticipationProfile(var TempActivatedNetworkProfile: Record "Continia Activated Net. Prof." temporary; ParticipationGuid: Guid) ActivatedNetworkProfileGuid: Guid
    var
        ActivatedNetProf: Record "Continia Activated Net. Prof.";
        ApiUrlMgt: Codeunit "Continia Api Url";
        HttpResponse: HttpResponseMessage;
        HttpContentData: Text;
    begin
        HttpContentData := GetParticipationProfilesRequest(TempActivatedNetworkProfile);

        if ExecuteRequest('POST', ApiUrlMgt.ParticipationProfilesUrl(TempActivatedNetworkProfile.Network, ParticipationGuid), HttpContentData, HttpResponse) then begin
            ActivatedNetProf := TempActivatedNetworkProfile;
            ActivatedNetProf.Insert();
            UpdateParticipationProfile(HttpResponse, ActivatedNetProf);
            exit(ActivatedNetProf.Id);
        end;
    end;

    internal procedure PatchParticipationProfile(var TempActivatedNetworkProfile: Record "Continia Activated Net. Prof." temporary; ParticipationGuid: Guid)
    var
        ActivatedNetProf: Record "Continia Activated Net. Prof.";
        ApiUrlMgt: Codeunit "Continia Api Url";
        HttpResponse: HttpResponseMessage;
        HttpContentData: Text;
    begin
        HttpContentData := GetParticipationProfilesRequest(TempActivatedNetworkProfile);

        if ExecuteRequest('PATCH', ApiUrlMgt.SingleParticipationProfileUrl(TempActivatedNetworkProfile.Network, ParticipationGuid, TempActivatedNetworkProfile.Id), HttpContentData, HttpResponse) then begin
            ActivatedNetProf.Get(TempActivatedNetworkProfile.RecordId);
            UpdateParticipationProfile(HttpResponse, ActivatedNetProf);
        end;
    end;

    internal procedure DeleteParticipationProfile(var ActivatedNetworkProfile: Record "Continia Activated Net. Prof."; ParticipationGuid: Guid)
    var
        ApiUrlMgt: Codeunit "Continia Api Url";
        HttpResponse: HttpResponseMessage;
    begin
        if ExecuteRequest('DELETE', ApiUrlMgt.SingleParticipationProfileUrl(ActivatedNetworkProfile.Network, ParticipationGuid, ActivatedNetworkProfile.Id), HttpResponse) then begin
            ActivatedNetworkProfile.Validate(Disabled, CreateDateTime(Today, Time));
            ActivatedNetworkProfile.Modify();
        end;
    end;

    internal procedure GetAllParticipationProfiles(Participation: Record "Continia Participation")
    var
        ApiUrlMgt: Codeunit "Continia Api Url";
        HttpResponse: HttpResponseMessage;
        CurrPage: Integer;
        PageSize: Integer;
        TotalCount: Integer;
        PageRecordsCount: Integer;
        HandledRecordsCount: Integer;
    begin
        TotalCount := 0;
        HandledRecordsCount := 0;
        CurrPage := 0;
        PageSize := 100;
        repeat
            CurrPage += 1;
            if ExecuteRequest('GET', ApiUrlMgt.ParticipationProfilesUrl(Participation.Network, Participation.Id, CurrPage, PageSize), HttpResponse) then begin
                if TotalCount = 0 then
                    TotalCount := GetRecordsCount(HttpResponse);
                HandleApiError(HttpResponse);
                PageRecordsCount := ReadParticipationProfilesResponse(HttpResponse, Participation);
                HandledRecordsCount += PageRecordsCount;
            end;
        until (HandledRecordsCount >= TotalCount) or (PageRecordsCount = 0);
    end;

    local procedure ReadParticipationProfilesResponse(var HttpResponse: HttpResponseMessage; Participation: Record "Continia Participation") HandledRecordsCount: Integer
    var
        i: Integer;
        ResponseBody: Text;
        ResponseXmlDoc: XmlDocument;
        Node: XmlNode;
        NodeList: XmlNodeList;
    begin
        HttpResponse.Content.ReadAs(ResponseBody);
        if ResponseBody = '' then
            exit;

        XmlDocument.ReadFrom(ResponseBody, ResponseXmlDoc);
        if not ResponseXmlDoc.SelectNodes('/participation_profiles/participation_profile', NodeList) then
            exit;

        HandledRecordsCount := NodeList.Count;

        for i := 1 to NodeList.Count do begin
            NodeList.Get(i, Node);
            CreateOrUpdateParticipProfiles(Participation, Node);
        end;
    end;

    local procedure GetParticipationProfilesRequest(ActivatedNetworkProfile: Record "Continia Activated Net. Prof.") RequestBody: Text
    var
        ParticipationProfileNode: XmlElement;
        ProfileDirectionNode: XmlElement;
        ProfileIdNode: XmlElement;
    begin
        ParticipationProfileNode := XmlElement.Create('participation_profile');

        ProfileDirectionNode := XmlElement.Create('direction');
        ProfileDirectionNode.Add(XmlText.Create(ActivatedNetworkProfile.GetParticipApiDirectionEnum()));
        ParticipationProfileNode.Add(ProfileDirectionNode);

        ProfileIdNode := XmlElement.Create('network_profile_id');
        ProfileIdNode.Add(XmlText.Create(GetGuidAsText(ActivatedNetworkProfile."Network Profile Id")));
        ParticipationProfileNode.Add(ProfileIdNode);

        ParticipationProfileNode.WriteTo(RequestBody);
    end;

    local procedure CreateOrUpdateParticipProfiles(Participation: Record "Continia Participation"; ProfilesNode: XmlNode)
    var
        ActivatedNetworkProfile: Record "Continia Activated Net. Prof.";
        ProfileGuid: Guid;
        CreatedNode: XmlNode;
        DirectionNode: XmlNode;
        DisabledNode: XmlNode;
        ParticipationProfileIdNode: XmlNode;
        ProfileIdNode: XmlNode;
        UpdatedNode: XmlNode;
    begin
        ProfilesNode.SelectSingleNode('network_profile_id', ProfileIdNode);
        Evaluate(ProfileGuid, ProfileIdNode.AsXmlElement().InnerText);
        if not ActivatedNetworkProfile.Get(Participation.Network, Participation."Identifier Type Id", Participation."Identifier Value", ProfileGuid) then begin
            ActivatedNetworkProfile.Init();
            ActivatedNetworkProfile.Network := Participation.Network;
            ActivatedNetworkProfile."Identifier Type Id" := Participation."Identifier Type Id";
            ActivatedNetworkProfile."Identifier Value" := Participation."Identifier Value";
            ActivatedNetworkProfile."Network Profile Id" := ProfileGuid;
            ActivatedNetworkProfile.Insert();
        end;

        ProfilesNode.SelectSingleNode('participation_profile_id', ParticipationProfileIdNode);
        Evaluate(ActivatedNetworkProfile.Id, ParticipationProfileIdNode.AsXmlElement().InnerText);

        ProfilesNode.SelectSingleNode('direction', DirectionNode);
        ActivatedNetworkProfile.ValidateApiDirection(DirectionNode.AsXmlElement().InnerText);

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

    local procedure UpdateParticipationProfile(var HttpResponse: HttpResponseMessage; var ActivatedNetworkProfile: Record "Continia Activated Net. Prof.")
    var
        ResponseBody: Text;
        ResponseXmlDoc: XmlDocument;
        CreatedNode: XmlNode;
        DirectionNode: XmlNode;
        DisabledNode: XmlNode;
        ProfileIdNode: XmlNode;
        UpdatedNode: XmlNode;
    begin
        HttpResponse.Content.ReadAs(ResponseBody);
        if ResponseBody = '' then
            exit;

        XmlDocument.ReadFrom(ResponseBody, ResponseXmlDoc);
        ResponseXmlDoc.SelectSingleNode('/participation_profile/participation_profile_id', ProfileIdNode);
        Evaluate(ActivatedNetworkProfile.Id, ProfileIdNode.AsXmlElement().InnerText);

        ResponseXmlDoc.SelectSingleNode('/participation_profile/direction', DirectionNode);
        ActivatedNetworkProfile.ValidateApiDirection(DirectionNode.AsXmlElement().InnerText);

        ResponseXmlDoc.SelectSingleNode('/participation_profile/created_utc', CreatedNode);
        Evaluate(ActivatedNetworkProfile.Created, CreatedNode.AsXmlElement().InnerText, 9);

        ResponseXmlDoc.SelectSingleNode('/participation_profile/updated_utc', UpdatedNode);
        Evaluate(ActivatedNetworkProfile.Updated, UpdatedNode.AsXmlElement().InnerText, 9);

        if ResponseXmlDoc.SelectSingleNode('/participation_profile/disabled_utc', DisabledNode) then
            Evaluate(ActivatedNetworkProfile.Disabled, DisabledNode.AsXmlElement().InnerText)
        else
            Clear(ActivatedNetworkProfile.Disabled);

        ActivatedNetworkProfile.Modify();
    end;
    #endregion

    #region Participation Profiles Lookup endpoints in Continia Delivery Network
    internal procedure CheckProfilesNotRegistered(var TempParticipation: Record "Continia Participation" temporary)
    var
        NetworkIdentifier: Record "Continia Network Identifier";
        ApiUrlMgt: Codeunit "Continia Api Url";
        HttpResponse: HttpResponseMessage;
    begin
        NetworkIdentifier := TempParticipation.GetNetworkIdentifier();

        if ExecuteRequest('GET', ApiUrlMgt.ParticipationLookupUrl(TempParticipation.Network, NetworkIdentifier."Identifier Type Id", TempParticipation."Identifier Value"), HttpResponse) then
            HandleProfilesLookupResponse(HttpResponse, TempParticipation);
    end;

    local procedure HandleProfilesLookupResponse(var HttpResponse: HttpResponseMessage; var TempParticipation: Record "Continia Participation" temporary)
    var
        ErrorInfo: ErrorInfo;
        ProfileGuid: Guid;
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
        ProfileId: XmlNode;
        ProfileNode: XmlNode;
        ProfileDescriptionNode: XmlNode;
        AccessPointNodeList: XmlNodeList;
        ProfilesNodeList: XmlNodeList;
    begin
        HttpResponse.Content.ReadAs(ResponseBody);
        if ResponseBody = '' then
            exit;

        XmlDocument.ReadFrom(ResponseBody, ResponseXmlDoc);
        ResponseXmlDoc.SelectNodes('/participation_lookups/participation_lookup/external_access_points/access_point', AccessPointNodeList);
        for i := 1 to AccessPointNodeList.Count do begin
            AccessPointNodeList.Get(i, AccessPointNode);
            AccessPointNode.SelectNodes('supported_profiles/network_profile', ProfilesNodeList);
            for j := 1 to ProfilesNodeList.Count do begin
                ProfilesNodeList.Get(j, ProfileNode);
                if ProfileNode.SelectSingleNode('network_profile_id', ProfileId) then begin
                    Evaluate(ProfileGuid, ProfileId.AsXmlElement().InnerText);
                    ProfileNode.SelectSingleNode('description', ProfileDescriptionNode);
                    AccessPointNode.SelectSingleNode('name', APNameNode);
                    AccessPointNode.SelectSingleNode('email', APEmailNode);
                    AccessPointName := APNameNode.AsXmlElement().InnerText;
                    AccessPointEmail := APEmailNode.AsXmlElement().InnerText;

                    RegisteredProfilesErrText += StrSubstNo('%1 //', ProfileDescriptionNode.AsXmlElement().InnerText);
                end;
            end;

            if RegisteredProfilesErrText <> '' then begin
                AccessPointErrText := StrSubstNo(AccessPointDetailedErr, AccessPointName, AccessPointEmail, RegisteredProfilesErrText);
                DetailedErrText += StrSubstNo('%1 // //', AccessPointErrText);
            end
        end;

        if RegisteredProfilesErrText <> '' then begin
            ErrorInfo.Title := ParticipationAlreadyRegisteredTitleErr;
            ErrorInfo.Message := StrSubstNo(ParticipationAlreadyRegisteredErr, TempParticipation.Network, TempParticipation."Identifier Type Id", TempParticipation."Identifier Value");
            ErrorInfo.DetailedMessage(DetailedErrText);
            Error(ErrorInfo);
        end
    end;
    #endregion

    #region Get Documents for E-Document service
    internal procedure GetDocuments(ActivatedNetworkProfile: Record "Continia Activated Net. Prof."; ReceiveContext: Codeunit ReceiveContext): Boolean
    var
        Participation: Record "Continia Participation";
        ApiUrlMgt: Codeunit "Continia Api Url";
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        CurrPage: Integer;
        PageSize: Integer;
        Success: Boolean;
    begin
        CurrPage := 1;
        PageSize := 100; // only get 100 documents at a time.

        Participation.Get(ActivatedNetworkProfile.Network, ActivatedNetworkProfile."Identifier Type Id", ActivatedNetworkProfile."Identifier Value");

        Success := ExecuteRequest(
            'GET',
            ApiUrlMgt.DocumentsFoParticipationProfile(
                ActivatedNetworkProfile.Network,
                Participation.Id,
                ActivatedNetworkProfile.Id,
                CurrPage,
                PageSize,
                true),
            HttpRequest,
            HttpResponse);
        ReceiveContext.Http().SetHttpRequestMessage(HttpRequest);
        ReceiveContext.Http().SetHttpResponseMessage(HttpResponse);
        exit(Success);
    end;
    #endregion

    #region Send Documents
    internal procedure SendDocument(EDocument: Record "E-Document"; SendContext: Codeunit SendContext): Boolean
    var
        ConnectionSetup: Record "Continia Connection Setup";
        CredentialManagement: Codeunit "Continia Credential Management";
        Base64Convert: Codeunit "Base64 Convert";
        ApiUrlMgt: Codeunit "Continia Api Url";
        TempBlob: Codeunit "Temp Blob";
        HttpResponse: HttpResponseMessage;
        HttpRequest: HttpRequestMessage;
        ReadStream: InStream;
        HttpContentData: Text;
        DocumentBase64Node: XmlElement;
        RootNode: XmlElement;
        Success: Boolean;
    begin
        ConnectionSetup.Get();

        TempBlob := SendContext.GetTempBlob();

        RootNode := XmlElement.Create('unprocessed_document_request');
        DocumentBase64Node := XmlElement.Create('base64_data');
        TempBlob.CreateInStream(ReadStream);
        DocumentBase64Node.Add(XmlText.Create(Base64Convert.ToBase64(ReadStream)));
        RootNode.Add(DocumentBase64Node);

        RootNode.WriteTo(HttpContentData);

        Success := ExecuteRequest('POST', ApiUrlMgt.PostDocumentsUrl(CredentialManagement.GetCompanyId()), HttpContentData, HttpRequest, HttpResponse);
        SendContext.Http().SetHttpRequestMessage(HttpRequest);
        SendContext.Http().SetHttpResponseMessage(HttpResponse);

        if Success then begin
            SetEDocumentGuid(EDocument."Entry No", GetDocumentGuid(HttpResponse));
            exit(true);
        end;
    end;

    local procedure SetEDocumentGuid(EDocEntryNo: Integer; DocumentId: Guid)
    var
        EDocument: Record "E-Document";
    begin
        if IsNullGuid(DocumentId) then
            exit;
        if not EDocument.Get(EDocEntryNo) then
            exit;
        EDocument."Continia Document Id" := DocumentId;
        EDocument.Modify();
    end;

    local procedure GetDocumentGuid(var HttpResponse: HttpResponseMessage) DocumentGuid: Guid
    var
        ResponseBody: Text;
        ResponseXmlDoc: XmlDocument;
        DocumentGuidNode: XmlNode;
    begin
        HttpResponse.Content.ReadAs(ResponseBody);
        if ResponseBody = '' then
            exit;

        XmlDocument.ReadFrom(ResponseBody, ResponseXmlDoc);
        ResponseXmlDoc.SelectSingleNode('/id_result/id', DocumentGuidNode);
        Evaluate(DocumentGuid, DocumentGuidNode.AsXmlElement().InnerText);
        exit(DocumentGuid);
    end;
    #endregion

    #region Get Technical response
    internal procedure GetTechnicalResponse(var EDocument: Record "E-Document"; SendContext: Codeunit SendContext): Boolean
    var
        ApiUrlMgt: Codeunit "Continia Api Url";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        SuccessfulStatusTok: Label 'SuccessEnum', Locked = true;
        ErrorStatusTok: Label 'ErrorEnum', Locked = true;
        DocumentStatus: Text;
        EDocumentDescription: Text;
        ResponseBody: Text;
        ResponseXmlDoc: XmlDocument;
        DocumentStatusNode: XmlNode;
        ErrorCodeNode: XmlNode;
        ErrorMessageNode: XmlNode;
        TechnicalResponseNode: XmlNode;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        Success: Boolean;
    begin
        Success := ExecuteRequest('GET', ApiUrlMgt.TechnicalResponseUrl(EDocument."Continia Document Id"), HttpRequest, HttpResponse);
        SendContext.Http().SetHttpRequestMessage(HttpRequest);
        SendContext.Http().SetHttpResponseMessage(HttpResponse);
        if Success then begin
            HttpResponse.Content.ReadAs(ResponseBody);
            if ResponseBody = '' then
                exit(false);

            XmlDocument.ReadFrom(ResponseBody, ResponseXmlDoc);
            ResponseXmlDoc.SelectSingleNode('/technical_response', TechnicalResponseNode);

            if not TechnicalResponseNode.SelectSingleNode('document_status', DocumentStatusNode) then
                exit(false);

            DocumentStatus := DocumentStatusNode.AsXmlElement().InnerText;
            case DocumentStatus of
                SuccessfulStatusTok:
                    begin
                        MarkDocumentAsProcessed(EDocument."Continia Document Id");
                        exit(true);
                    end;
                ErrorStatusTok:
                    begin
                        if TechnicalResponseNode.SelectSingleNode('error_code', ErrorCodeNode) and TechnicalResponseNode.SelectSingleNode('error_message', ErrorMessageNode) then
                            EDocumentDescription := StrSubstNo('%1 - %2', ErrorCodeNode.AsXmlElement().InnerText, ErrorMessageNode.AsXmlElement().InnerText);
                        EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, EDocumentDescription);
                        MarkDocumentAsProcessed(EDocument."Continia Document Id");
                        exit(false);
                    end;
            end;
            exit(false);
        end;
    end;
    #endregion;

    #region Get Document Business Responses
    internal procedure GetBusinessResponses(DocumentGuid: Guid; ActionContext: Codeunit ActionContext): Boolean
    var
        ApiUrlMgt: Codeunit "Continia Api Url";
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        Success: Boolean;
    begin
        Success := ExecuteRequest('GET', ApiUrlMgt.BusinessResponseUrl(DocumentGuid), HttpRequest, HttpResponse);
        ActionContext.Http().SetHttpRequestMessage(HttpRequest);
        ActionContext.Http().SetHttpResponseMessage(HttpResponse);
        exit(Success);
    end;
    #endregion

    #region Perform actions on document
    // Cancel document
    internal procedure CancelDocument(DocumentGuid: Guid; ActionContext: Codeunit ActionContext): Boolean
    var
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        Success: Boolean;
    begin
        Success := PerformActionOnDocument(DocumentGuid, 'CancelEnum', HttpRequest, HttpResponse);
        if Success then
            ActionContext.Status().SetStatus(Enum::"E-Document Service Status"::Canceled);

        ActionContext.Http().SetHttpRequestMessage(HttpRequest);
        ActionContext.Http().SetHttpResponseMessage(HttpResponse);
        exit(Success);
    end;

    // Mark document as processed
    internal procedure MarkDocumentAsProcessed(DocumentGuid: Guid): Boolean
    var
        ReceiveContext: Codeunit ReceiveContext;
    begin
        exit(MarkDocumentAsProcessed(DocumentGuid, ReceiveContext));
    end;

    internal procedure MarkDocumentAsProcessed(DocumentGuid: Guid; ReceiveContext: Codeunit ReceiveContext): Boolean
    var
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        Success: Boolean;
    begin
        Success := PerformActionOnDocument(DocumentGuid, 'MarkAsProcessedEnum', HttpRequest, HttpResponse);
        ReceiveContext.Http().SetHttpRequestMessage(HttpRequest);
        ReceiveContext.Http().SetHttpResponseMessage(HttpResponse);
        exit(Success);
    end;

    internal procedure PerformActionOnDocument(DocumentGuid: Guid; Action: Text; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    var
        ApiUrlMgt: Codeunit "Continia Api Url";
        HttpContentData: Text;
        ActionNode: XmlElement;
        RootNode: XmlElement;
    begin
        RootNode := XmlElement.Create('document_action_request');

        ActionNode := XmlElement.Create('action');
        ActionNode.Add(XmlText.Create(Action));
        RootNode.Add(ActionNode);

        RootNode.WriteTo(HttpContentData);

        exit(ExecuteRequest('POST', ApiUrlMgt.DocumentActionUrl(DocumentGuid), HttpContentData, HttpRequest, HttpResponse));
    end;
    #endregion

    #region Helper functions
    internal procedure DownloadFileFromUrl(Url: Text; ReceiveContext: Codeunit ReceiveContext)
    var
        HttpClient: HttpClient;
        ReadStream: InStream;
        WriteStream: OutStream;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        Success: Boolean;
    begin
        Success := HttpClient.Get(Url, HttpResponse);
        ReceiveContext.Http().SetHttpRequestMessage(HttpRequest);
        ReceiveContext.Http().SetHttpResponseMessage(HttpResponse);
        if not Success then
            exit;
        ReceiveContext.GetTempBlob().CreateOutStream(WriteStream);
        HttpResponse.Content.ReadAs(ReadStream);
        CopyStream(WriteStream, ReadStream);
    end;

    local procedure ExecuteRequest(Method: Text; Url: Text; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    var
        HttpContentData: Text;
    begin
        exit(ExecuteRequest(Method, Url, HttpContentData, HttpRequest, HttpResponse));
    end;

    local procedure ExecuteRequest(Method: Text; Url: Text; var HttpResponse: HttpResponseMessage): Boolean
    var
        HttpRequest: HttpRequestMessage;
        HttpContentData: Text;
    begin
        exit(ExecuteRequest(Method, Url, HttpContentData, HttpRequest, HttpResponse));
    end;

    local procedure ExecuteRequest(Method: Text; Url: Text; HttpContentData: Text; var HttpResponse: HttpResponseMessage): Boolean
    var
        HttpRequest: HttpRequestMessage;
    begin
        exit(ExecuteRequest(Method, Url, HttpContentData, HttpRequest, HttpResponse));
    end;

    local procedure ExecuteRequest(Method: Text; Url: Text; HttpContentData: Text; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    var
        SessionManager: Codeunit "Continia Session Manager";
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpContentHeaders: HttpHeaders;
        HttpHeaders: HttpHeaders;
        AccessTokenValue: SecretText;
    begin
        HttpRequest.GetHeaders(HttpHeaders);
        AccessTokenValue := SecretStrSubstNo('Bearer %1', SessionManager.GetAccessToken());

        HttpHeaders.Add('Authorization', AccessTokenValue);
        HttpHeaders.Add('Accept', 'application/xml;charset=utf-8');
        HttpRequest.Method(Method);
        HttpRequest.SetRequestUri(Url);

        if HttpContentData <> '' then begin
            HttpContent.WriteFrom(HttpContentData);
            HttpContent.GetHeaders(HttpContentHeaders);
            if HttpContentHeaders.Contains('Content-Type') then
                HttpContentHeaders.Remove('Content-Type');
            HttpContentHeaders.Add('Content-Type', 'application/xml');
            HttpRequest.Content := HttpContent;
        end;

        if HttpClient.Send(HttpRequest, HttpResponse) then
            exit(HandleApiError(HttpResponse));
    end;

    local procedure GetRecordsCount(var HttpResponse: HttpResponseMessage) Count: Integer
    var
        ResponseHeaders: HttpHeaders;
        HeaderValues: List of [Text];
    begin
        ResponseHeaders := HttpResponse.Headers();
        if not ResponseHeaders.Contains('X-Total-Count') then
            exit;

        ResponseHeaders.GetValues('X-Total-Count', HeaderValues);
        Evaluate(Count, HeaderValues.Get(1));
    end;

    internal procedure HandleApiError(var HttpResponse: HttpResponseMessage): Boolean
    var
        HttpStatusCode: Integer;
        ResponseBody: Text;
        ResponseBodyXML: XmlDocument;
    begin
        HttpStatusCode := HttpResponse.HttpStatusCode;
        if HttpStatusCode in [200, 201, 202] then
            exit(true);

        HttpResponse.Content().ReadAs(ResponseBody);
        if ResponseBody <> '' then
            if not XmlDocument.ReadFrom(ResponseBody, ResponseBodyXML) then
                exit(ThrowError(UnexpectedApiErr));

        ReadErrorResponse(ResponseBodyXML, HttpStatusCode);
    end;

    internal procedure ReadErrorResponse(var ResponseXML: XmlDocument; HttpStatusCode: Integer): Boolean
    var
        ApiErrorCode: Text;
        ApiErrorMessage: Text;
        ErrorCodeNode: XmlNode;
        ErrorMessageNode: XmlNode;
    begin
        if not ResponseXML.SelectSingleNode('/error/code', ErrorCodeNode) then
            exit(ThrowError(UnexpectedApiErr));

        if not ResponseXML.SelectSingleNode('/error/message', ErrorMessageNode) then
            exit(ThrowError(UnexpectedApiErr));

        ApiErrorCode := ErrorCodeNode.AsXmlElement().InnerText;
        ApiErrorMessage := ErrorMessageNode.AsXmlElement().InnerText;

        case HttpStatusCode of
            500, 501:
                exit(ThrowError(StrSubstNo(Error500Err, ApiErrorCode, ApiErrorMessage)));
            400, 401, 402, 404, 409, 422:
                exit(ThrowError(StrSubstNo(ApiErr, ApiErrorCode, ApiErrorMessage)));
            else
                exit(ThrowError(UnexpectedApiErr));
        end;
    end;

    local procedure ThrowError(ErrorMsg: Text): Boolean
    begin
        if SuppressError then
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

    internal procedure GetGuidAsText(Value: Guid): Text[36]
    begin
        exit(CopyStr(Format(Value, 0, 4), 1, 36))
    end;

    internal procedure SetSuppressError(NewSuppressError: Boolean)
    begin
        SuppressError := NewSuppressError;
    end;
    #endregion

    var
        SuppressError: Boolean;
        AccessPointDetailedErr: Label 'Access Point: %1// Contact Email: %2// Registered Profiles://%3', Comment = '%1 = Access Point Name, %2 = Access Point Email, %3 = Registered Profiles';
        ApiErr: Label 'The Continia Delivery Network API returned the following error: Error Code %1 - %2', Comment = '%1 = Continia Delivery Network Error Code, %2 = Error Message';
        Error500Err: Label 'The Continia Delivery Network API returned the following system error: Error Code %1 - %2', Comment = '%1 = Continia Delivery Network Error Code, %2 = Error Message';
        ParticipationAlreadyRegisteredErr: Label 'There is already a registration in %1 network with the identifier type %2 and value %3.', Comment = '%1 = Network Name, %2 = Identifier Type, %3 = Identifier Value';
        ParticipationAlreadyRegisteredTitleErr: Label 'Registration Already Exists';
        UnexpectedApiErr: Label 'There was an unexpected error while communicating with the Continia Delivery Network API.';


}