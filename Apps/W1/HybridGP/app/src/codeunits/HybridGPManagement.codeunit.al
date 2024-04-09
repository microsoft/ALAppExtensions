namespace Microsoft.DataMigration.GP;

using Microsoft.DataMigration;
using System.Integration;
using System.Text;

codeunit 4016 "Hybrid GP Management"
{
    var
        ItemLengthErr: Label 'There are items that need to be truncated which might cause duplicate key errors. Please check all items where the length of the ITEMNMBR field is greater than 20. Examples: %1', Comment = '%1 - List of Items';
        PostingSetupErr: Label 'These Posting Accounts are missing and will cause posting errors: %1', Comment = '%1 - List of Posting Accounts';
        ReplicationCompletedServiceTypeTxt: Label 'ReplicationCompleted', Locked = true;
        UpdateStatusOnHybridReplicationCompletedMsg: Label 'Updating status on GP migration completed.', Locked = true;
        GPSettingUpgradePendingOnReplicationRunCompletedMsg: Label 'Setting upgrade pending on Replication Run Completed.', Locked = true;
        GPCloudMigrationReplicationErrorsMsg: Label 'Errors occured during GP Cloud Migration. Error message: %1.', Locked = true;
        SqlCompatibilityErr: Label 'SQL database must be at compatibility level 130 or higher.';
        StartingHandleInitializationofGPSynchronizationTelemetryMsg: Label 'Starting HandleInitializationofGPSynchronization', Locked = true;
        UpgradeWasScheduledMsg: Label 'Upgrade was succesfully scheduled';
        GPCloudMigrationDoesNotSupportNewUIMsg: Label 'GP Cloud migration does not support the new UI, please switch back to the previous UI page.';
        CannotContinueUpgradeFailedMsg: Label 'Previous data upgrade has failed. You need to delete the failed companies and to migrate them again.';
        CannotUseDataMigrationOverviewMsg: Label 'It is not possible to use the Data Migration Overview page to fix the errors that occurred during GP Cloud Migration, it is will not be possible to start the Data Upgrade again. Investigate the issue and after fixing the issue, delete the failed companies and migrate them again.';
        OneStepUpgradeStartingLbl: Label 'Starting One Step Upgrade', Locked = true;
        NoDataReplicatedLbl: Label 'No data was replicated. Aborting One Step Upgrade', Locked = true;
        FailedTablesLbl: Label 'There are failed tables. Aborting One Step Upgrade', Locked = true;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnReplicationRunCompleted', '', false, false)]
    local procedure HandleGPOnReplicationRunCompleted(RunId: Text[50]; SubscriptionId: Text; NotificationText: Text)
    var
        HybridGPWizard: Codeunit "Hybrid GP Wizard";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        if not HybridCloudManagement.CanHandleNotification(SubscriptionId, HybridGPWizard.ProductId()) then
            exit;

        UpdateStatusOnHybridReplicationCompleted(RunId, NotificationText);
        HandleInitializationofGPSynchronization(RunId, SubscriptionId, NotificationText);
        TriggerUpgradeIfOneStepEnabled(RunId);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Hybrid Cloud Setup Wizard", 'OnHandleCloseWizard', '', false, false)]
    local procedure OnHandleCloseWizard(var Handled: Boolean; var CloseWizard: Boolean)
    var
        HybridGPWizard: Codeunit "Hybrid GP Wizard";
    begin
        if not (HybridGPWizard.GetGPMigrationEnabled()) then
            exit;

        Handled := true;
        CloseWizard := true;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Data Migration Overview", 'OnOpenPageEvent', '', false, false)]
    local procedure HandleDataMigrationOverviewOpen(var Rec: Record "Data Migration Status")
    var
        HybridGPWizard: Codeunit "Hybrid GP Wizard";
    begin
        if not (HybridGPWizard.GetGPMigrationEnabled()) then
            exit;
        Message(CannotUseDataMigrationOverviewMsg);
    end;

    local procedure TriggerUpgradeIfOneStepEnabled(RunId: Text[50])
    var
        HybridCompanyStatus: Record "Hybrid Company Status";
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        GPUpgradeSettings: Record "GP Upgrade Settings";
        HybridGPManagement: Codeunit "Hybrid GP Management";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        GPUpgradeSettings.GetonInsertGPUpgradeSettings(GPUpgradeSettings);
        if not GPUpgradeSettings."One Step Upgrade" then
            exit;

        Session.LogMessage('0000LJL', OneStepUpgradeStartingLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetTelemetryCategory());

        SelectLatestVersion();
        HybridReplicationDetail.ReadIsolation := IsolationLevel::ReadUncommitted;
        HybridReplicationDetail.SetRange("Run ID", RunId);
        if HybridReplicationDetail.IsEmpty() then begin
            Session.LogMessage('0000LJM', NoDataReplicatedLbl + RunId, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetTelemetryCategory());
            exit;
        end;

        HybridReplicationDetail.SetRange(Status, HybridReplicationDetail.Status::Failed);
        if not HybridReplicationDetail.IsEmpty() then begin
            Session.LogMessage('0000LJN', FailedTablesLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetTelemetryCategory());
            exit;
        end;

        HybridCompanyStatus.SetFilter(Name, '<>''''');
        HybridCompanyStatus.SetRange("Upgrade Status", HybridCompanyStatus."Upgrade Status"::Pending);
        if HybridCompanyStatus.FindFirst() then begin
            HybridReplicationSummary.Get(RunId);
            HybridReplicationSummary.Status := HybridReplicationSummary.Status::UpgradeInProgress;
            HybridReplicationSummary.Modify();
            HybridGPManagement.InvokeCompanyUpgrade(HybridReplicationSummary, HybridCompanyStatus.Name, GPUpgradeSettings."One Step Upgrade Delay");
            exit;
        end;
    end;

    local procedure UpdateStatusOnHybridReplicationCompleted(RunId: Text[50]; NotificationText: Text)
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridMessageManagement: Codeunit "Hybrid Message Management";
        JsonManagement: Codeunit "JSON Management";
        JsonManagement2: Codeunit "JSON Management";
        HelperFunctions: Codeunit "Helper Functions";
        ErrorCode: Text;
        ErrorMessage: Text;
        Errors: Text;
        IncrementalTable: Text;
        IncrementalTableCount: Integer;
        Value: Text;
        i: Integer;
        j: Integer;
    begin
        Session.LogMessage('0000FVL', UpdateStatusOnHybridReplicationCompletedMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetTelemetryCategory());
        // Get table information, iterate through and create detail records for each
        for j := 1 to 2 do begin
            JsonManagement.InitializeObject(NotificationText);

            // Wrapping these in if/then pairs to ensure backward-compatibility
            if j = 1 then
                if (not JsonManagement.GetArrayPropertyValueAsStringByName('IncrementalTables', Value)) then exit;
            if j = 2 then
                if (not JsonManagement.GetArrayPropertyValueAsStringByName('GPHistoryTables', Value)) then exit;
            JsonManagement.InitializeCollection(Value);
            IncrementalTableCount := JsonManagement.GetCollectionCount();

            for i := 0 to IncrementalTableCount - 1 do begin
                JsonManagement.GetObjectFromCollectionByIndex(IncrementalTable, i);
                JsonManagement.InitializeObject(IncrementalTable);

                HybridReplicationDetail.Init();
                HybridReplicationDetail."Run ID" := RunId;
                JsonManagement.GetStringPropertyValueByName('TableName', Value);
                HybridReplicationDetail."Table Name" := CopyStr(Value, 1, 250);

                JsonManagement.GetStringPropertyValueByName('CompanyName', Value);
                HybridReplicationDetail."Company Name" := CopyStr(Value, 1, 250);

                HybridReplicationDetail.Status := HybridReplicationDetail.Status::Successful;
                if JsonManagement.GetStringPropertyValueByName('Errors', Errors) and Errors.StartsWith('[') then begin
                    JsonManagement2.InitializeCollection(Errors);
                    if JsonManagement2.GetCollectionCount() > 0 then begin
                        JsonManagement2.GetObjectFromCollectionByIndex(Value, 0);
                        JsonManagement2.InitializeObject(Value);
                        JsonManagement2.GetStringPropertyValueByName('Code', ErrorCode);
                        JsonManagement2.GetStringPropertyValueByName('Message', ErrorMessage);
                    end;
                end else begin
                    JsonManagement.GetStringPropertyValueByName('ErrorMessage', ErrorMessage);
                    JsonManagement.GetStringPropertyValueByName('ErrorCode', ErrorCode);
                end;

                if (ErrorMessage <> '') or (ErrorCode <> '') then begin
                    HybridReplicationDetail.Status := HybridReplicationDetail.Status::Failed;
                    ErrorMessage := HybridMessageManagement.ResolveMessageCode(CopyStr(ErrorCode, 1, 10), ErrorMessage);
                    HybridReplicationDetail."Error Message" := CopyStr(ErrorMessage, 1, 2048);
                    HybridReplicationDetail."Error Code" := CopyStr(ErrorCode, 1, 10);
                    Session.LogMessage('0000FVM', StrSubstNo(GPCloudMigrationReplicationErrorsMsg, ErrorMessage), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetTelemetryCategory());
                end;

                HybridReplicationDetail.Insert();
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Message Management", 'OnResolveMessageCode', '', false, false)]
    local procedure GetGPMessageOnResolveMessageCode(MessageCode: Code[10]; InnerMessage: Text; var Message: Text)
    begin
        if Message <> '' then
            exit;

        case MessageCode of
            '50001':
                Message := SqlCompatibilityErr;
            '50100':
                Message := StrSubstNo(ItemLengthErr, InnerMessage);
            '50110':
                Message := StrSubstNo(PostingSetupErr, InnerMessage);
        end;
    end;

    local procedure HandleInitializationofGPSynchronization(RunId: Text[50]; SubscriptionId: Text; NotificationText: Text)
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridCompanyStatus: Record "Hybrid Company Status";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        JsonManagement: Codeunit "JSON Management";
        HelperFunctions: Codeunit "Helper Functions";
        ServiceType: Text;
    begin
        // Do not process migration data for a diagnostic run since there should be none
        if HybridReplicationSummary.Get(RunId) and (HybridReplicationSummary.ReplicationType = HybridReplicationSummary.ReplicationType::Diagnostic) then
            exit;

        JsonManagement.InitializeObject(NotificationText);
        JsonManagement.GetStringPropertyValueByName('ServiceType', ServiceType);
        Session.LogMessage('0000FXA', StartingHandleInitializationofGPSynchronizationTelemetryMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetTelemetryCategory());

        if ServiceType = ReplicationCompletedServiceTypeTxt then begin
            Session.LogMessage('0000FVN', GPSettingUpgradePendingOnReplicationRunCompletedMsg, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetTelemetryCategory());
            HybridCloudManagement.SetUpgradePendingOnReplicationRunCompleted(RunId, SubscriptionId, NotificationText);
            // Remove PerDatabase company status, it is not applcable for GP
            if HybridCompanyStatus.Get('') then
                HybridCompanyStatus.Delete();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnInvokeDataUpgrade', '', false, false)]
    local procedure InvokeDataUpgrade(var HybridReplicationSummary: Record "Hybrid Replication Summary"; var Handled: Boolean)
    var
        FailedUpgradedHybridCompanyStatus: Record "Hybrid Company Status";
        FailedHybridCompanyStatus: Record "Hybrid Company Status";
        HybridCompanyStatus: Record "Hybrid Company Status";
        GPUpgradeSettings: Record "GP Upgrade Settings";
        HybridGPWizard: Codeunit "Hybrid GP Wizard";
    begin
        if Handled then
            exit;

        if not HybridGPWizard.GetGPMigrationEnabled() then
            exit;

        FailedHybridCompanyStatus.SetRange("Upgrade Status", HybridCompanyStatus."Upgrade Status"::Started);
        FailedHybridCompanyStatus.ModifyAll("Upgrade Status", HybridCompanyStatus."Upgrade Status"::Failed);

        FailedUpgradedHybridCompanyStatus.SetRange("Upgrade Status", HybridCompanyStatus."Upgrade Status"::Failed);
        if not FailedUpgradedHybridCompanyStatus.IsEmpty() then
            Error(CannotContinueUpgradeFailedMsg);

        HybridReplicationSummary.Status := HybridReplicationSummary.Status::UpgradeInProgress;
        HybridReplicationSummary.Modify();
        Commit();

        HybridCompanyStatus.SetRange("Upgrade Status", HybridCompanyStatus."Upgrade Status"::Pending);
        HybridCompanyStatus.FindFirst();
        GPUpgradeSettings.GetonInsertGPUpgradeSettings(GPUpgradeSettings);
        GPUpgradeSettings."Data Upgrade Started" := CurrentDateTime();
        GPUpgradeSettings.Modify();

        InvokeCompanyUpgrade(HybridReplicationSummary, HybridCompanyStatus.Name);
        Handled := true;

        if GuiAllowed then
            Message(UpgradeWasScheduledMsg);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Mgt.", 'OnBeforeStartMigration', '', false, false)]
    local procedure DisableNewSessionForGPCloudMigration(var CheckExistingData: Boolean; var StartNewSession: Boolean)
    var
        HybridGPWizard: Codeunit "Hybrid GP Wizard";
    begin
        if not HybridGPWizard.GetGPMigrationEnabled() then
            exit;

        StartNewSession := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnHandleFixDataOnReplicationCompleted', '', false, false)]
    local procedure SkipDataRepair(var Handled: Boolean; var FixData: Boolean)
    var
        HybridGPWizard: Codeunit "Hybrid GP Wizard";
    begin
        if not HybridGPWizard.GetGPMigrationEnabled() then
            exit;

        Handled := true;
        FixData := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnIsUpgradeSupported', '', false, false)]
    local procedure OnIsUpgradeSupported(var UpgradeSupported: Boolean)
    var
        HybridGPWizard: Codeunit "Hybrid GP Wizard";
    begin
        if HybridGPWizard.GetGPMigrationEnabled() then
            UpgradeSupported := true;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Cloud Migration Management", 'CheckNewUISupported', '', false, false)]
    local procedure HandleCheckNewUISupported()
    var
        HybridGPWizard: Codeunit "Hybrid GP Wizard";
    begin
        if HybridGPWizard.GetGPMigrationEnabled() then
            Message(GPCloudMigrationDoesNotSupportNewUIMsg);
    end;

    procedure InvokeCompanyUpgrade(var HybridReplicationSummary: Record "Hybrid Replication Summary"; CompanyName: Text[50])
    begin
        InvokeCompanyUpgrade(HybridReplicationSummary, CompanyName, GetMinimalDelayDuration());
    end;

    procedure InvokeCompanyUpgrade(var HybridReplicationSummary: Record "Hybrid Replication Summary"; CompanyName: Text[50]; DelayDuration: Duration)
    var
        CreateSession: Boolean;
        SesssionID: Integer;
    begin
        CreateSession := true;
        OnCreateSessionForUpgrade(CreateSession);
        if not CreateSession then begin
            Codeunit.Run(Codeunit::"GP Cloud Migration", HybridReplicationSummary);
            exit;
        end;

        if DelayDuration = 0 then
            DelayDuration := GetMinimalDelayDuration();

        if TaskScheduler.CanCreateTask() then
            TaskScheduler.CreateTask(
                Codeunit::"GP Cloud Migration", Codeunit::"Hybrid Handle GP Upgrade Error", true, CompanyName, CurrentDateTime() + DelayDuration, HybridReplicationSummary.RecordId, GetDefaultJobTimeout())
        else
            Session.StartSession(SesssionID, Codeunit::"GP Cloud Migration", CompanyName, HybridReplicationSummary, GetDefaultJobTimeout())
    end;

    internal procedure GetDefaultJobTimeout(): Duration
    begin
        exit(48 * 60 * 60 * 1000); // 48 hours
    end;

    local procedure GetMinimalDelayDuration(): Duration
    begin
        exit(5000);
    end;

    [InternalEvent(false)]
    local procedure OnCreateSessionForUpgrade(var CreateSession: Boolean)
    begin
    end;
}