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
        StartingInstallGPSmartlistsTelemetryMsg: Label 'Starting Handle Initialization of GP Synchronization', Locked = true;
        UpgradeWasScheduledMsg: Label 'Upgrade was succesfully scheduled';

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
                if (not JsonManagement.GetArrayPropertyValueAsStringByName('IncrementalTables', Value)) then EXIT;
            if j = 2 then
                if (not JsonManagement.GetArrayPropertyValueAsStringByName('GPHistoryTables', Value)) then EXIT;
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
        SesssionID: Integer;
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
        end else begin
            Session.LogMessage('0000FXB', StartingInstallGPSmartlistsTelemetryMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetTelemetryCategory());

            if not TaskScheduler.CanCreateTask() then
                TaskScheduler.CreateTask(
                    Codeunit::"Install GP SmartLists", 0, true, CompanyName(), CurrentDateTime() + 1000)
            else
                Session.StartSession(SesssionID, Codeunit::"Install GP SmartLists", CompanyName())
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnInvokeDataUpgrade', '', false, false)]
    local procedure InvokeDataUpgrade(var HybridReplicationSummary: Record "Hybrid Replication Summary"; var Handled: Boolean)
    var
        HybridCompanyStatus: Record "Hybrid Company Status";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        HybridGPWizard: Codeunit "Hybrid GP Wizard";
    begin
        if Handled then
            exit;

        if not HybridGPWizard.GetGPMigrationEnabled() then
            exit;

        HybridCloudManagement.VerifyCanStartUpgrade(HybridReplicationSummary);

        HybridReplicationSummary.Status := HybridReplicationSummary.Status::UpgradeInProgress;
        HybridReplicationSummary.Modify();
        Commit();

        HybridCompanyStatus.SetRange("Upgrade Status", HybridCompanyStatus."Upgrade Status"::Pending);
        HybridCompanyStatus.FindFirst();

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

    procedure InvokeCompanyUpgrade(var HybridReplicationSummary: Record "Hybrid Replication Summary"; CompanyName: Text[50])
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

        if TaskScheduler.CanCreateTask() then
            TaskScheduler.CreateTask(
                Codeunit::"GP Cloud Migration", Codeunit::"Hybrid Handle GP Upgrade Error", true, CompanyName, CurrentDateTime() + 5000, HybridReplicationSummary.RecordId)
        else
            Session.StartSession(SesssionID, Codeunit::"GP Cloud Migration", CompanyName, HybridReplicationSummary)
    end;

    [InternalEvent(false)]
    local procedure OnCreateSessionForUpgrade(var CreateSession: Boolean)
    begin
    end;
}