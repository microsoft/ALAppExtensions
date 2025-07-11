#if not CLEAN27
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using System.Upgrade;

codeunit 10583 "Upg. Tag Reports GB"
{
    ObsoleteReason = 'Feature Reports GB will be enabled by default in version 30.0.';
    ObsoleteState = Pending;
    ObsoleteTag = '27.0';
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetReportsGBUpgradeTag());
    end;

    internal procedure GetReportsGBUpgradeTag(): Code[250]
    begin
        exit('MS-573191-ReportsGBUpgradeTag-20250602');
    end;
}
#endif