codeunit 9032 "Upgrade Custom User Groups"
{
    // Obsolete = Removed tables can only be referenced from Upgrade codeunits.
    // Even though this codeunit will not have the OnUpgradePerDatabase trigger,
    // in v25+ the event subscriber will always run in the upgrade context.
    Subtype = Upgrade;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade User Groups", 'OnMigrateUserGroups', '', false, false)]
    local procedure TransferCustomPermissionsPerPlan()
    var
        CustomUserGroupInPlan: Record "Custom User Group In Plan";
        UserGroupPermissionSet: Record "User Group Permission Set";
        PlanConfiguration: Codeunit "Plan Configuration";
    begin
        if CustomUserGroupInPlan.FindSet() then
            repeat
                UserGroupPermissionSet.SetRange("User Group Code", CustomUserGroupInPlan."User Group Code");
                if UserGroupPermissionSet.FindSet() then
                    repeat
                        PlanConfiguration.AddCustomPermissionSetToPlan(CustomUserGroupInPlan."Plan ID",
                            UserGroupPermissionSet."Role ID",
                            UserGroupPermissionSet."App ID",
                            UserGroupPermissionSet.Scope,
                            CustomUserGroupInPlan."Company Name");
                    until UserGroupPermissionSet.Next() = 0;
            until CustomUserGroupInPlan.Next() = 0;
    end;
}