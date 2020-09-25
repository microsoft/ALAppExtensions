table 10672 "SAF-T Mapping"
{
    DataClassification = CustomerContent;
    Caption = 'SAF-T Mapping';

    fields
    {
        field(1; "Mapping Type"; Enum "SAF-T Mapping Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Mapping Type';
        }
        field(2; "Category No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Category No.';
            TableRelation = "SAF-T Mapping Category" where ("Mapping Type" = field ("Mapping Type"));
        }
        field(3; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
        }
        field(4; Description; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
    }

    keys
    {
        key(PK; "Mapping Type", "Category No.", "No.")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "No.", Description)
        {

        }
    }
}
