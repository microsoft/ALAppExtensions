namespace Microsoft.DataMigration.GP;

page 41100 "GP 1099 Migration Log Factbox"
{
    Caption = 'GP 1099 Migration Log Factbox';
    PageType = CardPart;
    SourceTable = "GP 1099 Migration Log";
    InsertAllowed = false;
    DelayedInsert = false;
    ModifyAllowed = false;
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            group(CueGroup1)
            {
                ShowCaption = false;

                cuegroup(Statistics)
                {
                    ShowCaption = false;

                    field("Error Count"; ErrorCount)
                    {
                        Caption = 'GP 1099 Migration Errors';
                        ApplicationArea = All;
                        Style = Unfavorable;
                        StyleExpr = (ErrorCount > 0);
                        ToolTip = 'Indicates the number of GP 1099 migration errors that occurred during the migration.';

                        trigger OnDrillDown()
                        var
                            GP1099MigrationLog: Page "GP 1099 Migration Log";
                        begin
                            GP1099MigrationLog.FilterOnErrors();
                            GP1099MigrationLog.Run();
                        end;
                    }
                    field("Total Count"; TotalCount)
                    {
                        Caption = 'GP 1099 Migration Log Entries';
                        ApplicationArea = All;
                        ToolTip = 'Indicates the number of GP 1099 migration log entries that have been logged during the migration.';

                        trigger OnDrillDown()
                        begin
                            Page.RunModal(Page::"GP 1099 Migration Log");
                        end;
                    }
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        GP1099MigrationLog: Record "GP 1099 Migration Log";
    begin
        TotalCount := GP1099MigrationLog.Count();

        GP1099MigrationLog.SetRange(IsError, true);
        ErrorCount := GP1099MigrationLog.Count();
    end;

    var
        ErrorCount: Integer;
        TotalCount: Integer;
}