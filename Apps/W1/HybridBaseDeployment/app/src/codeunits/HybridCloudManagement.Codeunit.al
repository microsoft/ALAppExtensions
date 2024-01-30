namespace Microsoft.DataMigration;

using Microsoft.Utilities;
using System.Apps;
using System.Integration;
using System.Security.User;
using System.Security.AccessControl;
using System.Upgrade;
using System.Telemetry;
using System.Reflection;
using System.Environment.Configuration;
using System.Threading;
using System.Environment;
using System.Azure.Identity;
using System.Media;
using System.Text;
using Microsoft.Foundation.Company;

codeunit 4001 "Hybrid Cloud Management"
{
    Permissions = tabledata "Intelligent Cloud Status" = rimd,
                  tabledata "Published Application" = r,
                  tabledata AllObj = r,
                  tabledata "Intelligent Cloud" = rimd,
                  tabledata "Hybrid DA Approval" = rim,
                  tabledata "Webhook Subscription" = rimd;

    var
        SubscriptionFormatTxt: Label '%1_IntelligentCloud', Comment = '%1 - The source product id', Locked = true;
        ServiceSubscriptionFormatTxt: Label 'IntelligentCloudService_%1', Comment = '%1 - The source product id', Locked = true;
        DataSyncWizardPageNameTxt: Label 'Set up Cloud Migration';
        CloudMigrationDescriptionTxt: Label 'Migrate data from your on-premises environment to Business Central.';
        HelpLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2013440', Locked = true;
        CloudMigrationTok: Label 'CloudMigration', Locked = true;
        MigrationDisabledTelemetryTxt: Label 'Migration disabled. Source Product=%1; Reason=%2', Comment = '%1 - source product, %2 - reason for disabling', Locked = true;
        UserMustBeAbleToScheduleTasksMsg: Label 'You do not have the right permissions to schedule tasks, which is required for running the migration. Please check your permissions and license entitlements before you continue.';
        CreatingIntegrationRuntimeMsg: Label 'Creating Integration Runtime for Product ID: %1', Comment = '%1 - The source product id', Locked = true;
        CreatedIntegrationRuntimeMsg: Label 'Created Integration Runtime, IRName" %1', Comment = '%1 - Name of Integration Runtime', Locked = true;
        ReplicationCompletedServiceTypeTxt: Label 'ReplicationCompleted', Locked = true;
        CloudMigrationDisabledDueToUpgradeMsg: Label 'Cloud migration was stopped because the target environment was upgraded. Before you set up the cloud migration again, see the article Migrate On-Premises Data to Business Central Online in the Business Central administration content.';
        CannotStartUpgradeFailedErr: Label 'You cannot start the upgrade again because there are companies in which data upgrade has failed. After investigating the failure you must delete these companies and start the migration again, revert to backup or point in time restore to the point before running upgrade.';
        CannotStartUpgradeFailedTablesErr: Label 'The upgrade can''t start due to %1 failed tables.\\Investigate and mitigate the failure, and then use the Replicate Data action again to migrate the missing data from the on-premises database.', Comment = '%1 the number of failed tables.';
        CannotTriggerUpgradeErr: Label 'Upgrade cannot be started until all companies are successfully replicated.';
        CannotStartUpgradeNotAllComapniesAreMigratedErr: Label 'Cannot start upgrade because following companies are not ready to be migrated:%1', Comment = '%1 - Comma separated list of companies pending cloud migration';
        ScheduledFixingDataTelemetryMsg: Label 'Companion table repair scheduled.', Locked = true;
        MarkedCompanyAsUpgradePendingTelemetryMsg: Label 'Marked Company as Upgrade Pending. Comany name: %1', Locked = true;
        DelegatedAdminCannotRunCloudMigrationErr: Label 'A delegated admin cannot run the cloud migration until a licensed user has approved access to the migration tool.';
        DisableReplicationRevokedConsentTxt: Label 'Cloud migration has been disabled because a user has revoked consent.';
        NoConsentToRevokeErr: Label 'There are no consent records to revoke.';
        StatusIsAlreadyGrantedErr: Label 'The access was already granted';
        GrantApprovalPermissionErr: Label 'You do not have permission to grant approval to run the cloud migration setup. You must be a licensed user, and your user account must have the SUPER permission set.';
        DoYouWantToDisableQst: Label 'If you revoke consent, the cloud migration stops.\\Are you sure that you want to continue?';
        RemovingTheTablesWillRemoveHistoryQst: Label 'If you exclude tables in this way, already migrated data may be deleted. This way, if the same tables are included in the cloud migration later, data from the on-premises database will replace the existing data in the target environment. If you do not want this to happen, do not include the table to the cloud migration again.\\Are you sure that you want to continue?';
        CompanyWasNotCreatedErr: Label 'Company creation failed. Errors could be found on the assisted setup page. Company name is: %1.', Comment = '%1 - Company name';
        CompanySetupIsNotcompleteErr: Label 'The company %1 was not setup correctly. Current setup status: %2', Comment = '%1 - Company name, %2 - Company Status';
        MigraitonAlreadyInProgressErr: Label 'A migration is already in progress.';
        CompanyCreationFailedErr: Label 'Company creation failed with error %1. Please fix this and re-run the Cloud Migration Setup wizard.', Comment = '%1 - the error message';
        CompanyInProgressErr: Label 'Cannot run data replication since the background task has not finished creating companies yet.';
        UpgradeNotExecutedErr: Label 'Upgrade was not run, because there were no extensions capable of handling the upgrade.';
        CannotStartUpgradeFromOldRunErr: Label 'The selected summary is not from the latest replication run. To start the upgrade, select the summary from the lastest run.';
        ResetCloudFailedErr: Label 'Failed to reset cloud data';
        DisablereplicationTxt: Label 'Cloud migration has been disabled.';
        DisabledCloudMigrationFromCompanyTxt: Label 'Cloud migration has been disabled.', Locked = true;
        UnfavorableStyleLbl: Label 'Unfavorable', Locked = true;
        CloudMigrationStatusNotSetupLbl: Label 'Cloud migration is disabled';
        CloudMigrationStatusCreatingCompaniesInProgressLbl: Label 'Creating companies';
        CloudMigrationStatusCreatingCompaniesFailedLbl: Label 'Creating companies has failed';
        CloudMigrationFailedTablesStatusLbl: Label 'Replication completed with failed tables';
        RunFailedTablesStatusLbl: Label '%1 replication completed with failed tables', Comment = '%1 - will be replaced by run type like Azure Data Lake or Diagnostic';
        UpgradeCompletedStatusLbl: Label 'Upgrade completed successfully';
        UpgradeFailedStatusLbl: Label 'Upgrade failed';
        UpgradeIsRunningStatusLbl: Label 'Upgrade is in progress';
        CloudMigrationStatusInProgressLbl: Label 'Replication in progress';
        CloudMigrationRunProgressLbl: Label '%1 run in progress', Comment = '%1 - will be replaced by run type like Azure Data Lake or Diagnostic';
        CloudMigrationWasAbandonedLbl: Label 'Cloud migration was abandoned.';
        CloudMigrationIsPausedLbl: Label 'Cloud migration is paused.';
        CloudMigrationIsCompletedLbl: Label 'Cloud migration is completed.';
        FixCloudMigrationFailedTablesStatusLbl: Label 'Investigate the error messages for the failed tables. After fixing the root cause in the OnPremise database or if the issue is transient, invoke the Run replication action to delta sync the tables.';
        ScheduleNewRunLbl: Label 'Investigate the error messages for the failed tables. After fixing the root cause or if the issue is transient, schedule a new run the Run replication action to delta sync the tables.';
        WaitForMigrationLbl: Label 'You need to wait for the replication of the data to complete. The system is copying the data, if it seems that progress is not updated, it is copying the data in bulk.\\If you need to stop this process, you can stop the integration runtime on the OnPremise machine.';
        WaitForReplicationRunLbl: Label 'You need to wait for the %1 run to complete.', Comment = '%1 - will be replaced by run type like Azure Data Lake or Diagnostic';
        FixCloudMigrationStatusCreatingCompaniesFailedLbl: Label 'Creation of the companies has failed. Investigate the error messages and after fixing the root cause delete the failed companies and invoke Select Companies to migrate action to start the creation of the companies again.';
        DataRepairInProgressLbl: Label 'Repairing OnPrem data';
        DataRepairInProgressMessageLbl: Label 'The repair of the OnPrem data is in progress. During this time we are inserting the missing table extension records and doing other repair processes. If the repair fails, you can invoke it manually by using Repair OnPrem data acton.';
        CloudMigrationLastStepLbl: Label 'Last step - %1', Comment = '%1 - Text for step name';
        ReadyForReplicationStatusLbl: Label 'Ready for replication';
        CloudMigrationCompletedTxt: Label 'Cloud migration was completed.';
        CannotCompleteMigrationUpgradeNotCompleteErr: Label 'You cannot complete the cloud migration because upgrade was not completed. If you want to stop the cloud migration, use pause or abandon actions.';
        CannotCompleteCloudMigrationWithFailedTablesErr: Label 'You cannot complete the cloud migration because there are failed tables. To fix the issue run the replication again to pull the failed tables. If you want to stop the cloud migration, use pause or abandon actions.';
        CannotCompleteCloudMigrationDataRepairPendingErr: Label 'You need to invoke repair companion table records before completing the cloud migration.';
        TableWasUnblockedMsg: Label 'Table was successfully unblocked. You can move the missing data through configuration packages or via other means.';
        DataReplicationStartedLbl: Label 'Replication run started.', Locked = true;
        DataUpgradeScheduledLbl: Label 'Cloud Migration data upgrade scheduled.', Locked = true;
        UnblockedManuallyLbl: Label 'Unblocked manually';
        SettingForUserPermissionsMsg: Label 'Setting for Keeping user permissions was set to: %1.', Comment = '%1 - true or false';
        DoNotManageCompaniesManuallyLbl: Label 'We strongly recommend that you don''t manage companies, such as renaming and deleting, while cloud migration is running.';
        LearnMoreMsg: Label 'Learn more';
        DontShowAgainMsg: Label 'Don''t show again';
        CompanyManagementDocumentationHyperlinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2248704', Locked = true;
        WarnManageCompaniesNotificationsTxt: Label 'Cloud Migration - Manage Companies Warning';
        WarnManageCompaniesDescriptionTxt: Label 'Warning to the users to read the documentation before managing the companies during cloud migration.';

    procedure CanHandleNotification(SubscriptionId: Text; ProductId: Text): Boolean
    var
        ExpectedSubscriptionId: Text;
    begin
        ExpectedSubscriptionId := StrSubstNo(SubscriptionFormatTxt, ProductId);
        exit((StrPos(SubscriptionId, ExpectedSubscriptionId) > 0) or
            CanHandleServiceNotification(SubscriptionId, ProductId));
    end;

    procedure CanHandleServiceNotification(SubscriptionId: Text; ProductId: Text): Boolean
    var
        ExpectedServiceSubscriptionId: Text;
    begin
        ExpectedServiceSubscriptionId := StrSubstNo(ServiceSubscriptionFormatTxt, ProductId);
        exit(StrPos(SubscriptionId, ExpectedServiceSubscriptionId) > 0);
    end;

    procedure CanSetupAdlMigration() CanSetup: Boolean
    var
        IntelligentCloud: Record "Intelligent Cloud";
    begin
        if not (IntelligentCloud.Get() and IntelligentCloud.Enabled) then
            exit;

        OnCanSetupAdlMigration(CanSetup);
    end;

    procedure CanGrantPermission(): Boolean
    var
        UserPermissions: Codeunit "User Permissions";
        IdentityManagement: Codeunit "Identity Management";
        CanSetup: Boolean;
    begin
        CanSetup := UserPermissions.IsSuper(UserSecurityId()) and TaskScheduler.CanCreateTask() and (not IdentityManagement.IsUserDelegatedAdmin());
        exit(CanSetup);
    end;

    procedure CreateCompanies()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        CanCreateCompanies: Boolean;
        SessionID: Integer;
    begin
        CanCreateCompanies := true;
        OnCanCreateCompanies(CanCreateCompanies);

        if not CanCreateCompanies then
            exit;

        ClearCompanyCreationStatus();
        Commit();

        IntelligentCloudSetup.LockTable();
        IntelligentCloudSetup.Get();
        IntelligentCloudSetup."Company Creation Task Status" := IntelligentCloudSetup."Company Creation Task Status"::InProgress;
        Clear(IntelligentCloudSetup."Company Creation Session ID");
        Clear(IntelligentCloudSetup."Company Creation Task Error");
        Clear(IntelligentCloudSetup."Company Creation Task ID");
        IntelligentCloudSetup.Modify();

        BackupDataPerDatabase(IntelligentCloudSetup);

        if TaskScheduler.CanCreateTask() then begin
            IntelligentCloudSetup."Company Creation Task ID" := TaskScheduler.CreateTask(
            Codeunit::"Create Companies IC",
            Codeunit::"Handle Create Company Failure", true, '', 0DT);
            IntelligentCloudSetup.Modify();
        end else begin
            if not Session.StartSession(SessionID, Codeunit::"Create Companies IC", CompanyName()) then
                Codeunit.Run(Codeunit::"Handle Create Company Failure");
            IntelligentCloudSetup."Company Creation Session ID" := SessionID;
            IntelligentCloudSetup.Modify();
        end;

        Commit();
    end;

    internal procedure VerifyCanScheduleTasks()
    var
        Handled: Boolean;
    begin
        OnBeforeCanScheduleTask(Handled);
        if Handled then
            exit;

        if not TaskScheduler.CanCreateTask() then
            Error(UserMustBeAbleToScheduleTasksMsg);
    end;

    procedure ClearCompanyCreationStatus()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        if not IntelligentCloudSetup.Get() then
            exit;

        Clear(IntelligentCloudSetup."Company Creation Session ID");
        Clear(IntelligentCloudSetup."Company Creation Task ID");
        Clear(IntelligentCloudSetup."Company Creation Task Error");
        IntelligentCloudSetup.Modify();
    end;

    procedure IsCompanyUnderUpgrade(NewCompanyName: Code[50]): Boolean
    var
        HybridCompany: Record "Hybrid Company";
        HybridCompanyStatus: Record "Hybrid Company Status";
    begin
        if not IsIntelligentCloudEnabled() then
            exit(false);

        HybridCompany.SetFilter(Name, '%1', '@' + NewCompanyName);
        if not HybridCompany.FindFirst() then
            exit(false);

        if HybridCompanyStatus.Get(HybridCompany.Name) then
            if HybridCompanyStatus."Upgrade Status" in [HybridCompanyStatus."Upgrade Status"::" ", HybridCompanyStatus."Upgrade Status"::Completed] then
                exit(false);

        exit(true);
    end;

    procedure IsIntelligentCloudEnabled(): Boolean
    var
        IntelligentCloud: Record "Intelligent Cloud";
    begin
        if not IntelligentCloud.Get() then
            exit(false);

        exit(IntelligentCloud.Enabled);
    end;

    [Scope('OnPrem')]
    internal procedure RefreshIntelligentCloudStatusTable()
    var
        ALCloudMigration: DotNet ALCloudMigration;
    begin
        ALCloudMigration.UpdateCloudMigrationStatus();
    end;

    procedure BackupDataPerDatabase(var IntelligentCloudSetup: Record "Intelligent Cloud Setup")
    var
        Handled: Boolean;
    begin
        OnBackupDataPerDatabase(IntelligentCloudSetup."Product ID", Handled);
        if Handled then
            exit;

        BackupUpgradeTags(IntelligentCloudSetup);
    end;

    local procedure BackupUpgradeTags(var IntelligentCloudSetup: Record "Intelligent Cloud Setup")
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        Handled: Boolean;
        ShouldBackupUpgradeTags: Boolean;
    begin
        OnBackupUpgradeTags(IntelligentCloudSetup."Product ID", Handled, ShouldBackupUpgradeTags);

        if Handled then
            exit;

        if not ShouldBackupUpgradeTags then
            exit;

        IntelligentCloudSetup."Upgrade Tag Backup ID" := UpgradeTag.BackupUpgradeTags();
        IntelligentCloudSetup.Modify();
        Commit();
    end;

    [Scope('OnPrem')]
    procedure DisableDataLakeMigration()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridDeployment: Codeunit "Hybrid Deployment";
    begin
        IntelligentCloudSetup.Get();
        HybridDeployment.Initialize(IntelligentCloudSetup."Product ID");

        Session.LogMessage('SmbMig-004', 'Start disable Azure Data Lake migration.', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetTelemetryCategory());
        HybridDeployment.DisableDataLakeMigration();
        Session.LogMessage('SmbMig-005', 'Finish disable Azure Data Lake migration.', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetTelemetryCategory());
    end;

    internal procedure DisableMigrationAPI()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        IntelligentCloudSetup.Get();
        DisableMigration(IntelligentCloudSetup."Product ID", DisablereplicationTxt, false)
    end;


    [Scope('OnPrem')]
    procedure DisableMigration()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        IntelligentCloudSetup.Get();
        DisableMigration(IntelligentCloudSetup."Product ID", DisablereplicationTxt, true)
    end;

    [Scope('OnPrem')]
    procedure DisableMigration(SourceProduct: Text; Reason: Text; NeedsCleanup: Boolean)
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        IntelligentCloud: Record "Intelligent Cloud";
        HybridDeployment: Codeunit "Hybrid Deployment";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        RestoreDataPerDatabaseTables(HybridReplicationSummary."Run ID", SourceProduct);

        if NeedsCleanup then begin
            HybridDeployment.Initialize(SourceProduct);
            HybridDeployment.DisableReplication();
        end;

        IntelligentCloud.Get();
        IntelligentCloud.Enabled := false;
        IntelligentCloud.Modify();
        Session.LogMessage('SmbMig-001', StrSubstNo(MigrationDisabledTelemetryTxt, SourceProduct, Reason), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetTelemetryCategory());

        HybridReplicationSummary.Init();
        HybridReplicationSummary."Run ID" := CreateGuid();
        HybridReplicationSummary."Start Time" := CurrentDateTime();
        HybridReplicationSummary."End Time" := CurrentDateTime();
        HybridReplicationSummary.Status := HybridReplicationSummary.Status::Completed;
        HybridReplicationSummary."Trigger Type" := HybridReplicationSummary."Trigger Type"::Manual;
        HybridReplicationSummary.Source := CopyStr(GetHybridProductName(SourceProduct), 1, 250);
        HybridReplicationSummary.SetDetails(Reason);
        HybridReplicationSummary.Insert();

        Commit(); // Manual commit in case subscriber to the call below crashes

        OnAfterDisableMigration(SourceProduct);
        FeatureTelemetry.LogUptake('0000JMT', HybridCloudManagement.GetFeatureTelemetryName(), Enum::"Feature Uptake Status"::Used);
        FeatureTelemetry.LogUsage('0000JMX', HybridCloudManagement.GetFeatureTelemetryName(), 'Disabling cloud migration');
        SendTelemetryDisableCloudMigration(Reason);
    end;

    local procedure DisableMigrationOnly(Reason: Text)
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        IntelligentCloud: Record "Intelligent Cloud";
    begin
        IntelligentCloud.Get();
        IntelligentCloud.Enabled := false;
        IntelligentCloud.Modify();
        Session.LogMessage('SmbMig-001', StrSubstNo(MigrationDisabledTelemetryTxt, '', Reason), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetTelemetryCategory());

        HybridReplicationSummary.Init();
        HybridReplicationSummary."Run ID" := CreateGuid();
        HybridReplicationSummary."Start Time" := CurrentDateTime();
        HybridReplicationSummary."End Time" := CurrentDateTime();
        HybridReplicationSummary.Status := HybridReplicationSummary.Status::Completed;
        HybridReplicationSummary."Trigger Type" := HybridReplicationSummary."Trigger Type"::Manual;
        HybridReplicationSummary.SetDetails(Reason);
        HybridReplicationSummary.Insert();

        Commit(); // Manual commit in case subscriber to the call below crashes

        SendTelemetryDisableCloudMigration(Reason);
    end;

    procedure RepairCompanionTableRecordConsistency()
    var
        LastHybridReplicationSummary: Record "Hybrid Replication Summary";
        ReplicationRunCompletedArg: Record "Replication Run Completed Arg";
    begin
        RepairCompanionTables();
        Commit();
        ReplicationRunCompletedArg.DeleteAll();

        if not GetLastReplicationSummary(LastHybridReplicationSummary) then
            exit;

        LastHybridReplicationSummary."Data Repair Status" := LastHybridReplicationSummary."Data Repair Status"::Completed;
        LastHybridReplicationSummary.Modify();
    end;

    procedure RepairCompanionTables()
    var
        AllObj: Record AllObj;
        PublishedApplication: Record "Published Application";
        CompanionTableRecordConsistencyRepair: DotNet CompanionTableRecordConsistencyRepair;
    begin
        Session.LogMessage('0000FJ1', 'Companion table repair started.', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', GetTelemetryCategory());
        CompanionTableRecordConsistencyRepair := CompanionTableRecordConsistencyRepair.CompanionTableRecordConsistencyRepair();
        AllObj.SetRange("Object Type", AllObj."Object Type"::"TableExtension");
        PublishedApplication.SetRange(Installed, true);
        if PublishedApplication.FindSet() then
            repeat
                AllObj.SetRange("App Runtime Package ID", PublishedApplication."Runtime Package ID");
                if not AllObj.IsEmpty() then begin
#pragma warning disable AA0217
                    Session.LogMessage('0000FJ2', StrSubstNo('Starting Repair of Companion Tables for Package ID %1', PublishedApplication."Package ID"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetTelemetryCategory());
                    CompanionTableRecordConsistencyRepair.UpdateCompanionTablesInAppWithMissingRecords(PublishedApplication."Runtime Package ID");
                    Commit();
                    Session.LogMessage('0000FJ3', StrSubstNo('Completed Repair of Companion Tables for Package ID %1', PublishedApplication."Package ID"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetTelemetryCategory());
#pragma warning restore
                end;
            until PublishedApplication.Next() = 0;

        Session.LogMessage('0000FJ4', 'Companion table repair completed successfully.', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', GetTelemetryCategory());
    end;

    [Scope('OnPrem')]
    procedure FinishDataLakeMigration(HybridReplicationSummary: Record "Hybrid Replication Summary")
    var
        SesssionID: Integer;
        Handled: Boolean;
    begin
        OnAfterDataLakeMigration(HybridReplicationSummary, Handled);

        if Handled then
            exit;

        if TaskScheduler.CanCreateTask() then begin
            // Schedule a task to cleanup the Azure Data Lake migration.
            // Set it for a minute in the future so that it doesn't conflict with the finishing migration.
            TaskScheduler.CreateTask(Codeunit::"Data Lake Migration Cleanup", 0, true, CompanyName(), CurrentDateTime() + 60000);
            Session.LogMessage('SmbMig-002', 'Scheduled task to clean up Azure Data Lake migration.', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetTelemetryCategory());
        end else
            if not Session.StartSession(SesssionID, Codeunit::"Data Lake Migration Cleanup", CompanyName()) then
                Session.LogMessage('SmbMig-003', 'Scheduled task to clean up Azure Data Lake migration.', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetTelemetryCategory());
    end;

    local procedure RestoreDataPerDatabaseTables(RunId: Text[50]; SourceProduct: Text)
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
        Handled: Boolean;
    begin
        OnRestoreDataPerDatabalseTables(Handled, RunId, SourceProduct);
        if Handled then
            exit;

        IntelligentCloudSetup.Get();
        if IntelligentCloudSetup."Upgrade Tag Backup ID" <> 0 then
            UpgradeTag.RestoreUpgradeTagsFromBackup(IntelligentCloudSetup."Upgrade Tag Backup ID", true);
    end;

    procedure GetTelemetryCategory(): Text
    begin
        exit(CloudMigrationTok);
    end;

    procedure GetTotalFailedTables() Count: Integer
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridCompany: Record "Hybrid Company";
    begin
        HybridReplicationSummary.SetCurrentKey("Start Time");
        HybridReplicationSummary.SetRange(Status, HybridReplicationSummary.Status::Completed);
        if not HybridReplicationSummary.FindLast() then
            exit;

        HybridReplicationDetail.SetRange("Run ID", HybridReplicationSummary."Run ID");
        HybridReplicationDetail.SetFilter(Status, '%1|%2', HybridReplicationDetail.Status::Failed, HybridReplicationDetail.Status::Warning);
        HybridCompany.SetRange(Replicate, true);
        if HybridReplicationDetail.FindSet() then
            repeat
                HybridCompany.SetRange(Name, HybridReplicationDetail."Company Name");
                if (HybridReplicationDetail."Company Name" = '') or not HybridCompany.IsEmpty() then
                    Count += 1;
            until HybridReplicationDetail.Next() = 0;
    end;

    procedure GetTotalSuccessfulTables() Count: Integer
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridReplicationDetailPreviousRecord: Record "Hybrid Replication Detail";
    begin
        HybridReplicationDetail.SetCurrentKey("Table Name", "Company Name");
        HybridReplicationDetail.SetRange(Status, HybridReplicationDetail.Status::Successful);
        if HybridReplicationDetail.FindSet() then
            repeat
                HybridReplicationSummary.Get(HybridReplicationDetail."Run ID");

                if HybridReplicationSummary.ReplicationType in [HybridReplicationSummary.ReplicationType::Full, HybridReplicationSummary.ReplicationType::Normal] then begin
                    if (HybridReplicationDetail."Company Name" <> HybridReplicationDetailPreviousRecord."Company Name") or (HybridReplicationDetail."Table Name" <> HybridReplicationDetailPreviousRecord."Table Name") then
                        Count += 1;

                    HybridReplicationDetailPreviousRecord := HybridReplicationDetail;
                end;
            until HybridReplicationDetail.Next() = 0
    end;

    procedure GetTotalTablesNotMigrated() TotalTables: Integer;
    var
        HybridCompany: Record "Hybrid Company";
        TableMetadata: Record "Table Metadata";
    begin
        TableMetadata.Reset();
        TableMetadata.SetRange(ReplicateData, false);
        TableMetadata.SetFilter(ID, '<%1|>%2', 2000000000, 2000000300);
        TableMetadata.SetFilter(Name, '<>*Buffer');
        HybridCompany.Reset();
        HybridCompany.SetRange(Replicate, true);
        if HybridCompany.FindSet() then
            repeat
                if TableMetadata.ChangeCompany(HybridCompany.Name) then // CHANGECOMPANY should transfer the range to the new company
                    TotalTables := TotalTables + TableMetadata.CountApprox();
            until HybridCompany.Next() = 0;

        // Now add the system tables
        TableMetadata.RESET();
        TableMetadata.SETRANGE(ReplicateData, false);
        TableMetadata.SETRANGE(DataPerCompany, false);
        TableMetadata.SetFilter(ID, '<%1|>%2', 2000000000, 2000000300);
        TableMetadata.SetFilter(Name, '<>*Buffer');
        if TableMetadata.FindSet() then
            TotalTables := TotalTables + TableMetadata.Count();
    end;

    procedure GetSaasWizardRedirectUrl(var IntelligentCloudSetup: Record "Intelligent Cloud Setup") RedirectUrl: Text
    begin
        RedirectUrl := GetUrl(ClientType::Web, '', ObjectType::Page, Page::"Hybrid Cloud Setup Wizard", IntelligentCloudSetup, true);
    end;

    procedure GetRedirectFilter() RedirectFilter: Text
    begin
        RedirectFilter := 'FROMONPREM';
    end;

    procedure GetChosenProductName(): Text
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        if not IntelligentCloudSetup.Get() then
            exit('');

        exit(GetHybridProductName(IntelligentCloudSetup."Product ID"));
    end;

    procedure GetHybridProductName(ProductId: Text) ProductName: Text
    begin
        OnGetHybridProductName(ProductId, ProductName);

        // if no product name is provided, then default to the product identifier
        if ProductName = '' then
            ProductName := ProductId;
    end;

    procedure GetNotificationSource(SubscriptionID: Text; var SourceProduct: Text)
    var
        SubscriptionFormat: Text;
        ServiceSubscriptionFormat: Text;
    begin
        SubscriptionFormat := StrSubstNo(SubscriptionFormatTxt, '');
        ServiceSubscriptionFormat := StrSubstNo(ServiceSubscriptionFormatTxt, '');

        case true of
            StrPos(SubscriptionID, SubscriptionFormat) > 0:
                SourceProduct := SubscriptionID.Replace(SubscriptionFormat, '');
            StrPos(SubscriptionID, ServiceSubscriptionFormat) > 0:
                SourceProduct := SubscriptionID.Replace(ServiceSubscriptionFormat, '');
            else
                OnGetNotificationSource(SubscriptionID, SourceProduct);
        end;
    end;

    procedure HandleShowCompanySelectionStep(var HybridProductType: Record "Hybrid Product Type"; SqlConnectionString: Text; SqlServerType: Text; IRName: Text)
    var
        HandledExternally: Boolean;
    begin
        OnBeforeShowCompanySelectionStep(HybridProductType, SqlConnectionString, SqlServerType, IRName, HandledExternally);
        if HandledExternally then
            exit;

        EnableReplication(HybridProductType, SqlConnectionString, SqlServerType, IRName);
        ClearCompanyCreationStatus();
    end;

    internal procedure EnableReplication(var HybridProductType: Record "Hybrid Product Type"; SqlConnectionString: Text; SqlServerType: Text; IRName: Text)
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridDeployment: Codeunit "Hybrid Deployment";
        DeployedVersion: Text;
        LatestVersion: Text;
    begin
        HybridDeployment.Initialize(HybridProductType.ID);
        HybridDeployment.EnableReplication(SqlConnectionString, SqlServerType, IRName);

        HybridDeployment.GetVersionInformation(DeployedVersion, LatestVersion);
        IntelligentCloudSetup.SetDeployedVersion(DeployedVersion);
        IntelligentCloudSetup.SetLatestVersion(LatestVersion);

        OnAfterEnableMigration(HybridProductType);
    end;

    internal procedure FinishCloudMigrationSetup(var IntelligentCloudSetup: Record "Intelligent Cloud Setup")
    var
        HybridCompany: Record "Hybrid Company";
        GuidedExperience: Codeunit "Guided Experience";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        TelemetryDimensions.Add('TotalNumberOfOnPremCompanies', Format(HybridCompany.Count(), 0, 9));
        HybridCompany.SetRange(Replicate, true);
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"Hybrid Cloud Setup Wizard");
        IntelligentCloudSetup.Validate("Replication User", UserId());
        IntelligentCloudSetup.Modify();
        RestoreDefaultMigrationTableMappings(false);
        RefreshIntelligentCloudStatusTable();
        CreateCompanies();

        FeatureTelemetry.LogUptake('0000JMU', GetFeatureTelemetryName(), Enum::"Feature Uptake Status"::"Set up");
        TelemetryDimensions.Add('Category', CloudMigrationTok);
        TelemetryDimensions.Add('NumberOfCompanies', Format(HybridCompany.Count(), 0, 9));
        TelemetryDimensions.Add('TotalMigrationSize', Format(HybridCompany.GetTotalMigrationSize(), 0, 9));
        TelemetryDimensions.Add('TotalOnPremSize', Format(HybridCompany.GetTotalOnPremSize(), 0, 9));
        TelemetryDimensions.Add('Product', IntelligentCloudSetup."Product ID");
        FeatureTelemetry.LogUsage('0000EUR', GetFeatureTelemetryName(), 'Completed Cloud Migration Setup.', TelemetryDimensions);
    end;

    local procedure SendTelemetryDisableCloudMigration(Reason: Text)
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        TelemetryDimensions.Add('Category', CloudMigrationTok);
        TelemetryDimensions.Add('DisabledReasonDescription', Reason);
        TelemetryDimensions.Add('DisabledReason', GetDisabledReasonTelemetryText());
        if IntelligentCloudSetup.Get() then
            TelemetryDimensions.Add('SourceProduct', IntelligentCloudSetup."Product ID");

        Session.LogMessage('0000IGC', DisabledCloudMigrationFromCompanyTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', CloudMigrationTok);
    end;

    local procedure GetDisabledReasonTelemetryText(): Text
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        if IntelligentCloudSetup.Get() then
            case IntelligentCloudSetup.DisabledReason of
                IntelligentCloudSetup.DisabledReason::Abandoned:
                    exit('Abandoned');
                IntelligentCloudSetup.DisabledReason::Completed:
                    exit('Completed');
                IntelligentCloudSetup.DisabledReason::Paused:
                    exit('Paused');
            end;

        exit('');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Deployment", 'OnBeforeResetUsersToIntelligentCloudPermissions', '', false, false)]
    local procedure HandleBeforeResetUsersToIntelligentCloudPermissions(var Handled: Boolean)
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        if Handled then
            exit;

        if not IntelligentCloudSetup.Get() then
            exit;

        if IntelligentCloudSetup."Keep User Permissions" then
            Handled := true;
    end;

    procedure HandleShowIRInstructionsStep(var HybridProductType: Record "Hybrid Product Type"; var IRName: Text; var PrimaryKey: Text)
    var
        HybridDeployment: Codeunit "Hybrid Deployment";
        HandledExternally: Boolean;
    begin
        Session.LogMessage('0000EV4', StrSubstNo(CreatingIntegrationRuntimeMsg, HybridProductType.ID), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CloudMigrationTok);

        OnBeforeShowIRInstructionsStep(HybridProductType, IRName, PrimaryKey, HandledExternally);
        if HandledExternally or (IRName <> '') then
            exit;

        HybridDeployment.Initialize(HybridProductType.ID);
        HybridDeployment.CreateIntegrationRuntime(IRName, PrimaryKey);
        Session.LogMessage('0000EV5', StrSubstNo(CreatedIntegrationRuntimeMsg, IRName), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CloudMigrationTok);
    end;

    procedure GetJobQueueCategory(): Code[10]
    begin
        exit('COULDMIG');
    end;

    procedure CreateAndScheduleBackgroundJob(ObjectIdToRun: Integer; Description: Text[250]): Guid
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueEntryBuffer: Record "Job Queue Entry Buffer";
    begin
        JobQueueEntry.Init();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := ObjectIdToRun;
        JobQueueEntry."Maximum No. of Attempts to Run" := 1;
        JobQueueEntry."Job Queue Category Code" := GetJobQueueCategory();
        JobQueueEntry.Description := Description;
        Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry);

        JobQueueEntryBuffer.Init();
        JobQueueEntryBuffer.TransferFields(JobQueueEntry);
        JobQueueEntryBuffer."Job Queue Entry ID" := JobQueueEntry.SystemId;
        JobQueueEntryBuffer."Start Date/Time" := CurrentDateTime();
        JobQueueEntryBuffer.Insert();

        exit(JobQueueEntryBuffer.SystemId);
    end;

    procedure RefreshReplicationStatus()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridDeployment: Codeunit "Hybrid Deployment";
        HybridMessageManagement: Codeunit "Hybrid Message Management";
        Status: Text;
        Errors: Text;
    begin
        HybridReplicationSummary.SetRange("Run ID", '');
        HybridReplicationSummary.DeleteAll();
        HybridReplicationSummary.SetRange("Run ID");

        HybridReplicationSummary.SetRange(Status, HybridReplicationSummary.Status::InProgress);
        if HybridReplicationSummary.FindSet(true) then begin
            IntelligentCloudSetup.Get();
            HybridDeployment.Initialize(IntelligentCloudSetup."Product ID");
            repeat
                HybridDeployment.GetReplicationRunStatus(HybridReplicationSummary."Run ID", Status, Errors);
                if Status <> Format(HybridReplicationSummary.Status::InProgress) then begin
                    HybridReplicationSummary.EvaluateStatus(Status);
                    if not (Errors in ['', '[]']) then begin
                        Errors := HybridMessageManagement.ResolveMessageCode('', Errors);
                        HybridReplicationSummary.SetDetails(Errors);
                    end;

                    HybridReplicationSummary.Modify();
                end;
            until HybridReplicationSummary.Next() = 0;
        end;
    end;

    internal procedure ResetCloudData()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridDeployment: Codeunit "Hybrid Deployment";
        IntelligentCloudManagement: Page "Intelligent Cloud Management";
    begin
        if not IntelligentCloudSetup.Get() then
            Error(ResetCloudFailedErr);

        HybridDeployment.Initialize(IntelligentCloudSetup."Product ID");
        HybridDeployment.ResetCloudData();
        IntelligentCloudManagement.OnResetAllCloudData();
    end;

    [Scope('OnPrem')]
    procedure RunAdlMigration(CloudMigrationAdlSetup: Record "Cloud Migration ADL Setup" temporary) RunId: Text
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridDeployment: Codeunit "Hybrid Deployment";
    begin
        IntelligentCloudSetup.Get();
        HybridDeployment.Initialize(IntelligentCloudSetup."Product ID");
        HybridDeployment.InitiateDataLakeMigration(RunId, CloudMigrationAdlSetup."Storage Account Name", CloudMigrationAdlSetup."Storage Account Key");
        HybridReplicationSummary.CreateInProgressRecord(RunId, HybridReplicationSummary.ReplicationType::"Azure Data Lake");
    end;

    internal procedure RunReplicationAPI(ReplicationType: Option) RunId: Text;
    begin
        exit(RunReplication(ReplicationType));
    end;

    [Scope('OnPrem')]
    procedure RunReplication(ReplicationType: Option) RunId: Text;
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        HybridDeployment: Codeunit "Hybrid Deployment";
        TelemetryDictionary: Dictionary of [Text, Text];
        Handled: Boolean;
    begin
        IntelligentCloudSetup.Get();
        HybridDeployment.Initialize(IntelligentCloudSetup."Product ID");
        if ReplicationType = HybridReplicationSummary.ReplicationType::Full then
            HybridDeployment.ResetCloudData();

        MarkTablesAsReplaceData();
        OnHandleRunReplication(Handled, RunId, ReplicationType);
        if not Handled then
            HybridDeployment.RunReplication(RunId, ReplicationType);

        HybridReplicationSummary.CreateInProgressRecord(RunId, ReplicationType);
        if HybridReplicationSummary.FindLast() then;
        TelemetryDictionary.Add('Category', GetTelemetryCategory());
        TelemetryDictionary.Add('ReplicationType', GetReplicationTypeTelemetryText(HybridReplicationSummary));
        TelemetryDictionary.Add('SourceProduct', IntelligentCloudSetup."Product ID");
        Session.LogMessage('0000K0J', DataReplicationStartedLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, TelemetryDictionary);

        FeatureTelemetry.LogUptake('0000JMV', GetFeatureTelemetryName(), Enum::"Feature Uptake Status"::Used);
        FeatureTelemetry.LogUsage('0000JMY', GetFeatureTelemetryName(), 'Running data replication');
    end;

    internal procedure GetReplicationTypeTelemetryText(var HybridReplicationSummary: Record "Hybrid Replication Summary"): Text
    begin
        case HybridReplicationSummary.ReplicationType of
            HybridReplicationSummary.ReplicationType::Full, HybridReplicationSummary.ReplicationType::Normal:
                exit('Data Replication');
            HybridReplicationSummary.ReplicationType::"Azure Data Lake":
                exit('Azure Data Lake');
            HybridReplicationSummary.ReplicationType::Diagnostic:
                exit('Diagnostic');
        end;
        exit('');
    end;

    internal procedure GetFeatureTelemetryName(): Text
    begin
        exit('Cloud Migration');
    end;

    local procedure MarkTablesAsReplaceData()
    var
        IntelligentCloudStatus: Record "Intelligent Cloud Status";
    begin
        IntelligentCloudStatus.Get('Upgrade Tags$63ca2fa4-4f03-4f2b-a480-172fef340d3f', '');
        IntelligentCloudStatus."Preserve Cloud Data" := false;
        IntelligentCloudStatus.Modify();
    end;

    procedure CheckFixDataOnReplicationCompleted(NotificationText: Text): Boolean
    var
        JsonManagement: Codeunit "JSON Management";
        ServiceType: Text;
        FixData: Boolean;
        Handled: Boolean;
    begin
        OnHandleFixDataOnReplicationCompleted(Handled, FixData);
        if Handled then
            exit(FixData);

        JsonManagement.InitializeObject(NotificationText);
        JsonManagement.GetStringPropertyValueByName('ServiceType', ServiceType);
        if not IsReplicationCompleted(ServiceType) then
            exit(false);

        exit(true);
    end;

    internal procedure IsReplicationCompleted(ServiceType: Text): Boolean
    begin
        exit(ReplicationCompletedServiceTypeTxt = ServiceType);
    end;

    internal procedure SendCloudMigrationTelemetry()
    var
        IntelligentCloud: Record "Intelligent Cloud";
        HybridCompany: Record "Hybrid Company";
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        if not IntelligentCloud.Get() then
            exit;

        Clear(HybridCompany);
        FeatureTelemetry.LogUptake('0000JMQ', HybridCloudManagement.GetFeatureTelemetryName(), Enum::"Feature Uptake Status"::Used);

        TelemetryDimensions.Add('Category', HybridCloudManagement.GetTelemetryCategory());
        TelemetryDimensions.Add('NumberOfCompanies', Format(HybridCompany.Count(), 0, 9));
        TelemetryDimensions.Add('TotalMigrationSize', Format(HybridCompany.GetTotalMigrationSize(), 0, 9));
        TelemetryDimensions.Add('TotalOnPremSize', Format(HybridCompany.GetTotalOnPremSize(), 0, 9));
        IntelligentCloudSetup."Product ID" := 'Unknown';
        if IntelligentCloudSetup.Get() then;
        TelemetryDimensions.Add('Product', IntelligentCloudSetup."Product ID");
        TelemetryDimensions.Add('MigrationDateTime', Format(IntelligentCloud.SystemModifiedAt, 0, 9));
        FeatureTelemetry.LogUsage('0000JMR', HybridCloudManagement.GetFeatureTelemetryName(), 'Tenant was cloud migrated', TelemetryDimensions);
    end;

    procedure RestoreDefaultMigrationTableMappings(DeleteExisting: Boolean)
    var
        MigrationTableMapping: Record "Migration Table Mapping";
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        if DeleteExisting then
            MigrationTableMapping.DeleteAll();

        if IntelligentCloudSetup.Get() then;

        OnInsertDefaultTableMappings(IntelligentCloudSetup."Product ID", DeleteExisting);
    end;

    procedure CompleteCloudMigration()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        IntelligentCloudSetup.Get();
        DisableMigration(IntelligentCloudSetup."Product ID", CloudMigrationCompletedTxt, true);
        IntelligentCloudSetup.Find();
        IntelligentCloudSetup.DisabledReason := IntelligentCloudSetup.DisabledReason::Completed;
        IntelligentCloudSetup.Modify();

        FeatureTelemetry.LogUptake('0000JV4', HybridCloudManagement.GetFeatureTelemetryName(), Enum::"Feature Uptake Status"::Used);
        FeatureTelemetry.LogUsage('0000JV5', HybridCloudManagement.GetFeatureTelemetryName(), 'Completed the cloud migration succesfully');
        SendCloudMigrationTelemetry();

        if GuiAllowed then
            Message(CloudMigrationCompletedTxt);
    end;

    procedure SendMissingScheduleTasksNotification();
    var
        UserIsNotAbleToScheduleTasks: Notification;
    begin
        UserIsNotAbleToScheduleTasks.Id := '90b26c2e-df8e-4672-a6d0-b39d4c3a5874';
        UserIsNotAbleToScheduleTasks.Recall();
        UserIsNotAbleToScheduleTasks.Message := UserMustBeAbleToScheduleTasksMsg;
        UserIsNotAbleToScheduleTasks.Scope := NotificationScope::LocalScope;
        UserIsNotAbleToScheduleTasks.Send();
    end;

    procedure ScheduleDataFixOnReplicationCompleted(RunId: Text[50]; SubscriptionId: Text; NotificationText: Text)
    var
        ReplicationRunCompletedArg: Record "Replication Run Completed Arg";
        NotificationOutStream: OutStream;
        CreateSession: Boolean;
        SessionID: Integer;
    begin
        ReplicationRunCompletedArg.DeleteAll();
        ReplicationRunCompletedArg."Run ID" := RunId;
        ReplicationRunCompletedArg."Subscription ID" := CopyStr(SubscriptionId, 1, MaxStrLen(ReplicationRunCompletedArg."Subscription ID"));
        ReplicationRunCompletedArg.Insert();
        ReplicationRunCompletedArg."Notification Text".CreateOutStream(NotificationOutStream);
        NotificationOutStream.WriteText(NotificationText);
        ReplicationRunCompletedArg.Modify();
        Commit();

        CreateSession := true;
        OnCreateSessionForDataFixAfterReplication(CreateSession);

        if not CreateSession then begin
            Commit();
            Codeunit.Run(Codeunit::"Fix Data OnRun Completed", ReplicationRunCompletedArg);
            exit;
        end;

        if TaskScheduler.CanCreateTask() then
            ReplicationRunCompletedArg.TaskId := TaskScheduler.CreateTask(Codeunit::"Fix Data OnRun Completed", Codeunit::"Handle Fix Data Failure", true, CompanyName(), CurrentDateTime() + 5000, ReplicationRunCompletedArg.RecordId)
        else begin
            Session.StartSession(SessionID, Codeunit::"Fix Data OnRun Completed", CompanyName(), ReplicationRunCompletedArg);
            ReplicationRunCompletedArg."Session Id" := SessionID;
        end;

        Session.LogMessage('0000FXC', ScheduledFixingDataTelemetryMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', CloudMigrationTok);

        ReplicationRunCompletedArg.Modify();
        Commit();
    end;

    local procedure AddWebhookSubscription(SubscriptionId: Text[150]; ClientState: Text[50])
    var
        WebhookSubscription: Record "Webhook Subscription";
        HybridDAApproval: Record "Hybrid DA Approval";
        IdentityManagement: Codeunit "Identity Management";
        SubscriptionExists: Boolean;
    begin
        WebhookSubscription.LockTable();
        SubscriptionExists := WebhookSubscription.GET(SubscriptionId, '');
        WebhookSubscription."Application ID" := CopyStr(ApplicationIdentifier(), 1, 20);
        WebhookSubscription."Client State" := ClientState;
        WebhookSubscription."Company Name" := CopyStr(CompanyName(), 1, 30);
        WebhookSubscription."Subscription ID" := SubscriptionId;


        if not IdentityManagement.IsUserDelegatedAdmin() then
            WebhookSubscription."Run Notification As" := UserSecurityId()
        else begin
            HybridDAApproval.SetRange(Status, HybridDAApproval.Status::Granted);
            if not HybridDAApproval.FindFirst() then
                Error(DelegatedAdminCannotRunCloudMigrationErr);
            WebhookSubscription."Run Notification As" := HybridDAApproval."Granted By User Security ID";
        end;

        if SubscriptionExists then
            WebhookSubscription.Modify()
        else
            WebhookSubscription.Insert();

        Commit();
    end;

    procedure ConstructTableName(Name: Text[30]; TableID: Integer) TableName: Text[250]
    var
        AllObj: Record AllObj;
        PublishedApplication: Record "Published Application";
        AppID: Text[50];
    begin
        TableName := Name;
        AllObj.Reset();
        AllObj.SetRange("Object Type", AllObj."Object Type"::Table);
        AllObj.SetRange("Object ID", TableID);
        if AllObj.FindFirst() then begin
            PublishedApplication.Reset();
            PublishedApplication.SetRange("Runtime Package ID", AllObj."App Runtime Package ID");
            if PublishedApplication.FindFirst() then begin
                AppID := CopyStr(Lowercase(CopyStr(PublishedApplication.ID, 2, (StrLen(PublishedApplication.ID) - 2))), 1, 50);
                TableName := CopyStr(TableName + '$' + AppID, 1, 250);
            end;
        end;
        exit(TableName);
    end;

    [Scope('OnPrem')]
    internal procedure GetOrInsertDelegatedAdminApprovalRecord(var HybridDAApproval: Record "Hybrid DA Approval")
    begin
        if HybridDAApproval.Count() = 0 then
            HybridDAApproval.Insert();

        HybridDAApproval.FindLast();
    end;

    [Scope('OnPrem')]
    internal procedure GrantConsentToDelegatedAdmin(var HybridDAApproval: Record "Hybrid DA Approval")
    var
        ExistingHybridDAApproval: Record "Hybrid DA Approval";
        NewHybridDAApproval: Record "Hybrid DA Approval";
    begin
        if not CanGrantPermission() then
            Error(GrantApprovalPermissionErr);

        ExistingHybridDAApproval.SetRange(Status, ExistingHybridDAApproval.Status::Granted);
        if not ExistingHybridDAApproval.IsEmpty() then
            Error(StatusIsAlreadyGrantedErr);

        if HybridDAApproval.Status = HybridDAApproval.Status::Revoked then begin
            NewHybridDAApproval."Granted By User Security ID" := UserSecurityId();
            NewHybridDAApproval."Granted Date" := CurrentDateTime();
            NewHybridDAApproval.Status := NewHybridDAApproval.Status::Granted;
            NewHybridDAApproval.Insert();
            NewHybridDAApproval.Get(NewHybridDAApproval.PrimaryKey);
            HybridDAApproval := NewHybridDAApproval;
            exit;
        end;

        if HybridDAApproval.Status = HybridDAApproval.Status::" " then begin
            HybridDAApproval."Granted By User Security ID" := UserSecurityId();
            HybridDAApproval."Granted Date" := CurrentDateTime();
            HybridDAApproval.Status := NewHybridDAApproval.Status::Granted;
            HybridDAApproval.Modify();
            exit;
        end;
    end;

    internal procedure VerifyCanStartReplication()
    var
        IntelligentCloudManagement: Page "Intelligent Cloud Management";
        AdditionalProcessesRunning: Boolean;
        ErrorMessage: Text;
    begin
        AdditionalProcessesRunning := false;
        if not CanRunReplication(ErrorMessage) then
            Error(ErrorMessage);

        if CompanyCreationFailed(ErrorMessage) then
            Error(CompanyCreationFailedErr, ErrorMessage);

        if CompanyCreationInProgress() then
            Error(CompanyInProgressErr);

        IntelligentCloudManagement.CheckAdditionalProcesses(AdditionalProcessesRunning, ErrorMessage);
        if AdditionalProcessesRunning then
            Error(ErrorMessage);
    end;

    local procedure CompanyCreationFailed(var ErrorMessage: Text): Boolean
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        if IntelligentCloudSetup.Get() then begin
            ErrorMessage := IntelligentCloudSetup."Company Creation Task Error";
            exit((IntelligentCloudSetup."Company Creation Task Status" = IntelligentCloudSetup."Company Creation Task Status"::Failed));
        end;

        exit(not HybridCloudManagement.VerifyCompaniesCreatedSuccessfully(ErrorMessage));
    end;

    internal procedure CompanyCreationInProgress(): Boolean
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


    internal procedure CanRunReplication(var Reason: Text): Boolean
    var
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        if IsReplicationInProgress(Reason) then
            exit(false);

        exit(HybridCloudManagement.VerifyCanReplicateCompanies(Reason));
    end;

    internal procedure IsReplicationInProgress(var Reason: Text): Boolean
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
    begin
        HybridReplicationSummary.SetRange(Status, HybridReplicationSummary.Status::InProgress);
        HybridReplicationSummary.SetFilter("Start Time", '>%1', (CurrentDateTime() - 86400000));
        if not HybridReplicationSummary.IsEmpty() then begin
            Reason := MigraitonAlreadyInProgressErr;
            exit(true);
        end;

        exit(false);
    end;

    procedure VerifyCanReplicateCompanies(var Reason: Text): Boolean
    var
        CanReplicate: Boolean;
    begin
        CanReplicate := true;
        OnVerifyCanReplicateCompanies(Reason, CanReplicate);
        exit(CanReplicate);
    end;

    internal procedure ChangeRemovePermissionsFromUsers()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        IntelligentCloudSetup.Get();
        IntelligentCloudSetup."Keep User Permissions" := not IntelligentCloudSetup."Keep User Permissions";
        IntelligentCloudSetup.Modify();
        Message(SettingForUserPermissionsMsg, IntelligentCloudSetup."Keep User Permissions");
    end;

    internal procedure VerifyCanCompleteCloudMigration()
    var
        LastHybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridReplicationStatistics: Codeunit "Hybrid Replication Statistics";
        UpgradeSupported: Boolean;
        Handled: Boolean;
        FixData: Boolean;
    begin
        HybridReplicationStatistics.GetTotalFailedTables(HybridReplicationDetail);
        if HybridReplicationDetail.Count() > 0 then
            Error(CannotCompleteCloudMigrationWithFailedTablesErr);

        FixData := true;
        OnHandleFixDataOnReplicationCompleted(Handled, FixData);
        if FixData then begin
            GetLastReplicationSummary(LastHybridReplicationSummary);
            if LastHybridReplicationSummary."Data Repair Status" <> LastHybridReplicationSummary."Data Repair Status"::Completed then
                Error(CannotCompleteCloudMigrationDataRepairPendingErr);
        end;

        OnIsUpgradeSupported(UpgradeSupported);
        if UpgradeSupported then
            if not IsUpgradeCompleted() then
                Error(CannotCompleteMigrationUpgradeNotCompleteErr);
    end;

    [Scope('OnPrem')]
    internal procedure RevokeConsentFromDelegatedAdmin()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        if not Confirm(DoYouWantToDisableQst) then
            exit;

        SetRevokedToHybridDAAproval();

        if IntelligentCloudSetup.Get() then
            DisableMigration(IntelligentCloudSetup."Product ID", DisableReplicationRevokedConsentTxt, true);
    end;

    internal procedure CheckNeedsApprovalToRunCloudMigration(): Boolean
    var
        HybridDAAPproval: Record "Hybrid DA Approval";
        AzureADGraphUser: Codeunit "Azure AD Graph User";
        IsUserDelegated: Boolean;
    begin
        IsUserDelegated := AzureADGraphUser.IsUserDelegatedAdmin() or AzureADGraphUser.IsUserDelegatedHelpdesk();
        if not IsUserDelegated then begin
            VerifyCanScheduleTasks();
            exit(false);
        end;

        HybridDAAPproval.SetRange(Status, HybridDAAPproval.Status::Granted);
        exit(HybridDAAPproval.IsEmpty());
    end;

    internal procedure VerifyCompaniesCreatedSuccessfully(var ErrorMessage: Text): Boolean
    var
        AssistedCompanySetupStatus: Record "Assisted Company Setup Status";
        HybridCompany: Record "Hybrid Company";
        Company: Record Company;
        CompanySetupStatus: Enum "Company Setup Status";
    begin
        HybridCompany.SetRange(Replicate, true);
        if not HybridCompany.FindSet() then
            exit(true);

        repeat
            if not Company.Get(HybridCompany.Name) then begin
                ErrorMessage := StrSubstNo(CompanyWasNotCreatedErr, Company.Name);
                exit(false);
            end;

            CompanySetupStatus := AssistedCompanySetupStatus.GetCompanySetupStatusValue(Company.Name);
            if not (CompanySetupStatus = CompanySetupStatus::Completed) then begin
                ErrorMessage := StrSubstNo(CompanySetupIsNotcompleteErr, Company.Name, CompanySetupStatus);
                exit(false);
            end;
        until HybridCompany.Next() = 0;

        exit(true);
    end;

    [Scope('OnPrem')]
    local procedure SetRevokedToHybridDAAproval()
    var
        GrantedHybridDAApproval: Record "Hybrid DA Approval";
        CopyGrantedHybridDAApproval: Record "Hybrid DA Approval";
    begin
        GrantedHybridDAApproval.SetRange(Status, GrantedHybridDAApproval.Status::Granted);
        if not GrantedHybridDAApproval.FindSet() then
            Error(NoConsentToRevokeErr);

        repeat
            CopyGrantedHybridDAApproval.Copy(GrantedHybridDAApproval);
            CopyGrantedHybridDAApproval."Revoked By User Security ID" := UserSecurityId();
            CopyGrantedHybridDAApproval."Revoked Date" := CurrentDateTime();
            CopyGrantedHybridDAApproval.Status := CopyGrantedHybridDAApproval.Status::Revoked;
            CopyGrantedHybridDAApproval.Modify();
        until GrantedHybridDAApproval.Next() = 0;
    end;

    internal procedure CanSkipIRSetup(SqlServerType: Option; RuntimeNameTxt: Text): Boolean
    var
        DummyIntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        exit((SqlServerType = DummyIntelligentCloudSetup."Sql Server Type"::AzureSQL) or (RuntimeNameTxt <> ''));
    end;

    procedure CanSetupIntelligentCloud(): Boolean
    var
        UserPermissions: Codeunit "User Permissions";
        IdentityManagement: Codeunit "Identity Management";
        CanSetup: Boolean;
    begin
        CanSetup := UserPermissions.IsSuper(UserSecurityId()) and TaskScheduler.CanCreateTask() and (not IdentityManagement.IsUserDelegatedAdmin());
        OnCanSetupIntelligentCloud(CanSetup);
        exit(CanSetup);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDataLakeMigration(HybridReplicationSummary: Record "Hybrid Replication Summary"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDisableMigration(SourceProduct: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowIRInstructionsStep(var HybridProductType: Record "Hybrid Product Type"; var IRName: Text; var PrimaryKey: Text; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowCompanySelectionStep(var HybridProductType: Record "Hybrid Product Type"; SqlConnectionString: Text; SqlServerType: Text; IRName: Text; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeShowProductSpecificSettingsPageStep(var HybridProductType: Record "Hybrid Product Type"; var ShowSettingsStep: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetHybridProductType(var HybridProductType: Record "Hybrid Product Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetHybridProductName(ProductId: Text; var ProductName: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetHybridProductDescription(ProductId: Text; var ProductDescription: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetNotificationSource(SubscriptionID: Text; var SourceProduct: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnShowProductTypeStep(var HybridProductType: Record "Hybrid Product Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnShowSQLServerTypeStep(var HybridProductType: Record "Hybrid Product Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnShowScheduleStep(var HybridProductType: Record "Hybrid Product Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnShowDoneStep(var HybridProductType: Record "Hybrid Product Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterEnableMigration(HybridProductType: Record "Hybrid Product Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCanSetupAdlMigration(var CanSetup: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCanSetupIntelligentCloud(var CanSetup: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnReplicationRunCompleted(RunId: Text[50]; SubscriptionId: Text; NotificationText: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnHandleFixDataOnReplicationCompleted(var Handled: Boolean; var FixData: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCanCreateCompanies(var CanCreateCompanies: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCanStartupgrade(var Handled: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Deployment", 'OnCanStartUpgrade', '', false, false)]
    local procedure DisableCloudMigrationUnderUpgrade(CompanyName: Text)
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        Handled: Boolean;
    begin
        OnCanStartupgrade(Handled);
        if Handled then
            exit;

        if not IsIntelligentCloudEnabled() then
            exit;

        if IntelligentCloudSetup.Get() then
            DisableMigration(IntelligentCloudSetup."Product ID", CloudMigrationDisabledDueToUpgradeMsg, false)
        else
            DisableMigrationOnly(CloudMigrationDisabledDueToUpgradeMsg);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Deployment", 'OnBeforeEnableReplication', '', false, false)]
    local procedure CreateWebhookSubscriptionOnEnableReplication(ProductId: Text; var NotificationUrl: Text; var SubscriptionId: Text[150]; var ClientState: Text[50]; var ServiceNotificationUrl: Text; var ServiceSubscriptionId: Text[150]; var ServiceClientState: Text[50])
    var
        WebhookManagement: Codeunit "Webhook Management";
    begin
        NotificationUrl := WebhookManagement.GetNotificationUrl();
        SubscriptionId := COPYSTR(STRSUBSTNO(SubscriptionFormatTxt, ProductId), 1, 150);
        ClientState := CreateGuid();

        ServiceNotificationUrl := WebhookManagement.GetNotificationUrl();
        ServiceSubscriptionId := COPYSTR(STRSUBSTNO(ServiceSubscriptionFormatTxt, ProductId), 1, 150);
        ServiceClientState := CreateGuid();

        AddWebhookSubscription(SubscriptionId, ClientState);
        AddWebhookSubscription(ServiceSubscriptionId, ServiceClientState);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company", 'OnAfterRenameEvent', '', false, false)]
    local procedure HandleCompanyRename(var Rec: Record Company; var xRec: Record Company; RunTrigger: Boolean)
    var
        Company: Record Company;
        WebhookSubscription: Record "Webhook Subscription";
        FilterStr: Text;
    begin
        if Rec.IsTemporary() then
            exit;

        FilterStr := StrSubstNo(SubscriptionFormatTxt, '*') + '|' + StrSubstNo(ServiceSubscriptionFormatTxt, '*');
        WebhookSubscription.SetFilter("Subscription ID", FilterStr);

        if WebhookSubscription.FindSet() then
            repeat
                if not Company.Get(WebhookSubscription."Company Name") then begin
                    WebhookSubscription."Company Name" := Rec.Name;
                    WebhookSubscription.Modify();
                end;
            until WebhookSubscription.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company", 'OnAfterDeleteEvent', '', false, false)]
    local procedure HandleCompanyDelete(var Rec: Record Company; RunTrigger: Boolean)
    var
        Company: Record Company;
        WebhookSubscription: Record "Webhook Subscription";
        HybridCompany: Record "Hybrid Company";
        FilterStr: Text;
        ReplacementCompanyName: Text[30];
    begin
        if Rec.IsTemporary() then
            exit;

        FilterStr := StrSubstNo(SubscriptionFormatTxt, '*') + '|' + StrSubstNo(ServiceSubscriptionFormatTxt, '*');
        WebhookSubscription.SetRange("Company Name", Rec.Name);
        WebhookSubscription.SetFilter("Subscription ID", FilterStr);

        if not WebhookSubscription.IsEmpty() and Company.FindSet() then begin
            ReplacementCompanyName := Company.Name;

            repeat
                if not HybridCompany.Get(Company.Name) then begin
                    ReplacementCompanyName := Company.Name;
                    break;
                end;
            until Company.Next() = 0;

            WebhookSubscription.ModifyAll("Company Name", ReplacementCompanyName);
        end;

        if HybridCompany.Get(Company.Name) then
            HybridCompany.Delete();
        RemoveIntelligentCloudStatusRecords(Company.Name);
        CleanupSetupTables(Rec);
    end;

    local procedure RemoveIntelligentCloudStatusRecords(CompanyName: Text[50])
    var
        IntelligentCloudStatus: Record "Intelligent Cloud Status";
    begin
        IntelligentCloudStatus.SetRange("Company Name", CompanyName);
        IntelligentCloudStatus.DeleteAll();
    end;

    procedure ExcludePerCompanyTablesFromCloudMigration()
    var
        IntelligentCloudStatus: Record "Intelligent Cloud Status";
    begin
        if GuiAllowed() then
            if not Confirm(RemovingTheTablesWillRemoveHistoryQst) then
                exit;

        IntelligentCloudStatus.SetFilter("Company Name", '<>''''');
        IntelligentCloudStatus.DeleteAll();
    end;

    procedure ExcludePerDatabaseTablesFromCloudMigration()
    var
        IntelligentCloudStatus: Record "Intelligent Cloud Status";
    begin
        if GuiAllowed() then
            if not Confirm(RemovingTheTablesWillRemoveHistoryQst) then
                exit;

        IntelligentCloudStatus.SetRange("Company Name", '');
        IntelligentCloudStatus.DeleteAll();
    end;

    procedure ExcludeTableFromCloudMigration(TableName: Text[250]; CompanyName: Text[30])
    var
        IntelligentCloudStatus: Record "Intelligent Cloud Status";
    begin
        if GuiAllowed() then
            if not Confirm(RemovingTheTablesWillRemoveHistoryQst) then
                exit;

        IntelligentCloudStatus.Get(TableName, CompanyName);
        IntelligentCloudStatus.Delete();
    end;

    procedure RunDataUpgrade(var HybridReplicationSummary: Record "Hybrid Replication Summary")
    var
        ExistingHybridReplicationSummary: Record "Hybrid Replication Summary";
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        TelemetryDictionary: Dictionary of [Text, Text];
        Handled: Boolean;
        ErrorMessage: Text;
    begin
        if IsReplicationInProgress(ErrorMessage) then
            Error(ErrorMessage);

        ExistingHybridReplicationSummary.SetFilter("End Time", '>%1', HybridReplicationSummary."End Time");
        if not ExistingHybridReplicationSummary.IsEmpty() then
            Error(CannotStartUpgradeFromOldRunErr);

        OnInvokeDataUpgrade(HybridReplicationSummary, Handled);
        if not Handled then
            Error(UpgradeNotExecutedErr);

        TelemetryDictionary.Add('Category', GetTelemetryCategory());
        if IntelligentCloudSetup.Get() then
            TelemetryDictionary.Add('SourceProduct', IntelligentCloudSetup."Product ID");

        Session.LogMessage('0000K0K', DataUpgradeScheduledLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, TelemetryDictionary);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterAssistedSetup', '', false, false)]
    local procedure AddIntelligentCloudToAssistedSetup()
    var
        GuidedExperience: Codeunit "Guided Experience";
        PermissionManager: Codeunit "Permission Manager";
        Description: Text[1024];
    begin
        Description := CopyStr(CloudMigrationDescriptionTxt, 1, 1024);
        GuidedExperience.InsertAssistedSetup(DataSyncWizardPageNameTxt, DataSyncWizardPageNameTxt, Description, 0, ObjectType::Page, Page::"Hybrid Cloud Setup Wizard", "Assisted Setup Group"::ReadyForBusiness, '', "Video Category"::Uncategorized, HelpLinkTxt);
        if PermissionManager.IsIntelligentCloud() then
            GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"Hybrid Cloud Setup Wizard");
    end;

    local procedure CleanupSetupTables(Company: Record Company)
    var
        HybridCompanyStatus: Record "Hybrid Company Status";
    begin
        if HybridCompanyStatus.Get(Company.Name) then
            HybridCompanyStatus.Delete();
    end;

    procedure UnblockTable(CompanyName: Text; TableName: Text[250])
    var
        IntelligentCloudStatus: Record "Intelligent Cloud Status";
        LastHybridReplicationDetail: Record "Hybrid Replication Detail";
        LastHybridReplicationSummary: Record "Hybrid Replication Summary";
        RemainingFailedHybridReplicationDetails: Record "Hybrid Replication Detail";
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridReplicationStatistics: Codeunit "Hybrid Replication Statistics";
        StatusText: Text;
    begin
        IntelligentCloudStatus.SetFilter("Table Name", '%1|%2', '*$' + TableName, TableName);
        IntelligentCloudStatus.SetRange("Company Name", CompanyName);
        IntelligentCloudStatus.SetRange(Blocked, true);
        if not IntelligentCloudStatus.FindFirst() then
            exit;

        IntelligentCloudStatus.Blocked := false;
        IntelligentCloudStatus.Modify();

        LastHybridReplicationDetail.SetRange("Table Name", TableName);
        LastHybridReplicationDetail.SetRange("Company Name", CompanyName);
        LastHybridReplicationDetail.SetRange(Status, LastHybridReplicationDetail.Status::Failed);
        LastHybridReplicationDetail.SetCurrentKey("End Time");
        if not LastHybridReplicationDetail.FindLast() then
            exit;

        StatusText := UnblockedManuallyLbl;
        if LastHybridReplicationDetail."Error Message" <> '' then
            StatusText += ' - ' + LastHybridReplicationDetail."Error Message";
        LastHybridReplicationDetail."Error Message" := CopyStr(StatusText, 1, MaxStrLen(HybridReplicationDetail."Error Message"));
        LastHybridReplicationDetail.Status := LastHybridReplicationDetail.Status::Successful;
        LastHybridReplicationDetail.Modify();

        HybridReplicationStatistics.GetTotalFailedTables(RemainingFailedHybridReplicationDetails);
        RemainingFailedHybridReplicationDetails.SetRange("Company Name", LastHybridReplicationDetail."Company Name");
        if RemainingFailedHybridReplicationDetails.IsEmpty() then begin
            GetLastReplicationSummary(LastHybridReplicationSummary);
            LastHybridReplicationSummary.Status := LastHybridReplicationSummary.Status::UpgradePending;
            LastHybridReplicationSummary.Modify();
        end;

        RemainingFailedHybridReplicationDetails.SetRange(Status, RemainingFailedHybridReplicationDetails.Status::Failed);
        if RemainingFailedHybridReplicationDetails.IsEmpty() then
            InsertOrUpdateHybridCompanyStatus(LastHybridReplicationDetail."Company Name");

        if GuiAllowed() then
            Message(TableWasUnblockedMsg);
    end;

    procedure OpenWizardAction(OpenWizardNotification: Notification)
    begin
        Page.Run(PAGE::"Hybrid Cloud Setup Wizard");
    end;

    procedure CheckMigratedDataSize(HybridCompany: Record "Hybrid Company"): Boolean
    var
        DatabaseSizeTooLargeDialog: Page "Database Size Too Large Dialog";
    begin
        if HybridCompany.GetTotalMigrationSize() >= GetNoWarningSizeInGB() then
            if DatabaseSizeTooLargeDialog.RunModal() = Action::No then
                exit(false);

        exit(true);
    end;

    procedure GetNoWarningSizeInGB(): Integer
    begin
        // We warn at 50 GB. The number is based on experience from current runs.
        exit(50);
    end;

    procedure VerifyCanStartUpgrade(var HybridReplicationSummary: Record "Hybrid Replication Summary")
    var
        ErrorMessage: Text;
    begin
        ErrorMessage := CannotTriggerUpgradeErr;
        if not VerifyCanStartUpgrade(HybridReplicationSummary, ErrorMessage) then
            Error(ErrorMessage);
    end;

    procedure VerifyCanStartUpgrade(var HybridReplicationSummary: Record "Hybrid Replication Summary"; var ErrorMessage: Text): Boolean
    var
        HybridCompany: Record "Hybrid Company";
        HybridCompanyStatus: Record "Hybrid Company Status";
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridReplicationStatistics: Codeunit "Hybrid Replication Statistics";
        CompaniesNotReadyForUpgrade: Text;
    begin
        if HybridReplicationStatistics.GetTotalFailedTables(HybridReplicationDetail) then begin
            ErrorMessage := StrSubstNo(CannotStartUpgradeFailedTablesErr, HybridReplicationDetail.Count());
            exit(false);
        end;

        HybridCompanyStatus.SetRange("Upgrade Status", HybridCompanyStatus."Upgrade Status"::Failed);
        if not HybridCompanyStatus.IsEmpty() then begin
            ErrorMessage := CannotStartUpgradeFailedErr;
            exit(false);
        end;

        HybridCompany.SetRange(Replicate, true);
        if not HybridCompany.IsEmpty() then begin
            HybridCompany.FindSet();
            repeat
                if not IsCompanyReadyForUpgrade(HybridCompany) then
                    CompaniesNotReadyForUpgrade += ', ' + HybridCompany.Name;
            until HybridCompany.Next() = 0;

            if CompaniesNotReadyForUpgrade <> '' then begin
                ErrorMessage := StrSubstNo(CannotStartUpgradeNotAllComapniesAreMigratedErr, CompaniesNotReadyForUpgrade.TrimStart(','));
                exit(false);
            end;
        end;

        if not (HybridReplicationSummary.Status = HybridReplicationSummary.Status::UpgradePending) then begin
            ErrorMessage := CannotTriggerUpgradeErr;
            exit(false);
        end;

        exit(true);
    end;

    procedure SetUpgradePendingOnReplicationRunCompleted(RunId: Text[50]; SubscriptionId: Text; NotificationText: Text)
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        JsonManagement: Codeunit "JSON Management";
    begin
        HybridReplicationSummary.Get(RunId);

        JsonManagement.InitializeObject(NotificationText);
        if CompaniesReplicatedSuccessfully(HybridReplicationSummary, JsonManagement) then begin
            HybridReplicationSummary.Status := HybridReplicationSummary.Status::UpgradePending;
            HybridReplicationSummary.Modify();
            SetPendingOnHybridCompanyStatus();
        end;
    end;

    internal procedure StartDataUpgrade()
    var
        HybridDeployment: Codeunit "Hybrid Deployment";
    begin
        HybridDeployment.StartDataUpgrade();
    end;

    internal procedure IsUpgradeCompleted(): Boolean
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridCompanyStatus: Record "Hybrid Company Status";
        HybridCompany: Record "Hybrid Company";
    begin
        GetLastReplicationSummary(HybridReplicationSummary);
        if not (HybridReplicationSummary.Status = HybridReplicationSummary.Status::Completed) then
            exit(false);

        HybridCompany.SetRange(Replicated, true);
        if not HybridCompany.FindSet() then
            exit;

        repeat
            if not HybridCompanyStatus.Get(HybridCompany.Name) then
                exit(false);

            if HybridCompanyStatus."Upgrade Status" <> HybridCompanyStatus."Upgrade Status"::Completed then
                exit(false);
        until HybridCompany.Next() = 0;

        exit(true);
    end;

    procedure GetLastReplicationSummary(var HybridReplicationSummary: Record "Hybrid Replication Summary"): Boolean
    begin
        HybridReplicationSummary.SetCurrentKey("Start Time");
        exit(HybridReplicationSummary.FindLast());
    end;

    internal procedure GetCloudMigrationStatusText(var CloudMigrationStatusText: Text; var CloudMigrationStatusTextStyle: Text; var MoreInformationTxt: Text)
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridCompanyStatus: Record "Hybrid Company Status";
    begin
        Clear(CloudMigrationStatusTextStyle);
        Clear(CloudMigrationStatusText);
        Clear(MoreInformationTxt);

        CloudMigrationStatusText := CloudMigrationStatusNotSetupLbl;
        if not IsIntelligentCloudEnabled() then begin
            case IntelligentCloudSetup.DisabledReason of
                IntelligentCloudSetup.DisabledReason::Abandoned:
                    CloudMigrationStatusText := CloudMigrationWasAbandonedLbl;
                IntelligentCloudSetup.DisabledReason::Paused:
                    CloudMigrationStatusText := CloudMigrationIsPausedLbl;
                IntelligentCloudSetup.DisabledReason::Completed:
                    CloudMigrationStatusText := CloudMigrationIsCompletedLbl;
            end;
            exit;
        end;

        if not IntelligentCloudSetup.Get() then
            exit;

        Clear(CloudMigrationStatusText);
        if IntelligentCloudSetup."Company Creation Task Status" = IntelligentCloudSetup."Company Creation Task Status"::InProgress then begin
            CloudMigrationStatusText := CloudMigrationStatusCreatingCompaniesInProgressLbl;
            exit;
        end;

        if IntelligentCloudSetup."Company Creation Task Status" = IntelligentCloudSetup."Company Creation Task Status"::Failed then begin
            CloudMigrationStatusText := CloudMigrationStatusCreatingCompaniesFailedLbl;
            CloudMigrationStatusTextStyle := UnfavorableStyleLbl;
            MoreInformationTxt := FixCloudMigrationStatusCreatingCompaniesFailedLbl;
            exit;
        end;

        HybridReplicationSummary.SetAutoCalcFields("Tables Failed");
        if not GetLastReplicationSummary(HybridReplicationSummary) then
            exit;

        if HybridReplicationSummary.Status = HybridReplicationSummary.Status::InProgress then begin
            if (HybridReplicationSummary.ReplicationType in [HybridReplicationSummary.ReplicationType::Normal, HybridReplicationSummary.ReplicationType::Full]) then begin
                CloudMigrationStatusText := CloudMigrationStatusInProgressLbl;
                MoreInformationTxt := WaitForMigrationLbl;
                exit;
            end;

            if (HybridReplicationSummary.ReplicationType in [HybridReplicationSummary.ReplicationType::"Azure Data Lake", HybridReplicationSummary.ReplicationType::Diagnostic]) then begin
                CloudMigrationStatusText := StrSubstNo(CloudMigrationRunProgressLbl, HybridReplicationSummary.ReplicationType);
                MoreInformationTxt := StrSubstNo(WaitForReplicationRunLbl, HybridReplicationSummary.ReplicationType);
                exit;
            end;
        end;

        if HybridReplicationSummary."Data Repair Status" = HybridReplicationSummary."Data Repair Status"::"In Progress" then begin
            CloudMigrationStatusText := DataRepairInProgressLbl;
            MoreInformationTxt := DataRepairInProgressMessageLbl;
            exit;
        end;

        CloudMigrationStatusText := HybridReplicationSummary.GetDetails();
        if CloudMigrationStatusText = '' then
            CloudMigrationStatusText := StrSubstNo(CloudMigrationLastStepLbl, HybridReplicationSummary.Status);

        if not (HybridReplicationSummary.Status in [HybridReplicationSummary.Status::UpgradePending, HybridReplicationSummary.Status::Completed]) then
            exit;

        if HybridReplicationSummary."Tables Failed" > 0 then begin
            if (HybridReplicationSummary.ReplicationType in [HybridReplicationSummary.ReplicationType::Normal, HybridReplicationSummary.ReplicationType::Full]) then begin
                CloudMigrationStatusText := CloudMigrationFailedTablesStatusLbl;
                MoreInformationTxt := FixCloudMigrationFailedTablesStatusLbl;
                CloudMigrationStatusTextStyle := UnfavorableStyleLbl;
                exit;
            end;
            if (HybridReplicationSummary.ReplicationType in [HybridReplicationSummary.ReplicationType::"Azure Data Lake", HybridReplicationSummary.ReplicationType::Diagnostic]) then begin
                CloudMigrationStatusText := StrSubstNo(RunFailedTablesStatusLbl, HybridReplicationSummary.ReplicationType);
                MoreInformationTxt := ScheduleNewRunLbl;
                CloudMigrationStatusTextStyle := UnfavorableStyleLbl;
                exit;
            end;
        end;

        if IsUpgradeCompleted() then begin
            CloudMigrationStatusText := UpgradeCompletedStatusLbl;
            exit;
        end;

        HybridCompanyStatus.SetRange("Upgrade Status", HybridCompanyStatus."Upgrade Status"::Failed);
        if not HybridCompanyStatus.IsEmpty() then begin
            CloudMigrationStatusText := UpgradeFailedStatusLbl;
            exit;
        end;

        HybridCompanyStatus.SetRange("Upgrade Status", HybridCompanyStatus."Upgrade Status"::Started);
        if not HybridCompanyStatus.IsEmpty() then begin
            CloudMigrationStatusText := UpgradeIsRunningStatusLbl;
            exit;
        end;

        CloudMigrationStatusText := ReadyForReplicationStatusLbl;
    end;

    internal procedure CompaniesReplicatedSuccessfully(var HybridReplicationSummary: Record "Hybrid Replication Summary"; var JsonManagement: Codeunit "JSON Management"): Boolean
    var
        HybridCompany: Record "Hybrid Company";
        ServiceType: Text;
    begin
        if HybridReplicationSummary.Status <> HybridReplicationSummary.Status::Completed then
            exit(false);

        if not (HybridReplicationSummary.ReplicationType in [HybridReplicationSummary.ReplicationType::Full, HybridReplicationSummary.ReplicationType::Normal]) then
            exit(false);

        HybridCompany.SetRange(Replicate, true);
        if HybridCompany.IsEmpty() then
            exit(false);

        if not JsonManagement.GetStringPropertyValueByName('ServiceType', ServiceType) then
            exit(false);

        exit(IsReplicationCompleted(ServiceType));
    end;

    local procedure SetPendingOnHybridCompanyStatus()
    var
        HybridCompany: Record "Hybrid Company";
    begin
        InsertOrUpdateHybridCompanyStatus('');

        HybridCompany.SetRange(Replicated, true);
        if HybridCompany.FindSet() then
            repeat
                InsertOrUpdateHybridCompanyStatus(HybridCompany.Name);
            until HybridCompany.Next() = 0;
    end;

    local procedure InsertOrUpdateHybridCompanyStatus(HybridCompanyName: Text[250])
    var
        HybridCompanyStatus: Record "Hybrid Company Status";
        HybridCompanyStatusExist: Boolean;
    begin
        HybridCompanyStatusExist := HybridCompanyStatus.Get(HybridCompanyName);

        if HybridCompanyStatusExist then
            if (HybridCompanyStatus."Upgrade Status" = HybridCompanyStatus."Upgrade Status"::Completed) then
                exit;

        HybridCompanyStatus.Replicated := true;
        HybridCompanyStatus."Upgrade Status" := HybridCompanyStatus."Upgrade Status"::Pending;
        if HybridCompanyStatusExist then
            HybridCompanyStatus.Modify()
        else begin
            HybridCompanyStatus.Name := CopyStr(HybridCompanyName, 1, MaxStrLen(HybridCompanyStatus.Name));
            HybridCompanyStatus.Insert();
        end;
        Session.LogMessage('0000FXD', StrSubstNo(MarkedCompanyAsUpgradePendingTelemetryMsg, HybridCompanyStatus.Name), Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, 'Category', CloudMigrationTok);
    end;

    procedure IsCompanyReadyForUpgrade(HybridCompany: Record "Hybrid Company"): Boolean
    var
        HybridCompanyStatus: Record "Hybrid Company Status";
    begin
        if not HybridCompanyStatus.Get(HybridCompany.Name) then
            exit(false);

        if not (HybridCompanyStatus."Upgrade Status" = HybridCompanyStatus."Upgrade Status"::Pending) then
            exit(false);

        if not HybridCompanyStatus.Replicated then
            exit(false);

        exit(true);
    end;

    local procedure GetManageCompaniesWarningNotificationID(): Guid
    begin
        exit('3796153f-fd0a-47dc-899b-8cab5f5cd941');
    end;

    procedure DontShowCompaniesWarningNotification(Notification: Notification)
    var
        MyNotifications: Record "My Notifications";
    begin
        if not MyNotifications.SetStatus(GetManageCompaniesWarningNotificationID(), false) then
            MyNotifications.InsertDefault(
              GetManageCompaniesWarningNotificationID(), WarnManageCompaniesNotificationsTxt, WarnManageCompaniesDescriptionTxt, false);
    end;

    procedure CompaniesWarningNotificationLearnMore(Notification: Notification)
    begin
        Hyperlink(CompanyManagementDocumentationHyperlinkTxt);
    end;

    [EventSubscriber(ObjectType::Page, Page::Companies, 'OnOpenPageEvent', '', false, false)]
    local procedure WarnNotToManageCompaniesManually(var Rec: Record Company)
    var
        MyNotifications: Record "My Notifications";
        SendSetupWebhooksNotification: Notification;
    begin
        if not IsIntelligentCloudEnabled() then
            exit;

        if MyNotifications.Get(UserId(), GetManageCompaniesWarningNotificationID()) then
            if MyNotifications.Enabled = false then
                exit;

        SendSetupWebhooksNotification.Id := GetManageCompaniesWarningNotificationID();
        if SendSetupWebhooksNotification.Recall() then;
        SendSetupWebhooksNotification.Message(DoNotManageCompaniesManuallyLbl);
        SendSetupWebhooksNotification.Scope(NotificationScope::LocalScope);
        SendSetupWebhooksNotification.AddAction(LearnMoreMsg, Codeunit::"Hybrid Cloud Management", 'CompaniesWarningNotificationLearnMore');
        SendSetupWebhooksNotification.AddAction(DontShowAgainMsg, Codeunit::"Hybrid Cloud Management", 'DontShowCompaniesWarningNotification');
        SendSetupWebhooksNotification.Send();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBackupDataPerDatabase(ProductID: Text[250]; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBackupUpgradeTags(ProductID: Text[250]; var Handled: Boolean; var BackupUpgradeTags: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRestoreDataPerDatabalseTables(var Handled: Boolean; RunId: Text[50]; SourceProduct: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnInvokeDataUpgrade(var HybridReplicationSummary: Record "Hybrid Replication Summary"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertDefaultTableMappings(ProductID: Text[250]; DeleteExisting: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHandleRunReplication(var Handled: Boolean; var RunId: Text; ReplicationType: Option)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnVerifyCanReplicateCompanies(var Reason: Text; var CanReplicate: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsUpgradeSupported(var UpgradeSupported: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnCreateSessionForDataFixAfterReplication(var CreateSession: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeCanScheduleTask(var Handled: Boolean)
    begin
    end;
}