permissionset 80102 "Blob Stor. - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'Blob Storage - Edit';

    IncludedPermissionSets = "Blob Stor. - Read";

    Permissions =
        tabledata "Blob Storage Account" = imd;
}
