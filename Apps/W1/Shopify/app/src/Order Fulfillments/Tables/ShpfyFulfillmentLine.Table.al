namespace Microsoft.Integration.Shopify;

table 30139 "Shpfy Fulfillment Line"
{
    Caption = 'Fulfillment Line';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Fulfillment Line Id"; BigInteger)
        {
            Caption = 'Fulfillment Line Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; "Fulfillment Id"; BigInteger)
        {
            Caption = 'Fulfillment Id';
            DataClassification = SystemMetadata;
            TableRelation = "Shpfy Order Fulfillment"."Shopify Fulfillment Id";
            Editable = false;
        }
        field(3; "Order Id"; BigInteger)
        {
            Caption = 'Order Id';
            DataClassification = SystemMetadata;
            TableRelation = "Shpfy Order Header"."Shopify Order Id";
            Editable = false;
        }
        field(4; "Order Line Id"; BigInteger)
        {
            Caption = 'Order Line Id';
            DataClassification = SystemMetadata;
            TableRelation = "Shpfy Order Line"."Line Id" where("Shopify Order Id" = field("Order Id"));
            Editable = false;
        }
        field(5; Quantity; Integer)
        {
            Caption = 'Quantity';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(6; "Is Gift Card"; Boolean)
        {
            Caption = 'Is Gift Card';
            DataClassification = SystemMetadata;
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Fulfillment Line Id")
        {
            Clustered = true;
        }
        key(Indx001; "Fulfillment Id", "Is Gift Card") { }
    }
}