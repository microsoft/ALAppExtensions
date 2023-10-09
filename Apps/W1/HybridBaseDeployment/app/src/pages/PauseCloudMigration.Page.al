namespace Microsoft.DataMigration;

page 40038 "Pause Cloud Migration"
{
    Caption = 'Pause cloud migration';
    InsertAllowed = false;
    DeleteAllowed = false;
    PageType = NavigatePage;

    layout
    {
        area(Content)
        {
            group(Banner1)
            {
                InstructionalText = 'This process will disable the cloud migration for your environment and data migration from your on-premises solution. You can setup the migration again on the same or different enviroment.';
                Visible = Step1Visible;
                ShowCaption = false;

                field(Description; Description)
                {
                    ApplicationArea = All;
                    Caption = 'Additional details';
                    ToolTip = 'Specifies additional details why it was needed to disable cloud migration. Used for log purposes.';
                    MultiLine = true;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ActionCancel)
            {
                ApplicationArea = All;
                Caption = 'Cancel';
                ToolTip = 'Go to the previous page.';
                Image = Cancel;
                InFooterBar = true;

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Finish';
                ToolTip = 'Complete and disable cloud migration.';
                Image = Approve;
                InFooterBar = true;

                trigger OnAction()
                begin
                    DisableCloudMigration();
                    CurrPage.Close();
                end;
            }
        }
    }

    local procedure DisableCloudMigration(): Boolean
    var
        CurrentIntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        DisabledReason: Text;
    begin
        if Dialog.Confirm(DisableReplicationConfirmQst, false) then begin
            DisabledReason := GetStatusText();
            if Description <> '' then
                DisabledReason += ' ' + Description;
            CurrentIntelligentCloudSetup.Get();
            HybridCloudManagement.DisableMigration(CurrentIntelligentCloudSetup."Product ID", DisabledReason, true);

            CurrentIntelligentCloudSetup.Get();
            CurrentIntelligentCloudSetup.DisabledReason := GlobalIntelligentCloudSetup.DisabledReason;
            CurrentIntelligentCloudSetup.Modify();
            Message(DisablereplicationTxt);
            exit(true);
        end;

        exit(false);
    end;

    local procedure GetStatusText(): Text
    begin
        if GlobalIntelligentCloudSetup.DisabledReason = GlobalIntelligentCloudSetup.DisabledReason::Paused then
            exit(CloudMigrationWasPausedTxt);

        if GlobalIntelligentCloudSetup.DisabledReason = GlobalIntelligentCloudSetup.DisabledReason::Abandoned then
            exit(CloudMigrationWasAbandonedTxt);
    end;

    trigger OnOpenPage()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
    begin
        HybridReplicationSummary.SetRange(Status, HybridReplicationSummary.Status::InProgress);
        if not HybridReplicationSummary.IsEmpty() then
            Error(MustFinishMigrationsErr);

        if GlobalIntelligentCloudSetup.DisabledReason = GlobalIntelligentCloudSetup.DisabledReason::Abandoned then
            CurrPage.Caption(AbandonCloudMigrationLbl);

        Step1Visible := true;
    end;

    internal procedure SetAbandoned()
    begin
        GlobalIntelligentCloudSetup.DisabledReason := GlobalIntelligentCloudSetup.DisabledReason::Abandoned;
    end;

    internal procedure SetPaused()
    begin
        GlobalIntelligentCloudSetup.DisabledReason := GlobalIntelligentCloudSetup.DisabledReason::Paused;
    end;

    var
        GlobalIntelligentCloudSetup: Record "Intelligent Cloud Setup";
        DisableReplicationConfirmQst: Label 'You will no longer have the cloud migration setup. Are you sure you want to disable?';
        CloudMigrationWasAbandonedTxt: Label 'Cloud migration was abandoned.';
        CloudMigrationWasPausedTxt: Label 'Cloud migration was paused.';
        DisablereplicationTxt: Label 'Cloud migration has been disabled.';
        MustFinishMigrationsErr: Label 'In order to disable the cloud migration, you must first wait for any in progress migrations to finish.';
        Description: Text;
        Step1Visible: Boolean;
        AbandonCloudMigrationLbl: Label 'Abandon cloud migration';
}