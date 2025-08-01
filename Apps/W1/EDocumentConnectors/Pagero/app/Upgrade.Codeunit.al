// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;
using System.Upgrade;

using Microsoft.eServices.EDocument;
#if not CLEAN26
using Microsoft.eServices.EDocument.Integration;
#endif

#pragma warning disable AS0130
#pragma warning disable PTE0025
codeunit 6370 Upgrade
#pragma warning restore AS0130
#pragma warning restore PTE0025
{
    Access = Internal;
    Subtype = Upgrade;
    Permissions = tabledata "E-Document Service" = rm;

    trigger OnUpgradePerCompany()
    var

    begin
#if not CLEAN26
        // Upgrade code per company
        UpdateServiceIntegration();
#endif

    end;

#if not CLEAN26
    local procedure UpdateServiceIntegration()
    var
        EDocumentService: Record "E-Document Service";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeServiceIntegrationTag()) then
            exit;

        // 6361 - Pagero (removed)
        EDocumentService.SetRange("Service Integration", 6361);
        if EDocumentService.FindSet() then
            repeat
                EDocumentService."Service Integration V2" := Enum::"Service Integration"::Pagero;
                EDocumentService."Service Integration" := Enum::"E-Document Integration"::"No Integration";
                EDocumentService.Modify();
            until EDocumentService.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeServiceIntegrationTag());
    end;
#endif


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(UpgradeServiceIntegrationTag());
    end;

    local procedure UpgradeServiceIntegrationTag(): Code[250]
    begin
        exit('MS-547765-UpdateServiceIntegrationPagero-20241118');
    end;


}