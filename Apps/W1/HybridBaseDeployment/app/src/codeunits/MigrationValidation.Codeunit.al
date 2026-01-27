namespace Microsoft.DataMigration;

using System.Security.User;
using System.Threading;
using System.Integration;
using System.Environment;

codeunit 40032 "Migration Validation"
{
    trigger OnRun()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        if not IntelligentCloudSetup.Get() then
            exit;

        StartValidation(IntelligentCloudSetup."Product ID", false);
    end;

    /// <summary>
    /// Start migration validation for the current company
    /// </summary>
    /// <param name="MigrationType">The type of migration</param>
    /// <param name="RunOnlyAutomatic">Should only run validators that are set to run automatically</param>
    procedure StartValidation(MigrationType: Text[250]; RunOnlyAutomatic: Boolean)
    var
        MigrationValidatorRegistry: Record "Migration Validator Registry";
        CloudMigrationWarning: Record "Cloud Migration Warning";
    begin
        CommitAfterXValidatedRecordCount := GetDefaultCommitAfterXValidatedRecordCount();
        OnBeforeStartValidation(MigrationType, CommitAfterXValidatedRecordCount);

        MigrationValidatorRegistry.SetRange("Migration Type", MigrationType);

        if RunOnlyAutomatic then
            MigrationValidatorRegistry.SetRange(Automatic, true);

        if not MigrationValidatorRegistry.FindSet() then
            exit;

        repeat
            Commit();
            if not Codeunit.Run(MigrationValidatorRegistry."Codeunit Id") then begin
                Clear(CloudMigrationWarning);
                CloudMigrationWarning."Entry No." := 0;
                CloudMigrationWarning."Warning Type" := CloudMigrationWarning."Warning Type"::"Migration Validator";
                CloudMigrationWarning.Message := CopyStr(StrSubstNo(CloudMigrationWarningErr, MigrationValidatorRegistry."Validator Code", GetLastErrorText()), 1, MaxStrLen(CloudMigrationWarning.Message));
                CloudMigrationWarning.Insert();
            end;
        until MigrationValidatorRegistry.Next() = 0;

        SetCompanyValidated();
        Commit();
        OnMigrationValidated(MigrationType, CompanyName());
    end;

    /// <summary>
    /// Report that the Company has had validation tests run.
    /// </summary>
    procedure SetCompanyValidated()
    var
        HybridCompanyStatus: Record "Hybrid Company Status";
    begin
        if HybridCompanyStatus.Get(CompanyName()) then
            if not HybridCompanyStatus.Validated then begin
                HybridCompanyStatus.Validate(Validated, true);
                HybridCompanyStatus.Modify(true);
            end;
    end;

    /// <summary>
    /// Schedule validation for a Company.
    /// </summary>
    /// <param name="Company">The Company context to schedule validation testing.</param>
    /// <param name="ScheduledEntryNumber">The index number for this scheduled validation. Used to calculate the start time for the scheduled job.</param>
    procedure ScheduleCompanyValidation(Company: Text; ScheduledEntryNumber: Integer)
    var
        TimeoutDuration: Duration;
        MaxAttempts: Integer;
        TimeBetweenScheduledJobs: Integer;
        QueueCategory: Code[10];
        IsHandled: Boolean;
        OverrideTimeoutDuration: Duration;
        OverrideMaxAttempts: Integer;
        OverrideTimeBetweenScheduledJobs: Integer;
        StartDateTime: DateTime;
        FailoverToSession: Boolean;
        SessionId: Integer;
    begin
        TimeoutDuration := GetDefaultJobTimeout();
        MaxAttempts := GetDefaultJobMaxAttempts();
        TimeBetweenScheduledJobs := GetDefaultTimeBetweenScheduledJobs();
        OverrideTimeoutDuration := TimeoutDuration;
        OverrideMaxAttempts := MaxAttempts;
        OverrideTimeBetweenScheduledJobs := TimeBetweenScheduledJobs;
        QueueCategory := GetJobQueueCategory();

        OnBeforeCreateMigrationValidationJob(IsHandled, OverrideTimeoutDuration, OverrideMaxAttempts, OverrideTimeBetweenScheduledJobs);
        if IsHandled then begin
            TimeoutDuration := OverrideTimeoutDuration;
            MaxAttempts := OverrideMaxAttempts;
            TimeBetweenScheduledJobs := OverrideTimeBetweenScheduledJobs;
        end;

        FailoverToSession := not CanStartBackgroundJob();

        if not FailoverToSession then begin
            SendStartValidationResultMessage('', StrSubstNo(TelemetryValidationToBeScheduledMsg, JobQueueLbl), false, false);

            StartDateTime := CurrentDateTime();
            if ScheduledEntryNumber > 1 then
                StartDateTime += (TimeBetweenScheduledJobs * (ScheduledEntryNumber - 1));

            CreateAndScheduleBackgroundJob(Company,
                    Codeunit::"Migration Validation",
                    TimeoutDuration,
                    MaxAttempts,
                    QueueCategory,
                    MigrationValidationJobDescriptionTxt,
                    StartDateTime);

            SendStartValidationResultMessage('', StrSubstNo(TelemetryValidationScheduledMsg, JobQueueLbl), false, true);
        end;

        if FailoverToSession then begin
            SendStartValidationResultMessage('', StrSubstNo(TelemetryValidationToBeScheduledMsg, SessionLbl), false, false);

            if Session.StartSession(SessionId, Codeunit::"Migration Validation", Company) then
                SendStartValidationResultMessage('', StrSubstNo(TelemetryValidationScheduledMsg, SessionLbl), false, true)
            else
                SendStartValidationResultMessage('', TelemetryValidationFailedToStartSessionMsg, true, true);
        end;
    end;

    /// <summary>
    /// Delete the past validation errors and other entries for the current Company.
    /// </summary>
    /// <param name="Company">The Company that needs the migration validation errors deleted.</param>
    procedure DeleteMigrationValidationEntriesForCompany()
    begin
        DeleteMigrationValidationEntriesForCompany(CompanyName());
    end;

    /// <summary>
    /// Delete the past validation errors and other entries for the specified Company.
    /// </summary>
    /// <param name="Company">The Company that needs the migration validation errors deleted.</param>
    procedure DeleteMigrationValidationEntriesForCompany(Company: Text)
    var
        MigrationValidationError: Record "Migration Validation Error";
        ValidationProgress: Record "Validation Progress";
        HybridCompanyStatus: Record "Hybrid Company Status";
    begin
        MigrationValidationError.SetRange("Company Name", Company);
        if not MigrationValidationError.IsEmpty() then
            MigrationValidationError.DeleteAll(true);

        ValidationProgress.SetRange("Company Name", Company);
        if not ValidationProgress.IsEmpty() then
            ValidationProgress.DeleteAll(true);

        if not HybridCompanyStatus.Get(Company) then
            exit;

        HybridCompanyStatus.Validate(Validated, false);
        HybridCompanyStatus.Modify(true);
    end;

    procedure PrepareValidation()
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        IntelligentCloudSetup.Get();

        OnPrepareValidation(IntelligentCloudSetup."Product ID");
    end;

    internal procedure GetCommitAfterXValidatedRecordCount(): Integer
    begin
        exit(CommitAfterXValidatedRecordCount);
    end;

    local procedure CanStartBackgroundJob(): Boolean
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

    local procedure SendStartValidationResultMessage(TelemetryEventId: Text; MessageText: Text; IsError: Boolean; ShouldShowMessage: Boolean)
    begin
        if IsError then
            Session.LogMessage(TelemetryEventId, MessageText, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CloudMigrationTok)
        else
            Session.LogMessage(TelemetryEventId, MessageText, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CloudMigrationTok);

        if ShouldShowMessage and GuiAllowed() then
            Message(MessageText);
    end;

    local procedure CreateAndScheduleBackgroundJob(Company: Text; ObjectIdToRun: Integer; TimeoutDuration: Duration; MaxAttempts: Integer; CategoryCode: Code[10]; Description: Text[250]; StartDateTime: DateTime): Guid
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueEntryBuffer: Record "Job Queue Entry Buffer";
    begin
        JobQueueEntry.ChangeCompany(Company);
        JobQueueEntryBuffer.ChangeCompany(Company);

        JobQueueEntry.Init();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := ObjectIdToRun;
        JobQueueEntry."Maximum No. of Attempts to Run" := MaxAttempts;
        JobQueueEntry."Job Queue Category Code" := CategoryCode;
        JobQueueEntry.Description := Description;
        JobQueueEntry."Job Timeout" := TimeoutDuration;
        JobQueueEntry."Earliest Start Date/Time" := StartDateTime;
        Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry);

        JobQueueEntryBuffer.Init();
        JobQueueEntryBuffer.TransferFields(JobQueueEntry);
        JobQueueEntryBuffer."Job Queue Entry ID" := JobQueueEntry.SystemId;
        JobQueueEntryBuffer."Start Date/Time" := StartDateTime;
        JobQueueEntryBuffer.Insert();

        exit(JobQueueEntryBuffer.SystemId);
    end;

    local procedure GetDefaultJobMaxAttempts(): Integer
    begin
        exit(10);
    end;

    local procedure GetDefaultJobTimeout(): Duration
    begin
        exit(48 * 60 * 60 * 1000); // 48 hours
    end;

    internal procedure GetDefaultTimeBetweenScheduledJobs(): Integer
    begin
        exit(60 * 1000 * 2); // 2 minutes
    end;

    local procedure GetJobQueueCategory(): Code[10]
    begin
        exit(JobQueueCategoryTok);
    end;

    local procedure GetDefaultCommitAfterXValidatedRecordCount(): Integer
    begin
        exit(500);
    end;

    var
        CloudMigrationWarningErr: Label '%1 - %2', Comment = '%1 = Validator Code, %2 = Error message';
        TelemetryValidationToBeScheduledMsg: Label 'Migration validation is about to be scheduled. Mode: %1', Comment = '%1 is the mode.', Locked = true;
        TelemetryValidationScheduledMsg: Label 'Migration validation is now scheduled. Mode: %1', Comment = '%1 is the mode.', Locked = true;
        TelemetryValidationFailedToStartSessionMsg: Label 'Migration validation could not start a new Session.', Locked = true;
        MigrationValidationJobDescriptionTxt: Label 'Migration Validation';
        JobQueueLbl: Label 'Job Queue', Locked = true;
        SessionLbl: Label 'Session', Locked = true;
        JobQueueCategoryTok: Label 'VALIDATION', Locked = true;
        CloudMigrationTok: Label 'CloudMigration', Locked = true;
        CommitAfterXValidatedRecordCount: Integer;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Mgt.", OnBeforeMigrationStarted, '', false, false)]
    local procedure BeforeMigrationStarted(var DataMigrationStatus: Record "Data Migration Status"; Retry: Boolean)
    begin
        DeleteMigrationValidationEntriesForCompany();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company", OnAfterDeleteEvent, '', false, false)]
    local procedure CleanupAfterCompanyDelete(var Rec: Record Company; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        DeleteMigrationValidationEntriesForCompany(Rec.Name);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Mgt.", OnValidateMigration, '', false, false)]
    local procedure StartMigrationValidation(var DataCreationFailed: Boolean)
    begin
        StartMigrationValidationImp(DataCreationFailed);
    end;

    internal procedure StartMigrationValidationImp(var DataCreationFailed: Boolean)
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        MigrationValidationError: Record "Migration Validation Error";
        MigrationValidation: Codeunit "Migration Validation";
    begin
        if DataCreationFailed then
            exit;

        IntelligentCloudSetup.Get();
        MigrationValidation.StartValidation(IntelligentCloudSetup."Product ID", true);

        MigrationValidationError.SetRange("Migration Type", IntelligentCloudSetup."Product ID");
        MigrationValidationError.SetRange("Company Name", CompanyName());
        MigrationValidationError.SetRange("Is Warning", false);
        MigrationValidationError.SetRange("Errors should fail migration", true);
        if not MigrationValidationError.IsEmpty() then
            DataCreationFailed := true;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPrepareValidation(ProductID: Text[250])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeStartValidation(MigrationType: Text[250]; var OverrideCommitAfterXValidatedRecordCount: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateMigrationValidationJob(var IsHandled: Boolean; var TimeoutDuration: Duration; var MaxAttempts: Integer; var TimeBetweenScheduledJobs: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnMigrationValidated(MigrationType: Text[250]; Company: Text)
    begin
    end;
}