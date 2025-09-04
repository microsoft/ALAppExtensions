namespace Microsoft.DataMigration;

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

        field(5; "User Mapping Completed"; Boolean)
        {
            Description = 'User Mapping Completed';
        }

        field(6; "Last User Mapping DateTime"; DateTime)
        {
            Description = 'Last User Mapping DateTime';
        }

        field(7; "Record Link Move Completed"; Boolean)
        {
            Description = 'Record Link Migration Completed';
        }

        field(8; "Last Record Link Move DateTime"; DateTime)
        {
            Description = 'Last Record Link Migration DateTime';
        }
        field(9; "Tenant Media Count"; Integer)
        {
            Description = 'Tenant Media Count';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; Name)
        {
            Clustered = true;
        }
        key(Key2; "Upgrade Status")
        {
        }
    }
}