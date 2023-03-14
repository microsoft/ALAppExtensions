codeunit 139679 "Mock Hybrid Deployment Handler"
{
    Permissions = TableData "Hybrid Deployment Setup" = rimd;
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        SourceProduct: Text;
        ReplicationStatusJsonTxt: Label '{ "ReplicationRunId": "%1", "Status": "%2"}';
        TestInstanceIDTok: Label 'TestInstanceID';
        TestRuntimeNameTxt: Label 'TestRuntime';
        CreatedRuntimeJsonTxt: Label '{"Name":"%1","PrimaryKey":"%2"}';
        DeployedLatestVersionJsonTxt: Label '{"DeployedVersion":"%1","LatestVersion":"%2"}';
        RunIDStatusJsonTxt: Label '{"RunId":"TestRun%1"}';
        CompletedTok: Label 'Completed';

    local procedure CanHandle(): Boolean
    var
        HybridDeploymentSetup: Record "Hybrid Deployment Setup";
    begin
        if not HybridDeploymentSetup.Get() then
            exit(false);

        exit(HybridDeploymentSetup."Handler Codeunit ID" = CODEUNIT::"Mock Hybrid Deployment Handler");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Deployment", 'OnCreateIntegrationRuntime', '', false, false)]
    local procedure HandleCreateIntegrationRuntime(var InstanceId: Text)
    begin
        if not CanHandle() then
            exit;

        InstanceId := TestInstanceIDTok;
        LibraryVariableStorage.Enqueue(StrSubstNo(CreatedRuntimeJsonTxt, TestRuntimeNameTxt, CreateGuid()));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Deployment", 'OnDisableReplication', '', false, false)]
    local procedure HandleDisableReplication(var InstanceId: Text)
    begin
        if not CanHandle() then
            exit;

        InstanceId := TestInstanceIDTok;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Deployment", 'OnEnableReplication', '', false, false)]
    local procedure HandleEnableReplication(OnPremiseConnectionString: Text; DatabaseType: Text; IntegrationRuntimeName: Text; NotificationUrl: Text; ClientState: Text; SubscriptionId: Text; ServiceNotificationUrl: Text; ServiceClientState: Text; ServiceSubscriptionId: Text; var InstanceId: Text)
    begin
        if not CanHandle() then
            exit;

        IntegrationRuntimeName := TestRuntimeNameTxt;
        InstanceId := TestInstanceIDTok;
        LibraryVariableStorage.Enqueue(StrSubstNo(ReplicationStatusJsonTxt, TestRuntimeNameTxt, CompletedTok));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnAfterEnableMigration', '', false, false)]
    local procedure OnAfterEnableMigration(HybridProductType: Record "Hybrid Product Type")
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        HybridReplicationSummary."Run ID" := 'Run ' + CreateGuid();
        HybridReplicationSummary."Start Time" := CurrentDateTime();
        HybridReplicationSummary."End Time" := CurrentDateTime();
        HybridReplicationSummary."Trigger Type" := HybridReplicationSummary."Trigger Type"::Manual;
        HybridReplicationSummary.Status := HybridReplicationSummary.Status::Completed;
        HybridReplicationSummary.Source := CopyStr(HybridCloudManagement.GetChosenProductName(), 1, MaxStrLen(HybridReplicationSummary.Source));
        HybridReplicationSummary.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Deployment", 'OnGetIntegrationRuntimeKeys', '', false, false)]
    local procedure HandleGetIntegrationRuntimeKeys(var InstanceId: Text)
    begin
        if not CanHandle() then
            exit;

        InstanceId := TestInstanceIDTok;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Deployment", 'OnGetReplicationRunStatus', '', false, false)]
    local procedure HandleGetReplicationRunStatus(var InstanceId: Text; RunId: Text)
    begin
        if not CanHandle() then
            exit;

        InstanceId := TestInstanceIDTok;
        AddRequestStatusJsonOutput(StrSubstNo(ReplicationStatusJsonTxt, RunId, CompletedTok));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Deployment", 'OnGetRequestStatus', '', false, false)]
    local procedure HandleGetRequestStatus(InstanceId: Text; var JsonOutput: Text; var Status: Text)
    begin
        if not CanHandle() then
            exit;

        JsonOutput := LibraryVariableStorage.DequeueText();
        Status := CompletedTok;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Deployment", 'OnGetVersionInformation', '', false, false)]
    local procedure HandleGetVersionInformation(var InstanceId: Text)
    begin
        if not CanHandle() then
            exit;

        InstanceId := TestInstanceIDTok;
        LibraryVariableStorage.Enqueue(StrSubstNo(DeployedLatestVersionJsonTxt, '20.0.0.0', '20.0.0.0'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Deployment", 'OnInitialize', '', false, false)]
    local procedure HandleInitialize(SourceProductId: Text)
    begin
        if not CanHandle() then
            exit;

        SourceProduct := SourceProductId;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Deployment", 'OnRunReplication', '', false, false)]
    local procedure HandleRunReplication(var InstanceId: Text; ReplicationType: Integer)
    begin
        if not CanHandle() then
            exit;

        InstanceId := TestInstanceIDTok;
        LibraryVariableStorage.Enqueue(StrSubstNo(RunIDStatusJsonTxt, CreateGuid()));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Deployment", 'OnRunUpgrade', '', false, false)]
    local procedure HandleRunUpgrade(var InstanceId: Text)
    begin
        if not CanHandle() then
            exit;

        InstanceId := TestInstanceIDTok;
        LibraryVariableStorage.Enqueue(StrSubstNo(ReplicationStatusJsonTxt, TestRuntimeNameTxt, CompletedTok));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnBeforeShowCompanySelectionStep', '', false, false)]
    local procedure HandleOnBeforeShowCompanySelectionStep(var HybridProductType: Record "Hybrid Product Type"; SqlConnectionString: Text; SqlServerType: Text; IRName: Text; var Handled: Boolean)
    begin
        if not CanHandle() then
            exit;

        InsertHybridCompanyIfMissing();
        Commit();
    end;

    local procedure AddRequestStatusJsonOutput(NewRequestStatusJson: Text)
    begin
        LibraryVariableStorage.Enqueue(NewRequestStatusJson);
    end;

    local procedure InsertHybridCompanyIfMissing()
    var
        HybridCompany: Record "Hybrid Company";
    begin
        if HybridCompany.Get(CompanyName()) then
            exit;

        HybridCompany.Name := CopyStr(CompanyName(), 1, MaxStrLen(HybridCompany.Name));
        HybridCompany."Display Name" := HybridCompany.Name;
        HybridCompany.Replicate := true;
        HybridCompany.Insert();
    end;
}
