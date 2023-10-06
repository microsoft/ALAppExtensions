permissionset 70003 "File System - Edit"
{
    Access = Public;
    Assignable = false;
    Caption = 'File System - Edit';

    IncludedPermissionSets = "File System - Read";

    Permissions = tabledata "File System Connector Logo" = imd,
                  tabledata "Tenant Media" = imd;
}