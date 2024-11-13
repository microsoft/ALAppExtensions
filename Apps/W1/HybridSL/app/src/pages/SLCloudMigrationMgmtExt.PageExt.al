pageextension 47001 "SL Cloud Migration Mgmt. Ext." extends "Cloud Migration Management"
{
    layout
    {
        addlast(CloudMigration)
        {
            group(SLCloudMigrationErrors)
            {
                Editable = false;
                ShowCaption = false;
                Visible = SLMigrationEnabled;
                group("SL Cloud Migration")
                {
                    ShowCaption = false;
                    field("SL Cloud Migration Warnings"; MigrationWarningCount)
                    {
                        ApplicationArea = All;
                        Caption = 'SL Cloud Migration Warnings';
                        ToolTip = 'Indicates the number of migration warning entries.';

                        trigger OnDrillDown()
                        begin
                            Page.Run(Page::"SL Migration Warnings");
                        end;
                    }
                    field("SL Cloud Migration Errors"; MigrationErrorCount)
                    {
                        ApplicationArea = All;
                        Caption = 'SL Cloud Migration Errors';
                        ToolTip = 'Indicates the number of SL migration error entries.';

                        trigger OnDrillDown()
                        begin
                            Page.Run(Page::"SL Migration Error Overview");
                        end;
                    }
                    field("SL Posting Errors"; PostingErrorCount)
                    {
                        ApplicationArea = All;
                        Caption = 'Posting Errors';
                        Style = Unfavorable;
                        StyleExpr = (PostingErrorCount > 0);
                        ToolTip = 'Indicates the number of posting errors that occurred during the migration.';

                        trigger OnDrillDown()
                        begin
                            Page.Run(Page::"SL Migration Warnings");
                        end;
                    }
                    field("SL Failed Companies"; FailedCompanyCount)
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
                    field("SL Failed Batches"; FailedBatchCount)
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
                }
            }
        }
    }

    actions
    {
        addafter(RunReplicationNow)
        {
            action(SLConfigureMigration)
            {
                ApplicationArea = All;
                Caption = 'Configure SL Migration';
                Enabled = HasCompletedSetupWizard;
                Image = Setup;
                ToolTip = 'Configure migration settings for SL';
                Visible = SLMigrationEnabled;

                trigger OnAction()
                var
                    SLMigrationConfiguration: Page "SL Migration Configuration";
                begin
                    SLMigrationConfiguration.ShouldShowManagementPromptOnClose(false);
                    SLMigrationConfiguration.Run();
                end;
            }
        }

        addafter(RunDataUpgrade)
        {
            action(SLReRunHistoricalMigration)
            {
                ApplicationArea = All;
                Caption = 'Rerun SL Historical Snapshot';
                Enabled = HasCompletedSetupWizard;
                Image = Archive;
                ToolTip = 'Rerun SL Historical Snapshot';
                Visible = SLMigrationEnabled;

                trigger OnAction()
                var
                    SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
                    SLWizardIntegration: Codeunit "SL Wizard Integration";
                begin
                    if not SLCompanyAdditionalSettings.GetMigrateHistory() then begin
                        Message(DetailSnapshotNotConfiguredMsg);
                        exit;
                    end;

                    if Confirm(ConfirmRerunQst) then
                        SLWizardIntegration.ScheduleSLHistoricalSnapshotMigration();
                end;
            }
        }
        addfirst(Category_Process)
        {
            actionref(SLConfigureMigration_Promoted; SLConfigureMigration)
            {
            }
        }
    }

    trigger OnOpenPage()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridCompany: Record "Hybrid Company";
        SLConfiguration: Record "SL Migration Config";
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        SLHybridWizard: Codeunit "SL Hybrid Wizard";
    begin
        if IntelligentCloudSetup.Get() then
            SLMigrationEnabled := SLHybridWizard.CanHandle(IntelligentCloudSetup."Product ID");

        if SLMigrationEnabled then begin
            HybridCompany.SetRange(Replicate, true);
            HasCompletedSetupWizard := not HybridCompany.IsEmpty();

            if HybridCompany.Get(CompanyName()) then begin
                SLConfiguration.GetSingleInstance();
                if GetHasCompletedMigration() then
                    if SLCompanyAdditionalSettings.GetMigrateHistory() then
                        if not SLConfiguration.HasHistoricalJobRan() then
                            ShowSLHistoricalJobNeedsToRunNotification();
            end;
        end;
    end;

    internal procedure GetHasCompletedMigration(): Boolean
    var
        DataMigrationStatus: Record "Data Migration Status";
    begin
        DataMigrationStatus.SetFilter(Status, '%1|%2', DataMigrationStatus.Status::Completed, DataMigrationStatus.Status::"Completed with Errors");
        exit(not DataMigrationStatus.IsEmpty());
    end;

    internal procedure ShowSLHistoricalJobNeedsToRunNotification()
    var
        SLHistoricalSnapshotJobHasNotRanNotification: Notification;
    begin
        SLHistoricalSnapshotJobHasNotRanNotification.Id := '253A52DA-F9F8-4B2E-B3C2-2E42DD8B97D5';
        SLHistoricalSnapshotJobHasNotRanNotification.Recall();
        SLHistoricalSnapshotJobHasNotRanNotification.Message := HistoricalDataJobNotRanMsg;
        SLHistoricalSnapshotJobHasNotRanNotification.Scope := NotificationScope::LocalScope;
        SLHistoricalSnapshotJobHasNotRanNotification.AddAction(HistoricalDataStartJobMsg, Codeunit::"SL Wizard Integration", 'StartSLHistoricalJobMigrationAction');
        SLHistoricalSnapshotJobHasNotRanNotification.Send();
    end;

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
        SLMigrationErrors: Record "SL Migration Errors";
        DataMigrationError: Record "Data Migration Error";
        TotalErrors: Integer;
        MigrationErrors: Integer;
        MigrationTypeTxt: Label 'Dynamics SL', Locked = true;
    begin
        FailedBatchCount := 0;
        FailedBatchMsg := 'One or more batches failed to post.\';

        SLMigrationErrorOverview.SetRange("Error Dismissed", false);
        MigrationErrorCount := SLMigrationErrorOverview.Count();
        HybridCompanyStatus.SetRange("Upgrade Status", HybridCompanyStatus."Upgrade Status"::Failed);
        FailedCompanyCount := HybridCompanyStatus.Count();
        MigrationWarningCount := SLMigrationWarnings.Count();

        if FailedBatchCount = 0 then
            FailedBatchMsg := 'No failed batches';

        SLMigrationErrors.Init();

        DataMigrationError.SetRange("Migration Type", MigrationTypeTxt);
        TotalErrors := DataMigrationError.Count();

        SLMigrationWarnings.SetRange("Migration Area", 'Batch Posting');
        PostingErrorCount := SLMigrationWarnings.Count();
        MigrationErrors := TotalErrors;

        SLMigrationErrors.PostingErrorCount := PostingErrorCount;
        SLMigrationErrors.MigrationErrorCount := MigrationErrors;
        if not SLMigrationErrors.Insert() then
            SLMigrationErrors.Modify();
    end;

    var
        HasCompletedSetupWizard: Boolean;
        SLMigrationEnabled: Boolean;
        MigrationErrorCount: Integer;
        FailedCompanyCount: Integer;
        FailedBatchCount: Integer;
        PostingErrorCount: Integer;
        MigrationWarningCount: Integer;
        ConfirmRerunQst: Label 'Are you sure you want to rerun the SL Historical Snapshot migration?';
        DetailSnapshotNotConfiguredMsg: Label 'SL Historical Snapshot is not configured to migrate.';
        HistoricalDataJobNotRanMsg: Label 'The SL Historical Snapshot job has not ran.';
        HistoricalDataStartJobMsg: Label 'Start SL Historical Snapshot job.';
        FailedBatchMsg: Text;
}
