permissionset 4811 "Intr. Core - Read"
{
    Access = Internal;
    Assignable = true;
    Caption = 'Intrastat Core - Read';

    IncludedPermissionSets = "Intrastat Core - Objects";

    Permissions =
        tabledata "Intrastat Report Setup" = R,
        tabledata "Intrastat Report Header" = R,
        tabledata "Intrastat Report Line" = R,
        tabledata "Intrastat Report Checklist" = R;
}