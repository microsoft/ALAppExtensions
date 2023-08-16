permissionset 687 "Paym. Prac. Edit"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "Paym. Prac. Read";

    Permissions =
        tabledata "Payment Period" = IMD,
        tabledata "Payment Practice Data" = IMD,
        tabledata "Payment Practice Line" = IMD,
        tabledata "Payment Practice Header" = IMD;

}