namespace Microsoft.DataMigration.GP;

using Microsoft.DataMigration;

codeunit 42007 "Hybrid GP US Install"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerDatabase()
    begin
        RegisterValidator();
        RegisterTests();
    end;

    local procedure RegisterValidator()
    var
        MigrationValidatorRegistry: Record "Migration Validator Registry";
        HybridGPWizard: Codeunit "Hybrid GP Wizard";
        GPUSMigrationValidator: Codeunit "GP US Migration Validator";
        ValidatorCode: Code[20];
        MigrationType: Text[250];
        ValidatorCodeunitId: Integer;
    begin
        ValidatorCode := GPUSMigrationValidator.GetValidatorCode();
        MigrationType := HybridGPWizard.ProductId();
        ValidatorCodeunitId := Codeunit::"GP US Migration Validator";
        if not MigrationValidatorRegistry.Get(ValidatorCode) then begin
            MigrationValidatorRegistry.Validate("Validator Code", ValidatorCode);
            MigrationValidatorRegistry.Validate("Migration Type", MigrationType);
            MigrationValidatorRegistry.Validate(Description, ValidatorDescriptionLbl);
            MigrationValidatorRegistry.Validate("Codeunit Id", ValidatorCodeunitId);
            MigrationValidatorRegistry.Insert(true);
        end;
    end;

    local procedure RegisterTests()
    begin
        AddTest('VEND1099IRS1099CODE', 'Vendor 1099', 'IRS 1099 Code');
        AddTest('VEND1099FEDIDNO', 'Vendor 1099', 'Federal ID No.');
        AddTest('VEND1099TRXEXISTS', 'Vendor 1099', 'Missing 1099 transaction');
        AddTest('VEND1099TEN99TRXAMT', 'Vendor 1099', '1099 transaction amount');
    end;

    local procedure AddTest(Code: Code[30]; Entity: Text[50]; Description: Text)
    var
        MigrationValidationTest: Record "Migration Validation Test";
        GPUSMigrationValidator: Codeunit "GP US Migration Validator";
    begin
        if not MigrationValidationTest.Get(Code, GPUSMigrationValidator.GetValidatorCode()) then begin
            MigrationValidationTest.Validate(Code, Code);
            MigrationValidationTest.Validate("Validator Code", GPUSMigrationValidator.GetValidatorCode());
            MigrationValidationTest.Validate(Entity, Entity);
            MigrationValidationTest.Validate("Test Description", Description);
            MigrationValidationTest.Insert(true);
        end;
    end;

    var
        ValidatorDescriptionLbl: Label 'GP US migration validator', MaxLength = 250;
}