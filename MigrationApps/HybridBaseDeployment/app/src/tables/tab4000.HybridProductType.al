table 4000 "Hybrid Product Type"
{
    DataPerCompany = false;
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; "ID"; Text[250])
        {
            Description = 'The id used to identify the product';
            DataClassification = SystemMetadata;
        }
        field(2; "Display Name"; Text[250])
        {
            Description = 'The display name of the product';
            DataClassification = SystemMetadata;
        }
        field(3; "App ID"; Guid)
        {
            Description = 'The product extension app id';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }
}