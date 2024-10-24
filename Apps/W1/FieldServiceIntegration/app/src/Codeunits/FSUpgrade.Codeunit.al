// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using System.Upgrade;
using System.Environment.Configuration;

codeunit 6617 "FS Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradeAssistedSetup();
    end;

    local procedure UpgradeAssistedSetup()
    var
        GuidedExperience: Codeunit "Guided Experience";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetAssistedSetupUpgradeTag()) then
            exit;

#if not CLEAN25
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"FS Connection Setup Wizard");
#else
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, 6421); // 6421 is the ID of the FS Connection Setup Wizard page in Base Application
#endif

        UpgradeTag.SetUpgradeTag(GetAssistedSetupUpgradeTag());
    end;

    local procedure GetAssistedSetupUpgradeTag(): Code[250]
    begin
        exit('MS-548926-AssistedSetupUpgradeTag-20240510');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetAssistedSetupUpgradeTag());
    end;
}