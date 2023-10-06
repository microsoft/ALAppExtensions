namespace Microsoft.Integration.MDM;

using Microsoft.Integration.SyncEngine;

codeunit 7235 "Master Data Mgt. Table Couple"
{
    TableNo = "Integration Table Mapping";
    Permissions = tabledata "Master Data Full Synch. R. Ln." = r,
                  tabledata "Master Data Mgt. Coupling" = r,
                  tabledata "Integration Field Mapping" = ri,
                  tabledata "Master Data Management Setup" = r;

    trigger OnRun()
    var
        Handled: Boolean;
    begin
        OnBeforeRun(Rec, Handled);
        if Handled then
            exit;

        PerformScheduledCoupling(Rec);
    end;

    var
        IntegrationMasterDataSynch: Codeunit "Integration Master Data Synch.";
        SynchActionType: Option "None",Insert,Modify,ForceModify,IgnoreUnchanged,Fail,Skip,Delete,Uncouple,Couple;
        NoMatchingCriteriaDefinedErr: Label 'You must specify which fields on the table %1 should be used for match-based coupling.', Comment = '%1 - integration table mapping name';
        NoMatchFoundErr: Label 'Failed to couple %2 record(s), because no unique uncoupled matching entity was found in %1 with the specified matching criteria.', Comment = '%1 - comma-separated list of field names, %2 - A URL, %3 - an integer, number of records';
        NoMatchFoundTelemetryErr: Label 'No matching entity was found for %1 in %3 by matching on following fields: %2.', Locked = true;
        SingleMatchAlreadyCoupledTelemetryErr: Label 'Single matching entity was found for %1 in %3 by matching on following fields: %2, but it is already coupled.', Locked = true;
        MultipleMatchesFoundTelemetryErr: Label 'Multiple matching entities found for %1 in %3 by matching on following fields: %2.', Locked = true;
        NoMatchingCriteriaDefinedTelemetryErr: Label 'User is trying to schedule match based coupling for integration table mapping %1 without having specified the matchin criteria.', Locked = true;
        NoConflictResolutionStrategyDefinedTelemetryErr: Label 'User is trying to schedule match based coupling for integration table mapping %1 without having specified the conflict resolution strategy.', Locked = true;
        SkippingPostCouplingSynchTelemetryUserChoiceMsg: Label 'Skipping post-coupling synchronization for integration table mapping %1, because the user chose not to run it.', Locked = true;
        SkippingPostCouplingSynchTelemetryNoneCoupledMsg: Label 'Skipping post-coupling synchronization for integration table mapping %1, because no records were coupled.', Locked = true;
        StartingPostCouplingSynchTelemetryMsg: Label 'Starting post-coupling synchronization for integration table mapping %1, for %2 coupled records.', Locked = true;
        SchedulingPostCouplingSynchForBatchTelemetryMsg: Label 'Scheduling post-coupling synchronization for integration table mapping %1, for a batch of %2 coupled records.', Locked = true;
        CouplingMsg: Label 'Coupling records...\\Processing record #1##########', Comment = '#1 place holder for record number';
        MappingNameWithParentTxt: Label '%1 (%2)', Locked = true;
        IntegrationOrgCompanyName: Text;
        IntegrationOrgCompanyNameLbl: Label 'Company %1', Comment = '%1 - company name';

    internal procedure PerformScheduledCoupling(var IntegrationTableMapping: Record "Integration Table Mapping")
    var
        MasterDataFullSynchRLn: Record "Master Data Full Synch. R. Ln.";
        IntegrationTableSynch: Codeunit "Integration Table Synch.";
        JobId: Guid;
    begin
        JobId := IntegrationTableSynch.BeginIntegrationCoupleJob(TableConnectionType::ExternalSQL, IntegrationTableMapping, IntegrationTableMapping."Table ID");
        if not IsNullGuid(JobId) then begin
            if IntegrationTableMapping.Direction in [IntegrationTableMapping.Direction::Bidirectional, IntegrationTableMapping.Direction::FromIntegrationTable] then
                MasterDataFullSynchRLn.FullSynchStarted(IntegrationTableMapping, JobId, IntegrationTableMapping.Direction::FromIntegrationTable);
            if IntegrationTableMapping.Direction in [IntegrationTableMapping.Direction::Bidirectional, IntegrationTableMapping.Direction::ToIntegrationTable] then
                MasterDataFullSynchRLn.FullSynchStarted(IntegrationTableMapping, JobId, IntegrationTableMapping.Direction::ToIntegrationTable);

            CoupleRecords(IntegrationTableMapping, IntegrationTableSynch);
            IntegrationTableSynch.EndIntegrationSynchJob();

            if IntegrationTableMapping.Direction in [IntegrationTableMapping.Direction::Bidirectional, IntegrationTableMapping.Direction::FromIntegrationTable] then
                MasterDataFullSynchRLn.FullSynchFinished(IntegrationTableMapping, IntegrationTableMapping.Direction::FromIntegrationTable);
            if IntegrationTableMapping.Direction in [IntegrationTableMapping.Direction::Bidirectional, IntegrationTableMapping.Direction::ToIntegrationTable] then
                MasterDataFullSynchRLn.FullSynchFinished(IntegrationTableMapping, IntegrationTableMapping.Direction::ToIntegrationTable);
        end;
    end;

    local procedure CoupleRecords(var IntegrationTableMapping: Record "Integration Table Mapping"; var IntegrationTableSynch: Codeunit "Integration Table Synch.")
    var
        IntegrationFieldMapping: Record "Integration Field Mapping";
        TempMatchingIntegrationFieldMapping: Record "Integration Field Mapping" temporary;
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        MasterDataManagementSetup: Record "Master Data Management Setup";
        MasterDataManagement: Codeunit "Master Data Management";
        LocalRecordRef: RecordRef;
        IntegrationRecordRef: RecordRef;
        EmptyRecordRef: RecordRef;
        MatchingIntegrationRecordFieldRef: FieldRef;
        MatchingLocalFieldRef: FieldRef;
        SetMatchingFieldFilterHandled: Boolean;
        MatchingFieldCount: Integer;
        MatchCount: Integer;
        UnmatchedIntegrationSystemIdsDictionary: Dictionary of [Code[20], List of [Guid]];
        UnmatchedIntegrationSystemIds: List of [Guid];
        CoupledSystemIds: List of [Guid];
        CoupledIntegrationSystemIds: List of [Guid];
        IntegrationRecordSystemId: Guid;
        RecordNumber: Integer;
        Dialog: Dialog;
        TableFilter: Text;
        FilterList: List of [Text];
        MatchPriorityList: List of [Integer];
        MatchPriority: Integer;
    begin
        // collect the matching criteria fields in a temporary record
        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Use For Match-Based Coupling", true);
        IntegrationFieldMapping.SetCurrentKey("Match Priority");
        IntegrationFieldMapping.SetAscending("Match Priority", true);
        if IntegrationFieldMapping.FindSet() then
            repeat
                TempMatchingIntegrationFieldMapping.Init();
                TempMatchingIntegrationFieldMapping.TransferFields(IntegrationFieldMapping);
                TempMatchingIntegrationFieldMapping.Insert();
                if not MatchPriorityList.Contains(TempMatchingIntegrationFieldMapping."Match Priority") then
                    MatchPriorityList.Add(TempMatchingIntegrationFieldMapping."Match Priority");
            until IntegrationFieldMapping.Next() = 0
        else begin
            Session.LogMessage('0000J8C', StrSubstNo(NoMatchingCriteriaDefinedTelemetryErr, GetMappingNameWithParent(IntegrationTableMapping)), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MasterDataManagement.GetTelemetryCategory());
            IntegrationTableSynch.LogMatchBasedCouplingError(LocalRecordRef, StrSubstNo(NoMatchingCriteriaDefinedErr, IntegrationTableMapping.GetUserFriendlyMappingName()));
            exit;
        end;

        if GuiAllowed() then begin
            Dialog.Open(CouplingMsg);
            Dialog.Update(1, '');
        end;

        // iterate through integration records and for each of them try to find a match in local system
        MasterDataManagementSetup.Get();
        IntegrationRecordRef.Open(IntegrationTableMapping."Integration Table ID");
        IntegrationRecordRef.ChangeCompany(MasterDataManagementSetup."Company Name");
        IntegrationMasterDataSynch.SplitIntegrationTableFilter(IntegrationTableMapping, FilterList);
        foreach TableFilter in FilterList do begin
            if TableFilter <> '' then
                IntegrationRecordRef.SetView(TableFilter);
            if IntegrationRecordRef.FindSet() then
                repeat
                    if GuiAllowed() then begin
                        RecordNumber += 1;
                        Dialog.Update(1, RecordNumber);
                    end;
                    IntegrationRecordSystemId := IntegrationRecordRef.Field(IntegrationRecordRef.SystemIdNo()).Value();
                    // re-check that the record is uncoupled as it could just be coupled by another job
                    if MasterDataMgtCoupling.IsIntegrationSystemIdCoupled(IntegrationRecordSystemId, IntegrationTableMapping."Integration Table ID") then begin
                        Session.LogMessage('0000J8D', GetSingleMatchAlreadyCoupledTelemetryErrorMessage(IntegrationRecordRef, TempMatchingIntegrationFieldMapping), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MasterDataManagement.GetTelemetryCategory());
                        CoupledIntegrationSystemIds.Add(IntegrationRecordSystemId)
                    end else begin
                        Clear(LocalRecordRef);
                        LocalRecordRef.Open(IntegrationTableMapping."Table ID");
                        IntegrationTableMapping.SetRecordRefFilter(LocalRecordRef);
                        // this inner loop is looping through a temporary record set with a handful of user-chosen matching fields - not a performance concern as such
                        foreach MatchPriority in MatchPriorityList do
                            if not CoupledIntegrationSystemIds.Contains(IntegrationRecordSystemId) then begin
                                MatchingFieldCount := 0;
                                MatchCount := 0;
                                TempMatchingIntegrationFieldMapping.Reset();
                                TempMatchingIntegrationFieldMapping.SetRange("Match Priority", MatchPriority);
                                TempMatchingIntegrationFieldMapping.FindSet();
                                repeat
                                    // initialize the fields that we should match on
                                    MatchingIntegrationRecordFieldRef := IntegrationRecordRef.Field(TempMatchingIntegrationFieldMapping."Integration Table Field No.");
                                    MatchingLocalFieldRef := LocalRecordRef.Field(TempMatchingIntegrationFieldMapping."Field No.");

                                    // raise an event so that custom filtering logic can be implemented (depending on which record and which fields are chosen as the matching field)
                                    SetMatchingFieldFilterHandled := false;
                                    OnBeforeSetMatchingFilter(IntegrationRecordRef, MatchingIntegrationRecordFieldRef, LocalRecordRef, MatchingLocalFieldRef, SetMatchingFieldFilterHandled);

                                    // if nobody implemented custom filtering, apply default filtering logic
                                    // and that is: set the filter on the integration table field with the value of the local field (case sensitive if specified by user)
                                    if not SetMatchingFieldFilterHandled then
                                        case MatchingIntegrationRecordFieldRef.Type of
                                            FieldType::Code:
                                                begin
                                                    if Format(MatchingIntegrationRecordFieldRef.Value()) <> '' then
                                                        MatchingLocalFieldRef.SetRange(MatchingIntegrationRecordFieldRef.Value())
                                                    else
                                                        MatchingLocalFieldRef.SetFilter('=''''');
                                                    MatchingFieldCount += 1;
                                                end;
                                            FieldType::Text:
                                                begin
                                                    if Format(MatchingIntegrationRecordFieldRef.Value()) <> '' then
                                                        if not TempMatchingIntegrationFieldMapping."Case-Sensitive Matching" then
                                                            MatchingLocalFieldRef.SetFilter('''@' + Format(MatchingIntegrationRecordFieldRef.Value()).Replace('''', '''''') + '''')
                                                        else
                                                            MatchingLocalFieldRef.SetRange(MatchingIntegrationRecordFieldRef.Value())
                                                    else
                                                        MatchingLocalFieldRef.SetFilter('=''''');
                                                    MatchingFieldCount += 1;
                                                end;
                                            else begin
                                                MatchingLocalFieldRef.SetRange(MatchingIntegrationRecordFieldRef.Value());
                                                MatchingFieldCount += 1;
                                            end;
                                        end;
                                until TempMatchingIntegrationFieldMapping.Next() = 0;

                                // if there is exactly one match, and it is not coupled, couple it. otherwise - log a synch error
                                if MatchingFieldCount > 0 then
                                    MatchCount := LocalRecordRef.Count();
                                case MatchCount of
                                    0:
                                        begin
                                            Session.LogMessage('0000J8E', GetNoMatchFoundTelemetryErrorMessage(IntegrationRecordRef, TempMatchingIntegrationFieldMapping), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MasterDataManagement.GetTelemetryCategory());
                                            if not UnmatchedIntegrationSystemIds.Contains(IntegrationRecordSystemId) then
                                                UnmatchedIntegrationSystemIds.Add(IntegrationRecordSystemId);
                                        end;
                                    1:
                                        begin
                                            LocalRecordRef.FindFirst();
                                            if MasterDataMgtCoupling.IsLocalSystemIdCoupled(LocalRecordRef.Field(LocalRecordRef.SystemIdNo).Value()) then begin
                                                Session.LogMessage('0000J8F', GetSingleMatchAlreadyCoupledTelemetryErrorMessage(IntegrationRecordRef, TempMatchingIntegrationFieldMapping), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MasterDataManagement.GetTelemetryCategory());
                                                if not UnmatchedIntegrationSystemIds.Contains(IntegrationRecordSystemId) then
                                                    UnmatchedIntegrationSystemIds.Add(IntegrationRecordSystemId);
                                            end else
                                                if IntegrationTableSynch.Couple(LocalRecordRef, IntegrationRecordRef) then begin
                                                    CoupledIntegrationSystemIds.Add(IntegrationRecordSystemId);
                                                    if UnmatchedIntegrationSystemIds.Contains(IntegrationRecordSystemId) then
                                                        UnmatchedIntegrationSystemIds.Remove(IntegrationRecordSystemId);
                                                    CoupledSystemIds.Add(LocalRecordRef.Field(LocalRecordRef.SystemIdNo).Value());
                                                end;
                                        end;
                                    else begin
                                        Session.LogMessage('0000J8G', GetMultipleMatchesFoundTelemetryErrorMessage(IntegrationRecordRef, TempMatchingIntegrationFieldMapping), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MasterDataManagement.GetTelemetryCategory());
                                        if not UnmatchedIntegrationSystemIds.Contains(IntegrationRecordSystemId) then
                                            UnmatchedIntegrationSystemIds.Add(IntegrationRecordSystemId);
                                    end;
                                end;
                            end;
                    end;
                until IntegrationRecordRef.Next() = 0;
            if GuiAllowed then
                Dialog.Update(1, RecordNumber);
        end;

        if GuiAllowed then
            Dialog.Close();

        // if the user chose so, create new entities in integration system for records that couldn't be matched
        if UnmatchedIntegrationSystemIds.Count() > 0 then
            if ShouldCreateNewRecordsInCaseOfNoMatch(IntegrationTableMapping) then begin
                UnmatchedIntegrationSystemIdsDictionary.Add(IntegrationTableMapping.Name, UnmatchedIntegrationSystemIds);
                MasterDataManagement.CreateNewRecordsInLocalSystem(UnmatchedIntegrationSystemIdsDictionary);
            end else begin
                IntegrationTableSynch.UpdateSynchJobCounters(SynchActionType::Fail, UnmatchedIntegrationSystemIds.Count());
                IntegrationTableSynch.LogSynchError(EmptyRecordRef, EmptyRecordRef, GetNoMatchFoundErrorMessage(UnmatchedIntegrationSystemIds.Count()), false);
            end;

        // schedule synch job of coupled records, if user chose to do so
        if IntegrationTableMapping."Synch. After Bulk Coupling" then
            SynchronizeCoupledRecords(IntegrationTableMapping, CoupledSystemIds, CoupledIntegrationSystemIds)
        else
            Session.LogMessage('0000J8H', StrSubstNo(SkippingPostCouplingSynchTelemetryUserChoiceMsg, GetMappingNameWithParent(IntegrationTableMapping)), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MasterDataManagement.GetTelemetryCategory());
    end;

    local procedure ShouldCreateNewRecordsInCaseOfNoMatch(var IntegrationTableMapping: Record "Integration Table Mapping"): Boolean
    var
        Handled: Boolean;
        ShouldCreateNewRecord: Boolean;
    begin
        OnShouldCreateNewRecordInCaseOfNoMatch(IntegrationTableMapping, ShouldCreateNewRecord, Handled);
        if Handled then
            exit(ShouldCreateNewRecord);

        exit(IntegrationTableMapping."Create New in Case of No Match");
    end;

    local procedure SynchronizeCoupledRecords(var IntegrationTableMapping: Record "Integration Table Mapping"; var CoupledSystemIds: List of [Guid]; var CoupledIntegrationSystemIds: List of [Guid])
    var
        MasterDataManagement: Codeunit "Master Data Management";
        Direction: Integer;
    begin
        if CoupledSystemIds.Count() = 0 then begin
            Session.LogMessage('0000J8I', StrSubstNo(SkippingPostCouplingSynchTelemetryNoneCoupledMsg, GetMappingNameWithParent(IntegrationTableMapping)), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MasterDataManagement.GetTelemetryCategory());
            exit;
        end;

        Session.LogMessage('0000J8J', StrSubstNo(StartingPostCouplingSynchTelemetryMsg, GetMappingNameWithParent(IntegrationTableMapping), CoupledSystemIds.Count()), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MasterDataManagement.GetTelemetryCategory());

        Direction := IntegrationTableMapping.Direction;
        if IntegrationTableMapping.Direction = IntegrationTableMapping.Direction::Bidirectional then
            case IntegrationTableMapping."Update-Conflict Resolution" of
                IntegrationTableMapping."Update-Conflict Resolution"::"None":
                    Session.LogMessage('0000J8K', StrSubstNo(NoConflictResolutionStrategyDefinedTelemetryErr, GetMappingNameWithParent(IntegrationTableMapping)), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MasterDataManagement.GetTelemetryCategory());
                IntegrationTableMapping."Update-Conflict Resolution"::"Get Update from Integration":
                    Direction := IntegrationTableMapping.Direction::FromIntegrationTable;
                IntegrationTableMapping."Update-Conflict Resolution"::"Send Update to Integration":
                    Direction := IntegrationTableMapping.Direction::ToIntegrationTable;
            end;

        Session.LogMessage('0000J8L', StrSubstNo(SchedulingPostCouplingSynchForBatchTelemetryMsg, GetMappingNameWithParent(IntegrationTableMapping), CoupledSystemIds.Count()), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MasterDataManagement.GetTelemetryCategory());
        MasterDataManagement.EnqueueSyncJob(IntegrationTableMapping, CoupledSystemIds, CoupledIntegrationSystemIds, Direction, true);
    end;

    local procedure GetNoMatchFoundErrorMessage(ErrorCount: Integer): Text
    begin
        exit(StrSubstNo(NoMatchFoundErr, GetIntegrationOrgCompanyName(), ErrorCount));
    end;

    local procedure GetNoMatchFoundTelemetryErrorMessage(var LocalRecordRef: RecordRef; var MatchIntegrationFieldMapping: Record "Integration Field Mapping" temporary): Text
    var
        MatchingFieldNameList: Text;
    begin
        MatchingFieldNameList := GetMatchingFieldNameList(LocalRecordRef, MatchIntegrationFieldMapping);
        exit(StrSubstNo(NoMatchFoundTelemetryErr, Format(LocalRecordRef.Field(LocalRecordRef.SystemIdNo).Value()), MatchingFieldNameList, GetIntegrationOrgCompanyName()));
    end;

    local procedure GetMultipleMatchesFoundTelemetryErrorMessage(var LocalRecordRef: RecordRef; var MatchIntegrationFieldMapping: Record "Integration Field Mapping" temporary): Text
    var
        MatchingFieldNameList: Text;
    begin
        MatchingFieldNameList := GetMatchingFieldNameList(LocalRecordRef, MatchIntegrationFieldMapping);
        exit(StrSubstNo(MultipleMatchesFoundTelemetryErr, Format(LocalRecordRef.Field(LocalRecordRef.SystemIdNo).Value()), MatchingFieldNameList, GetIntegrationOrgCompanyName()));
    end;

    local procedure GetSingleMatchAlreadyCoupledTelemetryErrorMessage(var LocalRecordRef: RecordRef; var MatchIntegrationFieldMapping: Record "Integration Field Mapping" temporary): Text
    var
        MatchingFieldNameList: Text;
    begin
        MatchingFieldNameList := GetMatchingFieldNameList(LocalRecordRef, MatchIntegrationFieldMapping);
        exit(StrSubstNo(SingleMatchAlreadyCoupledTelemetryErr, Format(LocalRecordRef.Field(LocalRecordRef.SystemIdNo).Value()), MatchingFieldNameList, GetIntegrationOrgCompanyName()));
    end;

    local procedure GetMappingNameWithParent(var IntegrationTableMapping: Record "Integration Table Mapping"): Text
    begin
        if IntegrationTableMapping."Parent Name" <> '' then
            exit(StrSubstNo(MappingNameWithParentTxt, IntegrationTableMapping.Name, IntegrationTableMapping."Parent Name"));
        exit(IntegrationTableMapping.Name);
    end;

    local procedure GetMatchingFieldNameList(var LocalRecordRef: RecordRef; var MatchIntegrationFieldMapping: Record "Integration Field Mapping" temporary) MatchingFieldNameList: Text
    begin
        MatchIntegrationFieldMapping.FindSet();
        repeat
            if MatchingFieldNameList = '' then
                MatchingFieldNameList := LocalRecordRef.Field(MatchIntegrationFieldMapping."Field No.").Name()
            else
                MatchingFieldNameList += ', ' + LocalRecordRef.Field(MatchIntegrationFieldMapping."Field No.").Name()
        until MatchIntegrationFieldMapping.Next() = 0;
    end;

    local procedure GetIntegrationOrgCompanyName(): Text
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
    begin
        if IntegrationOrgCompanyName <> '' then
            exit(IntegrationOrgCompanyName);

        if not MasterDataManagementSetup.Get() then
            exit(IntegrationOrgCompanyName);

        if MasterDataManagementSetup."Is Enabled" then
            IntegrationOrgCompanyName := StrSubstNo(IntegrationOrgCompanyNameLbl, MasterDataManagementSetup."Company Name");

        exit(IntegrationOrgCompanyName);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRun(IntegrationTableMapping: Record "Integration Table Mapping"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetMatchingFilter(var IntegrationRecordRef: RecordRef; var MatchingIntegrationRecordFieldRef: FieldRef; var LocalRecordRef: RecordRef; var MatchingLocalFieldRef: FieldRef; var SetMatchingFilterHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnShouldCreateNewRecordInCaseOfNoMatch(var IntegrationTableMapping: Record "Integration Table Mapping"; var ShouldCreateNewRecord: Boolean; var Handled: Boolean)
    begin
    end;
}
