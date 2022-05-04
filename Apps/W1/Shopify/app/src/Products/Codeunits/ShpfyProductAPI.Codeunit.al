/// <summary>
/// Codeunit Shpfy Product API (ID 30176).
/// </summary>
codeunit 30176 "Shpfy Product API"
{
    Access = Internal;
    Permissions = tabledata Item = r;

    var
        Shop: Record "Shpfy Shop";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JHelper: Codeunit "Shpfy Json Helper";
        Events: Codeunit "Shpfy Product Events";
        VariantApi: Codeunit "Shpfy Variant API";

    /// <summary> 
    /// Create Shopify Product Image.
    /// </summary>
    /// <param name="Product">Parameter of type Record "Shopify Product".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <returns>Return value of type BigInteger.</returns>
    internal procedure CreateShopifyProductImage(Product: Record "Shpfy Product"; Item: Record Item): BigInteger
    var
        JResponse: JsonToken;
        Method: Text;
        Request: Text;
        Url: Text;
        ProductUrlTxt: Label 'products/%1/images.json', Comment = '%1 = Shopify product id', Locked = true;
        ProductImageUrlTxt: Label 'products/%1/images/%2.json', Comment = '%1 = Shopify product id, %2 = Shopify image id.', Locked = true;
    begin
        if Shop."Sync Item Images" = Shop."Sync Item Images"::"To Shopify" then
            if Item.Picture.Count > 0 then begin
                CreateProductImageAsJson(Item, Product.Id, Product."Image Id").WriteTo(Request);
                if Product."Image Id" = 0 then begin
                    Method := 'POST';
                    Url := CommunicationMgt.CreateWebRequestURL(StrSubstNo(ProductUrlTxt, Product.Id));
                end else begin
                    Method := 'PUT';
                    Url := CommunicationMgt.CreateWebRequestURL(StrSubstNo(ProductImageUrlTxt, Product.Id, Product."Image Id"));
                end;
                if JResponse.ReadFrom(CommunicationMgt.ExecuteWebRequest(Url, Method, Request)) then
                    exit(JHelper.GetValueAsBigInteger(JResponse, 'image.id'))
                else
                    exit(Product."Image Id");
            end else
                if Product."Image Id" > 0 then begin
                    Method := 'DELETE';
                    Url := CommunicationMgt.CreateWebRequestURL(StrSubstNo(ProductImageUrlTxt, Product.Id, Product."Image Id"));
                    CommunicationMgt.ExecuteWebRequest(Url, Method, Request);
                    exit(0);
                end;
    end;

    /// <summary> 
    /// Create Product.
    /// </summary>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    internal procedure CreateProduct(var ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant")
    var
        NewShopifyProduct: Record "Shpfy Product";
        ShopLocation: Record "Shpfy Shop Location";
        NewShopifyVariant: Record "Shpfy Variant";
        JArray: JsonArray;
        JResponse: JsonToken;
        JToken: JsonToken;
        Data: Text;
        GraphQuery: TextBuilder;

    begin
        ShopifyVariant.FindSet();
        Events.OnBeforeSendCreateShopifyProduct(Shop, ShopifyProduct, ShopifyVariant);
        GraphQuery.Append('{"query":"mutation {productCreate(input: {');
        GraphQuery.Append('title: \"');
        GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(ShopifyProduct.Title));
        GraphQuery.Append('\"');
        Data := ShopifyProduct.GetDescriptionHtml();
        if Data <> '' then begin
            GraphQuery.Append(', descriptionHtml: \"');
            GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(Data));
            GraphQuery.Append('\"');
        end;
        if ShopifyProduct."Product Type" <> '' then begin
            GraphQuery.Append(', productType: \"');
            GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(ShopifyProduct."Product Type"));
            GraphQuery.Append('\"');
        end;
        GraphQuery.Append(', status: ');
        GraphQuery.Append(ConvertToProductStatus(ShopifyProduct.Status));
        Data := ShopifyProduct.GetCommaSeperatedTags();
        if Data <> '' then begin
            GraphQuery.Append(', tags: \"');
            GraphQuery.Append(Data);
            GraphQuery.Append('\"');
        end;
        if ShopifyProduct.Vendor <> '' then begin
            GraphQuery.Append(', vendor: \"');
            GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(ShopifyProduct.Vendor));
            GraphQuery.Append('\"');
        end;
        if ShopifyProduct."Has Variants" or (ShopifyVariant."UoM Option Id" > 0) then begin
            GraphQuery.Append(', options: [\"');
            GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(ShopifyVariant."Option 1 Name"));
            if ShopifyVariant."Option 2 Name" <> '' then begin
                GraphQuery.Append('\", \"');
                GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(ShopifyVariant."Option 2 Name"));
            end;
            GraphQuery.Append('\"]');
        end;
        GraphQuery.Append(', published: true');
        GraphQuery.Append(', variants: {inventoryPolicy: ');
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
        if ShopifyProduct."Has Variants" or (ShopifyVariant."UoM Option Id" > 0) then begin
            GraphQuery.Append(', options: [\"');
            GraphQuery.Append(ShopifyVariant."Option 1 Value");
            if ShopifyVariant."Option 2 Name" <> '' then begin
                GraphQuery.Append('\", \"');
                GraphQuery.Append(ShopifyVariant."Option 2 Value");
            end;
            GraphQuery.Append('\"]');
        end;
        ShopLocation.SetRange("Shop Code", ShopifyProduct."Shop Code");
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
        GraphQuery.Append('}}}) ');

        GraphQuery.Append('{product {legacyResourceId, onlineStoreUrl, onlineStorePreviewUrl, createdAt, updatedAt, variants(first: 1) {edges {node {legacyResourceId, createdAt, updatedAt}}}}}');
        GraphQuery.Append('}"}');

        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQuery.ToText());
        NewShopifyProduct := ShopifyProduct;
        NewShopifyProduct.Id := JHelper.GetValueAsBigInteger(JResponse, 'data.productCreate.product.legacyResourceId');
        if NewShopifyProduct.Id = 0 then
            exit;
