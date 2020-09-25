table 10684 "SAF-T Missing Field"
{
    DataClassification = CustomerContent;
    Caption = 'SAF-T Missing Field';

    #pragma warning disable AS0034
    TableType = Temporary;
    #pragma warning restore AS0034

    fields
    {
        field(1; "Table No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Table No.';
        }
        field(2; "Field No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Field No.';
        }
        field(3; "Record ID"; RecordId)
        {
            DataClassification = CustomerContent;
            Caption = 'Record ID';
        }
        field(4; "Group No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Group No.';
        }
        field(5; "Field Caption"; Text[1024])
        {
            DataClassification = CustomerContent;
            Caption = 'Field Caption';
        }
    }

    keys
    {
        key(PK; "Table No.", "Field No.")
        {
            Clustered = true;
        }
        key(Group; "Table No.", "Group No.")
        {
        }
    }

}