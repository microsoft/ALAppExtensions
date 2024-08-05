namespace Microsoft.DataMigration.GP;

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
    begin
        Rec.GetonInsertGPUpgradeSettings(Rec);
    end;
}