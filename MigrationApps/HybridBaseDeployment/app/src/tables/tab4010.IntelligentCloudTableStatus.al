table 4010 "Intelligent Cloud Table Status"
{
    DataPerCompany = false;
    ReplicateData = false;
    ObsoleteState = Removed;
    ObsoleteReason = 'With Text[>100] available, this table is obsolete in favor of Hybrid Replication Detail.';
    ObsoleteTag = '16.0';
    Extensible = false;

    fields
    {
        field(1; "Run ID"; Text[50])
        {
            Description = 'The ID of the replication run.';
            DataClassification = SystemMetadata;
        }
        field(2; "Table Name"; Text[128])
        {
            Description = 'The name of the table that was replicated.';
            DataClassification = SystemMetadata;
        }
        field(3; "Company Name"; Text[30])
        {
            Description = 'The name of the company for which the table data was replicated.';
            DataClassification = SystemMetadata;
        }
        field(4; "New Version"; BigInteger)
        {
            Description = 'The new version of the data that was replicated.';
            DataClassification = SystemMetadata;

        }
        field(5; "Error Code"; Text[10])
        {
            Description = 'The error code for any errors that occured during the replication.';
            DataClassification = SystemMetadata;
        }
        field(6; "Error Message"; Text[2048])
        {
            Description = 'Any errors that occured during the replication.';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Run ID", "Table Name", "Company Name")
        {
            Clustered = true;
        }
    }
}