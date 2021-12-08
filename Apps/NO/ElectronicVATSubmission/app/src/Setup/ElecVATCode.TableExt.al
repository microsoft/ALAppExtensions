tableextension 10687 "Elec. VAT Code" extends "VAT Code"
{
    fields
    {
        field(10680; "VAT Rate For Reporting"; Decimal)
        {
            Caption = 'VAT Rate For Reporting';
        }
        field(10681; "Report VAT Rate"; Boolean)
        {
            Caption = 'Report VAT Rate';
        }
    }
}