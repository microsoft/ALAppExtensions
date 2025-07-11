// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

using System.Upgrade;

codeunit 104066 "SMTP Connector - Upgrade"
{
    Subtype = Upgrade;
    Permissions = tabledata "SMTP Account" = rm;

    internal procedure GetSMTPAccountAuthTypeUpgradeTag(): Code[250]
    begin
        exit('MS-387128-GetSMTPAccountAuthTypeUpgradeTag-20220107');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not UpgradeTag.HasUpgradeTag(GetSMTPAccountAuthTypeUpgradeTag()) then
            PerCompanyUpgradeTags.Add(GetSMTPAccountAuthTypeUpgradeTag());
    end;
}