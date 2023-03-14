permissionset 27077 "DataSharing - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'DataSharing - Read';

    IncludedPermissionSets = "DataSharing- Objects";

    Permissions = tabledata "MS - Data Sharing Setup" = R;
}