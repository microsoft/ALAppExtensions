permissionset 4005 "HBD - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'HybridBaseDeployment - Edit';

    IncludedPermissionSets = "HBD - Read";

    Permissions = tabledata "Hybrid Company Status" = IMD,
                    tabledata "Hybrid DA Approval" = IMD;
}
