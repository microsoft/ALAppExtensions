permissionsetextension 20875 "D365 READQuickBooks Data Migration" extends "D365 READ"
{
    Permissions = tabledata "MigrationQB Account" = R,
                  tabledata "MigrationQB Account Setup" = R,
                  tabledata "MigrationQB Config" = R,
                  tabledata "MigrationQB Customer" = R,
                  tabledata "MigrationQB CustomerTrans" = R,
                  tabledata "MigrationQB Item" = R,
                  tabledata "MigrationQB Vendor" = R,
                  tabledata "MigrationQB VendorTrans" = R;
}
