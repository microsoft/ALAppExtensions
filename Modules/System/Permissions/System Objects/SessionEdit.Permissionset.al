permissionset 96 "Session - Edit"
{
    Access = Public;
    Assignable = False;

    IncludedPermissionSets = "Session - Read";

    Permissions = tabledata "Active Session" = IMD,
                  tabledata Session = imd,
                  tabledata "Session Event" = IMD;
}