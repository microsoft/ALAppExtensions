codeunit 13602 "Upgrade Local Permission Set"
{
    Subtype = Upgrade;

    trigger OnUpgradePerDatabase()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
        ServerSettings: Codeunit "Server Setting";
    begin
        if not ServerSettings.GetUsePermissionSetsFromExtensions() then
            exit;

        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetRemoveLocalPermissionSetUpgradeTag()) then
            exit;

        RemoveLocalPermissionSet();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetRemoveLocalPermissionSetUpgradeTag());
    end;


    local procedure RemoveLocalPermissionSet()
    var
        UserGroupPermissionSet: Record "User Group Permission Set";
        AccessControl: Record "Access Control";
        NullGuid: Guid;
    begin
        UserGroupPermissionSet.SetRange(Scope, UserGroupPermissionSet.Scope::System);
        UserGroupPermissionSet.SetRange("Role ID", 'LOCAL');
        UserGroupPermissionSet.SetRange("App ID", NullGuid);

        UserGroupPermissionSet.DeleteAll();

        AccessControl.SetRange(Scope, AccessControl.Scope::System);
        AccessControl.SetRange("Role ID", 'LOCAL');
        AccessControl.SetRange("App ID", NullGuid);

        AccessControl.DeleteAll();
    end;

}