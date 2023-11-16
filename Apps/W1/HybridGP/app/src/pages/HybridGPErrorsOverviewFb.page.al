namespace Microsoft.DataMigration.GP;

using Microsoft.DataMigration;

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
            cuegroup(FailedCompanies)
            {
                ShowCaption = false;

                field("Failed Companies"; FailedCompanyCount)
                {
                    Caption = 'Failed Companies';
                    ApplicationArea = Basic, Suite;
                    Style = Unfavorable;
                    StyleExpr = (FailedCompanyCount > 0);
                    ToolTip = 'Indicates the number of companies that failed to upgrade.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Hybrid GP Failed Companies");
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
    var
        HybridCompanyUpgrade: Record "Hybrid Company Status";
    begin
        MigrationErrorCount := Rec.Count();
        HybridCompanyUpgrade.SetRange("Upgrade Status", HybridCompanyUpgrade."Upgrade Status"::Failed);
        FailedCompanyCount := HybridCompanyUpgrade.Count();
    end;

    var
        MigrationErrorCount: Integer;
        FailedCompanyCount: Integer;
}
