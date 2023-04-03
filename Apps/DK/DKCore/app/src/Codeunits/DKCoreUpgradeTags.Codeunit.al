codeunit 13600 "DKCore Upgrade Tags"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerDatabaseUpgradeTags', '', false, false)]
    local procedure RegisterPerDatabaseTags(var PerDatabaseUpgradeTags: List of [Code[250]])
    begin
        PerDatabaseUpgradeTags.Add(GetRemoveLocalPermissionSetUpgradeTag());
    end;

    internal procedure GetRemoveLocalPermissionSetUpgradeTag(): Code[250]
    begin
        exit('MS-398253-RemoveLocalPermissionSet-20210503')
    end;
}