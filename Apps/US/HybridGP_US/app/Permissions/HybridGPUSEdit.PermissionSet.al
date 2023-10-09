namespace System.Security.AccessControl;

using Microsoft.DataMigration.GP;

permissionset 4714 "HybridGPUS - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'HybridGPUS" - Edit';

    IncludedPermissionSets = "HybridGPUS - Read";

    Permissions = tabledata "Supported Tax Year" = IMD,
                  tabledata "GP 1099 Box Mapping" = IMD,
                  tabledata "GP 1099 Migration Log" = IMD;
}
