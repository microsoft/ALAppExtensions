// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using Microsoft.DataMigration;

page 47023 "SL Hybrid Overview Fb"
{
    ApplicationArea = All;
    Caption = 'SL Migration Overview';
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
                    ApplicationArea = Basic, Suite;
                    Caption = 'Migration Errors';
                    Style = Unfavorable;
                    StyleExpr = (MigrationErrorCount > 0);
                    ToolTip = 'Indicates the number of errors that occurred during the migration.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"SL Migration Error Overview");
                    end;
                }
                field("Failed Companies"; FailedCompanyCount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Failed Companies';
                    Style = Unfavorable;
                    StyleExpr = (FailedCompanyCount > 0);
                    ToolTip = 'Indicates the number of companies that failed to upgrade.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"SL Hybrid Failed Companies");
                    end;
                }
            }

            cuegroup(Other)
            {
                ShowCaption = false;

                field("Failed Batches"; FailedBatchCount)
                {
                    ApplicationArea = All;
                    Caption = 'Failed Batches';
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
                    ApplicationArea = All;
                    Caption = 'Migration Warnings';
                    ToolTip = 'Indicates the number of migration warning entries.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"SL Migration Warnings");
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        SLMigrationErrorOverview: Record "SL Migration Error Overview";
    begin
        MigrationErrorCount := SLMigrationErrorOverview.Count();
    end;

    trigger OnAfterGetCurrRecord()
    var
        SLMigrationErrorOverview: Record "SL Migration Error Overview";
        HybridCompanyStatus: Record "Hybrid Company Status";
        SLMigrationWarnings: Record "SL Migration Warnings";
    begin
        FailedBatchCount := 0;
        FailedBatchMsg := 'One or more batches failed to post.\';

        MigrationErrorCount := SLMigrationErrorOverview.Count();
        HybridCompanyStatus.SetRange("Upgrade Status", HybridCompanyStatus."Upgrade Status"::Failed);
        FailedCompanyCount := HybridCompanyStatus.Count();
        MigrationWarningCount := SLMigrationWarnings.Count();

        if FailedBatchCount = 0 then
            FailedBatchMsg := 'No failed batches';
    end;

    var
        MigrationErrorCount: Integer;
        FailedCompanyCount: Integer;
        FailedBatchCount: Integer;
        MigrationWarningCount: Integer;
        FailedBatchMsg: Text;
}
