// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using System.Integration;
using Microsoft.DataMigration;
using System.Threading;
using System.Security.User;
using System.Environment;
using Microsoft.Finance.FinancialReports;

codeunit 42005 "SL Wizard Integration"
{
    Access = Internal;

    var
        SLHelperFunctions: Codeunit "SL Helper Functions";
        DataMigratorDescTxt: Label 'Import from Dynamics SL Cloud';
        ThatsItTxt: Label 'To check the status of the data migration, go to the %1 page.', Comment = '%1=Page Name';
        TelemetrySnapshotScheduledMsg: Label 'SL Historical Snapshot is now scheduled. Mode: %1', Locked = true;
        TelemetrySnapshotToBeScheduledMsg: Label 'SL Historical Snapshot is about to be scheduled. Mode: %1', Locked = true;
        TelemetrySnapshotFailedToStartSessionMsg: Label 'SL Historical Snapshot could not start a new Session.', Locked = true;
        SLSnapshotJobDescriptionTxt: Label 'Migrate SL Historical Snapshot';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", OnShowThatsItMessage, '', true, true)]
    local procedure OnShowThatsItMessageShowSLThatsItMessage(var DataMigratorRegistration: Record "Data Migrator Registration"; var Message: Text)
    var
        DataMigrationOverview: Page "Data Migration Overview";
    begin
        if DataMigratorRegistration."No." <> GetCurrentCodeUnitNumber() then
            exit;

        Message := StrSubstNo(ThatsItTxt, DataMigrationOverview.Caption);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Facade", OnEnableTogglingDataMigrationOverviewPage, '', true, true)]
    local procedure OnEnableTogglingDataMigrationOverviewPage(var DataMigratorRegistration: Record "Data Migrator Registration"; var EnableTogglingOverviewPage: Boolean)
    begin
        if DataMigratorRegistration."No." <> GetCurrentCodeUnitNumber() then
            exit;

        EnableTogglingOverviewPage := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Mgt.", OnAfterMigrationFinished, '', true, true)]
    local procedure OnAfterMigrationFinishedSubscriber(var DataMigrationStatus: Record "Data Migration Status"; WasAborted: Boolean; StartTime: DateTime; Retry: Boolean)
    var
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
    begin
        if not (DataMigrationStatus."Migration Type" = SLHelperFunctions.GetMigrationTypeTxt()) then
            exit;
        SLHelperFunctions.PostGLTransactions();
        SLHelperFunctions.SetProcessesRunning(false);

        if SLCompanyAdditionalSettings.GetMigrateHistory() then
            ScheduleSLHistoricalSnapshotMigration();
    end;

    internal procedure ScheduleSLHistoricalSnapshotMigration()
    var
        SLConfiguration: Record "SL Migration Config";
        SLUpgradeSettings: Record "SL Upgrade Settings";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        HybridSLManagement: Codeunit "SL Hybrid Management";
        IsHandled: Boolean;
        FailoverToSession: Boolean;
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

            CreateAndScheduleBackgroundJob(Codeunit::SLPopulateHistTables,
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
            if Session.StartSession(SessionID, Codeunit::SLPopulateHistTables, CompanyName(), SLUpgradeSettings, TimeoutDuration) then begin
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Mgt.", OnCreatePostMigrationData, '', true, true)]
    local procedure OnCreatePostMigrationDataSubscriber(var DataMigrationStatus: Record "Data Migration Status"; var DataCreationFailed: Boolean)
    var
        MigrationSLConfig: Record "SL Migration Config";
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
        if MigrationSLConfig.Get() then
            if MigrationSLConfig."Updated GL Setup" then begin
                Flag := true;
                SLHelperFunctions.ResetAdjustforPaymentInGLSetup(Flag);
            end;
    end;

    internal procedure GetDefaultSLHistoricalMigrationJobMaxAttempts(): Integer
    begin
        exit(10);
    end;

    internal procedure RegisterSLDataMigrator(): Boolean
    var
        DataMigratorRegistration: Record "Data Migrator Registration";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if not EnvironmentInformation.IsSaaS() then
            exit;

        DataMigratorRegistration.Reset();
        DataMigratorRegistration.SetFilter("No.", '= %1', GetCurrentCodeUnitNumber());
        if not DataMigratorRegistration.FindSet() then
            if not DataMigratorRegistration.RegisterDataMigrator(GetCurrentCodeUnitNumber(), CopyStr(DataMigratorDescTxt, 1, 250)) then begin
                SLHelperFunctions.SetProcessesRunning(false);
                exit(false);
            end;

        exit(true);
    end;

    internal procedure UnRegisterSLDataMigrator()
    var
        DataMigratorRegistration: Record "Data Migrator Registration";
        EnvironmentInformation: Codeunit "Environment Information";
    begin

        if not EnvironmentInformation.IsSaaS() then
            exit;

        DataMigratorRegistration.Reset();
        DataMigratorRegistration.SetFilter("No.", '= %1', GetCurrentCodeUnitNumber());
        if DataMigratorRegistration.FindSet() then
            DataMigratorRegistration.Delete();
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

    internal procedure GetCurrentCodeUnitNumber(): Integer
    begin
        exit(Codeunit::"SL Wizard Integration");
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

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCreateSLHistoricalMigrationJob(var IsHandled: Boolean; var TimeoutDuration: Duration; var MaxAttempts: Integer)
    begin
    end;
}
