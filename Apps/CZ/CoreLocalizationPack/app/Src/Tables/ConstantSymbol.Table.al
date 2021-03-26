table 11712 "Constant Symbol CZL"
{
    Caption = 'Constant Symbol';
    LookupPageID = "Constant Symbols CZL";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            CharAllowed = '09';
            NotBlank = true;
            DataClassification = CustomerContent;            
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
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
