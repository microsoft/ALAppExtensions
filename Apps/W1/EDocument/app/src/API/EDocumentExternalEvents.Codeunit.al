// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.API;

using Microsoft.eServices.EDocument;
using System.Integration;

codeunit 6121 "E-Document External Events"
{
    var
        EDocumentsAPIHelper: Codeunit "E-Documents API Helper";
        EventCategory: Enum EventCategory;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Document Processing", 'OnAfterModifyEDocumentStatus', '', false, false)]
    local procedure OnAfterModifyEDocumentStatus(var EDocument: Record "E-Document"; var EDocumentServiceStatus: Record "E-Document Service Status")
    var
        Url: Text[250];
        WebClientUrl: Text[250];
        EDocumentApiUrlTok: Label 'v2.0/companies(%1)/eDocuments(%2)', Locked = true;
    begin
        Url := EDocumentsAPIHelper.CreateLink(CopyStr(EDocumentApiUrlTok, 1, 250), EDocument.SystemId);
        WebClientUrl := CopyStr(GetUrl(ClientType::Web, CompanyName(), ObjectType::Page, Page::"E-Document", EDocument), 1, MaxStrLen(WebClientUrl));

        this.EDocumentStatusChanged(EDocument.SystemId, EDocument.Status, Url, WebClientUrl);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Document Processing", 'OnAfterInsertServiceStatus', '', false, false)]
    local procedure OnAfterInsertServiceStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var EDocumentServiceStatus: Record "E-Document Service Status")
    var
        Url: Text[250];
        WebClientUrl: Text[250];
        EDocumentApiUrlTok: Label 'v2.0/companies(%1)/eDocuments(%2)', Locked = true;
    begin
        Url := EDocumentsAPIHelper.CreateLink(CopyStr(EDocumentApiUrlTok, 1, 250), EDocument.SystemId);
        WebClientUrl := CopyStr(GetUrl(ClientType::Web, CompanyName(), ObjectType::Page, Page::"E-Document", EDocument), 1, MaxStrLen(WebClientUrl));

        this.EDocumentServiceStatusChanged(EDocument.SystemId, EDocumentService.SystemId, EDocumentServiceStatus.Status, Url, WebClientUrl);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Document Processing", 'OnAfterModifyServiceStatus', '', false, false)]
    local procedure OnAfterModifyServiceStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var EDocumentServiceStatus: Record "E-Document Service Status")
    var
        Url: Text[250];
        WebClientUrl: Text[250];
        EDocumentApiUrlTok: Label 'v2.0/companies(%1)/eDocuments(%2)', Locked = true;
    begin
        Url := EDocumentsAPIHelper.CreateLink(CopyStr(EDocumentApiUrlTok, 1, 250), EDocument.SystemId);
        WebClientUrl := CopyStr(GetUrl(ClientType::Web, CompanyName(), ObjectType::Page, Page::"E-Document", EDocument), 1, MaxStrLen(WebClientUrl));

        this.EDocumentServiceStatusChanged(EDocument.SystemId, EDocumentService.SystemId, EDocumentServiceStatus.Status, Url, WebClientUrl);
    end;

    [ExternalBusinessEvent('EDocumentStatusChanged', 'E-Document status changed', 'This business event is triggered when status on E-Document has been updated.', EventCategory::"E-Document", '1.0')]
    local procedure EDocumentStatusChanged(EDocumentId: Guid; EDocumentStatus: enum "E-Document Status"; Url: Text[250]; WebClientUrl: Text[250])
    begin
    end;

    [ExternalBusinessEvent('EDocumentErviceStatusChanged', 'E-Document service status changed', 'This business event is triggered when status for a specific service on E-Document has been updated.', EventCategory::"E-Document", '1.0')]
    local procedure EDocumentServiceStatusChanged(EDocumentId: Guid; EDocumentServiceId: Guid; EDocumentServiceStatus: enum "E-Document Service Status"; Url: Text[250]; WebClientUrl: Text[250])
    begin
    end;
}
