namespace Microsoft.DataMigration.GP;

using System.Environment.Configuration;
using System.Integration;

page 4031 "Hybrid GP Errors Factbox"
{
    Caption = 'GP Synchronization Errors';
    SourceTable = "GP Migration Errors";
    PageType = CardPart;
    InsertAllowed = false;
    DelayedInsert = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            cuegroup(Statistics)
            {
                ShowCaption = false;

                field("Migration Errors"; Rec.MigrationErrorCount)
                {
                    Caption = 'Migration Errors';
                    ApplicationArea = Basic, Suite;
                    Style = Unfavorable;
                    StyleExpr = (Rec.MigrationErrorCount > 0);
                    ToolTip = 'Indicates the number of errors that occurred during the migration.';

                    trigger OnDrillDown()
                    var
                        DataSyncStatus: Page "Data Sync Status";
                    begin
                        DataSyncStatus.SetMigrationVisibility(true);
                        DataSyncStatus.RunModal();
                    end;
                }

#if not CLEAN23
                field("Posting Errors"; Rec.PostingErrorCount)
                {
                    Caption = 'Posting Errors';
                    ApplicationArea = Basic, Suite;
                    Style = Unfavorable;
                    StyleExpr = (Rec.PostingErrorCount > 0);
                    ToolTip = 'Indicates the number of posting errors that occurred during the migration.';
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Removed functionality because of false positives and performance issues.';
                    ObsoleteTag = '23.0';

                    trigger OnDrillDown()
                    begin
                        Page.RunModal(Page::"Data Sync Status");
                    end;
                }
#endif                
            }
        }
    }
    trigger OnInit()
    var
        DataMigrationError: Record "Data Migration Error";
        GPMigrationErrors: Record "GP Migration Errors";
        TotalErrors: Integer;
        MigrationErrors: Integer;
        PostingErrors: Integer;
    begin
        GPMigrationErrors.Init();

        DataMigrationError.Reset();
        DataMigrationError.SetRange("Migration Type", MigrationTypeTxt);
        TotalErrors := DataMigrationError.Count();
        DataMigrationError.SetRange("Destination Table ID", 0);
        PostingErrors := DataMigrationError.Count();
        MigrationErrors := TotalErrors - PostingErrors;

        GPMigrationErrors.PostingErrorCount := PostingErrors;
        GPMigrationErrors.MigrationErrorCount := MigrationErrors;
        if not GPMigrationErrors.Insert() then
            GPMigrationErrors.Modify();
    end;

    var
        MigrationTypeTxt: Label 'Great Plains', Locked = true;
}
