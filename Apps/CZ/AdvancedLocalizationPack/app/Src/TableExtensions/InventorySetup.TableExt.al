tableextension 31250 "Inventory Setup CZA" extends "Inventory Setup"
{
    fields
    {
        field(31061; "Use GPPG from SKU CZA"; Boolean)
        {
            Caption = 'Use Gen. Prod. Posting Group from Stockkeeping Unit';
            DataClassification = CustomerContent;
        }
        field(31067; "Skip Update SKU on Posting CZA"; Boolean)
        {
            Caption = 'Skip Update SKU on Posting';
            DataClassification = CustomerContent;
        }
        field(31068; "Exact Cost Revers. Mandat. CZA"; Boolean)
        {
            Caption = 'Exact Cost Reversing Mandatory';
            DataClassification = CustomerContent;
        }
    }
}
