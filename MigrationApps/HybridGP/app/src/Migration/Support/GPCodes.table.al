table 4025 "GP Codes"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; Id; Text[20])
        {
            DataClassification = SystemMetadata;
        }
        field(2; Name; Text[50])
        {
            DataClassification = SystemMetadata;
        }
        field(3; Description; Text[50])
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; Id, Name)
        {
            Clustered = true;
        }
    }
}