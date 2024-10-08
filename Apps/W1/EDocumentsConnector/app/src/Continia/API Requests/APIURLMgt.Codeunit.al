// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;
using System.Environment;

codeunit 6392 "API URL Mgt."
{
    Access = Internal;
    internal procedure NetworkProfilesURL(Network: Enum "Network"; Page: Integer; PageSize: Integer): Text
    var
        ProfilesUrlLbl: Label '%1/networks/%2/profiles.xml?page=%3&page_size=%4', Locked = true;
    begin
        exit(StrSubstNo(ProfilesUrlLbl, CDNBaseURL(), GetNetworkNameAsText(Network), Page, PageSize));
    end;

    internal procedure NetworkIdentifiersURL(Network: Enum "Network"; Page: Integer; PageSize: Integer): Text
    var
        IdentifiersUrlLbl: Label '%1/networks/%2/id_types.xml?page=%3&page_size=%4', Locked = true;
    begin
        exit(StrSubstNo(IdentifiersUrlLbl, CDNBaseURL(), GetNetworkNameAsText(Network), Page, PageSize));
    end;

    internal procedure ParticipationURL(Network: Enum "Network"): Text
    var
        ParticipationUrlLbl: Label '%1/networks/%2/participations.xml', Locked = true;
    begin
        exit(StrSubstNo(ParticipationUrlLbl, CDNBaseURL(), GetNetworkNameAsText(Network)))
    end;

    internal procedure SingleParticipationURL(Network: Enum "Network"; ParticipationGUID: Guid): Text
    var
        SingleParticipationUrlLbl: Label '%1/networks/%2/participations/%3.xml', Locked = true;
    begin
        exit(StrSubstNo(SingleParticipationUrlLbl, CDNBaseURL(), GetNetworkNameAsText(Network), GetGUIDAsText(ParticipationGUID)))
    end;

    internal procedure ParticipationProfilesURL(Network: Enum "Network"; ParticipationGUID: Guid): Text
    var
        ParticipationProfilesUrlLbl: Label '%1/networks/%2/participations/%3/profiles.xml', Locked = true;
    begin
        exit(StrSubstNo(ParticipationProfilesUrlLbl, CDNBaseURL(), GetNetworkNameAsText(Network), GetGUIDAsText(ParticipationGUID)))
    end;

    internal procedure ParticipationProfilesURL(Network: Enum "Network"; ParticipationGUID: Guid; Page: Integer; PageSize: Integer): Text
    var
        ParticipationProfilesUrlPagesLbl: Label '%1/networks/%2/participations/%3/profiles.xml?page=%4&page_size=%5', Locked = true;
    begin
        exit(StrSubstNo(ParticipationProfilesUrlPagesLbl, CDNBaseURL(), GetNetworkNameAsText(Network), GetGUIDAsText(ParticipationGUID), Page, PageSize))
    end;

    internal procedure SingleParticipationProfileURL(Network: Enum "Network"; ParticipationGUID: Guid; ProfileGUID: Guid): Text
    var
        SingleParticipationProfileUrlLbl: Label '%1/networks/%2/participations/%3/profiles/%4.xml', Locked = true;
    begin
        exit(StrSubstNo(SingleParticipationProfileUrlLbl, CDNBaseURL(), GetNetworkNameAsText(Network), GetGUIDAsText(ParticipationGUID), GetGUIDAsText(ProfileGUID)))
    end;

    internal procedure ParticipationLookupURL(Network: Enum "Network"; IdType: Text[4]; IdValue: Text[50]): Text
    var
        ParticipationLookupUrlLbl: Label '%1/networks/%2/participation_lookups.xml?id_type=%3&id_value=%4', Locked = true;
    begin
        exit(StrSubstNo(ParticipationLookupUrlLbl, CDNBaseURL(), GetNetworkNameAsText(Network), IdType, IdValue))
    end;

    internal procedure DocumentsForCompanyURL(CompanyGUID: Guid; Page: Integer; PageSize: Integer; Incoming: Boolean): Text
    var
        DirectionQueryTxt: Text;
        DocumentsForCompanyUrlLbl: Label '%1/documents.xml?business_central_company_code=%2&page=%3&page_size=%4&direction=%5', Locked = true;
    begin
        if Incoming then
            DirectionQueryTxt := 'IncomingEnum'
        else
            DirectionQueryTxt := 'OutgoingEnum';
        exit(StrSubstNo(DocumentsForCompanyUrlLbl, CDNBaseURL(), GetGUIDAsText(CompanyGUID), Page, PageSize, DirectionQueryTxt))
    end;

    internal procedure DocumentActionUrl(DocumentGUID: Guid): Text
    var
        DocumentActionUrlLbl: Label '%1/documents/%2/action.xml', Locked = true;
    begin
        exit(StrSubstNo(DocumentActionUrlLbl, CDNBaseURL(), GetGUIDAsText(DocumentGUID)))
    end;

    internal procedure PostDocumentsUrl(CompanyGUID: Guid): Text
    var
        PostDocumentsUrlLbl: Label '%1/documents.xml?business_central_company_code=%2', Locked = true;
    begin
        exit(StrSubstNo(PostDocumentsUrlLbl, CDNBaseURL(), GetGUIDAsText(CompanyGUID)))
    end;

    internal procedure TechnicalResponseURL(DocumentGUID: Guid): Text
    var
        TechnicalResponseUrlLbl: Label '%1/documents/%2/technical_response.xml', Locked = true;
    begin
        exit(StrSubstNo(TechnicalResponseUrlLbl, CDNBaseURL(), GetGUIDAsText(DocumentGUID)))
    end;

    internal procedure BusinessResponseURL(DocumentGUID: Guid): Text
    var
        BusinessResponseUrlLbl: Label '%1/documents/%2/business_responses.xml', Locked = true;
    begin
        exit(StrSubstNo(BusinessResponseUrlLbl, CDNBaseURL(), GetGUIDAsText(DocumentGUID)))
    end;

    internal procedure PartnerAccessTokenUrl(): Text
    var
        PartnerAccessTokenUrlLbl: Label '%1/partner/PartnerZoneLogin', Locked = true;
    begin
        exit(StrSubstNo(PartnerAccessTokenUrlLbl, COBaseUrl()));
    end;

    internal procedure PartnerZoneUrl(): Text
    var
        PartnerAccessTokenUrlLbl: Label '%1/partner/PartnerZoneConnect', Locked = true;
    begin
        exit(StrSubstNo(PartnerAccessTokenUrlLbl, COBaseUrl()));
    end;

    internal procedure ClientAccessTokenUrl(): Text
    var
        ClientAccessTokenUrlLbl: Label '%1/oauth/token/', Locked = true;
    begin
        exit(StrSubstNo(ClientAccessTokenUrlLbl, COBaseUrl()));
    end;

    internal procedure ClientEnvironmentInitializeUrl(): Text
    var
        ClientEnvironmentInitializeUrlLbl: Label '%1/core/initializeV3', Locked = true;
    begin
        exit(StrSubstNo(ClientEnvironmentInitializeUrlLbl, COBaseUrl()));
    end;

    internal procedure UpdateSubscriptionUrl(): Text
    var
        UpdateSubscriptionUrlLbl: Label '%1/core/UpdateSubscription', Locked = true;
    begin
        exit(StrSubstNo(UpdateSubscriptionUrlLbl, COBaseUrl()));
    end;

    internal procedure GetSubscriptionUrl(): Text
    var
        GetSubscriptionUrlLbl: Label '%1/core/GetSubscriptions', Locked = true;
    begin
        exit(StrSubstNo(GetSubscriptionUrlLbl, COBaseUrl()));
    end;

    internal procedure GetAcceptCompanyLicenseUrl(): Text
    var
        GetAcceptCompanyLicenseUrlLbl: Label '%1/core/AcceptCompanyLicense', Locked = true;
    begin
        exit(StrSubstNo(GetAcceptCompanyLicenseUrlLbl, COBaseUrl()));
    end;

    internal procedure GetUpdateCompanyInfoUrl(): Text
    var
        GetUpdateCompanyInfoUrlLbl: Label '%1/core/UpdateInvoicingInformation', Locked = true;
    begin
        exit(StrSubstNo(GetUpdateCompanyInfoUrlLbl, COBaseUrl()));
    end;

    local procedure COBaseUrl() URL: Text
    var
        Handled: Boolean;
    begin
        OnGetCOBaseUrl(URL, Handled);
        if Handled then
            exit(URL);

        exit('https://auth.continiaonline.com/api/v1');
    end;


    internal procedure CDNBaseURL() URL: Text
    var
        EnvironmentInformation: Codeunit "Environment Information";
        Handled: Boolean;
        LocalizedBaseUrl: Text;
    begin
        OnGetCDNBaseUrl(URL, Handled);
        if Handled then
            exit(URL);

        LocalizedBaseUrl := GetBaseUrlForLocalization(EnvironmentInformation.GetApplicationFamily());
        if LocalizedBaseUrl <> '' then
            exit(LocalizedBaseUrl)
        else
            exit('https://cdnapi.continiaonline.com/api/v1.0');

    end;

    local procedure GetBaseUrlForLocalization(Localization: Text): Text
    begin
        OnBeforeGetBaseUrlForLocalization(Localization);

        case Localization of
            'NZ', 'AU':
                exit('https://aue-cdnapi.continiaonline.com/api/v1.0/');
            'NL':
                exit('https://weu-cdnapi.continiaonline.com/api/v1.0/');
        end;
    end;

    internal procedure GetNetworkNameAsText(NetworkName: Enum "Network"): Text
    begin
        exit(NetworkName.Names.Get(NetworkName.Ordinals.IndexOf(NetworkName.AsInteger())));
    end;

    internal procedure GetGUIDAsText(Value: Guid): Text[36]
    begin
        exit(CopyStr(DelChr(Value, '<>', '{}'), 1, 36))
    end;


    [IntegrationEvent(false, false)]
    local procedure OnGetCOBaseUrl(var ReturnUrl: Text; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetCDNBaseUrl(var ReturnUrl: Text; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetBaseUrlForLocalization(var Localization: Text)
    begin
    end;

}