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
        UpgradeWillDisableReplicatonsQst: Label 'The upgrade must be triggered as the last step, because you''ll not be able to migrate further data after the upgrade. Before you start the upgrade, make sure that you have moved all companies that you want to move.\\Are you sure that you want to proceed?';
        TelemetryCategoryTok: Label 'HybridBCLast', Locked = true;
        W1CountryCodeTxt: Label 'W1', Locked = true;
        BaseAppExtensionIdTxt: Label '437dbf0e-84ff-417a-965d-ed2bb9650972', Locked = true;
        UpgradeWasScheduledMsg: Label 'Upgrade was succesfully scheduled';
        CannotStartUpgradeCompanyUpgradeCompletedErr: Label 'You cannot start the upgrade because one or more companies are already upgraded. If you want to run the upgrade again, you must delete these companies and start the migration again.';


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
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if Handled then
            exit;

        if not HybridBCLastManagement.GetBCLastProductEnabled() then
            exit;


        HybridCompanyStatus.SetRange("Upgrade Status", HybridCompanyStatus."Upgrade Status"::Completed);
        if not HybridCompanyStatus.IsEmpty() then
            Error(CannotStartUpgradeCompanyUpgradeCompletedErr);

        HybridCloudManagement.VerifyCanStartUpgrade(HybridReplicationSummary);

        if GuiAllowed() then
            if not Confirm(UpgradeWillDisableReplicatonsQst) then
                exit;

        IntelligentCloudSetup.Get();
        if IntelligentCloudSetup."Upgrade Tag Backup ID" <> 0 then
            UpgradeTag.RestoreUpgradeTagsFromBackup(IntelligentCloudSetup."Upgrade Tag Backup ID", true);

        HybridReplicationSummary.Status := HybridReplicationSummary.Status::UpgradeInProgress;
        HybridReplicationSummary.Modify();

        UpgradeNonCompanyData(HybridReplicationSummary);
        Commit();

        Clear(HybridCompanyStatus);
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

    [IntegrationEvent(false, false)]
    local procedure OnInvokePerCompanyUpgrade(HybridReplicationSummary: Record "Hybrid Replication Summary"; CompanyName: Text[30])
    begin
    end;

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
}