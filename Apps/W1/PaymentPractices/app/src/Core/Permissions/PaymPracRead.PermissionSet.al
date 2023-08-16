permissionset 686 "Paym. Prac. Read"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "Paym. Prac. Objects";

    Permissions =
        tabledata "Payment Period" = R,
        tabledata "Payment Practice Data" = R,
        tabledata "Payment Practice Line" = R,
        tabledata "Payment Practice Header" = R;

}