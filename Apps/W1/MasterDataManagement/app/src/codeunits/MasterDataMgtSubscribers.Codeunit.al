namespace Microsoft.Integration.MDM;

using System.Threading;
using System.Telemetry;
using System.Environment;
using System.Reflection;
using System.IO;
using System.Environment.Configuration;
using Microsoft.Integration.Dataverse;
using Microsoft.CRM.Contact;
using Microsoft.Sales.Customer;
using Microsoft.CRM.BusinessRelation;
using Microsoft.Purchases.Vendor;
using Microsoft.CRM.Setup;
using Microsoft.Bank.BankAccount;
using Microsoft.Inventory.Item;
using Microsoft.Integration.SyncEngine;
using Microsoft.Utilities;

codeunit 7237 "Master Data Mgt. Subscribers"
{
    Access = Internal;
    Permissions = tabledata "Master Data Mgt. Coupling" = rm,
                  tabledata "Integration Field Mapping" = r,
                  tabledata "Integration Table Mapping" = rm,
                  tabledata "Tenant Media" = imd,
                  tabledata "Tenant Media Set" = imd,
                  tabledata "Tenant Media Thumbnails" = imd,
                  tabledata "Integration Synch. Job" = r,
                  tabledata "Job Queue Entry" = rmd,
                  tabledata "Master Data Management Setup" = r;

    var
        ValueWillBeOverwrittenErr: label 'Record %2 was modified locally since the last synchronization and a different value for field %1 (%3) is synchronizing from the source record.\\Before retrying, open Synchronization Tables, select %4, choose action Fields and either disable the synchronization of %1 or set it up to overwrite local changes. Alternatively, choose to overwrite local changes on synchronization table %4.', Comment = '%1 - a field caption, %2 - a record identifier, %3 - a field value (any value), %4 - table caption';
        UnsupportedKeyLengthErr: label 'Table %1 has a primary key that consists of %2 fields. Synchronization engine doesn''t support renaming with primary key length of more than 5 fields.\\Before retrying, open Synchronization Tables, select %1, choose Synchronization Fields and disable the synchronization of its primary key fields.', Comment = '%1 - a table caption, %2 - an integer';
        MappingDoesNotAllowDirectionErr: label 'The only supported direction for the data synchronization is %1.', Comment = '%1 - a text: From Integration Table';
        RunningFullSynchTelemetryTxt: Label 'Running full synch job for table mapping %1', Locked = true;
        SetContactNoFromSourceCompanyTxt: Label 'For %1 %2, initialized company contact No. to be equal the No. of the company contact from the source company %3.', Locked = true;

    [EventSubscriber(ObjectType::Table, Database::"Integration Table Mapping", 'OnAfterDeleteEvent', '', false, false)]
    local procedure HandleOnAfterDeleteIntegrationTableMapping(var Rec: Record "Integration Table Mapping"; RunTrigger: Boolean)
    var
        JobQueueEntry: record "Job Queue Entry";
        MasterDataManagement: Codeunit "Master Data Management";
        IsHandled: Boolean;
    begin
        if Rec.IsTemporary() then
            exit;

        if Rec.Type <> Rec.Type::"Master Data Management" then
            exit;

        MasterDataManagement.OnHandleOnAfterDeleteIntegrationTableMapping(Rec, RunTrigger, IsHandled);
        if IsHandled then
            exit;

        JobQueueEntry.LockTable();
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetFilter("Object ID to Run", '%1|%2|%3', Codeunit::"Integration Synch. Job Runner", Codeunit::"Int. Uncouple Job Runner", Codeunit::"Int. Coupling Job Runner");
        JobQueueEntry.SetRange("Record ID to Process", Rec.RecordId());
        JobQueueEntry.DeleteTasks();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Queue Start Codeunit", 'OnAfterRun', '', false, false)]
    local procedure OnAfterJobQueueEntryRun(var JobQueueEntry: Record "Job Queue Entry")
    begin
        HandleOnAfterJobQueueEntryRun(JobQueueEntry);
    end;

    internal procedure HandleOnAfterJobQueueEntryRun(var JobQueueEntry: Record "Job Queue Entry")
    var
        IntegrationSynchJob: Record "Integration Synch. Job";
        IntegrationTableMapping: Record "Integration Table Mapping";
        OriginalIntegrationTableMapping: Record "Integration Table Mapping";
        MasterDataManagement: Codeunit "Master Data Management";
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        if IsJobQueueEntryDataSynchJob(JobQueueEntry, IntegrationTableMapping) then begin
            if IntegrationSynchJob.HaveJobsBeenIdle(JobQueueEntry.GetLastLogEntryNo()) then begin
                if JobQueueEntry."Recurring Job" then
                    JobQueueEntry.Status := JobQueueEntry.Status::"On Hold with Inactivity Timeout"
            end else
                JobQueueEntry.Status := JobQueueEntry.Status::Ready;
            FeatureTelemetry.LogUsage('0000JIR', MasterDataManagement.GetFeatureName(), '');
            if IntegrationTableMapping.IsFullSynch() then begin
                Session.LogMessage('0000JIS', StrSubstNo(RunningFullSynchTelemetryTxt, IntegrationTableMapping.Name), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MasterDataManagement.GetTelemetryCategory());
                OriginalIntegrationTableMapping.SetRange(Status, IntegrationTableMapping.Status::Enabled);
                OriginalIntegrationTableMapping.SetRange(Type, OriginalIntegrationTableMapping.Type::"Master Data Management");
                OriginalIntegrationTableMapping.SetRange("Table ID", IntegrationTableMapping."Table ID");
                OriginalIntegrationTableMapping.SetRange("Integration Table ID", IntegrationTableMapping."Integration Table ID");
                OriginalIntegrationTableMapping.SetRange("Delete After Synchronization", false);
                if OriginalIntegrationTableMapping.FindFirst() then
                    if OriginalIntegrationTableMapping."Synch. Only Coupled Records" then begin
                        OriginalIntegrationTableMapping."Synch. Only Coupled Records" := false;
                        OriginalIntegrationTableMapping.Modify();
                    end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", 'OnFindingIfJobNeedsToBeRun', '', false, false)]
    local procedure OnFindingIfJobNeedsToBeRun(var Sender: Record "Job Queue Entry"; var Result: Boolean)
    begin
        HandleOnFindingIfJobNeedsToBeRun(Sender, Result);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Copy Company", 'OnAfterCreatedNewCompanyByCopyCompany', '', false, false)]
    local procedure CleanupSetupAfterCreatedNewCompanyByCopyCompany(NewCompanyName: Text[30])
    var
        MasterDataMgtSubscriber: Record "Master Data Mgt. Subscriber";
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        MasterDataManagementSetup: Record "Master Data Management Setup";
    begin
        MasterDataMgtCoupling.ChangeCompany(NewCompanyName);
        MasterDataMgtCoupling.DeleteAll();
        MasterDataManagementSetup.ChangeCompany(NewCompanyName);
        MasterDataManagementSetup.DeleteAll();
        MasterDataMgtSubscriber.ChangeCompany(NewCompanyName);
        MasterDataMgtSubscriber.DeleteAll();
    end;

    internal procedure HandleOnFindingIfJobNeedsToBeRun(var Sender: Record "Job Queue Entry"; var Result: Boolean)
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        IntegrationTableMapping: Record "Integration Table Mapping";
        MasterDataManagement: Codeunit "Master Data Management";
        RecRef: RecordRef;
        IsHandled: Boolean;
        SourceCompanyName: Text[30];
    begin
        if Result then
            exit;

        if IsJobQueueEntryDataSynchJob(Sender, IntegrationTableMapping) then begin
            MasterDataManagementSetup.Get();
            if MasterDataManagementSetup."Is Enabled" then begin
                MasterDataManagement.OnSetIntegrationTableFilter(IntegrationTableMapping, RecRef, IsHandled);
                if not IsHandled then begin
                    RecRef.Open(IntegrationTableMapping."Integration Table ID", false);
                    MasterDataManagement.OnSetSourceCompanyName(SourceCompanyName, IntegrationTableMapping."Integration Table ID");
                    if SourceCompanyName = '' then
                        SourceCompanyName := MasterDataManagementSetup."Company Name";
                    RecRef.ChangeCompany(SourceCompanyName);
                    IntegrationTableMapping.SetIntRecordRefFilter(RecRef);
                end;
                if not RecRef.IsEmpty() then
                    Result := true;
                RecRef.Close();
            end;
        end;
    end;

    local procedure IsJobQueueEntryDataSynchJob(JobQueueEntry: Record "Job Queue Entry"; var IntegrationTableMapping: Record "Integration Table Mapping"): Boolean
    var
        RecRef: RecordRef;
    begin
        Clear(IntegrationTableMapping);
        if JobQueueEntry."Object Type to Run" <> JobQueueEntry."Object Type to Run"::Codeunit then
            exit(false);
        case JobQueueEntry."Object ID to Run" of
            CODEUNIT::"Integration Synch. Job Runner":
                begin
                    if not RecRef.Get(JobQueueEntry."Record ID to Process") then
                        exit(false);
                    if RecRef.Number() = DATABASE::"Integration Table Mapping" then begin
                        RecRef.SetTable(IntegrationTableMapping);
                        exit(IntegrationTableMapping."Synch. Codeunit ID" = CODEUNIT::"Integration Master Data Synch.");
                    end;
                end;
            CODEUNIT::"Int. Uncouple Job Runner":
                begin
                    if not RecRef.Get(JobQueueEntry."Record ID to Process") then
                        exit(false);
                    if RecRef.Number() = DATABASE::"Integration Table Mapping" then begin
                        RecRef.SetTable(IntegrationTableMapping);
                        exit(IntegrationTableMapping."Uncouple Codeunit ID" = Codeunit::"Master Data Mgt. Tbl. Uncouple");
                    end;
                end;
            CODEUNIT::"Int. Coupling Job Runner":
                begin
                    if not RecRef.Get(JobQueueEntry."Record ID to Process") then
                        exit(false);
                    if RecRef.Number() = DATABASE::"Integration Table Mapping" then begin
                        RecRef.SetTable(IntegrationTableMapping);
                        exit(IntegrationTableMapping."Coupling Codeunit ID" = Codeunit::"Master Data Mgt. Table Couple");
                    end;
                end;
        end;
        exit(false);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Integration Synch. Error List", 'OnOpenSourceRecord', '', false, false)]
    local procedure OnOpenSourceRecord(var RecordId: RecordId; var IsHandled: Boolean)
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        Company: Record Company;
        MasterDataManagement: Codeunit "Master Data Management";
        PageManagement: Codeunit "Page Management";
        RecRef: RecordRef;
        SourceCompanyName: Text[30];
    begin
        if not MasterDataManagement.IsEnabled() then
            exit;

        if not MasterDataManagementSetup.Get() then
            exit;

        if not Company.Get(MasterDataManagementSetup."Company Name") then
            exit;

        RecRef.Open(RecordId.TableNo);
        MasterDataManagement.OnSetSourceCompanyName(SourceCompanyName, RecordId.TableNo);
        if SourceCompanyName = '' then
            SourceCompanyName := MasterDataManagementSetup."Company Name";
        RecRef.ChangeCompany(SourceCompanyName);
        IsHandled := RecRef.Get(RecordId);
        PageManagement.PageRun(RecRef);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Record Synch.", 'OnTransferFieldData', '', false, false)]
    local procedure OnTransferFieldData(SourceFieldRef: FieldRef; DestinationFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    begin
        HandleOnTransferFieldData(SourceFieldRef, DestinationFieldRef, NewValue, IsValueFound, NeedsConversion);
    end;

    internal procedure HandleOnTransferFieldData(SourceFieldRef: FieldRef; DestinationFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        MasterDataManagement: Codeunit "Master Data Management";
        TypeHelper: Codeunit "Type Helper";
        DestinationRecordRef: RecordRef;
        OriginalDestinationFieldValue: Variant;
        EmptyGuid: Guid;
        SourceValue: Text;
        DestinationRecCreatedAt: DateTime;
        DestinationRecModifiedAt: DateTime;
        ValueWillBeOverwritten: Boolean;
        ThrowError: Boolean;
        IsHandled: Boolean;
    begin
        if IsValueFound then
            exit;

        if not MasterDataManagement.IsEnabled() then
            exit;

        if SourceFieldRef.Number() <> DestinationFieldRef.Number() then
            exit;

        if SourceFieldRef.Record().Number() <> DestinationFieldRef.Record().Number() then
            exit;

        OriginalDestinationFieldValue := DestinationFieldRef.Value();
        if DestinationFieldRef.Name() = 'Primary Contact No.' then begin
            SourceValue := Format(SourceFieldRef.Value());
            if (SourceValue = '') or (SourceValue = Format(EmptyGuid)) then begin
                // in case of bringing in a blank value for a field that is marked as "Clear Value on Failed Sync", keep the Destination value
                NewValue := OriginalDestinationFieldValue;
                IsValueFound := true;
                NeedsConversion := false;
            end;
        end;

        if SourceFieldRef.Value() <> DestinationFieldRef.Value() then begin
            DestinationRecordRef := DestinationFieldRef.Record();
            DestinationRecCreatedAt := DestinationRecordRef.Field(DestinationRecordRef.SystemCreatedAtNo()).Value();
            DestinationRecModifiedAt := DestinationRecordRef.Field(DestinationRecordRef.SystemModifiedAtNo()).Value();
            if DestinationRecModifiedAt > DestinationRecCreatedAt then
                if MasterDataMgtCoupling.FindRowFromRecordRef(DestinationRecordRef, MasterDataMgtCoupling) then
                    ValueWillBeOverwritten := TypeHelper.CompareDateTime(DestinationRecModifiedAt, MasterDataMgtCoupling."Last Synch. Modified On") > 0;
        end;

        if ValueWillBeOverwritten then begin
            MasterDataManagement.OnLocalRecordChangeOverwrite(SourceFieldRef, DestinationFieldRef, ThrowError, IsHandled);
            if not IsHandled then begin
                ThrowError := true;
                IntegrationTableMapping.SetRange(Status, IntegrationTableMapping.Status::Enabled);
                IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
                IntegrationTableMapping.SetRange("Delete After Synchronization", false);
                IntegrationTableMapping.SetRange("Table ID", DestinationRecordRef.Number());
                IntegrationTableMapping.SetRange("Integration Table ID", SourceFieldRef.Record().Number());
                if IntegrationTableMapping.FindFirst() then begin
                    IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
                    IntegrationFieldMapping.SetRange("Field No.", SourceFieldRef.Number());
                    if IntegrationFieldMapping.FindFirst() then
                        if IntegrationFieldMapping."Overwrite Local Change" or IntegrationTableMapping."Overwrite Local Change" or (IntegrationFieldMapping.Status = IntegrationFieldMapping.Status::Disabled) then
                            ThrowError := false;
                end;

                Session.LogMessage('0000JIT', DestinationRecordRef.Caption(), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MasterDataManagement.GetTelemetryCategory());
                Session.LogMessage('0000JIU', DestinationRecordRef.Caption() + '.' + DestinationFieldRef.Caption(), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MasterDataManagement.GetTelemetryCategory());
            end;
            if ThrowError then
                Error(ValueWillBeOverwrittenErr, DestinationFieldRef.Caption(), Format(DestinationFieldRef.Record().RecordId()), Format(SourceFieldRef.Value()), Format(DestinationFieldRef.Record().Caption()));
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Table Synch.", 'OnDetermineSynchDirection', '', false, false)]
    local procedure OnDetermineSynchDirection(var CurrentIntegrationTableMapping: Record "Integration Table Mapping"; var TableID: Integer; var ErrorMessage: Text; var IsHandled: Boolean)
    begin
        if (CurrentIntegrationTableMapping.Type <> CurrentIntegrationTableMapping.Type::"Master Data Management") then
            exit;

        if not (CurrentIntegrationTableMapping.Direction in [0, CurrentIntegrationTableMapping.Direction::FromIntegrationTable]) then
            ErrorMessage := StrSubstNo(MappingDoesNotAllowDirectionErr, Format(CurrentIntegrationTableMapping.Direction::FromIntegrationTable));

        CurrentIntegrationTableMapping.Direction := CurrentIntegrationTableMapping.Direction::FromIntegrationTable;
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Integration Table Mapping", 'OnIsCreateNewInCaseOfNoMatchControlVisible', '', false, false)]
    local procedure OnIsCreateNewInCaseOfNoMatchControlVisible(var IntegrationTableMapping: Record "Integration Table Mapping"; var CreateNewInCaseOfNoMatchControlVisible: Boolean; var IsHandled: Boolean)
    begin
        if IntegrationTableMapping.Type <> IntegrationTableMapping.Type::"Master Data Management" then
            exit;

        if IntegrationTableMapping."Delete After Synchronization" then
            exit;

        CreateNewInCaseOfNoMatchControlVisible := true;
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Copy Company", 'OnAfterCreatedNewCompanyByCopyCompany', '', false, false)]
    local procedure HandleOnAfterCreatedNewCompanyByCopyCompany(NewCompanyName: Text[30])
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        MasterDataFullSynchRLn: Record "Master Data Full Synch. R. Ln.";
    begin
        MasterDataMgtCoupling.ChangeCompany(NewCompanyName);
        MasterDataFullSynchRLn.ChangeCompany(NewCompanyName);

        if MasterDataMgtCoupling.IsEmpty() and MasterDataFullSynchRLn.IsEmpty() then
            exit;

        MasterDataMgtCoupling.DeleteAll();
        MasterDataFullSynchRLn.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CRM Synch. Helper", 'OnFindAndSynchRecordIDFromIntegrationSystemId', '', false, false)]
    local procedure OnFindAndSynchRecordIDFromIntegrationSystemId(IntegrationSystemId: Guid; TableId: Integer; var LocalRecordID: RecordID; IsHandled: Boolean)
    begin
        HandleOnFindAndSynchRecordIDFromIntegrationSystemId(IntegrationSystemId, TableId, LocalRecordID, IsHandled);
    end;

    internal procedure HandleOnFindAndSynchRecordIDFromIntegrationSystemId(IntegrationSystemId: Guid; TableId: Integer; var LocalRecordID: RecordID; var IsHandled: Boolean)
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        MasterDataManagement: Codeunit "Master Data Management";
        OutOfMapFilter: Boolean;
    begin
        if not MasterDataManagement.IsEnabled() then
            exit;

        IsHandled := true;
        if not MasterDataMgtCoupling.FindRecordIDFromID(IntegrationSystemId, TableId, LocalRecordID) then
            if SynchRecordIfMappingExists(TableId, TableId, IntegrationSystemId, OutOfMapFilter) then begin
                if not MasterDataMgtCoupling.FindRecordIDFromID(IntegrationSystemId, TableId, LocalRecordID) then
                    exit;
            end else
                if OutOfMapFilter then
                    exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnAfterInsertRecord', '', false, false)]
    local procedure HandleOnAfterInsertRecord(var SourceRecordRef: RecordRef; var DestinationRecordRef: RecordRef)
    begin
        case GetSourceDestCode(SourceRecordRef, DestinationRecordRef) of
            'Customer-Customer',
            'Vendor-Vendor':
                UpdateChildContactsParentCompany(SourceRecordRef);
            'Contact-Contact':
                FixPrimaryContactNo(SourceRecordRef, DestinationRecordRef);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnBeforeModifyRecord', '', false, false)]
    local procedure OnBeforeModifyRecord(IntegrationTableMapping: Record "Integration Table Mapping"; SourceRecordRef: RecordRef; var DestinationRecordRef: RecordRef)
    begin
        if IntegrationTableMapping.Type <> IntegrationTableMapping.Type::"Master Data Management" then
            exit;

        RenameIfNeededOnBeforeModifyRecord(IntegrationTableMapping, SourceRecordRef, DestinationRecordRef);

        if SourceRecordRef.Number() = Database::Item then
            UpdateItemMediaSet(SourceRecordRef, DestinationRecordRef);
    end;

    internal procedure RenameIfNeededOnBeforeModifyRecord(IntegrationTableMapping: Record "Integration Table Mapping"; SourceRecordRef: RecordRef; var DestinationRecordRef: RecordRef)
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        MasterDataManagement: Codeunit "Master Data Management";
        BeforeRenameDestinationRecordRef: RecordRef;
        IsHandled: Boolean;
        SourceCompanyName: Text[30];
    begin
        if not MasterDataManagement.IsEnabled() then
            exit;

        if IntegrationTableMapping.Type <> IntegrationTableMapping.Type::"Master Data Management" then
            exit;

        MasterDataManagementSetup.Get();
        MasterDataManagement.OnGetIntegrationRecordRef(IntegrationTableMapping, SourceRecordRef, IsHandled);
        if not IsHandled then begin
            MasterDataManagement.OnSetSourceCompanyName(SourceCompanyName, IntegrationTableMapping."Table ID");
            if SourceCompanyName = '' then
                SourceCompanyName := MasterDataManagementSetup."Company Name";
            SourceRecordRef.ChangeCompany(SourceCompanyName);
            SourceRecordRef.GetBySystemId(SourceRecordRef.Field(SourceRecordRef.SystemIdNo()).Value());
        end;
        BeforeRenameDestinationRecordRef.Open(DestinationRecordRef.Number());
        BeforeRenameDestinationRecordRef.GetBySystemId(DestinationRecordRef.Field(DestinationRecordRef.SystemIdNo()).Value());
        if not IsPrimaryKeyDifferent(SourceRecordRef, BeforeRenameDestinationRecordRef) then
            exit;

        RenameDestination(SourceRecordRef, DestinationRecordRef);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnBeforeTransferRecordFields', '', false, false)]
    local procedure OnBeforeTransferRecordFields(SourceRecordRef: RecordRef; var DestinationRecordRef: RecordRef)
    begin
        ApplyTransformations(SourceRecordRef, DestinationRecordRef);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnBeforeDetermineConfigTemplateCode', '', false, false)]
    local procedure OnBeforeDetermineConfigTemplateCode(IntegrationTableMapping: Record "Integration Table Mapping"; var TemplateCode: Code[10]; var Handled: Boolean)
    begin
        if Handled then
            exit;

        if IntegrationTableMapping.Type <> IntegrationTableMapping.Type::"Master Data Management" then
            exit;

        if IntegrationTableMapping."Table Config Template Code" <> '' then
            TemplateCode := IntegrationTableMapping."Table Config Template Code"
        else
            TemplateCode := IntegrationTableMapping."Int. Tbl. Config Template Code";

        Handled := true;
    end;

    local procedure ApplyTransformations(SourceRecordRef: RecordRef; var DestinationRecordRef: RecordRef)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        TransformationRule: Record "Transformation Rule";
        CRMSynchHelper: Codeunit "CRM Synch. Helper";
    begin
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        IntegrationTableMapping.SetRange("Integration Table ID", SourceRecordRef.Number());
        IntegrationTableMapping.SetRange("Table ID", DestinationRecordRef.Number());
        if not IntegrationTableMapping.FindFirst() then
            exit;

        IntegrationFieldMapping.SetFilter("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetFilter("Transformation Rule", '<>%1', ' ');

        if IntegrationFieldMapping.FindSet() then
            repeat
                if TransformationRule.Get(IntegrationFieldMapping."Transformation Rule") then
                    if IntegrationFieldMapping."Transformation Direction" = IntegrationFieldMapping."Transformation Direction"::FromIntegrationTable then
                        CrmsynchHelper.TransformValue(SourceRecordRef, DestinationRecordRef, TransformationRule, IntegrationFieldMapping."Integration Table Field No.", IntegrationFieldMapping."Field No.");
            until IntegrationFieldMapping.Next() <= 0;
    end;

    local procedure IsPrimaryKeyDifferent(var SourceRecordRef: RecordRef; var DestinationRecordRef: RecordRef): Boolean
    var
        SourcePrimaryKeyRef: KeyRef;
        DestinationPrimaryKeyRef: KeyRef;
        FieldIndex: Integer;
        IsKeyDifferent: Boolean;
    begin
        if SourceRecordRef.Number <> DestinationRecordRef.Number then
            exit(true);

        SourcePrimaryKeyRef := SourceRecordRef.KeyIndex(1);
        DestinationPrimaryKeyRef := DestinationRecordRef.KeyIndex(1);
        for FieldIndex := 1 to SourcePrimaryKeyRef.FieldCount() do
            IsKeyDifferent := IsKeyDifferent or (SourcePrimaryKeyRef.FieldIndex(FieldIndex).Value() <> DestinationPrimaryKeyRef.FieldIndex(FieldIndex).Value());

        exit(IsKeyDifferent);
    end;

    local procedure RenameDestination(var SourceRecordRef: RecordRef; var DestinationRecordRef: RecordRef)
    var
        IntegrationFieldMapping: Record "Integration Field Mapping";
        IntegrationTableMapping: Record "Integration Table Mapping";
        BackupDestinatioRecordRef: RecordRef;
        RenamedDestinatioRecordRef: RecordRef;
        SourcePrimaryKeyRef: KeyRef;
    begin
        if SourceRecordRef.Number <> DestinationRecordRef.Number then
            exit;

        BackupDestinatioRecordRef.Open(DestinationRecordRef.Number());
        BackupDestinatioRecordRef.Copy(DestinationRecordRef);
        RenamedDestinatioRecordRef.Open(DestinationRecordRef.Number());
        RenamedDestinatioRecordRef.GetBySystemId(DestinationRecordRef.Field(DestinationRecordRef.SystemIdNo()).Value());
        SourcePrimaryKeyRef := SourceRecordRef.KeyIndex(1);
        case SourcePrimaryKeyRef.FieldCount() of
            1:
                RenamedDestinatioRecordRef.Rename(SourcePrimaryKeyRef.FieldIndex(1).Value());
            2:
                RenamedDestinatioRecordRef.Rename(SourcePrimaryKeyRef.FieldIndex(1).Value(), SourcePrimaryKeyRef.FieldIndex(2).Value());
            3:
                RenamedDestinatioRecordRef.Rename(SourcePrimaryKeyRef.FieldIndex(1).Value(), SourcePrimaryKeyRef.FieldIndex(2).Value(), SourcePrimaryKeyRef.FieldIndex(3).Value());
            4:
                RenamedDestinatioRecordRef.Rename(SourcePrimaryKeyRef.FieldIndex(1).Value(), SourcePrimaryKeyRef.FieldIndex(2).Value(), SourcePrimaryKeyRef.FieldIndex(3).Value(), SourcePrimaryKeyRef.FieldIndex(4).Value());
            5:
                RenamedDestinatioRecordRef.Rename(SourcePrimaryKeyRef.FieldIndex(1).Value(), SourcePrimaryKeyRef.FieldIndex(2).Value(), SourcePrimaryKeyRef.FieldIndex(3).Value(), SourcePrimaryKeyRef.FieldIndex(4).Value(), SourcePrimaryKeyRef.FieldIndex(5).Value());
            else
                Error(UnsupportedKeyLengthErr, SourceRecordRef.Caption(), Format(SourcePrimaryKeyRef.FieldCount()));
        end;
        DestinationRecordRef.GetBySystemId(DestinationRecordRef.Field(DestinationRecordRef.SystemIdNo()).Value());
        IntegrationTableMapping.SetRange(Status, IntegrationTableMapping.Status::Enabled);
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        IntegrationTableMapping.SetRange("Table ID", DestinationRecordRef.Number());
        IntegrationTableMapping.SetRange("Integration Table ID", SourceRecordRef.Number());
        IntegrationTableMapping.FindFirst();
        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange(Status, IntegrationFieldMapping.Status::Enabled);
        if IntegrationFieldMapping.FindSet() then
            repeat
                DestinationRecordRef.Field(IntegrationFieldMapping."Field No.").Value(BackupDestinatioRecordRef.Field(IntegrationFieldMapping."Field No.").Value());
            until IntegrationFieldMapping.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnWasModifiedAfterLastSynch', '', false, false)]
    local procedure OnWasModifiedAfterLastSynch(IntegrationTableConnectionType: TableConnectionType; IntegrationTableMapping: Record "Integration Table Mapping"; var SourceRecordRef: RecordRef; var SourceWasChanged: Boolean; var IsHandled: Boolean)
    begin
        HandleOnWasModifiedAfterLastSynch(IntegrationTableConnectionType, IntegrationTableMapping, SourceRecordRef, SourceWasChanged, IsHandled);
    end;

    internal procedure HandleOnWasModifiedAfterLastSynch(IntegrationTableConnectionType: TableConnectionType; IntegrationTableMapping: Record "Integration Table Mapping"; var SourceRecordRef: RecordRef; var SourceWasChanged: Boolean; var IsHandled: Boolean)
    var
        MasterDataManagement: Codeunit "Master Data Management";
        IntegrationRecordManagement: Codeunit "Integration Record Management";
        LastModifiedOn: DateTime;
    begin
        if IntegrationTableConnectionType <> IntegrationTableConnectionType::ExternalSQL then
            exit;

        if not MasterDataManagement.IsEnabled() then
            exit;

        LastModifiedOn := GetRowLastModifiedOn(IntegrationTableMapping, SourceRecordRef);
        if IntegrationTableMapping."Integration Table ID" = SourceRecordRef.Number() then
            SourceWasChanged := IntegrationRecordManagement.IsModifiedAfterIntegrationTableRecordLastSynch(IntegrationTableConnectionType, SourceRecordRef.Field(IntegrationTableMapping."Integration Table UID Fld. No.").Value(), IntegrationTableMapping."Table ID", LastModifiedOn)
        else
            SourceWasChanged := IntegrationRecordManagement.IsModifiedAfterRecordLastSynch(IntegrationTableConnectionType, SourceRecordRef, LastModifiedOn);

        IsHandled := true;
    end;

    internal procedure GetRowLastModifiedOn(IntegrationTableMapping: Record "Integration Table Mapping"; var FromRecordRef: RecordRef): DateTime
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        MasterDataManagement: Codeunit "Master Data Management";
        IntegrationRecordRef: RecordRef;
        ModifiedFieldRef: FieldRef;
        IsHandled: Boolean;
        IntRecSystemId: Guid;
        SourceCompanyName: Text[30];
    begin
        MasterDataManagementSetup.Get();
        IntegrationRecordRef.Open(FromRecordRef.Number, false);
        IntRecSystemId := FromRecordRef.Field(FromRecordRef.SystemIdNo).Value();
        MasterDataManagement.OnGetIntegrationRecordRefBySystemId(IntegrationTableMapping, IntegrationRecordRef, IntRecSystemId, IsHandled);
        if not IsHandled then begin
            MasterDataManagement.OnSetSourceCompanyName(SourceCompanyName, IntegrationTableMapping."Table ID");
            if SourceCompanyName = '' then
                SourceCompanyName := MasterDataManagementSetup."Company Name";
            IntegrationRecordRef.ChangeCompany(SourceCompanyName);
            IntegrationRecordRef.GetBySystemId(IntRecSystemId);
        end;
        if FromRecordRef.Number() = IntegrationTableMapping."Integration Table ID" then begin
            ModifiedFieldRef := IntegrationRecordRef.Field(IntegrationTableMapping."Int. Tbl. Modified On Fld. No.");
            exit(ModifiedFieldRef.Value());
        end;

        ModifiedFieldRef := IntegrationRecordRef.Field(IntegrationRecordRef.SystemModifiedAtNo());
        exit(ModifiedFieldRef.Value());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustCont-Update", 'OnInsertNewContactOnBeforeAssignNo', '', false, false)]
    local procedure OnInsertNewContactFromCustomerOnBeforeAssignNo(var Contact: Record Contact; var IsHandled: Boolean; Customer: Record Customer)
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        ContactBusinessRelation: Record "Contact Business Relation";
        Company: Record Company;
        LocalContact: Record Contact;
        IntegrationTableMapping: Record "Integration Table Mapping";
        MasterDataManagement: Codeunit "Master Data Management";
        SourceCompanyName: Text[30];
    begin
        if not MasterDataManagement.IsEnabled() then
            exit;

        if not MasterDataManagementSetup.Get() then
            exit;

        MasterDataManagement.OnSetSourceCompanyName(SourceCompanyName, Database::Contact);
        if SourceCompanyName = '' then
            SourceCompanyName := MasterDataManagementSetup."Company Name";

        if not Company.Get(SourceCompanyName) then
            exit;

        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        IntegrationTableMapping.SetRange("Table ID", Database::Customer);
        IntegrationTableMapping.SetRange("Integration Table ID", Database::Customer);
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        IntegrationTableMapping.SetRange(Status, IntegrationTableMapping.Status::Enabled);
        if IntegrationTableMapping.IsEmpty() then
            exit;

        if not ContactBusinessRelation.ChangeCompany(SourceCompanyName) then
            exit;

        ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
        ContactBusinessRelation.SetRange("No.", Customer."No.");
        if ContactBusinessRelation.FindFirst() then
            if not LocalContact.Get(ContactBusinessRelation."Contact No.") then begin
                Contact."No." := ContactBusinessRelation."Contact No.";
                Session.LogMessage('0000JT4', StrSubstNo(SetContactNoFromSourceCompanyTxt, Customer.TableCaption(), Customer.SystemId, MasterDataManagementSetup."Company Name"), Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, 'Category', MasterDataManagement.GetTelemetryCategory());
                IsHandled := true;
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VendCont-Update", 'OnInsertNewContactOnBeforeAssignNo', '', false, false)]
    local procedure OnInsertNewContactFromVendorOnBeforeAssignNo(var Contact: Record Contact; var IsHandled: Boolean; Vendor: Record Vendor; MarketingSetup: Record "Marketing Setup"; LocalCall: Boolean)
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        ContactBusinessRelation: Record "Contact Business Relation";
        Company: Record COmpany;
        LocalContact: Record Contact;
        IntegrationTableMapping: Record "Integration Table Mapping";
        MasterDataManagement: Codeunit "Master Data Management";
        SourceCompanyName: Text[30];
    begin
        if not MasterDataManagement.IsEnabled() then
            exit;

        if not MasterDataManagementSetup.Get() then
            exit;

        MasterDataManagement.OnSetSourceCompanyName(SourceCompanyName, Database::Contact);
        if SourceCompanyName = '' then
            SourceCompanyName := MasterDataManagementSetup."Company Name";

        if not Company.Get(SourceCompanyName) then
            exit;

        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        IntegrationTableMapping.SetRange("Table ID", Database::Vendor);
        IntegrationTableMapping.SetRange("Integration Table ID", Database::Vendor);
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        IntegrationTableMapping.SetRange(Status, IntegrationTableMapping.Status::Enabled);
        if IntegrationTableMapping.IsEmpty() then
            exit;

        if not ContactBusinessRelation.ChangeCompany(SourceCompanyName) then
            exit;

        ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Vendor);
        ContactBusinessRelation.SetRange("No.", Vendor."No.");
        if ContactBusinessRelation.FindFirst() then
            if not LocalContact.Get(ContactBusinessRelation."Contact No.") then begin
                Contact."No." := ContactBusinessRelation."Contact No.";
                Session.LogMessage('0000JT5', StrSubstNo(SetContactNoFromSourceCompanyTxt, Vendor.TableCaption(), Vendor.SystemId, MasterDataManagementSetup."Company Name"), Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, 'Category', MasterDataManagement.GetTelemetryCategory());
                IsHandled := true;
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"BankCont-Update", 'OnInitContactFromBankAccountOnBeforeAssignNo', '', false, false)]
    local procedure OnInitContactFromBankAccountOnBeforeAssignNo(var Contact: Record Contact; BankAccount: Record "Bank Account"; MarketingSetup: Record "Marketing Setup"; var IsHandled: Boolean)
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        ContactBusinessRelation: Record "Contact Business Relation";
        Company: Record COmpany;
        LocalContact: Record Contact;
        IntegrationTableMapping: Record "Integration Table Mapping";
        MasterDataManagement: Codeunit "Master Data Management";
        SourceCompanyName: Text[30];
    begin
        if not MasterDataManagement.IsEnabled() then
            exit;

        if not MasterDataManagementSetup.Get() then
            exit;

        MasterDataManagement.OnSetSourceCompanyName(SourceCompanyName, Database::Contact);
        if SourceCompanyName = '' then
            SourceCompanyName := MasterDataManagementSetup."Company Name";

        if not Company.Get(SourceCompanyName) then
            exit;

        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        IntegrationTableMapping.SetRange("Table ID", Database::"Bank Account");
        IntegrationTableMapping.SetRange("Integration Table ID", Database::"Bank Account");
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        IntegrationTableMapping.SetRange(Status, IntegrationTableMapping.Status::Enabled);
        if IntegrationTableMapping.IsEmpty() then
            exit;

        if not ContactBusinessRelation.ChangeCompany(SourceCompanyName) then
            exit;

        ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::"Bank Account");
        ContactBusinessRelation.SetRange("No.", BankAccount."No.");
        if ContactBusinessRelation.FindFirst() then
            if not LocalContact.Get(ContactBusinessRelation."Contact No.") then begin
                Contact."No." := ContactBusinessRelation."Contact No.";
                Session.LogMessage('0000JT6', StrSubstNo(SetContactNoFromSourceCompanyTxt, BankAccount.TableCaption(), BankAccount.SystemId, MasterDataManagementSetup."Company Name"), Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, 'Category', MasterDataManagement.GetTelemetryCategory());
                IsHandled := true;
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnBeforeInsertRecord', '', false, false)]
    local procedure HandleOnBeforeInsertRecord(SourceRecordRef: RecordRef; var DestinationRecordRef: RecordRef)
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        IntegrationTableMapping: Record "Integration Table Mapping";
        CustomerTemplMgt: Codeunit "Customer Templ. Mgt.";
        VendorTemplMgt: Codeunit "Vendor Templ. Mgt.";
        ItemTemplMgt: Codeunit "Item Templ. Mgt.";
        MasterDataManagement: Codeunit "Master Data Management";
        ConfigTemplateCode: Code[10];
        SourceDestCode: Text;
    begin
        if not MasterDataManagement.IsEnabled() then
            exit;

        SourceDestCode := GetSourceDestCode(SourceRecordRef, DestinationRecordRef);

        if SourceRecordRef.Number in [Database::Customer, Database::Vendor, Database::Item] then begin
            IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
            IntegrationTableMapping.SetRange("Table ID", DestinationRecordRef.Number);
            IntegrationTableMapping.SetRange("Integration Table ID", SourceRecordRef.Number);
            if IntegrationTableMapping.FindFirst() then
                ConfigTemplateCode := IntegrationTableMapping."Table Config Template Code";
        end;

        case SourceDestCode of
            'Customer-Customer':
                if ConfigTemplateCode <> '' then
                    if ConfigTemplateHeader.Get(ConfigTemplateCode) then
                        CustomerTemplMgt.FillCustomerKeyFromInitSeries(DestinationRecordRef, ConfigTemplateHeader);
            'Vendor-Vendor':
                if ConfigTemplateCode <> '' then
                    if ConfigTemplateHeader.Get(ConfigTemplateCode) then
                        VendorTemplMgt.FillVendorKeyFromInitSeries(DestinationRecordRef, ConfigTemplateHeader);
            'Item-Item':
                begin
                    if ConfigTemplateCode <> '' then
                        if ConfigTemplateHeader.Get(ConfigTemplateCode) then
                            ItemTemplMgt.FillItemKeyFromInitSeries(DestinationRecordRef, ConfigTemplateHeader);

                    UpdateItemMediaSet(SourceRecordRef, DestinationRecordRef);
                end;
        end;
    end;

    local procedure UpdateItemMediaSet(var SourceRecordRef: RecordRef; var DestinationRecordRef: RecordRef)
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        SourceTenantMedia: Record "Tenant Media";
        DestinationTenantMedia: Record "Tenant Media";
        SourceItem: Record Item;
        DestinationItem: Record Item;
        MasterDataManagement: Codeunit "Master Data Management";
        MediaInStream: InStream;
        MediaOutStream: OutStream;
        DestinationItemMediaIds: List of [Guid];
        MediaId: Guid;
        i: Integer;
        MediaItemInserted: Boolean;
        SourceCompanyName: Text[30];
    begin
        if not MasterDataManagementSetup.Get() then
            exit;

        if not MasterDataManagementSetup."Is Enabled" then
            exit;

        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        IntegrationTableMapping.SetRange(Status, IntegrationTableMapping.Status::Enabled);
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        IntegrationTableMapping.SetRange("Table ID", Database::Item);
        IntegrationTableMapping.SetRange("Integration Table ID", Database::Item);
        if not IntegrationTableMapping.FindFirst() then
            exit;

        // exit if Picture field mapping is not enabled
        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", DestinationItem.FieldNo(Picture));
        IntegrationFieldMapping.SetRange(Status, IntegrationFieldMapping.Status::Enabled);
        if IntegrationFieldMapping.IsEmpty() then
            exit;

        // if source item picture has media that are not in destination item picture media, add their ids
        SourceRecordRef.SetTable(SourceItem);
        DestinationRecordRef.SetTable(DestinationItem);
        MasterDataManagementSetup.Get();
        MasterDataManagement.OnSetSourceCompanyName(SourceCompanyName, Database::Item);
        if SourceCompanyName = '' then
            SourceCompanyName := MasterDataManagementSetup."Company Name";
        SourceItem.ChangeCompany(SourceCompanyName);

        // remove all the media from Destination item
        for i := 1 to DestinationItem.Picture.Count() do
            DestinationItemMediaIds.Add(DestinationItem.Picture.Item(i));
        foreach MediaId in DestinationItemMediaIds do
            DestinationItem.Picture.Remove(MediaId);

        // reinsert all media from source item to the destination item
        for i := 1 to SourceItem.Picture.Count() do
            if SourceTenantMedia.Get(SourceItem.Picture.Item(i)) then begin
                SourceTenantMedia.CalcFields(Content);
                SourceTenantMedia.Content.CreateInStream(MediaInStream);
                DestinationTenantMedia.TransferFields(SourceTenantMedia, true);
                DestinationTenantMedia.ID := CreateGuid();
                DestinationTenantMedia."Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(DestinationTenantMedia."Company Name"));
                DestinationTenantMedia.Content.CreateOutStream(MediaOutStream);
                CopyStream(MediaOutStream, MediaInStream);
                DestinationTenantMedia.Insert();
                DestinationItem.Picture.Insert(DestinationTenantMedia.ID);
                MediaItemInserted := true;
            end;
        if MediaItemInserted then
            DestinationRecordRef.GetTable(DestinationItem);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnAfterUnchangedRecordHandled', '', false, false)]
    local procedure HandleOnAfterUnchangedRecordHandled(IntegrationTableMapping: Record "Integration Table Mapping"; SourceRecordRef: RecordRef; DestinationRecordRef: RecordRef)
    var
        MasterDataManagement: Codeunit "Master Data Management";
        SourceDestCode: Text;
    begin
        if not MasterDataManagement.IsEnabled() then
            exit;

        if IntegrationTableMapping.Type <> IntegrationTableMapping.Type::"Master Data Management" then
            exit;

        SourceDestCode := GetSourceDestCode(SourceRecordRef, DestinationRecordRef);
        case SourceDestCode of
            'Item-Item':
                begin
                    UpdateItemMediaSet(SourceRecordRef, DestinationRecordRef);
                    DestinationRecordRef.Modify();
                end;
        end;
    end;

    local procedure SynchRecordIfMappingExists(TableNo: Integer; IntegrationTableNo: Integer; PrimaryKey: Variant; var OutOfMapFilter: Boolean): Boolean
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationSynchJob: Record "Integration Synch. Job";
        IntegrationMasterDataSynch: Codeunit "Integration Master Data Synch.";
        NewJobEntryId: Guid;
    begin
        IntegrationTableMapping.SetRange("Table ID", TableNo);
        IntegrationTableMapping.SetRange("Integration Table ID", IntegrationTableNo);
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        IntegrationTableMapping.SetRange(Status, IntegrationTableMapping.Status::Enabled);
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        if IntegrationTableMapping.FindFirst() then begin
            NewJobEntryId := IntegrationMasterDataSynch.SynchRecord(IntegrationTableMapping, PrimaryKey, true, false);
            OutOfMapFilter := IntegrationMasterDataSynch.GetOutOfMapFilter();
        end;

        if IsNullGuid(NewJobEntryId) then
            exit(false);
        if IntegrationSynchJob.Get(NewJobEntryId) then
            exit(
              (IntegrationSynchJob.Inserted > 0) or
              (IntegrationSynchJob.Modified > 0) or
              (IntegrationSynchJob.Unchanged > 0));
    end;

    local procedure GetSourceDestCode(SourceRecordRef: RecordRef; DestinationRecordRef: RecordRef): Text
    begin
        if (SourceRecordRef.Number() <> 0) and (DestinationRecordRef.Number() <> 0) then
            exit(SourceRecordRef.Name() + '-' + DestinationRecordRef.Name());
        exit('');
    end;

    local procedure FixPrimaryContactNo(var SourceRecordRef: RecordRef; var DestinationRecordRef: RecordRef): Boolean
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Contact: Record Contact;
        IntegrationContact: Record Contact;
        IntegrationCustomer: Record Customer;
        IntegrationVendor: Record Vendor;
        MasterDataManagementSetup: Record "Master Data Management Setup";
        IntegrationTableMapping: Record "Integration Table Mapping";
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        IntegrationContactBusinessRelation: Record "Contact Business Relation";
        IntegrationRecSynchInvoke: Codeunit "Integration Rec. Synch. Invoke";
        MasterDataManagement: Codeunit "Master Data Management";
        RecRef: RecordRef;
        RecordModifiedAfterLastSync: Boolean;
        LinkType: Enum "Contact Business Relation Link To Table";
    begin
        if not MasterDataManagement.IsEnabled() then
            exit(false);

        MasterDataManagementSetup.Get();
        DestinationRecordRef.SetTable(Contact);
        IntegrationContact.ChangeCompany(MasterDataManagementSetup."Company Name");
        SourceRecordRef.SetTable(IntegrationContact);
        IntegrationContactBusinessRelation.ChangeCompany(MasterDataManagementSetup."Company Name");

        case IntegrationContact."Contact Business Relation" of
            IntegrationContact."Contact Business Relation"::Customer:
                begin
                    IntegrationCustomer.ChangeCompany(MasterDataManagementSetup."Company Name");
                    if IntegrationContactBusinessRelation.FindByContact(LinkType::Customer, IntegrationContact."No.") then
                        if IntegrationCustomer.Get(IntegrationContactBusinessRelation."No.") then
                            if FindCustomerByIntegrationSystemId(IntegrationCustomer.SystemId, Customer) then
                                if Customer."Primary Contact No." = '' then
                                    if IntegrationTableMapping.FindMapping(Database::Customer, Database::Customer) then
                                        if IntegrationTableMapping.Direction in [IntegrationTableMapping.Direction::Bidirectional, IntegrationTableMapping.Direction::FromIntegrationTable] then begin
                                            RecRef.GetTable(Customer);
                                            RecordModifiedAfterLastSync := IntegrationRecSynchInvoke.WasModifiedAfterLastSynch(IntegrationTableMapping, RecRef);
                                            Customer.Validate("Primary Contact No.", Contact."No.");
                                            Customer.Modify();
                                            if not RecordModifiedAfterLastSync then begin
                                                MasterDataMgtCoupling.SetRange("Local System ID", Customer.SystemId);
                                                if MasterDataMgtCoupling.FindFirst() then begin
                                                    MasterDataMgtCoupling."Last Synch. Modified On" := Customer.SystemModifiedAt;
                                                    MasterDataMgtCoupling.Modify();
                                                end;
                                            end;
                                            exit(true);
                                        end;
                end;
            IntegrationContact."Contact Business Relation"::Vendor:
                begin
                    IntegrationVendor.ChangeCompany(MasterDataManagementSetup."Company Name");
                    if IntegrationContactBusinessRelation.FindByContact(LinkType::Vendor, IntegrationContact."No.") then
                        if IntegrationVendor.Get(IntegrationContactBusinessRelation."No.") then
                            if FindVendorByIntegrationSystemId(IntegrationVendor.SystemId, Vendor) then
                                if Vendor."Primary Contact No." = '' then
                                    if IntegrationTableMapping.FindMapping(Database::Vendor, Database::Vendor) then
                                        if IntegrationTableMapping.Direction in [IntegrationTableMapping.Direction::Bidirectional, IntegrationTableMapping.Direction::FromIntegrationTable] then begin
                                            RecRef.GetTable(Vendor);
                                            RecordModifiedAfterLastSync := IntegrationRecSynchInvoke.WasModifiedAfterLastSynch(IntegrationTableMapping, RecRef);
                                            Vendor.Validate("Primary Contact No.", Contact."No.");
                                            Vendor.Modify();
                                            if not RecordModifiedAfterLastSync then begin
                                                MasterDataMgtCoupling.SetRange("Local System ID", Vendor.SystemId);
                                                if MasterDataMgtCoupling.FindFirst() then begin
                                                    MasterDataMgtCoupling."Last Synch. Modified On" := Vendor.SystemModifiedAt;
                                                    MasterDataMgtCoupling.Modify();
                                                end;
                                            end;
                                            exit(true);
                                        end;
                end;
            else
                exit(false)
        end;
    end;

    local procedure FindCustomerByIntegrationSystemId(IntegrationSystemId: Guid; var Customer: Record Customer): Boolean
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        CustomerRecordID: RecordID;
    begin
        if MasterDataMgtCoupling.FindRecordIDFromID(IntegrationSystemId, DATABASE::Customer, CustomerRecordID) then
            exit(Customer.Get(CustomerRecordID));

        exit(false);
    end;

    local procedure FindVendorByIntegrationSystemId(IntegrationSystemId: Guid; var Vendor: Record Vendor): Boolean
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        VendorRecordID: RecordID;
    begin
        if MasterDataMgtCoupling.FindRecordIDFromID(IntegrationSystemId, DATABASE::Vendor, VendorRecordID) then
            exit(Vendor.Get(VendorRecordID));

        exit(false);
    end;

    local procedure UpdateChildContactsParentCompany(var SourceRecordRef: RecordRef)
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        MasterDataManagementSetup: Record "Master Data Management Setup";
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationCustomer: Record Customer;
        IntegrationVendor: Record Vendor;
        IntegrationContact: Record Contact;
        Contact: Record Contact;
        IntegrationContactBusinessRelation: Record "Contact Business Relation";
        MasterDataManagement: Codeunit "Master Data Management";
        ContactRecordRef: RecordRef;
        IntegrationContactRecordRef: RecordRef;
        LinkType: Enum "Contact Business Relation Link To Table";
        IsHandled: Boolean;
    begin
        MasterDataManagement.OnUpdateChildContactsParentCompany(SourceRecordRef, IsHandled);
        if IsHandled then
            exit;

        if not MasterDataManagement.IsEnabled() then
            exit;

        Contact.SetRange("Company No.", '');
        if Contact.IsEmpty() then
            exit; // all contacts have parent company set

        MasterDataManagementSetup.Get();
        IntegrationCustomer.ChangeCompany(MasterDataManagementSetup."Company Name");
        IntegrationVendor.ChangeCompany(MasterDataManagementSetup."Company Name");
        IntegrationContact.ChangeCompany(MasterDataManagementSetup."Company Name");
        IntegrationContactBusinessRelation.ChangeCompany(MasterDataManagementSetup."Company Name");
        case SourceRecordRef.Number of
            Database::Customer:
                begin
                    SourceRecordRef.SetTable(IntegrationCustomer);
                    if not IntegrationTableMapping.FindMapping(Database::Customer, Database::Customer) then
                        exit;
                    if not IntegrationContactBusinessRelation.FindContactsByRelation(IntegrationContact, LinkType::Customer, IntegrationCustomer."No.") then
                        exit;
                end;
            Database::Vendor:
                begin
                    SourceRecordRef.SetTable(IntegrationVendor);
                    if not IntegrationTableMapping.FindMapping(Database::Vendor, Database::Vendor) then
                        exit;
                    if not IntegrationContactBusinessRelation.FindContactsByRelation(IntegrationContact, LinkType::Vendor, IntegrationVendor."No.") then
                        exit;
                end;
            else
                exit;
        end;

        if not (IntegrationTableMapping.Direction in [IntegrationTableMapping.Direction::Bidirectional, IntegrationTableMapping.Direction::FromIntegrationTable]) then
            exit;

        // find and process already synced child contacts
        if IntegrationContact.FindSet() then
            repeat
                if MasterDataMgtCoupling.FindByIntegrationSystemID(IntegrationContact.SystemId) then begin
                    IntegrationContactRecordRef.ChangeCompany(MasterDataManagementSetup."Company Name");
                    IntegrationContactRecordRef.GetTable(IntegrationContact);
                    ContactRecordRef.Open(Database::Contact);
                    if ContactRecordRef.GetBySystemId(MasterDataMgtCoupling."Local System ID") then begin
                        FixPrimaryContactNo(IntegrationContactRecordRef, ContactRecordRef);
                        UpdateContactParentCompany(SourceRecordRef.Field(SourceRecordRef.SystemIdNo).Value(), ContactRecordRef);
                    end;
                    ContactRecordRef.Close();
                end;
            until IntegrationContact.Next() = 0;
    end;

    local procedure UpdateContactParentCompany(ParentId: Guid; var ContactRecordRef: RecordRef)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        Contact: Record Contact;
        IntegrationRecSynchInvoke: Codeunit "Integration Rec. Synch. Invoke";
        CRMSynchHelper: Codeunit "CRM Synch. Helper";
        RecordModifiedAfterLastSync: Boolean;
        OldCompanyNo: Code[20];
        NewCompanyNo: Code[20];
    begin
        if not IntegrationTableMapping.FindMapping(Database::Contact, Database::Contact) then
            exit;

        if not (IntegrationTableMapping.Direction in [IntegrationTableMapping.Direction::Bidirectional, IntegrationTableMapping.Direction::FromIntegrationTable]) then
            exit;

        RecordModifiedAfterLastSync := IntegrationRecSynchInvoke.WasModifiedAfterLastSynch(IntegrationTableMapping, ContactRecordRef);
        OldCompanyNo := ContactRecordRef.Field(Contact.FieldNo("Company No.")).Value();

        if not CRMSynchHelper.SetContactParentCompany(ParentId, ContactRecordRef) then
            exit;

        NewCompanyNo := ContactRecordRef.Field(Contact.FieldNo("Company No.")).Value();
        if NewCompanyNo = OldCompanyNo then
            exit;

        ContactRecordRef.Modify();
        if not RecordModifiedAfterLastSync then begin
            ContactRecordRef.SetTable(Contact);
            MasterDataMgtCoupling.SetRange("Local System ID", Contact.SystemId);
            if MasterDataMgtCoupling.FindFirst() then begin
                MasterDataMgtCoupling."Last Synch. Modified On" := Contact.SystemModifiedAt;
                MasterDataMgtCoupling.Modify();
            end;
        end;
    end;
}