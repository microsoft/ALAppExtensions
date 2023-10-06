namespace Microsoft.DataMigration;

table 40032 "Hybrid Table Status"
{
    DataClassification = SystemMetadata;
    TableType = Temporary;

    fields
    {
        field(2; "Table Name"; Text[250])
        {
            Description = 'The name of the table that was replicated.';
            DataClassification = SystemMetadata;
        }
        field(3; "Company Name"; Text[250])
        {
            Description = 'The name of the company for which the table data was replicated.';
            DataClassification = SystemMetadata;
        }
        field(8; "Status"; Option)
        {
            Description = 'The status of the table replication.';
            OptionMembers = Failed,InProgress,Successful,Warning,NotStarted;
            OptionCaption = 'Failed,In Progress,Successful,Warning,Not Started';
            DataClassification = SystemMetadata;
        }
        field(9; "Total records - Source Table"; Integer)
        {
            Description = 'The number of the records for the table in the On-Premises database.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(10; "Total records - Target Table"; Integer)
        {
            Description = 'The number of the records for the table in the Target database.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(11; "Target difference to Source"; Integer)
        {
            Description = 'The difference between the On-Premises record count compared to SaaS count.';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(12; Details; Text[2048])
        {
            Description = 'Details regarding replication.';
            DataClassification = SystemMetadata;
        }

        field(13; "Replication Count"; Integer)
        {
            Description = 'Replication Count';
            DataClassification = SystemMetadata;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Table Name", "Company Name")
        {
            Clustered = true;
        }
    }
}