#pragma warning disable AA0139
        NewShopifyProduct."Preview URL" := JHelper.GetValueAsText(JResponse, 'data.productCreate.product.onlineStorePreviewUrl', MaxStrLen(NewShopifyProduct."Preview URL"));
        NewShopifyProduct.URL := JHelper.GetValueAsText(JResponse, 'data.productCreate.product.onlineStoreUrl', MaxStrLen(NewShopifyProduct.URL));
#pragma warning restore AA0139
        NewShopifyProduct."Created At" := JHelper.GetValueAsDateTime(JResponse, 'data.productCreate.product.createdAt');
        NewShopifyProduct."Updated At" := JHelper.GetValueAsDateTime(JResponse, 'data.productCreate.product.updatedAt');
        NewShopifyProduct.Insert();

        NewShopifyVariant := ShopifyVariant;
        NewShopifyVariant."Product Id" := NewShopifyProduct.Id;
        if JHelper.GetJsonArray(JResponse, JArray, 'data.productCreate.product.variants.edges') and JArray.Get(0, JToken) then begin
            NewShopifyVariant.Id := JHelper.GetValueAsBigInteger(JToken, 'edges.node.legacyResourceId');
            NewShopifyVariant."Created At" := JHelper.GetValueAsDateTime(JToken, 'edges.node.createdAt');
            NewShopifyVariant."Updated At" := JHelper.GetValueAsDateTime(JToken, 'edges.node.updatedAt');
            NewShopifyVariant.Insert();
        end;

        while ShopifyVariant.Next() > 0 do begin
            ShopifyVariant."Product Id" := NewShopifyProduct.Id;
            VariantApi.AddProductVariant(ShopifyVariant);
        end;

    end;

    /// <summary> 
    /// Create Product Image As Json.
    /// </summary>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ProductId">Parameter of type BigInteger.</param>
    /// <param name="ImageId">Parameter of type BigInteger.</param>
    /// <returns>Return variable "Result" of type JsonObject.</returns>
    internal procedure CreateProductImageAsJson(Item: Record Item; ProductId: BigInteger; ImageId: BigInteger) Result: JsonObject;
    var
        TenantMedia: Record "Tenant Media";
        MediaId: Guid;
        Image: JsonObject;
        ImageString: Text;
    begin
        if Item.Picture.Count > 0 then begin
            MediaId := Item.Picture.Item(1);
            if TenantMedia.Get(MediaId) then
                ImageString := CreateTenantMediaBase64String(TenantMedia);
        end;

        if ImageId <> 0 then
            Image.Add('id', ImageId)
        else
            Image.Add('position', 1);
        if ProductId <> 0 then
            Image.Add('product_id', ProductId);

        Image.Add('attachment', ImageString);
        Result.Add('image', Image);
    end;

    /// <summary> 
    /// Create Tenant Medi aBase64 String.
    /// </summary>
    /// <param name="TenantMedia">Parameter of type Record "Tenant Media".</param>
    /// <returns>Return value of type Text.</returns>
    local procedure CreateTenantMediaBase64String(TenantMedia: Record "Tenant Media"): Text;
    var
        Convert: Codeunit "Base64 Convert";
        InStream: InStream;
    begin
        TenantMedia.CalcFields(Content);
        if TenantMedia.Content.HasValue then begin
            TenantMedia.Content.CreateInStream(InStream);
            exit(Convert.ToBase64(InStream));
        end;
    end;

    /// <summary> 
    /// Get Image Data.
    /// </summary>
    /// <param name="JImageNode">Parameter of type JsonToken.</param>
    /// <param name="ImageData">Parameter of type Dictionary of [BigInteger, Text].</param>
    local procedure GetImageData(JImageNode: JsonToken; var ImageData: Dictionary of [BigInteger, Text])
    var
        Data: Dictionary of [BigInteger, Text];
    begin
        Data.Add(CommunicationMgt.GetIdOfGId(JHelper.GetValueAsText(JImageNode, 'node.id')), JHelper.GetValueAsText(JImageNode, 'node.transformedSrc'));
        ImageData := Data;
    end;

    /// <summary> 
    /// Retrieve Shopify Product.
    /// </summary>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <returns>Return value of type Boolean.</returns>
    internal procedure RetrieveShopifyProduct(var ShopifyProduct: Record "Shpfy Product"): Boolean
    var
        Parameters: Dictionary of [Text, Text];
        GraphQLType: Enum "Shpfy GraphQL Type";
        JProduct: JsonObject;
        JResponse: JsonToken;
    begin
        Parameters.Add('ProductId', Format(ShopifyProduct.Id));
        Parameters.add('MaxLengthDescription', Format(MaxStrLen(ShopifyProduct.Description)));
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType::GetProductById, Parameters);
        if JHelper.GetJsonObject(JResponse, JProduct, 'data.product') then
            exit(UpdateShopifyProductFields(ShopifyProduct, JProduct));
    end;


    /// <summary> 
    /// Retrieve Shopify Product Ids.
    /// </summary>
    /// <param name="ProductIds">Parameter of type Dictionary of [BigInteger, DateTime].</param>
    internal procedure RetrieveShopifyProductIds(var ProductIds: Dictionary of [BigInteger, DateTime])
    var
        Math: Codeunit "Shpfy Math";
        Id: BigInteger;
        LastSyncTime: DateTime;
        UpdatedAt: DateTime;
        Parameters: Dictionary of [Text, Text];
        GraphQLType: Enum "Shpfy GraphQL Type";
        JProducts: JsonArray;
        JNode: JsonObject;
        JItem: JsonToken;
        JResponse: JsonToken;
        Cursor: Text;
    begin
        Clear(ProductIds);
        GraphQLType := GraphQLType::GetProductIds;
        LastSyncTime := Shop.GetLastSyncTime("Shpfy Synchronization Type"::Products);
        if LastSyncTime > 0DT then
            Parameters.Add('Time', Format(LastSyncTime, 0, 9))
        else
            Parameters.Add('Time', '');
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            if JHelper.GetJsonArray(JResponse, JProducts, 'data.products.edges') then begin
                foreach JItem in JProducts do begin
                    Cursor := JHelper.GetValueAsText(JItem.AsObject(), 'cursor');
                    if JHelper.GetJsonObject(JItem.AsObject(), JNode, 'node') then begin
                        Id := CommunicationMgt.GetIdOfGId(JHelper.GetValueAsText(JNode, 'id'));
                        UpdatedAt := JHelper.GetValueAsDateTime(JNode, 'updatedAt');
                        if not ProductIds.ContainsKey(Id) then
                            ProductIds.Add(Id, UpdatedAt)
                        else
                            ProductIds.Set(Id, Math.Max(ProductIds.Get(Id), UpdatedAt));
                    end;
                end;
                GraphQLType := GraphQLType::GetNextProductIds;
                if Parameters.ContainsKey('After') then
                    Parameters.Set('After', Cursor)
                else
                    Parameters.Add('After', Cursor);
            end;
        until not JHelper.GetValueAsBoolean(JResponse, 'data.products.pageInfo.hasNextPage');
    end;

    /// <summary> 
    /// Retrieve Shopify Product Images.
    /// </summary>
    /// <param name="ProductImages">Parameter of type Dictionary of [BigInteger, Dictionary of [BigInteger, Text]].</param>
    internal procedure RetrieveShopifyProductImages(var ProductImages: Dictionary of [BigInteger, Dictionary of [BigInteger, Text]])
    var
        Id: BigInteger;
        ImageData: Dictionary of [BigInteger, Text];
        Parameters: Dictionary of [Text, Text];
        GraphQLType: Enum "Shpfy GraphQL Type";
        JImages: JsonArray;
        JProducts: JsonArray;
        JNode: JsonObject;
        JImage: JsonToken;
        JItem: JsonToken;
        JResponse: JsonToken;
        Cursor: Text;
    begin
        Clear(ProductImages);
        GraphQLType := GraphQLType::GetProductImages;
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            if JHelper.GetJsonArray(JResponse, JProducts, 'data.products.edges') then begin
                foreach JItem in JProducts do begin
                    Cursor := JHelper.GetValueAsText(JItem.AsObject(), 'cursor');
                    if JHelper.GetJsonObject(JItem.AsObject(), JNode, 'node') then begin
                        Id := JHelper.GetValueAsBigInteger(JNode, 'legacyResourceId');
                        if JHelper.GetJsonArray(JNode, JImages, 'images.edges') and (JImages.Count = 1) then begin
                            foreach JImage in JImages do
                                GetImageData(JImage, ImageData);
                            ProductImages.Add(Id, ImageData);
                        end;
                    end;
                end;
                if Parameters.ContainsKey('After') then
                    Parameters.Set('After', Cursor)
                else
                    Parameters.Add('After', Cursor);
            end;
            GraphQLType := GraphQLType::GetNextProductImages;
        until not JHelper.GetValueAsBoolean(JResponse, 'data.products.pageInfo.hasNextPage');
    end;

    /// <summary> 
    ///  Set Shop.
    /// </summary>
    /// <param name="Code">Parameter of type Code[20].</param>
    internal procedure SetShop(Code: Code[20])
    begin
        Clear(Shop);
        Shop.Get(Code);
        SetShop(Shop);
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
        VariantApi.SetShop(Shop);
        CommunicationMgt.SetShop(Shop);
    end;

    /// <summary> 
    /// Update Product.
    /// </summary>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="xShopifyProduct">Parameter of type Record "Shopify Product".</param>
    internal procedure UpdateProduct(var ShopifyProduct: Record "Shpfy Product"; var xShopifyProduct: Record "Shpfy Product")
    var
        JResponse: JsonToken;
        Data: Text;
        GraphQuery: TextBuilder;
    begin
        Events.OnBeforeSendUpdateShopifyProduct(Shop, ShopifyProduct, xShopifyProduct);
        GraphQuery.Append('{"query":"mutation {productUpdate(input: {id: \"gid://shopify/Product/');
        GraphQuery.Append(Format(ShopifyProduct.Id));
        GraphQuery.Append('\"');
        if ShopifyProduct.Title <> xShopifyProduct.Title then begin
            GraphQuery.Append(', title: \"');
            GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(ShopifyProduct.Title));
            GraphQuery.Append('\"');
        end;
        Data := ShopifyProduct.GetDescriptionHtml();
        if Data <> xShopifyProduct.GetDescriptionHtml() then begin
            GraphQuery.Append(', descriptionHtml: \"');
            GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(Data));
            GraphQuery.Append('\"');
        end;
        if ShopifyProduct."Product Type" <> xShopifyProduct."Product Type" then begin
            GraphQuery.Append(', productType: \"');
            GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(ShopifyProduct."Product Type"));
            GraphQuery.Append('\"');
        end;
        if ShopifyProduct.Status <> xShopifyProduct.Status then begin
            GraphQuery.Append(', status: ');
            GraphQuery.Append(ConvertToProductStatus(ShopifyProduct.Status));
        end;
        Data := ShopifyProduct.GetCommaSeperatedTags();
        GraphQuery.Append(', tags: \"');
        GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(Data));
        GraphQuery.Append('\"');
        if ShopifyProduct.Vendor <> xShopifyProduct.Vendor then begin
            GraphQuery.Append(', vendor: \"');
            GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(ShopifyProduct.Vendor));
            GraphQuery.Append('\"');
        end;
        if (ShopifyProduct."SEO Title" <> xShopifyProduct."SEO Title") or (ShopifyProduct."SEO Description" <> xShopifyProduct."SEO Description") then begin
            GraphQuery.Append(', seo: {');
            GraphQuery.Append('description: \"');
            GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(ShopifyProduct."SEO Description"));
            GraphQuery.Append('\", ');
            GraphQuery.Append('title: \"');
            GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(ShopifyProduct."SEO Title"));
            GraphQuery.Append('\", ');
            GraphQuery.Remove(GraphQuery.Length - 1, 2);
            GraphQuery.Append('}')
        end;
        GraphQuery.Append('}) ');
        GraphQuery.Append('{product {id, onlineStoreUrl, onlineStorePreviewUrl, updatedAt}}');
        GraphQuery.Append('}"}');

        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQuery.ToText());
