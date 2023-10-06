permissionset 80101 "Blob Stor. - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'Blob Storage - Read';

    IncludedPermissionSets = "Blob Stor. - Objects";

    Permissions =
        tabledata "Blob Storage Account" = r;
}
