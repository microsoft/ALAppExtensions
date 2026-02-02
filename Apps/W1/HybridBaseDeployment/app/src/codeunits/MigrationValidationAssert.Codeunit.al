namespace Microsoft.DataMigration;

using System.Reflection;

codeunit 40033 "Migration Validation Assert"
{
    /// <summary>
    /// Set the context for this series of migration validation tests.
    /// </summary>
    /// <param name="EntryValidationSuiteId">The validation suite executing the tests.</param>
    /// <param name="EntryEntityType">The entity type being tested.</param>
    /// <param name="EntryContext">The entity Id context.</param>
    procedure SetContext(EntryValidationSuiteId: Code[20]; EntryEntityType: Text[50]; EntryContext: Text[250])
    var
        ValidationSuite: Record "Validation Suite";
    begin
        ContextIsSet := false;

        EntityType := EntryEntityType;
        Context := EntryContext;

        if ValidationSuiteId <> EntryValidationSuiteId then begin
            ValidationSuiteId := EntryValidationSuiteId;

            ValidationSuite.Get(ValidationSuiteId);
            ContextMigrationType := ValidationSuite."Migration Type";
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
        ValidationSuiteLine: record "Validation Suite Line";
        OverrideIsWarning: Boolean;
        OverrideShouldRedact: Boolean;
        ActualIsWarning: Boolean;
        ActualShouldRedact: Boolean;
    begin
        ValidationSuiteLine.SetRange(Code, TestCode);
        ValidationSuiteLine.SetRange("Validation Suite Id", ValidationSuiteId);
        ValidationSuiteLine.SetRange(Ignore, true);
        if not ValidationSuiteLine.IsEmpty() then
            exit;

        ActualIsWarning := ShouldBeWarning;
        OverrideIsWarning := ShouldBeWarning;
        ActualShouldRedact := ShouldRedact;
        OverrideShouldRedact := ShouldRedact;

        OnTestOverrideWarning(ValidationSuiteId, TestCode, Context, ShouldBeWarning, OverrideIsWarning);
        ActualIsWarning := OverrideIsWarning;

        OnTestOverrideShouldRedact(ValidationSuiteId, TestCode, Context, ShouldRedact, OverrideShouldRedact);
        ActualShouldRedact := OverrideShouldRedact;

        if ActualShouldRedact then begin
            Expected := RedactedLbl;
            Actual := RedactedLbl;
        end;

        MigrationValidationError."Entry No." := 0;
        MigrationValidationError.Validate("Company Name", CompanyName());
        MigrationValidationError.Validate("Test Code", TestCode);
        MigrationValidationError.Validate("Validation Suite Id", ValidationSuiteId);
        MigrationValidationError.Validate("Migration Type", ContextMigrationType);
        MigrationValidationError.Validate("Entity Type", EntityType);
        MigrationValidationError.Validate("Entity Display Name", Context);
        MigrationValidationError.Validate("Test Description", TestDescription);
        MigrationValidationError.Validate(Expected, Expected);
        MigrationValidationError.Validate(Actual, Actual);
        MigrationValidationError.Validate("Is Warning", ActualIsWarning);
        MigrationValidationError.Insert(true);
    end;

    /// <summary>
    /// Report that the source record has been validated.
    /// </summary>
    /// <param name="EntryValidationSuiteId">Validator used for testing this source record</param>
    /// <param name="SourceRecRef">Source record that was validated</param>
    procedure SetSourceRowValidated(EntryValidationSuiteId: Code[20]; SourceRecRef: RecordRef)
    var
        ValidationProgress: Record "Validation Progress";
        MigrationValidation: Codeunit "Migration Validation";
        SourceTableId: Integer;
        ValidatedRowSystemId: Guid;
    begin
        SourceTableId := SourceRecRef.Number();
        ValidatedRowSystemId := SourceRecRef.Field(SourceRecRef.SystemIdNo()).Value;

        if not ValidationProgress.Get(CompanyName(), EntryValidationSuiteId, SourceTableId, ValidatedRowSystemId) then begin
            ValidationProgress.Validate("Company Name", CompanyName());
            ValidationProgress.Validate("Validation Suite Id", EntryValidationSuiteId);
            ValidationProgress.Validate("Source Table Id", SourceTableId);
            ValidationProgress.Validate("Validated Row System Id", ValidatedRowSystemId);
            ValidationProgress.Insert(true);

            CurrentValidatedRecordCount += 1;
            if CurrentValidatedRecordCount >= MigrationValidation.GetCommitAfterXValidatedRecordCount() then begin
                Commit();
                CurrentValidatedRecordCount := 0;
            end;
        end;
    end;

    /// <summary>
    /// Check to see if a source record has been validated.
    /// </summary>
    /// <param name="SourceValidationSuiteId">Validator used for testing this source record</param>
    /// <param name="SourceRecRef">The source record to check if it has already been validated.</param>
    /// <returns></returns>
    procedure IsSourceRowValidated(SourceValidationSuiteId: Code[20]; SourceRecRef: RecordRef): Boolean
    var
        ValidationProgress: Record "Validation Progress";
        SourceTableId: Integer;
        ValidatedRowSystemId: Guid;
    begin
        SourceTableId := SourceRecRef.Number();
        ValidatedRowSystemId := SourceRecRef.Field(SourceRecRef.SystemIdNo()).Value;

        ValidationProgress.SetRange("Company Name", CompanyName());
        ValidationProgress.SetRange("Validation Suite Id", SourceValidationSuiteId);
        ValidationProgress.SetRange("Source Table Id", SourceTableId);
        ValidationProgress.SetRange("Validated Row System Id", ValidatedRowSystemId);
        exit(not ValidationProgress.IsEmpty());
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

    var
        ValidationSuiteId: Code[20];
        ContextMigrationType: Text[250];
        EntityType: Text[50];
        Context: Text[250];
        ContextIsSet: Boolean;
        MissingExpectedLbl: Label 'Expected to exist';
        MissingActualLbl: Label 'Does not exist';
        RedactedLbl: Label '<redacted>';
        SetContextErr: Label 'Context must be set before calling this procedure.';
        CurrentValidatedRecordCount: Integer;
        UnsupportedTypeErr: Label 'Equality assertions only support Boolean, Option, Integer, BigInteger, Decimal, Code, Text, Date, DateFormula, Time, Duration, and DateTime values. Current value:%1.', Comment = '%1 = The unsupported variant type.';

    [IntegrationEvent(false, false)]
    local procedure OnTestOverrideWarning(Validator: Code[20]; Test: Code[30]; TestContext: Text[250]; EntryIsWarning: Boolean; var OverrideIsWarning: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnTestOverrideShouldRedact(Validator: Code[20]; Test: Code[30]; TestContext: Text[250]; EntryShouldRedact: Boolean; var OverrideShouldRedact: Boolean)
    begin
    end;
}