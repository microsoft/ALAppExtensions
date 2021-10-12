table 20363 "Upgraded Tax Types"
{
    DataClassification = SystemMetadata;
    Extensible = false;

    fields
    {
        field(1; "Tax Type"; Code[20])
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Tax Type")
        {
            Clustered = true;
        }
    }
}