permissionset 1481 "Edit in Excel - Read"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Edit in Excel - Objects";

    Permissions = TableData "Edit in Excel Settings" = R,
                  TableData "Media Resources" = r;
}
