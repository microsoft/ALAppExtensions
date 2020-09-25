table 10673 "SAF-T Export Setup"
{
    DataClassification = CustomerContent;
    Caption = 'SAF-T Export Setup';

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Primary Key';
        }
        field(2; "Mapping Range Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Mapping Range Code';
            TableRelation = "SAF-T Mapping Range";
        }
        field(3; "Header Comment"; Text[18])
        {
            DataClassification = CustomerContent;
            Caption = 'Header Comment';
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
