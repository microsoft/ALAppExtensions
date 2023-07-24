permissionset 5280 "SAF-T - Edit"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "SAF-T - Read";

    Permissions = tabledata "Source Code SAF-T" = IMD,
                  tabledata "Missing Field SAF-T" = IMD;
}