namespace Microsoft.DataMigration;

using System.Reflection;
using System.Security.User;
using System.Threading;

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
        OverrideCommitAfterXValidatedRecordCount := CommitAfterXValidatedRecordCount;

        OnBeforeStartValidation(MigrationType, OverrideCommitAfterXValidatedRecordCount);
        if OverrideCommitAfterXValidatedRecordCount > 0 then
            CommitAfterXValidatedRecordCount := OverrideCommitAfterXValidatedRecordCount;

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
    /// Report that the source record has been validated.
    /// </summary>
    /// <param name="SourceValidatorCode">Validator used for testing this source record</param>
    /// <param name="SourceRecRef">Source record that was validated</param>
    procedure SetSourceRowValidated(SourceValidatorCode: Code[20]; SourceRecRef: RecordRef)
    var
        ValidationProgress: Record "Validation Progress";
        SourceTableId: Integer;
        ValidatedRowSystemId: Guid;
    begin
        SourceTableId := SourceRecRef.Number();
        ValidatedRowSystemId := SourceRecRef.Field(SourceRecRef.SystemIdNo()).Value;

        if not ValidationProgress.Get(CompanyName(), SourceValidatorCode, SourceTableId, ValidatedRowSystemId) then begin
            ValidationProgress.Validate("Company Name", CompanyName());
            ValidationProgress.Validate("Validator Code", SourceValidatorCode);
            ValidationProgress.Validate("Source Table Id", SourceTableId);
            ValidationProgress.Validate("Validated Row System Id", ValidatedRowSystemId);
            ValidationProgress.Insert(true);

            CurrentValidatedRecordCount += 1;
            if CurrentValidatedRecordCount >= CommitAfterXValidatedRecordCount then begin
                Commit();
                CurrentValidatedRecordCount := 0;
            end;
        end;
    end;

    /// <summary>
    /// Check to see if a source record has been validated.
    /// </summary>
    /// <param name="SourceValidatorCode">Validator used for testing this source record</param>
    /// <param name="SourceRecRef">The source record to check if it has already been validated.</param>
    /// <returns></returns>
    procedure IsSourceRowValidated(SourceValidatorCode: Code[20]; SourceRecRef: RecordRef): Boolean
    var
        ValidationProgress: Record "Validation Progress";
        SourceTableId: Integer;
        ValidatedRowSystemId: Guid;
    begin
        SourceTableId := SourceRecRef.Number();
        ValidatedRowSystemId := SourceRecRef.Field(SourceRecRef.SystemIdNo()).Value;

        ValidationProgress.SetRange("Company Name", CompanyName());
        ValidationProgress.SetRange("Validator Code", SourceValidatorCode);
        ValidationProgress.SetRange("Source Table Id", SourceTableId);
        ValidationProgress.SetRange("Validated Row System Id", ValidatedRowSystemId);
        exit(not ValidationProgress.IsEmpty());
    end;

    /// <summary>
    /// Set the context for this series of migration validation tests.
    /// </summary>
    /// <param name="EntryValidatorCode">The validator executing the validation tests.</param>
    /// <param name="EntryEntityType">The entity type being tested.</param>
    /// <param name="EntryContext">The entity Id context.</param>
    procedure SetContext(EntryValidatorCode: Code[20]; EntryEntityType: Text[50]; EntryContext: Text[250])
    var
        MigrationValidatorRegistry: Record "Migration Validator Registry";
    begin
        ContextIsSet := false;

        EntityType := EntryEntityType;
        Context := EntryContext;

        if ValidatorCode <> EntryValidatorCode then begin
            ValidatorCode := EntryValidatorCode;

            MigrationValidatorRegistry.Get(ValidatorCode);
            ContextMigrationType := MigrationValidatorRegistry."Migration Type";
        end;

        if ContextMigrationType = '' then
            exit;

        if EntityType = '' then
            exit;

        if Context = '' then
            exit;

        ContextIsSet := true;
    end;

    /// <summary>
    /// Validate that the actual value matches the expected value.
    /// </summary>
    /// <param name="Expected">The expected value for the test.</param>
    /// <param name="Actual">The actual value being tested.</param>
    /// <param name="TestDescription">Description of the test.</param>
    procedure ValidateAreEqual(TestCode: Code[30]; Expected: Variant; Actual: Variant; TestDescription: Text[250]): Boolean
    begin
        exit(ValidateAreEqual(TestCode, Expected, Actual, TestDescription, false));
    end;

    /// <summary>
    /// Validate that the actual value matches the expected value.
    /// </summary>
    /// <param name="Expected">The expected value for the test.</param>
    /// <param name="Actual">The actual value being tested.</param>
    /// <param name="TestDescription">Description of the test.</param>
    /// <param name="ShouldBeWarning">Should the test be handled as a warning.</param>
    procedure ValidateAreEqual(TestCode: Code[30]; Expected: Variant; Actual: Variant; TestDescription: Text[250]; ShouldBeWarning: Boolean): Boolean
    begin
        exit(ValidateAreEqual(TestCode, Expected, Actual, TestDescription, ShouldBeWarning, false));
    end;

    /// <summary>
    /// Validate that the actual value matches the expected value.
    /// </summary>
    /// <param name="Expected">The expected value for the test.</param>
    /// <param name="Actual">The actual value being tested.</param>
    /// <param name="TestDescription">Description of the test.</param>
    /// <param name="ShouldBeWarning">Should the test be handled as a warning.</param>
    /// <param name="ShouldRedact">Should the Expected and Actual values be redacted when logged as a validation error.</param>
    procedure ValidateAreEqual(TestCode: Code[30]; Expected: Variant; Actual: Variant; TestDescription: Text[250]; ShouldBeWarning: Boolean; ShouldRedact: Boolean): Boolean
    begin
        AssertContextIsSet();

        if Equal(Expected, Actual) then
            exit(true);

        CreateValidationError(TestCode, Expected, Actual, TestDescription, ShouldBeWarning, ShouldRedact);
    end;

    /// <summary>
    /// Validate that a record exists.
    /// </summary>
    /// <param name="GetReturnValue">Return value of the Get() call on the record being validated.</param>
    /// <param name="TestDescription">Description of the test.</param>
    procedure ValidateRecordExists(TestCode: Code[30]; GetReturnValue: Boolean; TestDescription: Text[250]): Boolean
    begin
        AssertContextIsSet();

        if GetReturnValue then
            exit(true);

        CreateValidationError(TestCode, MissingExpectedLbl, MissingActualLbl, TestDescription, false, false);
    end;

    /// <summary>
    /// Validate that a record exists.
    /// </summary>
    /// <param name="GetReturnValue">Return value of the Get() call on the record being validated.</param>
    /// <param name="TestDescription">Description of the test.</param>
    /// <param name="ShouldBeWarning">Should the test be handled as a warning.</param>
    procedure ValidateRecordExists(TestCode: Code[30]; GetReturnValue: Boolean; TestDescription: Text[250]; ShouldBeWarning: Boolean): Boolean
    begin
        AssertContextIsSet();

        if GetReturnValue then
            exit(true);

        CreateValidationError(TestCode, MissingExpectedLbl, MissingActualLbl, TestDescription, ShouldBeWarning, false);
    end;

    local procedure CreateValidationError(TestCode: Code[30]; Expected: Variant; Actual: Variant; TestDescription: Text[250]; ShouldBeWarning: Boolean; ShouldRedact: Boolean)
    var
        MigrationValidationError: Record "Migration Validation Error";
        MigrationValidationTest: record "Migration Validation Test";
        OverrideIsWarning: Boolean;
        OverrideShouldRedact: Boolean;
        ActualIsWarning: Boolean;
        ActualShouldRedact: Boolean;
    begin
        MigrationValidationTest.SetRange(Code, TestCode);
        MigrationValidationTest.SetRange("Validator Code", ValidatorCode);
        MigrationValidationTest.SetRange(Ignore, true);
        if not MigrationValidationTest.IsEmpty() then
            exit;

        ActualIsWarning := ShouldBeWarning;
        OverrideIsWarning := ShouldBeWarning;
        ActualShouldRedact := ShouldRedact;
        OverrideShouldRedact := ShouldRedact;

        OnTestOverrideWarning(ValidatorCode, TestCode, Context, ShouldBeWarning, OverrideIsWarning);
        ActualIsWarning := OverrideIsWarning;

        OnTestOverrideShouldRedact(ValidatorCode, TestCode, Context, ShouldRedact, OverrideShouldRedact);
        ActualShouldRedact := OverrideShouldRedact;

        if ActualShouldRedact then begin
            Expected := RedactedLbl;
            Actual := RedactedLbl;
        end;

        MigrationValidationError."Entry No." := 0;
        MigrationValidationError.Validate("Company Name", CompanyName());
        MigrationValidationError.Validate("Test Code", TestCode);
        MigrationValidationError.Validate("Validator Code", ValidatorCode);
        MigrationValidationError.Validate("Migration Type", ContextMigrationType);
        MigrationValidationError.Validate("Entity Type", EntityType);
        MigrationValidationError.Validate(Context, Context);
        MigrationValidationError.Validate("Test Description", TestDescription);
        MigrationValidationError.Validate(Expected, Expected);
        MigrationValidationError.Validate(Actual, Actual);
        MigrationValidationError.Validate("Is Warning", ActualIsWarning);
        MigrationValidationError.Insert(true);
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
    local procedure Equal(Left: Variant; Right: Variant): Boolean
    begin
        if IsNumber(Left) and IsNumber(Right) then
            exit(EqualNumbers(Left, Right));

        if Left.IsDotNet or Right.IsDotNet then
            exit((Format(Left, 0, 2) = Format(Right, 0, 2)));

        exit((TypeOf(Left) = TypeOf(Right)) and (Format(Left, 0, 2) = Format(Right, 0, 2)))
    end;

    local procedure EqualNumbers(Left: Decimal; Right: Decimal): Boolean
    begin
        exit(Left = Right)
    end;

    local procedure IsNumber(Value: Variant): Boolean
    begin
        exit(Value.IsDecimal or Value.IsInteger or Value.IsChar)
    end;

    local procedure TypeOf(Value: Variant): Integer
    var
        "Field": Record "Field";
    begin
        case true of
            Value.IsBoolean:
                exit(Field.Type::Boolean);
            Value.IsOption or Value.IsInteger or Value.IsByte:
                exit(Field.Type::Integer);
            Value.IsBigInteger:
                exit(Field.Type::BigInteger);
            Value.IsDecimal:
                exit(Field.Type::Decimal);
            Value.IsText or Value.IsCode or Value.IsChar or Value.IsTextConstant:
                exit(Field.Type::Text);
            Value.IsDate:
                exit(Field.Type::Date);
            Value.IsTime:
                exit(Field.Type::Time);
            Value.IsDuration:
                exit(Field.Type::Duration);
            Value.IsDateTime:
                exit(Field.Type::DateTime);
            Value.IsDateFormula:
                exit(Field.Type::DateFormula);
            Value.IsGuid:
                exit(Field.Type::GUID);
            Value.IsRecordId:
                exit(Field.Type::RecordID);
            else
                Error(UnsupportedTypeErr, UnsupportedTypeName(Value))
        end
    end;

    local procedure UnsupportedTypeName(Value: Variant): Text
    begin
        case true of
            Value.IsRecord:
                exit('Record');
            Value.IsRecordRef:
                exit('RecordRef');
            Value.IsFieldRef:
                exit('FieldRef');
            Value.IsCodeunit:
                exit('Codeunit');
            Value.IsAutomation:
                exit('Automation');
            Value.IsFile:
                exit('File');
        end;
        exit('Unsupported Type');
    end;

    local procedure AssertContextIsSet()
    begin
        if not ContextIsSet then
            Error(SetContextErr);
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
        ValidatorCode: Code[20];
        ContextMigrationType: Text[250];
        EntityType: Text[50];
        Context: Text[250];
        MissingExpectedLbl: Label 'Expected to exist';
        MissingActualLbl: Label 'Does not exist';
        RedactedLbl: Label '<redacted>';
        ContextIsSet: Boolean;
        SetContextErr: Label 'Context must be set before calling this procedure.';
        UnsupportedTypeErr: Label 'Equality assertions only support Boolean, Option, Integer, BigInteger, Decimal, Code, Text, Date, DateFormula, Time, Duration, and DateTime values. Current value:%1.', Comment = '%1 = The unsupported variant type.';
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
        OverrideCommitAfterXValidatedRecordCount: Integer;
        CurrentValidatedRecordCount: Integer;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeStartValidation(MigrationType: Text[250]; var OverrideCommitAfterXValidatedRecordCount: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnTestOverrideWarning(Validator: Code[20]; Test: Code[30]; TestContext: Text[250]; EntryIsWarning: Boolean; var OverrideIsWarning: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnTestOverrideShouldRedact(Validator: Code[20]; Test: Code[30]; TestContext: Text[250]; EntryShouldRedact: Boolean; var OverrideShouldRedact: Boolean)
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