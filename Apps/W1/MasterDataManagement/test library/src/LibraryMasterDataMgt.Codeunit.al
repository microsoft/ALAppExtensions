#pragma warning disable AA0247
codeunit 139757 "Library - Master Data Mgt."
{
    Access = Public;

    procedure HandleOnTransferFieldData(SourceFieldRef: FieldRef; DestinationFieldRef: FieldRef; var NewValue: Variant; var IsValueFound: Boolean; var NeedsConversion: Boolean)
    begin
        MasterDataMgtSubscribers.HandleOnTransferFieldData(SourceFieldRef, DestinationFieldRef, NewValue, IsValueFound, NeedsConversion);
    end;

    procedure RenameIfNeededOnBeforeModifyRecord(IntegrationTableMapping: Record "Integration Table Mapping"; SourceRecordRef: RecordRef; var DestinationRecordRef: RecordRef)
    begin
        MasterDataMgtSubscribers.RenameIfNeededOnBeforeModifyRecord(IntegrationTableMapping, SourceRecordRef, DestinationRecordRef);
    end;

    procedure HandleOnWasModifiedAfterLastSynch(IntegrationTableConnectionType: TableConnectionType; IntegrationTableMapping: Record "Integration Table Mapping"; var SourceRecordRef: RecordRef; var SourceWasChanged: Boolean; var IsHandled: Boolean)
    begin
        MasterDataMgtSubscribers.HandleOnWasModifiedAfterLastSynch(IntegrationTableConnectionType, IntegrationTableMapping, SourceRecordRef, SourceWasChanged, IsHandled);
    end;

    procedure HandleOnFindAndSynchRecordIDFromIntegrationSystemId(IntegrationSystemId: Guid; TableId: Integer; var LocalRecordID: RecordID; var IsHandled: Boolean)
    begin
        MasterDataMgtSubscribers.HandleOnFindAndSynchRecordIDFromIntegrationSystemId(IntegrationSystemId, TableId, LocalRecordID, IsHandled);
    end;

    procedure HandleOnFindingIfJobNeedsToBeRun(var Sender: Record "Job Queue Entry"; var Result: Boolean)
    begin
        MasterDataMgtSubscribers.HandleOnFindingIfJobNeedsToBeRun(Sender, Result);
    end;

    procedure HandleOnAfterJobQueueEntryRun(var JobQueueEntry: Record "Job Queue Entry")
    begin
        MasterDataMgtSubscribers.HandleOnAfterJobQueueEntryRun(JobQueueEntry);
    end;

    procedure FindRelatedTables(var ExistingSynchTableNos: List of [Integer]; var RelatedTablesToAdd: List of [Integer]; var RelatedTablesToAddText: Text; TableId: Integer)
    var
        MasterDataSynchTables: Page "Master Data Synch. Tables";
    begin
        MasterDataSynchTables.FindRelatedTables(ExistingSynchTableNos, RelatedTablesToAdd, RelatedTablesToAddText, TableId);
    end;

    var
        MasterDataMgtSubscribers: Codeunit "Master Data Mgt. Subscribers";
}
