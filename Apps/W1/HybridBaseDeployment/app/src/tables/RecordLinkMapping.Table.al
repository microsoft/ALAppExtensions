namespace Microsoft.DataMigration;

table 40030 "Record Link Mapping"
{
    DataPerCompany = false;
    ReplicateData = false;
    Extensible = false;
    Caption = 'Record Link Mapping';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Source ID"; Integer)
        {
            Caption = 'Source ID';
        }
        field(2; "Target ID"; Integer)
        {
            Caption = 'Target ID';
        }
        field(3; Company; Text[30])
        {
            Caption = 'Company';
        }
    }

    keys
    {
        key(Key1; "Source ID", "Target ID", Company)
        {
            Clustered = true;
        }
    }
}