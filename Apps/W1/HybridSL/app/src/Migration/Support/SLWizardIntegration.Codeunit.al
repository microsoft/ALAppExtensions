// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using System.Integration;
using Microsoft.DataMigration;
using System.Threading;
using Microsoft.Inventory.Item;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Sales.Customer;
using Microsoft.Purchases.Vendor;
using System.Security.User;
using Microsoft.Finance.FinancialReports;

codeunit 47005 "SL Wizard Integration"
{
    Access = Internal;

    var
        SLHelperFunctions: Codeunit "SL Helper Functions";
        DataMigratorDescTxt: Label 'Import from Dynamics SL Cloud';
        SLSnapshotJobDescriptionTxt: Label 'Migrate SL Historical Snapshot';
        TelemetrySnapshotFailedToStartSessionMsg: Label 'SL Historical Snapshot could not start a new Session.', Locked = true;
        TelemetrySnapshotScheduledMsg: Label 'SL Historical Snapshot is now scheduled. Mode: %1', Locked = true;
        TelemetrySnapshotToBeScheduledMsg: Label 'SL Historical Snapshot is about to be scheduled. Mode: %1', Locked = true;
        UnableToRegisterMigrationMsg: Label 'Unable to register the SL Cloud Migration.', Locked = true;
        UnableToUnRegisterMigrationMsg: Label 'Unable to unregister the SL Cloud Migration.', Locked = true;

    internal procedure RegisterSLDataMigrator(): Boolean
    var
        DataMigratorRegistration: Record "Data Migrator Registration";
    begin
        DataMigratorRegistration.SetFilter("No.", '= %1', GetCurrentCodeUnitNumber());
        if not DataMigratorRegistration.FindSet() then
            if not DataMigratorRegistration.RegisterDataMigrator(GetCurrentCodeUnitNumber(), CopyStr(DataMigratorDescTxt, 1, 250)) then begin
                SLHelperFunctions.GetLastError();
                Session.LogMessage('0000B68', UnableToRegisterMigrationMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', SLHelperFunctions.GetTelemetryCategory());
                SLHelperFunctions.SetProcessesRunning(false);
                exit(false);
            end;

        exit(true);
    end;

    internal procedure UnRegisterSLDataMigrator()
    var
        DataMigratorRegistration: Record "Data Migrator Registration";
    begin
        DataMigratorRegistration.SetFilter("No.", '= %1', GetCurrentCodeUnitNumber());
        if not DataMigratorRegistration.FindSet() then
            if not DataMigratorRegistration.Delete() then
                Session.LogMessage('0000B69', UnableToUnRegisterMigrationMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', SLHelperFunctions.GetTelemetryCategory());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", 'OnApplySelectedData', '', true, true)]
    local procedure OnApplySelectedDataApplySLData(var DataMigratorRegistration: Record "Data Migrator Registration"; var DataMigrationEntity: Record "Data Migration Entity"; var Handled: Boolean)
    begin
        if DataMigratorRegistration."No." <> GetCurrentCodeUnitNumber() then
            exit;

        SendTelemetryForSelectedEntities(DataMigrationEntity);
        Handled := true;
    end;

    // This is after OnMigrationCompleted. OnMigrationCompleted fires when opening the Data Migration Overview page so removed that subscriber
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Mgt.", OnCreatePostMigrationData, '', true, true)]
    local procedure OnCreatePostMigrationDataSubscriber(var DataMigrationStatus: Record "Data Migration Status"; var DataCreationFailed: Boolean)
    var
        SLMigrationConfig: Record "SL Migration Config";
        SLMigrationErrorHandler: Codeunit "SL Migration Error Handler";
        Flag: Boolean;
    begin
        if not (DataMigrationStatus."Migration Type" = SLHelperFunctions.GetMigrationTypeTxt()) then
            exit;

        if SLMigrationErrorHandler.GetErrorOccurred() then
            exit;

        if DataMigrationStatus.Status = DataMigrationStatus.Status::Completed then
            UnRegisterSLDataMigrator();

        Codeunit.Run(Codeunit::"Categ. Generate Acc. Schedules");
        if SLMigrationConfig.Get() then
            if SLMigrationConfig."Updated GL Setup" then begin
                Flag := true;
                SLHelperFunctions.ResetAdjustforPaymentInGLSetup(Flag);
            end;
    end;

    // This is after OnMigrationCompleted. OnMigrationCompleted fires when opening the Data Migration Overview page so removed that subscriber
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Mgt.", OnAfterMigrationFinished, '', true, true)]
    local procedure OnAfterMigrationFinishedSubscriber(var DataMigrationStatus: Record "Data Migration Status"; WasAborted: Boolean; StartTime: DateTime; Retry: Boolean)
    var
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        SLHybridWizard: Codeunit "SL Hybrid Wizard";
    begin
        if not SLHybridWizard.GetSLMigrationEnabled() then
            exit;

        SLHelperFunctions.PostGLTransactions();
        SLHelperFunctions.SetProcessesRunning(false);

        if SLCompanyAdditionalSettings.GetMigrateHistory() then
            ScheduleSLHistoricalSnapshotMigration();
    end;

    internal procedure SendTelemetryForSelectedEntities(var DataMigrationEntity: Record "Data Migration Entity")
    var
        EntitiesToMigrateMessage: Text;
        VendorsTxt: Label 'Vendors: %1; ', Comment = '%1 - Number of vendors', Locked = true;
        CustomersTxt: Label 'Customers: %1; ', Comment = '%1 - Number of customers', Locked = true;
        GLAccountsTxt: Label 'GL Accounts: %1; ', Comment = '%1 - Number of GL Accounts', Locked = true;
        ItemsTxt: Label 'Items: %1; ', Comment = '%1 - Number of items', Locked = true;
    begin
        DataMigrationEntity.SetRange(Selected, true);
        DataMigrationEntity.SetRange("Table ID", Database::Vendor);
        if DataMigrationEntity.FindFirst() then
            EntitiesToMigrateMessage += StrSubstNo(VendorsTxt, DataMigrationEntity."No. of Records");

        DataMigrationEntity.SetRange("Table ID", Database::Customer);
        if DataMigrationEntity.FindFirst() then
            EntitiesToMigrateMessage += StrSubstNo(CustomersTxt, DataMigrationEntity."No. of Records");

        DataMigrationEntity.SetRange("Table ID", Database::"G/L Account");
        if DataMigrationEntity.FindFirst() then
            EntitiesToMigrateMessage += StrSubstNo(GLAccountsTxt, DataMigrationEntity."No. of Records");

        DataMigrationEntity.SetRange("Table ID", Database::Item);
        if DataMigrationEntity.FindFirst() then
            EntitiesToMigrateMessage += StrSubstNo(ItemsTxt, DataMigrationEntity."No. of Records");

        Session.LogMessage('00001OA', EntitiesToMigrateMessage, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', SLHelperFunctions.GetTelemetryCategory());
    end;

    internal procedure GetCurrentCodeUnitNumber(): Integer
    begin
        exit(Codeunit::"SL Wizard Integration");
    end;

    internal procedure GetDefaultSLHistoricalMigrationJobMaxAttempts(): Integer
    begin
        exit(10);
    end;

    internal procedure StartSLHistoricalJobMigrationAction(JobNotRanNotification: Notification)
    begin
        ScheduleSLHistoricalSnapshotMigration();
    end;

    internal procedure CanStartBackgroundJob(): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
        UserPermissions: Codeunit "User Permissions";
    begin
        if not UserPermissions.IsSuper(UserSecurityId()) then
            exit(false);

        if not TaskScheduler.CanCreateTask() then
            exit(false);

        if not JobQueueEntry.WritePermission then
            exit(false);

        exit(true);
    end;

    internal procedure ScheduleSLHistoricalSnapshotMigration()
    var
        SLConfiguration: Record "SL Migration Config";
        SLUpgradeSettings: Record "SL Upgrade Settings";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        HybridSLManagement: Codeunit "SL Hybrid Management";
        FailoverToSession: Boolean;
        IsHandled: Boolean;
        QueueCategory: Code[10];
        TimeoutDuration: Duration;
        OverrideTimeoutDuration: Duration;
        MaxAttempts: Integer;
        OverrideMaxAttempts: Integer;
        SessionID: Integer;
    begin
        TimeoutDuration := HybridSLManagement.GetDefaultJobTimeout();
        MaxAttempts := GetDefaultSLHistoricalMigrationJobMaxAttempts();
        QueueCategory := HybridCloudManagement.GetJobQueueCategory();

        OnBeforeCreateSLHistoricalMigrationJob(IsHandled, OverrideTimeoutDuration, OverrideMaxAttempts);
        if IsHandled then begin
            TimeoutDuration := OverrideTimeoutDuration;
            MaxAttempts := OverrideMaxAttempts;
        end;

        FailoverToSession := not CanStartBackgroundJob();

        if not FailoverToSession then begin
            SendStartSnapshotResultMessage('', StrSubstNo(TelemetrySnapshotToBeScheduledMsg, 'Job Queue'), false, false);

            CreateAndScheduleBackgroundJob(Codeunit::"SL Populate Hist. Tables",
                    TimeoutDuration,
                    MaxAttempts,
                    QueueCategory,
                    SLSnapshotJobDescriptionTxt);

            SendStartSnapshotResultMessage('', StrSubstNo(TelemetrySnapshotScheduledMsg, 'Job Queue'), false, true);
            if SLConfiguration.Get() then begin
                SLConfiguration."Historical Job Ran" := true;
                SLConfiguration.Modify();
            end;
        end;

        if FailoverToSession then begin
            SendStartSnapshotResultMessage('', StrSubstNo(TelemetrySnapshotToBeScheduledMsg, 'Session'), false, false);
            if Session.StartSession(SessionID, Codeunit::"SL Populate Hist. Tables", CompanyName(), SLUpgradeSettings, TimeoutDuration) then begin
                SendStartSnapshotResultMessage('', StrSubstNo(TelemetrySnapshotScheduledMsg, 'Session'), false, true);
                if SLConfiguration.Get() then begin
                    SLConfiguration."Historical Job Ran" := true;
                    SLConfiguration.Modify();
                end;
            end else begin
                SendStartSnapshotResultMessage('', TelemetrySnapshotFailedToStartSessionMsg, true, true);
                exit;
            end;
        end;
    end;

    internal procedure SendStartSnapshotResultMessage(TelemetryEventId: Text; MessageText: Text; IsError: Boolean; ShouldShowMessage: Boolean)
    begin
        if IsError then
            Session.LogMessage(TelemetryEventId, MessageText, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', SLHelperFunctions.GetTelemetryCategory())
        else
            Session.LogMessage(TelemetryEventId, MessageText, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', SLHelperFunctions.GetTelemetryCategory());

        if ShouldShowMessage and GuiAllowed() then
            Message(MessageText);
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCreateSLHistoricalMigrationJob(var IsHandled: Boolean; var TimeoutDuration: Duration; var MaxAttempts: Integer)
    begin
    end;

    internal procedure CreateAndScheduleBackgroundJob(ObjectIdToRun: Integer; TimeoutDuration: Duration; MaxAttempts: Integer; CategoryCode: Code[10]; Description: Text[250]): Guid
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueEntryBuffer: Record "Job Queue Entry Buffer";
    begin
        JobQueueEntry.Init();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := ObjectIdToRun;
        JobQueueEntry."Maximum No. of Attempts to Run" := MaxAttempts;
        JobQueueEntry."Job Queue Category Code" := CategoryCode;
        JobQueueEntry.Description := Description;
        JobQueueEntry."Job Timeout" := TimeoutDuration;
        Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry);

        JobQueueEntryBuffer.Init();
        JobQueueEntryBuffer.TransferFields(JobQueueEntry);
        JobQueueEntryBuffer."Job Queue Entry ID" := JobQueueEntry.SystemId;
        JobQueueEntryBuffer."Start Date/Time" := CurrentDateTime();
        JobQueueEntryBuffer.Insert();

        exit(JobQueueEntryBuffer.SystemId);
    end;
}
