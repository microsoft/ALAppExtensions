codeunit 4021 "Hybrid BC Last Management"
{
    Permissions = TableData "Intelligent Cloud Status" = rimd;

    var
        SqlCompatibilityErr: Label 'SQL database must be at compatibility level 130 or higher.';
        DatabaseTooLargeErr: Label 'The maximum allowed amount of data for migration has been exceeded. For more information on how to proceed, see  https://go.microsoft.com/fwlink/?linkid=2013440.';
        TableNotExistsErr: Label 'The table does not exist in the local instance.';
        SchemaMismatchErr: Label 'The local table schema differs from the Business Central cloud table.';
        FailurePreparingDataErr: Label 'Failed to prepare data for the table. Inner error: %1';
        FailureCopyingTableErr: Label 'Failed to copy the table. Inner error: %1';
        UnsupportedVersionErr: Label 'The version of the on-premises deployment does not match the requirements of Business Central online. Check if the version was set correctly on the database. For more information, see the documentation - https://go.microsoft.com/fwlink/?linkid=2148701.';
        CloudMigrationTok: Label 'CloudMigration', Locked = true;
        CompanyUpgradeFailedMsg: Label 'Company upgrade failed', Locked = true;
        PerDatabaseUpgradeFailedMsg: Label 'Ped database upgrade failed', Locked = true;
        CompanyUnderUpgradeErr: Label 'Cloud migration can�t be run, because an upgrade has started on company %1 (upgrade status: %2). Either exclude the company from migration or delete it, then try migration again.', Comment = '%1 - Name of company, %2 Status of upgrade for company';

    procedure GetAppId() AppId: Guid
    var
        ExtensionInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(ExtensionInfo);
        AppId := ExtensionInfo.Id();
    end;

    internal procedure IsSupportedUpgrade(TargetVersion: Decimal): Boolean
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        IntelligentCloudSetup.Get();
        exit(IntelligentCloudSetup."Source BC Version" < TargetVersion);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Message Management", 'OnResolveMessageCode', '', false, false)]
    local procedure GetMessageOnResolveMessageCode(MessageCode: Code[10]; InnerMessage: Text; var Message: Text)
    var
        InteligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridBCLastWizard: Codeunit "Hybrid BC Last Wizard";
        ErrorCodePosition: Integer;
    begin
        if Message <> '' then
            exit;

        if not InteligentCloudSetup.Get() then
            exit;

        if not (InteligentCloudSetup."Product ID" = HybridBCLastWizard.ProductId()) then
            exit;

        if MessageCode = '' then begin
            ErrorCodePosition := StrPos(InnerMessage, 'SqlErrorNumber=');
            if ErrorCodePosition > 0 then
                MessageCode := CopyStr(InnerMessage, ErrorCodePosition + 15, 5);
        end;

        case MessageCode of
            '50001':
                Message := SqlCompatibilityErr;
            '50002':
                Message := DatabaseTooLargeErr;
            '50004':
                Message := TableNotExistsErr;
            '50005':
                Message := SchemaMismatchErr;
            '50006':
                Message := StrSubstNo(FailurePreparingDataErr, InnerMessage);
            '50007':
                Message := StrSubstNo(FailureCopyingTableErr, InnerMessage);
            '50018':
                Message := UnsupportedVersionErr;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnReplicationRunCompleted', '', false, false)]
    local procedure ReplicationRunCompleted(RunId: Text[50]; SubscriptionId: Text; NotificationText: Text)
    var
        W1Management: Codeunit "W1 Management";
    begin
        UpdateStatusOnHybridReplicationCompleted(RunId, SubscriptionId);
        W1Management.SetUpgradePendingOnReplicationRunCompleted(RunId, SubscriptionId, NotificationText);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnVerifyCanReplicateCompanies', '', false, false)]
    local procedure HandleVerifyCanReplicateCompanies(var Reason: Text; var CanReplicate: Boolean)
    var
        HybridCompany: Record "Hybrid Company";
        HybridCompanyStatus: Record "Hybrid Company Status";
        HybridBCLastWizard: Codeunit "Hybrid BC Last Wizard";
    begin
        if not HybridBCLastWizard.IsBCLastMigration() then
            exit;

        HybridCompany.SetRange(Replicate, true);
        if not HybridCompany.FindSet() then begin
            CanReplicate := true;
            exit;
        end;

        repeat
            if HybridCompanyStatus.Get(HybridCompany.Name) then
                if HybridCompanyStatus.Replicated then
                    if HybridCompanyStatus."Upgrade Status" in [HybridCompanyStatus."Upgrade Status"::Completed, HybridCompanyStatus."Upgrade Status"::Started, HybridCompanyStatus."Upgrade Status"::Failed] then begin
                        Reason := StrSubstNo(CompanyUnderUpgradeErr, HybridCompany.Name, HybridCompanyStatus."Upgrade Status");
                        CanReplicate := false;
                        exit;
                    end;
        until HybridCompany.Next() = 0;

        CanReplicate := true;
        exit;
    end;

    local procedure UpdateStatusOnHybridReplicationCompleted(RunId: Text[50]; SubscriptionId: Text)
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        HybridBCLastWizard: Codeunit "Hybrid BC Last Wizard";
        HybridMessageManagement: Codeunit "Hybrid Message Management";
        Message: Text;
    begin
        if not HybridCloudManagement.CanHandleNotification(SubscriptionId, HybridBCLastWizard.ProductId()) then
            exit;

        HybridReplicationSummary.Get(RunId);

        // As of 16.0, Hybrid Replication Detail records are inserted via the pipeline
        // Need to update Hybrid Replication Detail records with translated error messages
        HybridReplicationDetail.SetRange("Run ID", RunId);
        HybridReplicationDetail.SetRange(Status, HybridReplicationDetail.Status::Failed);
        HybridReplicationDetail.SetFilter("Error Code", '<>%1', '');
        if HybridReplicationDetail.FindSet() then
            repeat
                Message := HybridMessageManagement.ResolveMessageCode(CopyStr(HybridReplicationDetail."Error Code", 1, 10), HybridReplicationDetail."Error Message");
                HybridMessageManagement.SetHybridReplicationDetailStatus(HybridReplicationDetail."Error Code", HybridReplicationDetail);
                HybridReplicationDetail."Error Message" := CopyStr(Message, 1, 2048);

                if HybridReplicationDetail."Start Time" = 0DT then
                    HybridReplicationDetail."Start Time" := HybridReplicationSummary."Start Time";

                if HybridReplicationDetail."End Time" = 0DT then
                    HybridReplicationDetail."End Time" := HybridReplicationSummary."End Time";

                HybridReplicationDetail.Modify();
            until HybridReplicationDetail.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Data Load", 'OnAfterCompanyTableLoad', '', false, false)]
    local procedure UpdateStatusOnTableLoaded(TableNo: Integer; SyncedVersion: BigInteger)
    var
        IntelligentCloudStatus: Record "Intelligent Cloud Status";
    begin
        // Need to update IC Status with new synced version on successful table load
        IntelligentCloudStatus.SetRange("Table Id", TableNo);
        IntelligentCloudStatus.SetRange("Company Name", CompanyName());
        if IntelligentCloudStatus.FindFirst() then begin
            IntelligentCloudStatus.Blocked := false;
            IntelligentCloudStatus."Synced Version" := SyncedVersion;
            IntelligentCloudStatus.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Data Load", 'OnAfterNonCompanyTableLoad', '', false, false)]
    local procedure UpdateStatusOnNonCompanyTableLoaded(TableNo: Integer; SyncedVersion: BigInteger)
    var
        IntelligentCloudStatus: Record "Intelligent Cloud Status";
    begin
        // Need to update IC Status with new synced version on successful table load
        IntelligentCloudStatus.SetRange("Table Id", TableNo);
        IntelligentCloudStatus.SetRange("Company Name", '');
        if IntelligentCloudStatus.FindFirst() then begin
            IntelligentCloudStatus.Blocked := false;
            IntelligentCloudStatus."Synced Version" := SyncedVersion;
            IntelligentCloudStatus.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Management", 'OnAfterCompanyUpgradeFailed', '', true, false)]
    local procedure UpdateStatusOnCompanyUpgradeFailed(var HybridReplicationSummary: Record "Hybrid Replication Summary"; ErrorMessage: Text)
    begin
        Session.LogMessage('0000EV2', CompanyUpgradeFailedMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CloudMigrationTok);
        MarkCompanyUpgradeAsFailed(CopyStr(CompanyName(), 1, 50), ErrorMessage, HybridReplicationSummary)
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Management", 'OnAfterNonCompanyUpgradeFailed', '', true, false)]
    local procedure UpdateStatusOnNonCompanyMigrationFailed(var HybridReplicationSummary: Record "Hybrid Replication Summary"; ErrorMessage: Text)
    begin
        Session.LogMessage('0000EV3', PerDatabaseUpgradeFailedMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CloudMigrationTok);
        MarkCompanyUpgradeAsFailed('', ErrorMessage, HybridReplicationSummary)
    end;

    local procedure MarkCompanyUpgradeAsFailed(CompanyName: Text[50]; ErrorMessage: Text; var HybridReplicationSummary: Record "Hybrid Replication Summary")
    var
        HybridCompanyStatus: Record "Hybrid Company Status";
        FailureMessageOutStream: OutStream;
    begin
        HybridCompanyStatus.Get(CompanyName);
        HybridCompanyStatus."Upgrade Status" := HybridCompanyStatus."Upgrade Status"::Failed;
        HybridCompanyStatus."Upgrade Failure Message".CreateOutStream(FailureMessageOutStream);
        FailureMessageOutStream.Write(ErrorMessage);
        HybridCompanyStatus.Modify();

        HybridReplicationSummary.Status := HybridReplicationSummary.Status::UpgradeFailed;
        HybridReplicationSummary.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnBackupUpgradeTags', '', false, false)]
    local procedure BackupUpgradeTags(ProductID: Text[250]; var Handled: Boolean; var BackupUpgradeTags: Boolean)
    begin
        if Handled then
            exit;

        if not GetBCLastProductEnabled() then
            exit;

        // Don't set handled to allow the others to override
        BackupUpgradeTags := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnSetAllUpgradeTags', '', false, false)]
    local procedure HandleSetAllUpgradeTags(NewCompanyName: Text; var SkipSetAllUpgradeTags: Boolean)
    var
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        if SkipSetAllUpgradeTags then
            exit;

        if not GetBCLastProductEnabled() then
            exit;

        SkipSetAllUpgradeTags := HybridCloudManagement.IsCompanyUnderUpgrade(CopyStr(NewCompanyName, 1, 50));
    end;

    procedure GetBCLastProductEnabled(): Boolean
    var
        InteligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridBCLastWizard: Codeunit "Hybrid BC Last Wizard";
    begin
        if not InteligentCloudSetup.Get() then
            exit(false);

        if not (InteligentCloudSetup."Product ID" = HybridBCLastWizard.ProductId()) then
            exit(false);

        exit(true);
    end;
}