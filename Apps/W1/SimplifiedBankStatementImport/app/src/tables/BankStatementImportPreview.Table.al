table 8850 "Bank Statement Import Preview"
{
    TableType = Temporary;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(2; "Date"; Text[1024])
        {
            Caption = 'Date';
            DataClassification = SystemMetadata;
        }
        field(3; Amount; Text[1024])
        {
            Caption = 'Amount';
            DataClassification = SystemMetadata;
        }
        field(4; Description; Text[1024])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
        }
        field(5; "Amount Format"; Text[1024])
        {
            Caption = 'Amount Format';
            DataClassification = SystemMetadata;
        }
        field(6; "Date Format"; Text[1024])
        {
            Caption = 'Date Format';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}