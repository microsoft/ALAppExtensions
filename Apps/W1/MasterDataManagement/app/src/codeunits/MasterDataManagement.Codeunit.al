namespace Microsoft.Integration.MDM;

using Microsoft.Integration.SyncEngine;
using System.Reflection;
using System.Threading;
using System.Telemetry;
using Microsoft.Integration.Dataverse;
using System.Environment.Configuration;
using System.Environment;
using System.Utilities;
using Microsoft.Finance.Currency;
using Microsoft.CRM.Contact;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using System.Security.AccessControl;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Foundation.Address;
using Microsoft.Purchases.Setup;
using Microsoft.Foundation.NoSeries;
using Microsoft.Foundation.Shipping;
using Microsoft.Sales.Setup;
using Microsoft.CRM.Setup;
using Microsoft.CRM.Team;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.SalesTax;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.Dimension;

codeunit 7233 "Master Data Management"
{
    SingleInstance = true;
    Permissions = tabledata "Master Data Mgt. Coupling" = rmd,
                  tabledata "Integration Field Mapping" = ri,
                  tabledata "Integration Table Mapping" = rim,
                  tabledata "Integration Synch. Job" = r,
                  tabledata "Job Queue Entry" = rm,
                  tabledata "Master Data Management Setup" = r;

    var

        IntegrationTableMappingNotFoundErr: Label 'No %1 was found for table %2.', Comment = '%1 = Integration Table Mapping caption, %2 = Table caption for the table which is not mapped';
        UpdateNowUniDirectionQst: Label 'Send data update to source company.,Get data update from source company.';
        UpdateNowBiDirectionQst: Label 'Send data update to source company.,Get data update from source company.,Merge data.';
        UpdateOneNowTitleTxt: Label 'Synchronize data for %1?', Comment = '%1 = Table caption and value for the entity we want to synchronize now.';
        UpdateMultipleNowTitleTxt: Label 'Synchronize data for the selected records?';
        SyncNowFailedMsg: Label 'The synchronization failed.';
        SyncNowScheduledMsg: Label 'The synchronization has been scheduled.';
        SyncNowSkippedMsg: Label 'The synchronization has been skipped.';
        SyncMultipleMsg: Label 'The synchronization has been scheduled for %1 of %4 records. %2 records failed. %3 records were skipped.', Comment = '%1,%2,%3,%4 are numbers of records';
        UncoupleFailedMsg: Label 'The uncoupling failed.';
        UncoupleScheduledMsg: Label 'The uncoupling has been scheduled.';
        UncoupleSkippedMsg: Label 'The uncoupling has been skipped.';
        UncoupleMultipleMsg: Label 'The uncoupling has been scheduled for %1 of %4 records. %2 records failed. %3 records were skipped.', Comment = '%1,%2,%3,%4 are numbers of records';
        CouplingFailedMsg: Label 'The coupling failed.';
        CouplingScheduledMsg: Label 'The coupling has been scheduled.';
        CouplingSkippedMsg: Label 'The coupling has been skipped.';
        CouplingMultipleMsg: Label 'The coupling has been scheduled for %1 of %4 records. %2 records failed. %3 records were skipped.', Comment = '%1,%2,%3,%4 are numbers of records';
        DetailsTxt: Label 'Details.';
        UpdateOneNowToIntegrationQst: Label 'Send data update to %2 for %1?', Comment = '%1 = Table caption and value for the entity we want to synchronize now., %2 = Business Central product name';
        UpdateOneNowToModifiedIntegrationQst: Label 'The %3 record coupled to %1 contains newer data than the %2 record. Do you want to overwrite the data in %3?', Comment = '%1 = Table caption and value for the entity we want to synchronize now. %2 - product name, %3 = Business Central product name';
        UpdateOneNowFromIntegrationQst: Label 'Get data update from %2 for %1?', Comment = '%1 = Table caption and value for the entity we want to synchronize now., %2 = Business Central product name';
        UpdateOneNowFromOldIntegrationQst: Label 'The %2 record %1 contains newer data than the %3 record. Get data update from %3, overwriting data in %2?', Comment = '%1 = Table caption and value for the entity we want to synchronize now. %2 - product name, %3 = Business Central product name';
        UpdateMultipleNowToIntegrationQst: Label 'Send data update to %1 for the selected records?', Comment = '%1 = Business Central product name';
        UpdateMultipleNowFromIntegrationQst: Label 'Get data update from %1 for the selected records?', Comment = '%1 = Business Central product name';
        BothRecordsModifiedBiDirectionalConflictMsg: Label 'Both the %1 record and the %3 %2 record have been changed since the last synchronization, or synchronization has never been performed. Bi-directional synchronization is forbidden as a changed bidirectional field was detected, but you can continue continue with uni-derictional synchronization. If you continue, data on one of the records will be lost and replaced with data from the other record.', Comment = '%1 and %2 area captions of tables such as Customer and CRM Account, %3 = Business Central product name';
        BothRecordsModifiedBiDirectionalNoConflictMsg: Label 'Both the %1 record and the %3 %2 record have been changed since the last synchronization, or synchronization has never been performed. No one changed bidirectional field was detected, therefore you can continue continue with both bi- and uni-directional synchronization. If you continue, data will be updated in accordance with the chosen synchronization direction and fields mapping.', Comment = '%1 and %2 area captions of tables such as Customer and CRM Account, %3 = Business Central product name';
        BothRecordsModifiedToIntegrationQst: Label 'Both %1 and the %4 %2 record have been changed since the last synchronization, or synchronization has never been performed. If you continue with synchronization, data in %4 will be overwritten with data from %3. Are you sure you want to synchronize?', Comment = '%1 is a formatted RecordID, such as ''Customer 1234''. %2 is the caption of a Business Central table. %3 - product name, %4 = Business Central product name';
        BothRecordsModifiedToNAVQst: Label 'Both %1 and the %4 %2 record have been changed since the last synchronization, or synchronization has never been performed. If you continue with synchronization, data in %3 will be overwritten with data from %4. Are you sure you want to synchronize?', Comment = '%1 is a formatted RecordID, such as ''Customer 1234''. %2 is the caption of a Business Central  table. %3 - product name, %4 = Business Central product name';
        NoOf: Option ,Scheduled,Failed,Skipped,Total;
        CategoryTok: Label 'AL Master Data Management', Locked = true;
        DeletionConflictHandledRemoveCouplingTxt: Label 'Deletion conflict handled by removing the coupling to the deleted record.', Locked = true;
        DeletionConflictHandledRestoreRecordTxt: Label 'Deletion conflict handled by restoring the deleted record.', Locked = true;
        ResetAllCustomIntegrationTableMappingsLbl: Label 'One or more of the selected integration table mappings is custom. \\To restore a custom table mapping, you must subscribe to the event OnBeforeResetTableMapping in codeunit "Master Data Mgt. Setup Default" and implement the defaults for each custom table mapping. \\Do you want to continue?';
        DeletedRecordWithZeroTableIdTxt: Label 'CRM Integration Record with zero Table ID has been deleted. Integration ID: %1, CRM ID: %2', Locked = true;
        AllRecordsMarkedAsSkippedTxt: Label 'All of selected %1 records are marked as skipped.', Comment = '%1 = table caption';
        RecordMarkedAsSkippedTxt: Label 'The %1 record is marked as skipped.', Comment = '%1 = table caption';
        AllRecordsAlreadyCoupledTxt: Label 'All of the selected records are already coupled.', Comment = '%1 = table caption';
        RecordAlreadyCoupledTxt: Label 'The record is already coupled.', Comment = '%1 = table caption';
        DetailedNotificationMessageTxt: Label '%1 %2', Comment = '%1 - notification message, %2 - details', Locked = true;
        CommonNotificationNameTxt: Label 'Notify the user about scheduled synchronization jobs.';
        CommonNotificationDescriptionTxt: Label 'Turns the user''s attention to the Integration Synchronization Jobs page.';
        DisableNotificationTxt: Label 'Disable this notification.';
        UserDisabledNotificationTxt: Label 'The user disabled notification ''%1''.', Locked = true;
        UserOpenedIntegrationSynchJobListViaNotificationTxt: Label 'User opened Integration Synchronization Jobs via the notification.', Locked = true;
        RecordRefAlreadyMappedErr: Label 'Cannot couple %1 to this %3 record, because the %3 record is already coupled to %2.', Comment = '%1 ID of the record, %2 ID of the already mapped record, %3 = table caption';
        RecordIdAlreadyMappedErr: Label 'Cannot couple the %2 record to %1, because %1 is already coupled to another %2 record.', Comment = '%1 ID from the record, %2 ID of the already mapped record';
        IntegrationRecordNotFoundErr: Label 'The integration record for entity %1 was not found.', Comment = '%1 - entity name';
        RescheduledTaskTxt: label 'Rescheduled task %1 for Job Queue Entry %2 (%3) to run not before %4', Locked = true;
        FeatureNameTxt: Label 'Master Data Management', Locked = true;
        CachedIsSynchronizationRecord: Dictionary of [Text, Boolean];
        CachedDisableEventDrivenSynchJobReschedule: Dictionary of [Text, Boolean];
        NoPermissionToSetUpErr: Label 'Your license does not allow you to set up Master Data Management. To view details about your permissions, see the Effective Permissions page.';
        NoPermissionToUseErr: Label 'Your license does not allow you to use Master Data Management. To view details about your permissions, see the Effective Permissions page.';
        NoPermissionToScheduleJobErr: Label 'Your license does not allow you to schedule a background task. To view details about your permissions, see the Effective Permissions page.';

    internal procedure GetFeatureName(): Text
    begin
        exit(FeatureNameTxt);
    end;

    internal procedure GetTelemetryCategory(): Text
    begin
        exit(CategoryTok);
    end;

    internal procedure IsEnabled(): Boolean
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
    begin
        if not MasterDataManagementSetup.ReadPermission() then
            exit(false);

        if not MasterDataManagementSetup.Get() then
            exit(false);

        if not MasterDataManagementSetup."Is Enabled" then
            exit(false);

        exit(true);
    end;

    internal procedure UpdateMultipleNow(RecVariant: Variant)
    begin
        UpdateMultipleNow(RecVariant, false);
    end;

    internal procedure UpdateMultipleNow(RecVariant: Variant; IsOption: Boolean)
    var
        RecRef: RecordRef;
        RecordCounter: array[4] of Integer;
    begin
        RecordCounter[NoOf::Total] := GetRecordRef(RecVariant, RecRef);
        if RecordCounter[NoOf::Total] = 0 then
            exit;

        if RecRef.Number = DATABASE::"Master Data Mgt. Coupling" then
            UpdateIntRecords(RecRef, RecordCounter)
        else
            UpdateRecords(RecRef, RecordCounter);
    end;

    local procedure UpdateIntRecords(var RecRef: RecordRef; var RecordCounter: array[4] of Integer)
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationRecordSynch: Codeunit "Integration Record Synch.";
        SourceRecRef: RecordRef;
        RecId: RecordId;
        SelectedDirection: Integer;
        Direction: Integer;
        Unused: Boolean;
        LocalTableId: Integer;
        MappingName: Code[20];
        RecordCount: Integer;
        TotalCount: Integer;
        IdFilter: Text;
        IdFilterList: List of [Text];
        LocalTableList: List of [Integer];
        LocalIdList: List of [Guid];
        IntegrationSystemIdList: List of [Guid];
        MappingDictionary: Dictionary of [Integer, Code[20]];
        LocalIdDictionary: Dictionary of [Code[20], List of [Guid]];
        IntegrationSystemIdDictionary: Dictionary of [Code[20], List of [Guid]];
        TableCaption: Text;
    begin
        if RecordCounter[NoOf::Total] = 1 then begin
            RecRef.SetTable(MasterDataMgtCoupling);
            LocalTableId := MasterDataMgtCoupling."Table ID";
            GetIntegrationTableMapping(IntegrationTableMapping, LocalTableId);
            MasterDataMgtCoupling.FindRecordId(RecId);
            SourceRecRef.Get(RecId);
            SelectedDirection :=
              GetSelectedSingleSyncDirection(IntegrationTableMapping, SourceRecRef, MasterDataMgtCoupling."Integration System ID", Unused)
        end else begin
            IntegrationTableMapping.Direction := IntegrationTableMapping.Direction::Bidirectional;
            SelectedDirection := GetSelectedMultipleSyncDirection(IntegrationTableMapping);
        end;
        if SelectedDirection < 0 then
            exit; // The user cancelled

        repeat
            RecRef.SetTable(MasterDataMgtCoupling);
            MasterDataMgtCoupling.FindRecordId(RecId);
            LocalTableId := MasterDataMgtCoupling."Table ID";
            if not MappingDictionary.ContainsKey(LocalTableId) then begin
                GetIntegrationTableMapping(IntegrationTableMapping, LocalTableId);
                MappingDictionary.Add(LocalTableId, IntegrationTableMapping.Name);
            end;
            MappingName := MappingDictionary.Get(LocalTableId);
            if not LocalIdDictionary.ContainsKey(MappingName) then begin
                Clear(LocalIdList);
                LocalIdDictionary.Add(MappingName, LocalIdList);
            end;
            if not IntegrationSystemIdDictionary.ContainsKey(MappingName) then begin
                Clear(IntegrationSystemIdList);
                IntegrationSystemIdDictionary.Add(MappingName, IntegrationSystemIdList);
            end;
            LocalIdList := LocalIdDictionary.Get(MappingName);
            IntegrationSystemIdList := IntegrationSystemIdDictionary.Get(MappingName);
            LocalIdList.Add(MasterDataMgtCoupling."Local System ID");
            IntegrationSystemIdList.Add(MasterDataMgtCoupling."Integration System ID");
            TotalCount += 1;
        until RecRef.Next() = 0;

        if TotalCount = 0 then begin
            if MappingDictionary.Keys().Count() = 1 then
                TableCaption := GetTableCaption(MappingDictionary.Keys().Get(1));
            if RecordCounter[NoOf::Total] > 1 then
                SendNotification(StrSubstNo(DetailedNotificationMessageTxt, SyncNowSkippedMsg, StrSubstNo(AllRecordsMarkedAsSkippedTxt, TableCaption)))
            else
                SendNotification(StrSubstNo(DetailedNotificationMessageTxt, SyncNowSkippedMsg, StrSubstNo(RecordMarkedAsSkippedTxt, TableCaption)));
            exit;
        end;

        LocalTableList := MappingDictionary.Keys();
        foreach LocalTableId in LocalTableList do begin
            MappingName := MappingDictionary.Get(LocalTableId);
            LocalIdList := LocalIdDictionary.Get(MappingName);
            RecordCount := LocalIdList.Count();
            if RecordCount > 0 then begin
                IntegrationSystemIdList := IntegrationSystemIdDictionary.Get(MappingName);
                IntegrationTableMapping.Get(MappingName);
                if IntegrationTableMapping.Direction = IntegrationTableMapping.Direction::Bidirectional then
                    Direction := SelectedDirection
                else
                    Direction := IntegrationTableMapping.Direction;
                if EnqueueSyncJob(IntegrationTableMapping, LocalIdList, IntegrationSystemIdList, Direction, false) then begin
                    IntegrationRecordSynch.GetIdFilterList(LocalIdList, IdFilterList);
                    foreach IdFilter in IdFilterList do
                        if IdFilter <> '' then begin
                            MasterDataMgtCoupling.SetFilter("Local System ID", IdFilter);
                            MasterDataMgtCoupling.ModifyAll(Skipped, false);
                        end;
                    RecordCounter[NoOf::Scheduled] += RecordCount;
                end else
                    RecordCounter[NoOf::Failed] += RecordCount;
            end;
        end;

        SendSyncNotification(RecordCounter);
    end;

    local procedure UpdateRecords(var LocalRecordRef: RecordRef; var RecordCounter: array[4] of Integer)
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        SelectedDirection: Integer;
        IntegrationSystemId: Guid;
        Unused: Boolean;
        Skipped: Boolean;
        RecordCount: Integer;
        LocalId: Guid;
        LocalIdList: List of [Guid];
        IntegrationSystemIdList: List of [Guid];
    begin
        GetIntegrationTableMapping(IntegrationTableMapping, LocalRecordRef.Number());

        if RecordCounter[NoOf::Total] = 1 then
            if GetCoupledIntegrationSystemId(LocalRecordRef.RecordId(), IntegrationSystemId) then
                SelectedDirection :=
                  GetSelectedSingleSyncDirection(IntegrationTableMapping, LocalRecordRef, IntegrationSystemId, Unused)
            else
                exit
        else
            SelectedDirection := GetSelectedMultipleSyncDirection(IntegrationTableMapping);
        if SelectedDirection < 0 then
            exit; // The user cancelled

        repeat
            Skipped := false;
            if RecordCounter[NoOf::Total] > 1 then begin
                Skipped := not GetCoupledIntegrationSystemId(LocalRecordRef.RecordId(), IntegrationSystemId);
                if not Skipped then
                    Skipped := WasRecordModifiedAfterLastSynch(IntegrationTableMapping, LocalRecordRef, IntegrationSystemId, SelectedDirection);
            end;
            if not Skipped then
                Skipped := IsRecordSkipped(LocalRecordRef.RecordId());
            if Skipped then
                RecordCounter[NoOf::Skipped] += 1
            else begin
                LocalId := LocalRecordRef.Field((LocalRecordRef.SystemIdNo())).Value();
                LocalIdList.Add(LocalId);
                IntegrationSystemIdList.Add(IntegrationSystemId);
            end;
        until LocalRecordRef.Next() = 0;

        RecordCount := LocalIdList.Count();
        if RecordCount = 0 then begin
            if RecordCounter[NoOf::Total] > 1 then
                SendNotification(StrSubstNo(DetailedNotificationMessageTxt, SyncNowSkippedMsg, StrSubstNo(AllRecordsMarkedAsSkippedTxt, GetTableCaption(LocalRecordRef.Number()))))
            else
                SendNotification(StrSubstNo(DetailedNotificationMessageTxt, SyncNowSkippedMsg, StrSubstNo(RecordMarkedAsSkippedTxt, GetTableCaption(LocalRecordRef.Number()))));
            exit;
        end;

        if EnqueueSyncJob(IntegrationTableMapping, LocalIdList, IntegrationSystemIdList, SelectedDirection, IntegrationTableMapping."Synch. Only Coupled Records") then
            RecordCounter[NoOf::Scheduled] += RecordCount
        else
            RecordCounter[NoOf::Failed] += RecordCount;

        SendSyncNotification(RecordCounter);
    end;

    internal procedure UpdateOneNow(RecordID: RecordID)
    begin
        // Extinct method. Kept for backward compatibility.
        UpdateMultipleNow(RecordID)
    end;

    local procedure WasRecordModifiedAfterLastSynch(IntegrationTableMapping: Record "Integration Table Mapping"; RecRef: RecordRef; IntegrationSystemId: Guid; SelectedDirection: Option): Boolean
    var
        IntegrationRecSynchInvoke: Codeunit "Integration Rec. Synch. Invoke";
        IntegrationRecordRef: RecordRef;
        RecordModified: Boolean;
        IntegrationRecordModified: Boolean;
    begin
        RecordModified := IntegrationRecSynchInvoke.WasModifiedAfterLastSynch(IntegrationTableMapping, RecRef);
        GetIntegrationRecordRef(IntegrationTableMapping, IntegrationSystemId, IntegrationRecordRef);
        IntegrationRecordModified := IntegrationRecSynchInvoke.WasModifiedAfterLastSynch(IntegrationTableMapping, IntegrationRecordRef);
        exit(
          ((SelectedDirection = IntegrationTableMapping.Direction::ToIntegrationTable) and IntegrationRecordModified) or
          ((SelectedDirection = IntegrationTableMapping.Direction::FromIntegrationTable) and RecordModified))
    end;

    internal procedure GetIntegrationSystemIdFromRecRef(IntegrationRecordRef: RecordRef): Guid
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        IntegrationSystemIDFieldRef: FieldRef;
        IntegrationRecordSystemId: Guid;
        IsHandled: Boolean;
        SourceCompanyName: Text[30];
    begin
        OnGetIntegrationSystemIdFromRecRef(IntegrationRecordRef, IntegrationRecordSystemId, IsHandled);
        if IsHandled then
            exit(IntegrationRecordSystemId);

        MasterDataManagementSetup.Get();

        OnSetSourceCompanyName(SourceCompanyName, IntegrationRecordRef.Number());
        if SourceCompanyName = '' then
            SourceCompanyName := MasterDataManagementSetup."Company Name";
        IntegrationRecordRef.ChangeCompany(SourceCompanyName);

        IntegrationSystemIDFieldRef := IntegrationRecordRef.Field(IntegrationRecordRef.SystemIdNo());
        exit(IntegrationSystemIDFieldRef.Value);
    end;

    internal procedure GetIntegrationRecordRef(var IntegrationTableMapping: Record "Integration Table Mapping"; ID: Variant; var IntegrationRecordRef: RecordRef): Boolean
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        IDFieldRef: FieldRef;
        RecordID: RecordID;
        TextKey: Text;
        Found: Boolean;
        IsHandled: Boolean;
        SourceCompanyName: Text[30];
    begin
        OnGetIntegrationRecordRefByIntegrationSystemId(IntegrationTableMapping, ID, IntegrationRecordRef, Found, IsHandled);
        if IsHandled then
            exit(Found);

        IntegrationRecordRef.Close();
        MasterDataManagementSetup.Get();
        OnSetSourceCompanyName(SourceCompanyName, IntegrationTableMapping."Integration Table ID");
        if SourceCompanyName = '' then
            SourceCompanyName := MasterDataManagementSetup."Company Name";
        if ID.IsGuid then begin
            IntegrationRecordRef.Open(IntegrationTableMapping."Integration Table ID");
            IntegrationRecordRef.ChangeCompany(SourceCompanyName);
            IDFieldRef := IntegrationRecordRef.Field(IntegrationTableMapping."Integration Table UID Fld. No.");
            IDFieldRef.SetFilter(ID);
            exit(IntegrationRecordRef.FindFirst());
        end;

        if ID.IsRecordId then begin
            IntegrationRecordRef.Open(IntegrationTableMapping."Integration Table ID");
            IntegrationRecordRef.ChangeCompany(SourceCompanyName);
            RecordID := ID;
            if RecordID.TableNo = IntegrationTableMapping."Table ID" then
                exit(IntegrationRecordRef.Get(ID));
        end;

        if ID.IsText then begin
            IntegrationRecordRef.Open(IntegrationTableMapping."Integration Table ID");
            IntegrationRecordRef.ChangeCompany(SourceCompanyName);
            IDFieldRef := IntegrationRecordRef.Field(IntegrationTableMapping."Integration Table UID Fld. No.");
            TextKey := ID;
            IDFieldRef.SetFilter('%1', TextKey);
            exit(IntegrationRecordRef.FindFirst());
        end;
    end;

    local procedure GetRecordRef(RecVariant: Variant; var RecordRef: RecordRef): Integer
    begin
        case true of
            RecVariant.IsRecord:
                RecordRef.GetTable(RecVariant);
            RecVariant.IsRecordId:
                if RecordRef.Get(RecVariant) then
                    RecordRef.SetRecFilter();
            RecVariant.IsRecordRef:
                RecordRef := RecVariant;
            else
                exit(0);
        end;
        if RecordRef.FindSet() then
            exit(RecordRef.Count);
        exit(0);
    end;

    internal procedure CreateNewRecordsInLocalSystem(var IntegrationIdListDictionary: Dictionary of [Code[20], List of [Guid]])
    var
        LocalSystemIdListDictionary: Dictionary of [Code[20], List of [Guid]];
    begin
        CreateNewRecords(LocalSystemIdListDictionary, IntegrationIdListDictionary);
    end;

    internal procedure CreateNewRecords(var LocalIdListDictionary: Dictionary of [Code[20], List of [Guid]]; var IntegrationSystemIdListDictionary: Dictionary of [Code[20], List of [Guid]])
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        IntegrationRecordRef: RecordRef;
        RecordCounter: array[4] of Integer;
        LocalId: Guid;
        IntegrationSystemId: Guid;
        LocalIdCount: Integer;
        IntegrationSystemIdCount: Integer;
        MappingDictionary: Dictionary of [Code[20], Boolean];
        ToIntegrationMappingList: List of [Code[20]];
        FromIntegrationMappingList: List of [Code[20]];
        MappingList: List of [Code[20]];
        LocalIdList: List of [Guid];
        IntegrationSystemIdList: List of [Guid];
        MappingName: Code[20];
        I: Integer;
        J: Integer;
    begin
        ToIntegrationMappingList := LocalIdListDictionary.Keys();
        FromIntegrationMappingList := IntegrationSystemIdListDictionary.Keys();
        MappingList.AddRange(ToIntegrationMappingList);
        MappingList.AddRange(FromIntegrationMappingList);
        foreach MappingName in MappingList do
            if not MappingDictionary.ContainsKey(MappingName) then
                MappingDictionary.Add(MappingName, true);
        MappingList := MappingDictionary.Keys();
        foreach MappingName in MappingList do begin
            Clear(LocalIdList);
            Clear(IntegrationSystemIdList);
            IntegrationTableMapping.Get(MappingName);
            if ToIntegrationMappingList.Contains(MappingName) then begin
                LocalIdList := LocalIdListDictionary.Get(MappingName);
                LocalIdCount := LocalIdList.Count();
                if LocalIdCount > 0 then begin
                    J := LocalIdCount + 1;
                    for I := 1 to LocalIdCount do begin
                        J -= 1;
                        LocalId := LocalIdList.Get(J);
                        RecordCounter[NoOf::Total] += 1;
                        MasterDataMgtCoupling.SetCurrentKey("Local System ID");
                        MasterDataMgtCoupling.SetFilter("Local System ID", LocalId);
                        if MasterDataMgtCoupling.FindFirst() then begin
                            if GetIntegrationRecordRef(IntegrationTableMapping."Integration Table ID", MasterDataMgtCoupling, IntegrationRecordRef) then begin
                                RecordCounter[NoOf::Skipped] += 1;
                                LocalIdList.RemoveAt(J);
                            end else
                                if not IsNullGuid(MasterDataMgtCoupling."Integration System ID") then // found the corrupt coupling
                                    MasterDataMgtCoupling.Delete();
                            IntegrationRecordRef.Close();
                        end;
                    end;
                end;
            end;
            if FromIntegrationMappingList.Contains(MappingName) then begin
                IntegrationSystemIdList := IntegrationSystemIdListDictionary.Get(MappingName);
                IntegrationSystemIdCount := IntegrationSystemIdList.Count();
                if IntegrationSystemIdCount > 0 then begin
                    J := IntegrationSystemIdCount + 1;
                    for I := 1 to IntegrationSystemIdCount do begin
                        J -= 1;
                        IntegrationSystemId := IntegrationSystemIdList.Get(J);
                        RecordCounter[NoOf::Total] += 1;
                        if FindCouplingByIntegrationSystemId(MasterDataMgtCoupling, IntegrationSystemId) then begin
                            RecordCounter[NoOf::Skipped] += 1;
                            IntegrationSystemIdList.RemoveAt(J);
                        end else
                            if not IsNullGuid(MasterDataMgtCoupling."Integration System ID") then // found the corrupt coupling
                                MasterDataMgtCoupling.Delete();
                    end;
                end;
            end;
            EnqueueCreateNewJob(LocalIdList, IntegrationSystemIdList, RecordCounter, IntegrationTableMapping);
        end;
        SendCreateNewNotification(RecordCounter);
    end;

    local procedure EnqueueCreateNewJob(var LocalIdList: List of [Guid]; IntegrationSystemIdList: List of [Guid]; var RecordCounter: array[4] of Integer; var IntegrationTableMapping: Record "Integration Table Mapping")
    var
        LocalIdCount: Integer;
        IntegrationSystemIdCount: Integer;
        Direction: Option;
    begin
        LocalIdCount := LocalIdList.Count();
        IntegrationSystemIdCount := IntegrationSystemIdList.Count();
        if (LocalIdCount > 0) or (IntegrationSystemIdCount > 0) then begin
            if IntegrationSystemIdCount = 0 then
                Direction := IntegrationTableMapping.Direction::ToIntegrationTable
            else
                if LocalIdCount = 0 then
                    Direction := IntegrationTableMapping.Direction::FromIntegrationTable
                else
                    Direction := IntegrationTableMapping.Direction;
            if EnqueueSyncJob(IntegrationTableMapping, LocalIdList, IntegrationSystemIdList, Direction, false) then
                RecordCounter[NoOf::Scheduled] += LocalIdCount + IntegrationSystemIdCount
            else
                RecordCounter[NoOf::Failed] += LocalIdCount + IntegrationSystemIdCount;
        end;
    end;

    local procedure SendCreateNewNotification(var RecordCounter: array[4] of Integer)
    begin
        if RecordCounter[NoOf::Total] = RecordCounter[NoOf::Skipped] then begin
            if RecordCounter[NoOf::Total] > 1 then
                SendNotification(StrSubstNo(DetailedNotificationMessageTxt, SyncNowSkippedMsg, AllRecordsAlreadyCoupledTxt))
            else
                SendNotification(StrSubstNo(DetailedNotificationMessageTxt, SyncNowSkippedMsg, RecordAlreadyCoupledTxt));
            exit;
        end;

        SendSyncNotification(RecordCounter);
    end;

    internal procedure RepairBrokenCouplings()
    begin
        RepairBrokenCouplings(false);
    end;

    internal procedure RepairBrokenCouplings(UseLocalRecordsOnly: Boolean)
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        BlankGuid: Guid;
    begin
        MasterDataMgtCoupling.SetRange("Table ID", 0);
        if MasterDataMgtCoupling.IsEmpty() then
            exit;

        if MasterDataMgtCoupling.FindSet() then
            repeat
                if MasterDataMgtCoupling."Local System ID" <> BlankGuid then
                    if not MasterDataMgtCoupling.RepairTableIdByLocalRecord() then
                        if not UseLocalRecordsOnly then
                            if not MasterDataMgtCoupling.RepairTableIdByIntegrationRecord() then begin
                                MasterDataMgtCoupling.Delete();
                                Session.LogMessage('0000J7U', StrSubstNo(DeletedRecordWithZeroTableIdTxt, MasterDataMgtCoupling."Local System ID", MasterDataMgtCoupling."Integration System ID"), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                            end;
            until MasterDataMgtCoupling.Next() = 0;
    end;

    internal procedure RemoveCoupling(TableID: Integer; IntegrationTableID: Integer)
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        IntegrationTableMapping: Record "Integration Table Mapping";
    begin
        if GetIntegrationTableMappingForUncoupling(IntegrationTableMapping, TableID, IntegrationTableID) then
            ScheduleUncoupling(IntegrationTableMapping, '', '')
        else begin
            RepairBrokenCouplings();
            MasterDataMgtCoupling.SetRange("Table ID", TableID);
            MasterDataMgtCoupling.DeleteAll();
        end;
    end;

    internal procedure MatchBasedCoupling(TableID: Integer): Boolean
    begin
        exit(MatchBasedCoupling(TableID, false, false, false));
    end;

    procedure MatchBasedCoupling(TableID: Integer; SkipSettingCriteria: Boolean; IsFullSync: Boolean; InForeground: Boolean): Boolean
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        ScheduleJob: Boolean;
    begin
        if GetIntegrationTableMappingForCoupling(IntegrationTableMapping, TableID) then begin
            if SkipSettingCriteria then
                ScheduleJob := true;

            if not ScheduleJob then begin
                IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
                IntegrationFieldMapping.SetRange("Constant Value", '');
                IntegrationFieldMapping.FindSet();
                ScheduleJob := (Page.RunModal(Page::"Match Based Coupling Criteria", IntegrationFieldMapping) = Action::LookupOK);
            end;

            if not ScheduleJob then
                exit(false);

            if InForeground then
                exit(PerformCoupling(IntegrationTableMapping, '', IsFullSync))
            else
                exit(ScheduleCoupling(IntegrationTableMapping, '', IsFullSync));
        end;

        exit(false);
    end;

    internal procedure RemoveCoupling(RecordID: RecordID; Schedule: Boolean): Boolean
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationRecordSynch: Codeunit "Integration Record Synch.";
    begin
        if not GetIntegrationTableMappingForUncoupling(IntegrationTableMapping, RecordID.TableNo()) then
            exit(MasterDataMgtCoupling.RemoveCouplingToRecord(RecordID));

        if Schedule then
            exit(ScheduleUncoupling(IntegrationTableMapping, IntegrationRecordSynch.GetTableViewForRecordID(RecordID), ''));

        exit(PerformUncoupling(IntegrationTableMapping, IntegrationRecordSynch.GetTableViewForRecordID(RecordID), ''));
    end;

    internal procedure RemoveCoupling(TableID: Integer; IntegrationTableID: Integer; IntegrationSystemId: Guid; Schedule: Boolean): Boolean
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        IntegrationTableMapping: Record "Integration Table Mapping";
    begin
        if not GetIntegrationTableMappingForUncoupling(IntegrationTableMapping, TableID, IntegrationTableID) then
            exit(MasterDataMgtCoupling.RemoveCouplingToIntegrationSystemId(IntegrationSystemId, TableID));

        if Schedule then
            exit(ScheduleUncoupling(IntegrationTableMapping, '', GetTableViewForGuid(IntegrationTableID, IntegrationTableMapping."Integration Table UID Fld. No.", IntegrationSystemId)));

        exit(PerformUncoupling(IntegrationTableMapping, '', GetTableViewForGuid(IntegrationTableID, IntegrationTableMapping."Integration Table UID Fld. No.", IntegrationSystemId)));
    end;

    local procedure ScheduleUncoupling(var IntegrationTableMapping: Record "Integration Table Mapping"; LocalTableFilter: Text; IntegrationTableFilter: Text): Boolean
    var
        RecordCounter: array[4] of Integer;
        Scheduled: Boolean;
    begin
        RecordCounter[NoOf::Total] := 1;
        Scheduled := EnqueueUncoupleJob(IntegrationTableMapping, LocalTableFilter, IntegrationTableFilter);
        if Scheduled then
            RecordCounter[NoOf::Scheduled] += 1
        else
            RecordCounter[NoOf::Failed] += 1;
        SendUncoupleNotification(RecordCounter);
        exit(Scheduled);
    end;

    local procedure ScheduleCoupling(var IntegrationTableMapping: Record "Integration Table Mapping"; LocalTableFilter: Text; IsFullSync: Boolean): Boolean
    var
        RecordCounter: array[4] of Integer;
        Scheduled: Boolean;
    begin
        IntegrationTableMapping.Find();
        RecordCounter[NoOf::Total] := 1;
        Scheduled := EnqueueCouplingJob(IntegrationTableMapping, LocalTableFilter, IsFullSync);
        if Scheduled then
            RecordCounter[NoOf::Scheduled] += 1
        else
            RecordCounter[NoOf::Failed] += 1;
        SendCouplingNotification(RecordCounter);
        exit(Scheduled);
    end;

    local procedure PerformCoupling(IntegrationTableMapping: Record "Integration Table Mapping"; LocalTableFilter: Text; IsFullSync: Boolean): Boolean
    var
        MasterDataMgtTableCouple: Codeunit "Master Data Mgt. Table Couple";
    begin
        IntegrationTableMapping.Find();
        if LocalTableFilter <> '' then
            IntegrationTableMapping.SetTableFilter(LocalTableFilter)
        else
            IntegrationTableMapping.CalcFields("Table Filter");
        IntegrationTableMapping.CalcFields("Integration Table Filter");
        IntegrationTableMapping."Full Sync is Running" := IsFullSync;
        AddIntegrationTableMapping(IntegrationTableMapping, true);
        MasterDataMgtTableCouple.PerformScheduledCoupling(IntegrationTableMapping);
        IntegrationTableMapping.Delete(true);
    end;

    local procedure PerformUncoupling(IntegrationTableMapping: Record "Integration Table Mapping"; LocalTableFilter: Text; IntegrationTableFilter: Text): Boolean
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        LocalRecordRef: RecordRef;
        IntegrationRecordRef: RecordRef;
        CountFailed: Integer;
        SourceCompanyName: Text[30];
    begin
        AddIntegrationTableMapping(IntegrationTableMapping);
        IntegrationTableMapping.SetTableFilter(LocalTableFilter);
        IntegrationTableMapping.SetIntegrationTableFilter(IntegrationTableFilter);
        if LocalTableFilter <> '' then begin
            LocalRecordRef.Open(IntegrationTableMapping."Table ID");
            LocalRecordRef.SetView(LocalTableFilter);
            if LocalRecordRef.FindSet() then
                repeat
                    if not PerformUncoupling(IntegrationTableMapping, LocalRecordRef, IntegrationRecordRef) then
                        CountFailed += 1;
                until LocalRecordRef.Next() = 0
        end else begin
            MasterDataManagementSetup.Get();
            IntegrationRecordRef.Open(IntegrationTableMapping."Integration Table ID");
            OnSetSourceCompanyName(SourceCompanyName, IntegrationTableMapping."Integration Table ID");
            if SourceCompanyName = '' then
                SourceCompanyName := MasterDataManagementSetup."Company Name";
            IntegrationRecordRef.ChangeCompany(SourceCompanyName);
            IntegrationRecordRef.SetView(IntegrationTableFilter);
            if IntegrationRecordRef.FindSet() then
                repeat
                    if not PerformUncoupling(IntegrationTableMapping, LocalRecordRef, IntegrationRecordRef) then
                        CountFailed += 1;
                until IntegrationRecordRef.Next() = 0;
        end;
        IntegrationTableMapping.Delete(true);
        exit(CountFailed = 0);
    end;

    local procedure PerformUncoupling(IntegrationTableMapping: Record "Integration Table Mapping"; LocalRecordRef: RecordRef; IntegrationRecordRef: RecordRef): Boolean
    var
        IntRecUncoupleInvoke: Codeunit "Int. Rec. Uncouple Invoke";
        SynchAction: Option "None",Insert,Modify,ForceModify,IgnoreUnchanged,Fail,Skip,Delete,Uncouple,Couple;
        LocalRecordModified: Boolean;
        IntegrationRecordModified: Boolean;
        JobId: Guid;
    begin
        SynchAction := SynchAction::Uncouple;
        IntRecUncoupleInvoke.SetContext(IntegrationTableMapping, LocalRecordRef, IntegrationRecordRef, SynchAction, LocalRecordModified, IntegrationRecordModified, JobId, TableConnectionType::ExternalSQL);
        IntRecUncoupleInvoke.Run();
        IntRecUncoupleInvoke.GetContext(IntegrationTableMapping, LocalRecordRef, IntegrationRecordRef, SynchAction, LocalRecordModified, IntegrationRecordModified);
        exit(SynchAction <> SynchAction::Fail);
    end;

    local procedure GetIntegrationTableMappingForUncoupling(var IntegrationTableMapping: Record "Integration Table Mapping"; TableID: Integer; IntegrationTableID: Integer): Boolean
    begin
        IntegrationTableMapping.SetRange(Status, IntegrationTableMapping.Status::Enabled);
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        IntegrationTableMapping.SetRange("Uncouple Codeunit ID", Codeunit::"Master Data Mgt. Tbl. Uncouple");
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        IntegrationTableMapping.SetRange("Table ID", TableID);
        IntegrationTableMapping.SetRange("Integration Table ID", IntegrationTableID);
        exit(IntegrationTableMapping.FindFirst());
    end;

    local procedure GetIntegrationTableMappingForUncoupling(var IntegrationTableMapping: Record "Integration Table Mapping"; TableID: Integer): Boolean
    begin
        IntegrationTableMapping.SetRange(Status, IntegrationTableMapping.Status::Enabled);
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        IntegrationTableMapping.SetRange("Uncouple Codeunit ID", Codeunit::"Master Data Mgt. Tbl. Uncouple");
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        IntegrationTableMapping.SetRange("Table ID", TableID);
        exit(IntegrationTableMapping.FindFirst());
    end;

    local procedure GetIntegrationTableMappingForCoupling(var IntegrationTableMapping: Record "Integration Table Mapping"; TableID: Integer): Boolean
    begin
        IntegrationTableMapping.SetRange(Status, IntegrationTableMapping.Status::Enabled);
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        IntegrationTableMapping.SetRange("Coupling Codeunit ID", Codeunit::"Master Data Mgt. Table Couple");
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        IntegrationTableMapping.SetRange("Table ID", TableID);
        exit(IntegrationTableMapping.FindFirst());
    end;

    internal procedure GetIntegrationTableMapping(var IntegrationTableMapping: Record "Integration Table Mapping"; TableID: Integer)
    begin
        OnBeforeGetIntegrationTableMapping(IntegrationTableMapping, TableId);
        IntegrationTableMapping.SetRange(Status, IntegrationTableMapping.Status::Enabled);
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        IntegrationTableMapping.SetRange("Synch. Codeunit ID", CODEUNIT::"Integration Master Data Synch.");
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        IntegrationTableMapping.SetRange("Integration Table ID", TableID);
        IntegrationTableMapping.SetRange("Table ID", TableID);
        if not IntegrationTableMapping.FindFirst() then
            Error(IntegrationTableMappingNotFoundErr, IntegrationTableMapping.TableCaption(), GetTableCaption(TableID));
    end;

    local procedure GetTableCaption(TableID: Integer): Text
    var
        TableMetadata: Record "Table Metadata";
    begin
        if TableMetadata.Get(TableID) then
            exit(TableMetadata.Caption);
        exit('');
    end;

    local procedure IsRecordSkipped(RecID: RecordID): Boolean
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
    begin
        if MasterDataMgtCoupling.FindByRecordID(RecID) then
            exit(MasterDataMgtCoupling.Skipped);
    end;

    internal procedure EnqueueFullSyncJob(Name: Code[20]): Guid
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        JobQueueEntry: Record "Job Queue Entry";
        MasterDataManagementSetupDefaults: Codeunit "Master Data Mgt. Setup Default";
        MasterDataManagement: Codeunit "Master Data Management";
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000JIP', MasterDataManagement.GetFeatureName(), Enum::"Feature Uptake Status"::Used);
        IntegrationTableMapping.Get(Name);
        IntegrationTableMapping."Full Sync is Running" := true;
        IntegrationTableMapping.CalcFields("Table Filter", "Integration Table Filter");
        AddIntegrationTableMapping(IntegrationTableMapping);
        Commit();
        if MasterDataManagementSetupDefaults.CreateJobQueueEntry(IntegrationTableMapping) then begin
            JobQueueEntry.SetRange("Record ID to Process", IntegrationTableMapping.RecordId);
            if JobQueueEntry.FindFirst() then
                exit(JobQueueEntry.ID);
        end;
    end;

    internal procedure EnqueueSyncJob(IntegrationTableMapping: Record "Integration Table Mapping"; SystemIds: List of [Guid]; IntegrationSystemIds: List of [Guid]; Direction: Integer; SynchronizeOnlyCoupledRecords: Boolean): Boolean
    var
        MasterDataManagementSetupDefault: Codeunit "Master Data Mgt. Setup Default";
        MasterDataManagement: Codeunit "Master Data Management";
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000JIQ', MasterDataManagement.GetFeatureName(), Enum::"Feature Uptake Status"::Used);
        IntegrationTableMapping.Direction := Direction;
        if Direction in [IntegrationTableMapping.Direction::Bidirectional, IntegrationTableMapping.Direction::FromIntegrationTable] then
            IntegrationTableMapping.SetIntegrationTableFilter(GetTableViewForIntegrationSystemIds(IntegrationTableMapping."Integration Table ID", IntegrationTableMapping."Integration Table UID Fld. No.", IntegrationSystemIds));
        if Direction in [IntegrationTableMapping.Direction::Bidirectional, IntegrationTableMapping.Direction::ToIntegrationTable] then
            IntegrationTableMapping.SetTableFilter(GetTableViewForSystemIds(IntegrationTableMapping."Table ID", SystemIds));
        AddIntegrationTableMapping(IntegrationTableMapping, SynchronizeOnlyCoupledRecords);
        Commit();
        exit(MasterDataManagementSetupDefault.CreateJobQueueEntry(IntegrationTableMapping));
    end;

    local procedure EnqueueUncoupleJob(IntegrationTableMapping: Record "Integration Table Mapping"; LocalTableFilter: Text; IntegrationTableFilter: Text): Boolean
    var
        MasterDataManagementSetupDefault: Codeunit "Master Data Mgt. Setup Default";
    begin
        IntegrationTableMapping.SetTableFilter(LocalTableFilter);
        IntegrationTableMapping.SetIntegrationTableFilter(IntegrationTableFilter);
        AddIntegrationTableMapping(IntegrationTableMapping);
        Commit();
        exit(MasterDataManagementSetupDefault.CreateUncoupleJobQueueEntry(IntegrationTableMapping));
    end;

    local procedure EnqueueCouplingJob(IntegrationTableMapping: Record "Integration Table Mapping"; LocalTableFilter: Text; IsFullSync: Boolean): Boolean
    var
        MasterDataManagementSetupDefaults: Codeunit "Master Data Mgt. Setup Default";
    begin
        if LocalTableFilter <> '' then
            IntegrationTableMapping.SetTableFilter(LocalTableFilter)
        else
            IntegrationTableMapping.CalcFields("Table Filter");
        IntegrationTableMapping.CalcFields("Integration Table Filter");
        IntegrationTableMapping."Full Sync is Running" := IsFullSync;
        AddIntegrationTableMapping(IntegrationTableMapping, true);

        Commit();
        exit(MasterDataManagementSetupDefaults.CreateCoupleJobQueueEntry(IntegrationTableMapping));
    end;

    internal procedure AddIntegrationTableMapping(var IntegrationTableMapping: Record "Integration Table Mapping")
    begin
        AddIntegrationTableMapping(IntegrationTableMapping, false);
    end;

    internal procedure AddIntegrationTableMapping(var IntegrationTableMapping: Record "Integration Table Mapping"; SynchOnlyCoupledRecords: Boolean)
    var
        SourceIntegrationTableMapping: Record "Integration Table Mapping";
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
        SourceMappingName: Code[20];
    begin
        SourceMappingName := IntegrationTableMapping.GetName();
        IntegrationTableMapping.Name := CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(IntegrationTableMapping.Name));
        IntegrationTableMapping."Synch. Only Coupled Records" := SynchOnlyCoupledRecords;
        IntegrationTableMapping."Delete After Synchronization" := true;
        IntegrationTableMapping."Parent Name" := SourceMappingName;
        SourceIntegrationTableMapping.Get(IntegrationTableMapping."Parent Name");
        IntegrationTableMapping."Update-Conflict Resolution" := SourceIntegrationTableMapping."Update-Conflict Resolution";
        IntegrationTableMapping."Deletion-Conflict Resolution" := SourceIntegrationTableMapping."Deletion-Conflict Resolution";
        Clear(IntegrationTableMapping."Synch. Modified On Filter");
        Clear(IntegrationTableMapping."Synch. Int. Tbl. Mod. On Fltr.");
        Clear(IntegrationTableMapping."Last Full Sync Start DateTime");
        IntegrationTableMapping.Insert();

        CRMIntegrationManagement.CloneIntegrationFieldMapping(SourceMappingName, IntegrationTableMapping.Name);
    end;

    local procedure GetTableViewForGuid(TableNo: Integer; IdFiledNo: Integer; IntegrationSystemId: Guid) View: Text
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        SourceCompanyName: Text[30];
    begin
        MasterDataManagementSetup.Get();
        RecordRef.Open(TableNo);
        OnSetSourceCompanyName(SourceCompanyName, TableNo);
        if SourceCompanyName = '' then
            SourceCompanyName := MasterDataManagementSetup."Company Name";
        RecordRef.ChangeCompany(SourceCompanyName);
        FieldRef := RecordRef.Field(IdFiledNo);
        FieldRef.SetRange(IntegrationSystemId);
        View := RecordRef.GetView();
        RecordRef.Close();
    end;

    local procedure GetTableViewForIntegrationSystemIds(TableNo: Integer; IdFiledNo: Integer; IntegrationSystemIds: List of [Guid]) View: Text
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        IntegrationRecordSynch: Codeunit "Integration Record Synch.";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        IntegrationSystemIdFilter: Text;
        SourceCompanyName: Text[30];
    begin
        MasterDataManagementSetup.Get();
        IntegrationSystemIdFilter := IntegrationRecordSynch.JoinIDs(IntegrationSystemIds, '|');
        RecordRef.Open(TableNo);
        OnSetSourceCompanyName(SourceCompanyName, TableNo);
        if SourceCompanyName = '' then
            SourceCompanyName := MasterDataManagementSetup."Company Name";
        RecordRef.ChangeCompany(SourceCompanyName);
        FieldRef := RecordRef.Field(IdFiledNo);
        FieldRef.SetFilter(IntegrationSystemIdFilter);
        View := RecordRef.GetView();
        RecordRef.Close();
    end;

    local procedure GetTableViewForSystemIds(TableNo: Integer; SystemIds: List of [Guid]) View: Text
    var
        IntegrationRecordSynch: Codeunit "Integration Record Synch.";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        SystemIdFilter: Text;
    begin
        SystemIdFilter := IntegrationRecordSynch.JoinIDs(SystemIds, '|');
        RecordRef.Open(TableNo);
        FieldRef := RecordRef.Field(RecordRef.SystemIdNo());
        FieldRef.SetFilter(SystemIdFilter);
        View := RecordRef.GetView();
        RecordRef.Close();
    end;

    local procedure GetCoupledIntegrationSystemId(RecordID: RecordID; var IntegrationSystemId: Guid): Boolean
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
    begin
        exit(MasterDataMgtCoupling.FindIDFromRecordID(RecordID, IntegrationSystemId))
    end;

    internal procedure ResetIntTableMappingDefaultConfiguration(var IntegrationTableMapping: Record "Integration Table Mapping")
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        JobQueueEntry: Record "Job Queue Entry";
        MasterDataManagementSetupDefaults: Codeunit "Master Data Mgt. Setup Default";
        EnqueueJobQueEntries: Boolean;
        IsHandled: Boolean;
        IsResettingCurrentMappingHandled: Boolean;
        ShouldScheduleJobQueueEntry: Boolean;
    begin
        if MasterDataManagementSetup.Get() then
            EnqueueJobQueEntries := (MasterDataManagementSetup."Is Enabled") and (not MasterDataManagementSetup."Delay Job Scheduling");

        if IntegrationTableMapping.FindSet() then
            repeat
                case IntegrationTableMapping."Table ID" of
                    Database::"Salesperson/Purchaser":
                        MasterDataManagementSetupDefaults.ResetSalesPeopleSystemUserMapping(IntegrationTableMapping.Name, EnqueueJobQueEntries);
                    Database::Customer:
                        MasterDataManagementSetupDefaults.ResetCustomerAccountMapping(IntegrationTableMapping.Name, EnqueueJobQueEntries);
                    Database::Vendor:
                        MasterDataManagementSetupDefaults.ResetVendorAccountMapping(IntegrationTableMapping.Name, EnqueueJobQueEntries);
                    Database::Contact:
                        MasterDataManagementSetupDefaults.ResetContactContactMapping(IntegrationTableMapping.Name, EnqueueJobQueEntries);
                    Database::Currency:
                        MasterDataManagementSetupDefaults.ResetCurrencyTransactionCurrencyMapping(IntegrationTableMapping.Name, EnqueueJobQueEntries);
                    Database::"Payment Terms":
                        MasterDataManagementSetupDefaults.ResetPaymentTermsMapping(IntegrationTableMapping.Name);
                    Database::"Shipment Method":
                        MasterDataManagementSetupDefaults.ResetShipmentMethodMapping(IntegrationTableMapping.Name);
                    Database::"Shipping Agent":
                        MasterDataManagementSetupDefaults.ResetShippingAgentMapping(IntegrationTableMapping.Name);
                    Database::"No. Series":
                        MasterDataManagementSetupDefaults.ResetNumberSeriesMapping(IntegrationTableMapping.Name, EnqueueJobQueEntries);
                    Database::"No. Series Line":
                        MasterDataManagementSetupDefaults.ResetNumberSeriesLineMapping(IntegrationTableMapping.Name, EnqueueJobQueEntries);
                    Database::"Sales & Receivables Setup":
                        MasterDataManagementSetupDefaults.ResetSalesReceivablesSetupMapping(IntegrationTableMapping.Name, EnqueueJobQueEntries);
                    Database::"Marketing Setup":
                        MasterDataManagementSetupDefaults.ResetMarketingSetupMapping(IntegrationTableMapping.Name, EnqueueJobQueEntries);
                    Database::"Purchases & Payables Setup":
                        MasterDataManagementSetupDefaults.ResetPurchasespayablesSetupMapping(IntegrationTableMapping.Name, EnqueueJobQueEntries);
                    Database::"Country/Region":
                        MasterDataManagementSetupDefaults.ResetCountryRegionMapping(IntegrationTableMapping.Name, EnqueueJobQueEntries);
                    Database::"Post Code":
                        MasterDataManagementSetupDefaults.ResetPostCodeMapping(IntegrationTableMapping.Name, EnqueueJobQueEntries);
                    Database::"Currency Exchange Rate":
                        MasterDataManagementSetupDefaults.ResetCurrencyExchangeRateMapping(IntegrationTableMapping.Name, EnqueueJobQueEntries);
                    Database::"VAT Business Posting Group":
                        MasterDataManagementSetupDefaults.ResetVATBusPostingGroupMapping(IntegrationTableMapping.Name, EnqueueJobQueEntries);
                    Database::"VAT Product Posting Group":
                        MasterDataManagementSetupDefaults.ResetVATProdPostingGroupMapping(IntegrationTableMapping.Name, EnqueueJobQueEntries);
                    Database::"Gen. Business Posting Group":
                        MasterDataManagementSetupDefaults.ResetGenBusPostingGroupMapping(IntegrationTableMapping.Name, EnqueueJobQueEntries);
                    Database::"Gen. Product Posting Group":
                        MasterDataManagementSetupDefaults.ResetGenProdPostingGroupMapping(IntegrationTableMapping.Name, EnqueueJobQueEntries);
                    Database::"Customer Posting Group":
                        MasterDataManagementSetupDefaults.ResetCustomerPostingGroupMapping(IntegrationTableMapping.Name, EnqueueJobQueEntries);
                    Database::"Vendor Posting Group":
                        MasterDataManagementSetupDefaults.ResetVendorPostingGroupMapping(IntegrationTableMapping.Name, EnqueueJobQueEntries);
                    Database::"Tax Area":
                        MasterDataManagementSetupDefaults.ResetTaxAreaMapping(IntegrationTableMapping.Name, EnqueueJobQueEntries);
                    Database::"Tax Group":
                        MasterDataManagementSetupDefaults.ResetTaxGroupMapping(IntegrationTableMapping.Name, EnqueueJobQueEntries);
                    Database::"G/L Account":
                        MasterDataManagementSetupDefaults.ResetGLAccountMapping(IntegrationTableMapping.Name, EnqueueJobQueEntries);
                    Database::"VAT Posting Setup":
                        MasterDataManagementSetupDefaults.ResetVATPostingSetupMapping(IntegrationTableMapping.Name, EnqueueJobQueEntries);
                    Database::"Tax Jurisdiction":
                        MasterDataManagementSetupDefaults.ResetTaxJurisdictionMapping(IntegrationTableMapping.Name, EnqueueJobQueEntries);
                    Database::Dimension:
                        MasterDataManagementSetupDefaults.ResetDimensionMapping(IntegrationTableMapping.Name, EnqueueJobQueEntries);
                    Database::"Dimension Value":
                        MasterDataManagementSetupDefaults.ResetDimensionValueMapping(IntegrationTableMapping.Name, EnqueueJobQueEntries);
                    else begin
                        ShouldScheduleJobQueueEntry := true;
                        IsResettingCurrentMappingHandled := false;
                        OnBeforeHandleCustomIntegrationTableMapping(IsHandled, IntegrationTableMapping.Name);
                        MasterDataManagementSetupDefaults.OnBeforeResetTableMapping(IntegrationTableMapping.Name, ShouldScheduleJobQueueEntry, IsResettingCurrentMappingHandled);
                        if (not IsHandled) and (not IsResettingCurrentMappingHandled) then begin
                            if Confirm(ResetAllCustomIntegrationTableMappingsLbl) then
                                if MasterDataManagementSetup.Get() then
                                    MasterDataManagementSetupDefaults.SetCustomIntegrationsTableMappings(MasterDataManagementSetup);
                            IsHandled := true;
                        end;
                        if ShouldScheduleJobQueueEntry and EnqueueJobQueEntries then begin
                            JobQueueEntry.ReadIsolation := IsolationLevel::ReadCommitted;
                            JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
                            JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Integration Synch. Job Runner");
                            JobQueueEntry.SetRange("Record ID to Process", IntegrationTableMapping.RecordId());
                            if JobQueueEntry.IsEmpty() then
                                MasterDataManagementSetupDefaults.RecreateJobQueueEntryFromIntTableMapping(IntegrationTableMapping, 1, ShouldScheduleJobQueueEntry, 30);
                        end;
                    end;
                end;
            until IntegrationTableMapping.Next() = 0;
    end;

    local procedure GetSelectedMultipleSyncDirection(IntegrationTableMapping: Record "Integration Table Mapping"): Integer
    var
        SynchronizeNowQuestion: Text;
        AllowedDirection: Integer;
        RecommendedDirection: Integer;
        SelectedDirection: Integer;
        IsHandled: Boolean;
    begin
        AllowedDirection := IntegrationTableMapping.Direction;
        RecommendedDirection := AllowedDirection;
        case AllowedDirection of
            IntegrationTableMapping.Direction::Bidirectional:
                begin
                    SelectedDirection := StrMenu(UpdateNowUniDirectionQst, RecommendedDirection, UpdateMultipleNowTitleTxt);
                    if SelectedDirection = 0 then
                        SelectedDirection := -1;
                    exit(SelectedDirection);
                end;
            IntegrationTableMapping.Direction::FromIntegrationTable:
                SynchronizeNowQuestion := StrSubstNo(UpdateMultipleNowFromIntegrationQst, ProductName.Short());
            else
                SynchronizeNowQuestion := StrSubstNo(UpdateMultipleNowToIntegrationQst, ProductName.Short());
        end;

        IsHandled := false;
        OnBeforeSynchronyzeNowQuestion(AllowedDirection, IsHandled);
        if IsHandled then
            exit(AllowedDirection);

        if Confirm(SynchronizeNowQuestion, true) then
            exit(AllowedDirection);
        exit(-1); // user canceled the process
    end;

    local procedure GetSelectedSingleSyncDirection(IntegrationTableMapping: Record "Integration Table Mapping"; RecordRef: RecordRef; IntegrationSystemId: Guid; var RecommendedDirectionIgnored: Boolean): Integer
    var
        IntegrationRecSynchInvoke: Codeunit "Integration Rec. Synch. Invoke";
        IntegrationTableSynch: Codeunit "Integration Table Synch.";
        IntegrationRecordRef: RecordRef;
        RecordIDDescr: Text;
        SynchronizeNowQuestion: Text;
        AllowedDirection: Integer;
        RecommendedDirection: Integer;
        SelectedDirection: Integer;
        RecordModified: Boolean;
        IntegrationRecordModified: Boolean;
        BothModified: Boolean;
        DefaultAnswer: Boolean;
        FieldsModified: Boolean;
        BidirectionalFieldsModified: Boolean;
    begin
        AllowedDirection := IntegrationTableMapping.Direction;

        // Determine which sides were modified since last synch
        IntegrationTableMapping.GetRecordRef(IntegrationSystemId, IntegrationRecordRef);
        RecordModified := IntegrationRecSynchInvoke.WasModifiedAfterLastSynch(IntegrationTableMapping, RecordRef);
        IntegrationRecordModified := IntegrationRecSynchInvoke.WasModifiedAfterLastSynch(IntegrationTableMapping, IntegrationRecordRef);
        BothModified := RecordModified and IntegrationRecordModified;
        RecordIDDescr := Format(RecordRef.RecordId, 0, 1);
        if BothModified then
            // Changes on both sides. Bidirectional: warn user. Unidirectional: confirm and exit.
            case AllowedDirection of
                IntegrationTableMapping.Direction::Bidirectional:
                    begin
                        IntegrationTableSynch.CheckTransferFields(IntegrationTableMapping, RecordRef, IntegrationRecordRef, FieldsModified, BidirectionalFieldsModified);
                        if BidirectionalFieldsModified then
                            Message(BothRecordsModifiedBiDirectionalConflictMsg, RecordRef.Caption, IntegrationRecordRef.Caption, ProductName.Short())
                        else begin
                            if not FieldsModified then
                                IntegrationTableSynch.CheckTransferFields(IntegrationTableMapping, IntegrationRecordRef, RecordRef, FieldsModified, BidirectionalFieldsModified);
                            if FieldsModified then
                                Message(BothRecordsModifiedBiDirectionalNoConflictMsg, RecordRef.Caption, IntegrationRecordRef.Caption, ProductName.Short());
                        end;
                    end;
                IntegrationTableMapping.Direction::ToIntegrationTable:
                    begin
                        IntegrationTableSynch.CheckTransferFields(IntegrationTableMapping, RecordRef, IntegrationRecordRef, FieldsModified, BidirectionalFieldsModified);
                        if not FieldsModified then
                            exit(AllowedDirection);
                        if Confirm(BothRecordsModifiedToIntegrationQst, false, RecordIDDescr, IntegrationRecordRef.Caption, PRODUCTNAME.Short(), ProductName.Short()) then
                            exit(AllowedDirection);
                        exit(-1);
                    end;
                IntegrationTableMapping.Direction::FromIntegrationTable:
                    begin
                        IntegrationTableSynch.CheckTransferFields(IntegrationTableMapping, IntegrationRecordRef, RecordRef, FieldsModified, BidirectionalFieldsModified);
                        if not FieldsModified then
                            exit(AllowedDirection);
                        if Confirm(BothRecordsModifiedToNAVQst, false, RecordIDDescr, IntegrationRecordRef.Caption, PRODUCTNAME.Short(), ProductName.Short()) then
                            exit(AllowedDirection);
                        exit(-1);
                    end;
            end;

        // Zero or one side changed. Synch for zero too because dependent objects could have changed.
        case AllowedDirection of
            IntegrationTableMapping.Direction::Bidirectional:
                begin
                    if BothModified and BidirectionalFieldsModified then begin
                        RecommendedDirection := IntegrationTableMapping.Direction::ToIntegrationTable;
                        SelectedDirection := StrMenu(UpdateNowUniDirectionQst, RecommendedDirection, StrSubstNo(UpdateOneNowTitleTxt, RecordIDDescr));
                        if SelectedDirection = 0 then
                            SelectedDirection := -1;
                    end else begin
                        if RecordModified = IntegrationRecordModified then
                            RecommendedDirection := IntegrationTableMapping.Direction::Bidirectional
                        else
                            if IntegrationRecordModified then
                                RecommendedDirection := IntegrationTableMapping.Direction::FromIntegrationTable
                            else
                                RecommendedDirection := IntegrationTableMapping.Direction::ToIntegrationTable;
                        SelectedDirection := StrMenu(UpdateNowBiDirectionQst, RecommendedDirection, StrSubstNo(UpdateOneNowTitleTxt, RecordIDDescr));
                        case SelectedDirection of
                            0:
                                SelectedDirection := -1;
                            3:
                                SelectedDirection := IntegrationTableMapping.Direction::Bidirectional;
                        end;
                    end;
                    RecommendedDirectionIgnored := SelectedDirection <> RecommendedDirection;
                    exit(SelectedDirection);
                end;
            IntegrationTableMapping.Direction::FromIntegrationTable:
                if RecordModified then
                    SynchronizeNowQuestion := StrSubstNo(UpdateOneNowFromOldIntegrationQst, RecordIDDescr, PRODUCTNAME.Short(), ProductName.Short())
                else begin
                    SynchronizeNowQuestion := StrSubstNo(UpdateOneNowFromIntegrationQst, RecordIDDescr, ProductName.Short());
                    DefaultAnswer := true;
                end;
            else
                if IntegrationRecordModified then
                    SynchronizeNowQuestion := StrSubstNo(UpdateOneNowToModifiedIntegrationQst, RecordIDDescr, PRODUCTNAME.Short(), ProductName.Short())
                else begin
                    SynchronizeNowQuestion := StrSubstNo(UpdateOneNowToIntegrationQst, RecordIDDescr, ProductName.Short());
                    DefaultAnswer := true;
                end;
        end;

        if Confirm(SynchronizeNowQuestion, DefaultAnswer) then
            exit(AllowedDirection);

        exit(-1); // user canceled the process
    end;

    local procedure DeleteIntegrationRecordByBCID(var BCRecordRef: RecordRef)
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
    begin
        if MasterDataMgtCoupling.FindByRecordID(BCRecordRef.RecordId()) then begin
            MasterDataMgtCoupling.Delete();
            Commit();
        end;
    end;

    local procedure DeleteIntegrationRecordByIntegrationSystemId(var IntegrationRecordRef: RecordRef; var IntegrationTableMapping: Record "Integration Table Mapping")
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        IntegrationSystemId: Guid;
    begin
        IntegrationSystemId := IntegrationRecordRef.Field(IntegrationTableMapping."Integration Table UID Fld. No.").Value();
        if MasterDataMgtCoupling.FindByIntegrationSystemId(IntegrationSystemId) then begin
            MasterDataMgtCoupling.Delete();
            Commit();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnDeletionConflictDetected', '', false, false)]
    local procedure HandleOnDeletionConflictDetected(var IntegrationTableMapping: Record "Integration Table Mapping"; var SourceRecordRef: RecordRef; var DeletionConflictHandled: Boolean)
    var
        IntegrationSystemId: Guid;
    begin
        if DeletionConflictHandled then
            exit;

        if not IsEnabled() then
            exit;

        case IntegrationTableMapping."Deletion-Conflict Resolution" of
            IntegrationTableMapping."Deletion-Conflict Resolution"::"Remove Coupling":
                begin
                    if SourceRecordRef.Number = IntegrationTableMapping."Table ID" then
                        DeletionConflictHandled := RemoveCoupling(SourceRecordRef.RecordId(), false)
                    else begin
                        IntegrationSystemId := SourceRecordRef.Field(IntegrationTableMapping."Integration Table UID Fld. No.").Value();
                        DeletionConflictHandled := RemoveCoupling(IntegrationTableMapping."Table ID", IntegrationTableMapping."Integration Table ID", IntegrationSystemId, false);
                    end;

                    if DeletionConflictHandled then
                        Session.LogMessage('0000J88', DeletionConflictHandledRemoveCouplingTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                end;
            IntegrationTableMapping."Deletion-Conflict Resolution"::"Restore Records":
                begin
                    if SourceRecordRef.Number = IntegrationTableMapping."Table ID" then
                        DeleteIntegrationRecordByBCID(SourceRecordRef)
                    else
                        DeleteIntegrationRecordByIntegrationSystemId(SourceRecordRef, IntegrationTableMapping);

                    DeletionConflictHandled := true;
                    Session.LogMessage('0000J89', DeletionConflictHandledRestoreRecordTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"My Notifications", 'OnInitializingNotificationWithDefaultState', '', false, false)]
    local procedure OnInitializingNotificationWithDefaultState();
    var
        MyNotifications: Record "My Notifications";
    begin
        MyNotifications.InsertDefault(GetCommonNotificationID(), CommonNotificationNameTxt, CommonNotificationDescriptionTxt, true);
    end;

    internal procedure DisableNotification(HostNotification: Notification)
    var
        MyNotifications: Record "My Notifications";
        NotificationId: Text;
    begin
        NotificationId := HostNotification.GetData('NotificationId');
        if not MyNotifications.Disable(NotificationId) then
            MyNotifications.InsertDefault(NotificationId, GetNotificationName(NotificationId), GetNotificationDescription(NotificationId), false);
        Session.LogMessage('0000J8A', StrSubstNo(UserDisabledNotificationTxt, GetNotificationName(NotificationId)), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
    end;

    local procedure GetNotificationName(NotificationId: Guid): Text[128];
    begin
        case NotificationId of
            GetCommonNotificationID():
                exit(CommonNotificationNameTxt);
        end;
        exit('');
    end;

    local procedure GetNotificationDescription(NotificationId: Guid): Text;
    begin
        case NotificationId of
            GetCommonNotificationID():
                exit(CommonNotificationDescriptionTxt);
        end;
        exit('');
    end;

    internal procedure GetCommonNotificationID(): Guid
    begin
        exit('CA993340-70CE-4089-943A-00736896D2A4');
    end;

    local procedure SendSyncNotification(RecordCounter: array[4] of Integer): Boolean
    begin
        if RecordCounter[NoOf::Total] = 1 then begin
            if RecordCounter[NoOf::Scheduled] = 1 then
                exit(SendNotification(SyncNowScheduledMsg));
            if RecordCounter[NoOf::Skipped] = 1 then
                exit(SendNotification(SyncNowSkippedMsg));
            exit(SendNotification(SyncNowFailedMsg));
        end;
        exit(SendMultipleSyncNotification(RecordCounter));
    end;

    local procedure SendMultipleSyncNotification(RecordCounter: array[4] of Integer): Boolean
    begin
        exit(
          SendNotification(
            StrSubstNo(
              SyncMultipleMsg,
              RecordCounter[NoOf::Scheduled], RecordCounter[NoOf::Failed],
              RecordCounter[NoOf::Skipped], RecordCounter[NoOf::Total])));
    end;

    local procedure SendUncoupleNotification(RecordCounter: array[4] of Integer): Boolean
    begin
        if RecordCounter[NoOf::Total] = 1 then begin
            if RecordCounter[NoOf::Scheduled] = 1 then
                exit(SendNotification(UncoupleScheduledMsg));
            if RecordCounter[NoOf::Skipped] = 1 then
                exit(SendNotification(UncoupleSkippedMsg));
            exit(SendNotification(UncoupleFailedMsg));
        end;
        exit(SendMultipleUncoupleNotification(RecordCounter));
    end;

    local procedure SendCouplingNotification(RecordCounter: array[4] of Integer): Boolean
    begin
        if RecordCounter[NoOf::Total] = 1 then begin
            if RecordCounter[NoOf::Scheduled] = 1 then
                exit(SendNotification(CouplingScheduledMsg));
            if RecordCounter[NoOf::Skipped] = 1 then
                exit(SendNotification(CouplingSkippedMsg));
            exit(SendNotification(CouplingFailedMsg));
        end;
        exit(SendMultipleCouplingNotification(RecordCounter));
    end;

    local procedure SendMultipleUncoupleNotification(RecordCounter: array[4] of Integer): Boolean
    begin
        exit(
          SendNotification(
            StrSubstNo(
              UncoupleMultipleMsg,
              RecordCounter[NoOf::Scheduled], RecordCounter[NoOf::Failed],
              RecordCounter[NoOf::Skipped], RecordCounter[NoOf::Total])));
    end;

    local procedure SendMultipleCouplingNotification(RecordCounter: array[4] of Integer): Boolean
    begin
        exit(
          SendNotification(
            StrSubstNo(
              CouplingMultipleMsg,
              RecordCounter[NoOf::Scheduled], RecordCounter[NoOf::Failed],
              RecordCounter[NoOf::Skipped], RecordCounter[NoOf::Total])));
    end;

    local procedure SendNotification(Msg: Text): Boolean
    var
        MyNotifications: Record "My Notifications";
        SyncNotification: Notification;
    begin
        if not MyNotifications.IsEnabled(GetCommonNotificationID()) then
            exit;

        SyncNotification.Id := GetCommonNotificationID();
        SyncNotification.Recall();
        SyncNotification.Message(Msg);
        SyncNotification.Scope(NOTIFICATIONSCOPE::LocalScope);
        SyncNotification.AddAction(DetailsTxt, Codeunit::"Master Data Management", 'OpenIntegrationSynchronizationJobsFromNotification');
        SyncNotification.SetData('NotificationId', GetCommonNotificationID());
        SyncNotification.AddAction(DisableNotificationTxt, Codeunit::"Master Data Management", 'DisableNotification');
        SyncNotification.Send();
        exit(true);
    end;

    internal procedure OpenIntegrationSynchronizationJobsFromNotification(HostNotification: Notification)
    var
        IntegrationSynchJobList: Page "Integration Synch. Job List";
    begin
        IntegrationSynchJobList.Run();
        Session.LogMessage('0000J8B', UserOpenedIntegrationSynchJobListViaNotificationTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Integration Synch. Job Errors", 'OnIsDataIntegrationEnabled', '', false, false)]
    local procedure HandleOnIsDataIntegrationEnabled(var IsIntegrationEnabled: Boolean)
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
    begin
        if IsIntegrationEnabled then
            exit;

        if MasterDataManagementSetup.Get() then
            IsIntegrationEnabled := MasterDataManagementSetup."Is Enabled";
    end;

    local procedure IsDataIntegrationEnabled(var IsIntegrationEnabled: Boolean)
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
    begin
        if MasterDataManagementSetup.Get() then
            IsIntegrationEnabled := MasterDataManagementSetup."Is Enabled";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Integration Synch. Job Errors", 'OnForceSynchronizeDataIntegration', '', false, false)]
    local procedure ForceSynchronizeDataIntegration(LocalRecordID: RecordID; var SynchronizeHandled: Boolean)
    var
        Enabled: Boolean;
    begin
        if SynchronizeHandled then
            exit;

        IsDataIntegrationEnabled(Enabled);

        if not Enabled then
            exit;

        UpdateOneNow(LocalRecordID);
        SynchronizeHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Integration Synch. Job Errors", 'OnForceSynchronizeRecords', '', false, false)]
    local procedure ForceSynchronizeRecords(var LocalRecordIdList: List of [RecordId]; var SynchronizeHandled: Boolean)
    var
        SelectedMasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        LocalRecordId: RecordId;
        Enabled: Boolean;
    begin
        if SynchronizeHandled then
            exit;

        IsDataIntegrationEnabled(Enabled);

        if not Enabled then
            exit;

        foreach LocalRecordId in LocalRecordIdList do
            if MasterDataMgtCoupling.FindByRecordID(LocalRecordId) then begin
                SelectedMasterDataMgtCoupling."Integration System ID" := MasterDataMgtCoupling."Integration System ID";
                SelectedMasterDataMgtCoupling."Local System ID" := MasterDataMgtCoupling."Local System ID";
                if SelectedMasterDataMgtCoupling.Find() then
                    SelectedMasterDataMgtCoupling.Mark(true);
            end;

        SelectedMasterDataMgtCoupling.MarkedOnly(true);
        UpdateMultipleNow(SelectedMasterDataMgtCoupling);
        SynchronizeHandled := true;
    end;

    internal procedure IsEventDrivenReschedulingDisabled(TableID: Integer; CompanyName: Text[30]): Boolean
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        isEvtDrivenReschedulingDisabled: Boolean;
        DictionaryKey: Text;
    begin
        DictionaryKey := CompanyName + '.' + Format(TableID);
        if CachedDisableEventDrivenSynchJobReschedule.ContainsKey(DictionaryKey) then
            exit(CachedDisableEventDrivenSynchJobReschedule.Get(DictionaryKey));

        IntegrationTableMapping.ChangeCompany(CompanyName);
        IntegrationTableMapping.ReadIsolation := IsolationLevel::ReadUncommitted;
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        IntegrationTableMapping.SetRange(Status, IntegrationTableMapping.Status::Enabled);
        if IntegrationTableMapping.FindMappingForTable(TableID) then
            isEvtDrivenReschedulingDisabled := IntegrationTableMapping."Disable Event Job Resch."
        else
            isEvtDrivenReschedulingDisabled := true;

        if not CachedDisableEventDrivenSynchJobReschedule.ContainsKey(DictionaryKey) then
            if not CachedDisableEventDrivenSynchJobReschedule.Add(DictionaryKey, isEvtDrivenReschedulingDisabled) then
                exit(isEvtDrivenReschedulingDisabled);
        exit(isEvtDrivenReschedulingDisabled);
    end;

    internal procedure IsDataSynchRecord(TableID: Integer; CompanyName: Text[30]): Boolean
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        isIntegrationRecord: Boolean;
        DictionaryKey: Text;
    begin
        DictionaryKey := CompanyName + '.' + Format(TableID);
        if CachedIsSynchronizationRecord.ContainsKey(DictionaryKey) then
            exit(CachedIsSynchronizationRecord.Get(DictionaryKey));

        // this is the new event that partners who have integration to custom entities should subscribe to
        OnIsDataSynchRecord(TableID, isIntegrationRecord);
        if not isIntegrationRecord then begin
            IntegrationTableMapping.ChangeCompany(CompanyName);
            IntegrationTableMapping.ReadIsolation := IsolationLevel::ReadUncommitted;
            IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
            IntegrationTableMapping.SetRange(Status, IntegrationTableMapping.Status::Enabled);
            isIntegrationRecord := IntegrationTableMapping.DoesExistForTable(TableID);
        end;

        CachedIsSynchronizationRecord.Add(DictionaryKey, isIntegrationRecord);
        exit(isIntegrationRecord);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, 'OnAfterGetDatabaseTableTriggerSetup', '', false, false)]
    local procedure HandleOnAfterGetDatabaseTableTriggerSetup(TableId: Integer; var OnDatabaseInsert: Boolean; var OnDatabaseModify: Boolean; var OnDatabaseDelete: Boolean; var OnDatabaseRename: Boolean)
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        MasterDataMgtSubscriber: Record "Master Data Mgt. Subscriber";
        Enabled: Boolean;
    begin
        if not MasterDataMgtSubscriber.ReadPermission() then
            exit;

        if GetExecutionContext() = ExecutionContext::Upgrade then
            exit;

        if (OnDatabaseInsert and OnDatabaseModify and OnDatabaseRename) then
            exit;

        if CompanyName() = '' then
            exit;

        OnEnabledDatabaseTriggersSetup(TableId, Enabled);
        if not Enabled then
            if MasterDataMgtSubscriber.FindSet() then
                repeat
                    if MasterDataManagementSetup.ChangeCompany(MasterDataMgtSubscriber."Company Name") then
                        if MasterDataManagementSetup.ReadPermission() then
                            if MasterDataManagementSetup.Get() then
                                if MasterDataManagementSetup."Is Enabled" then
                                    Enabled := IsDataSynchRecord(TableId, MasterDataMgtSubscriber."Company Name");
                until (MasterDataMgtSubscriber.Next() = 0) or Enabled;

        if Enabled then begin
            OnDatabaseInsert := true;
            OnDatabaseModify := true;
            OnDatabaseRename := true;
            if not OnDatabaseDelete then
                OnDatabaseDelete := false;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, 'OnAfterOnDatabaseInsert', '', false, false)]
    local procedure HandleOnAfterOnDatabaseInsert(RecRef: RecordRef)
    begin
        ReactivateJobForTable(RecRef.Number);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, 'OnAfterOnDatabaseModify', '', false, false)]
    local procedure HandleOnDatabaseModify(RecRef: RecordRef)
    begin
        ReactivateJobForTable(RecRef.Number);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, 'OnAfterOnDatabaseRename', '', false, false)]
    local procedure HandleOnDatabaseRename(RecRef: RecordRef; XRecRef: RecordRef)
    begin
        ReactivateJobForTable(RecRef.Number);
    end;

    internal procedure ReactivateJobForTable(TableNo: Integer)
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        MasterDataMgtSubscriber: Record "Master Data Mgt. Subscriber";
        JobQueueEntry: Record "Job Queue Entry";
        ScheduledTask: Record "Scheduled Task";
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
        NewEarliestStartDateTime: DateTime;
        ShouldReactivateJob: Boolean;
        CurrentCompanyName: Text;
    begin
        if not MasterDataMgtSubscriber.ReadPermission() then
            exit;

        if not MasterDataMgtSubscriber.FindSet() then
            exit;

        CurrentCompanyName := CompanyName();
        repeat
            if MasterDataManagementSetup.ChangeCompany(MasterDataMgtSubscriber."Company Name") then begin
                JobQueueEntry.ChangeCompany(MasterDataMgtSubscriber."Company Name");
                if MasterDataManagementSetup.Get() then
                    ShouldReactivateJob := MasterDataManagementSetup."Is Enabled" and (MasterDataManagementSetup."Company Name" = CurrentCompanyName)
                else
                    ShouldReactivateJob := false;

                if ShouldReactivateJob then
                    if IsDataSynchRecord(TableNo, MasterDataMgtSubscriber."Company Name") then
                        if not IsEventDrivenReschedulingDisabled(TableNo, MasterDataMgtSubscriber."Company Name") then
                            if not DataUpgradeMgt.IsUpgradeInProgress() then begin
                                JobQueueEntry.Reset();
                                JobQueueEntry.ReadIsolation := IsolationLevel::ReadUncommitted;
                                JobQueueEntry.SetFilter(Status, Format(JobQueueEntry.Status::Ready) + '|' + Format(JobQueueEntry.Status::"On Hold with Inactivity Timeout"));
                                JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
                                JobQueueEntry.SetFilter("Object ID to Run", '%1|%2|%3', Codeunit::"Integration Synch. Job Runner", Codeunit::"Int. Coupling Job Runner", Codeunit::"Int. Uncouple Job Runner");
                                JobQueueEntry.SetRange("Recurring Job", true);
                                if UserCanRescheduleJob() then
                                    if JobQueueEntry.FindSet() then
                                        repeat
                                            // The rescheduled task might start while the current transaction is not committed yet.
                                            // Therefore the task will restart with a delay to lower a risk of use of "old" data.
                                            ScheduledTask.ReadIsolation := IsolationLevel::ReadUncommitted;
                                            NewEarliestStartDateTime := CurrentDateTime() + 2000;
                                            if ScheduledTask.Get(JobQueueEntry."System Task ID") then
                                                if (NewEarliestStartDateTime + 5000) < ScheduledTask."Not Before" then
                                                    if DoesJobActOnTable(JobQueueEntry, TableNo, MasterDataMgtSubscriber."Company Name") then
                                                        if TaskScheduler.SetTaskReady(ScheduledTask.ID, NewEarliestStartDateTime) then
                                                            if JobQueueEntry.Find() then begin
                                                                JobQueueEntry.RefreshLocked();
                                                                JobQueueEntry.Status := JobQueueEntry.Status::Ready;
                                                                JobQueueEntry."Earliest Start Date/Time" := NewEarliestStartDateTime;
                                                                JobQueueEntry.Modify();
                                                                Session.LogMessage('0000JB1', StrSubstNo(RescheduledTaskTxt, Format(ScheduledTask.ID), Format(JobQueueEntry.ID), JobQueueEntry.Description, Format(NewEarliestStartDateTime)), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                                                            end;
                                        until JobQueueEntry.Next() = 0;
                            end
            end
        until MasterDataMgtSubscriber.Next() = 0;
    end;

    local procedure DoesJobActOnTable(var JobQueueEntry: Record "Job Queue Entry"; TableNo: Integer; CompanyName: Text[30]): Boolean
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        RecRef: RecordRef;
    begin
        if not TryOpen(RecRef, DATABASE::"Integration Table Mapping") then
            exit(false);

        if not RecRef.ChangeCompany(CompanyName) then
            exit(false);

        IntegrationTableMapping.ChangeCompany(CompanyName);
        if RecRef.Get(JobQueueEntry."Record ID to Process") and
           (RecRef.Number = DATABASE::"Integration Table Mapping")
        then begin
            RecRef.SetTable(IntegrationTableMapping);
            exit(IntegrationTableMapping."Table ID" = TableNo);
        end;
    end;

    internal procedure UserCanRescheduleJob(): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
        DummyErrorMessageRegister: Record "Error Message Register";
        DummyErrorMessage: Record "Error Message";
    begin
        if not JobQueueEntry.ReadPermission then
            exit(false);
        if not JobQueueEntry.WritePermission then
            exit(false);
        if not DummyErrorMessageRegister.WritePermission then
            exit(false);
        if not DummyErrorMessage.WritePermission then
            exit(false);
        if not TaskScheduler.CanCreateTask() then
            exit(false);
        exit(true);
    end;

    [TryFunction]
    local procedure TryOpen(var RecRef: RecordRef; TableId: Integer)
    begin
        RecRef.Open(TableId);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Record Management", 'OnIsIntegrationRecordSkipped', '', false, false)]
    local procedure HandleOnIsIntegrationRecordSkipped(IntegrationTableConnectionType: TableConnectionType; var SourceRecRef: RecordRef; DirectionToIntTable: Boolean; var IsSkipped: Boolean; var IsHandled: Boolean)
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        MasterDataManagement: Codeunit "Master Data Management";
        Found: Boolean;
    begin
        if IntegrationTableConnectionType <> IntegrationTableConnectionType::ExternalSQL then
            exit;

        if not IsEnabled() then
            exit;

        if DirectionToIntTable then
            Found := MasterDataMgtCoupling.FindByRecordID(SourceRecRef.RecordId())
        else
            Found := MasterDataMgtCoupling.FindByIntegrationSystemID(MasterDataManagement.GetIntegrationSystemIdFromRecRef(SourceRecRef));

        if Found then
            IsSkipped := MasterDataMgtCoupling.Skipped;
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnUpdateIntegrationRecordTimestamp', '', false, false)]
    local procedure HandleOnUpdateIntegrationRecordTimestamp(IntegrationTableMapping: Record "Integration Table Mapping"; var SourceRecordRef: RecordRef; var DestinationRecordRef: RecordRef; IntegrationTableConnectionType: TableConnectionType; JobID: Guid; BothModified: Boolean; var IsHandled: Boolean)
    var
        IntegrationRecordManagement: Codeunit "Integration Record Management";
        IntegrationTableSynch: Codeunit "Integration Table Synch.";
        MasterDataMgtSubscribers: Codeunit "Master Data Mgt. Subscribers";
        LocalRecordRef: RecordRef;
        IntegrationTableUidFieldRef: FieldRef;
        IntegrationTableUid: Variant;
        IntegrationTableModifiedOn: DateTime;
        LocalTableModifiedOn: DateTime;
    begin
        if IntegrationTableConnectionType <> IntegrationTableConnectionType::ExternalSQL then
            exit;

        if not IsEnabled() then
            exit;

        IntegrationTableUidFieldRef := SourceRecordRef.Field(IntegrationTableMapping."Integration Table UID Fld. No.");
        IntegrationTableUid := IntegrationTableUidFieldRef.Value();
        IntegrationTableModifiedOn := MasterDataMgtSubscribers.GetRowLastModifiedOn(IntegrationTableMapping, SourceRecordRef);
        LocalTableModifiedOn := IntegrationTableSynch.GetRowLastModifiedOn(IntegrationTableMapping, DestinationRecordRef);

        IntegrationRecordManagement.UpdateIntegrationTableTimestamp(
          IntegrationTableConnectionType, IntegrationTableUid, IntegrationTableModifiedOn,
          LocalRecordRef.Number(), LocalTableModifiedOn, JobID, IntegrationTableMapping.Direction);
        Commit();

        IsHandled := true;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Record Management", 'OnUpdateIntegrationTableTimestamp', '', false, false)]
    local procedure HandleOnUpdateIntegrationTableTimestamp(IntegrationTableConnectionType: TableConnectionType; IntegrationTableUid: Variant; IntegrationTableModfiedOn: DateTime; TableID: Integer; ModifiedOn: DateTime; JobID: Guid; Direction: Option; var IsHandled: Boolean)
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        IntegrationTableMapping: Record "Integration Table Mapping";
    begin
        if IntegrationTableConnectionType <> IntegrationTableConnectionType::ExternalSQL then
            exit;

        if not IsEnabled() then
            exit;

        if not MasterDataMgtCoupling.FindRowFromIntegrationSystemID(IntegrationTableUid, TableID, MasterDataMgtCoupling) then begin
            IsHandled := true;
            exit;
        end;

        case Direction of
            IntegrationTableMapping.Direction::FromIntegrationTable:
                begin
                    MasterDataMgtCoupling."Last Synch. Job ID" := JobId;
                    MasterDataMgtCoupling."Last Synch. Result" := MasterDataMgtCoupling."Last Synch. Result"::Success;
                end;
            IntegrationTableMapping.Direction::ToIntegrationTable:
                begin
                    MasterDataMgtCoupling."Last Synch. Int. Job ID" := JobId;
                    MasterDataMgtCoupling."Last Synch. Int. Result" := MasterDataMgtCoupling."Last Synch. Int. Result"::Success;
                end;
        end;
        if ModifiedOn > MasterDataMgtCoupling."Last Synch. Modified On" then
            MasterDataMgtCoupling."Last Synch. Modified On" := ModifiedOn;
        if IntegrationTableModfiedOn > MasterDataMgtCoupling."Last Synch. Int. Modified On" then
            MasterDataMgtCoupling."Last Synch. Int. Modified On" := IntegrationTableModfiedOn;
        MasterDataMgtCoupling.Modify(true);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Record Management", 'OnIsRecordModifiedAfterRecordLastSynch', '', false, false)]
    local procedure HandleOnIsRecordModifiedAfterRecordLastSynch(IntegrationTableConnectionType: TableConnectionType; var SourceRecordId: RecordID; LastModifiedOn: DateTime; var IsModified: Boolean; var IsHandled: Boolean)
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        TypeHelper: Codeunit "Type Helper";
    begin
        if IntegrationTableConnectionType <> IntegrationTableConnectionType::ExternalSQL then
            exit;

        if not IsEnabled() then
            exit;

        if MasterDataMgtCoupling.FindRowFromRecordID(SourceRecordId, MasterDataMgtCoupling) then begin
            if (MasterDataMgtCoupling."Last Synch. Int. Result" = MasterDataMgtCoupling."Last Synch. Int. Result"::Failure) and (MasterDataMgtCoupling.Skipped = false) then
                IsModified := true
            else
                IsModified := TypeHelper.CompareDateTime(LastModifiedOn, MasterDataMgtCoupling."Last Synch. Modified On") > 0;
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Record Management", 'OnIsRecordRefModifiedAfterRecordLastSynch', '', false, false)]
    local procedure HandleOnIsRecordRefModifiedAfterRecordLastSynch(IntegrationTableConnectionType: TableConnectionType; var SourceRecordRef: RecordRef; LastModifiedOn: DateTime; var IsModified: Boolean; var IsHandled: Boolean)
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        IntegrationTableMapping: Record "Integration Table Mapping";
        TypeHelper: Codeunit "Type Helper";
        DateToCompareWith: DateTime;
    begin
        if IntegrationTableConnectionType <> IntegrationTableConnectionType::ExternalSQL then
            exit;

        if not IsEnabled() then
            exit;

        OnIsRecordRefModifiedAfterRecordLastSynch(SourceRecordRef, LastModifiedOn, IsModified, IsHandled);
        if IsHandled then
            exit;

        if MasterDataMgtCoupling.FindRowFromRecordRef(SourceRecordRef, MasterDataMgtCoupling) then begin
            if (MasterDataMgtCoupling."Last Synch. Int. Result" = MasterDataMgtCoupling."Last Synch. Int. Result"::Failure) and (MasterDataMgtCoupling.Skipped = false) then begin
                IsModified := true;
                IsHandled := true;
                exit;
            end;
            DateToCompareWith := MasterDataMgtCoupling."Last Synch. Modified On";
            IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
            IntegrationTableMapping.SetRange("Delete After Synchronization", false);
            IntegrationTableMapping.SetRange("Table ID", SourceRecordRef.Number());
            IntegrationTableMapping.SetRange("Integration Table ID", SourceRecordRef.Number());
            if IntegrationTableMapping.FindFirst() then begin
                if IntegrationTableMapping."Synch. Modified On Filter" = 0DT then begin
                    IsModified := true;
                    IsHandled := true;
                    exit;
                end;
                if IntegrationTableMapping."Synch. Modified On Filter" < DateToCompareWith then
                    DateToCompareWith := IntegrationTableMapping."Synch. Modified On Filter" - 999;
            end;
            IsModified := TypeHelper.CompareDateTime(LastModifiedOn, DateToCompareWith) > 0;
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Record Management", 'OnIsModifiedAfterIntegrationTableRecordLastSynch', '', false, false)]
    local procedure HandleOnIsModifiedAfterIntegrationTableRecordLastSynch(IntegrationTableConnectionType: TableConnectionType; IntegrationTableUid: Variant; DestinationTableId: Integer; LastModifiedOn: DateTime; var IsModified: Boolean; var IsHandled: Boolean)
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        TypeHelper: Codeunit "Type Helper";
    begin
        if IntegrationTableConnectionType <> IntegrationTableConnectionType::ExternalSQL then
            exit;

        if not IsEnabled() then
            exit;

        if MasterDataMgtCoupling.FindRowFromIntegrationSystemID(IntegrationTableUid, DestinationTableId, MasterDataMgtCoupling) then begin
            if (MasterDataMgtCoupling."Last Synch. Result" = MasterDataMgtCoupling."Last Synch. Result"::Failure) and (MasterDataMgtCoupling.Skipped = false) then
                IsModified := true
            else
                IsModified := TypeHelper.CompareDateTime(LastModifiedOn, MasterDataMgtCoupling."Last Synch. Int. Modified On") > 0;
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Record Management", 'OnUpdateIntegrationTableCouplingForRecordID', '', false, false)]
    local procedure HandleOnUpdateIntegrationTableCouplingForRecordID(IntegrationTableConnectionType: TableConnectionType; IntegrationTableUid: Variant; RecordId: RecordID; var IsHandled: Boolean)
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        MasterDataMgtCoupling2: Record "Master Data Mgt. Coupling";
        ErrIntegrationSystemID: Guid;
        SysId: Guid;
    begin
        if IntegrationTableConnectionType <> IntegrationTableConnectionType::ExternalSQL then
            exit;

        if not IsEnabled() then
            exit;

        if not MasterDataMgtCoupling.FindSystemIdByRecordId(SysId, RecordID) then
            Error(IntegrationRecordNotFoundErr, Format(RecordID, 0, 1));

        // Find coupling between IntegrationSystemID and TableNo
        if not MasterDataMgtCoupling.FindRowFromIntegrationSystemID(IntegrationTableUid, RecordID.TableNo, MasterDataMgtCoupling) then
            // Find rogue coupling beteen IntegrationSystemID and table 0
            if not MasterDataMgtCoupling.FindRowFromIntegrationSystemID(IntegrationTableUid, 0, MasterDataMgtCoupling) then begin
                // Find other coupling to the record
                if MasterDataMgtCoupling2.FindIDFromRecordID(RecordID, ErrIntegrationSystemID) then
                    Error(RecordIdAlreadyMappedErr, Format(RecordID, 0, 1), ProductName.Short());


                MasterDataMgtCoupling.InsertRecord(IntegrationTableUid, SysId, RecordID.TableNo);
                IsHandled := true;
                exit;
            end;

        if MasterDataMgtCoupling."Local System ID" <> SysId then begin
            if MasterDataMgtCoupling2.FindIDFromRecordID(RecordID, ErrIntegrationSystemID) then
                Error(RecordIdAlreadyMappedErr, Format(RecordID, 0, 1), ProductName.Short());
            MasterDataMgtCoupling.SetNewLocalSystemId(SysId);
        end;

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Record Management", 'OnRemoveIntegrationTableCouplingForRecordId', '', false, false)]
    local procedure HandleOnRemoveIntegrationTableCouplingForRecordId(IntegrationTableConnectionType: TableConnectionType; IntegrationTableUid: Variant; DestinationTableID: Integer; var RecordId: RecordID; var Removed: Boolean; var IsHandled: Boolean)
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
    begin
        if IntegrationTableConnectionType <> IntegrationTableConnectionType::ExternalSQL then
            exit;

        if not IsEnabled() then
            exit;

        IsHandled := true;
        Removed := MasterDataMgtCoupling.RemoveCouplingToRecord(RecordId);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Record Management", 'OnFindIntegrationTableUIdByRecordRef', '', false, false)]
    local procedure HandleOnFindIntegrationTableUIdByRecordRef(IntegrationTableConnectionType: TableConnectionType; var SourceRecordRef: RecordRef; var IntegrationTableUid: Variant; var IsFound: Boolean; var IsHandled: Boolean)
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
    begin
        if IntegrationTableConnectionType <> IntegrationTableConnectionType::ExternalSQL then
            exit;

        if not IsEnabled() then
            exit;

        IsFound := MasterDataMgtCoupling.FindIDFromRecordRef(SourceRecordRef, IntegrationTableUid);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Record Management", 'OnFindIntegrationTableUIdByRecordId', '', false, false)]
    local procedure HandleOnFindIntegrationTableUIdByRecordId(IntegrationTableConnectionType: TableConnectionType; var SourceRecordId: RecordID; var IntegrationTableUid: Variant; var IsFound: Boolean; var IsHandled: Boolean)
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
    begin
        if IntegrationTableConnectionType <> IntegrationTableConnectionType::ExternalSQL then
            exit;

        if not IsEnabled() then
            exit;

        IsFound := MasterDataMgtCoupling.FindIDFromRecordID(SourceRecordId, IntegrationTableUid);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Record Management", 'OnFindRecordIdByIntegrationTableUid', '', false, false)]
    local procedure HandleOnFindRecordIdByIntegrationTableUid(IntegrationTableConnectionType: TableConnectionType; var IntegrationTableUid: Variant; DestinationTableId: Integer; var DestinationRecordId: RecordID; var IsFound: Boolean; var IsHandled: Boolean)
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
    begin
        if IntegrationTableConnectionType <> IntegrationTableConnectionType::ExternalSQL then
            exit;

        if not IsEnabled() then
            exit;

        IsFound := MasterDataMgtCoupling.FindRecordIDFromID(IntegrationTableUid, DestinationTableId, DestinationRecordId);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Record Management", 'OnMarkLastSynchAsFailure', '', false, false)]
    local procedure HandleOnMarkLastSynchAsFailure(IntegrationTableConnectionType: TableConnectionType; var SourceRecRef: RecordRef; DirectionToIntTable: Boolean; JobID: Guid; var MarkedAsSkipped: Boolean; var IsHandled: Boolean)
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
    begin
        if IntegrationTableConnectionType <> IntegrationTableConnectionType::ExternalSQL then
            exit;

        if not IsEnabled() then
            exit;

        MasterDataMgtCoupling.SetLastSynchResultFailed(SourceRecRef, DirectionToIntTable, JobID, MarkedAsSkipped);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Record Management", 'OnRemoveIntegrationTableCouplingForRecordRef', '', false, false)]
    local procedure HandleOnRemoveIntegrationTableCouplingForRecordRef(IntegrationTableConnectionType: TableConnectionType; IntegrationTableUid: Variant; DestinationTableID: Integer; var RecordRef: RecordRef; var Removed: Boolean; var IsHandled: Boolean)
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        SysId: Guid;
    begin
        if IntegrationTableConnectionType <> IntegrationTableConnectionType::ExternalSQL then
            exit;

        if not IsEnabled() then
            exit;

        if not MasterDataMgtCoupling.FindSystemIdByRecordRef(SysId, RecordRef) then
            Error(IntegrationRecordNotFoundErr, RecordRef.Field(RecordRef.SystemIdNo()).Value());

        if MasterDataMgtCoupling.FindRowFromLocalSystemID(SysId, MasterDataMgtCoupling) then begin
            MasterDataMgtCoupling.Delete(true);
            Removed := true;
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Int. Rec. Uncouple Invoke", 'OnRemoveIntegrationTableCoupling', '', false, false)]
    local procedure HandleOnRemoveIntegrationTableCoupling(var IntegrationTableMapping: Record "Integration Table Mapping"; var LocalRecordRef: RecordRef; var IntegrationRecordRef: RecordRef; var IntegrationTableConnectionType: TableConnectionType; var IsHandled: Boolean; var Removed: Boolean)
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        SysId: Guid;
    begin
        if IntegrationTableMapping.Type <> IntegrationTableMapping.Type::"Master Data Management" then
            exit;

        if not IsEnabled() then
            exit;

        if not MasterDataMgtCoupling.FindSystemIdByRecordRef(SysId, LocalRecordRef) then
            Error(IntegrationRecordNotFoundErr, LocalRecordRef.Field(LocalRecordRef.SystemIdNo()).Value());

        IsHandled := true;

        if MasterDataMgtCoupling.FindRowFromLocalSystemID(SysId, MasterDataMgtCoupling) then begin
            MasterDataMgtCoupling.Delete(true);
            Removed := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Record Management", 'OnUpdateIntegrationTableCouplingForRecordRef', '', false, false)]
    local procedure HandleOnUpdateIntegrationTableCouplingForRecordRef(IntegrationTableConnectionType: TableConnectionType; IntegrationTableUid: Variant; RecordRef: RecordRef; var IsHandled: Boolean)
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        MasterDataMgtCoupling2: Record "Master Data Mgt. Coupling";
        ErrIntegrationSystemID: Guid;
        IntegrationSystemId: Guid;
        SysId: Guid;
    begin
        if IntegrationTableConnectionType <> IntegrationTableConnectionType::ExternalSQL then
            exit;

        if not IsEnabled() then
            exit;

        if not IntegrationTableUid.IsGuid() then
            Error('Invalid integration record system id.');

        IntegrationSystemId := IntegrationTableUid;
        if IntegrationSystemId = SysId then
            Error('Empty integration record system id.');

        if not MasterDataMgtCoupling.FindSystemIdByRecordRef(SysId, RecordRef) then
            Error(IntegrationRecordNotFoundErr, Format(RecordRef.RecordId(), 0, 1));

        // Find coupling between IntegrationSystemID and TableNo
        if not MasterDataMgtCoupling.FindRowFromIntegrationSystemID(IntegrationSystemId, RecordRef.Number(), MasterDataMgtCoupling) then
            // Find rogue coupling beteen IntegrationSystemID and table 0
            if not MasterDataMgtCoupling.FindRowFromIntegrationSystemID(IntegrationSystemId, 0, MasterDataMgtCoupling) then begin
                // Find other coupling to the record
                if MasterDataMgtCoupling2.FindIDFromRecordRef(RecordRef, ErrIntegrationSystemID) then
                    if MasterDataMgtCoupling2."Local System ID" <> MasterDataMgtCoupling2."Integration System ID" then
                        Error(RecordRefAlreadyMappedErr, IntegrationTableUid, ErrIntegrationSystemID, RecordRef.Caption());

                MasterDataMgtCoupling.InsertRecord(IntegrationTableUid, SysId, RecordRef.Number());
                IsHandled := true;
                exit;
            end;

        if MasterDataMgtCoupling."Local System ID" <> SysId then begin
            if MasterDataMgtCoupling2.FindIDFromRecordRef(RecordRef, ErrIntegrationSystemID) then
                Error(RecordRefAlreadyMappedErr, IntegrationTableUid, ErrIntegrationSystemID, RecordRef.Caption());
            MasterDataMgtCoupling.SetNewLocalSystemId(SysId);
        end;
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Rec. Synch. Invoke", 'OnUpdateIntegrationRecordCoupling', '', false, false)]
    local procedure HandleOnUpdateIntegrationRecordCoupling(IntegrationTableMapping: Record "Integration Table Mapping"; var SourceRecordRef: RecordRef; var DestinationRecordRef: RecordRef; var IsHandled: Boolean; IntegrationTableConnectionType: TableConnectionType)
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        IntegrationRecordManagement: Codeunit "Integration Record Management";
        IntegrationTableUidFieldRef: FieldRef;
        IntegrationTableUid: Variant;
        SourceCompanyName: Text[30];
    begin
        if IntegrationTableConnectionType <> IntegrationTableConnectionType::ExternalSQL then
            exit;

        if not IsEnabled() then
            exit;

        OnGetIntegrationRecordSystemId(SourceRecordRef, IntegrationTableUid, IsHandled);
        if not IsHandled then begin
            MasterDataManagementSetup.Get();
            OnSetSourceCompanyName(SourceCompanyName, IntegrationTableMapping."Integration Table ID");
            if SourceCompanyName = '' then
                SourceCompanyName := MasterDataManagementSetup."Company Name";
            SourceRecordRef.ChangeCompany(SourceCompanyName);
            IntegrationTableUidFieldRef := SourceRecordRef.Field(IntegrationTableMapping."Integration Table UID Fld. No.");
            IntegrationTableUid := IntegrationTableUidFieldRef.Value();
        end;

        IntegrationRecordManagement.UpdateIntegrationTableCoupling(
          IntegrationTableConnectionType, IntegrationTableUid, DestinationRecordRef);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Integration Table Mapping", 'OnSynchronizeNow', '', false, false)]
    local procedure HandleOnSynchronizeNow(var IntegrationTableMapping: Record "Integration Table Mapping"; ResetLastSynchModifiedOnDateTime: Boolean; ResetSynchonizationTimestampOnRecords: Boolean; var IsHandled: Boolean)
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        MasterDataManagementSetupDefaults: Codeunit "Master Data Mgt. Setup Default";
    begin
        if not IsEnabled() then
            exit;

        if ResetLastSynchModifiedOnDateTime then begin
            Clear(IntegrationTableMapping."Synch. Modified On Filter");
            Clear(IntegrationTableMapping."Synch. Int. Tbl. Mod. On Fltr.");
            IntegrationTableMapping.Modify();
        end;
        if ResetSynchonizationTimestampOnRecords then begin
            MasterDataMgtCoupling.SetRange("Table ID", IntegrationTableMapping."Table ID");
            case IntegrationTableMapping.Direction of
                IntegrationTableMapping.Direction::ToIntegrationTable:
                    MasterDataMgtCoupling.ModifyAll("Last Synch. Modified On", 0DT);
                IntegrationTableMapping.Direction::FromIntegrationTable:
                    MasterDataMgtCoupling.ModifyAll("Last Synch. Int. Modified On", 0DT);
            end
        end;
        Commit();
        MasterDataManagementSetupDefaults.CreateJobQueueEntry(IntegrationTableMapping);
        IsHandled := true;
    end;

    internal procedure GetIntegrationRecordRef(IntegrationTableID: Integer; var MasterDataMgtCoupling: Record "Master Data Mgt. Coupling"; var RecRef: RecordRef): Boolean
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        IsHandled: Boolean;
        Found: Boolean;
        SourceCompanyName: Text[30];
    begin
        OnGetIntegrationRecordRefFromCoupling(IntegrationTableID, MasterDataMgtCoupling, RecRef, Found, IsHandled);
        if IsHandled then
            exit(Found);

        if IntegrationTableID = 0 then
            exit(false);

        MasterDataManagementSetup.Get();
        RecRef.Open(IntegrationTableID);
        OnSetSourceCompanyName(SourceCompanyName, IntegrationTableID);
        if SourceCompanyName = '' then
            SourceCompanyName := MasterDataManagementSetup."Company Name";
        RecRef.ChangeCompany(SourceCompanyName);
        exit(RecRef.GetBySystemId(MasterDataMgtCoupling."Integration System ID"));
    end;

    internal procedure RemoveSubsidiarySubscriptionFromMasterCompany(MasterCompanyName: Text[30]; SubsidiaryCompanyName: Text[30])
    var
        MasterDataMgtSubscriber: Record "Master Data Mgt. Subscriber";
        IsHandled: Boolean;
    begin
        OnRemoveSubsidiarySubscriptionFromMasterCompany(MasterCompanyName, SubsidiaryCompanyName, IsHandled);
        if IsHandled then
            exit;

        MasterDataMgtSubscriber.ChangeCompany(MasterCompanyName);
        MasterDataMgtSubscriber.SetRange("Company Name", SubsidiaryCompanyName);
        if MasterDataMgtSubscriber.FindFirst() then
            MasterDataMgtSubscriber.Delete();
    end;

    local procedure FindCouplingByIntegrationSystemID(var MasterDataMgtCoupling: Record "Master Data Mgt. Coupling"; IntegrationSystemID: Guid) Found: Boolean
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        RecRef: RecordRef;
        RecId: RecordId;
        SourceCompanyName: Text[30];
    begin
        Clear(MasterDataMgtCoupling."Integration System ID");
        MasterDataManagementSetup.Get();
        MasterDataMgtCoupling.Reset();
        MasterDataMgtCoupling.SetRange("Integration System ID", IntegrationSystemID);
        if MasterDataMgtCoupling.FindFirst() then
            if MasterDataMgtCoupling.FindRecordId(RecId) then begin
                RecRef.Open(RecId.TableNo());
                OnSetSourceCompanyName(SourceCompanyName, RecId.TableNo());
                if SourceCompanyName = '' then
                    SourceCompanyName := MasterDataManagementSetup."Company Name";
                RecRef.ChangeCompany(SourceCompanyName);
                Found := RecRef.Get(RecId);
            end;
    end;

    internal procedure GetIntegrationRecRefCount(var IntegrationTableMapping: Record "Integration Table Mapping"): Integer
    var
        IntegrationContact: Record Contact;
        INtegrationVendor: Record Vendor;
        IntegrationCustomer: Record Customer;
        MasterDataManagementSetup: Record "Master Data Management Setup";
        IntegrationRecRef: RecordRef;
        IntegrationRecRefCount: Integer;
        SourceCompanyName: Text[30];
    begin
        MasterDataManagementSetup.Get();
        OnSetSourceCompanyName(SourceCompanyName, IntegrationTableMapping."Table ID");
        if SourceCompanyName = '' then
            SourceCompanyName := MasterDataManagementSetup."Company Name";
        IntegrationRecRef.Open(IntegrationTableMapping."Integration Table ID");
        IntegrationRecRef.ChangeCompany(SourceCompanyName);

        case IntegrationTableMapping."Integration Table ID" of
            Database::Vendor:
                begin
                    IntegrationVendor.Reset();
                    IntegrationVendor.SetView(GetIntegrationTableMappingView(DATABASE::Vendor));
                    IntegrationVendor.ChangeCompany(SourceCompanyName);
                    IntegrationRecRefCount := IntegrationVendor.Count();
                end;
            Database::Customer:
                begin
                    IntegrationCustomer.Reset();
                    IntegrationCustomer.SetView(GetIntegrationTableMappingView(DATABASE::Customer));
                    IntegrationCustomer.ChangeCompany(SourceCompanyName);
                    IntegrationRecRefCount := IntegrationCustomer.Count();
                end;
            Database::Contact:
                begin
                    IntegrationContact.Reset();
                    IntegrationContact.SetView(GetIntegrationTableMappingView(DATABASE::Contact));
                    IntegrationContact.ChangeCompany(SourceCompanyName);
                    IntegrationRecRefCount := IntegrationContact.Count();
                end;
            else
                IntegrationRecRefCount := IntegrationRecRef.Count();
        end;
        exit(IntegrationRecRefCount);
    end;

    local procedure GetIntegrationTableMappingView(TableId: Integer): Text
    var
        "Field": Record "Field";
        IntegrationTableMapping: Record "Integration Table Mapping";
        RecRef: array[2] of RecordRef;
        FieldRef: array[2] of FieldRef;
        FieldFilter: array[2] of Text;
        NoFilter: Dictionary of [Integer, Boolean];
    begin
        RecRef[1].Open(TableId);
        RecRef[2].Open(TableId);

        IntegrationTableMapping.SetRange(Status, IntegrationTableMapping.Status::Enabled);
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        IntegrationTableMapping.SetRange("Synch. Codeunit ID", CODEUNIT::"Integration Master Data Synch.");
        IntegrationTableMapping.SetRange("Integration Table ID", TableId);
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        IntegrationTableMapping.SetRange("Int. Table UID Field Type", Field.Type::GUID);
        if IntegrationTableMapping.FindSet() then
            repeat
                FieldFilter[2] := IntegrationTableMapping.GetIntegrationTableFilter();
                if FieldFilter[2] <> '' then begin
                    RecRef[2].SetView(FieldFilter[2]);

                    Field.SetRange(TableNo, TableId);
                    Field.SetFilter(ObsoleteState, '<>%1', Field.ObsoleteState::Removed);
                    if Field.FindSet() then
                        repeat
                            if not NoFilter.ContainsKey(Field."No.") then begin
                                FieldRef[1] := RecRef[1].Field(Field."No.");
                                FieldRef[2] := RecRef[2].Field(Field."No.");

                                FieldFilter[1] := FieldRef[1].GetFilter;
                                FieldFilter[2] := FieldRef[2].GetFilter;

                                if FieldFilter[2] <> '' then
                                    if FieldFilter[1] = '' then
                                        FieldRef[1].SetFilter(FieldFilter[2])
                                    else
                                        FieldRef[1].SetFilter(FieldFilter[1] + '|' + FieldFilter[2])
                                else begin
                                    NoFilter.Add(Field."No.", true);
                                    FieldRef[1].SetFilter('');
                                end;
                            end;
                        until Field.Next() = 0;
                end;
            until IntegrationTableMapping.Next() = 0;

        exit(RecRef[1].GetView(false));
    end;

    internal procedure AddSubsidiarySubscriptionToMasterCompany(MasterCompanyName: Text[30]; SubsidiaryCompanyName: Text[30])
    var
        MasterDataMgtSubscriber: Record "Master Data Mgt. Subscriber";
        IsHandled: Boolean;
    begin
        OnAddSubsidiarySubscriptionToMasterCompany(MasterCompanyName, SubsidiaryCompanyName, IsHandled);
        if IsHandled then
            exit;

        MasterDataMgtSubscriber.ChangeCompany(MasterCompanyName);
        MasterDataMgtSubscriber.SetRange("Company Name", SubsidiaryCompanyName);
        if MasterDataMgtSubscriber.IsEmpty() then begin
            MasterDataMgtSubscriber.Init();
            MasterDataMgtSubscriber."Company Name" := SubsidiaryCompanyName;
            MasterDataMgtSubscriber.Insert();
        end;
    end;

    internal procedure FindMappingByIntegrationRecordId(var IntegrationTableMapping: Record "Integration Table Mapping"; var MasterDataMgtCoupling: Record "Master Data Mgt. Coupling"): Boolean
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        IntegrationRecordRef: RecordRef;
        IntegrationSystemIdFieldRef: FieldRef;
        IntegrationTableView: Text;
        SourceCompanyName: Text[30];
    begin
        MasterDataManagementSetup.Get();
        IntegrationTableMapping.SetRange(Status, IntegrationTableMapping.Status::Enabled);
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        IntegrationTableMapping.SetFilter("Integration Table ID", '<>0');
        if IntegrationTableMapping.FindSet() then
            repeat
                IntegrationRecordRef.Close();
                IntegrationTableView := IntegrationTableMapping.GetIntegrationTableFilter();
                IntegrationRecordRef.Open(IntegrationTableMapping."Integration Table ID");
                OnSetSourceCompanyName(SourceCompanyName, IntegrationTableMapping."Integration Table ID");
                if SourceCompanyName = '' then
                    SourceCompanyName := MasterDataManagementSetup."Company Name";
                IntegrationRecordRef.ChangeCompany(SourceCompanyName);
                IntegrationSystemIdFieldRef := IntegrationRecordRef.Field(IntegrationRecordRef.SystemIdNo);
                IntegrationRecordRef.SetView(IntegrationTableView);
                IntegrationSystemIdFieldRef.SetRange(MasterDataMgtCoupling."Integration System ID");
                if not IntegrationRecordRef.IsEmpty() then
                    exit(true);
            until IntegrationTableMapping.Next() = 0;
        exit(false);
    end;

    internal procedure CheckSetupPermissions()
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        IntegrationTableMapping: Record "Integration Table Mapping";
    begin
        if not MasterDataManagementSetup.WritePermission() then
            Error(NoPermissionToSetUpErr);

        if not IntegrationTableMapping.WritePermission() then
            Error(NoPermissionToSetUpErr);
    end;

    internal procedure CheckUsagePermissions()
    var
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
    begin
        if not MasterDataMgtCoupling.WritePermission() then
            Error(NoPermissionToUseErr);
    end;

    internal procedure CheckTaskSchedulePermissions()
    begin
        if not CanScheduleJob() then
            Error(NoPermissionToScheduleJobErr);
    end;

    local procedure CanScheduleJob(): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
        User: Record User;
        EmptyGuid: Guid;
        UserId: Guid;
    begin
        if not (JobQueueEntry.WritePermission() and JobQueueEntry.ReadPermission()) then
            exit(false);
        UserId := UserSecurityId();
        if User.IsEmpty() then
            exit(true);
        if Format(UserId) = Format(EmptyGuid) then
            exit(true);
        if not User.Get(UserId) then
            exit(false);
        if User."License Type" = User."License Type"::"Limited User" then
            exit(false);
        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetIntegrationTableMapping(var IntegrationTableMapping: Record "Integration Table Mapping"; TableID: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeHandleCustomIntegrationTableMapping(var IsHandled: Boolean; IntegrationTableMappingName: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSynchronyzeNowQuestion(var AllowedDirection: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsDataSynchRecord(TableID: Integer; var isIntegrationRecord: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnEnabledDatabaseTriggersSetup(TableID: Integer; var Enabled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetIntegrationSystemIdFromRecRef(IntegrationRecordRef: RecordRef; var IntegrationRecordSystemId: Guid; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnGetIntegrationRecordRefByIntegrationSystemId(var IntegrationTableMapping: Record "Integration Table Mapping"; ID: Variant; var IntegrationRecordRef: RecordRef; var Found: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetIntegrationRecordRefFromCoupling(IntegrationTableID: Integer; var MasterDataMgtCoupling: Record "Master Data Mgt. Coupling"; var RecRef: RecordRef; var Found: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRemoveSubsidiarySubscriptionFromMasterCompany(MasterCompanyName: Text[30]; SubsidiaryCompanyName: Text[30]; var IsHandled: Boolean)
    begin
    end;


    [IntegrationEvent(false, false)]
    local procedure OnAddSubsidiarySubscriptionToMasterCompany(MasterCompanyName: Text[30]; SubsidiaryCompanyName: Text[30]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetIntegrationRecordSystemId(var SourceRecordRef: RecordRef; var IntegrationTableUid: Guid; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnSetIntegrationTableFilter(IntegrationTableMapping: Record "Integration Table Mapping"; var RecRef: RecordRef; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnGetIntegrationRecordRef(IntegrationTableMapping: Record "Integration Table Mapping"; var SourceRecordRef: RecordRef; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnGetIntegrationRecordRefBySystemId(IntegrationTableMapping: Record "Integration Table Mapping"; var SourceRecordRef: RecordRef; IntRecSystemId: Guid; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnUpdateChildContactsParentCompany(var SourceRecordRef: RecordRef; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnHandleOnAfterDeleteIntegrationTableMapping(var IntegrationTableMapping: Record "Integration Table Mapping"; RunTrigger: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnHandleRecreateJobQueueEntryFromIntegrationTableMapping(var JobQueueEntry: Record "Job Queue Entry"; var IntegrationTableMapping: Record "Integration Table Mapping"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnLocalRecordChangeOverwrite(var SourceFieldRef: FieldRef; var DestinationFieldRef: FieldRef; var ThrowError: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsRecordRefModifiedAfterRecordLastSynch(var SourceRecordRef: RecordRef; LastModifiedOn: DateTime; var IsModified: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterSetIntegrationTableMappingFilterForInitialSynch(var IntegrationTableMappingFilter: Text)
    begin
        // append the names of the custom table mappings to the IntegrationTableMappingFilter: it is an 'or' filter, so concatenate the names by |
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnSetSourceCompanyName(var SourceCompanyName: Text[30]; TableID: Integer)
    begin
    end;
}

