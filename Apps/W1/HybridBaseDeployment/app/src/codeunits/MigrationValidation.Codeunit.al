namespace Microsoft.DataMigration;

using System.Reflection;

codeunit 40032 "Migration Validation"
{
    /// <summary>
    /// Start migration validation for the current company
    /// </summary>
    /// <param name="MigrationType">The type of migration</param>
    /// <param name="Force">Force the validation. This would be done if conducting a manual validation.</param>
    procedure StartValidation(MigrationType: Text; Force: Boolean)
    var
        MigrationValidatorRegistry: Record "Migration Validator Registry";
        CloudMigrationWarning: Record "Cloud Migration Warning";
    begin
        MigrationValidatorRegistry.SetRange("Migration Type", MigrationType);

        if Force then
            DeleteMigrationValidationEntriesForCompany()
        else
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
    end;

    /// <summary>
    /// Report that the Company has had validation tests run.
    /// </summary>
    procedure ReportCompanyValidated()
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
        CompanyValidationProgress: Record "Company Validation Progress";
        HybridCompanyStatus: Record "Hybrid Company Status";
    begin
        MigrationValidationError.SetRange("Company Name", Company);
        if not MigrationValidationError.IsEmpty() then
            MigrationValidationError.DeleteAll(true);

        CompanyValidationProgress.SetRange("Company Name", Company);
        if not CompanyValidationProgress.IsEmpty() then
            CompanyValidationProgress.DeleteAll(true);

        if not HybridCompanyStatus.Get(Company) then
            exit;

        HybridCompanyStatus.Validate(Validated, false);
        HybridCompanyStatus.Modify(true);
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

    [IntegrationEvent(false, false)]
    local procedure OnTestOverrideWarning(Validator: Code[20]; Test: Code[30]; TestContext: Text[250]; EntryIsWarning: Boolean; var OverrideIsWarning: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnTestOverrideShouldRedact(Validator: Code[20]; Test: Code[30]; TestContext: Text[250]; EntryShouldRedact: Boolean; var OverrideShouldRedact: Boolean)
    begin
    end;
}