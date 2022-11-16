codeunit 4025 "GP Cloud Migration"
{
    TableNo = "Hybrid Replication Summary";

    trigger OnRun();
    var
        HybridCompanyStatus: Record "Hybrid Company Status";
        AssistedCompanySetupStatus: Record "Assisted Company Setup Status";
        HelperFunctions: Codeunit "Helper Functions";
        HybridGPManagement: Codeunit "Hybrid GP Management";
        SetupStatus: Enum "Company Setup Status";
    begin
        if AssistedCompanySetupStatus.Get(CompanyName()) then begin
            SetupStatus := AssistedCompanySetupStatus.GetCompanySetupStatusValue(CopyStr(CompanyName(), 1, 30));
            if SetupStatus = SetupStatus::Completed then
                InitiateGPMigration()
            else
                Session.LogMessage('000029K', CompanyFailedToMigrateMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetTelemetryCategory());
        end;

        Commit();
        HybridCompanyStatus.Get(CompanyName);
        HybridCompanyStatus."Upgrade Status" := HybridCompanyStatus."Upgrade Status"::Completed;
        HybridCompanyStatus.Modify();

        Clear(HybridCompanyStatus);
        HybridCompanyStatus.SetFilter(Name, '<>''''');
        HybridCompanyStatus.SetRange("Upgrade Status", HybridCompanyStatus."Upgrade Status"::Pending);
        if HybridCompanyStatus.FindFirst() then begin
            HybridGPManagement.InvokeCompanyUpgrade(Rec, HybridCompanyStatus.Name);
            exit;
        end;

        if Rec.Find() then begin
            Rec.Status := Rec.Status::Completed;
            Rec.Modify();
        end;
    end;

    var
        AccountsToMigrateCount: Integer;
        CustomersToMigrateCount: Integer;
        VendorsToMigrateCount: Integer;
        ItemsToMigrateCount: Integer;
        CompanyFailedToMigrateMsg: Label 'Migration did not start because the company setup is still in process.', Locked = true;
        InitiateMigrationMsg: Label 'Initiate GP Migration.', Locked = true;
        StartMigrationMsg: Label 'Start Migration', Locked = true;
        GPSY40100Lbl: Label 'SY40100', Locked = true;
        GPSY40101Lbl: Label 'SY40101', Locked = true;
        GPCM20600Lbl: Label 'CM20600', Locked = true;
        GPMC40200Lbl: Label 'MC40200', Locked = true;
        GPSY06000Lbl: Label 'SY06000', Locked = true;
        GPPM00100Lbl: Label 'PM00100', Locked = true;
        GPPM00200Lbl: Label 'PM00200', Locked = true;
        GPRM00101Lbl: Label 'RM00101', Locked = true;
        GPRM00201Lbl: Label 'RM00201', Locked = true;
        GPIV00101Lbl: Label 'IV00101', Locked = true;
        GPIV40400Lbl: Label 'IV40400', Locked = true;
        GPGL10111Lbl: Label 'GL10111', Locked = true;

    local procedure InitiateGPMigration()
    var
        DataMigrationEntity: Record "Data Migration Entity";
        GPCompanyMigrationSettings: Record "GP Company Migration Settings";
        GPConfiguration: Record "GP Configuration";
        HelperFunctions: Codeunit "Helper Functions";
        DataMigrationFacade: Codeunit "Data Migration Facade";
        WizardIntegration: Codeunit "Wizard Integration";
        Flag: Boolean;
    begin
        Session.LogMessage('0000BBH', InitiateMigrationMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetTelemetryCategory());

        SelectLatestVersion();
        HelperFunctions.SetProcessesRunning(true);
        HelperFunctions.CleanupBeforeSynchronization();

        if not HelperFunctions.PreMigrationCleanupCompleted() then begin
            HelperFunctions.GetLastError();
            HelperFunctions.SetProcessesRunning(false);
            exit;
        end;

        Flag := false;
        HelperFunctions.ResetAdjustforPaymentInGLSetup(Flag);
        if Flag then begin
            // If we updated the GL Setup table, we need to remember that so we can revert that change when migration is complete
            // See OnAfterMigrationFinishedSubscriber() method in codeunit 4028 
            GPConfiguration.GetSingleInstance();
            GPConfiguration."Updated GL Setup" := true;
            GPConfiguration.Modify();
        end;

        if not WizardIntegration.RegisterGPDataMigrator() then begin
            HelperFunctions.GetLastError();
            HelperFunctions.SetProcessesRunning(false);
            exit;
        end;

        AccountsToMigrateCount := HelperFunctions.GetNumberOfAccounts();
        CustomersToMigrateCount := HelperFunctions.GetNumberOfCustomers();
        VendorsToMigrateCount := HelperFunctions.GetNumberOfVendors();
        ItemsToMigrateCount := HelperFunctions.GetNumberOfItems();

        CreateDataMigrationEntites(DataMigrationEntity);

        HelperFunctions.CreateSetupRecordsIfNeeded();

        if not HelperFunctions.CreatePreMigrationData() then begin
            HelperFunctions.GetLastError();
            HelperFunctions.SetProcessesRunning(false);
            exit;
        end;

        Commit();
        if GPCompanyMigrationSettings.Get(CompanyName()) then begin
            HelperFunctions.SetGlobalDimensions(CopyStr(GPCompanyMigrationSettings."Global Dimension 1", 1, 20), CopyStr(GPCompanyMigrationSettings."Global Dimension 2", 1, 20));
            HelperFunctions.UpdateGlobalDimensionNo();
        end;

        CreateConfiguredDataMigrationStatusRecords(DataMigrationEntity);

        Session.LogMessage('0000BBI', StartMigrationMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetTelemetryCategory());
        DataMigrationFacade.StartMigration(HelperFunctions.GetMigrationTypeTxt(), FALSE);
    end;

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

    local procedure CreateDataMigrationEntites(var DataMigrationEntity: Record "Data Migration Entity"): Boolean
    var
        HelperFunctions: Codeunit "Helper Functions";
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

    local procedure CreateConfiguredDataMigrationStatusRecords(var DataMigrationEntity: Record "Data Migration Entity")
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPAccount: Record "GP Account";
        GPCustomer: Record "GP Customer";
        GPVendor: Record "GP Vendor";
        GPItem: Record "GP Item";
    begin
        CreateDataMigrationStatusRecords(Database::"G/L Account", AccountsToMigrateCount, Database::"GP Account", Codeunit::"GP Account Migrator");

        if GPCompanyAdditionalSettings.GetReceivablesModuleEnabled() then
            CreateDataMigrationStatusRecords(Database::"Customer", CustomersToMigrateCount, Database::"GP Customer", Codeunit::"GP Customer Migrator");

        if GPCompanyAdditionalSettings.GetPayablesModuleEnabled() then
            CreateDataMigrationStatusRecords(Database::"Vendor", VendorsToMigrateCount, Database::"GP Vendor", Codeunit::"GP Vendor Migrator");

        if GPCompanyAdditionalSettings.GetInventoryModuleEnabled() then
            CreateDataMigrationStatusRecords(Database::"Item", ItemsToMigrateCount, Database::"GP Item", Codeunit::"GP Item Migrator");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnInsertDefaultTableMappings', '', false, false)]
    local procedure OnInsertDefaultTableMappings(DeleteExisting: Boolean; ProductID: Text[250])
    begin
        UpdateOrInsertRecord(Database::"GP SY40100", GPSY40100Lbl);
        UpdateOrInsertRecord(Database::"GP SY40101", GPSY40101Lbl);
        UpdateOrInsertRecord(Database::"GP CM20600", GPCM20600Lbl);
        UpdateOrInsertRecord(Database::"GP MC40200", GPMC40200Lbl);
        UpdateOrInsertRecord(Database::"GP SY06000", GPSY06000Lbl);
        UpdateOrInsertRecord(Database::"GP PM00100", GPPM00100Lbl);
        UpdateOrInsertRecord(Database::"GP PM00200", GPPM00200Lbl);
        UpdateOrInsertRecord(Database::"GP RM00101", GPRM00101Lbl);
        UpdateOrInsertRecord(Database::"GP RM00201", GPRM00201Lbl);
        UpdateOrInsertRecord(Database::"GP IV00101", GPIV00101Lbl);
        UpdateOrInsertRecord(Database::"GP IV40400", GPIV40400Lbl);
    end;

    local procedure UpdateOrInsertRecord(TableID: Integer; SourceTableName: Text[128])
    var
        MigrationTableMapping: Record "Migration Table Mapping";
        CurrentModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        if MigrationTableMapping.Get(CurrentModuleInfo.Id(), TableID) then
            MigrationTableMapping.Delete();

        MigrationTableMapping."App ID" := CurrentModuleInfo.Id();
        MigrationTableMapping.Validate("Table ID", TableID);
        MigrationTableMapping."Source Table Name" := SourceTableName;
        MigrationTableMapping.Insert();
    end;
}