// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using Microsoft.DataMigration;
using System.Integration;
using System.Text;

codeunit 47013 "SL Hybrid Management"
{
    Access = Internal;

    var
        ItemLengthErr: Label 'There are items that need to be truncated which might cause duplicate key errors. Please check all items where the length of the ITEMNMBR field is greater than 20. Examples: %1', Comment = '%1 - List of Items';
        PostingSetupErr: Label 'These Posting Accounts are missing and will cause posting errors: %1', Comment = '%1 - List of Posting Accounts';
        UpgradeWasScheduledMsg: Label 'Company Migration Upgrade was successfully scheduled';
        UpdateStatusOnHybridReplicationCompletedMsg: Label 'Updating status on SL migration completed.', Locked = true;
        SqlCompatibilityErr: Label 'SQL database must be at compatibility level 130 or higher.';
        CannotContinueUpgradeFailedMsg: Label 'Previous data upgrade has failed. You need to delete the failed companies and to migrate them again.';
        ReplicationCompletedServiceTypeTxt: Label 'ReplicationCompleted', Locked = true;
        SLSettingUpgradePendingOnReplicationRunCompletedMsg: Label 'Setting upgrade pending on Replication Run Completed.', Locked = true;
        SLCloudMigrationReplicationErrorsMsg: Label 'Errors occurred during SL Cloud Migration. Error message: %1.', Locked = true;
        StartingHandleInitializationofSLSynchronizationTelemetryMsg: Label 'Starting HandleInitializationofSLSynchronization', Locked = true;
        CannotUseDataMigrationOverviewMsg: Label 'It is not possible to use the Data Migration Overview page to fix the errors that occurred during SL Cloud Migration, it will not be possible to start the Data Upgrade again. Investigate the issue and after fixing the issue, delete the failed companies and migrate them again.';
        ProductIdLbl: Label 'DynamicsSL', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", OnReplicationRunCompleted, '', false, false)]
    local procedure HandleSLOnReplicationRunCompleted(RunId: Text[50]; SubscriptionId: Text; NotificationText: Text)
    var
        HybridSLWizard: Codeunit "SL Hybrid Wizard";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        if not HybridCloudManagement.CanHandleNotification(SubscriptionId, HybridSLWizard.ProductIdTxt()) then
            exit;

        UpdateStatusOnHybridReplicationCompleted(RunId, NotificationText);
        InitializationofSLSynchronization(RunId, SubscriptionId, NotificationText);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Hybrid Cloud Setup Wizard", OnHandleCloseWizard, '', false, false)]
    local procedure OnHandleSLCloseWizard(var Handled: Boolean; var CloseWizard: Boolean)
    var
        HybridSLWizard: Codeunit "SL Hybrid Wizard";
    begin
        if not (HybridSLWizard.GetSLMigrationEnabled()) then
            exit;

        Handled := true;
        CloseWizard := true;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Data Migration Overview", OnOpenPageEvent, '', false, false)]
    local procedure HandleDataMigrationOverviewOpen(var Rec: Record "Data Migration Status")
    var
        HybridSLWizard: Codeunit "SL Hybrid Wizard";
    begin
        if not (HybridSLWizard.GetSLMigrationEnabled()) then
            exit;
        Message(CannotUseDataMigrationOverviewMsg);
    end;

    internal procedure InitializationofSLSynchronization(RunID: Text[50]; SubscriptionId: Text; NotificationText: Text)
    var
        HybridCompanyStatus: Record "Hybrid Company Status";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        SLHelperFunctions: Codeunit "SL Helper Functions";
        JsonManagement: Codeunit "JSON Management";
        ServiceType: Text;
    begin
        if HybridCloudManagement.CanHandleNotification(SubscriptionId, ProductIdLbl) then begin
            // Do not process migration data for a diagnostic run since there should be none
            if HybridReplicationSummary.Get(RunID) and (HybridReplicationSummary.ReplicationType = HybridReplicationSummary.ReplicationType::Diagnostic) then
                exit;

            JsonManagement.InitializeObject(NotificationText);
            JsonManagement.GetStringPropertyValueByName('ServiceType', ServiceType);
            Session.LogMessage('0000FXA', StartingHandleInitializationofSLSynchronizationTelemetryMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', SLHelperFunctions.GetTelemetryCategory());

            if ServiceType = ReplicationCompletedServiceTypeTxt then begin
                Session.LogMessage('0000FVN', SLSettingUpgradePendingOnReplicationRunCompletedMsg, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', SLHelperFunctions.GetTelemetryCategory());
                HybridCloudManagement.SetUpgradePendingOnReplicationRunCompleted(RunID, SubscriptionId, NotificationText);

                if HybridCompanyStatus.Get('') then
                    HybridCompanyStatus.Delete();
            end
        end;
    end;

    internal procedure UpdateStatusOnHybridReplicationCompleted(RunId: Text[50]; NotificationText: Text)
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridMessageManagement: Codeunit "Hybrid Message Management";
        JsonManagement: Codeunit "JSON Management";
        JsonManagement2: Codeunit "JSON Management";
        SLHelperFunctions: Codeunit "SL Helper Functions";
        IncrementalTableCount: Integer;
        i: Integer;
        j: Integer;
        ErrorCode: Text;
        ErrorMessage: Text;
        Errors: Text;
        IncrementalTable: Text;
        Value: Text;
    begin
        Session.LogMessage('0000FVL', UpdateStatusOnHybridReplicationCompletedMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', SLHelperFunctions.GetTelemetryCategory());
        // Get table information, iterate through and create detail records for each
        for j := 1 to 2 do begin
            JsonManagement.InitializeObject(NotificationText);
            // Wrapping these in if/then pairs to ensure backward-compatibility
            if j = 1 then
                if (not JsonManagement.GetArrayPropertyValueAsStringByName('IncrementalTables', Value)) then exit;
            if j = 2 then
                if (not JsonManagement.GetArrayPropertyValueAsStringByName('SLHistoryTables', Value)) then exit;
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
                    Session.LogMessage('0000FVM', StrSubstNo(SLCloudMigrationReplicationErrorsMsg, ErrorMessage), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', SLHelperFunctions.GetTelemetryCategory());
                end;
                HybridReplicationDetail.Insert();
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Message Management", OnResolveMessageCode, '', false, false)]
    local procedure GetSLMessageOnResolveMessageCode(MessageCode: Code[10]; InnerMessage: Text; var Message: Text)
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", OnInvokeDataUpgrade, '', false, false)]
    local procedure InvokeDataUpgrade(var HybridReplicationSummary: Record "Hybrid Replication Summary"; var Handled: Boolean)
    var
        HybridCompanyStatus: Record "Hybrid Company Status";
        FailedUpgradedHybridCompanyStatus: Record "Hybrid Company Status";
        FailedHybridCompanyStatus: Record "Hybrid Company Status";
        SLUpgradeSettings: Record "SL Upgrade Settings";
        HybridSLWizard: Codeunit "SL Hybrid Wizard";
    begin
        if Handled then
            exit;

        if not HybridSLWizard.GetSLMigrationEnabled() then
            exit;

        FailedHybridCompanyStatus.SetRange("Upgrade Status", HybridCompanyStatus."Upgrade Status"::Started);
        FailedHybridCompanyStatus.ModifyAll("Upgrade Status", HybridCompanyStatus."Upgrade Status"::Failed);

        FailedUpgradedHybridCompanyStatus.SetRange("Upgrade Status", HybridCompanyStatus."Upgrade Status"::Failed);
        if not FailedUpgradedHybridCompanyStatus.IsEmpty() then
            Error(CannotContinueUpgradeFailedMsg);

        HybridReplicationSummary.Status := HybridReplicationSummary.Status::UpgradeInProgress;
        HybridReplicationSummary.Modify();

        SLUpgradeSettings.GetonInsertSLUpgradeSettings(SLUpgradeSettings);
        SLUpgradeSettings."Data Upgrade Started" := CurrentDateTime();
        SLUpgradeSettings.Modify();
        Commit();

        HybridCompanyStatus.SetRange("Upgrade Status", HybridCompanyStatus."Upgrade Status"::Pending);
        HybridCompanyStatus.FindFirst();

        InvokeCompanyUpgrade(HybridReplicationSummary, HybridCompanyStatus.Name);
        Handled := true;

        if GuiAllowed then
            Message(UpgradeWasScheduledMsg);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Migration Mgt.", OnBeforeStartMigration, '', false, false)]
    local procedure DisableNewSessionForSLCloudMigration(var CheckExistingData: Boolean; var StartNewSession: Boolean)
    var
        HybridSLWizard: Codeunit "SL Hybrid Wizard";
    begin
        if not HybridSLWizard.GetSLMigrationEnabled() then
            exit;

        StartNewSession := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", OnHandleFixDataOnReplicationCompleted, '', false, false)]
    local procedure SkipSLDataRepair(var Handled: Boolean; var FixData: Boolean)
    var
        HybridSLWizard: Codeunit "SL Hybrid Wizard";
    begin
        if not HybridSLWizard.GetSLMigrationEnabled() then
            exit;

        Handled := true;
        FixData := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", OnIsUpgradeSupported, '', false, false)]
    local procedure OnIsSLUpgradeSupported(var UpgradeSupported: Boolean)
    var
        HybridSLWizard: Codeunit "SL Hybrid Wizard";
    begin
        if HybridSLWizard.GetSLMigrationEnabled() then
            UpgradeSupported := true;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Intelligent Cloud Management", 'OnOpenNewUI', '', false, false)]
    local procedure HandleOnOpenNewUI(var OpenNewUI: Boolean)
    var
        SLHybridWizard: Codeunit "SL Hybrid Wizard";
    begin
        if SLHybridWizard.GetSLMigrationEnabled() then
            OpenNewUI := true;
    end;

    internal procedure InvokeCompanyUpgrade(var HybridReplicationSummary: Record "Hybrid Replication Summary"; CompanyName: Text[50])
    begin
        InvokeCompanyUpgrade(HybridReplicationSummary, CompanyName, GetMinimalDelayDuration());
    end;

    internal procedure InvokeCompanyUpgrade(var HybridReplicationSummary: Record "Hybrid Replication Summary"; CompanyName: Text[50]; DelayDuration: Duration)
    var
        CreateSession: Boolean;
        SessionID: Integer;
    begin
        CreateSession := true;
        OnCreateSessionForUpgrade(CreateSession);
        if not CreateSession then begin
            Codeunit.Run(Codeunit::"SL Cloud Migration", HybridReplicationSummary);
            exit;
        end;

        if DelayDuration = 0 then
            DelayDuration := GetMinimalDelayDuration();

        if TaskScheduler.CanCreateTask() then
            TaskScheduler.CreateTask(
                Codeunit::"SL Cloud Migration", Codeunit::"SL Hybrid Handle Upgrade Error", true, CompanyName, CurrentDateTime() + DelayDuration, HybridReplicationSummary.RecordId, GetDefaultJobTimeout())
        else
            Session.StartSession(SessionID, Codeunit::"SL Cloud Migration", CompanyName, HybridReplicationSummary, GetDefaultJobTimeout())
    end;

    internal procedure GetDefaultJobTimeout(): Duration
    begin
        exit(48 * 60 * 60 * 1000); // 48 hours
    end;

    internal procedure GetMinimalDelayDuration(): Duration
    begin
        exit(5000);
    end;

    [InternalEvent(false)]
    internal procedure OnCreateSessionForUpgrade(var CreateSession: Boolean)
    begin
    end;
}