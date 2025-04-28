#if not CLEANSCHEMA27
namespace Microsoft.Integration.SyncBase;

table 2400 "Sync Setup"
{
    Caption = 'Sync Setup';
    DataClassification = SystemMetadata;
    ReplicateData = false;
    ObsoleteState = Removed;
    ObsoleteReason = 'The extension is being obsoleted.';
    ObsoleteTag = '27.0';

    fields
    {
        field(1; "Primary Key"; Code[1])
        {
        }
        field(2; "Last Sync Time"; DateTime)
        {
            DataClassification = SystemMetadata;
        }
        field(3; "Current Sync Time"; DateTime)
        {
            DataClassification = SystemMetadata;
        }
        field(4; "Max No. of sync attempts"; Integer)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

}
#endif