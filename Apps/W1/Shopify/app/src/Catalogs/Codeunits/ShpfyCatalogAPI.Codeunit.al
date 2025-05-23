namespace Microsoft.Integration.Shopify;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Sales.Customer;

/// <summary>
/// Codeunit Shpfy Catalog API (ID 30290).
/// </summary>
codeunit 30290 "Shpfy Catalog API"
{
    Access = Internal;

    var
        Shop: Record "Shpfy Shop";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";
        SkippedRecord: Codeunit "Shpfy Skipped Record";
        CatalogType: Enum "Shpfy Catalog Type";
        ShopifyCatalogURLLbl: Label 'https://admin.shopify.com/store/%1/catalogs/%2/editor', Comment = '%1 - Shop Name, %2 - Catalog Id', Locked = true;
        ShopifyMarketCatalogURLLbl: Label 'https://admin.shopify.com/store/%1/settings/markets/%2/pricing', Comment = '%1 - Shop Name, %2 - Market Catalog Id', Locked = true;
        ShopifyUnifiedMarketCatalogURLLbl: Label 'https://admin.shopify.com/store/%1/catalogs/%2/editor', Comment = '%1 - Shop Name, %2 - Catalog Id', Locked = true;
        CatalogNotFoundLbl: Label 'Catalog is not found.';

    internal procedure CreateCatalog(ShopifyCompany: Record "Shpfy Company"; Customer: Record Customer)
    var
        Catalog: Record "Shpfy Catalog";
        GraphQLType: Enum "Shpfy GraphQL Type";
        CatalogId: BigInteger;
        JResponse: JsonToken;
        Parameters: Dictionary of [Text, Text];
    begin
        Parameters.Add('Title', ShopifyCompany.Name);
        Parameters.Add('CompanyLocationId', Format(ShopifyCompany."Location Id"));
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType::CreateCatalog, Parameters);
        CatalogId := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JResponse, 'data.catalogCreate.catalog.id'));
        if CatalogId > 0 then begin
            Catalog.Id := CatalogId;
            Catalog."Shop Code" := Shop.Code;
            Catalog.Name := ShopifyCompany.Name;
            Catalog."Company SystemId" := ShopifyCompany.SystemId;
            Catalog."Customer No." := Customer."No.";
            Catalog.Insert();
            CreatePublication(Catalog);
            CreatePriceList(Catalog);
        end;
    end;

    internal procedure CreatePublication(var Catalog: Record "Shpfy Catalog")
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        Parameters: Dictionary of [Text, Text];
    begin
        Parameters.Add('CatalogId', Format(Catalog.Id));
        CommunicationMgt.ExecuteGraphQL(GraphQLType::CreatePublication, Parameters);
    end;

    internal procedure CreatePriceList(var Catalog: Record "Shpfy Catalog")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        GraphQLType: Enum "Shpfy GraphQL Type";
        Parameters: Dictionary of [Text, Text];
    begin
        Parameters.Add('Name', Format(Catalog.Name));
        Parameters.Add('CatalogId', Format(Catalog.Id));
        if Shop."Currency Code" <> '' then
            Parameters.Add('Currency', Shop."Currency Code")
        else begin
            GeneralLedgerSetup.Get();
            Parameters.Add('Currency', GeneralLedgerSetup."LCY Code");
        end;
        CommunicationMgt.ExecuteGraphQL(GraphQLType::CreatePriceList, Parameters);
    end;

    internal procedure GetCatalogs(ShopifyCompany: Record "Shpfy Company")
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        Cursor: Text;
        JResponse: JsonToken;
        Parameters: Dictionary of [Text, Text];
    begin
        GraphQLType := "Shpfy GraphQL Type"::GetCatalogs;
        Parameters.Add('CompanyId', Format(ShopifyCompany.Id));
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            if JResponse.IsObject() then
                if ExtractShopifyCatalogs(ShopifyCompany, JResponse.AsObject(), Cursor) then begin
                    if Parameters.ContainsKey('After') then
                        Parameters.Set('After', Cursor)
                    else
                        Parameters.Add('After', Cursor);
                    GraphQLType := "Shpfy GraphQL Type"::GetNextCatalogs;
                end else
                    break;
        until not JsonHelper.GetValueAsBoolean(JResponse, 'data.catalogs.pageInfo.hasNextPage');
    end;

    internal procedure GetMarketCatalogs()
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        Cursor: Text;
        JResponse: JsonToken;
        Parameters: Dictionary of [Text, Text];
    begin
        GraphQLType := "Shpfy GraphQL Type"::GetMarketCatalogs;
        repeat
            JResponse := this.CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            if JResponse.IsObject() then
                if this.ExtractShopifyMarketCatalogs(JResponse.AsObject(), Cursor) then begin
                    if Parameters.ContainsKey('After') then
                        Parameters.Set('After', Cursor)
                    else
                        Parameters.Add('After', Cursor);
                    GraphQLType := "Shpfy GraphQL Type"::GetNextMarketCatalogs;
                end else
                    break;
        until not this.JsonHelper.GetValueAsBoolean(JResponse, 'data.catalogs.pageInfo.hasNextPage');
    end;

    internal procedure GetCatalogPrices(Catalog: Record "Shpfy Catalog"; var TempCatalogPrice: Record "Shpfy Catalog Price" temporary)
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        Cursor: Text;
        JResponse: JsonToken;
        ProductList: List of [BigInteger];
        Parameters: Dictionary of [Text, Text];
    begin
        GetIncludedProductsInCatalog(Catalog, ProductList);
        if ProductList.Count() = 0 then
            exit;

        GraphQLType := "Shpfy GraphQL Type"::GetCatalogPrices;
        Parameters.Add('CatalogId', Format(Catalog.Id));
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            if JResponse.IsObject() then
                if ExtractShopifyCatalogPrices(TempCatalogPrice, ProductList, JResponse.AsObject(), Cursor) then begin
                    if Parameters.ContainsKey('After') then
                        Parameters.Set('After', Cursor)
                    else
                        Parameters.Add('After', Cursor);
                    GraphQLType := "Shpfy GraphQL Type"::GetNextCatalogPrices;
                end else
                    break;
        until not JsonHelper.GetValueAsBoolean(JResponse, 'data.catalog.priceList.prices.pageInfo.hasNextPage');
    end;

    internal procedure AddUpdatePriceGraphQL(var TempCatalogPrice: Record "Shpfy Catalog Price" temporary; Price: Decimal; CompareAtPrice: Decimal; var JSetPrice: JsonObject): Boolean
    var
        HasChange: Boolean;
        JPrice: JsonObject;
        JNullValue: JsonValue;
        JCompareAtPrice: JsonObject;
        VariantIdTxt: Label 'gid://shopify/ProductVariant/%1', Locked = true, Comment = '%1 = The product variant Id';
    begin
        JSetPrice.Add('variantId', StrSubstNo(VariantIdTxt, TempCatalogPrice."Variant Id"));
        if (TempCatalogPrice.Price <> Price) or (TempCatalogPrice."Compare at Price" <> CompareAtPrice) then begin
            HasChange := true;
            JPrice.Add('amount', Format(Price, 0, 9));
            JPrice.Add('currencyCode', TempCatalogPrice."Price List Currency");
            JSetPrice.Add('price', JPrice);
        end;
        if TempCatalogPrice."Compare at Price" <> CompareAtPrice then
            if (Price < CompareAtPrice) then begin
                HasChange := true;
                JCompareAtPrice.Add('amount', Format(CompareAtPrice, 0, 9));
                JCompareAtPrice.Add('currencyCode', TempCatalogPrice."Price List Currency");
                JSetPrice.Add('compareAtPrice', JCompareAtPrice);
            end else begin
                HasChange := true;
                JNullValue.SetValueToNull();
                JSetPrice.Add('compareAtPrice', JNullValue.AsToken());
            end;

        if HasChange then
            exit(true)
        else begin
            JSetPrice.Remove('variantId');
            exit(false);
        end;
    end;

    internal procedure UpdatePrice(JGraphQL: JsonObject; PriceListId: BigInteger)
    var
        IGraphQL: Interface "Shpfy IGraphQL";
    begin
        IGraphQL := Enum::"Shpfy GraphQL Type"::UpdateCatalogPrices;
        CommunicationMgt.ExecuteGraphQL(Format(JGraphQL).Replace('{{PriceListID}}', Format(PriceListId)), IGraphQL.GetExpectedCost());
    end;

    internal procedure UpdatePriceGraphQL(var JGraphQL: JsonObject; var JSetPrices: JsonArray)
    var
        IGraphQL: Interface "Shpfy IGraphQL";
    begin
        IGraphQL := Enum::"Shpfy GraphQL Type"::UpdateCatalogPrices;
        JGraphQL.ReadFrom(IGraphQL.GetGraphQL());
        JSetPrices := JsonHelper.GetJsonArray(JGraphQL, 'variables.prices');
    end;

    internal procedure ExtractShopifyCatalogPrices(var TempCatalogPrice: Record "Shpfy Catalog Price" temporary; ProductList: List of [BigInteger]; JResponse: JsonObject; var Cursor: Text): Boolean
    var
        JCatalogs: JsonArray;
        JEdge: JsonToken;
        JNode: JsonObject;
    begin
        if JsonHelper.GetJsonArray(JResponse, JCatalogs, 'data.catalog.priceList.prices.edges') then begin
            foreach JEdge in JCatalogs do begin
                Cursor := JsonHelper.GetValueAsText(JEdge.AsObject(), 'cursor');
                if JsonHelper.GetJsonObject(JEdge.AsObject(), JNode, 'node') then
                    if ProductList.Contains(CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JNode, 'variant.product.id'))) then begin
                        TempCatalogPrice."Variant Id" := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JNode, 'variant.id'));
                        TempCatalogPrice."Shop Code" := Shop.Code;
                        TempCatalogPrice."Price List Id" := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JResponse, 'data.catalog.priceList.id'));
                        TempCatalogPrice."Price List Currency" := StrSubstNo(JsonHelper.GetValueAsCode(JResponse, 'data.catalog.priceList.currency'), 1, MaxStrLen(TempCatalogPrice."Price List Currency"));
                        TempCatalogPrice.Price := JsonHelper.GetValueAsDecimal(JNode, 'price.amount');
                        TempCatalogPrice."Compare At Price" := JsonHelper.GetValueAsDecimal(JNode, 'compareAtPrice.amount');
                        TempCatalogPrice.Insert();
                    end;
            end;
            exit(true);
        end;
    end;

    internal procedure ExtractShopifyCatalogs(var ShopifyCompany: Record "Shpfy Company"; JResponse: JsonObject; var Cursor: Text): Boolean
    var
        Catalog: Record "Shpfy Catalog";
        JCatalogs: JsonArray;
        JEdge: JsonToken;
        JNode: JsonObject;
        CatalogId: BigInteger;
    begin
        if JsonHelper.GetJsonArray(JResponse, JCatalogs, 'data.catalogs.edges') then begin
            foreach JEdge in JCatalogs do begin
                Cursor := JsonHelper.GetValueAsText(JEdge.AsObject(), 'cursor');
                if JsonHelper.GetJsonObject(JEdge.AsObject(), JNode, 'node') then begin
                    CatalogId := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JNode, 'id'));
                    Catalog.SetRange(Id, CatalogId);
                    Catalog.SetRange("Company SystemId", ShopifyCompany.SystemId);
                    Catalog.SetRange("Catalog Type", "Shpfy Catalog Type"::Company);
                    if not Catalog.FindFirst() then begin
                        Catalog.Id := CatalogId;
                        Catalog."Company SystemId" := ShopifyCompany.SystemId;
                        Catalog."Sync Prices" := false;
                        Catalog."Catalog Type" := "Shpfy Catalog Type"::Company;
                        Catalog.Insert(true);
                    end;
                    Catalog."Shop Code" := Shop.Code;
                    Catalog.Name := CopyStr(JsonHelper.GetValueAsText(JNode, 'title'), 1, MaxStrLen(Catalog.Name));
                    Catalog.Modify(true);
                end;
            end;
            exit(true);
        end;
    end;

    internal procedure ExtractShopifyMarketCatalogs(JResponse: JsonObject; var Cursor: Text): Boolean
    var
        Catalog: Record "Shpfy Catalog";
        JCatalogs: JsonArray;
        JEdge: JsonToken;
        JNode: JsonObject;
        CatalogId: BigInteger;
        CurrencyCode: Text;
    begin
        if JsonHelper.GetJsonArray(JResponse, JCatalogs, 'data.catalogs.edges') then begin
            foreach JEdge in JCatalogs do begin
                Cursor := this.JsonHelper.GetValueAsText(JEdge.AsObject(), 'cursor');
                if this.JsonHelper.GetJsonObject(JEdge.AsObject(), JNode, 'node') then begin
                    CatalogId := this.CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JNode, 'id'));
                    CurrencyCode := this.JsonHelper.GetValueAsText(JNode, 'priceList.currency');
                    Catalog.SetRange(Id, CatalogId);
                    Catalog.SetRange("Catalog Type", "Shpfy Catalog Type"::Market);
                    if not Catalog.FindFirst() then begin
                        Catalog.Id := CatalogId;
                        Catalog."Catalog Type" := "Shpfy Catalog Type"::Market;
                        Catalog.Insert(true);
                    end;
                    Catalog."Shop Code" := Shop.Code;
                    Catalog.Name := CopyStr(this.JsonHelper.GetValueAsText(JNode, 'title'), 1, MaxStrLen(Catalog.Name));
                    Catalog."Currency Code" := CopyStr(CurrencyCode, 1, MaxStrLen(Catalog."Currency Code"));
                    Catalog.Modify(true);

                    this.GetMarketsLinkedToCatalog(Catalog);
                end;
            end;
            exit(true);
        end;
    end;

    internal procedure GetMarketsLinkedToCatalog(Catalog: Record "Shpfy Catalog")
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        Cursor: Text;
        JResponse: JsonToken;
        Parameters: Dictionary of [Text, Text];
    begin
        this.ClearCatalogMarketRelations(Catalog);
        GraphQLType := "Shpfy GraphQL Type"::GetCatalogMarkets;
        Parameters.Add('CatalogId', Format(Catalog.Id));
        repeat
            JResponse := this.CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            if JResponse.IsObject() then
                if this.ExtractMarketsLinkedToCatalog(JResponse.AsObject(), Catalog, Cursor) then begin
                    if Parameters.ContainsKey('After') then
                        Parameters.Set('After', Cursor)
                    else
                        Parameters.Add('After', Cursor);
                    GraphQLType := "Shpfy GraphQL Type"::GetNextCatalogMarkets;
                end else
                    break;
        until not this.JsonHelper.GetValueAsBoolean(JResponse, 'data.catalog.markets.pageInfo.hasNextPage');
    end;

    local procedure ClearCatalogMarketRelations(Catalog: Record "Shpfy Catalog")
    var
        MarketCatalogRelation: Record "Shpfy Market Catalog Relation";
    begin
        MarketCatalogRelation.SetRange("Shop Code", Shop.Code);
        MarketCatalogRelation.SetRange("Catalog Id", Catalog.Id);
        MarketCatalogRelation.DeleteAll(true);
    end;

    local procedure ExtractMarketsLinkedToCatalog(JResponse: JsonObject; Catalog: Record "Shpfy Catalog"; var Cursor: Text): Boolean
    var
        MarketCatalogRelation: Record "Shpfy Market Catalog Relation";
        MarketId: BigInteger;
        JMarkets: JsonArray;
        JEdge: JsonToken;
        JNode: JsonObject;
    begin
        if this.JsonHelper.GetJsonArray(JResponse, JMarkets, 'data.catalog.markets.edges') then begin
            foreach JEdge in JMarkets do begin
                Cursor := this.JsonHelper.GetValueAsText(JEdge.AsObject(), 'cursor');
                if this.JsonHelper.GetJsonObject(JEdge.AsObject(), JNode, 'node') then begin
                    MarketId := this.CommunicationMgt.GetIdOfGId(this.JsonHelper.GetValueAsText(JNode, 'id'));

                    MarketCatalogRelation.SetRange("Market Id", MarketId);
                    MarketCatalogRelation.SetRange("Catalog Id", Catalog.Id);
                    if not MarketCatalogRelation.FindFirst() then begin
                        MarketCatalogRelation."Market Id" := MarketId;
                        MarketCatalogRelation."Catalog Id" := Catalog.Id;
                        MarketCatalogRelation.Insert(true);
                    end;
                    MarketCatalogRelation."Shop Code" := this.Shop.Code;
                    MarketCatalogRelation."Market Name" := CopyStr(JsonHelper.GetValueAsText(JNode, 'name'), 1, MaxStrLen(MarketCatalogRelation."Market Name"));
                    MarketCatalogRelation."Catalog Title" := Catalog.Name;
                    MarketCatalogRelation.Modify(true);
                end;
            end;
            exit(true);
        end;
    end;

    internal procedure GetIncludedProductsInCatalog(Catalog: Record "Shpfy Catalog"; var ProductList: List of [BigInteger])
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        Cursor: Text;
        JResponse: JsonToken;
        Parameters: Dictionary of [Text, Text];
    begin
        GraphQLType := "Shpfy GraphQL Type"::GetCatalogProducts;
        Parameters.Add('CatalogId', Format(Catalog.Id));
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            if JResponse.IsObject() then
                if ExtractShopifyCatalogProducts(ProductList, JResponse.AsObject(), Catalog, Cursor) then begin
                    if Parameters.ContainsKey('After') then
                        Parameters.Set('After', Cursor)
                    else
                        Parameters.Add('After', Cursor);
                    GraphQLType := "Shpfy GraphQL Type"::GetNextCatalogProducts;
                end else
                    break;
        until not JsonHelper.GetValueAsBoolean(JResponse, 'data.catalog.publication.products.pageInfo.hasNextPage');
    end;

    internal procedure ExtractShopifyCatalogProducts(var ProductList: List of [BigInteger]; JResponse: JsonObject; Catalog: Record "Shpfy Catalog"; var Cursor: Text): Boolean
    var
        JCatalogProducts: JsonArray;
        JEdge: JsonToken;
        JCatalog: JsonObject;
        JNode: JsonObject;
        ProductId: BigInteger;
    begin
        if not JsonHelper.GetJsonObject(JResponse, JCatalog, 'data.catalog') then begin
            SkippedRecord.LogSkippedRecord(Catalog.Id, Catalog.RecordId, CatalogNotFoundLbl, Shop);
            exit(false);
        end;

        if JsonHelper.GetJsonArray(JCatalog, JCatalogProducts, 'publication.products.edges') then begin
            foreach JEdge in JCatalogProducts do begin
                Cursor := JsonHelper.GetValueAsText(JEdge.AsObject(), 'cursor');
                if JsonHelper.GetJsonObject(JEdge.AsObject(), JNode, 'node') then begin
                    ProductId := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JNode, 'id'));
                    ProductList.Add(ProductId);
                end;
            end;
            exit(true);
        end;
    end;

    internal procedure GetCatalogProductsURL(CatalogId: BigInteger): Text
    begin
        case this.CatalogType of
            "Shpfy Catalog Type"::Company:
                exit(StrSubstNo(this.ShopifyCatalogURLLbl, this.Shop."Shopify URL".Substring(1, this.Shop."Shopify URL".IndexOf('.myshopify.com') - 1).Replace('https://', ''), Format(CatalogId)));
            "Shpfy Catalog Type"::Market:
                if this.IsUnifiedMarketsEnabled(this.Shop) then
                    exit(StrSubstNo(this.ShopifyUnifiedMarketCatalogURLLbl, this.Shop."Shopify URL".Substring(1, this.Shop."Shopify URL".IndexOf('.myshopify.com') - 1).Replace('https://', ''), Format(CatalogId)))
                else
                    exit(StrSubstNo(this.ShopifyMarketCatalogURLLbl, this.Shop."Shopify URL".Substring(1, this.Shop."Shopify URL".IndexOf('.myshopify.com') - 1).Replace('https://', ''), Format(this.GetMartetIdForNotUnifiedMarket(CatalogId))));
        end;
    end;

    internal procedure IsUnifiedMarketsEnabled(ShopifyShop: Record "Shpfy Shop"): Boolean
    var
        JResponse: JsonToken;
    begin
        this.CommunicationMgt.SetShop(ShopifyShop);
        JResponse := this.CommunicationMgt.ExecuteGraphQL('{"query":"query { shop { features { unifiedMarkets } } }"}');
        exit(this.JsonHelper.GetValueAsBoolean(JResponse, 'data.shop.features.unifiedMarkets'));
    end;

    local procedure GetMartetIdForNotUnifiedMarket(CatalogId: BigInteger): BigInteger
    var
        MarketCatalogRelation: Record "Shpfy Market Catalog Relation";
    begin
        MarketCatalogRelation.SetRange("Catalog Id", CatalogId);
        MarketCatalogRelation.SetRange("Shop Code", this.Shop.Code);
        if MarketCatalogRelation.FindFirst() then
            exit(MarketCatalogRelation."Market Id");
    end;

    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
        CommunicationMgt.SetShop(Shop);
    end;

    internal procedure SetCatalogType(ShopifyCatalogType: Enum "Shpfy Catalog Type")
    begin
        this.CatalogType := ShopifyCatalogType;
    end;
}