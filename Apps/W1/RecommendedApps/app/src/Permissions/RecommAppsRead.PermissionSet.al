permissionset 4753 "RecommApps - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'RecommendedApps - Read';

    IncludedPermissionSets = "RecommApps - Objects";

    Permissions = tabledata "Recommended Apps" = R;
}
