table 20361 "Upgraded Use Cases"
{
    DataClassification = SystemMetadata;
    Extensible = false;

    fields
    {
        field(1; "Use Case ID"; Guid)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Use Case ID")
        {
            Clustered = true;
        }
    }
}