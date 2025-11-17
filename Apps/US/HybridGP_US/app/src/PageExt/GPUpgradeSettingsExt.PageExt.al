namespace Microsoft.DataMigration.GP;

using Microsoft.DataMigration;

pageextension 41105 "GP Upgrade Settings Ext" extends "GP Upgrade Settings"
{
    layout
    {
        addafter(GPAutomaticValidation)
        {
            field(GPUSAutomaticValidation; GPIRS1099AutoValidation)
            {
                ApplicationArea = All;
                Caption = 'GP-US (1099)';
                ToolTip = 'Specifies whether automatic validation is enabled for the GP-US (1099) migration.';

                trigger OnValidate()
                var
                    MigrationValidationRegistry: Record "Migration Validator Registry";
                    GPIRS1099MigrtionValidator: Codeunit "GP IRS1099 Migration Validator";
                begin
                    if MigrationValidationRegistry.Get(GPIRS1099MigrtionValidator.GetValidatorCode()) then begin
                        MigrationValidationRegistry.Validate(Automatic, GPIRS1099AutoValidation);
                        MigrationValidationRegistry.Modify(true);
                    end;
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        MigrationValidationRegistry: Record "Migration Validator Registry";
        GPIRS1099MigrtionValidator: Codeunit "GP IRS1099 Migration Validator";
    begin
        if MigrationValidationRegistry.Get(GPIRS1099MigrtionValidator.GetValidatorCode()) then
            GPIRS1099AutoValidation := MigrationValidationRegistry.Automatic;

    end;

    var
        GPIRS1099AutoValidation: Boolean;
}