permissionset 5315 "SIE - Edit"
{
    Access = Public;
    Assignable = true;

    IncludedPermissionSets = "SIE - Read";

    Permissions = tabledata "Import Buffer SIE" = IMD,
                  tabledata "Dimension SIE" = IMD;
}