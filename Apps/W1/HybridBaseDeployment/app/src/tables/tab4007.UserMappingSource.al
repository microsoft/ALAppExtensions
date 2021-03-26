table 4007 "User Mapping Source"
{
    DataPerCompany = false;
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; "User Security ID"; Guid)
        {
            Description = 'User Security ID';
            DataClassification = SystemMetadata;
        }
        field(2; "Authentication Object ID"; Text[80])
        {
            Description = 'Authentication Object ID';
            DataClassification = SystemMetadata;
        }
        field(3; "Name Identifier"; Text[250])
        {
            Description = 'Name Identifier';
            DataClassification = SystemMetadata;
        }
        field(4; "User ID"; Code[50])
        {
            Description = 'User ID';
            DataClassification = SystemMetadata;
        }
        field(5; "Authentication Email"; Text[50])
        {
            Description = 'Authentication Email';
            DataClassification = SystemMetadata;
            Caption = 'Authentication Email';
        }
    }

    keys
    {
        key(PK; "User Security ID")
        {
            Clustered = true;
        }
    }
}