#if not CLEAN27
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using System.Upgrade;

codeunit 10588 "Upg. Tag GovTalk"
{
    ObsoleteReason = 'Feature GovTalk will be enabled by default in version 30.0.';
    ObsoleteState = Pending;
    ObsoleteTag = '27.0';
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetGovTalkUpgradeTag());
    end;

    internal procedure GetGovTalkUpgradeTag(): Code[250]
    begin
        exit('MS-581204-GovTalkUpgradeTag-20250710');
    end;
}
#endif