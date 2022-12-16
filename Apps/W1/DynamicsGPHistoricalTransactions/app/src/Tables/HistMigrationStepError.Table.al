table 40911 "Hist. Migration Step Error"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; Id; Integer)
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
        field(3; Reference; Text[150])
        {
            Caption = 'Reference';
            DataClassification = CustomerContent;
        }
        field(4; "Error Code"; Text[100])
        {
            Caption = 'Error Code';
            DataClassification = SystemMetadata;
        }
        field(5; "Error Message"; Text[2048])
        {
            Caption = 'Error Message';
            DataClassification = SystemMetadata;
        }
        field(6; "Error Date"; DateTime)
        {
            Caption = 'Error Date';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; Id)
        {
            Clustered = true;
        }
    }
}