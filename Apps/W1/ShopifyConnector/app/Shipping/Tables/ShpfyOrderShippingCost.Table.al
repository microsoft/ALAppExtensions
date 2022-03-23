/// <summary>
/// Table Shpfy Order Shipping Cost (ID 30130).
/// </summary>
table 30130 "Shpfy Order Shipping Cost"
{
    Caption = 'Shopify Order Shipping Cost';
    DataClassification = CustomerContent;
    LookupPageID = "Shpfy Order Shipping Costs";

    fields
    {
        field(1; "Shopify Shipping Line Id"; BigInteger)
        {
            Caption = 'Shopify Shipping Line Id';
            DataClassification = SystemMetadata;
        }
        field(2; "Shopify Order Id"; BigInteger)
        {
            Caption = 'Shopify Order Id';
            DataClassification = SystemMetadata;
        }
        field(3; Title; Text[50])
        {
            Caption = 'Title';
            DataClassification = SystemMetadata;
        }
        field(4; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = SystemMetadata;
        }
        field(5; Source; Code[30])
        {
            Caption = 'Source';
            DataClassification = SystemMetadata;
        }
        field(6; "Code"; Code[50])
        {
            Caption = 'Code';
            DataClassification = SystemMetadata;
        }
        field(7; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Shopify Shipping Line Id")
        {
            Clustered = true;
        }
    }
}

