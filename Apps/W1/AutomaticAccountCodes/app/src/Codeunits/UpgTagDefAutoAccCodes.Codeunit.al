#if not CLEAN25
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AutomaticAccounts;

using System.Upgrade;

codeunit 4855 "Upg. Tag Def. Auto. Acc. Codes"
{
    ObsoleteReason = 'Automatic Acc.functionality is moved to a new app.';
    ObsoleteState = Pending;
#pragma warning disable AS0072
    ObsoleteTag = '25.0';
#pragma warning restore AS0072
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetAutoAccCodesUpgradeTag());
    end;

    internal procedure GetAutoAccCodesUpgradeTag(): Code[250]
    begin
        exit('547087-AutoAccCodesUpgrade-20240830');
    end;
}
#endif