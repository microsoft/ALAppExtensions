/// <summary>
/// Enum Shpfy Mapping Direction (ID 30101).
/// </summary>
enum 30101 "Shpfy Mapping Direction"
{
    Access = Internal;
    Extensible = true;

    value(0; ShopifyToBC)
    {
        Caption = 'Shopify to BC';
    }
    value(1; BCToShopify)
    {
        Caption = 'BC to Shopify';
    }

}
