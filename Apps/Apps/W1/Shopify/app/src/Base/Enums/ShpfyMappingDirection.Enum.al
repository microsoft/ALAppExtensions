namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy Mapping Direction (ID 30101).
/// </summary>
enum 30101 "Shpfy Mapping Direction"
{
    Caption = 'Shopify Mapping Direction';
    Extensible = false;

    value(0; ShopifyToBC)
    {
        Caption = 'Shopify to BC';
    }
    value(1; BCToShopify)
    {
        Caption = 'BC to Shopify';
    }

}
