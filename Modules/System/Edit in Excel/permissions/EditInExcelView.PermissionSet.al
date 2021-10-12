permissionset 1482 "Edit in Excel - View"
{
    Access = Public;
    Assignable = true;
    Caption = 'Edit in Excel - View';

    IncludedPermissionSets = "Edit in Excel - Read",
                             "Web Service Management - View";

    Permissions = system "Allow Action Export To Excel" = X;
}
