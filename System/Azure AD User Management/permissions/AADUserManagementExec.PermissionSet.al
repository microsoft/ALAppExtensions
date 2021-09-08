permissionset 9515 "AAD User Management - Exec"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "AAD User Management - Read";

    Permissions = tabledata User = m;
}