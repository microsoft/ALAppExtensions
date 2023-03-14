/// <summary>
/// TableExtension "Shpfy Sales Shipment Line (ID 30107) extends Record Sales Shipment Line.
/// </summary>
tableextension 30107 "Shpfy Sales Shipment Line" extends "Sales Shipment Line"
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

