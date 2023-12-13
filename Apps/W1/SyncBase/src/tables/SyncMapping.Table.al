namespace Microsoft.Integration.SyncBase;

table 2402 "Sync Mapping"
{
    Caption = 'Sync Mapping';
    DataClassification = SystemMetadata;
    ReplicateData = false;
#if not CLEAN24
    ObsoleteState = Pending;
    ObsoleteReason = 'The extension is being obsoleted.';
    ObsoleteTag = '24.0';
#else
    ObsoleteState = Removed;
    ObsoleteReason = 'The extension is being obsoleted.';
    ObsoleteTag = '27.0';
#endif

    fields
    {
        field(1; "Internal ID"; RecordID)
        {
            DataClassification = CustomerContent;
        }
        field(2; "External Id"; Guid)
        {
            DataClassification = SystemMetadata;
        }
        field(3; Handler; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(4; "Last Synced Internal"; DateTime)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Internal ID")
        {
        }
    }

    fieldgroups
    {
    }
}

