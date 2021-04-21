table 31077 "Specific Movement CZL"
{
    Caption = 'Specific Movement';
    LookupPageID = "Specific Movements CZL";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "Description EN"; Text[100])
        {
            Caption = 'Description EN';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }
}