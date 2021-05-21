table 31090 "Commodity CZL"
{
    Caption = 'Commodity';
    DataCaptionFields = Code;
    DrillDownPageID = "Commodities CZL";
    LookupPageID = "Commodities CZL";

    fields
    {
        field(1; Code; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }
}