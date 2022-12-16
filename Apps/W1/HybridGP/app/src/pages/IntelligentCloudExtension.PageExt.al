pageextension 4015 "Intelligent Cloud Extension" extends "Intelligent Cloud Management"
{
    layout
    {
        addlast(FactBoxes)
        {
            part("Show Errors"; "Hybrid GP Errors Factbox")
            {
                ApplicationArea = Basic, Suite;
                Visible = FactBoxesVisible;
            }
            part("Show Detail Snapshot Errors"; "Hist. Migration Status Factbox")
            {
                ApplicationArea = Basic, Suite;
                Visible = FactBoxesVisible;
            }
        }
    }

    actions
    {
        addafter(RunReplicationNow)
        {
            action(ConfigureGPMigration)
            {
                Enabled = HasCompletedSetupWizard;
                ApplicationArea = Basic, Suite;
                Caption = 'Configure GP Migration';
                ToolTip = 'Configure migration settings for GP.';
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = Setup;

                trigger OnAction()
                var
                    GPMigrationConfiguration: Page "GP Migration Configuration";
                begin
                    GPMigrationConfiguration.ShouldShowManagementPromptOnClose(false);
                    GPMigrationConfiguration.Run();
                end;
            }

            action(ReRunHistoricalMigration)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Rerun GP Detail Snapshot';
                ToolTip = 'Rerun the migration of GP historical transactions based on your company settings.';
                Image = Process;

                trigger OnAction()
                var
                    GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
                    HybridCloudManagement: Codeunit "Hybrid Cloud Management";
                    HistMigrationStatusMgmt: Codeunit "Hist. Migration Status Mgmt.";
                begin
                    if not GPCompanyAdditionalSettings.GetMigrateHistory() then begin
                        Message(DetailSnapshotNotConfiguredMsg);
                        exit;
                    end;
                    if Confirm(ConfirmRerunQst) then begin
                        if not (HistMigrationStatusMgmt.GetCurrentStatus() = "Hist. Migration Step Type"::"Not Started") then
                            if Confirm(RerunAllQst) then
                                HistMigrationStatusMgmt.ResetAll();

                        HybridCloudManagement.CreateAndScheduleBackgroundJob(Codeunit::"GP Populate Hist. Tables", 'Migrate GP Historical Snapshot');
                        Message(SnapshotJobRunningMsg);
                    end;
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridCompany: Record "Hybrid Company";
        HybridGPWizard: Codeunit "Hybrid GP Wizard";
    begin
        if IntelligentCloudSetup.Get() then
            FactBoxesVisible := IntelligentCloudSetup."Product ID" = HybridGPWizard.ProductId();

        HybridCompany.SetRange(Replicate, true);
        HasCompletedSetupWizard := not HybridCompany.IsEmpty();
    end;

    var
        FactBoxesVisible: Boolean;
        HasCompletedSetupWizard: Boolean;
        DetailSnapshotNotConfiguredMsg: Label 'GP Detail Snapshot is not configured to migrate.';
        ConfirmRerunQst: Label 'Are you sure you want to rerun the GP Detail Snapshot migration?';
        RerunAllQst: Label 'Do you want to rerun the GP Detail Snapshot for all transaction types? This will clear any previous run attempts.';
        SnapshotJobRunningMsg: Label 'The GP Detail Snapshot job is running.';
}