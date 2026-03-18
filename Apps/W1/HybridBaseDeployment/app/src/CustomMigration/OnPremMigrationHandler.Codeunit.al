// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration;

using System.Environment;
using System.Integration;

codeunit 40035 "OnPrem Migration Handler"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Access = Internal;

    var
        GlobalProductId: Text;
        CanModifyDataReplicationRules: Boolean;
        NotSupportedInOnPremErr: Label 'This functionality is not supported in on-premises environments. It cannot be simulated in this context. Please run this test in a SaaS environment';
        TestTrackingIdTxt: Label 'TestTrackingID', Locked = true;
        TestRuntimeNameTxt: Label 'TestRuntimeName';
        CompletedTok: Label 'Completed', Locked = true;

    [Scope('OnPrem')]
    internal procedure Activate()
    var
        HybridDeploymentSetup: Record "Hybrid Deployment Setup";
    begin
        if not HybridDeploymentSetup.Get() then
            HybridDeploymentSetup.Insert();

        HybridDeploymentSetup."Handler Codeunit ID" := Codeunit::"OnPrem Migration Handler";
        HybridDeploymentSetup.Modify();
    end;

    [Scope('OnPrem')]
    internal procedure EnableCloudMigration(var IntegrationRuntimeName: Text)
    var
        InstanceId: Text;
    begin
        EnableDisableCloudMigration(IntegrationRuntimeName, InstanceId, true);
    end;

    [Scope('OnPrem')]
    internal procedure EnableDisableCloudMigration(var IntegrationRuntimeName: Text; var InstanceId: Text; Enable: Boolean)
    var
        IntelligentCloud: Record "Intelligent Cloud";
    begin
        if not CanHandle() then
            exit;

        IntegrationRuntimeName := TestRuntimeNameTxt;
        InstanceId := TestTrackingIdTxt;
        if not IntelligentCloud.Get() then
            IntelligentCloud.Insert();

        IntelligentCloud.Enabled := Enable;
        IntelligentCloud.Modify();
    end;

    local procedure CanHandle(): Boolean
    var
        HybridDeploymentSetup: Record "Hybrid Deployment Setup";
    begin
        if HybridDeploymentSetup.Get() then
            exit(HybridDeploymentSetup."Handler Codeunit ID" = Codeunit::"OnPrem Migration Handler");

        exit(false);
    end;

    [Scope('OnPrem')]
    internal procedure SetCanModifyDataReplicationRules(CanModify: Boolean)
    begin
        CanModifyDataReplicationRules := CanModify;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Deployment", 'OnCreateIntegrationRuntime', '', false, false)]
    local procedure HandleCreateIntegrationRuntime(var InstanceId: Text)
    begin
        if not CanHandle() then
            exit;

        Error(NotSupportedInOnPremErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Deployment", 'OnGetRequestStatus', '', false, false)]
    local procedure HandleGetRequestStatus(InstanceId: Text; var JsonOutput: Text; var Status: Text)
    begin
        if not CanHandle() then
            exit;

        Status := CompletedTok;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Deployment", 'OnInitialize', '', false, false)]
    local procedure HandleInitialize(SourceProductId: Text)
    begin
        if not CanHandle() then
            exit;

        GlobalProductId := SourceProductId;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Deployment", 'OnSetReplicationSchedule', '', false, false)]
#pragma warning disable AA0245
    local procedure HandleSetReplicationSchedule(ReplicationFrequency: Text; DaysToRun: Text; TimeToRun: Time; Activate: Boolean; var InstanceId: Text)
#pragma warning restore AA0245
    begin
        if not CanHandle() then
            exit;

        InstanceId := TestTrackingIdTxt;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Deployment", 'OnEnableReplication', '', false, false)]
    local procedure HandleEnableReplication(OnPremiseConnectionString: Text; DatabaseType: Text; IntegrationRuntimeName: Text; NotificationUrl: Text; ClientState: Text; SubscriptionId: Text; ServiceNotificationUrl: Text; ServiceClientState: Text; ServiceSubscriptionId: Text; var InstanceId: Text)
    begin
        EnableDisableCloudMigration(IntegrationRuntimeName, InstanceId, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Deployment", 'OnGetIntegrationRuntimeKeys', '', false, false)]
    local procedure HandleGetIntegrationKey(var InstanceId: Text)
    begin
        if not CanHandle() then
            exit;

        Error(NotSupportedInOnPremErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"Hybrid Deployment", 'OnRunReplication', '', false, false)]
    local procedure HandleRunReplicationNow(var InstanceId: Text; ReplicationType: Integer)
    begin
        if not CanHandle() then
            exit;

        Error(NotSupportedInOnPremErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"Hybrid Deployment", 'OnDisableReplication', '', false, false)]
    local procedure HandleDisableReplication(var InstanceId: Text)
    begin
        if not CanHandle() then
            exit;

        InstanceId := TestTrackingIdTxt;
    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"Hybrid Deployment", 'OnAfterDisableReplication', '', false, false)]
    local procedure HandleOnAfterDisableReplication(var InstanceId: Text)
    var
        RuntimeName: Text;
    begin
        if not CanHandle() then
            exit;

        InstanceId := TestTrackingIdTxt;

        EnableDisableCloudMigration(RuntimeName, InstanceId, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"Hybrid Deployment", 'OnGetReplicationRunStatus', '', false, false)]
    local procedure HandleGetReplicationRunStatus(var InstanceId: Text; RunId: Text)
    begin
        if not CanHandle() then
            exit;

        Error(NotSupportedInOnPremErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"Hybrid Deployment", 'OnRegenerateIntegrationRuntimeKeys', '', false, false)]
    local procedure HandleRegenerateIntegrationKey(var InstanceId: Text)
    begin
        if not CanHandle() then
            exit;

        Error(NotSupportedInOnPremErr);
    end;


    [EventSubscriber(ObjectType::Codeunit, codeunit::"Hybrid Deployment", 'OnGetVersionInformation', '', false, false)]
    local procedure HandleOnGetVersionInformation(var InstanceId: Text)
    begin
        if not CanHandle() then
            exit;

        Error(NotSupportedInOnPremErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"Hybrid Deployment", 'OnRunUpgrade', '', false, false)]
    local procedure HandleOnRunUpgrade(var InstanceId: Text)
    begin
        if not CanHandle() then
            exit;

        Error(NotSupportedInOnPremErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Deployment", 'OnInitiateDataLakeMigration', '', false, false)]
    local procedure HandleOnInitiateDataLakeMigration(var InstanceId: Text; StorageAccountName: Text; StorageAccountKey: Text)
    begin
        if not CanHandle() then
            exit;

        Error(NotSupportedInOnPremErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Deployment", 'OnDisableDataLakeMigration', '', false, false)]
    local procedure HandleOnDisableDataLakeMigration(var InstanceId: Text)
    begin
        if not CanHandle() then
            exit;

        Error(NotSupportedInOnPremErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnAfterDataLakeMigration', '', false, false)]
    local procedure HandleOnFinishAdlMigration(HybridReplicationSummary: Record "Hybrid Replication Summary"; var Handled: Boolean)
    var
        EnvInfo: Codeunit "Environment Information";
    begin
        if not CanHandle() then
            exit;

        if not EnvInfo.IsSaaS() then
            Error(NotSupportedInOnPremErr);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Intelligent Cloud Management", 'CanRunDiagnostic', '', false, false)]
    local procedure CanRunDiagnostic(var CanRun: Boolean)
    begin
        if not CanHandle() then
            exit;

        CanRun := false;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Intelligent Cloud Management", 'CanMapCustomTables', '', false, false)]
    local procedure CanMapTables(var Enabled: Boolean)
    begin
        if not CanHandle() then
            exit;

        Enabled := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnCanSetupAdlMigration', '', false, false)]
    local procedure HandleCanSetupAdlMigration(var CanSetup: Boolean)
    begin
        if not CanHandle() then
            exit;

        CanSetup := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cloud Mig. Replicate Data Mgt.", 'OnCanIntelligentCloudSetupTableBeModified', '', false, false)]
    local procedure HandleCanIntelligentCloudSetupTableBeModified(TableID: Integer; var CanBeModified: Boolean)
    begin
        if not CanHandle() then
            exit;

        CanBeModified := CanModifyDataReplicationRules;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Cloud Mig - Select Tables", 'OnCanChangeSetup', '', false, false)]
    local procedure HandleCanChangeSetup(var CanChangeSetup: Boolean)
    begin
        if not CanHandle() then
            exit;

        CanChangeSetup := CanModifyDataReplicationRules;
    end;
}