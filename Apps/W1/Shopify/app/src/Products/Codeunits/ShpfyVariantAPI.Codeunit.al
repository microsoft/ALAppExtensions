// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy Variant API (ID 30189).
/// </summary>
codeunit 30189 "Shpfy Variant API"
{
    Access = Internal;

    var
        Shop: Record "Shpfy Shop";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";
        ProductEvents: Codeunit "Shpfy Product Events";
        MetafieldAPI: Codeunit "Shpfy Metafield API";


    /// <summary> 
    /// Find Shopify Product Variant.
    /// </summary>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <returns>Return variable "Found" of type Boolean.</returns>
    internal procedure FindShopifyProductVariant(var ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant") Found: Boolean;
    var
        Product: Record "Shpfy Product";
        Variant: Record "Shpfy Variant";
        ProductImport: Codeunit "Shpfy Product Import";
    begin
        Found := FindShopifyVariantBySKU(ShopifyVariant);
        if not Found then
            Found := FindShopifyVariantByBarcode(ShopifyVariant);
        if Found then begin
            ShopifyProduct.Id := ShopifyVariant."Product Id";
            if not Product.Get(ShopifyProduct.Id) then begin
                ProductImport.SetShop(ShopifyProduct."Shop Code");
                ProductImport.SetProduct(ShopifyProduct.Id);
                Commit();
                if ProductImport.Run() then;
                if Product.Get(ShopifyProduct.Id) and IsNullGuid(Product."Item SystemId") then begin
                    Product."Item SystemId" := ShopifyProduct."Item SystemId";
                    Product.Modify();
                end;
            end;
            if Variant.Get(ShopifyVariant.Id) then begin
                if IsNullGuid(Variant."Item Variant SystemId") then begin
                    Variant."Item Variant SystemId" := ShopifyVariant."Item Variant SystemId";
                    Variant."Item SystemId" := ShopifyVariant."Item SystemId";
                    Variant.Modify();
                end;
            end else begin
                Clear(Variant);
                Variant := ShopifyVariant;
                Variant.Insert();
            end;
        end;
    end;

    internal procedure AddProductVariant(var ShopifyVariant: Record "Shpfy Variant" temporary; ProductId: BigInteger; Strategy: Enum "Shpfy Variant Create Strategy"): Boolean
    var
        InventoryQuantities: Text;
        GraphQuery: TextBuilder;
        JResponse: JsonToken;
        JVariants: JsonArray;
        JVariant: JsonToken;
    begin
        InventoryQuantities := GetInventoryQuantities();
        GraphQuery.Append('{"query":"mutation { productVariantsBulkCreate(productId: \"gid://shopify/Product/');
        GraphQuery.Append(Format(ProductId));
        GraphQuery.Append('\", strategy: ');
        GraphQuery.Append(Format(Strategy));
        GraphQuery.Append(', variants: [');
        ShopifyVariant."Product Id" := ProductId;
        GraphQuery.Append(GetVariantGraphQuery(ShopifyVariant, InventoryQuantities).ToText());
        GraphQuery.Append(']) {productVariants {legacyResourceId, createdAt, updatedAt}, userErrors {field, message}}}"}');

        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQuery.ToText());
        if JsonHelper.GetJsonArray(JResponse, JVariants, 'data.productVariantsBulkCreate.productVariants') then
            if JVariants.Count = 1 then begin
                JVariants.Get(0, JVariant);
                exit(CreateNewVariant(JVariant, ShopifyVariant, ProductId));
            end;
        exit(false);
    end;

    internal procedure AddProductVariants(var ShopifyVariant: Record "Shpfy Variant" temporary; ProductId: BigInteger; Strategy: Enum "Shpfy Variant Create Strategy")
    var
        TempNewShopifyVariant: Record "Shpfy Variant" temporary;
        InventoryQuantities: Text;
        GraphQuery: TextBuilder;
        VariantGraphQuery: TextBuilder;
        JResponse: JsonToken;
        JVariants: JsonArray;
        ReturnQuery: Text;
    begin
        ReturnQuery := ']) {productVariants {legacyResourceId, createdAt, updatedAt}, userErrors {field, message}}}"}';

        if ShopifyVariant.FindSet() then begin
            InventoryQuantities := GetInventoryQuantities();
            GraphQuery.Append('{"query":"mutation { productVariantsBulkCreate(productId: \"gid://shopify/Product/');
            GraphQuery.Append(Format(ProductId));
            GraphQuery.Append('\", strategy: ');
            GraphQuery.Append(Format(Strategy));
            GraphQuery.Append(', variants: [');
            repeat
                ShopifyVariant."Product Id" := ProductId;
                VariantGraphQuery := GetVariantGraphQuery(ShopifyVariant, InventoryQuantities);
                if GraphQuery.Length() + VariantGraphQuery.Length() + StrLen(ReturnQuery) < CommunicationMgt.GetGraphQueryLengthThreshold() then begin
                    GraphQuery.Append(VariantGraphQuery.ToText() + ', ');
                    TempNewShopifyVariant := ShopifyVariant;
                    TempNewShopifyVariant.Insert();
                end else begin
                    GraphQuery.Remove(GraphQuery.Length - 1, 2);
                    GraphQuery.Append(ReturnQuery);
                    JResponse := CommunicationMgt.ExecuteGraphQL(GraphQuery.ToText());
                    if JsonHelper.GetJsonArray(JResponse, JVariants, 'data.productVariantsBulkCreate.productVariants') then
                        CreateNewVariants(JVariants, TempNewShopifyVariant, ProductId);

                    TempNewShopifyVariant.DeleteAll();
                    TempNewShopifyVariant := ShopifyVariant;
                    TempNewShopifyVariant.Insert();
                    GraphQuery.Clear();
                    GraphQuery.Append('{"query":"mutation { productVariantsBulkCreate(productId: \"gid://shopify/Product/');
                    GraphQuery.Append(Format(ProductId));
                    GraphQuery.Append('\", strategy: ');
                    GraphQuery.Append(Format(Strategy));
                    GraphQuery.Append(', variants: [');
                    GraphQuery.Append(VariantGraphQuery.ToText() + ', ');
                end;
            until ShopifyVariant.Next() = 0;
            GraphQuery.Remove(GraphQuery.Length - 1, 2);
            GraphQuery.Append(ReturnQuery);

            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQuery.ToText());
            if JsonHelper.GetJsonArray(JResponse, JVariants, 'data.productVariantsBulkCreate.productVariants') then
                CreateNewVariants(JVariants, TempNewShopifyVariant, ProductId);
        end;
    end;

    local procedure GetVariantGraphQuery(ShopifyVariant: Record "Shpfy Variant"; xShopifyVariant: Record "Shpfy Variant"; var HasChange: Boolean; var TitleChanged: Boolean): TextBuilder
    var
        GraphQuery: TextBuilder;
    begin
        GraphQuery.Append('{id: \"gid://shopify/ProductVariant/');
        GraphQuery.Append(Format(ShopifyVariant.Id));
        GraphQuery.Append('\"');
        if ShopifyVariant."Inventory Policy" <> xShopifyVariant."Inventory Policy" then begin
            HasChange := true;
            GraphQuery.Append(', inventoryPolicy: ');
            GraphQuery.Append(ShopifyVariant."Inventory Policy".Names.Get(ShopifyVariant."Inventory Policy".Ordinals.IndexOf(ShopifyVariant."Inventory Policy".AsInteger())));
        end;
        if ShopifyVariant.Title <> xShopifyVariant.Title then
            TitleChanged := true;
        if ShopifyVariant.Barcode <> xShopifyVariant.Barcode then begin
            HasChange := true;
            GraphQuery.Append(', barcode: \"');
            GraphQuery.Append(ShopifyVariant.Barcode);
            GraphQuery.Append('\"');
        end;
        if ShopifyVariant.Taxable then
            GraphQuery.Append(', taxable: true');
        if ShopifyVariant."Tax Code" <> xShopifyVariant."Tax Code" then begin
            HasChange := true;
            GraphQuery.Append(', taxCode: \"');
            GraphQuery.Append(ShopifyVariant."Tax Code");
            GraphQuery.Append('\"');
        end;
        if ShopifyVariant.Price <> xShopifyVariant.Price then begin
            HasChange := true;
            GraphQuery.Append(', price: \"');
            GraphQuery.Append(Format(ShopifyVariant.Price, 0, 9));
            GraphQuery.Append('\"');
        end;
        if (ShopifyVariant."Compare at Price" <> xShopifyVariant."Compare at Price") then
            if (ShopifyVariant.Price < ShopifyVariant."Compare at Price") then begin
                HasChange := true;
                GraphQuery.Append(', compareAtPrice: \"');
                GraphQuery.Append(Format(ShopifyVariant."Compare at Price", 0, 9));
                GraphQuery.Append('\"');
            end else begin
                HasChange := true;
                GraphQuery.Append(', compareAtPrice: null');
            end;
        if (ShopifyVariant."Unit Cost" <> xShopifyVariant."Unit Cost") or (ShopifyVariant.Weight <> xShopifyVariant.Weight) or (ShopifyVariant.SKU <> xShopifyVariant.SKU) then begin //or UpdateDefaultVariant then begin
            HasChange := true;
            GraphQuery.Append(', inventoryItem: {tracked: ');
            if Shop."Inventory Tracked" then
                GraphQuery.Append('true')
            else
                GraphQuery.Append('false');
            if ShopifyVariant."Unit Cost" <> xShopifyVariant."Unit Cost" then begin
                GraphQuery.Append(', cost: \"');
                GraphQuery.Append(Format(ShopifyVariant."Unit Cost", 0, 9));
                GraphQuery.Append('\"');
            end;
            if ShopifyVariant.SKU <> xShopifyVariant.SKU then begin
                GraphQuery.Append(', sku: \"');
                GraphQuery.Append(ShopifyVariant.SKU);
                GraphQuery.Append('\"');
            end;
            if ShopifyVariant.Weight <> xShopifyVariant.Weight then begin
                GraphQuery.Append(', measurement: {weight: {value:');
                GraphQuery.Append(Format(ShopifyVariant.Weight, 0, 9));
                GraphQuery.Append(', unit: ');
                if Shop."Weight Unit" = Shop."Weight Unit"::" " then begin
                    Shop."Weight Unit" := Shop.GetShopWeightUnit();
                    Shop.Modify();
                end;
                GraphQuery.Append(Shop."Weight Unit".Names.Get(Shop."Weight Unit".Ordinals.IndexOf(Shop."Weight Unit".AsInteger())).Trim().ToUpper().Replace(' ', '_'));
                GraphQuery.Append('}}');
            end;
            GraphQuery.Append('}');
        end;
        GraphQuery.Append('}');
        exit(GraphQuery);
    end;

    local procedure GetVariantGraphQuery(var ShopifyVariant: Record "Shpfy Variant"; InventoryQuantities: Text): TextBuilder
    var
        GraphQuery: TextBuilder;
    begin
        ProductEvents.OnBeforeSendAddShopifyProductVariant(Shop, ShopifyVariant);
        GraphQuery.Append('{ inventoryPolicy: ');
        GraphQuery.Append(ShopifyVariant."Inventory Policy".Names.Get(ShopifyVariant."Inventory Policy".Ordinals.IndexOf(ShopifyVariant."Inventory Policy".AsInteger())));
        if ShopifyVariant.Barcode <> '' then begin
            GraphQuery.Append(', barcode: \"');
            GraphQuery.Append(CommunicationMgt.EscapeGraphQLData(ShopifyVariant.Barcode));
            GraphQuery.Append('\"');
        end;
        if ShopifyVariant.Taxable then
            GraphQuery.Append(', taxable: true');
        if ShopifyVariant."Tax Code" <> '' then begin
            GraphQuery.Append(', taxCode: \"');
            GraphQuery.Append(ShopifyVariant."Tax Code");
            GraphQuery.Append('\"');
        end;
        if ShopifyVariant.Price > 0 then begin
            GraphQuery.Append(', price: \"');
            GraphQuery.Append(Format(ShopifyVariant.Price, 0, 9));
            GraphQuery.Append('\"');
        end;
        if ShopifyVariant."Compare at Price" > ShopifyVariant.Price then begin
            GraphQuery.Append(', compareAtPrice: \"');
            GraphQuery.Append(Format(ShopifyVariant."Compare at Price", 0, 9));
            GraphQuery.Append('\"');
        end;
        if ShopifyVariant."Option 1 Name" <> '' then begin
            GraphQuery.Append(', optionValues: [{ optionName: \"');
            GraphQuery.Append(CommunicationMgt.EscapeGraphQLData(ShopifyVariant."Option 1 Name"));
            GraphQuery.Append('\", name: \"');
            GraphQuery.Append(CommunicationMgt.EscapeGraphQLData(ShopifyVariant."Option 1 Value"));
            if ShopifyVariant."Option 2 Name" <> '' then begin
                GraphQuery.Append('\"}, { optionName: \"');
                GraphQuery.Append(CommunicationMgt.EscapeGraphQLData(ShopifyVariant."Option 2 Name"));
                GraphQuery.Append('\", name: \"');
                GraphQuery.Append(CommunicationMgt.EscapeGraphQLData(ShopifyVariant."Option 2 Value"));
            end;
            if ShopifyVariant."Option 3 Name" <> '' then begin
                GraphQuery.Append('\"}, { optionName: \"');
                GraphQuery.Append(CommunicationMgt.EscapeGraphQLData(ShopifyVariant."Option 3 Name"));
                GraphQuery.Append('\", name: \"');
                GraphQuery.Append(CommunicationMgt.EscapeGraphQLData(ShopifyVariant."Option 3 Value"));
            end;
            GraphQuery.Append('\"}]');
        end;
        if InventoryQuantities <> '' then
            GraphQuery.Append(InventoryQuantities);
        GraphQuery.Append(', inventoryItem: {tracked: ');
        if Shop."Inventory Tracked" then
            GraphQuery.Append('true')
        else
            GraphQuery.Append('false');
        if ShopifyVariant."Unit Cost" > 0 then begin
            GraphQuery.Append(', cost: \"');
            GraphQuery.Append(Format(ShopifyVariant."Unit Cost", 0, 9));
            GraphQuery.Append('\"');
        end;
        if ShopifyVariant.SKU <> '' then begin
            GraphQuery.Append(', sku: \"');
            GraphQuery.Append(CommunicationMgt.EscapeGraphQLData(ShopifyVariant.SKU));
            GraphQuery.Append('\"');
        end;
        if ShopifyVariant.Weight > 0 then begin
            GraphQuery.Append(', measurement: {weight: {value:');
            GraphQuery.Append(Format(ShopifyVariant.Weight, 0, 9));
            GraphQuery.Append(', unit: ');
            if Shop."Weight Unit" = Shop."Weight Unit"::" " then begin
                Shop."Weight Unit" := Shop.GetShopWeightUnit();
                Shop.Modify();
            end;
            GraphQuery.Append(Shop."Weight Unit".Names.Get(Shop."Weight Unit".Ordinals.IndexOf(Shop."Weight Unit".AsInteger())).Trim().ToUpper().Replace(' ', '_'));
            GraphQuery.Append('}}');
        end;
        GraphQuery.Append('}}');
        exit(GraphQuery);
    end;

    local procedure GetInventoryQuantities(): Text
    var
        ShopLocation: Record "Shpfy Shop Location";
        GraphQuery: TextBuilder;
    begin
        ShopLocation.SetRange("Shop Code", Shop.Code);
        ShopLocation.SetRange(Active, true);
        ShopLocation.SetRange("Default Product Location", true);
        if ShopLocation.FindSet(false) then begin
            GraphQuery.Append(', inventoryQuantities: [');
            repeat
                GraphQuery.Append('{availableQuantity: 0, locationId: \"gid://shopify/Location/');
                GraphQuery.Append(Format(ShopLocation.Id));
                GraphQuery.Append('\"}, ');
            until ShopLocation.Next() = 0;
            GraphQuery.Remove(GraphQuery.Length - 1, 2);
            GraphQuery.Append(']');
        end;
        exit(GraphQuery.ToText());
    end;

    local procedure CreateNewVariant(JVariant: JsonToken; var ShopifyVariant: Record "Shpfy Variant"; ProductId: BigInteger): Boolean
    var
        NewShopifyVariant: Record "Shpfy Variant";
    begin
        NewShopifyVariant := ShopifyVariant;
        NewShopifyVariant.Id := JsonHelper.GetValueAsBigInteger(JVariant, 'legacyResourceId');
        NewShopifyVariant."Product Id" := ProductId;
        NewShopifyVariant."Created At" := JsonHelper.GetValueAsDateTime(JVariant, 'createdAt');
        NewShopifyVariant."Updated At" := JsonHelper.GetValueAsDateTime(JVariant, 'updatedAt');
        if NewShopifyVariant.Id > 0 then begin
            NewShopifyVariant.Insert();
            exit(true);
        end;
    end;

    local procedure CreateNewVariants(JVariants: JsonArray; var ShopifyVariant: Record "Shpfy Variant" temporary; ProductId: BigInteger)
    var
        JVariant: JsonToken;
        Index: Integer;
    begin
        if JVariants.Count = 0 then
            exit;
        Index := 0;
        ShopifyVariant.FindSet();
        repeat
            if JVariants.Get(Index, JVariant) then
                CreateNewVariant(JVariant, ShopifyVariant, ProductId);
            Index += 1;
        until ShopifyVariant.Next() = 0;
    end;

    /// <summary> 
    /// Find Shopify Variant By Barcode.
    /// </summary>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <returns>Return value of type Boolean.</returns>
    internal procedure FindShopifyVariantByBarcode(var ShopifyVariant: Record "Shpfy Variant"): Boolean
    var
        Parameters: Dictionary of [Text, Text];
        GraphQLType: Enum "Shpfy GraphQL Type";
        JArray: JsonArray;
        JItem: JsonToken;
        JResponse: JsonToken;
    begin
        if ShopifyVariant.Barcode = '' then
            exit(false);

        Parameters.Add('Barcode', ShopifyVariant.Barcode.Replace('.', '\\\\.'));
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType::FindVariantByBarcode, Parameters);
        if JsonHelper.GetJsonArray(JResponse, JArray, 'data.productVariants.edges') then
            if JArray.Count = 1 then
                if JArray.Get(0, JItem) then begin
                    ShopifyVariant.Id := JsonHelper.GetValueAsBigInteger(JItem, 'node.legacyResourceId');
                    ShopifyVariant."Product Id" := JsonHelper.GetValueAsBigInteger(JItem, 'node.product.legacyResourceId');
                    exit(true);
                end;
    end;

    /// <summary> 
    /// Find Shopify Variant By SKU.
    /// </summary>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <returns>Return value of type Boolean.</returns>
    internal procedure FindShopifyVariantBySKU(var ShopifyVariant: Record "Shpfy Variant"): Boolean
    var
        Parameters: Dictionary of [Text, Text];
        GraphQLType: Enum "Shpfy GraphQL Type";
        JArray: JsonArray;
        JItem: JsonToken;
        JResponse: JsonToken;
    begin
        if ShopifyVariant.SKU = '' then
            exit(false);

        Parameters.Add('SKU', ShopifyVariant.SKU.Replace('.', '\\\\.'));
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType::FindVariantBySKU, Parameters);
        if JsonHelper.GetJsonArray(JResponse, JArray, 'data.productVariants.edges') then
            if JArray.Count = 1 then
                if JArray.Get(0, JItem) then begin
                    ShopifyVariant.Id := JsonHelper.GetValueAsBigInteger(JItem, 'node.legacyResourceId');
                    ShopifyVariant."Product Id" := JsonHelper.GetValueAsBigInteger(JItem, 'node.product.legacyResourceId');
                    exit(true);
                end;
    end;

    /// <summary> 
    /// Description for GetImageData.
    /// </summary>
    /// <param name="JImageNode">Parameter of type JsonToken.</param>
    /// <param name="ImageData">Parameter of type Dictionary of [BigInteger, Text].</param>
    local procedure GetImageData(JImageNode: JsonToken; var ImageData: Dictionary of [BigInteger, Text])
    var
        Data: Dictionary of [BigInteger, Text];
    begin
        Data.Add(CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JImageNode, 'node.id')), JsonHelper.GetValueAsText(JImageNode, 'node.image.url'));
        ImageData := Data;
    end;

    /// <summary> 
    /// Description for RetrieveShopifyProductVaraintImages.
    /// </summary>
    /// <param name="ProductVariantImages">Parameter of type Dictionary of [BigInteger, Dictionary of [BigInteger, Text]].</param>
    internal procedure RetrieveShopifyProductVariantImages(var ProductVariantImages: Dictionary of [BigInteger, Dictionary of [BigInteger, Text]])
    var
        Id: BigInteger;
        ImageData: Dictionary of [BigInteger, Text];
        Parameters: Dictionary of [Text, Text];
        GraphQLType: Enum "Shpfy GraphQL Type";
        JImages: JsonArray;
        JProductVariants: JsonArray;
        JImage: JsonToken;
        JNode: JsonObject;
        JItem: JsonToken;
        JResponse: JsonToken;
        Cursor: Text;
    begin
        Clear(ProductVariantImages);
        GraphQLType := GraphQLType::GetProductVariantImages;
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            if JsonHelper.GetJsonArray(JResponse, JProductVariants, 'data.productVariants.edges') then begin
                foreach JItem in JProductVariants do begin
                    Cursor := JsonHelper.GetValueAsText(JItem.AsObject(), 'cursor');
                    if JsonHelper.GetJsonObject(JItem.AsObject(), JNode, 'node') then begin
                        Id := JsonHelper.GetValueAsBigInteger(JNode, 'legacyResourceId');
                        if JsonHelper.GetJsonArray(JNode, JImages, 'media.edges') then
                            if JImages.Count = 1 then begin
                                JImages.Get(0, JImage);
                                GetImageData(JImage, ImageData);
                            end else
                                Clear(ImageData);
                        ProductVariantImages.Add(Id, ImageData);
                    end;
                end;
                if Parameters.ContainsKey('After') then
                    Parameters.Set('After', Cursor)
                else
                    Parameters.Add('After', Cursor);
            end;
            GraphQLType := GraphQLType::GetNextProductVariantImages;
        until not JsonHelper.GetValueAsBoolean(JResponse, 'data.productVariants.pageInfo.hasNextPage');
    end;

    /// <summary> 
    /// Retrieve Shopify Product Variant Ids.
    /// </summary>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ProductVariantIds">Parameter of type Dictionary of [BigInteger, DateTime].</param>
    internal procedure RetrieveShopifyProductVariantIds(ShopifyProduct: Record "Shpfy Product"; var ProductVariantIds: Dictionary of [BigInteger, DateTime])
    var
        Id: BigInteger;
        UpdatedAt: DateTime;
        Parameters: Dictionary of [Text, Text];
        GraphQLType: Enum "Shpfy GraphQL Type";
        JVariants: JsonArray;
        JNode: JsonObject;
        JItem: JsonToken;
        JResponse: JsonToken;
        Cursor: Text;
    begin
        Clear(ProductVariantIds);
        GraphQLType := GraphQLType::GetProductVariantIds;
        Parameters.Add('ProductId', Format(ShopifyProduct.Id));
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            if JsonHelper.GetJsonArray(JResponse, JVariants, 'data.product.variants.edges') then begin
                foreach JItem in JVariants do begin
                    Cursor := JsonHelper.GetValueAsText(JItem.AsObject(), 'cursor');
                    if JsonHelper.GetJsonObject(JItem.AsObject(), JNode, 'node') then begin
                        Id := JsonHelper.GetValueAsBigInteger(JNode, 'legacyResourceId');
                        UpdatedAt := JsonHelper.GetValueAsDateTime(JNode, 'updatedAt');
                        ProductVariantIds.Add(Id, UpdatedAt);
                    end;
                end;
                GraphQLType := GraphQLType::GetNextProductVariantIds;
                if Parameters.ContainsKey('After') then
                    Parameters.Set('After', Cursor)
                else
                    Parameters.Add('After', Cursor);
            end;
        until not JsonHelper.GetValueAsBoolean(JResponse, 'data.product.variants.pageInfo.hasNextPage');
    end;

    /// <summary> 
    /// Retrieve Shopify Variant.
    /// </summary>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="ShopifyInventoryItem">Parameter of type Record "Shopify Inventory Item".</param>
    /// <returns>Return value of type Boolean.</returns>
    internal procedure RetrieveShopifyVariant(ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; var ShopifyInventoryItem: Record "Shpfy Inventory Item"): Boolean
    var
        Parameters: Dictionary of [Text, Text];
        GraphQLType: Enum "Shpfy GraphQL Type";
        JData: JsonObject;
        JResponse: JsonToken;
    begin
        Parameters.Add('VariantId', Format(ShopifyVariant.Id));
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType::GetVariantById, Parameters);
        if JsonHelper.GetJsonObject(JResponse.AsObject(), JData, 'data.productVariant') then
            exit(UpdateShopifyVariantFields(ShopifyProduct, ShopifyVariant, ShopifyInventoryItem, JData));
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
        CommunicationMgt.SetShop(Shop);
        MetafieldAPI.SetShop(Shop);
    end;

    internal procedure UpdateProductVariants(var ShopifyVariant: Record "Shpfy Variant")
    var
        CurrShopifyVariant: Record "Shpfy Variant";
        xShopifyVariant: Record "Shpfy Variant";
        HasChange: Boolean;
        TitleChanged: Boolean;
        JResponse: JsonToken;
        JVariants: JsonArray;
        GraphQuery: TextBuilder;
        VariantGraphQuery: TextBuilder;
        ReturnQuery: Text;
    begin
        ReturnQuery := ']) {productVariants {legacyResourceId updatedAt}, userErrors {field, message}}}"}';

        if ShopifyVariant.FindSet() then begin
            GraphQuery.Append('{"query":"mutation { productVariantsBulkUpdate(productId: \"gid://shopify/Product/');
            GraphQuery.Append(Format(ShopifyVariant."Product Id"));
            GraphQuery.Append('\", variants: [');
            repeat
                HasChange := false;
                TitleChanged := false;
                xShopifyVariant.Get(ShopifyVariant.Id);
                ProductEvents.OnBeforeSendUpdateShopifyProductVariant(Shop, ShopifyVariant, xShopifyVariant);
                VariantGraphQuery := GetVariantGraphQuery(ShopifyVariant, xShopifyVariant, HasChange, TitleChanged);

                if HasChange then begin
                    if GraphQuery.Length() + VariantGraphQuery.Length() + StrLen(ReturnQuery) < CommunicationMgt.GetGraphQueryLengthThreshold() then
                        GraphQuery.Append(VariantGraphQuery.ToText() + ', ')
                    else begin
                        GraphQuery.Remove(GraphQuery.Length - 1, 2);
                        GraphQuery.Append(ReturnQuery);

                        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQuery.ToText());
                        if JsonHelper.GetJsonArray(JResponse, JVariants, 'data.productVariantsBulkUpdate.productVariants') then
                            UpdateVariants(JVariants, ShopifyVariant);

                        GraphQuery.Clear();
                        GraphQuery.Append('{"query":"mutation { productVariantsBulkUpdate(productId: \"gid://shopify/Product/');
                        GraphQuery.Append(Format(ShopifyVariant."Product Id"));
                        GraphQuery.Append('\", variants: [');
                    end;
                end else
                    if TitleChanged then begin
                        CurrShopifyVariant.Get(ShopifyVariant.Id);
                        CurrShopifyVariant.TransferFields(ShopifyVariant);
                        CurrShopifyVariant.Modify()
                    end;
            until ShopifyVariant.Next() = 0;
            GraphQuery.Remove(GraphQuery.Length - 1, 2);
            GraphQuery.Append(ReturnQuery);

            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQuery.ToText());
            if JsonHelper.GetJsonArray(JResponse, JVariants, 'data.productVariantsBulkUpdate.productVariants') then
                UpdateVariants(JVariants, ShopifyVariant);
        end;
    end;

    local procedure UpdateVariants(JVariants: JsonArray; var TempShopifyVariant: Record "Shpfy Variant" temporary)
    var
        ShopifyVariant: Record "Shpfy Variant";
        Id: BigInteger;
        JVariant: JsonToken;
        UpdatedAt: DateTime;
    begin
        foreach JVariant in JVariants do begin
            UpdatedAt := JsonHelper.GetValueAsDateTime(JVariant, 'updatedAt');
            Id := JsonHelper.GetValueAsBigInteger(JVariant, 'legacyResourceId');
            if UpdatedAt > 0DT then begin
                ShopifyVariant.Get(Id);
                TempShopifyVariant.Get(Id);
                ShopifyVariant := TempShopifyVariant;
                ShopifyVariant."Updated At" := UpdatedAt;
                if ShopifyVariant."Updated At" > 0DT then
                    ShopifyVariant.Modify();
            end;
        end;
    end;

    internal procedure UpdateProductPrice(ShopifyVariant: Record "Shpfy Variant"; xShopifyVariant: Record "Shpfy Variant"; var BulkOperationInput: TextBuilder; var GraphQueryList: Dictionary of [BigInteger, TextBuilder]; RecordCount: Integer; var JRequestData: JsonArray)
    var
        BulkOperationMgt: Codeunit "Shpfy Bulk Operation Mgt.";
        BulkOperationType: Enum "Shpfy Bulk Operation Type";
        IBulkOperation: Interface "Shpfy IBulk Operation";
        HasChange: Boolean;
        IsBulkOperationEnabled: Boolean;
        JResponse: JsonToken;
        JVariant: JsonToken;
        JVariants: JsonArray;
        JRequest: JsonObject;
        GraphQuery: TextBuilder;
        Price: Text;
        CompareAtPrice: Text;
    begin
        IsBulkOperationEnabled := RecordCount >= BulkOperationMgt.GetBulkOperationThreshold();
        GraphQuery.Append('{"query":"mutation { productVariantsBulkUpdate(productId: \"gid://shopify/Product/');
        GraphQuery.Append(Format(ShopifyVariant."Product Id"));
        GraphQuery.Append('\", variants: [{id: \"gid://shopify/ProductVariant/');
        GraphQuery.Append(Format(ShopifyVariant.Id));
        GraphQuery.Append('\"');
        if ShopifyVariant.Price <> xShopifyVariant.Price then begin
            HasChange := true;
            GraphQuery.Append(', price: \"');
            GraphQuery.Append(Format(ShopifyVariant.Price, 0, 9));
            GraphQuery.Append('\"');
            if IsBulkOperationEnabled then
                Price := Format(ShopifyVariant.Price, 0, 9);
        end;
        if (ShopifyVariant."Compare at Price" <> xShopifyVariant."Compare at Price") then
            if (ShopifyVariant.Price < ShopifyVariant."Compare at Price") then begin
                HasChange := true;
                GraphQuery.Append(', compareAtPrice: \"');
                GraphQuery.Append(Format(ShopifyVariant."Compare at Price", 0, 9));
                GraphQuery.Append('\"');
                if IsBulkOperationEnabled then
                    CompareAtPrice := Format(ShopifyVariant."Compare at Price", 0, 9);
            end else begin
                HasChange := true;
                GraphQuery.Append(', compareAtPrice: null');
                CompareAtPrice := '0';
            end;

        GraphQuery.Append('}]) {productVariants {updatedAt}, userErrors {field, message}}}"}');

        if HasChange then
            if IsBulkOperationEnabled then begin
                IBulkOperation := BulkOperationType::UpdateProductPrice;
                if Price = '' then
                    Price := Format(ShopifyVariant.Price, 0, 9);
                if CompareAtPrice = '' then
                    CompareAtPrice := Format(ShopifyVariant."Compare at Price", 0, 9);

                GraphQueryList.Add(ShopifyVariant.Id, GraphQuery);
                JRequest.Add('id', ShopifyVariant.Id);
                JRequest.Add('price', xShopifyVariant.Price);
                JRequest.Add('compareAtPrice', xShopifyVariant."Compare at Price");
                JRequest.Add('updatedAt', xShopifyVariant."Updated At");
                JRequestData.Add(JRequest);

                BulkOperationInput.AppendLine(StrSubstNo(IBulkOperation.GetInput(), ShopifyVariant."Product Id", ShopifyVariant.Id, Price, CompareAtPrice));
                ShopifyVariant."Updated At" := CurrentDateTime();
                ShopifyVariant.Modify();
            end else begin
                JResponse := CommunicationMgt.ExecuteGraphQL(GraphQuery.ToText());
                if JsonHelper.GetJsonArray(JResponse, JVariants, 'data.productVariantsBulkUpdate.productVariants') then
                    if JVariants.Get(0, JVariant) then begin
                        ShopifyVariant."Updated At" := JsonHelper.GetValueAsDateTime(JVariant, 'updatedAt');
                        if ShopifyVariant."Updated At" > 0DT then
                            ShopifyVariant.Modify();
                    end;
            end;
    end;

    [TryFunction]
    internal procedure UpdateProductPrice(GraphQuery: TextBuilder)
    var
        JVariants: JsonArray;
        JVariant: JsonToken;
        JResponse: JsonToken;
        VariantUpdateFailedErr: Label 'Failed to update variant price.';
    begin
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQuery.ToText());
        if JsonHelper.GetJsonArray(JResponse, JVariants, 'data.productVariantsBulkUpdate.productVariants') then
            if JVariants.Get(0, JVariant) then
                if JsonHelper.GetValueAsDateTime(JVariant, 'updatedAt') <= 0DT then
                    Error(VariantUpdateFailedErr);
    end;

    /// <summary> 
    /// Update Shopify Variant Fields.
    /// </summary>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="ShopifyInventoryItem">Parameter of type Record "Shopify Inventory Item".</param>
    /// <param name="JVariant">Parameter of type JsonObject.</param>
    /// <returns>Return variable "Result" of type Boolean.</returns>
    internal procedure UpdateShopifyVariantFields(ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; var ShopifyInventoryItem: Record "Shpfy Inventory Item"; JVariant: JsonObject) Result: Boolean
    var
        RecordRef: RecordRef;
        UpdatedAt: DateTime;
        JMetafields: JsonArray;
        JOptions: JsonArray;
        JNode: JsonObject;
        JItem: JsonToken;
    begin
        UpdatedAt := JsonHelper.GetValueAsDateTime(JVariant, 'updatedAt');
        if UpdatedAt < ShopifyVariant."Updated At" then
            exit(false);

        Result := true;
        ShopifyVariant."Updated At" := UpdatedAt;
        ShopifyVariant."Created At" := JsonHelper.GetValueAsDateTime(JVariant, 'createdAt');
        ShopifyVariant."Available For Sales" := JsonHelper.GetValueAsBoolean(JVariant, 'availableForSale');
