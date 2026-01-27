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
                begin
                    if not GPIRS1099AutoValidation then
                        GPIRS1099ValidationErrorsShouldFailMigration := false;

                    UpdateValidatorConfig();
                end;
            }
        }
        addafter(GPValidationErrorHandling)
        {
            field(GPUSValidationErrorHandling; GPIRS1099ValidationErrorsShouldFailMigration)
            {
                ApplicationArea = All;
                Caption = 'GP-US (1099)';
                ToolTip = 'Specifies whether GP-US (1099) validation errors should fail the migration. Only applies when automatic validation is enabled.';

                trigger OnValidate()
                begin
                    GPIRS1099AutoValidation := GPIRS1099ValidationErrorsShouldFailMigration;
                    UpdateValidatorConfig();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        ValidationSuite: Record "Validation Suite";
        GPIRS1099MigrtionValidator: Codeunit "GP IRS1099 Migration Validator";
    begin
        if ValidationSuite.Get(GPIRS1099MigrtionValidator.GetValidationSuiteId()) then begin
            GPIRS1099AutoValidation := ValidationSuite.Automatic;
            GPIRS1099ValidationErrorsShouldFailMigration := ValidationSuite."Errors should fail migration";
        end;
    end;

    local procedure UpdateValidatorConfig()
    var
        ValidationSuite: Record "Validation Suite";
        GPIRS1099MigrtionValidator: Codeunit "GP IRS1099 Migration Validator";
    begin
        if ValidationSuite.Get(GPIRS1099MigrtionValidator.GetValidationSuiteId()) then begin
            ValidationSuite.Validate(Automatic, GPIRS1099AutoValidation);
            ValidationSuite.Validate("Errors should fail migration", GPIRS1099ValidationErrorsShouldFailMigration);
            ValidationSuite.Modify(true);
        end;
    end;

    var
        GPIRS1099AutoValidation: Boolean;
        GPIRS1099ValidationErrorsShouldFailMigration: Boolean;
}