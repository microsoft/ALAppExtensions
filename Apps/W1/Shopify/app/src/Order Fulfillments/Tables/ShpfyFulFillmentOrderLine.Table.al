table 30144 "Shpfy FulFillment Order Line"
{
    Caption = 'FulFillment Order Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Shopify Fulfillment Order Id"; BigInteger)
        {
            Caption = 'Shopify Fulfillment Id';
            DataClassification = SystemMetadata;
        }
        field(2; "Shopify Fulfillm. Ord. Line Id"; BigInteger)
        {
            Caption = 'Shopify FulfillmentLine Id';
            DataClassification = SystemMetadata;
        }
        field(3; "Shopify Location Id"; BigInteger)
        {
            Caption = 'Shopify Location Id';
            DataClassification = SystemMetadata;
        }
        field(4; "Shopify Order Id"; BigInteger)
        {
            Caption = 'Shopify Order Id';
            DataClassification = SystemMetadata;
        }
        field(5; "Shopify Product Id"; BigInteger)
        {
            Caption = 'Shopify Product Id';
            DataClassification = SystemMetadata;
        }
        field(6; "Total Quantity"; Integer)
        {
            Caption = 'Total Quantity';
            DataClassification = CustomerContent;
        }
        field(7; "Remaining Quantity"; Integer)
        {
            Caption = 'Remaining Quantity';
            DataClassification = CustomerContent;
        }
        Field(8; "Quantity to Fulfill"; Decimal)
        {
            Caption = 'Qty. to Fulfill';
            DataClassification = CustomerContent;
        }
        field(9; "Shopify Variant Id"; BigInteger)
        {
            Caption = 'Shopify Variant Id';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; "Shopify Fulfillment Order Id", "Shopify Fulfillm. Ord. Line Id")
        {
            Clustered = true;
        }
    }
}