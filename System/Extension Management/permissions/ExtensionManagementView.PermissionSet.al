permissionset 2501 "Extension Management - View"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "Extension Management - Read";

    Permissions = tabledata "NAV App Setting" = m;
}