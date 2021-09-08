permissionset 9172 "Default Role Center - View"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Default Role Center - Read";

    Permissions = tabledata "All Profile" = m;
}