table 2401 "Sync Change"
{
    Caption = 'Sync Change';
    DataClassification = SystemMetadata;
    ReplicateData = false;

    fields
    {
        field(1; "No."; Integer)
        {
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }
        field(2; "Internal ID"; RecordID)
        {
            DataClassification = CustomerContent;
        }
        field(3; "External ID"; Guid)
        {
            DataClassification = SystemMetadata;
        }
        field(4; "Sync Handler"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(5; Direction; Option)
        {
            DataClassification = SystemMetadata;
            OptionMembers = Incoming,Outgoing,Bidirectional;
        }
        field(6; "Change Type"; Option)
        {
            DataClassification = SystemMetadata;
            OptionMembers = Create,Update,Delete;
        }
        field(7; "NAV Data"; Blob)
        {
            Caption = 'NAV Data';
            DataClassification = CustomerContent;
        }

        field(8; "Current No. of sync attempts"; Integer)
        {
            Caption = 'Current No. of sync attempts';
            DataClassification = SystemMetadata;
        }
        field(9; "Error message"; Text[250])
        {
            Caption = 'Error message';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }

    fieldgroups
    {
    }
}

