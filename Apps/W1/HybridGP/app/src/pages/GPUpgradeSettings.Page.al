namespace Microsoft.DataMigration.GP;
using Microsoft.DataMigration;

page 40043 "GP Upgrade Settings"
{
    PageType = Card;
    Caption = 'GP Migration Settings';
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "GP Upgrade Settings";

    layout
    {
        area(Content)
        {
            group(AutomaticValidation)
            {
                Caption = 'Automatic Validation';

                field(GPAutomaticValidation; GPAutoValidation)
                {
                    ApplicationArea = All;
                    Caption = 'GP';
                    ToolTip = 'Specifies whether automatic validation is enabled for the primary GP migration.';

                    trigger OnValidate()
                    var
                        MigrationValidationRegistry: Record "Migration Validator Registry";
                        GPMigrtionValidator: Codeunit "GP Migration Validator";
                    begin
                        if MigrationValidationRegistry.Get(GPMigrtionValidator.GetValidatorCode()) then begin
                            MigrationValidationRegistry.Validate(Enabled, GPAutoValidation);
                            MigrationValidationRegistry.Modify(true);
                        end;
                    end;
                }
            }

            group(ErrorHandling)
            {
                Caption = 'Error Handling';
                field(CollectAllErrors; Rec."Collect All Errors")
                {
                    ApplicationArea = All;
                    Caption = 'Attempt to migrate all companies';
                    ToolTip = 'Specifies whether to stop migration on first company failure or to attempt to migrate all companies.';
                }
                field(LogAllRecordChanges; Rec."Log All Record Changes")
                {
                    ApplicationArea = All;
                    Caption = 'Log all record changes';
                    ToolTip = 'Specifies whether to log all record changes during migration. This method will make the data migration slower.';
                }
            }

            group(OneStepUpgradeGroup)
            {
                Caption = 'One Step Migration';
                field(OneStepUpgrade; Rec."One Step Upgrade")
                {
                    ApplicationArea = All;
                    Caption = 'Run migration after replication';
                    ToolTip = 'Specifies whether to run the migration immediatelly after replication, without manually invoking the data migration action.';
                }
                field(OneStepUpgradeDelay; Rec."One Step Upgrade Delay")
                {
                    ApplicationArea = All;
                    Caption = 'Run migration after replication delay';
                    ToolTip = 'Specifies the delay to add after replication before starting the data migration.';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        MigrationValidationRegistry: Record "Migration Validator Registry";
        GPMigrtionValidator: Codeunit "GP Migration Validator";
    begin
        GPAutoValidation := true;

        if MigrationValidationRegistry.Get(GPMigrtionValidator.GetValidatorCode()) then
            GPAutoValidation := MigrationValidationRegistry.Enabled;

        Rec.GetonInsertGPUpgradeSettings(Rec);
    end;

    var
        GPAutoValidation: Boolean;
}