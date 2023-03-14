permissionset 4007 "HBD - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'HybridBaseDeployment - Read';

    IncludedPermissionSets = "HBD - Objects";

    Permissions = tabledata "Hybrid Company Status" = R,
                    tabledata "Hybrid DA Approval" = R;
}
