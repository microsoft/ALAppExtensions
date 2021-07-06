permissionset 132548 "Page Summary Read"
{
    Assignable = true;

    IncludedPermissionSets = "Page Summary Provider - Read";

    // Include Test Tables
    Permissions = tabledata "Page Provider Summary Test" = RIMD,
                  tabledata "Page Provider Summary Test2" = RIMD;
}