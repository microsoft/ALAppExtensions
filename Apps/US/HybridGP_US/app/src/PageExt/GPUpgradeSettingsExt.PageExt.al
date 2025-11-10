namespace Microsoft.DataMigration.GP;

using Microsoft.DataMigration;

pageextension 41105 "GP Upgrade Settings Ext" extends "GP Upgrade Settings"
{
    layout
    {
        addafter(GPAutomaticValidation)
        {
            field(GPUSAutomaticValidation; GPUSAutoValidation)
            {
                ApplicationArea = All;
                Caption = 'GP-US (1099)';
                ToolTip = 'Specifies whether automatic validation is enabled for the GP-US (1099) migration.';

                trigger OnValidate()
                var
                    MigrationValidationRegistry: Record "Migration Validator Registry";
                    GPUSMigrtionValidator: Codeunit "GP US Migration Validator";
                begin
                    if MigrationValidationRegistry.Get(GPUSMigrtionValidator.GetValidatorCode()) then begin
                        MigrationValidationRegistry.Validate(Enabled, GPUSAutoValidation);
                        MigrationValidationRegistry.Modify(true);
                    end;
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        MigrationValidationRegistry: Record "Migration Validator Registry";
        GPUSMigrtionValidator: Codeunit "GP US Migration Validator";
    begin
        GPUSAutoValidation := true;

        if MigrationValidationRegistry.Get(GPUSMigrtionValidator.GetValidatorCode()) then
            GPUSAutoValidation := MigrationValidationRegistry.Enabled;

    end;

    var
        GPUSAutoValidation: Boolean;
}