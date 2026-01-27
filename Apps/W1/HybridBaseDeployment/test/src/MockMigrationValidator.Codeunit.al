codeunit 139501 "Mock Migration Validator"
{
    trigger OnRun()
    begin
        RunCustomerMigrationValidation();
    end;

    local procedure RunCustomerMigrationValidation()
    var
        Customer: Record Customer;
        CustomerId1: Label 'TEST-1', MaxLength = 20, Locked = true;
        CustomerId2: Label 'TEST-2', MaxLength = 20, Locked = true;
    begin
        // [Customer: Test 1]

        // Set the context of this set of tests
        MigrationValidationAssert.SetContext(GetValidatorCode(), 'Customer', CustomerId1);

        // Check for the entity record by the key
        if not MigrationValidationAssert.ValidateRecordExists(Test_CUSTOMEREXISTS_Tok, Customer.Get(CustomerId1), 'Missing TEST-1') then
            exit;

        // This is a test that is not a warning, and would fail the migration
        MigrationValidationAssert.ValidateAreEqual(Test_CUSTOMERNAME_Tok, 'Test 1', Customer.Name, 'Name');

        // This is a test that would be just a warning
        MigrationValidationAssert.ValidateAreEqual(Test_CUSTOMERNAME2_Tok, 'Test name 2', Customer."Name 2", 'Name 2', true);

        // The source table will normally be the staging table, but for testing the Customer table is sufficient
        MigrationValidationAssert.SetSourceRowValidated(GetValidatorCode(), Customer);

        // [Customer: Test 2]

        // Set the context of this set of tests
        MigrationValidationAssert.SetContext(GetValidatorCode(), 'Customer', CustomerId2);

        // Check for the entity record by the key
        if not MigrationValidationAssert.ValidateRecordExists(Test_CUSTOMEREXISTS_Tok, Customer.Get(CustomerId2), 'Missing TEST-2') then
            exit;

        // This is a test that is not a warning, and would fail the migration
        MigrationValidationAssert.ValidateAreEqual(Test_CUSTOMERNAME_Tok, 'Test 2', Customer.Name, 'Name');

        // This is a test that would be just a warning
        MigrationValidationAssert.ValidateAreEqual(Test_CUSTOMERNAME2_Tok, 'Test name 2', Customer."Name 2", 'Name 2', true);

        // The source table will normally be the staging table, but for testing the Customer table is sufficient
        MigrationValidationAssert.SetSourceRowValidated(GetValidatorCode(), Customer);
    end;

    internal procedure GetValidatorCode(): Code[20]
    begin
        exit('TEST');
    end;

    // Normally initialized by this event, but called directly for testing.
    //[EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", OnPrepareMigrationValidation, '', false, false)]
    internal procedure OnPrepareMigrationValidation(ProductID: Text[250])
    begin
        RegisterValidator(ProductID);

        AddTest(Test_CUSTOMEREXISTS_Tok, 'Customer', 'Missing Customer');
        AddTest(Test_CUSTOMERNAME_Tok, 'Customer', 'Name');
        AddTest(Test_CUSTOMERNAME2_Tok, 'Customer', 'Name 2');
    end;

    local procedure RegisterValidator(ProductID: Text[250])
    var
        MigrationValidatorRegistry: Record "Migration Validator Registry";
        ValidatorCodeunitId: Integer;
    begin
        ValidatorCodeunitId := Codeunit::"Mock Migration Validator";
        if not MigrationValidatorRegistry.Get(GetValidatorCode()) then begin
            MigrationValidatorRegistry.Validate("Validator Code", GetValidatorCode());
            MigrationValidatorRegistry.Validate("Migration Type", ProductID);
            MigrationValidatorRegistry.Validate(Description, ValidatorDescriptionLbl);
            MigrationValidatorRegistry.Validate("Codeunit Id", ValidatorCodeunitId);
            MigrationValidatorRegistry.Validate(Automatic, true);
            MigrationValidatorRegistry.Validate("Errors should fail migration", true);
            MigrationValidatorRegistry.Insert(true);
        end;
    end;

    local procedure AddTest(Code: Code[30]; Entity: Text[50]; Description: Text)
    var
        MigrationValidationTest: Record "Migration Validation Test";
    begin
        if not MigrationValidationTest.Get(Code, GetValidatorCode()) then begin
            MigrationValidationTest.Validate(Code, Code);
            MigrationValidationTest.Validate("Validator Code", GetValidatorCode());
            MigrationValidationTest.Validate(Entity, Entity);
            MigrationValidationTest.Validate("Test Description", Description);
            MigrationValidationTest.Insert(true);
        end;
    end;

    var
        MigrationValidationAssert: Codeunit "Migration Validation Assert";
        ValidatorDescriptionLbl: Label 'Mock Migration Validator', MaxLength = 250;
        Test_CUSTOMEREXISTS_Tok: Label 'CUSTOMEREXISTS', Locked = true;
        Test_CUSTOMERNAME_Tok: Label 'CUSTOMERNAME', Locked = true;
        Test_CUSTOMERNAME2_Tok: Label 'CUSTOMERNAME2', Locked = true;
}