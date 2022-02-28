permissionset 2759 "UniversalPrint - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'Microsoft Universal Print - Read';

    IncludedPermissionSets = "UniversalPrint - Objects";

    Permissions = tabledata "Universal Printer Settings" = R,
                    tabledata "Universal Print Share Buffer" = R;
}
