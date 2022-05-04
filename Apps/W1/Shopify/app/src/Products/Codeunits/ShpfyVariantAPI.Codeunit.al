/// <summary>
/// Codeunit Shpfy Variant API (ID 30189).
/// </summary>
codeunit 30189 "Shpfy Variant API"
{
    Access = Internal;

    var
        Shop: Record "Shpfy Shop";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JHelper: Codeunit "Shpfy Json Helper";
        Events: Codeunit "Shpfy Product Events";

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
        ImportProduct: Codeunit "Shpfy Product Import";

    begin
        Found := FindShopifyVariantBySKU(ShopifyVariant);
        if not Found then
            Found := FindShopifyVariantByBarcode(ShopifyVariant);
        if Found then begin
            ShopifyProduct.Id := ShopifyVariant."Product Id";
            if not Product.Get(ShopifyProduct.Id) then begin
                ImportProduct.SetShop(ShopifyProduct."Shop Code");
                ImportProduct.SetProduct(ShopifyProduct.Id);
                Commit();
                if ImportProduct.Run() then;
                if Product.Get(ShopifyProduct.Id) and IsNullGuid(Product."Item SystemId") then begin
                    Product."Item SystemId" := ShopifyProduct."Item SystemId";
                    Product.Modify();
                end;
            end;
            if Variant.Get(ShopifyVariant.Id) then
                if IsNullGuid(Variant."Item Variant SystemId") then begin
                    Variant."Item Variant SystemId" := ShopifyVariant."Item Variant SystemId";
                    Variant."Item SystemId" := ShopifyVariant."Item SystemId";
                    Variant.Modify();
                end
                else begin
                    Clear(Variant);
                    Variant := ShopifyVariant;
                    Variant.Insert();
                end;
        end;
    end;

    /// <summary> 
    /// Add Product Variant.
    /// </summary>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    internal procedure AddProductVariant(var ShopifyVariant: Record "Shpfy Variant")
    var
        ShopLocation: Record "Shpfy Shop Location";
        NewShopifyVariant: Record "Shpfy Variant";
        JResponse: JsonToken;
        GraphQuery: TextBuilder;
    begin
        Events.OnBeforeSendAddShopifyProductVariant(Shop, ShopifyVariant);
        GraphQuery.Append('{"query":"mutation { productVariantCreate(input: {productId: \"gid://shopify/Product/');
        GraphQuery.Append(Format(ShopifyVariant."Product Id"));
        GraphQuery.Append('\"');
        GraphQuery.Append(', inventoryPolicy: ');
        GraphQuery.Append(ShopifyVariant."Inventory Policy".Names.Get(ShopifyVariant."Inventory Policy".Ordinals.IndexOf(ShopifyVariant."Inventory Policy".AsInteger())));
        if ShopifyVariant.Title <> '' then begin
            GraphQuery.Append(', title: \"');
            GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(ShopifyVariant.Title));
            GraphQuery.Append('\"');
        end;
        if ShopifyVariant.Barcode <> '' then begin
            GraphQuery.Append(', barcode: \"');
            GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(ShopifyVariant.Barcode));
            GraphQuery.Append('\"');
        end;
        if ShopifyVariant.SKU <> '' then begin
            GraphQuery.Append(', sku: \"');
            GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(ShopifyVariant.SKU));
            GraphQuery.Append('\"');
        end;
        if ShopifyVariant.Taxable then
            GraphQuery.Append(', taxable: true');
        if ShopifyVariant."Tax Code" <> '' then begin
            GraphQuery.Append(', taxCode: \"');
            GraphQuery.Append(ShopifyVariant."Tax Code");
            GraphQuery.Append('\"');
        end;
        if ShopifyVariant.Weight > 0 then begin
            GraphQuery.Append(', weight: ');
            GraphQuery.Append(Format(ShopifyVariant.Weight, 0, 9));
        end;
        if ShopifyVariant.Price > 0 then begin
            GraphQuery.Append(', price: \"');
            GraphQuery.Append(Format(ShopifyVariant.Price, 0, 9));
            GraphQuery.Append('\"')
        end;
        if ShopifyVariant."Compare at Price" > ShopifyVariant.Price then begin
            GraphQuery.Append(', compareAtPrice: \"');
            GraphQuery.Append(Format(ShopifyVariant."Compare at Price", 0, 9));
            GraphQuery.Append('\"');
        end;
        GraphQuery.Append(', options: [\"');
        GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(ShopifyVariant."Option 1 Value"));
        if ShopifyVariant."Option 2 Name" <> '' then begin
            GraphQuery.Append('\", \"');
            GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(ShopifyVariant."Option 2 Value"));
        end;
        GraphQuery.Append('\"]');

        ShopLocation.SetRange("Shop Code", Shop.Code);
        ShopLocation.SetRange(Active, true);
        if ShopLocation.FindSet(false, false) then begin
            GraphQuery.Append(', inventoryQuantities: [');
            repeat
                GraphQuery.Append('{availableQuantity: 0, locationId: \"gid://shopify/Location/');
                GraphQuery.Append(Format(ShopLocation.Id));
                GraphQuery.Append('\"}, ');
            until ShopLocation.Next() = 0;
            GraphQuery.Remove(GraphQuery.Length - 1, 2);
            GraphQuery.Append(']');
        end;

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
        GraphQuery.Append('}}) {productVariant {id, legacyResourceId}}}"}');

        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQuery.ToText());
        NewShopifyVariant := ShopifyVariant;
        NewShopifyVariant.Id := JHelper.GetValueAsBigInteger(JResponse, 'data.productVariantCreate.productVariant.legacyResourceId');
        if NewShopifyVariant.Id > 0 then
            NewShopifyVariant.Insert();
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

        Parameters.Add('Barcode', ShopifyVariant.Barcode);
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType::FindVariantByBarcode, Parameters);
        if JHelper.GetJsonArray(JResponse, JArray, 'data.productVariants.edges') then
            if JArray.Count = 1 then
                if JArray.Get(0, JItem) then begin
                    ShopifyVariant.Id := JHelper.GetValueAsBigInteger(JItem, 'node.legacyResourceId');
                    ShopifyVariant."Product Id" := JHelper.GetValueAsBigInteger(JItem, 'node.product.legacyResourceId');
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

        Parameters.Add('SKU', ShopifyVariant.SKU);
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType::FindVariantBySKU, Parameters);
        if JHelper.GetJsonArray(JResponse, JArray, 'data.productVariants.edges') then
            if JArray.Count = 1 then
                if JArray.Get(0, JItem) then begin
                    ShopifyVariant.Id := JHelper.GetValueAsBigInteger(JItem, 'node.legacyResourceId');
                    ShopifyVariant."Product Id" := JHelper.GetValueAsBigInteger(JItem, 'node.product.legacyResourceId');
                    exit(true);
                end;
    end;

    /// <summary> 
    /// Description for GetImageData.
    /// </summary>
    /// <param name="JImageNode">Parameter of type JsonToken.</param>
    /// <param name="ImageData">Parameter of type Dictionary of [BigInteger, Text].</param>
    local procedure GetImageData(JImageNode: JsonObject; var ImageData: Dictionary of [BigInteger, Text])
    var
        Data: Dictionary of [BigInteger, Text];
    begin
        Data.Add(CommunicationMgt.GetIdOfGId(JHelper.GetValueAsText(JImageNode, 'id')), JHelper.GetValueAsText(JImageNode, 'transformedSrc'));
        ImageData := Data;
    end;

    /// <summary> 
    /// Description for RetrieveShopifyProductVaraintImages.
    /// </summary>
    /// <param name="ProductVariantImages">Parameter of type Dictionary of [BigInteger, Dictionary of [BigInteger, Text]].</param>
    internal procedure RetrieveShopifyProductVaraintImages(var ProductVariantImages: Dictionary of [BigInteger, Dictionary of [BigInteger, Text]])
    var
        Id: BigInteger;
        ImageData: Dictionary of [BigInteger, Text];
        Parameters: Dictionary of [Text, Text];
        GraphQLType: Enum "Shpfy GraphQL Type";
        JProductVariants: JsonArray;
        JImage: JsonObject;
        JNode: JsonObject;
        JItem: JsonToken;
        JResponse: JsonToken;
        Cursor: Text;
    begin
        Clear(ProductVariantImages);
        GraphQLType := GraphQLType::GetProductVariantImages;
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            if JHelper.GetJsonArray(JResponse, JProductVariants, 'data.productVariants.edges') then begin
                foreach JItem in JProductVariants do begin
                    Cursor := JHelper.GetValueAsText(JItem.AsObject(), 'cursor');
                    if JHelper.GetJsonObject(JItem.AsObject(), JNode, 'node') then begin
                        Id := JHelper.GetValueAsBigInteger(JNode, 'legacyResourceId');
                        if JHelper.GetJsonObject(JNode, JImage, 'image') then begin
                            GetImageData(JImage, ImageData);
                            ProductVariantImages.Add(Id, ImageData);
                        end;
                    end;
                end;
                if Parameters.ContainsKey('After') then
                    Parameters.Set('After', Cursor)
                else
                    Parameters.Add('After', Cursor);
            end;
            GraphQLType := GraphQLType::GetNextProductVariantImages;
        until not JHelper.GetValueAsBoolean(JResponse, 'data.productVariants.pageInfo.hasNextPage');
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
            if JHelper.GetJsonArray(JResponse, JVariants, 'data.product.variants.edges') then begin
                foreach JItem in JVariants do begin
                    Cursor := JHelper.GetValueAsText(JItem.AsObject(), 'cursor');
                    if JHelper.GetJsonObject(JItem.AsObject(), JNode, 'node') then begin
                        Id := JHelper.GetValueAsBigInteger(JNode, 'legacyResourceId');
                        UpdatedAt := JHelper.GetValueAsDateTime(JNode, 'updatedAt');
                        ProductVariantIds.Add(Id, UpdatedAt);
                    end;
                end;
                GraphQLType := GraphQLType::GetNextProductVariantIds;
                if Parameters.ContainsKey('After') then
                    Parameters.Set('After', Cursor)
                else
                    Parameters.Add('After', Cursor);
            end;
        until not JHelper.GetValueAsBoolean(JResponse, 'data.product.variants.pageInfo.hasNextPage');
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
        if JHelper.GetJsonObject(JResponse.AsObject(), JData, 'data.productVariant') then
            exit(UpdateShopifyVariantFields(ShopifyProduct, ShopifyVariant, ShopifyInventoryItem, JData));
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="Code">Parameter of type Code[20].</param>
    internal procedure SetShop(Code: Code[20])
    begin
        Clear(Shop);
        Shop.Get(Code);
        CommunicationMgt.SetShop(Shop);
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
        CommunicationMgt.SetShop(Shop);
    end;

    /// <summary> 
    /// Update Product Variant.
    /// </summary>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="xShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    internal procedure UpdateProductVariant(ShopifyVariant: Record "Shpfy Variant"; xShopifyVariant: Record "Shpfy Variant")
    var
        HasChange: Boolean;
        JResponse: JsonToken;
        GraphQuery: TextBuilder;
    begin
        Events.OnBeforeSendUpdateShopifyProductVariant(Shop, ShopifyVariant, xShopifyVariant);
        GraphQuery.Append('{"query":"mutation { productVariantUpdate(input: {id: \"gid://shopify/ProductVariant/');
        GraphQuery.Append(Format(ShopifyVariant.Id));
        GraphQuery.Append('\"');
        if ShopifyVariant."Inventory Policy" <> xShopifyVariant."Inventory Policy" then begin
            HasChange := true;
            GraphQuery.Append(', inventoryPolicy: ');
            GraphQuery.Append(ShopifyVariant."Inventory Policy".Names.Get(ShopifyVariant."Inventory Policy".Ordinals.IndexOf(ShopifyVariant."Inventory Policy".AsInteger())));
        end;
        if ShopifyVariant.Title <> xShopifyVariant.Title then begin
            HasChange := true;
            GraphQuery.Append(', title: \"');
            GraphQuery.Append(ShopifyVariant.Title);
            GraphQuery.Append('\"');
        end;
        if ShopifyVariant.Barcode <> xShopifyVariant.Barcode then begin
            HasChange := true;
            GraphQuery.Append(', barcode: \"');
            GraphQuery.Append(ShopifyVariant.Barcode);
            GraphQuery.Append('\"');
        end;
        if ShopifyVariant.SKU <> xShopifyVariant.SKU then begin
            HasChange := true;
            GraphQuery.Append(', sku: \"');
            GraphQuery.Append(ShopifyVariant.SKU);
            GraphQuery.Append('\"');
        end;
        if ShopifyVariant."Tax Code" <> xShopifyVariant."Tax Code" then begin
            HasChange := true;
            GraphQuery.Append(', taxCode: \"');
            GraphQuery.Append(ShopifyVariant."Tax Code");
            GraphQuery.Append('\"');
        end;
        if ShopifyVariant.Weight <> xShopifyVariant.Weight then begin
            HasChange := true;
            GraphQuery.Append(', weight: ');
            GraphQuery.Append(Format(ShopifyVariant.Weight, 0, 9));
        end;
        if ShopifyVariant.Price <> xShopifyVariant.Price then begin
            HasChange := true;
            GraphQuery.Append(', price: \"');
            GraphQuery.Append(Format(ShopifyVariant.Price, 0, 9));
            GraphQuery.Append('\"')
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
        if ShopifyVariant."Unit Cost" <> xShopifyVariant."Unit Cost" then begin
            GraphQuery.Append(', inventoryItem: {cost: \"');
            GraphQuery.Append(Format(ShopifyVariant."Unit Cost", 0, 9));
            GraphQuery.Append('\"}');
        end;

        GraphQuery.Append('}) {productVariant {updatedAt}}}"}');

        if HasChange then begin
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQuery.ToText());
            ShopifyVariant."Updated At" := JHelper.GetValueAsDateTime(JResponse, 'data.productVariantUpdate.productVariant.updatedAt');
            if ShopifyVariant."Updated At" > 0DT then
                ShopifyVariant.Modify();
        end;
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
        RecRef: RecordRef;
        UpdatedAt: DateTime;
        JMetafields: JsonArray;
        JOptions: JsonArray;
        JNode: JsonObject;
        JItem: JsonToken;
    begin
        UpdatedAt := JHelper.GetValueAsDateTime(JVariant, 'updatedAt');
        if UpdatedAt < ShopifyVariant."Updated At" then
            exit(false);

        Result := true;
        ShopifyVariant."Updated At" := UpdatedAt;
        ShopifyVariant."Created At" := JHelper.GetValueAsDateTime(JVariant, 'createdAt');
        if IsNullGuid(ShopifyVariant."Item SystemId") then
            ShopifyVariant."Item SystemId" := ShopifyProduct."Item SystemId";
        ShopifyVariant."Available For Sales" := JHelper.GetValueAsBoolean(JVariant, 'availableForSale');
