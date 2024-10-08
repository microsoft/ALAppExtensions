namespace Microsoft.Integration.Shopify;

/// <summary>
/// Interface "Shpfy ICompany Mapping."
/// </summary>
interface "Shpfy ICompany Mapping"
{
    procedure DoMapping(CompanyId: BigInteger; ShopCode: Code[20]; TemplateCode: Code[20]; AllowCreate: Boolean): Code[20]

    procedure FindMapping(var ShopifyCompany: Record "Shpfy Company"; var TempShopifyCustomer: Record "Shpfy Customer" temporary): Boolean;
}