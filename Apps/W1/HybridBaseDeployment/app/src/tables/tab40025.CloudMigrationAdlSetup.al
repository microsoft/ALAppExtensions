table 40025 "Cloud Migration ADL Setup"
{
    TableType = Temporary;
    Extensible = false;
    ReplicateData = false;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Storage Account Name"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(3; "Storage Account Key"; Text[250])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}