permissionsetextension 26134 "D365 FULL ACCESSQuickBooks Data Migration" extends "D365 FULL ACCESS"
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
