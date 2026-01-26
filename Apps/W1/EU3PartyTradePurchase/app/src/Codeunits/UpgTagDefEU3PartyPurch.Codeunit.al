#if not CLEANSCHEMA26
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.EU3PartyTrade;

using System.Upgrade;

codeunit 4889 "Upg. Tag Def. EU3 Party Purch."
{
    ObsoleteReason = 'EU3 Party Purchase is moved to a new app.';
    ObsoleteState = Pending;
    ObsoleteTag = '26.0';
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetEU3PartyPurchaseUpgradeTag());
    end;

    internal procedure GetEU3PartyPurchaseUpgradeTag(): Code[250]
    begin
        exit('559328-EU3PartyPurchase-20250109');
    end;
}
#endif