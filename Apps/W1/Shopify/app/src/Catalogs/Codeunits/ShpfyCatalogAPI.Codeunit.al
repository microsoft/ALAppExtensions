namespace Microsoft.Integration.Shopify;

using Microsoft.Finance.GeneralLedger.Setup;

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
        ShopifyCatalogURLLbl: Label 'https://admin.shopify.com/store/%1/catalogs/%2/editor', Comment = '%1 - Shop Name, %2 - Catalog Id', Locked = true;

    internal procedure CreateCatalog(ShopifyCompany: Record "Shpfy Company")
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

    internal procedure GetCatalogPrices(CatalogId: BigInteger; var TempCatalogPrice: Record "Shpfy Catalog Price" temporary)
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        Cursor: Text;
        JResponse: JsonToken;
        ProductList: List of [BigInteger];
        Parameters: Dictionary of [Text, Text];
    begin
        GetIncludedProductsInCatalog(CatalogId, ProductList);
        GraphQLType := "Shpfy GraphQL Type"::GetCatalogPrices;
        Parameters.Add('CatalogId', Format(CatalogId));
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
        if TempCatalogPrice.Price <> Price then begin
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
                    Catalog.Id := CatalogId;
                    Catalog."Company SystemId" := ShopifyCompany.SystemId;
                    Catalog."Shop Code" := Shop.Code;
                    Catalog.Name := CopyStr(JsonHelper.GetValueAsText(JNode, 'title'), 1, MaxStrLen(Catalog.Name));

                    Catalog.SetRange(Id, CatalogId);
                    Catalog.SetRange("Company SystemId", ShopifyCompany.SystemId);
                    if Catalog.IsEmpty() then begin
                        Catalog.Insert();
                        Catalog."Sync Prices" := false;
                    end else begin
                        Catalog.FindFirst();
                        Catalog.Modify();
                    end;
                end;
            end;
            exit(true);
        end;
    end;

    internal procedure GetIncludedProductsInCatalog(CatalogId: BigInteger; var ProductList: List of [BigInteger])
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        Cursor: Text;
        JResponse: JsonToken;
        Parameters: Dictionary of [Text, Text];
    begin
        GraphQLType := "Shpfy GraphQL Type"::GetCatalogProducts;
        Parameters.Add('CatalogId', Format(CatalogId));
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            if JResponse.IsObject() then
                if ExtractShopifyCatalogProducts(ProductList, JResponse.AsObject(), Cursor) then begin
                    if Parameters.ContainsKey('After') then
                        Parameters.Set('After', Cursor)
                    else
                        Parameters.Add('After', Cursor);
                    GraphQLType := "Shpfy GraphQL Type"::GetNextCatalogProducts;
                end else
                    break;
        until not JsonHelper.GetValueAsBoolean(JResponse, 'data.catalog.publication.products.pageInfo.hasNextPage');
    end;

    internal procedure ExtractShopifyCatalogProducts(var ProductList: List of [BigInteger]; JResponse: JsonObject; var Cursor: Text): Boolean
    var
        JCatalogProducts: JsonArray;
        JEdge: JsonToken;
        JNode: JsonObject;
        ProductId: BigInteger;
    begin
        if JsonHelper.GetJsonArray(JResponse, JCatalogProducts, 'data.catalog.publication.products.edges') then begin
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
        exit(StrSubstNo(ShopifyCatalogURLLbl, Shop."Shopify URL".Substring(1, Shop."Shopify URL".IndexOf('.myshopify.com') - 1).TrimStart('https://'), Format(CatalogId)));
    end;

    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
        CommunicationMgt.SetShop(Shop);
    end;
}