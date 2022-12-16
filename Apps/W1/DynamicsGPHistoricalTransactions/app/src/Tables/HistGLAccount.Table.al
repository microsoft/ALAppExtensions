table 40900 "Hist. G/L Account"
{
    DataClassification = AccountData;

    fields
    {
        field(1; "No."; Code[130])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; "Name")
        {
        }
    }
}