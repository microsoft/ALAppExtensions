namespace Microsoft.DataMigration.GP;

page 40132 "Hybrid GP Errors Overview Fb"
{
    Caption = 'GP Upgrade Errors';
    PageType = CardPart;
    InsertAllowed = false;
    DelayedInsert = false;
    ModifyAllowed = false;
    SourceTable = "GP Migration Error Overview";

    layout
    {
        area(Content)
        {
            cuegroup(Statistics)
            {
                ShowCaption = false;

                field("Migration Errors"; MigrationErrorCount)
                {
                    Caption = 'Migration Errors';
                    ApplicationArea = Basic, Suite;
                    Style = Unfavorable;
                    StyleExpr = (MigrationErrorCount > 0);
                    ToolTip = 'Indicates the number of errors that occurred during the migration.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"GP Migration Error Overview");
                    end;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        MigrationErrorCount := Rec.Count();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        MigrationErrorCount := Rec.Count();
    end;

    var
        MigrationErrorCount: Integer;
}
