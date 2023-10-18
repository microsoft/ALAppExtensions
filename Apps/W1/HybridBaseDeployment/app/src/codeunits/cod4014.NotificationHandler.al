namespace Microsoft.DataMigration;

using Microsoft.CRM.Outlook;
using System.Environment;
using System.Integration;
using System.Text;

codeunit 4014 "Notification Handler"
{
    var
        UpgradeAvailableServiceTypeTxt: Label 'UpgradeAvailable', Locked = true;
        TenantCleanedUpServiceTypeTxt: Label 'TenantCleanedUp', Locked = true;
        CleanupNotificationMsg: Label 'Cloud Migration has been automatically disabled due to prolonged inactivity.';
        CloudMigrationTok: Label 'CloudMigration', Locked = true;
        RecievedWebhookNotificationMsg: Label 'Recieved Webhook Notification from Cloud Migration Service. Subscription ID %1', Locked = true;
        ProcessingServiceNotificationMsg: Label 'Processing Service Notification', Locked = true;
        ProcessingNotificationMsg: Label 'Processing Notification', Locked = true;
        AzureDataLakeMigrationFailedLbl: Label 'Azure Data Lake migration completed with failed tables.';
        DiagnosticFoundErrorsLbl: Label 'Diagnostic run has found errors.';
        HybridReplicationStatusMsg: Label 'Parsing Replication Summary. Status: %1, Replication type: %2', Locked = true;
        ProcessingCleanupNotificationMsg: Label 'Recieved Cleanup Notification from Replication Service. Disabling Cloud Migration.', Locked = true;
        CloudMigrationFailedTablesStatusLbl: Label 'Replication completed with failed tables.';
        ReplicationCompletedLbl: Label 'Replication completed successfully.';
        AzureDataLakeCompletedLbl: Label 'Azure Data Lake migration completed successfully.';
        DiagnosticRunCompletedLbl: Label 'Diagnostic run completed successfully.';
        TableWasNotReplicatedRetryMsg: Label 'Table was not replicated. Run the replication again to move the data.';
        DiagnosticRunPrefixTxt: Label 'Diagnostic run';
        DataReplicationCompletedLbl: Label 'Replication run completed.', Locked = true;
        DataReplicationHadFailedTablesLbl: Label 'Replication run completed with failed tables.', Locked = true;

    [EventSubscriber(ObjectType::Table, Database::"Webhook Notification", 'OnAfterInsertEvent', '', false, false)]
    local procedure HandleIntelligentCloudOnInsertWebhookNotification(var Rec: Record "Webhook Notification"; RunTrigger: Boolean)
    var
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        if Rec.IsTemporary() then
            exit;

        Session.LogMessage('0000EUX', StrSubstNo(RecievedWebhookNotificationMsg, Rec."Subscription ID"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CloudMigrationTok);
        SelectLatestVersion();

        case true of
            HybridCloudManagement.CanHandleServiceNotification(Rec."Subscription ID", ''):
                HandleServiceNotification(Rec);
            HybridCloudManagement.CanHandleNotification(Rec."Subscription ID", ''):
                HandleNotification(Rec);
        end;
    end;

    local procedure HandleNotification(var WebhookNotification: Record "Webhook Notification")
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        NotificationInStream: InStream;
        NotificationText: Text;
    begin
        Session.LogMessage('0000EUY', ProcessingNotificationMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CloudMigrationTok);

        WebhookNotification.Notification.CreateInStream(NotificationInStream);
        NotificationInStream.ReadText(NotificationText);

        ParseReplicationSummary(HybridReplicationSummary, NotificationText);
        UpdateReplicationSummaryDetailsStartAndEndTime(HybridReplicationSummary);
        HybridCloudManagement.OnReplicationRunCompleted(HybridReplicationSummary."Run ID", WebhookNotification."Subscription ID", NotificationText);
    end;

    local procedure HandleServiceNotification(var WebhookNotification: Record "Webhook Notification")
    var
        JsonManagement: Codeunit "JSON Management";
        NotificationInStream: InStream;
        NotificationText: Text;
        ServiceType: Text;
    begin
        Session.LogMessage('0000EUZ', ProcessingServiceNotificationMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CloudMigrationTok);
        WebhookNotification.Notification.CreateInStream(NotificationInStream);
        NotificationInStream.ReadText(NotificationText);

        JsonManagement.InitializeObject(NotificationText);
        JsonManagement.GetStringPropertyValueByName('ServiceType', ServiceType);

        case ServiceType of
            UpgradeAvailableServiceTypeTxt:
                ProcessUpgradeAvailableNotification(NotificationText);
            TenantCleanedUpServiceTypeTxt:
                ProcessCleanupNotification(WebHookNotification."Subscription ID");
            else
                HandleNotification(WebhookNotification);
        end;
    end;

    local procedure GetExtensionRefreshErrorMessage(ExtensionRefreshTxt: Text): Text
    var
        HybridMessageManagement: Codeunit "Hybrid Message Management";
        JsonManagement: Codeunit "JSON Management";
        MessageCode: Text;
        ErrorMessage: Text;
        Value: Text;
    begin
        JsonManagement.InitializeObject(ExtensionRefreshTxt);
        if JsonManagement.GetStringPropertyValueByName('ErrorCode', MessageCode) then
            if MessageCode <> '' then
                ErrorMessage := HybridMessageManagement.ResolveMessageCode(CopyStr(MessageCode, 1, 10), '');

        if JsonManagement.GetStringPropertyValueByName('FailedExtensions', Value) then
            ErrorMessage += ' ' + Value;
        exit(ErrorMessage);
    end;

    procedure ParseReplicationSummary(var HybridReplicationSummary: Record "Hybrid Replication Summary"; NotificationText: Text)
    var
        PreviousHybridReplicationSummary: Record "Hybrid Replication Summary";
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        HybridMessageManagement: Codeunit "Hybrid Message Management";
        JsonManagement: Codeunit "JSON Management";
        OutlookSynchTypeConv: Codeunit "Outlook Synch. Type Conv";
        Value: Text;
        Details: Text;
        MessageCode: Text;
        ServiceType: Text;
        ExistingDetails: Text;
        PreviousDetails: Text;
        TelemetryDictionary: Dictionary of [Text, Text];
        HasFailures: Boolean;
    begin
        JsonManagement.InitializeObject(NotificationText);
        JsonManagement.GetStringPropertyValueByName('RunId', Value);

        if HybridReplicationSummary.Get(Value) then begin
            PreviousHybridReplicationSummary.Copy(HybridReplicationSummary);
            PreviousDetails := HybridReplicationSummary.GetDetails();
            HybridReplicationSummary.Delete();
        end;

        Clear(HybridReplicationSummary);
        HybridReplicationSummary."Run ID" := CopyStr(Value, 1, MaxStrLen(HybridReplicationSummary."Run ID"));
        HybridReplicationSummary.Source := CopyStr(HybridCloudManagement.GetChosenProductName(), 1, MaxStrLen(HybridReplicationSummary.Source));
        HybridReplicationSummary."Start Time" := PreviousHybridReplicationSummary."Start Time";
        HybridReplicationSummary.ReplicationType := PreviousHybridReplicationSummary.ReplicationType;
        HybridReplicationSummary."Trigger Type" := PreviousHybridReplicationSummary."Trigger Type";
        HybridReplicationSummary.Insert();

        if JsonManagement.GetStringPropertyValueByName('StartTime', Value) then
            if Evaluate(HybridReplicationSummary."Start Time", Value) then
                HybridReplicationSummary."Start Time" := OutlookSynchTypeConv.UTC2LocalDT(HybridReplicationSummary."Start Time");

        if JsonManagement.GetStringPropertyValueByName('TriggerType', Value) then
            if not Evaluate(HybridReplicationSummary."Trigger Type", Value) then;

        if JsonManagement.GetStringPropertyValueByName('ReplicationType', Value) and (HybridReplicationSummary.ReplicationType = 0) then
            if not Evaluate(HybridReplicationSummary.ReplicationType, Value) then;

        if JsonManagement.GetStringPropertyValueByName('Status', Value) then begin
            Session.LogMessage('0000EV0', StrSubstNo(HybridReplicationStatusMsg, Format(Value), Format(HybridReplicationSummary.ReplicationType)), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CloudMigrationTok);
            if not Evaluate(HybridReplicationSummary.Status, Value) then;
        end;

        if JsonManagement.GetStringPropertyValueByName('Details', Details) or JsonManagement.GetStringPropertyValueByName('Code', MessageCode) then begin
            if MessageCode <> '' then begin
                Details := HybridMessageManagement.ResolveMessageCode(CopyStr(MessageCode, 1, 10), Details);
                HybridReplicationSummary.SetDetails(Details);
            end;

            if HybridReplicationSummary.Status = HybridReplicationSummary.Status::Completed then
                HybridReplicationSummary.SetDetails(Details);

            // Only look at inner errors if there was no error code provided
            if (HybridReplicationSummary.Status = HybridReplicationSummary.Status::Failed) and (MessageCode = '') then
                if not TryParseErrors(HybridReplicationSummary, Details) then
                    HybridReplicationSummary.SetDetails(Details);
        end;

        if HybridReplicationSummary.Status = HybridReplicationSummary.Status::Completed then begin
            if JsonManagement.GetStringPropertyValueByName('ExtensionRefreshFailed', Value) then
                HybridReplicationSummary.AddDetails(GetExtensionRefreshErrorMessage(Value));

            if JsonManagement.GetStringPropertyValueByName('ExtensionRefreshUnexpectedError', Value) then
                HybridReplicationSummary.AddDetails(GetExtensionRefreshErrorMessage(Value));
        end;

        if HybridReplicationSummary.Status <> HybridReplicationSummary.Status::InProgress then
            HybridReplicationSummary."End Time" := CurrentDateTime();

        if JsonManagement.GetStringPropertyValueByName('ServiceType', ServiceType) then
            if HybridCloudManagement.IsReplicationCompleted(ServiceType) then begin
                if PreviousHybridReplicationSummary.Status = PreviousHybridReplicationSummary.Status::InProgress then
                    Clear(PreviousDetails);

                MarkInProgressDetailRecordsAsFailed(HybridReplicationSummary);
                if (HybridReplicationSummary.ReplicationType in [HybridReplicationSummary.ReplicationType::Full, HybridReplicationSummary.ReplicationType::Diagnostic]) then begin
                    HybridReplicationSummary.CalcFields("Tables Failed");
                    if HybridReplicationSummary."Tables Failed" > 0 then
                        case HybridReplicationSummary.ReplicationType of
                            HybridReplicationSummary.ReplicationType::Full,
                            HybridReplicationSummary.ReplicationType::Normal:
                                HybridReplicationSummary.SetDetails(CloudMigrationFailedTablesStatusLbl + HybridReplicationSummary.GetDetails());
                            HybridReplicationSummary.ReplicationType::"Azure Data Lake":
                                HybridReplicationSummary.SetDetails(AzureDataLakeMigrationFailedLbl);
                            HybridReplicationSummary.ReplicationType::Diagnostic:
                                HybridReplicationSummary.SetDetails(DiagnosticFoundErrorsLbl);
                        end
                    else
                        case HybridReplicationSummary.ReplicationType of
                            HybridReplicationSummary.ReplicationType::Full,
                            HybridReplicationSummary.ReplicationType::Normal:
                                HybridReplicationSummary.SetDetails(ReplicationCompletedLbl);
                            HybridReplicationSummary.ReplicationType::"Azure Data Lake":
                                HybridReplicationSummary.SetDetails(AzureDataLakeCompletedLbl);
                            HybridReplicationSummary.ReplicationType::Diagnostic:
                                HybridReplicationSummary.SetDetails(DiagnosticRunCompletedLbl);
                        end
                end;

                TelemetryDictionary.Add('Category', HybridCloudManagement.GetTelemetryCategory());
                TelemetryDictionary.Add('ReplicationType', HybridCloudManagement.GetReplicationTypeTelemetryText(HybridReplicationSummary));

                if IntelligentCloudSetup.Get() then
                    TelemetryDictionary.Add('SourceProduct', IntelligentCloudSetup."Product ID");

                Session.LogMessage('0000K0H', DataReplicationCompletedLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, TelemetryDictionary);
                HasFailures := HybridReplicationSummary."Tables Failed" > 0;

                if HasFailures then begin
                    TelemetryDictionary.Add('HasFailures', Format(HasFailures, 0, 9));
                    TelemetryDictionary.Add('NumberOfFailedTables', Format(HybridReplicationSummary."Tables Failed", 0, 9));
                    TelemetryDictionary.Add('Details', HybridReplicationSummary.GetDetails());
                    Session.LogMessage('0000K0I', DataReplicationHadFailedTablesLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, TelemetryDictionary);
                end;
            end;

        if HybridReplicationSummary.ReplicationType = HybridReplicationSummary.ReplicationType::Diagnostic then begin
            ExistingDetails := HybridReplicationSummary.GetDetails();
            if ExistingDetails <> '' then
                if not (ExistingDetails.StartsWith(DiagnosticRunPrefixTxt)) then
                    HybridReplicationSummary.SetDetails(DiagnosticRunPrefixTxt + ' - ' + ExistingDetails);
        end;

        if PreviousDetails <> '' then
            if HybridReplicationSummary.GetDetails() = '' then
                HybridReplicationSummary.SetDetails(PreviousDetails);

        HybridReplicationSummary.Modify();
        Commit();

        if HybridReplicationSummary.ReplicationType = HybridReplicationSummary.ReplicationType::"Azure Data Lake" then
            HybridCloudManagement.FinishDataLakeMigration(HybridReplicationSummary);
    end;

    local procedure UpdateReplicationSummaryDetailsStartAndEndTime(HybridReplicationSummary: Record "Hybrid Replication Summary")
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        BlankDateTime: DateTime;
    begin
        Clear(BlankDateTime);
        HybridReplicationDetail.SetRange("Run ID", HybridReplicationSummary."Run ID");
        if HybridReplicationSummary."Start Time" > BlankDateTime then begin
            HybridReplicationDetail.SetRange("Start Time", BlankDateTime);
            if not HybridReplicationDetail.IsEmpty() then
                HybridReplicationDetail.ModifyAll("Start Time", HybridReplicationSummary."Start Time");

            Commit();
        end;

        Clear(HybridReplicationDetail);
        HybridReplicationDetail.SetRange("Run ID", HybridReplicationSummary."Run ID");
        if HybridReplicationSummary."End Time" > BlankDateTime then begin
            HybridReplicationDetail.SetRange("End Time", BlankDateTime);
            if not HybridReplicationDetail.IsEmpty() then
                HybridReplicationDetail.ModifyAll("End Time", HybridReplicationSummary."End Time");

            Commit();
        end;
    end;

    local procedure MarkInProgressDetailRecordsAsFailed(HybridReplicationSummary: Record "Hybrid Replication Summary")
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
    begin
        HybridReplicationDetail.SetRange("Run ID", HybridReplicationSummary."Run ID");
        HybridReplicationDetail.SetRange(Status, HybridReplicationDetail.Status::InProgress);
        HybridReplicationDetail.ModifyAll("Error Message", TableWasNotReplicatedRetryMsg);
        HybridReplicationDetail.ModifyAll(Status, HybridReplicationDetail.Status::Failed);
    end;

    local procedure ProcessCleanupNotification(SubscriptionID: Text)
    var
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        SourceProduct: Text;
    begin
        Session.LogMessage('0000EV1', ProcessingCleanupNotificationMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CloudMigrationTok);
        HybridCloudManagement.GetNotificationSource(SubscriptionID, SourceProduct);
        HybridCloudManagement.DisableMigration(SourceProduct, CleanupNotificationMsg, false);
    end;

    local procedure ProcessUpgradeAvailableNotification(NotificationText: Text)
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        JsonManagement: Codeunit "JSON Management";
        Version: Text;
    begin
        JsonManagement.InitializeObject(NotificationText);
        JsonManagement.GetStringPropertyValueByName('Version', Version);

        IntelligentCloudSetup.SetLatestVersion(Version);
    end;

    [TryFunction]
    local procedure TryParseErrors(var HybridReplicationSummary: Record "Hybrid Replication Summary"; Details: Text)
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridDeployment: Codeunit "Hybrid Deployment";
        HybridMessageManagement: Codeunit "Hybrid Message Management";
        PipelineRunId: Text;
        Errors: Text;
        Status: Text;
    begin
        IntelligentCloudSetup.Get();
        HybridDeployment.Initialize(IntelligentCloudSetup."Product ID");
        if not TryParsePipelineRunId(Details, PipelineRunId) then
            PipelineRunId := HybridReplicationSummary."Run ID";

        HybridDeployment.GetReplicationRunStatus(PipelineRunId, Status, Errors);
        if not (Errors in ['', '[]']) then begin
            Errors := HybridMessageManagement.ResolveMessageCode('', Errors);
            HybridReplicationSummary.SetDetails(Errors);
        end else
            HybridReplicationSummary.SetDetails(Details);
    end;

    [TryFunction]
    local procedure TryParsePipelineRunId(Details: Text; var PipelineRunId: Text)
    var
        JSONManagement: Codeunit "JSON Management";
    begin
        JSONManagement.InitializeObject(Details);
        JSONManagement.GetStringPropertyValueByName('pipelineRunId', PipelineRunId)
    end;
}