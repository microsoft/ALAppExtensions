permissionset 4715 "HybridGPUS - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'HybridGPUS - Read';

    IncludedPermissionSets = "HybridGPUS - Objects";
    Permissions = tabledata "Supported Tax Year" = R,
                  tabledata "GP 1099 Box Mapping" = R,
                  tabledata "GP 1099 Migration Log" = R;
}
