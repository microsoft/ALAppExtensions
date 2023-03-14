permissionset 6091 "FATS - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'FATS - Edit';

    IncludedPermissionSets = "FATS - Read";

    Permissions = tabledata "FA Ledg. Entry w. Issue" = IMD;
}
