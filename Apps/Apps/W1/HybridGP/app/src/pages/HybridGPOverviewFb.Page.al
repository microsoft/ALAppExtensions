namespace Microsoft.DataMigration.GP;

using Microsoft.DataMigration;

page 40125 "Hybrid GP Overview Fb"
{
    ApplicationArea = All;
    Caption = 'GP Migration Overview';
    PageType = CardPart;

    layout
    {
        area(Content)
        {
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
        TotalStatisticalBatchCount: Integer;
        TotalItemBatchCount: Integer;
        CompanyHasFailedBatches: Boolean;
        FailedBatchMsgBuilder: TextBuilder;
        AddComma: Boolean;
    begin
        FailedBatchCount := 0;
        FailedBatchMsgBuilder.Append('One or more batches failed to post.\');

        MigrationErrorCount := GPMigrationErrorOverview.Count();
        HybridCompanyStatus.SetRange("Upgrade Status", HybridCompanyStatus."Upgrade Status"::Failed);
        FailedCompanyCount := HybridCompanyStatus.Count();
        MigrationWarningCount := GPMigrationWarnings.Count();

        HybridCompanyStatus.Reset();
        HybridCompanyStatus.SetRange("Upgrade Status", HybridCompanyStatus."Upgrade Status"::Completed);
        if HybridCompanyStatus.FindSet() then
            repeat
                TotalGLBatchCount := 0;
                TotalStatisticalBatchCount := 0;
                TotalItemBatchCount := 0;

                HelperFunctions.GetUnpostedBatchCountForCompany(HybridCompanyStatus.Name, TotalGLBatchCount, TotalStatisticalBatchCount, TotalItemBatchCount);
                FailedBatchCount := FailedBatchCount + TotalGLBatchCount + TotalStatisticalBatchCount + TotalItemBatchCount;
                CompanyHasFailedBatches := (TotalGLBatchCount > 0) or (TotalItemBatchCount > 0);
                if CompanyHasFailedBatches then begin
                    FailedBatchMsgBuilder.Append(HybridCompanyStatus.Name + ': ');

                    if TotalGLBatchCount > 0 then begin
                        FailedBatchMsgBuilder.Append('GL batches: ' + Format(TotalGLBatchCount));
                        AddComma := true;
                    end;

                    if TotalStatisticalBatchCount > 0 then begin
                        if AddComma then
                            FailedBatchMsgBuilder.Append(', ');

                        FailedBatchMsgBuilder.Append('Statistical batches: ' + Format(TotalStatisticalBatchCount));
                    end;

                    if TotalItemBatchCount > 0 then begin
                        if AddComma then
                            FailedBatchMsgBuilder.Append(', ');

                        FailedBatchMsgBuilder.Append('Item batches: ' + Format(TotalItemBatchCount));
                    end;

                    FailedBatchMsgBuilder.Append('\');
                end;
            until HybridCompanyStatus.Next() = 0;

        if FailedBatchCount > 0 then
            FailedBatchMsg := FailedBatchMsgBuilder.ToText()
        else
            FailedBatchMsg := 'No failed batches';
    end;

    var
        MigrationErrorCount: Integer;
        FailedCompanyCount: Integer;
        FailedBatchCount: Integer;
        FailedBatchMsg: Text;
        MigrationWarningCount: Integer;
}
