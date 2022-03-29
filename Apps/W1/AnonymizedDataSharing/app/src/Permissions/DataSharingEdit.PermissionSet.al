permissionset 27076 "DataSharing - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'DataSharing - Edit';

    IncludedPermissionSets = "DataSharing - Read";

    Permissions = tabledata "MS - Data Sharing Setup" = imd;
}