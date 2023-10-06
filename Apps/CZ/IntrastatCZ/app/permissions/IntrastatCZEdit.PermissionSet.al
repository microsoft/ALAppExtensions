permissionset 31301 "Intrastat CZ - Edit"
{
    Access = Internal;
    Assignable = true;
    Caption = 'Intrastat CZ - Edit';

    IncludedPermissionSets = "Intrastat CZ - Read";

    Permissions =
        tabledata "Intrastat Delivery Group CZ" = IMD,
        tabledata "Specific Movement CZ" = IMD,
        tabledata "Statistic Indication CZ" = IMD;
}