#pragma warning disable AA0139
        ShopifyProduct."Preview URL" := JHelper.GetValueAsText(JResponse, 'data.productUpdate.product.onlineStorePreviewUrl', MaxStrLen(ShopifyProduct."Preview URL"));
        ShopifyProduct.URL := JHelper.GetValueAsText(JResponse, 'data.productUpdate.product.onlineStoreUrl', MaxStrLen(ShopifyProduct.URL));
#pragma warning restore AA0139
        ShopifyProduct."Updated At" := JHelper.GetValueAsDateTime(JResponse, 'data.productUpdate.product.updatedAt');
    end;

    /// <summary> 
    /// Update Shopify Product Fields.
    /// </summary>
    /// <param name="ShopifyProduct">Parameter of type record "Shopify Product".</param>
    /// <param name="JProduct">Parameter of type JsonObject.</param>
    /// <returns>Return variable "Result" of type Boolean.</returns>
    internal procedure UpdateShopifyProductFields(var ShopifyProduct: record "Shpfy Product"; JProduct: JsonObject) Result: Boolean
    var
        UpdatedAt: DateTime;
    begin
        UpdatedAt := JHelper.GetValueAsDateTime(JProduct, 'updatedAt');
        if UpdatedAt < ShopifyProduct."Updated At" then
            exit(false);

        Result := true;
        ShopifyProduct."Updated At" := UpdatedAt;
        ShopifyProduct."Created At" := JHelper.GetValueAsDateTime(JProduct, 'createdAt');
        ShopifyProduct."Has Variants" := not JHelper.GetValueAsBoolean(JProduct, 'hasOnlyDefaultVariant');
