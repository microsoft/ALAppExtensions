permissionset 4509 "Email ORA - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'Email - Outlook REST API - Read';

    IncludedPermissionSets = "Email ORA - Objects";

    Permissions = tabledata "Email - Outlook Account" = r,
                    tabledata "Email - Outlook API Setup" = R;
}
