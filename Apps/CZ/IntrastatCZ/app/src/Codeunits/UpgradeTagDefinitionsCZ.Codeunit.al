// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using System.Upgrade;

codeunit 31304 "Upgrade Tag Definitions CZ"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetIntrastatExcludeUpgradeTag());
        PerCompanyUpgradeTags.Add(GetIntrastatDeliveryGroupUpgradeTag());
        PerCompanyUpgradeTags.Add(GetIntrastatDescriptionUpgradeTag());
    end;

    procedure GetIntrastatExcludeUpgradeTag(): Code[250]
    begin
        exit('CZ-483543-IntrastatExclude-20230907');
    end;

    procedure GetIntrastatDeliveryGroupUpgradeTag(): Code[250]
    begin
        exit('CZ-485242-IntrastatDeliveryGroup-20230919');
    end;

    procedure GetIntrastatDescriptionUpgradeTag(): Code[250]
    begin
        exit('CZ-494894-IntrastatDescription-20231218');
    end;
}
