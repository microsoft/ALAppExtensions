codeunit 1935 "MigrationGP Dashboard Mgt"
{
    procedure InitMigrationStatus(TotalItemNb: Integer; TotalCustomerNb: Integer; TotalVendorNb: Integer; TotalChartOfAccountNb: Integer);
    var
        DataMigrationStatusFacade: Codeunit "Data Migration Status Facade";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
    begin
        DataMigrationStatusFacade.InitStatusLine(CopyStr(HelperFunctions.GetMigrationTypeTxt(), 1, 250), Database::Item, TotalItemNb, Database::"MigrationGP Item", Codeunit::"MigrationGP Item Migrator");
        DataMigrationStatusFacade.InitStatusLine(CopyStr(HelperFunctions.GetMigrationTypeTxt(), 1, 250), Database::Customer, TotalCustomerNb, Database::"MigrationGP Customer", Codeunit::"MigrationGP Customer Migrator");
        DataMigrationStatusFacade.InitStatusLine(CopyStr(HelperFunctions.GetMigrationTypeTxt(), 1, 250), Database::Vendor, TotalVendorNb, Database::"MigrationGP Vendor", Codeunit::"MigrationGP Vendor Migrator");
        DataMigrationStatusFacade.InitStatusLine(CopyStr(HelperFunctions.GetMigrationTypeTxt(), 1, 250), Database::"G/L Account", TotalChartOfAccountNb, Database::"MigrationGP Account", Codeunit::"MigrationGP Account Migrator");
    end;
}