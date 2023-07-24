// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9872 "Security Group Upgrade"
{
    Subtype = Upgrade;
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnUpgradePerDatabase()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetOnPremSecurityGroupUpgradeTag()) then
            exit;

        CreateSecurityGroups();

        UpgradeTag.SetUpgradeTag(GetOnPremSecurityGroupUpgradeTag());
    end;

    procedure CreateSecurityGroups()
    var
        User: Record User;
        SecurityGroupRec: Record "Security Group";
    begin
        User.SetRange("License Type", User."License Type"::"Windows Group");
        if not User.FindSet() then
            exit;

        repeat
            SecurityGroupRec.SetRange("Group User SID", User."User Security ID");
            if SecurityGroupRec.IsEmpty() then begin
                SecurityGroupRec."Group User SID" := User."User Security ID";
                SecurityGroupRec.Code := GenerateGroupCode(User."Windows Security ID");
                SecurityGroupRec.Insert();
            end
        until User.Next() = 0;
    end;

    local procedure GenerateGroupCode(GroupId: Text): Code[20]
    var
        SecurityGroupRec: Record "Security Group";
        SecurityGroupImpl: Codeunit "Security Group Impl.";
        GroupCode: Code[20];
        DesiredGroupCode: Code[20];
        Index: Integer;
        Suffix: Text;
        GroupDomainAndNameValue: Text[250];
    begin
        if SecurityGroupImpl.TryGetNameById(GroupId, GroupDomainAndNameValue) then
            DesiredGroupCode := SecurityGroupImpl.GetDesirableCode(GroupDomainAndNameValue)
        else
            DesiredGroupCode := 'SECURITY GROUP';

        GroupCode := DesiredGroupCode;

        SecurityGroupRec.SetRange(Code, GroupCode);
        if not SecurityGroupRec.IsEmpty() then
            repeat
                Index += 1;
                Suffix := '_' + Format(Index);
                GroupCode := CopyStr(DesiredGroupCode, 1, MaxStrLen(DesiredGroupCode) - StrLen(Suffix)) + Suffix;
                SecurityGroupRec.SetRange(Code, GroupCode);
            until SecurityGroupRec.IsEmpty();

        exit(GroupCode);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetOnPremSecurityGroupUpgradeTag());
    end;

    internal procedure GetOnPremSecurityGroupUpgradeTag(): Code[250]
    begin
        exit('MS-458366-OnPremSecurityGroups-20230205');
    end;
}