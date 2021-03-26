table 2407 "XS Synchronization Field"
{
    Caption = 'Synchronization Field';
    DataClassification = SystemMetadata;
    ReplicateData = false;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Table No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Table No.';
        }
        field(3; "Field No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Field No.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}