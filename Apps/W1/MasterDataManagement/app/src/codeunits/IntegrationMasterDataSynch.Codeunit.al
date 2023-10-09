namespace Microsoft.Integration.MDM;

using System.Threading;
using Microsoft.Integration.SyncEngine;
using System.Utilities;
using Microsoft.CRM.Contact;


codeunit 7231 "Integration Master Data Synch."
{
    TableNo = "Integration Table Mapping";
    Permissions = tabledata "Master Data Mgt. Coupling" = ri,
                  tabledata "Master Data Management Setup" = r;

    trigger OnRun()
    var
        OriginalJobQueueEntry: Record "Job Queue Entry";
        MasterDataManagement: Codeunit "Master Data Management";
        LatestModifiedOn: array[2] of DateTime;
        isHandled: Boolean;
        PrevStatus: Option;
        MappingName: Code[20];
    begin
        OnBeforeRun(Rec, IsHandled);
        if IsHandled then
            exit;

        Rec.SetOriginalJobQueueEntryOnHold(OriginalJobQueueEntry, PrevStatus);
        if Rec.Direction in [Rec.Direction::ToIntegrationTable, Rec.Direction::Bidirectional] then
            LatestModifiedOn[DateType::Local] := PerformScheduledSynchToIntegrationTable(Rec);
        if Rec.Direction in [Rec.Direction::FromIntegrationTable, Rec.Direction::Bidirectional] then
            LatestModifiedOn[DateType::Integration] := PerformScheduledSynchFromIntegrationTable(Rec);
        MappingName := Rec.Name;
        if not Rec.Find() then
            Session.LogMessage('0000J8M', StrSubstNo(UnableToFindMappingErr, MappingName), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MasterDataManagement.GetTelemetryCategory())
        else begin
            Rec.UpdateTableMappingModifiedOn(LatestModifiedOn);
            Rec.SetOriginalJobQueueEntryStatus(OriginalJobQueueEntry, PrevStatus);
        end;

        OnAfterRun(Rec);
    end;

    var
        MappedFieldDictionary: Dictionary of [Text, Boolean];
        SupportedSourceType: Option ,RecordID,GUID;
        DateType: Option ,Integration,Local;
        OutOfMapFilter: Boolean;
        RecordNotFoundErr: Label 'Cannot find %1 record %2.', Comment = '%1 = Source table caption, %2 = The lookup value when searching for the source record';
        SourceRecordIsNotInMappingErr: Label 'Cannot find the mapping %2 in table %1.', Comment = '%1 Integration Table Mapping caption, %2 Integration Table Mapping Name';
        CannotDetermineSourceOriginErr: Label 'Cannot determine the source origin: %1.', Comment = '%1 the value of the source id';
        CopyRecordRefFailedTxt: Label 'Copy record reference failed. Integration Record ID: %1', Locked = true, Comment = '%1 - Business Central record id';
        UnableToFindMappingErr: Label 'Unable to find Integration Table Mapping %1', Locked = true, Comment = '%1 - Mapping name';
        FieldKeyTxt: Label '%1-%2', Locked = true;

    internal procedure SplitLocalTableFilter(var IntegrationTableMapping: Record "Integration Table Mapping"; var TableFilterList: List of [Text]): Boolean
    var
        IntegrationRecordSynch: Codeunit "Integration Record Synch.";
        RecordRef: RecordRef;
    begin
        RecordRef.Open(IntegrationTableMapping."Table ID", true);
        exit(IntegrationRecordSynch.SplitTableFilter(IntegrationTableMapping."Table ID", RecordRef.SystemIdNo(), IntegrationTableMapping.GetTableFilter(), TableFilterList));
    end;

    internal procedure SplitIntegrationTableFilter(var IntegrationTableMapping: Record "Integration Table Mapping"; var TableFilterList: List of [Text]): Boolean
    var
        IntegrationRecordSynch: Codeunit "Integration Record Synch.";
    begin
        exit(IntegrationRecordSynch.SplitTableFilter(IntegrationTableMapping."Integration Table ID", IntegrationTableMapping."Integration Table UID Fld. No.", IntegrationTableMapping.GetIntegrationTableFilter(), TableFilterList));
    end;

    local procedure FindModifiedIntegrationRecords(var TempIntegrationRecordRef: RecordRef; IntegrationTableMapping: Record "Integration Table Mapping"; var FailedNotSkippedIdDictionary: Dictionary of [Guid, Boolean])
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        MasterDataManagement: Codeunit "Master Data Management";
        IntegrationRecordRef: RecordRef;
        IntegrationRecordID: Guid;
        TableFilter: Text;
        FilterList: List of [Text];
        IsHandled: Boolean;
    begin
        OnFindModifiedIntegrationRecords(TempIntegrationRecordRef, IntegrationTableMapping, FailedNotSkippedIdDictionary, IsHandled);
        if IsHandled then
            exit;

        MasterDataManagementSetup.Get();
        SplitIntegrationTableFilter(IntegrationTableMapping, FilterList);
        IntegrationRecordRef.Open(IntegrationTableMapping."Integration Table ID");
        IntegrationRecordRef.ChangeCompany(MasterDataManagementSetup."Company Name");
        foreach TableFilter in FilterList do begin
            IntegrationTableMapping.SetIntRecordRefFilter(IntegrationRecordRef, TableFilter);
            if IntegrationRecordRef.FindSet() then
                repeat
                    IntegrationRecordID := IntegrationRecordRef.Field(IntegrationTableMapping."Integration Table UID Fld. No.").Value();
                    if not FailedNotSkippedIdDictionary.ContainsKey(IntegrationRecordID) then
                        if not TryCopyRecordReference(IntegrationTableMapping, IntegrationRecordRef, TempIntegrationRecordRef, false) then
                            Session.LogMessage('0000J8Q', StrSubstNo(CopyRecordRefFailedTxt, IntegrationRecordID), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MasterDataManagement.GetTelemetryCategory());
                until IntegrationRecordRef.Next() = 0;
        end;
        IntegrationRecordRef.Close();
    end;

    [TryFunction]
    local procedure TryCopyRecordReference(var IntegrationTableMapping: Record "Integration Table Mapping"; FromRec: RecordRef; var ToRec: RecordRef; ValidateOnInsert: Boolean)
    begin
        CopyRecordReference(IntegrationTableMapping, FromRec, ToRec, ValidateOnInsert);
    end;

    local procedure CopyRecordReference(var IntegrationTableMapping: Record "Integration Table Mapping"; FromRec: RecordRef; var ToRec: RecordRef; ValidateOnInsert: Boolean)
    var
        TempBlob: Codeunit "Temp Blob";
        FromField: FieldRef;
        ToField: FieldRef;
        Counter: Integer;
    begin
        if FromRec.Number <> ToRec.Number then
            exit;

        ToRec.Init();
        for Counter := 1 to FromRec.FieldCount do begin
            FromField := FromRec.FieldIndex(Counter);
            if FromField.Type <> FieldType::TableFilter then
                if FromField.Type <> FieldType::Blob then begin
                    ToField := ToRec.Field(FromField.Number);
                    ToField.Value := FromField.Value;
                end else
                    if IsFieldMapped(IntegrationTableMapping, FromRec.Number(), FromField.Number()) then begin
                        ToField := ToRec.Field(FromField.Number);
                        TempBlob.FromFieldRef(FromField);
                        TempBlob.ToFieldRef(ToField);
                    end;
        end;
        FromField := FromRec.Field(FromRec.SystemIdNo);
        ToField := ToRec.Field(FromRec.SystemIdNo);
        ToField.Value := FromField.Value;
        ToRec.Insert(ValidateOnInsert);
    end;

    local procedure IsFieldMapped(var IntegrationTableMapping: Record "Integration Table Mapping"; TableNo: Integer; FieldNo: Integer): Boolean
    var
        IntegrationFieldMapping: Record "Integration Field Mapping";
        FieldKey: Text;
        IsMapped: Boolean;
    begin
        FieldKey := StrSubstNo(FieldKeyTxt, TableNo, FieldNo);
        if not MappedFieldDictionary.ContainsKey(FieldKey) then begin
            IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
            if TableNo = IntegrationTableMapping."Integration Table ID" then
                IntegrationFieldMapping.SetRange("Integration Table Field No.", FieldNo)
            else
                IntegrationFieldMapping.SetRange("Field No.", FieldNo);
            IsMapped := not IntegrationFieldMapping.IsEmpty();
            MappedFieldDictionary.Add(FieldKey, IsMapped);
        end;
        exit(MappedFieldDictionary.Get(FieldKey));
    end;

    local procedure FindFailedNotSkippedIntegrationRecords(var TempIntegrationRecordRef: RecordRef; IntegrationTableMapping: Record "Integration Table Mapping"; var TempMasterDataMgtCoupling: Record "Master Data Mgt. Coupling" temporary; var IntegrationSystemIDDictionary: Dictionary of [Guid, Boolean]): Boolean
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        IntegrationRecordSynch: Codeunit "Integration Record Synch.";
        IntegrationRecordRef: RecordRef;
        IntegrationableView: Text;
        IntegrationSystemIDFilter: Text;
        Found: Boolean;
        IsHandled: Boolean;
        IntegrationSystemIDFilterList: List of [Text];
    begin
        OnFindFailedNotSkippedIntegrationRecords(TempIntegrationRecordRef, IntegrationTableMapping, TempMasterDataMgtCoupling, IntegrationSystemIDDictionary, Found, IsHandled);
        if (IsHandled) then
            exit(Found);

        MasterDataManagementSetup.Get();
        IntegrationableView := IntegrationTableMapping.GetIntegrationTableFilter();
        IntegrationRecordRef.Open(IntegrationTableMapping."Integration Table ID");
        IntegrationRecordRef.ChangeCompany(MasterDataManagementSetup."Company Name");
        IntegrationRecordRef.SetView(IntegrationableView);
        IntegrationSystemIDFilter := IntegrationRecordRef.Field(IntegrationTableMapping."Integration Table UID Fld. No.").GetFilter();
        IntegrationRecordRef.Close();
        if IntegrationSystemIDFilter <> '' then
            exit(false); // Ignore failed not synched records if going to synch records selected by IntegrationSystemID

        TempMasterDataMgtCoupling.SetRange(Skipped, false);
        TempMasterDataMgtCoupling.SetRange("Table ID", IntegrationTableMapping."Table ID");
        TempMasterDataMgtCoupling.SetRange("Last Synch. Result", TempMasterDataMgtCoupling."Last Synch. Result"::Failure);
        if TempMasterDataMgtCoupling.FindSet() then begin
            repeat
                if not IntegrationSystemIDDictionary.ContainsKey(TempMasterDataMgtCoupling."Integration System ID") then
                    IntegrationSystemIDDictionary.Add(TempMasterDataMgtCoupling."Integration System ID", true);
            until TempMasterDataMgtCoupling.Next() = 0;
            IntegrationRecordSynch.GetIdFilterList(IntegrationSystemIDDictionary, IntegrationSystemIDFilterList);
            Found := CacheFilteredIntegrationRecords(IntegrationSystemIDFilterList, IntegrationTableMapping, TempIntegrationRecordRef);
        end;
        TempMasterDataMgtCoupling.SetRange(Skipped);
        TempMasterDataMgtCoupling.SetRange("Table ID");
        TempMasterDataMgtCoupling.SetRange("Last Synch. Result");
        exit(Found);
    end;

    local procedure CacheFilteredIntegrationRecords(var IntegrationSystemIDFilterList: List of [Text]; IntegrationTableMapping: Record "Integration Table Mapping"; var TempIntegrationRecordRef: RecordRef): Boolean
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        IntegrationRecordRef: RecordRef;
        IntegrationSystemIDFilter: Text;
        Cached: Boolean;
        IsHandled: Boolean;
    begin
        OnCacheFilteredIntegrationRecords(IntegrationSystemIDFilterList, IntegrationTableMapping, TempIntegrationRecordRef, Cached, IsHandled);
        if (IsHandled) then
            exit(Cached);

        MasterDataManagementSetup.Get();
        foreach IntegrationSystemIDFilter in IntegrationSystemIDFilterList do
            if IntegrationSystemIDFilter <> '' then begin
                IntegrationRecordRef.Open(IntegrationTableMapping."Integration Table ID");
                IntegrationRecordRef.ChangeCompany(MasterDataManagementSetup."Company Name");
                IntegrationRecordRef.Field(IntegrationTableMapping."Integration Table UID Fld. No.").SetFilter(IntegrationSystemIDFilter);
                if IntegrationRecordRef.FindSet() then
                    repeat
                        CopyRecordReference(IntegrationTableMapping, IntegrationRecordRef, TempIntegrationRecordRef, false);
                        Cached := true;
                    until IntegrationRecordRef.Next() = 0;
                IntegrationRecordRef.Close();
            end;
        exit(Cached);
    end;

    local procedure CacheFilteredIntegrationTable(var TempIntegrationRecordRef: RecordRef; IntegrationTableMapping: Record "Integration Table Mapping"; var TempMasterDataMgtCoupling: Record "Master Data Mgt. Coupling" temporary)
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        FailedNotSkippedIdDictionary: Dictionary of [Guid, Boolean];
    begin
        MasterDataManagementSetup.Get();
        TempIntegrationRecordRef.Open(IntegrationTableMapping."Integration Table ID", true, MasterDataManagementSetup."Company Name");
        FindFailedNotSkippedIntegrationRecords(TempIntegrationRecordRef, IntegrationTableMapping, TempMasterDataMgtCoupling, FailedNotSkippedIdDictionary);
        FindModifiedIntegrationRecords(TempIntegrationRecordRef, IntegrationTableMapping, FailedNotSkippedIdDictionary);
    end;

    internal procedure GetOutOfMapFilter(): Boolean
    begin
        exit(OutOfMapFilter);
    end;

    local procedure GetSourceRecordRef(IntegrationTableMapping: Record "Integration Table Mapping"; SourceID: Variant; var RecordRef: RecordRef): Boolean
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        MasterDataManagement: Codeunit "Master Data Management";
        RecordID: RecordID;
        IntegrationSystemID: Guid;
        IsHandled: Boolean;
    begin
        case GetSourceType(SourceID) of
            SupportedSourceType::RecordID:
                begin
                    RecordID := SourceID;
                    if RecordID.TableNo = 0 then
                        Error(CannotDetermineSourceOriginErr, SourceID);
                    if not (RecordID.TableNo = IntegrationTableMapping."Table ID") then
                        Error(SourceRecordIsNotInMappingErr, IntegrationTableMapping.TableCaption(), IntegrationTableMapping.Name);
                    if not RecordRef.Get(RecordID) then
                        Error(RecordNotFoundErr, RecordRef.Caption, Format(RecordID, 0, 1));
                    exit(IntegrationTableMapping.FindFilteredRec(RecordRef, OutOfMapFilter));
                end;
            SupportedSourceType::GUID:
                begin
                    IntegrationSystemID := SourceID;
                    if IsNullGuid(IntegrationSystemID) then
                        Error(CannotDetermineSourceOriginErr, SourceID);
                    MasterDataManagement.OnGetIntegrationRecordRefBySystemId(IntegrationTableMapping, RecordRef, IntegrationSystemID, IsHandled);
                    if not IsHandled then begin
                        MasterDataManagementSetup.Get();
                        RecordRef.ChangeCompany(MasterDataManagementSetup."Company Name");
                        if not RecordRef.GetBySystemId(IntegrationSystemID) then
                            Error(RecordNotFoundErr, IntegrationTableMapping.GetExtendedIntegrationTableCaption(), IntegrationSystemID);
                    end;
                    exit(IntegrationTableMapping.FindFilteredRec(RecordRef, OutOfMapFilter));
                end;
            else
                Error(CannotDetermineSourceOriginErr, SourceID);
        end;
    end;

    local procedure GetSourceType(Source: Variant): Integer
    begin
        if Source.IsRecordId then
            exit(SupportedSourceType::RecordID);
        if Source.IsGuid then
            exit(SupportedSourceType::GUID);
        exit(0);
    end;

    local procedure FindFailedNotSkippedLocalRecords(var SystemIdDictionary: Dictionary of [Guid, Boolean]; IntegrationTableMapping: Record "Integration Table Mapping"; var TempMasterDataMgtCoupling: Record "Master Data Mgt. Coupling" temporary): Boolean
    var
        LocalRecordRef: RecordRef;
        PrimaryKeyRef: KeyRef;
        LocalTableView: Text;
        I: Integer;
        NoFilterOnPK: Boolean;
    begin
        LocalTableView := IntegrationTableMapping.GetTableFilter();
        LocalRecordRef.Open(IntegrationTableMapping."Table ID");
        LocalRecordRef.SetView(LocalTableView);

        if LocalRecordRef.Field(LocalRecordRef.SystemIdNo()).GetFilter() <> '' then
            exit(false); // Ignore failed not synched records if going to synch records selected by systemId

        PrimaryKeyRef := LocalRecordRef.KeyIndex(1);
        for I := 1 to PrimaryKeyRef.FieldCount() do
            if LocalRecordRef.Field(PrimaryKeyRef.FieldIndex(I).Number()).GetFilter() = '' then begin
                NoFilterOnPK := true;
                break;
            end;
        if not NoFilterOnPK then
            exit(false); // Ignore failed not synched records if going to synch records selected by primary key

        TempMasterDataMgtCoupling.SetRange(Skipped, false);
        TempMasterDataMgtCoupling.SetRange("Table ID", IntegrationTableMapping."Table ID");
        TempMasterDataMgtCoupling.SetRange("Last Synch. Int. Result", TempMasterDataMgtCoupling."Last Synch. Int. Result"::Failure);
        if TempMasterDataMgtCoupling.FindSet() then
            repeat
                if not SystemIdDictionary.ContainsKey(TempMasterDataMgtCoupling."Local System ID") then
                    SystemIdDictionary.Add(TempMasterDataMgtCoupling."Local System ID", true);
            until TempMasterDataMgtCoupling.Next() = 0;
        TempMasterDataMgtCoupling.SetRange(Skipped);
        TempMasterDataMgtCoupling.SetRange("Table ID");
        TempMasterDataMgtCoupling.SetRange("Last Synch. Int. Result");
        exit(SystemIdDictionary.Count() > 0);
    end;

    internal procedure SynchRecord(IntegrationTableMapping: Record "Integration Table Mapping"; SourceID: Variant; ForceModify: Boolean; IgnoreSynchOnlyCoupledRecords: Boolean) JobID: Guid
    var
        IntegrationTableSynch: Codeunit "Integration Table Synch.";
        FromRecordRef: RecordRef;
        ToRecordRef: RecordRef;
    begin
        if GetSourceRecordRef(IntegrationTableMapping, SourceID, FromRecordRef) then begin // sets the global OutOfMapFilter
            JobID := IntegrationTableSynch.BeginIntegrationSynchJob(TABLECONNECTIONTYPE::ExternalSQL, IntegrationTableMapping, FromRecordRef.Number);
            if not IsNullGuid(JobID) then begin
                IntegrationTableSynch.Synchronize(FromRecordRef, ToRecordRef, ForceModify, IgnoreSynchOnlyCoupledRecords);
                IntegrationTableSynch.EndIntegrationSynchJob();
            end;
        end;
    end;

    local procedure SyncLocalTableToIntegrationTable(IntegrationTableMapping: Record "Integration Table Mapping"; var IntegrationTableSynch: Codeunit "Integration Table Synch.") LatestLocalModifiedOn: DateTime
    var
        TempMasterDataMgtCoupling: Record "Master Data Mgt. Coupling" temporary;
        IntTableManualSubscribers: Codeunit "Int. Table Manual Subscribers";
        IntegrationRecordSynch: Codeunit "Integration Record Synch.";
        SourceRecordRef: RecordRef;
        RecordSystemId: Guid;
        FailedNotSkippedIdDictionary: Dictionary of [Guid, Boolean];
        FilterList: List of [Text];
        TableFilter: Text;
    begin
        BindSubscription(IntTableManualSubscribers);
        LatestLocalModifiedOn := 0DT;
        SplitLocalTableFilter(IntegrationTableMapping, FilterList);
        CreateMasterDataMgtCouplingClone(IntegrationTableMapping."Table ID", TempMasterDataMgtCoupling);

        SourceRecordRef.Open(IntegrationTableMapping."Table ID");
        if FindFailedNotSkippedLocalRecords(FailedNotSkippedIdDictionary, IntegrationTableMapping, TempMasterDataMgtCoupling) then
            foreach RecordSystemId in FailedNotSkippedIdDictionary.Keys() do
                if SourceRecordRef.GetBySystemId(RecordSystemId) then
                    SyncLocalRecordToIntegrationTable(SourceRecordRef, IntegrationTableMapping, IntegrationTableSynch, TempMasterDataMgtCoupling, LatestLocalModifiedOn);

        foreach TableFilter in FilterList do
            if IntegrationRecordSynch.FindModifiedLocalRecords(SourceRecordRef, TableFilter, IntegrationTableMapping) then
                repeat
                    RecordSystemId := SourceRecordRef.Field(SourceRecordRef.SystemIdNo()).Value();
                    if not FailedNotSkippedIdDictionary.ContainsKey(RecordSystemId) then
                        SyncLocalRecordToIntegrationTable(SourceRecordRef, IntegrationTableMapping, IntegrationTableSynch, TempMasterDataMgtCoupling, LatestLocalModifiedOn);
                until SourceRecordRef.Next() = 0;

        OnSyncLocalTableToIntegrationTableOnBeforeCheckLatestModifiedOn(SourceRecordRef, IntegrationTableMapping);
        SourceRecordRef.Close();
        UnbindSubscription(IntTableManualSubscribers);
    end;

    internal procedure SyncLocalRecordToIntegrationTable(var SourceRecordRef: RecordRef; IntegrationTableMapping: Record "Integration Table Mapping"; var IntegrationTableSynch: Codeunit "Integration Table Synch."; var TempMasterDataMgtCoupling: Record "Master Data Mgt. Coupling" temporary; var LatestLocalModifiedOn: DateTime)
    var
        DestinationRecordRef: RecordRef;
        SystemIdFieldRef: FieldRef;
        IgnoreRecord: Boolean;
        ForceModify: Boolean;
        LocalModifiedOn: DateTime;
        RecordSynchSucceeded: Boolean;
    begin
        ForceModify := IntegrationTableMapping."Delete After Synchronization";
        IgnoreRecord := false;
        RecordSynchSucceeded := false;
        OnQueryPostFilterIgnoreRecord(SourceRecordRef, IgnoreRecord);
        if not IgnoreRecord then begin
            SystemIdFieldRef := SourceRecordRef.Field(SourceRecordRef.SystemIdNo);
            if not TempMasterDataMgtCoupling.IsLocalSystemIdCoupled(SystemIdFieldRef.Value()) then
                IgnoreRecord := IntegrationTableMapping."Synch. Only Coupled Records";
            if not IgnoreRecord then
                RecordSynchSucceeded := IntegrationTableSynch.Synchronize(SourceRecordRef, DestinationRecordRef, ForceModify, false);
        end;
        // collect latest modified time across all synched local records
        if RecordSynchSucceeded then begin
            LocalModifiedOn := IntegrationTableSynch.GetRowLastModifiedOn(IntegrationTableMapping, SourceRecordRef);
            if LocalModifiedOn > LatestLocalModifiedOn then
                LatestLocalModifiedOn := LocalModifiedOn;
        end;
    end;

    local procedure SynchIntegrationTableToLocalTable(IntegrationTableMapping: Record "Integration Table Mapping"; var IntegrationTableSynch: Codeunit "Integration Table Synch."; var SourceRecordRef: RecordRef) LatestIntegrationModifiedOn: DateTime
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        TempMasterDataMgtCoupling: Record "Master Data Mgt. Coupling" temporary;
        IntTableManualSubscribers: Codeunit "Int. Table Manual Subscribers";
        MasterDataMgtSubscribers: Codeunit "Master Data Mgt. Subscribers";
        DestinationRecordRef: RecordRef;
        CloneSourceRecordRef: RecordRef;
        IntegrationModifiedOn: DateTime;
        IgnoreRecord: Boolean;
        ForceModify: Boolean;
        RecordSynchSucceeded: Boolean;
    begin
        BindSubscription(IntTableManualSubscribers);
        LatestIntegrationModifiedOn := 0DT;
        MasterDataManagementSetup.Get();
        CreateMasterDataMgtCouplingClone(IntegrationTableMapping."Table ID", TempMasterDataMgtCoupling);
        CacheFilteredIntegrationTable(SourceRecordRef, IntegrationTableMapping, TempMasterDataMgtCoupling);
        ForceModify := IntegrationTableMapping."Delete After Synchronization";
        if SourceRecordRef.FindSet() then
            repeat
                CloneSourceRecordRef.Open(IntegrationTableMapping."Integration Table ID", true, MasterDataManagementSetup."Company Name");
                CopyRecordReference(IntegrationTableMapping, SourceRecordRef, CloneSourceRecordRef, false);
                IgnoreRecord := false;
                RecordSynchSucceeded := false;
                OnQueryPostFilterIgnoreRecord(CloneSourceRecordRef, IgnoreRecord);
                if not IgnoreRecord then begin
                    if TempMasterDataMgtCoupling.IsIntegrationRecordRefCoupled(CloneSourceRecordRef) then
                        TempMasterDataMgtCoupling.Delete()
                    else
                        IgnoreRecord := IntegrationTableMapping."Synch. Only Coupled Records";
                    if not IgnoreRecord then
                        RecordSynchSucceeded := IntegrationTableSynch.Synchronize(CloneSourceRecordRef, DestinationRecordRef, ForceModify, false);
                end;
                // collect latest modified time across all synched integration records
                if RecordSynchSucceeded then begin
                    IntegrationModifiedOn := MasterDataMgtSubscribers.GetRowLastModifiedOn(IntegrationTableMapping, CloneSourceRecordRef);
                    if IntegrationModifiedOn > LatestIntegrationModifiedOn then
                        LatestIntegrationModifiedOn := IntegrationModifiedOn;
                end;
                CloneSourceRecordRef.Close();
            until SourceRecordRef.Next() = 0;
        UnbindSubscription(IntTableManualSubscribers);
    end;

    local procedure PerformScheduledSynchToIntegrationTable(var IntegrationTableMapping: Record "Integration Table Mapping") LatestLocalModifiedOn: DateTime
    var
        MasterDataFullSynchRLn: Record "Master Data Full Synch. R. Ln.";
        IntegrationTableSynch: Codeunit "Integration Table Synch.";
        JobId: Guid;
        JobStartDateTime: DateTime;
    begin
        JobStartDateTime := CurrentDateTime();
        JobId :=
          IntegrationTableSynch.BeginIntegrationSynchJob(
            TABLECONNECTIONTYPE::ExternalSQL, IntegrationTableMapping, IntegrationTableMapping."Table ID");
        if not IsNullGuid(JobId) then begin
            MasterDataFullSynchRLn.FullSynchStarted(IntegrationTableMapping, JobId, IntegrationTableMapping.Direction::ToIntegrationTable);
            LatestLocalModifiedOn := SyncLocalTableToIntegrationTable(IntegrationTableMapping, IntegrationTableSynch);
            if JobStartDateTime > LatestLocalModifiedOn then
                LatestLocalModifiedOn := JobStartDateTime;
            IntegrationTableSynch.EndIntegrationSynchJob();
            MasterDataFullSynchRLn.FullSynchFinished(IntegrationTableMapping, IntegrationTableMapping.Direction::ToIntegrationTable);
        end;
    end;

    local procedure PerformScheduledSynchFromIntegrationTable(var IntegrationTableMapping: Record "Integration Table Mapping") LatestIntegrationModifiedOn: DateTime
    var
        MasterDataFullSynchRLn: Record "Master Data Full Synch. R. Ln.";
        IntegrationTableSynch: Codeunit "Integration Table Synch.";
        SourceRecordRef: RecordRef;
        JobId: Guid;
        JobStartDateTime: DateTime;
    begin
        JobStartDateTime := CurrentDateTime();
        JobId :=
          IntegrationTableSynch.BeginIntegrationSynchJob(
            TABLECONNECTIONTYPE::ExternalSQL, IntegrationTableMapping, IntegrationTableMapping."Integration Table ID");
        if not IsNullGuid(JobId) then begin
            MasterDataFullSynchRLn.FullSynchStarted(IntegrationTableMapping, JobId, IntegrationTableMapping.Direction::FromIntegrationTable);
            LatestIntegrationModifiedOn := SynchIntegrationTableToLocalTable(IntegrationTableMapping, IntegrationTableSynch, SourceRecordRef);
            if JobStartDateTime > LatestIntegrationModifiedOn then
                LatestIntegrationModifiedOn := JobStartDateTime;
            IntegrationTableSynch.EndIntegrationSynchJob();
            MasterDataFullSynchRLn.FullSynchFinished(IntegrationTableMapping, IntegrationTableMapping.Direction::FromIntegrationTable);
        end;
    end;

    internal procedure CreateMasterDataMgtCouplingClone(ForTable: Integer; var TempMasterDataMgtCoupling: Record "Master Data Mgt. Coupling" temporary)
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
    begin
        TempMasterDataMgtCoupling.Reset();
        TempMasterDataMgtCoupling.DeleteAll();

        MasterDataMgtCoupling.SetRange("Table ID", ForTable);
        if not MasterDataMgtCoupling.FindSet() then
            exit;

        repeat
            TempMasterDataMgtCoupling.Copy(MasterDataMgtCoupling, false);
            TempMasterDataMgtCoupling.Insert();
        until MasterDataMgtCoupling.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnQueryPostFilterIgnoreRecord(SourceRecordRef: RecordRef; var IgnoreRecord: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRun(IntegrationTableMapping: Record "Integration Table Mapping"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRun(IntegrationTableMapping: Record "Integration Table Mapping")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSyncLocalTableToIntegrationTableOnBeforeCheckLatestModifiedOn(var SourceRecordRef: RecordRef; IntegrationTableMapping: Record "Integration Table Mapping")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Master Data Synch.", 'OnQueryPostFilterIgnoreRecord', '', false, false)]
    local procedure IgnoreCompanyContactOnQueryPostFilterIgnoreRecord(SourceRecordRef: RecordRef; var IgnoreRecord: Boolean)
    var
        Contact: Record Contact;
    begin
        if IgnoreRecord then
            exit;

        if SourceRecordRef.Number = DATABASE::Contact then begin
            SourceRecordRef.SetTable(Contact);
            if Contact.Type = Contact.Type::Company then
                IgnoreRecord := true;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", 'OnBeforeModifyEvent', '', false, false)]
    local procedure OnBeforeModifyJobQueueEntry(var Rec: Record "Job Queue Entry"; var xRec: Record "Job Queue Entry"; RunTrigger: Boolean)
    var
        MasterDataFullSynchRLn: Record "Master Data Full Synch. R. Ln.";
    begin
        if Rec.IsTemporary() then
            exit;

        MasterDataFullSynchRLn.OnBeforeModifyJobQueueEntry(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Integration Synch. Job", 'OnCanBeRemoved', '', false, false)]
    local procedure OnSynchJobEntryCanBeRemoved(IntegrationSynchJob: Record "Integration Synch. Job"; var AllowRemoval: Boolean)
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
    begin
        if AllowRemoval then
            exit;

        with MasterDataMgtCoupling do begin
            SetRange(Skipped, true);
            SetRange("Last Synch. Job ID", IntegrationSynchJob.ID);
            if IsEmpty() then begin
                SetRange("Last Synch. Job ID");
                SetRange("Last Synch. Int. Job ID", IntegrationSynchJob.ID);
                if IsEmpty() then
                    AllowRemoval := true;
            end;
        end;
    end;

    [InternalEvent(false, false)]
    local procedure OnFindModifiedIntegrationRecords(var TempIntegrationRecordRef: RecordRef; IntegrationTableMapping: Record "Integration Table Mapping"; var FailedNotSkippedIdDictionary: Dictionary of [Guid, Boolean]; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnFindFailedNotSkippedIntegrationRecords(var TempIntegrationRecordRef: RecordRef; IntegrationTableMapping: Record "Integration Table Mapping"; var TempMasterDataMgtCoupling: Record "Master Data Mgt. Coupling" temporary; var IntegrationSystemIDDictionary: Dictionary of [Guid, Boolean]; var Found: Boolean; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnCacheFilteredIntegrationRecords(var IntegrationSystemIDFilterList: List of [Text]; IntegrationTableMapping: Record "Integration Table Mapping"; var TempIntegrationRecordRef: RecordRef; var Cached: Boolean; var IsHandled: Boolean)
    begin
    end;
}



