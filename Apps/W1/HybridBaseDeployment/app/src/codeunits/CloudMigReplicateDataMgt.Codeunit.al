namespace Microsoft.DataMigration;

using System.Environment;
using System.Environment.Configuration;
using System.Integration;
using System.Reflection;
using System.Text;

codeunit 40021 "Cloud Mig. Replicate Data Mgt."
{
    Permissions = tabledata "Intelligent Cloud Status" = rmid;

    internal procedure CanChangeIntelligentCloudStatus(TableID: Integer; var IsObsolete: Boolean): Boolean
    var
        TableMetadata: Record "Table Metadata";
    begin
        if ((TableID >= 2000000000) and (TableID <= 2000100000) and (not (TableID in [Database::"Tenant Media", Database::"Tenant Media Set", Database::"Tenant Media Thumbnails"]))) then
            exit(false);

        if not TableMetadata.Get(TableID) then
            exit(false);

        IsObsolete := TableMetadata.ObsoleteState = TableMetadata.ObsoleteState::Removed;
        exit(true);
    end;

    internal procedure LoadRecords(var IntelligentCloudStatus: Record "Intelligent Cloud Status")
    var
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        HybridCloudManagement.RefreshIntelligentCloudStatusTable();

        if IntelligentCloudStatus.Count() > GetMaximumNumberOfRecordsForFiltering() then
            exit;

        if IntelligentCloudStatus.IsEmpty() then
            exit;

        if not IntelligentCloudStatus.FindSet() then
            exit;

        repeat
            if CheckRecordCanBeModified(IntelligentCloudStatus."Table Id") then
                IntelligentCloudStatus.Mark(true);
        until IntelligentCloudStatus.Next() = 0;

        IntelligentCloudStatus.MarkedOnly(true);
    end;

    internal procedure GetMaximumNumberOfRecordsForFiltering(): Integer
    begin
        exit(10000);
    end;

    internal procedure CheckCanChangeTheTable(var IntelligentCloudStatus: Record "Intelligent Cloud Status")
    begin
        if not IntelligentCloudStatus.FindSet() then
            exit;

        repeat
            if not CheckRecordCanBeModified(IntelligentCloudStatus."Table Id") then
                Error(TableReplicationPropertiesCannotBeChangedErr, IntelligentCloudStatus."Table Name");
        until IntelligentCloudStatus.Next() = 0;
    end;

    internal procedure CheckRecordCanBeModified(TableID: Integer): Boolean
    var
        CanBeIncluded: Boolean;
    begin
        OnCanIntelligentCloudSetupTableBeModified(TableID, CanBeIncluded);
        exit(CanBeIncluded);
    end;

    internal procedure IncludeExcludeTablesFromCloudMigration(var IntelligentCloudStatus: Record "Intelligent Cloud Status"; NewReplicateData: Boolean)
    var
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        TelemetryDictionary: Dictionary of [Text, Text];
        TablesModified: Text;
        SeparatorChar: Char;
    begin
        if not IntelligentCloudStatus.FindSet() then
            exit;

        SeparatorChar := ',';
        repeat
            if IntelligentCloudStatus."Replicate Data" <> NewReplicateData then begin
                InsertInitialLog(IntelligentCloudStatus);
                IntelligentCloudStatus."Replicate Data" := NewReplicateData;
                IntelligentCloudStatus.Modify();
                InsertModifyLog(IntelligentCloudStatus);
                TablesModified += IntelligentCloudStatus."Table Name" + SeparatorChar;
            end;
        until IntelligentCloudStatus.Next() = 0;

        TablesModified := TablesModified.TrimEnd(SeparatorChar);
        TelemetryDictionary.Add('Category', HybridCloudManagement.GetTelemetryCategory());
        TelemetryDictionary.Add('TablesModified', TablesModified);
        TelemetryDictionary.Add('ReplicateData', Format(NewReplicateData, 0, 9));
        Session.LogMessage('0000MRJ', ChangedReplicationPropertyLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, TelemetryDictionary);
    end;

    internal procedure ChangePreserveCloudData(var IntelligentCloudStatus: Record "Intelligent Cloud Status"; NewPreserveCloudData: Boolean)
    var
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        TelemetryDictionary: Dictionary of [Text, Text];
        TablesModified: Text;
        SeparatorChar: Char;
    begin
        if not IntelligentCloudStatus.FindSet() then
            exit;

        SeparatorChar := ',';
        repeat
            if IntelligentCloudStatus."Preserve Cloud Data" <> NewPreserveCloudData then begin
                if (not NewPreserveCloudData) and (IntelligentCloudStatus."Table Id" = Database::"Tenant Media") then
                    Error(NotPossibleToReplaceTenantMediaTableErr);

                if (NewPreserveCloudData) and (IntelligentCloudStatus."Company Name" = '') then
                    Error(NotPossibleToDeltaSyncDataPerCompanyErr);

                InsertInitialLog(IntelligentCloudStatus);
                IntelligentCloudStatus."Preserve Cloud Data" := NewPreserveCloudData;
                IntelligentCloudStatus.Modify();
                InsertModifyLog(IntelligentCloudStatus);
            end;
        until IntelligentCloudStatus.Next() = 0;

        TablesModified := TablesModified.TrimEnd(SeparatorChar);
        TelemetryDictionary.Add('Category', HybridCloudManagement.GetTelemetryCategory());
        TelemetryDictionary.Add('TablesModified', TablesModified);
        TelemetryDictionary.Add('PreserveCloudData', Format(NewPreserveCloudData, 0, 9));
        Session.LogMessage('0000MRK', ChangedPreserveCloudDataPropertyLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, TelemetryDictionary);
    end;

    local procedure GetDocumentationNotificationID(): Guid
    begin
        exit('c6f6b118-feb4-482d-abcc-a6d9e9511111')
    end;

    internal procedure ShowDocumentationNotification()
    var
        MyNotifications: Record "My Notifications";
        DocumentationNotification: Notification;
    begin
        if MyNotifications.Get(UserId(), GetDocumentationNotificationID()) then
            if MyNotifications.Enabled = false then
                exit;

        DocumentationNotification.Id := GetDocumentationNotificationID();
        if DocumentationNotification.Recall() then;
        DocumentationNotification.Message(DocumentationNotificationTitleTxt);
        DocumentationNotification.Scope(NotificationScope::LocalScope);
        DocumentationNotification.AddAction(LearnMoreTxt, Codeunit::"Cloud Mig. Replicate Data Mgt.", 'ShowDocumentation');
        DocumentationNotification.AddAction(DontShowAgainTxt, Codeunit::"Cloud Mig. Replicate Data Mgt.", 'DontShowDocumentationNotificationAgain');
        DocumentationNotification.Send();
    end;

    procedure ShowDocumentation(Notification: Notification)
    begin
        HyperLink(OverrideReplicationSetupDocumentationURLLbl);
    end;

    procedure DontShowDocumentationNotificationAgain(Notification: Notification)
    var
        MyNotifications: Record "My Notifications";
    begin
        if not MyNotifications.SetStatus(GetDocumentationNotificationID(), false) then
            MyNotifications.InsertDefault(
              GetDocumentationNotificationID(), OverrideReplicationSeteupDocumentationNotificationTxt, OverrideReplicationSetupDocumentationNotificationDescriptionTxt, false);
    end;

    local procedure InsertInitialLog(var IntelligentCloudStatus: Record "Intelligent Cloud Status")
    var
        CloudMigrationOverrideLogInitialEntry: Record "Cloud Migration Override Log";
    begin
        CloudMigrationOverrideLogInitialEntry.SetRange("Table Id", IntelligentCloudStatus."Table Id");
        CloudMigrationOverrideLogInitialEntry.SetRange("Company Name", IntelligentCloudStatus."Company Name");
        if CloudMigrationOverrideLogInitialEntry.IsEmpty() then begin
            CloudMigrationOverrideLogInitialEntry.TransferFields(IntelligentCloudStatus, true);
            CloudMigrationOverrideLogInitialEntry."Change Type" := CloudMigrationOverrideLogInitialEntry."Change Type"::"Initial Entry";
            CloudMigrationOverrideLogInitialEntry.Insert(true);
        end;
    end;

    local procedure GetAddTableMappingsNotificationID(): Guid
    begin
        exit('16fd70ce-a173-4068-a3b7-305429a0054f')
    end;

    internal procedure ShowAddTableMappingsNotification()
    var
        MyNotifications: Record "My Notifications";
        AddTableMappingsNotification: Notification;
    begin
        if MyNotifications.Get(UserId(), GetAddTableMappingsNotificationID()) then
            if MyNotifications.Enabled = false then
                exit;

        AddTableMappingsNotification.Id := GetAddTableMappingsNotificationID();
        if AddTableMappingsNotification.Recall() then;
        AddTableMappingsNotification.Message(AddTableMappingsNotificationMessageTxt);
        AddTableMappingsNotification.Scope(NotificationScope::LocalScope);
        AddTableMappingsNotification.AddAction(LearnMoreTxt, Codeunit::"Cloud Mig. Replicate Data Mgt.", 'ShowDocumentation');
        AddTableMappingsNotification.AddAction(DontShowAgainTxt, Codeunit::"Cloud Mig. Replicate Data Mgt.", 'DontShowAddTableMappingsNotificationAgain');
        AddTableMappingsNotification.Send();
    end;

    procedure ShowAddTableMappingsNotificationDocumentation(Notification: Notification)
    begin
        HyperLink(AddMigrationTableMappingsDocumentationURLLbl);
    end;

    procedure DontShowAddTableMappingsNotificationAgain(Notification: Notification)
    var
        MyNotifications: Record "My Notifications";
    begin
        if not MyNotifications.SetStatus(GetAddTableMappingsNotificationID(), false) then
            MyNotifications.InsertDefault(
              GetAddTableMappingsNotificationID(), AddTableMappingsNotificationTitleTxt, AddTableMappingsDescriptionTxt, false);
    end;

    local procedure InsertResetToDefaultLog(var IntelligentCloudStatus: Record "Intelligent Cloud Status")
    var
        CloudMigrationOverrideLogInitialEntry: Record "Cloud Migration Override Log";
    begin
        CloudMigrationOverrideLogInitialEntry.TransferFields(IntelligentCloudStatus, true);
        CloudMigrationOverrideLogInitialEntry."Change Type" := CloudMigrationOverrideLogInitialEntry."Change Type"::"Reset to Default";
        CloudMigrationOverrideLogInitialEntry.Insert(true);
    end;

    var
    local procedure InsertModifyLog(var IntelligentCloudStatus: Record "Intelligent Cloud Status")
        CloudMigrationOverrideLogChangeEntry: Record "Cloud Migration Override Log";
    begin
        CloudMigrationOverrideLogChangeEntry.TransferFields(IntelligentCloudStatus, true);
        Clear(CloudMigrationOverrideLogChangeEntry."Primary Key");
        CloudMigrationOverrideLogChangeEntry."Change Type" := CloudMigrationOverrideLogChangeEntry."Change Type"::Modified;
        CloudMigrationOverrideLogChangeEntry.Insert(true);
    end;

    internal procedure FilterCompanies(var IntelligentCloudStatus: Record "Intelligent Cloud Status"; CompanyFilterDisplayName: Text)
    var
        HybridCompany: Record "Hybrid Company";
    begin
        HybridCompany.SetRange(Name, CompanyFilterDisplayName);
        if HybridCompany.IsEmpty then
            IntelligentCloudStatus.SetFilter("Company Name", CompanyFilterDisplayName)
        else
            IntelligentCloudStatus.SetRange("Company Name", CompanyFilterDisplayName);
    end;

    internal procedure LookupTableData(var IntelligentCloudStatus: Record "Intelligent Cloud Status"; var TableNameFilter: Text): Boolean
    var
        AllObj: Record AllObj;
    begin
        LookupTableData(IntelligentCloudStatus, TableNameFilter, AllObj);
    end;

    internal procedure LookupTableData(var IntelligentCloudStatus: Record "Intelligent Cloud Status"; var TableNameFilter: Text; var AllObj: Record AllObj): Boolean
    var
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
        AllObjects: Page "All Objects";
        AllObjRecordRef: RecordRef;
    begin
        AllObj.SetRange("Object Type", AllObj."Object Type"::Table);

        AllObjects.SetTableView(AllObj);
        AllObjects.LookupMode(true);
        if not (AllObjects.RunModal() in [Action::OK, Action::LookupOK]) then
            exit(false);

        AllObjects.SetSelectionFilter(AllObj);
        AllObjects.GetRecord(AllObj);
        AllObjRecordRef.GetTable(AllObj);
        IntelligentCloudStatus.SetFilter("Table Id", SelectionFilterManagement.GetSelectionFilter(AllObjRecordRef, AllObj.FieldNo(AllObj."Object ID")));

        if not AllObj.FindSet() then
            exit;

        TableNameFilter := '';
        repeat
            TableNameFilter += '|' + AllObj."Object Name";
        until AllObj.Next() = 0;

        TableNameFilter := CopyStr(TableNameFilter, 2, StrLen(TableNameFilter) - 1);
        exit(true);
    end;

    internal procedure UpdateStatusOnTableLoaded(TableNo: Integer; SyncedVersion: BigInteger)
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

    internal procedure UpdateStatusOnNonCompanyTableLoaded(TableNo: Integer; SyncedVersion: BigInteger)
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

    internal procedure ResetToDefault(var IntelligentCloudStatus: Record "Intelligent Cloud Status")
    var
        CloudMigrationOverrideLog: Record "Cloud Migration Override Log";
    begin
        if not IntelligentCloudStatus.FindSet() then
            exit;

        CloudMigrationOverrideLog.SetRange("Change Type", CloudMigrationOverrideLog."Change Type"::"Initial Entry");
        repeat
            CloudMigrationOverrideLog.SetRange("Table Name", IntelligentCloudStatus."Table Name");
            CloudMigrationOverrideLog.SetRange("Company Name", IntelligentCloudStatus."Company Name");
            if CloudMigrationOverrideLog.FindLast() then begin
                IntelligentCloudStatus."Replicate Data" := CloudMigrationOverrideLog."Replicate Data";
                IntelligentCloudStatus."Preserve Cloud Data" := CloudMigrationOverrideLog."Preserve Cloud Data";
                IntelligentCloudStatus.Modify();
                InsertResetToDefaultLog(IntelligentCloudStatus);
            end;
        until IntelligentCloudStatus.Next() = 0;
    end;

    internal procedure GetChangedTables(var IntelligentCloudStatus: Record "Intelligent Cloud Status")
    var
        CloudMigrationOverrideLog: Record "Cloud Migration Override Log";
    begin
        if not CloudMigrationOverrideLog.FindSet() then
            exit;

        repeat
            MarkIntelligentCloudStatusTable(IntelligentCloudStatus, CloudMigrationOverrideLog);
        until CloudMigrationOverrideLog.Next() = 0;
    end;

    local procedure MarkIntelligentCloudStatusTable(var IntelligentCloudStatus: Record "Intelligent Cloud Status"; var CloudMigrationOverride: Record "Cloud Migration Override Log")
    begin
        if not IntelligentCloudStatus.Get(CloudMigrationOverride."Table Name", CloudMigrationOverride."Company Name") then
            exit;

        if CloudMigrationOverride."Change Type" = CloudMigrationOverride."Change Type"::Modified then
            IntelligentCloudStatus.Mark(true)
        else
            IntelligentCloudStatus.Mark(false);
    end;

    [InternalEvent(false, false)]
    local procedure OnCanIntelligentCloudSetupTableBeModified(TableID: Integer; var CanBeModified: Boolean)
    begin
    end;

    var
        TableReplicationPropertiesCannotBeChangedErr: Label 'The replication properties of the table %1 cannot be changed because it is internal. Changing the replication of the sensitive tables is not allowed.', Comment = '%1 - Table name, e.g. CRONUS International Ltd_$Activity Step$437dbf0e-84ff-417a-965d-ed2bb9650972';
        OverrideReplicationSetupDocumentationURLLbl: Label 'https://go.microsoft.com/fwlink/?linkid=2248572', Locked = true;
        AddMigrationTableMappingsDocumentationURLLbl: Label 'https://go.microsoft.com/fwlink/?linkid=2296587', Locked = true;
        OverrideReplicationSeteupDocumentationNotificationTxt: Label 'Cloud Mig. Replication Rules';
        OverrideReplicationSetupDocumentationNotificationDescriptionTxt: Label 'Notification to learn more about how to configure which data is replicated and how.';
        LearnMoreTxt: Label 'Learn more';
        DontShowAgainTxt: Label 'Don''t show again';
        NotPossibleToReplaceTenantMediaTableErr: Label 'It is not possible to overwrite the data in the Tenant Media table as it contains the data needed for the system to run correctly.';
        DocumentationNotificationTitleTxt: Label 'We strongly recommend reading the documentation before making changes, to avoid data loss and incorrect data replication.';
        NotPossibleToDeltaSyncDataPerCompanyErr: Label 'Delta syncing per-company data is not supported. This process is not supported by the service, because it could result in slower replication and incorrect data replication.';
        ChangedReplicationPropertyLbl: Label 'The replication property has been changed.', Locked = true;
        ChangedPreserveCloudDataPropertyLbl: Label 'The Preserve Cloud Data property has been changed.', Locked = true;
        AddTableMappingsNotificationMessageTxt: Label 'We strongly recommend using "Add Table Mappings" action to add table mapping definitions. It will help you to enter the table mappings correctly and avoid any issues during replication.';
        AddTableMappingsNotificationTitleTxt: Label 'Add Migration Table Mappings';
        AddTableMappingsDescriptionTxt: Label 'Notification to learn more about how to configure table mappings instead of entering the data manually.';
}