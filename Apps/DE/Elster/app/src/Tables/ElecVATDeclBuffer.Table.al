#pragma warning disable AA0247
table 11027 "Elec. VAT Decl. Buffer"
{
    TableType = Temporary;
    LookupPageId = "Elec. VAT Decl. Overview";
    DrillDownPageId = "Elec. VAT Decl. Overview";

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
        }
        field(2; Amount; Decimal)
        {
            Caption = 'Amount';
        }
    }

    keys
    {
        key(Key1; Code)
        {
        }
    }
}
