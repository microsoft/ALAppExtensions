// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1567 "System Upgrade Privacy Notices"
{
    Subtype = Upgrade;

    trigger OnUpgradePerDatabase()
    begin
        UpgradeTeamsPrivacyNotice();
    end;

    local procedure UpgradeTeamsPrivacyNotice()
    var
        PrivacyNotice: Codeunit "Privacy Notice";
        UpgradeTag: Codeunit "Upgrade Tag";
        SystemPrivacyNoticeReg: Codeunit "System Privacy Notice Reg.";
    begin
        if UpgradeTag.HasUpgradeTag(GetTeamsPrivacyNoticeUpgradeTag()) then
            exit;
        
        PrivacyNotice.CreateDefaultPrivacyNotices();

        PrivacyNotice.SetApprovalState(SystemPrivacyNoticeReg.GetTeamsPrivacyNoticeId(), "Privacy Notice Approval State"::Agreed);

        UpgradeTag.SetUpgradeTag(GetTeamsPrivacyNoticeUpgradeTag());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetTeamsPrivacyNoticeUpgradeTag());
    end;

    local procedure GetTeamsPrivacyNoticeUpgradeTag(): Code[250]
    begin
        exit('MS-427298-PrivacyNoticeApproveTeams-20220222');
    end;
}
