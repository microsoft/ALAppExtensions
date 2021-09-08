permissionset 31 "SUPER"
{
    Access = Public;
    Assignable = true;
    Caption = 'This role has all permissions.';

    IncludedPermissionSets = "Application Objects - Exec",
                             "Super (Data)",
                             "System Objects - Exec";
}
