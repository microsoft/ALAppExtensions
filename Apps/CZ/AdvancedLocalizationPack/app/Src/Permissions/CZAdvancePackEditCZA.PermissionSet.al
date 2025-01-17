permissionset 11741 "CZ Advance Pack - Edit CZA"
{
    Access = Internal;
    Assignable = false;
    Caption = 'CZ Advance Pack - Edit';

    IncludedPermissionSets = "CZ Advance Pack - Read CZA";

    Permissions = tabledata "Detailed G/L Entry CZA" = IMD;
}
