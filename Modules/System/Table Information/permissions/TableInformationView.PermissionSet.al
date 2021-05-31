permissionset 8701 "Table Information - View"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Table Information - Read";

    Permissions = tabledata "Table Information Cache" = imd,
                  tabledata "Company Size Cache" = imd;
}