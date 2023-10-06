permissionset 31300 "Intrastat CZ - Read"
{
    Access = Internal;
    Assignable = true;
    Caption = 'Intrastat CZ - Read';

    IncludedPermissionSets = "Intrastat Core - Objects";

    Permissions =
        tabledata "Intrastat Delivery Group CZ" = R,
        tabledata "Specific Movement CZ" = R,
        tabledata "Statistic Indication CZ" = R;
}