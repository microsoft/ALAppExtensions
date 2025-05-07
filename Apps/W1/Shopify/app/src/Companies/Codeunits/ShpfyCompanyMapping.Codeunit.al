namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy Company Mapping (ID 30303).
/// </summary>
codeunit 30303 "Shpfy Company Mapping"
{
    Access = Internal;

    var
        Shop: Record "Shpfy Shop";

    internal procedure DoMapping(CompanyId: BigInteger; TemplateCode: Code[20]; AllowCreate: Boolean): Code[20]
    var
        IMapping: Interface "Shpfy ICompany Mapping";
    begin
        IMapping := Shop."Company Mapping Type";
        exit(IMapping.DoMapping(CompanyId, Shop.Code, TemplateCode, AllowCreate));
    end;

    internal procedure FindMapping(var ShopifyCompany: Record "Shpfy Company"; var TempShopifyCustomer: Record "Shpfy Customer" temporary): Boolean;
    var
        CompByEmailPhone: Codeunit "Shpfy Comp. By Email/Phone";
        IMapping: Interface "Shpfy ICompany Mapping";
    begin
        IMapping := Shop."Company Mapping Type";
        if IMapping is "Shpfy IFind Company Mapping" then
            exit((IMapping as "Shpfy IFind Company Mapping").FindMapping(ShopifyCompany, TempShopifyCustomer))
        else
            CompByEmailPhone.FindMapping(ShopifyCompany, TempShopifyCustomer);
    end;

    internal procedure SetShop(Code: Code[20])
    begin
        Clear(Shop);
        Shop.Get(Code);
        SetShop(Shop);
    end;

    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
    end;
}