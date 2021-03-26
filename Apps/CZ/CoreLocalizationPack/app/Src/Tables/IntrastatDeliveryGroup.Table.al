table 31078 "Intrastat Delivery Group CZL"
{
    Caption = 'Intrastat Delivery Group';
    DrillDownPageID = "Intrastat Delivery Groups CZL";
    LookupPageID = "Intrastat Delivery Groups CZL";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
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
