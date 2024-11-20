// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using Microsoft.DataMigration;
using Microsoft.Utilities;
using System.Integration;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Sales.Customer;
using Microsoft.Purchases.Vendor;
using Microsoft.Inventory.Item;

codeunit 47001 "SL Cloud Migration"
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
        Success: Boolean;
    begin
        SLMigrationErrorHandler.ClearErrorOccurred();

        ClearLastError();
        OnUpgradeSLCompany(Success);

        if not Success then begin
            HybridHandleSLUpgradeError.MarkUpgradeFailed(Rec);
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
        SLMigrationConfig: Record "SL Migration Config";
        DataMigrationFacade: Codeunit "Data Migration Facade";
        SLDimensions: Codeunit "SL Dimensions";
        SLHelperFunctions: Codeunit "SL Helper Functions";
        SLPopulateAccounts: Codeunit "SL Populate Accounts";
        SLPopulateAccountHistory: Codeunit "SL Populate Account History";
        SLPopulateFiscalPeriods: Codeunit "SL Populate Fiscal Periods";
        WizardIntegration: Codeunit "SL Wizard Integration";
        Flag: Boolean;
    begin
        Session.LogMessage('0000BBH', InitiateMigrationMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', SLHelperFunctions.GetTelemetryCategory());

        SelectLatestVersion();
        SLHelperFunctions.SetProcessesRunning(true);

        SLPopulateFiscalPeriods.CreateFiscalPeriodsFromGLSetup();
        SLDimensions.InsertSLSegmentsForDimensionSets();
        SLDimensions.CreateSLCodes();
        SLPopulateAccounts.PopulateSLAccounts();
        SLPopulateAccountHistory.Run();
        Commit();

        Flag := false;
        SLHelperFunctions.ResetAdjustforPaymentInGLSetup(Flag);
        if Flag then begin
            SLMigrationConfig.GetSingleInstance();
            SLMigrationConfig."Updated GL Setup" := true;
            SLMigrationConfig.Modify();
        end;

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

        if not SLHelperFunctions.CreatePreMigrationData() then begin
            SLHelperFunctions.GetLastError();
            SLHelperFunctions.SetProcessesRunning(false);
            exit;
        end;

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

    [IntegrationEvent(false, false, true)]
    internal procedure OnUpgradeSLCompany(var Success: Boolean)
    begin
    end;
}