// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Logiq;

using System.Upgrade;
#if not CLEAN26
using Microsoft.eServices.EDocument.Integration;
using Microsoft.eServices.EDocument;
#endif

#pragma warning disable AS0130
#pragma warning disable PTE0025
codeunit 6435 "Logiq Upgrade"
#pragma warning restore AS0130
#pragma warning restore PTE0025
{
    Access = Internal;
    Subtype = Upgrade;

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

        // 6431 - Logiq Integration
        EDocumentService.SetRange("Service Integration", 6431);
        if EDocumentService.FindSet() then
            repeat
                EDocumentService."Service Integration V2" := Enum::"Service Integration"::Logiq;
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
        exit('MS-499158-UpdateServiceIntegrationLogiq-20250129');
    end;


}