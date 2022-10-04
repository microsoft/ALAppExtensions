permissionsetextension 16491 "D365 TEAM MEMBERQuickBooks Data Migration" extends "D365 TEAM MEMBER"
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
