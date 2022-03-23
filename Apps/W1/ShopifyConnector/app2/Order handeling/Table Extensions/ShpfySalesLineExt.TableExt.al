/// <summary>
/// TableExtension Shpfy Sales Line Ext. (ID 30104) extends Record Sales Line.
/// </summary>
tableextension 30104 "Shpfy Sales Line Ext." extends "Sales Line"
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

