// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.API;

using Microsoft.eServices.EDocument;
using System.Environment;
using System.Integration;

codeunit 6185 "E-Document Business Events"
{

    InherentEntitlements = X;
    InherentPermissions = X;

    var
        EDocumentApiUrlTok: Label 'v2.0/companies(%1)/eDocuments(%2)', Locked = true;


    [ExternalBusinessEvent('EDocumentStatusChanged', 'E-Document status changed', 'This business event is triggered when status on E-Document has been updated.', Enum::EventCategory::"E-Document", '1.0')]
    local procedure EDocumentStatusChanged(EDocumentId: Guid; EDocumentStatus: enum "E-Document Status"; Url: Text[250]; WebClientUrl: Text[250])
    begin
    end;

    [ExternalBusinessEvent('EDocumentServiceStatusChanged', 'E-Document service status changed', 'This business event is triggered when status for a specific service on E-Document has been updated.', Enum::EventCategory::"E-Document", '1.0')]
    local procedure EDocumentServiceStatusChanged(EDocumentId: Guid; EDocumentServiceId: Guid; EDocumentServiceStatus: enum "E-Document Service Status"; Url: Text[250]; WebClientUrl: Text[250])
    begin
    end;

    local procedure CreateLink(url: Text; Id: Guid): Text[250]
    var
        Link: Text[250];
    begin
        Link := GetBaseUrl() + StrSubstNo(url, GetCompanyId(), TrimGuid(Id));
        exit(Link);
    end;

    local procedure GetBaseUrl(): Text
    begin
        exit(GetUrl(ClientType::Api));
    end;

    local procedure GetCompanyId(): Text
    var
        Company: Record Company;
    begin
        Company.Get(CompanyName);
        exit(TrimGuid(Company.SystemId));
    end;

    local procedure TrimGuid(Id: Guid): Text
    begin
        exit(DelChr(Format(Id), '<>', '{}'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Document Processing", OnAfterModifyEDocumentStatus, '', false, false)]
    local procedure OnAfterModifyEDocumentStatus(var EDocument: Record "E-Document"; var EDocumentServiceStatus: Record "E-Document Service Status")
    var
        Url: Text[250];
        WebClientUrl: Text[250];
    begin
        Url := CreateLink(EDocumentApiUrlTok, EDocument.SystemId);
        WebClientUrl := CopyStr(GetUrl(ClientType::Web, CompanyName(), ObjectType::Page, Page::"E-Document", EDocument), 1, MaxStrLen(WebClientUrl));

        EDocumentStatusChanged(EDocument.SystemId, EDocument.Status, Url, WebClientUrl);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Document Processing", OnAfterModifyServiceStatus, '', false, false)]
    local procedure OnAfterModifyServiceStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var EDocumentServiceStatus: Record "E-Document Service Status")
    var
        Url: Text[250];
        WebClientUrl: Text[250];
    begin
        Url := CreateLink(EDocumentApiUrlTok, EDocument.SystemId);
        WebClientUrl := CopyStr(GetUrl(ClientType::Web, CompanyName(), ObjectType::Page, Page::"E-Document", EDocument), 1, MaxStrLen(WebClientUrl));

        EDocumentServiceStatusChanged(EDocument.SystemId, EDocumentService.SystemId, EDocumentServiceStatus.Status, Url, WebClientUrl);
    end;


}
