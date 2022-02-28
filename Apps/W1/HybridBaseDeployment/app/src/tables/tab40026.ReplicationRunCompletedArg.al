table 40026 "Replication Run Completed Arg"
{
    DataClassification = SystemMetadata;
    ReplicateData = false;

    fields
    {
        field(1; "Run ID"; Text[50])
        {
            Description = 'The ID of the replication run.';
            DataClassification = SystemMetadata;
        }

        field(2; "Subscription ID"; Text[150])
        {
            Caption = 'Subscription ID';
        }

        field(3; "Notification Text"; Blob)
        {
            Caption = 'Notification Text';
        }

        field(4; TaskId; Guid)
        {
            Caption = 'Task ID';
        }

        field(5; "Session Id"; Integer)
        {
            Caption = 'Session ID';
        }
    }

    keys
    {
        key(Key1; "Run ID")
        {
            Clustered = true;
        }
    }
}