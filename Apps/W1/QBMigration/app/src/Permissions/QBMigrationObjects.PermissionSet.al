permissionset 27226 "QBMigration - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'QB Migration - Objects';

    Permissions = table "MigrationQB Account" = X,
                     codeunit "MigrationQB Account Migrator" = X,
                     page "MigrationQB AccountTable" = X,
                     table "MigrationQB Customer" = X,
                     codeunit "MigrationQB Customer Migrator" = X,
                     page "MigrationQB CustomerTable" = X,
                     page "MigrationQB CustomerTrans" = X,
                     table "MigrationQB CustomerTrans" = X,
                     codeunit "QB Migration Install" = X,
                     table "MigrationQB Item" = X,
                     codeunit "MigrationQB Item Migrator" = X,
                     page "MigrationQB ItemTable" = X,
                     table "MigrationQB Account Setup" = X,
                     table "MigrationQB Config" = X,
                     codeunit "MigrationQB Dashboard Mgt" = X,
                     codeunit "MigrationQB Data Loader" = X,
                     codeunit "MigrationQB Data Reader" = X,
                     page "MigrationQB Default Accounts" = X,
                     Codeunit "MigrationQB Helper Functions" = X,
                     codeunit "MigrationQB Mgt" = X,
                     codeunit "MigrateQBO Wizard Integration" = X,
                     page "MS - QBO Data Migration" = X,
                     page "MigrationQB Posting Accounts" = X,
                     codeunit "MigrationQB Wizard Integration" = X,
                     codeunit "MigrationQB Upgrade" = X,
                     table "MigrationQB Vendor" = X,
                     codeunit "MigrationQB Vendor Migrator" = X,
                     page "MigrationQB VendorTable" = X,
                     page "MigrationQB VendorTrans" = X,
                     table "MigrationQB VendorTrans" = X;
}
