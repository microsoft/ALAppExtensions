table 4028 "GP Segments"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; Id; Text[20])
        {
            DataClassification = SystemMetadata;
        }
        field(2; Name; Text[20])
        {
            DataClassification = SystemMetadata;
        }
        field(3; CodeCaption; Text[20])
        {
            DataClassification = SystemMetadata;
        }
        field(4; FilterCaption; Text[20])
        {
            DataClassification = SystemMetadata;
        }
        field(5; SegmentNumber; Integer)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }
}