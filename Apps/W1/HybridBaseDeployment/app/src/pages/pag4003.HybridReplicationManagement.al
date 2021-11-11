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

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Start Time"; "Start Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the start time of the migration.';
                }
                field("End Time"; "End Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the end time of the migration.';
                }
                field("Trigger Type"; "Trigger Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the trigger type of the migration.';
                }
                field("Replication Type"; ReplicationType)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of migration.';
                }
                field("Status"; Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status of the migration run.';
                }
                field("Source"; Source)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source of the migration run.';
                }
                field("Details"; DetailsValue)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Details';
                    ToolTip = 'Specifies additional details about the migration run.';
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
#if not CLEAN19
            action(ManageSchedule)
            {
                Enabled = IsSuper and IsSetupComplete;
                Visible = false;
                ApplicationArea = Basic, Suite;
                Caption = 'Manage Schedule';
                ToolTip = 'Manage migration schedule.';
                Promoted = true;
                PromotedCategory = Process;
                RunObject = page "Intelligent Cloud Schedule";
                RunPageMode = Edit;
                Image = CalendarMachine;
            }
#endif
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
                    HybridReplicationSummary: Record "Hybrid Replication Summary";
                    HybridCloudManagement: Codeunit "Hybrid Cloud Management";
                    AdditionalProcessesRunning: Boolean;
                    ErrorMessage: Text;
                    CompaniesNotCreated: Boolean;
                begin
                    AdditionalProcessesRunning := false;
                    if not CanRunReplication(ErrorMessage) then
                        Error(ErrorMessage);

                    if CompanyCreationFailed(ErrorMessage) then
                        Error(CompanyCreationFailedErr, ErrorMessage);

                    CompaniesNotCreated := CompanyCreationInProgress();
                    if not CompaniesNotCreated then
                        CompaniesNotCreated := CompanyCreationNotComplete();

                    if CompaniesNotCreated then
                        Error(CompanyNotCreatedErr);

                    CheckAdditionalProcesses(AdditionalProcessesRunning, ErrorMessage);
                    if AdditionalProcessesRunning then
                        Error(ErrorMessage);

                    if Dialog.Confirm(RunReplicationConfirmQst, false) then begin
                        HybridCloudManagement.RunReplication(HybridReplicationSummary.ReplicationType::Normal);
                        Message(RunReplicationTxt);
                    end;
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
                    HybridReplicationSummary: Record "Hybrid Replication Summary";
                    HybridCloudManagement: Codeunit "Hybrid Cloud Management";
                    Handled: Boolean;
                    ErrorMessage: Text;
                begin
                    if IsReplicationInProgress(ErrorMessage) then
                        Error(ErrorMessage);

                    HybridReplicationSummary.SetFilter("End Time", '>%1', Rec."End Time");
                    if HybridReplicationSummary.FindFirst() then
                        Error(CannotStartUpgradeFromOldRunErr);

                    HybridCloudManagement.OnInvokeDataUpgrade(Rec, Handled);
                    if not Handled then
                        Error(UpgradeNotExecutedErr);
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
                    ErrorMessage: Text;
                begin
                    if CompanyCreationInProgress() then
                        Error(CompanyNotCreatedErr);
                    if CompanyCreationFailed(ErrorMessage) then
                        Error(CompanyCreationFailedErr, ErrorMessage);
                    if not CanRunReplication(ErrorMessage) then
                        Error(ErrorMessage);

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
                    IntelligentCloudSetup: Record "Intelligent Cloud Setup";
                    HybridDeployment: Codeunit "Hybrid Deployment";
                begin
                    if Dialog.Confirm(ResetCloudDataConfirmQst, false) then
                        if not IntelligentCloudSetup.Get() then
                            Error(ResetCloudFailedErr)
                        else begin
                            HybridDeployment.Initialize(IntelligentCloudSetup."Product ID");
                            HybridDeployment.ResetCloudData();
                            Message(ResetTriggeredTxt);
                            OnResetAllCloudData();
                        end;
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
                Enabled = IsSuper and IsMigratedCompany;
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
                    HybridCloudManagement: codeunit "Hybrid Cloud Management";
                begin
                    HybridCloudManagement.RepairCompanionTableRecordConsistency();
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
        EnvironmentInfo: Codeunit "Environment Information";
        IntelligentCloudNotifier: Codeunit "Intelligent Cloud Notifier";
    begin
        IsSuper := UserPermissions.IsSuper(UserSecurityId());
        if not IsSuper then
            SendUserIsNotSuperNotification();

        IsOnPrem := NOT EnvironmentInfo.IsSaaS();
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

    trigger OnAfterGetRecord()
    begin
        DetailsValue := GetDetails();
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
        IsSetupComplete := PermissionManager.IsIntelligentCloud() OR (IsOnPrem AND NOT IntelligentCloudStatus.IsEmpty());
        IsMigratedCompany := HybridCompany.Get(CompanyName()) and HybridCompany.Replicate;
        AdlSetupEnabled := HybridCloudManagement.CanSetupAdlMigration();
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

    local procedure CanRunReplication(var Reason: Text): Boolean
    begin
        if IsReplicationInProgress(Reason) then
            exit(false);

        exit(VerifyCanReplicateCompanies(Reason));
    end;

    local procedure IsReplicationInProgress(var Reason: Text): Boolean
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
    begin
        HybridReplicationSummary.SetRange(Status, Rec.Status::InProgress);
        HybridReplicationSummary.SetFilter("Start Time", '>%1', (CurrentDateTime() - 86400000));
        if not HybridReplicationSummary.IsEmpty() then begin
            Reason := MigraitonAlreadyInProgressErr;
            exit(true);
        end;

        exit(false);
    end;

    local procedure VerifyCanReplicateCompanies(var Reason: Text): Boolean
    var
        HybridCompany: Record "Hybrid Company";
        HybridCompanyStatus: Record "Hybrid Company Status";
    begin
        HybridCompany.SetRange(Replicate, true);
        if not HybridCompany.FindSet() then
            exit(true);

        repeat
            if HybridCompanyStatus.Get(HybridCompany.Name) then
                if HybridCompanyStatus.Replicated then
                    if HybridCompanyStatus."Upgrade Status" in [HybridCompanyStatus."Upgrade Status"::Completed, HybridCompanyStatus."Upgrade Status"::Started, HybridCompanyStatus."Upgrade Status"::Failed] then begin
                        Reason := StrSubstNo(CompanyUnderUpgradeErr, HybridCompany.Name, HybridCompanyStatus."Upgrade Status");
                        exit(false);
                    end;
        until HybridCompany.Next() = 0;

        exit(true);
    end;

    local procedure CompanyCreationInProgress(): Boolean
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        ScheduledTask: Record "Scheduled Task";
    begin
        if not IntelligentCloudSetup.Get() then
            exit(false);
        if not IsNullGuid(IntelligentCloudSetup."Company Creation Task ID") then
            exit(ScheduledTask.Get(IntelligentCloudSetup."Company Creation Task ID"));

        if IntelligentCloudSetup."Company Creation Session ID" <> 0 then
            exit(Session.IsSessionActive(IntelligentCloudSetup."Company Creation Session ID"));
    end;

    local procedure CompanyCreationNotComplete(): Boolean
    var
        AssistedCompanySetupStatus: Record "Assisted Company Setup Status";
        HybridCompany: Record "Hybrid Company";
        SetupStatus: Enum "Company Setup Status";
    begin
        HybridCompany.Reset();
        HybridCompany.SetRange(Replicate, true);
        if HybridCompany.FindSet() then
            repeat
                if AssistedCompanySetupStatus.Get(HybridCompany.Name) then begin
                    SetupStatus := AssistedCompanySetupStatus.GetCompanySetupStatusValue(CopyStr(HybridCompany.Name, 1, 30));
                    if SetupStatus <> SetupStatus::Completed then
                        exit(true);
                end;
            until HybridCompany.Next() = 0;
        exit(false);
    end;

    local procedure CompanyCreationFailed(var ErrorMessage: Text): Boolean
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        Company: Record "Company";
        HybridCompany: Record "Hybrid Company";
        AssistedCompanySetupStatus: Record "Assisted Company Setup Status";
        CompanySetupStatus: Enum "Company Setup Status";
    begin
        if IntelligentCloudSetup.Get() then begin
            ErrorMessage := IntelligentCloudSetup."Company Creation Task Error";
            exit((IntelligentCloudSetup."Company Creation Task Status" = IntelligentCloudSetup."Company Creation Task Status"::Failed));
        end;

        HybridCompany.SetRange(Replicate, true);
        if not HybridCompany.FindSet() then
            exit(false);

        repeat
            if not Company.Get(HybridCompany.Name) then begin
                ErrorMessage := StrSubstNo(CompanyWasNotCreatedErr, Company.Name);
                exit(true);
            end;

            CompanySetupStatus := AssistedCompanySetupStatus.GetCompanySetupStatusValue(Company.Name);
            if not (CompanySetupStatus = CompanySetupStatus::Completed) then begin
                ErrorMessage := StrSubstNo(CompanySetupIsNotcompleteErr, Company.Name, CompanySetupStatus);
                exit(true);
            end;
        until HybridCompany.Next() = 0;
        exit(false);
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
    local procedure CheckAdditionalProcesses(var AdditionalProcessesRunning: Boolean; var ErrorMessage: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnResetAllCloudData()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure CanMapCustomTables(var Enabled: Boolean)
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
        RunReplicationConfirmQst: Label 'Are you sure you want to trigger migration?';
        RegenerateNewKeyConfirmQst: Label 'Are you sure you want to generate new integration runtime key?';
        CompanyNotCreatedErr: Label 'Cannot run migration since the background task has not finished creating companies yet.';
        CompanyCreationFailedErr: Label 'Company creation failed with error %1. Please fix this and re-run the Cloud Migration Setup wizard.', Comment = '%1 - the error message';
        MigraitonAlreadyInProgressErr: Label 'A migration is already in progress.';
        RunReplicationTxt: Label 'Migration has been successfully triggered. You can track the status on the management page.';
        IntegrationKeyTxt: Label 'Primary key for the integration runtime is: %1', Comment = '%1 = Integration Runtime Key';
        NewIntegrationKeyTxt: Label 'New Primary key for the integration runtime is: %1', Comment = '%1 = Integration Runtime Key';
        ResetCloudDataConfirmQst: Label 'If you choose to reset cloud data, all migrated data will be deleted for all companies in the next migration run. Are you sure you want to reset cloud data?';
        ResetCloudFailedErr: Label 'Failed to reset cloud data';
        ResetTriggeredTxt: Label 'Reset has been successfully triggered. All migration enabled data will be reset in the next migration run.';
        TablesReadyForReplicationMsg: Label 'All tables have been successfully prepared for migration.';
        NonInitializedCompaniesMsg: Label 'One or more companies have been successfully migrated but are not yet initialized. Manage the companies in the Hybrid Companies List page.';
        CompanyUnderUpgradeErr: Label 'Cloud migration can’t be run, because an upgrade has started on company %1 (upgrade status: %2). Either exclude the company from migration or delete it, then try migration again.', Comment = '%1 - Name of company, %2 Status of upgrade for company';
        OpenPageMsg: Label 'Open page';
        UserMustBeSuperMsg: Label 'You must have the SUPER permission set to run this wizard.';
        IntelligentCloudIsDisabledMsg: Label 'Cloud migration has been disabled. To start the migration again, you must complete the wizard.';
        IntelligentCloudNotSetupMsg: Label 'Cloud migration was not set up. To migrate data to the cloud, complete the wizard.';
        UpgradeNotExecutedErr: Label 'Upgrade was not run, because there were no extensions capable of handling the upgrade.';
        CannotStartUpgradeFromOldRunErr: Label 'The selected summary is not from the latest replication run. To start the upgrade, select the summary from the lastest run.';
        CompanyWasNotCreatedErr: Label 'Company creation failed. Errors could be found on the assisted setup page. Company name is: %1.', Comment = '%1 - Company name';
        CompanySetupIsNotcompleteErr: Label 'The company %1 was not setup correctly. Current setup status: %2', Comment = '%1 - Company name, %2 - Company Status';
}