permissionset 70000 "File System - Admin"
{
    Access = Public;
    Assignable = true;
    Caption = 'File System - Admin';

    IncludedPermissionSets = "File System - Edit";

    Permissions =
        tabledata "File Account" = RMID,
        tabledata "File System Connector" = RMID,
        tabledata "File System Connector Logo" = RMID,
        tabledata "File Account Scenario" = RMID,
        tabledata "File Scenario" = RMID,
        tabledata "File Account Content" = RMID;
}
