permissionset 5523 "Email SMTP - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'Email - SMTP Connector - Read';

    IncludedPermissionSets = "Email SMTP - Objects";

    Permissions = tabledata "SMTP Account" = r;
}
