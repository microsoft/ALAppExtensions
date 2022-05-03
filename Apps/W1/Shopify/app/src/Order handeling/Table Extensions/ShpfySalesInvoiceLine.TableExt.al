/// <summary>
/// TableExtension Shpfy Sales Invoice Line (ID 30103) extends Record Sales Invoice Line.
/// </summary>
tableextension 30103 "Shpfy Sales Invoice Line" extends "Sales Invoice Line"
{
    fields
    {
        field(30100; "Shpfy Order Line Id"; BigInteger)
        {
            Caption = 'Shopify Order Line Id';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(30101; "Shpfy Order No."; Code[50])
        {
            Caption = 'Shopify Order No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}

