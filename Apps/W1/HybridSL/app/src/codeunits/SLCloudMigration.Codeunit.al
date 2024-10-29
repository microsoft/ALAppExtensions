// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using Microsoft.DataMigration;
using Microsoft.Utilities;
using System.Integration;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Sales.Customer;
using Microsoft.Purchases.Vendor;
using Microsoft.Inventory.Item;

codeunit 42001 "SL Cloud Migration"
{
    Access = Internal;
    TableNo = "Hybrid Replication Summary";
    trigger OnRun();
    var
        HybridCompanyStatus: Record "Hybrid Company Status";
        HybridSLManagement: Codeunit "SL Hybrid Management";
        SLHelperFunctions: Codeunit "SL Helper Functions";
        SLMigrationErrorHandler: Codeunit "SL Migration Error Handler";
        HybridHandleSLUpgradeError: Codeunit "SL Hybrid Handle Upgrade Error";
        SLPopulateAccounts: Codeunit "SL Populate Accounts";
        SLPopulateFiscalPeriods: Codeunit "SL Populate Fiscal Periods";
        SLDimensions: Codeunit "SL Dimensions";
        Success: Boolean;
    begin
        SLMigrationErrorHandler.ClearErrorOccurred();
        ClearLastError();
        SLPopulateFiscalPeriods.CreateFiscalPeriodsFromGLSetup();
        SLDimensions.InsertSLSegmentsForDimensionSets();
        SLDimensions.CreateSLCodes();
        SLPopulateAccounts.PopulateSLAccounts();
        Commit();

        Codeunit.Run(Codeunit::"SL Populate Account History");
        OnUpgradeSLCompany(Success);
        if not Success then begin
            HybridHandleSLUpgradeError.MarkUpgradeFailed(Rec);
            Commit();

            HybridCompanyStatus.Get(CompanyName);
            HybridCompanyStatus."Upgrade Status" := HybridCompanyStatus."Upgrade Status"::Failed;
            HybridCompanyStatus.Modify();
            Commit();

            SLHelperFunctions.CheckAndLogErrors();
            SLMigrationErrorHandler.ClearErrorOccurred();
            Commit();
        end;

        HybridCompanyStatus.SetFilter(Name, '<>''''');
        HybridCompanyStatus.SetRange("Upgrade Status", HybridCompanyStatus."Upgrade Status"::Pending);
        if HybridCompanyStatus.FindFirst() then begin
            HybridSLManagement.InvokeCompanyUpgrade(Rec, HybridCompanyStatus.Name);
            exit;
        end;

        if not Rec.Find() then
            exit;

        if Rec.Status = Rec.Status::Failed then
            exit;

        if SLMigrationErrorHandler.ErrorOccurredDuringLastUpgrade() then begin
            HybridHandleSLUpgradeError.MarkUpgradeFailed(Rec);
            exit;
        end;

        Rec.Status := Rec.Status::Completed;
        Rec.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SL Cloud Migration", OnUpgradeSLCompany, '', false, false)]
    local procedure HandleOnUpgradeSLCompany(var Success: Boolean)
    var
        SLMigrationErrorHandler: Codeunit "SL Migration Error Handler";
    begin
        ClearLastError();
        UpgradeSLCompany();
        Success := not SLMigrationErrorHandler.GetErrorOccurred();
    end;

    internal procedure UpgradeSLCompany()
    var
        AssistedCompanySetupStatus: Record "Assisted Company Setup Status";
        HybridCompanyStatus: Record "Hybrid Company Status";
        SLHelperFunctions: Codeunit "SL Helper Functions";
        SetupStatus: Enum "Company Setup Status";
    begin
        if AssistedCompanySetupStatus.Get(CompanyName()) then begin
            SetupStatus := AssistedCompanySetupStatus.GetCompanySetupStatusValue(CopyStr(CompanyName(), 1, 30));
            if SetupStatus = SetupStatus::Completed then
                InitiateSLMigration()
            else
                Session.LogMessage('000029K', CompanyFailedToMigrateMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', SLHelperFunctions.GetTelemetryCategory());
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
        InitiateMigrationMsg: Label 'Initiate SL Migration.', Locked = true;
        StartMigrationMsg: Label 'Start Migration', Locked = true;

    internal procedure InitiateSLMigration()
    var
        SLCompanyMigrationSettings: Record "SL Company Migration Settings";
        DataMigrationEntity: Record "Data Migration Entity";
        MigrationSLConfig: Record "SL Migration Config";
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
        SLHelperFunctions: Codeunit "SL Helper Functions";
        DataMigrationFacade: Codeunit "Data Migration Facade";
        WizardIntegration: Codeunit "SL Wizard Integration";
        Flag: Boolean;
    begin
        MigrationSLConfig.GetSingleInstance();
        Session.LogMessage('0000BBH', InitiateMigrationMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', SLHelperFunctions.GetTelemetryCategory());
        MigrationSLConfig."Post Transactions" := true;
        SelectLatestVersion();
        SLHelperFunctions.SetProcessesRunning(true);

        Flag := false;
        if Flag then begin
            MigrationSLConfig.GetSingleInstance();
            MigrationSLConfig."Updated GL Setup" := true;
            MigrationSLConfig.Modify();
        end;

        DataMigrationEntity.DeleteAll();
        if not WizardIntegration.RegisterSLDataMigrator() then begin
            SLHelperFunctions.GetLastError();
            SLHelperFunctions.SetProcessesRunning(false);
            exit;
        end;

        AccountsToMigrateCount := SLHelperFunctions.GetNumberOfAccounts();
        CustomersToMigrateCount := SLHelperFunctions.GetNumberOfCustomers();
        VendorsToMigrateCount := SLHelperFunctions.GetNumberOfVendors();
        ItemsToMigrateCount := SLHelperFunctions.GetNumberOfItems();

        CreateDataMigrationEntites(DataMigrationEntity);

        SLHelperFunctions.CreateItemTrackingCodes();
        SLHelperFunctions.CreateLocations();

        if not Dimension.IsEmpty() then
            Dimension.DeleteAll();
        if not DimensionValue.IsEmpty() then
            DimensionValue.DeleteAll();
        SLHelperFunctions.CreateDimensions();

        Commit();
        if SLCompanyMigrationSettings.Get(CompanyName()) then begin
            SLHelperFunctions.SetGlobalDimensions(CopyStr(SLCompanyMigrationSettings."Global Dimension 1", 1, 20), CopyStr(SLCompanyMigrationSettings."Global Dimension 2", 1, 20));
            SLHelperFunctions.UpdateGlobalDimensionNo();
        end;

        CreateConfiguredDataMigrationStatusRecords();

        Session.LogMessage('0000BBI', StartMigrationMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', SLHelperFunctions.GetTelemetryCategory());
        DataMigrationFacade.StartMigration(SLHelperFunctions.GetMigrationTypeTxt(), false);
    end;

    internal procedure CreateDataMigrationStatusRecords(DestinationTableID: Integer; NumberOfRecords: Integer; StagingTableID: Integer; CodeunitToRun: Integer)
    var
        DataMigrationStatus: Record "Data Migration Status";
        SLHelperFunctions: Codeunit "SL Helper Functions";
    begin
        DataMigrationStatus.Init();
        DataMigrationStatus.Validate("Migration Type", SLHelperFunctions.GetMigrationTypeTxt());
        DataMigrationStatus.Validate("Destination Table ID", DestinationTableID);
        DataMigrationStatus.Validate("Total Number", NumberOfRecords);
        DataMigrationStatus.Validate(Status, DataMigrationStatus.Status::Pending);
        DataMigrationStatus.Validate("Source Staging Table ID", StagingTableID);
        DataMigrationStatus.Validate("Migration Codeunit To Run", CodeunitToRun);
        DataMigrationStatus.Insert()
    end;

    internal procedure CreateDataMigrationEntites(var DataMigrationEntity: Record "Data Migration Entity"): Boolean
    var
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
    begin
        DataMigrationEntity.InsertRecord(Database::"G/L Account", AccountsToMigrateCount);

        if SLCompanyAdditionalSettings.GetReceivablesModuleEnabled() then
            DataMigrationEntity.InsertRecord(Database::Customer, CustomersToMigrateCount);

        if SLCompanyAdditionalSettings.GetPayablesModuleEnabled() then
            DataMigrationEntity.InsertRecord(Database::Vendor, VendorsToMigrateCount);

        if SLCompanyAdditionalSettings.GetInventoryModuleEnabled() then
            DataMigrationEntity.InsertRecord(Database::Item, ItemsToMigrateCount);

        exit(true);
    end;

    internal procedure CreateConfiguredDataMigrationStatusRecords()
    var
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
    begin
        CreateDataMigrationStatusRecords(Database::"G/L Account", AccountsToMigrateCount, Database::"SL Account Staging", Codeunit::"SL Account Migrator");

        if SLCompanyAdditionalSettings.GetReceivablesModuleEnabled() then
            CreateDataMigrationStatusRecords(Database::Customer, CustomersToMigrateCount, Database::"SL Customer", Codeunit::"SL Customer Migrator");

        if SLCompanyAdditionalSettings.GetPayablesModuleEnabled() then
            CreateDataMigrationStatusRecords(Database::Vendor, VendorsToMigrateCount, Database::"SL Vendor", Codeunit::"SL Vendor Migrator");

        if SLCompanyAdditionalSettings.GetInventoryModuleEnabled() then
            CreateDataMigrationStatusRecords(Database::Item, ItemsToMigrateCount, Database::"SL Inventory", Codeunit::"SL Item Migrator");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", OnIsCloudMigrationCompleted, '', false, false)]
    local procedure HandleIsCloudMigrationCompleted(SourceProduct: Text; var CloudMigrationCompleted: Boolean)
    var
        HybridSLWizard: Codeunit "SL Hybrid Wizard";
    begin
        if SourceProduct <> HybridSLWizard.ProductIdTxt() then
            exit;

        CloudMigrationCompleted := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", OnInsertDefaultTableMappings, '', false, false)]
    local procedure OnInsertDefaultTableMappings(DeleteExisting: Boolean; ProductID: Text[250])
    var
        HybridSLWizard: Codeunit "SL Hybrid Wizard";
    begin
        if ProductID <> HybridSLWizard.ProductIdTxt() then
            exit;

        // Accounts
        UpdateOrInsertRecord(Database::"SL Account", 'Account');
        UpdateOrInsertRecord(Database::"SL AcctHist", 'AcctHist');
        UpdateOrInsertRecord(Database::"SL Batch", 'Batch');
        UpdateOrInsertRecord(Database::"SL GLSetup", 'GLSetup');
        UpdateOrInsertRecord(Database::"SL GLTran", 'GLTran');
        // Payables
        UpdateOrInsertRecord(Database::"SL AP_Balances", 'AP_Balances');
        UpdateOrInsertRecord(Database::"SL APAdjust", 'APAdjust');
        UpdateOrInsertRecord(Database::"SL APDoc", 'APDoc');
        UpdateOrInsertRecord(Database::"SL APSetup", 'APSetup');
        UpdateOrInsertRecord(Database::"SL APTran", 'APTran');
        UpdateOrInsertRecord(Database::"SL POAddress", 'POAddress');
        UpdateOrInsertRecord(Database::"SL POReceipt", 'POReceipt');
        UpdateOrInsertRecord(Database::"SL POSetup", 'POSetup');
        UpdateOrInsertRecord(Database::"SL POTran", 'POTran');
        UpdateOrInsertRecord(Database::"SL PurchOrd", 'PurchOrd');
        UpdateOrInsertRecord(Database::"SL PurOrdDet", 'PurOrdDet');
        UpdateOrInsertRecord(Database::"SL Vendor", 'Vendor');
        // Receivables
        UpdateOrInsertRecord(Database::"SL AR_Balances", 'AR_Balances');
        UpdateOrInsertRecord(Database::"SL ARAdjust", 'ARAdjust');
        UpdateOrInsertRecord(Database::"SL ARDoc", 'ARDoc');
        UpdateOrInsertRecord(Database::"SL ARSetup", 'ARSetup');
        UpdateOrInsertRecord(Database::"SL ARTran", 'ARTran');
        UpdateOrInsertRecord(Database::"SL Customer", 'Customer');
        UpdateOrInsertRecord(Database::"SL SOAddress", 'SOAddress');
        UpdateOrInsertRecord(Database::"SL SOHeader", 'SOHeader');
        UpdateOrInsertRecord(Database::"SL SOLine", 'SOLine');
        UpdateOrInsertRecord(Database::"SL SOSetup", 'SOSetup');
        UpdateOrInsertRecord(Database::"SL SOShipHeader", 'SOShipHeader');
        UpdateOrInsertRecord(Database::"SL SOShipLine", 'SOShipLine');
        UpdateOrInsertRecord(Database::"SL SOShipLot", 'SOShipLot');
        UpdateOrInsertRecord(Database::"SL SOType", 'SOType');
        // Items
        UpdateOrInsertRecord(Database::"SL INSetup", 'INSetup');
        UpdateOrInsertRecord(Database::"SL INTran", 'INTran');
        UpdateOrInsertRecord(Database::"SL Inventory", 'Inventory');
        UpdateOrInsertRecord(Database::"SL InventoryADG", 'InventoryADG');
        UpdateOrInsertRecord(Database::"SL ItemCost", 'ItemCost');
        UpdateOrInsertRecord(Database::"SL ItemSite", 'ItemSite');
        UpdateOrInsertRecord(Database::"SL LotSerMst", 'LotSerMst');
        UpdateOrInsertRecord(Database::"SL LotSerT", 'LotSerT');
        UpdateOrInsertRecord(Database::"SL Site", 'Site');
        // Misc
        UpdateOrInsertRecord(Database::"SL FlexDef", 'FlexDef');
        UpdateOrInsertRecord(Database::"SL SegDef", 'SegDef');
        UpdateOrInsertRecord(Database::"SL Terms", 'Terms');
    end;

    internal procedure UpdateOrInsertRecord(TableID: Integer; SourceTableName: Text[128])
    begin
        UpdateOrInsertRecord(TableID, SourceTableName, true);
    end;

    internal procedure UpdateOrInsertRecord(TableID: Integer; SourceTableName: Text[128]; PerCompanyTable: Boolean)
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
    internal procedure OnUpgradeSLCompany(var Success: Boolean)
    begin
    end;
}