table 4022 "User Mapping Work"
{
    DataPerCompany = false;
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; "Source User ID"; Code[50])
        {
            Description = 'Source User ID';
            DataClassification = SystemMetadata;
        }
        field(2; "Dest User ID"; Code[50])
        {
            TableRelation = "User"."User Name" WHERE("Authentication Email" = FILTER(<> ''));
            ValidateTableRelation = false;
            Description = 'Destination User ID';
            DataClassification = SystemMetadata;
            Caption = 'Destination User ID';
        }
    }

    keys
    {
        key(PK; "Source User ID")
        {
            Clustered = true;
        }
    }
}