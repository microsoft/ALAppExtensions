namespace Microsoft.DataMigration.GP;

using Microsoft.DataMigration;

page 40132 "Hybrid GP Errors Overview Fb"
{
    Caption = 'GP Upgrade Errors';
    PageType = CardPart;

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
            cuegroup(MigrationLog)
            {
                ShowCaption = false;

                field("Migration Log"; MigrationLogCount)
                {
                    Caption = 'Migration Log';
                    ApplicationArea = All;
                    ToolTip = 'Indicates the number of migration log entries.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"GP Migration Log");
                    end;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    var
        GPMigrationErrorOverview: Record "GP Migration Error Overview";
    begin
        MigrationErrorCount := GPMigrationErrorOverview.Count();
    end;

    trigger OnAfterGetCurrRecord()
    var
        GPMigrationErrorOverview: Record "GP Migration Error Overview";
        HybridCompanyUpgrade: Record "Hybrid Company Status";
        GPMigrationLog: Record "GP Migration Log";
    begin
        MigrationErrorCount := GPMigrationErrorOverview.Count();
        HybridCompanyUpgrade.SetRange("Upgrade Status", HybridCompanyUpgrade."Upgrade Status"::Failed);
        FailedCompanyCount := HybridCompanyUpgrade.Count();

        MigrationLogCount := GPMigrationLog.Count();
    end;

    var
        MigrationErrorCount: Integer;
        FailedCompanyCount: Integer;
        MigrationLogCount: Integer;
}
