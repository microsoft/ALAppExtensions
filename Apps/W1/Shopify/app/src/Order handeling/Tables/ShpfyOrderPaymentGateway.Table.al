/// <summary>
/// Table Shpfy Order Payment Gateway (ID 30120).
/// </summary>
table 30120 "Shpfy Order Payment Gateway"
{
    Access = Internal;
    Caption = 'Shopify Order Payment Gateway';
    DataClassification = SystemMetadata;
    fields
    {
        field(1; "Order Id"; BigInteger)
        {
            Caption = 'Order Id';
            DataClassification = SystemMetadata;
        }
        field(2; Name; Code[50])
        {
            Caption = 'Name';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; "Order Id", Name)
        {
            Clustered = true;
        }
    }

}
