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
    [EventSubscriber(ObjectType::Codeunit, 1798, 'OnAfterMigrationFinished', '', true, true)]
    local procedure OnAfterMigrationFinishedSubscriber(var DataMigrationStatus: Record "Data Migration Status"; WasAborted: Boolean; StartTime: DateTime; Retry: Boolean)
    var
        GPConfiguration: Record "GP Configuration";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        Flag: Boolean;
    begin
        if not (DataMigrationStatus."Migration Type" = HelperFunctions.GetMigrationTypeTxt()) then
            exit;

        if not HelperFunctions.CreatePostMigrationData() then begin
            HelperFunctions.GetLastError();
            HelperFunctions.SetProcessesRunning(false);
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

    local procedure GetDefaultGPHistoricalMigrationJobTimeoutDuration(): Integer
    begin
        exit(48 * 60 * 60 * 1000); // 48 hours
    end;

    local procedure GetDefaultGPHistoricalMigrationJobMaxAttempts(): Integer
    begin
        exit(10);
    end;

    procedure StartGPHistoricalJobMigrationAction(JobNotRanNotification: Notification)
    begin
        ScheduleGPHistoricalSnapshotMigration();
    end;

    procedure ScheduleGPHistoricalSnapshotMigration()
    var
        GPConfiguration: Record "GP Configuration";
        JobQueueEntry: Record "Job Queue Entry";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        UserPermissions: Codeunit "User Permissions";
        TimeoutDuration: Duration;
        MaxAttempts: Integer;
        QueueCategory: Code[10];
        IsHandled: Boolean;
        OverrideTimeoutDuration: Duration;
        OverrideMaxAttempts: Integer;
    begin
        if not UserPermissions.IsSuper(UserSecurityId()) then
            exit;

        if not TaskScheduler.CanCreateTask() then
            exit;

        if not JobQueueEntry.WritePermission then
            exit;

        TimeoutDuration := GetDefaultGPHistoricalMigrationJobTimeoutDuration();
        MaxAttempts := GetDefaultGPHistoricalMigrationJobMaxAttempts();

        OnBeforeCreateGPHistoricalMigrationJob(IsHandled, OverrideTimeoutDuration, OverrideMaxAttempts);
        if IsHandled then begin
            TimeoutDuration := OverrideTimeoutDuration;
            MaxAttempts := OverrideMaxAttempts;
        end;

        QueueCategory := HybridCloudManagement.GetJobQueueCategory();

        CreateAndScheduleBackgroundJob(Codeunit::"GP Populate Hist. Tables",
                TimeoutDuration,
                MaxAttempts,
                QueueCategory,
                GPSnapshotJobDescriptionTxt);

        if GPConfiguration.Get() then begin
            GPConfiguration."Historical Job Ran" := true;
            GPConfiguration.Modify();
        end;
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
}