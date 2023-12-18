namespace Microsoft.DataMigration.GP;

using System.Integration;
using System.Threading;
using Microsoft.DataMigration;
using System.Security.User;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Inventory.Item;

codeunit 4035 "Wizard Integration"
{
    var
        HelperFunctions: Codeunit "Helper Functions";
        DataMigratorDescTxt: Label 'Import from Dynamics GP Cloud';
        UnableToRegisterMigrationMsg: Label 'Unable to register the GP Cloud Migration.', Locked = true;
        UnableToUnRegisterMigrationMsg: Label 'Unable to unregister the GP Cloud Migration.', Locked = true;

    procedure RegisterGPDataMigrator(): Boolean
    var
        DataMigratorRegistration: Record "Data Migrator Registration";
    begin
        DataMigratorRegistration.Reset();
        DataMigratorRegistration.SetFilter("No.", '= %1', GetCurrentCodeUnitNumber());
        if not DataMigratorRegistration.FindSet() then
            if not DataMigratorRegistration.RegisterDataMigrator(GetCurrentCodeUnitNumber(), CopyStr(DataMigratorDescTxt, 1, 250)) then begin
                HelperFunctions.GetLastError();
                Session.LogMessage('0000B68', UnableToRegisterMigrationMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetTelemetryCategory());
                HelperFunctions.SetProcessesRunning(false);
                exit(false);
            end;

        exit(true);
    end;

    procedure UnRegisterGPDataMigrator()
    var
        DataMigratorRegistration: Record "Data Migrator Registration";
    begin
        DataMigratorRegistration.Reset();
        DataMigratorRegistration.SetFilter("No.", '= %1', GetCurrentCodeUnitNumber());
        if DataMigratorRegistration.FindSet() then
            if not DataMigratorRegistration.Delete() then
                Session.LogMessage('0000B69', UnableToUnRegisterMigrationMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetTelemetryCategory());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", 'OnApplySelectedData', '', true, true)]
    local procedure OnApplySelectedDataApplyGPData(var DataMigratorRegistration: Record "Data Migrator Registration"; var DataMigrationEntity: Record "Data Migration Entity"; var Handled: Boolean)
    begin
        if DataMigratorRegistration."No." <> GetCurrentCodeUnitNumber() then
            exit;

        SendTelemetryForSelectedEntities(DataMigrationEntity);
        Handled := true;
    end;

    // This is after OnMigrationCompleted. OnMigrationCompleted fires when opening the Data Migration Overview page so removed that subscriber
    [EventSubscriber(ObjectType::Codeunit, 1798, 'OnCreatePostMigrationData', '', true, true)]
    local procedure OnCreatePostMigrationDataSubscriber(var DataMigrationStatus: Record "Data Migration Status"; var DataCreationFailed: Boolean)
    var
        GPConfiguration: Record "GP Configuration";
        GPMigrationErrorHandler: Codeunit "GP Migration Error Handler";
        Flag: Boolean;
    begin
        if not (DataMigrationStatus."Migration Type" = HelperFunctions.GetMigrationTypeTxt()) then
            exit;

        if GPMigrationErrorHandler.GetErrorOccured() then
            exit;

        if not HelperFunctions.CreatePostMigrationData() then begin
            HelperFunctions.GetLastError();
            HelperFunctions.CheckAndLogErrors();
            HelperFunctions.SetProcessesRunning(false);
            DataCreationFailed := true;
            exit;
        end;

        if DataMigrationStatus.Status = DataMigrationStatus.Status::Completed then
            UnRegisterGPDataMigrator();

        Codeunit.Run(571);
        if GPConfiguration.Get() then
            if GPConfiguration."Updated GL Setup" then begin
                Flag := true;
                HelperFunctions.ResetAdjustforPaymentInGLSetup(Flag);
            end;
    end;

    // This is after OnMigrationCompleted. OnMigrationCompleted fires when opening the Data Migration Overview page so removed that subscriber
    [EventSubscriber(ObjectType::Codeunit, 1798, 'OnAfterMigrationFinished', '', true, true)]
    local procedure OnAfterMigrationFinishedSubscriber(var DataMigrationStatus: Record "Data Migration Status"; WasAborted: Boolean; StartTime: DateTime; Retry: Boolean)
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        HelperFunctions.PostGLTransactions();
        HelperFunctions.SetProcessesRunning(false);

        if GPCompanyAdditionalSettings.GetMigrateHistory() then
            ScheduleGPHistoricalSnapshotMigration();
    end;

    local procedure SendTelemetryForSelectedEntities(var DataMigrationEntity: Record "Data Migration Entity")
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

        Session.LogMessage('00001OA', EntitiesToMigrateMessage, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetTelemetryCategory());
    end;

    local procedure GetCurrentCodeUnitNumber(): Integer
    begin
        exit(codeunit::"Wizard Integration");
    end;

    local procedure GetDefaultGPHistoricalMigrationJobMaxAttempts(): Integer
    begin
        exit(10);
    end;

    procedure StartGPHistoricalJobMigrationAction(JobNotRanNotification: Notification)
    begin
        ScheduleGPHistoricalSnapshotMigration();
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

    procedure ScheduleGPHistoricalSnapshotMigration()
    var
        GPConfiguration: Record "GP Configuration";
        GPUpgradeSettings: Record "GP Upgrade Settings";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        HybridGPManagement: Codeunit "Hybrid GP Management";
        TimeoutDuration: Duration;
        MaxAttempts: Integer;
        QueueCategory: Code[10];
        IsHandled: Boolean;
        OverrideTimeoutDuration: Duration;
        OverrideMaxAttempts: Integer;
        SessionId: Integer;
        FailoverToSession: Boolean;
    begin
        TimeoutDuration := HybridGPManagement.GetDefaultJobTimeout();
        MaxAttempts := GetDefaultGPHistoricalMigrationJobMaxAttempts();
        QueueCategory := HybridCloudManagement.GetJobQueueCategory();

        OnBeforeCreateGPHistoricalMigrationJob(IsHandled, OverrideTimeoutDuration, OverrideMaxAttempts);
        if IsHandled then begin
            TimeoutDuration := OverrideTimeoutDuration;
            MaxAttempts := OverrideMaxAttempts;
        end;

        FailoverToSession := not CanStartBackgroundJob();

        if not FailoverToSession then begin
            SendStartSnapshotResultMessage('', StrSubstNo(TelemetrySnapshotToBeScheduledMsg, 'Job Queue'), false, false);

            CreateAndScheduleBackgroundJob(Codeunit::"GP Populate Hist. Tables",
                    TimeoutDuration,
                    MaxAttempts,
                    QueueCategory,
                    GPSnapshotJobDescriptionTxt);

            SendStartSnapshotResultMessage('', StrSubstNo(TelemetrySnapshotScheduledMsg, 'Job Queue'), false, true);
            if GPConfiguration.Get() then begin
                GPConfiguration."Historical Job Ran" := true;
                GPConfiguration.Modify();
            end;
        end;

        if FailoverToSession then begin
            SendStartSnapshotResultMessage('', StrSubstNo(TelemetrySnapshotToBeScheduledMsg, 'Session'), false, false);
            if Session.StartSession(SessionId, Codeunit::"GP Populate Hist. Tables", CompanyName(), GPUpgradeSettings, TimeoutDuration) then begin
                SendStartSnapshotResultMessage('', StrSubstNo(TelemetrySnapshotScheduledMsg, 'Session'), false, true);
                if GPConfiguration.Get() then begin
                    GPConfiguration."Historical Job Ran" := true;
                    GPConfiguration.Modify();
                end;
            end else begin
                SendStartSnapshotResultMessage('', TelemetrySnapshotFailedToStartSessionMsg, true, true);
                exit;
            end;
        end;
    end;

    local procedure SendStartSnapshotResultMessage(TelemetryEventId: Text; MessageText: Text; IsError: Boolean; ShouldShowMessage: Boolean)
    begin
        if IsError then
            Session.LogMessage(TelemetryEventId, MessageText, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetTelemetryCategory())
        else
            Session.LogMessage(TelemetryEventId, MessageText, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetTelemetryCategory());

        if ShouldShowMessage and GuiAllowed() then
            Message(MessageText);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateGPHistoricalMigrationJob(var IsHandled: Boolean; var TimeoutDuration: Duration; var MaxAttempts: Integer)
    begin
    end;

    procedure CreateAndScheduleBackgroundJob(ObjectIdToRun: Integer; TimeoutDuration: Duration; MaxAttempts: Integer; CategoryCode: Code[10]; Description: Text[250]): Guid
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

    var
        GPSnapshotJobDescriptionTxt: Label 'Migrate GP Historical Snapshot';
        TelemetrySnapshotToBeScheduledMsg: Label 'GP Historical Snapshot is about to be scheduled. Mode: %1', Locked = true;
        TelemetrySnapshotScheduledMsg: Label 'GP Historical Snapshot is now scheduled. Mode: %1', Locked = true;
        TelemetrySnapshotFailedToStartSessionMsg: Label 'GP Historical Snapshot could not start a new Session.', Locked = true;
}