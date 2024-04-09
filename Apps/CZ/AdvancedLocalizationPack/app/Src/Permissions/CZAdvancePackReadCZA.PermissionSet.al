permissionset 11740 "CZ Advance Pack - Read CZA"
{
    Access = Internal;
    Assignable = false;
    Caption = 'CZ Advance Pack - Read';

    IncludedPermissionSets = "CZ Advance Pack - Objects CZA";

    Permissions = tabledata "Detailed G/L Entry CZA" = R;
}