#pragma warning disable AA0139
        ShopifyProduct.Description := JHelper.GetValueAsText(JProduct, 'description', MaxStrLen(ShopifyProduct.Description));
#pragma warning restore AA0139
        ShopifyProduct.SetDescriptionHtml(JHelper.GetValueAsText(JProduct, 'descriptionHtml'));
#pragma warning disable AA0139
        ShopifyProduct."Preview URL" := JHelper.GetValueAsText(JProduct, 'onlineStorePreviewUrl', MaxStrLen(ShopifyProduct."Preview URL"));
        ShopifyProduct.URL := JHelper.GetValueAsText(JProduct, 'onlineStoreUrl', MaxStrLen(ShopifyProduct.URL));
        ShopifyProduct."Product Type" := JHelper.GetValueAsText(JProduct, 'productType', MaxStrLen(ShopifyProduct."Product Type"));
#pragma warning restore AA0139
        ShopifyProduct.UpdateTags(JHelper.GetArrayAsText(JProduct, 'tags'));
#pragma warning disable AA0139
        ShopifyProduct.Title := JHelper.GetValueAsText(JProduct, 'title', MaxStrLen(ShopifyProduct.Title));
        ShopifyProduct.Vendor := JHelper.GetValueAsText(JProduct, 'vendor', MaxStrLen(ShopifyProduct.Vendor));
        ShopifyProduct."SEO Description" := JHelper.GetValueAsText(JProduct, 'seo.description', MaxStrLen(ShopifyProduct."SEO Description"));
        ShopifyProduct."SEO Title" := JHelper.GetValueAsText(JProduct, 'seo.title', MaxStrLen(ShopifyProduct."SEO Title"));
#pragma warning restore AA0139
        ShopifyProduct.Status := ConvertToProductStatus(JHelper.GetValueAsText(JProduct, 'status'));
        ShopifyProduct.Modify(false);
    end;


    local procedure ConvertToProductStatus(Value: Text): Enum "Shpfy Product Status"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Product Status".Names().Contains(Value) then
            exit(Enum::"Shpfy Product Status".FromInteger(Enum::"Shpfy Product Status".Ordinals().Get(Enum::"Shpfy Product Status".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Product Status"::Active);
    end;

    local procedure ConvertToProductStatus(Value: Enum "Shpfy Product Status"): Text
    begin
        exit(Value.Names.Get(Value.Ordinals.IndexOf(Value.AsInteger())).ToUpper());
    end;
}