permissionset 5521 "Email SMTP - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'Email - SMTP Connector - Edit';

    IncludedPermissionSets = "Email SMTP - Read";

    Permissions = tabledata "SMTP Account" = imd;
}
