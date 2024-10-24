// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using System.Environment.Configuration;
using System.Integration;

page 42009 "SL Hybrid Errors Factbox"
{
    ApplicationArea = All;
    Caption = 'SL Synchronization Errors';
    DelayedInsert = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = CardPart;
    SourceTable = "SL Migration Errors";

    layout
    {
        area(Content)
        {
            cuegroup(Statistics)
            {
                ShowCaption = false;
                field("Migration Errors"; Rec.MigrationErrorCount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Migration Errors';
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
                field("Posting Errors"; Rec.PostingErrorCount)
                {
                    Caption = 'Posting Errors';
                    Style = Unfavorable;
                    StyleExpr = (Rec.PostingErrorCount > 0);
                    ToolTip = 'Indicates the number of posting errors that occurred during the migration.';

                    trigger OnDrillDown()
                    var
                        DataSyncStatus: Page "Data Sync Status";
                    begin
                        DataSyncStatus.SetMigrationVisibility(false);
                        Page.RunModal(Page::"Data Sync Status");
                        DataSyncStatus.Run();
                    end;
                }
            }
        }
    }
    trigger OnInit()
    var
        DataMigrationError: Record "Data Migration Error";
        SLMigrationErrors: Record "SL Migration Errors";
        TotalErrors: Integer;
        MigrationErrors: Integer;
        PostingErrors: Integer;
    begin
        SLMigrationErrors.Init();

        DataMigrationError.Reset();
        DataMigrationError.SetRange("Migration Type", MigrationTypeTxt);
        TotalErrors := DataMigrationError.Count();
        DataMigrationError.SetRange("Destination Table ID", 0);
        PostingErrors := DataMigrationError.Count();
        MigrationErrors := TotalErrors - PostingErrors;

        SLMigrationErrors.PostingErrorCount := PostingErrors;
        SLMigrationErrors.MigrationErrorCount := MigrationErrors;
        if not SLMigrationErrors.Insert() then
            SLMigrationErrors.Modify();
    end;

    var
        MigrationTypeTxt: Label 'Dynamics SL', Locked = true;
}