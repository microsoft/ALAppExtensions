codeunit 4026 "W1 Management"
{
    Description = 'This codeunit manages the W1 data transformation and loading via event subscribers.';
    TableNo = "Hybrid Replication Summary";

    var
        BeginCompanyTxt: Label 'Begin BC Last Intelligent Cloud transformation for company %1.', Locked = true;
        BeginNonCompanyTxt: Label 'Begin BC Last Intelligent Cloud transformation for non company tables.', Locked = true;
        FinishCompanyTxt: Label 'Finish BC Last Intelligent Cloud transformation for company %1.', Locked = true;
        FinishNonCompanyTxt: Label 'Finish BC Last Intelligent Cloud transformation for non company tables.', Locked = true;
        CompanyTransformationFailedTxt: Label 'Company transformation failed with error: %1', Locked = true;
        NonCompanyTransformationFailedTxt: Label 'Non company transformation failed with error: %1', Locked = true;
        UpgradeWillDisableReplicatonsQst: Label 'The upgrade must be triggered as the last step, because you''ll not be able to migrate further data after the upgrade. Before you start the upgrade, make sure that you have moved all companies that you want to move. Are you sure that you want to proceed?';
        UpgradeWillDisableReplicatonAndSignOutUserQst: Label 'The upgrade must be triggered as the last step, because you''ll not be able to migrate further data after the upgrade. Before you start the upgrade, make sure that you have moved all companies that you want to move.\\You''ll lose access to the environment when you start the upgrade process. You can track the process and manage the environment at the Business Central admin center.\\Are you sure that you want to proceed?';
        TelemetryCategoryTok: Label 'HybridBCLast', Locked = true;
        W1CountryCodeTxt: Label 'W1', Locked = true;
        BaseAppExtensionIdTxt: Label '437dbf0e-84ff-417a-965d-ed2bb9650972', Locked = true;
        UpgradeWasScheduledMsg: Label 'Upgrade was succesfully scheduled';
        UpgradeWasScheduledTrackStatusInTACMsg: Label 'Upgrade was succesfully scheduled. You can track the status in the Tenant Admin Center under Operations tab.';
        VerifyCanStartUpgradeForCompanyMsg: Label 'Verifying if the upgrade can be started for the company %1.', Locked = true;
        SettingCanUpgradeToTrueForCompanyNameMsg: Label 'Setting can start upgrade to true, for the company %1', Locked = true;
        UpdatingUpgradeStatusOfTheCompanyMsg: Label 'Setting can start upgrade to true, for the company %1', Locked = true;
        CloudMigrationTok: Label 'CloudMigration', Locked = true;
        CannotStartUpgradeCompanyUpgradeCompletedErr: Label 'You cannot start the upgrade because one or more companies are already upgraded. If you want to run the upgrade again, you must delete these companies and start the migration again.';
        PleaseWaitForUpgradeToBeTriggeredErr: Label 'The upgrade has been scheduled at %1. Please wait for %2 minutes for the task to start. You can check if the upgrade was scheduled and track the progress in on the Operations tab in the Business Central admin center. If the task does not start during this time, start the process again.', Comment = '%1 - Time upgrade action was invoked. %2 Time in minutes to wait.';
        CheckUpgradeStatusInTenantAdminCenterMsg: Label 'The upgrade was scheduled at %1. You can see if the upgrade has run on the Operations tab in the Business Central admin center. In case the upgrade fails, we will have restored the tenant to the point before the upgrade, so you can fix any issues and start a new upgrade run.', Comment = '%1 - Time upgrade action was invoked.';
        SettingTheHybridReplicationSummaryToCompletedTxt: Label 'Updating Hybrid Replication Summary records to completed.', Locked = true;
#if not CLEAN21
        UpgradeEngineSelectQst: Label 'AL Code,Invoke Full Upgrade (New)';
        UseLegacyUpgradeEngineWasChangedTxt: Label 'The setting for using the legacy upgrade engine was changed to %1', Locked = true;
#endif

    trigger OnRun()
    begin
        UpgradePerCompanyData(Rec);
    end;

    procedure SetUpgradePendingOnReplicationRunCompleted(RunId: Text[50]; SubscriptionId: Text; NotificationText: Text)
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        HybridBCLastWizard: Codeunit "Hybrid BC Last Wizard";
        JsonManagement: Codeunit "JSON Management";
        JsonValue: Variant;
        SyncedVersion: BigInteger;
    begin
        if not HybridCloudManagement.CanHandleNotification(SubscriptionId, HybridBCLastWizard.ProductId()) then
            exit;

        JsonManagement.InitializeObject(NotificationText);
        if JsonManagement.GetPropertyValueByName('SyncedVersion', JsonValue) then
            SyncedVersion := JsonValue;

        HybridReplicationSummary.Get(RunId);
        HybridReplicationSummary."Synced Version" := SyncedVersion;
        HybridReplicationSummary.Modify();

        HybridCloudManagement.SetUpgradePendingOnReplicationRunCompleted(RunId, SubscriptionId, NotificationText);
    end;

    procedure IsCompanyReadyForUpgrade(HybridCompany: Record "Hybrid Company"): Boolean
    var
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        exit(HybridCloudManagement.IsCompanyReadyForUpgrade(HybridCompany));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnInvokeDataUpgrade', '', false, false)]
    local procedure InvokeDataUpgrade(var HybridReplicationSummary: Record "Hybrid Replication Summary"; var Handled: Boolean)
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridCompanyStatus: Record "Hybrid Company Status";
        HybridBCLastManagement: Codeunit "Hybrid BC Last Management";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        HybridDeployment: Codeunit "Hybrid Deployment";
        UpgradeTag: Codeunit "Upgrade Tag";
        UseLegacyUpgrade: Boolean;
        BlankDateTime: DateTime;
        TimeAfterLastRun: Duration;
    begin
        if Handled then
            exit;

        if not HybridBCLastManagement.GetBCLastProductEnabled() then
            exit;

        HybridCompanyStatus.SetRange("Upgrade Status", HybridCompanyStatus."Upgrade Status"::Completed);
        if not HybridCompanyStatus.IsEmpty() then
            Error(CannotStartUpgradeCompanyUpgradeCompletedErr);

        HybridCloudManagement.VerifyCanStartUpgrade(HybridReplicationSummary);

        if IntelligentCloudSetup.Get() then
            UseLegacyUpgrade := IntelligentCloudSetup."Use Legacy Upgrade Engine";

        OnUseLegacyUpgrade(UseLegacyUpgrade);

        if GuiAllowed() then
            if UseLegacyUpgrade then begin
                if not Confirm(UpgradeWillDisableReplicatonsQst) then
                    exit;
            end else
                if not Confirm(UpgradeWillDisableReplicatonAndSignOutUserQst) then
                    exit;

        IntelligentCloudSetup.Get();
        if IntelligentCloudSetup."Upgrade Tag Backup ID" <> 0 then
            UpgradeTag.RestoreUpgradeTagsFromBackup(IntelligentCloudSetup."Upgrade Tag Backup ID", true);

        if UseLegacyUpgrade then begin
            HybridReplicationSummary.Status := HybridReplicationSummary.Status::UpgradeInProgress;
            HybridReplicationSummary.Modify();
            Commit();
            InvokeLegacyUpgrade(HybridReplicationSummary, Handled);
            exit;
        end else begin
            if HybridReplicationSummary."Upgrade Started DateTime" <> BlankDateTime then begin
                TimeAfterLastRun := CurrentDateTime() - HybridReplicationSummary."Upgrade Started DateTime";
                if TimeAfterLastRun < (GetUpgradeWaitTimeInMinutes() * 60 * 1000) then
                    Error(PleaseWaitForUpgradeToBeTriggeredErr, HybridReplicationSummary."Upgrade Started DateTime", GetUpgradeWaitTimeInMinutes());
            end;

            HybridReplicationSummary."Upgrade Started DateTime" := CurrentDateTime();
            HybridReplicationSummary.Modify();
            HybridDeployment.StartDataUpgrade();
            Handled := true;
            if GuiAllowed() then
                Message(UpgradeWasScheduledTrackStatusInTACMsg);
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Intelligent Cloud Management", 'OnOpenPageEvent', '', false, false)]
    local procedure RaiseNotificationForUpgrade()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridBCLastManagement: Codeunit "Hybrid BC Last Management";
        CheckUpgradeStatusNotification: Notification;
        BlankDateTime: DateTime;
        UpgradeDuration: Duration;
    begin
        if not GuiAllowed() then
            exit;

        if not HybridBCLastManagement.GetBCLastProductEnabled() then
            exit;

        CheckUpgradeStatusNotification.Id := '53e1ace7-868b-4848-b500-17f1fddef308';
        if CheckUpgradeStatusNotification.Recall() then;

        HybridReplicationSummary.SetCurrentKey("Start Time");
        if not HybridReplicationSummary.FindLast() then
            exit;

        if HybridReplicationSummary."Upgrade Started DateTime" = BlankDateTime then
            exit;

        UpgradeDuration := CurrentDateTime - HybridReplicationSummary."Upgrade Started DateTime";
        if UpgradeDuration < (GetUpgradeWaitTimeInMinutes() * 60 * 1000) then
            exit;

        CheckUpgradeStatusNotification.Scope := NotificationScope::LocalScope;
        CheckUpgradeStatusNotification.Message := StrSubstNo(CheckUpgradeStatusInTenantAdminCenterMsg, HybridReplicationSummary."Upgrade Started DateTime");
        if CheckUpgradeStatusNotification.Send() then;
    end;

    local procedure GetUpgradeWaitTimeInMinutes(): Integer
    begin
        exit(15);
    end;

    local procedure InvokeLegacyUpgrade(var HybridReplicationSummary: Record "Hybrid Replication Summary"; var Handled: Boolean)
    var
        HybridCompanyStatus: Record "Hybrid Company Status";
    begin
        UpgradeNonCompanyData(HybridReplicationSummary);
        Commit();

        HybridCompanyStatus.SetRange("Upgrade Status", HybridCompanyStatus."Upgrade Status"::Pending);
        HybridCompanyStatus.SetFilter(Name, '<>''''');
        HybridCompanyStatus.FindFirst();
        InvokePerCompanyUpgrade(HybridReplicationSummary, HybridCompanyStatus.Name);

        Handled := true;
        if GuiAllowed then
            Message(UpgradeWasScheduledMsg);
    end;

    procedure GetSupportedUpgradeVersions(var TargetVersions: List of [Decimal])
    var
        HybridBCLastManagement: Codeunit "Hybrid BC Last Management";
    begin
        if HybridBCLastManagement.IsSupportedUpgrade(15.0) then
            TargetVersions.Add(15.0);

        if HybridBCLastManagement.IsSupportedUpgrade(16.0) then
            TargetVersions.Add(16.0);

        if HybridBCLastManagement.IsSupportedUpgrade(17.0) then
            TargetVersions.Add(17.0);

        if HybridBCLastManagement.IsSupportedUpgrade(18.0) then
            TargetVersions.Add(18.0);

        if HybridBCLastManagement.IsSupportedUpgrade(19.0) then
            TargetVersions.Add(19.0);

        if HybridBCLastManagement.IsSupportedUpgrade(20.0) then
            TargetVersions.Add(20.0);

        if HybridBCLastManagement.IsSupportedUpgrade(21.0) then
            TargetVersions.Add(21.0);
    end;

    procedure PopulateTableMapping();
    var
        SourceTableMapping: Record "Source Table Mapping";
        EnvironmentInformation: Codeunit "Environment Information";
        CountryCode: Code[10];
        TargetVersions: List of [Decimal];
        TargetVersion: Decimal;
    begin
        SourceTableMapping.DeleteAll();

        CountryCode := Format(EnvironmentInformation.GetApplicationFamily());
        GetSupportedUpgradeVersions(TargetVersions);
        foreach TargetVersion in TargetVersions do begin
            OnPopulateW1TableMappingForVersion(CountryCode, TargetVersion);
            OnAfterPopulateW1TableMappingForVersion(CountryCode, TargetVersion);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Management", 'OnPopulateW1TableMappingForVersion', '', false, false)]
    local procedure PopulateW1TableMapping15x(CountryCode: Text; TargetVersion: Decimal)
    var
        SourceTableMapping: Record "Source Table Mapping";
        IncomingDocument: Record "Incoming Document";
        StgIncomingDocument: Record "Stg Incoming Document";
        ExtensionInfo: ModuleInfo;
    begin
        if TargetVersion <> 15.0 then
            exit;

        NavApp.GetCurrentModuleInfo(ExtensionInfo);

        // Provide table mappings here to assist upgrading from 14x -> 15x
        with SourceTableMapping do begin
            MapTable(IncomingDocument.TableName(), W1CountryCodeTxt, StgIncomingDocument.TableName(), true, BaseAppExtensionIdTxt, ExtensionInfo.Id());
            MapTable(IncomingDocument.TableName(), W1CountryCodeTxt, IncomingDocument.TableName(), false, BaseAppExtensionIdTxt, BaseAppExtensionIdTxt);
        end;
    end;

    procedure TelemetryCategory(): Text
    begin
        exit(TelemetryCategoryTok);
    end;

    procedure InvokePerCompanyUpgrade(HybridReplicationSummary: Record "Hybrid Replication Summary"; CompanyName: Text[50])
    var
        HybridBCLastSetup: Record "Hybrid BC Last Setup";
        CreateSession: Boolean;
        SessionID: Integer;
    begin
        if not HybridBCLastSetup.CanHandleCodeunit(Codeunit::"W1 Management") then
            exit;

        CreateSession := true;
        OnCreateSessionForUpgrade(CreateSession);

        if not CreateSession then begin
            Codeunit.Run(Codeunit::"W1 Management", HybridReplicationSummary);
            exit;
        end;

        if TaskScheduler.CanCreateTask() then
            TaskScheduler.CreateTask(Codeunit::"W1 Management", 0, true, CompanyName, 0DT, HybridReplicationSummary.RecordId(), GetDefaultPerCompanyUpgradeTimeout())
        else
            Session.StartSession(SessionID, Codeunit::"W1 Management", CompanyName, HybridReplicationSummary);
    end;

    local procedure GetDefaultPerCompanyUpgradeTimeout(): Duration
    begin
        exit(48 * 60 * 60 * 1000); // 48 hours
    end;

    local procedure UpgradeNonCompanyData(HybridReplicationSummary: Record "Hybrid Replication Summary")
    var
        ErrorMessage: Text;
    begin
        SendTraceTag('0000CA0', TelemetryCategory(), Verbosity::Normal, BeginNonCompanyTxt, DataClassification::SystemMetadata);

        Commit();
        if not Codeunit.Run(CODEUNIT::"Execute Non-Company Upgrade", HybridReplicationSummary) then begin
            ErrorMessage := GetLastErrorText();
            SendTraceTag('0000CA1', TelemetryCategory(), Verbosity::Error, StrSubstNo(NonCompanyTransformationFailedTxt, ErrorMessage), DataClassification::SystemMetadata);
            ClearLastError();
            OnAfterNonCompanyUpgradeFailed(HybridReplicationSummary, ErrorMessage);
        end else begin
            SendTraceTag('0000CA2', TelemetryCategory(), Verbosity::Normal, FinishNonCompanyTxt, DataClassification::SystemMetadata);
            OnAfterNonCompanyUpgradeCompleted(HybridReplicationSummary);
        end;
    end;

    local procedure UpgradePerCompanyData(HybridReplicationSummary: Record "Hybrid Replication Summary")
    var
        Company: Record Company;
        ErrorMessage: Text;
    begin
        SendTraceTag('00007EB', TelemetryCategory(), Verbosity::Normal, StrSubstNo(BeginCompanyTxt, Company.Name), DataClassification::SystemMetadata);
        Commit();
        if not Codeunit.Run(Codeunit::"W1 Company Handler", HybridReplicationSummary) then begin
            ErrorMessage := GetLastErrorText() + GetLastErrorCallStack();
            SendTraceTag('00007KD', TelemetryCategory(), Verbosity::Error, StrSubstNo(CompanyTransformationFailedTxt, ErrorMessage), DataClassification::SystemMetadata);
            OnAfterCompanyUpgradeFailed(HybridReplicationSummary, ErrorMessage);
        end else begin
            SendTraceTag('00007EC', TelemetryCategory(), Verbosity::Normal, StrSubstNo(FinishCompanyTxt, Company.Name), DataClassification::SystemMetadata);
            OnAfterCompanyUpgradeCompleted(HybridReplicationSummary);
        end;
    end;

    procedure BeforePerDatabaseUpgrade()
    begin
        if not UseNewUpgradeEngineForCurrentCompany() then
            exit;

        OnBeforePerDatabaseUpgrade();
    end;

    procedure BeforePerCompanyUpgrade()
    begin
        if not UseNewUpgradeEngineForCurrentCompany() then
            exit;

        OnBeforePerCompanyUpgrade();
    end;

    procedure UpdateStatusRecordsAfterUpgradePerDatabase()
    var
        HybridCompanyStatus: Record "Hybrid Company Status";
    begin
        if not UseNewUpgradeEngineForCurrentCompany() then
            exit;

        if HybridCompanyStatus.Get('') then begin
            Session.LogMessage('0000IGF', StrSubstNo(UpdatingUpgradeStatusOfTheCompanyMsg), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CloudMigrationTok);
            HybridCompanyStatus."Upgrade Status" := HybridCompanyStatus."Upgrade Status"::Completed;
            HybridCompanyStatus.Modify();
        end;

        SetUpgradeCompletedOnHybridReplicationStatus();
    end;

    procedure UpdateStatusRecordsAfterUpgradePerCompany()
    var
        HybridCompanyStatus: Record "Hybrid Company Status";
    begin
        if not UseNewUpgradeEngineForCurrentCompany() then
            exit;

        if HybridCompanyStatus.Get(CompanyName) then begin
            Session.LogMessage('0000IGG', StrSubstNo(UpdatingUpgradeStatusOfTheCompanyMsg, CompanyName), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CloudMigrationTok);
            HybridCompanyStatus."Upgrade Status" := HybridCompanyStatus."Upgrade Status"::Completed;
            HybridCompanyStatus.Modify();
        end;

        SetUpgradeCompletedOnHybridReplicationStatus();
    end;

    local procedure SetUpgradeCompletedOnHybridReplicationStatus()
    var
        HybridCompanyStatus: Record "Hybrid Company Status";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
    begin
        HybridCompanyStatus.SetRange("Upgrade Status", HybridCompanyStatus."Upgrade Status"::Pending);
        if not HybridCompanyStatus.IsEmpty() then
            exit;

        Session.LogMessage('0000IGH', SettingTheHybridReplicationSummaryToCompletedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CloudMigrationTok);

        HybridReplicationSummary.SetRange(Status, HybridReplicationSummary.Status::UpgradeInProgress);
        HybridReplicationSummary.ModifyAll(Status, HybridReplicationSummary.Status::Completed);

        Clear(HybridReplicationSummary);
        HybridReplicationSummary.SetCurrentKey("Start Time");
        HybridReplicationSummary.FindLast();
        if HybridReplicationSummary.Status = HybridReplicationSummary.Status::UpgradePending then begin
            Session.LogMessage('0000IGI', SettingTheHybridReplicationSummaryToCompletedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CloudMigrationTok);
            HybridReplicationSummary.Status := HybridReplicationSummary.Status::Completed;
            HybridReplicationSummary.Modify();
        end;
    end;

    local procedure UseNewUpgradeEngineForCurrentCompany(): Boolean
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridCompanyStatus: Record "Hybrid Company Status";
        HybridBCLastManagement: Codeunit "Hybrid BC Last Management";
        UseLegacyUpgrade: Boolean;
    begin
        if not HybridBCLastManagement.GetBCLastProductEnabled() then
            exit(false);

        OnUseLegacyUpgrade(UseLegacyUpgrade);
        if UseLegacyUpgrade then
            exit(false);

        if IntelligentCloudSetup.Get() then
            if IntelligentCloudSetup."Use Legacy Upgrade Engine" then
                exit(false);

        if not HybridCompanyStatus.Get(CompanyName) then
            exit(false);

        exit(HybridCompanyStatus."Upgrade Status" = HybridCompanyStatus."Upgrade Status"::Pending);
    end;

#if not CLEAN21
    procedure ChangeUpgradeEngine()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridBCLastManagement: Codeunit "Hybrid BC Last Management";
        Selection: Integer;
        CurrentlySelected: Integer;
    begin
        if not HybridBCLastManagement.GetBCLastProductEnabled() then
            exit;

        IntelligentCloudSetup.Get();

        CurrentlySelected := 1;
        if IntelligentCloudSetup."Use Legacy Upgrade Engine" then
            CurrentlySelected := 1;

        Selection := StrMenu(UpgradeEngineSelectQst, CurrentlySelected);
        if Selection = 0 then
            exit;

        IntelligentCloudSetup."Use Legacy Upgrade Engine" := Selection = 1;
        IntelligentCloudSetup.Modify();
        Session.LogMessage('0000IG9', StrSubstNo(UseLegacyUpgradeEngineWasChangedTxt, Format(IntelligentCloudSetup."Use Legacy Upgrade Engine", 0, 9)), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CloudMigrationTok);
    end;
#endif

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Deployment", 'OnHandleVerifyCanStartUpgrade', '', false, false)]
    local procedure HandleVerifyCanStartUpgrade(var CanStartUpgrade: Boolean; var Handled: Boolean)
    begin
        Session.LogMessage('0000IGA', StrSubstNo(VerifyCanStartUpgradeForCompanyMsg, CompanyName), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CloudMigrationTok);

        if not UseNewUpgradeEngineForCurrentCompany() then
            exit;

        Session.LogMessage('0000IGB', StrSubstNo(SettingCanUpgradeToTrueForCompanyNameMsg, CompanyName), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CloudMigrationTok);

        CanStartUpgrade := true;
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Migration Table Mapping", 'OnIsBCMigration', '', false, false)]
    local procedure OnIsBCMigration(var SourceBC: Boolean)
    var
        HybridBCLastManagement: Codeunit "Hybrid BC Last Management";
    begin
        if not HybridBCLastManagement.GetBCLastProductEnabled() then
            exit;

        SourceBC := true;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPopulateW1TableMappingForVersion(CountryCode: Text; TargetVersion: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPopulateW1TableMappingForVersion(CountryCode: Text; TargetVersion: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCompanyUpgradeFailed(var HybridReplicationSummary: Record "Hybrid Replication Summary"; ErrorMessage: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterNonCompanyUpgradeFailed(var HybridReplicationSummary: Record "Hybrid Replication Summary"; ErrorMessage: Text)
    begin
    end;


    [IntegrationEvent(false, false)]
    procedure OnAfterCompanyUpgradeCompleted(HybridReplicationSummary: Record "Hybrid Replication Summary")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterNonCompanyUpgradeCompleted(HybridReplicationSummary: Record "Hybrid Replication Summary")
    begin
    end;

#pragma warning disable AA0228
    [IntegrationEvent(false, false)]
    local procedure OnInvokePerCompanyUpgrade(HybridReplicationSummary: Record "Hybrid Replication Summary"; CompanyName: Text[30])
    begin
    end;
#pragma warning restore

    [IntegrationEvent(false, false)]
    procedure OnUpgradeNonCompanyDataForVersion(HybridReplicationSummary: Record "Hybrid Replication Summary"; TargetVersion: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnTransformNonCompanyTableDataForVersion(CountryCode: Text; TargetVersion: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnLoadNonCompanyTableDataForVersion(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    begin
    end;

    [InternalEvent(false)]
    local procedure OnCreateSessionForUpgrade(var CreateSession: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUseLegacyUpgrade(var UseLegacyUpgrade: Boolean)
    begin
    end;

    // Upgrade events
    [IntegrationEvent(false, false)]
    local procedure OnBeforePerDatabaseUpgrade()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePerCompanyUpgrade()
    begin
    end;
}