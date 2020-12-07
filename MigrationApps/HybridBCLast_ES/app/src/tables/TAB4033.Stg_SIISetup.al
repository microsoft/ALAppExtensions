table 4033 "Stg SII Setup"
{
    ReplicateData = false;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(2; Certificate; BLOB)
        {
            DataClassification = CustomerContent;
        }
        field(3; Password; Text[250])
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