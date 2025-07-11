// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

using System.Environment;

codeunit 6392 "Continia Api Url"
{
    Access = Internal;

    internal procedure NetworkProfilesUrl(Network: Enum "Continia E-Delivery Network"; Page: Integer; PageSize: Integer): Text
    var
        ProfilesUrlLbl: Label '%1/networks/%2/profiles.xml?page=%3&page_size=%4', Locked = true;
    begin
        exit(StrSubstNo(ProfilesUrlLbl, CdnBaseUrl(), GetNetworkNameAsText(Network), Page, PageSize));
    end;

    internal procedure NetworkIdentifiersUrl(Network: Enum "Continia E-Delivery Network"; Page: Integer; PageSize: Integer): Text
    var
        IdentifiersUrlLbl: Label '%1/networks/%2/id_types.xml?page=%3&page_size=%4', Locked = true;
    begin
        exit(StrSubstNo(IdentifiersUrlLbl, CdnBaseUrl(), GetNetworkNameAsText(Network), Page, PageSize));
    end;

    internal procedure ParticipationUrl(Network: Enum "Continia E-Delivery Network"): Text
    var
        ParticipationUrlLbl: Label '%1/networks/%2/participations.xml', Locked = true;
    begin
        exit(StrSubstNo(ParticipationUrlLbl, CdnBaseUrl(), GetNetworkNameAsText(Network)))
    end;

    internal procedure SingleParticipationUrl(Network: Enum "Continia E-Delivery Network"; ParticipationGuid: Guid): Text
    var
        SingleParticipationUrlLbl: Label '%1/networks/%2/participations/%3.xml', Locked = true;
    begin
        exit(StrSubstNo(SingleParticipationUrlLbl, CdnBaseUrl(), GetNetworkNameAsText(Network), GetGuidAsText(ParticipationGuid)))
    end;

    internal procedure ParticipationProfilesUrl(Network: Enum "Continia E-Delivery Network"; ParticipationGuid: Guid): Text
    var
        ParticipationProfilesUrlLbl: Label '%1/networks/%2/participations/%3/profiles.xml', Locked = true;
    begin
        exit(StrSubstNo(ParticipationProfilesUrlLbl, CdnBaseUrl(), GetNetworkNameAsText(Network), GetGuidAsText(ParticipationGuid)))
    end;

    internal procedure ParticipationProfilesUrl(Network: Enum "Continia E-Delivery Network"; ParticipationGuid: Guid; Page: Integer; PageSize: Integer): Text
    var
        ParticipationProfilesUrlPagesLbl: Label '%1/networks/%2/participations/%3/profiles.xml?page=%4&page_size=%5', Locked = true;
    begin
        exit(StrSubstNo(ParticipationProfilesUrlPagesLbl, CdnBaseUrl(), GetNetworkNameAsText(Network), GetGuidAsText(ParticipationGuid), Page, PageSize))
    end;

    internal procedure SingleParticipationProfileUrl(Network: Enum "Continia E-Delivery Network"; ParticipationGuid: Guid; ProfileGuid: Guid): Text
    var
        SingleParticipationProfileUrlLbl: Label '%1/networks/%2/participations/%3/profiles/%4.xml', Locked = true;
    begin
        exit(StrSubstNo(SingleParticipationProfileUrlLbl, CdnBaseUrl(), GetNetworkNameAsText(Network), GetGuidAsText(ParticipationGuid), GetGuidAsText(ProfileGuid)))
    end;

    internal procedure ParticipationLookupUrl(Network: Enum "Continia E-Delivery Network"; IdType: Text[4]; IdValue: Text[50]): Text
    var
        ParticipationLookupUrlLbl: Label '%1/networks/%2/participation_lookups.xml?id_type=%3&id_value=%4', Locked = true;
    begin
        exit(StrSubstNo(ParticipationLookupUrlLbl, CdnBaseUrl(), GetNetworkNameAsText(Network), IdType, IdValue))
    end;

    internal procedure DocumentsFoParticipationProfile(Network: Enum "Continia E-Delivery Network"; ParticipationGuid: Guid; ProfileGuid: Guid; Page: Integer; PageSize: Integer; Incoming: Boolean): Text
    var
        DirectionQueryTxt: Text;
        DocumentsForParticipationProfileUrlLbl: Label '%1/networks/%2/participations/%3/profiles/%4/documents.xml?page=%5&page_size=%6&direction=%7', Locked = true;
    begin
        if Incoming then
            DirectionQueryTxt := 'IncomingEnum'
        else
            DirectionQueryTxt := 'OutgoingEnum';
        exit(StrSubstNo(
                DocumentsForParticipationProfileUrlLbl,
                CdnBaseUrl(),
                Network,
                GetGuidAsText(ParticipationGuid),
                GetGuidAsText(ProfileGuid),
                Page,
                PageSize,
                DirectionQueryTxt));
    end;

    internal procedure DocumentActionUrl(DocumentGuid: Guid): Text
    var
        DocumentActionUrlLbl: Label '%1/documents/%2/action.xml', Locked = true;
    begin
        exit(StrSubstNo(DocumentActionUrlLbl, CdnBaseUrl(), GetGuidAsText(DocumentGuid)))
    end;

    internal procedure PostDocumentsUrl(CompanyGuid: Guid): Text
    var
        PostDocumentsUrlLbl: Label '%1/documents.xml?business_central_company_code=%2', Locked = true;
    begin
        exit(StrSubstNo(PostDocumentsUrlLbl, CdnBaseUrl(), GetGuidAsText(CompanyGuid)))
    end;

    internal procedure TechnicalResponseUrl(DocumentGuid: Guid): Text
    var
        TechnicalResponseUrlLbl: Label '%1/documents/%2/technical_response.xml', Locked = true;
    begin
        exit(StrSubstNo(TechnicalResponseUrlLbl, CdnBaseUrl(), GetGuidAsText(DocumentGuid)))
    end;

    internal procedure BusinessResponseUrl(DocumentGuid: Guid): Text
    var
        BusinessResponseUrlLbl: Label '%1/documents/%2/business_responses.xml', Locked = true;
    begin
        exit(StrSubstNo(BusinessResponseUrlLbl, CdnBaseUrl(), GetGuidAsText(DocumentGuid)))
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

    local procedure COBaseUrl() Url: Text
    var
        Handled: Boolean;
    begin
        OnGetCOBaseUrl(Url, Handled);
        if Handled then
            exit(Url);

        exit('https://auth.continiaonline.com/api/v1');
    end;


    internal procedure CdnBaseUrl() Url: Text
    var
        EnvironmentInformation: Codeunit "Environment Information";
        Handled: Boolean;
        LocalizedBaseUrl: Text;
    begin
        OnGetCdnBaseUrl(Url, Handled);
        if Handled then
            exit(Url);

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

    internal procedure GetNetworkNameAsText(NetworkName: Enum "Continia E-Delivery Network"): Text
    begin
        exit(NetworkName.Names.Get(NetworkName.Ordinals.IndexOf(NetworkName.AsInteger())).ToLower());
    end;

    internal procedure GetGuidAsText(Value: Guid): Text[36]
    begin
        exit(CopyStr(DelChr(Value, '<>', '{}'), 1, 36))
    end;


    [IntegrationEvent(false, false)]
    local procedure OnGetCOBaseUrl(var ReturnUrl: Text; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetCdnBaseUrl(var ReturnUrl: Text; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetBaseUrlForLocalization(var Localization: Text)
    begin
    end;

}