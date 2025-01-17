namespace Microsoft.DataMigration;

using System.Environment;
using System.Integration;
using System.Telemetry;
using System.Security.AccessControl;
using System.Security.User;
using Microsoft.API.Upgrade;

page 40063 "Cloud Migration Management"
{
    Caption = 'Cloud Migration Management';
    PageType = ListPlus;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    RefreshOnActivate = true;
    DataCaptionExpression = PageCaptionTxt;
    Permissions = tabledata "Intelligent Cloud Status" = rimd;

    layout
    {
        area(Content)
        {
            group(CloudMigration)
            {
                Editable = false;

                ShowCaption = false;
                group(OveralInformation)
                {
                    ShowCaption = false;
                    field(OverallStatus; StatusTxt)
                    {
                        ApplicationArea = All;
                        StyleExpr = StatusTxtStyle;
                        Caption = 'Status';
                        Tooltip = 'Indicates the number of remaining tables to migrate for the selected migration.';

                        trigger OnDrillDown()
                        begin
                            if MoreInformationTxt <> '' then
                                Message(MoreInformationTxt)
                            else
                                Message(StatusTxt);
                        end;
                    }
                }

                group(MigrationStatistics)
                {
                    ShowCaption = false;

                    group(RunStatistics)
                    {
                        Caption = 'Run statistics';
                        ShowCaption = false;

                        group(TablesRemainingGroup)
                        {
                            ShowCaption = false;
                            Visible = TablesRemainingVisible;
                            field("Tables Remaining"; TotalTablesRemainingCount)
                            {
                                ApplicationArea = All;
                                Caption = 'Tables remaining';
                                Tooltip = 'Indicates the number of remaining tables to migrate for the selected migration.';

                                trigger OnDrillDown()
                                var
                                    HybridReplicationStatistics: Codeunit "Hybrid Replication Statistics";
                                begin
                                    HybridReplicationStatistics.OpenTablesRemaining();
                                end;
                            }
                        }
                        field("Tables Successful"; TotalSuccessfulTablesCount)
                        {
                            ApplicationArea = All;
                            Caption = 'Tables successful';
                            Tooltip = 'Indicates the number of tables that were successful for the selected migration.';
                            Style = Favorable;
                            StyleExpr = (TotalSuccessfulTablesCount > 0);

                            trigger OnDrillDown()
                            var
                                HybridReplicationStatistics: Codeunit "Hybrid Replication Statistics";
                            begin
                                HybridReplicationStatistics.ShowSuccessfulTables();
                            end;
                        }

                        group(TablesFailedGroup)
                        {
                            ShowCaption = false;
                            Visible = TablesFailedVisible;
                            field("Tables Failed"; TotalTablesFailedCount)
                            {
                                ApplicationArea = All;
                                Caption = 'Tables failed';
                                Tooltip = 'Indicates the number of tables that failed for the selected migration.';
                                Style = Unfavorable;
                                StyleExpr = (TotalTablesFailedCount > 0);

                                trigger OnDrillDown()
                                var
                                    HybridReplicationStatistics: Codeunit "Hybrid Replication Statistics";
                                begin
                                    HybridReplicationStatistics.ShowFailedTables();
                                end;
                            }
                        }
                        group(WarningsGroup)
                        {
                            ShowCaption = false;
                            Visible = WarningsVisible;
                            field("Tables with Warnings";
                            TotalTablesWithWarningsCount)
                            {
                                ApplicationArea = All;
                                Caption = 'Warnings';
                                Tooltip = 'Indicates the number of tables that had warnings for the selected migration.';
                                Style = Ambiguous;
                                StyleExpr = (TotalTablesWithWarningsCount > 0);

                                trigger OnDrillDown()
                                var
                                    HybridReplicationStatistics: Codeunit "Hybrid Replication Statistics";
                                begin
                                    HybridReplicationStatistics.OpenLastRunTablesStatus(DummyHybridReplicationDetail.Status::Warning);
                                end;
                            }
                        }
                    }
                    group(Companies)
                    {
                        ShowCaption = false;
                        group(CompaniesReplicatedGroup)
                        {
                            ShowCaption = false;
                            Visible = CompaniesStatusText <> '';

                            field(CompaniesStatusText; CompaniesStatusText)
                            {
                                ApplicationArea = All;
                                Caption = 'Companies status';
                                Tooltip = 'Indicates the number of companies that was moved to SaaS, number of companies in progress and a total number of companies.';

                                trigger OnDrillDown()
                                var
                                    HybridReplicaitonStatistics: Codeunit "Hybrid Replication Statistics";
                                begin
                                    Page.RunModal(Page::"Hybrid Companies Management");
                                    CompaniesStatusText := HybridReplicaitonStatistics.GetCompaniesOverviewText();
                                end;
                            }
                        }
                        group(NotInitializedCompanies)
                        {
                            ShowCaption = false;
                            Visible = NotInitializedCompaniesVisible;
                            field("Not Initialized Companies"; NotInitializedCompaniesCount)
                            {
                                ApplicationArea = All;
                                Caption = 'Not initialized companies';
                                Tooltip = 'Indicates the number of companies that must be initialized before they can be used.';
                                Style = Unfavorable;
                                StyleExpr = (NotInitializedCompaniesCount > 0);

                                trigger OnDrillDown()
                                begin
                                    Page.Run(Page::"Hybrid Companies List");
                                end;
                            }
                        }
                    }
                }
            }
            part(HybridMigrationLog; "Hybrid Migration Log")
            {
                Caption = 'Migration log';
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RunReplicationNow)
            {
                Enabled = IsSuper and IsSetupComplete;
                Visible = not IsOnPrem;
                ApplicationArea = All;
                Caption = 'Run data replication';
                ToolTip = 'Start the data replication for selected companies.';
                Image = Setup;

                trigger OnAction()
                var
                    HybridCloudManagement: Codeunit "Hybrid Cloud Management";
                begin
                    HybridCloudManagement.VerifyCanStartReplication();
                    if not Dialog.Confirm(RunReplicationConfirmQst, false) then
                        exit;

                    HybridCloudManagement.RunReplication(LastHybridReplicationSummary.ReplicationType::Normal);

                    Message(RunReplicationTxt);
                end;
            }

            action(RunDataUpgrade)
            {
                Enabled = IsSuper and IsSetupComplete;
                Visible = not IsOnPrem;
                ApplicationArea = All;
                Caption = 'Run data upgrade';
                ToolTip = 'Start the upgrade after cloud migration.';
                Image = Process;

                trigger OnAction()
                var
                    HybridCloudManagement: Codeunit "Hybrid Cloud Management";
                begin
                    HybridCloudManagement.RunDataUpgrade(LastHybridReplicationSummary);
                end;
            }

            action(RunDiagnostic)
            {
                Enabled = IsSuper and IsSetupComplete;
                Visible = not IsOnPrem and DiagnosticRunsEnabled;
                ApplicationArea = All;
                Caption = 'Create diagnostic run';
                ToolTip = 'Start a diagnostic run of the Cloud Migration. No data will be copied, it is used to test the data.';
                Image = Tools;

                trigger OnAction()
                var
                    DummyHybridReplicationSummary: Record "Hybrid Replication Summary";
                    HybridCloudManagement: Codeunit "Hybrid Cloud Management";
                begin
                    HybridCloudManagement.VerifyCanStartReplication();
                    HybridCloudManagement.RunReplication(DummyHybridReplicationSummary.ReplicationType::Diagnostic);
                end;
            }

            action(RefreshStatus)
            {
                Enabled = IsSuper and IsSetupComplete;
                Visible = not IsOnPrem;
                ApplicationArea = All;
                Caption = 'Refresh status';
                ToolTip = 'Refresh the status of in-progress migration runs.';
                Image = RefreshLines;

                trigger OnAction()
                var
                    HybridCloudManagement: Codeunit "Hybrid Cloud Management";
                begin
                    SelectLatestVersion();
                    if LastHybridReplicationSummary.Status = LastHybridReplicationSummary.Status::UpgradePending then begin
                        CurrPage.Update();
                        exit;
                    end;

                    if CanRefresh() then begin
                        HybridCloudManagement.RefreshReplicationStatus();
                        LastRefresh := CurrentDateTime();
                    end;
                    HybridCloudManagement.GetLastReplicationSummary(LastHybridReplicationSummary);
                    HybridCloudManagement.GetCloudMigrationStatusText(StatusTxt, StatusTxtStyle, MoreInformationTxt);
                    UpdateTablesStatistics();
                    UpdateControlProperties();
                    CurrPage.Update();
                    WarnAboutNonInitializedCompanies();
                end;
            }

            action(ResetAllCloudData)
            {
                Enabled = IsSuper and IsSetupComplete;
                Visible = not IsOnPrem;
                ApplicationArea = All;
                Caption = 'Reset cloud data';
                ToolTip = 'Resets migration enabled data in the cloud tenant.';
                Image = Restore;

                trigger OnAction()
                var
                    HybridCloudManagement: Codeunit "Hybrid Cloud Management";
                begin
                    if not Dialog.Confirm(ResetCloudDataConfirmQst, false) then
                        exit;

                    HybridCloudManagement.ResetCloudData();
                    Message(ResetCompletedTxt);
                end;
            }

            action(PrepareTables)
            {
                Enabled = IsSuper and IsSetupComplete;
                Visible = IsOnPrem;
                ApplicationArea = All;
                Caption = 'Prepare tables for replication';
                ToolTip = 'Gets the candidate tables ready for replication';
                Image = SuggestTables;

                trigger OnAction()
                begin
                    HybridDeployment.PrepareTablesForReplication();
                    Message(TablesReadyForReplicationMsg);
                end;
            }

            action(GetRuntimeKey)
            {
                Enabled = IsSuper and IsSetupComplete;
                Visible = not IsOnPrem;
                ApplicationArea = All;
                Caption = 'Get runtime service key';
                ToolTip = 'Gets the integration runtime key.';
                Image = EncryptionKeys;

                trigger OnAction()
                var
                    PrimaryKey: Text;
                    SecondaryKey: Text;
                begin
                    HybridDeployment.GetIntegrationRuntimeKeys(PrimaryKey, SecondaryKey);
                    Message(IntegrationKeyTxt, PrimaryKey);
                end;
            }

            action(GenerateNewKey)
            {
                Enabled = IsSuper and IsSetupComplete;
                Visible = not IsOnPrem;
                ApplicationArea = All;
                Caption = 'Reset runtime service key';
                ToolTip = 'Resets integration runtime service key.';
                Image = New;

                trigger OnAction()
                var
                    PrimaryKey: Text;
                    SecondaryKey: Text;
                begin
                    if Dialog.Confirm(RegenerateNewKeyConfirmQst, false) then begin
                        HybridDeployment.RegenerateIntegrationRuntimeKeys(PrimaryKey, SecondaryKey);
                        Message(NewIntegrationKeyTxt, PrimaryKey);
                    end;
                end;
            }

            action(CompleteCloudMigration)
            {
                Enabled = IsSuper and IsSetupComplete;
                Visible = not IsOnPrem;
                ApplicationArea = All;
                Caption = 'Complete migration';
                ToolTip = 'Completes cloud migration setup.';
                Image = Completed;

                trigger OnAction()
                var
                    HybridCloudManagement: Codeunit "Hybrid Cloud Management";
                    IntelligentCloudReady: Page "Intelligent Cloud Ready";
                begin
                    HybridCloudManagement.VerifyCanCompleteCloudMigration();
                    IntelligentCloudReady.RunModal();
                end;
            }

            action(PauseCloudMigration)
            {
                Enabled = IsSuper and IsSetupComplete;
                Visible = not IsOnPrem;
                ApplicationArea = All;
                Caption = 'Pause migration';
                ToolTip = 'Pauses cloud migration. Use this action if you want to continue cloud migration in the future.';
                Image = Pause;

                trigger OnAction()
                var
                    PauseCloudMigration: Page "Pause Cloud Migration";
                begin
                    PauseCloudMigration.SetPaused();
                    PauseCloudMigration.RunModal();
                    CurrPage.Update(false);
                end;
            }

            action(AbandonCloudMigration)
            {
                Enabled = IsSuper and IsSetupComplete;
                Visible = not IsOnPrem;
                ApplicationArea = All;
                Caption = 'Abandon migration';
                ToolTip = 'Abandons cloud migration. Use this action if you do not want to start the cloud migration again in this environment.';
                Image = Delete;

                trigger OnAction()
                var
                    PauseCloudMigration: Page "Pause Cloud Migration";
                begin
                    PauseCloudMigration.SetAbandoned();
                    PauseCloudMigration.RunModal();
                    CurrPage.Update(false);
                end;
            }

            action(CheckForUpdate)
            {
                Enabled = IsSuper and IsSetupComplete;
                Visible = not IsOnPrem;
                ApplicationArea = All;
                Caption = 'Check for update';
                ToolTip = 'Checks if an update is available for your cloud migration ADF pipeline.';
                RunObject = page "Intelligent Cloud Update";
                RunPageMode = Edit;
                Image = Setup;
            }

            action(UpdateReplicationCompanies)
            {
                Enabled = IsSuper and IsSetupComplete and UpdateReplicationCompaniesEnabled;
                Visible = not IsOnPrem and UpdateReplicationCompaniesEnabled;
                ApplicationArea = All;
                Caption = 'Select companies to replicate';
                ToolTip = 'Select companies to replicate';
                Image = Setup;

                trigger OnAction()
                var
                    HybridReplicationStatistics: Codeunit "Hybrid Replication Statistics";
                begin
                    Page.RunModal(Page::"Hybrid Companies Management");
                    CompaniesStatusText := HybridReplicationStatistics.GetCompaniesOverviewText();
                end;
            }

            action(SetupChecklist)
            {
                Enabled = IsSuper and IsMigratedCompany;
                Visible = not IsOnPrem and SetupChecklistEnabled;
                ApplicationArea = All;
                Caption = 'Setup checklist';
                ToolTip = 'Setup checklist';
                RunObject = page "Post Migration Checklist";
                RunPageMode = Edit;
                Image = Setup;
            }

            action(MapUsers)
            {
                Enabled = IsSuper;
                Visible = not IsOnPrem and MapUsersEnabled;
                ApplicationArea = All;
                Caption = 'Define user mappings';
                ToolTip = 'When all data is replicated, define user mappings to rename the business data that depends on the user name. The On-Prem user name will be renamed with SaaS user name.';
                RunObject = page "Migration User Mapping";
                RunPageMode = Edit;
                Image = Setup;
            }

            action(RepairCompanionTableRecordConsistency)
            {
                Visible = not IsOnPrem;
                ApplicationArea = All;
                Caption = 'Repair companion table records';
                ToolTip = 'This action will insert missing records in the table extensions. Use this action if records were copied but are not showing up in the UI.';
                Image = Database;

                trigger OnAction()
                var
                    HybridCloudManagement: Codeunit "Hybrid Cloud Management";
                begin
                    HybridCloudManagement.RepairCompanionTableRecordConsistency();
                end;
            }

            action(ManageCustomTables)
            {
                Enabled = IsSuper;
                Visible = not IsOnPrem;
                ApplicationArea = All;
                Caption = 'Manage custom tables';
                ToolTip = 'Manage custom table mappings for the migration. This functionality can be used to rename the table during replication or to split OnPrem table with customizations to main table and table extensions.';
                RunObject = page "Migration Table Mapping";
                RunPageMode = Edit;
                Image = TransferToGeneralJournal;
            }
            action(AdlSetup)
            {
                Enabled = AdlSetupEnabled;
                Visible = AdlSetupEnabled;
                RunObject = page "Cloud Migration ADL Setup";
                ApplicationArea = All;
                Caption = 'Azure Data Lake';
                ToolTip = 'Migrate your on-premises data to Azure Data Lake.';
                Image = TransmitElectronicDoc;
            }
            action(SetupCloudMigration)
            {
                Enabled = IsSuper;
                Visible = not IsOnPrem;
                RunObject = page "Hybrid Cloud Setup Wizard";
                ApplicationArea = All;
                Caption = 'Setup cloud migration';
                ToolTip = 'Sets up the cloud migration for the OnPrem database to SaaS.';
                Image = Setup;
            }
            action(SanitizeTableRecords)
            {
                Enabled = IsSuper;
                Visible = not IsOnPrem;
                RunObject = page "Cloud Migration Sanitize Table";
                ApplicationArea = All;
                Caption = 'Sanitize tables';
                ToolTip = 'Sanitizes the data in the code fields so they can be used in the product. Invoke-NAVSanitizeField action should be used instead before cloud migration. If that was not done, this action can help to solve the issue.';
                Image = Setup;
            }

            action(EnableDisableNewUI)
            {
                Enabled = IsSuper and IsSetupComplete;
                Visible = not IsOnPrem;
                ApplicationArea = Basic, Suite;
                Caption = 'Enable/Disable new UI';
                ToolTip = 'Allows to enable or disable the new UI.';
                Image = ChangeLog;

                trigger OnAction()
                var
                    IntelligentCloudSetup: Record "Intelligent Cloud Setup";
                    IntelligentCloudManagement: Page "Intelligent Cloud Management";
                begin
                    if IntelligentCloudSetup.ChangeUI() then
                        if not IntelligentCloudManagement.GetUseNewUI() then begin
                            Page.Run(Page::"Intelligent Cloud Management");
                            CurrPage.Close();
                        end;
                end;
            }

            action(SkipRemovingPemissionsFromUsers)
            {
                Enabled = IsSuper;
                Visible = not IsOnPrem;
                ApplicationArea = Basic, Suite;
                Caption = 'Enable/Disable Removing Permissions from Users';
                ToolTip = 'Allows change the behavior if user permissions should be removed when the cloud migration is setup.';
                Image = ChangeLog;

                trigger OnAction()
                var
                    HybridCloudManagement: Codeunit "Hybrid Cloud Management";
                begin
                    HybridCloudManagement.ChangeRemovePermissionsFromUsers();
                end;
            }
            action(ChangeTheWayDataIsReplicated)
            {
                Enabled = IsSuper;
                Visible = not IsOnPrem;
                ApplicationArea = Basic, Suite;
                Caption = 'Change how the data is replicated';
                ToolTip = 'Allows defining which data is replicated and how. You can include or exclude the tables from the cloud migration and define if a table keeps existing data (delta sync) or replaces the entire table.';
                Image = ChangeLog;

                trigger OnAction()
                var
                    IntelligentCloudStatus: Record "Intelligent Cloud Status";
                    CloudMigReplicateDataMgt: Codeunit "Cloud Mig. Replicate Data Mgt.";
                begin
                    CloudMigReplicateDataMgt.LoadRecords(IntelligentCloudStatus);

                    if IntelligentCloudStatus.FindFirst() then
                        Page.Run(Page::"Cloud Mig - Select Tables", IntelligentCloudStatus);
                end;
            }
            action(SkipApiUpgrade)
            {
                Visible = not IsOnPrem;
                ApplicationArea = Basic, Suite;
                Caption = 'Manage API Upgrade';
                ToolTip = 'Allows to skip the API upgrade and run it later after the cloud migraiton is completed.';
                Image = ChangeLog;
                RunObject = page "API Data Upgrade Companies";
            }
        }

        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process', Comment = 'Promoted actions for Cloud Migration page.';

                actionref(RunReplicationNow_Promoted; RunReplicationNow)
                {
                }
                actionref(RunDataUpgrade_Promoted; RunDataUpgrade)
                {
                }
                actionref(RefreshStatus_Promoted; RefreshStatus)
                {
                }
                group(Category_Category6)
                {
                    Caption = 'Complete';
                    ShowAs = SplitButton;

                    actionref(CompleteCloudMigration_Promoted; CompleteCloudMigration)
                    {
                    }
                    actionref(PauseCloudMigration_Promoted; PauseCloudMigration)
                    {
                    }
                    actionref(AbandonCloudMigration_Promoted; AbandonCloudMigration)
                    {
                    }
                }

                actionref(ManageCustomTables_Promoted; ManageCustomTables)
                {
                }
                actionref(MapUsers_Promoted; MapUsers)
                {
                }
                actionref(RunDiagnostic_Promoted; RunDiagnostic)
                {
                }
            }
        }
    }

    trigger OnInit()
    begin
        SelectLatestVersion();
    end;

    trigger OnOpenPage()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        EnvironmentInformation: Codeunit "Environment Information";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        IntelligentCloudNotifier: Codeunit "Intelligent Cloud Notifier";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        PermissionManager: Codeunit "Permission Manager";
        UserPermissions: Codeunit "User Permissions";
    begin
        CheckNewUISupported();
        FeatureTelemetry.LogUptake('0000JMI', HybridCloudManagement.GetFeatureTelemetryName(), Enum::"Feature Uptake Status"::Discovered);
        IsSuper := UserPermissions.IsSuper(UserSecurityId());
        if not IsSuper then
            SendUserIsNotSuperNotification();

        SendRepairDataNotification();
        IsOnPrem := not EnvironmentInformation.IsSaaS();

        if (not PermissionManager.IsIntelligentCloud()) and (not IsOnPrem) then
            SendSetupIntelligentCloudNotification();

        UpdateTablesStatistics();
        UpdateControlProperties();
        CanRunDiagnostic(DiagnosticRunsEnabled);
        CanShowSetupChecklist(SetupChecklistEnabled);
        CanShowMapUsers(MapUsersEnabled);
        UpdateReplicationCompaniesEnabled := true;
        CanShowUpdateReplicationCompanies(UpdateReplicationCompaniesEnabled);
        CanMapCustomTables(CustomTablesEnabled);

        if IntelligentCloudSetup.Get() then
            HybridDeployment.Initialize(IntelligentCloudSetup."Product ID");

        IntelligentCloudNotifier.ShowICUpdateNotification();
        WarnAboutNonInitializedCompanies();
    end;

    trigger OnAfterGetCurrRecord()
    var
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        LastHybridReplicationSummary.SetAutoCalcFields("Companies Not Initialized");
        HybridCloudManagement.GetLastReplicationSummary(LastHybridReplicationSummary);
        HybridCloudManagement.GetCloudMigrationStatusText(StatusTxt, StatusTxtStyle, MoreInformationTxt);
        UpdateControlProperties();
    end;

    local procedure UpdateTablesStatistics()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        TempHybridReplicationDetail: Record "Hybrid Replication Detail" temporary;
        HybridReplicaitonStatistics: Codeunit "Hybrid Replication Statistics";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        PageCaptionTxt := CurrPage.Caption();

        CompaniesStatusText := HybridReplicaitonStatistics.GetCompaniesOverviewText();

        HybridReplicaitonStatistics.GetTotalFailedTables(HybridReplicationDetail);
        TotalTablesFailedCount := HybridReplicationDetail.Count();

        HybridReplicaitonStatistics.GetTotalSuccessfulTables(TempHybridReplicationDetail);
        TotalSuccessfulTablesCount := TempHybridReplicationDetail.Count();

        HybridCloudManagement.GetLastReplicationSummary(HybridReplicationSummary);
        HybridReplicationSummary.CalcFields("Tables Remaining");
        TotalTablesRemainingCount := HybridReplicationSummary."Tables Remaining";

        if HybridReplicationSummary.Status = HybridReplicationSummary.Status::Completed then begin
            NotInitializedCompaniesVisible := true;
            HybridReplicationSummary.CalcFields("Companies Not Initialized");
            NotInitializedCompaniesCount := HybridReplicationSummary."Companies Not Initialized";
        end;
    end;

    local procedure UpdateControlProperties()
    var
        IntelligentCloudStatus: Record "Intelligent Cloud Status";
        HybridCompany: Record "Hybrid Company";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        PermissionManager: Codeunit "Permission Manager";
    begin
        IsSetupComplete := PermissionManager.IsIntelligentCloud() or (IsOnPrem and not IntelligentCloudStatus.IsEmpty());
        IsMigratedCompany := HybridCompany.Get(CompanyName()) and HybridCompany.Replicate;
        AdlSetupEnabled := HybridCloudManagement.CanSetupAdlMigration();

        Clear(NotInitializedCompaniesVisible);
        TablesRemainingVisible := TotalTablesRemainingCount > 0;
        WarningsVisible := TotalTablesWithWarningsCount > 0;
        TablesFailedVisible := TotalTablesFailedCount > 0;
    end;

    procedure SendRepairDataNotification()
    var
        ReplicationRunCompletedArg: Record "Replication Run Completed Arg";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        RepairDataNotification: Notification;
    begin
        RepairDataNotification.Id := '7c075e6a-3ba0-48d4-9c93-8cd47ee740a5';
        RepairDataNotification.Recall();

        HybridReplicationSummary.SetCurrentKey("Start Time");
        HybridReplicationSummary.Ascending := false;
        if not HybridReplicationSummary.FindLast() then
            exit;

        if HybridReplicationSummary."Data Repair Status" = HybridReplicationSummary."Data Repair Status"::Pending then
            exit;

        if ReplicationRunCompletedArg.IsEmpty() then
            exit;

        RepairDataNotification.Message := DataRepairNotCompletedMsg;
        RepairDataNotification.Scope := NotificationScope::LocalScope;
        RepairDataNotification.Send();
    end;

    procedure SendUserIsNotSuperNotification();
    var
        UserIsNotSuperNotification: Notification;
    begin
        UserIsNotSuperNotification.Id := 'c496b111-5c7d-4a8d-a5c3-9f63ed01fc4b';
        UserIsNotSuperNotification.Recall();
        UserIsNotSuperNotification.Message := UserMustBeSuperMsg;
        UserIsNotSuperNotification.Scope := NotificationScope::LocalScope;
        UserIsNotSuperNotification.Send();
    end;

    procedure SendSetupIntelligentCloudNotification();
    var
        IntelligentCloud: Record "Intelligent Cloud";
        UserIsNotSuperNotification: Notification;
    begin
        UserIsNotSuperNotification.Id := 'a396b111-5c7d-4a8d-a5c3-9f63ed01fc3a';
        UserIsNotSuperNotification.Recall();
        if IntelligentCloud.Get() then
            if IntelligentCloud.Enabled then
                exit;

        UserIsNotSuperNotification.Message := IntelligentCloudNotSetupMsg;
        UserIsNotSuperNotification.AddAction(OpenPageMsg, Codeunit::"Hybrid Cloud Management", 'OpenWizardAction');
        UserIsNotSuperNotification.Send();
    end;

    local procedure CanRefresh(): Boolean
    var
        AllowedRefreshPeriod: Integer;
    begin
        AllowedRefreshPeriod := 60000; // 60 seconds
        if LastRefresh = 0DT then
            exit(true);

        exit(CurrentDateTime() - LastRefresh > AllowedRefreshPeriod);
    end;

    local procedure WarnAboutNonInitializedCompanies()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridCompanyInitialize: Codeunit "Hybrid Company Initialize";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        UninitializedCompaniesNotification: Notification;
        UninitializedCompanies: List of [Text[50]];
    begin
        if not NotInitializedCompaniesVisible then
            exit;

        HybridCloudManagement.GetLastReplicationSummary(HybridReplicationSummary);
        if not (HybridReplicationSummary.Status = LastHybridReplicationSummary.Status::Completed) then
            exit;

        HybridCompanyInitialize.GetNonInitialziedCompaniesWithMigrationCompleted(UninitializedCompanies);
        if UninitializedCompanies.Count() = 0 then
            exit;

        UninitializedCompaniesNotification.Id := HybridCompanyInitialize.GetUnintializedCompaniesNotificationID();
        UninitializedCompaniesNotification.Recall();
        UninitializedCompaniesNotification.Message := NonInitializedCompaniesMsg;
        UninitializedCompaniesNotification.Scope := NotificationScope::LocalScope;

        UninitializedCompaniesNotification.AddAction(OpenPageMsg, Codeunit::"Hybrid Company Initialize", 'OpenManageCompaniesPage');
        UninitializedCompaniesNotification.Send();
    end;

    [IntegrationEvent(false, false)]
    local procedure CanRunDiagnostic(var CanRun: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure CanShowSetupChecklist(var Enabled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure CanShowMapUsers(var Enabled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure CanShowUpdateReplicationCompanies(var Enabled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure CheckAdditionalProcesses(var AdditionalProcessesRunning: Boolean; var ErrorMessage: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnResetAllCloudData()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure CanMapCustomTables(var Enabled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure CheckNewUISupported()
    begin
    end;

    var
        LastHybridReplicationSummary: Record "Hybrid Replication Summary";
        DummyHybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridDeployment: Codeunit "Hybrid Deployment";
        RegenerateNewKeyConfirmQst: Label 'Are you sure you want to generate new integration runtime key?';
        RunReplicationTxt: Label 'Data replication has been successfully started. You can track the status on the management page.';
        IntegrationKeyTxt: Label 'Primary key for the integration runtime is: %1', Comment = '%1 = Integration Runtime Key';
        NewIntegrationKeyTxt: Label 'New Primary key for the integration runtime is: %1', Comment = '%1 = Integration Runtime Key';
        ResetCloudDataConfirmQst: Label 'If you choose to reset cloud data, all migrated data will be deleted for all companies in the next migration run. Are you sure you want to reset cloud data?';
        ResetCompletedTxt: Label 'Reset has been successfully run. All migration enabled data will be reset in the next migration run.';
        TablesReadyForReplicationMsg: Label 'All tables have been successfully prepared for migration.';
        NonInitializedCompaniesMsg: Label 'One or more companies have been successfully migrated but are not yet initialized. Manage the companies in the Hybrid Companies List page.';
        OpenPageMsg: Label 'Start setup';
        UserMustBeSuperMsg: Label 'You must have the SUPER permission set to run this wizard.';
        IntelligentCloudNotSetupMsg: Label 'Cloud migration is not enabled. To start the migration you must complete the setup.';
        RunReplicationConfirmQst: Label 'Are you sure you want to start data replication?';
        DataRepairNotCompletedMsg: Label 'Data repair has not completed. Before you complete the cloud migration or start an upgrade, invoke the ''Repair Companion Table Records'' action';
        TotalSuccessfulTablesCount: Integer;
        TotalTablesFailedCount: Integer;
        TotalTablesRemainingCount: Integer;
        TotalTablesWithWarningsCount: Integer;
        NotInitializedCompaniesCount: Integer;
        StatusTxt: Text;
        StatusTxtStyle: Text;
        MoreInformationTxt: Text;
        CompaniesStatusText: Text;
        PageCaptionTxt: Text;
        NotInitializedCompaniesVisible: Boolean;
        TablesRemainingVisible: Boolean;
        TablesFailedVisible: Boolean;
        WarningsVisible: Boolean;
        IsSetupComplete: Boolean;
        IsSuper: Boolean;
        IsOnPrem: Boolean;
        IsMigratedCompany: Boolean;
        DiagnosticRunsEnabled: Boolean;
        SetupChecklistEnabled: Boolean;
        MapUsersEnabled: Boolean;
        AdlSetupEnabled: Boolean;
        UpdateReplicationCompaniesEnabled: Boolean;
        CustomTablesEnabled: Boolean;
        LastRefresh: DateTime;

}
