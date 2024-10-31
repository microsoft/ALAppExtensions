namespace Microsoft.DataMigration.GP;

using Microsoft.DataMigration;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Purchases.Vendor;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Utilities;
using System.Integration;

codeunit 4025 "GP Cloud Migration"
{
    TableNo = "Hybrid Replication Summary";

    trigger OnRun();
    var
        HybridCompanyStatus: Record "Hybrid Company Status";
        GPUpgradeSettings: Record "GP Upgrade Settings";
        HybridGPManagement: Codeunit "Hybrid GP Management";
        HelperFunctions: Codeunit "Helper Functions";
        GPMigrationErrorHandler: Codeunit "GP Migration Error Handler";
        HybridHandleGPUpgradeError: Codeunit "Hybrid Handle GP Upgrade Error";
        GPCollectAllModifications: Codeunit "GP Collect All Modifications";
        Success: Boolean;
    begin
        GPMigrationErrorHandler.ClearErrorOccured();

        GPUpgradeSettings.GetonInsertGPUpgradeSettings(GPUpgradeSettings);
        if GPUpgradeSettings."Log All Record Changes" then
            if BindSubscription(GPCollectAllModifications) then;

        ClearLastError();
        OnUpgradeGPCompany(Success);

        if GPUpgradeSettings."Log All Record Changes" then
            if UnbindSubscription(GPCollectAllModifications) then;

        if not Success then begin
            HybridHandleGPUpgradeError.MarkUpgradeFailed(Rec);
            Commit();

            HelperFunctions.CheckAndLogErrors();
            GPMigrationErrorHandler.ClearErrorOccured();
            Commit();

            GPUpgradeSettings.GetonInsertGPUpgradeSettings(GPUpgradeSettings);
            if not GPUpgradeSettings."Collect All Errors" then
                Error(DataTransformationErrorsPresentMsg);
        end;

        HybridCompanyStatus.SetFilter(Name, '<>''''');
        HybridCompanyStatus.SetRange("Upgrade Status", HybridCompanyStatus."Upgrade Status"::Pending);
        if HybridCompanyStatus.FindFirst() then begin
            HybridGPManagement.InvokeCompanyUpgrade(Rec, HybridCompanyStatus.Name);
            exit;
        end;

        if not Rec.Find() then
            exit;

        if Rec.Status = Rec.Status::Failed then
            exit;

        if GPMigrationErrorHandler.ErrorOccuredDuringLastUpgrade() then begin
            HybridHandleGPUpgradeError.MarkUpgradeFailed(Rec);
            exit;
        end;

        Rec.Status := Rec.Status::Completed;
        Rec.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GP Cloud Migration", 'OnUpgradeGPCompany', '', false, false)]
    local procedure HandleOnUpgradeGPCompany(var Success: Boolean)
    var
        GPMigrationErrorHandler: Codeunit "GP Migration Error Handler";
    begin
        ClearLastError();
        UpgradeGPCompany();
        Success := not GPMigrationErrorHandler.GetErrorOccured();
    end;

    internal procedure UpgradeGPCompany()
    var
        AssistedCompanySetupStatus: Record "Assisted Company Setup Status";
        HybridCompanyStatus: Record "Hybrid Company Status";
        HelperFunctions: Codeunit "Helper Functions";
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
    end;

    var
        AccountsToMigrateCount: Integer;
        CustomersToMigrateCount: Integer;
        VendorsToMigrateCount: Integer;
        ItemsToMigrateCount: Integer;
        CompanyFailedToMigrateMsg: Label 'Migration did not start because the company setup is still in process.', Locked = true;
        InitiateMigrationMsg: Label 'Initiate GP Migration.', Locked = true;
        StartMigrationMsg: Label 'Start Migration', Locked = true;

    local procedure InitiateGPMigration()
    var
        DataMigrationEntity: Record "Data Migration Entity";
        GPCompanyMigrationSettings: Record "GP Company Migration Settings";
        GPConfiguration: Record "GP Configuration";
        GPPopulateCombinedTables: Codeunit "GP Populate Combined Tables";
        HelperFunctions: Codeunit "Helper Functions";
        DataMigrationFacade: Codeunit "Data Migration Facade";
        WizardIntegration: Codeunit "Wizard Integration";
        Flag: Boolean;
    begin
        Session.LogMessage('0000BBH', InitiateMigrationMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetTelemetryCategory());

        SelectLatestVersion();
        HelperFunctions.SetProcessesRunning(true);

        GPPopulateCombinedTables.PopulateAllMappedTables();
        Commit();

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

        CreateConfiguredDataMigrationStatusRecords();

        Session.LogMessage('0000BBI', StartMigrationMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetTelemetryCategory());
        DataMigrationFacade.StartMigration(HelperFunctions.GetMigrationTypeTxt(), false);
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
        DataMigrationStatus.Insert();
    end;

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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnIsCloudMigrationCompleted', '', false, false)]
    local procedure HandleIsCloudMigrationCompleted(SourceProduct: Text; var CloudMigrationCompleted: Boolean)
    var
        HybridGPWizard: Codeunit "Hybrid GP Wizard";
    begin
        if SourceProduct <> HybridGPWizard.ProductId() then
            exit;

        CloudMigrationCompleted := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnInsertDefaultTableMappings', '', false, false)]
    local procedure OnInsertDefaultTableMappings(DeleteExisting: Boolean; ProductID: Text[250])
    var
        HybridGPWizard: Codeunit "Hybrid GP Wizard";
    begin
        if ProductID <> HybridGPWizard.ProductId() then
            exit;

        UpdateOrInsertRecord(Database::"GP BM30200", 'BM30200');

        UpdateOrInsertRecord(Database::"GP Checkbook MSTR", 'CM00100');
        UpdateOrInsertRecord(Database::"GP Checkbook Transactions", 'CM20200');
        UpdateOrInsertRecord(Database::"GP CM20600", 'CM20600');

        UpdateOrInsertRecord(Database::"GP GL00100", 'GL00100');
        UpdateOrInsertRecord(Database::"GP GL00105", 'GL00105');
        UpdateOrInsertRecord(Database::"GP GL10110", 'GL10110');
        UpdateOrInsertRecord(Database::"GP GL10111", 'GL10111');
        UpdateOrInsertRecord(Database::"GP GL20000", 'GL20000');
        UpdateOrInsertRecord(Database::"GP GL30000", 'GL30000');
        UpdateOrInsertRecord(Database::"GP GL40200", 'GL40200');

        UpdateOrInsertRecord(Database::"GP IV00101", 'IV00101');
        UpdateOrInsertRecord(Database::"GP IV00102", 'IV00102');
        UpdateOrInsertRecord(Database::"GP IV00104", 'IV00104');
        UpdateOrInsertRecord(Database::"GP IV00105", 'IV00105');
        UpdateOrInsertRecord(Database::"GP IV00200", 'IV00200');
        UpdateOrInsertRecord(Database::"GP IV00300", 'IV00300');
        UpdateOrInsertRecord(Database::"GP IV10200", 'IV10200');
        UpdateOrInsertRecord(Database::"GP IV40400", 'IV40400');

        UpdateOrInsertRecord(Database::GPIVBinQtyTransferHist, 'IV30004');
        UpdateOrInsertRecord(Database::GPIVTrxHist, 'IV30200');
        UpdateOrInsertRecord(Database::GPIVTrxAmountsHist, 'IV30300');
        UpdateOrInsertRecord(Database::GPIVTrxDetailHist, 'IV30301');
        UpdateOrInsertRecord(Database::GPIVTrxBinQtyHist, 'IV30302');
        UpdateOrInsertRecord(Database::GPIVSerialLotNumberHist, 'IV30400');
        UpdateOrInsertRecord(Database::GPIVDistributionHist, 'IV30500');
        UpdateOrInsertRecord(Database::GPIVLotAttributeHist, 'IV30600');
        UpdateOrInsertRecord(Database::"GP IV40201", 'IV40201');
        UpdateOrInsertRecord(Database::"GP Item Location", 'IV40700');

        UpdateOrInsertRecord(Database::"GP MC40000", 'MC40000');
        UpdateOrInsertRecord(Database::"GP MC40200", 'MC40200', false);

        UpdateOrInsertRecord(Database::"GP PM00100", 'PM00100');
        UpdateOrInsertRecord(Database::"GP PM00200", 'PM00200');
        UpdateOrInsertRecord(Database::"GP PM00201", 'PM00201');
        UpdateOrInsertRecord(Database::"GP PM00204", 'PM00204');
        UpdateOrInsertRecord(Database::"GP Vendor Address", 'PM00300');
        UpdateOrInsertRecord(Database::"GP PM10200", 'PM10200');
        UpdateOrInsertRecord(Database::"GP PM20000", 'PM20000');
        UpdateOrInsertRecord(Database::GPPMHist, 'PM30200');
        UpdateOrInsertRecord(Database::"GP PM30300", 'PM30300');

        UpdateOrInsertRecord(Database::"GP POP10100", 'POP10100');
        UpdateOrInsertRecord(Database::"GP POP10110", 'POP10110');
        UpdateOrInsertRecord(Database::GPPOPReceiptApply, 'POP10500');
        UpdateOrInsertRecord(Database::GPPOPReceiptHist, 'POP30300');
        UpdateOrInsertRecord(Database::GPPOPReceiptLineHist, 'POP30310');
        UpdateOrInsertRecord(Database::GPPOPSerialLotHist, 'POP30330');
        UpdateOrInsertRecord(Database::GPPOPPOHist, 'POP30100');
        UpdateOrInsertRecord(Database::GPPOPPOLineHist, 'POP30110');
        UpdateOrInsertRecord(Database::GPPOPPOTaxHist, 'POP30160');
        UpdateOrInsertRecord(Database::GPPOPBinQtyHist, 'POP30340');
        UpdateOrInsertRecord(Database::GPPOPTaxHist, 'POP30360');
        UpdateOrInsertRecord(Database::GPPOPDistributionHist, 'POP30390');
        UpdateOrInsertRecord(Database::GPPOPLandedCostHist, 'POP30700');

        UpdateOrInsertRecord(Database::"GP RM00101", 'RM00101');
        UpdateOrInsertRecord(Database::"GP Customer Address", 'RM00102');
        UpdateOrInsertRecord(Database::"GP RM00103", 'RM00103');
        UpdateOrInsertRecord(Database::"GP RM00201", 'RM00201');
        UpdateOrInsertRecord(Database::"GP RM20101", 'RM20101');
        UpdateOrInsertRecord(Database::"GP RM20201", 'RM20201');
        UpdateOrInsertRecord(Database::GPRMHist, 'RM30101');
        UpdateOrInsertRecord(Database::"GP RM30201", 'RM30201');

        UpdateOrInsertRecord(Database::GPSOPTrxHist, 'SOP30200');
        UpdateOrInsertRecord(Database::GPSOPDepositHist, 'SOP30201');
        UpdateOrInsertRecord(Database::GPSOPTrxAmountsHist, 'SOP30300');
        UpdateOrInsertRecord(Database::GPSOPCommissionsWorkHist, 'SOP10101');
        UpdateOrInsertRecord(Database::GPSOPDistributionWorkHist, 'SOP10102');
        UpdateOrInsertRecord(Database::GPSOPPaymentWorkHist, 'SOP10103');
        UpdateOrInsertRecord(Database::GPSOPProcessHoldWorkHist, 'SOP10104');
        UpdateOrInsertRecord(Database::GPSOPTaxesWorkHist, 'SOP10105');
        UpdateOrInsertRecord(Database::GPSOPUserDefinedWorkHist, 'SOP10106');
        UpdateOrInsertRecord(Database::GPSOPTrackingNumbersWorkHist, 'SOP10107');
        UpdateOrInsertRecord(Database::GPSOPWorkflowWorkHist, 'SOP10112');
        UpdateOrInsertRecord(Database::GPSOPSerialLotWorkHist, 'SOP10201');
        UpdateOrInsertRecord(Database::GPSOPLineCommentWorkHist, 'SOP10202');
        UpdateOrInsertRecord(Database::GPSOPBinQuantityWorkHist, 'SOP10203');

        UpdateOrInsertRecord(Database::"GP SY00300", 'SY00300');
        UpdateOrInsertRecord(Database::"GP SY01100", 'SY01100');
        UpdateOrInsertRecord(Database::"GP SY01200", 'SY01200');
        UpdateOrInsertRecord(Database::"GP Payment Terms", 'SY03300');
        UpdateOrInsertRecord(Database::"GP Bank MSTR", 'SY04100');
        UpdateOrInsertRecord(Database::"GP SY06000", 'SY06000');
        UpdateOrInsertRecord(Database::"GP SY40100", 'SY40100');
        UpdateOrInsertRecord(Database::"GP SY40101", 'SY40101');
    end;

    local procedure UpdateOrInsertRecord(TableID: Integer; SourceTableName: Text[128])
    begin
        UpdateOrInsertRecord(TableID, SourceTableName, true);
    end;

    local procedure UpdateOrInsertRecord(TableID: Integer; SourceTableName: Text[128]; PerCompanyTable: Boolean)
    var
        MigrationTableMapping: Record "Migration Table Mapping";
        CurrentModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        if MigrationTableMapping.Get(CurrentModuleInfo.Id(), TableID) then
            MigrationTableMapping.Delete();

        MigrationTableMapping."App ID" := CurrentModuleInfo.Id();
        MigrationTableMapping.Validate("Table ID", TableID);
        MigrationTableMapping."Data Per Company" := PerCompanyTable;
        MigrationTableMapping."Source Table Name" := SourceTableName;
        MigrationTableMapping.Insert();
    end;

    [IntegrationEvent(false, false, true)]
    local procedure OnUpgradeGPCompany(var Success: Boolean)
    begin
    end;

    var
        DataTransformationErrorsPresentMsg: Label 'Data transformation errors were found. You can inspect the errors on the "Data transformation errors" page.';
}
