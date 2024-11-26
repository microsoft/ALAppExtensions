// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Tietoevry;

using System.Upgrade;
#if not CLEAN26
using Microsoft.eServices.EDocument.Integration;
using Microsoft.eServices.EDocument;
#endif

codeunit 6390 Upgrade
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var

    begin
#if not CLEAN26
        // Upgrade code per company
        this.UpdateServiceIntegration();
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

        // 6390 - Tietoevry Integration
        EDocumentService.SetRange("Service Integration", 6370);
        if EDocumentService.FindSet() then
            repeat
                EDocumentService."Service Integration V2" := Enum::"Service Integration"::Tietoevry;
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
        exit('MS-000000-UpdateServiceIntegrationTietoevry-20241125');
    end;


}