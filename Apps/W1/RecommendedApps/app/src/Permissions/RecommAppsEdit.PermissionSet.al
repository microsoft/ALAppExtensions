permissionset 4751 "RecommApps - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'RecommendedApps - Edit';

    IncludedPermissionSets = "RecommApps - Read";

    Permissions = tabledata "Recommended Apps" = IMD;
}
