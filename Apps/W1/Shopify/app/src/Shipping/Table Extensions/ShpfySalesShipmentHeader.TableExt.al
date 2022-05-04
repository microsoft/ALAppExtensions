/// <summary>
/// TableExtensionShpfy Sales Shipment Header (ID 30106) extends Record Sales Shipment Header.
/// </summary>
tableextension 30106 "Shpfy Sales Shipment Header" extends "Sales Shipment Header"
{
    fields
    {
        field(30100; "Shpfy Order Id"; BigInteger)
        {
            Caption = 'Shopify Order Id';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(30102; "Shpfy Order No."; Code[50])
        {
            Caption = 'Shopify Order No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(30103; "Shpfy Fulfillment Id"; BigInteger)
        {
            Caption = 'Shopify Fulfillment Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}

