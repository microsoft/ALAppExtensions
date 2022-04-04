permissionset 27225 "QBMigration - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'QB Migration - Edit';

    IncludedPermissionSets = "QBMigration - Read";

    Permissions = tabledata "MigrationQB Account" = IMD,
                    tabledata "MigrationQB Customer" = IMD,
                    tabledata "MigrationQB CustomerTrans" = IMD,
                    tabledata "MigrationQB Item" = IMD,
                    tabledata "MigrationQB Account Setup" = IMD,
                    tabledata "MigrationQB Config" = IMD,
                    tabledata "MigrationQB Vendor" = IMD,
                    tabledata "MigrationQB VendorTrans" = IMD;
}