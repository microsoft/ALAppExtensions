permissionset 5314 "SIE - Read"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "SIE - Objects";

    Permissions = tabledata "Import Buffer SIE" = R,
                  tabledata "Dimension SIE" = R;
}