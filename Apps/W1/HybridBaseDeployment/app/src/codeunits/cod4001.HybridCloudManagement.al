codeunit 4001 "Hybrid Cloud Management"
{
    Permissions = tabledata "Webhook Subscription" = rimd,
                  tabledata "Intelligent Cloud" = rimd,
                  tabledata "Intelligent Cloud Status" = rimd,
                  tabledata "Installed Application" = r;

    var
        SubscriptionFormatTxt: Label '%1_IntelligentCloud', Comment = '%1 - The source product id', Locked = true;
        ServiceSubscriptionFormatTxt: Label 'IntelligentCloudService_%1', Comment = '%1 - The source product id', Locked = true;
        DataSyncWizardPageNameTxt: Label 'Set up Cloud Migration';
        CloudMigrationDescriptionTxt: Label 'Migrate data from your on-premises environment to Business Central.';
        HelpLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2013440', Locked = true;
        TelemetryCategoryTxt: Label 'CloudMigration', Locked = true;
        MigrationDisabledTelemetryTxt: Label 'Migration disabled. Source Product=%1; Reason=%2', Comment = '%1 - source product, %2 - reason for disabling', Locked = true;
        UserMustBeAbleToScheduleTasksMsg: Label 'You do not have the right permissions to schedule tasks, which is required for running the migration. Please check your permissions and license entitlements before you continue.';
        IntelligentCloudTok: Label 'IntelligentCloud', Locked = true;
        CreatingIntegrationRuntimeMsg: Label 'Creating Integration Runtime for Product ID: %1', Comment = '%1 - The source product id', Locked = true;
        CreatedIntegrationRuntimeMsg: Label 'Created Integration Runtime, IRName" %1', Comment = '%1 - Name of Integration Runtime', Locked = true;
        ReplicationCompletedServiceTypeTxt: Label 'ReplicationCompleted', Locked = true;
        CannotStartUpgradeDuringCloudMigrationErr: Label 'Upgrade cannot be started because company is under cloud migration.';

    procedure CanHandleNotification(SubscriptionId: Text; ProductId: Text): Boolean
    var
        ExpectedSubscriptionId: Text;
    begin
        ExpectedSubscriptionId := StrSubstNo(SubscriptionFormatTxt, ProductId);
        exit((StrPos(SubscriptionId, ExpectedSubscriptionId) > 0) OR
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

    procedure CanSetupIntelligentCloud(): Boolean
    var
        UserPermissions: Codeunit "User Permissions";
        CanSetup: Boolean;
    begin
        CanSetup := UserPermissions.IsSuper(UserSecurityId()) and TaskScheduler.CanCreateTask();
        OnCanSetupIntelligentCloud(CanSetup);
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

        IntelligentCloudSetup.LockTable();
        IntelligentCloudSetup.Get();
        Clear(IntelligentCloudSetup."Company Creation Session ID");
        Clear(IntelligentCloudSetup."Company Creation Task ID");
        Clear(IntelligentCloudSetup."Company Creation Task Error");
        IntelligentCloudSetup."Company Creation Task Status" := IntelligentCloudSetup."Company Creation Task Status"::InProgress;
        BackupDataPerDatabase(IntelligentCloudSetup);

        if TaskScheduler.CanCreateTask() then
            IntelligentCloudSetup."Company Creation Task ID" := TaskScheduler.CreateTask(
            Codeunit::"Create Companies IC",
            Codeunit::"Handle Create Company Failure", true, '', 0DT)
        else begin
            if not Session.StartSession(SessionID, Codeunit::"Create Companies IC", CompanyName()) then
                Codeunit.Run(Codeunit::"Handle Create Company Failure");
            IntelligentCloudSetup."Company Creation Session ID" := SessionID;
        end;
        Commit();
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

    local procedure IsIntelligentCloudEnabled(): Boolean
    var
        IntelligentCloud: Record "Intelligent Cloud";
    begin
        if not IntelligentCloud.Get() then
            exit(false);

        exit(IntelligentCloud.Enabled);
    end;

    [Scope('OnPrem')]
    internal procedure EnableDataPerDatabaseTables()
    var
        PerDatabaseTables: Dictionary of [Integer, Text[250]];
        TableId: Integer;
    begin
        PerDatabaseTables := GetPerDatabaseTablesToCloudMigrate();
        foreach TableId in PerDatabaseTables.Keys() do
            InsertIntelligentCloudStatusForPerDatabaseTable(TableId, PerDatabaseTables.Get(TableId))
    end;

    local procedure InsertIntelligentCloudStatusForPerDatabaseTable(TableId: Integer; TableName: Text[250])
    var
        IntelligentCloudStatus: Record "Intelligent Cloud Status";
    begin
        if IntelligentCloudStatus.Get(TableName, '') then
            exit;

        IntelligentCloudStatus."Table Id" := TableId;
        IntelligentCloudStatus."Table Name" := TableName;
        IntelligentCloudStatus."Company Name" := '';
        IntelligentCloudStatus.Insert();
    end;

    local procedure GetPerDatabaseTablesToCloudMigrate(): Dictionary of [Integer, Text[250]]
    var
        PerDatabaseTables: Dictionary of [Integer, Text[250]];
    begin
        PerDatabaseTables.Add(9999, 'Upgrade Tags$63ca2fa4-4f03-4f2b-a480-172fef340d3f');
        PerDatabaseTables.Add(2000000184, 'Tenant Media');
        PerDatabaseTables.Add(2000000183, 'Tenant Media Set');
        exit(PerDatabaseTables);
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
        BackupUpgradeTags: Boolean;
    begin
        OnBackupUpgradeTags(IntelligentCloudSetup."Product ID", Handled, BackupUpgradeTags);

        if Handled then
            exit;

        if not BackupUpgradeTags then
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

        SendTraceTag('SmbMig-004', GetTelemetryCategory(), Verbosity::Normal, 'Start disable Azure Data Lake migration.');
        HybridDeployment.DisableDataLakeMigration();
        SendTraceTag('SmbMig-005', GetTelemetryCategory(), Verbosity::Normal, 'Finish disable Azure Data Lake migration.');
    end;

    [Scope('OnPrem')]
    procedure DisableMigration(SourceProduct: Text; Reason: Text; NeedsCleanup: Boolean)
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        IntelligentCloud: Record "Intelligent Cloud";
        HybridDeployment: Codeunit "Hybrid Deployment";
    begin
        SendTraceTag('SmbMig-001', GetTelemetryCategory(), Verbosity::Normal, StrSubstNo(MigrationDisabledTelemetryTxt, SourceProduct, Reason), DataClassification::SystemMetadata);
        RestoreDataPerDatabaseTables(HybridReplicationSummary."Run ID", SourceProduct);

        if NeedsCleanup then begin
            HybridDeployment.Initialize(SourceProduct);
            HybridDeployment.DisableReplication();
        end;

        IntelligentCloud.Get();
        IntelligentCloud.Enabled := false;
        IntelligentCloud.Modify();

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
    end;

    [Scope('OnPrem')]
    procedure RepairCompanionTableRecordConsistency()
    var
        AllObj: Record AllObj;
        InstalledApplication: Record "Installed Application";
        CompanionTableRecordConsistencyRepair: DotNet CompanionTableRecordConsistencyRepair;
    begin
        Session.LogMessage('0000FJ1', 'Starting Repair of Companion Tables', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetTelemetryCategory());
        CompanionTableRecordConsistencyRepair := CompanionTableRecordConsistencyRepair.CompanionTableRecordConsistencyRepair();
        AllObj.SetRange("Object Type", AllObj."Object Type"::"TableExtension");
        if InstalledApplication.FindSet() then
            repeat
                AllObj.SetRange("App Runtime Package ID", InstalledApplication."Runtime Package ID");
                if AllObj.FindFirst() then begin
                    Session.LogMessage('0000FJ2', StrSubstNo('Staring Repair of Companion Tables for Package ID %1', InstalledApplication."Package ID"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetTelemetryCategory());
                    CompanionTableRecordConsistencyRepair.UpdateCompanionTablesInAppWithMissingRecords(InstalledApplication."Runtime Package ID");
                    Session.LogMessage('0000FJ3', StrSubstNo('Completed Repair of Companion Tables for Package ID %1', InstalledApplication."Package ID"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetTelemetryCategory());
                end;
            until InstalledApplication.Next() = 0;

        Session.LogMessage('0000FJ4', 'Completed Repair of Companion Tables', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetTelemetryCategory());
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
            SendTraceTag('SmbMig-002', GetTelemetryCategory(), Verbosity::Normal, 'Scheduled task to clean up Azure Data Lake migration.');
        end else
            if not Session.StartSession(SesssionID, Codeunit::"Data Lake Migration Cleanup", CompanyName()) then
                SendTraceTag('SmbMig-003', GetTelemetryCategory(), Verbosity::Warning, 'Unable to schedule task to clean up Azure Data Lake migration.');
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
        exit(TelemetryCategoryTxt);
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
        PreviousRecord: Record "Hybrid Replication Detail";
    begin
        HybridReplicationDetail.SetCurrentKey("Table Name", "Company Name");
        HybridReplicationDetail.SetRange(Status, HybridReplicationDetail.Status::Successful);
        if HybridReplicationDetail.FindSet() then
            repeat
                HybridReplicationSummary.Get(HybridReplicationDetail."Run ID");

                if HybridReplicationSummary.ReplicationType IN [HybridReplicationSummary.ReplicationType::Full, HybridReplicationSummary.ReplicationType::Normal] then begin
                    if (HybridReplicationDetail."Company Name" <> PreviousRecord."Company Name") or (HybridReplicationDetail."Table Name" <> PreviousRecord."Table Name") then
                        Count += 1;

                    PreviousRecord := HybridReplicationDetail;
                end;
            until HybridReplicationDetail.Next() = 0
    end;

    procedure GetTotalTablesNotMigrated() TotalTables: Integer;
    var
        HybridCompany: Record "Hybrid Company";
        TableMetadata: Record "Table Metadata";
    begin
        TableMetadata.RESET();
        TableMetadata.SETRANGE(ReplicateData, false);
        TableMetadata.SetFilter(ID, '<%1|>%2', 2000000000, 2000000300);
        TableMetadata.SetFilter(Name, '<>*Buffer');
        HybridCompany.Reset();
        HybridCompany.SetRange(Replicate, true);
        if HybridCompany.FindSet() then
            repeat
                IF TableMetadata.CHANGECOMPANY(HybridCompany.Name) THEN // CHANGECOMPANY should transfer the range to the new company
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
        RedirectUrl := GetUrl(CLIENTTYPE::Web, '', OBJECTTYPE::Page, Page::"Hybrid Cloud Setup Wizard", IntelligentCloudSetup, true);
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

        // If no product name is provided, then default to the product identifier
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
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridDeployment: Codeunit "Hybrid Deployment";
        HandledExternally: Boolean;
        DeployedVersion: Text;
        LatestVersion: Text;
    begin
        OnBeforeShowCompanySelectionStep(HybridProductType, SqlConnectionString, SqlServerType, IRName, HandledExternally);
        if HandledExternally then
            exit;

        HybridDeployment.Initialize(HybridProductType.ID);
        HybridDeployment.EnableReplication(SqlConnectionString, SqlServerType, IRName);

        HybridDeployment.GetVersionInformation(DeployedVersion, LatestVersion);
        IntelligentCloudSetup.SetDeployedVersion(DeployedVersion);
        IntelligentCloudSetup.SetLatestVersion(LatestVersion);

        OnAfterEnableMigration(HybridProductType);
    end;

    procedure HandleShowIRInstructionsStep(var HybridProductType: Record "Hybrid Product Type"; var IRName: Text; var PrimaryKey: Text)
    var
        HybridDeployment: Codeunit "Hybrid Deployment";
        HandledExternally: Boolean;
    begin
        Session.LogMessage('0000EV4', StrSubstNo(CreatingIntegrationRuntimeMsg, HybridProductType.ID), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', IntelligentCloudTok);

        OnBeforeShowIRInstructionsStep(HybridProductType, IRName, PrimaryKey, HandledExternally);
        if HandledExternally OR (IRName <> '') then
            exit;

        HybridDeployment.Initialize(HybridProductType.ID);
        HybridDeployment.CreateIntegrationRuntime(IRName, PrimaryKey);
        Session.LogMessage('0000EV5', StrSubstNo(CreatedIntegrationRuntimeMsg, IRName), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', IntelligentCloudTok);
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

    [Scope('OnPrem')]
    procedure RunReplication(ReplicationType: Option) RunId: Text;
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridDeployment: Codeunit "Hybrid Deployment";
    begin
        IntelligentCloudSetup.Get();
        HybridDeployment.Initialize(IntelligentCloudSetup."Product ID");
        if ReplicationType = HybridReplicationSummary.ReplicationType::Full then
            HybridDeployment.ResetCloudData();

        HybridDeployment.RunReplication(RunId, ReplicationType);
        HybridReplicationSummary.CreateInProgressRecord(RunId, ReplicationType);
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
        if not (ReplicationCompletedServiceTypeTxt = ServiceType) then
            exit(false);

        exit(true);
    end;

    procedure RestoreDefaultMigrationTableMappings(DeleteExisting: Boolean)
    var
        MigrationTableMapping: Record "Migration Table Mapping";
        IntellingentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        if DeleteExisting then
            MigrationTableMapping.DeleteAll();

        if IntellingentCloudSetup.Get() then;

        OnInsertDefaultTableMappings(IntellingentCloudSetup."Product ID", DeleteExisting);
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
        SessionID: Integer;
    begin
        ReplicationRunCompletedArg."Run ID" := RunId;
        ReplicationRunCompletedArg."Subscription ID" := SubscriptionId;
        ReplicationRunCompletedArg.Insert();
        ReplicationRunCompletedArg."Notification Text".CreateOutStream(NotificationOutStream);
        NotificationOutStream.WriteText(NotificationText);
        ReplicationRunCompletedArg.Modify();

        if TaskScheduler.CanCreateTask() then
            ReplicationRunCompletedArg.TaskId := TaskScheduler.CreateTask(Codeunit::"Fix Data OnRun Completed", Codeunit::"Handle Fix Data Failure", true, CompanyName(), CurrentDateTime() + 4000, ReplicationRunCompletedArg.RecordId)
        else begin
            Session.StartSession(SessionID, Codeunit::"Fix Data OnRun Completed", CompanyName(), ReplicationRunCompletedArg);
            ReplicationRunCompletedArg."Session Id" := SessionID;
        end;

        ReplicationRunCompletedArg.Modify();
        Commit();
    end;

    local procedure AddWebhookSubscription(SubscriptionId: Text[150]; ClientState: Text[50])
    var
        WebhookSubscription: Record "Webhook Subscription";
        SubscriptionExists: Boolean;
    begin
        WebhookSubscription.LockTable();
        SubscriptionExists := WebhookSubscription.GET(SubscriptionId, '');
        WebhookSubscription."Application ID" := CopyStr(ApplicationIdentifier(), 1, 20);
        WebhookSubscription."Client State" := ClientState;
        WebhookSubscription."Company Name" := CopyStr(CompanyName(), 1, 30);
        WebhookSubscription."Run Notification As" := UserSecurityId();

        WebhookSubscription."Subscription ID" := SubscriptionId;

        if SubscriptionExists then
            WebhookSubscription.Modify()
        else
            WebhookSubscription.Insert();

        Commit();
    end;

    procedure ConstructTableName(Name: Text[30]; TableID: Integer) TableName: Text[250]
    var
        AllObj: Record AllObj;
        PublishedApp: Record "Published Application";
        AppID: Text[50];
    begin
        TableName := Name;
        AllObj.Reset();
        AllObj.SetRange("Object Type", AllObj."Object Type"::Table);
        AllObj.SetRange("Object ID", TableID);
        if AllObj.FindFirst() then begin
            PublishedApp.Reset();
            PublishedApp.SetRange("Runtime Package ID", AllObj."App Runtime Package ID");
            If PublishedApp.FindFirst() then begin
                AppID := CopyStr(Lowercase(CopyStr(PublishedApp.ID, 2, (StrLen(PublishedApp.ID) - 2))), 1, 50);
                TableName := CopyStr(TableName + '$' + AppID, 1, 250);
            end;
        end;
        exit(TableName);
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
    local procedure CanStartUpgrade(CompanyName: Text)
    var
        Handled: Boolean;
    begin
        OnCanStartupgrade(Handled);
        if Handled then
            exit;

        if IsIntelligentCloudEnabled() then
            Error(CannotStartUpgradeDuringCloudMigrationErr);
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

        CleanupSetupTables(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assisted Setup", 'OnRegister', '', false, false)]
    local procedure AddIntelligentCloudToAssistedSetup()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        PermissionManager: Codeunit "Permission Manager";
        Info: ModuleInfo;
        AssistedSetupGroup: Enum "Assisted Setup Group";
        Description: Text[1024];
    begin
        NavApp.GetCurrentModuleInfo(Info);
        Description := CopyStr(CloudMigrationDescriptionTxt, 1, 1024);
        AssistedSetup.Add(Info.Id(), PAGE::"Hybrid Cloud Setup Wizard", DataSyncWizardPageNameTxt, AssistedSetupGroup::ReadyForBusiness, '', "Video Category"::Uncategorized, HelpLinkTxt, Description);
        if PermissionManager.IsIntelligentCloud() then
            AssistedSetup.Complete(PAGE::"Hybrid Cloud Setup Wizard");
    end;

    local procedure CleanupSetupTables(Company: Record Company)
    var
        HybridCompanyStatus: Record "Hybrid Company Status";
    begin
        if HybridCompanyStatus.Get(Company.Name) then
            HybridCompanyStatus.Delete();
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
}