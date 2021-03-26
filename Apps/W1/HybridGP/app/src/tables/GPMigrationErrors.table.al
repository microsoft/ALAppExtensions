table 4015 "GP Migration Errors"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; Dummy; Code[10])
        {
            DataClassification = SystemMetadata;
        }
        field(2; MigrationErrorCount; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(3; PostingErrorCount; Integer)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; Dummy)
        {
            Clustered = true;
        }
    }
}