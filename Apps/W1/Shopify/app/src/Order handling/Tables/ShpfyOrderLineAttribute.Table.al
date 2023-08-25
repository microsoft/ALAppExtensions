/// <summary>
/// Table Shpfy Order Line Attribute (ID 30148).
/// </summary>
table 30148 "Shpfy Order Line Attribute"
{
    Caption = 'Shopify Order Attributes';
    DataClassification = SystemMetadata;
    DrillDownPageID = "Shpfy Order Lines Attributes";
    LookupPageID = "Shpfy Order Lines Attributes";
    Access = Internal;
    extensible = false;

    fields
    {
        field(1; "Order Id"; BigInteger)
        {
            Caption = 'Order Id';
            DataClassification = SystemMetaData;
        }
        field(2; "Order Line Id"; Guid)
        {
            Caption = 'Line Id';
            DataClassification = SystemMetaData;
        }
        field(3; "Key"; Text[100])
        {
            Caption = 'Key';
            DataClassification = SystemMetaData;
        }
        field(4; Value; Text[250])
        {
            Caption = 'Value';
            DataClassification = SystemMetaData;
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
