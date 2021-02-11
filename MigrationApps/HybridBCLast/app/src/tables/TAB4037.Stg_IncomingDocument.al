table 4037 "Stg Incoming Document"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(19; URL1; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(20; URL2; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(21; URL3; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(22; URL4; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(60; URL; Text[1024])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

