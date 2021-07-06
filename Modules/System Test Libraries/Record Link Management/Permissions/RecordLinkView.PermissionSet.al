permissionset 132508 "Record Link View"
{
    Assignable = true;
    IncludedPermissionSets = "Record Link Management - View";

    // Include Test Tables
    Permissions = tabledata "Record Link Record Test" = RIMD;
}