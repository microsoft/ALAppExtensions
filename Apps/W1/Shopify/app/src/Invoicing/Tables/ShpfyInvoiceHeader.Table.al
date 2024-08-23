namespace Microsoft.Integration.Shopify;

/// <summary>
/// Table Shpfy Invoice Header (ID 30161).
/// </summary>
table 30161 "Shpfy Invoice Header"
{
    Caption = 'Shopify Invoice Header';
    DataClassification = CustomerContent;
    Access = Internal;

    fields
    {
        field(1; "Shopify Order Id"; BigInteger)
        {
            Caption = 'Shopify Order Id';
        }
    }

    keys
    {
        key(PK; "Shopify Order Id")
        {
            Clustered = true;
        }
    }
}