#pragma warning disable AA0139
        ShopifyVariant.Barcode := JsonHelper.GetValueAsText(JVariant, 'barcode', MaxStrLen(ShopifyVariant.Barcode));
        ShopifyVariant."Display Name" := JsonHelper.GetValueAsText(JVariant, 'displayName', MaxStrLen(ShopifyVariant."Display Name"));
        ShopifyVariant."Tax Code" := JsonHelper.GetValueAsText(JVariant, 'taxCode', MaxStrLen(ShopifyVariant."Tax Code"));
        ShopifyVariant.SKU := JsonHelper.GetValueAsText(JVariant, 'sku', MaxStrLen(ShopifyVariant.SKU));
        ShopifyVariant.Title := JsonHelper.GetValueAsText(JVariant, 'title', MaxStrLen(ShopifyVariant.Title));
#pragma warning restore AA0139
        ShopifyVariant."Compare at Price" := JsonHelper.GetValueAsDecimal(JVariant, 'compareAtPrice');
        if Evaluate(ShopifyVariant."Inventory Policy", JsonHelper.GetValueAsText(JVariant, 'inventoryPolicy')) then;
        ShopifyVariant.Position := JsonHelper.GetValueAsInteger(JVariant, 'position');
        ShopifyVariant.Price := JsonHelper.GetValueAsDecimal(JVariant, 'price');
        ShopifyVariant.Taxable := JsonHelper.GetValueAsBoolean(JVariant, 'taxable');
        ShopifyVariant.Weight := JsonHelper.GetValueAsDecimal(JVariant, 'inventoryItem.measurement.weight.value');
        ShopifyVariant."Unit Cost" := JsonHelper.GetValueAsDecimal(JVariant, 'inventoryItem.unitCost.amount');

        RecordRef.GetTable(ShopifyVariant);
        Clear(ShopifyVariant."Option 1 Name");
        Clear(ShopifyVariant."Option 1 Value");
        Clear(ShopifyVariant."Option 2 Name");
        Clear(ShopifyVariant."Option 2 Value");
        Clear(ShopifyVariant."Option 3 Name");
        Clear(ShopifyVariant."Option 3 Value");
        if JsonHelper.GetJsonArray(JVariant, JOptions, 'selectedOptions') then begin
            Clear(JItem);
            foreach JItem in JOptions do
                case Joptions.IndexOf(JItem) of
                    0:
                        begin
                            JsonHelper.GetValueIntoField(JItem, 'name', RecordRef, ShopifyVariant.FieldNo("Option 1 Name"));
                            JsonHelper.GetValueIntoField(JItem, 'value', RecordRef, ShopifyVariant.FieldNo("Option 1 Value"));
                        end;
                    1:
                        begin
                            JsonHelper.GetValueIntoField(JItem, 'name', RecordRef, ShopifyVariant.FieldNo("Option 2 Name"));
                            JsonHelper.GetValueIntoField(JItem, 'value', RecordRef, ShopifyVariant.FieldNo("Option 2 Value"));
                        end;
                    2:
                        begin
                            JsonHelper.GetValueIntoField(JItem, 'name', RecordRef, ShopifyVariant.FieldNo("Option 3 Name"));
                            JsonHelper.GetValueIntoField(JItem, 'value', RecordRef, ShopifyVariant.FieldNo("Option 3 Value"));
                        end;
                end;
        end;
        RecordRef.SetTable(ShopifyVariant);
        ShopifyVariant."UoM Option Id" := 0;
        if Shop."UoM as Variant" then
            case Shop."Option Name for UoM" of
                ShopifyVariant."Option 1 Name":
                    ShopifyVariant."UoM Option Id" := 1;
                ShopifyVariant."Option 2 Name":
                    ShopifyVariant."UoM Option Id" := 2;
                ShopifyVariant."Option 3 Name":
                    ShopifyVariant."UoM Option Id" := 3;
            end;
        ShopifyVariant.Modify(false);

        if JsonHelper.GetJsonObject(JVariant, JNode, 'inventoryItem') then begin
            UpdatedAt := JsonHelper.GetValueAsDateTime(JNode, 'updatedAt');
            if UpdatedAt > ShopifyInventoryItem."Updated At" then begin
                Clear(RecordRef);
                RecordRef.GetTable(ShopifyInventoryItem);
                if ShopifyInventoryItem.Id = 0 then
                    JsonHelper.GetValueIntoField(JNode, 'legacyResourceId', RecordRef, ShopifyInventoryItem.FieldNo(Id));
                JsonHelper.GetValueIntoField(JNode, 'countryCodeOfOrigin', RecordRef, ShopifyInventoryItem.FieldNo("Country/Region of Origin"));
                JsonHelper.GetValueIntoField(JNode, 'createdAt', RecordRef, ShopifyInventoryItem.FieldNo("Create At"));
                JsonHelper.GetValueIntoField(JNode, 'inventoryHistoryUrl', RecordRef, ShopifyInventoryItem.FieldNo("History URL"));
                JsonHelper.GetValueIntoField(JNode, 'provinceCodeOfOrigin', RecordRef, ShopifyInventoryItem.FieldNo("Province of Origin"));
                JsonHelper.GetValueIntoField(JNode, 'requiresShipping', RecordRef, ShopifyInventoryItem.FieldNo("Requires Shipping"));
                JsonHelper.GetValueIntoField(JNode, 'tracked', RecordRef, ShopifyInventoryItem.FieldNo(Tracked));
                JsonHelper.GetValueIntoField(JNode, 'trackedEditable.locked', RecordRef, ShopifyInventoryItem.FieldNo("Tracked Editable"));
                JsonHelper.GetValueIntoField(JNode, 'trackedEditable.reason', RecordRef, ShopifyInventoryItem.FieldNo("Tracked Reason"));
                JsonHelper.GetValueIntoField(JNode, 'unitCost.amount', RecordRef, ShopifyInventoryItem.FieldNo("Unit Cost"));
                JsonHelper.GetValueIntoField(JNode, 'updatedAt', RecordRef, ShopifyInventoryItem.FieldNo("Updated At"));
                RecordRef.SetTable(ShopifyInventoryItem);
                if not ShopifyInventoryItem.Modify() then
                    ShopifyInventoryItem.Insert();
            end;
        end;
        if JsonHelper.GetJsonObject(JVariant, JNode, 'metafields') then
            if JsonHelper.GetJsonArray(JNode, JMetafields, 'edges') then
                MetafieldAPI.UpdateMetafieldsFromShopify(JMetafields, Database::"Shpfy Variant", ShopifyVariant.Id);
    end;
}