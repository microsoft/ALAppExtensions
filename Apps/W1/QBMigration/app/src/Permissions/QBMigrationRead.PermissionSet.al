permissionset 27227 "QBMigration - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'QB Migration - Read';

    IncludedPermissionSets = "QBMigration - Objects";

    Permissions = tabledata "MigrationQB Account" = R,
                    tabledata "MigrationQB Customer" = R,
                    tabledata "MigrationQB CustomerTrans" = R,
                    tabledata "MigrationQB Item" = R,
                    tabledata "MigrationQB Account Setup" = R,
                    tabledata "MigrationQB Config" = R,
                    tabledata "MigrationQB Vendor" = R,
                    tabledata "MigrationQB VendorTrans" = R;
}
