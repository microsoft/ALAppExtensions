namespace Microsoft.Integration.Shopify;

/// <summary>
/// Interface "Shpfy ICustomer/Company Mapping."
/// </summary>
interface "Shpfy IFind Company Mapping" extends "Shpfy ICompany Mapping"
{
    procedure FindMapping(var ShopifyCompany: Record "Shpfy Company"; var TempShopifyCustomer: Record "Shpfy Customer" temporary): Boolean
}