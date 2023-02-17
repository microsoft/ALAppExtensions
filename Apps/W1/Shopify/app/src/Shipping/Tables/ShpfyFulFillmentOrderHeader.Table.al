table 30143 "Shpfy FulFillment Order Header"
{
    Caption = 'Fulfillment Order Header';
    DataClassification = CustomerContent;
    LookupPageId = "Shpfy Fulfillment Orders";
    DrillDownPageId = "Shpfy Fulfillment Order Card";

    fields
    {
        field(1; "Shopify Fulfillment Order Id"; BigInteger)
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Shopify Order Id"; BigInteger)
        {
            DataClassification = SystemMetadata;
        }
        field(3; Status; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(4; "Shop Id"; Integer)
        {
            Caption = 'Shop Id';
            DataClassification = CustomerContent;
        }
        field(5; "Shop Code"; Code[20])
        {
            Caption = 'Shop Code';
            DataClassification = CustomerContent;
            TableRelation = "Shpfy Shop".Code;
        }
    }
    keys
    {
        key(PK; "Shopify Fulfillment Order Id")
        {
            Clustered = true;
        }
    }
}
