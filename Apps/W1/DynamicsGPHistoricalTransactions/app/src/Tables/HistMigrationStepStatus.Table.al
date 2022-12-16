table 40910 "Hist. Migration Step Status"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; Step; enum "Hist. Migration Step Type")
        {
            Caption = 'Step';
            DataClassification = SystemMetadata;
            NotBlank = true;
        }
        field(2; "Start Date"; DateTime)
        {
            Caption = 'Start Date';
            DataClassification = SystemMetadata;
            NotBlank = true;
        }
        field(3; "End Date"; DateTime)
        {
            Caption = 'End Date';
            DataClassification = SystemMetadata;
        }
        field(4; Completed; Boolean)
        {
            Caption = 'Completed';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; Step)
        {
            Clustered = true;
        }
    }
}