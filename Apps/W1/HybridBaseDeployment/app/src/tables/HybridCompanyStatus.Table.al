table 40027 "Hybrid Company Status"
{
    DataClassification = SystemMetadata;
    DataPerCompany = false;
    ReplicateData = false;

    // We must prohibit extending this table since it is not populated by the application.
    Extensible = false;

    fields
    {
        field(1; "Name"; Text[50])
        {
            Description = 'The SQL-friendly name of a company';
            DataClassification = SystemMetadata;
        }

        field(2; Replicated; Boolean)
        {
            Description = 'Replicated';
            DataClassification = SystemMetadata;
        }

        field(3; "Upgrade Status"; Option)
        {
            Description = 'Upgrade Status';
            OptionMembers = " ",Pending,Started,Completed,Failed;
            OptionCaption = ' ,Pending,Started,Completed,Failed';
            DataClassification = SystemMetadata;
        }

        field(4; "Upgrade Failure Message"; Blob)
        {
            Description = 'Upgrade Failure Message';
        }
    }

    keys
    {
        key(Key1; Name)
        {
            Clustered = true;
        }
    }
}