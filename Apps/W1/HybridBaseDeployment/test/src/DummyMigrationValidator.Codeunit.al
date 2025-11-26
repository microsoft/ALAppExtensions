codeunit 139501 "Dummy Migration Validator"
{
    trigger OnRun()
    begin
        RunCustomerMigrationValidation();
    end;

    local procedure RunCustomerMigrationValidation()
    var
        Customer: Record Customer;
        MigrationValidationMgmt: Codeunit "Migration Validation Mgmt.";
    begin
        // [Customer: Test 1]

        // Set the context of this set of tests
        MigrationValidationMgmt.SetContext(GetValidatorCode(), 'Customer', 'TEST-1');

        // Check for the entity record by the key
        if not MigrationValidationMgmt.ValidateRecordExists(Customer.Get('TEST-1'), 'Missing TEST-1') then
            exit;

        // This is a test that is not a warning, and would fail the migration
        MigrationValidationMgmt.ValidateAreEqual('Test 1', Customer.Name, 'Name');

        // This is a test that would be just a warning
        MigrationValidationMgmt.ValidateAreEqual('Test name 2', Customer."Name 2", 'Name 2', true);

        // [Customer: Test 2]

        // Set the context of this set of tests
        MigrationValidationMgmt.SetContext(GetValidatorCode(), 'Customer', 'TEST-2');

        // Check for the entity record by the key
        if not MigrationValidationMgmt.ValidateRecordExists(Customer.Get('TEST-2'), 'Missing TEST-2') then
            exit;

        // This is a test that is not a warning, and would fail the migration
        MigrationValidationMgmt.ValidateAreEqual('Test 2', Customer.Name, 'Name');

        // This is a test that would be just a warning
        MigrationValidationMgmt.ValidateAreEqual('Test name 2', Customer."Name 2", 'Name 2', true);
    end;

    internal procedure GetValidatorCode(): Code[20]
    begin
        exit('TEST');
    end;
}