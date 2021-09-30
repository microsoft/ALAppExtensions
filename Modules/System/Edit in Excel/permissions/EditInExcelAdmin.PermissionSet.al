permissionset 1480 "Edit in Excel-Admin"
{
    Access = Public;
    Assignable = true;
    Caption = 'Edit in Excel - Admin';

    IncludedPermissionSets = "Edit in Excel - View",
                             "Guided Experience - View";

    Permissions = tabledata "Edit in Excel Settings" = RIMD;
}