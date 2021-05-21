permissionset 9987 "Word Templates - Edit"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Word Templates - Read";

    Permissions = tabledata "Word Template" = IMD,
                  tabledata "Word Templates Table" = imd;
}