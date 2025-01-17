namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Item;

/// <summary>
/// Codeunit Shpfy Sync Catalog Prices (ID 30295).
/// </summary>
codeunit 30295 "Shpfy Sync Catalog Prices"
{
    Access = Internal;
    TableNo = "Shpfy Shop";

    trigger OnRun()
    var
        Catalog: Record "Shpfy Catalog";
        CatalogIds: List of [BigInteger];
    begin
        SetShop(Rec);
        Catalog.SetRange("Shop Code", Shop.Code);
        Catalog.SetRange("Sync Prices", true);
        if CompanyId <> '' then
            Catalog.SetRange("Company SystemId", CompanyId);
        if Catalog.FindSet() then
            repeat
                if not CatalogIds.Contains(Catalog.Id) then begin
                    CatalogIds.Add(Catalog.Id);
                    ProductPriceCalc.SetShopAndCatalog(Shop, Catalog);
                    SyncCatalogPrices(Catalog);
                end;
            until Catalog.Next() = 0;
    end;

    var
        Shop: Record "Shpfy Shop";
        CatalogAPI: Codeunit "Shpfy Catalog API";
        ProductPriceCalc: Codeunit "Shpfy Product Price Calc.";
        CompanyId: Text;

    internal procedure SyncCatalogPrices(var Catalog: Record "Shpfy Catalog")
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ItemUnitofMeasure: Record "Item Unit of Measure";
        ShopifyVariant: Record "Shpfy Variant";
        TempCatalogPrice: Record "Shpfy Catalog Price" temporary;
        JGraphQL: JsonObject;
        JSetPrices: JsonArray;
    begin
        CatalogAPI.GetCatalogPrices(Catalog, TempCatalogPrice);
        if TempCatalogPrice.FindSet() then begin
            CatalogAPI.UpdatePriceGraphQL(JGraphQL, JSetPrices);
            repeat
                if ShopifyVariant.Get(TempCatalogPrice."Variant Id") then
                    if not IsNullGuid(ShopifyVariant."Item SystemId") then
                        if Item.GetBySystemId(ShopifyVariant."Item SystemId") then begin
                            Clear(ItemVariant);
                            if not IsNullGuid((ShopifyVariant."Item Variant SystemId")) then
                                if ItemVariant.GetBySystemId(ShopifyVariant."Item Variant SystemId") then;
                            Clear(ItemUnitofMeasure);
                            if Shop."UoM as Variant" then begin
                                case ShopifyVariant."UoM Option Id" of
                                    1:
                                        if ItemUnitofMeasure.Get(Item."No.", ShopifyVariant."Option 1 Value") then;
                                    2:
                                        if ItemUnitofMeasure.Get(Item."No.", ShopifyVariant."Option 2 Value") then;
                                    3:
                                        if ItemUnitofMeasure.Get(Item."No.", ShopifyVariant."Option 3 Value") then;
                                end;
                                UpdateVariantPrice(TempCatalogPrice, Item, ItemVariant.Code, ItemUnitofMeasure.Code, JSetPrices);
                            end else
                                UpdateVariantPrice(TempCatalogPrice, Item, ItemVariant.Code, Item."Sales Unit of Measure", JSetPrices);
                        end;

                if JSetPrices.Count() = 250 then begin
                    CatalogAPI.UpdatePrice(JGraphQL, TempCatalogPrice."Price List Id");
                    Clear(JGraphQL);
                    CatalogAPI.UpdatePriceGraphQL(JGraphQL, JSetPrices);
                end;
            until TempCatalogPrice.Next() = 0;

            if JSetPrices.Count() > 0 then
                CatalogAPI.UpdatePrice(JGraphQL, TempCatalogPrice."Price List Id");
        end;
    end;

    local procedure UpdateVariantPrice(var TempCatalogPrice: Record "Shpfy Catalog Price" temporary; Item: Record Item; ItemVariantCode: Code[10]; ItemUnitofMeasureCode: Code[10]; var JSetPrices: JsonArray)
    var
        UnitCost: Decimal;
        Price: Decimal;
        CompareAtPrice: Decimal;
        JSetPrice: JsonObject;
    begin
        if (not Item.Blocked) and (not Item."Sales Blocked") then begin
            ProductPriceCalc.CalcPrice(Item, ItemVariantCode, ItemUnitofMeasureCode, UnitCost, Price, CompareAtPrice);
            if CatalogAPI.AddUpdatePriceGraphQL(TempCatalogPrice, Price, CompareAtPrice, JSetPrice) then
                JSetPrices.Add(JSetPrice);
        end;
    end;

    local procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
        Shop.SetRecFilter();
        CatalogAPI.SetShop(Shop);
    end;

    internal procedure SetCompanyId(ShopifyCompanyId: Text)
    begin
        CompanyId := ShopifyCompanyId;
    end;
}