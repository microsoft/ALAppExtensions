codeunit 139682 "GP Test Helper Functions"
{
    var
        AccountsToMigrateCount: Integer;
        CustomersToMigrateCount: Integer;
        VendorsToMigrateCount: Integer;
        ItemsToMigrateCount: Integer;

    procedure InitializeMigration()
    var
        DataMigrationEntity: Record "Data Migration Entity";
        DataMigrationStatus: Record "Data Migration Status";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        AccountsToMigrateCount := HelperFunctions.GetNumberOfAccounts();
        CustomersToMigrateCount := HelperFunctions.GetNumberOfCustomers();
        VendorsToMigrateCount := HelperFunctions.GetNumberOfVendors();
        ItemsToMigrateCount := HelperFunctions.GetNumberOfItems();

        DataMigrationEntity.DeleteAll();
        DataMigrationStatus.DeleteAll();

        CreateDataMigrationEntites(DataMigrationEntity);
        HelperFunctions.CreateSetupRecordsIfNeeded();
        CreateConfiguredDataMigrationStatusRecords();
    end;

    procedure MigrationConfiguredForTable(TableNo: Integer): Boolean
    var
        DataMigrationEntity: Record "Data Migration Entity";
    begin
        DataMigrationEntity.SetRange("Table ID", TableNo);
        exit(not DataMigrationEntity.IsEmpty());
    end;

    procedure CreateConfigurationSettings()
    var
        GPCompanyMigrationSettings: Record "GP Company Migration Settings";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        CompanyNameText: Text[30];
    begin
#pragma warning disable AA0139
        CompanyNameText := CompanyName();
#pragma warning restore AA0139

        if not GPCompanyMigrationSettings.Get(CompanyNameText) then begin
            GPCompanyMigrationSettings.Name := CompanyNameText;
            GPCompanyMigrationSettings.Insert(true);
        end;

        if not GPCompanyAdditionalSettings.Get(CompanyNameText) then begin
            GPCompanyAdditionalSettings.Name := CompanyNameText;
            GPCompanyAdditionalSettings.Insert(true);
        end;
    end;

    procedure DeleteAllSettings()
    var
        GPCompanyMigrationSettings: Record "GP Company Migration Settings";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        GPCompanyMigrationSettings.DeleteAll();
        GPCompanyAdditionalSettings.DeleteAll();
    end;

    // Copied from GP Cloud Migration Codeunit
    local procedure CreateDataMigrationEntites(var DataMigrationEntity: Record "Data Migration Entity"): Boolean
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        DataMigrationEntity.InsertRecord(Database::"G/L Account", AccountsToMigrateCount);

        if GPCompanyAdditionalSettings.GetReceivablesModuleEnabled() then
            DataMigrationEntity.InsertRecord(Database::Customer, CustomersToMigrateCount);

        if GPCompanyAdditionalSettings.GetPayablesModuleEnabled() then
            DataMigrationEntity.InsertRecord(Database::Vendor, VendorsToMigrateCount);

        if GPCompanyAdditionalSettings.GetInventoryModuleEnabled() then
            DataMigrationEntity.InsertRecord(Database::Item, ItemsToMigrateCount);

        exit(true);
    end;

    // Copied from GP Cloud Migration Codeunit
    local procedure CreateConfiguredDataMigrationStatusRecords()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        CreateDataMigrationStatusRecords(Database::"G/L Account", AccountsToMigrateCount, Database::"GP Account", Codeunit::"GP Account Migrator");

        if GPCompanyAdditionalSettings.GetReceivablesModuleEnabled() then
            CreateDataMigrationStatusRecords(Database::"Customer", CustomersToMigrateCount, Database::"GP Customer", Codeunit::"GP Customer Migrator");

        if GPCompanyAdditionalSettings.GetPayablesModuleEnabled() then
            CreateDataMigrationStatusRecords(Database::"Vendor", VendorsToMigrateCount, Database::"GP Vendor", Codeunit::"GP Vendor Migrator");

        if GPCompanyAdditionalSettings.GetInventoryModuleEnabled() then
            CreateDataMigrationStatusRecords(Database::"Item", ItemsToMigrateCount, Database::"GP Item", Codeunit::"GP Item Migrator");
    end;

    // Copied from GP Cloud Migration Codeunit
    local procedure CreateDataMigrationStatusRecords(DestinationTableID: Integer; NumberOfRecords: Integer; StagingTableID: Integer; CodeunitToRun: Integer)
    var
        DataMigrationStatus: Record "Data Migration Status";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        DataMigrationStatus.Init();
        DataMigrationStatus.Validate("Migration Type", HelperFunctions.GetMigrationTypeTxt());
        DataMigrationStatus.Validate("Destination Table ID", DestinationTableID);
        DataMigrationStatus.Validate("Total Number", NumberOfRecords);
        DataMigrationStatus.Validate(Status, DataMigrationStatus.Status::Pending);
        DataMigrationStatus.Validate("Source Staging Table ID", StagingTableID);
        DataMigrationStatus.Validate("Migration Codeunit To Run", CodeunitToRun);
        DataMigrationStatus.Insert()
    end;
}