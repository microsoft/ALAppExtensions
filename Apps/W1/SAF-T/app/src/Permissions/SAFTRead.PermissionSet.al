permissionset 5281 "SAF-T - Read"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "SAF-T Objects";

    Permissions = tabledata "Source Code SAF-T" = R,
                  tabledata "Missing Field SAF-T" = R;
}