/// <summary>
/// Table Shpfy Order Line Attribute (ID 30123).
/// </summary>
table 30148 "Shpfy Order Line Attribute"
{
    Caption = 'Shopify Order Attributes';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Order Id"; BigInteger)
        {
            Caption = 'Order Id';
            DataClassification = CustomerContent;
        }
        field(2; "Order Line Id"; Guid)
        {
            Caption = 'Line Id';
            DataClassification = CustomerContent;
        }
        field(3; "Key"; Text[100])
        {
            Caption = 'Key';
            DataClassification = CustomerContent;
        }
        field(4; Value; Text[250])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Order Id", "Order Line Id", "Key")
        {
            Clustered = true;
        }
    }

}
