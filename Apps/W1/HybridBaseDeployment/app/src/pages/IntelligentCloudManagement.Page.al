namespace Microsoft.DataMigration;

using System.Integration;
using System.Security.AccessControl;
using System.Security.User;
using System.Environment;
using System.Telemetry;

page 4003 "Intelligent Cloud Management"
{
    SourceTable = "Hybrid Replication Summary";
    Caption = 'Cloud Migration Management';
    SourceTableView = sorting("Start Time") order(descending);
    PageType = List;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    UsageCategory = Lists;
    ApplicationArea = Basic, Suite;
    PromotedActionCategories = 'Process';
    RefreshOnActivate = true;
    Permissions = tabledata "Intelligent Cloud Status" = rimd;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Start Time"; Rec."Start Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the start time of the migration.';
                }
                field("End Time"; Rec."End Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the end time of the migration.';
                }
                field("Trigger Type"; Rec."Trigger Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the trigger type of the migration.';
                    Visible = false;
                }
                field("Replication Type"; Rec.ReplicationType)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of migration.';
                }
                field("Status"; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status of the migration run.';
                }
                field("Source"; Rec.Source)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source of the migration run.';
                }
                field("Details"; DetailsValue)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Details';
                    ToolTip = 'Specifies additional details about the migration run.';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        if DetailsValue <> '' then
                            Message(DetailsValue);
                    end;
                }
            }
        }
        area(FactBoxes)
        {
            part("Replication Statistics"; "Intelligent Cloud Stat Factbox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Run ID" = field("Run ID");
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
                ApplicationArea = Basic, Suite;
                Caption = 'Run Migration Now';
                ToolTip = 'Manually trigger the Cloud Migration.';
                Promoted = true;
                PromotedCategory = Process;
                Image = Setup;

                trigger OnAction()
                var
                    HybridCloudManagement: Codeunit "Hybrid Cloud Management";
                begin
                    HybridCloudManagement.VerifyCanStartReplication();
                    if not Dialog.Confirm(RunReplicationConfirmQst, false) then
                        exit;

                    HybridCloudManagement.RunReplication(Rec.ReplicationType::Normal);

                    Message(RunReplicationTxt);
                end;
            }

            action(RunDataUpgrade)
            {
                Enabled = IsSuper and IsSetupComplete;
                Visible = not IsOnPrem;
                ApplicationArea = Basic, Suite;
                Caption = 'Run Data Upgrade Now';
                ToolTip = 'Manually start the upgrade after cloud migration.';
                Promoted = true;
                PromotedCategory = Process;
                Image = Process;

                trigger OnAction()
                var
                    HybridCloudManagement: Codeunit "Hybrid Cloud Management";
                begin
                    HybridCloudManagement.RunDataUpgrade(Rec);
                end;
            }

            action(RunDiagnostic)
            {
                Enabled = IsSuper and IsSetupComplete;
                Visible = not IsOnPrem and DiagnosticRunsEnabled;
                ApplicationArea = Basic, Suite;
                Caption = 'Create Diagnostic Run';
                ToolTip = 'Trigger a diagnostic run of the Cloud Migration.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
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
                ApplicationArea = Basic, Suite;
                Caption = 'Refresh Status';
                ToolTip = 'Refresh the status of in-progress migration runs.';
                Promoted = true;
                PromotedCategory = Process;
                Image = RefreshLines;

                trigger OnAction()
                var
                    HybridCloudManagement: Codeunit "Hybrid Cloud Management";
                begin
                    SelectLatestVersion();
                    if Rec.Status = Rec.Status::UpgradePending then begin
                        CurrPage.Update();
                        exit;
                    end;

                    if CanRefresh() then begin
                        HybridCloudManagement.RefreshReplicationStatus();
                        LastRefresh := CurrentDateTime();
                    end;

                    CurrPage.Update();
                    CurrPage."Replication Statistics".Page.Update();
                    WarnAboutNonInitializedCompanies();
                end;
            }

            action(ResetAllCloudData)
            {
                Enabled = IsSuper and IsSetupComplete;
                Visible = not IsOnPrem;
                ApplicationArea = Basic, Suite;
                Caption = 'Reset Cloud Data';
                ToolTip = 'Resets migration enabled data in the cloud tenant.';
                Image = Restore;

                trigger OnAction()
                var
                    HybridCloudManagement: Codeunit "Hybrid Cloud Management";
                begin
                    if not Dialog.Confirm(ResetCloudDataConfirmQst, false) then
                        exit;

                    HybridCloudManagement.ResetCloudData();
                    Message(ResetTriggeredTxt);
                end;
            }

            action(PrepareTables)
            {
                Enabled = IsSuper and IsSetupComplete;
                Visible = IsOnPrem;
                ApplicationArea = Basic, Suite;
                Caption = 'Prepare tables for migration';
                ToolTip = 'Gets the candidate tables ready for migration';
                Promoted = true;
                PromotedCategory = Process;
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
                ApplicationArea = Basic, Suite;
                Caption = 'Get Runtime Service Key';
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
                ApplicationArea = Basic, Suite;
                Caption = 'Reset Runtime Service Key';
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

            action(DisableIntelligentCloud)
            {
                Enabled = IsSuper and IsSetupComplete;
                Visible = not IsOnPrem;
                ApplicationArea = Basic, Suite;
                Caption = 'Disable Cloud Migration';
                ToolTip = 'Disables Cloud Migration setup.';
                RunObject = page "Intelligent Cloud Ready";
                RunPageMode = Edit;
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
            }

            action(CheckForUpdate)
            {
                Enabled = IsSuper and IsSetupComplete;
                Visible = not IsOnPrem;
                ApplicationArea = Basic, Suite;
                Caption = 'Check for Update';
                ToolTip = 'Checks if an update is available for your Cloud Migration integration.';
                RunObject = page "Intelligent Cloud Update";
                RunPageMode = Edit;
                Image = Setup;
            }

            action(UpdateReplicationCompanies)
            {
                Enabled = IsSuper and IsSetupComplete and UpdateReplicationCompaniesEnabled;
                Visible = not IsOnPrem and UpdateReplicationCompaniesEnabled;
                ApplicationArea = Basic, Suite;
                Caption = 'Select Companies to Migrate';
                ToolTip = 'Select companies to Migrate';
                Image = Setup;

                trigger OnAction()
                begin
                    Page.RunModal(Page::"Hybrid Companies Management");
                end;
            }

            action(SetupChecklist)
            {
                Enabled = IsSuper and IsMigratedCompany;
                Visible = not IsOnPrem and SetupChecklistEnabled;
                ApplicationArea = Basic, Suite;
                Caption = 'Setup Checklist';
                ToolTip = 'Setup Checklist';
                RunObject = page "Post Migration Checklist";
                RunPageMode = Edit;
                Image = Setup;
            }

            action(MapUsers)
            {
                Enabled = IsSuper;
                Visible = not IsOnPrem and MapUsersEnabled;
                ApplicationArea = Basic, Suite;
                Caption = 'Define User Mappings';
                ToolTip = 'Define User Mappings';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = false;
                RunObject = page "Migration User Mapping";
                RunPageMode = Edit;
                Image = Setup;
            }

            action(RepairCompanionTableRecordConsistency)
            {
                Visible = not IsOnPrem;
                ApplicationArea = Basic, Suite;
                Caption = 'Repair Companion Table Records';
                ToolTip = 'Repair Companion Table Records';
                Promoted = false;
                Image = Database;

                trigger OnAction()
                var
                    ReplicationRunCompletedArg: Record "Replication Run Completed Arg";
                    HybridCloudManagement: codeunit "Hybrid Cloud Management";
                begin
                    HybridCloudManagement.RepairCompanionTableRecordConsistency();
                    Commit();
                    ReplicationRunCompletedArg.DeleteAll();
                end;
            }

            action(ManageCustomTables)
            {
                Enabled = IsSuper;
                Visible = not IsOnPrem;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = Basic, Suite;
                Caption = 'Manage Custom Tables';
                ToolTip = 'Manage custom table mappings for the migration.';
                RunObject = page "Migration Table Mapping";
                RunPageMode = Edit;
                Image = TransferToGeneralJournal;
            }

            action(AdlSetup)
            {
                Enabled = AdlSetupEnabled;
                Visible = AdlSetupEnabled;
                RunObject = page "Cloud Migration ADL Setup";
                ApplicationArea = Basic, Suite;
                Caption = 'Azure Data Lake';
                ToolTip = 'Migrate your on-premises data to Azure Data Lake.';
                Image = TransmitElectronicDoc;
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
                begin
                    if IntelligentCloudSetup.ChangeUI() then
                        if GetUseNewUI() then begin
                            Page.Run(Page::"Cloud Migration Management");
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
        }
    }

    trigger OnInit()
    begin
        SelectLatestVersion();
    end;

    trigger OnOpenPage()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        PermissionManager: Codeunit "Permission Manager";
        UserPermissions: Codeunit "User Permissions";
        EnvironmentInformation: Codeunit "Environment Information";
        IntelligentCloudNotifier: Codeunit "Intelligent Cloud Notifier";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        if GetUseNewUI() then begin
            Page.Run(Page::"Cloud Migration Management");
            Error('');
        end;

        FeatureTelemetry.LogUptake('0000JMI', HybridCloudManagement.GetFeatureTelemetryName(), Enum::"Feature Uptake Status"::Discovered);
        IsSuper := UserPermissions.IsSuper(UserSecurityId());
        if not IsSuper then
            SendUserIsNotSuperNotification();

        SendRepairDataNotification();
        IsOnPrem := not EnvironmentInformation.IsSaaS();

        if (not PermissionManager.IsIntelligentCloud()) and (not IsOnPrem) then
            SendSetupIntelligentCloudNotification();

        UpdateEditablityOfControls();
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

        if not Rec.FindSet() then
            exit;
    end;

    internal procedure GetUseNewUI(): Boolean;
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        OpenNewUI: Boolean;
    begin
        OpenNewUI := false;
        if IntelligentCloudSetup.Get() then
            case IntelligentCloudSetup."Use New UI" of
                IntelligentCloudSetup."Use New UI"::No:
                    exit(false);
                IntelligentCloudSetup."Use New UI"::Yes:
                    OpenNewUI := true;
                else
                    OnOpenNewUI(OpenNewUI);
            end;

        exit(OpenNewUI);
    end;

    trigger OnAfterGetRecord()
    begin
        DetailsValue := Rec.GetDetails();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateEditablityOfControls();
    end;

    local procedure UpdateEditablityOfControls()
    var
        IntelligentCloudStatus: Record "Intelligent Cloud Status";
        HybridCompany: Record "Hybrid Company";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        PermissionManager: Codeunit "Permission Manager";
    begin
        IsSetupComplete := PermissionManager.IsIntelligentCloud() or (IsOnPrem and not IntelligentCloudStatus.IsEmpty());
        IsMigratedCompany := HybridCompany.Get(CompanyName()) and HybridCompany.Replicate;
        AdlSetupEnabled := HybridCloudManagement.CanSetupAdlMigration();
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

        if HybridReplicationSummary.Status = HybridReplicationSummary.Status::RepairDataPending then
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
        if IntelligentCloud.Get() then begin
            if IntelligentCloud.Enabled then
                exit;
            UserIsNotSuperNotification.Message := IntelligentCloudIsDisabledMsg;
        end else
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
        HybridCompanyInitialize: Codeunit "Hybrid Company Initialize";
        UninitializedCompaniesNotification: Notification;
        UninitializedCompanies: List of [Text[50]];
    begin
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
    local procedure OnOpenNewUI(var OpenNewUI: Boolean)
    begin
    end;

    var
        HybridDeployment: Codeunit "Hybrid Deployment";
        LastRefresh: DateTime;
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
        DetailsValue: Text;
        RegenerateNewKeyConfirmQst: Label 'Are you sure you want to generate new integration runtime key?';
        RunReplicationTxt: Label 'Migration has been successfully triggered. You can track the status on the management page.';
        IntegrationKeyTxt: Label 'Primary key for the integration runtime is: %1', Comment = '%1 = Integration Runtime Key';
        NewIntegrationKeyTxt: Label 'New Primary key for the integration runtime is: %1', Comment = '%1 = Integration Runtime Key';
        ResetCloudDataConfirmQst: Label 'If you choose to reset cloud data, all migrated data will be deleted for all companies in the next migration run. Are you sure you want to reset cloud data?';
        ResetTriggeredTxt: Label 'Reset has been successfully triggered. All migration enabled data will be reset in the next migration run.';
        TablesReadyForReplicationMsg: Label 'All tables have been successfully prepared for migration.';
        NonInitializedCompaniesMsg: Label 'One or more companies have been successfully migrated but are not yet initialized. Manage the companies in the Hybrid Companies List page.';
        OpenPageMsg: Label 'Open page';
        UserMustBeSuperMsg: Label 'You must have the SUPER permission set to run this wizard.';
        IntelligentCloudIsDisabledMsg: Label 'Cloud migration has been disabled. To start the migration again, you must complete the wizard.';
        IntelligentCloudNotSetupMsg: Label 'Cloud migration was not set up. To migrate data to the cloud, complete the wizard.';
        RunReplicationConfirmQst: Label 'Are you sure you want to trigger migration?';
        DataRepairNotCompletedMsg: Label 'Data repair has not completed. Before you complete the cloud migration or trigger an upgrade, invoke the ''Repair Companion Table Records'' action';
}
