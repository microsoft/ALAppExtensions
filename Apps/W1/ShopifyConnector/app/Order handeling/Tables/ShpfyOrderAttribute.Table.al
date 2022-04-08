/// <summary>
/// Table Shpfy Order Attribute (ID 30116).
/// </summary>
table 30116 "Shpfy Order Attribute"
{
    Access = Internal;
    Caption = 'Shopify Order Attributes';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Order Id"; BigInteger)
        {
            Caption = 'Order Id';
            DataClassification = CustomerContent;
        }
        field(2; "Key"; Text[100])
        {
            Caption = 'Key';
            DataClassification = CustomerContent;
        }
        field(3; Value; Text[250])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Order Id", "Key")
        {
            Clustered = true;
        }
    }

}
