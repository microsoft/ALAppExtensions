codeunit 4025 "GP Cloud Migration"
{
    trigger OnRun();
    var
        AssistedCompanySetupStatus: Record "Assisted Company Setup Status";
        HelperFunctions: Codeunit "Helper Functions";
        SetupStatus: Option " ","Completed","In Progress","Error","Missing Permission";
    begin
        if AssistedCompanySetupStatus.Get(CompanyName()) then begin
            SetupStatus := AssistedCompanySetupStatus.GetCompanySetupStatus(CopyStr(CompanyName(), 1, 30));
            if SetupStatus = SetupStatus::Completed then
                InitiateGPMigration()
            else
                SendTraceTag('000029K', HelperFunctions.GetMigrationTypeTxt(), Verbosity::Normal, CompanyFailedToMigrateMsg, DataClassification::SystemMetadata);
        end;
    end;

    var
        CompanyFailedToMigrateMsg: Label 'Migration did not start because the company setup is still in process.', Locked = true;
        InitiateMigrationMsg: Label 'Initiate GP Migration.', Locked = true;
        StartMigrationMsg: Label 'Start Migration', Locked = true;

    local procedure InitiateGPMigration()
    var
        DataMigrationEntity: Record "Data Migration Entity";
        GPCompanyMigrationSettings: Record "GP Company Migration Settings";
        GPAccount: Record "GP Account";
        GPCustomer: Record "GP Customer";
        GPVendor: Record "GP Vendor";
        GPItem: Record "GP Item";
        GPConfiguration: Record "GP Configuration";
        HelperFunctions: Codeunit "Helper Functions";
        DataMigrationFacade: Codeunit "Data Migration Facade";
        WizardIntegration: Codeunit "Wizard Integration";
        Flag: Boolean;
    begin
        SendTraceTag('0000BBH', HelperFunctions.GetMigrationTypeTxt(), Verbosity::Normal, InitiateMigrationMsg, DataClassification::SystemMetadata);
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

        CreateDataMigrationStatusRecords(Database::"G/L Account", GPAccount.Count(), 4090, 4017);
        CreateDataMigrationStatusRecords(Database::"Customer", GPCustomer.Count(), 4093, 4018);
        CreateDataMigrationStatusRecords(Database::"Vendor", GPVendor.Count(), 4096, 4022);
        CreateDataMigrationStatusRecords(Database::"Item", GPItem.Count(), 4095, 4019);

        SendTraceTag('0000BBI', HelperFunctions.GetMigrationTypeTxt(), Verbosity::Normal, StartMigrationMsg, DataClassification::SystemMetadata);
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
    begin
        DataMigrationEntity.InsertRecord(Database::"G/L Account", HelperFunctions.GetNumberOfAccounts());
        DataMigrationEntity.InsertRecord(Database::Customer, HelperFunctions.GetNumberOfCustomers());
        DataMigrationEntity.InsertRecord(Database::Vendor, HelperFunctions.GetNumberOfVendors());
        DataMigrationEntity.InsertRecord(Database::Item, HelperFunctions.GetNumberOfItems());
        exit(true);
    end;
}
