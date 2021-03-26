permissionsetextension 1632 "D365 BASIC ISVQuickBooks Data Migration" extends "D365 BASIC ISV"
{
    Permissions = tabledata "MigrationQB Account" = RIMD,
                  tabledata "MigrationQB Account Setup" = RIMD,
                  tabledata "MigrationQB Config" = RIMD,
                  tabledata "MigrationQB Customer" = RIMD,
                  tabledata "MigrationQB CustomerTrans" = RIMD,
                  tabledata "MigrationQB Item" = RIMD,
                  tabledata "MigrationQB Vendor" = RIMD,
                  tabledata "MigrationQB VendorTrans" = RIMD;
}
