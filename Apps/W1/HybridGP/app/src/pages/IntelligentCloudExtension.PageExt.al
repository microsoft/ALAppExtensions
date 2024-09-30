namespace Microsoft.DataMigration.GP;

using Microsoft.DataMigration.GP.HistoricalData;
using Microsoft.DataMigration;
using System.Security.User;
using System.Integration;

pageextension 4015 "Intelligent Cloud Extension" extends "Intelligent Cloud Management"
{
    layout
    {
        addlast(FactBoxes)
        {
            part("Show Errors"; "Hybrid GP Errors Factbox")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
#if not CLEAN24
            part(Errors; "Hybrid GP Errors Overview Fb")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteReason = 'Replaced by Overview part.';
                ObsoleteTag = '24.0';
            }
#endif
            part(Overview; "Hybrid GP Overview Fb")
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
        modify(RunDataUpgrade)
        {
            Visible = UseTwoStepProcess;
        }

        addafter(RunReplicationNow)
        {
            action(ConfigureGPMigration)
            {
                Enabled = HasCompletedSetupWizard;
                ApplicationArea = All;
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
                Enabled = IsSuper and HasCompletedSetupWizard;
                ApplicationArea = All;
                Caption = 'Rerun GP Detail Snapshot';
                ToolTip = 'Rerun the migration of GP historical transactions based on your company settings.';
                Image = Process;

                trigger OnAction()
                var
                    GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
                    HistMigrationCurrentStatus: Record "Hist. Migration Current Status";
                    GPHistSourceProgress: Record "GP Hist. Source Progress";
                    WizardIntegration: Codeunit "Wizard Integration";
                begin
                    if not GPCompanyAdditionalSettings.GetMigrateHistory() then begin
                        Message(DetailSnapshotNotConfiguredMsg);
                        exit;
                    end;

                    if Confirm(ConfirmRerunQst) then begin
                        if not GPHistSourceProgress.IsEmpty() then begin
                            HistMigrationCurrentStatus.EnsureInit();
                            HistMigrationCurrentStatus."Reset Data" := Confirm(ResetPreviousRunQst);
                            HistMigrationCurrentStatus.Modify();
                        end;

                        WizardIntegration.ScheduleGPHistoricalSnapshotMigration();
                    end;
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridCompany: Record "Hybrid Company";
        GPConfiguration: Record "GP Configuration";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPUpgradeSettings: Record "GP Upgrade Settings";
        HybridGPWizard: Codeunit "Hybrid GP Wizard";
        UserPermissions: Codeunit "User Permissions";
    begin
        IsSuper := UserPermissions.IsSuper(UserSecurityId());

        if IntelligentCloudSetup.Get() then
            FactBoxesVisible := IntelligentCloudSetup."Product ID" = HybridGPWizard.ProductId();

        HybridCompany.SetRange(Replicate, true);
        HasCompletedSetupWizard := not HybridCompany.IsEmpty();

        GPUpgradeSettings.GetonInsertGPUpgradeSettings(GPUpgradeSettings);
        UseTwoStepProcess := not GPUpgradeSettings."One Step Upgrade";

        if HybridCompany.Get(CompanyName()) then begin
            GPConfiguration.GetSingleInstance();
            if GetHasCompletedMigration() then
                if GPCompanyAdditionalSettings.GetMigrateHistory() then
                    if not GPConfiguration.HasHistoricalJobRan() then
                        ShowGPHistoricalJobNeedsToRunNotification();
        end;
    end;

    local procedure GetHasCompletedMigration(): Boolean
    var
        DataMigrationStatus: Record "Data Migration Status";
    begin
        DataMigrationStatus.SetFilter(Status, '%1|%2', DataMigrationStatus.Status::Completed, DataMigrationStatus.Status::"Completed with Errors");
        exit(not DataMigrationStatus.IsEmpty());
    end;

    local procedure ShowGPHistoricalJobNeedsToRunNotification()
    var
        GPHistoricalSnapshotJobHasNotRanNotification: Notification;
    begin
        GPHistoricalSnapshotJobHasNotRanNotification.Id := '143A52DA-E9F8-4B2E-A3C2-2E42DD8B97D4';
        GPHistoricalSnapshotJobHasNotRanNotification.Recall();
        GPHistoricalSnapshotJobHasNotRanNotification.Message := HistoricalDataJobNotRanMsg;
        GPHistoricalSnapshotJobHasNotRanNotification.Scope := NotificationScope::LocalScope;
        GPHistoricalSnapshotJobHasNotRanNotification.AddAction(HistoricalDataStartJobMsg, Codeunit::"Wizard Integration", 'StartGPHistoricalJobMigrationAction');
        GPHistoricalSnapshotJobHasNotRanNotification.Send();
    end;

    var
        IsSuper: Boolean;
        FactBoxesVisible: Boolean;
        HasCompletedSetupWizard: Boolean;
        UseTwoStepProcess: Boolean;
        DetailSnapshotNotConfiguredMsg: Label 'GP Historical Snapshot is not configured to migrate.';
        ConfirmRerunQst: Label 'Are you sure you want to rerun the GP Historical Snapshot migration?';
        ResetPreviousRunQst: Label 'Do you want to reset your previous GP Historical Snapshot migration? Choose No if you want to continue progress from the previous attempt.';
        HistoricalDataJobNotRanMsg: Label 'The GP Historical Snapshot job has not ran.';
        HistoricalDataStartJobMsg: Label 'Start GP Historical Snapshot job.';
}
