page 4007 "Intelligent Cloud Ready"
{
    Caption = 'Cloud Ready Checklist';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(CloudreadyInfo)
            {
                ShowCaption = false;

                group(Checklist)
                {
                    ShowCaption = false;
                    InstructionalText = 'This process will disable your Cloud Migration environment and data migration from your on-premises solution. It is highly recommended that you work with your partner to complete this process if you intend to make your Business Central tenant your primary solution.';

                    field(Spacer1; '')
                    {
                        ApplicationArea = All;
                        Caption = '';
                        ShowCaption = false;
                        Editable = false;
                    }
                    group(RecommendedSteps)
                    {
                        Caption = 'Recommended Steps:';
                        field(ReadWhitePaperTxt; ReadMigrationWhitePaperTxt)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;

                            trigger OnDrillDown()
                            begin
                                Hyperlink(ReadWhitePaperURLTxt);
                            end;
                        }
                        field(ExitAllUsersTxt; HaveAllUsersExitTxt)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;
                        }
                        field(RunFullReplicationTxt; RunFullMigrationTxt)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;
                        }
                        field(CorrectErrorsTxt; FixErrorsTxt)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;
                        }
                        field(RunReplicationAgainTxt; RunMigrationAgainTxt)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;
                        }
                        field(DisableIntelligentCloudTxt; DisableMigrationTxt)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;
                        }
                        field(ReviewUserPermissionsTxt; ReviewPermissionsTxt)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;
                        }
#pragma warning disable AA0218
                        field(ChecklistAgreement; InAgreement)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'I have read and understand the recommended steps';
                            Enabled = IsSuperAndSetupComplete;
                        }
#pragma warning restore
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RunReplicationNow)
            {
                Enabled = IsSuperAndSetupComplete;
                Visible = false;
                ApplicationArea = Basic, Suite;
                Caption = 'Run Migration Now';
                ToolTip = 'Manually trigger Cloud Migration.';
                Image = Setup;
                ObsoleteState = Pending;
                ObsoleteReason = 'Conflicts with instructions/not needed here';
                ObsoleteTag = '17.0';

                trigger OnAction()
                var
                    HybridReplicationSummary: Record "Hybrid Replication Summary";
                    HybridCloudManagement: Codeunit "Hybrid Cloud Management";
                begin
                    HybridCloudManagement.RunReplication(HybridReplicationSummary.ReplicationType::Normal);
                    Message(RunReplicationTxt);
                end;
            }

            action(DisableReplication)
            {
                Enabled = IsSuperAndSetupComplete and InAgreement;
                ApplicationArea = Basic, Suite;
                Caption = 'Disable Cloud Migration';
                ToolTip = 'Disables Cloud Migration setup.';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    IntelligentCloudSetup: Record "Intelligent Cloud Setup";
                    HybridCloudManagement: Codeunit "Hybrid Cloud Management";
                    PermissionManager: Codeunit "Permission Manager";
                    UserPermissions: Codeunit "User Permissions";
                begin
                    if Dialog.Confirm(DisableReplicationConfirmQst, false) then begin
                        IntelligentCloudSetup.Get();
                        HybridCloudManagement.DisableMigration(IntelligentCloudSetup."Product ID", DisablereplicationTxt, true);
                        Message(DisablereplicationTxt);

                        IsSuperAndSetupComplete := PermissionManager.IsIntelligentCloud() and UserPermissions.IsSuper(UserSecurityId());
                        InAgreement := false;
                    end;
                end;
            }
            action(AdlSetup)
            {
                Enabled = CanSetupAdl;
                RunObject = page "Cloud Migration ADL Setup";
                ApplicationArea = Basic, Suite;
                Caption = 'Azure Data Lake';
                ToolTip = 'Migrate your on-premises data to Azure Data Lake.';
                Image = TransmitElectronicDoc;
                Promoted = true;
                PromotedCategory = Process;
            }
            action(PermissionSets)
            {
                Enabled = IsSuperAndSetupComplete;
                ApplicationArea = Basic, Suite;
                Caption = 'Permission Sets';
                RunObject = page "Permission Sets";
                RunPageMode = Edit;
                Image = Permission;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Review and modify assigned user permission sets.';
            }
        }
    }

    trigger OnOpenPage()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        PermissionManager: Codeunit "Permission Manager";
        UserPermissions: Codeunit "User Permissions";
    begin
        HybridReplicationSummary.SetRange(Status, HybridReplicationSummary.Status::InProgress);
        if not HybridReplicationSummary.IsEmpty() then
            Error(MustFinishMigrationsErr);

        IsSuperAndSetupComplete := PermissionManager.IsIntelligentCloud() and UserPermissions.IsSuper(UserSecurityId());
        CanSetupAdl := HybridCloudManagement.CanSetupAdlMigration();
    end;

    var
        DisableReplicationConfirmQst: Label 'You will no longer have the Cloud Migration setup. Are you sure you want to disable?';
        DisablereplicationTxt: Label 'Cloud Migration has been disabled.';
        RunReplicationTxt: Label 'Cloud migration has been started. You can track the status on the management page.';
        ReadMigrationWhitePaperTxt: Label '1. Read the Business Central Cloud Migration help.';
        ReadWhitePaperURLTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2009758', Locked = true;
        HaveAllUsersExitTxt: Label '2. Have all users exit both the cloud tenant and on-premises solution.';
        RunFullMigrationTxt: Label '3. Run a migration by selecting Run Migration Now within the Cloud Migration Management page.';
        FixErrorsTxt: Label '4. Correct any necessary errors.';
        RunMigrationAgainTxt: Label '5. Run the migration again if you had to make any corrections in step #4.', Comment = '#4 - reference to step 4';
        DisableMigrationTxt: Label '6. Disable Cloud Migration in the Actions menu above.';
        ReviewPermissionsTxt: Label '7. Review and make necessary updates to users, user groups and permission sets.';
        MustFinishMigrationsErr: Label 'In order to disable the cloud migration, you must first wait for any in progress migrations to finish.';
        InAgreement: Boolean;
        IsSuperAndSetupComplete: Boolean;
        CanSetupAdl: Boolean;
}