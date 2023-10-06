namespace Microsoft.DataMigration.GP.HistoricalData;

table 40910 "Hist. Migration Step Status"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(2; Step; enum "Hist. Migration Step Type")
        {
            Caption = 'Step';
            DataClassification = SystemMetadata;
            NotBlank = true;
        }
        field(3; "Start Date"; DateTime)
        {
            Caption = 'Start Date';
            DataClassification = SystemMetadata;
            NotBlank = true;
        }
        field(4; "End Date"; DateTime)
        {
            Caption = 'End Date';
            DataClassification = SystemMetadata;
        }
        field(5; Completed; Boolean)
        {
            Caption = 'Completed';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }

        key(Key2; Step)
        {
        }
    }
}