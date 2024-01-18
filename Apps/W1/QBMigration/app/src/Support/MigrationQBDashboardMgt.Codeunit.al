codeunit 1915 "MigrationQB Dashboard Mgt"
{
    var
        HelperFunctions: Codeunit "MigrationQB Helper Functions";

    procedure InitMigrationStatus(TotalItemNb: Integer; TotalCustomerNb: Integer; TotalVendorNb: Integer; TotalChartOfAccountNb: Integer);
    var
        DataMigrationStatusFacade: Codeunit "Data Migration Status Facade";
    begin
        DataMigrationStatusFacade.InitStatusLine(CopyStr(HelperFunctions.GetMigrationTypeTxt(), 1, 10), Database::Item, TotalItemNb, Database::"MigrationQB Item", Codeunit::"MigrationQB Item Migrator");
        DataMigrationStatusFacade.InitStatusLine(CopyStr(HelperFunctions.GetMigrationTypeTxt(), 1, 10), Database::Customer, TotalCustomerNb, Database::"MigrationQB Customer", Codeunit::"MigrationQB Customer Migrator");
        DataMigrationStatusFacade.InitStatusLine(CopyStr(HelperFunctions.GetMigrationTypeTxt(), 1, 10), Database::Vendor, TotalVendorNb, Database::"MigrationQB Vendor", Codeunit::"MigrationQB Vendor Migrator");
        DataMigrationStatusFacade.InitStatusLine(CopyStr(HelperFunctions.GetMigrationTypeTxt(), 1, 10), Database::"G/L Account", TotalChartOfAccountNb, Database::"MigrationQB Account", Codeunit::"MigrationQB Account Migrator");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", 'OnMigrationCompleted', '', false, false)]
    local procedure OnAllStepsCompletedSubscriber(DataMigrationStatus: Record "Data Migration Status")
    begin
        if not (DataMigrationStatus."Migration Type" = HelperFunctions.GetMigrationTypeTxt()) then
            exit;

        HelperFunctions.CleanupStagingTables();
        HelperFunctions.CleanupIsolatedStorage();
    end;
}