permissionset 2718 "Page Summary - Admin"
{
    Access = Public;
    Assignable = true;
    Caption = 'Page Summary Provider - Admin';

    IncludedPermissionSets = "Page Summary Provider - Read";

    Permissions = tabledata "Page Summary Settings" = IMD;
}