permissionset 4507 "Email ORA - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'Email - Outlook REST API - Edit';

    IncludedPermissionSets = "Email ORA - Read";

    Permissions = tabledata "Email - Outlook Account" = imd,
                  tabledata "Email - Outlook API Setup" = IMD;
}
