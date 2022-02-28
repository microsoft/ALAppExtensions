permissionset 6095 "FATS - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'FATS - Read';

    IncludedPermissionSets = "FATS - Objects";

    Permissions = tabledata "FA Ledg. Entry w. Issue" = R;
}
