namespace Microsoft.DataMigration.GP;

using Microsoft.DataMigration;

page 40132 "Hybrid GP Errors Overview Fb"
{
    Caption = 'GP Migration Overview';
    PageType = CardPart;

    layout
    {
        area(Content)
        {
            cuegroup(Statistics)
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'Reorganization of tiles';
                ObsoleteTag = '24.0';
                Visible = false;
            }
            cuegroup(FailedCompanies)
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'Reorganization of tiles';
                ObsoleteTag = '24.0';
                Visible = false;
            }

            cuegroup(Errors)
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

            cuegroup(Other)
            {
                ShowCaption = false;

                field("Failed Batches"; FailedBatchCount)
                {
                    Caption = 'Failed Batches';
                    ApplicationArea = All;
                    Style = Unfavorable;
                    StyleExpr = (FailedBatchCount > 0);
                    ToolTip = 'Indicates the total number of failed batches, for all migrated companies.';

                    trigger OnDrillDown()
                    begin
                        Message(FailedBatchMsg);
                    end;
                }

                field("Migration Warnings"; MigrationWarningCount)
                {
                    Caption = 'Migration Warnings';
                    ApplicationArea = All;
                    ToolTip = 'Indicates the number of migration warning entries.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"GP Migration Warnings");
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
        HybridCompanyStatus: Record "Hybrid Company Status";
        GPMigrationWarnings: Record "GP Migration Warnings";
        HelperFunctions: Codeunit "Helper Functions";
        TotalGLBatchCount: Integer;
        TotalItemBatchCount: Integer;
        CompanyHasFailedBatches: Boolean;
    begin
        FailedBatchCount := 0;
        FailedBatchMsg := 'One or more batches failed to post.\';

        MigrationErrorCount := GPMigrationErrorOverview.Count();
        HybridCompanyStatus.SetRange("Upgrade Status", HybridCompanyStatus."Upgrade Status"::Failed);
        FailedCompanyCount := HybridCompanyStatus.Count();
        MigrationWarningCount := GPMigrationWarnings.Count();

        HybridCompanyStatus.Reset();
        HybridCompanyStatus.SetRange("Upgrade Status", HybridCompanyStatus."Upgrade Status"::Completed);
        if HybridCompanyStatus.FindSet() then
            repeat
                TotalGLBatchCount := 0;
                TotalItemBatchCount := 0;

                HelperFunctions.GetUnpostedBatchCountForCompany(HybridCompanyStatus.Name, TotalGLBatchCount, TotalItemBatchCount);
                FailedBatchCount := FailedBatchCount + TotalGLBatchCount + TotalItemBatchCount;
                CompanyHasFailedBatches := (TotalGLBatchCount > 0) or (TotalItemBatchCount > 0);
                if CompanyHasFailedBatches then begin
                    if (TotalGLBatchCount > 0) and (TotalItemBatchCount > 0) then
                        FailedBatchMsg := FailedBatchMsg + HybridCompanyStatus.Name + ': GL batches: ' + Format(TotalGLBatchCount) + ', Item batches: ' + Format(TotalItemBatchCount) + '\';

                    if (TotalGLBatchCount > 0) and (TotalItemBatchCount = 0) then
                        FailedBatchMsg := FailedBatchMsg + HybridCompanyStatus.Name + ': GL batches: ' + Format(TotalGLBatchCount) + '\';

                    if (TotalGLBatchCount = 0) and (TotalItemBatchCount > 0) then
                        FailedBatchMsg := FailedBatchMsg + HybridCompanyStatus.Name + ': Item batches: ' + Format(TotalItemBatchCount) + '\';
                end;
            until HybridCompanyStatus.Next() = 0;

        if FailedBatchCount = 0 then
            FailedBatchMsg := 'No failed batches';
    end;

    var
        MigrationErrorCount: Integer;
        FailedCompanyCount: Integer;
        FailedBatchCount: Integer;
        FailedBatchMsg: Text;
        MigrationWarningCount: Integer;
}