#pragma warning disable AA0139
        ShopifyVariant.Barcode := JHelper.GetValueAsText(JVariant, 'barcode', MaxStrLen(ShopifyVariant.Barcode));
        ShopifyVariant."Display Name" := JHelper.GetValueAsText(JVariant, 'displayName', MaxStrLen(ShopifyVariant."Display Name"));
        ShopifyVariant."Tax Code" := JHelper.GetValueAsText(JVariant, 'taxCode', MaxStrLen(ShopifyVariant."Tax Code"));
        ShopifyVariant.SKU := JHelper.GetValueAsText(JVariant, 'sku', MaxStrLen(ShopifyVariant.SKU));
        ShopifyVariant.Title := JHelper.GetValueAsText(JVariant, 'title', MaxStrLen(ShopifyVariant.Title));
#pragma warning restore AA0139
        ShopifyVariant."Compare at Price" := JHelper.GetValueAsDecimal(JVariant, 'compareAtPrice');
        if Evaluate(ShopifyVariant."Inventory Policy", JHelper.GetValueAsText(JVariant, 'inventoryPolicy')) then;
        ShopifyVariant.Position := JHelper.GetValueAsInteger(JVariant, 'position');
        ShopifyVariant.Price := JHelper.GetValueAsDecimal(JVariant, 'price');
        ShopifyVariant.Taxable := JHelper.GetValueAsBoolean(JVariant, 'taxable');
        ShopifyVariant.Weight := JHelper.GetValueAsDecimal(JVariant, 'weight');
        ShopifyVariant."Unit Cost" := JHelper.GetValueAsDecimal(JVariant, 'inventoryItem.unitCost.amount');

        RecRef.GetTable(ShopifyVariant);
        Clear(ShopifyVariant."Option 1 Name");
        Clear(ShopifyVariant."Option 1 Value");
        Clear(ShopifyVariant."Option 2 Name");
        Clear(ShopifyVariant."Option 2 Value");
        Clear(ShopifyVariant."Option 3 Name");
        Clear(ShopifyVariant."Option 3 Value");
        if JHelper.GetJsonArray(JVariant, JOptions, 'selectedOptions') then begin
            Clear(JItem);
            foreach JItem in JOptions do
                case Joptions.IndexOf(JItem) of
                    0:
                        begin
                            JHelper.GetValueIntoField(JItem, 'name', RecRef, ShopifyVariant.FieldNo("Option 1 Name"));
                            JHelper.GetValueIntoField(JItem, 'value', RecRef, ShopifyVariant.FieldNo("Option 1 Value"));
                        end;
                    1:
                        begin
                            JHelper.GetValueIntoField(JItem, 'name', RecRef, ShopifyVariant.FieldNo("Option 2 Name"));
                            JHelper.GetValueIntoField(JItem, 'value', RecRef, ShopifyVariant.FieldNo("Option 2 Value"));
                        end;
                    2:
                        begin
                            JHelper.GetValueIntoField(JItem, 'name', RecRef, ShopifyVariant.FieldNo("Option 3 Name"));
                            JHelper.GetValueIntoField(JItem, 'value', RecRef, ShopifyVariant.FieldNo("Option 3 Value"));
                        end;
                end;
        end;
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
        RecRef.SetTable(ShopifyVariant);
        ShopifyVariant.Modify(false);

        if JHelper.GetJsonObject(JVariant, JNode, 'inventoryItem') then begin
            UpdatedAt := JHelper.GetValueAsDateTime(JNode, 'updatedAt');
            if UpdatedAt > ShopifyInventoryItem."Updated At" then begin
                Clear(RecRef);
                RecRef.GetTable(ShopifyInventoryItem);
                if ShopifyInventoryItem.Id = 0 then
                    JHelper.GetValueIntoField(JNode, 'legacyResourceId', RecRef, ShopifyInventoryItem.FieldNo(Id));
                JHelper.GetValueIntoField(JNode, 'countryCodeOfOrigin', RecRef, ShopifyInventoryItem.FieldNo("Country/Region of Origin"));
                JHelper.GetValueIntoField(JNode, 'createdAt', RecRef, ShopifyInventoryItem.FieldNo("Create At"));
                JHelper.GetValueIntoField(JNode, 'inventoryHistoryUrl', RecRef, ShopifyInventoryItem.FieldNo("History URL"));
                JHelper.GetValueIntoField(JNode, 'provinceCodeOfOrigin', RecRef, ShopifyInventoryItem.FieldNo("Province of Origin"));
                JHelper.GetValueIntoField(JNode, 'requiresShipping', RecRef, ShopifyInventoryItem.FieldNo("Requires Shipping"));
                JHelper.GetValueIntoField(JNode, 'tracked', RecRef, ShopifyInventoryItem.FieldNo(Tracked));
                JHelper.GetValueIntoField(JNode, 'trackedEditable.locked', RecRef, ShopifyInventoryItem.FieldNo("Tracked Editable"));
                JHelper.GetValueIntoField(JNode, 'trackedEditable.reason', RecRef, ShopifyInventoryItem.FieldNo("Tracked Reason"));
                JHelper.GetValueIntoField(JNode, 'unitCost.amount', RecRef, ShopifyInventoryItem.FieldNo("Unit Cost"));
                JHelper.GetValueIntoField(JNode, 'updatedAt', RecRef, ShopifyInventoryItem.FieldNo("Updated At"));
                RecRef.SetTable(ShopifyInventoryItem);
                if not ShopifyInventoryItem.Modify() then
                    ShopifyInventoryItem.Insert();
            end;
        end;
        if JHelper.GetJsonObject(JVariant, JNode, 'metafields') then
            if JHelper.GetJsonArray(JNode, JMetafields, 'edges') then
                foreach JItem in JMetafields do;
    end;
}